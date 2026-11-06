import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/application/day_reminder_lifecycle.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_reminder.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';

class _Notifications extends Fake implements NotificationUtil {
  final pending = <int, DayReminder>{};
  final delivered = <int, DayReminder>{};
  final cancelled = <int>[];
  final scheduled = <int>[];
  bool permitted = true;
  bool fail = false;
  bool deliverOnSchedule = false;
  Completer<void>? gate;
  Completer<void>? started;
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => [
    for (final entry in pending.entries)
      PendingNotificationRequest(entry.key, 'title', entry.value.body, null),
  ];
  @override
  Future<bool> checkPermissionStatus() async => permitted;
  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
    pending.remove(id);
    delivered.remove(id);
  }

  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (fail) throw StateError('调度失败');
    if (started?.isCompleted == false) started!.complete();
    await gate?.future;
    final destination = deliverOnSchedule ? delivered : pending;
    destination[id] = (date: scheduledDate, body: body);
    scheduled.add(id);
  }
}

/// 构造有效的年度纪念日或单次倒数日，允许同名记录使用不同身份。
DayEvent event(
  String name,
  OriginalDate date, {
  bool yearly = true,
  String? id,
}) => DayEvent(
  id: id ?? name,
  dayBookId: 'book',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  definition: DayEventDefinition(
    name: name,
    category: yearly ? DayCategory.birthday : DayCategory.countdown,
    repeatType: yearly ? DayRepeatType.yearly : DayRepeatType.none,
    statisticType: DayStatisticType.day,
    countdownMode: yearly ? null : DayCountdownMode.fixedDate,
    event: date,
  ),
);

/// 提醒随身份、日期与偏好更新，跨到期核对不能误撤已投递通知。
void main() {
  const settings = ReminderSettings(
    notificationsEnabled: true,
    isEnabled: false,
    hour: 21,
    minute: 0,
    daysEnabled: true,
    daysOffsets: 139,
    daysHour: 9,
    daysMinute: 30,
  );
  testWidgets('常驻调度跟随真实设置总开关与记录流，删除本子撤销全部纪念日提醒', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.daysEnabled: true,
      ReminderPrefs.daysDailyEnabled: true,
      ReminderPrefs.daysDailyEventIds: ['生日'],
    });
    final notifications = _Notifications();
    // 本场景通过真实设置入口提交，通用通知后端与纪念日渠道共用同一替身。
    NotificationFactory.setInstanceForTesting(notifications);
    NotificationFactory.setDaysInstanceForTesting(notifications);
    final books = StreamController<List<DayBook>>.broadcast();
    final entries = StreamController<List<DayEvent>>.broadcast();
    final container = ProviderContainer(
      overrides: [
        currentAccountIdProvider.overrideWithValue(null),
        localClockNowProvider.overrideWithValue(() => DateTime(2026, 1, 1)),
        localTodayProvider.overrideWithBuild(
          (ref, notifier) => DateTime(2026, 1, 1),
        ),
        dayBooksProvider.overrideWith((ref) => books.stream),
        dayEventsProvider('book').overrideWith((ref) => entries.stream),
      ],
    );
    final subscription = container.listen(
      dayReminderLifecycleProvider,
      (_, _) {},
    );
    await tester.pumpAndSettle();
    final book = DayBook(
      id: 'book',
      name: '本子',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final birthday = event('生日', OriginalDate.solar(DateOnly(2000, 2, 1)));
    books.add([book]);
    await tester.pumpAndSettle();
    entries.add([birthday]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isNotEmpty);
    final notifier = container.read(reminderSettingsProvider.notifier);
    final initiallyScheduled = notifications.scheduled.length;
    final pendingCount = notifications.pending.length;
    expect(pendingCount, 366);
    final loaded = container.read(reminderSettingsProvider);
    expect(loaded.isLoaded, isTrue);
    await notifier.updateSettings(loaded.copyWith(hour: 22, minute: 15));
    await tester.pumpAndSettle();
    await notifier.updateSettings(
      container.read(reminderSettingsProvider).copyWith(restEnabled: false),
    );
    await tester.pumpAndSettle();
    expect(
      notifications.scheduled.length,
      initiallyScheduled,
      reason: '每日记账时间和健身开关不改变纪念日排期',
    );
    await notifier.updateSettings(
      container
          .read(reminderSettingsProvider)
          .copyWith(daysHour: 10, daysMinute: 15),
    );
    await tester.pumpAndSettle();
    expect(notifications.scheduled.length, initiallyScheduled + pendingCount);
    expect(
      notifications.pending.values.every(
        (item) => item.date.hour == 10 && item.date.minute == 15,
      ),
      isTrue,
    );
    final original = container.read(reminderSettingsProvider);
    await notifier.updateSettings(
      original.copyWith(notificationsEnabled: false),
    );
    await tester.pumpAndSettle();
    expect(notifications.pending, isEmpty);
    // 测试中模拟已保存配置恢复，权限请求已由设置服务测试覆盖。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ReminderPrefs.notificationsEnabled, true);
    container.invalidate(reminderSettingsProvider);
    await tester.pumpAndSettle();
    books.add([book]);
    await tester.pumpAndSettle();
    entries.add([birthday]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isNotEmpty);
    entries.add([]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isEmpty);
    entries.add([birthday]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isNotEmpty);
    books.add([]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isEmpty);
    subscription.close();
    container.dispose();
    await books.close();
    await entries.close();
    NotificationFactory.reset();
    await tester.pump(const Duration(seconds: 3));
  });

  // 读取失败只是"暂时不知道有哪些纪念日"，与"用户关闭纪念日提醒"（空计划）不同：
  // 空计划在调度器里等于取消全部已排通知，错误态不能折叠成空计划。
  testWidgets('纪念日数据读取失败时保留既有排队，不取消已排提醒', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.daysEnabled: true,
    });
    final notifications = _Notifications();
    NotificationFactory.setDaysInstanceForTesting(notifications);
    final books = StreamController<List<DayBook>>.broadcast();
    final entries = StreamController<List<DayEvent>>.broadcast();
    final container = ProviderContainer(
      overrides: [
        currentAccountIdProvider.overrideWithValue(null),
        localClockNowProvider.overrideWithValue(() => DateTime(2026, 1, 1)),
        localTodayProvider.overrideWithBuild(
          (ref, notifier) => DateTime(2026, 1, 1),
        ),
        dayBooksProvider.overrideWith((ref) => books.stream),
        dayEventsProvider('book').overrideWith((ref) => entries.stream),
      ],
    );
    final subscription = container.listen(
      dayReminderLifecycleProvider,
      (_, _) {},
    );
    await tester.pumpAndSettle();
    books.add([
      DayBook(
        id: 'book',
        name: '本子',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ]);
    await tester.pumpAndSettle();
    entries.add([event('生日', OriginalDate.solar(DateOnly(2000, 2, 1)))]);
    await tester.pumpAndSettle();
    expect(notifications.pending, isNotEmpty);

    entries.addError(StateError('db down'));
    await tester.pumpAndSettle();
    expect(notifications.pending, isNotEmpty, reason: '读取失败不得取消已排提醒');
    expect(notifications.cancelled, isEmpty);

    subscription.close();
    container.dispose();
    await books.close();
    await entries.close();
    NotificationFactory.reset();
    await tester.pump(const Duration(seconds: 3));
  });

  test('提前多选跨年按当地时间安排，同日合并，过期不补发', () {
    final events = [
      event('生日', OriginalDate.solar(DateOnly(2000, 1, 1))),
      event('倒数日', OriginalDate.solar(DateOnly(2027, 1, 1)), yearly: false),
    ];
    final plan = planDayReminders(events, settings, DateTime(2026, 12, 24));
    final dates = plan.values.map((e) => e.date).toList()..sort();
    expect(dates, [
      DateTime(2026, 12, 25, 9, 30),
      DateTime(2026, 12, 29, 9, 30),
      DateTime(2026, 12, 31, 9, 30),
      DateTime(2027, 1, 1, 9, 30),
    ]);
    expect(
      plan.values.every((e) => e.body.contains('生日') && e.body.contains('倒数日')),
      isTrue,
    );
    final after = planDayReminders(events, settings, DateTime(2027, 1, 1, 10));
    // 当天的条目仍用于对齐已送达通知；是否补发由真实调度时间判断。
    final elapsedToday = after.values.singleWhere(
      (item) => item.date == DateTime(2027, 1, 1, 9, 30),
    );
    expect(elapsedToday.body, contains('倒数日'));
    expect(
      after.values.every((item) => !item.date.isBefore(DateTime(2027, 1, 1))),
      isTrue,
    );
    expect(
      planDayReminders(
        events,
        settings.copyWith(notificationsEnabled: false),
        DateTime(2026),
      ),
      isEmpty,
    );
    expect(
      planDayReminders(
        events,
        settings.copyWith(daysEnabled: false),
        DateTime(2026),
      ),
      isEmpty,
    );
  });
  test('每日提醒跳过已删除、不可读、阶段和已过期记录', () {
    final valid = event('基础', OriginalDate.solar(DateOnly(2026, 1, 8)));
    final events = [
      DayEvent(
        id: 'deleted',
        dayBookId: valid.dayBookId,
        definition: valid.definition,
        createdAt: valid.createdAt,
        updatedAt: valid.updatedAt,
        deletedAt: DateTime(2026),
      ),
      DayEvent(
        id: 'unreadable',
        dayBookId: valid.dayBookId,
        definition: valid.definition,
        createdAt: valid.createdAt,
        updatedAt: valid.updatedAt,
        hasUnreadableDate: true,
      ),
      DayEvent(
        id: 'stage',
        dayBookId: valid.dayBookId,
        definition: DayEventDefinition(
          name: '阶段',
          category: DayCategory.stage,
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.day,
          start: OriginalDate.solar(DateOnly(2026, 1, 8)),
        ),
        createdAt: valid.createdAt,
        updatedAt: valid.updatedAt,
      ),
      event('已过期', OriginalDate.solar(DateOnly(2025, 12, 31)), yearly: false),
    ];
    expect(
      planDayReminders(
        events,
        settings.copyWith(
          daysDailyEnabled: true,
          daysDailyEventIds: events.map((item) => item.id).toSet(),
        ),
        DateTime(2026),
      ),
      isEmpty,
    );
  });
  test('切换账号时同名同日历史通知仍撤销，未来排期按新账号重建', () async {
    var now = DateTime(2026, 9, 28, 8);
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(notifications, clock: () => now);
    final selected = settings.copyWith(daysOffsets: 1);
    final birthday = event('同名生日', OriginalDate.solar(DateOnly(2000, 9, 28)));
    final before = planDayReminders([birthday], selected, now);
    final elapsedId = before.entries
        .singleWhere(
          (entry) => entry.value.date == DateTime(2026, 9, 28, 9, 30),
        )
        .key;
    final futureId = before.entries
        .singleWhere(
          (entry) => entry.value.date == DateTime(2027, 9, 28, 9, 30),
        )
        .key;
    await scheduler.synchronize(before, '纪念日', accountId: 'account-a');
    notifications.pending.remove(elapsedId);
    now = DateTime(2026, 9, 29);
    final after = planDayReminders(
      [birthday],
      selected,
      now,
      registeredDates: scheduler.registeredDates,
    );
    expect(after[elapsedId], before[elapsedId]);
    await scheduler.synchronize(after, '纪念日', accountId: 'account-b');
    expect(notifications.cancelled, containsAll([elapsedId, futureId]));
    expect(notifications.pending.keys, [futureId]);
    expect(
      notifications.scheduled.where((id) => id == elapsedId),
      hasLength(1),
    );
    expect(notifications.scheduled.where((id) => id == futureId), hasLength(2));
    expect(scheduler.registeredDates, [DateTime(2027, 9, 28, 9, 30)]);
  });
  test('删除或关闭撤销旧通知，保留其他类型，调度失败后可重试', () async {
    final notifications = _Notifications();
    notifications.pending[1001] = (date: DateTime(2027), body: '记账');
    notifications.pending[2001] = (date: DateTime(2027), body: '休息');
    final scheduler = DayReminderScheduler(
      notifications,
      clock: () => DateTime(2026),
    );
    final plan = {10001: (date: DateTime(2027), body: '生日')};
    await scheduler.synchronize(plan, '纪念日');
    notifications.fail = true;
    await expectLater(
      scheduler.synchronize({
        10002: (date: DateTime(2027, 2), body: '更新'),
      }, '纪念日'),
      throwsStateError,
    );
    notifications.fail = false;
    await scheduler.synchronize(plan, '纪念日');
    expect(notifications.pending.keys, contains(10001));
    await scheduler.synchronize({}, '纪念日');
    expect(notifications.pending.keys.toSet(), {1001, 2001});
    notifications.permitted = false;
    await expectLater(scheduler.synchronize(plan, '纪念日'), throwsStateError);
    notifications.permitted = true;
    await scheduler.synchronize(plan, '纪念日');
    expect(notifications.pending.keys, contains(10001));
  });
  test('飞行中的旧账号调度晚于关闭返回，也必须撤销', () async {
    final notifications = _Notifications()
      ..gate = Completer<void>()
      ..started = Completer<void>();
    final scheduler = DayReminderScheduler(
      notifications,
      clock: () => DateTime(2026),
    );
    final old = scheduler.synchronize({
      10001: (date: DateTime(2027), body: '旧账号'),
    }, '纪念日');
    await notifications.started!.future;
    final stopping = scheduler.synchronize({}, '纪念日');
    notifications.gate!.complete();
    await Future.wait([old, stopping]);
    expect(notifications.pending, isEmpty);
  });
  for (final change in ['不变', '关闭', '正文', '时间', '账号']) {
    test('纪念日跨到期并发核对按$change状态保留或撤销通知', () async {
      try {
        var now = DateTime(2026, 10, 5, 9, 29, 59);
        final date = DateTime(2026, 10, 5, 9, 30);
        final notifications = _Notifications()
          ..deliverOnSchedule = true
          ..gate = Completer<void>()
          ..started = Completer<void>();
        final scheduler = DayReminderScheduler(notifications, clock: () => now);
        final first = scheduler.synchronize(
          {10001: (date: date, body: '旧正文')},
          '纪念日',
          accountId: 'account-a',
        );
        await notifications.started!.future;
        now = DateTime(2026, 10, 5, 9, 30, 1);
        final plan = change == '关闭'
            ? <int, DayReminder>{}
            : {
                10001: (
                  date: change == '时间' ? DateTime(2026, 10, 5, 9, 29) : date,
                  body: change == '正文' ? '新正文' : '旧正文',
                ),
              };
        final updated = scheduler.synchronize(
          plan,
          '纪念日',
          accountId: change == '账号' ? 'account-b' : 'account-a',
          force: true,
        );
        notifications.gate!.complete();
        await Future.wait([first, updated]);
        if (change == '不变') {
          // 到期不是取消指令；同一身份和正文的迟到登记应保留已送达通知。
          expect(notifications.cancelled, isEmpty);
          expect(notifications.delivered, {10001: (date: date, body: '旧正文')});
          expect(scheduler.registeredDates, [date]);
        } else {
          expect(notifications.cancelled, [10001]);
          expect(notifications.delivered, isEmpty);
          expect(scheduler.registeredDates, isEmpty);
        }
        expect(notifications.pending, isEmpty);
        expect(notifications.scheduled, [10001]);
      } catch (error, stackTrace) {
        printOnFailure('纪念日跨到期并发状态验证失败：$change\n$error\n$stackTrace');
        rethrow;
      }
    });
  }
}
