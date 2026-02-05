class AiModel {
  String id;
  String title;
  String? authorId;
  String? code;
  String? ownerText;

  AiModel(this.id, this.title, [this.authorId, this.code, this.ownerText]);

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      json['id'],
      json['title'],
      json['author_id'],
      json['code'],
      json['owner_text'],
    );
  }
}
