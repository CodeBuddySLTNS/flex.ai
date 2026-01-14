import 'package:flexai/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  Future<String?> registerUsername(String username) async {
    try {
      final response = await _supabase.functions.invoke(
        'register-username',
        body: {'username': username},
      );

      final data = response.data;

      if (data is Map<String, dynamic> && data['user_id'] != null) {
        return data['user_id'].toString();
      }

      throw "UNKNOWN_ERROR";
    } on FunctionException catch (e) {
      if (e.status == 409) {
        throw "DUPLICATE";
      }

      throw "NETWORK_ERROR";
    } catch (e) {
      throw "NETWORK_ERROR";
    }
  }

  Future<ChatMessage> sendMessage(
    String username,
    String prompt,
    String? conversationId,
    String? instructionId,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'query-gemini',
        body: {
          'username': username,
          'prompt': prompt,
          'conversation_id': conversationId,
          'instruction_id': instructionId ?? prefs.getString('instructionId'),
        },
      );

      final data = response.data;

      if (data.isNotEmpty) {
        return ChatMessage.fromJson({...data, 'status': 'sent'});
      }

      throw "UNKNOWN_ERROR";
    } on FunctionException catch (e) {
      if (e.status == 409) {
        throw "DUPLICATE";
      }

      debugPrint("1st: $e");
      throw "NETWORK_ERROR";
    } catch (e) {
      debugPrint("2nd: $e");
      throw "NETWORK_ERROR";
    }
  }

  Future<List<ChatMessage>> getChatMessages(String conversationId) async {
    final List<Map<String, dynamic>> response = await _supabase
        .from('chat_messages')
        .select(
          'id, conversationId:conversation_id, role, content, createdAt:created_at',
        )
        .eq("conversation_id", conversationId);

    if (response.isNotEmpty) {
      return response
          .map((m) => ChatMessage.fromJson({...m, 'status': 'sent'}))
          .toList();
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
  String status;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = 'sending',
  });

  ChatMessage copyWith({String? status, String? content}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

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
