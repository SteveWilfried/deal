import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../detail_deal/detail_deal.dart';
import '../publish/publish_deal_page.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class VendorStats {
  final int totalDeals;
  final int activeDeals;
  final int soldDeals;
  final int totalViews;
  final int totalContacts;
  final int walletBalance;
  final int pendingWithdraw;
  final double conversionRate;
  final List<MonthlyStat> monthlyStats;

  const VendorStats({
    required this.totalDeals,
    required this.activeDeals,
    required this.soldDeals,
    required this.totalViews,
    required this.totalContacts,
    required this.walletBalance,
    required this.pendingWithdraw,
    required this.conversionRate,
    required this.monthlyStats,
  });
}

class MonthlyStat {
  final String month;
  final int views;
  final int contacts;
  const MonthlyStat(this.month, this.views, this.contacts);
}

class ResellerLink {
  final String id;
  final String dealTitle;
  final String shortUrl;
  final int clicks;
  final int sales;
  final int commission; // FCFA
  const ResellerLink({
    required this.id,
    required this.dealTitle,
    required this.shortUrl,
    required this.clicks,
    required this.sales,
    required this.commission,
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

final kDemoStats = VendorStats(
  totalDeals: 12,
  activeDeals: 8,
  soldDeals: 4,
  totalViews: 3420,
  totalContacts: 187,
  walletBalance: 47500,
  pendingWithdraw: 12000,
  conversionRate: 5.5,
  monthlyStats: [
    MonthlyStat('Oct', 420, 22),
    MonthlyStat('Nov', 610, 35),
    MonthlyStat('Déc', 890, 51),
    MonthlyStat('Jan', 740, 43),
    MonthlyStat('Fév', 980, 62),
    MonthlyStat('Mar', 1120, 71),
  ],
);

final kDemoDeals = [
  DealModel(
    id: 'd1', title: 'iPhone 13 Pro 256Go', price: 280000, oldPrice: 320000,
    condition: 'Occasion', city: 'Douala', category: 'Électronique',
    description: '', images: ['https://picsum.photos/seed/ip13/400/300'],
    isVerified: true, isFlash: true,
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
    views: 1240, seller: _demoSeller,
  ),
  DealModel(
    id: 'd2', title: 'Canapé cuir 3 places', price: 85000,
    condition: 'Occasion', city: 'Yaoundé', category: 'Maison',
    description: '', images: ['https://picsum.photos/seed/sofa2/400/300'],
    postedAt: DateTime.now().subtract(const Duration(days: 5)),
    views: 430, seller: _demoSeller,
  ),
  DealModel(
    id: 'd3', title: 'Samsung Galaxy A14 128Go', price: 95000, oldPrice: 120000,
    condition: 'Neuf', city: 'Douala', category: 'Électronique',
    description: '', images: ['https://picsum.photos/seed/sams/400/300'],
    availableForResell: true,
    postedAt: DateTime.now().subtract(const Duration(days: 8)),
    views: 876, seller: _demoSeller,
  ),
  DealModel(
    id: 'd4', title: 'Moto Bajaj Boxer 150cc', price: 450000,
    condition: 'Occasion', city: 'Douala', category: 'Auto / Moto',
    description: '', images: ['https://picsum.photos/seed/moto/400/300'],
    postedAt: DateTime.now().subtract(const Duration(days: 12)),
    views: 210, seller: _demoSeller,
  ),
];

final kDemoResellerLinks = [
  ResellerLink(
    id: 'r1', dealTitle: 'Samsung Galaxy A14',
    shortUrl: 'ndokoti.cm/r/abc123',
    clicks: 142, sales: 3, commission: 15000,
  ),
  ResellerLink(
    id: 'r2', dealTitle: 'iPhone 13 Pro',
    shortUrl: 'ndokoti.cm/r/xyz456',
    clicks: 89, sales: 1, commission: 8000,
  ),
];

// ─────────────────────────────────────────────
//  PAGE DASHBOARD
// ─────────────────────────────────────────────
class VendorDashboardPage extends StatefulWidget {
  final VendorStats? stats;
  final List<DealModel>? deals;
  final List<ResellerLink>? resellerLinks;

  const VendorDashboardPage({
    super.key,
    this.stats,
    this.deals,
    this.resellerLinks,
  });

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage>
    with SingleTickerProviderStateMixin {
  late final VendorStats _stats;
  late final List<DealModel> _deals;
  late final List<ResellerLink> _resellerLinks;
  late final TabController _tabController;

  String _dealFilter = 'Tous'; // Tous | Actifs | Vendus

  @override
  void initState() {
    super.initState();
    _stats = widget.stats ?? kDemoStats;
    _deals = widget.deals ?? kDemoDeals;
    _resellerLinks = widget.resellerLinks ?? kDemoResellerLinks;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<DealModel> get _filteredDeals {
    switch (_dealFilter) {
      case 'Actifs': return _deals.take(3).toList();
      case 'Vendus': return _deals.skip(3).toList();
      default:       return _deals;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildKpiRow()),
          SliverToBoxAdapter(child: _buildWalletCard()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDealsTab(),
            _buildStatsTab(),
            _buildResellerTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishDealPage()),
        ),
        backgroundColor: AppColors.cta,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau deal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ──────────────────────── HEADER ────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dashboard Vendeur',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      const Text('Steve Djomi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Notifications
                  Stack(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.cta, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Résumé rapide ──
              Row(
                children: [
                  _HeaderChip(
                    icon: Icons.sell_outlined,
                    label: '${_stats.activeDeals} annonces actives',
                  ),
                  const SizedBox(width: 10),
                  _HeaderChip(
                    icon: Icons.star_outline,
                    label: '4.8 ★ (34 avis)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────── KPI ROW ────────────────────────
  Widget _buildKpiRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _KpiCard(
            label: 'Vues totales',
            value: '${_stats.totalViews}',
            icon: Icons.visibility_outlined,
            color: const Color(0xFF1565C0),
            bg: const Color(0xFFE3F2FD),
            delta: '+18%',
            deltaUp: true,
          ),
          const SizedBox(width: 12),
          _KpiCard(
            label: 'Contacts reçus',
            value: '${_stats.totalContacts}',
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFE8F5E9),
            delta: '+12%',
            deltaUp: true,
          ),
          const SizedBox(width: 12),
          _KpiCard(
            label: 'Taux contact',
            value: '${_stats.conversionRate}%',
            icon: Icons.trending_up_rounded,
            color: AppColors.cta,
            bg: const Color(0xFFFFF3E0),
            delta: '+0.3%',
            deltaUp: true,
          ),
        ],
      ),
    );
  }

  // ──────────────────────── WALLET ────────────────────────
  Widget _buildWalletCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A5C), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cta.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.cta, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Portefeuille Ndokoti',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(_stats.walletBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton retrait
                ElevatedButton(
                  onPressed: () => _showWithdrawSheet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Retirer',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),

            // Détails
            Row(
              children: [
                _WalletDetail(
                  label: 'En attente',
                  value: _formatPrice(_stats.pendingWithdraw),
                  icon: Icons.hourglass_top_rounded,
                ),
                _WalletDetail(
                  label: 'Ventes réalisées',
                  value: '${_stats.soldDeals}',
                  icon: Icons.check_circle_outline,
                ),
                _WalletDetail(
                  label: 'Commission revendeurs',
                  value: _formatPrice(23000),
                  icon: Icons.people_outline,
                ),
              ],
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
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(3),
          tabs: const [
            Tab(text: '📋  Annonces'),
            Tab(text: '📊  Stats'),
            Tab(text: '🔄  Revendeurs'),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  ONGLET 1 — ANNONCES
  // ══════════════════════════════════════════════
  Widget _buildDealsTab() {
    return Column(
      children: [
        // Filtres
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: ['Tous', 'Actifs', 'Vendus'].map((f) {
              final selected = _dealFilter == f;
              return GestureDetector(
                onTap: () => setState(() => _dealFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      )),
                ),
              );
            }).toList(),
          ),
        ),

        // Liste
        Expanded(
          child: _filteredDeals.isEmpty
              ? _buildEmptyDeals()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _filteredDeals.length,
                  itemBuilder: (_, i) =>
                      _VendorDealCard(deal: _filteredDeals[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDeals() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sell_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            _dealFilter == 'Vendus'
                ? 'Aucune vente pour le moment'
                : 'Aucune annonce active',
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  ONGLET 2 — STATISTIQUES
  // ══════════════════════════════════════════════
  Widget _buildStatsTab() {
    final maxViews = _stats.monthlyStats
        .map((s) => s.views)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Résumé performance ──
          const Text('Performance globale',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBig(label: 'Annonces publiées', value: '${_stats.totalDeals}',
                  color: AppColors.cta),
              const SizedBox(width: 12),
              _StatBig(label: 'Taux de contact', value: '${_stats.conversionRate}%',
                  color: const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBig(label: 'Vues totales', value: '${_stats.totalViews}',
                  color: const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _StatBig(label: 'Contacts reçus', value: '${_stats.totalContacts}',
                  color: const Color(0xFF7B1FA2)),
            ],
          ),

          const SizedBox(height: 24),

          // ── Graphe vues par mois ──
          const Text('Vues par mois',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _stats.monthlyStats.map((s) {
                      final heightRatio = s.views / maxViews;
                      final isLast = s == _stats.monthlyStats.last;
                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${s.views}',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isLast
                                          ? AppColors.cta
                                          : AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                height: 120 * heightRatio,
                                decoration: BoxDecoration(
                                  color: isLast
                                      ? AppColors.cta
                                      : AppColors.primary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _stats.monthlyStats.map((s) {
                    return Expanded(
                      child: Text(s.month,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Top annonces ──
          const Text('Top annonces',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          ..._deals.take(3).map((d) => _TopDealRow(deal: d)),

          const SizedBox(height: 24),

          // ── Conseils ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 18),
                  SizedBox(width: 8),
                  Text('Conseils pour booster vos ventes',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary)),
                ]),
                SizedBox(height: 10),
                _TipRow(text: 'Ajoutez 5+ photos à chaque annonce'),
                _TipRow(text: 'Répondez aux contacts en moins de 1h'),
                _TipRow(text: 'Activez l\'option Revendeur pour plus de visibilité'),
                _TipRow(text: 'Publiez le matin entre 7h et 10h'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  ONGLET 3 — PROGRAMME REVENDEUR
  // ══════════════════════════════════════════════
  Widget _buildResellerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Bannière programme ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Programme Revendeur',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 6),
                      Text(
                        'Vos revendeurs génèrent des ventes\npendant que vous dormez.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.people_alt_rounded,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats revendeur ──
          Row(
            children: [
              _ResellerStat(
                  label: 'Revendeurs actifs',
                  value: '7',
                  icon: Icons.person_outline,
                  color: const Color(0xFF7B1FA2)),
              const SizedBox(width: 12),
              _ResellerStat(
                  label: 'Liens cliqués',
                  value: '${_resellerLinks.fold(0, (s, l) => s + l.clicks)}',
                  icon: Icons.link_rounded,
                  color: const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _ResellerStat(
                  label: 'Commissions versées',
                  value: _formatPrice(
                      _resellerLinks.fold(0, (s, l) => s + l.commission)),
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF2E7D32)),
            ],
          ),

          const SizedBox(height: 20),

          // ── Liens revendeurs ──
          const Text('Liens de vos revendeurs',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 12),

          ..._resellerLinks.map((link) => _ResellerLinkCard(
                link: link,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: link.shortUrl));
                  _showSnack('Lien copié : ${link.shortUrl}');
                },
              )),

          const SizedBox(height: 20),

          // ── Comment ça marche ──
          const Text('Comment ça marche ?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          _HowItWorksStep(
            step: '1',
            title: 'Activez la revente sur vos annonces',
            subtitle: 'Lors de la publication, activez le toggle "Permettre la revente".',
            color: AppColors.cta,
          ),
          _HowItWorksStep(
            step: '2',
            title: 'Les revendeurs listent votre produit',
            subtitle: 'Ils créent un lien traçable avec leur propre marge.',
            color: const Color(0xFF7B1FA2),
          ),
          _HowItWorksStep(
            step: '3',
            title: 'Vente conclue → vous êtes payé',
            subtitle: 'Le montant net (hors marge revendeur) arrive dans votre portefeuille.',
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── ACTIONS ────────────────────────
  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WithdrawSheet(balance: _stats.walletBalance),
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
//  WIDGET — CARTE DEAL VENDEUR
// ═══════════════════════════════════════════════
class _VendorDealCard extends StatelessWidget {
  final DealModel deal;
  const _VendorDealCard({required this.deal});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              deal.images.first,
              width: 72, height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72, height: 72,
                color: const Color(0xFFE5E7EB),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(_formatPrice(deal.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.cta)),
                const SizedBox(height: 6),
                // Métriques
                Row(
                  children: [
                    _MiniStat(icon: Icons.visibility_outlined, value: '${deal.views}'),
                    const SizedBox(width: 12),
                    _MiniStat(icon: Icons.chat_bubble_outline_rounded, value: '${(deal.views * 0.055).round()}'),
                    if (deal.availableForResell) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('🔄 Revendable',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7B1FA2))),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'view') {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetailPage(deal: deal)));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Voir l\'annonce'),
                ]),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ]),
              ),
              const PopupMenuItem(
                value: 'boost',
                child: Row(children: [
                  Icon(Icons.rocket_launch_rounded, size: 16, color: AppColors.cta),
                  SizedBox(width: 8),
                  Text('Booster', style: TextStyle(color: AppColors.cta)),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  WIDGET — LIEN REVENDEUR
// ═══════════════════════════════════════════════
class _ResellerLinkCard extends StatelessWidget {
  final ResellerLink link;
  final VoidCallback onCopy;
  const _ResellerLinkCard({required this.link, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(link.dealTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          // URL copiable
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(link.shortUrl,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.copy_rounded,
                      size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LinkStat(icon: Icons.touch_app_rounded,
                  label: '${link.clicks} clics'),
              const SizedBox(width: 16),
              _LinkStat(icon: Icons.check_circle_outline,
                  label: '${link.sales} ventes'),
              const Spacer(),
              Text('+ ${link.commission} FCFA',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF2E7D32))),
            ],
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

  String _fmt(int n) {
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Retrait de fonds',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('Solde disponible : ${_fmt(widget.balance)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            const Text('Méthode',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary)),
            const SizedBox(height: 10),
            Row(
              children: ['MTN MoMo', 'Orange Money'].map((m) {
                final sel = _method == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB)),
                      ),
                      child: Text(m,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
                hintText: 'Ex: 10 000',
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
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.cta, width: 2)),
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
                            content: const Text('Demande envoyée ! Traitement sous 24h.'),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                          ));
                        }
                      },
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
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
//  PETITS WIDGETS
// ═══════════════════════════════════════════════
class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, delta;
  final IconData icon;
  final Color color, bg;
  final bool deltaUp;

  const _KpiCard({
    required this.label, required this.value, required this.delta,
    required this.icon, required this.color, required this.bg,
    required this.deltaUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(
                deltaUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 11,
                color: deltaUp ? const Color(0xFF2E7D32) : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(delta,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: deltaUp ? const Color(0xFF2E7D32) : Colors.red)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _WalletDetail extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _WalletDetail({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatBig extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBig({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 24, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TopDealRow extends StatelessWidget {
  final DealModel deal;
  const _TopDealRow({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, color: AppColors.cta, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(deal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary)),
          ),
          Text('${deal.views} vues',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ResellerStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ResellerStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: color),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LinkStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LinkStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String step, title, subtitle;
  final Color color;
  const _HowItWorksStep(
      {required this.step, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
