import 'package:flexai/main.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';

class FlexAIChat extends StatefulWidget {
  const FlexAIChat({super.key});
  @override
  State<FlexAIChat> createState() => _FlexAIChatState();
}

class _FlexAIChatState extends State<FlexAIChat> {
  bool isFetching = false;
  String username = '';
  List<ChatMessage> chatMessages = [];

  final TextEditingController _usernameText = TextEditingController();
  final TextEditingController _prompText = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUsername();
  }

  Future<void> fetchChatMessages() async {
    final messages = await SupabaseService().getChatMessages("conversationId");

    if (messages.isNotEmpty) {
      setState(() {
        chatMessages = messages;
      });
    }
  }

  void _checkUsername() {
    final String? savedUsername = prefs.getString("username");

    if (savedUsername == null || savedUsername.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUsernameDialog();
      });
    } else {
      setState(() {
        username = savedUsername;
      });
    }
  }

  void _showUsernameDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Set Username",
          style: TextStyle(fontFamily: "Poppins"),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: _usernameText,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: "Poppins"),
          decoration: InputDecoration(
            hintText: "e.g. JuanTamad",
            hintStyle: TextStyle(fontFamily: "Poppins"),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                if (_usernameText.text.trim().isNotEmpty) {
                  await prefs.setString("username", _usernameText.text.trim());
                  setState(() => username = _usernameText.text.trim());
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameText.dispose();
    _prompText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isFetching
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator.adaptive(),
                      SizedBox(height: 10),
                      Text(
                        "Loading chat history...",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Chat messages will go here
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 230, 230, 230),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Hello! How can I assist you today?",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 15, left: 10, right: 10, top: 5),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 250, 250, 250),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 2),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _prompText,
                  cursorColor: Colors.black54,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Poppins",
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: "Poppins",
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () async {},
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    border: BoxBorder.all(),
                  ),
                  child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
