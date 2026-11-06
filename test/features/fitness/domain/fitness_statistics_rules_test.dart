import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';

const setId = '11111111-1111-4111-8111-111111111111';
const exerciseInstanceId = '22222222-2222-4222-8222-222222222222';

FitnessExercise checkedExercise([String exerciseId = '0025']) =>
    FitnessExercise(
      id: exerciseInstanceId,
      exerciseId: exerciseId,
      sets: const [
        FitnessSet(id: setId, weight: '20', reps: 8, completed: true),
      ],
    );

/// 训练区间固定从当天 12:00 UTC 起算，本地日期与安排日一致。
FitnessWorkout workout({
  required String id,
  required String date,
  required int minutes,
  String status = 'completed',
  List<FitnessExercise> exercises = const [],
  FitnessRestTimer? restTimer,
}) {
  final start = DateTime.parse('${date}T12:00:00.000Z');
  return FitnessWorkout(
    id: id,
    name: '训练 $id',
    scheduledDate: date,
    status: status,
    exercises: exercises,
    restTimer: restTimer,
    runSegments: [
      FitnessRunSegment(
        startedAt: start,
        endedAt: status == 'completed'
            ? start.add(Duration(minutes: minutes))
            : null,
      ),
    ],
  );
}

FitnessExerciseDefinition definition(String id, String bodyPart) =>
    FitnessExerciseDefinition(
      id: id,
      nameZh: '动作$id',
      nameZhHant: '動作$id',
      nameEn: 'Exercise $id',
      bodyPart: bodyPart,
      target: 'target-$id',
      equipment: 'barbell',
      gifAsset: '',
      secondaryMuscles: const [],
      instructionsZh: const [],
      instructionsZhHant: const [],
      instructionsEn: const [],
    );

void main() {
  group('完成组统计契约', () {
    for (final set in [
      const FitnessSet(id: setId, completed: true),
      const FitnessSet(id: setId, reps: 0, completed: true),
      const FitnessSet(id: setId, reps: 8, weightLeft: '5', completed: true),
      const FitnessSet(id: setId, reps: 8, weight: 'NaN', completed: true),
      const FitnessSet(id: setId, kind: 'warmup', completed: true),
    ]) {
      test('非法完成组不能被统计省略：${set.toJson()}', () {
        final invalid = workout(
          id: 'invalid',
          date: '2026-03-02',
          minutes: 30,
          exercises: [
            FitnessExercise(
              id: exerciseInstanceId,
              exerciseId: '0025',
              sets: [set],
            ),
          ],
        );
        expect(
          () => fitnessStatistics(
            [invalid],
            startDate: '2026-03-01',
            endDate: '2026-03-31',
          ),
          throwsA(isA<FitnessValidationException>()),
        );
      });
    }

    test('未完成单边草稿、自重和目录缺失历史保留各自语义', () {
      final stats = fitnessStatistics(
        [
          workout(
            id: 'history',
            date: '2026-03-02',
            minutes: 30,
            exercises: [
              FitnessExercise(
                id: exerciseInstanceId,
                exerciseId: 'historical-exercise',
                sets: const [
                  FitnessSet(id: 'draft', weightLeft: '5'),
                  FitnessSet(id: 'body', reps: 8, completed: true),
                  FitnessSet(
                    id: 'weighted',
                    weight: '20',
                    reps: 8,
                    completed: true,
                  ),
                ],
              ),
            ],
          ),
        ],
        startDate: '2026-03-01',
        endDate: '2026-03-31',
      );
      expect(stats.trainingDays, 1);
      expect(stats.totalDuration, const Duration(minutes: 30));
      expect(stats.volumeKg.toString(), '160');
      expect(stats.bodyPartVolumeKg, isEmpty);
    });
  });

  group('训练时长序列', () {
    test('逐日序列缺日断点、同日多次训练合并、零时长记为 0', () {
      final stats = fitnessStatistics(
        [
          workout(
            id: 'a',
            date: '2026-03-02',
            minutes: 60,
            exercises: [checkedExercise()],
          ),
          workout(id: 'b', date: '2026-03-02', minutes: 30),
          // 已结束但没有勾选组的训练保留时长，不计训练天数。
          workout(id: 'c', date: '2026-03-04', minutes: 0),
        ],
        startDate: '2026-03-01',
        endDate: '2026-03-05',
      );
      final values = fitnessDurationSeries(
        stats.durationByDate,
        dates: [
          '2026-03-01',
          '2026-03-02',
          '2026-03-03',
          '2026-03-04',
          '2026-03-05',
        ],
      );
      expect(values[0].isNaN, isTrue);
      expect(values[1], 1.5);
      expect(values[2].isNaN, isTrue);
      expect(values[3], 0);
      expect(values[4].isNaN, isTrue);
      expect(stats.trainingDays, 1);
    });

    test('周视图七天刻度只在训练日有值', () {
      final stats = fitnessStatistics(
        [workout(id: 'a', date: '2026-03-04', minutes: 60)],
        startDate: '2026-03-02',
        endDate: '2026-03-08',
      );
      final values = fitnessDurationSeries(
        stats.durationByDate,
        dates: [
          for (var day = 2; day <= 8; day++)
            '2026-03-${day.toString().padLeft(2, '0')}',
        ],
      );
      expect(values, hasLength(7));
      expect(values[2], 1);
      expect(values.where((value) => !value.isNaN), [1]);
    });

    test('年视图按自然月合并同月多天，范围外记录不参与', () {
      const year = 2026;
      final stats = fitnessStatistics(
        [
          workout(id: 'a', date: '$year-01-01', minutes: 60),
          workout(id: 'b', date: '$year-01-01', minutes: 30),
          workout(id: 'c', date: '$year-01-31', minutes: 120),
          workout(id: 'd', date: '$year-02-01', minutes: 90),
          workout(id: 'outside', date: '${year - 1}-12-31', minutes: 600),
        ],
        startDate: '$year-01-01',
        endDate: '$year-12-31',
      );
      final values = fitnessDurationSeries(
        stats.durationByDate,
        dates: [
          for (var month = 1; month <= 12; month++)
            fitnessDate(DateTime(year, month)),
        ],
        monthly: true,
      );
      expect(values, hasLength(12));
      expect(values[0], 3.5);
      expect(values[1], 1.5);
      expect(values.skip(2).every((value) => value.isNaN), isTrue);
      expect(stats.totalDuration, const Duration(hours: 5));
      expect(stats.durationByDate.containsKey('${year - 1}-12-31'), isFalse);
    });
  });

  group('动作历史', () {
    test('只列有勾选组的训练，进行中同样计入并按归属日倒序', () {
      final history = fitnessExerciseHistory(
        [
          workout(
            id: 'checked',
            date: '2026-09-12',
            minutes: 30,
            exercises: [
              FitnessExercise(
                id: exerciseInstanceId,
                exerciseId: '0025',
                sets: const [
                  FitnessSet(id: setId, weight: '20', reps: 8, completed: true),
                  FitnessSet(id: 'other-set', weight: '999', reps: 99),
                ],
              ),
            ],
          ),
          workout(
            id: 'none',
            date: '2026-09-13',
            minutes: 30,
            exercises: [
              FitnessExercise(
                id: exerciseInstanceId,
                exerciseId: '0025',
                sets: const [FitnessSet(id: setId, weight: '999', reps: 99)],
              ),
            ],
          ),
          workout(
            id: 'running',
            date: '2026-09-14',
            minutes: 0,
            status: 'in_progress',
            exercises: [checkedExercise()],
          ),
        ],
        '0025',
        now: DateTime.utc(2026, 9, 14, 12),
      );
      expect(history.map((item) => item.id), ['running', 'checked']);
    });

    test('到期的末组休息合成真实时长且不写回组数据', () {
      final start = DateTime.utc(2026, 9, 12, 12);
      final running = workout(
        id: 'running',
        date: '2026-09-12',
        minutes: 0,
        status: 'in_progress',
        exercises: [checkedExercise()],
        restTimer: FitnessRestTimer(
          exerciseId: exerciseInstanceId,
          setId: setId,
          elapsedSeconds: 10,
          remainingSeconds: 30,
          durationSeconds: 30,
          endsAt: start.add(const Duration(seconds: 30)),
        ),
      );
      final history = fitnessExerciseHistory(
        [running],
        '0025',
        now: start.add(const Duration(minutes: 2)),
      );
      final settled = history.single;
      expect(settled.exercises.single.sets.single.restDurationsSeconds, [40]);
      expect(settled.restTimer, isNull);
      // 展示用的合成结果不改写原训练，计时状态仍由仓库持有。
      expect(
        running.exercises.single.sets.single.restDurationsSeconds,
        isEmpty,
      );
      expect(running.restTimer, isNotNull);
      // 未到期的休息不合成时长，历史直接呈现计时进行中。
      final counting = fitnessExerciseHistory(
        [running],
        '0025',
        now: start.add(const Duration(seconds: 10)),
      ).single;
      expect(counting.restTimer, isNotNull);
      expect(
        counting.exercises.single.sets.single.restDurationsSeconds,
        isEmpty,
      );
    });
  });

  group('动作列表排序', () {
    final chest = definition('0001', 'chest');
    final back = definition('0002', 'back');
    final legs = definition('0003', 'upper legs');
    final catalog = [chest, back, legs];
    List<String> order(List<String> pinned, {List<String>? recentOrder}) =>
        fitnessSortExercises(
          catalog,
          catalog: catalog,
          pinnedIds: pinned,
          recentOrder: recentOrder,
        ).map((item) => item.id).toList();

    test('默认按部位分组顺序、组内保持目录原序', () {
      final samePart = definition('0004', 'chest');
      final mixed = [chest, back, samePart, legs];
      expect(
        fitnessSortExercises(
          mixed,
          catalog: mixed,
          pinnedIds: const [],
        ).map((item) => item.id),
        ['0001', '0004', '0002', '0003'],
      );
    });

    test('置顶排最前，取消置顶回到部位顺序', () {
      expect(order(const []), ['0001', '0002', '0003']);
      expect(order(const ['0003']), ['0003', '0001', '0002']);
      expect(order(const []), ['0001', '0002', '0003']);
    });

    test('最近使用筛选按最近顺序排列，置顶仍然优先', () {
      // 最近使用筛选下列表项都来自最近记录，未置顶动作按最近顺序排列。
      expect(order(const [], recentOrder: const ['0003', '0001', '0002']), [
        '0003',
        '0001',
        '0002',
      ]);
      expect(
        order(const ['0002'], recentOrder: const ['0003', '0001', '0002']),
        ['0002', '0003', '0001'],
      );
    });
  });
}
