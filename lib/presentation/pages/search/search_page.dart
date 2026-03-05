import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/deal_service.dart';
import '../detail_deal/detail_deal.dart';

// ─────────────────────────────────────────────
//  MODÈLE FILTRE
// ─────────────────────────────────────────────
class SearchFilters {
  String query;
  String? category;
  String? city;
  int? minPrice;
  int? maxPrice;
  String? condition;   // Neuf | Occasion | Reconditionné
  String sortBy;       // recent | price_asc | price_desc | popular
  bool verifiedOnly;
  bool flashOnly;
  bool resellableOnly;

  SearchFilters({
    this.query = '',
    this.category,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.sortBy = 'recent',
    this.verifiedOnly = false,
    this.flashOnly = false,
    this.resellableOnly = false,
  });

  SearchFilters copyWith({
    String? query, String? category, String? city,
    int? minPrice, int? maxPrice, String? condition, String? sortBy,
    bool? verifiedOnly, bool? flashOnly, bool? resellableOnly,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: category,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      condition: condition,
      sortBy: sortBy ?? this.sortBy,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      flashOnly: flashOnly ?? this.flashOnly,
      resellableOnly: resellableOnly ?? this.resellableOnly,
    );
  }

  int get activeCount {
    int n = 0;
    if (category != null) n++;
    if (city != null) n++;
    if (minPrice != null || maxPrice != null) n++;
    if (condition != null) n++;
    if (verifiedOnly) n++;
    if (flashOnly) n++;
    if (resellableOnly) n++;
    return n;
  }

  bool get isEmpty =>
      query.isEmpty && category == null && city == null &&
      minPrice == null && maxPrice == null && condition == null &&
      !verifiedOnly && !flashOnly && !resellableOnly;
}

// ─────────────────────────────────────────────
//  DONNÉES DEMO
// ─────────────────────────────────────────────
final _demoSeller = SellerModel(
  id: 's1', name: 'TechCam', rating: 4.7, reviewCount: 128,
  totalDeals: 54, phone: '237655000001',
  isVerified: true, memberSince: DateTime(2023, 3, 15),
);

final List<DealModel> kAllDeals = [
  DealModel(id: '1', title: 'iPhone 13 Pro 256Go', price: 280000, oldPrice: 320000,
    condition: 'Occasion', city: 'Douala', category: 'Électronique',
    description: '', images: ['https://picsum.photos/seed/ip13/400/300'],
    isVerified: true, isFlash: true,
    postedAt: DateTime.now().subtract(const Duration(hours: 2)), views: 1240, seller: _demoSeller),
  DealModel(id: '2', title: 'Samsung Galaxy A14 128Go', price: 95000, oldPrice: 120000,
    condition: 'Neuf', city: 'Yaoundé', category: 'Électronique',
    description: '', images: ['https://picsum.photos/seed/sams/400/300'],
    availableForResell: true,
    postedAt: DateTime.now().subtract(const Duration(hours: 5)), views: 876, seller: _demoSeller),
  DealModel(id: '3', title: 'Canapé cuir 3 places', price: 85000,
    condition: 'Occasion', city: 'Douala', category: 'Maison',
    description: '', images: ['https://picsum.photos/seed/sofa/400/300'],
    postedAt: DateTime.now().subtract(const Duration(days: 1)), views: 430, seller: _demoSeller),
  DealModel(id: '4', title: 'Moto Bajaj Boxer 150cc', price: 450000,
    condition: 'Occasion', city: 'Douala', category: 'Auto / Moto',
    description: '', images: ['https://picsum.photos/seed/moto/400/300'],
    postedAt: DateTime.now().subtract(const Duration(days: 2)), views: 210, seller: _demoSeller),
  DealModel(id: '5', title: 'Appartement F3 Bonapriso', price: 250000,
    condition: 'Neuf', city: 'Douala', category: 'Immobilier',
    description: '', images: ['https://picsum.photos/seed/appt/400/300'],
    isVerified: true,
    postedAt: DateTime.now().subtract(const Duration(days: 3)), views: 580, seller: _demoSeller),
  DealModel(id: '6', title: 'Laptop HP Elitebook 840 G3', price: 180000,
    condition: 'Reconditionné', city: 'Yaoundé', category: 'Électronique',
    description: '', images: ['https://picsum.photos/seed/hp840/400/300'],
    isFlash: true,
    postedAt: DateTime.now().subtract(const Duration(days: 1)), views: 320, seller: _demoSeller),
  DealModel(id: '7', title: 'Robe de soirée taille 40', price: 15000,
    condition: 'Neuf', city: 'Douala', category: 'Mode',
    description: '', images: ['https://picsum.photos/seed/robe/400/300'],
    postedAt: DateTime.now().subtract(const Duration(hours: 8)), views: 95, seller: _demoSeller),
  DealModel(id: '8', title: 'Frigo Samsung 200L double porte', price: 120000,
    condition: 'Occasion', city: 'Garoua', category: 'Maison',
    description: '', images: ['https://picsum.photos/seed/frigo/400/300'],
    availableForResell: true,
    postedAt: DateTime.now().subtract(const Duration(days: 4)), views: 160, seller: _demoSeller),
];

const List<String> kCategories = [
  'Tous', 'Électronique', 'Immobilier', 'Auto / Moto',
  'Services', 'Mode', 'Maison', 'Emploi', 'Loisirs', 'Animaux',
];

const List<String> kCities = [
  'Toutes', 'Douala', 'Yaoundé', 'Bafoussam', 'Garoua',
  'Bamenda', 'Ngaoundéré', 'Bertoua', 'Libreville', 'Port-Gentil',
];

const List<Map<String, String>> kSortOptions = [
  {'value': 'recent',     'label': 'Plus récents'},
  {'value': 'popular',    'label': 'Plus populaires'},
  {'value': 'price_asc',  'label': 'Prix croissant'},
  {'value': 'price_desc', 'label': 'Prix décroissant'},
];

// ─────────────────────────────────────────────
//  PAGE RECHERCHE
// ─────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const SearchPage({super.key, this.initialQuery, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchFilters _filters;
  late TextEditingController _searchCtl;
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  List<DealModel> _results = [];
  List<String> _recentSearches = ['Samsung', 'iPhone', 'Moto', 'Canapé'];

  @override
  void initState() {
    super.initState();
    _filters = SearchFilters(
      query: widget.initialQuery ?? '',
      category: widget.initialCategory,
    );
    _searchCtl = TextEditingController(text: _filters.query);
    if (_filters.query.isNotEmpty || widget.initialCategory != null) {
      _runSearch();
    }
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Moteur de recherche — branché sur DealService (DummyJSON) ──
  void _runSearch() {
    setState(() => _isSearching = true);
    DealService.instance.search(
      query:          _filters.query,
      category:       _filters.category,
      city:           _filters.city,
      minPrice:       _filters.minPrice,
      maxPrice:       _filters.maxPrice,
      condition:      _filters.condition,
      sortBy:         _filters.sortBy,
      verifiedOnly:   _filters.verifiedOnly,
      flashOnly:      _filters.flashOnly,
      resellableOnly: _filters.resellableOnly,
      perPage:        50,
    ).then((results) {
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Erreur de chargement. Vérifiez votre connexion.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    });
  }

  void _onSubmit(String q) {
    if (q.trim().isEmpty) return;
    if (!_recentSearches.contains(q)) {
      setState(() => _recentSearches.insert(0, q));
    }
    setState(() => _filters.query = q);
    _runSearch();
  }

  void _clearSearch() {
    _searchCtl.clear();
    setState(() {
      _filters.query = '';
      _results = [];
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FiltersSheet(
        filters: _filters,
        onApply: (updated) {
          setState(() => _filters = updated);
          _runSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _results.isNotEmpty;
    final hasQuery = _filters.query.isNotEmpty || !_filters.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryChips(),
            if (hasQuery) _buildResultsHeader(),
            Expanded(
              child: _isSearching
                  ? _buildSkeleton()
                  : !hasQuery
                      ? _buildSuggestionsView()
                      : hasResults
                          ? _buildResultsGrid()
                          : _buildNoResults(),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── SEARCH BAR ────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtl,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: _onSubmit,
                decoration: InputDecoration(
                  hintText: 'Rechercher un deal...',
                  hintStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textSecondary),
                  suffixIcon: _searchCtl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 18),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) {
                  setState(() {});
                  if (v.length >= 2) {
                    setState(() => _filters.query = v);
                    _runSearch();
                  } else if (v.isEmpty) {
                    setState(() {
                      _filters.query = '';
                      _results = [];
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Bouton filtres
          GestureDetector(
            onTap: _openFilters,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _filters.activeCount > 0
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 10)
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.tune_rounded,
                      color: _filters.activeCount > 0
                          ? Colors.white
                          : AppColors.primary),
                  if (_filters.activeCount > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                            color: AppColors.cta, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${_filters.activeCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── CATEGORY CHIPS ────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: kCategories.length,
        itemBuilder: (_, i) {
          final cat = kCategories[i];
          final selected = (cat == 'Tous' && _filters.category == null) ||
              _filters.category == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _filters.category = cat == 'Tous' ? null : cat;
              });
              if (!_filters.isEmpty || _filters.query.isNotEmpty) _runSearch();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  )),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────── HEADER RÉSULTATS ────────────────────────
  Widget _buildResultsHeader() {
    final sortLabel = kSortOptions
        .firstWhere((s) => s['value'] == _filters.sortBy)['label']!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Text(
            '${_results.length} résultat${_results.length > 1 ? 's' : ''}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary),
          ),
          const Spacer(),
          // Tri
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(sortLabel,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── GRILLE RÉSULTATS ────────────────────────
  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _results.length,
      itemBuilder: (_, i) => _SearchDealCard(
        deal: _results[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailPage(deal: _results[i])),
        ),
      ),
    );
  }

  // ──────────────────────── SKELETON LOADING ────────────────────────
  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }

  // ──────────────────────── VUE SUGGESTIONS ────────────────────────
  Widget _buildSuggestionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recherches récentes
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recherches récentes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary)),
                TextButton(
                  onPressed: () =>
                      setState(() => _recentSearches.clear()),
                  child: const Text('Effacer',
                      style: TextStyle(color: AppColors.cta, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _recentSearches.map((r) => GestureDetector(
                onTap: () {
                  _searchCtl.text = r;
                  _onSubmit(r);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(r,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 28),
          ],

          // Suggestions tendances
          const Text('🔥 Tendances',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          ...[
            'Téléphones Samsung Douala',
            'Moto occasion Yaoundé',
            'Appartements à louer Bonapriso',
            'Laptops reconditionnés',
            'Frigos Samsung pas chers',
          ].map((t) => ListTile(
            onTap: () {
              _searchCtl.text = t;
              _onSubmit(t);
            },
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.cta.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.trending_up_rounded,
                  color: AppColors.cta, size: 18),
            ),
            title: Text(t,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.primary)),
            trailing: const Icon(Icons.north_west_rounded,
                size: 14, color: AppColors.textSecondary),
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
        ],
      ),
    );
  }

  // ──────────────────────── AUCUN RÉSULTAT ────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text('Aucun résultat',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'Aucun deal ne correspond à "${_filters.query}".\nEssayez d\'autres mots-clés ou modifiez les filtres.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _filters = SearchFilters();
                  _searchCtl.clear();
                  _results = [];
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 16),
              label: const Text('Réinitialiser',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── SORT SHEET ────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Trier par',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 12),
            ...kSortOptions.map((opt) {
              final selected = _filters.sortBy == opt['value'];
              return ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _filters.sortBy = opt['value']!);
                  _runSearch();
                },
                title: Text(opt['label']!,
                    style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary)),
                trailing: selected
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.cta)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHEET FILTRES AVANCÉS
// ═══════════════════════════════════════════════
class _FiltersSheet extends StatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onApply;

  const _FiltersSheet({required this.filters, required this.onApply});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late SearchFilters _f;
  late RangeValues _priceRange;

  static const double _maxPrice = 2000000;

  final _minCtl = TextEditingController();
  final _maxCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _f = widget.filters.copyWith(
      query: widget.filters.query,
      sortBy: widget.filters.sortBy,
      verifiedOnly: widget.filters.verifiedOnly,
      flashOnly: widget.filters.flashOnly,
      resellableOnly: widget.filters.resellableOnly,
    );
    _f.category = widget.filters.category;
    _f.city = widget.filters.city;
    _f.condition = widget.filters.condition;
    _f.minPrice = widget.filters.minPrice;
    _f.maxPrice = widget.filters.maxPrice;

    _priceRange = RangeValues(
      (_f.minPrice ?? 0).toDouble(),
      (_f.maxPrice?.toDouble() ?? _maxPrice),
    );
    if (_f.minPrice != null) _minCtl.text = '${_f.minPrice}';
    if (_f.maxPrice != null) _maxCtl.text = '${_f.maxPrice}';
  }

  @override
  void dispose() {
    _minCtl.dispose();
    _maxCtl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _f = SearchFilters(query: widget.filters.query, sortBy: widget.filters.sortBy);
      _priceRange = const RangeValues(0, _maxPrice);
      _minCtl.clear();
      _maxCtl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle + titre
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filtres avancés',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppColors.primary)),
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Réinitialiser',
                            style: TextStyle(
                                color: AppColors.cta, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contenu scrollable
            Expanded(
              child: ListView(
                controller: scrollCtl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // ── Catégorie ──
                  _FilterSection(title: 'Catégorie'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: kCategories.skip(1).map((cat) {
                      final sel = _f.category == cat;
                      return _Chip(
                        label: cat,
                        selected: sel,
                        onTap: () =>
                            setState(() => _f.category = sel ? null : cat),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Ville ──
                  _FilterSection(title: 'Ville'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: kCities.skip(1).map((city) {
                      final sel = _f.city == city;
                      return _Chip(
                        label: city,
                        selected: sel,
                        onTap: () =>
                            setState(() => _f.city = sel ? null : city),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Prix ──
                  _FilterSection(title: 'Budget (FCFA)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PriceField(
                          controller: _minCtl,
                          hint: 'Min',
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            setState(() {
                              _f.minPrice = n;
                              _priceRange = RangeValues(
                                  (n ?? 0).toDouble(), _priceRange.end);
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: _PriceField(
                          controller: _maxCtl,
                          hint: 'Max',
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            setState(() {
                              _f.maxPrice = n;
                              _priceRange = RangeValues(_priceRange.start,
                                  (n ?? _maxPrice).toDouble());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0, max: _maxPrice,
                    activeColor: AppColors.cta,
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (v) {
                      setState(() {
                        _priceRange = v;
                        _f.minPrice = v.start.round();
                        _f.maxPrice = v.end.round();
                        _minCtl.text = '${v.start.round()}';
                        _maxCtl.text = '${v.end.round()}';
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── État ──
                  _FilterSection(title: 'État du produit'),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Neuf', 'Occasion', 'Reconditionné'].map((c) {
                      final sel = _f.condition == c;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _f.condition = sel ? null : c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(c,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Badges ──
                  _FilterSection(title: 'Options'),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    label: '✓ Annonces vérifiées seulement',
                    value: _f.verifiedOnly,
                    onChanged: (v) => setState(() => _f.verifiedOnly = v),
                  ),
                  _SwitchTile(
                    label: '⚡ Flash Deals uniquement',
                    value: _f.flashOnly,
                    onChanged: (v) => setState(() => _f.flashOnly = v),
                  ),
                  _SwitchTile(
                    label: '🔄 Deals revendables',
                    value: _f.resellableOnly,
                    onChanged: (v) => setState(() => _f.resellableOnly = v),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bouton appliquer
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, MediaQuery.of(context).padding.bottom + 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(_f);
                  },
                  child: const Text('Appliquer les filtres',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  CARTE DEAL RECHERCHE
// ═══════════════════════════════════════════════
class _SearchDealCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback onTap;
  const _SearchDealCard({required this.deal, required this.onTap});

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
    final hasDiscount = deal.oldPrice != null && deal.oldPrice! > deal.price;
    final discount = hasDiscount
        ? (((deal.oldPrice! - deal.price) / deal.oldPrice!) * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
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
                    // Badges
                    Positioned(
                      top: 8, left: 8,
                      child: Column(
                        children: [
                          if (deal.isFlash)
                            _SmallBadge(label: '⚡ Flash',
                                color: const Color(0xFFE65100),
                                bg: const Color(0xFFFFF3E0)),
                          if (deal.isVerified) ...[
                            const SizedBox(height: 4),
                            _SmallBadge(label: '✓ Vérifié',
                                color: const Color(0xFF1B5E20),
                                bg: const Color(0xFFE8F5E9)),
                          ],
                        ],
                      ),
                    ),
                    // Remise
                    if (hasDiscount)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('-$discount%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Infos
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1.3)),
                  const SizedBox(height: 5),
                  Text(_formatPrice(deal.price),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cta)),
                  if (deal.oldPrice != null) ...[
                    Text(_formatPrice(deal.oldPrice!),
                        style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(deal.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SKELETON CARD
// ═══════════════════════════════════════════════
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(width: double.infinity, height: 10),
                    const SizedBox(height: 6),
                    _SkeletonLine(width: 80, height: 10),
                    const SizedBox(height: 6),
                    _SkeletonLine(width: 60, height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width, height;
  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  PETITS WIDGETS
// ═══════════════════════════════════════════════
class _FilterSection extends StatelessWidget {
  final String title;
  const _FilterSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.cta,
      title: Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.primary)),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _PriceField(
      {required this.controller,
      required this.hint,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: 'F',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.cta, width: 2)),
      ),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _SmallBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
