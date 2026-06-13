import '../models/observation.dart';
import '../models/memory_item.dart';

/// Memory 晋升算法
///
/// 将 ObservationSnapshot 中的结构化数据（兴趣/情绪/项目/阅读）
/// 晋升为长期记忆，包含稳定性评分和频次统计。
///
/// 晋升规则：
/// - 每条 Observation 子项 → 匹配或新建 MemoryItem
/// - frequency ≥ 3 或 跨度为 ≥7 天 → 稳定性升高
/// - frequency ≤ 1 且跨度 < 3 天 → 稳定性保持低值（暂不晋升）
class MemoryPromoter {
  static const double _initialStability = 0.3;
  static const double _stabilityBoost = 0.15;
  static const double _maxStability = 0.95;

  /// 从 ObservationSnapshot 晋升/更新记忆列表
  ///
  /// [observation] — 当前观察快照
  /// [existing] — 已有的记忆列表（来自持久化）
  /// 返回更新后的完整记忆列表
  static List<MemoryItem> promote(
    ObservationSnapshot observation,
    List<MemoryItem> existing,
  ) {
    final updated = <String, MemoryItem>{};

    // 先把现有记忆转成 Map<key, item> 用于快速查找
    for (final mem in existing) {
      updated[mem.id] = mem;
    }

    // ── 1. 兴趣 → Memory(type: 'topic') ──
    for (final interest in observation.interests) {
      final key = 'topic_${interest.topic}';
      final old = _findByKey(existing, key);
      if (old != null) {
        updated[key] = _update(old, key, interest.topic, observation.date);
      } else {
        updated[key] = _create(key, 'topic', interest.topic, observation.date);
      }
    }

    // ── 2. 情绪 → Memory(type: 'emotion') ──
    if (observation.mood.mood != 'neutral' || observation.mood.confidence > 0) {
      final key = 'emotion_${observation.mood.mood}';
      final old = _findByKey(existing, key);
      if (old != null) {
        updated[key] = _update(old, key, '情绪: ${observation.mood.mood}', observation.date);
      } else {
        updated[key] = _create(key, 'emotion', '情绪: ${observation.mood.mood}', observation.date);
      }
    }

    // ── 3. 活跃项目 → Memory(type: 'project') ──
    for (final project in observation.activeProjects) {
      final key = 'project_${project.name}';
      final old = _findByKey(existing, key);
      if (old != null) {
        updated[key] = _update(old, key, '项目: ${project.name}', observation.date);
      } else {
        updated[key] = _create(key, 'project', '项目: ${project.name}', observation.date);
      }
    }

    // ── 4. 阅读 → Memory(type: 'reading') ──
    if (observation.reading != null) {
      final key = 'reading_${observation.reading!.book}';
      final old = _findByKey(existing, key);
      if (old != null) {
        updated[key] = _update(old, key, '阅读: ${observation.reading!.book}', observation.date);
      } else {
        updated[key] = _create(key, 'reading', '阅读: ${observation.reading!.book}', observation.date);
      }
    }

    return updated.values.toList();
  }

  /// 按 key 查找现有记忆（兼容 id = key 的命名规则）
  static MemoryItem? _findByKey(List<MemoryItem> list, String key) {
    for (final item in list) {
      if (item.id == key) return item;
    }
    return null;
  }

  /// 创建新的 MemoryItem
  static MemoryItem _create(String id, String type, String content, DateTime now) {
    return MemoryItem(
      id: id,
      type: type,
      content: content,
      sourceKeys: [id],
      frequency: 1,
      firstSeen: now,
      lastSeen: now,
      stabilityScore: _initialStability,
    );
  }

  /// 更新已有 MemoryItem
  static MemoryItem _update(MemoryItem old, String id, String content, DateTime now) {
    final newFreq = old.frequency + 1;
    return old.copyWith(
      id: id,
      content: content,
      sourceKeys: [...old.sourceKeys, id],
      frequency: newFreq,
      lastSeen: now,
      stabilityScore: _calcStability(newFreq, old.firstSeen),
    );
  }

  /// 稳定性计算核心算法
  ///
  /// - freqScore: 频率越高越稳定 (frequency / 10, 上限1.0)
  /// - timeScore: 跨度越长越稳定 (days / 14, 上限1.0)
  /// - 加权：freq × 0.6 + time × 0.4
  /// - 每次更新会叠加 _stabilityBoost，但不超过 _maxStability
  static double _calcStability(int frequency, DateTime firstSeen) {
    final days = DateTime.now().difference(firstSeen).inDays + 1;
    final freqScore = (frequency / 10.0).clamp(0.0, 1.0);
    final timeScore = (days / 14.0).clamp(0.0, 1.0);
    return (freqScore * 0.6 + timeScore * 0.4 + _stabilityBoost).clamp(0.0, _maxStability);
  }

  /// 获取「稳定记忆」——已通过晋升门槛的记忆
  ///
  /// 默认 threshold=0.5，满足 frequency≥3 或 跨度≥7天 通常会达到
  static List<MemoryItem> getStableMemories(List<MemoryItem> memories, {double threshold = 0.5}) {
    return memories.where((m) => m.stabilityScore >= threshold).toList();
  }

  /// 按类型分组
  static Map<String, List<MemoryItem>> groupByType(List<MemoryItem> memories) {
    final map = <String, List<MemoryItem>>{};
    for (final m in memories) {
      map.putIfAbsent(m.type, () => []);
      map[m.type]!.add(m);
    }
    return map;
  }

  /// 按稳定性降序排列，取 topN
  static List<MemoryItem> topStable(List<MemoryItem> memories, {int topN = 5}) {
    final sorted = List<MemoryItem>.from(memories)
      ..sort((a, b) => b.stabilityScore.compareTo(a.stabilityScore));
    return sorted.take(topN).toList();
  }
}
