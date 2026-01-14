import 'package:flexai/main.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';

class FlexAIChat extends StatefulWidget {
  const FlexAIChat({super.key});
  @override
  State<FlexAIChat> createState() => _FlexAIChatState();
}

class _FlexAIChatState extends State<FlexAIChat> {
  bool isTyping = false;
  bool isRetrying = false;
  bool isFetchingChats = false;
  String username = '';
  String conversationId = '';
  List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 0,
      conversationId: '',
      role: 'model',
      content: 'Welcome to Flex AI. What’s on your mind today?',
      createdAt: '',
    ),
  ];

  final TextEditingController _prompText = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkUsername();
  }

  Future<void> sendMessage(String prompt, {bool retry = false}) async {
    try {
      final ChatMessage reply = await SupabaseService().sendMessage(
        username,
        prompt,
        conversationId,
        null,
      );

      setState(() {
        if (retry) {
          isRetrying = false;
        }

        chatMessages.add(reply);
        if (conversationId.isEmpty) conversationId = reply.conversationId;

        isTyping = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        if (retry) {
          isRetrying = false;
        } else {
          chatMessages[chatMessages.length - 1].status = 'failed';
        }

        chatMessages.add(
          ChatMessage(
            id: 0,
            conversationId: '',
            role: 'model',
            content: 'Network error. Please check your internet connection.',
            createdAt: '',
          ),
        );
        isTyping = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    }
  }

  Future<void> fetchChatMessages() async {
    final messages = await SupabaseService().getChatMessages("conversationId");

    if (messages.isNotEmpty) {
      setState(() {
        chatMessages = messages;
      });
    }
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
    final TextEditingController localController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        // Local variables for the dialog state
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Set Username",
                style: TextStyle(fontFamily: "Poppins"),
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
                        setDialogState(() => errorMessage = null);
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final inputName = localController.text.trim();

                            if (inputName.isNotEmpty) {
                              setDialogState(() {
                                isLoading = true;
                                errorMessage = null;
                              });

                              try {
                                final userId = await SupabaseService()
                                    .registerUsername(inputName);

                                if (userId != null) {
                                  await prefs.setString("userId", userId);
                                  await prefs.setString("username", inputName);

                                  if (mounted) {
                                    setState(() {
                                      username = inputName;
                                    });
                                  }

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              } catch (e) {
                                switch (e) {
                                  case "DUPLICATE":
                                    return setDialogState(() {
                                      errorMessage = "Username already taken.";
                                      isLoading = false;
                                    });

                                  case "NETWORK_ERROR":
                                    return setDialogState(() {
                                      errorMessage =
                                          "Please check your internet connection.";
                                      isLoading = false;
                                    });

                                  default:
                                    return setDialogState(() {
                                      errorMessage =
                                          "Something went wrong. Please try again.";
                                      isLoading = false;
                                    });
                                }
                              }
                            }
                          },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _prompText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: isFetchingChats
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
                    controller: _scrollController,
                    child: Column(
                      // Chat messages will go here
                      children: [
                        ...chatMessages.map<Widget>((chat) {
                          return Align(
                            alignment: chat.role == "model"
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 100,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 230, 230, 230),
                                border:
                                    chat.status == 'failed' ||
                                        chat.status == 'expired'
                                    ? BoxBorder.all(
                                        color: const Color.fromARGB(
                                          80,
                                          255,
                                          82,
                                          82,
                                        ),
                                      )
                                    : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: chat.role == 'model'
                                      ? Radius.zero
                                      : Radius.circular(15),
                                  bottomRight: chat.role == 'model'
                                      ? Radius.circular(15)
                                      : Radius.zero,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat.content,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 16,
                                    ),
                                  ),

                                  if (chat.role == 'user' &&
                                      chat.status == 'failed')
                                    GestureDetector(
                                      onTap: isRetrying || isTyping
                                          ? null
                                          : () {
                                              setState(() {
                                                chatMessages.removeLast();
                                                isRetrying = true;
                                                isTyping = true;
                                              });
                                              sendMessage(
                                                chat.content,
                                                retry: true,
                                              );
                                            },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!isRetrying)
                                            Icon(
                                              Icons.refresh_rounded,
                                              color: Colors.red,
                                              size: 15,
                                            ),
                                          Text(
                                            isRetrying
                                                ? "Retrying..."
                                                : "Retry",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        if (isTyping)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 230, 230, 230),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.zero,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Thinking...",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // A small spinner
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
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
                  onTap: isTyping
                      ? null
                      : () async {
                          setState(() {
                            chatMessages.add(
                              ChatMessage(
                                id: 0,
                                conversationId: '',
                                role: 'user',
                                content: _prompText.text.trim(),
                                createdAt: '',
                              ),
                            );

                            chatMessages = chatMessages
                                .map(
                                  (c) => c.copyWith(
                                    status: c.status == 'failed'
                                        ? 'expired'
                                        : c.status,
                                  ),
                                )
                                .toList();

                            isTyping = true;
                          });

                          sendMessage(_prompText.text.trim());

                          _prompText.clear();
                          FocusScope.of(context).unfocus();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            scrollToBottom();
                          });
                        },
                  child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      border: BoxBorder.all(),
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
