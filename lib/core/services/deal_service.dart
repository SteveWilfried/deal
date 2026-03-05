import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../presentation/pages/detail_deal/detail_deal.dart';

// ─────────────────────────────────────────────
//  CONSTANTES
// ─────────────────────────────────────────────

/// Taux de conversion USD → FCFA (à mettre à jour périodiquement)
const double _kUsdToFcfa = 620.0;

/// Vendeur fictif Ndokoti utilisé comme fallback
const _kDefaultSeller = _DefaultSeller();

class _DefaultSeller {
  const _DefaultSeller();
}

// ─────────────────────────────────────────────
//  MAPPING CATÉGORIES DummyJSON → Ndokoti
// ─────────────────────────────────────────────
const Map<String, String> _categoryMap = {
  'smartphones':        'Électronique',
  'laptops':            'Électronique',
  'tablets':            'Électronique',
  'mobile-accessories': 'Électronique',
  'computers':          'Électronique',
  'mens-watches':       'Mode',
  'womens-watches':     'Mode',
  'womens-bags':        'Mode',
  'womens-jewellery':   'Mode',
  'sunglasses':         'Mode',
  'mens-shirts':        'Mode',
  'womens-dresses':     'Mode',
  'mens-shoes':         'Mode',
  'womens-shoes':       'Mode',
  'tops':               'Mode',
  'furniture':          'Maison',
  'home-decoration':    'Maison',
  'kitchen-accessories':'Maison',
  'lighting':           'Maison',
  'fragrances':         'Mode',
  'skincare':           'Mode',
  'beauty':             'Mode',
  'groceries':          'Maison',
  'automotive':         'Auto / Moto',
  'motorcycle':         'Auto / Moto',
  'vehicle':            'Auto / Moto',
  'sports-accessories': 'Loisirs',
  'sports':             'Loisirs',
};

String _mapCategory(String raw) =>
    _categoryMap[raw.toLowerCase()] ?? 'Électronique';

// ─────────────────────────────────────────────
//  VENDEURS FICTIFS PAR VILLE
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> _kSellers = [
  {'id':'sv1','name':'TechCam Douala','phone':'237655101010','rating':4.8,'reviewCount':142,'totalDeals':67,'isVerified':true,'memberSince':'2022-03-15','city':'Douala'},
  {'id':'sv2','name':'Boutique Elite','phone':'237699202020','rating':4.5,'reviewCount':89,'totalDeals':34,'isVerified':true,'memberSince':'2022-07-01','city':'Yaoundé'},
  {'id':'sv3','name':'AfriShop','phone':'237677303030','rating':4.7,'reviewCount':203,'totalDeals':91,'isVerified':true,'memberSince':'2021-11-10','city':'Douala'},
  {'id':'sv4','name':'CamMobile','phone':'237655404040','rating':4.2,'reviewCount':56,'totalDeals':22,'isVerified':false,'memberSince':'2023-01-20','city':'Bafoussam'},
  {'id':'sv5','name':'Garage Central','phone':'237699505050','rating':4.6,'reviewCount':78,'totalDeals':44,'isVerified':true,'memberSince':'2022-09-12','city':'Garoua'},
  {'id':'sv6','name':'ImmoCam','phone':'237677606060','rating':4.4,'reviewCount':115,'totalDeals':58,'isVerified':true,'memberSince':'2021-05-22','city':'Douala'},
  {'id':'sv7','name':'ModeParis237','phone':'237655707070','rating':4.1,'reviewCount':44,'totalDeals':29,'isVerified':false,'memberSince':'2023-03-17','city':'Yaoundé'},
  {'id':'sv8','name':'ServicePro237','phone':'237655010101','rating':4.9,'reviewCount':187,'totalDeals':120,'isVerified':true,'memberSince':'2021-02-14','city':'Limbé'},
];

final List<String> _kCities = [
  'Douala','Yaoundé','Bafoussam','Garoua','Bamenda',
  'Ngaoundéré','Bertoua','Edéa','Kribi','Limbé',
];

// ─────────────────────────────────────────────
//  DEAL SERVICE
// ─────────────────────────────────────────────

/// Service centralisé pour charger les produits depuis DummyJSON.
///
/// Endpoints utilisés :
///   GET https://dummyjson.com/products?limit=N&skip=N
///   GET https://dummyjson.com/products/search?q=xxx
///   GET https://dummyjson.com/products/category/smartphones
///
/// Quand votre API FastAPI sera prête, remplacez [_baseUrl]
/// par 'https://api.ndokoti.cm/v1' et adaptez [_fromDummyJson].
class DealService {
  DealService._();
  static final DealService instance = DealService._();

  static const String _baseUrl = 'https://dummyjson.com';

  // Cache en mémoire
  List<DealModel>? _allCache;

  // ─────────────────────────────────────────
  //  API PUBLIQUE
  // ─────────────────────────────────────────

  /// Charge tous les produits (194 au total sur DummyJSON).
  /// Résultat mis en cache après le premier appel.
  Future<List<DealModel>> getDeals({bool forceRefresh = false}) async {
    if (_allCache != null && !forceRefresh) return _allCache!;
    _allCache = await _fetchAll();
    return _allCache!;
  }

  /// Vide le cache
  void invalidateCache() => _allCache = null;

  /// Recherche texte (utilise l'endpoint /search de DummyJSON)
  Future<List<DealModel>> search({
    String query = '',
    String? category,
    String? city,
    int? minPrice,
    int? maxPrice,
    String? condition,
    String sortBy = 'recent',
    bool verifiedOnly = false,
    bool flashOnly = false,
    bool resellableOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    List<DealModel> results;

    if (query.isNotEmpty) {
      // Recherche via API
      results = await _searchRemote(query);
    } else {
      // Tous les produits depuis le cache
      results = await getDeals();
    }

    // ── Filtres côté client ──
    if (category != null && category != 'Tous') {
      results = results.where((d) => d.category == category).toList();
    }
    if (city != null && city != 'Toutes') {
      results = results.where((d) => d.city == city).toList();
    }
    if (minPrice != null) {
      results = results.where((d) => d.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((d) => d.price <= maxPrice).toList();
    }
    if (condition != null) {
      results = results.where((d) => d.condition == condition).toList();
    }
    if (verifiedOnly)    results = results.where((d) => d.isVerified).toList();
    if (flashOnly)       results = results.where((d) => d.isFlash).toList();
    if (resellableOnly)  results = results.where((d) => d.availableForResell).toList();

    // ── Tri ──
    switch (sortBy) {
      case 'price_asc':  results.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': results.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'popular':    results.sort((a, b) => b.views.compareTo(a.views)); break;
      default:           results.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    }

    // ── Pagination ──
    final start = (page - 1) * perPage;
    if (start >= results.length) return [];
    return results.skip(start).take(perPage).toList();
  }

  /// Flash deals (les plus remisés)
  Future<List<DealModel>> getFlashDeals({int limit = 10}) async {
    final all = await getDeals();
    return all.where((d) => d.isFlash).take(limit).toList();
  }

  /// Deals populaires
  Future<List<DealModel>> getPopular({int limit = 20}) async {
    final all = await getDeals();
    return (List<DealModel>.from(all)
      ..sort((a, b) => b.views.compareTo(a.views))).take(limit).toList();
  }

  /// Par catégorie
  Future<List<DealModel>> getByCategory(String category, {int limit = 20}) async {
    final all = await getDeals();
    return all.where((d) => d.category == category).take(limit).toList();
  }

  /// Par ID
  Future<DealModel?> getById(String id) async {
    final all = await getDeals();
    try { return all.firstWhere((d) => d.id == id); } catch (_) { return null; }
  }

  // ─────────────────────────────────────────
  //  HTTP
  // ─────────────────────────────────────────

  /// Charge tous les produits (plusieurs pages car limit max = 100)
  Future<List<DealModel>> _fetchAll() async {
    final deals = <DealModel>[];
    int skip = 0;
    const int limit = 100;
    int total = 9999;

    while (deals.length < total) {
      final url = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
      final resp = await http.get(url).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        debugPrint('DealService: HTTP ${resp.statusCode}');
        break;
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      total = (json['total'] as num).toInt();
      final List items = json['products'] as List;
      if (items.isEmpty) break;

      deals.addAll(items.map((e) => _fromDummyJson(e as Map<String, dynamic>)));
      skip += limit;
    }

    return deals;
  }

  /// Recherche distante
  Future<List<DealModel>> _searchRemote(String query) async {
    final url = Uri.parse(
        '$_baseUrl/products/search?q=${Uri.encodeComponent(query)}&limit=50');
    final resp = await http.get(url).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return [];
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final List items = json['products'] as List;
    return items.map((e) => _fromDummyJson(e as Map<String, dynamic>)).toList();
  }

  // ─────────────────────────────────────────
  //  CONVERSION DummyJSON → DealModel Ndokoti
  // ─────────────────────────────────────────
  static DealModel _fromDummyJson(Map<String, dynamic> j) {
    // Prix : USD → FCFA (arrondi à 500 FCFA)
    final rawPrice   = (j['price'] as num).toDouble();
    final discountPc = (j['discountPercentage'] as num?)?.toDouble() ?? 0;
    final priceInFcfa    = _roundToNearest500((rawPrice * _kUsdToFcfa).round());
    final oldPriceInFcfa = discountPc > 0
        ? _roundToNearest500((rawPrice / (1 - discountPc / 100) * _kUsdToFcfa).round())
        : null;

    // Images
    final List<String> images = [];
    if (j['images'] is List && (j['images'] as List).isNotEmpty) {
      images.addAll((j['images'] as List).cast<String>().take(5));
    } else if (j['thumbnail'] != null) {
      images.add(j['thumbnail'] as String);
    }

    // Catégorie Ndokoti
    final category = _mapCategory((j['category'] as String? ?? '').toLowerCase());

    // Vendeur aléatoire mais déterministe (basé sur l'id produit)
    final sellerIndex = ((j['id'] as num).toInt()) % _kSellers.length;
    final sellerData  = _kSellers[sellerIndex];
    final seller = SellerModel(
      id:          sellerData['id'] as String,
      name:        sellerData['name'] as String,
      phone:       sellerData['phone'] as String,
      rating:      (sellerData['rating'] as num).toDouble(),
      reviewCount: (sellerData['reviewCount'] as num).toInt(),
      totalDeals:  (sellerData['totalDeals'] as num).toInt(),
      isVerified:  sellerData['isVerified'] as bool,
      memberSince: DateTime.parse(sellerData['memberSince'] as String),
    );

    // Ville déterministe (basé sur l'id)
    final cityIndex = ((j['id'] as num).toInt()) % _kCities.length;
    final city = _kCities[cityIndex];

    // État du produit
    final stock = (j['stock'] as num?)?.toInt() ?? 99;
    final condition = stock > 50 ? 'Neuf' : stock > 10 ? 'Occasion' : 'Reconditionné';

    // Booléens calculés
    final rating     = (j['rating'] as num?)?.toDouble() ?? 0;
    final id         = (j['id'] as num).toInt();
    final isVerified = rating >= 4.5;
    final isFlash    = discountPc >= 10;
    final isBoosted  = id % 7 == 0;
    final resellable = category == 'Électronique' || category == 'Maison';

    // Date simulée (produits récents)
    final daysAgo = (id * 3) % 90;
    final postedAt = DateTime.now().subtract(Duration(days: daysAgo));

    // Vues simulées
    final views = 50 + (id * 17 + (rating * 100).toInt()) % 2000;

    return DealModel(
      id:                'dj_$id',
      title:             j['title'] as String,
      price:             priceInFcfa,
      oldPrice:          oldPriceInFcfa,
      condition:         condition,
      city:              city,
      category:          category,
      description:       j['description'] as String? ?? '',
      images:            images.isNotEmpty ? images : ['https://picsum.photos/seed/deal$id/600/500'],
      isVerified:        isVerified,
      isFlash:           isFlash,
      isBoosted:         isBoosted,
      availableForResell: resellable,
      postedAt:          postedAt,
      views:             views,
      seller:            seller,
    );
  }

  static int _roundToNearest500(int value) => ((value + 250) ~/ 500) * 500;
}
