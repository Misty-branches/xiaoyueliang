import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory_item.dart';
import '../models/observation.dart';
import 'memory_promoter.dart';

/// Memory 持久化 Provider
///
/// 管理长期记忆的加载、保存、晋升查询。
/// 观察层每次生成 ObservationSnapshot 后，自动触发晋升。
class MemoryProvider extends ChangeNotifier {
  static const String _storageKey = 'moon_memories';

  List<MemoryItem> _memories = [];
  bool _loaded = false;

  /// 获取全部记忆
  List<MemoryItem> get memories => _memories;

  /// 是否已加载
  bool get isLoaded => _loaded;

  /// 记忆总数
  int get count => _memories.length;

  // ── 持久化 ──

  /// 从 SharedPreferences 加载记忆
  Future<void> loadMemories() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _memories = list.map((e) => MemoryItem.fromJson(e)).toList();
      }
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[MemoryProvider] 加载失败: $e');
      _loaded = true;
    }
  }

  /// 保存到 SharedPreferences
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_memories.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('[MemoryProvider] 保存失败: $e');
    }
  }

  // ── 晋升入口 ──

  /// 从 ObservationSnapshot 晋升记忆
  ///
  /// 调用 MemoryPromoter.promote() 处理，自动持久化。
  /// 通常在观察层生成快照后调用。
  Future<void> promoteFromObservation(ObservationSnapshot observation) async {
    _memories = MemoryPromoter.promote(observation, _memories);
    await _save();
    notifyListeners();
  }

  // ── 查询 ──

  /// 获取稳定记忆（stabilityScore ≥ threshold）
  List<MemoryItem> getStableMemories({double threshold = 0.5}) {
    return MemoryPromoter.getStableMemories(_memories, threshold: threshold);
  }

  /// 按类型获取
  List<MemoryItem> getByType(String type) {
    return _memories.where((m) => m.type == type).toList();
  }

  /// 兴趣类记忆
  List<MemoryItem> get topicMemories => getByType('topic');

  /// 情绪类记忆
  List<MemoryItem> get emotionMemories => getByType('emotion');

  /// 项目类记忆
  List<MemoryItem> get projectMemories => getByType('project');

  /// 阅读类记忆
  List<MemoryItem> get readingMemories => getByType('reading');

  /// 按稳定性降序
  List<MemoryItem> get topStable => MemoryPromoter.topStable(_memories);

  /// 按类型分组
  Map<String, List<MemoryItem>> get grouped => MemoryPromoter.groupByType(_memories);

  /// 获取记忆摘要文本（供Debug面板/今日寄语用）
  String get summary {
    if (_memories.isEmpty) return '暂无记忆';
    final stable = getStableMemories();
    if (stable.isEmpty) return '${_memories.length}条记忆，暂无稳定记忆';
    return '${_memories.length}条记忆，${stable.length}条稳定';
  }
}
