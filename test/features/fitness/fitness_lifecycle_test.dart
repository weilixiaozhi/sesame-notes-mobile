import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/features/fitness/application/fitness_lifecycle.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/providers/account_reminder_invalidation_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 模拟原生已保存的休息任务，允许取消回执延迟或失败。
class _Notifications extends Fake implements NotificationUtil {
  bool pending = true;
  int cancellations = 0;
  int scheduled = 0;
  final failingAttempts = <int>{};
  Completer<void>? firstCancellation;

  /// 渠道初始化与权限不影响本地生命周期用例。
  @override
  Future<void> initialize() async {}

  /// 保留实际取消先后关系，失败不能清除系统任务。
  @override
  Future<void> cancelNotification(int id) async {
    if (id != fitnessRestNotificationId) throw StateError('休息通知编号不匹配');
    final attempt = ++cancellations;
    if (attempt == 1) await firstCancellation?.future;
    if (failingAttempts.contains(attempt)) throw StateError('取消暂时失败');
    pending = false;
  }

  /// 健身权限始终可用，测试只关注身份失效和排期顺序。
  @override
  Future<bool> checkPermissionStatus() async => true;

  /// 记录清理后是否恢复了当前身份的有效计时。
  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (id != fitnessRestNotificationId) throw StateError('休息通知编号不匹配');
    scheduled++;
    pending = true;
  }
}

/// 保留真实账号及提醒编排，仅替换数据库数据流和系统通知接口。
class _Fixture {
  final notifications = _Notifications();
  final preferences = StreamController<FitnessPreferences>.broadcast();
  final workouts = StreamController<FitnessWorkout?>.broadcast();
  late final ProviderContainer container;
  ProviderSubscription<Future<void> Function()>? subscription;

  /// 数据流初始保持未知，不把尚未读取的训练误认为用户已停止。
  _Fixture() {
    SharedPreferences.setMockInitialValues({});
    NotificationFactory.setFitnessRestInstanceForTesting(notifications);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        reminderSettingsProvider.overrideWithBuild(
          (ref, notifier) => const ReminderSettings(
            isEnabled: false,
            hour: 21,
            minute: 0,
            notificationsEnabled: true,
          ),
        ),
        fitnessPreferencesProvider.overrideWith((ref) => preferences.stream),
        fitnessRunningWorkoutProvider.overrideWith((ref) => workouts.stream),
        currentFitnessSpaceProvider.overrideWithValue(const AsyncData(null)),
        currentFitnessSpaceIdProvider.overrideWithBuild(
          (ref, notifier) => null,
        ),
      ],
    );
  }

  /// 模拟认证桥已确认的失效事件，可在应用壳开始订阅之前发生。
  void invalidate() => container
      .read(accountReminderInvalidationProvider.notifier)
      .invalidateReminders();

  /// 应用壳首次进入或重新建立提醒监听。
  void start() {
    subscription = container.listen(fitnessLifecycleProvider, (_, _) {});
  }

  /// 当前事件只有在健身系统清理成功后才能确认。
  bool get pendingInvalidation => container
      .read(accountReminderInvalidationProvider)
      .isPending(AccountReminderKind.fitness);

  /// 用当前身份数据恢复一条尚未结束的本机训练计时。
  void publishWorkout() {
    preferences.add(const FitnessPreferences());
    workouts.add(
      FitnessWorkout(
        id: 'workout',
        name: '本机训练',
        scheduledDate: '2026-10-05',
        status: 'in_progress',
        restTimer: FitnessRestTimer(
          status: 'running',
          endsAt: DateTime.now().add(const Duration(minutes: 10)),
          remainingSeconds: 600,
          durationSeconds: 600,
        ),
      ),
    );
  }

  /// 释放生命周期定时器和数据流，避免影响后续随机顺序测试。
  Future<void> dispose() async {
    if (notifications.firstCancellation?.isCompleted == false) {
      notifications.firstCancellation!.complete();
    }
    subscription?.close();
    container.dispose();
    await preferences.close();
    await workouts.close();
    NotificationFactory.reset();
  }
}

/// 认证失效的回放必须保持原生清理成功与业务确认之间的先后关系。
void main() {
  testWidgets('订阅前认证失效即使训练未加载也清理旧任务，业务分别确认', (tester) async {
    final fixture = _Fixture();
    try {
      fixture.invalidate();
      fixture.start();
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isFalse);
      expect(fixture.pendingInvalidation, isFalse);
      expect(
        fixture.container
            .read(accountReminderInvalidationProvider)
            .isPending(AccountReminderKind.days),
        isTrue,
      );
      final before = fixture.notifications.cancellations;
      fixture.container
          .read(accountReminderInvalidationProvider.notifier)
          .acknowledge(AccountReminderKind.days, 1);
      fixture.container.invalidate(fitnessLifecycleProvider);
      await tester.pumpAndSettle();
      expect(fixture.notifications.cancellations, before);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });

  testWidgets('清理失败保留失效事件，恢复前台重试后才确认', (tester) async {
    final fixture = _Fixture();
    try {
      fixture.notifications.failingAttempts.add(1);
      fixture.invalidate();
      fixture.start();
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isTrue);
      expect(fixture.pendingInvalidation, isTrue);
      await fixture.container.read(fitnessLifecycleProvider)();
      expect(fixture.notifications.pending, isFalse);
      expect(fixture.pendingInvalidation, isFalse);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });

  for (final newEvent in [false, true]) {
    testWidgets('${newEvent ? '新失效事件' : '同事件新清理'}失败时，旧取消回执不能提前确认', (
      tester,
    ) async {
      final fixture = _Fixture();
      try {
        fixture.notifications.firstCancellation = Completer<void>();
        fixture.notifications.failingAttempts.add(2);
        fixture.invalidate();
        fixture.start();
        await tester.pumpAndSettle();
        expect(fixture.notifications.cancellations, 1);
        Future<void>? refresh;
        if (newEvent) {
          fixture.invalidate();
        } else {
          refresh = fixture.container.read(fitnessLifecycleProvider)();
        }
        await tester.pumpAndSettle();
        fixture.notifications.firstCancellation!.complete();
        await tester.pumpAndSettle();
        await refresh;
        expect(fixture.notifications.cancellations, 2);
        expect(fixture.pendingInvalidation, isTrue);
        expect(
          fixture.container
              .read(accountReminderInvalidationProvider)
              .handledGeneration(AccountReminderKind.fitness),
          0,
        );
        await fixture.container.read(fitnessLifecycleProvider)();
        expect(fixture.pendingInvalidation, isFalse);
      } finally {
        await fixture.dispose();
        await tester.pump(const Duration(seconds: 3));
      }
    });
  }

  testWidgets('正常缓存身份恢复和同账号刷新不会清理尚未加载的休息任务', (tester) async {
    final fixture = _Fixture();
    try {
      fixture.container
          .read(accountStateProvider.notifier)
          .restorePending(userId: 'account-a');
      fixture.start();
      await tester.pumpAndSettle();
      fixture.container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'restored',
              userId: 'account-a',
              deviceId: 'device',
            ),
            preserveIdentity: true,
          );
      await tester.pumpAndSettle();
      fixture.container
          .read(authSessionProvider.notifier)
          .updateToken('refreshed');
      await tester.pumpAndSettle();
      expect(fixture.notifications.pending, isTrue);
      expect(fixture.notifications.cancellations, 0);
      expect(fixture.pendingInvalidation, isFalse);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });

  testWidgets('失效清理期间到达的当前训练数据在确认后恢复排期', (tester) async {
    final fixture = _Fixture();
    try {
      fixture.notifications.firstCancellation = Completer<void>();
      fixture.invalidate();
      fixture.start();
      await tester.pumpAndSettle();
      fixture.publishWorkout();
      await tester.pumpAndSettle();
      fixture.notifications.firstCancellation!.complete();
      await tester.pumpAndSettle();
      expect(fixture.pendingInvalidation, isFalse);
      expect(fixture.notifications.scheduled, 1);
      expect(fixture.notifications.pending, isTrue);
    } finally {
      await fixture.dispose();
      await tester.pump(const Duration(seconds: 3));
    }
  });
}
