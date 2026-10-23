import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/app_expandable_calendar.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 日子首页与训练共用可展开日期卡片，选日只更新当前页的日期基准。
class DayWeekStrip extends StatefulWidget {
  /// 今天、选中日期和当前本的事件由首页提供，卡片只维护展开状态。
  const DayWeekStrip({
    super.key,
    required this.today,
    required this.selectedDay,
    required this.events,
    required this.onDateSelected,
  });

  final DateOnly today, selectedDay;
  final List<DayEvent> events;
  final ValueChanged<DateTime> onDateSelected;

  /// 业务日期由首页持有，周月状态只作用于当前卡片。
  @override
  State<DayWeekStrip> createState() => _DayWeekStripState();
}

class _DayWeekStripState extends State<DayWeekStrip> {
  bool _expanded = false;

  /// 循环日子按领域规则派生真实发生日期，日期标签与统一日历保持一致。
  @override
  Widget build(BuildContext context) {
    final selected = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    final projected = projectCalendarDayEvents(widget.events, selected);
    // 周历翻页保留相邻页参与动画，行高需要同时容纳这些日期的标签。
    final maxLabels = projected.byDate.values.fold(
      0,
      (max, events) => events.length > max ? events.length : max,
    );
    return SectionCard(
      key: const ValueKey('days-week-strip'),
      margin: const EdgeInsets.only(bottom: AppDimens.p16),
      child: AppExpandableCalendar<DayEvent>(
        firstDay: DateTime(DayLimits.minYear),
        lastDay: DateTime(DayLimits.maxYear, 12, 31),
        selectedDay: selected,
        currentDay: DateTime(
          widget.today.year,
          widget.today.month,
          widget.today.day,
        ),
        expanded: _expanded,
        onToggleExpanded: () => setState(() => _expanded = !_expanded),
        onDateSelected: widget.onDateSelected,
        maxLabels: maxLabels,
        rangeToggleKey: const ValueKey('days-calendar-range-toggle'),
        rangeTextKey: const ValueKey('days-calendar-range-text'),
        dayMarkerBuilder: (context, date, _) {
          final events =
              projected.byDate[DateFormat('yyyy-MM-dd').format(date)];
          return events == null || events.isEmpty
              ? null
              : AppCalendarLabels(
                  labels: [for (final event in events) event.definition.name],
                );
        },
      ),
    );
  }
}
