import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';

/// 记录调度参数的假通知实现：断言恢复提醒使用了注入文案。
class _RecordingNotificationUtil implements NotificationUtil {
  List<PendingNotificationRequest> pending = [];
  bool failSchedule = false;
  int scheduleAttempts = 0;
  int cancelCalls = 0;
  Completer<void>? scheduleGate;
  final List<({int id, String title, String body, int hour, int minute})>
  scheduled = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduleAttempts++;
    await scheduleGate?.future;
    if (failSchedule) throw StateError('模拟系统调度失败');
    scheduled.add((
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
    ));
  }

  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {
    cancelCalls++;
  }

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      pending;

  @override
  Future<bool> checkPermissionStatus() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ReminderMonitorService().configureTexts(
      textsProvider: () => (title: '记账提醒', body: '记一笔今日账目'),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('notification_channel'),
          (call) async => call.method == 'getTimeZone' ? 'Asia/Shanghai' : null,
        );
  });

  tearDown(() {
    ReminderMonitorService().clearTexts();
    NotificationFactory.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('notification_channel'),
          null,
        );
  });

  testWidgets('未配置文案持有者时恢复无副作用，不读取时区或创建任务', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);
    var zoneReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('notification_channel'), (
          call,
        ) async {
          if (call.method != 'getTimeZone') return null;
          zoneReads++;
          return 'Asia/Shanghai';
        });
    final service = ReminderMonitorService()..clearTexts();

    expect(await service.restoreReminder(), isFalse);
    expect(zoneReads, 0);
    expect(util.scheduled, isEmpty);
    expect(util.cancelCalls, 0);
  });

  testWidgets('不支持提醒的平台恢复无副作用，不读取原生时区', (tester) async {
    NotificationFactory.reset();
    var zoneReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('notification_channel'), (
          call,
        ) async {
          if (call.method != 'getTimeZone') return null;
          zoneReads++;
          return 'Asia/Shanghai';
        });

    expect(NotificationFactory.supportsReminders, isFalse);
    expect(await ReminderMonitorService().restoreReminder(), isFalse);
    expect(zoneReads, 0);
  });

  testWidgets('读取时区期间清除配置，旧恢复不读取文案或提交系统任务', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final zone = Completer<String>();
    var textReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('notification_channel'),
          (call) async => call.method == 'getTimeZone' ? zone.future : null,
        );
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService()
      ..configureTexts(
        textsProvider: () {
          textReads++;
          return (title: '原配置', body: '原文案');
        },
      );
    final restoring = service.restoreReminder();
    try {
      await tester.pumpAndSettle();
      service.clearTexts();
      zone.complete('Asia/Tokyo');

      expect(await restoring, isFalse);
      expect(textReads, 0);
      expect(util.scheduled, isEmpty);
      expect(util.cancelCalls, 0);
    } finally {
      if (!zone.isCompleted) zone.complete('Asia/Tokyo');
      await restoring;
      await tester.pump(const Duration(seconds: 3));
    }
  });

  testWidgets('重新配置后旧队列不接管新文案，只有新持有者恢复系统任务', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final firstZone = Completer<String>();
    var zoneReads = 0;
    var oldTextReads = 0;
    var newTextReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('notification_channel'), (
          call,
        ) async {
          if (call.method != 'getTimeZone') return null;
          zoneReads++;
          return zoneReads == 1 ? firstZone.future : 'Asia/Tokyo';
        });
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService()
      ..configureTexts(
        textsProvider: () {
          oldTextReads++;
          return (title: '原配置', body: '原文案');
        },
      );
    final inFlight = service.restoreReminder();
    final oldQueued = service.restoreReminder();
    await tester.pumpAndSettle();
    service.configureTexts(
      textsProvider: () {
        newTextReads++;
        return (title: '当前配置', body: '当前文案');
      },
    );
    final current = service.restoreReminder();
    try {
      firstZone.complete('Asia/Shanghai');
      expect(await Future.wait([inFlight, oldQueued, current]), [
        false,
        false,
        true,
      ]);
      expect(zoneReads, 2);
      expect(oldTextReads, 0);
      expect(newTextReads, 1);
      expect(util.scheduled, hasLength(1));
      expect(util.scheduled.single.title, '当前配置');
      expect(util.scheduled.single.body, '当前文案');
    } finally {
      if (!firstZone.isCompleted) firstZone.complete('Asia/Shanghai');
      await Future.wait([inFlight, oldQueued, current]);
      await tester.pump(const Duration(seconds: 3));
    }
  });

  testWidgets('恢复提醒时使用注入的文案回调生成 title/body', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
      ReminderPrefs.hour: 21,
      ReminderPrefs.minute: 0,
    });
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);

    final service = ReminderMonitorService();
    service.configureTexts(textsProvider: () => (title: '注入标题', body: '注入正文'));
    unawaited(service.restoreReminder());

    await tester.pumpAndSettle();
    expect(util.scheduled, hasLength(1));
    expect(util.scheduled.single.id, ReminderPrefs.mainNotificationId);
    expect(util.scheduled.single.title, '注入标题');
    expect(util.scheduled.single.body, '注入正文');

    // 消化 LoggerService 的 2 秒防抖落盘定时器，避免 teardown 报 pending timer
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('插件缓存仍有主提醒时也重新提交系统调度，且不先取消旧提醒', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final util = _RecordingNotificationUtil()
      ..pending = [
        PendingNotificationRequest(
          ReminderPrefs.mainNotificationId,
          '标题',
          '正文',
          null,
        ),
      ];
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService();

    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();

    expect(util.scheduled, hasLength(1));
    expect(util.cancelCalls, 0);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('从系统设置返回前台立即恢复，不受六小时节流限制', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService();

    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();
    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();

    expect(util.scheduled, hasLength(2));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('系统调度失败后下次恢复前台可以重试', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    final util = _RecordingNotificationUtil()..failSchedule = true;
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService();

    await expectLater(service.restoreReminder(), throwsStateError);
    await tester.pumpAndSettle();
    util.failSchedule = false;
    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();

    expect(util.scheduleAttempts, 2);
    expect(util.scheduled, hasLength(1));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('未开启提醒时恢复前台不创建系统通知任务', (tester) async {
    SharedPreferences.setMockInitialValues({ReminderPrefs.enabled: false});
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService();

    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();

    expect(util.scheduled, isEmpty);
    await tester.pump(const Duration(seconds: 3));
  });

  for (final invalidZone in [false, true]) {
    testWidgets('设备时区${invalidZone ? '标识无效' : '读取失败'}保留旧规则和系统任务，随后成功可恢复', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        ReminderPrefs.notificationsEnabled: true,
        ReminderPrefs.enabled: true,
      });
      final util = _RecordingNotificationUtil();
      NotificationFactory.setInstanceForTesting(util);
      final service = ReminderMonitorService();
      await service.restoreReminder();
      expect(tz.local.name, 'Asia/Shanghai');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async {
              if (call.method != 'getTimeZone') return null;
              if (invalidZone) return 'Invalid/Zone';
              throw PlatformException(code: 'timezone_unavailable');
            },
          );
      await expectLater(service.restoreReminder(), throwsA(anything));

      expect(tz.local.name, 'Asia/Shanghai');
      expect(util.scheduled, hasLength(1));
      expect(util.cancelCalls, 0);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async => call.method == 'getTimeZone' ? 'Asia/Tokyo' : null,
          );
      // 新调度读取不得缓存上次失败，操作队列也必须允许后继恢复。
      await NotificationFactory.ensureTimeZone();
      await service.restoreReminder();
      expect(tz.local.name, 'Asia/Tokyo');
      expect(util.scheduled, hasLength(2));
      await tester.pump(const Duration(seconds: 3));
    });
  }

  for (final fixed in [
    (name: 'GMT+05:45', minutes: 345),
    (name: 'GMT-03:30', minutes: -210),
  ]) {
    testWidgets('设备明确固定时区${fixed.name}按声明的半小时或45分钟偏移正常排期', (tester) async {
      SharedPreferences.setMockInitialValues({
        ReminderPrefs.notificationsEnabled: true,
        ReminderPrefs.enabled: true,
        ReminderPrefs.hour: 21,
        ReminderPrefs.minute: 15,
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            (call) async => call.method == 'getTimeZone' ? fixed.name : null,
          );
      final util = _RecordingNotificationUtil();
      NotificationFactory.setInstanceForTesting(util);

      expect(await ReminderMonitorService().restoreReminder(), isTrue);
      expect(tz.local.name, fixed.name);
      final scheduled = calculateNextReminderTime(
        21,
        15,
        now: DateTime.utc(2026, 10, 19, 10),
      );
      expect((scheduled.hour, scheduled.minute), (21, 15));
      expect(scheduled.timeZoneOffset, Duration(minutes: fixed.minutes));
      expect(util.scheduled, hasLength(1));
      expect(
        (util.scheduled.single.hour, util.scheduled.single.minute),
        (21, 15),
      );
      await tester.pump(const Duration(seconds: 3));
    });
  }

  testWidgets('关闭提醒期间修改系统时区，返回前台后再次开启应使用新时区', (tester) async {
    SharedPreferences.setMockInitialValues({ReminderPrefs.enabled: false});
    NotificationFactory.setInstanceForTesting(_RecordingNotificationUtil());
    tz.setLocalLocation(tz.UTC);
    final service = ReminderMonitorService();

    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();

    expect(tz.local.name, 'Asia/Shanghai');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('并发时区刷新串行读取系统，调度等待最新缓存且周期记账仍按规则时区', (tester) async {
    final firstRead = Completer<String>();
    var reads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('notification_channel'), (
          call,
        ) async {
          if (call.method != 'getTimeZone') return null;
          reads++;
          return reads == 1 ? firstRead.future : 'Asia/Tokyo';
        });
    final first = NotificationFactory.initializeTimeZone();
    final latest = NotificationFactory.initializeTimeZone();
    final scheduleReady = NotificationFactory.ensureTimeZone();
    try {
      await tester.pumpAndSettle();
      expect(reads, 1);
      expect(identical(scheduleReady, latest), isTrue);
      firstRead.complete('America/New_York');
      await first;
      await scheduleReady;

      expect(reads, 2);
      expect(tz.local.name, 'Asia/Tokyo');
      final instant = DateTime.utc(2024, 3, 10, 1);
      expect(
        recurringToday('America/New_York', instant),
        DateTime.utc(2024, 3, 9),
      );
      expect(
        recurringOccurrenceInstant(
          DateTime.utc(2024, 3, 11),
          'America/New_York',
        ),
        DateTime.utc(2024, 3, 11, 4),
      );
      expect(tz.local.name, 'Asia/Tokyo');
    } finally {
      if (!firstRead.isCompleted) firstRead.complete('America/New_York');
      await latest;
      await tester.pump(const Duration(seconds: 3));
    }
  });

  testWidgets('同时触发的恢复按顺序读取和调度，避免旧配置覆盖新配置', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
      ReminderPrefs.hour: 21,
    });
    final gate = Completer<void>();
    final util = _RecordingNotificationUtil()..scheduleGate = gate;
    NotificationFactory.setInstanceForTesting(util);
    final service = ReminderMonitorService();

    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();
    unawaited(service.restoreReminder());
    await tester.pumpAndSettle();
    final attemptsWhilePending = util.scheduleAttempts;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ReminderPrefs.hour, 22);
    gate.complete();
    await tester.pumpAndSettle();

    expect(attemptsWhilePending, 1);
    expect(util.scheduled.map((call) => call.hour), [21, 22]);
    await tester.pump(const Duration(seconds: 3));
  });
}
