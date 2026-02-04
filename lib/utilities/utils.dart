import 'package:flexai/models/ai_model.dart';

String getAiModelAsset(String? model) {
  switch (model) {
    case 'flex_ai':
      return "assets/images/flexai_icon.svg";

    case 'bardagul_ai':
      return "assets/images/bardagul_ai.svg";

    case 'tita_ai':
      return "assets/images/tita_ai.svg";

    case 'harot_ai':
      return "assets/images/harot_ai.svg";

    case 'other_ai':
      return "assets/images/other_ai.svg";

    default:
      return "assets/images/error_ai.svg";
  }
}

String getGreetings(String? model) {
  switch (model) {
    case 'bardagul_ai':
      return "Welcome sa Flex AI. Bilisan mo, marami pa akong gagawin. Anong kadramahan na naman ang dala mo today? Ready na ako mang-roast.";

    case 'tita_ai':
      return "Hello there! Welcome to Flex AI. Grabe, ang init sa labas 'no? Anyway, how are you? May problema ba sa love life? Kwento ka naman kay Tita.";

    case 'harot_ai':
      return "Hello baby! Welcome to Flex AI. You look good today ha. 😉 Ano, usap tayo? I’m all yours. What’s on your pretty mind?";

    case 'other_ai':
      return "Hi there! How can I help you today?";

    default:
      return "Welcome to Flex AI. What’s on your mind today?";
  }
}

String getModelById(String id, List<AiModel> models) {
  AiModel result = models.firstWhere(
    (person) => person.id == id,
    orElse: () => AiModel('', 'Flex AI'),
  );

  return result.code ?? 'flex_ai';
}
