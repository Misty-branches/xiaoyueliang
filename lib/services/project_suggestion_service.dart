import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';
import '../models/project_item.dart';

/// 项目建议服务
/// 基于观察结果，生成项目状态建议
class ProjectSuggestionService {
  /// 生成项目建议
  /// 读取观察结果中的 activeProjects + 兴趣话题
  /// 返回 List<Map>，每项含 { type, message, relatedTo }
  static Future<List<Map<String, dynamic>>> check() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. 读取 moon_latest_observation
      final raw = prefs.getString('moon_latest_observation');
      if (raw == null) {
        await prefs.setString('moon_project_suggestions', '[]');
        return [];
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final snapshot = ObservationSnapshot.fromJson(json);

      final List<Map<String, dynamic>> suggestions = [];
      final now = DateTime.now();

      // 2. 检查 activeProjects 中是否有项目长时间无更新
      for (final project in snapshot.activeProjects) {
        final daysSinceUpdate = now.difference(project.lastUpdate).inDays;
        if (daysSinceUpdate >= 7) {
          suggestions.add({
            'type': 'stale',
            'message': '项目「${project.name}」已 $daysSinceUpdate 天无更新，是否查看进度？',
            'relatedTo': project.name,
            'daysSinceUpdate': daysSinceUpdate,
          });
        }
      }

      // 同时检查 projects key 中的 ProjectItem 列表（完整的项目数据）
      try {
        final projectsData = prefs.getString('projects');
        if (projectsData != null) {
          final projectList = jsonDecode(projectsData) as List;
          for (final p in projectList) {
            final item = ProjectItem.fromJson(p);
            if (item.status == 'active') {
              final daysSinceUpdate = now.difference(item.updatedAt).inDays;
              if (daysSinceUpdate >= 7) {
                // 避免与 observation 中的 activeProjects 重复
                final isDuplicate = suggestions.any((s) =>
                    s['relatedTo'] == item.title && s['type'] == 'stale');
                if (!isDuplicate) {
                  suggestions.add({
                    'type': 'stale',
                    'message': '项目「${item.title}」已 $daysSinceUpdate 天无更新，是否查看进度？',
                    'relatedTo': item.title,
                    'daysSinceUpdate': daysSinceUpdate,
                  });
                }
              }
            }
          }
        }
      } catch (e) {
        // 忽略项目列表解析错误
      }

      // 3. 检查 interests：高频兴趣话题但没有对应项目 → 建议新建项目
      final existingProjectNames = <String>{
        ...snapshot.activeProjects.map((p) => p.name),
      };
      // 也包含 projects key 中的项目
      try {
        final projectsData = prefs.getString('projects');
        if (projectsData != null) {
          final projectList = jsonDecode(projectsData) as List;
          for (final p in projectList) {
            final item = ProjectItem.fromJson(p);
            existingProjectNames.add(item.title);
          }
        }
      } catch (_) {
        // 忽略
      }

      for (final interest in snapshot.interests) {
        // 只对高分兴趣话题（score >= 0.5）建议建项目
        if (interest.score < 0.5) continue;

        // 检查是否已有对应项目（书名匹配兴趣词）
        final hasProject = existingProjectNames.any((name) =>
            name.toLowerCase().contains(interest.topic.toLowerCase()));

        if (!hasProject) {
          suggestions.add({
            'type': 'new_project',
            'message': '最近对「${interest.topic}」很感兴趣，要不要建个项目？',
            'relatedTo': interest.topic,
            'score': interest.score,
          });
        }
      }

      // 4. 结果存入 SharedPreferences
      await prefs.setString(
          'moon_project_suggestions', jsonEncode(suggestions));

      return suggestions;
    } catch (e) {
      // 异常保护：返回空列表
      final emptyList = <Map<String, dynamic>>[];
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('moon_project_suggestions', '[]');
      } catch (_) {
        // 忽略存储异常
      }
      return emptyList;
    }
  }
}
