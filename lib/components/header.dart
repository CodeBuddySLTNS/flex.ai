import 'package:flexai/components/ai_models_select.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends ConsumerWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset("assets/images/flexai.svg", width: 50),
          status
              ? AiModelSelect()
              : Text(
                  'Not activated',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.red[900],
                  ),
                ),
          IconButton(
            icon: Icon(Icons.menu, size: 30),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
