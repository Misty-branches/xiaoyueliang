import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/project_item.dart';
import '../models/book_item.dart';

/// 观察层核心 Provider
///
/// 负责从原始数据中提炼出 ObservationSnapshot，
/// 供 Agent 能力层（Shell/Cron）读取。
/// 所有提取器均有异常保护 fallback。
class ObservationProvider extends ChangeNotifier {
  static const String _storageKey = 'moon_latest_observation';

  ObservationSnapshot? _latestObservation;

  /// 获取最新观察快照（可能为 null）
  ObservationSnapshot? get latestObservation => _latestObservation;

  // ──────────────────────────────────────────────
  // 缓存加载与保存
  // ──────────────────────────────────────────────

  /// 从 SharedPreferences 加载缓存的观察快照
  Future<void> loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _latestObservation = ObservationSnapshot.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      // 缓存读取失败不阻塞，静默 fallback
      debugPrint('[ObservationProvider] 加载缓存失败: $e');
    }
  }

  /// 保存观察快照到 SharedPreferences
  Future<void> _saveToCache(ObservationSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(snapshot.toJson()));
    } catch (e) {
      debugPrint('[ObservationProvider] 保存缓存失败: $e');
    }
  }

  // ──────────────────────────────────────────────
  // 核心入口
  // ──────────────────────────────────────────────

  /// 生成观察快照
  ///
  /// 接收各数据源原始数据，依次调用 5 个提取器，
  /// 组合为 ObservationSnapshot 并缓存到 SharedPreferences。
  Future<ObservationSnapshot> generateObservation({
    required List<ChatMessage> recentMessages,
    required List<DiaryEntry> recentDiaries,
    required List<ProjectItem> projects,
    required List<BookItem> books,
    required int messageCounts,
    required int diaryCounts,
    required int todoCounts,
  }) async {
    try {
      final interests = extractInterests(recentMessages, recentDiaries);
      final mood = extractMood(recentMessages, recentDiaries);
      final activeProjects = extractActiveProjects(projects);
      final reading = extractReading(books, recentMessages);
      final behavior = extractBehavior(messageCounts, diaryCounts, todoCounts);

      final snapshot = ObservationSnapshot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        interests: interests,
        mood: mood,
        activeProjects: activeProjects,
        reading: reading,
        behavior: behavior,
      );

      _latestObservation = snapshot;
      await _saveToCache(snapshot);
      notifyListeners();

      return snapshot;
    } catch (e) {
      // 整体 fallback：返回空快照
      debugPrint('[ObservationProvider] generateObservation 异常: $e');
      final fallback = ObservationSnapshot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
      );
      _latestObservation = fallback;
      notifyListeners();
      return fallback;
    }
  }

  // ──────────────────────────────────────────────
  // 提取器 1：兴趣提取
  // ──────────────────────────────────────────────

  /// 提取用户近期兴趣话题
  ///
  /// 将聊天消息和日记文本合并，按空格/标点切词，
  /// 过滤单字和停用词后统计词频，按时间衰减加权。
  /// 取权重最高的前 5 个话题，score 归一化到 0~1。
  List<InterestItem> extractInterests(
    List<ChatMessage> recentMessages,
    List<DiaryEntry> recentDiaries, {
    int days = 14,
  }) {
    try {
      // 停用词表
      const stopWords = <String>{
        '的', '了', '是', '在', '有', '和', '就', '不', '人', '都',
        '一', '一个', '上', '也', '很', '到', '说', '要', '去',
        '你', '我', '他', '她', '它', '们', '这', '那',
        '什么', '怎么', '为什么', '因为', '所以', '但是', '如果', '虽然', '然后',
      };

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 切词正则：按空格、中英文标点分割
      final splitter = RegExp(
        r'''[\s,，。！？、；：·…—–—""''（）《》【】｛｝!?;:()]+''',
      );

      // 词频统计 <word, totalWeight>
      final Map<String, double> wordWeights = {};

      /// 处理单个文本段，根据天数差计算权重
      void processText(String text, DateTime itemDate) {
        final daysAgo = today.difference(
          DateTime(itemDate.year, itemDate.month, itemDate.day),
        ).inDays;

        if (daysAgo < 0 || daysAgo > days) return;

        // 今天权重 1.0，每倒退一天减 0.07，最低 0
        final weight = (1.0 - daysAgo * 0.07).clamp(0.0, 1.0);

        final words = text
            .split(splitter)
            .where((w) => w.trim().isNotEmpty)
            .where((w) => w.length > 1) // 过滤单字
            .where((w) => !stopWords.contains(w)) // 过滤停用词
            .toList();

        for (final word in words) {
          wordWeights[word] = (wordWeights[word] ?? 0.0) + weight;
        }
      }

      // 处理聊天消息
      for (final msg in recentMessages) {
        processText(msg.content, msg.timestamp);
      }

      // 处理日记（标题 + 内容）
      for (final diary in recentDiaries) {
        processText(diary.title, diary.date);
        processText(diary.content, diary.date);
      }

      if (wordWeights.isEmpty) return [];

      // 按权重降序排列，取前5
      final sorted = wordWeights.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top5 = sorted.take(5).toList();

      // 归一化：最大值缩放到 1.0
      final maxWeight = top5.first.value;
      if (maxWeight <= 0) return [];

      return top5.map((entry) {
        return InterestItem(
          topic: entry.key,
          score: (entry.value / maxWeight).clamp(0.0, 1.0),
          lastMention: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[ObservationProvider] extractInterests 异常: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────
  // 提取器 2：情绪提取
  // ──────────────────────────────────────────────

  /// 提取用户近期情绪状态
  ///
  /// 统计聊天消息和日记中正向/负向词的出现次数，
  /// 取置信度最高的情绪，返回 MoodState。
  MoodState extractMood(
    List<ChatMessage> recentMessages,
    List<DiaryEntry> recentDiaries, {
    int days = 7,
  }) {
    try {
      // 正向情绪词
      const positiveWords = <String>{
        '开心', '好棒', '喜欢', '笑', '棒', '太棒了', '爱了', '赞',
        '好', '舒服', '温暖', '可爱', '不错', '棒极了',
      };

      // 负向情绪词
      const negativeWords = <String>{
        '烦', '累', '生气', '难过', '伤心', '无聊', '烦死了', '累了',
        '没劲', '郁闷', '焦虑', '糟糕', '讨厌', '烦人',
      };

      int positiveCount = 0;
      int negativeCount = 0;

      // 统计消息
      for (final msg in recentMessages) {
        for (final word in positiveWords) {
          if (msg.content.contains(word)) positiveCount++;
        }
        for (final word in negativeWords) {
          if (msg.content.contains(word)) negativeCount++;
        }
      }

      // 统计日记
      for (final diary in recentDiaries) {
        final diaryText = '${diary.title} ${diary.content}';
        for (final word in positiveWords) {
          if (diaryText.contains(word)) positiveCount++;
        }
        for (final word in negativeWords) {
          if (diaryText.contains(word)) negativeCount++;
        }
      }

      final total = positiveCount + negativeCount;
      if (total == 0) {
        return const MoodState(mood: 'neutral', confidence: 0.0);
      }

      if (positiveCount > negativeCount) {
        return MoodState(
          mood: 'happy',
          confidence: positiveCount / total,
        );
      } else if (negativeCount > positiveCount) {
        return MoodState(
          mood: 'sad',
          confidence: negativeCount / total,
        );
      } else {
        return const MoodState(mood: 'neutral', confidence: 0.0);
      }
    } catch (e) {
      debugPrint('[ObservationProvider] extractMood 异常: $e');
      return const MoodState();
    }
  }

  // ──────────────────────────────────────────────
  // 提取器 3：活跃项目提取
  // ──────────────────────────────────────────────

  /// 提取近期活跃项目
  ///
  /// 检查每个项目的更新日期，在指定天数内有更新的标记为 active。
  List<ActiveProject> extractActiveProjects(
    List<ProjectItem> projects, {
    int days = 7,
  }) {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));

      return projects
          .where((p) => p.updatedAt.isAfter(cutoff))
          .map((p) => ActiveProject(
                name: p.title,
                status: p.status,
                lastUpdate: p.updatedAt,
              ))
          .toList();
    } catch (e) {
      debugPrint('[ObservationProvider] extractActiveProjects 异常: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────
  // 提取器 4：阅读进度提取
  // ──────────────────────────────────────────────

  /// 提取当前阅读进度
  ///
  /// 从书架上取进度最大且未读完（progress < 100%）的书，
  /// 在近期消息中统计书名提及次数作为讨论热度。
  /// 无进度中的书籍时返回 null。
  ReadingProgress? extractReading(
    List<BookItem> books,
    List<ChatMessage> recentMessages,
  ) {
    try {
      // 筛选进度在 (0%, 100%) 之间的书（已开始且未读完）
      final inProgress = books.where((b) => b.progress > 0 && b.progress < 1.0);

      if (inProgress.isEmpty) return null;

      // 取进度最大的书
      final target = inProgress.reduce(
        (a, b) => a.progress >= b.progress ? a : b,
      );

      // 在消息中搜索书名提及次数
      int discussions = 0;
      for (final msg in recentMessages) {
        if (msg.content.contains(target.title)) {
          discussions++;
        }
      }

      return ReadingProgress(
        book: target.title,
        progress: (target.progress * 100).toInt(), // 转为 0~100 整数
        discussions: discussions,
      );
    } catch (e) {
      debugPrint('[ObservationProvider] extractReading 异常: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // 提取器 5：行为模式提取
  // ──────────────────────────────────────────────

  /// 提取用户行为模式
  ///
  /// 根据消息、日记、待办的数据量推断最常用模块，
  /// 活跃时段暂时固定为 "22:00-00:00"。
  BehaviorPattern extractBehavior(
    int messageCounts,
    int diaryCounts,
    int todoCounts,
  ) {
    try {
      // 根据数据量判断最常用模块
      String favoriteModule;
      if (messageCounts >= diaryCounts && messageCounts >= todoCounts) {
        favoriteModule = '聊天';
      } else if (diaryCounts >= messageCounts && diaryCounts >= todoCounts) {
        favoriteModule = '日记';
      } else {
        favoriteModule = '待办';
      }

      return BehaviorPattern(
        activeTime: '22:00-00:00',
        favoriteModule: favoriteModule,
      );
    } catch (e) {
      debugPrint('[ObservationProvider] extractBehavior 异常: $e');
      return const BehaviorPattern();
    }
  }
}
