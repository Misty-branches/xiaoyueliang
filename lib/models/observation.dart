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

  ObservationSnapshot({
    required this.id,
    required this.date,
    this.interests = const [],
    this.mood = const MoodState(),
    this.activeProjects = const [],
    this.reading,
    this.behavior = const BehaviorPattern(),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
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

/// 兴趣项：话题名称 + 相关度评分(0~1) + 最近提及时间
class InterestItem {
  final String topic;
  final double score;
  final DateTime lastMention;

  const InterestItem({
    required this.topic,
    required this.score,
    required this.lastMention,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'score': score,
        'lastMention': lastMention.toIso8601String(),
      };

  factory InterestItem.fromJson(Map<String, dynamic> json) => InterestItem(
        topic: json['topic'] as String,
        score: (json['score'] as num).toDouble(),
        lastMention: DateTime.parse(json['lastMention'] as String),
      );
}

/// 情绪状态
class MoodState {
  final String mood; // 'happy' | 'calm' | 'sad' | 'angry' | 'neutral'
  final double confidence;

  const MoodState({this.mood = 'neutral', this.confidence = 0.0});

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'confidence': confidence,
      };

  factory MoodState.fromJson(Map<String, dynamic> json) => MoodState(
        mood: json['mood'] as String? ?? 'neutral',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
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
