import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';

/// 记账提醒恢复服务
///
/// 功能：
/// 应用装配层在启动、恢复前台和系统时钟变化时调用，按已保存设置重新提交系统调度。
class ReminderMonitorService {
  static final ReminderMonitorService _instance =
      ReminderMonitorService._internal();
  factory ReminderMonitorService() => _instance;
  ReminderMonitorService._internal();

  ({String title, String body}) Function()? _textsProvider;

  /// 主提醒的操作队列，确保用户设置与生命周期恢复按顺序读写同一个系统任务。
  Future<void>? _pendingUpdate;

  /// 串行执行主提醒事务；失败仍传给调用方，并释放队列供后续操作重试。
  Future<T> runUpdate<T>(Future<T> Function() action) async {
    final previous = _pendingUpdate;
    final completed = Completer<void>();
    _pendingUpdate = completed.future;
    try {
      await previous;
      return await action();
    } finally {
      completed.complete();
      if (identical(_pendingUpdate, completed.future)) _pendingUpdate = null;
    }
  }

  /// 注入当前语言的提醒文案。
  ///
  /// [textsProvider] 生成恢复提醒的通知文案（由 Composition Root 按当前
  /// 语言装配，本服务不反向依赖 BuildContext / l10n）。
  void configureTexts({
    required ({String title, String body}) Function() textsProvider,
  }) {
    _textsProvider = textsProvider;
  }

  /// 应用容器释放后清除持有的本地化读取回调。
  void clearTexts() {
    _textsProvider = null;
  }

  /// 返回配置持有者与当地时区上下文是否仍有效，供装配层决定是否继续恢复纪念日。
  /// 无持有者或身份失效时不触碰系统任务；主提醒关闭仍返回 true，不改变用户开关。
  Future<bool> restoreReminder() {
    if (!NotificationFactory.supportsReminders) return Future.value(false);
    final textsProvider = _textsProvider;
    if (textsProvider == null) return Future.value(false);
    return runUpdate(() => _restoreReminder(textsProvider));
  }

  /// 在主提醒队列中读取最新配置，避免覆盖用户正在保存的新设置。
  Future<bool> _restoreReminder(
    ({String title, String body}) Function() textsProvider,
  ) async {
    if (!identical(_textsProvider, textsProvider)) return false;
    logger.info('ReminderMonitor', '🔍 开始检查记账提醒状态...');

    // 即使提醒关闭也刷新时区，确保之后首次开启使用设备当前的当地时间。
    await NotificationFactory.initializeTimeZone();
    if (!identical(_textsProvider, textsProvider)) return false;
    final prefs = await SharedPreferences.getInstance();
    // 两次外部读取都可能跨越容器清理或重新配置，回调只允许由原持有者读取。
    if (!identical(_textsProvider, textsProvider)) return false;
    final isEnabled =
        (prefs.getBool(ReminderPrefs.notificationsEnabled) ?? false) &&
        (prefs.getBool(ReminderPrefs.enabled) ?? false);

    if (!isEnabled) {
      logger.info('ReminderMonitor', 'ℹ️  用户未启用记账提醒');
      return true;
    }

    final notificationUtil = NotificationFactory.getInstance();
    final hour = prefs.getInt(ReminderPrefs.hour) ?? 21;
    final minute = prefs.getInt(ReminderPrefs.minute) ?? 0;
    final texts = textsProvider();

    // 插件的待处理列表是持久化缓存，无法证明系统闹钟仍在；同 ID 覆盖调度，
    // 不预先取消，避免新的系统调度失败时主动清掉旧提醒。
    await notificationUtil.scheduleDailyReminder(
      id: ReminderPrefs.mainNotificationId,
      title: texts.title,
      body: texts.body,
      hour: hour,
      minute: minute,
    );

    logger.info('ReminderMonitor', '✅ 记账提醒已重新设置');
    return identical(_textsProvider, textsProvider);
  }
}
