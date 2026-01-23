import 'package:flexai/components/header.dart';
import 'package:flexai/components/sidebar_drawer.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/screens/flexai_chat.dart';
import 'package:flexai/screens/loading_screen.dart';
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

  runApp(
    const ProviderScope(
      child: FlexAI(), // Removed MaterialApp wrapper here, moved inside FlexAI
    ),
  );
}

// --- 1. THE APP STATE (Manages Loading) ---
class AppState extends ChangeNotifier {
  bool isLoading = true;

  Future<void> initApp() async {
    // This is where you put extra async checks (Auth, User Profile, etc.)
    // We add a delay to ensure the animation plays nicely
    await Future.delayed(const Duration(seconds: 4));

    isLoading = false;
    notifyListeners(); // Tells the Router to re-evaluate redirects
  }
}

final appStateProvider = ChangeNotifierProvider((ref) => AppState());

// --- 2. THE ROUTER PROVIDER (Replaces the global _router) ---
final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    initialLocation: "/",
    refreshListenable: appState, // Listens for notifyListeners() from AppState
    // THE REDIRECT LOGIC
    redirect: (context, state) {
      final isLoading = appState.isLoading;
      final isGoingToLoading = state.uri.toString() == '/loading';

      // If we are loading, but not on the loading screen -> Go to /loading
      if (isLoading && !isGoingToLoading) {
        return '/loading';
      }

      // If we are DONE loading, but still on loading screen -> Go to Home
      if (!isLoading && isGoingToLoading) {
        return '/';
      }

      return null; // No redirection needed
    },

    routes: [
      // ROUTE A: The Loading Screen (Outside ShellRoute)
      GoRoute(
        path: '/loading',
        // Paste the RobotLoadingScreen class I gave you into a file and import it
        builder: (context, state) => const RobotLoadingScreen(),
      ),

      // ROUTE B: The Main App Shell
      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                endDrawer: const SidebarDrawer(), // Added const for performance
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
        ],
      ),
    ],
  );
});

// --- 3. THE WIDGET ---
class FlexAI extends ConsumerStatefulWidget {
  const FlexAI({super.key});

  @override
  ConsumerState<FlexAI> createState() => _FlexAIState();
}

class _FlexAIState extends ConsumerState<FlexAI> {
  @override
  void initState() {
    super.initState();
    // Start the "Initialization" process when the app mounts
    ref.read(appStateProvider).initApp();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the routerProvider we created above
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
