import 'package:flutter/material.dart';
import 'colors.dart';
import 'app_visual_theme.dart';

/// 图表令牌：统一统计色阶与图表视觉参数
class AppChartTokens {
  /// 分类色阶采用当前皮肤的主色与页背景混合，深色主题保留更明显的层次。
  static List<Color> categoryPalette(BuildContext context) {
    final visual = AppTokens.visual(context);
    final weights = visual.preset == AppThemePreset.classic
        ? const [1.0, 0.75, 0.52, 0.28, 0.15]
        : visual.brightness == Brightness.dark
        ? const [1.0, 0.82, 0.68, 0.52, 0.38]
        : const [1.0, 0.76, 0.57, 0.41, 0.27];
    return [
      for (final weight in weights)
        Color.lerp(
          AppTokens.scaffoldBackground(context),
          AppTokens.primary(context),
          weight,
        )!,
    ];
  }

  // 填充色仅表达当前周期内相对训练量，选中不改变色阶。
  static const double bodySelectionScale = 1.04;
  static Color bodyVolumeColor(
    double volume,
    double maximum,
    Color neutral,
    Color primary,
  ) => volume <= 0 || maximum <= 0
      ? neutral
      : primary.withValues(alpha: (volume / maximum).clamp(0, 1));
  static Color bodyNeutral(BuildContext context) => AppTokens.isDark(context)
      ? const Color(0xFF485569)
      : const Color(0xFFDCE2EB);
  static Color bodyOutline(BuildContext context) => AppTokens.isDark(context)
      ? const Color(0xFFA1AEC5)
      : const Color(0xFF8B9DBB);

  static const double trendHeight = 180.0;

  /// 记账趋势采用紧凑高度，为分类分布与排行保留首屏空间。
  static const double ledgerTrendHeight = 144.0;

  /// 坐标区域随实际文字宽度扩展，基础间距沿用图表统一布局。
  static const double yAxisMinWidth = 40.0;
  static const double axisLabelGap = 8.0;
  static const double plotLeftInset = 8.0;
  static const double plotRightInset = 24.0;
  static const double plotTopInset = 12.0;
  static const double bottomAxisHeight = 24.0;

  static const double lineWidth = 2.0;
  static const double dotRadius = 2.5;
  static const double xLabelFontSize = 10.0;
  static const double yLabelFontSize = 11.0;
}
