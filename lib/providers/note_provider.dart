import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note_item.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteItem> _notes = [];
  List<NoteItem> get notes => _notes;
  int get noteCount => _notes.length;

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _notes = list.map((e) => NoteItem.fromJson(e)).toList();
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_notes.map((e) => e.toJson()).toList());
    await prefs.setString('notes', data);
  }

  Future<void> addOrUpdateNote(NoteItem note) async {
    final existingIdx = _notes.indexWhere((n) => n.id == note.id);
    if (existingIdx != -1) {
      _notes[existingIdx] = note;
    } else {
      _notes.insert(0, note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await saveNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await saveNotes();
    notifyListeners();
  }
}
