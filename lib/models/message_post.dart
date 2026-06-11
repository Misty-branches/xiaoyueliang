class MessagePost {
  final String id;
  final String userId;
  final String content;
  final String stickerColor;
  final String mood;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<MessageReply> replies;

  MessagePost({
    required this.id,
    required this.userId,
    required this.content,
    this.stickerColor = '#FFF7E6',
    this.mood = 'share',
    this.imageUrl,
    DateTime? createdAt,
    List<String>? likes,
    List<MessageReply>? replies,
  })  : createdAt = createdAt ?? DateTime.now(),
        likes = likes ?? [],
        replies = replies ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'content': content,
        'stickerColor': stickerColor,
        'mood': mood,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  factory MessagePost.fromJson(Map<String, dynamic> json) => MessagePost(
        id: json['id'] as String,
        userId: json['userId'] as String,
        content: json['content'] as String,
        stickerColor: json['stickerColor'] as String? ?? '#FFF7E6',
        mood: json['mood'] as String? ?? 'share',
        imageUrl: json['imageUrl'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        likes: json['likes'] != null
            ? (json['likes'] as List).map((e) => e as String).toList()
            : null,
        replies: json['replies'] != null
            ? (json['replies'] as List)
                .map((e) => MessageReply.fromJson(e))
                .toList()
            : null,
      );
}

class MessageReply {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String mood;
  final DateTime createdAt;
  final List<String> likes;

  MessageReply({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.mood = 'share',
    DateTime? createdAt,
    List<String>? likes,
  })  : createdAt = createdAt ?? DateTime.now(),
        likes = likes ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'userId': userId,
        'content': content,
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
      };

  factory MessageReply.fromJson(Map<String, dynamic> json) => MessageReply(
        id: json['id'] as String,
        postId: json['postId'] as String,
        userId: json['userId'] as String,
        content: json['content'] as String,
        mood: json['mood'] as String? ?? 'share',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        likes: json['likes'] != null
            ? (json['likes'] as List).map((e) => e as String).toList()
            : null,
      );
}
