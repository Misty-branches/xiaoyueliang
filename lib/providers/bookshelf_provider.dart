import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/book_item.dart';

class BookshelfProvider extends ChangeNotifier {
  List<BookItem> _books = [];
  List<BookItem> get books => _books;

  int get bookCount => _books.length;

  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('books');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _books = list.map((e) => BookItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_books.map((b) => b.toJson()).toList());
    await prefs.setString('books', data);
  }

  Future<void> addBook(BookItem item) async {
    _books.add(item);
    await saveBooks();
    notifyListeners();
  }

  Future<void> updateProgress(String id, int total, int current) async {
    final idx = _books.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _books[idx].totalPages = total;
      _books[idx].currentPages = current;
      await saveBooks();
      notifyListeners();
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    await saveBooks();
    notifyListeners();
  }
}
