import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════
// 主题色系 — 完全对照 DESIGN.md 规范
// ═══════════════════════════════════════════════
// 日间：雾绿清透（纯白卡片 + 鼠尾草绿）
// 夜间：蓝灰清透（月光银蓝）
// 所有色值来自 ~/.hermes/projects/xiaoyueliang/DESIGN.md

// ───────────────────── 日间色板 ─────────────────────
const _dayBg            = Color(0xFFEEF3EC);  // bg
const _dayCard          = Color(0xFFFFFFFF);  // card — 纯白
const _dayBorder        = Color(0xFFDCE4DA);  // card-border
const _dayPrimary       = Color(0xFF7DBA98);  // primary — 鼠尾草绿
const _dayPrimaryLight  = Color(0xFFE2EDE6);  // primary-light
const _dayPrimaryDeep   = Color(0xFF5A9A78);  // primary-deep
const _dayText          = Color(0xFF2A3830);  // text — 暖深绿
const _dayTextSecondary = Color(0xFF648470);  // text-secondary
const _dayTextMuted     = Color(0xFF8EAA96);  // text-muted
const _daySelected      = Color(0xFFE8F0E6);  // selected-bg
const _dayWarmAccent    = Color(0xFFD4816A);  // warm-accent
const _dayTabBg         = Color(0xFFFFFFFF);  // tab-bg
const _dayTabBorder     = Color(0xFFDCE4DA);  // tab-border
const _dayBodyBg        = Color(0xFFE2EAE0);  // body-bg（手机外框背景）
const _dayGradientCenter = Color(0xD9FFFFFF); // gradient-center: rgba(255,255,255,0.85)

// ───────────────────── 夜间色板 ─────────────────────
const _nightBg            = Color(0xFFCCD8E6);  // night-bg
const _nightCard          = Color(0xFFE6ECF4);  // night-card
const _nightBorder        = Color(0xFFC2D0DE);  // night-card-border
const _nightPrimary       = Color(0xFF7A94B0);  // night-primary
const _nightPrimaryLight  = Color(0xFFCCD8E6);  // night-primary-light
const _nightPrimaryDeep   = Color(0xFF5A7088);  // night-primary-deep
const _nightText          = Color(0xFF1A2838);  // night-text
const _nightTextSecondary = Color(0xFF567088);  // night-text-secondary
const _nightTextMuted     = Color(0xFF869EB6);  // night-text-muted
const _nightSelected      = Color(0xFFCCD8E6);  // night-selected
const _nightWarmAccent    = Color(0xFFD4816A);  // 夜间暖色同日间
const _nightTabBg         = Color(0xFFE6ECF4);  // night-tab-bg
const _nightTabBorder     = Color(0xFFC2D0DE);  // night-tab-border
const _nightBodyBg        = Color(0xFFBECEDE);  // night-body-bg

/// 主题色系扩展
class AppColors extends ThemeExtension<AppColors> {
  final Color background;      // 页面背景
  final Color cardSurface;     // 卡片背景（纯白）
  final Color cardBase;        // 卡片次级底色（输入框、筛选按钮、气泡底）
  final Color accent;          // 主色（按钮、图标、标签）
  final Color accentLight;     // 主色浅底（头像背景）
  final Color accentDeep;      // 主色深（按下态）
  final Color accentWarm;      // 暖色强调（目标渐变、日记）
  final Color tag;             // 标签色（同主色，用于标签背景和文字）
  final Color mainText;        // 主文字
  final Color secondaryText;   // 副文字
  final Color mutedText;       // 弱文字（标签、注释）
  final Color border;          // 边框
  final Color shadow;          // 阴影色
  final Color selectedBg;      // 选中背景
  final Color tabBg;           // 底部导航栏背景
  final Color tabBorder;       // 底部导航栏边框
  final Color bodyBg;          // 手机外框背景
  final Color gradientCenter;  // 径向渐变中心色

  const AppColors({
    required this.background,
    required this.cardSurface,
    required this.cardBase,
    required this.accent,
    required this.accentLight,
    required this.accentDeep,
    required this.accentWarm,
    required this.tag,
    required this.mainText,
    required this.secondaryText,
    required this.mutedText,
    required this.border,
    required this.shadow,
    required this.selectedBg,
    required this.tabBg,
    required this.tabBorder,
    required this.bodyBg,
    required this.gradientCenter,
  });

  // ───────────────────── 色板实例 ─────────────────────
  static const day = AppColors(
    background:      _dayBg,
    cardSurface:     _dayCard,
    cardBase:        _dayPrimaryLight, // #E2EDE6 — 输入框/筛选按钮底色
    accent:          _dayPrimary,
    accentLight:     _dayPrimaryLight,
    accentDeep:      _dayPrimaryDeep,
    accentWarm:      _dayWarmAccent,
    tag:             _dayPrimary,      // 标签色 = 主色 #7DBA98
    mainText:        _dayText,
    secondaryText:   _dayTextSecondary,
    mutedText:       _dayTextMuted,
    border:          _dayBorder,
    shadow:          Color(0x0A000000),
    selectedBg:      _daySelected,
    tabBg:           _dayTabBg,
    tabBorder:       _dayTabBorder,
    bodyBg:          _dayBodyBg,
    gradientCenter:  _dayGradientCenter,
  );

  static const night = AppColors(
    background:      _nightBg,
    cardSurface:     _nightCard,
    cardBase:        Color(0xFFD6DEE8), // 夜间卡片次级底色
    accent:          _nightPrimary,
    accentLight:     _nightPrimaryLight,
    accentDeep:      _nightPrimaryDeep,
    accentWarm:      _nightWarmAccent,
    tag:             _nightPrimary,     // 标签色 = 夜间主色 #7A94B0
    mainText:        _nightText,
    secondaryText:   _nightTextSecondary,
    mutedText:       _nightTextMuted,
    border:          _nightBorder,
    shadow:          Color(0x0A000000),
    selectedBg:      _nightSelected,
    tabBg:           _nightTabBg,
    tabBorder:       _nightTabBorder,
    bodyBg:          _nightBodyBg,
    gradientCenter:  Color(0xD9E6ECF4),
  );

  // ───────────────────── ThemeExtension 实现 ─────────────────────
  @override
  AppColors copyWith({
    Color? background,
    Color? cardSurface,
    Color? cardBase,
    Color? accent,
    Color? accentLight,
    Color? accentDeep,
    Color? accentWarm,
    Color? tag,
    Color? mainText,
    Color? secondaryText,
    Color? mutedText,
    Color? border,
    Color? shadow,
    Color? selectedBg,
    Color? tabBg,
    Color? tabBorder,
    Color? bodyBg,
    Color? gradientCenter,
  }) {
    return AppColors(
      background:      background      ?? this.background,
      cardSurface:     cardSurface     ?? this.cardSurface,
      cardBase:        cardBase        ?? this.cardBase,
      accent:          accent          ?? this.accent,
      accentLight:     accentLight     ?? this.accentLight,
      accentDeep:      accentDeep      ?? this.accentDeep,
      accentWarm:      accentWarm      ?? this.accentWarm,
      tag:             tag             ?? this.tag,
      mainText:        mainText        ?? this.mainText,
      secondaryText:   secondaryText   ?? this.secondaryText,
      mutedText:       mutedText       ?? this.mutedText,
      border:          border          ?? this.border,
      shadow:          shadow          ?? this.shadow,
      selectedBg:      selectedBg      ?? this.selectedBg,
      tabBg:           tabBg           ?? this.tabBg,
      tabBorder:       tabBorder       ?? this.tabBorder,
      bodyBg:          bodyBg          ?? this.bodyBg,
      gradientCenter:  gradientCenter  ?? this.gradientCenter,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background:      Color.lerp(background,      other.background,      t)!,
      cardSurface:     Color.lerp(cardSurface,     other.cardSurface,     t)!,
      cardBase:        Color.lerp(cardBase,        other.cardBase,        t)!,
      accent:          Color.lerp(accent,          other.accent,          t)!,
      accentLight:     Color.lerp(accentLight,     other.accentLight,     t)!,
      accentDeep:      Color.lerp(accentDeep,      other.accentDeep,      t)!,
      accentWarm:      Color.lerp(accentWarm,      other.accentWarm,      t)!,
      tag:             Color.lerp(tag,             other.tag,             t)!,
      mainText:        Color.lerp(mainText,        other.mainText,        t)!,
      secondaryText:   Color.lerp(secondaryText,   other.secondaryText,   t)!,
      mutedText:       Color.lerp(mutedText,       other.mutedText,       t)!,
      border:          Color.lerp(border,          other.border,          t)!,
      shadow:          Color.lerp(shadow,          other.shadow,          t)!,
      selectedBg:      Color.lerp(selectedBg,      other.selectedBg,      t)!,
      tabBg:           Color.lerp(tabBg,           other.tabBg,           t)!,
      tabBorder:       Color.lerp(tabBorder,       other.tabBorder,       t)!,
      bodyBg:          Color.lerp(bodyBg,          other.bodyBg,          t)!,
      gradientCenter:  Color.lerp(gradientCenter,  other.gradientCenter,  t)!,
    );
  }
}
