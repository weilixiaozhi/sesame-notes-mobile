import '../../../data/models/fitness.dart';
import '../../../shared/services/notification/notification_util.dart';
import '../../../shared/services/notification/reminder_constants.dart';

typedef FitnessNotificationFactory =
    NotificationUtil Function(FitnessPreferences preferences);

/// 所有休息更新排到同一队列，迟到的权限/调度结果不能覆盖新计时或新账号。
class FitnessRestReminder {
  final FitnessNotificationFactory notificationFactory;
  final DateTime Function() clock;
  Future<void> _tail = Future.value();
  int _generation = 0;
  String? _scheduledKey;
  String? _scheduledTimerKey;
  String? _requestedTimerKey;

  FitnessRestReminder({
    required this.notificationFactory,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  /// 保留同一次已到期提醒，只有计时变化、暂停或关闭时才撤销系统通知。
  Future<void> synchronize({
    required String identity,
    required FitnessWorkout? workout,
    required FitnessPreferences preferences,
    required String title,
    required String body,
    bool force = false,
  }) {
    final generation = ++_generation;
    final rest = workout?.restTimer;
    final canSchedule =
        workout?.status == 'in_progress' &&
        rest?.status == 'running' &&
        rest?.endsAt != null;
    final timerKey = canSchedule
        ? '$identity/${workout!.id}/${rest!.endsAt!.toUtc().toIso8601String()}'
        : null;
    _requestedTimerKey = timerKey;
    final key = canSchedule
        ? '$timerKey/'
              '${preferences.soundEnabled}/${preferences.vibrationEnabled}/$title/$body'
        : '$identity/stopped';
    final result = _tail.then((_) async {
      if (generation != _generation || (!force && key == _scheduledKey)) return;
      // 恢复前台可能与系统投递同时发生。到期不是取消指令，保留同一计时
      // 已显示或仍在等待系统投递的通知；冷启动没有内存记录时也不撤销它。
      if (canSchedule &&
          !rest!.endsAt!.isAfter(clock()) &&
          (_scheduledTimerKey == null || _scheduledTimerKey == timerKey)) {
        return;
      }
      final notifications = notificationFactory(preferences);
      // 同一计时只覆盖调度，不先撤销，避免临近到期的权限查询或系统调用
      // 让已登记的任务出现空窗；新计时和明确停止仍清理旧通知。
      if (!canSchedule || timerKey != _scheduledTimerKey) {
        await notifications.cancelNotification(fitnessRestNotificationId);
        if (generation != _generation) return;
        _scheduledKey = null;
        _scheduledTimerKey = null;
      }
      if (!canSchedule || !rest!.endsAt!.isAfter(clock())) {
        _scheduledKey = key;
        return;
      }
      if (!await notifications.checkPermissionStatus()) return;
      if (generation != _generation) return;
      // 权限查询期间可能已到时；不补发过期提醒，避免恢复前台重复响铃。
      if (!rest.endsAt!.isAfter(clock())) return;
      await notifications.scheduleOnceReminder(
        id: fitnessRestNotificationId,
        title: title,
        body: body,
        scheduledDate: rest.endsAt!,
      );
      if (generation != _generation && _requestedTimerKey != timerKey) {
        await notifications.cancelNotification(fitnessRestNotificationId);
        return;
      }
      _scheduledKey = key;
      _scheduledTimerKey = timerKey;
    });
    // 单次平台失败传给调用方；队列继续接收用户后续的跳过、结束和重试。
    _tail = result.catchError((Object _) {});
    return result;
  }
}
