import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/observation.dart';

class DailyMessage {
  final String message;
  final String tone;
  final DateTime generatedAt;
  final DateTime expiresAt;

  DailyMessage({
    required this.message,
    this.tone = 'warm',
    required this.generatedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'message': message,
    'tone': tone,
    'generatedAt': generatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory DailyMessage.fromJson(Map<String, dynamic> json) => DailyMessage(
    message: json['message'] ?? '',
    tone: json['tone'] ?? 'warm',
    generatedAt: DateTime.parse(json['generatedAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

class DailyMessageProvider extends ChangeNotifier {
  DailyMessage? _message;
  bool _isLoading = false;

  DailyMessage? get message => _message;
  bool get isLoading => _isLoading;
  bool get hasMessage => _message != null && !_message!.isExpired;

  Future<void> loadMessage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 检查是否有缓存的寄语
      final jsonStr = prefs.getString('daily_message');
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        _message = DailyMessage.fromJson(json);
        if (!_message!.isExpired) {
          _isLoading = false;
          notifyListeners();
          return; // 缓存有效，直接返回
        }
        _message = null;
      }

      // 2. 尝试从 ObservationProvider 的快照生成寄语
      final obsRaw = prefs.getString('moon_latest_observation');
      if (obsRaw != null) {
        try {
          final obsJson = jsonDecode(obsRaw) as Map<String, dynamic>;
          final snapshot = ObservationSnapshot.fromJson(obsJson);

          String generatedMessage;
          if (snapshot.interests.isNotEmpty) {
            final topic = snapshot.interests[0].topic;
            final mood = snapshot.mood.mood;
            generatedMessage = _generateObservationMessage(topic, mood);
          } else {
            generatedMessage = _generateObservationMessage(null, snapshot.mood.mood);
          }

          final now = DateTime.now();
          _message = DailyMessage(
            message: generatedMessage,
            generatedAt: now,
            expiresAt: DateTime(now.year, now.month, now.day + 1),
          );

          await prefs.setString('daily_message', jsonEncode(_message!.toJson()));
          _isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('解析观察快照失败: $e');
        }
      }

      // 3. Fallback：从预设列表选一条
      await _fallbackGenerate(prefs);

    } catch (e) {
      debugPrint('加载今日寄语失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 根据话题和情绪生成寄语
  String _generateObservationMessage(String? topic, String mood) {
    // 有话题的组合模板
    if (topic != null && topic.isNotEmpty) {
      switch (mood) {
        case 'happy':
          return '今天 $topic 学得开心吗？继续加油～';
        case 'sad':
          return '最近看了好多 $topic 呢，有什么想聊的吗？';
        case 'neutral':
        default:
          final neutralTemplates = [
            '今天关于 $topic 有什么新想法吗？✨',
            '最近 $topic 怎么样？有什么想分享的吗？',
            '今天有关于 $topic 的新发现吗？🌟',
          ];
          return neutralTemplates[DateTime.now().hour % neutralTemplates.length];
      }
    }

    // 无话题，只根据情绪
    switch (mood) {
      case 'happy':
        final happyTemplates = [
          '今天心情不错呢，保持这份好心情哦 ☀️',
          '看起来今天很开心，有什么好事吗？✨',
        ];
        return happyTemplates[DateTime.now().hour % happyTemplates.length];
      case 'sad':
        final sadTemplates = [
          '今天似乎有点低落，需要我陪陪你吗？🌙',
          '累了就歇一歇，我一直在这里哦 🌙',
        ];
        return sadTemplates[DateTime.now().hour % sadTemplates.length];
      case 'neutral':
      default:
        return _defaultMessages[DateTime.now().hour % _defaultMessages.length];
    }
  }

  /// 预设默认寄语列表
  static const List<String> _defaultMessages = [
    '今天阳光很好，适合把想做的事列出来，一件一件慢慢来 ☀️',
    '无论今天过得怎样，记得给自己一个微笑 🌙',
    '每一小步都是进步，别忘了为自己的努力鼓掌 ✨',
    '生活就像一杯茶，慢慢品才有味道 🍵',
    '今天也要开开心心的呀 ☀️',
  ];

  /// Fallback：从预设列表选一条
  Future<void> _fallbackGenerate(SharedPreferences prefs) async {
    final now = DateTime.now();
    _message = DailyMessage(
      message: _defaultMessages[now.hour % _defaultMessages.length],
      generatedAt: now,
      expiresAt: DateTime(now.year, now.month, now.day + 1),
    );
    await prefs.setString('daily_message', jsonEncode(_message!.toJson()));
  }

  Future<void> generateMessage({
    required String emotionalState,
    required List<String> activeProjects,
  }) async {
    // TODO: 调用 AI 生成寄语，现在用默认文案
    final messages = [
      '今天阳光很好，适合把想做的事列出来，一件一件慢慢来 ☀️',
      '无论今天过得怎样，记得给自己一个微笑 🌙',
      '每一小步都是进步，别忘了为自己的努力鼓掌 ✨',
      '生活就像一杯茶，慢慢品才有味道 🍵',
      '今天也要开开心心的呀 ☀️',
    ];
    
    final now = DateTime.now();
    _message = DailyMessage(
      message: messages[now.hour % messages.length],
      generatedAt: now,
      expiresAt: DateTime(now.year, now.month, now.day + 1),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_message', jsonEncode(_message!.toJson()));
    notifyListeners();
  }
}
