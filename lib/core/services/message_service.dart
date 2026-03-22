import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════
//  MessageService — Messagerie
// ═══════════════════════════════════════════════════════════

class ConversationModel {
  final String id;
  final String? dealId;
  final String? dealTitle;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    this.dealId,
    this.dealTitle,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) => ConversationModel(
    id:              j['id'] as String,
    dealId:          j['deal_id'] as String?,
    dealTitle:       j['deal_title'] as String?,
    otherUserId:     j['other_user_id'] as String,
    otherUserName:   j['other_user_name'] as String?,
    otherUserAvatar: j['other_user_avatar'] as String?,
    lastMessage:     j['last_message'] as String?,
    lastMessageAt:   j['last_message_at'] != null
        ? DateTime.tryParse(j['last_message_at'] as String)
        : null,
    unreadCount:     (j['unread_count'] as num?)?.toInt() ?? 0,
    createdAt:       DateTime.tryParse(j['created_at'] as String) ?? DateTime.now(),
  );
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final bool isMe;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.isMe,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id:             j['id'] as String,
    conversationId: j['conversation_id'] as String,
    senderId:       j['sender_id'] as String,
    content:        j['content'] as String,
    isRead:         j['is_read'] as bool? ?? false,
    isMe:           j['is_mine'] as bool? ?? false,
    createdAt:      DateTime.tryParse(j['created_at'] as String) ?? DateTime.now(),
  );
}

class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  // ── Conversations ─────────────────────────
  Future<List<ConversationModel>> getConversations() async {
    if (!AppConfig.useRealBackend) return [];
    final data = await ApiService.instance.get('/messages/conversations');
    return (data as List)
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Démarrer une conversation ─────────────
  Future<String?> startConversation({
    required String sellerId,
    String? dealId,
    required String firstMessage,
  }) async {
    if (!AppConfig.useRealBackend) return null;
    try {
      final body = <String, dynamic>{
        'seller_id': sellerId,
        'first_message': firstMessage,
        if (dealId != null) 'deal_id': dealId,
      };
      final data = await ApiService.instance.post(
        '/messages/conversations',
        body: body,
      );
      return (data as Map<String, dynamic>)['conversation_id'] as String?;
    } catch (e) {
      debugPrint('MessageService startConversation error: $e');
      return null;
    }
  }

  // ── Messages d'une conversation ───────────
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
  }) async {
    if (!AppConfig.useRealBackend) return [];
    final data = await ApiService.instance.get(
      '/messages/conversations/$conversationId/messages',
      params: {'page': '$page', 'per_page': '50'},
    );
    return (data as List)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Envoyer un message ────────────────────
  Future<MessageModel?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (!AppConfig.useRealBackend) return null;
    try {
      final data = await ApiService.instance.post(
        '/messages/conversations/$conversationId/messages',
        body: {'content': content},
      );
      return MessageModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('MessageService sendMessage error: $e');
      return null;
    }
  }
}
