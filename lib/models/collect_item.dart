class CollectItem {
  final String id;
  final String sourceType;
  final String? sourceId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime collectedAt;

  CollectItem({
    required this.id,
    required this.sourceType,
    this.sourceId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.collectedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'collectedAt': collectedAt.toIso8601String(),
      };

  factory CollectItem.fromJson(Map<String, dynamic> json) => CollectItem(
        id: json['id'] as String,
        sourceType: json['sourceType'] as String,
        sourceId: json['sourceId'] as String?,
        title: json['title'] as String,
        content: json['content'] as String,
        imageUrl: json['imageUrl'] as String?,
        collectedAt: DateTime.parse(json['collectedAt'] as String),
      );
}
