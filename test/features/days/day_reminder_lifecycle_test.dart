import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
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

  /// 账号 A 先建立真实身份，随后通过会话入口执行退出或换号。
  _AccountReminderFixture({
    bool holdScheduling = false,
    bool startLifecycle = true,
    Stream<void>? clockEvents,
  }) {
    ReminderMonitorService().configureTexts(
      textsProvider: () => (title: '记账提醒', body: '记一笔今日账目'),
    );
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: false,
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
    changeAccount('account-a');
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

/// 失效身份的旧通知必须清理成功，迟到回执不能重新登记旧账号内容。
void main() {
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
