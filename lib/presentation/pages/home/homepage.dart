import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/deal_service.dart';
import '../search/search_page.dart';
import '../detail_deal/detail_deal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<List<DealModel>> _dealsFuture;
  late Future<List<DealModel>> _flashFuture;
  String? _selectedCategory;
  bool _isListening = false;

  late AnimationController _aiPulseCtrl;
  late Animation<double> _aiPulse;
  late AnimationController _micWaveCtrl;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.phone_iphone_rounded,
      'label': 'Électronique',
      'color': const Color(0xFF1565C0),
    },
    {
      'icon': Icons.home_rounded,
      'label': 'Immobilier',
      'color': const Color(0xFF2E7D32),
    },
    {
      'icon': Icons.directions_car_rounded,
      'label': 'Auto / Moto',
      'color': const Color(0xFFE65100),
    },
    {
      'icon': Icons.design_services_rounded,
      'label': 'Services',
      'color': const Color(0xFF6A1B9A),
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'label': 'Mode',
      'color': const Color(0xFFC62828),
    },
    {
      'icon': Icons.weekend_rounded,
      'label': 'Maison',
      'color': const Color(0xFF00695C),
    },
    {
      'icon': Icons.sports_soccer_rounded,
      'label': 'Loisirs',
      'color': const Color(0xFFF57C00),
    },
    {
      'icon': Icons.pets_rounded,
      'label': 'Animaux',
      'color': const Color(0xFF4E342E),
    },
    {
      'icon': Icons.favorite,
      'label': 'Rencontre',
      'color': const Color(0xFFAD1457),
    },
  ];

  final List<Map<String, String>> _aiSuggestions = [
    {'emoji': '🔥', 'label': 'Tendances Douala'},
    {'emoji': '📱', 'label': 'Samsung pas cher'},
    {'emoji': '🏠', 'label': 'Studios à louer'},
    {'emoji': '🚗', 'label': 'Motos occasion'},
    {'emoji': '⚡', 'label': 'Flash deals'},
    {'emoji': '👗', 'label': 'Mode femme'},
  ];

  @override
  void initState() {
    super.initState();
    _dealsFuture = DealService.instance.getPopular(limit: 20);
    _flashFuture = DealService.instance.getFlashDeals(limit: 6);

    _aiPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _aiPulse = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _aiPulseCtrl, curve: Curves.easeInOut));

    _micWaveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _aiPulseCtrl.dispose();
    _micWaveCtrl.dispose();
    super.dispose();
  }

  void _filterByCategory(String cat) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = _selectedCategory == cat ? null : cat;
      _dealsFuture = _selectedCategory != null
          ? DealService.instance.getByCategory(_selectedCategory!)
          : DealService.instance.getPopular(limit: 20);
    });
  }

  void _startVoiceSearch() {
    HapticFeedback.mediumImpact();
    setState(() => _isListening = true);
    _micWaveCtrl.repeat(reverse: true);
    // TODO: intégrer speech_to_text package
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _micWaveCtrl.stop();
      setState(() => _isListening = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchPage()),
      );
    });
  }

  void _openImageSearch() {
    HapticFeedback.lightImpact();
    // TODO: ouvrir image_picker directement puis passer l'image à SearchPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u00a0');
      buf.write(s[i]);
    }
    return '$buf FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildAiSuggestions()),
            SliverToBoxAdapter(child: _buildFlashSection()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildDealsHeader()),
            _buildDealsGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trouvez votre deal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          ScaleTransition(
            scale: _aiPulse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'IA activée',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  // ── BARRE RECHERCHE IA (texte + image + voix) ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Zone texte
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ex: "téléphone pas cher à Douala"',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _vDiv(),

            // Bouton Image
            _SBarBtn(
              icon: Icons.camera_alt_rounded,
              label: 'Image',
              color: AppColors.cta,
              onTap: _openImageSearch,
            ),

            _vDiv(),

            // Bouton Voix
            AnimatedBuilder(
              animation: _micWaveCtrl,
              builder: (_, __) => _SBarBtn(
                icon: _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                label: _isListening ? 'Écoute…' : 'Voix',
                color: _isListening
                    ? AppColors.primary
                    : AppColors.textSecondary,
                onTap: _isListening ? null : _startVoiceSearch,
                waveValue: _isListening ? _micWaveCtrl.value : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDiv() =>
      Container(width: 1, height: 30, color: const Color(0xFFE5E7EB));

  // ── SUGGESTIONS IA ──────────────────────────
  Widget _buildAiSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  '✦  IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Suggestions pour vous',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _aiSuggestions.length,
            itemBuilder: (_, i) {
              final s = _aiSuggestions[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s['emoji']!, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        s['label']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── FLASH DEALS ─────────────────────────────
  Widget _buildFlashSection() {
    return FutureBuilder<List<DealModel>>(
      future: _flashFuture,
      builder: (_, snap) {
        if (snap.hasError) {
          debugPrint('🔴 FLASH ERROR: ${snap.error}');
          debugPrint('🔴 FLASH STACK: ${snap.stackTrace}');
          return const SizedBox.shrink();
        }
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE65100).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 3),
                        Text(
                          'FLASH DEALS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Sélectionnés par l\'IA',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
                    child: const Text(
                      'Tout voir →',
                      style: TextStyle(
                        color: AppColors.cta,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: snap.data!.length,
                itemBuilder: (_, i) => _FlashCard(
                  deal: snap.data![i],
                  fmt: _fmt,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(deal: snap.data![i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── CATÉGORIES ──────────────────────────────
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Text(
            'Catégories',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
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
              final color = cat['color'] as Color;
              return GestureDetector(
                onTap: () => _filterByCategory(cat['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: selected ? color : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: selected
                                  ? color.withOpacity(0.35)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: selected ? 14 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: selected ? Colors.white : color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── HEADER GRILLE ───────────────────────────
  Widget _buildDealsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedCategory ?? 'Deals populaires',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 10,
                    color: Color(0xFF6A1B9A),
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Triés par l\'IA selon vos préférences',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.cta.withOpacity(0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.cta,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GRILLE DEALS ────────────────────────────
  Widget _buildDealsGrid() {
    return FutureBuilder<List<DealModel>>(
      future: _dealsFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const _SkeletonCard(),
                childCount: 6,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          );
        }
        if (snap.hasError) {
          debugPrint('🔴 DEALS ERROR: ${snap.error}');
          debugPrint('🔴 DEALS STACK: ${snap.stackTrace}');
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Impossible de charger les deals',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _dealsFuture = DealService.instance.getDeals(
                        forceRefresh: true,
                      );
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        final deals = snap.data ?? [];
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _DealCard(
                deal: deals[i],
                fmt: _fmt,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(deal: deals[i]),
                  ),
                ),
              ),
              childCount: deals.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  Search Bar Button
// ═══════════════════════════════════════════════
class _SBarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double waveValue;
  const _SBarBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.waveValue = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (waveValue > 0)
              ...List.generate(
                2,
                (i) => Transform.scale(
                  scale: 1.0 + (i + 1) * 0.35 * waveValue,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(
                        0.07 * (1 - waveValue),
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Flash Card
// ═══════════════════════════════════════════════
class _FlashCard extends StatelessWidget {
  final DealModel deal;
  final String Function(int) fmt;
  final VoidCallback onTap;
  const _FlashCard({
    required this.deal,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasD = deal.oldPrice != null && deal.oldPrice! > deal.price;
    final pct = hasD
        ? (((deal.oldPrice! - deal.price) / deal.oldPrice!) * 100).round()
        : 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      deal.images.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                            Text(
                              'FLASH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasD)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '-$pct%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt(deal.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cta,
                    ),
                  ),
                  if (hasD)
                    Text(
                      fmt(deal.oldPrice!),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
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
//  Deal Card (grille)
// ═══════════════════════════════════════════════
class _DealCard extends StatelessWidget {
  final DealModel deal;
  final String Function(int) fmt;
  final VoidCallback onTap;
  const _DealCard({required this.deal, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasD = deal.oldPrice != null && deal.oldPrice! > deal.price;
    final pct = hasD
        ? (((deal.oldPrice! - deal.price) / deal.oldPrice!) * 100).round()
        : 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      deal.images.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFFE5E7EB)),
                    ),
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (deal.isFlash)
                            _Bdg(
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFFE65100),
                            ),
                          if (deal.isVerified) ...[
                            const SizedBox(height: 3),
                            _Bdg(
                              icon: Icons.verified_rounded,
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasD)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$pct%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
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
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fmt(deal.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cta,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          deal.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

class _Bdg extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Bdg({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(icon, color: Colors.white, size: 13),
  );
}

// ═══════════════════════════════════════════════
//  Skeleton Card
// ═══════════════════════════════════════════════
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _a = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Opacity(
      opacity: _a.value,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, color: const Color(0xFFE5E7EB)),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 80,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: 55,
                    color: const Color(0xFFE5E7EB),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
