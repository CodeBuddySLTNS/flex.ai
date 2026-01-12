import 'package:flexai/components/header.dart';
import 'package:flexai/components/sidebar_drawer.dart';
import 'package:flexai/screens/flexai_chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
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
