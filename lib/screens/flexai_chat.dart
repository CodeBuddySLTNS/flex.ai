import 'package:flexai/components/chat_message.dart';
import 'package:flexai/components/set_username.dart';
import 'package:flexai/main.dart';
import 'package:flexai/models/chat_message.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flexai/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlexAIChat extends ConsumerStatefulWidget {
  const FlexAIChat({super.key});
  @override
  ConsumerState<FlexAIChat> createState() => _FlexAIChatState();
}

class _FlexAIChatState extends ConsumerState<FlexAIChat> {
  bool isTyping = false;
  bool isRetrying = false;
  bool isFetchingChats = false;
  String username = '';
  String conversationId = '';
  List<ChatMessage> chatMessages = [];

  final TextEditingController _prompText = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkUsername();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final convoId = ref.read(conversationIdProvider);
      if (convoId.isNotEmpty) {
        fetchChatMessages(convoId);
      }
    });
  }

  Future<void> sendMessage(String prompt, {bool retry = false}) async {
    try {
      debugPrint('convo id: $conversationId');
      final ChatMessage reply = await SupabaseService().sendMessage(
        username,
        prompt,
        conversationId != 'new' ? conversationId : '',
        ref.watch(selectedModelProvider),
      );

      setState(() {
        if (retry) {
          isRetrying = false;
          chatMessages[chatMessages.length - 1].status = 'sent';
        }

        chatMessages.add(reply);
        if (conversationId.isEmpty) {
          conversationId = reply.conversationId;
          ref.read(conversationIdProvider.notifier).state =
              reply.conversationId;
        }

        isTyping = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
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
            content: e == 'SERVER_ERROR'
                ? 'Something went wrong with our server. Please try again.'
                : 'Network error. Please check your internet connection.',
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

  Future<void> fetchChatMessages(String convoId) async {
    setState(() {
      isFetchingChats = true;
      chatMessages = [];
    });

    try {
      final messages = await SupabaseService().getChatMessages(convoId);

      setState(() {
        conversationId = convoId;
        isFetchingChats = false;
      });

      setState(() {
        chatMessages = messages;
      });
    } catch (e) {
      setState(() {
        isFetchingChats = false;
      });
    }
  }

  void retryFn(String message) {
    setState(() {
      chatMessages.removeLast();
      isRetrying = true;
      isTyping = true;
    });
    sendMessage(message, retry: true);
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _checkUsername() {
    final String? savedUsername =
        prefs.getString("username") ?? ref.read(usernameProvider);

    if (savedUsername == null || savedUsername.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUsernameDialog(context: context);
      });
    } else {
      setState(() {
        username = savedUsername;
      });
    }
  }

  @override
  void dispose() {
    _prompText.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);

    ref.listen(
      usernameProvider,
      (prev, next) => setState(() => username = next),
    );

    ref.listen(conversationIdProvider, (prev, next) {
      debugPrint("prev: $prev");
      debugPrint("next: $next");

      if (next != conversationId && next != 'new' && next != 'settings') {
        fetchChatMessages(next);
      } else if (next == 'new') {
        conversationId = '';
        if (context.mounted) setState(() => chatMessages = []);
      }
    });

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
                          "Loading chat messages...",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        chatBubble(
                          chat: ChatMessage(
                            id: 0,
                            conversationId: '',
                            role: 'model',
                            model: model.isNotEmpty ? model : 'flex_ai',
                            content: getGreetings(model),
                            createdAt: '',
                          ),
                          context: context,
                          isRetrying: isRetrying,
                          isTyping: isTyping,
                          retryFn: retryFn,
                        ),

                        // Chat messages will go here
                        ...chatMessages.map<Widget>((chat) {
                          return chatBubble(
                            chat: chat,
                            context: context,
                            isRetrying: isRetrying,
                            isTyping: isTyping,
                            retryFn: retryFn,
                          );
                        }),

                        if (isTyping)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
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
                                SvgPicture.asset(
                                  getAiModelAsset(
                                    model.isNotEmpty ? model : 'flex_ai',
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.2 -
                                      20,
                                ),
                              ],
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
