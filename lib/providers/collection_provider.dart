import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/collect_item.dart';

class CollectionProvider extends ChangeNotifier {
  List<CollectItem> _items = [];
  List<CollectItem> get items => _items;

  int get itemCount => _items.length;

  List<CollectItem> getBySource(String sourceType) =>
      _items.where((i) => i.sourceType == sourceType).toList();

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('collections');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _items = list.map((e) => CollectItem.fromJson(e)).toList();
      _items.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
      notifyListeners();
    }
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('collections', data);
  }

  Future<void> addItem(CollectItem item) async {
    _items.insert(0, item);
    _items.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    await saveItems();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await saveItems();
    notifyListeners();
  }

  bool isCollected(String sourceId) =>
      _items.any((i) => i.sourceId == sourceId);
}
