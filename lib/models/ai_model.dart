class AiModel {
  String id;
  String title;
  String? authorId;

  AiModel(this.id, this.title, [this.authorId]);

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(json['id'], json['title'], json['author_id']);
  }
}
