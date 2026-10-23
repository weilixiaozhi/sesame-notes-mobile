import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/services/notification/notification_android.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';

/// 独立缓存耗电管理状态，仅在进入页面或从系统设置返回时重新读取。
final reminderBatteryInfoProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
      try {
        final notifications = NotificationFactory.getInstance();
        if (notifications is! AndroidNotificationUtil) return null;
        return await notifications.getBatteryOptimizationInfo();
      } on UnsupportedError {
        return null;
      } catch (error, stack) {
        logger.error('ReminderSystemStatus', '读取耗电管理状态失败', error, stack);
        rethrow;
      }
    });

/// 并行读取所有提醒渠道，缓存与提醒偏好分离，避免点击选项触发加载闪烁。
final reminderChannelInfoProvider =
    FutureProvider.autoDispose<Map<String, Map<String, dynamic>?>>((ref) async {
      try {
        final notifications = NotificationFactory.getInstance();
        if (notifications is! AndroidNotificationUtil) return {};
        const channelIds = [
          'accounting_reminder',
          'days_reminder',
          'fitness_rest_alarm_v2',
        ];
        // 直接读取渠道，保留 null 以区分未创建和被系统关闭的渠道。
        final details = await Future.wait([
          for (final id in channelIds)
            notifications.getNotificationChannelInfoById(id),
        ]);
        return Map.fromIterables(channelIds, details);
      } on UnsupportedError {
        return {};
      } catch (error, stack) {
        logger.error('ReminderSystemStatus', '读取通知管理状态失败', error, stack);
        rethrow;
      }
    });
