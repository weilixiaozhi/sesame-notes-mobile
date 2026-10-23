import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'format_money.dart';
import 'app_empty.dart';

/// 图表金额标注：输入单位为元，>=10000 用 w，>=1000 用 k。
/// 最多两位小数并去尾零；不可传入数据库的整数分。
String formatChartValueLabel(double v) {
  if (v >= 10000) {
    return '${formatMoneyCompact(v / 10000, maxDecimals: 2)}w';
  }
  if (v >= 1000) return '${formatMoneyCompact(v / 1000, maxDecimals: 2)}k';
  return formatMoneyCompact(v, maxDecimals: 2);
}

/// 支出趋势图：点击固定日期金额，长按查看数值，并可按宿主配置横滑周期。
class AnalyticsLineChart extends StatefulWidget {
  /// 金额单位为元，与横轴日期一一对应；空列表仅展示网格与刻度。
  final List<double> values;
  final List<String> xLabels;
  final List<String>? tooltipLabels;
  final String? currencyCode;

  /// 非金额业务提供单位格式；缺失值用 NaN 留出断点，不补零。
  final String Function(double)? valueFormatter;

  /// 非金额业务的纵轴刻度与单位。
  final String Function(double)? yValueFormatter;

  /// 当前日期的横轴下标。
  final int? highlightIndex;

  /// 横轴末端的周期单位。
  final String? xUnitLabel;

  /// 左滑传入 1、右滑传入 -1；未提供时保留拖动查看图中数值的交互。
  final ValueChanged<int>? onPeriodSwipe;

  /// 日期、数值和可选周期导航由统计页面提供。
  const AnalyticsLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    this.tooltipLabels,
    this.currencyCode,
    this.valueFormatter,
    this.yValueFormatter,
    this.highlightIndex,
    this.xUnitLabel,
    this.onPeriodSwipe,
  });

  /// 管理固定日期与触摸期间的临时选择。
  @override
  State<AnalyticsLineChart> createState() => _AnalyticsLineChartState();
}

class _AnalyticsLineChartState extends State<AnalyticsLineChart> {
  int? _pinnedIndex;
  int? _selectedIndex;
  Offset _periodDrag = Offset.zero;

  /// 数据或日期变化后清除旧选择；普通父组件重建保留固定日期。
  @override
  void didUpdateWidget(covariant AnalyticsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values) ||
        !listEquals(oldWidget.xLabels, widget.xLabels) ||
        oldWidget.xUnitLabel != widget.xUnitLabel) {
      _pinnedIndex = null;
      _selectedIndex = null;
    }
  }

  /// 点击松手固定日期，拖动结束或手势取消时恢复已固定的日期。
  void _handleTouch(fl.FlTouchEvent event, fl.LineTouchResponse? response) {
    if (widget.onPeriodSwipe != null) {
      // 图表自身的平移识别器可能先取得手势，复用同一周期切换规则。
      if (event is fl.FlPanStartEvent) {
        _periodDrag = Offset.zero;
      } else if (event is fl.FlPanUpdateEvent) {
        _periodDrag += event.details.delta;
      } else if (event is fl.FlPanEndEvent) {
        if (_finishPeriodSwipe(event.details.velocity.pixelsPerSecond)) return;
      } else if (event is fl.FlPanCancelEvent) {
        _periodDrag = Offset.zero;
      }
    }
    final touchedIndex = response?.lineBarSpots?.firstOrNull?.spotIndex;
    // 点击抬手在移动端不属于持续触摸事件，需要单独保存固定选择。
    if (event is fl.FlTapUpEvent) {
      _pinnedIndex = touchedIndex;
    }
    final index = event.isInterestedForInteractions
        ? touchedIndex
        : _pinnedIndex;
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  /// 只把明确的横向滑动用于翻页，轻触、竖滑和长按继续承担原有交互。
  bool _finishPeriodSwipe(Offset velocity) {
    final distance = _periodDrag;
    _periodDrag = Offset.zero;
    final horizontalDistance = distance.dx.abs() > distance.dy.abs();
    final horizontalVelocity = velocity.dx.abs() > velocity.dy.abs();
    if (widget.onPeriodSwipe == null ||
        !(horizontalDistance && distance.dx.abs() >= AppDimens.p40 ||
            horizontalVelocity && velocity.dx.abs() >= 350)) {
      return false;
    }
    final direction = distance.dx == 0 ? velocity.dx : distance.dx;
    _clearSelection();
    widget.onPeriodSwipe!(direction < 0 ? 1 : -1);
    return true;
  }

  /// 点击图表以外的区域时收起竖线与提示。
  void _clearSelection() {
    if (_pinnedIndex != null || _selectedIndex != null) {
      setState(() {
        _pinnedIndex = null;
        _selectedIndex = null;
      });
    }
  }

  /// 绘制轻量网格、折线与图表原生触摸指示。
  @override
  Widget build(BuildContext context) {
    final expense = AppTokens.chartExpense(context);
    final textPrimary = AppTokens.textPrimary(context);
    final textSecondary = AppTokens.textSecondary(context);
    final range = _chooseYRange();
    final values = widget.values;
    final hasData = values.any((value) => value.isFinite);
    final xLabels = widget.xLabels;
    final xUnitLabel = widget.xUnitLabel;
    final yLabelStyle = AppTextTokens.caption(
      context,
    ).copyWith(fontSize: AppChartTokens.yLabelFontSize, color: textSecondary);
    // 金额刻度使用完整数值与千分位，训练时长等业务继续使用宿主提供的单位。
    final formatYLabel = widget.yValueFormatter ?? formatMoneyCompact;
    final yLabels = <String>[
      for (
        var index = 0;
        index <= ((range.max - range.min) / range.step).round();
        index++
      )
        formatYLabel(range.min + index * range.step),
    ];
    final leftReserved = _measureYLabelWidth(context, yLabels, yLabelStyle);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final plotWidth = math.max(1.0, width - leftReserved);
        final dataWidth = math.max(
          1.0,
          plotWidth -
              AppChartTokens.plotLeftInset -
              AppChartTokens.plotRightInset,
        );
        final n = values.length;
        final axisCount = math.max(n, xLabels.length);
        // 通过横轴数据范围预留首尾空间，金额与周期单位均不贴边。
        final unitDx = math.max(1, axisCount - 1) / dataWidth;
        final minX = axisCount == 1
            ? -0.5
            : -AppChartTokens.plotLeftInset * unitDx;
        final maxX = axisCount == 1
            ? 0.5
            : math.max(1, axisCount - 1) +
                  AppChartTokens.plotRightInset * unitDx;
        // 周和年完整显示刻度；按日月历才依据可用宽度适度抽稀。
        final labelSpacing = MediaQuery.textScalerOf(context).scale(28);
        final labelStep = xLabels.length <= 12
            ? 1
            : math.max(1, (labelSpacing * unitDx).ceil());
        final barData = fl.LineChartBarData(
          spots: [
            for (var i = 0; i < n; i++)
              values[i].isFinite
                  ? fl.FlSpot(i.toDouble(), values[i])
                  : fl.FlSpot.nullSpot,
          ],
          color: expense,
          showingIndicators: [?_selectedIndex],
          barWidth: AppChartTokens.lineWidth,
          isCurved: false,
          isStrokeCapRound: true,
          belowBarData: fl.BarAreaData(
            show: range.min == 0,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                expense.withValues(alpha: 0.12),
                expense.withValues(alpha: 0),
              ],
            ),
          ),
          dotData: fl.FlDotData(
            // 月视图以连续折线表达走势，仅突出今天与选中的日期。
            checkToShowDot: (spot, _) =>
                spot.y != 0 &&
                (n <= 12 ||
                    spot.x == widget.highlightIndex?.toDouble() ||
                    spot.x == _selectedIndex?.toDouble()),
            getDotPainter: (spot, percent, bar, index) => fl.FlDotCirclePainter(
              radius: AppChartTokens.dotRadius,
              color: expense,
              strokeWidth: 0,
            ),
          ),
        );

        final chart = Stack(
          fit: StackFit.expand,
          children: [
            fl.LineChart(
              fl.LineChartData(
                minX: minX,
                maxX: maxX,
                minY: range.min,
                maxY: range.max,
                showingTooltipIndicators: [
                  if (_selectedIndex != null)
                    fl.ShowingTooltipIndicators([
                      fl.LineBarSpot(
                        barData,
                        0,
                        barData.spots[_selectedIndex!],
                      ),
                    ]),
                ],
                borderData: fl.FlBorderData(show: false),
                gridData: fl.FlGridData(
                  show: hasData,
                  drawVerticalLine: false,
                  horizontalInterval: range.step,
                  getDrawingHorizontalLine: (_) => fl.FlLine(
                    color: textSecondary.withValues(alpha: 0.16),
                    strokeWidth: 1,
                    dashArray: const [3, 4],
                  ),
                ),
                titlesData: fl.FlTitlesData(
                  leftTitles: fl.AxisTitles(
                    sideTitles: fl.SideTitles(
                      showTitles: hasData,
                      reservedSize: leftReserved,
                      interval: range.step,
                      getTitlesWidget: (value, meta) => fl.SideTitleWidget(
                        meta: meta,
                        space: AppChartTokens.axisLabelGap,
                        child: Text(
                          formatYLabel(value),
                          maxLines: 1,
                          softWrap: false,
                          style: yLabelStyle,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: fl.AxisTitles(
                    sideTitles: fl.SideTitles(
                      showTitles: true,
                      reservedSize: AppChartTokens.bottomAxisHeight,
                      interval: 1,
                      getTitlesWidget: (value, meta) => _buildXTitle(
                        value,
                        meta,
                        textPrimary,
                        textSecondary,
                        labelStep,
                        labelStep / unitDx,
                      ),
                    ),
                  ),
                  topTitles: fl.AxisTitles(
                    sideTitles: fl.SideTitles(
                      showTitles: true,
                      reservedSize: AppChartTokens.plotTopInset,
                      getTitlesWidget: (_, _) => const SizedBox.shrink(),
                    ),
                  ),
                  rightTitles: const fl.AxisTitles(
                    sideTitles: fl.SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: fl.LineTouchData(
                  handleBuiltInTouches: false,
                  touchCallback: _handleTouch,
                  // 命中以横向距离为准，手指无需精确落在折线上。
                  touchSpotThreshold: double.infinity,
                  getTouchLineStart: (_, _) => range.min,
                  getTouchLineEnd: (_, _) => range.max,
                  getTouchedSpotIndicator: (bar, indices) => [
                    for (final _ in indices)
                      fl.TouchedSpotIndicatorData(
                        fl.FlLine(
                          color: expense.withValues(alpha: 0.45),
                          strokeWidth: 1,
                        ),
                        fl.FlDotData(
                          getDotPainter: (_, _, _, _) => fl.FlDotCirclePainter(
                            radius: AppChartTokens.dotRadius + 1,
                            color: expense,
                            strokeWidth: 2,
                            strokeColor: AppTokens.surface(context),
                          ),
                        ),
                      ),
                  ],
                  touchTooltipData: fl.LineTouchTooltipData(
                    getTooltipColor: (_) => AppTokens.surface(context),
                    tooltipBorderRadius: BorderRadius.circular(
                      AppDimens.radius8,
                    ),
                    tooltipPadding: const EdgeInsets.all(AppDimens.p8),
                    tooltipMargin: 8,
                    maxContentWidth: 160,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    showOnTopOfTheChartBoxArea: true,
                    getTooltipItems: (spots) => [
                      for (final spot in spots)
                        fl.LineTooltipItem(
                          '${(widget.tooltipLabels ?? xLabels).elementAtOrNull(spot.spotIndex) ?? spot.spotIndex + 1}  ${widget.valueFormatter?.call(spot.y) ?? formatMoneyWithCurrency(spot.y, currencyCode: widget.currencyCode)}',
                          AppTextTokens.label(
                            context,
                          ).copyWith(color: textPrimary, height: 1.5),
                        ),
                    ],
                  ),
                ),
                lineBarsData: n == 0 ? const [] : [barData],
              ),
              // 竖线与提示随触摸即时更新。
              duration: Duration.zero,
            ),
            if (!hasData) const Center(child: AppEmpty()),
            if (xUnitLabel?.isNotEmpty ?? false)
              Positioned(
                right: 0,
                bottom: 4,
                child: Text(
                  xUnitLabel!,
                  style: TextStyle(
                    fontSize: AppChartTokens.xLabelFontSize,
                    color: textSecondary,
                  ),
                ),
              ),
          ],
        );
        return TapRegion(
          onTapOutside: (_) => _clearSelection(),
          child: widget.onPeriodSwipe == null
              ? chart
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // 与外层业务页签使用相同方向的识别器，图内横滑优先留在图表。
                  onHorizontalDragStart: (_) => _periodDrag = Offset.zero,
                  onHorizontalDragUpdate: (details) =>
                      _periodDrag += details.delta,
                  onHorizontalDragEnd: (details) =>
                      _finishPeriodSwipe(details.velocity.pixelsPerSecond),
                  onHorizontalDragCancel: () => _periodDrag = Offset.zero,
                  child: chart,
                ),
        );
      },
    );
  }

  /// 按字体、系统字号与业务单位测量纵轴，完整数字无需缩字或贴住折线。
  double _measureYLabelWidth(
    BuildContext context,
    List<String> labels,
    TextStyle style,
  ) {
    var width = AppChartTokens.yAxisMinWidth;
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );
    try {
      for (final label in labels) {
        painter.text = TextSpan(text: label, style: style);
        painter.layout();
        width = math.max(width, painter.width + AppChartTokens.axisLabelGap);
      }
      return width.ceilToDouble();
    } finally {
      painter.dispose();
    }
  }

  /// 日期按可用宽度抽稀，当前日期优先显示并让相邻刻度避开。
  Widget _buildXTitle(
    double value,
    fl.TitleMeta meta,
    Color textPrimary,
    Color textSecondary,
    int step,
    double labelWidth,
  ) {
    final xLabels = widget.xLabels;
    final highlightIndex = widget.highlightIndex;
    final index = value.round();
    if ((value - index).abs() > 0.001 || index < 0 || index >= xLabels.length) {
      return const SizedBox.shrink();
    }
    final highlighted = index == highlightIndex;
    if (!highlighted &&
        (index % step != 0 ||
            (highlightIndex != null &&
                (index - highlightIndex).abs() < step))) {
      return const SizedBox.shrink();
    }
    return fl.SideTitleWidget(
      meta: meta,
      space: 8,
      child: SizedBox(
        width: labelWidth,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            xLabels[index],
            maxLines: 1,
            style: TextStyle(
              fontSize: AppChartTokens.xLabelFontSize,
              color: highlighted ? textPrimary : textSecondary,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// 纵轴覆盖所有金额并上下留白，刻度按 1/2/2.5/5/10 的数量级取整。
  ({double min, double max, double step}) _chooseYRange() {
    final values = widget.values.where((value) => value.isFinite).toList();
    if (values.isEmpty || values.every((value) => value == 0)) {
      return (min: 0, max: 1, step: 0.25);
    }
    final low = values.reduce(math.min);
    final high = values.reduce(math.max);
    // 常量与微小波动至少保留金额量级的 20%，避免视觉夸大变化。
    final span = math.max(high - low, math.max(high.abs() * 0.2, 0.01));
    final rawStep = span * 1.2 / 4;
    final magnitude = math
        .pow(10, (math.log(rawStep) / math.ln10).floor())
        .toDouble();
    final step = math.max(
      0.01,
      [
            1.0,
            2.0,
            2.5,
            5.0,
            10.0,
          ].firstWhere((factor) => factor * magnitude >= rawStep) *
          magnitude,
    );
    final padding = (span - (high - low)) / 2 + span * 0.1;
    final lower = low >= 0 ? math.max(0.0, low - padding) : low - padding;
    return (
      min: (lower / step).floor() * step,
      max: ((high + padding) / step).ceil() * step,
      step: step,
    );
  }
}
