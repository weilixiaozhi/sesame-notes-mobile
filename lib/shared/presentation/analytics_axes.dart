/// 统计折线图横轴口径：记账与健身共用同一套刻度、提示与高亮规则。
///
/// 设计意图：折线图（AnalyticsLineChart）只负责绘制，"横轴显示什么"由本出口
/// 统一决定，避免两个统计页各写一套导致同一周期呈现不一致。
/// - 周：刻度为星期简称（周一..周日），不添加重复的末端单位；
/// - 月：刻度为日（1..31），末端单位为「日」；
/// - 年：刻度为月（1..12），末端单位为「月」；
/// - 触摸/点击提示：日刻度用 MMMd，月刻度用 yMMM；
/// - 当前周期内高亮「今天」所在刻度。
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';

/// 折线图横轴配置。
typedef AnalyticsAxes = ({
  /// 刻度文案，与折线数值一一对应。
  List<String> xLabels,

  /// 触摸/点击刻度时的提示文案，与刻度一一对应。
  List<String> tooltipLabels,

  /// 当前周期内「今天」所在刻度下标；不在当前周期时为 null。
  int? highlightIndex,

  /// 横轴末端的刻度单位；星期简称本身已含单位时为空。
  String? unitLabel,
});

/// 星期简称（周视图刻度）：英文用 Mon..Sun，其余语言用 周一..周日。
///
/// 只依赖 Locale（由调用方从 BuildContext 取），本身是纯函数。
String analyticsWeekdayShort(Locale locale, int weekday) {
  if (locale.languageCode == 'en') {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return en[weekday - 1];
  }
  const zh = ['一', '二', '三', '四', '五', '六', '日'];
  return '周${zh[weekday - 1]}';
}

/// 生成折线图横轴配置。
///
/// [points] 为各刻度对应的时间点，顺序与折线数值一致：周/月视图为每天，
/// 年视图固定传 1..12 月，保证刻度始终完整。
/// [isCurrent] 为选中周期是否就是当前周期，历史周期不高亮。
/// [highlightDate] 用于定位高亮刻度：周/月按天匹配，年按月匹配。
AnalyticsAxes buildAnalyticsAxes({
  required BuildContext context,
  required AnalyticsPeriod period,
  required List<DateTime> points,
  required bool isCurrent,
  required DateTime highlightDate,
  required String dayUnitLabel,
  required String monthUnitLabel,
}) => buildAnalyticsAxesForLocale(
  locale: Localizations.localeOf(context),
  period: period,
  points: points,
  isCurrent: isCurrent,
  highlightDate: highlightDate,
  dayUnitLabel: dayUnitLabel,
  monthUnitLabel: monthUnitLabel,
);

/// [buildAnalyticsAxes] 的纯函数入口：locale 显式传入，不依赖 BuildContext。
AnalyticsAxes buildAnalyticsAxesForLocale({
  required Locale locale,
  required AnalyticsPeriod period,
  required List<DateTime> points,
  required bool isCurrent,
  required DateTime highlightDate,
  required String dayUnitLabel,
  required String monthUnitLabel,
}) {
  final localeName = locale.toString();
  final xLabels = <String>[];
  final tooltipLabels = <String>[];
  var highlightIndex = -1;
  for (var index = 0; index < points.length; index++) {
    final point = points[index];
    xLabels.add(switch (period) {
      AnalyticsPeriod.week => analyticsWeekdayShort(locale, point.weekday),
      AnalyticsPeriod.month => '${point.day}',
      AnalyticsPeriod.year => '${point.month}',
    });
    tooltipLabels.add(switch (period) {
      AnalyticsPeriod.week ||
      AnalyticsPeriod.month => DateFormat.MMMd(localeName).format(point),
      AnalyticsPeriod.year => DateFormat.yMMM(localeName).format(point),
    });
    if (highlightIndex < 0 && _isHighlighted(period, point, highlightDate)) {
      highlightIndex = index;
    }
  }
  return (
    xLabels: xLabels,
    tooltipLabels: tooltipLabels,
    highlightIndex: isCurrent && highlightIndex >= 0 ? highlightIndex : null,
    unitLabel: switch (period) {
      AnalyticsPeriod.week => null,
      AnalyticsPeriod.month => dayUnitLabel,
      AnalyticsPeriod.year => monthUnitLabel,
    },
  );
}

/// 周/月刻度按天匹配，年刻度按月匹配。
bool _isHighlighted(AnalyticsPeriod period, DateTime point, DateTime target) =>
    period == AnalyticsPeriod.year
    ? point.year == target.year && point.month == target.month
    : point.year == target.year &&
          point.month == target.month &&
          point.day == target.day;
