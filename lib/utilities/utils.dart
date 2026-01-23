String getAiModelAsset(String? model) {
  switch (model) {
    case 'flex_ai':
      return "assets/images/flexai_icon.svg";

    case 'bardagul_ai':
      return "assets/images/badagul_ai.svg";

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
