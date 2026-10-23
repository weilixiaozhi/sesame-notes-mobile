/// 记账提醒相关持久化键与通知 ID 的统一常量。
///
/// 设计意图：providers / main / 提醒监控服务多处读写同一组
/// prefs 键与通知 ID。集中定义后所有调用方引用同一常量，键值字符串只
/// 在这里出现一次。
class ReminderPrefs {
  const ReminderPrefs._();

  /// 通知总开关与分类设置只作用于当前设备。
  static const notificationsEnabled = 'notifications_enabled';
  static const restEnabled = 'rest_reminder_enabled';
  static const daysEnabled = 'days_reminder_enabled';
  static const daysHour = 'days_reminder_hour';
  static const daysMinute = 'days_reminder_minute';
  static const daysOffsets = 'days_reminder_offsets';
  static const daysDailyEnabled = 'days_reminder_daily_enabled';
  static const daysDailyEventIds = 'days_reminder_daily_event_ids';

  /// 每日记账开关键。
  static const String enabled = 'reminder_enabled';

  /// 提醒小时键（0-23）。
  static const String hour = 'reminder_hour';

  /// 提醒分钟键（0-59）。
  static const String minute = 'reminder_minute';

  /// 每日记账提醒独立使用此编号，取消和重建不会影响其他提醒分类。
  static const int mainNotificationId = 1001;
}

/// 健身同一时间仅有一个休息计时，重设复用通知 ID，不影响每日记账提醒。
const fitnessRestNotificationId = 2001;
