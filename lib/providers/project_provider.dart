import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/project_item.dart';

class ProjectProvider extends ChangeNotifier {
  List<ProjectItem> _projects = [];
  List<ProjectItem> get projects => _projects;
  List<ProjectItem> get activeProjects =>
      _projects.where((p) => p.status == 'active').toList();
  int get projectCount => _projects.length;

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('projects');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _projects = list.map((e) => ProjectItem.fromJson(e)).toList();
      _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    }
  }

  Future<void> saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_projects.map((e) => e.toJson()).toList());
    await prefs.setString('projects', data);
  }

  Future<String> addProject(ProjectItem project) async {
    _projects.insert(0, project);
    _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await saveProjects();
    notifyListeners();
    return project.id;
  }

  Future<void> updateProject(ProjectItem project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await saveProjects();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await saveProjects();
    notifyListeners();
  }
}
