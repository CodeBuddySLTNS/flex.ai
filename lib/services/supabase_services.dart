import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  Future<List<ChatMessage>> getChatMessages(String conversationId) async {
    final List<Map<String, dynamic>> response = await _supabase
        .from('chat_messages')
        .select(
          'id, conversationId:conversation_id, role, content, createdAt:created_at',
        )
        .eq("conversation_id", conversationId);

    if (response.isNotEmpty) {
      List<ChatMessage> messages = response
          .map((m) => ChatMessage.fromJson(m))
          .toList();
      return messages;
    }

    return [];
  }
}

class ChatMessage {
  int id;
  String conversationId;
  String role;
  String content;
  String createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json["conversationId"],
      role: json["role"],
      content: json["content"],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
