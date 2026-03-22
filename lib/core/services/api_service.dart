import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// ═══════════════════════════════════════════════════════════
//  ApiService — Client HTTP centralisé
//
//  Gère :
//    - Injection automatique du token JWT Supabase
//    - Timeouts
//    - Codes d'erreur → exceptions lisibles
//    - Logs debug
//    - Retry sur 401 (token refresh)
// ═══════════════════════════════════════════════════════════

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Message utilisateur à afficher dans l'UI
  String get userMessage {
    switch (statusCode) {
      case 400: return 'Requête invalide. Vérifiez les données.';
      case 401: return 'Session expirée. Reconnectez-vous.';
      case 403: return 'Accès refusé.';
      case 404: return 'Contenu introuvable.';
      case 422: return 'Données incorrectes.';
      case 429: return 'Trop de requêtes. Réessayez dans quelques secondes.';
      case 500:
      case 502:
      case 503: return 'Serveur indisponible. Réessayez plus tard.';
      default:  return message.isNotEmpty ? message : 'Erreur réseau.';
    }
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';

  String get userMessage => 'Pas de connexion internet. Vérifiez votre réseau.';
}

// ─────────────────────────────────────────────
//  Service
// ─────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Token JWT Supabase — à mettre à jour après chaque login/refresh
  String? _accessToken;

  /// Accès public au token (pour upload multipart)
  String? get accessToken => _accessToken;

  void setToken(String token) {
    _accessToken = token;
    debugPrint('ApiService: token mis à jour');
  }

  void clearToken() {
    _accessToken = null;
  }

  // ─────────────────────────────────────────
  //  Headers
  // ─────────────────────────────────────────
  Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      h['Authorization'] = 'Bearer $_accessToken';
    }
    return h;
  }

  // ─────────────────────────────────────────
  //  GET
  // ─────────────────────────────────────────
  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final uri = _buildUri(path, params);
    debugPrint('GET $uri');
    try {
      final resp = await http
          .get(uri, headers: _headers)
          .timeout(AppConfig.receiveTimeout);
      return _parse(resp);
    } on SocketException {
      throw const NetworkException('Pas de connexion');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // ─────────────────────────────────────────
  //  POST
  // ─────────────────────────────────────────
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    debugPrint('POST $uri');
    try {
      final resp = await http
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.sendTimeout);
      return _parse(resp);
    } on SocketException {
      throw const NetworkException('Pas de connexion');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // ─────────────────────────────────────────
  //  PUT
  // ─────────────────────────────────────────
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    debugPrint('PUT $uri');
    try {
      final resp = await http
          .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.sendTimeout);
      return _parse(resp);
    } on SocketException {
      throw const NetworkException('Pas de connexion');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // ─────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────
  Future<void> delete(String path) async {
    final uri = _buildUri(path, null);
    debugPrint('DELETE $uri');
    try {
      final resp = await http
          .delete(uri, headers: _headers)
          .timeout(AppConfig.receiveTimeout);
      if (resp.statusCode != 204 && resp.statusCode != 200) {
        _throwFromResponse(resp);
      }
    } on SocketException {
      throw const NetworkException('Pas de connexion');
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  // ─────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────
  Uri _buildUri(String path, Map<String, String>? params) {
    final base = '${AppConfig.apiUrl}$path';
    final uri = Uri.parse(base);
    if (params != null && params.isNotEmpty) {
      return uri.replace(queryParameters: params);
    }
    return uri;
  }

  dynamic _parse(http.Response resp) {
    debugPrint('  → ${resp.statusCode}');
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return jsonDecode(utf8.decode(resp.bodyBytes));
    }
    _throwFromResponse(resp);
  }

  Never _throwFromResponse(http.Response resp) {
    String message = '';
    try {
      final body = jsonDecode(utf8.decode(resp.bodyBytes));
      message = body['detail']?.toString() ?? body['message']?.toString() ?? '';
    } catch (_) {
      message = resp.body;
    }
    throw ApiException(resp.statusCode, message);
  }
}
