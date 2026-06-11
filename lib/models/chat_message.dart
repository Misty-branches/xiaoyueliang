class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;
  final String? thinking; // 思考链内容 (only for assistant messages)
  final String language; // 'zh' | 'en' — 消息语言，支持中英转换
  final bool hasAudio; // 是否有语音版本
  final int likes; // 赞数
  final int dislikes; // 踩数

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.thinking,
    this.language = 'zh',
    this.hasAudio = false,
    this.likes = 0,
    this.dislikes = 0,
  });

  ChatMessage copyWith({
    String? content,
    String? thinking,
    String? language,
    bool? hasAudio,
    int? likes,
    int? dislikes,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        timestamp: timestamp,
        thinking: thinking ?? this.thinking,
        language: language ?? this.language,
        hasAudio: hasAudio ?? this.hasAudio,
        likes: likes ?? this.likes,
        dislikes: dislikes ?? this.dislikes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        if (thinking != null) 'thinking': thinking,
        'language': language,
        'hasAudio': hasAudio,
        'likes': likes,
        'dislikes': dislikes,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        thinking: json['thinking'] as String?,
        language: json['language'] as String? ?? 'zh',
        hasAudio: json['hasAudio'] as bool? ?? false,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      );
}
