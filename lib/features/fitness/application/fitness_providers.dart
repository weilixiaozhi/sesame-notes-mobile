import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/shared/providers/fitness_repository_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';

import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

/// 健身统计与外壳周期入口共享选择，各业务分别保留当前周期。
final fitnessAnalyticsPeriodProvider =
    NotifierProvider<SimpleStateNotifier<AnalyticsPeriod>, AnalyticsPeriod>(
      () => SimpleStateNotifier((ref) => AnalyticsPeriod.month),
    );

// 页面订阅账号隔离仓库，切换身份后由依赖关系重新订阅。
// 计划与模板按最近更新优先输出，首页预览与完整列表共用同一顺序。
final fitnessTemplatesProvider =
    StreamProvider.autoDispose<List<FitnessTemplate>>(
      (ref) => ref
          .watch(fitnessQueryRepositoryProvider)
          .watchTemplates()
          .map(
            (items) =>
                fitnessSortByRecent(items, (t) => t.updatedAt ?? t.createdAt),
          ),
    );
final fitnessPlansProvider = StreamProvider.autoDispose<List<FitnessPlan>>(
  (ref) => ref
      .watch(fitnessQueryRepositoryProvider)
      .watchPlans()
      .map(
        (items) =>
            fitnessSortByRecent(items, (p) => p.updatedAt ?? p.createdAt),
      ),
);
final fitnessCalendarPlansProvider =
    StreamProvider.autoDispose<List<FitnessPlan>>(
      (ref) => ref
          .watch(fitnessQueryRepositoryProvider)
          .watchPlans(includeDeleted: true),
    );
final fitnessPreferencesProvider =
    StreamProvider.autoDispose<FitnessPreferences>(
      (ref) => ref.watch(fitnessQueryRepositoryProvider).watchPreferences(),
    );

/// 只驱动显示重绘；真实运行时间与休息截止时间由仓库保存。
final fitnessClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

final fitnessWorkoutProvider = StreamProvider.autoDispose
    .family<FitnessWorkout?, String>(
      (ref, id) => ref.watch(fitnessQueryRepositoryProvider).watchWorkout(id),
    );
final fitnessRunningWorkoutProvider = StreamProvider<FitnessWorkout?>(
  (ref) => ref.watch(fitnessQueryRepositoryProvider).watchRunningWorkout(),
);
final fitnessRecentExerciseIdsProvider =
    StreamProvider.autoDispose<List<String>>(
      (ref) =>
          ref.watch(fitnessQueryRepositoryProvider).watchRecentExerciseIds(),
    );

typedef FitnessWorkoutRange = ({DateTime start, DateTime until, bool calendar});
final fitnessWorkoutsInRangeProvider = StreamProvider.autoDispose
    .family<List<FitnessWorkout>, FitnessWorkoutRange>(
      (ref, range) => ref
          .watch(fitnessQueryRepositoryProvider)
          .watchWorkoutsInRange(
            range.start,
            range.until,
            calendar: range.calendar,
          ),
    );
final fitnessWorkoutBoundsProvider =
    StreamProvider.autoDispose<({DateTime? earliest, DateTime? latest})>(
      (ref) => ref.watch(fitnessQueryRepositoryProvider).watchWorkoutBounds(),
    );
final fitnessExerciseHistoryProvider = StreamProvider.autoDispose
    .family<List<FitnessWorkout>, ({String exerciseId, int limit})>(
      (ref, query) => ref
          .watch(fitnessQueryRepositoryProvider)
          .watchExerciseHistory(query.exerciseId, limit: query.limit),
    );
