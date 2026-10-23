import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

/// 中央添加按钮与日历共用选中日期，业务切换不会覆盖用户选择。
final calendarSelectedDateProvider =
    NotifierProvider<SimpleStateNotifier<DateTime>, DateTime>(
      () => SimpleStateNotifier((ref) {
        final now = ref.read(localTodayProvider);
        return DateTime(now.year, now.month, now.day);
      }),
    );

/// 可见月份包含相邻月补位日期，以当地零点构造查询边界。
({DateTime start, DateTime until}) calendarGridRange(DateTime month) {
  final first = DateTime(month.year, month.month);
  final start = DateTime(first.year, first.month, 2 - first.weekday);
  final last = DateTime(month.year, month.month + 1, 0);
  return (
    start: start,
    until: DateTime(last.year, last.month, last.day + 8 - last.weekday),
  );
}

/// 每条纪念日按原有循环与阶段规则派生，坏记录单独列出，不阻断其他业务。
class CalendarDayEvents {
  const CalendarDayEvents(this.byDate, this.invalid);
  final Map<String, List<DayEvent>> byDate;
  final List<DayEvent> invalid;
}

/// 仅计算当前可见网格，同一记录在同一天只出现一次。
CalendarDayEvents projectCalendarDayEvents(
  List<DayEvent> events,
  DateTime month,
) {
  final range = calendarGridRange(month);
  final byDate = <String, List<DayEvent>>{};
  final invalid = <DayEvent>[];
  final ordered = [...events]
    ..sort((a, b) {
      final category = dayCategoryOrder
          .indexOf(a.definition.category)
          .compareTo(dayCategoryOrder.indexOf(b.definition.category));
      if (category != 0) return category;
      final created = a.createdAt.compareTo(b.createdAt);
      return created != 0 ? created : a.id.compareTo(b.id);
    });
  for (final event in ordered) {
    try {
      if (event.hasUnreadableDate) {
        throw const DayDateException('unreadable_projection');
      }
      final occurrences = const DayDateRules().eventsInCalendarRange(
        event.definition,
        DateTime.utc(range.start.year, range.start.month, range.start.day),
        DateTime.utc(range.until.year, range.until.month, range.until.day - 1),
      );
      for (final date in occurrences.map((item) => item.date.iso8601).toSet()) {
        byDate.putIfAbsent(date, () => []).add(event);
      }
    } catch (error, stack) {
      logger.error('UnifiedCalendar', '纪念日日期派生失败 id=${event.id}', error, stack);
      invalid.add(event);
    }
  }
  return CalendarDayEvents(byDate, invalid);
}

/// 当前日子本的加载状态和日期投影一起传递，避免失败被误报为空。
final calendarDayEventsProvider = Provider.autoDispose
    .family<AsyncValue<CalendarDayEvents>, DateTime>((ref, month) {
      final book = ref.watch(currentDayBookProvider);
      return book.when(
        data: (book) => book == null
            ? const AsyncData(CalendarDayEvents({}, []))
            : ref
                  .watch(dayEventsProvider(book.id))
                  .whenData(
                    (events) => projectCalendarDayEvents(events, month),
                  ),
        loading: () => const AsyncLoading(),
        error: (error, stack) => AsyncError(error, stack),
      );
    });

/// 月历数量不读取正文、不受明细分页限制，账号或时区变化会重新订阅。
final unifiedMemoCountsProvider = StreamProvider.autoDispose
    .family<Map<DateTime, int>, ({String bookId, DateTime month})>((
      ref,
      query,
    ) {
      ref.watch(localTodayProvider);
      final range = calendarGridRange(query.month);
      return ref
          .watch(memoQueryRepositoryProvider)
          .watchCalendarCounts(
            query.bookId,
            start: range.start,
            until: range.until,
            accountId: ref.watch(currentAccountIdProvider),
          );
    });
