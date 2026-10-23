import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../core/logging/logger_service.dart';
import '../../../data/models/fitness.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/account_reminder_invalidation_provider.dart';
import '../../../shared/providers/fitness_repository_provider.dart';
import '../../../shared/providers/fitness_space_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/services/notification/notification_factory.dart';
import '../../../shared/services/notification/notification_util.dart';
import 'fitness_providers.dart';
import 'fitness_rest_reminder.dart';

/// 使用当前设备的唯一休息通知渠道。
NotificationUtil _notificationFor(
  FitnessPreferences preferences,
  String channelName,
) => NotificationFactory.getFitnessRestInstance(
  channelName: channelName,
  soundEnabled: preferences.soundEnabled,
  vibrationEnabled: preferences.vibrationEnabled,
);

/// 用户主动开始计时时申请通知与精确提醒权限。
Future<bool> requestFitnessReminderPermission({
  required FitnessPreferences preferences,
  required String channelName,
}) async {
  try {
    return await _notificationFor(
      preferences,
      channelName,
    ).requestPermissions();
  } on UnsupportedError {
    return false;
  }
}

/// 应用壳常驻，切业务和收起详情不停止计时；数据刷新只交给已有仓库事务。
final fitnessLifecycleProvider = Provider<Future<void> Function()>((ref) {
  var disposed = false;
  var submittedUpdate = 0;
  AppLocalizations localizations() => lookupAppLocalizations(
    ref.read(languageProvider) ?? PlatformDispatcher.instance.locale,
  );
  final reminder = FitnessRestReminder(
    notificationFactory: (preferences) =>
        _notificationFor(preferences, localizations().fitnessRest),
  );

  /// 明确的认证失效先清理旧提醒，只有最新清理成功后才确认对应事件。
  Future<void> updateReminder({bool force = false, bool clear = false}) async {
    if (disposed) return;
    final invalidation = ref.read(accountReminderInvalidationProvider);
    final invalidated = invalidation.isPending(AccountReminderKind.fitness);
    final shouldClear = clear || invalidated;
    final preferenceState = ref.read(fitnessPreferencesProvider);
    final workoutState = ref.read(fitnessRunningWorkoutProvider);
    final settings = ref.read(reminderSettingsProvider);
    final enabled = settings.restActive;
    // 读取中的空值不代表用户停止计时；切账号和关闭开关仍立即清理旧任务。
    if (!shouldClear &&
        (!settings.isLoaded ||
            (enabled &&
                (preferenceState.isLoading ||
                    preferenceState.hasError ||
                    workoutState.isLoading ||
                    workoutState.hasError)))) {
      return;
    }
    final preferences = preferenceState.value;
    final workout = workoutState.value;
    final l = localizations();
    // 偏好加载完成后即整理系统渠道，无需用户再启动一次计时；加载中的
    // 默认值不能参与迁移，否则可能覆盖用户原先选择的静音组合。
    if (preferences != null &&
        !preferenceState.isLoading &&
        !preferenceState.hasError) {
      try {
        unawaited(
          _notificationFor(preferences, l.fitnessRest).initialize().catchError((
            Object error,
            StackTrace stack,
          ) {
            logger.error('FitnessReminder', '初始化休息通知渠道失败', error, stack);
          }),
        );
      } on UnsupportedError {
        // 无系统通知的平台仍可使用训练计时。
      }
    }
    final account = ref.read(currentAccountIdProvider);
    final generation = ref
        .read(authSessionProvider.notifier)
        .identityGeneration;
    final updateId = ++submittedUpdate;
    try {
      await reminder.synchronize(
        identity:
            '$account/$generation/${ref.read(currentFitnessSpaceIdProvider).value}',
        workout: shouldClear || !enabled ? null : workout,
        preferences: preferences ?? const FitnessPreferences(),
        title: l.fitnessRestCompletedTitle,
        body: l.fitnessRestCompletedBody,
        force: force || invalidated,
      );
      if (!disposed &&
          invalidated &&
          updateId == submittedUpdate &&
          ref.read(accountReminderInvalidationProvider).generation ==
              invalidation.generation) {
        ref
            .read(accountReminderInvalidationProvider.notifier)
            .acknowledge(AccountReminderKind.fitness, invalidation.generation);
        // 清理期间新身份数据可能已到达；确认后再按当前完整数据登记，避免遗漏恢复。
        await updateReminder(force: true);
      }
    } on UnsupportedError {
      // 非 Android 平台不消费尚未执行的平台清理事件。
    } catch (error, stack) {
      logger.error('FitnessReminder', '休息提醒暂不可用，训练记录继续保存', error, stack);
    }
  }

  Future<void> refreshSchedule() async {
    if (disposed) return;
    final space = ref.read(currentFitnessSpaceProvider).value;
    if (space == null || space.isStale || !space.isComplete) return;
    try {
      await ref.read(fitnessWorkoutRepositoryProvider).refreshSchedule();
    } catch (error, stack) {
      if (disposed) return;
      logger.error('FitnessSchedule', '训练日程生成失败，保留原数据等待重试', error, stack);
    }
  }

  ref.listen(
    reminderSettingsProvider,
    (_, _) => unawaited(updateReminder(force: true)),
  );
  ref.listen(
    fitnessRunningWorkoutProvider,
    (_, _) => unawaited(updateReminder()),
  );
  ref.listen(fitnessPreferencesProvider, (_, _) => unawaited(updateReminder()));
  ref.listen(currentFitnessSpaceProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id ||
        previous?.value?.syncId != next.value?.syncId) {
      unawaited(updateReminder(force: true, clear: true));
      unawaited(refreshSchedule());
    }
  });
  ref.listen(currentAccountIdProvider, (_, _) {
    unawaited(updateReminder(force: true, clear: true));
    unawaited(refreshSchedule());
  });
  ref.listen(authIdentityGenerationProvider, (_, _) {
    // 身份变化先撤销旧提醒，等新账号的数据订阅就绪后再登记。
    unawaited(updateReminder(force: true, clear: true));
  });
  ref.listen(
    accountReminderInvalidationProvider.select((state) => state.generation),
    (_, _) => unawaited(updateReminder(force: true)),
  );
  ref.listen(
    languageProvider,
    (_, _) => unawaited(updateReminder(force: true)),
  );
  // 常驻应用跨午夜时生成新周期；休眠恢复仍以本地日历重核，不靠计数器补天数。
  Timer? midnight;
  void scheduleMidnight() {
    if (disposed) return;
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    midnight = Timer(next.difference(now), () {
      unawaited(refreshSchedule());
      scheduleMidnight();
    });
  }

  scheduleMidnight();
  unawaited(refreshSchedule());
  unawaited(updateReminder(force: true));
  ref.onDispose(() {
    disposed = true;
    midnight?.cancel();
  });
  // 前台恢复由现有应用壳统一调用；先补齐本机日程，再沿用壳的同步刷新。
  return () async {
    if (disposed) return;
    await updateReminder(force: true);
    midnight?.cancel();
    scheduleMidnight();
    await refreshSchedule();
  };
});
