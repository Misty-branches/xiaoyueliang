import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color cardSurface;
  final Color cardBase;
  final Color mainText;
  final Color secondaryText;
  final Color mutedText;
  final Color accent;
  final Color accentLight;
  final Color accentDeep;
  final Color accentWarm;
  final Color tag;
  final Color border;
  final Color shadow;

  const AppColors({
    required this.background,
    required this.cardSurface,
    required this.cardBase,
    required this.mainText,
    required this.secondaryText,
    required this.mutedText,
    required this.accent,
    required this.accentLight,
    required this.accentDeep,
    required this.accentWarm,
    required this.tag,
    required this.border,
    required this.shadow,
  });

  // 日间主题 — 绿色/薄荷色系，清新养眼
  static const AppColors light = AppColors(
    background: Color(0xFFEEF3EC),
    cardSurface: Color(0xFFFFFFFF),
    cardBase: Color(0xFFE2EDE6),
    mainText: Color(0xFF2A3830),
    secondaryText: Color(0xFF648470),
    mutedText: Color(0xFF8EAA96),
    accent: Color(0xFF7DBA98),
    accentLight: Color(0xFFE2EDE6),
    accentDeep: Color(0xFF5A9A78),
    accentWarm: Color(0xFFD4816A),
    tag: Color(0xFF7DBA98),
    border: Color(0xFFDCE4DA),
    shadow: Color(0x0A000000),
  );

  // 夜间主题 — 蓝灰色系
  static const AppColors dark = AppColors(
    background: Color(0xFFCCD8E6),
    cardSurface: Color(0xFFE6ECF4),
    cardBase: Color(0xFFD6DEE8),
    mainText: Color(0xFF1A2838),
    secondaryText: Color(0xFF567088),
    mutedText: Color(0xFF869EB6),
    accent: Color(0xFF7A94B0),
    accentLight: Color(0xFFCCD8E6),
    accentDeep: Color(0xFF5A7088),
    accentWarm: Color(0xFFE8A87C),
    tag: Color(0xFF7A94B0),
    border: Color(0xFFC2D0DE),
    shadow: Color(0x0A000000),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? cardSurface,
    Color? cardBase,
    Color? mainText,
    Color? secondaryText,
    Color? mutedText,
    Color? accent,
    Color? accentLight,
    Color? accentDeep,
    Color? accentWarm,
    Color? tag,
    Color? border,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBase: cardBase ?? this.cardBase,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDeep: accentDeep ?? this.accentDeep,
      accentWarm: accentWarm ?? this.accentWarm,
      tag: tag ?? this.tag,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
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
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      tag: Color.lerp(tag, other.tag, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
