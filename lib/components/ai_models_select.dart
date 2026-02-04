import 'package:flexai/main.dart';
import 'package:flexai/models/ai_model.dart';
import 'package:flexai/providers/chat_provider.dart';
import 'package:flexai/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class AiModelSelect extends ConsumerWidget {
  const AiModelSelect({super.key});

  // default fallback model
  static final _defaultModel = AiModel(
    prefs.getString('default_model') ?? 'bbfb75e2-2a4e-4843-be60-0751440026db',
    prefs.getString('default_model_title') ?? 'Flex AI',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    final modelsAsync = ref.watch(aiModelsProvider);

    return modelsAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => const SizedBox(
        width: 100,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => TextButton(
        onPressed: () => ref.refresh(aiModelsProvider),
        child: const Text(
          'Error. Retry?',
          style: TextStyle(fontFamily: 'Poppins'),
          textAlign: TextAlign.center,
        ),
      ),
      data: (models) {
        // ensure we have at least the default model
        final aiModels = models.isEmpty ? [_defaultModel] : models;

        // ensure selected model exists in list, otherwise use first
        final validSelection = aiModels.any((m) => m.id == selectedModel)
            ? selectedModel
            : 'bbfb75e2-2a4e-4843-be60-0751440026db';

        // update selection if it was invalid
        if (validSelection != selectedModel) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedModelProvider.notifier).state = validSelection;
          });
        }

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: validSelection,
            alignment: AlignmentDirectional.center,
            dropdownColor: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
            items: aiModels.map<DropdownMenuItem<String>>((AiModel model) {
              return DropdownMenuItem(
                value: model.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(getAiModelAsset(model.code), width: 30),
                    const SizedBox(width: 5),
                    Text(
                      model.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              ref.read(selectedModelProvider.notifier).state = newValue!;
              ref.read(modelProvider.notifier).state = getModelById(
                newValue,
                aiModels,
              );
            },
          ),
        );
      },
    );
  }
}
