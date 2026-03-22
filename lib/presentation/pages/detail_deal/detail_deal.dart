import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/services/message_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/guest_service.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class SellerModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final int reviewCount;
  final int totalDeals;
  final String phone;
  final bool isVerified;
  final DateTime memberSince;

  const SellerModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.totalDeals,
    required this.phone,
    this.isVerified = false,
    required this.memberSince,
  });
}

class DealModel {
  final String id;
  final String title;
  final int price;
  final int? oldPrice;
  final String condition;
  final String city;
  final String description;
  final List<String> images;
  final String category;
  final bool isVerified;
  final bool isFlash;
  final bool isBoosted;
  final bool availableForResell;
  final DateTime postedAt;
  final int views;
  final SellerModel seller;

  const DealModel({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    required this.condition,
    required this.city,
    required this.description,
    required this.images,
    required this.category,
    this.isVerified = false,
    this.isFlash = false,
    this.isBoosted = false,
    this.availableForResell = false,
    required this.postedAt,
    this.views = 0,
    required this.seller,
  });
}

final kDemoDeal = DealModel(
  id: 'deal_001',
  title: 'Smartphone Samsung Galaxy A14 128Go',
  price: 95000,
  oldPrice: 120000,
  condition: 'Occasion',
  city: 'Douala',
  category: 'Electronique',
  description:
      'Smartphone Samsung Galaxy A14 en très bon état.\n\n'
      'Caractéristiques :\n'
      '• Ecran 6.6" Full HD+\n'
      '• 4 Go RAM / 128 Go stockage\n'
      '• Batterie 5000 mAh longue durée\n'
      '• Triple caméra 50MP\n'
      '• Android 13\n\n'
      'Inclus dans la vente :\n'
      '• Téléphone + chargeur d\'origine\n'
      '• Boîte d\'origine\n\n'
      'Raison de la vente : passage à un autre modèle.\n'
      'Disponible pour test sur place à Bonanjo, Douala.',
  images: [
    'https://picsum.photos/seed/phone1/600/500',
    'https://picsum.photos/seed/phone2/600/500',
    'https://picsum.photos/seed/phone3/600/500',
    'https://picsum.photos/seed/phone4/600/500',
  ],
  isVerified: true,
  isFlash: true,
  isBoosted: false,
  availableForResell: true,
  postedAt: DateTime(2025, 3, 5, 10, 0),
  views: 247,
  seller: SellerModel(
    id: 'seller_001',
    name: 'Boutique TechCam',
    rating: 4.7,
    reviewCount: 128,
    totalDeals: 54,
    phone: '237655123456',
    isVerified: true,
    memberSince: DateTime(2023, 3, 15),
  ),
);

// ─────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────
class ProductDetailPage extends StatefulWidget {
  final DealModel? deal;
  const ProductDetailPage({super.key, this.deal});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final DealModel _deal;
  final PageController _pageController = PageController();
  int _currentImage = 0;
  bool _isFavorite = false;
  bool _descExpanded = false;
  bool _loadingFavorite = false;
  bool _loadingMessage = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _deal = widget.deal ?? kDemoDeal;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
    _initFavorite();
  }

  Future<void> _initFavorite() async {
    if (!AppConfig.useRealBackend) return;
    final isFav = await FavoriteService.instance.checkFavorite(_deal.id);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    if (price == 0) return 'Prix à débattre';
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} FCFA';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jour(s)';
    return 'Il y a ${diff.inDays ~/ 7} semaine(s)';
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color ?? AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Toggle favori ─────────────────────────
  Future<void> _toggleFavorite() async {
    if (_loadingFavorite) return;
    if (!GuestService.instance.requireAuth(context, reason: 'Connectez-vous pour ajouter des annonces à vos favoris.')) return;
    HapticFeedback.lightImpact();
    _heartController.forward().then((_) => _heartController.reverse());

    if (!AppConfig.useRealBackend) {
      setState(() => _isFavorite = !_isFavorite);
      _showSnack(
        _isFavorite ? '❤️ Ajouté aux favoris' : 'Retiré des favoris',
        color: _isFavorite ? Colors.red : AppColors.primary,
      );
      return;
    }

    setState(() => _loadingFavorite = true);
    final result = await FavoriteService.instance.toggleFavorite(_deal.id);
    if (mounted) {
      setState(() {
        _isFavorite = result;
        _loadingFavorite = false;
      });
      _showSnack(
        result ? '❤️ Ajouté aux favoris' : 'Retiré des favoris',
        color: result ? Colors.red : AppColors.primary,
      );
    }
  }

  // ── Envoyer message ───────────────────────
  Future<void> _sendMessage() async {
    if (_loadingMessage) return;
    if (!GuestService.instance.requireAuth(context, reason: 'Connectez-vous pour envoyer un message au vendeur.')) return;
    HapticFeedback.mediumImpact();

    if (!AppConfig.useRealBackend) {
      _openWhatsApp();
      return;
    }

    setState(() => _loadingMessage = true);
    final convId = await MessageService.instance.startConversation(
      sellerId: _deal.seller.id,
      dealId: _deal.id,
      firstMessage: 'Bonjour, je suis intéressé par "${_deal.title}" à ${_formatPrice(_deal.price)}.',
    );
    if (mounted) {
      setState(() => _loadingMessage = false);
      if (convId != null) {
        _showSnack('✅ Message envoyé au vendeur');
      } else {
        _showSnack('❌ Erreur lors de l\'envoi du message');
      }
    }
  }

  void _openWhatsApp() {
    LauncherService.openWhatsApp(
      context: context,
      phone: _deal.seller.phone,
      message: LauncherService.buildDealMessage(
        dealTitle: _deal.title,
        price: _formatPrice(_deal.price),
        dealId: _deal.id,
      ),
    );
  }

  void _callSeller() {
    LauncherService.call(context: context, phone: _deal.seller.phone);
  }

  void _smsSeller() {
    LauncherService.sms(
      context: context,
      phone: _deal.seller.phone,
      body: 'Bonjour, je vous contacte via Ndokoti pour "${_deal.title}".',
    );
  }

  void _shareOffer() {
    LauncherService.openUrl(
      context: context,
      url: 'https://ndokoti.cm/deal/${_deal.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildCarousel()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBadges(),
                      const SizedBox(height: 12),
                      _buildPriceTitle(),
                      const SizedBox(height: 12),
                      _buildMeta(),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      _buildDescription(),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      _buildSellerCard(),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      _buildSafetyTips(),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingAppBar(),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Divider(color: Color(0xFFEEEEEE)),
  );

  // ── Carousel ──────────────────────────────
  Widget _buildCarousel() {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _deal.images.length,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemBuilder: (_, i) => Image.network(
              _deal.images[i],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cta, strokeWidth: 2,
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48, color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          // Gradient bas
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          // Indicateurs
          if (_deal.images.length > 1)
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_deal.images.length, (i) {
                  final active = i == _currentImage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          // Compteur
          Positioned(
            bottom: 14, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImage + 1}/${_deal.images.length}',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar flottant ───────────────────────
  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  // Bouton favori animé
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: AnimatedBuilder(
                      animation: _heartScale,
                      builder: (_, child) => Transform.scale(
                        scale: _heartScale.value,
                        child: child,
                      ),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _isFavorite
                              ? Colors.red.shade50
                              : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _loadingFavorite
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : Icon(
                                _isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isFavorite ? Colors.red : AppColors.primary,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CircleBtn(icon: Icons.share_rounded, onTap: _shareOffer),
                  const SizedBox(width: 8),
                  _CircleBtn(
                    icon: Icons.more_vert_rounded,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ReportSheet(onShare: _shareOffer),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Badges ────────────────────────────────
  Widget _buildBadges() {
    return Wrap(
      spacing: 8, runSpacing: 6,
      children: [
        if (_deal.isVerified)
          _Badge(label: '✓ Vérifié', color: const Color(0xFF1B5E20), bg: const Color(0xFFE8F5E9)),
        if (_deal.isFlash)
          _Badge(label: '⚡ Flash Deal', color: const Color(0xFFE65100), bg: const Color(0xFFFFF3E0)),
        if (_deal.isBoosted)
          _Badge(label: '🚀 Boosté', color: AppColors.primary, bg: const Color(0xFFE3F2FD)),
        _Badge(label: _deal.condition, color: AppColors.textSecondary, bg: const Color(0xFFF3F4F6)),
        if (_deal.availableForResell)
          _Badge(label: '🔄 Revendable', color: const Color(0xFF4A148C), bg: const Color(0xFFF3E5F5)),
      ],
    );
  }

  // ── Prix & titre ──────────────────────────
  Widget _buildPriceTitle() {
    final hasDiscount = _deal.oldPrice != null && _deal.oldPrice! > _deal.price;
    final discount = hasDiscount
        ? ((_deal.oldPrice! - _deal.price) / _deal.oldPrice! * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _deal.title,
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: AppColors.primary, height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatPrice(_deal.price),
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.cta,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  '-$discount%',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold, fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_deal.oldPrice != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatPrice(_deal.oldPrice!),
            style: const TextStyle(
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // ── Meta ──────────────────────────────────
  Widget _buildMeta() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(_deal.city, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 16),
        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(_timeAgo(_deal.postedAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('${_deal.views} vues', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  // ── Description ───────────────────────────
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _descExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Text(
            _deal.description,
            maxLines: 5, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.65),
          ),
          secondChild: Text(
            _deal.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.65),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _descExpanded = !_descExpanded),
          child: Row(
            children: [
              Text(
                _descExpanded ? 'Voir moins' : 'Voir plus',
                style: const TextStyle(
                  color: AppColors.cta, fontWeight: FontWeight.w600, fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _descExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.cta, size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Vendeur ───────────────────────────────
  Widget _buildSellerCard() {
    final s = _deal.seller;
    final yrs = DateTime.now().year - s.memberSince.year;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos du vendeur',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      s.avatarUrl != null
                          ? CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(s.avatarUrl!),
                            )
                          : CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.cta.withOpacity(0.15),
                              child: Text(
                                s.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold,
                                  color: AppColors.cta,
                                ),
                              ),
                            ),
                      if (s.isVerified)
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B5E20), shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (s.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: Color(0xFF1B5E20), size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                            const SizedBox(width: 3),
                            Text(
                              '${s.rating} (${s.reviewCount} avis)',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Profil',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _StatCol(label: 'Annonces', value: '${s.totalDeals}'),
                    Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                    _StatCol(label: 'Note', value: '${s.rating}/5'),
                    Container(width: 1, height: 30, color: const Color(0xFFE5E7EB)),
                    _StatCol(label: 'Membre', value: yrs > 0 ? '${yrs}an(s)' : 'Récent'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Conseils sécurité ─────────────────────
  Widget _buildSafetyTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [
            Icon(Icons.security_rounded, color: Color(0xFFF57F17), size: 18),
            SizedBox(width: 8),
            Text(
              'Conseils de sécurité Ndokoti',
              style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF57F17),
              ),
            ),
          ]),
          SizedBox(height: 8),
          _TipRow(text: 'Rencontrez le vendeur dans un lieu public'),
          _TipRow(text: 'Vérifiez le produit avant tout paiement'),
          _TipRow(text: 'Ne payez jamais à l\'avance sans voir l\'article'),
          _TipRow(text: 'Signalez tout vendeur suspect via le menu ⋮'),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          _BtnAction(icon: Icons.call_rounded, label: 'Appeler', onTap: _callSeller),
          const SizedBox(width: 8),
          // Bouton Message Ndokoti (si backend réel) ou SMS
          AppConfig.useRealBackend
              ? _BtnActionLoading(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Message',
                  loading: _loadingMessage,
                  onTap: _sendMessage,
                )
              : _BtnAction(icon: Icons.sms_rounded, label: 'SMS', onTap: _smsSeller),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _openWhatsApp,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  WIDGETS HELPER
// ═══════════════════════════════════════════════

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Badge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _BtnAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BtnAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _BtnActionLoading extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _BtnActionLoading({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFF57F17), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSheet extends StatelessWidget {
  final VoidCallback onShare;
  const _ReportSheet({required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: AppColors.primary),
            title: const Text('Partager l\'annonce'),
            onTap: () {
              Navigator.pop(context);
              onShare();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          ListTile(
            leading: const Icon(Icons.flag_rounded, color: Colors.orange),
            title: const Text('Signaler l\'annonce'),
            onTap: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          ListTile(
            leading: const Icon(Icons.block_rounded, color: Colors.red),
            title: const Text('Bloquer ce vendeur'),
            onTap: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }
}


// Alias pour compatibilité
typedef DetailDealPage = ProductDetailPage;
