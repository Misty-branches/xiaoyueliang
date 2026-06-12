import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedGoal {
  final String id;
  final String title;
  final int progress;
  final int total;
  final String status; // active, completed, paused
  final DateTime createdAt;
  final DateTime updatedAt;

  SharedGoal({
    required this.id,
    required this.title,
    this.progress = 0,
    required this.total,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent => total > 0 ? progress / total : 0;
  bool get isCompleted => progress >= total;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'progress': progress,
    'total': total,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SharedGoal.fromJson(Map<String, dynamic> json) => SharedGoal(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    progress: json['progress'] ?? 0,
    total: json['total'] ?? 1,
    status: json['status'] ?? 'active',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  SharedGoal copyWith({
    String? title,
    int? progress,
    int? total,
    String? status,
  }) => SharedGoal(
    id: id,
    title: title ?? this.title,
    progress: progress ?? this.progress,
    total: total ?? this.total,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}

class SharedGoalsProvider extends ChangeNotifier {
  List<SharedGoal> _goals = [];
  bool _isLoading = false;

  List<SharedGoal> get goals => _goals;
  List<SharedGoal> get activeGoals => _goals.where((g) => g.status == 'active').toList();
  bool get isLoading => _isLoading;
  bool get hasGoals => _goals.isNotEmpty;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('shared_goals');
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _goals = jsonList.map((j) => SharedGoal.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('加载共同目标失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(SharedGoal goal) async {
    _goals.add(goal);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateGoal(String id, {int? progress, String? status}) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        progress: progress,
        status: status,
      );
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> removeGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString('shared_goals', jsonStr);
  }
}
