import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════
//  NotificationService — Notifications
// ═══════════════════════════════════════════════════════════

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:        j['id'] as String,
    title:     j['title'] as String,
    body:      j['body'] as String,
    type:      j['type'] as String,
    isRead:    j['is_read'] as bool? ?? false,
    data:      j['data'] as Map<String, dynamic>?,
    createdAt: DateTime.tryParse(j['created_at'] as String) ?? DateTime.now(),
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // ── Récupérer les notifications ───────────
  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int page = 1,
  }) async {
    if (!AppConfig.useRealBackend) return [];
    final data = await ApiService.instance.get(
      '/notifications',
      params: {
        'page': '$page',
        'per_page': '20',
        if (unreadOnly) 'unread_only': 'true',
      },
    );
    return (data as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Nombre non lus ────────────────────────
  Future<int> getUnreadCount() async {
    if (!AppConfig.useRealBackend) return 0;
    try {
      final data = await ApiService.instance.get('/notifications/unread-count');
      _unreadCount = (data as Map<String, dynamic>)['count'] as int? ?? 0;
      return _unreadCount;
    } catch (e) {
      return 0;
    }
  }

  // ── Marquer comme lu ─────────────────────
  Future<void> markAsRead(String notificationId) async {
    if (!AppConfig.useRealBackend) return;
    try {
      await ApiService.instance.put('/notifications/$notificationId/read');
      if (_unreadCount > 0) _unreadCount--;
    } catch (e) {
      debugPrint('NotificationService markAsRead error: $e');
    }
  }

  // ── Tout marquer comme lu ─────────────────
  Future<void> markAllAsRead() async {
    if (!AppConfig.useRealBackend) return;
    try {
      await ApiService.instance.put('/notifications/read-all');
      _unreadCount = 0;
    } catch (e) {
      debugPrint('NotificationService markAllAsRead error: $e');
    }
  }
}
