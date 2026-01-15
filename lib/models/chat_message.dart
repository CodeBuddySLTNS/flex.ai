class ChatMessage {
  int id;
  String conversationId;
  String role;
  String content;
  String createdAt;
  String status;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.status = 'sending',
  });

  ChatMessage copyWith({String? status, String? content}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json["conversationId"],
      role: json["role"],
      content: json["content"],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
