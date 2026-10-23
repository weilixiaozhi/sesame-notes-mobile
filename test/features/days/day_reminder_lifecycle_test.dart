import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/application/day_reminder.dart';
import 'package:sesame_notes/features/days/application/day_reminder_lifecycle.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_reminder_invalidation_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';
import 'package:sesame_notes/shell/reminder_lifecycle_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// 保留启动前系统已接受的提醒，记录生命周期的撤销与重新排队操作。
class _Notifications extends Fake implements NotificationUtil {
  final pending = <int, DayReminder>{};
  final cancelled = <int>[];
  final scheduled = <int>[];
  final scheduledTimeZones = <String>[];
  final dailySchedules = <({int id, int hour, int minute, String timeZone})>[];
  bool failDailySchedule = false;
  Completer<void>? schedulingGate;
  Completer<void>? schedulingStarted;
  int cancellationsToFail = 0;

  /// 返回系统保存的待执行提醒。
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => [
    for (final entry in pending.entries)
      PendingNotificationRequest(entry.key, '纪念日', entry.value.body, null),
  ];

  /// 允许生命周期验证通知排队，不依赖宿主平台权限。
  @override
  Future<bool> checkPermissionStatus() async => true;

  /// 记录真实撤销操作，防止先删后建被最终队列状态掩盖。
  @override
  Future<void> cancelNotification(int id) async {
    if (cancellationsToFail > 0) {
      cancellationsToFail--;
      throw StateError('系统暂未接受取消请求');
    }
    cancelled.add(id);
    pending.remove(id);
  }

  /// 模拟系统以相同标识覆盖未来通知。
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (schedulingStarted?.isCompleted == false) schedulingStarted!.complete();
    await schedulingGate?.future;
    pending[id] = (date: scheduledDate, body: body);
    scheduled.add(id);
    scheduledTimeZones.add(tz.local.name);
  }

  /// 记录每日提醒的当地时区和原始时分，确认系统时间事件不改变用户设置。
  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (failDailySchedule) throw StateError('系统未接受每日提醒');
    dailySchedules.add((
      id: id,
      hour: hour,
      minute: minute,
      timeZone: tz.local.name,
    ));
  }
}

/// 保留真实会话与纪念日生命周期，仅把数据库流替换为可控制的本地读取。
class _AccountReminderFixture {
  final notifications = _Notifications();
  final oldBooks = StreamController<List<DayBook>>.broadcast();
  final newBooks = StreamController<List<DayBook>>.broadcast();
  late final ProviderContainer container;
  ProviderSubscription<Future<void> Function()>? subscription;
  final now = DateTime(2026, 10, 5, 8);

  /// 账号 A 先建立真实身份，随后通过会话入口执行退出、换号或令牌轮换。
  _AccountReminderFixture({
    bool holdScheduling = false,
    bool cachedAccount = false,
    bool startLifecycle = true,
    bool accountingEnabled = false,
    bool notificationsEnabled = true,
    Stream<void>? clockEvents,
  }) {
    ReminderMonitorService().configureTexts(
      textsProvider: () => (title: '记账提醒', body: '记一笔今日账目'),
    );
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: notificationsEnabled,
      ReminderPrefs.enabled: accountingEnabled,
      ReminderPrefs.hour: 21,
      ReminderPrefs.minute: 15,
      ReminderPrefs.daysEnabled: true,
      ReminderPrefs.daysOffsets: 1,
    });
    if (holdScheduling) {
      notifications.schedulingGate = Completer<void>();
      notifications.schedulingStarted = Completer<void>();
    }
    NotificationFactory.setDaysInstanceForTesting(notifications);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        if (clockEvents != null)
          clockChangeEventsProvider.overrideWithValue(clockEvents),
        localClockNowProvider.overrideWithValue(() => now),
        localTodayProvider.overrideWithBuild((ref, notifier) => now),
        dayBooksProvider.overrideWith((ref) {
          final account = ref.watch(currentAccountIdProvider);
          return account == 'account-a' ? oldBooks.stream : newBooks.stream;
        }),
        dayEventsProvider('book').overrideWith((ref) {
          final account = ref.watch(currentAccountIdProvider);
          return Stream.value([
            DayEvent(
              id: 'birthday',
              dayBookId: 'book',
              createdAt: now,
              updatedAt: now,
              definition: DayEventDefinition(
                name: account ?? '本机',
                category: DayCategory.countdown,
                repeatType: DayRepeatType.none,
                statisticType: DayStatisticType.day,
                countdownMode: DayCountdownMode.fixedDate,
                event: OriginalDate.solar(DateOnly(2026, 10, 6)),
              ),
            ),
          ]);
        }),
      ],
    );
    if (cachedAccount) {
      container
          .read(accountStateProvider.notifier)
          .restorePending(userId: 'account-a');
    } else {
      changeAccount('account-a');
    }
    if (startLifecycle) subscribeLifecycle();
  }

  /// 允许在身份失效发生后才装配页面中的提醒监听器。
  void subscribeLifecycle() {
    subscription = container.listen(dayReminderLifecycleProvider, (_, _) {});
  }

  /// 显式退出或更换账号，令牌仅用于驱动真实身份 Provider，不发起网络请求。
  void changeAccount(String? account) {
    final session = container.read(authSessionProvider.notifier);
    if (account == null) {
      session.signOut();
    } else {
      session.signIn(
        AuthSession(
          accessToken: 'token-$account',
          userId: account,
          deviceId: 'device',
        ),
      );
    }
  }

  /// 返回本地流读取成功后的固定本列表。
  List<DayBook> get books => [
    DayBook(id: 'book', name: '纪念日', createdAt: now, updatedAt: now),
  ];

  /// 清理流和身份容器，释放被挂起的调度回执以免污染后续测试。
  Future<void> dispose() async {
    if (notifications.schedulingGate?.isCompleted == false) {
      notifications.schedulingGate!.complete();
    }
    subscription?.close();
    container.dispose();
    await oldBooks.close();
    await newBooks.close();
    NotificationFactory.reset();
    ReminderMonitorService().clearTexts();
  }
}

/// 构造设置延迟加载的冷启动场景，验证系统队列只随已知配置变化。
void main() {
  testWidgets('释放提醒生命周期后取消系统时钟监听，后续广播不会重建提醒', (tester) async {
    final events = StreamController<void>.broadcast();
    final container = ProviderContainer(
      overrides: [clockChangeEventsProvider.overrideWithValue(events.stream)],
    );
    container.listen(reminderClockLifecycleProvider, (_, _) {});
    try {
      expect(events.hasListener, isTrue);
      container.dispose();
      await tester.pumpAndSettle();
      expect(events.hasListener, isFalse);
      events.add(null);
      await tester.pumpAndSettle();
      expect(events.hasListener, isFalse);
    } finally {
      await events.close();
    }
  });
  for (final enabled in [true, false]) {
    testWidgets('同一日系统时区变化时${enabled ? '按新时区重排主提醒和纪念日' : '总开关关闭仍刷新时区但不恢复通知'}', (
      tester,
    ) async {
      var deviceZone = 'Asia/Shanghai';
      var zoneReads = 0;
      final events = StreamController<void>.broadcast();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async {
              if (call.method != 'getTimeZone') return null;
              zoneReads++;
              return deviceZone;
            },
          );
      await NotificationFactory.initializeTimeZone();
      final fixture = _AccountReminderFixture(
        accountingEnabled: true,
        notificationsEnabled: enabled,
        clockEvents: events.stream,
      );
      NotificationFactory.setInstanceForTesting(fixture.notifications);
      fixture.container.listen(reminderClockLifecycleProvider, (_, _) {});
      try {
        await tester.pumpAndSettle();
        fixture.oldBooks.add(fixture.books);
        await tester.pumpAndSettle();
        final originalCount = fixture.notifications.scheduled.length;
        final today = fixture.container.read(localTodayProvider);
        final previousReads = zoneReads;

        deviceZone = 'Asia/Tokyo';
        events.add(null);
        await tester.pumpAndSettle();

        expect(fixture.container.read(localTodayProvider), today);
        expect(tz.local.name, 'Asia/Tokyo');
        expect(zoneReads, previousReads + 1);
        if (enabled) {
          expect(
            fixture.notifications.scheduled.length,
            greaterThan(originalCount),
          );
          expect(fixture.notifications.scheduledTimeZones.last, 'Asia/Tokyo');
          expect(fixture.notifications.dailySchedules, [
            (
              id: ReminderPrefs.mainNotificationId,
              hour: 21,
              minute: 15,
              timeZone: 'Asia/Tokyo',
            ),
          ]);
        } else {
          expect(fixture.notifications.scheduled, isEmpty);
          expect(fixture.notifications.dailySchedules, isEmpty);
        }
      } finally {
        await fixture.dispose();
        await events.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('notification_channel'),
              null,
            );
        await tester.pump(const Duration(seconds: 3));
      }
    });
  }
  testWidgets('时区读取期间退出账号，时钟事件恢复不能重新登记旧账号纪念日', (tester) async {
    final events = StreamController<void>.broadcast();
    final zoneRead = Completer<String>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('notification_channel'),
          (call) async => call.method == 'getTimeZone' ? 'Asia/Shanghai' : null,
        );
    await NotificationFactory.initializeTimeZone();
    final fixture = _AccountReminderFixture(clockEvents: events.stream);
    NotificationFactory.setInstanceForTesting(fixture.notifications);
    fixture.container.listen(reminderClockLifecycleProvider, (_, _) {});
    try {
      await tester.pumpAndSettle();
      fixture.oldBooks.add(fixture.books);
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isNotEmpty);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async =>
                call.method == 'getTimeZone' ? zoneRead.future : null,
          );
      events.add(null);
      await tester.pumpAndSettle();
      fixture.changeAccount(null);
      await tester.pumpAndSettle();
      zoneRead.complete('Asia/Tokyo');
      await tester.pumpAndSettle();

      expect(tz.local.name, 'Asia/Tokyo');
      expect(fixture.notifications.pending, isEmpty);
      expect(fixture.notifications.cancelled, isNotEmpty);
    } finally {
      if (!zoneRead.isCompleted) zoneRead.complete('Asia/Tokyo');
      await fixture.dispose();
      await events.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            null,
          );
      await tester.pump(const Duration(seconds: 3));
    }
  });
  for (final zoneFailure in [true, false]) {
    testWidgets('${zoneFailure ? '读取时区' : '登记主提醒'}失败保留原纪念日任务，成功恢复后才继续重排', (
      tester,
    ) async {
      var deviceZone = 'Asia/Shanghai';
      var failZoneRead = false;
      final events = StreamController<void>.broadcast();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async {
              if (call.method != 'getTimeZone') return null;
              if (failZoneRead) {
                throw PlatformException(code: 'timezone_unavailable');
              }
              return deviceZone;
            },
          );
      await NotificationFactory.initializeTimeZone();
      final fixture = _AccountReminderFixture(
        accountingEnabled: true,
        clockEvents: events.stream,
      );
      NotificationFactory.setInstanceForTesting(fixture.notifications);
      fixture.container.listen(reminderClockLifecycleProvider, (_, _) {});
      try {
        await tester.pumpAndSettle();
        fixture.oldBooks.add(fixture.books);
        await tester.pumpAndSettle();
        final previousCount = fixture.notifications.scheduled.length;
        final previousTasks = Map.of(fixture.notifications.pending);
        deviceZone = 'Asia/Tokyo';
        failZoneRead = zoneFailure;
        fixture.notifications.failDailySchedule = !zoneFailure;

        events.add(null);
        await tester.pumpAndSettle();

        expect(tz.local.name, zoneFailure ? 'Asia/Shanghai' : 'Asia/Tokyo');
        expect(fixture.notifications.pending, previousTasks);
        expect(fixture.notifications.scheduled.length, previousCount);
        expect(fixture.notifications.dailySchedules, isEmpty);
        failZoneRead = false;
        fixture.notifications.failDailySchedule = false;
        events.add(null);
        await tester.pumpAndSettle();
        expect(tz.local.name, 'Asia/Tokyo');
        expect(fixture.notifications.dailySchedules, hasLength(1));
        expect(fixture.notifications.scheduled.length, previousCount + 1);
      } finally {
        await fixture.dispose();
        await events.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('notification_channel'),
              null,
            );
        await tester.pump(const Duration(seconds: 3));
      }
    });
  }
  for (final enabled in [true, false]) {
    testWidgets('冷启动设置读取完成前保留既有纪念日提醒，读取后${enabled ? '继续调度' : '撤销关闭分类'}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        ReminderPrefs.notificationsEnabled: true,
        ReminderPrefs.daysEnabled: enabled,
        ReminderPrefs.daysOffsets: 128,
      });
      final stored = await SharedPreferences.getInstance();
      final loading = Completer<SharedPreferences>();
      final now = DateTime(2026, 9, 27, 8);
      final reminderDate = DateTime(2026, 9, 28, 9);
      final reminderId =
          dayReminderIdStart +
          DateOnly.fromDateTime(reminderDate).dayNumber % 400;
      final notifications = _Notifications()
        ..pending[reminderId] = (date: reminderDate, body: '生日 · 2026-10-05');
      NotificationFactory.setDaysInstanceForTesting(notifications);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => loading.future),
          currentAccountIdProvider.overrideWithValue(null),
          localClockNowProvider.overrideWithValue(() => now),
          localTodayProvider.overrideWithBuild((ref, notifier) => now),
          dayBooksProvider.overrideWith(
            (ref) => Stream.value([
              DayBook(id: 'book', name: '生日', createdAt: now, updatedAt: now),
            ]),
          ),
          dayEventsProvider('book').overrideWith(
            (ref) => Stream.value([
              DayEvent(
                id: 'birthday',
                dayBookId: 'book',
                createdAt: now,
                updatedAt: now,
                definition: DayEventDefinition(
                  name: '生日',
                  category: DayCategory.birthday,
                  repeatType: DayRepeatType.yearly,
                  statisticType: DayStatisticType.day,
                  event: OriginalDate.solar(DateOnly(2000, 10, 5)),
                ),
              ),
            ]),
          ),
        ],
      );
      final subscription = container.listen(
        dayReminderLifecycleProvider,
        (_, _) {},
      );
      try {
        await tester.pumpAndSettle();
        expect(container.read(reminderSettingsProvider).isLoaded, isFalse);
        expect(notifications.cancelled, isEmpty);
        expect(notifications.pending.keys, contains(reminderId));
        expect(container.read(dayReminderEventsProvider).isLoading, isTrue);

        loading.complete(stored);
        await tester.pumpAndSettle();
        expect(container.read(reminderSettingsProvider).isLoaded, isTrue);
        if (enabled) {
          expect(notifications.cancelled, isEmpty);
          expect(notifications.pending.keys, contains(reminderId));
          expect(notifications.scheduled, contains(reminderId));
        } else {
          expect(notifications.cancelled, [reminderId]);
          expect(notifications.pending, isEmpty);
          expect(notifications.scheduled, isEmpty);
        }
      } finally {
        if (!loading.isCompleted) loading.complete(stored);
        subscription.close();
        container.dispose();
        NotificationFactory.reset();
        await tester.pump(const Duration(seconds: 3));
      }
    });
  }
  for (final nextAccount in [null, 'account-b']) {
    for (final readFails in [false, true]) {
      testWidgets(
        '${nextAccount == null ? '退出登录' : '切换账号'}后新数据${readFails ? '读取失败' : '仍在加载'}也立即撤销旧纪念日排期',
        (tester) async {
          final fixture = _AccountReminderFixture();
          try {
            await tester.pumpAndSettle();
            fixture.oldBooks.add(fixture.books);
            await tester.pumpAndSettle();
            expect(fixture.notifications.pending, hasLength(1));
            final oldIds = fixture.notifications.pending.keys.toSet();

            fixture.changeAccount(nextAccount);
            await tester.pumpAndSettle();
            if (readFails) {
              fixture.newBooks.addError(StateError('新身份数据暂不可读'));
              await tester.pumpAndSettle();
            }
            expect(fixture.notifications.pending, isEmpty);
            expect(fixture.notifications.cancelled, containsAll(oldIds));
            expect(
              fixture.container.read(reminderSettingsProvider).daysActive,
              isTrue,
            );

            // 新范围的数据到达后按原设置重新排期，身份清理不等于关闭用户的提醒配置。
            fixture.newBooks.add(fixture.books);
            await tester.pumpAndSettle();
            expect(fixture.notifications.pending, hasLength(1));
            expect(
              fixture.notifications.pending.values.single.body,
              contains(nextAccount ?? '本机'),
            );
          } finally {
            await fixture.dispose();
            await tester.pump(const Duration(seconds: 3));
          }
        },
      );
    }
  }
  testWidgets('同账号令牌刷新及临时读取失败继续保留既有纪念日排期', (tester) async {
    final fixture = _AccountReminderFixture();
    try {
      await tester.pumpAndSettle();
      fixture.oldBooks.add(fixture.books);
      await tester.pumpAndSettle();
      final saved = Map<int, DayReminder>.of(fixture.notifications.pending);
      expect(saved, hasLength(1));
      fixture.container
          .read(authSessionProvider.notifier)
          .updateToken('refreshed-token');
      await tester.pumpAndSettle();
      fixture.container.invalidate(dayBooksProvider);
      await tester.pumpAndSettle();
      expect(
        fixture.container.read(dayReminderEventsProvider).isLoading,
        isTrue,
      );
      fixture.oldBooks.addError(StateError('同账号暂时读取失败'));
      await tester.pumpAndSettle();
      expect(fixture.container.read(currentAccountIdProvider), 'account-a');
      expect(fixture.notifications.cancelled, isEmpty);
      expect(fixture.notifications.pending, saved);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
  testWidgets('旧账号原生登记回执晚于退出，新身份加载中也不能恢复旧排期', (tester) async {
    final fixture = _AccountReminderFixture(holdScheduling: true);
    try {
      await tester.pumpAndSettle();
      fixture.oldBooks.add(fixture.books);
      await tester.pumpAndSettle();
      expect(fixture.notifications.schedulingStarted!.isCompleted, isTrue);
      fixture.changeAccount(null);
      await tester.pumpAndSettle();
      fixture.notifications.schedulingGate!.complete();
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isEmpty);
      expect(fixture.notifications.cancelled, isNotEmpty);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
  testWidgets('冷启动缓存账号恢复同账号会话时，数据加载中继续保留系统排期', (tester) async {
    final fixture = _AccountReminderFixture(cachedAccount: true);
    try {
      final stored = {10001: (date: DateTime(2026, 10, 6, 9), body: '缓存账号纪念日')};
      fixture.notifications.pending.addAll(stored);
      await tester.pumpAndSettle();
      expect(fixture.container.read(currentAccountIdProvider), 'account-a');
      expect(fixture.container.read(authSessionProvider), isNull);
      fixture.container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'restored-token',
              userId: 'account-a',
              deviceId: 'device',
            ),
            preserveIdentity: true,
          );
      await tester.pumpAndSettle();
      expect(
        fixture.container.read(dayReminderEventsProvider).isLoading,
        isTrue,
      );
      expect(fixture.notifications.pending, stored);
      expect(fixture.notifications.cancelled, isEmpty);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
  testWidgets('身份清理失败后前台恢复仍重试，新数据未就绪不能遗忘旧排期', (tester) async {
    final fixture = _AccountReminderFixture();
    try {
      await tester.pumpAndSettle();
      fixture.oldBooks.add(fixture.books);
      await tester.pumpAndSettle();
      fixture.notifications.cancellationsToFail = 1;
      fixture.changeAccount(null);
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isNotEmpty);
      expect(
        fixture.container.read(dayReminderEventsProvider).isLoading,
        isTrue,
      );
      await fixture.container.read(dayReminderLifecycleProvider)();
      expect(fixture.notifications.pending, isEmpty);
      expect(
        fixture.container.read(reminderSettingsProvider).daysActive,
        isTrue,
      );
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
  for (final readFails in [false, true]) {
    testWidgets('启动前身份已失效，首次订阅时数据${readFails ? '读取失败' : '加载中'}也清理原账号提醒', (
      tester,
    ) async {
      final fixture = _AccountReminderFixture(startLifecycle: false);
      try {
        fixture.notifications.pending[10001] = (
          date: DateTime(2026, 10, 6, 9),
          body: '已失效账号的纪念日',
        );
        fixture.changeAccount(null);
        fixture.container
            .read(accountReminderInvalidationProvider.notifier)
            .invalidateReminders();
        if (readFails) {
          fixture.container.read(dayBooksProvider);
          fixture.newBooks.addError(StateError('本机数据暂不可读'));
          await tester.pumpAndSettle();
        }

        fixture.subscribeLifecycle();
        await tester.pumpAndSettle();
        expect(fixture.notifications.pending, isEmpty);
        expect(fixture.notifications.cancelled, [10001]);
        expect(
          fixture.container
              .read(accountReminderInvalidationProvider)
              .isPending(AccountReminderKind.days),
          isFalse,
        );
        expect(
          fixture.container
              .read(accountReminderInvalidationProvider)
              .isPending(AccountReminderKind.fitness),
          isTrue,
          reason: '纪念日清理不能提前确认健身业务的待办',
        );
      } finally {
        await fixture.dispose();
        await tester.pump(const Duration(seconds: 3));
      }
    });
  }
  testWidgets('启动前失效的排期取消失败时保留待办，恢复前台成功后才确认', (tester) async {
    final fixture = _AccountReminderFixture(startLifecycle: false);
    try {
      fixture.notifications.pending[10001] = (
        date: DateTime(2026, 10, 6, 9),
        body: '已失效账号的纪念日',
      );
      fixture.notifications.cancellationsToFail = 1;
      fixture.changeAccount(null);
      fixture.container
          .read(accountReminderInvalidationProvider.notifier)
          .invalidateReminders();
      fixture.container.read(reminderSettingsProvider);
      await tester.pumpAndSettle();
      fixture.subscribeLifecycle();
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isNotEmpty);
      expect(
        fixture.container
            .read(accountReminderInvalidationProvider)
            .isPending(AccountReminderKind.days),
        isTrue,
      );

      await fixture.container.read(dayReminderLifecycleProvider)();
      expect(fixture.notifications.pending, isEmpty);
      expect(
        fixture.container
            .read(accountReminderInvalidationProvider)
            .isPending(AccountReminderKind.days),
        isFalse,
      );
      fixture.newBooks.add(fixture.books);
      await tester.pumpAndSettle();
      final current = Map<int, DayReminder>.of(fixture.notifications.pending);
      expect(current, isNotEmpty);
      final cancelled = fixture.notifications.cancelled.toList();

      // 重新装配监听器时，已消费的历史失效事件不能删除新身份的有效排期。
      fixture.container.invalidate(dayReminderLifecycleProvider);
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, current);
      expect(fixture.notifications.cancelled, cancelled);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
  testWidgets('首次订阅已有当前身份数据时，先清旧账号同日排期再登记有效计划', (tester) async {
    final fixture = _AccountReminderFixture(startLifecycle: false);
    ProviderSubscription<AsyncValue<List<DayEvent>>>? eventsSubscription;
    try {
      fixture.changeAccount(null);
      fixture.container
          .read(accountReminderInvalidationProvider.notifier)
          .invalidateReminders();
      eventsSubscription = fixture.container.listen(
        dayReminderEventsProvider,
        (_, _) {},
      );
      await tester.pumpAndSettle();
      fixture.newBooks.add(fixture.books);
      await tester.pumpAndSettle();
      expect(
        fixture.container.read(dayReminderEventsProvider).hasValue,
        isTrue,
      );
      final date = DateTime(2026, 10, 6, 9);
      final id =
          dayReminderIdStart + DateOnly.fromDateTime(date).dayNumber % 400;
      fixture.notifications.pending[id] = (date: date, body: '旧账号的同日纪念日');

      fixture.subscribeLifecycle();
      await tester.pumpAndSettle();
      expect(fixture.notifications.cancelled, [id]);
      expect(fixture.notifications.pending[id]?.body, contains('本机'));
      expect(
        fixture.container
            .read(accountReminderInvalidationProvider)
            .isPending(AccountReminderKind.days),
        isFalse,
      );
    } finally {
      eventsSubscription?.close();
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
}
