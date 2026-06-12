import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityItem {
  final String id;
  final String text;
  final String type; // realtime, scheduled
  final String trigger; // chat, letter, note, daily
  final DateTime timestamp;

  ActivityItem({
    required this.id,
    required this.text,
    required this.type,
    required this.trigger,
    required this.timestamp,
  });

  String get timeStr {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 2) return '昨天';
    return '${diff.inDays}天前';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type,
    'trigger': trigger,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    type: json['type'] ?? 'realtime',
    trigger: json['trigger'] ?? '',
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class RecentActivityProvider extends ChangeNotifier {
  List<ActivityItem> _activities = [];
  bool _isLoading = false;

  List<ActivityItem> get activities => _activities;
  List<ActivityItem> get recentActivities => _activities.take(4).toList();
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('recent_activities');
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _activities = jsonList.map((j) => ActivityItem.fromJson(j)).toList();
        _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('加载最近活动失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addActivity({
    required String text,
    required String type,
    required String trigger,
  }) async {
    final activity = ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      type: type,
      trigger: trigger,
      timestamp: DateTime.now(),
    );

    _activities.insert(0, activity);
    
    // 只保留最近20条
    if (_activities.length > 20) {
      _activities = _activities.take(20).toList();
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> addRealtimeActivity({
    required String text,
    required String trigger,
  }) async {
    await addActivity(
      text: text,
      type: 'realtime',
      trigger: trigger,
    );
  }

  Future<void> addScheduledActivity({
    required String text,
    required String trigger,
  }) async {
    await addActivity(
      text: text,
      type: 'scheduled',
      trigger: trigger,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString('recent_activities', jsonStr);
  }
}
