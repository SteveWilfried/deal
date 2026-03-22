import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../presentation/pages/detail_deal/detail_deal.dart';
import '../config/app_config.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════
//  DealService — Service deals Ndokoti
//
//  Mode réel  (AppConfig.useRealBackend = true)
//    → Appels vers API FastAPI Ndokoti
//    → Endpoints : GET /v1/deals, GET /v1/deals/{id}, etc.
//
//  Mode démo  (AppConfig.useRealBackend = false)  [défaut]
//    → Données DummyJSON converties au format Ndokoti
//    → Cache mémoire pour éviter les requêtes répétées
//
//  Comment basculer en mode réel :
//    flutter run --dart-define=USE_REAL_BACKEND=true \
//                --dart-define=NDOKOTI_API_URL=https://api.ndokoti.cm
// ═══════════════════════════════════════════════════════════

const double _kUsdToFcfa = 620.0;

const Map<String, String> _kCategoryMap = {
  'smartphones':        'Électronique',
  'laptops':            'Électronique',
  'tablets':            'Électronique',
  'mobile-accessories': 'Électronique',
  'computers':          'Électronique',
  'mens-watches':       'Mode', 'womens-watches': 'Mode',
  'womens-bags':        'Mode', 'womens-jewellery': 'Mode',
  'sunglasses':         'Mode', 'mens-shirts': 'Mode',
  'womens-dresses':     'Mode', 'mens-shoes': 'Mode',
  'womens-shoes':       'Mode', 'tops': 'Mode',
  'fragrances':         'Mode', 'skincare': 'Mode', 'beauty': 'Mode',
  'furniture':          'Maison', 'home-decoration': 'Maison',
  'kitchen-accessories':'Maison', 'lighting': 'Maison', 'groceries': 'Maison',
  'automotive':         'Auto / Moto', 'motorcycle': 'Auto / Moto', 'vehicle': 'Auto / Moto',
  'sports-accessories': 'Loisirs', 'sports': 'Loisirs',
};

const List<Map<String, dynamic>> _kSellers = [
  {'id':'sv1','name':'TechCam Douala',  'phone':'237655101010','rating':4.8,'reviewCount':142,'totalDeals':67,'isVerified':true, 'memberSince':'2022-03-15'},
  {'id':'sv2','name':'Boutique Elite',  'phone':'237699202020','rating':4.5,'reviewCount':89, 'totalDeals':34,'isVerified':true, 'memberSince':'2022-07-01'},
  {'id':'sv3','name':'AfriShop',        'phone':'237677303030','rating':4.7,'reviewCount':203,'totalDeals':91,'isVerified':true, 'memberSince':'2021-11-10'},
  {'id':'sv4','name':'CamMobile',       'phone':'237655404040','rating':4.2,'reviewCount':56, 'totalDeals':22,'isVerified':false,'memberSince':'2023-01-20'},
  {'id':'sv5','name':'Garage Central',  'phone':'237699505050','rating':4.6,'reviewCount':78, 'totalDeals':44,'isVerified':true, 'memberSince':'2022-09-12'},
  {'id':'sv6','name':'ImmoCam',         'phone':'237677606060','rating':4.4,'reviewCount':115,'totalDeals':58,'isVerified':true, 'memberSince':'2021-05-22'},
  {'id':'sv7','name':'ModeParis237',    'phone':'237655707070','rating':4.1,'reviewCount':44, 'totalDeals':29,'isVerified':false,'memberSince':'2023-03-17'},
  {'id':'sv8','name':'ServicePro237',   'phone':'237655010101','rating':4.9,'reviewCount':187,'totalDeals':120,'isVerified':true,'memberSince':'2021-02-14'},
];

const List<String> _kCities = [
  'Douala','Yaoundé','Bafoussam','Garoua','Bamenda',
  'Ngaoundéré','Bertoua','Edéa','Kribi','Limbé',
];

class DealService {
  DealService._();
  static final DealService instance = DealService._();

  List<DealModel>? _demoCache;

  // ═══════════════════════════════════════════
  //  API PUBLIQUE
  // ═══════════════════════════════════════════

  Future<List<DealModel>> getDeals({bool forceRefresh = false}) async {
    if (AppConfig.useRealBackend) return _apiGetDeals();
    if (_demoCache != null && !forceRefresh) return _demoCache!;
    _demoCache = await _dummyFetchAll();
    return _demoCache!;
  }

  void invalidateCache() => _demoCache = null;

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
    int perPage = AppConfig.defaultPerPage,
  }) async {
    if (AppConfig.useRealBackend) {
      return _apiSearch(
        query: query, category: category, city: city,
        minPrice: minPrice, maxPrice: maxPrice, condition: condition,
        sortBy: sortBy, verifiedOnly: verifiedOnly,
        flashOnly: flashOnly, resellableOnly: resellableOnly,
        page: page, perPage: perPage,
      );
    }
    return _demoSearch(
      query: query, category: category, city: city,
      minPrice: minPrice, maxPrice: maxPrice, condition: condition,
      sortBy: sortBy, verifiedOnly: verifiedOnly,
      flashOnly: flashOnly, resellableOnly: resellableOnly,
      page: page, perPage: perPage,
    );
  }

  Future<List<DealModel>> getFlashDeals({int limit = AppConfig.flashDealsLimit}) async {
    if (AppConfig.useRealBackend) return _apiGetDeals(flashOnly: true, perPage: limit);
    final all = await getDeals();
    return all.where((d) => d.isFlash).take(limit).toList();
  }

  Future<List<DealModel>> getPopular({int limit = AppConfig.popularDealsLimit}) async {
    if (AppConfig.useRealBackend) return _apiGetDeals(sortBy: 'popular', perPage: limit);
    final all = await getDeals();
    return (List<DealModel>.from(all)
      ..sort((a, b) => b.views.compareTo(a.views))).take(limit).toList();
  }

  Future<List<DealModel>> getByCategory(String category, {int limit = 20}) async {
    if (AppConfig.useRealBackend) return _apiGetDeals(category: category, perPage: limit);
    final all = await getDeals();
    return all.where((d) => d.category == category).take(limit).toList();
  }

  Future<DealModel?> getById(String id) async {
    if (AppConfig.useRealBackend) return _apiGetById(id);
    final all = await getDeals();
    try { return all.firstWhere((d) => d.id == id); } catch (_) { return null; }
  }

  Future<List<DealModel>> getSellerDeals(String sellerId, {int page = 1}) async {
    if (AppConfig.useRealBackend) return _apiGetSellerDeals(sellerId, page: page);
    final all = await getDeals();
    return all.where((d) => d.seller.id == sellerId).toList();
  }

  /// Crée une annonce sur le backend réel.
  /// Lance une [UnsupportedError] en mode démo.
  Future<DealModel> createDeal({
    required String title,
    required String description,
    required int price,
    int? oldPrice,
    required String category,
    required String condition,
    required String city,
    required List<String> images,
    bool resellable = false,
    int? wholesalePrice,
    bool isFlash = false,
  }) async {
    if (!AppConfig.useRealBackend) {
      throw UnsupportedError('createDeal nécessite USE_REAL_BACKEND=true');
    }
    final data = await ApiService.instance.post('/deals', body: {
      'title':       title,
      'description': description,
      'price':       price,
      if (oldPrice != null)       'old_price':       oldPrice,
      'category':    category,
      'condition':   condition,
      'city':        city,
      'images':      images,
      'resellable':  resellable,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      'is_flash':    isFlash,
    });
    return fromApiJson(data as Map<String, dynamic>);
  }

  Future<void> deleteDeal(String dealId) async {
    if (!AppConfig.useRealBackend) {
      throw UnsupportedError('deleteDeal nécessite USE_REAL_BACKEND=true');
    }
    await ApiService.instance.delete('/deals/$dealId');
    invalidateCache();
  }

  // ═══════════════════════════════════════════
  //  COUCHE API RÉELLE
  // ═══════════════════════════════════════════

  Future<List<DealModel>> _apiGetDeals({
    String? category, String? city,
    String sortBy = 'recent',
    bool flashOnly = false, bool verifiedOnly = false,
    int page = 1, int perPage = 20,
  }) async {
    final params = <String, String>{
      'sort_by': sortBy, 'page': '$page', 'per_page': '$perPage',
      if (category != null)  'category':      category,
      if (city != null)      'city':          city,
      if (flashOnly)         'flash_only':    'true',
      if (verifiedOnly)      'verified_only': 'true',
    };
    final data = await ApiService.instance.get('/deals', params: params);
    final list = (data as Map<String, dynamic>)['deals'] as List;
    return list.map((e) => fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DealModel>> _apiSearch({
    String query = '', String? category, String? city,
    int? minPrice, int? maxPrice, String? condition,
    String sortBy = 'recent', bool verifiedOnly = false,
    bool flashOnly = false, bool resellableOnly = false,
    int page = 1, int perPage = 20,
  }) async {
    final params = <String, String>{
      'sort_by': sortBy, 'page': '$page', 'per_page': '$perPage',
      if (query.isNotEmpty)   'q':               query,
      if (category != null)   'category':        category,
      if (city != null)       'city':            city,
      if (minPrice != null)   'min_price':       '$minPrice',
      if (maxPrice != null)   'max_price':       '$maxPrice',
      if (condition != null)  'condition':       condition,
      if (verifiedOnly)       'verified_only':   'true',
      if (flashOnly)          'flash_only':      'true',
      if (resellableOnly)     'resellable_only': 'true',
    };
    final data = await ApiService.instance.get('/deals', params: params);
    final list = (data as Map<String, dynamic>)['deals'] as List;
    return list.map((e) => fromApiJson(e as Map<String, dynamic>)).toList();
  }

  Future<DealModel?> _apiGetById(String id) async {
    try {
      final data = await ApiService.instance.get('/deals/$id');
      return fromApiJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<DealModel>> _apiGetSellerDeals(String sellerId, {int page = 1}) async {
    final data = await ApiService.instance.get(
      '/deals/seller/$sellerId',
      params: {'page': '$page', 'per_page': '20'},
    );
    final list = (data as Map<String, dynamic>)['deals'] as List;
    return list.map((e) => fromApiJson(e as Map<String, dynamic>)).toList();
  }

  // ─────────────────────────────────────────
  //  Conversion API JSON → DealModel
  // ─────────────────────────────────────────
  static DealModel fromApiJson(Map<String, dynamic> j) {
    final s = j['seller'] as Map<String, dynamic>?;
    final seller = s != null
        ? SellerModel(
            id:          s['id'].toString(),
            name:        s['name'] as String? ?? 'Vendeur',
            phone:       '',
            rating:      (s['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: (s['review_count'] as num?)?.toInt() ?? 0,
            totalDeals:  (s['total_deals'] as num?)?.toInt() ?? 0,
            isVerified:  s['is_verified'] as bool? ?? false,
            memberSince: (s['member_since'] ?? s['created_at']) != null
                ? DateTime.tryParse((s['member_since'] ?? s['created_at']).toString()) ?? DateTime.now()
                : DateTime.now(),
          )
        : _kFallbackSeller;

    final images = (j['images'] as List?)?.cast<String>() ?? [];
    return DealModel(
      id:                 j['id'].toString(),
      title:              j['title'] as String,
      price:              (j['price'] as num).toInt(),
      oldPrice:           (j['old_price'] as num?)?.toInt(),
      condition:          j['condition'] as String? ?? 'Neuf',
      city:               j['city'] as String? ?? '',
      category:           j['category'] as String? ?? 'Autre',
      description:        j['description'] as String? ?? '',
      images:             images.isNotEmpty ? images : ['https://picsum.photos/seed/${j['id']}/600/500'],
      isVerified:         j['is_verified'] as bool? ?? false,
      isFlash:            j['is_flash'] as bool? ?? false,
      isBoosted:          j['is_boosted'] as bool? ?? false,
      availableForResell: j['resellable'] as bool? ?? false,
      postedAt:           j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      views:              (j['views_count'] as num?)?.toInt() ?? 0,
      seller:             seller,
    );
  }

  static final SellerModel _kFallbackSeller = SellerModel(
    id: 'unknown', name: 'Vendeur Ndokoti', phone: '',
    rating: 4.0, reviewCount: 0, totalDeals: 0,
    isVerified: false, memberSince: DateTime(2024),
  );

  // ═══════════════════════════════════════════
  //  COUCHE DÉMO — DummyJSON
  // ═══════════════════════════════════════════

  Future<List<DealModel>> _dummyFetchAll() async {
    final deals = <DealModel>[];
    int skip = 0;
    const int limit = 100;
    int total = 9999;

    while (deals.length < total) {
      final url = Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip');
      final resp = await http.get(url).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) break;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      total = (json['total'] as num).toInt();
      final List items = json['products'] as List;
      if (items.isEmpty) break;
      deals.addAll(items.map((e) => _fromDummyJson(e as Map<String, dynamic>)));
      skip += limit;
    }
    debugPrint('DealService [DEMO]: ${deals.length} deals chargés');
    return deals;
  }

  Future<List<DealModel>> _demoSearch({
    String query = '', String? category, String? city,
    int? minPrice, int? maxPrice, String? condition,
    String sortBy = 'recent', bool verifiedOnly = false,
    bool flashOnly = false, bool resellableOnly = false,
    int page = 1, int perPage = 20,
  }) async {
    List<DealModel> results;

    if (query.isNotEmpty) {
      final url = Uri.parse('https://dummyjson.com/products/search?q=${Uri.encodeComponent(query)}&limit=50');
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return [];
      results = ((jsonDecode(resp.body) as Map)['products'] as List)
          .map((e) => _fromDummyJson(e as Map<String, dynamic>)).toList();
    } else {
      results = await getDeals();
    }

    if (category != null && category != 'Tous')
      results = results.where((d) => d.category == category).toList();
    if (city != null && city != 'Toutes')
      results = results.where((d) => d.city == city).toList();
    if (minPrice != null) results = results.where((d) => d.price >= minPrice).toList();
    if (maxPrice != null) results = results.where((d) => d.price <= maxPrice).toList();
    if (condition != null) results = results.where((d) => d.condition == condition).toList();
    if (verifiedOnly)   results = results.where((d) => d.isVerified).toList();
    if (flashOnly)      results = results.where((d) => d.isFlash).toList();
    if (resellableOnly) results = results.where((d) => d.availableForResell).toList();

    switch (sortBy) {
      case 'price_asc':  results.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': results.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'popular':    results.sort((a, b) => b.views.compareTo(a.views)); break;
      default:           results.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    }

    final start = (page - 1) * perPage;
    if (start >= results.length) return [];
    return results.skip(start).take(perPage).toList();
  }

  static DealModel _fromDummyJson(Map<String, dynamic> j) {
    final rawPrice   = (j['price'] as num).toDouble();
    final discountPc = (j['discountPercentage'] as num?)?.toDouble() ?? 0;
    final price    = _r500((rawPrice * _kUsdToFcfa).round());
    final oldPrice = discountPc > 0
        ? _r500((rawPrice / (1 - discountPc / 100) * _kUsdToFcfa).round())
        : null;

    final images = <String>[];
    if (j['images'] is List) images.addAll((j['images'] as List).cast<String>().take(5));
    else if (j['thumbnail'] != null) images.add(j['thumbnail'] as String);

    final cat    = _kCategoryMap[(j['category'] as String? ?? '').toLowerCase()] ?? 'Électronique';
    final id     = (j['id'] as num).toInt();
    final sd     = _kSellers[id % _kSellers.length];
    final rating = (j['rating'] as num?)?.toDouble() ?? 0;
    final stock  = (j['stock'] as num?)?.toInt() ?? 99;

    return DealModel(
      id:                'dj_$id',
      title:             j['title'] as String,
      price:             price,
      oldPrice:          oldPrice,
      condition:         stock > 50 ? 'Neuf' : stock > 10 ? 'Occasion' : 'Reconditionné',
      city:              _kCities[id % _kCities.length],
      category:          cat,
      description:       j['description'] as String? ?? '',
      images:            images.isNotEmpty ? images : ['https://picsum.photos/seed/deal$id/600/500'],
      isVerified:        rating >= 4.5,
      isFlash:           discountPc >= 10,
      isBoosted:         id % 7 == 0,
      availableForResell: cat == 'Électronique' || cat == 'Maison',
      postedAt:          DateTime.now().subtract(Duration(days: (id * 3) % 90)),
      views:             50 + (id * 17 + (rating * 100).toInt()) % 2000,
      seller: SellerModel(
        id:          sd['id'] as String,
        name:        sd['name'] as String,
        phone:       sd['phone'] as String,
        rating:      (sd['rating'] as num).toDouble(),
        reviewCount: (sd['reviewCount'] as num).toInt(),
        totalDeals:  (sd['totalDeals'] as num).toInt(),
        isVerified:  sd['isVerified'] as bool,
        memberSince: DateTime.parse(sd['memberSince'] as String),
      ),
    );
  }

  static int _r500(int v) => ((v + 250) ~/ 500) * 500;
}
