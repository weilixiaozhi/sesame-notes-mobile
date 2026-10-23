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
  @override
  Future<void> cancelNotification(int id) async {
    expect(id, fitnessRestNotificationId);
    cancellations++;
  }

  @override
  Future<bool> checkPermissionStatus() =>
      permission?.future ?? Future.value(permitted);
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    expect(id, fitnessRestNotificationId);
    scheduled.add(scheduledDate);
    await scheduling?.future;
  }
}

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

  test('关闭声音和震动仍调度静音休息横幅', () async {
    final notifications = _Notifications();
    final reminders = FitnessRestReminder(
      notificationFactory: (_) => notifications,
      clock: () => now,
    );
    await reminders.synchronize(
      identity: 'local',
      workout: workout(),
      preferences: const FitnessPreferences(
        soundEnabled: false,
        vibrationEnabled: false,
      ),
      title: 'Rest',
      body: 'Ready',
    );
    expect(notifications.scheduled, [now.add(const Duration(seconds: 90))]);
  });

  test('到期后恢复前台保留系统通知，切换身份和跳过仍取消', () async {
    var current = now;
    final notifications = _Notifications();
    final reminders = FitnessRestReminder(
      notificationFactory: (_) => notifications,
      clock: () => current,
    );
    Future<void> update({String identity = 'a', FitnessWorkout? value}) =>
        reminders.synchronize(
          identity: identity,
          workout: value ?? workout(),
          preferences: const FitnessPreferences(),
          title: 'Rest',
          body: 'Ready',
          force: true,
        );
    await update();
    final before = notifications.cancellations;
    current = now.add(const Duration(seconds: 90));
    await update();
    await update();
    expect(notifications.cancellations, before);
    expect(notifications.scheduled, hasLength(1));
    await update(identity: 'b');
    expect(notifications.cancellations, before + 1);
    await update(value: workout(restStatus: 'paused'));
    expect(notifications.cancellations, before + 2);
  });

  test('冷启动加载已结束计时不会撤走已投递通知或补发旧提醒', () async {
    final notifications = _Notifications();
    final reminders = FitnessRestReminder(
      notificationFactory: (_) => notifications,
      clock: () => now.add(const Duration(minutes: 5)),
    );
    await reminders.synchronize(
      identity: 'a',
      workout: workout(),
      preferences: const FitnessPreferences(),
      title: 'Rest',
      body: 'Ready',
      force: true,
    );
    expect(notifications.cancellations, 0);
    expect(notifications.scheduled, isEmpty);
  });

  test('系统登记返回与到期恢复前台交错时，不撤销同一次休息通知', () async {
    var current = now;
    final notifications = _Notifications()..scheduling = Completer<void>();
    final reminders = FitnessRestReminder(
      notificationFactory: (_) => notifications,
      clock: () => current,
    );
    Future<void> update() => reminders.synchronize(
      identity: 'a',
      workout: workout(),
      preferences: const FitnessPreferences(),
      title: 'Rest',
      body: 'Ready',
      force: true,
    );
    final first = update();
    await Future<void>.delayed(Duration.zero);
    current = now.add(const Duration(seconds: 90));
    final resumed = update();
    notifications.scheduling!.complete();
    await Future.wait([first, resumed]);
    expect(notifications.cancellations, 1);
    expect(notifications.scheduled, hasLength(1));
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
