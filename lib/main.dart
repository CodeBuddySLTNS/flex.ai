import 'package:flexai/components/header.dart';
import 'package:flexai/components/sidebar_drawer.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/screens/activation_screen.dart';
import 'package:flexai/screens/flexai_chat.dart';
import 'package:flexai/screens/loading_screen.dart';
import 'package:flexai/screens/settings.dart';
import 'package:flexai/screens/share_screen.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late SharedPreferencesWithCache prefs;

Future main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  prefs = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );

  // prefs.clear();

  prefs.setBool('is_activated', true);
  prefs.setBool('is_owner', true);

  runApp(const ProviderScope(child: FlexAI()));
}

class AppState extends ChangeNotifier {
  bool isLoading = true;

  Future<void> initApp() async {
    await Future.delayed(const Duration(seconds: 4));

    isLoading = false;
    notifyListeners();
  }
}

final appStateProvider = ChangeNotifierProvider((ref) => AppState());

final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    initialLocation: "/",
    refreshListenable: appState,
    redirect: (context, state) {
      final isLoading = appState.isLoading;
      final currentPath = state.uri.toString();
      final isAtLoading = currentPath == '/loading';
      final isAtActivation = currentPath == '/activation';
      final isActivated = prefs.getBool('is_activated') == true;

      // while loading, always go to loading screen
      if (isLoading && !isAtLoading) {
        return '/loading';
      }

      // redirect based on activation status
      if (!isLoading && isAtLoading) {
        return isActivated ? '/' : '/activation';
      }

      // protect home route - redirect to activation if not activated
      if (!isLoading && !isActivated && !isAtActivation && !isAtLoading) {
        return '/activation';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const RobotLoadingScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                endDrawer: const SidebarDrawer(),
                onEndDrawerChanged: (isOpened) {
                  ref.invalidate(chatHistoryProvider);
                },
                body: SafeArea(
                  child: Column(
                    children: [
                      const Header(),
                      Expanded(child: child),
                    ],
                  ),
                ),
              );
            },
          );
        },
        routes: [
          GoRoute(path: "/", builder: (context, state) => const FlexAIChat()),
          GoRoute(
            path: "/activation",
            builder: (context, state) => const ActivationScreen(),
          ),
          GoRoute(
            path: "/settings",
            builder: (context, state) => const Settings(),
          ),
          GoRoute(
            path: "/share",
            builder: (context, state) => const ShareScreen(),
          ),
        ],
      ),
    ],
  );
});

class FlexAI extends ConsumerStatefulWidget {
  const FlexAI({super.key});

  @override
  ConsumerState<FlexAI> createState() => _FlexAIState();
}

class _FlexAIState extends ConsumerState<FlexAI> {
  final SupabaseService _supabaseService = SupabaseService();
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    ref.read(appStateProvider).initApp();
    _subscribeToInstructionsChanges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(statusProvider, (previous, next) {
      if (next == true && previous != true) {
        _channel?.unsubscribe();
        _subscribeToInstructionsChanges();
      }
    });
  }

  void _subscribeToInstructionsChanges() {
    final instructionId = prefs.getString('instructionId');
    if (instructionId == null) return;

    debugPrint(
      'Subscribing to instructions changes for instructionId: $instructionId',
    );

    _channel = _supabaseService.subscribeToInstructions(
      instructionId: instructionId,
      onUpdate: (ownerText) {
        ref.invalidate(aiModelsProvider);
        if (ownerText != null) {
          prefs.setString('owner_text', ownerText);
        }
      },
    );
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
