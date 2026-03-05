import 'package:deal/presentation/pages/detail_deal/detail_deal.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/deal_service.dart';
import '../search/search_page.dart';
import '../../widgets/deal_card.dart';
import '../../widgets/category_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DealModel>> _dealsFuture;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.phone_iphone, 'label': 'Électronique'},
    {'icon': Icons.home, 'label': 'Immobilier'},
    {'icon': Icons.directions_car, 'label': 'Auto / Moto'},
    {'icon': Icons.design_services, 'label': 'Services'},
    {'icon': Icons.shopping_bag, 'label': 'Mode'},
    {'icon': Icons.weekend, 'label': 'Maison'},
    {'icon': Icons.sports_soccer, 'label': 'Loisirs'},
    {'icon': Icons.pets, 'label': 'Animaux'},
  ];

  @override
  void initState() {
    super.initState();
    _dealsFuture = DealService.instance.getDeals();
  }

  void _filterByCategory(String cat) {
    setState(() {
      _selectedCategory = _selectedCategory == cat ? null : cat;
      _dealsFuture = _selectedCategory != null
          ? DealService.instance.getByCategory(_selectedCategory!)
          : DealService.instance.getDeals();
    });
  }

  String _formatPrice(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '\$buf FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Barre de recherche ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  ),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        SizedBox(width: 10),
                        Expanded(child: Text('Rechercher un deal...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
                        Icon(Icons.tune_rounded, color: AppColors.cta),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Catégories ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text('Catégories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final selected = _selectedCategory == cat['label'];
                        return GestureDetector(
                          onTap: () => _filterByCategory(cat['label'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 72,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.primary : AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                                  ),
                                  child: Icon(cat['icon'] as IconData,
                                    color: selected ? Colors.white : AppColors.cta, size: 24),
                                ),
                                const SizedBox(height: 6),
                                Text(cat['label'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected ? AppColors.primary : AppColors.textSecondary,
                                  )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Titre section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory != null ? _selectedCategory! : 'Deals populaires',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
                      child: const Text('Voir tout', style: TextStyle(color: AppColors.cta, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Grille deals ──
            FutureBuilder<List<DealModel>>(
              future: _dealsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const _SkeletonDealCard(),
                        childCount: 6,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            const Text('Impossible de charger les deals', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const SizedBox(height: 8),
                            TextButton(onPressed: () => setState(() { _dealsFuture = DealService.instance.getDeals(forceRefresh: true); }), child: const Text('Réessayer')),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final deals = snapshot.data ?? [];
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final deal = deals[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(deal: deal))),
                          child: DealCard(
                            title: deal.title,
                            price: _formatPrice(deal.price),
                            location: deal.city,
                            image: deal.images.first,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(deal: deal))),
                          ),
                        );
                      },
                      childCount: deals.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton card ──
class _SkeletonDealCard extends StatelessWidget {
  const _SkeletonDealCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(child: Container(decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ))),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 10, color: const Color(0xFFE5E7EB)),
              const SizedBox(height: 6),
              Container(height: 10, width: 80, color: const Color(0xFFE5E7EB)),
              const SizedBox(height: 6),
              Container(height: 8, width: 60, color: const Color(0xFFE5E7EB)),
            ]),
          ),
        ],
      ),
    );
  }
}
