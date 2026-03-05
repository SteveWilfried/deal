import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/auth_flow.dart';
import '../detail_deal/detail_deal.dart';

// ─────────────────────────────────────────────
//  MODEL UTILISATEUR
// ─────────────────────────────────────────────
enum UserRole { buyer, seller, reseller }

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final String city;
  final UserRole role;
  final bool isVerified;
  final DateTime memberSince;
  final int totalDeals;
  final int totalSales;
  final int totalFavorites;
  final double rating;
  final int reviewCount;
  final int walletBalance; // FCFA
  final List<DealModel> myDeals;
  final List<DealModel> myFavorites;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.city,
    required this.role,
    this.isVerified = false,
    required this.memberSince,
    this.totalDeals = 0,
    this.totalSales = 0,
    this.totalFavorites = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.walletBalance = 0,
    this.myDeals = const [],
    this.myFavorites = const [],
  });
}

// ─────────────────────────────────────────────
//  DEMO DATA
// ─────────────────────────────────────────────
final _demoSeller = SellerModel(
  id: 'me',
  name: 'Steve Djomi',
  rating: 4.8,
  reviewCount: 34,
  totalDeals: 12,
  phone: '237655000001',
  isVerified: true,
  memberSince: DateTime(2024, 1, 10),
);

final _demoDeal1 = DealModel(
  id: 'my_001',
  title: 'iPhone 13 Pro 256Go',
  price: 280000,
  oldPrice: 320000,
  condition: 'Occasion',
  city: 'Douala',
  category: 'Électronique',
  description: 'iPhone 13 Pro en excellent état.',
  images: ['https://picsum.photos/seed/iphone/400/300'],
  isVerified: true,
  postedAt: DateTime.now().subtract(const Duration(days: 2)),
  views: 134,
  seller: _demoSeller,
);

final _demoDeal2 = DealModel(
  id: 'my_002',
  title: 'Canapé 3 places cuir marron',
  price: 85000,
  condition: 'Occasion',
  city: 'Yaoundé',
  category: 'Maison',
  description: 'Canapé en très bon état.',
  images: ['https://picsum.photos/seed/sofa/400/300'],
  postedAt: DateTime.now().subtract(const Duration(days: 5)),
  views: 67,
  seller: _demoSeller,
);

final kDemoProfile = UserProfile(
  id: 'user_me',
  name: 'Steve Djomi',
  phone: '+237 655 000 001',
  city: 'Douala',
  role: UserRole.seller,
  isVerified: true,
  memberSince: DateTime(2024, 1, 10),
  totalDeals: 12,
  totalSales: 8,
  totalFavorites: 23,
  rating: 4.8,
  reviewCount: 34,
  walletBalance: 47500,
  myDeals: [_demoDeal1, _demoDeal2],
  myFavorites: [_demoDeal1, _demoDeal2],
);

// ─────────────────────────────────────────────
//  PAGE PROFIL
// ─────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  final UserProfile? profile;
  const ProfilePage({super.key, this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final UserProfile _profile;
  late final TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile ?? kDemoProfile;
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() => _tabIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.seller:   return 'Vendeur';
      case UserRole.reseller: return 'Revendeur';
      case UserRole.buyer:    return 'Acheteur';
    }
  }

  String _formatPrice(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} FCFA';
  }

  String _memberDuration() {
    final months = DateTime.now().difference(_profile.memberSince).inDays ~/ 30;
    if (months < 1)  return 'Membre récent';
    if (months < 12) return 'Membre depuis $months mois';
    return 'Membre depuis ${months ~/ 12} an(s)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStats()),
          if (_profile.role == UserRole.seller ||
              _profile.role == UserRole.reseller)
            SliverToBoxAdapter(child: _buildWallet()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDealsTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── HEADER ────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // ── Top row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mon Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white70),
                    onPressed: _openSettings,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Avatar + infos ──
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 78, height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cta, width: 3),
                          color: AppColors.cta.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            _profile.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (_profile.isVerified)
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                  BorderSide(color: AppColors.primary, width: 2)),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 13),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded,
                                  color: Color(0xFF4CAF50), size: 18),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.cta.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.cta.withOpacity(0.5)),
                              ),
                              child: Text(
                                _roleLabel(_profile.role),
                                style: const TextStyle(
                                  color: AppColors.cta,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(_profile.city,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white54, size: 13),
                            const SizedBox(width: 4),
                            Text(_memberDuration(),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Bouton modifier profil ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openEditProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.white70, size: 16),
                  label: const Text(
                    'Modifier mon profil',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────── STATS ────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(
              value: '${_profile.totalDeals}',
              label: 'Annonces',
              icon: Icons.sell_outlined,
              color: AppColors.cta,
            ),
            _Divider(),
            _StatItem(
              value: '${_profile.totalSales}',
              label: 'Ventes',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF2E7D32),
            ),
            _Divider(),
            _StatItem(
              value: '${_profile.rating}',
              label: 'Note',
              icon: Icons.star_outline_rounded,
              color: Colors.amber,
            ),
            _Divider(),
            _StatItem(
              value: '${_profile.totalFavorites}',
              label: 'Favoris',
              icon: Icons.favorite_outline_rounded,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── WALLET ────────────────────────
  Widget _buildWallet() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A5C), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône portefeuille
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.cta.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.cta, size: 26),
            ),
            const SizedBox(width: 14),

            // Solde
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mon Portefeuille',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(_profile.walletBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            // Bouton retrait
            ElevatedButton(
              onPressed: _openWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'Retirer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── TAB BAR ────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(3),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sell_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Mes annonces (${_profile.totalDeals})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_outline, size: 16),
                  const SizedBox(width: 6),
                  Text('Favoris (${_profile.totalFavorites})'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── ONGLET MES ANNONCES ────────────────────────
  Widget _buildDealsTab() {
    final deals = _profile.myDeals;
    if (deals.isEmpty) {
      return _EmptyState(
        icon: Icons.sell_outlined,
        title: 'Aucune annonce',
        subtitle: 'Publiez votre premier deal\net touchez des milliers d\'acheteurs.',
        actionLabel: 'Publier un deal',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: deals.length,
      itemBuilder: (_, i) => _MyDealCard(
        deal: deals[i],
        onEdit: () => _showSnack('Modifier "${deals[i].title}"'),
        onDelete: () => _showDeleteDialog(deals[i]),
        onView: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailPage(deal: deals[i])),
        ),
      ),
    );
  }

  // ──────────────────────── ONGLET FAVORIS ────────────────────────
  Widget _buildFavoritesTab() {
    final favs = _profile.myFavorites;
    if (favs.isEmpty) {
      return _EmptyState(
        icon: Icons.favorite_outline_rounded,
        title: 'Aucun favori',
        subtitle: 'Ajoutez des deals en favoris\npour les retrouver facilement.',
        actionLabel: 'Explorer les deals',
        onAction: () => Navigator.pop(context),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: favs.length,
      itemBuilder: (_, i) {
        final deal = favs[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailPage(deal: deal)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      children: [
                        Image.network(
                          deal.images.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE5E7EB),
                            child: const Icon(Icons.image_not_supported_outlined,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => _showSnack('Retiré des favoris'),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.favorite_rounded,
                                  color: Colors.red, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(deal.price),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cta),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(deal.city,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────── ACTIONS ────────────────────────
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(
        onLogout: _logout,
      ),
    );
  }

  void _openEditProfile() =>
      _showSnack('Modification du profil — à venir');

  void _openWithdraw() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WithdrawSheet(balance: _profile.walletBalance),
    );
  }

  void _showDeleteDialog(DealModel deal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer l\'annonce',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Voulez-vous vraiment supprimer "${deal.title}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Annonce supprimée');
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pop(context); // ferme settings
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthWelcomePage()),
      (_) => false,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ═══════════════════════════════════════════════
//  CARTE "MON DEAL"
// ═══════════════════════════════════════════════
class _MyDealCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _MyDealCard({
    required this.deal,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  String _formatPrice(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                deal.images.first,
                width: 80, height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80, height: 80,
                  color: const Color(0xFFE5E7EB),
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(deal.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.cta),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${deal.views} vues',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      // Badge vérifié
                      if (deal.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('✓ Vérifié',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                _IconAction(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: onEdit),
                const SizedBox(height: 8),
                _IconAction(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red,
                    onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHEET PARAMÈTRES
// ═══════════════════════════════════════════════
class _SettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const _SettingsSheet({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Paramètres',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Modifier le profil',
            onTap: () => Navigator.pop(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => Navigator.pop(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Confidentialité',
            onTap: () => Navigator.pop(context),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Aide & Support',
            onTap: () => Navigator.pop(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'CGU & Politique de confidentialité',
            onTap: () => Navigator.pop(context),
          ),

          const Divider(height: 24),

          // Déconnexion
          ListTile(
            onTap: onLogout,
            leading: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded,
                  color: Colors.red.shade700, size: 20),
            ),
            title: Text('Se déconnecter',
                style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHEET RETRAIT
// ═══════════════════════════════════════════════
class _WithdrawSheet extends StatefulWidget {
  final int balance;
  const _WithdrawSheet({required this.balance});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _amountCtl = TextEditingController();
  String _method = 'MTN MoMo';
  bool _loading = false;

  String _formatPrice(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Retirer des fonds',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('Solde disponible : ${_formatPrice(widget.balance)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),

            const SizedBox(height: 20),

            // Méthode
            const Text('Méthode de retrait',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary)),
            const SizedBox(height: 10),
            Row(
              children: ['MTN MoMo', 'Orange Money'].map((m) {
                final selected = _method == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        m,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Montant
            const Text('Montant (FCFA)',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Ex: 10000',
                suffixText: 'FCFA',
                suffixStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.cta, width: 2),
                ),
              ),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Demande de retrait envoyée !'),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ));
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Confirmer le retrait',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  WIDGETS UTILITAIRES
// ═══════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: const Color(0xFFE5E7EB));
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.cta.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.cta),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label,
          style:
              const TextStyle(fontSize: 14, color: AppColors.primary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textSecondary),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
