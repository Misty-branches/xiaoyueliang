import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';

class DiaryProvider extends ChangeNotifier {
  List<DiaryEntry> _entries = [];
  List<DiaryEntry> get entries => _entries;

  DiaryEntry? get latestEntry => _entries.isEmpty ? null : _entries.first;
  int get entryCount => _entries.length;

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('diary_entries');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _entries = list.map((e) => DiaryEntry.fromJson(e)).toList();
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('diary_entries', data);
  }

  Future<void> addOrUpdateEntry(DiaryEntry entry) async {
    final existingIdx = _entries.indexWhere((e) => e.id == entry.id);
    if (existingIdx != -1) {
      _entries[existingIdx] = entry;
    } else {
      _entries.insert(0, entry);
    }
    _entries.sort((a, b) => b.date.compareTo(a.date));
    await saveEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await saveEntries();
    notifyListeners();
  }
}
