class BookItem {
  final String id;
  String title;
  String author;
  int totalPages;
  int currentPages;
  String coverEmoji; // using emoji as placeholder for cover art
  DateTime addedAt;

  BookItem({
    required this.id,
    required this.title,
    this.author = '',
    this.totalPages = 0,
    this.currentPages = 0,
    this.coverEmoji = '📖',
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get progress =>
      totalPages > 0 ? (currentPages / totalPages).clamp(0.0, 1.0) : 0.0;

  String get progressPercent => '${(progress * 100).toInt()}%';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'totalPages': totalPages,
        'currentPages': currentPages,
        'coverEmoji': coverEmoji,
        'addedAt': addedAt.toIso8601String(),
      };

  factory BookItem.fromJson(Map<String, dynamic> json) => BookItem(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String? ?? '',
        totalPages: json['totalPages'] as int? ?? 0,
        currentPages: json['currentPages'] as int? ?? 0,
        coverEmoji: json['coverEmoji'] as String? ?? '📖',
        addedAt: json['addedAt'] != null
            ? DateTime.parse(json['addedAt'] as String)
            : null,
      );
}
