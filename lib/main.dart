import 'package:flexai/components/header.dart';
import 'package:flexai/components/sidebar_drawer.dart';
import 'package:flexai/screens/flexai_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: FlexAI()));
}

class FlexAI extends StatelessWidget {
  const FlexAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          endDrawer: SidebarDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                Header(),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
      routes: [
        GoRoute(path: "/", builder: (context, state) => const FlexAIChat()),
      ],
    ),
  ],
);
