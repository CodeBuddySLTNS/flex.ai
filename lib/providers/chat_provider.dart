import 'package:flexai/services/supabase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final usernameProvider = StateProvider<String>((ref) => '');
final conversationIdProvider = StateProvider<String>((ref) => '');
final selectedModelProvider = StateProvider<String>(
  (ref) => 'bbfb75e2-2a4e-4843-be60-0751440026db',
);

final chatHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return SupabaseService().getChatHistory();
});
