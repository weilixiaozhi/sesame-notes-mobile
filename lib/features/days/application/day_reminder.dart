import '../../../data/models/day_event.dart';
import '../../../core/logging/logger_service.dart';
import '../../../shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import '../domain/day_date_rules.dart';

/// 同一天合并成一条通知；保留独立 ID 段，取消时不影响记账和健身。
const dayReminderIdStart = 10000;
const dayReminderIdEnd = 10400;
typedef DayReminder = ({DateTime date, String body});

/// 以本地日历日核对提醒，并重新验证已登记日期，保留仍有效的已送达通知。
Map<int, DayReminder> planDayReminders(
  List<DayEvent> events,
  ReminderSettings settings,
  DateTime now, {
  Iterable<DateTime> registeredDates = const [],
}) {
  if (!settings.daysActive) return {};
  try {
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day + 366);
    final occurrenceEnd = DateTime(end.year, end.month, end.day + 7);
    final followingWindowDay = DateTime(end.year, end.month, end.day + 8);
    final lastDailyDay = DateTime(end.year, end.month, end.day - 1);
    final registeredDays = {
      for (final date in registeredDates)
        DateTime(date.year, date.month, date.day),
    };
    final start = registeredDays.fold(
      today,
      (earliest, date) => date.isBefore(earliest) ? date : earliest,
    );
    final dailyDates = [
      for (final day in registeredDays)
        if (day.isBefore(today)) day,
      for (
        var day = today;
        day.isBefore(end);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        day,
    ]..sort();
    // 每天以记录身份去重，同名的不同纪念日仍各自保留一行。
    final byDate = <DateTime, Map<String, String>>{};
    for (final event in events) {
      if (event.deletedAt != null ||
          event.hasUnreadableDate ||
          event.definition.category == DayCategory.stage) {
        continue;
      }
      final dailyEnabled =
          settings.daysDailyEnabled &&
          settings.daysDailyEventIds.contains(event.id);
      // 固定节点最多提前七天，日期计算只覆盖排期窗口和这段提前量。
      final occurrences = const DayDateRules().eventsInCalendarRange(
        event.definition,
        start,
        occurrenceEnd,
      );
      for (final occurrence in occurrences) {
        for (final offset in settings.selectedDayOffsets) {
          final date = DateTime(
            occurrence.date.year,
            occurrence.date.month,
            occurrence.date.day - offset,
            settings.daysHour,
            settings.daysMinute,
          );
          final day = DateTime(date.year, date.month, date.day);
          // 已登记日期使用当前记录和设置重算，内容变化交给调度器核对，
          // 失去对应记录的日期从计划中消失，过去的日期不会补发。
          if ((date.isBefore(today) && !registeredDays.contains(day)) ||
              !date.isBefore(end)) {
            continue;
          }
          byDate.putIfAbsent(date, () => {})[event.id] =
              '${event.definition.name} · ${occurrence.date.iso8601}';
        }
      }
      if (!dailyEnabled) continue;
      final dailyOccurrences = [...occurrences];
      final lastOccurrence = occurrences.lastOrNull?.date;
      // 每日窗口末日也需要指向下一次纪念日。窗口内日期不足时，
      // 仅补充窗口后的第一次；远期倒数日和农历闰月跳年均由日期域定位。
      // 已覆盖末日或已达到支持年份上限时，无需继续计算未来年份。
      if (!followingWindowDay.isAfter(DateTime(DayLimits.maxYear, 12, 31)) &&
          (lastOccurrence == null ||
              DateTime(
                lastOccurrence.year,
                lastOccurrence.month,
                lastOccurrence.day,
              ).isBefore(lastDailyDay))) {
        final next = const DayDateRules().nextOccurrence(
          event.definition,
          DateOnly.fromDateTime(followingWindowDay),
        );
        if (next != null) dailyOccurrences.add(DayOccurrence(next));
      }
      var occurrenceIndex = 0;
      for (final day in dailyDates) {
        // 日期和发生日期均有序，指针只向前移动；单次倒数日到期后停止，
        // 年度纪念日自然转向下一次，已登记的历史日期仍能核对原始正文。
        while (occurrenceIndex < dailyOccurrences.length) {
          final occurrence = dailyOccurrences[occurrenceIndex].date;
          if (!DateTime(
            occurrence.year,
            occurrence.month,
            occurrence.day,
          ).isBefore(day)) {
            break;
          }
          occurrenceIndex++;
        }
        if (occurrenceIndex == dailyOccurrences.length) break;
        final date = DateTime(
          day.year,
          day.month,
          day.day,
          settings.daysHour,
          settings.daysMinute,
        );
        // 固定节点已经写入同一条记录时保留其提醒，只填补普通日期。
        byDate
            .putIfAbsent(date, () => {})
            .putIfAbsent(
              event.id,
              () =>
                  '${event.definition.name} · ${dailyOccurrences[occurrenceIndex].date.iso8601}',
            );
      }
    }
    // 同一标识每 400 天复用一次，历史日期与未来日期重合时优先未来排期。
    // 过去的条目只用于核对通知，不会重新发送。
    final dates = byDate.keys.toList()..sort();
    return {
      for (final date in dates)
        dayReminderIdStart + DateOnly.fromDateTime(date).dayNumber % 400: (
          date: date,
          body: (byDate[date]!.values.toList()..sort()).join('\n'),
        ),
    };
  } catch (error, stack) {
    logger.error(
      'DayReminder',
      '生成纪念日提醒失败：记录数=${events.length}，'
          '每日提醒=${settings.daysDailyEnabled}，选中数=${settings.daysDailyEventIds.length}',
      error,
      stack,
    );
    rethrow;
  }
}

/// 更新排队并检查代次，账号切换、删记录和关闭开关不会被旧调度覆盖。
class DayReminderScheduler {
  DayReminderScheduler(this.notifications, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final DateTime Function() clock;
  final NotificationUtil notifications;
  Future<void> _tail = Future.value();
  int _generation = 0;
  final _scheduled = <int, DayReminder>{};
  String? _title;
  String? _accountId;
  bool _hasAccountScope = false;
  Map<int, DayReminder> _requestedPlan = const {};
  String? _requestedAccountId;

  /// 提供仍需核对的已登记日期，使日期推进与业务删除具有不同的取消结果。
  Iterable<DateTime> get registeredDates =>
      _scheduled.values.map((reminder) => reminder.date);

  /// 串行应用完整计划，过去的有效条目仅保留通知，未来条目提交系统调度。
  Future<void> synchronize(
    Map<int, DayReminder> plan,
    String title, {
    bool force = false,
    String? accountId,
  }) {
    final generation = ++_generation;
    // 保存最新完整意图，系统登记返回时按提醒内容与身份判断是否仍然有效。
    // 固定本次快照，调用方后续修改原映射不会改变队列中的取消依据。
    final requestedPlan = Map<int, DayReminder>.unmodifiable(plan);
    _requestedPlan = requestedPlan;
    _requestedAccountId = accountId;
    final result = _tail.then((_) async {
      try {
        if (generation != _generation) return;
        final pending = await notifications.getPendingNotifications();
        if (generation != _generation) return;
        final pendingIds = pending.map((item) => item.id).toSet();
        final oldIds = {
          ..._scheduled.keys,
          for (final item in pending)
            if (item.id >= dayReminderIdStart && item.id < dayReminderIdEnd)
              item.id,
        };
        final accountChanged = _hasAccountScope && _accountId != accountId;
        // 账号身份独立于日期和正文，即使两个账号的同日记录同名也要撤销旧通知。
        // 首次建立身份时沿用系统排队，避免冷启动把已保存的提醒先删后建。
        for (final id in oldIds.where(
          (id) => accountChanged || !requestedPlan.containsKey(id),
        )) {
          await notifications.cancelNotification(id);
          _scheduled.remove(id);
          if (generation != _generation) return;
        }
        _accountId = accountId;
        _hasAccountScope = true;
        if (accountChanged) _title = null;
        if (requestedPlan.isEmpty) return;
        if (!await notifications.checkPermissionStatus()) {
          throw StateError('纪念日通知权限或渠道未开启');
        }
        if (generation != _generation) return;
        for (final entry in requestedPlan.entries) {
          if (!entry.value.date.isAfter(clock())) {
            // 已送达的合并通知只有内容和时间仍一致时才保留，避免展示已删除记录。
            // 到期后的内容变更仅撤销旧通知，不补发新的历史提醒。
            final previous = _scheduled[entry.key];
            if (previous != null && previous != entry.value) {
              await notifications.cancelNotification(entry.key);
              _scheduled.remove(entry.key);
              if (generation != _generation) return;
            }
            continue;
          }
          if (!force &&
              pendingIds.contains(entry.key) &&
              _title == title &&
              _scheduled[entry.key] == entry.value) {
            continue;
          }
          await notifications.scheduleOnceReminder(
            id: entry.key,
            title: title,
            body: entry.value.body,
            scheduledDate: entry.value.date,
          );
          _scheduled[entry.key] = entry.value;
          if (generation != _generation) {
            // 相同提醒的恢复核对可以与到期投递交错，保留其系统任务和已显示通知。
            // 标题随语言变化不影响已到期提醒；删除、内容、时间或账号变更才需撤销。
            if (_requestedAccountId != accountId ||
                _requestedPlan[entry.key] != entry.value) {
              await notifications.cancelNotification(entry.key);
              _scheduled.remove(entry.key);
            }
            return;
          }
        }
        _title = title;
      } catch (error, stack) {
        logger.error(
          'DayReminder',
          '同步纪念日提醒失败：代次=$generation，计划数=${requestedPlan.length}',
          error,
          stack,
        );
        rethrow;
      }
    });
    _tail = result.catchError((Object _) {});
    return result;
  }
}
