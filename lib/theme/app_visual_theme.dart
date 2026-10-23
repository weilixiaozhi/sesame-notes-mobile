import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dimens.dart';

part 'app_theme_presets.dart';

/// 视觉皮肤独立于系统、浅色和深色显示模式。
enum AppThemePreset {
  classic,
  minimal,
  journal;

  /// 无法识别的持久化值使用经典蓝，不改动显示模式偏好。
  static AppThemePreset parse(String? value) =>
      values.where((preset) => preset.name == value).firstOrNull ?? classic;
}

/// 所有皮肤都提供相同的语义色，界面不依赖具体颜色常量。
enum AppThemeColor {
  page,
  surface,
  soft,
  text,
  muted,
  line,
  brand,
  brandStrong,
  brandSoft,
  action,
  onAction,
  danger,
  dangerSoft,
  success,
  raised,
  navSurface,
  navActive,
  navInactive,
  focus,
  iconBg,
  iconFg,
  overlay,
  toast,
  onToast,
  pieOther,
  dayBg,
  dayText,
  dayMuted,
  dayLine,
  peachBg,
  peachFg,
  sageBg,
  sageFg,
  purpleBg,
  purpleFg,
  trainingBg,
  trainingText,
  trainingMuted,
  trainingAction,
  trainingOnAction,
  cardBorder,
}

/// 圆角属于视觉皮肤，触控尺寸和布局间距仍由 AppDimens 管理。
enum AppThemeRadius { card, hero, button, input, sheet, entrySheet, key }

/// 将完整皮肤挂在 ThemeData 上，主题动画只插值外观并保留原组件状态。
@immutable
class AppVisualTheme extends ThemeExtension<AppVisualTheme> {
  /// 每套皮肤必须提供完整颜色、几何与阴影，避免业务页面额外分支。
  const AppVisualTheme({
    required this.preset,
    required this.brightness,
    required this.colors,
    required this.radii,
    required this.largeWeight,
    required this.titleWeight,
    required this.displaySerif,
    required this.cardShadows,
    required this.fabShadows,
    required this.sheetShadows,
    required this.textureOpacity,
    required this.listGroupsUseCards,
    required this.listGroupHeadingGap,
  });

  final AppThemePreset preset;
  final Brightness brightness;
  final Map<AppThemeColor, Color> colors;
  final Map<AppThemeRadius, double> radii;
  final double largeWeight;
  final double titleWeight;
  final bool displaySerif;
  final List<BoxShadow> cardShadows;
  final List<BoxShadow> fabShadows;
  final List<BoxShadow> sheetShadows;
  final double textureOpacity;

  /// 分组列表是否使用卡片表面，业务页只消费视觉角色。
  final bool listGroupsUseCards;

  /// 分组标题到列表的间距，与卡片表面的视觉层次配套。
  final double listGroupHeadingGap;

  /// 按风格和亮暗直接读取不可变令牌，不访问持久化或路由状态。
  static AppVisualTheme resolve(AppThemePreset preset, Brightness brightness) =>
      _themePresets[(preset, brightness)]!;

  /// 测试或未装配扩展的独立 MaterialApp 使用同亮暗的经典皮肤。
  static AppVisualTheme of(BuildContext context) =>
      Theme.of(context).extension<AppVisualTheme>() ??
      resolve(AppThemePreset.classic, Theme.of(context).brightness);

  /// 查找语义色，完整性由主题注册表测试保障。
  Color color(AppThemeColor role) => colors[role]!;

  /// 查找视觉圆角，结构尺度不经过此入口。
  double radius(AppThemeRadius role) => radii[role]!;

  /// 非可变字体取最接近的系统字重，可变字体同时使用准确的 wght 值。
  FontWeight get titleFontWeight =>
      FontWeight.values[(titleWeight / 100).round().clamp(1, 9) - 1];

  /// 主数字使用独立字重，避免影响正文和键盘数字。
  FontWeight get largeFontWeight =>
      FontWeight.values[(largeWeight / 100).round().clamp(1, 9) - 1];

  /// 复制主题时保留未指定角色，供局部预览与主题动画使用。
  @override
  AppVisualTheme copyWith({
    AppThemePreset? preset,
    Brightness? brightness,
    Map<AppThemeColor, Color>? colors,
    Map<AppThemeRadius, double>? radii,
    double? largeWeight,
    double? titleWeight,
    bool? displaySerif,
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? fabShadows,
    List<BoxShadow>? sheetShadows,
    double? textureOpacity,
    bool? listGroupsUseCards,
    double? listGroupHeadingGap,
  }) => AppVisualTheme(
    preset: preset ?? this.preset,
    brightness: brightness ?? this.brightness,
    colors: colors ?? this.colors,
    radii: radii ?? this.radii,
    largeWeight: largeWeight ?? this.largeWeight,
    titleWeight: titleWeight ?? this.titleWeight,
    displaySerif: displaySerif ?? this.displaySerif,
    cardShadows: cardShadows ?? this.cardShadows,
    fabShadows: fabShadows ?? this.fabShadows,
    sheetShadows: sheetShadows ?? this.sheetShadows,
    textureOpacity: textureOpacity ?? this.textureOpacity,
    listGroupsUseCards: listGroupsUseCards ?? this.listGroupsUseCards,
    listGroupHeadingGap: listGroupHeadingGap ?? this.listGroupHeadingGap,
  );

  /// 颜色、圆角和阴影平滑变化，字体家族在动画中点切换。
  @override
  AppVisualTheme lerp(covariant AppVisualTheme? other, double t) {
    if (other == null) return this;
    return AppVisualTheme(
      preset: t < 0.5 ? preset : other.preset,
      brightness: t < 0.5 ? brightness : other.brightness,
      colors: {
        for (final role in AppThemeColor.values)
          role: Color.lerp(color(role), other.color(role), t)!,
      },
      radii: {
        for (final role in AppThemeRadius.values)
          role: lerpDouble(radius(role), other.radius(role), t)!,
      },
      largeWeight: lerpDouble(largeWeight, other.largeWeight, t)!,
      titleWeight: lerpDouble(titleWeight, other.titleWeight, t)!,
      displaySerif: t < 0.5 ? displaySerif : other.displaySerif,
      cardShadows: BoxShadow.lerpList(cardShadows, other.cardShadows, t)!,
      fabShadows: BoxShadow.lerpList(fabShadows, other.fabShadows, t)!,
      sheetShadows: BoxShadow.lerpList(sheetShadows, other.sheetShadows, t)!,
      textureOpacity: lerpDouble(textureOpacity, other.textureOpacity, t)!,
      listGroupsUseCards: t < 0.5
          ? listGroupsUseCards
          : other.listGroupsUseCards,
      listGroupHeadingGap: lerpDouble(
        listGroupHeadingGap,
        other.listGroupHeadingGap,
        t,
      )!,
    );
  }
}
