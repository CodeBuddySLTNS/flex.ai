import 'package:flexai/main.dart';
import 'package:flexai/models/ai_model.dart';
import 'package:flexai/models/chat_message.dart';
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
      throw "SERVER_ERROR";
    } catch (e) {
      debugPrint("2nd: $e");
      throw "NETWORK_ERROR";
    }
  }

  Future<List<ChatMessage>> getChatMessages(String conversationId) async {
    final List<Map<String, dynamic>> response = await _supabase
        .from('chat_messages')
        .select(
          'id, conversationId:conversation_id, role, content, model, createdAt:created_at',
        )
        .eq("conversation_id", conversationId);

    if (response.isNotEmpty) {
      return response
          .map((m) => ChatMessage.fromJson({...m, 'status': 'sent'}))
          .toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final response = await _supabase
        .from('conversations')
        .select()
        .eq('user_id', prefs.getString('userId') ?? '')
        .order('created_at', ascending: false);

    if (response.isNotEmpty) {
      return response;
    }

    return [];
  }

  Future<List<AiModel>> getModels() async {
    final userId = prefs.getString('userId') ?? '';
    final instructionId = prefs.getString('instructionId') ?? '';
    final response = await _supabase
        .from('instructions')
        .select()
        .or(
          'is_model.eq.true${userId.isNotEmpty ? ',author_id.eq.$userId' : ''}${instructionId.isNotEmpty ? ',id.eq.$instructionId' : ''}',
        )
        .order('created_at', ascending: true);

    if (response.isNotEmpty) {
      return response.map((r) => AiModel.fromJson(r)).toList();
    }

    return [];
  }

  Future<AiModel> getModel(String id) async {
    final response = await _supabase
        .from('instructions')
        .select()
        .eq('id', id)
        .single();

    return AiModel.fromJson(response);
  }

  Future<bool> createAIModel(
    String username,
    String title,
    String content,
    String? ownerText,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-ai-model',
        body: {
          'username': username,
          'title': title,
          'content': content,
          'owner_text': ownerText,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        AiModel aiModel = AiModel.fromJson(data);
        prefs.setString('default_model', aiModel.id);
        prefs.setString('default_model_title', aiModel.title);
        return true;
      }

      throw "UNKNOWN_ERROR";
    } on FunctionException catch (e) {
      debugPrint("1st: $e");
      if (e.status == 409) {
        throw "DUPLICATE";
      }

      throw "NETWORK_ERROR";
    } catch (e) {
      debugPrint("2nd: $e");
      throw "NETWORK_ERROR";
    }
  }

  // realtime listener for instructions updates
  RealtimeChannel subscribeToInstructions({
    required String instructionId,
    required Function(String? ownerText) onUpdate,
  }) {
    return _supabase
        .channel('instructions_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'instructions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: instructionId,
          ),
          callback: (payload) {
            final newData = payload.newRecord;

            if (newData.containsKey('owner_text')) {
              onUpdate(newData['owner_text']);
            }
          },
        )
        .subscribe();
  }
}
