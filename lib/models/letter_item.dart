class LetterItem {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  LetterItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LetterItem.fromJson(Map<String, dynamic> json) => LetterItem(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        type: json['type'] as String,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
