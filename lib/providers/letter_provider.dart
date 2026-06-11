import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/letter_item.dart';

class LetterProvider extends ChangeNotifier {
  List<LetterItem> _letters = [];
  List<LetterItem> get letters => _letters;

  int get unreadCount => _letters.where((l) => !l.isRead).length;

  Future<void> loadLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('letters');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _letters = list.map((e) => LetterItem.fromJson(e)).toList();
      _letters.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> saveLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_letters.map((e) => e.toJson()).toList());
    await prefs.setString('letters', data);
  }

  Future<String> addLetter(LetterItem letter) async {
    _letters.insert(0, letter);
    _letters.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await saveLetters();
    notifyListeners();
    return letter.id;
  }

  Future<void> markAsRead(String id) async {
    final index = _letters.indexWhere((l) => l.id == id);
    if (index != -1) {
      final updated = LetterItem(
        id: _letters[index].id,
        title: _letters[index].title,
        content: _letters[index].content,
        type: _letters[index].type,
        isRead: true,
        createdAt: _letters[index].createdAt,
      );
      _letters[index] = updated;
      await saveLetters();
      notifyListeners();
    }
  }

  Future<void> deleteLetter(String id) async {
    _letters.removeWhere((l) => l.id == id);
    await saveLetters();
    notifyListeners();
  }
}
