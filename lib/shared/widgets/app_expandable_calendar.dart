import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 业务首页共用周月切换、日期标签与回到今天操作。
class AppExpandableCalendar<T> extends StatelessWidget {
  /// 日期和展开状态由业务持有，切换日期只通知当前页面。
  const AppExpandableCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.selectedDay,
    required this.currentDay,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onDateSelected,
    required this.maxLabels,
    required this.dayMarkerBuilder,
    this.rangeToggleKey,
    this.rangeTextKey,
    this.previousWeekLabel,
    this.nextWeekLabel,
  });

  final DateTime firstDay, lastDay, selectedDay, currentDay;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<DateTime> onDateSelected;
  final int maxLabels;
  final Widget? Function(BuildContext, DateTime, bool) dayMarkerBuilder;
  final Key? rangeToggleKey, rangeTextKey;
  final String? previousWeekLabel, nextWeekLabel;

  /// 标题和留白区域同样归日期导航，按当前展开状态移动一周或一月。
  void _movePage(int direction) {
    final target = expanded
        ? DateTime(selectedDay.year, selectedDay.month + direction)
        : DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day + 7 * direction,
          );
    final bounded = target.isBefore(firstDay)
        ? firstDay
        : target.isAfter(lastDay)
        ? lastDay
        : target;
    if (!DateUtils.isSameDay(bounded, selectedDay)) {
      onDateSelected(bounded);
    }
  }

  /// 收起时横滑切周，展开后横滑切月，日期格始终使用共享日历。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final start = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day - selectedDay.weekday + 1,
    );
    final end = DateTime(start.year, start.month, start.day + 6);
    final rangeLabel = expanded
        ? DateFormat.yMMMM(l.localeName).format(selectedDay)
        : '${DateFormat.MMMd(l.localeName).format(start)} ~ ${DateFormat.MMMd(l.localeName).format(end)}';
    var dragDistance = 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => dragDistance = 0,
      onHorizontalDragUpdate: (details) => dragDistance += details.delta.dx,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() > 50) {
          _movePage(velocity < 0 ? 1 : -1);
        } else if (dragDistance.abs() > 25) {
          _movePage(dragDistance < 0 ? 1 : -1);
        }
      },
      child: Column(
        children: [
          if (shouldShowCalendarToday(
            selectedDay: selectedDay,
            focusedDay: selectedDay,
            currentDay: currentDay,
          ))
            Align(
              alignment: Alignment.centerRight,
              child: HeaderTextAction(
                label: l.calendarToday,
                onPressed: () => onDateSelected(DateUtils.dateOnly(currentDay)),
              ),
            ),
          AppCalendar<T>(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: selectedDay,
            currentDay: currentDay,
            calendarFormat: expanded
                ? CalendarFormat.month
                : CalendarFormat.week,
            adaptiveRows: expanded,
            previousPageLabel: expanded ? null : previousWeekLabel,
            nextPageLabel: expanded ? null : nextWeekLabel,
            rowHeight: expanded
                ? AppDimens.calendarRowHeight
                : AppCalendarLabels.rowHeight(context, maxLabels),
            selectedDayPredicate: (date) => isSameDay(date, selectedDay),
            onDaySelected: (date, _) =>
                onDateSelected(DateUtils.dateOnly(date)),
            // 翻页回调已经指向新周或新月，直接采用日期以免跨周后被拉回原页。
            onPageChanged: (date) => onDateSelected(DateUtils.dateOnly(date)),
            headerTitleBuilder: (context, _) => Tooltip(
              message: rangeLabel,
              excludeFromSemantics: true,
              child: InkWell(
                key: rangeToggleKey,
                onTap: onToggleExpanded,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: kMinInteractiveDimension,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        // 长日期只缩放文字，翻页与展开操作保持完整点击区域。
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            rangeLabel,
                            key: rangeTextKey,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: AppTextTokens.strongTitle(context),
                          ),
                        ),
                      ),
                      Icon(
                        expanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                        size: AppDimens.icon16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            dayMarkerBuilder: dayMarkerBuilder,
          ),
        ],
      ),
    );
  }
}
