import 'package:decimal/decimal.dart';

import '../../../data/models/fitness.dart';
import '../../../data/models/fitness_catalog.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'fitness_anatomy.dart';

class FitnessStatistics {
  final int trainingDays;
  final Duration totalDuration;
  final Decimal volumeKg;
  final Map<String, Duration> durationByDate;
  final Map<String, Decimal> bodyPartVolumeKg;
  final Map<String, Decimal> anatomyVolumeKg;
  final Map<String, Map<String, Decimal>> anatomyCategoryVolumeKg;
  final Set<String> trainedMuscles;
  const FitnessStatistics({
    required this.trainingDays,
    required this.totalDuration,
    required this.volumeKg,
    required this.durationByDate,
    required this.bodyPartVolumeKg,
    required this.anatomyVolumeKg,
    required this.anatomyCategoryVolumeKg,
    required this.trainedMuscles,
  });
}

/// 范围两端均包含。零组结束保留时长，但不计训练天数。
FitnessStatistics fitnessStatistics(
  List<FitnessWorkout> workouts, {
  required String startDate,
  required String endDate,
  Map<String, FitnessExerciseDefinition> catalog = const {},
}) {
  workouts = {
    for (final workout in workouts) workout.id: workout,
  }.values.toList();
  fitnessParseDate(startDate);
  fitnessParseDate(endDate);
  fitnessRequire(startDate.compareTo(endDate) <= 0, 'FITNESS_DATE_RANGE');
  final completed = workouts
      .where(
        (w) =>
            w.status == 'completed' &&
            fitnessWorkoutDate(w).compareTo(startDate) >= 0 &&
            fitnessWorkoutDate(w).compareTo(endDate) <= 0,
      )
      .toList();
  var duration = Duration.zero, volume = Decimal.zero;
  final days = <String>{},
      byDate = <String, Duration>{},
      parts = <String, Decimal>{},
      anatomy = <String, Decimal>{},
      anatomyCategories = <String, Map<String, Decimal>>{},
      trainedMuscles = <String>{};
  for (final w in completed) {
    final date = fitnessWorkoutDate(w),
        elapsed = fitnessElapsed(w, w.runSegments.last.endedAt!);
    duration += elapsed;
    byDate[date] = (byDate[date] ?? Duration.zero) + elapsed;
    for (final e in w.exercises) {
      for (final s in e.sets) {
        if (!s.completed) continue;
        // 计算入口核验已完成成绩，错误不能被过滤为少算的正常报表。
        final v = fitnessSetVolume(s);
        days.add(date);
        if (s.kind == 'warmup') continue;
        volume += v;
        final definition = catalog[e.exerciseId];
        // 目录分类保存稳定业务标识；人体图按主训练肌群单独聚合，避免分类迁移导致归零。
        if (definition != null &&
            definition.bodyPart != 'cardio' &&
            definition.target != 'cardiovascular system' &&
            definition.target != 'cardio') {
          trainedMuscles.add(definition.target);
          parts[definition.bodyPart] =
              (parts[definition.bodyPart] ?? Decimal.zero) + v;
          final region = fitnessMuscleBodyPart(definition.target);
          if (fitnessAnatomyParts.contains(region)) {
            anatomy[region] = (anatomy[region] ?? Decimal.zero) + v;
            final categories = anatomyCategories.putIfAbsent(region, () => {});
            categories[definition.bodyPart] =
                (categories[definition.bodyPart] ?? Decimal.zero) + v;
          }
        }
      }
    }
  }
  return FitnessStatistics(
    trainingDays: days.length,
    totalDuration: duration,
    volumeKg: volume,
    durationByDate: byDate,
    bodyPartVolumeKg: parts,
    anatomyVolumeKg: anatomy,
    anatomyCategoryVolumeKg: anatomyCategories,
    trainedMuscles: trainedMuscles,
  );
}

class FitnessRestDay {
  final String date, sourcePlanId, sourcePlanName;
  const FitnessRestDay({
    required this.date,
    required this.sourcePlanId,
    required this.sourcePlanName,
  });
}

List<FitnessRestDay> fitnessCalendarRestDays(List<FitnessPlan> plans) {
  final result = <FitnessRestDay>[];
  for (final plan in plans) {
    final dates = <String>{};
    final cycles = [...plan.generationState.generatedCycles]
      ..sort((a, b) => a.cycleIndex.compareTo(b.cycleIndex));
    for (final cycle in cycles) {
      final end = fitnessAddDays(cycle.startDate, cycle.cycleDays);
      // 重新开始的周期覆盖日期归属，旧休息日不能与新训练同时显示。
      dates.removeWhere(
        (date) =>
            date.compareTo(cycle.generatedFromDate) >= 0 &&
            date.compareTo(end) < 0,
      );
      dates.addAll(cycle.restDates);
    }
    result.addAll(
      dates.map(
        (date) => FitnessRestDay(
          date: date,
          sourcePlanId: plan.id,
          sourcePlanName: plan.name,
        ),
      ),
    );
  }
  return result;
}

/// 时长折线的数值序列：按刻度日期取训练时长（小时），没有记录的刻度留缺失值形成断点。
/// [monthly] 为真时按自然月合并同月多天，否则按天合并同日多次训练；范围外记录已由统计排除。
List<double> fitnessDurationSeries(
  Map<String, Duration> durationByDate, {
  required List<String> dates,
  bool monthly = false,
}) {
  final hours = <String, double>{};
  for (final entry in durationByDate.entries) {
    final date = monthly ? '${entry.key.substring(0, 7)}-01' : entry.key;
    hours[date] =
        (hours[date] ?? 0) +
        entry.value.inMicroseconds / Duration.microsecondsPerHour;
  }
  return [for (final date in dates) hours[date] ?? double.nan];
}

typedef FitnessDateRange = ({String startDate, String endDate});
FitnessDateRange fitnessDateRange(DateTime day, String period) =>
    switch (period) {
      'week' => (
        startDate: fitnessDate(
          DateTime(day.year, day.month, day.day - day.weekday + 1),
        ),
        endDate: fitnessDate(
          DateTime(day.year, day.month, day.day - day.weekday + 7),
        ),
      ),
      'month' => (
        startDate: fitnessDate(DateTime(day.year, day.month)),
        endDate: fitnessDate(DateTime(day.year, day.month + 1, 0)),
      ),
      'year' => (
        startDate: fitnessDate(DateTime(day.year)),
        endDate: fitnessDate(DateTime(day.year, 12, 31)),
      ),
      _ => throw const FitnessValidationException('FITNESS_DATE_RANGE'),
    };

/// 首页按选择日查询，安排日、实际开始日与归档日均可追溯，同一训练只显示一次。
List<FitnessWorkout> fitnessWorkoutsOnDate(
  List<FitnessWorkout> workouts,
  String date, {
  DateTime? now,
}) {
  fitnessParseDate(date);
  final current = now ?? DateTime.now();
  final rank = {'in_progress': 0, 'completed': 1, 'scheduled': 2};
  final result = workouts
      .where(
        (w) =>
            w.scheduledDate == date ||
            fitnessWorkoutDate(w) == date ||
            w.runSegments.any(
              (s) =>
                  fitnessDate(s.startedAt.toLocal()).compareTo(date) <= 0 &&
                  fitnessDate(
                        (s.endedAt ?? current).toLocal(),
                      ).compareTo(date) >=
                      0,
            ),
      )
      .toList();
  result.sort((a, b) {
    final status = rank[a.status]!.compareTo(rank[b.status]!);
    return status != 0 ? status : a.id.compareTo(b.id);
  });
  return result;
}

/// 动作历史：只保留该动作有勾选组的训练，进行中的训练同样计入；
/// 到期的最后一次休息按持久化计时状态合成真实时长，最后按训练归属日倒序。
List<FitnessWorkout> fitnessExerciseHistory(
  List<FitnessWorkout> workouts,
  String exerciseId, {
  required DateTime now,
}) {
  final history = <FitnessWorkout>[];
  for (final workout in workouts) {
    final matched = workout.exercises.where((e) => e.exerciseId == exerciseId);
    if (!matched.any((e) => e.sets.any((s) => s.completed))) continue;
    // 到期的最后一次休息可由持久化计时状态还原，无须等下一组写入，也不写回组数据。
    history.add(
      workout.restTimer?.status == 'running' &&
              fitnessRestRemaining(workout.restTimer, now) == 0
          ? fitnessSettleRest(workout, now)
          : workout,
    );
  }
  history.sort(
    (a, b) => fitnessWorkoutDate(b).compareTo(fitnessWorkoutDate(a)),
  );
  return history;
}
