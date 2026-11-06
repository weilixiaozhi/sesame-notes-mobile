import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/features/fitness/application/fitness_rest_reminder.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';

class _Notifications extends Fake implements NotificationUtil {
  final scheduled = <DateTime>[];
  int cancellations = 0;
  bool permitted = true;
  Completer<bool>? permission;
  Completer<void>? scheduling;
  Completer<void>? schedulingStarted;
  @override
  Future<void> cancelNotification(int id) async {
    expect(id, fitnessRestNotificationId);
    cancellations++;
  }

  @override
  Future<bool> checkPermissionStatus() =>
      permission?.future ?? Future.value(permitted);

  /// 通知登记可由测试挂起，精确复现原生回执与前台恢复交错。
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      expect(id, fitnessRestNotificationId);
      scheduled.add(scheduledDate);
      if (schedulingStarted?.isCompleted == false) {
        schedulingStarted!.complete();
      }
      await scheduling?.future;
    } catch (error, stackTrace) {
      printOnFailure('休息通知受控登记失败：$error\n$stackTrace');
      rethrow;
    }
  }
}

/// 休息提醒在跨到期恢复、身份切换与迟到登记时保持正确的系统通知。
void main() {
  final now = DateTime.utc(2026, 9, 11, 12);
  FitnessWorkout workout({
    String status = 'in_progress',
    String restStatus = 'running',
    int seconds = 90,
  }) => FitnessWorkout(
    id: 'workout',
    name: 'private',
    scheduledDate: '2026-09-11',
    status: status,
    restTimer: FitnessRestTimer(
      status: restStatus,
      endsAt: now.add(Duration(seconds: seconds)),
      remainingSeconds: seconds,
      durationSeconds: seconds,
    ),
  );

  test('登记回执跨到期恢复仍保留系统通知，切换身份和跳过仍取消', () async {
    var current = now;
    final notifications = _Notifications()
      ..scheduling = Completer<void>()
      ..schedulingStarted = Completer<void>();
    try {
      final reminders = FitnessRestReminder(
        notificationFactory: (_) => notifications,
        clock: () => current,
      );

      /// 同一休息通过真实队列核对，保留强制前台恢复和账号切换入口。
      Future<void> update({String identity = 'a', FitnessWorkout? value}) =>
          reminders.synchronize(
            identity: identity,
            workout: value ?? workout(),
            preferences: const FitnessPreferences(),
            title: 'Rest',
            body: 'Ready',
            force: true,
          );
      final registering = update();
      await notifications.schedulingStarted!.future.timeout(
        const Duration(seconds: 3),
      );
      final before = notifications.cancellations;
      current = now.add(const Duration(seconds: 90));
      // 原生仍在登记同一次休息时发起到期恢复，随后释放迟到的系统回执。
      final resumed = update();
      notifications.scheduling!.complete();
      await Future.wait([registering, resumed]);
      await update();
      expect(notifications.cancellations, before);
      expect(notifications.scheduled, hasLength(1));
      await update(identity: 'b');
      expect(notifications.cancellations, before + 1);
      await update(value: workout(restStatus: 'paused'));
      expect(notifications.cancellations, before + 2);
    } catch (error, stackTrace) {
      printOnFailure('休息登记跨到期恢复验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      if (!notifications.scheduling!.isCompleted) {
        notifications.scheduling!.complete();
      }
    }
  });

  test('重设、暂停、结束和账号变化使用同一通知身份且失效权限回调不再调度', () async {
    final notifications = _Notifications();
    final reminders = FitnessRestReminder(
      notificationFactory: (_) => notifications,
      clock: () => now,
    );
    Future<void> update(
      FitnessWorkout? current, {
      String identity = 'a',
      bool force = false,
    }) => reminders.synchronize(
      identity: identity,
      workout: current,
      preferences: const FitnessPreferences(soundEnabled: true),
      title: 'Rest',
      body: 'Ready',
      force: force,
    );
    await update(workout());
    await update(workout());
    expect(notifications.scheduled, [now.add(const Duration(seconds: 90))]);
    await update(workout(seconds: 120));
    expect(notifications.scheduled.last, now.add(const Duration(seconds: 120)));
    await update(workout(restStatus: 'paused'));
    await update(workout(status: 'completed'));
    expect(notifications.scheduled.length, 2);
    notifications.permission = Completer<bool>();
    final old = update(workout(seconds: 180));
    await Future<void>.delayed(Duration.zero);
    final changedAccount = update(null, identity: 'b');
    notifications.permission!.complete(true);
    await Future.wait([old, changedAccount]);
    expect(notifications.scheduled.length, 2);
    expect(notifications.cancellations, greaterThanOrEqualTo(5));
    notifications.permission = null;
    notifications.permitted = false;
    await update(workout(), identity: 'b');
    expect(notifications.scheduled.length, 2);
    notifications.permitted = true;
    await update(workout(), identity: 'b', force: true);
    expect(notifications.scheduled.length, 3);
    await update(workout(seconds: 0), identity: 'b');
    expect(notifications.scheduled.length, 3);
  });
}
