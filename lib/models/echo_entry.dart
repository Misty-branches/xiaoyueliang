class EchoEntry {
  final String id;
  final String title;
  final String content;
  final String code;
  final String link;
  final DateTime date;

  EchoEntry({
    required this.id,
    required this.title,
    required this.content,
    this.code = '',
    this.link = '',
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'code': code,
        'link': link,
        'date': date.toIso8601String(),
      };

  factory EchoEntry.fromJson(Map<String, dynamic> json) => EchoEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        code: json['code'] as String? ?? '',
        link: json['link'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
      );
}
