import 'package:flexai/models/chat_message.dart';
import 'package:flexai/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

Widget chatBubble({
  required BuildContext context,
  required ChatMessage chat,
  required bool isRetrying,
  required bool isTyping,
  required Function(String) retryFn,
}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: chat.role == "model"
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 230, 230, 230),
            border: chat.status == 'failed' || chat.status == 'expired'
                ? BoxBorder.all(color: const Color.fromARGB(80, 255, 82, 82))
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
              MarkdownBody(
                data: chat.content,
                selectable: true,
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final Uri url = Uri.parse(href);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontFamily: "Poppins", fontSize: 16),
                  strong: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  a: TextStyle(
                    fontFamily: "monospace",
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),

              if (chat.role == 'user' && chat.status == 'failed')
                GestureDetector(
                  onTap: isRetrying || isTyping
                      ? null
                      : () => retryFn(chat.content),
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
                        isRetrying ? "Retrying..." : "Retry",
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

        if (chat.role == 'model')
          SvgPicture.asset(
            getAiModelAsset(chat.model),
            width: MediaQuery.of(context).size.width * 0.2 - 20,
          ),
      ],
    ),
  );
}
