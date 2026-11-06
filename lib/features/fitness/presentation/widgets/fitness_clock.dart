import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

import '../../application/fitness_providers.dart';
import 'fitness_widgets.dart';

/// 秒表只唤醒仍在变化的显示；真实时间始终重新读取，恢复页面后无需补计秒数。
DateTime fitnessDisplayNow(
  WidgetRef ref, {
  required bool ticking,
  DateTime? until,
}) {
  final now = ref.watch(localClockNowProvider)();
  if (ticking && (until == null || until.isAfter(now))) {
    ref.watch(fitnessClockProvider);
  }
  return now;
}

/// 时长文本独立订阅秒表，训练内容与编辑器不参与每秒重建。
class FitnessWorkoutElapsedText extends ConsumerWidget {
  /// 调用方沿用当前入口的文字样式。
  const FitnessWorkoutElapsedText({
    super.key,
    required this.workout,
    this.style,
  });

  final FitnessWorkout workout;
  final TextStyle? style;

  /// 暂停、未开始和已完成训练只展示持久化时间段，不启动周期任务。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = fitnessDisplayNow(
      ref,
      ticking:
          workout.status == 'in_progress' &&
          workout.runSegments.isNotEmpty &&
          workout.runSegments.last.endedAt == null,
    );
    return Text(
      fitnessDuration(fitnessElapsed(workout, now).inSeconds),
      style: style,
    );
  }
}

/// 只在休息倒计时尚未结束时重建局部内容，到期那一帧同时释放时钟订阅。
class FitnessRestClock extends ConsumerWidget {
  /// 构建器可以呈现倒计时或提交一次到期提示，保持外层静态内容不变。
  const FitnessRestClock({
    super.key,
    required this.timer,
    required this.builder,
  });

  final FitnessRestTimer? timer;
  final Widget Function(BuildContext context, DateTime now) builder;

  /// 暂停状态的剩余秒数来自持久化快照，不依赖当前时间流逝。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = fitnessDisplayNow(
      ref,
      ticking: timer?.status == 'running',
      until: timer?.endsAt,
    );
    return builder(context, now);
  }
}
