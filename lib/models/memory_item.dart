/// Memory · 长期记忆数据结构
///
/// 由 MemoryPromoter 从 ObservationSnapshot 晋升而来，
/// 代表系统对用户的「稳定认知」——兴趣、项目、情绪模式、阅读习惯等。
class MemoryItem {
  final String id;
  final String type; // 'topic' | 'emotion' | 'project' | 'reading'
  final String content;
  final List<String> sourceKeys;
  final int frequency;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final double stabilityScore; // 0~1

  const MemoryItem({
    required this.id,
    required this.type,
    required this.content,
    this.sourceKeys = const [],
    this.frequency = 1,
    required this.firstSeen,
    required this.lastSeen,
    this.stabilityScore = 0.0,
  });

  MemoryItem copyWith({
    String? id,
    String? type,
    String? content,
    List<String>? sourceKeys,
    int? frequency,
    DateTime? firstSeen,
    DateTime? lastSeen,
    double? stabilityScore,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      sourceKeys: sourceKeys ?? this.sourceKeys,
      frequency: frequency ?? this.frequency,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      stabilityScore: stabilityScore ?? this.stabilityScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'sourceKeys': sourceKeys,
        'frequency': frequency,
        'firstSeen': firstSeen.toIso8601String(),
        'lastSeen': lastSeen.toIso8601String(),
        'stabilityScore': stabilityScore,
      };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
        id: json['id'] as String,
        type: json['type'] as String,
        content: json['content'] as String,
        sourceKeys: (json['sourceKeys'] as List?)?.cast<String>() ?? [],
        frequency: (json['frequency'] as num?)?.toInt() ?? 1,
        firstSeen: DateTime.parse(json['firstSeen'] as String),
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        stabilityScore: (json['stabilityScore'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  String toString() =>
      'MemoryItem($type: $content, freq=$frequency, stability=${stabilityScore.toStringAsFixed(2)})';
}
