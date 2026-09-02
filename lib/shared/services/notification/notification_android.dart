import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'notification_util.dart' as util;

/// Android 特定的通知实现
class AndroidNotificationUtil implements util.NotificationUtil {
  final FlutterLocalNotificationsPlugin _plugin;
  final MethodChannel _channel = const MethodChannel('notification_channel');
  bool _initialized = false;

  AndroidNotificationUtil(this._plugin);

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    // initialize 使用命名参数
    await _plugin.initialize(settings: initSettings);

    // 不在初始化阶段自动请求通知权限，避免应用首次安装启动即弹出系统权限弹窗。
    // 通知权限延迟到用户主动开启记账提醒时再请求（见 ReminderSettingsNotifier）。
    _initialized = true;

    logger.info('AndroidNotification', '[Android] 通知服务初始化完成');
  }

  @override
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return false;

    // 请求基础通知权限
    final granted = await androidPlugin.requestNotificationsPermission();
    logger.info('AndroidNotification', '[Android] 基础通知权限: ${granted ?? false}');

    // 请求精确闹钟权限 (Android 12+)
    try {
      await androidPlugin.requestExactAlarmsPermission();
      final canScheduleExact = await androidPlugin
          .canScheduleExactNotifications();
      logger.info(
        'AndroidNotification',
        '[Android] 精确闹钟权限: ${canScheduleExact ?? false}',
      );
    } catch (e) {
      logger.warning('AndroidNotification', '[Android] 请求精确闹钟权限失败: $e');
    }

    return granted ?? false;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    final scheduledDate = util.calculateNextReminderTime(hour, minute);
    final tzScheduledDate = util.convertToTZDateTime(scheduledDate);

    final androidDetails = _androidDetails(
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      autoCancel: false,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      // 插件负责持久化并在设备重启后恢复每日提醒，单一重复任务可避免多套
      // 调度器在同一时间发送重复通知。
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // 每天重复
      );

      logger.info('AndroidNotification', '[Android] 每日提醒设置成功: $hour:$minute');
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 每日提醒设置失败', e, st);
      rethrow;
    }
  }

  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await initialize();

    final tzScheduledDate = util.convertToTZDateTime(scheduledDate);

    final androidDetails = _androidDetails(
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    logger.info('AndroidNotification', '[Android] 单次提醒设置成功: $scheduledDate');
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (!_initialized) await initialize();

    await _plugin.cancel(id: id);
    logger.info('AndroidNotification', '[Android] 提醒已取消: $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
    logger.info('AndroidNotification', '[Android] 所有通知已取消');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = _androidDetails();

    final notificationDetails = NotificationDetails(android: androidDetails);

    // show 使用命名参数
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
    logger.info('AndroidNotification', '[Android] 即时通知已显示: $title');
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _plugin.pendingNotificationRequests();
  }

  @override
  Future<bool> checkPermissionStatus() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return false;

    final enabled = await androidPlugin.areNotificationsEnabled();
    return enabled ?? false;
  }

  /// 通知详情统一出口：每日提醒、单次提醒和即时通知共用同一基础配置，
  /// 仅差异字段（渠道信息、类别、可见性、autoCancel）在此定制，
  /// 默认值与插件构造参数默认值保持一致，避免各处配置漂移。
  AndroidNotificationDetails _androidDetails({
    String channelId = 'accounting_reminder',
    String channelName = '记账提醒',
    String channelDescription = '每日记账提醒',
    AndroidNotificationCategory? category,
    NotificationVisibility? visibility,
    bool autoCancel = true,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      ticker: '记账提醒',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      enableLights: true,
      category: category,
      visibility: visibility,
      autoCancel: autoCancel,
    );
  }

  /// 检查电池优化状态（Android 特有）
  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? false;
    } catch (e) {
      logger.warning('AndroidNotification', '[Android] 检查电池优化状态失败: $e');
      return false;
    }
  }

  /// 打开应用设置（Android 特有）
  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 打开应用设置失败', e, st);
      rethrow;
    }
  }

  /// 打开通知渠道设置（Android 特有）
  Future<void> openNotificationChannelSettings() async {
    try {
      await _channel.invokeMethod('openNotificationChannelSettings');
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 打开通知渠道设置失败', e, st);
      rethrow;
    }
  }

  /// 获取电池优化详细信息（Android 特有）
  Future<Map<String, dynamic>> getBatteryOptimizationInfo() async {
    try {
      final result = await _channel.invokeMethod('getBatteryOptimizationInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      logger.warning('AndroidNotification', '[Android] 获取电池优化信息失败: $e');
      return {
        'isIgnoring': false,
        'manufacturer': 'Unknown',
        'model': 'Unknown',
        'androidVersion': 'Unknown',
      };
    }
  }

  /// 获取通知渠道详细信息（Android 特有）
  Future<Map<String, dynamic>> getNotificationChannelInfo() async {
    try {
      final result = await _channel.invokeMethod('getNotificationChannelInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      logger.warning('AndroidNotification', '[Android] 获取通知渠道信息失败: $e');
      return {
        'isEnabled': false,
        'importance': 'unknown',
        'sound': false,
        'vibration': false,
      };
    }
  }
}
