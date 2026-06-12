import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      final jsonStr = prefs.getString('daily_message');
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        _message = DailyMessage.fromJson(json);
        if (_message!.isExpired) {
          _message = null;
        }
      }
    } catch (e) {
      debugPrint('加载今日寄语失败: $e');
    }

    _isLoading = false;
    notifyListeners();
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
