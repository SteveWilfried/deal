import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/services/deal_service.dart';
import '../../../core/config/app_config.dart';
import '../../widgets/deal_card.dart';
import '../detail_deal/detail_deal.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<DealModel> _favorites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (AppConfig.useRealBackend) {
        _favorites = await FavoriteService.instance.getFavorites();
      } else {
        // Mode démo — afficher quelques deals
        _favorites = await DealService.instance.getPopular(limit: 6);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des favoris';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeFavorite(DealModel deal) async {
    HapticFeedback.lightImpact();
    await FavoriteService.instance.removeFavorite(deal.id);
    setState(() => _favorites.removeWhere((d) => d.id == deal.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Retiré des favoris'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Annuler',
            textColor: AppColors.cta,
            onPressed: () async {
              await FavoriteService.instance.addFavorite(deal.id);
              setState(() => _favorites.insert(0, deal));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        actions: [
          if (_favorites.isNotEmpty)
            TextButton(
              onPressed: _loadFavorites,
              child: const Text(
                'Actualiser',
                style: TextStyle(color: AppColors.cta),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildSkeleton();
    if (_error != null) return _buildError();
    if (_favorites.isEmpty) return _buildEmpty();
    return _buildGrid();
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      color: AppColors.cta,
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _favorites.length,
        itemBuilder: (_, i) {
          final deal = _favorites[i];
          return Stack(
            children: [
              DealCard(
                title: deal.title,
                price: '${deal.price} FCFA',
                location: deal.city,
                image: deal.images.isNotEmpty ? deal.images[0] : '',
                isFlash: deal.isFlash,
                isVerified: deal.isVerified,
                isBoosted: deal.isBoosted,
                discountLabel: deal.oldPrice != null
                    ? '-${(((deal.oldPrice! - deal.price) / deal.oldPrice!) * 100).round()}%'
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(deal: deal),
                  ),
                ),
              ),
              // Bouton retirer favori
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeFavorite(deal),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cta.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: AppColors.cta,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez des deals à vos favoris\npour les retrouver ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFavorites,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: AppColors.surfaceAlt,
                  ),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 80, color: AppColors.surfaceAlt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
