import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

/// 来信检测服务
/// 检测用户是否长时间未互动，标记"可生成来信"状态
class LetterDetectionService {
  /// 检测是否需要生成来信
  /// 读取观察快照 + 检查各数据源最近互动时间
  /// 返回 { ready: bool, reason: String, daysSinceLastInteraction: int, checkedAt: String }
  static Future<Map<String, dynamic>> check() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 读取观察快照
      final raw = prefs.getString('moon_latest_observation');
      ObservationSnapshot? snapshot;
      if (raw != null) {
        try {
          final json = jsonDecode(raw) as Map<String, dynamic>;
          snapshot = ObservationSnapshot.fromJson(json);
        } catch (e) {
          // 观察快照解析失败，继续检查其他数据源
        }
      }

      // 2. 从 observation.behavior.favoriteModule 了解最爱模块
      final favoriteModule = snapshot?.behavior.favoriteModule ?? '';

      // 3. 在各 SharedPreferences key 中检查最近互动时间
      DateTime? latestInteraction;

      // 3a. 聊天消息 → 检查 conversations 列表中的最新 updatedAt
      try {
        final convData = prefs.getString('conversations');
        if (convData != null) {
          final convList = jsonDecode(convData) as List;
          for (final c in convList) {
            final conv = Conversation.fromJson(c);
            if (latestInteraction == null ||
                conv.updatedAt.isAfter(latestInteraction)) {
              latestInteraction = conv.updatedAt;
            }
          }
        }
      } catch (e) {
        // 忽略聊天记录解析错误
      }

      // 3b. 聊天消息旧格式 → 尝试 moon_messages key（向后兼容）
      try {
        final moonMsgData = prefs.getString('moon_messages');
        if (moonMsgData != null) {
          final msgList = jsonDecode(moonMsgData) as List;
          for (final m in msgList) {
            final msg = ChatMessage.fromJson(m);
            if (latestInteraction == null ||
                msg.timestamp.isAfter(latestInteraction)) {
              latestInteraction = msg.timestamp;
            }
          }
        }
      } catch (e) {
        // 忽略旧格式解析错误
      }

      // 3c. 日记 → 检查 diary_entries 列表
      try {
        final diaryData = prefs.getString('diary_entries');
        if (diaryData != null) {
          final diaryList = jsonDecode(diaryData) as List;
          for (final d in diaryList) {
            final dateStr = d['date'] as String?;
            if (dateStr != null) {
              final date = DateTime.parse(dateStr);
              if (latestInteraction == null || date.isAfter(latestInteraction)) {
                latestInteraction = date;
              }
            }
          }
        }
      } catch (e) {
        // 忽略日记解析错误
      }

      // 3d. 日记旧格式 → 尝试 moon_diary key
      try {
        final moonDiaryData = prefs.getString('moon_diary');
        if (moonDiaryData != null) {
          final diaryList = jsonDecode(moonDiaryData) as List;
          for (final d in diaryList) {
            final dateStr = d['date'] as String?;
            if (dateStr != null) {
              final date = DateTime.parse(dateStr);
              if (latestInteraction == null || date.isAfter(latestInteraction)) {
                latestInteraction = date;
              }
            }
          }
        }
      } catch (e) {
        // 忽略旧格式解析错误
      }

      // 3e. 留言板 → 检查 message_posts 列表
      try {
        final postsData = prefs.getString('message_posts');
        if (postsData != null) {
          final postList = jsonDecode(postsData) as List;
          for (final p in postList) {
            final dateStr = p['createdAt'] as String?;
            if (dateStr != null) {
              final date = DateTime.parse(dateStr);
              if (latestInteraction == null || date.isAfter(latestInteraction)) {
                latestInteraction = date;
              }
            }
          }
        }
      } catch (e) {
        // 忽略留言板解析错误
      }

      // 3f. 留言板旧格式 → 尝试 moon_posts key
      try {
        final moonPostsData = prefs.getString('moon_posts');
        if (moonPostsData != null) {
          final postList = jsonDecode(moonPostsData) as List;
          for (final p in postList) {
            final dateStr = p['createdAt'] as String?;
            if (dateStr != null) {
              final date = DateTime.parse(dateStr);
              if (latestInteraction == null || date.isAfter(latestInteraction)) {
                latestInteraction = date;
              }
            }
          }
        }
      } catch (e) {
        // 忽略旧格式解析错误
      }

      // 4-5. 计算 daysSinceLastInteraction
      final now = DateTime.now();
      final int daysSinceLastInteraction;
      final bool ready;
      String reason;

      if (latestInteraction != null) {
        daysSinceLastInteraction = now.difference(latestInteraction).inDays;
      } else {
        // 没有任何互动记录，默认视为很久未互动
        daysSinceLastInteraction = 999;
      }

      // 6. 判断是否需要生成来信
      if (latestInteraction == null) {
        ready = true;
        reason = '还没有任何互动记录，可以写一封问候信～';
      } else if (daysSinceLastInteraction > 5) {
        ready = true;
        reason = '你已经 $daysSinceLastInteraction 天没有来找小月亮了，'
            '${favoriteModule.isNotEmpty ? "要不要聊聊「$favoriteModule」？" : "想给你写封信～"}';
      } else {
        ready = false;
        reason = '最近 $daysSinceLastInteraction 天内有互动，暂时不需要来信';
      }

      // 7. 结果存入 SharedPreferences
      final result = {
        'ready': ready,
        'reason': reason,
        'daysSinceLastInteraction': daysSinceLastInteraction,
        'checkedAt': now.toIso8601String(),
      };
      await prefs.setString('moon_letter_ready', jsonEncode(result));

      return result;
    } catch (e) {
      // 异常保护：返回安全默认值
      final fallback = {
        'ready': false,
        'reason': '检测来信状态时发生错误：$e',
        'daysSinceLastInteraction': -1,
        'checkedAt': DateTime.now().toIso8601String(),
      };
      return fallback;
    }
  }
}
