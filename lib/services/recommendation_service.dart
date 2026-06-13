import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../models/book_item.dart';

/// 推荐阅读服务
/// 根据观察结果的兴趣话题，推荐书籍
class RecommendationService {
  /// 生成推荐阅读列表
  /// 读取观察结果中的 interests + 书房书籍列表
  /// 返回 List<Map>，每项含 { bookTitle, reason, matchScore }
  static Future<List<Map<String, dynamic>>> generate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 读取 moon_latest_observation 中的 interests（top3）
      final raw = prefs.getString('moon_latest_observation');
      if (raw == null) {
        // 没有观察快照，无法推荐
        await prefs.setString('moon_recommendations', '[]');
        return [];
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final snapshot = ObservationSnapshot.fromJson(json);

      // 取 top3 兴趣话题
      final interests = snapshot.interests.take(3).toList();
      if (interests.isEmpty) {
        // 没有兴趣话题，无法推荐
        await prefs.setString('moon_recommendations', '[]');
        return [];
      }

      // 2. 从 SharedPreferences 读取书籍列表
      final booksData = prefs.getString('books');
      List<BookItem> books = [];
      if (booksData != null) {
        try {
          final bookList = jsonDecode(booksData) as List;
          books = bookList.map((e) => BookItem.fromJson(e)).toList();
        } catch (e) {
          // 书籍解析失败
        }
      }

      // 也尝试读取 moon_books key（向后兼容）
      if (books.isEmpty) {
        final moonBooksData = prefs.getString('moon_books');
        if (moonBooksData != null) {
          try {
            final bookList = jsonDecode(moonBooksData) as List;
            books = bookList.map((e) => BookItem.fromJson(e)).toList();
          } catch (e) {
            // 旧格式解析失败
          }
        }
      }

      if (books.isEmpty) {
        // 没有书籍，无法推荐
        await prefs.setString('moon_recommendations', '[]');
        return [];
      }

      // 3-4. 遍历书籍标题，检查是否包含兴趣话题关键词，计算匹配得分
      final List<Map<String, dynamic>> recommendations = [];

      for (final book in books) {
        double matchScore = 0.0;
        final List<String> matchedTopics = [];

        for (final interest in interests) {
          // 书名包含兴趣词（忽略大小写）
          if (book.title.toLowerCase().contains(interest.topic.toLowerCase())) {
            matchScore += 0.5;
            matchedTopics.add(interest.topic);
          }
        }

        if (matchScore > 0) {
          // 5. 生成推荐理由
          final topicStr = matchedTopics.take(2).join('「、」');
          final reason = matchedTopics.length == 1
              ? '因为最近你对「$topicStr」很感兴趣'
              : '因为最近你对「${matchedTopics.first}」等话题很感兴趣';

          recommendations.add({
            'bookTitle': book.title,
            'author': book.author,
            'reason': reason,
            'matchScore': matchScore,
            'matchedTopics': matchedTopics,
          });
        }
      }

      // 按匹配分数从高到低排序
      recommendations.sort((a, b) =>
          (b['matchScore'] as double).compareTo(a['matchScore'] as double));

      // 6. 结果存入 SharedPreferences
      await prefs.setString('moon_recommendations', jsonEncode(recommendations));

      return recommendations;
    } catch (e) {
      // 异常保护：返回空列表
      final emptyList = <Map<String, dynamic>>[];
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('moon_recommendations', '[]');
      } catch (_) {
        // 忽略存储异常
      }
      return emptyList;
    }
  }
}
