import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════
//  AuthService — Authentification Supabase OTP + profil
//
//  Flow complet :
//    1. sendOtp(phone)           → Supabase envoie SMS
//    2. verifyOtp(phone, code)   → retourne session JWT
//    3. syncProfile()            → crée/récupère profil sur FastAPI
//    4. refreshSession()         → renouvelle le token avant expiry
//
//  Le token JWT est automatiquement injecté dans ApiService.
// ═══════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  Modèle utilisateur local
// ─────────────────────────────────────────────
class NdokotiUser {
  final String id; // UUID Supabase
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String? city;
  final String role; // buyer | seller | admin
  final bool isVerified;
  final int walletBalance;
  final double rating;
  final int reviewCount;
  final int totalDeals;

  const NdokotiUser({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    this.city,
    required this.role,
    required this.isVerified,
    required this.walletBalance,
    required this.rating,
    required this.reviewCount,
    required this.totalDeals,
  });

  factory NdokotiUser.fromJson(Map<String, dynamic> j) => NdokotiUser(
    id: j['supabase_id']?.toString() ?? j['id'].toString(),
    phone: j['phone'] as String,
    name: j['name'] as String?,
    avatarUrl: j['avatar_url'] as String?,
    city: j['city'] as String?,
    role: j['role'] as String? ?? 'buyer',
    isVerified: j['is_verified'] as bool? ?? false,
    walletBalance: (j['wallet_balance'] as num?)?.toInt() ?? 0,
    rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (j['review_count'] as num?)?.toInt() ?? 0,
    totalDeals: (j['total_deals'] as num?)?.toInt() ?? 0,
  );

  bool get isSeller => role == 'seller' || role == 'admin';

  NdokotiUser copyWith({String? name, String? city, String? avatarUrl}) =>
      NdokotiUser(
        id: id,
        phone: phone,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        city: city ?? this.city,
        role: role,
        isVerified: isVerified,
        walletBalance: walletBalance,
        rating: rating,
        reviewCount: reviewCount,
        totalDeals: totalDeals,
      );
}

// ─────────────────────────────────────────────
//  Exception auth
// ─────────────────────────────────────────────
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

// ─────────────────────────────────────────────
//  Service
// ─────────────────────────────────────────────
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  NdokotiUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;

  NdokotiUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  String? get accessToken => _accessToken;

  // ─────────────────────────────────────────
  //  MODE DEV — Connexion sans OTP
  // ─────────────────────────────────────────
  /// Simule une session locale sans passer par Supabase/Twilio.
  /// À utiliser UNIQUEMENT en développement.
  Future<NdokotiUser> loginDev() async {
    const fakeToken = 'dev_token_ndokoti_2024';
    _accessToken = fakeToken;
    _refreshToken = null;
    _expiresAt = DateTime.now().add(const Duration(days: 30));
    ApiService.instance.setToken(fakeToken);

    // Créer/récupérer le user dev depuis le backend
    try {
      final data = await ApiService.instance.post('/users/dev-login');
      _currentUser = NdokotiUser.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      // Fallback : user fictif local si le backend est indispo
      _currentUser = const NdokotiUser(
        id:            '00000000-0000-0000-0000-000000000001',
        phone:         '+237699000001',
        name:          'Dev User',
        role:          'seller',
        isVerified:    true,
        walletBalance: 0,
        rating:        5.0,
        reviewCount:   0,
        totalDeals:    0,
      );
    }
    debugPrint('AuthService: loginDev → ${_currentUser!.name}');
    return _currentUser!;
  }

  // ─────────────────────────────────────────
  //  Supabase REST Auth endpoints
  // ─────────────────────────────────────────
  static const String _supabaseAuth = '${AppConfig.supabaseUrl}/auth/v1';

  Map<String, String> get _supabaseHeaders => {
    'apikey': AppConfig.supabaseAnonKey,
    'Content-Type': 'application/json',
  };

  // ─────────────────────────────────────────
  //  1. Envoyer OTP SMS
  // ─────────────────────────────────────────
  /// [phone] format international : +237655000001
  Future<void> sendOtp(String phone) async {
    debugPrint('AuthService: sendOtp → $phone');
    final resp = await http
        .post(
          Uri.parse('$_supabaseAuth/otp'),
          headers: _supabaseHeaders,
          body: jsonEncode({'phone': phone, 'channel': 'sms'}),
        )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      final body = _safeJson(resp.body);
      final msg =
          body?['msg'] ?? body?['error_description'] ?? 'Erreur envoi SMS';
      throw AuthException(msg.toString());
    }
    debugPrint('AuthService: OTP envoyé');
  }

  // ─────────────────────────────────────────
  //  2. Vérifier OTP → session JWT
  // ─────────────────────────────────────────
  Future<NdokotiUser> verifyOtp(String phone, String token) async {
    debugPrint('AuthService: verifyOtp → $phone');
    final resp = await http
        .post(
          Uri.parse('$_supabaseAuth/verify'),
          headers: _supabaseHeaders,
          body: jsonEncode({'phone': phone, 'token': token, 'type': 'sms'}),
        )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      final body = _safeJson(resp.body);
      final msg =
          body?['msg'] ?? body?['error_description'] ?? 'Code incorrect';
      throw AuthException(msg.toString());
    }

    final session = jsonDecode(resp.body) as Map<String, dynamic>;
    _storeSession(session);

    // Sync profil sur le backend Ndokoti
    final user = await _syncProfile(phone);
    _currentUser = user;
    return user;
  }

  // ─────────────────────────────────────────
  //  3. Créer/récupérer profil sur FastAPI
  // ─────────────────────────────────────────
  Future<NdokotiUser> _syncProfile(String phone) async {
    try {
      final data = await ApiService.instance.post(
        '/users/me',
        body: {'supabase_id': _supabaseUid, 'phone': phone},
      );
      return NdokotiUser.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      // 409 = profil déjà existant → GET
      if (e.statusCode == 409 || e.statusCode == 200) {
        final data = await ApiService.instance.get('/users/me');
        return NdokotiUser.fromJson(data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  //  4. Rafraîchir le token
  // ─────────────────────────────────────────
  Future<bool> refreshSession() async {
    if (_refreshToken == null) return false;
    debugPrint('AuthService: refreshSession');
    try {
      final resp = await http
          .post(
            Uri.parse('$_supabaseAuth/token?grant_type=refresh_token'),
            headers: _supabaseHeaders,
            body: jsonEncode({'refresh_token': _refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) return false;
      _storeSession(jsonDecode(resp.body) as Map<String, dynamic>);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  //  5. Déconnexion
  // ─────────────────────────────────────────
  Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        await http
            .post(
              Uri.parse('$_supabaseAuth/logout'),
              headers: {
                ..._supabaseHeaders,
                'Authorization': 'Bearer $_accessToken',
              },
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
    _clearSession();
  }

  // ─────────────────────────────────────────
  //  6. Mise à jour profil
  // ─────────────────────────────────────────
  Future<NdokotiUser> updateProfile({
    String? name,
    String? city,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (city != null) body['city'] = city;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final data = await ApiService.instance.put('/users/me', body: body);
    final updated = NdokotiUser.fromJson(data as Map<String, dynamic>);
    _currentUser = updated;
    return updated;
  }

  // ─────────────────────────────────────────
  //  7. Auto-refresh avant expiry
  // ─────────────────────────────────────────
  /// À appeler au démarrage de l'app et avant chaque requête critique.
  Future<bool> ensureValidToken() async {
    if (_accessToken == null) return false;
    if (_expiresAt != null &&
        DateTime.now().isAfter(
          _expiresAt!.subtract(const Duration(minutes: 5)),
        )) {
      return refreshSession();
    }
    return true;
  }

  // ─────────────────────────────────────────
  //  Helpers privés
  // ─────────────────────────────────────────
  void _storeSession(Map<String, dynamic> session) {
    _accessToken = session['access_token'] as String?;
    _refreshToken = session['refresh_token'] as String?;
    final expiresIn = (session['expires_in'] as num?)?.toInt() ?? 3600;
    _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    if (_accessToken != null) {
      ApiService.instance.setToken(_accessToken!);
    }
    debugPrint('AuthService: session stockée, expire dans ${expiresIn}s');
  }

  void _clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _currentUser = null;
    ApiService.instance.clearToken();
    debugPrint('AuthService: session effacée');
  }

  /// Extraire le supabase_id depuis le JWT (sans vérification de signature)
  String? get _supabaseUid {
    if (_accessToken == null) return null;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      return decoded['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _safeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
