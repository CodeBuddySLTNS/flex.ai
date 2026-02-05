import 'package:flexai/main.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showUsernameDialog({required BuildContext context}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => UsernameDialog(),
  );
}

class UsernameDialog extends ConsumerStatefulWidget {
  const UsernameDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends ConsumerState<UsernameDialog> {
  final TextEditingController localController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Your Name",
        style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: localController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: "Poppins"),
            decoration: const InputDecoration(
              hintText: "e.g. JuanTamad",
              hintStyle: TextStyle(fontFamily: "Poppins"),
            ),
            onChanged: (_) {
              if (errorMessage != null) {
                setState(() => errorMessage = null);
              }
            },
          ),
          const SizedBox(height: 5),

          if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: isLoading
                ? null
                : () async {
                    final inputName = localController.text.trim();

                    if (inputName.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        final userId = await SupabaseService().registerUsername(
                          inputName,
                        );

                        if (userId != null) {
                          await prefs.setString("userId", userId);
                          await prefs.setString("username", inputName);
                          ref.read(usernameProvider.notifier).state = inputName;
                          ref.invalidate(aiModelsProvider);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      } catch (e) {
                        switch (e) {
                          case "DUPLICATE":
                            return setState(() {
                              errorMessage = "Username already taken.";
                              isLoading = false;
                            });

                          case "NETWORK_ERROR":
                            return setState(() {
                              errorMessage =
                                  "Please check your internet connection.";
                              isLoading = false;
                            });

                          default:
                            return setState(() {
                              errorMessage =
                                  "Something went wrong. Please try again.";
                              isLoading = false;
                            });
                        }
                      }
                    }
                  },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
