import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// 通知工具类 - 平台无关的通知抽象层
///
/// 提供统一的通知接口，屏蔽平台差异
abstract class NotificationUtil {
  Future<void> initialize();

  /// 请求通知权限
  Future<bool> requestPermissions();

  /// 调度每日重复提醒
  ///
  /// [id] 通知ID
  /// [title] 通知标题
  /// [body] 通知内容
  /// [hour] 小时 (0-23)
  /// [minute] 分钟 (0-59)
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  /// 调度单次提醒
  ///
  /// [id] 通知ID
  /// [title] 通知标题
  /// [body] 通知内容
  /// [scheduledDate] 调度时间
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// 取消指定通知
  Future<void> cancelNotification(int id);

  /// 取消所有通知
  Future<void> cancelAllNotifications();

  Future<List<PendingNotificationRequest>> getPendingNotifications();

  /// 检查通知权限状态
  Future<bool> checkPermissionStatus();
}

/// 计算下一次提醒时间
///
/// 如果指定时间已过，按当地日历取明天，避免夏令时切换导致钟面时间偏移。
DateTime calculateNextReminderTime(int hour, int minute, {DateTime? now}) {
  final localNow = tz.TZDateTime.from(now ?? DateTime.now(), tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    localNow.year,
    localNow.month,
    localNow.day,
    hour,
    minute,
  );

  if (!scheduledDate.isAfter(localNow)) {
    scheduledDate = tz.TZDateTime(
      tz.local,
      localNow.year,
      localNow.month,
      localNow.day + 1,
      hour,
      minute,
    );
  }

  return scheduledDate;
}

/// 转换为本地时区并保留原时间点，包括 UTC 输入和毫秒精度。
tz.TZDateTime convertToTZDateTime(DateTime dateTime) {
  return tz.TZDateTime.from(dateTime, tz.local);
}
