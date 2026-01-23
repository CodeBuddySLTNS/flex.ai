class AiModel {
  String id;
  String title;
  String? authorId;
  String? code;

  AiModel(this.id, this.title, [this.authorId, this.code]);

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(json['id'], json['title'], json['author_id'], json['code']);
  }
}
