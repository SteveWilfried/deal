import 'package:flutter/foundation.dart';
import '../../../presentation/pages/detail_deal/detail_deal.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'deal_service.dart';

// ═══════════════════════════════════════════════════════════
//  FavoriteService — Gestion des favoris
// ═══════════════════════════════════════════════════════════

class FavoriteService {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  // Cache local des IDs favoris
  final Set<String> _favoriteIds = {};
  bool _loaded = false;

  // ── Charger les favoris ───────────────────
  Future<List<DealModel>> getFavorites() async {
    if (!AppConfig.useRealBackend) {
      debugPrint('FavoriteService: mode démo — pas de favoris');
      return [];
    }
    final data = await ApiService.instance.get('/favorites');
    final list = data as List;
    final deals = list.map((e) => DealService.fromApiJson(e as Map<String, dynamic>)).toList();
    _favoriteIds.clear();
    _favoriteIds.addAll(deals.map((d) => d.id));
    _loaded = true;
    return deals;
  }

  // ── Ajouter un favori ─────────────────────
  Future<bool> addFavorite(String dealId) async {
    if (!AppConfig.useRealBackend) return false;
    try {
      await ApiService.instance.post('/favorites/$dealId');
      _favoriteIds.add(dealId);
      return true;
    } catch (e) {
      debugPrint('FavoriteService addFavorite error: $e');
      return false;
    }
  }

  // ── Retirer un favori ─────────────────────
  Future<bool> removeFavorite(String dealId) async {
    if (!AppConfig.useRealBackend) return false;
    try {
      await ApiService.instance.delete('/favorites/$dealId');
      _favoriteIds.remove(dealId);
      return true;
    } catch (e) {
      debugPrint('FavoriteService removeFavorite error: $e');
      return false;
    }
  }

  // ── Toggle favori ─────────────────────────
  Future<bool> toggleFavorite(String dealId) async {
    if (isFavorite(dealId)) {
      await removeFavorite(dealId);
      return false;
    } else {
      await addFavorite(dealId);
      return true;
    }
  }

  // ── Vérifier si favori (local) ────────────
  bool isFavorite(String dealId) => _favoriteIds.contains(dealId);

  // ── Vérifier depuis le backend ────────────
  Future<bool> checkFavorite(String dealId) async {
    if (!AppConfig.useRealBackend) return false;
    try {
      final data = await ApiService.instance.get('/favorites/check/$dealId');
      final result = (data as Map<String, dynamic>)['is_favorite'] as bool;
      if (result) {
        _favoriteIds.add(dealId);
      } else {
        _favoriteIds.remove(dealId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  void clearCache() {
    _favoriteIds.clear();
    _loaded = false;
  }
}
