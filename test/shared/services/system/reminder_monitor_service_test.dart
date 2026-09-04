// 提醒监控服务测试。
//
// 需求锚点：监控服务只负责时钟与调度，通知文案由 Composition Root
// 经回调注入（service 不得反向依赖 BuildContext / l10n）；恢复提醒时
// 必须使用注入文案回调生成的 title/body。
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';

/// 记录调度参数的假通知实现：断言恢复提醒使用了注入文案。
class _RecordingNotificationUtil implements NotificationUtil {
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
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      [];

  @override
  Future<bool> checkPermissionStatus() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('恢复提醒时使用注入的文案回调生成 title/body', (tester) async {
    SharedPreferences.setMockInitialValues({
      ReminderPrefs.enabled: true,
      ReminderPrefs.hour: 21,
      ReminderPrefs.minute: 0,
    });
    final util = _RecordingNotificationUtil();
    NotificationFactory.setInstanceForTesting(util);

    final service = ReminderMonitorService();
    service.startMonitoring(textsProvider: () => (title: '注入标题', body: '注入正文'));
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);

    await tester.pumpAndSettle();
    expect(util.scheduled, hasLength(1));
    expect(util.scheduled.single.id, ReminderPrefs.mainNotificationId);
    expect(util.scheduled.single.title, '注入标题');
    expect(util.scheduled.single.body, '注入正文');

    // 消化 LoggerService 的 2 秒防抖落盘定时器，避免 teardown 报 pending timer
    await tester.pump(const Duration(seconds: 3));
  });
}
