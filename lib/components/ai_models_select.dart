import 'package:flexai/models/ai_model.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiModelSelect extends ConsumerStatefulWidget {
  const AiModelSelect({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AiModelSelectState();
}

class _AiModelSelectState extends ConsumerState<AiModelSelect> {
  List<AiModel> aiModels = [
    AiModel('bbfb75e2-2a4e-4843-be60-0751440026db', 'Flex AI'),
  ];

  @override
  void initState() {
    super.initState();
    fetchModels();
  }

  Future<void> fetchModels() async {
    try {
      final models = await SupabaseService().getModels();

      if (models.isNotEmpty) {
        setState(() {
          aiModels = models;
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedModel = ref.watch(selectedModelProvider);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedModel,
        alignment: AlignmentDirectional.center,
        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(15),
        items: aiModels.map<DropdownMenuItem<String>>((AiModel model) {
          return DropdownMenuItem(
            value: model.id,
            child: Text(
              model.title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          ref.read(selectedModelProvider.notifier).state = newValue!;
          debugPrint(ref.read(selectedModelProvider));
        },
      ),
    );
  }
}
