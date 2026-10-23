import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';

class _FailingPreferences extends Fake implements SharedPreferences {
  final SharedPreferences delegate;
  bool failNextWrite = false;
  bool failSelectionWrite = false;

  _FailingPreferences(this.delegate);

  /// 读取已有的提醒启用状态。
  @override
  bool? getBool(String key) => delegate.getBool(key);

  /// 读取已有的提醒时间。
  @override
  int? getInt(String key) => delegate.getInt(key);

  /// 读取每日纪念日选择，保留真实偏好存储的列表行为。
  @override
  List<String>? getStringList(String key) => delegate.getStringList(key);

  /// 模拟一次磁盘写入失败，后续写入可用于恢复原设置。
  @override
  Future<bool> setBool(String key, bool value) async {
    if (failNextWrite) {
      failNextWrite = false;
      return false;
    }
    return delegate.setBool(key, value);
  }

  /// 将时间字段保存到当前测试的偏好存储。
  @override
  Future<bool> setInt(String key, int value) => delegate.setInt(key, value);

  /// 在其余字段已保存后模拟多选写入失败，验证整包设置能够回滚。
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    if (failSelectionWrite && key == ReminderPrefs.daysDailyEventIds) {
      failSelectionWrite = false;
      return false;
    }
    return delegate.setStringList(key, value);
  }
}

class _FakeNotificationUtil extends Fake implements NotificationUtil {
  int requestCount = 0;
  bool permissionGranted = true;
  bool failSchedule = false;
  bool failCancel = false;
  int? failScheduleCall;
  int scheduleCalls = 0;
  Future<void>? scheduling;
  Completer<void>? scheduleStarted;
  final scheduled = <String>[];
  final cancelled = <int>[];
  final pending = <int, String>{};

  /// 返回当前测试配置的系统授权结果。
  @override
  Future<bool> requestPermissions() async {
    requestCount++;
    return permissionGranted;
  }

  /// 用相同通知标识替换任务，调度失败时保留已注册的任务。
  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduleCalls++;
    if (failSchedule || scheduleCalls == failScheduleCall) {
      throw StateError('系统调度失败');
    }
    final waiting = scheduling;
    scheduling = null;
    if (scheduleStarted?.isCompleted == false) scheduleStarted!.complete();
    await waiting;
    scheduled.add('$id:$hour:$minute');
    pending[id] = '$hour:$minute';
  }

  /// 取消成功后才移除系统中的任务。
  @override
  Future<void> cancelNotification(int id) async {
    if (failCancel) throw StateError('系统取消失败');
    cancelled.add(id);
    pending.remove(id);
  }
}

/// 等待真实偏好加载完成，再从完整配置构造本次用户修改。
Future<ReminderSettings> _loadedSettings(ProviderContainer container) async {
  final ready = Completer<ReminderSettings>();
  final subscription = container.listen<ReminderSettings>(
    reminderSettingsProvider,
    (_, next) {
      if (next.isLoaded && !ready.isCompleted) ready.complete(next);
    },
    fireImmediately: true,
  );
  try {
    return await ready.future.timeout(const Duration(seconds: 5));
  } catch (error, stack) {
    logger.error('ReminderSettingsTest', '等待提醒设置加载失败', error, stack);
    rethrow;
  } finally {
    subscription.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeNotificationUtil notifications;

  setUp(() {
    resetGlobalTestState();
    // 既有调度测试显式模拟用户已经开启总开关。
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
    });
    notifications = _FakeNotificationUtil();
    NotificationFactory.setInstanceForTesting(notifications);
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

  test('不支持提醒的平台拒绝提交且保留偏好和已确认配置', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [reminderSupportedProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);
    final previous = await _loadedSettings(container);

    await expectLater(
      container
          .read(reminderSettingsProvider.notifier)
          .updateSettings(previous.copyWith(notificationsEnabled: true)),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'notification_unsupported',
        ),
      ),
    );

    expect(container.read(reminderSettingsProvider), previous);
    expect(notifications.requestCount, 0);
    expect(notifications.scheduled, isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(ReminderPrefs.notificationsEnabled), isNull);
  });

  test('全新安装通知默认关闭，加载和恢复均不申请权限或调度', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(reminderSettingsProvider).notificationsEnabled,
      isFalse,
    );
    await _loadedSettings(container);
    final settings = container.read(reminderSettingsProvider);
    expect(settings.isLoaded, isTrue);
    expect(settings.notificationsEnabled, isFalse);
    expect(settings.dailyActive, isFalse);
    expect(settings.daysActive, isFalse);
    expect(settings.daysDailyEnabled, isFalse);
    expect(settings.daysDailyEventIds, isEmpty);
    expect(settings.restActive, isFalse);
    await ReminderMonitorService().restoreReminder();
    expect(notifications.requestCount, 0);
    expect(notifications.scheduled, isEmpty);
    await container
        .read(reminderSettingsProvider.notifier)
        .updateSettings(settings.copyWith(notificationsEnabled: true));
    expect(notifications.requestCount, 1);
    expect(
      container.read(reminderSettingsProvider).notificationsEnabled,
      isTrue,
    );
  });

  test('只有分类开关开启时，缺失的通知总开关仍为关闭', () async {
    SharedPreferences.setMockInitialValues({ReminderPrefs.enabled: true});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _loadedSettings(container);
    final settings = container.read(reminderSettingsProvider);
    expect(settings.notificationsEnabled, isFalse);
    expect(settings.isEnabled, isTrue);
    expect(settings.dailyActive, isFalse);
    await ReminderMonitorService().restoreReminder();
    expect(notifications.requestCount, 0);
    expect(notifications.scheduled, isEmpty);
  });

  test('总开关关闭后恢复分类配置与时间', () async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
      ReminderPrefs.hour: 8,
      ReminderPrefs.minute: 30,
      ReminderPrefs.daysEnabled: true,
      ReminderPrefs.daysOffsets: 129,
    });
    NotificationFactory.setDaysInstanceForTesting(notifications);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    // 从完整配置构造修改，保持已保存的总开关和分类选项。
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(hour: 7, minute: 45),
    );
    final previous = container.read(reminderSettingsProvider);
    expect(previous.notificationsEnabled, isTrue);
    expect(previous.isEnabled, isTrue);
    expect(previous.selectedDayOffsets, [0, 7]);
    await notifier.updateSettings(
      previous.copyWith(notificationsEnabled: false),
    );
    var settings = container.read(reminderSettingsProvider);
    expect(settings.isEnabled, isTrue);
    expect(settings.daysEnabled, isTrue);
    expect(settings.dailyActive, isFalse);
    expect(settings.daysActive, isFalse);
    expect(settings.restActive, isFalse);
    expect(notifications.pending[ReminderPrefs.mainNotificationId], isNull);
    await ReminderMonitorService().restoreReminder();
    expect(notifications.pending[ReminderPrefs.mainNotificationId], isNull);
    await notifier.updateSettings(
      settings.copyWith(notificationsEnabled: true),
    );
    settings = container.read(reminderSettingsProvider);
    expect(settings.dailyActive, isTrue);
    expect(settings.daysActive, isTrue);
    expect(notifications.pending[ReminderPrefs.mainNotificationId], '7:45');
    expect(settings.selectedDayOffsets, [0, 7]);
  });

  test('纪念日权限拒绝不保存开启，非法时点或空多选被拒绝', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await _loadedSettings(container);
    NotificationFactory.setDaysInstanceForTesting(notifications);
    notifications.permissionGranted = false;
    final previous = container.read(reminderSettingsProvider);
    await expectLater(
      notifier.updateSettings(previous.copyWith(daysEnabled: true)),
      throwsA(isA<PlatformException>()),
    );
    expect(container.read(reminderSettingsProvider), previous);
    for (final settings in [
      previous.copyWith(daysOffsets: 0),
      previous.copyWith(daysOffsets: 4),
      previous.copyWith(daysHour: 24),
      previous.copyWith(daysMinute: -1),
      previous.copyWith(daysDailyEnabled: true),
    ]) {
      await expectLater(notifier.updateSettings(settings), throwsArgumentError);
    }
    expect(container.read(reminderSettingsProvider), previous);
  });

  test('分类配置持久化，磁盘失败不留下部分更新的全局开关', () async {
    final prefs = await SharedPreferences.getInstance();
    final failing = _FailingPreferences(prefs);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => failing),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await _loadedSettings(container);
    final settings = container
        .read(reminderSettingsProvider)
        .copyWith(
          notificationsEnabled: false,
          daysEnabled: true,
          daysHour: 10,
          daysMinute: 25,
          daysOffsets: 139,
          daysDailyEnabled: true,
          daysDailyEventIds: {'second-event', 'first-event'},
          restEnabled: false,
        );
    await notifier.updateSettings(settings);
    final restored = ProviderContainer();
    addTearDown(restored.dispose);
    expect(await _loadedSettings(restored), settings);
    failing.failNextWrite = true;
    await expectLater(
      notifier.updateSettings(settings.copyWith(daysHour: 11)),
      throwsStateError,
    );
    expect(prefs.getInt(ReminderPrefs.daysHour), 10);
    expect(container.read(reminderSettingsProvider), settings);
  });

  test('每日多选保存失败恢复已写入的开关、时间和原选项', () async {
    final prefs = await SharedPreferences.getInstance();
    final failing = _FailingPreferences(prefs);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => failing),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await _loadedSettings(container);
    final previous = container
        .read(reminderSettingsProvider)
        .copyWith(daysDailyEventIds: {'existing-event'});
    await notifier.updateSettings(previous);
    failing.failSelectionWrite = true;
    await expectLater(
      notifier.updateSettings(
        previous.copyWith(
          daysDailyEnabled: true,
          daysDailyEventIds: {'new-event'},
          daysHour: 12,
        ),
      ),
      throwsStateError,
    );
    expect(container.read(reminderSettingsProvider), previous);
    expect(prefs.getBool(ReminderPrefs.daysDailyEnabled), isFalse);
    expect(prefs.getStringList(ReminderPrefs.daysDailyEventIds), [
      'existing-event',
    ]);
    expect(prefs.getInt(ReminderPrefs.daysHour), previous.daysHour);
  });

  test('每日多选按集合比较，编辑源集合不会改变已发布配置', () {
    const initial = ReminderSettings(isEnabled: false, hour: 21, minute: 0);
    final selection = {'first', 'second'};
    final selected = initial.copyWith(
      daysDailyEnabled: true,
      daysDailyEventIds: selection,
    );
    final reordered = initial.copyWith(
      daysDailyEnabled: true,
      daysDailyEventIds: {'second', 'first'},
    );
    expect(selected, reordered);
    expect(selected.hashCode, reordered.hashCode);
    selection.clear();
    expect(selected.daysDailyEventIds, {'first', 'second'});
    expect(selected.copyWith(daysDailyEventIds: {'first'}), isNot(selected));
    expect(selected.copyWith(daysDailyEnabled: false), isNot(selected));
    expect(selected.copyWith(daysDailyEnabled: false).daysDailyEventIds, {
      'first',
      'second',
    });
  });

  test('从 prefs 恢复设置', () async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
      ReminderPrefs.hour: 8,
      ReminderPrefs.minute: 30,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(reminderSettingsProvider).isEnabled,
      isFalse,
      reason: '先同步返回默认值',
    );
    final settings = await _loadedSettings(container);
    expect(settings.isEnabled, isTrue);
    expect(settings.hour, 8);
    expect(settings.minute, 30);
  });

  test('完整设置开启分类时请求权限并调度，关闭时取消', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);

    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    expect(notifications.requestCount, 1);
    expect(notifications.scheduled.single, contains('21:0'));

    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: false),
    );
    expect(notifications.cancelled, [ReminderPrefs.mainNotificationId]);
  });

  test('完整设置保存提醒时间并在开启时重排通知', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);

    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(hour: 8, minute: 30),
    );
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReminderPrefs.hour), 8);
    expect(notifications.cancelled, isEmpty, reason: '未开启时只保存时间');

    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(hour: 9, minute: 15),
    );
    expect(notifications.scheduled.last, contains('9:15'));
  });

  test('完整设置在偏好加载完成后整包应用', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);

    await notifier.updateSettings(
      const ReminderSettings(
        isEnabled: true,
        notificationsEnabled: true,
        hour: 7,
        minute: 45,
      ),
    );
    expect(container.read(reminderSettingsProvider).timeString, '07:45');
    expect(notifications.scheduled.single, contains('7:45'));
  });

  test('完整设置申请通知权限被拒时保持原配置、不调度也不持久化', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    final previous = await _loadedSettings(container);
    notifications.permissionGranted = false;

    await expectLater(
      notifier.updateSettings(
        previous.copyWith(isEnabled: true, hour: 7, minute: 45),
      ),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'notification_permission_denied',
        ),
      ),
    );

    expect(container.read(reminderSettingsProvider), previous);
    expect(notifications.scheduled, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ReminderPrefs.enabled) ?? false, isFalse);
  });

  test('开启时调度失败不显示或持久化为已启用', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    notifications.failSchedule = true;

    await expectLater(
      notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(isEnabled: true),
      ),
      throwsStateError,
    );

    expect(container.read(reminderSettingsProvider).isEnabled, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ReminderPrefs.enabled) ?? false, isFalse);
  });

  test('修改时间调度失败时保留原来的提醒和设置', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    notifications.failSchedule = true;

    await expectLater(
      notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(hour: 8, minute: 30),
      ),
      throwsStateError,
    );

    expect(container.read(reminderSettingsProvider).timeString, '21:00');
    expect(notifications.pending[ReminderPrefs.mainNotificationId], '21:0');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReminderPrefs.hour), 21);
    expect(prefs.getInt(ReminderPrefs.minute), 0);
  });

  test('关闭时取消失败保持已启用，允许用户重试', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    notifications.failCancel = true;

    await expectLater(
      notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(isEnabled: false),
      ),
      throwsStateError,
    );

    expect(container.read(reminderSettingsProvider).isEnabled, isTrue);
    expect(notifications.pending[ReminderPrefs.mainNotificationId], '21:0');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ReminderPrefs.enabled), isTrue);
  });

  test('时间保存失败时恢复原来的系统任务和持久化设置', () async {
    final prefs = await SharedPreferences.getInstance();
    final failingPrefs = _FailingPreferences(prefs);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => failingPrefs),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    failingPrefs.failNextWrite = true;

    await expectLater(
      notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(hour: 8, minute: 30),
      ),
      throwsStateError,
    );

    expect(container.read(reminderSettingsProvider).timeString, '21:00');
    expect(notifications.pending[ReminderPrefs.mainNotificationId], '21:0');
    expect(prefs.getInt(ReminderPrefs.hour), 21);
    expect(prefs.getInt(ReminderPrefs.minute), 0);
    expect(prefs.getBool(ReminderPrefs.enabled), isTrue);
  });

  test('时间保存失败且通知恢复失败时仍恢复持久化设置', () async {
    final prefs = await SharedPreferences.getInstance();
    final failingPrefs = _FailingPreferences(prefs);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => failingPrefs),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    await notifier.updateSettings(
      (await _loadedSettings(container)).copyWith(isEnabled: true),
    );
    failingPrefs.failNextWrite = true;
    notifications.failScheduleCall = 3;

    await expectLater(
      notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(hour: 8, minute: 30),
      ),
      throwsStateError,
    );

    expect(container.read(reminderSettingsProvider).timeString, '21:00');
    expect(prefs.getInt(ReminderPrefs.hour), 21);
    expect(prefs.getInt(ReminderPrefs.minute), 0);
    expect(prefs.getBool(ReminderPrefs.enabled), isTrue);
  });

  for (final disable in [false, true]) {
    test('前台恢复与设置更新并发时以用户新配置为准，关闭=$disable', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(reminderSettingsProvider.notifier);
      await notifier.updateSettings(
        (await _loadedSettings(container)).copyWith(isEnabled: true),
      );
      final gate = Completer<void>();
      notifications.scheduling = gate.future;
      notifications.scheduleStarted = Completer<void>();

      final restoring = ReminderMonitorService().restoreReminder();
      await notifications.scheduleStarted!.future;
      final updating = disable
          ? notifier.updateSettings(
              (await _loadedSettings(container)).copyWith(isEnabled: false),
            )
          : notifier.updateSettings(
              (await _loadedSettings(container)).copyWith(hour: 8, minute: 30),
            );
      gate.complete();
      await Future.wait([restoring, updating]);

      expect(container.read(reminderSettingsProvider).isEnabled, !disable);
      expect(
        notifications.pending[ReminderPrefs.mainNotificationId],
        disable ? isNull : '8:30',
      );
    });
  }

  test('连续启用和修改时间保留先前更新的开关状态', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reminderSettingsProvider.notifier);
    final loaded = await _loadedSettings(container);
    final enabledIntent = loaded.copyWith(isEnabled: true);
    final gate = Completer<void>();
    notifications.scheduling = gate.future;
    notifications.scheduleStarted = Completer<void>();

    final enabling = notifier.updateSettings(enabledIntent);
    await notifications.scheduleStarted!.future;
    // 后续意图明确保留正在提交的启用选择，不读取尚未更新的界面状态。
    final updating = notifier.updateSettings(
      enabledIntent.copyWith(hour: 8, minute: 30),
    );
    gate.complete();
    await Future.wait([enabling, updating]);

    final settings = container.read(reminderSettingsProvider);
    expect(settings.isEnabled, isTrue);
    expect(settings.timeString, '08:30');
    expect(notifications.pending[ReminderPrefs.mainNotificationId], '8:30');
    expect(notifications.requestCount, 1);
    expect(notifications.scheduled, [
      '${ReminderPrefs.mainNotificationId}:21:0',
      '${ReminderPrefs.mainNotificationId}:8:30',
    ]);
  });
}
