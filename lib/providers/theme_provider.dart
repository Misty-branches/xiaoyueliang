import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  AppColors get colors => _isDark ? AppColors.dark : AppColors.light;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('theme_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_mode', _isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark != value) {
      _isDark = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_mode', value);
      notifyListeners();
    }
  }
}
