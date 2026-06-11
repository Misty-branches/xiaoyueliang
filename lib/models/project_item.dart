class ProjectItem {
  final String id;
  final String title;
  final String description;
  final String status;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  ProjectItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'active',
    this.progress = 0.0,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'progress': progress,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
      };

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: json['status'] as String? ?? 'active',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      );
}
