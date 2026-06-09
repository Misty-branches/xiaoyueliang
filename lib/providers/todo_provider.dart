import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoItem> _todos = [];
  List<TodoItem> get todos => _todos;

  int get incompleteCount => _todos.where((t) => !t.isCompleted).length;
  List<TodoItem> get incompleteTodos => _todos.where((t) => !t.isCompleted).toList();
  List<TodoItem> get completedTodos => _todos.where((t) => t.isCompleted).toList();

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _todos = list.map((e) => TodoItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString('todos', data);
  }

  Future<void> addTodo(TodoItem item) async {
    _todos.insert(0, item);
    await saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _todos[idx].isCompleted = !_todos[idx].isCompleted;
      await saveTodos();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await saveTodos();
    notifyListeners();
  }
}
