import 'package:flexai/components/header.dart';
import 'package:flexai/components/sidebar_drawer.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/screens/flexai_chat.dart';
import 'package:flexai/screens/loading_screen.dart';
import 'package:flexai/screens/settings.dart';
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
      final isGoingToLoading = state.uri.toString() == '/loading';

      if (isLoading && !isGoingToLoading) {
        return '/loading';
      }

      if (!isLoading && isGoingToLoading) {
        return '/';
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
            path: "/settings",
            builder: (context, state) => const Settings(),
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
  @override
  void initState() {
    super.initState();
    ref.read(appStateProvider).initApp();
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
