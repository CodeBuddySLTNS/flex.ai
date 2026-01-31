import 'package:flexai/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryProvider);

    return Drawer(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      child: Center(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: 40),
                SvgPicture.asset("assets/images/flexai.svg", width: 100),
                Text(
                  "version 1.0.0",
                  style: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
                ),
                SizedBox(height: 10),
              ],
            ),
            Divider(),

            ListTile(
              title: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5),
                  Text("Settings", style: TextStyle(fontFamily: "Poppins")),
                ],
              ),
              onTap: () {
                context.pop();
                context.go("/settings");
              },
            ),

            ListTile(
              title: Row(
                children: [
                  Icon(Icons.add_rounded),
                  SizedBox(width: 5),
                  Text("New chat", style: TextStyle(fontFamily: "Poppins")),
                ],
              ),
              onTap: () {
                ref.read(conversationIdProvider.notifier).state = 'new';
                ref.read(modelProvider.notifier).state = 'flex_ai';
                ref.read(selectedModelProvider.notifier).state =
                    'bbfb75e2-2a4e-4843-be60-0751440026db';
                debugPrint("dcd");
                context.pop();
              },
            ),

            Expanded(
              child: historyAsync.when(
                data: (chats) {
                  if (chats.isEmpty) {
                    return Text('No chats yet.');
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ListTile(
                        title: Text(
                          chat['title'] ?? "Untitled chat",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                        onTap: () {
                          debugPrint("chnage convo: ${chat['id']}");
                          ref.read(conversationIdProvider.notifier).state =
                              chat['id'];
                          context.pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading chats",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.red[300],
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(chatHistoryProvider);
                      },
                      label: Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
