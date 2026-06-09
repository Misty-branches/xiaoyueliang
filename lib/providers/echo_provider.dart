import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/echo_entry.dart';

class EchoProvider extends ChangeNotifier {
  List<EchoEntry> _entries = [];
  List<EchoEntry> get entries => _entries;

  int get entryCount => _entries.length;

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('echo_entries');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _entries = list.map((e) => EchoEntry.fromJson(e)).toList();
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('echo_entries', data);
  }

  Future<void> addEntry(EchoEntry entry) async {
    _entries.insert(0, entry);
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
