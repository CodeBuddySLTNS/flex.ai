import 'package:flexai/main.dart';
import 'package:flexai/models/ai_model.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final statusProvider = StateProvider<bool>(
  (ref) => prefs.getBool('is_activated') ?? false,
);

final usernameProvider = StateProvider<String>((ref) => '');
final conversationIdProvider = StateProvider<String>((ref) => '');
final modelProvider = StateProvider<String>((ref) => '');
final selectedModelProvider = StateProvider<String>(
  (ref) =>
      prefs.getString('instructionId') ??
      prefs.getString('default_model') ??
      'bbfb75e2-2a4e-4843-be60-0751440026db',
);

final chatHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return SupabaseService().getChatHistory();
});

// ai models provider - can be invalidated to refetch
final aiModelsProvider = FutureProvider<List<AiModel>>((ref) async {
  return SupabaseService().getModels();
});
