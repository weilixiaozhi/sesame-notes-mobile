import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';

/// 记账提醒监控服务
///
/// 功能：
/// 1. 监听应用生命周期
/// 2. 应用从后台恢复到前台时，检查提醒是否仍然有效
/// 3. 如果提醒丢失，自动重新设置
class ReminderMonitorService with WidgetsBindingObserver {
  static final ReminderMonitorService _instance =
      ReminderMonitorService._internal();
  factory ReminderMonitorService() => _instance;
  ReminderMonitorService._internal();

  DateTime? _lastCheckTime;
  static const _checkInterval = Duration(hours: 6); // 最多6小时检查一次
  ({String title, String body}) Function()? _textsProvider;

  /// 开始监控
  ///
  /// [textsProvider] 生成恢复提醒的通知文案（由 Composition Root 按当前
  /// 语言装配，本服务不反向依赖 BuildContext / l10n）；未注入时回退内置文案。
  void startMonitoring({
    ({String title, String body}) Function()? textsProvider,
  }) {
    _textsProvider = textsProvider;
    WidgetsBinding.instance.addObserver(this);
    logger.info('ReminderMonitor', '✅ 记账提醒监控服务已启动');
  }

  /// 停止监控
  void stopMonitoring() {
    WidgetsBinding.instance.removeObserver(this);
    logger.info('ReminderMonitor', '🛑 记账提醒监控服务已停止');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.info('ReminderMonitor', '📱 应用生命周期变化: $state');

    if (state == AppLifecycleState.resumed) {
      // 应用从后台恢复到前台
      _checkAndRestoreReminder();
    }
  }

  /// 检查并恢复提醒
  Future<void> _checkAndRestoreReminder() async {
    try {
      // 避免频繁检查
      if (_lastCheckTime != null &&
          DateTime.now().difference(_lastCheckTime!) < _checkInterval) {
        logger.info('ReminderMonitor', 'ℹ️  距离上次检查时间过短，跳过本次检查');
        return;
      }

      logger.info('ReminderMonitor', '🔍 开始检查记账提醒状态...');
      _lastCheckTime = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(ReminderPrefs.enabled) ?? false;

      if (!isEnabled) {
        logger.info('ReminderMonitor', 'ℹ️  用户未启用记账提醒');
        return;
      }

      // 检查是否有待处理的提醒
      final notificationUtil = NotificationFactory.getInstance();
      final pending = await notificationUtil.getPendingNotifications();
      final hasMainReminder = pending.any(
        (n) => n.id == ReminderPrefs.mainNotificationId,
      );

      if (!hasMainReminder) {
        logger.info('ReminderMonitor', '⚠️  警告：检测到记账提醒丢失，正在重新设置...');

        final hour = prefs.getInt(ReminderPrefs.hour) ?? 21;
        final minute = prefs.getInt(ReminderPrefs.minute) ?? 0;
        // 文案由 Composition Root 注入（跟随当前语言）；未注入时用内置兜底。
        final texts = _textsProvider?.call();
        final title = texts?.title ?? '记账提醒';
        final body = texts?.body ?? '记得记一笔今天的账哦';

        await notificationUtil.scheduleDailyReminder(
          id: ReminderPrefs.mainNotificationId,
          title: title,
          body: body,
          hour: hour,
          minute: minute,
        );

        logger.info('ReminderMonitor', '✅ 记账提醒已重新设置');
      } else {
        logger.info(
          'ReminderMonitor',
          '✅ 记账提醒状态正常 (待处理通知数: ${pending.length})',
        );
      }
    } catch (e) {
      logger.warning('ReminderMonitor', '❌ 检查提醒状态失败: $e');
    }
  }
}
