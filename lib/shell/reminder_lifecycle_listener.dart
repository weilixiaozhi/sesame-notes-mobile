import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/clock/local_clock.dart';
import '../core/logging/logger_service.dart';
import '../features/days/application/day_reminder_lifecycle.dart';
import '../features/fitness/application/fitness_lifecycle.dart';
import '../shared/services/reminder_monitor_service.dart';

/// 按系统时钟事件重排提醒；时区变化即使没有跨日，也必须重新读取当地规则。
final reminderClockLifecycleProvider = Provider<void>((ref) {
  var pending = Future<void>.value();

  /// 串行恢复主提醒和纪念日，确保原生调度读取到本轮最新时区。
  Future<void> restore() async {
    try {
      if (!ref.mounted) return;
      if (!await ReminderMonitorService().restoreReminder()) return;
      if (!ref.mounted) return;
      await ref.read(dayReminderLifecycleProvider)();
    } catch (error, stack) {
      logger.error('ReminderClock', '系统时间变化后的提醒更新失败，恢复前台时重试', error, stack);
    }
  }

  // 日期展示和提醒编排共享同一条广播流，避免重复订阅原生通道替换事件接收器。
  final subscription = ref
      .watch(clockChangeEventsProvider)
      .listen(
        (_) => pending = pending.then((_) => restore()),
        onError: (Object error, StackTrace stack) {
          logger.error('ReminderClock', '系统时间通知暂不可用，恢复前台时重新核对提醒', error, stack);
        },
      );

  /// 释放原生事件订阅，平台取消异常只记录日志，不打断应用容器销毁。
  Future<void> stop() async {
    try {
      await subscription.cancel();
    } catch (error, stack) {
      logger.error('ReminderClock', '释放系统时间监听失败', error, stack);
    }
  }

  ref.onDispose(() => unawaited(stop()));
});

/// 导航器上层持续订阅提醒，页面不可见时仍把数据变化提交给系统。
class ReminderLifecycleListener extends ConsumerWidget {
  /// 仅在本地初始化完成后装配通知与系统时钟监听。
  const ReminderLifecycleListener({super.key, required this.enabled});
  final bool enabled;

  /// 持续保活业务提醒和时钟恢复入口，页面切换不会中断订阅。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (enabled) {
      ref.watch(fitnessLifecycleProvider);
      ref.watch(dayReminderLifecycleProvider);
      ref.watch(reminderClockLifecycleProvider);
    }
    return const SizedBox.shrink();
  }
}
