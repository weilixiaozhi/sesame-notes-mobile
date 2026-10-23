import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:sesame_notes/shared/services/notification/notification_android.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';

import '../models/reminder_settings.dart';

/// 记账提醒设置的 Notifier
class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  /// 首次修改等配置加载完成，避免总开关覆盖已有的分类配置。
  late Future<void> _loaded;

  @override
  ReminderSettings build() {
    // 先同步返回默认设置，再异步加载保存的配置，避免首次渲染等待 IO。
    _loaded = _loadSettings();
    return ReminderSettings.defaultSettings();
  }

  // prefs 键统一引用服务层常量（与 main / 监控服务共用），
  // 避免字符串散落导致改名后静默失联。
  static const String _keyEnabled = ReminderPrefs.enabled;
  static const String _keyHour = ReminderPrefs.hour;
  static const String _keyMinute = ReminderPrefs.minute;

  /// 当前语言下的提醒文案（无 BuildContext，按语言 provider / 系统语言解析）。
  AppLocalizations get _l10n {
    final locale =
        ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale;
    return lookupAppLocalizations(locale);
  }

  /// 从本机偏好恢复配置，首次使用的选项采用明确的产品默认值。
  Future<void> _loadSettings() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final isEnabled = prefs.getBool(_keyEnabled) ?? false;
      final hour = prefs.getInt(_keyHour) ?? 21;
      final minute = prefs.getInt(_keyMinute) ?? 0;

      if (!ref.mounted) return;
      state = ReminderSettings(
        isEnabled: isEnabled,
        hour: hour,
        minute: minute,
        notificationsEnabled:
            prefs.getBool(ReminderPrefs.notificationsEnabled) ?? false,
        restEnabled: prefs.getBool(ReminderPrefs.restEnabled) ?? true,
        daysEnabled: prefs.getBool(ReminderPrefs.daysEnabled) ?? false,
        daysHour: prefs.getInt(ReminderPrefs.daysHour) ?? 9,
        daysMinute: prefs.getInt(ReminderPrefs.daysMinute) ?? 0,
        daysOffsets: prefs.getInt(ReminderPrefs.daysOffsets) ?? 3,
        daysDailyEnabled:
            prefs.getBool(ReminderPrefs.daysDailyEnabled) ?? false,
        daysDailyEventIds: Set.unmodifiable(
          prefs.getStringList(ReminderPrefs.daysDailyEventIds) ?? const [],
        ),
      );
    } catch (e, st) {
      logger.error('ReminderSettings', '加载提醒设置失败', e, st);
    }
  }

  /// 保存指定设置，写入失败时交由调用方恢复通知和界面状态。
  Future<void> _saveSettings(ReminderSettings settings) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (!await prefs.setInt(_keyHour, settings.hour) ||
          !await prefs.setInt(_keyMinute, settings.minute) ||
          !await prefs.setBool(_keyEnabled, settings.isEnabled) ||
          !await prefs.setBool(
            ReminderPrefs.notificationsEnabled,
            settings.notificationsEnabled,
          ) ||
          !await prefs.setBool(
            ReminderPrefs.restEnabled,
            settings.restEnabled,
          ) ||
          !await prefs.setBool(
            ReminderPrefs.daysEnabled,
            settings.daysEnabled,
          ) ||
          !await prefs.setInt(ReminderPrefs.daysHour, settings.daysHour) ||
          !await prefs.setInt(ReminderPrefs.daysMinute, settings.daysMinute) ||
          !await prefs.setInt(
            ReminderPrefs.daysOffsets,
            settings.daysOffsets,
          ) ||
          !await prefs.setBool(
            ReminderPrefs.daysDailyEnabled,
            settings.daysDailyEnabled,
          ) ||
          !await prefs.setStringList(
            ReminderPrefs.daysDailyEventIds,
            settings.daysDailyEventIds.toList()..sort(),
          )) {
        throw StateError('提醒设置保存失败');
      }
    } catch (e, st) {
      logger.error('ReminderSettings', '保存提醒设置失败', e, st);
      rethrow;
    }
  }

  /// 更新完整设置；权限、调度或持久化失败时保留原配置并向界面报告。
  /// 与生命周期恢复共用队列，加载完成后核对原配置并提交整次用户意图。
  Future<void> updateSettings(ReminderSettings settings) {
    return ReminderMonitorService().runUpdate(() async {
      await _loaded;
      final previous = state;
      try {
        // 能力与页面共用工厂事实，绕过界面的调用同样不能写入无效提醒配置。
        if (!ref.read(reminderSupportedProvider)) {
          throw PlatformException(
            code: 'notification_unsupported',
            message: '当前平台暂不支持提醒通知',
          );
        }
        if (settings.hour < 0 ||
            settings.hour > 23 ||
            settings.minute < 0 ||
            settings.minute > 59 ||
            settings.daysHour < 0 ||
            settings.daysHour > 23 ||
            settings.daysMinute < 0 ||
            settings.daysMinute > 59 ||
            settings.daysOffsets <= 0 ||
            settings.daysOffsets & ~139 != 0) {
          throw ArgumentError('提醒时间或提前天数无效');
        }
        if (settings.daysDailyEnabled && settings.daysDailyEventIds.isEmpty) {
          throw ArgumentError('请选择需要每日提醒的纪念日');
        }
        final needsPermission =
            settings.notificationsEnabled &&
            (!previous.notificationsEnabled ||
                (settings.isEnabled && !previous.isEnabled) ||
                (settings.daysEnabled && !previous.daysEnabled) ||
                (settings.restEnabled && !previous.restEnabled));
        final notificationUtil =
            needsPermission || settings.dailyActive || previous.dailyActive
            ? NotificationFactory.getInstance()
            : null;
        if (needsPermission) {
          final enablingGlobal = !previous.notificationsEnabled;
          final permissionUtil =
              !enablingGlobal && settings.daysActive && !previous.daysActive
              ? NotificationFactory.getDaysInstance()
              : notificationUtil!;
          final granted = permissionUtil is AndroidNotificationUtil
              ? await permissionUtil.requestPermissions(
                  checkChannel:
                      !enablingGlobal &&
                      (settings.daysActive && !previous.daysActive ||
                          settings.dailyActive),
                )
              : await permissionUtil.requestPermissions();
          if (!granted) {
            throw PlatformException(
              code: 'notification_permission_denied',
              message: '请在系统设置中允许通知',
            );
          }
        }
        if (notificationUtil != null) {
          await _syncNotification(notificationUtil, settings);
        }

        try {
          await _saveSettings(settings);
        } catch (_) {
          // 两种恢复独立执行，系统任务恢复失败也不能留下部分写入的新设置。
          try {
            if (notificationUtil != null) {
              await _syncNotification(notificationUtil, previous);
            }
          } catch (e, st) {
            logger.error('ReminderSettings', '恢复原提醒任务失败', e, st);
          }
          try {
            await _saveSettings(previous);
          } catch (e, st) {
            logger.error('ReminderSettings', '恢复原提醒设置失败', e, st);
          }
          rethrow;
        }
        state = settings;
      } catch (e, st) {
        logger.error(
          'ReminderSettings',
          '更新提醒失败：启用=${settings.isEnabled}，时间=${settings.timeString}，'
              '每日纪念日=${settings.daysDailyEnabled}，选中数=${settings.daysDailyEventIds.length}',
          e,
          st,
        );
        rethrow;
      }
    });
  }

  /// 将指定配置应用到系统通知，调度失败不会主动删除原有任务。
  Future<void> _syncNotification(
    NotificationUtil notificationUtil,
    ReminderSettings settings,
  ) async {
    if (settings.dailyActive) {
      await notificationUtil.scheduleDailyReminder(
        id: ReminderPrefs.mainNotificationId,
        title: _l10n.reminderTitle,
        body: _l10n.reminderBody,
        hour: settings.hour,
        minute: settings.minute,
      );
    } else {
      await notificationUtil.cancelNotification(
        ReminderPrefs.mainNotificationId,
      );
    }
  }
}

/// 记账提醒设置Provider
final reminderSettingsProvider =
    NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
      ReminderSettingsNotifier.new,
    );

/// 提醒能力来自实际通知后端，界面与保存入口使用相同判断。
final reminderSupportedProvider = Provider<bool>(
  (ref) => NotificationFactory.supportsReminders,
);

/// 准点调度权限独立于通知显示权限；非 Android 平台不展示此诊断。
final exactReminderPermissionProvider = FutureProvider.autoDispose<bool?>((
  ref,
) async {
  try {
    final notifications = NotificationFactory.getInstance();
    if (notifications is! AndroidNotificationUtil) return null;
    return await notifications.canScheduleExactReminders();
  } on UnsupportedError {
    return null;
  } catch (error, stack) {
    logger.error('ReminderSettings', '检查准点提醒权限失败', error, stack);
    rethrow;
  }
});
