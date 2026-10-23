import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 分类占比环图，按完整占比切分扇区，两侧标注分类名称和百分比。
class CategoryDonutChart extends StatelessWidget {
  /// 上层提供 Top5 分类与其他聚合，百分比的单位为 0..1。
  final List<DonutCategory> data;

  /// 总金额（元），用于判断空数据状态。
  final double sum;

  const CategoryDonutChart({super.key, required this.data, required this.sum});

  /// 环图最大外半径；窄屏按两侧文字和引导线所需宽度缩小。
  static const double _outerRadius = 78;
  static const double _labelWidth = AppDimens.p40 + AppDimens.p16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final caption = AppTextTokens.caption(context).copyWith(height: 1.25);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelWidth = math.max(
      _labelWidth,
      textScaler.scale(caption.fontSize!) * 4,
    );
    final tonalColors = AppChartTokens.categoryPalette(context);
    // 图表和引导线共享同一份有效扇区序列与归一化角度。
    final visible = sum <= 0
        ? <DonutCategory>[]
        : data.where((item) => item.percent > 0).toList();
    final labelHeight = visible.fold<double>(
      0,
      (height, item) => math.max(
        height,
        _measureLabelHeight(context, item, caption, labelWidth),
      ),
    );
    final isEmpty = visible.isEmpty;
    final total = visible.fold<double>(0, (sum, item) => sum + item.percent);
    final midAngles = <double>[];
    var startAngle = -math.pi / 2;
    for (final item in visible) {
      final sweep = item.percent / total * 2 * math.pi;
      midAngles.add(startAngle + sweep / 2);
      startAngle += sweep;
    }
    final colors = [
      for (var i = 0; i < visible.length; i++)
        visible[i].isOther
            ? AppTokens.chartOther(context)
            : tonalColors[i % tonalColors.length],
    ];
    final leftCount = midAngles.where((angle) => math.cos(angle) < 0).length;
    final maxSideCount = math.max(leftCount, midAngles.length - leftCount);
    final labelGap = labelHeight + AppDimens.p8;

    return SizedBox(
      // 常规字号保持紧凑，辅助大字按实际标签数量增加高度。
      height: math.max(200, maxSideCount * labelGap + AppDimens.p16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 300.0;
          final h = constraints.maxHeight;
          final center = Offset(w / 2, h / 2);
          final labelAnchorX = labelWidth + AppDimens.p8;
          final outerR = math.min(
            _outerRadius,
            math.max(0.0, w / 2 - labelAnchorX - AppDimens.p16),
          );
          final labelYs = _layoutLabelYs(
            midAngles,
            center,
            outerR,
            h,
            labelHeight,
            labelGap,
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              if (!isEmpty)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GuideLinePainter(
                      midAngles: midAngles,
                      labelYs: labelYs,
                      sectionColors: colors,
                      center: center,
                      outerRadius: outerR,
                      labelAnchorX: labelAnchorX,
                      lineColor: AppTokens.textSecondary(
                        context,
                      ).withValues(alpha: 0.45),
                    ),
                  ),
                ),
              SizedBox.square(
                dimension: outerR * 2,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: isEmpty ? 0 : 2,
                    centerSpaceRadius: outerR * 2 / 3,
                    sections: [
                      if (isEmpty)
                        PieChartSectionData(
                          color: AppTokens.surfaceSecondary(context),
                          value: 1,
                          radius: outerR / 3,
                          showTitle: false,
                        ),
                      for (var i = 0; i < visible.length; i++)
                        PieChartSectionData(
                          color: colors[i],
                          value: visible[i].percent * 100,
                          radius: outerR / 3,
                          showTitle: false,
                        ),
                    ],
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                  // 扇区与引导线共用当前帧的占比，避免过渡角度与标签错位。
                  duration: Duration.zero,
                ),
              ),
              if (!isEmpty)
                SizedBox(
                  width: math.max(0, outerR * 4 / 3 - AppDimens.p16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.analyticsCategoryLabel,
                          style: AppTextTokens.strongTitle(context),
                        ),
                        const SizedBox(height: AppDimens.p4),
                        Text(l10n.analyticsExpenseRatio, style: caption),
                      ],
                    ),
                  ),
                ),
              for (var i = 0; i < visible.length; i++)
                _buildLabel(
                  context,
                  visible[i],
                  colors[i],
                  math.cos(midAngles[i]) < 0,
                  labelYs[i],
                  labelWidth,
                  labelHeight,
                  caption,
                ),
            ],
          );
        },
      ),
    );
  }

  /// 使用实际字体和缩放测量两行标签，覆盖字体回退与行框取整差异。
  double _measureLabelHeight(
    BuildContext context,
    DonutCategory item,
    TextStyle caption,
    double width,
  ) {
    final defaults = DefaultTextStyle.of(context);
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: defaults.textHeightBehavior,
      maxLines: 1,
      ellipsis: '…',
    );
    try {
      painter.text = TextSpan(
        text: item.name,
        style: defaults.style.merge(caption),
      );
      painter.layout(maxWidth: width - AppDimens.p8);
      final nameHeight = math.max(AppDimens.p4, painter.height);
      painter.text = TextSpan(
        text: '${(item.percent * 100).toStringAsFixed(1)}%',
        style: defaults.style.merge(
          caption.copyWith(fontWeight: FontWeight.w600),
        ),
      );
      painter.layout(maxWidth: width);
      return nameHeight + painter.height;
    } finally {
      painter.dispose();
    }
  }

  /// 同侧标签按扇区锚点从上到下保序排列，并留出完整文字行高。
  List<double> _layoutLabelYs(
    List<double> angles,
    Offset center,
    double radius,
    double height,
    double labelHeight,
    double gap,
  ) {
    final naturalYs = [
      for (final angle in angles) center.dy + math.sin(angle) * radius,
    ];
    final result = List<double>.filled(angles.length, 0);
    final minY = labelHeight / 2 + AppDimens.p8;
    final maxY = height - minY;
    for (final isLeft in [true, false]) {
      final indices = [
        for (var i = 0; i < angles.length; i++)
          if ((math.cos(angles[i]) < 0) == isLeft) i,
      ]..sort((a, b) => naturalYs[a].compareTo(naturalYs[b]));
      var previous = minY - gap;
      for (final i in indices) {
        result[i] = math.max(naturalYs[i], previous + gap);
        previous = result[i];
      }
      // 底部超出时反向回收，保持顺序与间距；组件高度已容纳所有标签。
      var next = maxY + gap;
      for (final i in indices.reversed) {
        result[i] = math.min(result[i], next - gap);
        next = result[i];
      }
    }
    return result;
  }

  /// 名称和百分比分行显示，文字固定在两侧区域内，引导线止于区域外。
  Widget _buildLabel(
    BuildContext context,
    DonutCategory item,
    Color color,
    bool isLeft,
    double labelY,
    double width,
    double height,
    TextStyle caption,
  ) {
    final dot = Container(
      width: AppDimens.p4,
      height: AppDimens.p4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final name = Flexible(
      child: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: caption,
      ),
    );
    return Positioned(
      left: isLeft ? AppDimens.p4 : null,
      right: isLeft ? null : AppDimens.p4,
      top: labelY - height / 2,
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: isLeft
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [name, const SizedBox(width: AppDimens.p4), dot]
                : [dot, const SizedBox(width: AppDimens.p4), name],
          ),
          Text(
            '${(item.percent * 100).toStringAsFixed(1)}%',
            maxLines: 1,
            style: caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokens.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// 引导线在环图外侧的独立通道内连接，避免穿过环图或标签文字。
class _GuideLinePainter extends CustomPainter {
  final List<double> midAngles;
  final List<double> labelYs;
  final List<Color> sectionColors;
  final Offset center;
  final double outerRadius;
  final double labelAnchorX;
  final Color lineColor;

  _GuideLinePainter({
    required this.midAngles,
    required this.labelYs,
    required this.sectionColors,
    required this.center,
    required this.outerRadius,
    required this.labelAnchorX,
    required this.lineColor,
  });

  /// 扇区水平出线至同侧通道，再按相同的纵向顺序连接标签。
  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < midAngles.length; i++) {
      final angle = midAngles[i];
      final isLeft = math.cos(angle) < 0;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * outerRadius;
      final railX =
          center.dx + (isLeft ? -1 : 1) * (outerRadius + AppDimens.p8);
      final endX = isLeft ? labelAnchorX : size.width - labelAnchorX;
      // 所有斜线只占用同一竖向通道，起点与终点均按 y 排序，因此互不交叉。
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(railX, start.dy)
          ..lineTo(endX, labelYs[i]),
        guidePaint,
      );
      canvas.drawCircle(start, 2, Paint()..color = sectionColors[i]);
    }
  }

  /// 数据、布局或主题改变时更新引导线。
  @override
  bool shouldRepaint(covariant _GuideLinePainter old) =>
      old.midAngles != midAngles ||
      old.labelYs != labelYs ||
      old.sectionColors != sectionColors ||
      old.center != center ||
      old.outerRadius != outerRadius ||
      old.labelAnchorX != labelAnchorX ||
      old.lineColor != lineColor;
}

/// 环图分类及占全部支出的比例。
class DonutCategory {
  final String name;
  final double percent;
  final bool isOther;

  /// 创建分类，其他聚合使用中性灰扇区。
  const DonutCategory({
    required this.name,
    required this.percent,
    this.isOther = false,
  });
}
