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
  test('每日提醒默认关闭，启用后沿用共用时间且四个固定节点均不重复', () {
    final selected = event(
      '出发日',
      OriginalDate.solar(DateOnly(2026, 1, 8)),
      yearly: false,
    );
    final configured = settings.copyWith(daysDailyEventIds: {selected.id});
    final before = planDayReminders([selected], configured, DateTime(2026));
    expect(before.values.map((item) => item.date.day), [1, 5, 7, 8]);

    final daily = planDayReminders(
      [selected],
      configured.copyWith(daysDailyEnabled: true),
      DateTime(2026),
    );
    expect(daily, hasLength(8));
    expect(daily.values.map((item) => item.date), [
      for (var day = 1; day <= 8; day++) DateTime(2026, 1, day, 9, 30),
    ]);
    expect(
      daily.values.every((item) => item.body == '出发日 · 2026-01-08'),
      isTrue,
    );
    expect(
      planDayReminders(
        [selected],
        configured.copyWith(daysDailyEnabled: true),
        DateTime(2026, 1, 9),
      ),
      isEmpty,
    );
  });
  test('每日多选只扩展勾选记录，同名记录保留各自一行并按身份去重', () {
    final first = event(
      '相同名称',
      OriginalDate.solar(DateOnly(2026, 1, 8)),
      yearly: false,
      id: 'first',
    );
    final second = event(
      '相同名称',
      OriginalDate.solar(DateOnly(2026, 1, 8)),
      yearly: false,
      id: 'second',
    );
    final unselected = event(
      '未勾选',
      OriginalDate.solar(DateOnly(2026, 1, 8)),
      yearly: false,
    );
    final plan = planDayReminders(
      [first, second, unselected, first],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {first.id, second.id, 'missing-event'},
      ),
      DateTime(2026),
    );
    final ordinary = plan.values.singleWhere((item) => item.date.day == 2);
    expect(ordinary.body.split('\n'), [
      '相同名称 · 2026-01-08',
      '相同名称 · 2026-01-08',
    ]);
    for (final day in [1, 5, 7, 8]) {
      final fixed = plan.values.singleWhere((item) => item.date.day == day);
      expect(fixed.body.split('\n'), hasLength(3));
      expect(fixed.body, contains('未勾选'));
    }
  });
  test('年度每日提醒在当日后转到下一年，遥远倒数日仍覆盖排期窗口', () {
    final anniversary = event(
      '元旦纪念日',
      OriginalDate.solar(DateOnly(2000, 1, 1)),
    );
    final annual = planDayReminders(
      [anniversary],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {anniversary.id},
      ),
      DateTime(2026, 12, 31),
    );
    expect(annual, hasLength(366));
    expect(
      annual.values
          .singleWhere((item) => item.date == DateTime(2027, 1, 1, 9, 30))
          .body,
      '元旦纪念日 · 2027-01-01',
    );
    expect(
      annual.values
          .singleWhere((item) => item.date == DateTime(2027, 1, 2, 9, 30))
          .body,
      '元旦纪念日 · 2028-01-01',
    );
    final distant = event(
      '未来目标',
      OriginalDate.solar(DateOnly(2030, 1, 1)),
      yearly: false,
    );
    final countdown = planDayReminders(
      [distant],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {distant.id},
      ),
      DateTime(2026),
    );
    expect(countdown, hasLength(366));
    expect(
      countdown.values.every((item) => item.body.endsWith('2030-01-01')),
      isTrue,
    );
  });
  test('每日提醒复用农历和闰日回落，按提醒当日选择下一次日期', () {
    final lunar = event(
      '春节生日',
      const OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2000,
        originalMonth: 1,
        originalDay: 1,
      ),
    );
    final leap = event('闰日', OriginalDate.solar(DateOnly(2024, 2, 29)));
    final plan = planDayReminders(
      [lunar, leap],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {lunar.id, leap.id},
      ),
      DateTime(2026, 2, 17),
    );
    expect(plan.values.first.body, contains('春节生日 · 2026-02-17'));
    expect(
      plan.values
          .singleWhere((item) => item.date == DateTime(2026, 2, 18, 9, 30))
          .body,
      contains('春节生日 · 2027-02-06'),
    );
    expect(
      plan.values
          .singleWhere((item) => item.date == DateTime(2026, 3, 1, 9, 30))
          .body,
      contains('闰日 · 2027-02-28'),
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
  test('每日提醒在窗口没有农历闰月时定位跨年下一次，达到年份上限后停止', () {
    final leapMonth = event(
      '闰二月生日',
      const OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2023,
        originalMonth: 2,
        originalDay: 1,
        isLeapMonth: true,
      ),
    );
    final daily = planDayReminders(
      [leapMonth],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {leapMonth.id},
      ),
      DateTime(2026),
    );
    expect(daily, hasLength(366));
    expect(
      daily.values.every((item) => item.body == '闰二月生日 · 2042-03-22'),
      isTrue,
    );

    final finalAnniversary = event(
      '年末纪念日',
      OriginalDate.solar(DateOnly(2000, 12, 31)),
    );
    final bounded = planDayReminders(
      [finalAnniversary],
      settings.copyWith(
        daysDailyEnabled: true,
        daysDailyEventIds: {finalAnniversary.id},
      ),
      DateTime(2100, 12, 30),
    );
    expect(bounded.values.map((item) => item.date), [
      DateTime(2100, 12, 30, 9, 30),
      DateTime(2100, 12, 31, 9, 30),
    ]);
  });
  test('每日提醒跨日保留已投递内容，取消选择撤销每日排期并保留固定节点', () async {
    var now = DateTime(2026, 1, 2, 8);
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(notifications, clock: () => now);
    final target = event(
      '出发日',
      OriginalDate.solar(DateOnly(2026, 1, 8)),
      yearly: false,
    );
    final daily = settings.copyWith(
      daysDailyEnabled: true,
      daysDailyEventIds: {target.id},
    );
    final before = planDayReminders([target], daily, now);
    final delivered = before.entries.first;
    await scheduler.synchronize(before, '纪念日');
    notifications.pending.remove(delivered.key);
    notifications.delivered[delivered.key] = delivered.value;
    now = DateTime(2026, 1, 3, 8);
    final after = planDayReminders(
      [target],
      daily,
      now,
      registeredDates: scheduler.registeredDates,
    );
    await scheduler.synchronize(after, '纪念日', force: true);
    expect(notifications.delivered[delivered.key], delivered.value);
    expect(
      notifications.scheduled.where((id) => id == delivered.key),
      hasLength(1),
    );
    await scheduler.synchronize(
      planDayReminders(
        [target],
        daily.copyWith(daysDailyEnabled: false),
        now,
        registeredDates: scheduler.registeredDates,
      ),
      '纪念日',
    );
    expect(notifications.delivered, isEmpty);
    expect(notifications.pending.values.map((item) => item.date.day), [
      5,
      7,
      8,
    ]);
    await scheduler.synchronize(planDayReminders([], daily, now), '纪念日');
    expect(notifications.pending, isEmpty);
  });
  test('到期后返回前台保留当天通知，不补发，删除记录仍撤销', () async {
    var now = DateTime(2026, 9, 21, 9);
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(notifications, clock: () => now);
    final events = [
      event('验收日', OriginalDate.solar(DateOnly(2026, 9, 21)), yearly: false),
    ];
    final selected = settings.copyWith(daysOffsets: 1);
    final before = planDayReminders(events, selected, now);
    await scheduler.synchronize(before, '纪念日');
    final id = notifications.scheduled.single;
    // 系统送达后会从待执行列表移除，但通知仍显示在通知栏。
    notifications.pending.remove(id);
    now = DateTime(2026, 9, 21, 10);
    final after = planDayReminders(events, selected, now);
    await scheduler.synchronize(after, '纪念日', force: true);
    await scheduler.synchronize(after, '纪念日', force: true);
    expect(notifications.cancelled, isEmpty);
    expect(notifications.scheduled, [id]);
    // 冷启动同样不补发今天已经到时的提醒。
    await DayReminderScheduler(
      notifications,
      clock: () => now,
    ).synchronize(after, '纪念日', force: true);
    expect(notifications.scheduled, [id]);
    await scheduler.synchronize(planDayReminders([], selected, now), '纪念日');
    expect(notifications.cancelled, [id]);
  });
  test('农历年度日期和闰日复用业务规则，提前一周不按原始公历日期重复', () {
    final lunar = event(
      '春节生日',
      const OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2000,
        originalMonth: 1,
        originalDay: 1,
      ),
    );
    final plan = planDayReminders(
      [lunar],
      settings.copyWith(daysOffsets: 129),
      DateTime(2026, 1, 1),
    );
    expect(plan.values.map((e) => e.date).toSet(), {
      DateTime(2026, 2, 10, 9, 30),
      DateTime(2026, 2, 17, 9, 30),
    });
    final leap = planDayReminders(
      [event('闰日', OriginalDate.solar(DateOnly(2024, 2, 29)))],
      settings.copyWith(daysOffsets: 1),
      DateTime(2027, 1, 1),
    );
    expect(leap.values.single.date, DateTime(2027, 2, 28, 9, 30));
  });
  test('农历八月廿五提前一周送达后，次日核对保留通知，删除记录仍撤销', () async {
    var now = DateTime(2026, 9, 27);
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(notifications, clock: () => now);
    final birthday = event(
      '生日',
      const OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2000,
        originalMonth: 8,
        originalDay: 25,
      ),
    );
    final before = planDayReminders([birthday], settings, now);
    final reminder = before.entries.singleWhere(
      (entry) => entry.value.date == DateTime(2026, 9, 28, 9, 30),
    );
    expect(reminder.value.body, contains('2026-10-05'));
    await scheduler.synchronize(before, '纪念日');
    // 系统送达后只从排期移除；通知栏内容等待用户处理。
    notifications.pending.remove(reminder.key);
    now = DateTime(2026, 9, 29);
    final after = planDayReminders(
      [birthday],
      settings,
      now,
      registeredDates: scheduler.registeredDates,
    );
    await scheduler.synchronize(after, '纪念日', force: true);
    expect(notifications.cancelled, isNot(contains(reminder.key)));
    expect(
      notifications.scheduled.where((id) => id == reminder.key),
      hasLength(1),
    );
    expect(
      notifications.pending.values.map((item) => item.date),
      containsAll([
        DateTime(2026, 10, 2, 9, 30),
        DateTime(2026, 10, 4, 9, 30),
        DateTime(2026, 10, 5, 9, 30),
      ]),
    );
    await scheduler.synchronize(planDayReminders([], settings, now), '纪念日');
    expect(notifications.cancelled, contains(reminder.key));
  });
  test('跨日删除合并通知中的部分记录时撤销旧正文，不补发历史提醒', () async {
    var now = DateTime(2026, 9, 28, 8);
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(notifications, clock: () => now);
    final selected = settings.copyWith(daysOffsets: 1);
    final first = event(
      '生日甲',
      OriginalDate.solar(DateOnly(2026, 9, 28)),
      yearly: false,
    );
    final second = event(
      '生日乙',
      OriginalDate.solar(DateOnly(2026, 9, 28)),
      yearly: false,
    );
    final before = planDayReminders([first, second], selected, now);
    await scheduler.synchronize(before, '纪念日');
    final reminderId = before.keys.single;
    expect(before.values.single.body, contains('生日甲'));
    expect(before.values.single.body, contains('生日乙'));
    notifications.pending.remove(reminderId);
    now = DateTime(2026, 9, 29);
    final after = planDayReminders(
      [second],
      selected,
      now,
      registeredDates: scheduler.registeredDates,
    );
    expect(after.keys, contains(reminderId));
    expect(after.values.single.body, isNot(contains('生日甲')));
    await scheduler.synchronize(after, '纪念日');
    expect(notifications.cancelled, [reminderId]);
    expect(notifications.scheduled, [reminderId]);
    expect(scheduler.registeredDates, isEmpty);
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
  test('历史通知与下一年排期复用标识时保留未来提醒', () {
    final previous = DateTime(2026, 9, 28);
    final upcoming = DateTime(
      previous.year,
      previous.month,
      previous.day + 400,
    );
    final plan = planDayReminders(
      [
        event(
          '未来纪念日',
          OriginalDate.solar(DateOnly.fromDateTime(upcoming)),
          yearly: false,
        ),
        event(
          '过去纪念日',
          OriginalDate.solar(DateOnly.fromDateTime(previous)),
          yearly: false,
        ),
      ],
      settings.copyWith(daysOffsets: 1),
      DateTime(2026, 11, 3),
      registeredDates: [previous],
    );
    expect(plan, hasLength(1));
    expect(
      plan.values.single.date,
      DateTime(upcoming.year, upcoming.month, upcoming.day, 9, 30),
    );
    expect(plan.values.single.body, contains('未来纪念日'));
  });
  test('系统丢失未来排期时，普通数据核对也会重新登记', () async {
    final notifications = _Notifications();
    final scheduler = DayReminderScheduler(
      notifications,
      clock: () => DateTime(2026),
    );
    final plan = {10001: (date: DateTime(2027), body: '生日')};
    await scheduler.synchronize(plan, '纪念日');
    notifications.pending.clear();
    await scheduler.synchronize(plan, '纪念日');
    expect(notifications.scheduled, [10001, 10001]);
    expect(notifications.pending, plan);
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
  for (final delivered in [false, true]) {
    test('同一纪念日跨到期并发核对时保留${delivered ? '已送达通知' : '等待系统投递的提醒'}', () async {
      var now = DateTime(2026, 10, 5, 9, 29, 59);
      final date = DateTime(2026, 10, 5, 9, 30);
      final notifications = _Notifications()
        ..deliverOnSchedule = delivered
        ..gate = Completer<void>()
        ..started = Completer<void>();
      final scheduler = DayReminderScheduler(notifications, clock: () => now);
      final plan = {10001: (date: date, body: '生日')};
      final first = scheduler.synchronize(plan, '纪念日', accountId: 'account-a');
      await notifications.started!.future;
      // 原生登记已开始，但回执与前台恢复交错；到期本身不能撤销同一条提醒。
      now = DateTime(2026, 10, 5, 9, 30, 1);
      final resumed = scheduler.synchronize(
        plan,
        '纪念日',
        accountId: 'account-a',
        force: true,
      );
      notifications.gate!.complete();
      await Future.wait([first, resumed]);
      expect(notifications.cancelled, isEmpty);
      expect(notifications.scheduled, [10001]);
      expect(delivered ? notifications.delivered : notifications.pending, plan);
      expect(scheduler.registeredDates, [date]);
    });
  }
  for (final concurrent in [false, true]) {
    test('到期后仅切换语言标题${concurrent ? '并发' : '顺序'}核对仍保留通知', () async {
      var now = DateTime(2026, 10, 5, 9, 29, 59);
      final date = DateTime(2026, 10, 5, 9, 30);
      final notifications = _Notifications()..deliverOnSchedule = true;
      if (concurrent) {
        notifications.gate = Completer<void>();
        notifications.started = Completer<void>();
      }
      final scheduler = DayReminderScheduler(notifications, clock: () => now);
      final plan = {10001: (date: date, body: '生日')};
      final first = scheduler.synchronize(plan, '纪念日', accountId: 'account-a');
      if (concurrent) {
        await notifications.started!.future;
      } else {
        await first;
      }
      now = DateTime(2026, 10, 5, 9, 30, 1);
      final updated = scheduler.synchronize(
        plan,
        'Anniversary',
        accountId: 'account-a',
        force: true,
      );
      notifications.gate?.complete();
      await Future.wait([first, updated]);
      expect(notifications.cancelled, isEmpty);
      expect(notifications.delivered, plan);
      expect(notifications.scheduled, [10001]);
      expect(scheduler.registeredDates, [date]);
    });
  }
  for (final change in ['关闭', '正文', '时间', '账号']) {
    test('纪念日跨到期并发核对遇到$change变化时撤销旧通知', () async {
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
      expect(notifications.cancelled, [10001]);
      expect(notifications.delivered, isEmpty);
      expect(notifications.pending, isEmpty);
      expect(notifications.scheduled, [10001]);
      expect(scheduler.registeredDates, isEmpty);
    });
  }
}
