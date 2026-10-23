import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/logging/logger_service.dart';
import 'notification_android.dart';
import 'notification_navigation.dart';
import 'reminder_constants.dart';

/// 休息闹钟由原生定时任务统一播放声振，前后台使用同一执行入口。
class AndroidRestNotificationUtil extends AndroidNotificationUtil {
  static const _channel = MethodChannel('notification_channel');

  /// 权限、渠道及通知点击继续复用通用通知服务。
  AndroidRestNotificationUtil(
    super.plugin, {
    required super.channel,
    super.prepareChannel,
  }) : super(
         destination: NotificationDestination.fitness,
         visibility: NotificationVisibility.private,
       );

  /// 保存绝对到期时间，系统到时唤起有限时长的休息闹钟。
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await initialize();
      await _channel.invokeMethod<void>('scheduleFitnessRestAlarm', {
        'id': id,
        'title': title,
        'body': body,
        'at': scheduledDate.millisecondsSinceEpoch,
      });
    } catch (error, stack) {
      logger.error('FitnessRestAlarm', '登记休息闹钟失败', error, stack);
      rethrow;
    }
  }

  /// 明确停止同时撤销定时、当前声振和通知，并清理同 ID 通用提醒任务。
  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod<void>('cancelFitnessRestAlarm', {'id': id});
      await super.cancelNotification(id);
    } catch (error, stack) {
      logger.error('FitnessRestAlarm', '停止休息闹钟失败', error, stack);
      rethrow;
    }
  }

  /// 全部关闭时包含独立运行的休息闹钟。
  @override
  Future<void> cancelAllNotifications() async {
    try {
      await cancelNotification(fitnessRestNotificationId);
      await super.cancelAllNotifications();
    } catch (error, stack) {
      logger.error('FitnessRestAlarm', '关闭全部休息提醒失败', error, stack);
      rethrow;
    }
  }

  /// 合并通用提醒与独立休息闹钟，已响铃的提醒不算待执行任务。
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final requests = await super.getPendingNotifications();
      final pending = await _channel.invokeMapMethod<String, dynamic>(
        'getPendingFitnessRestAlarm',
      );
      if (pending == null) return requests;
      final id = pending['id'] as int;
      return [
        ...requests.where((request) => request.id != id),
        PendingNotificationRequest(
          id,
          pending['title'] as String,
          pending['body'] as String,
          NotificationDestination.fitness.path,
        ),
      ];
    } catch (error, stack) {
      logger.error('FitnessRestAlarm', '读取待执行休息闹钟失败', error, stack);
      rethrow;
    }
  }
}
