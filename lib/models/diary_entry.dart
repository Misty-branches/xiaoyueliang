class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String category; // 'diary' | 'dream'
  final DateTime date;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'date': date.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
