import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/observation_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/diary_provider.dart';
import '../providers/project_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/memory_provider.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';

/// 观察触发服务（工具类/单例）
///
/// 提供静态方法在各页面/APP启动时收集 Provider 数据，
/// 触发 ObservationProvider.generateObservation()。
/// 内置 3 秒防抖，避免频繁触发。
class ObservationService {
  ObservationService._(); // 私有构造，禁止实例化

  static Timer? _debounceTimer;

  /// 防抖触发观察
  ///
  /// 在 3 秒内多次调用只执行最后一次。
  /// 接收所有需要的 Provider 实例作为参数。
  static Future<void> triggerObservation({
    required ChatProvider chatProvider,
    required DiaryProvider diaryProvider,
    required ProjectProvider projectProvider,
    required BookshelfProvider bookshelfProvider,
    required TodoProvider todoProvider,
    required ObservationProvider observationProvider,
    required MemoryProvider memoryProvider,
  }) async {
    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 创建新的定时器，3秒后执行
    _debounceTimer = Timer(const Duration(seconds: 3), () async {
      await _collectAndGenerate(
        chatProvider: chatProvider,
        diaryProvider: diaryProvider,
        projectProvider: projectProvider,
        bookshelfProvider: bookshelfProvider,
        todoProvider: todoProvider,
        observationProvider: observationProvider,
        memoryProvider: memoryProvider,
      );
    });
  }

  /// 立即执行收集并生成（无防抖）
  ///
  /// 适合 APP 启动/页面初始化时直接调用。
  static Future<void> collectNow({
    required ChatProvider chatProvider,
    required DiaryProvider diaryProvider,
    required ProjectProvider projectProvider,
    required BookshelfProvider bookshelfProvider,
    required TodoProvider todoProvider,
    required ObservationProvider observationProvider,
    required MemoryProvider memoryProvider,
  }) async {
    _debounceTimer?.cancel();
    await _collectAndGenerate(
      chatProvider: chatProvider,
      diaryProvider: diaryProvider,
      projectProvider: projectProvider,
      bookshelfProvider: bookshelfProvider,
      todoProvider: todoProvider,
      observationProvider: observationProvider,
      memoryProvider: memoryProvider,
    );
  }

  /// 核心收集方法
  static Future<void> _collectAndGenerate({
    required ChatProvider chatProvider,
    required DiaryProvider diaryProvider,
    required ProjectProvider projectProvider,
    required BookshelfProvider bookshelfProvider,
    required TodoProvider todoProvider,
    required ObservationProvider observationProvider,
    required MemoryProvider memoryProvider,
  }) async {
    try {
      // 1. 收集最近30天的消息
      final recentMessages = _filterRecentMessages(
        chatProvider.messages,
        days: 30,
      );

      // 2. 收集最近30天的日记
      final recentDiaries = _filterRecentDiaries(
        diaryProvider.entries,
        days: 30,
      );

      // 3. 获取项目列表
      final projects = projectProvider.projects;

      // 4. 获取书籍列表
      final books = bookshelfProvider.books;

      // 5. 统计数据
      final messageCount = recentMessages.length;
      final diaryCount = recentDiaries.length;
      final todoCount = todoProvider.todos.length;

      // 6. 调用 ObservationProvider 生成快照
      final snapshot = await observationProvider.generateObservation(
        recentMessages: recentMessages,
        recentDiaries: recentDiaries,
        projects: projects,
        books: books,
        messageCounts: messageCount,
        diaryCounts: diaryCount,
        todoCounts: todoCount,
      );

      // 7. 观察结果 → Memory 晋升（自动持久化）
      await memoryProvider.promoteFromObservation(snapshot);

      debugPrint('[ObservationService] 观察+记忆完成: $messageCount 条消息, '
          '$diaryCount 篇日记, $todoCount 个待办, '
          '${memoryProvider.count} 条记忆');
    } catch (e) {
      debugPrint('[ObservationService] 收集数据异常: $e');
    }
  }

  /// 过滤最近 N 天的消息
  static List<ChatMessage> _filterRecentMessages(
    List<ChatMessage> messages, {
    int days = 30,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return messages.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  /// 过滤最近 N 天的日记
  static List<DiaryEntry> _filterRecentDiaries(
    List<DiaryEntry> entries, {
    int days = 30,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((e) => e.date.isAfter(cutoff)).toList();
  }
}
