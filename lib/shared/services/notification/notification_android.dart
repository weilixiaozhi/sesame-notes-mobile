import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'notification_util.dart' as util;
import 'notification_navigation.dart';

/// Android 特定的通知实现
class AndroidNotificationUtil implements util.NotificationUtil {
  static const _reminderChannel = AndroidNotificationChannel(
    'accounting_reminder',
    '记账提醒',
    description: '每日记账提醒',
    importance: Importance.max,
    enableLights: true,
  );
  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidNotificationChannel _notificationChannel;
  final NotificationVisibility visibility;
  final NotificationDestination destination;
  final Future<void> Function()? prepareSchedule;
  final Future<void> Function()? prepareChannel;
  final MethodChannel _channel = const MethodChannel('notification_channel');
  bool _initialized = false;

  /// 复用应用通知插件，统一管理提醒渠道与系统设置。
  AndroidNotificationUtil(
    this._plugin, {
    AndroidNotificationChannel channel = _reminderChannel,
    this.visibility = NotificationVisibility.public,
    this.destination = NotificationDestination.bookkeeping,
    this.prepareSchedule,
    this.prepareChannel,
  }) : _notificationChannel = channel;

  /// 初始化插件并提前创建渠道，使首次提醒前也能检查和设置渠道。
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: NotificationNavigation.receive,
      );
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) throw StateError('Android 通知服务不可用');
      await prepareChannel?.call();
      // 创建同 ID 渠道是幂等操作，系统会保留用户的声音、振动和开关设置。
      await androidPlugin.createNotificationChannel(_notificationChannel);
      // 权限仅在用户主动开启提醒时申请，初始化本身不会触发权限弹窗。
      _initialized = true;
      logger.info('AndroidNotification', '[Android] 通知服务初始化完成');
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 通知服务初始化失败', e, st);
      rethrow;
    }
  }

  /// 申请通知权限，并确认应用总开关与提醒渠道都允许发送。
  @override
  Future<bool> requestPermissions({bool checkChannel = true}) async {
    try {
      if (!_initialized) await initialize();
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null) return false;

      // 请求基础通知权限
      final granted = await androidPlugin.requestNotificationsPermission();
      logger.info(
        'AndroidNotification',
        '[Android] 基础通知权限: ${granted ?? false}',
      );
      if (granted != true || (checkChannel && !await checkPermissionStatus())) {
        return false;
      }

      // 请求精确闹钟权限 (Android 12+)
      try {
        await androidPlugin.requestExactAlarmsPermission();
        final canScheduleExact = await androidPlugin
            .canScheduleExactNotifications();
        logger.info(
          'AndroidNotification',
          '[Android] 精确闹钟权限: ${canScheduleExact ?? false}',
        );
      } catch (e, st) {
        logger.error(
          'AndroidNotification',
          '[Android] 请求精确闹钟权限失败，将使用非精确提醒',
          e,
          st,
        );
      }

      return true;
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 请求通知权限失败', e, st);
      rethrow;
    }
  }

  /// 使用同一个持久化重复任务调度每日提醒。
  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await prepareSchedule?.call();
    final scheduledDate = util.calculateNextReminderTime(hour, minute);
    await _scheduleReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      daily: true,
      hour: hour,
      minute: minute,
    );
  }

  /// 调度只发送一次的提醒，并复用相同的精确权限降级规则。
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _scheduleReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  /// 优先精确定时；系统拒绝精确闹钟时登记允许待机触发的非精确任务。
  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool daily = false,
    int? hour,
    int? minute,
  }) async {
    try {
      if (!_initialized) await initialize();
      await prepareSchedule?.call();
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final exactAllowed =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      final localDate = util.convertToTZDateTime(scheduledDate);

      final requestedMode = exactAllowed
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle;
      // 原生管理排期和续期，系统闹钟展示入口与到期执行广播使用不同 PendingIntent。
      // 原生同时处理权限撤回竞态，返回真实执行模式以准确提示可能的延迟。
      final modeName = await _channel.invokeMethod<String>(
        'scheduleReminderAlarm',
        {
          'id': id,
          'title': title,
          'body': body,
          'at': localDate.millisecondsSinceEpoch,
          'timeZoneName': localDate.location.name,
          'daily': daily,
          'hour': ?hour,
          'minute': ?minute,
          'payload': destination.path,
          'platformSpecifics': {
            'channelId': _notificationChannel.id,
            'category': destination == NotificationDestination.fitness
                ? AndroidNotificationCategory.alarm.name
                : AndroidNotificationCategory.reminder.name,
            'visibility': visibility.index,
            'playSound': _notificationChannel.playSound,
            'sound': _notificationChannel.sound?.sound,
            'enableVibration': _notificationChannel.enableVibration,
            'vibrationPattern': _notificationChannel.vibrationPattern?.toList(),
            'scheduleMode': requestedMode.name,
          },
        },
      );

      if (modeName == null) throw StateError('系统未返回提醒调度结果');
      final mode = AndroidScheduleMode.values.byName(modeName);
      if (mode == AndroidScheduleMode.inexactAllowWhileIdle) {
        logger.warning(
          'AndroidNotification',
          '[Android] 提醒已登记，但未获精确闹钟权限，通知可能延迟',
        );
      }
      logger.info(
        'AndroidNotification',
        '[Android] 提醒登记成功: id=$id, time=$scheduledDate, mode=${mode.name}',
      );
    } catch (e, st) {
      logger.error(
        'AndroidNotification',
        '[Android] 提醒登记失败: id=$id, time=$scheduledDate',
        e,
        st,
      );
      rethrow;
    }
  }

  /// 原生按通知 ID 取消排期及已显示通知，无需提前创建渠道。
  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod<void>('cancelReminderAlarm', {'id': id});
      logger.info('AndroidNotification', '[Android] 提醒已取消: $id');
    } catch (error, stack) {
      logger.error('AndroidNotification', '取消提醒失败: id=$id', error, stack);
      rethrow;
    }
  }

  /// 先释放已登记原生任务，再统一清除应用当前已显示的通知。
  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _channel.invokeMethod<void>('cancelAllReminderAlarms');
      await _plugin.cancelAll();
      logger.info('AndroidNotification', '[Android] 所有通知已取消');
    } catch (error, stack) {
      logger.error('AndroidNotification', '取消全部提醒失败', error, stack);
      rethrow;
    }
  }

  /// 独立检查精确闹钟权限，通知渠道可用不代表定时提醒能够准点送达。
  Future<bool> canScheduleExactReminders() async {
    try {
      if (!_initialized) await initialize();
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.canScheduleExactNotifications() ??
          false;
    } catch (error, stack) {
      logger.error('AndroidNotification', '读取精确提醒权限失败', error, stack);
      rethrow;
    }
  }

  /// 用户主动打开系统精确提醒授权页，返回后重新读取真实权限。
  Future<bool> requestExactReminderPermission() async {
    try {
      if (!_initialized) await initialize();
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
      return await canScheduleExactReminders();
    } catch (error, stack) {
      logger.error('AndroidNotification', '申请精确提醒权限失败', error, stack);
      rethrow;
    }
  }

  /// 待处理列表只读取当前原生登记，包含记账、纪念日及其业务目的地址。
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      if (!_initialized) await initialize();
      final native = await _channel.invokeListMethod<dynamic>(
        'getPendingReminderAlarms',
      );
      final requests = <PendingNotificationRequest>[];
      for (final value in native ?? const []) {
        final item = Map<String, dynamic>.from(value as Map);
        final id = item['id'] as int;
        requests.add(
          PendingNotificationRequest(
            id,
            item['title'] as String?,
            item['body'] as String?,
            item['payload'] as String?,
          ),
        );
      }
      return requests;
    } catch (error, stack) {
      logger.error('AndroidNotification', '读取提醒排期失败', error, stack);
      rethrow;
    }
  }

  /// 同时检查应用通知总开关和当前提醒渠道，避免把被拦截的通知视为可用。
  @override
  Future<bool> checkPermissionStatus() async {
    try {
      if (!_initialized) await initialize();
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null) return false;

      final enabled = await androidPlugin.areNotificationsEnabled();
      if (enabled != true) return false;
      final channelInfo = await getNotificationChannelInfo();
      return channelInfo['isEnabled'] == true;
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 检查通知权限失败', e, st);
      rethrow;
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

  /// 打开厂商自启动管理页；未提供可用入口时返回 false，由界面提供操作指引。
  Future<bool> openAutoStartSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openAutoStartSettings') ??
          false;
    } catch (error, stack) {
      logger.error('AndroidNotification', '[Android] 打开自启动设置失败', error, stack);
      rethrow;
    }
  }

  /// 打开应用的全部通知渠道管理页，允许设置记账、纪念日和休息提醒。
  Future<void> openAppNotificationSettings() async {
    try {
      await _channel.invokeMethod<void>('openAppNotificationSettings');
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 打开通知管理失败', e, st);
      rethrow;
    }
  }

  /// 读取系统耗电管理豁免状态；读取失败交给界面提示，避免误报为未豁免。
  Future<Map<String, dynamic>> getBatteryOptimizationInfo() async {
    try {
      final result = await _channel.invokeMethod('getBatteryOptimizationInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 获取耗电管理信息失败', e, st);
      rethrow;
    }
  }

  /// 获取通知渠道详细信息（Android 特有）
  Future<Map<String, dynamic>> getNotificationChannelInfo() async {
    try {
      if (!_initialized) await initialize();
      return await getNotificationChannelInfoById(_notificationChannel.id) ??
          {};
    } catch (e, st) {
      logger.error('AndroidNotification', '[Android] 获取通知渠道信息失败', e, st);
      rethrow;
    }
  }

  /// 只读查询指定渠道，未创建时返回 null；诊断不会创建渠道或修改声振设置。
  Future<Map<String, dynamic>?> getNotificationChannelInfoById(
    String channelId,
  ) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getNotificationChannelInfo',
        {'channelId': channelId},
      );
      return result?['channelExists'] == false ? null : result;
    } catch (error, stack) {
      logger.error(
        'AndroidNotification',
        '[Android] 获取通知渠道信息失败: channelId=$channelId',
        error,
        stack,
      );
      rethrow;
    }
  }
}
