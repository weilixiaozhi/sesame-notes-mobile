import 'package:flutter/material.dart';

import 'colors.dart';
import 'app_visual_theme.dart';

/// 文本样式令牌：全局统一字号与字重
class AppTextTokens {
  /// 选择标签只覆盖排版，选中及禁用前景色由原生控件主题解析。
  static TextStyle chipLabel(BuildContext ctx, {bool compact = false}) {
    final base = compact ? caption(ctx) : label(ctx);
    return TextStyle(
      fontSize: base.fontSize,
      fontWeight: base.fontWeight,
      fontFamily: base.fontFamily,
      fontFamilyFallback: base.fontFamilyFallback,
      fontFeatures: base.fontFeatures,
      height: base.height,
      letterSpacing: base.letterSpacing,
    );
  }

  /// 金额编辑域保留原字号和皮肤字重，字体家族始终使用可读的无衬线正文。
  static TextStyle amountInput(BuildContext ctx, {TextStyle? textStyle}) {
    final bodyStyle = input(ctx);
    return (textStyle ?? display3(ctx)).copyWith(
      fontFamily: bodyStyle.fontFamily,
      fontFamilyFallback: bodyStyle.fontFamilyFallback,
    );
  }

  /// 业务页大标题保持清晰层级，沿用用户配置的字体。
  static TextStyle domainTitle(BuildContext ctx) => AppTypography.displayStyle(
    display2(ctx),
    AppVisualTheme.of(ctx),
    large: false,
    serif: true,
  );

  /// 倒数数字使用大字号和常规字重，保持日期卡片的视觉重心。
  static TextStyle heroNumber(BuildContext ctx) => AppTypography.displayStyle(
    input(ctx),
    AppVisualTheme.of(ctx),
    serif: true,
  ).copyWith(fontSize: 48, height: 1.15);

  /// 记账主金额保留金额和货币符号的首屏空间。
  static TextStyle moneyHero(BuildContext ctx) => AppTypography.displayStyle(
    input(ctx),
    AppVisualTheme.of(ctx),
    serif: true,
  ).copyWith(fontSize: 36, height: 1.15);

  /// 主金额的小数与整数共享风格，保留更轻的视觉层级。
  static TextStyle moneyHeroFraction(BuildContext ctx) =>
      moneyHero(ctx).copyWith(fontSize: 24);

  /// 货币符号使用无衬线正文，避免符号在系统衬线回退时变化。
  static TextStyle moneyHeroCurrency(BuildContext ctx) =>
      AppTypography.displayStyle(
        input(ctx),
        AppVisualTheme.of(ctx),
      ).copyWith(fontSize: 16, height: 1.15);

  /// 装饰性眉题与可操作的中文标题分层显示。
  static TextStyle domainEyebrow(BuildContext ctx) =>
      caption(ctx).copyWith(fontSize: 9, letterSpacing: 1.2);

  /// 分类排行用正文区分父子层级，子分类保留较紧凑字号。
  static TextStyle categoryRank(BuildContext ctx, {required bool topLevel}) =>
      body(ctx).copyWith(fontSize: topLevel ? 12 : 11);

  /// 普通输入与日期字段沿用 Material 输入的正文令牌，提示只改变前景色。
  static TextStyle input(BuildContext ctx) => Theme.of(
    ctx,
  ).textTheme.bodyLarge!.copyWith(color: AppTokens.textPrimary(ctx));

  /// 列表、历史和选择页的辅助日期时间，以及各业务域的列表分组标题，
  /// 统一为 11 号常规字重与次要色。
  static TextStyle dateSecondary(BuildContext ctx) =>
      body(ctx).copyWith(fontSize: 11, color: AppTokens.textSecondary(ctx));

  /// 日历与健身计划中需要突出的日期行：正文大小的半粗体。
  static TextStyle dateHeading(BuildContext ctx) =>
      body(ctx).copyWith(fontWeight: FontWeight.w600);

  /// 连续阅读和编辑的正文留出舒展行高。
  static TextStyle documentBody(BuildContext ctx) =>
      input(ctx).copyWith(height: 1.8);

  /// 底部导航文字：固定行高与字距，选中项通过字重和前景色区分。
  static TextStyle bottomNavigation(
    BuildContext ctx, {
    required bool selected,
  }) => title(ctx).copyWith(
    fontSize: 16,
    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    height: 1.25,
    letterSpacing: 1,
    color: AppTokens.tabBarForeground(ctx, selected: selected),
  );

  // 列表标题与大额数字保留已有角色，只在这里定义相对正文的差异。
  static TextStyle title(BuildContext ctx) => input(ctx).copyWith(fontSize: 14);
  static TextStyle strongTitle(BuildContext ctx) => AppTypography.displayStyle(
    title(ctx),
    AppVisualTheme.of(ctx),
    large: false,
  );
  static TextStyle boldTitle(BuildContext ctx) => AppTypography.displayStyle(
    input(ctx),
    AppVisualTheme.of(ctx),
  ).copyWith(fontSize: Theme.of(ctx).textTheme.titleLarge!.fontSize);
  static TextStyle body(BuildContext ctx) => Theme.of(
    ctx,
  ).textTheme.bodyMedium!.copyWith(color: AppTokens.textPrimary(ctx));
  static TextStyle label(BuildContext ctx) => Theme.of(
    ctx,
  ).textTheme.labelMedium!.copyWith(color: AppTokens.textSecondary(ctx));
  static TextStyle caption(BuildContext ctx) => Theme.of(
    ctx,
  ).textTheme.labelSmall!.copyWith(color: AppTokens.textSecondary(ctx));
  static TextStyle display1(BuildContext ctx) =>
      boldTitle(ctx).copyWith(fontSize: 20);
  static TextStyle display2(BuildContext ctx) =>
      boldTitle(ctx).copyWith(fontSize: 22);
  static TextStyle display3(BuildContext ctx) =>
      boldTitle(ctx).copyWith(fontSize: 28);
}

// ============================================================================
// 字体令牌 (Typography Tokens)
// ============================================================================

/// 字体配置令牌
class AppTypography {
  // iOS 系统中文字体。
  static const String systemCJKiOS = 'PingFang SC';

  /// 只有标题和主数字使用皮肤字重；手账字体缺失时由系统候选逐级回退。
  static TextStyle displayStyle(
    TextStyle base,
    AppVisualTheme visual, {
    bool large = true,
    bool serif = false,
  }) => base.copyWith(
    fontWeight: large ? visual.largeFontWeight : visual.titleFontWeight,
    fontVariations: [
      FontVariation('wght', large ? visual.largeWeight : visual.titleWeight),
    ],
    fontFamily: visual.displaySerif && serif ? 'Georgia' : base.fontFamily,
    fontFamilyFallback: visual.displaySerif && serif
        ? const [
            'Palatino',
            'Times New Roman',
            'Noto Serif CJK SC',
            'Noto Serif',
            'Songti SC',
            'STSong',
            'SimSun',
            'serif',
          ]
        : base.fontFamilyFallback,
  );

  /// 正文、输入、键盘和按钮标签保持系统无衬线字体。
  static TextTheme buildBase(
    TextTheme base, {
    required bool isIOS,
    required AppVisualTheme visual,
  }) {
    final bodyW = FontWeight.w400;
    final titleW = FontWeight.w600;
    final latin = isIOS ? 'Helvetica Neue' : 'Roboto';
    final cjk = isIOS ? systemCJKiOS : 'NotoSans';
    final familyFallback = <String>{
      latin,
      cjk,
      'PingFang SC',
      'Helvetica Neue',
      'Roboto',
      'Arial',
    };

    TextStyle merge(
      TextStyle? src,
      double size,
      FontWeight w, {
      double? height,
    }) {
      return (src ?? const TextStyle()).copyWith(
        // 统一各文字角色的字距，数字等宽以便金额、组数和计时上下对齐。
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontSize: size,
        fontWeight: w,
        height: height ?? 1.25,
        fontFamily: latin,
        fontFamilyFallback: familyFallback.toList(),
      );
    }

    final result = base.copyWith(
      bodySmall: merge(base.bodySmall, 11, bodyW),
      bodyMedium: merge(base.bodyMedium, 12, bodyW),
      bodyLarge: merge(base.bodyLarge, 12, bodyW, height: 1.28),
      labelSmall: merge(base.labelSmall, 10, bodyW),
      labelMedium: merge(base.labelMedium, 11, FontWeight.w500),
      labelLarge: merge(base.labelLarge, 12, FontWeight.w600),
      titleSmall: merge(base.titleSmall, 12, FontWeight.w500),
      titleMedium: merge(base.titleMedium, 13, FontWeight.w500),
      titleLarge: merge(base.titleLarge, 16, titleW, height: 1.3),
      headlineSmall: merge(base.headlineSmall, 18, titleW, height: 1.3),
    );
    return result.copyWith(
      titleSmall: displayStyle(result.titleSmall!, visual, large: false),
      titleMedium: displayStyle(result.titleMedium!, visual, large: false),
      titleLarge: displayStyle(result.titleLarge!, visual, large: false),
      headlineSmall: displayStyle(result.headlineSmall!, visual, large: false),
    );
  }
}
