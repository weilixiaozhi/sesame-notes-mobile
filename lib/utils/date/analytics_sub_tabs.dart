/// 统计页子 Tab 生成算法（纯函数，便于单元测试）。
///
/// 设计意图：
/// - 无任何数据时，返回当前选中周期；未指定选择时返回当前周期。
/// - 有数据时，按 earliest..latest 生成连续 Tab 列表（即便中间空也保留）。
/// - earliest == latest 时只返回一个 Tab。
/// - 列表按时间升序排列，并始终包含选中的周期供界面高亮和定位。
library;

// 周日期纯函数（mondayOf / weekNumber / weeksInYear / mondayOfWeek）定义于
// lib/utils/date/week_math.dart，本文件直接复用。
import 'week_math.dart';
import 'month_range.dart';

/// 统计周期类型枚举（'week'/'month'/'year' 的强类型版本）。
enum AnalyticsPeriod { week, month, year }

/// 子 Tab 项：id 唯一标识、label 显示文案、start/end 半开区间 [start, end)。
class AnalyticsSubTab {
  final String id;
  final String label;
  final DateTime start;
  final DateTime end;

  const AnalyticsSubTab({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
  });
}

/// 生成子 Tab 列表。
///
/// [period] 周期类型；[earliest]/[latest] 为账本内有数据的最早/最晚交易时间（本地时区），
/// 可为 null 表示无数据；[now] 注入当前时间便于测试；[monthStartDay] 账本每月起始日(1-31)，
/// 仅影响月/年视图的区间切分（与 periodForLabel 口径一致）。
/// [selectedDate] 为选中的标签日期，月/年仅取对应标签，周取所在周一。
///
/// 返回按时间升序的 Tab 列表；无数据时返回选中周期或当前周期一项。
List<AnalyticsSubTab> generateSubTabs({
  required AnalyticsPeriod period,
  required DateTime? earliest,
  required DateTime? latest,
  required DateTime now,
  DateTime? selectedDate,
  required int monthStartDay,
  required String Function(int month) monthLabel,
  required String Function(int weekNumber) weekNLabel,
  required String thisWeekLabel,
  required String Function(int year) yearLabel,
}) {
  // 选择器和图表可以浏览无记录的周期；该日期必须成为可定位的子周期。
  final selected = selectedDate == null
      ? null
      : _selectedPeriodTab(
          period,
          selectedDate,
          monthStartDay,
          monthLabel,
          weekNLabel,
          yearLabel,
        );
  // 数据尚未加载或完全为空时，子周期仍与标题中的选择保持一致。
  if (earliest == null || latest == null) {
    return [
      selected ??
          _currentPeriodTab(
            period,
            now,
            monthStartDay,
            monthLabel,
            thisWeekLabel,
            yearLabel,
          ),
    ];
  }

  final tabs = switch (period) {
    AnalyticsPeriod.month => _generateMonthTabs(
      earliest,
      latest,
      monthStartDay,
      monthLabel,
    ),
    AnalyticsPeriod.year => _generateYearTabs(
      earliest,
      latest,
      monthStartDay,
      yearLabel,
    ),
    AnalyticsPeriod.week => _generateWeekTabs(earliest, latest, weekNLabel),
  };
  if (selected != null && !tabs.any((tab) => tab.id == selected.id)) {
    // 只补充正在浏览的周期，避免少量历史数据因为远期选择而生成巨大空白列表。
    tabs.add(selected);
    tabs.sort((a, b) => a.start.compareTo(b.start));
  }
  return tabs;
}

/// 将选择器的标签日期直接转成期间，避免自定义账期把月初标签归到上月。
AnalyticsSubTab _selectedPeriodTab(
  AnalyticsPeriod period,
  DateTime date,
  int monthStartDay,
  String Function(int month) monthLabel,
  String Function(int weekNumber) weekNLabel,
  String Function(int year) yearLabel,
) {
  switch (period) {
    case AnalyticsPeriod.month:
      final range = periodForLabel(date.year, date.month, monthStartDay);
      return AnalyticsSubTab(
        id: '${date.year}-${date.month.toString().padLeft(2, '0')}',
        label: monthLabel(date.month),
        start: range.start,
        end: range.end,
      );
    case AnalyticsPeriod.year:
      final range = yearRangeFor(date.year, monthStartDay);
      return AnalyticsSubTab(
        id: '${date.year}',
        label: yearLabel(date.year),
        start: range.start,
        end: range.end,
      );
    case AnalyticsPeriod.week:
      final monday = mondayOf(date);
      final number = weekNumber(monday);
      return AnalyticsSubTab(
        id: '${monday.year}-W$number',
        label: weekNLabel(number),
        start: monday,
        end: DateTime(monday.year, monday.month, monday.day + 7),
      );
  }
}

/// 生成当前周期对应的单个 Tab（无数据兜底）。
AnalyticsSubTab _currentPeriodTab(
  AnalyticsPeriod period,
  DateTime now,
  int monthStartDay,
  String Function(int month) monthLabel,
  String thisWeekLabel,
  String Function(int year) yearLabel,
) {
  switch (period) {
    case AnalyticsPeriod.month:
      final label = labelForDate(now, monthStartDay);
      final range = periodForLabel(label.year, label.month, monthStartDay);
      return AnalyticsSubTab(
        id: '${label.year}-${label.month.toString().padLeft(2, '0')}',
        label: monthLabel(label.month),
        start: range.start,
        end: range.end,
      );
    case AnalyticsPeriod.year:
      final y = labelForDate(now, monthStartDay).year;
      final range = yearRangeFor(y, monthStartDay);
      return AnalyticsSubTab(
        id: '$y',
        label: yearLabel(y),
        start: range.start,
        end: range.end,
      );
    case AnalyticsPeriod.week:
      final monday = mondayOf(now);
      return AnalyticsSubTab(
        id: '${monday.year}-W${weekNumber(monday)}',
        label: thisWeekLabel,
        start: monday,
        end: DateTime(monday.year, monday.month, monday.day + 7),
      );
  }
}

/// 月视图 Tab：从 earliest 所在标签月到 latest 所在标签月，按月递增。
List<AnalyticsSubTab> _generateMonthTabs(
  DateTime earliest,
  DateTime latest,
  int monthStartDay,
  String Function(int month) monthLabel,
) {
  final startLabel = labelForDate(earliest, monthStartDay);
  final endLabel = labelForDate(latest, monthStartDay);
  final tabs = <AnalyticsSubTab>[];
  DateTime cur = DateTime(startLabel.year, startLabel.month, 1);
  final end = DateTime(endLabel.year, endLabel.month, 1);
  // 上限保护：极端情况（数据跨度过大）避免无限循环，最多 240 个月（20 年）。
  int guard = 0;
  while (!cur.isAfter(end) && guard < 240) {
    final range = periodForLabel(cur.year, cur.month, monthStartDay);
    tabs.add(
      AnalyticsSubTab(
        id: '${cur.year}-${cur.month.toString().padLeft(2, '0')}',
        label: monthLabel(cur.month),
        start: range.start,
        end: range.end,
      ),
    );
    cur = DateTime(cur.year, cur.month + 1, 1);
    guard++;
  }
  return tabs;
}

/// 年视图 Tab：从 earliest 所属账期年到 latest 所属账期年，按年递增。
List<AnalyticsSubTab> _generateYearTabs(
  DateTime earliest,
  DateTime latest,
  int monthStartDay,
  String Function(int year) yearLabel,
) {
  final startY = labelForDate(earliest, monthStartDay).year;
  final endY = labelForDate(latest, monthStartDay).year;
  final tabs = <AnalyticsSubTab>[];
  for (var y = startY; y <= endY; y++) {
    final range = yearRangeFor(y, monthStartDay);
    tabs.add(
      AnalyticsSubTab(
        id: '$y',
        label: yearLabel(y),
        start: range.start,
        end: range.end,
      ),
    );
  }
  return tabs;
}

/// 周视图 Tab：从 earliest 所在周一到 latest 所在周一，按周一递增。
List<AnalyticsSubTab> _generateWeekTabs(
  DateTime earliest,
  DateTime latest,
  String Function(int weekNumber) weekNLabel,
) {
  final startMonday = mondayOf(earliest);
  final endMonday = mondayOf(latest);
  final tabs = <AnalyticsSubTab>[];
  DateTime cur = startMonday;
  // 上限保护：最多 520 周（约 10 年）。
  int guard = 0;
  while (!cur.isAfter(endMonday) && guard < 520) {
    final wn = weekNumber(cur);
    tabs.add(
      AnalyticsSubTab(
        id: '${cur.year}-W$wn',
        label: weekNLabel(wn),
        start: cur,
        end: DateTime(cur.year, cur.month, cur.day + 7),
      ),
    );
    cur = DateTime(cur.year, cur.month, cur.day + 7);
    guard++;
  }
  return tabs;
}
