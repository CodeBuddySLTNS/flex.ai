import 'package:flexai/services/supabase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final conversationIdProvider = StateProvider<String>((ref) => '');

final chatHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return SupabaseService().getChatHistory();
});
