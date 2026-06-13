/// 观察层 · 数据结构
/// 由 ObservationProvider 从原始数据提炼，供 Agent 能力层读取。

class ObservationSnapshot {
  final String id;
  final DateTime date;
  final List<InterestItem> interests;
  final MoodState mood;
  final List<ActiveProject> activeProjects;
  final ReadingProgress? reading;
  final BehaviorPattern behavior;

  /// 整体可信度评分 (0~1)
  ///
  /// 由各子项的分数加权平均计算：
  /// - 兴趣均分 × 0.3 + 情绪置信度 × 0.3
  /// - + 活跃项目 (有=0.7) × 0.2 + 阅读状态 (有=0.6) × 0.2
  final double confidence;

  ObservationSnapshot({
    required this.id,
    required this.date,
    this.interests = const [],
    this.mood = const MoodState(),
    this.activeProjects = const [],
    this.reading,
    this.behavior = const BehaviorPattern(),
    double? confidence,
  }) : confidence = confidence ?? _calcConfidence(interests, mood, activeProjects, reading);

  /// 静态计算方法（构造函数默认调用）
  static double _calcConfidence(
    List<InterestItem> interests,
    MoodState mood,
    List<ActiveProject> activeProjects,
    ReadingProgress? reading,
  ) {
    double interestScore = 0.0;
    if (interests.isNotEmpty) {
      interestScore = interests.map((i) => i.score).reduce((a, b) => a + b) / interests.length;
    }

    final double moodScore = mood.confidence;
    final double projectScore = activeProjects.isNotEmpty ? 0.7 : 0.0;
    final double readingScore = reading != null ? 0.6 : 0.0;

    return (interestScore * 0.3 + moodScore * 0.3 + projectScore * 0.2 + readingScore * 0.2)
        .clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'confidence': confidence,
        'interests': interests.map((i) => i.toJson()).toList(),
        'mood': mood.toJson(),
        'activeProjects': activeProjects.map((p) => p.toJson()).toList(),
        if (reading != null) 'reading': reading!.toJson(),
        'behavior': behavior.toJson(),
      };

  factory ObservationSnapshot.fromJson(Map<String, dynamic> json) =>
      ObservationSnapshot(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        confidence: (json['confidence'] as num?)?.toDouble(),
        interests: (json['interests'] as List?)
                ?.map((e) => InterestItem.fromJson(e))
                .toList() ??
            [],
        mood: json['mood'] != null
            ? MoodState.fromJson(json['mood'])
            : const MoodState(),
        activeProjects: (json['activeProjects'] as List?)
                ?.map((e) => ActiveProject.fromJson(e))
                .toList() ??
            [],
        reading: json['reading'] != null
            ? ReadingProgress.fromJson(json['reading'])
            : null,
        behavior: json['behavior'] != null
            ? BehaviorPattern.fromJson(json['behavior'])
            : const BehaviorPattern(),
      );
}

/// 兴趣项：话题名称 + 相关度评分(0~1) + 最近提及时间 + 来源类型
class InterestItem {
  final String topic;
  final double score;
  final DateTime lastMention;
  final String sourceType; // 'explicit' | 'implicit' | 'inferred'

  const InterestItem({
    required this.topic,
    required this.score,
    required this.lastMention,
    this.sourceType = 'inferred',
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'score': score,
        'lastMention': lastMention.toIso8601String(),
        'sourceType': sourceType,
      };

  factory InterestItem.fromJson(Map<String, dynamic> json) => InterestItem(
        topic: json['topic'] as String,
        score: (json['score'] as num).toDouble(),
        lastMention: DateTime.parse(json['lastMention'] as String),
        sourceType: json['sourceType'] as String? ?? 'inferred',
      );
}

/// 情绪状态
class MoodState {
  final String mood; // 'happy' | 'calm' | 'sad' | 'angry' | 'neutral'
  final double confidence;
  final String sourceType; // 'explicit' | 'implicit' | 'inferred'

  const MoodState({
    this.mood = 'neutral',
    this.confidence = 0.0,
    this.sourceType = 'inferred',
  });

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'confidence': confidence,
        'sourceType': sourceType,
      };

  factory MoodState.fromJson(Map<String, dynamic> json) => MoodState(
        mood: json['mood'] as String? ?? 'neutral',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        sourceType: json['sourceType'] as String? ?? 'inferred',
      );
}

/// 活跃项目
class ActiveProject {
  final String name;
  final String status; // 'active' | 'paused' | 'completed'
  final DateTime lastUpdate;

  const ActiveProject({
    required this.name,
    this.status = 'active',
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
        'lastUpdate': lastUpdate.toIso8601String(),
      };

  factory ActiveProject.fromJson(Map<String, dynamic> json) => ActiveProject(
        name: json['name'] as String,
        status: json['status'] as String? ?? 'active',
        lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      );
}

/// 阅读进度
class ReadingProgress {
  final String book;
  final int progress; // 0~100
  final int discussions;

  const ReadingProgress({
    required this.book,
    this.progress = 0,
    this.discussions = 0,
  });

  Map<String, dynamic> toJson() => {
        'book': book,
        'progress': progress,
        'discussions': discussions,
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        book: json['book'] as String,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        discussions: (json['discussions'] as num?)?.toInt() ?? 0,
      );
}

/// 行为模式
class BehaviorPattern {
  final String activeTime; // 活跃时段描述，如 "22:00-00:00"
  final String favoriteModule; // 最爱模块

  const BehaviorPattern({
    this.activeTime = '',
    this.favoriteModule = '',
  });

  Map<String, dynamic> toJson() => {
        'activeTime': activeTime,
        'favoriteModule': favoriteModule,
      };

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) =>
      BehaviorPattern(
        activeTime: json['activeTime'] as String? ?? '',
        favoriteModule: json['favoriteModule'] as String? ?? '',
      );
}
