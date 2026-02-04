import 'package:flexai/main.dart';
import 'package:flexai/models/ai_model.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final usernameProvider = StateProvider<String>((ref) => '');
final conversationIdProvider = StateProvider<String>((ref) => '');
final modelProvider = StateProvider<String>((ref) => '');
final selectedModelProvider = StateProvider<String>(
  (ref) =>
      prefs.getString('default_model') ??
      'bbfb75e2-2a4e-4843-be60-0751440026db',
);

final chatHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  debugPrint("history fetching...");
  return SupabaseService().getChatHistory();
});

// ai models provider - can be invalidated to refetch
final aiModelsProvider = FutureProvider<List<AiModel>>((ref) async {
  debugPrint("fetching ai models...");
  return SupabaseService().getModels();
});
