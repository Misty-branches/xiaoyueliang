import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color cardSurface;
  final Color cardBase;
  final Color mainText;
  final Color secondaryText;
  final Color accent;
  final Color accentWarm;
  final Color tag;
  final Color border;

  const AppColors({
    required this.background,
    required this.cardSurface,
    required this.cardBase,
    required this.mainText,
    required this.secondaryText,
    required this.accent,
    required this.accentWarm,
    required this.tag,
    required this.border,
  });

  static const AppColors light = AppColors(
    background: Color(0xFFF2F0EB),
    cardSurface: Color(0xFFFFFFFF),
    cardBase: Color(0xFFEDE9E1),
    mainText: Color(0xFF1A1A2E),
    secondaryText: Color(0xFF8A9BB0),
    accent: Color(0xFF7BA8D0),
    accentWarm: Color(0xFFC9A96E),
    tag: Color(0xFFD4A96E),
    border: Color(0xFFD8D4CC),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF162B42),
    cardSurface: Color(0xFF1E3550),
    cardBase: Color(0xFF26405A),
    mainText: Color(0xFFF0F4F8),
    secondaryText: Color(0xFFA0B8CC),
    accent: Color(0xFF7BA8D0),
    accentWarm: Color(0xFFF5D88A),
    tag: Color(0xFFF0D8A8),
    border: Color(0xFF2E4A68),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? cardSurface,
    Color? cardBase,
    Color? mainText,
    Color? secondaryText,
    Color? accent,
    Color? accentWarm,
    Color? tag,
    Color? border,
  }) {
    return AppColors(
      background: background ?? this.background,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBase: cardBase ?? this.cardBase,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      accent: accent ?? this.accent,
      accentWarm: accentWarm ?? this.accentWarm,
      tag: tag ?? this.tag,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBase: Color.lerp(cardBase, other.cardBase, t)!,
      mainText: Color.lerp(mainText, other.mainText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      tag: Color.lerp(tag, other.tag, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
