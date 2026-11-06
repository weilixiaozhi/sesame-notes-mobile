import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';

/// 用真实运行片段表达已完成、暂停和跨午夜训练。
FitnessWorkout _workout(
  String id,
  String scheduledDate,
  String status, [
  List<FitnessRunSegment> segments = const [],
]) => FitnessWorkout(
  id: id,
  name: id,
  scheduledDate: scheduledDate,
  status: status,
  runSegments: segments,
);

/// 使用逐日查询核对区间投影的日期归属、训练状态和去重规则。
void main() {
  test('一次区间投影与逐日查询一致，包含暂停间隙、跨午夜和重复状态', () {
    try {
      final start = DateTime(2026, 11, 1);
      final until = DateTime(2026, 11, 9);
      final now = DateTime(2026, 11, 7, 12);
      final data = [
        _workout('z-running', '2026-11-01', 'in_progress', [
          FitnessRunSegment(startedAt: DateTime(2026, 11, 4, 23)),
        ]),
        _workout('a-paused', '2026-11-02', 'in_progress', [
          FitnessRunSegment(
            startedAt: DateTime(2026, 11, 2, 9),
            endedAt: DateTime(2026, 11, 3, 1),
          ),
          FitnessRunSegment(
            startedAt: DateTime(2026, 11, 5, 22),
            endedAt: DateTime(2026, 11, 6, 1),
          ),
        ]),
        _workout('done', '2026-10-30', 'completed', [
          FitnessRunSegment(
            startedAt: DateTime(2026, 10, 31, 23),
            endedAt: DateTime(2026, 11, 2, 1),
          ),
        ]),
        _workout('planned', '2026-11-07', 'scheduled'),
        _workout('planned-again', '2026-11-07', 'scheduled'),
        _workout('outside', '2026-11-09', 'scheduled'),
      ];
      final projected = fitnessCalendarWorkoutStatuses(
        data,
        start: start,
        until: until,
        now: now,
      );
      for (
        var date = start;
        date.isBefore(until);
        date = DateTime(date.year, date.month, date.day + 1)
      ) {
        final expected = {
          for (final workout in fitnessWorkoutsOnDate(
            data,
            fitnessDate(date),
            now: now,
          ))
            (
              status: workout.status,
              paused:
                  workout.status == 'in_progress' &&
                  workout.runSegments.isNotEmpty &&
                  workout.runSegments.last.endedAt != null,
            ),
        }.toList();
        expect(
          projected[fitnessDate(date)] ?? [],
          expected,
          reason: '日期${fitnessDate(date)}的状态、去重和顺序须与明细一致',
        );
      }
      expect(projected.containsKey('2026-10-30'), isFalse);
      expect(projected.containsKey('2026-11-09'), isFalse);
      expect(
        projected['2026-11-04']!.any((state) => state.paused),
        isFalse,
        reason: '暂停间隙不能被投影为训练日',
      );
    } catch (error, stackTrace) {
      debugPrint('健身日历区间投影回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('跨多年运行区间仅生成可见日期', () {
    try {
      final projected = fitnessCalendarWorkoutStatuses(
        [
          _workout('long', '1900-01-01', 'completed', [
            FitnessRunSegment(
              startedAt: DateTime(1900),
              endedAt: DateTime(2200, 12, 31),
            ),
          ]),
        ],
        start: DateTime(2026, 11, 1),
        until: DateTime(2026, 11, 8),
        now: DateTime(2026, 11, 6),
      );
      expect(projected.keys, [
        for (var day = 1; day <= 7; day++)
          '2026-11-${day.toString().padLeft(2, '0')}',
      ]);
      expect(projected.values.every((values) => values.length == 1), isTrue);
    } catch (error, stackTrace) {
      debugPrint('健身跨年投影边界回归失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
