import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

const exerciseId = '11111111-1111-4111-8111-111111111111';
const setIdA = '22222222-2222-4222-8222-222222222222';
const setIdB = '33333333-3333-4333-8333-333333333333';
const setIdC = '44444444-4444-4444-8444-444444444444';
const setIdD = '55555555-5555-4555-8555-555555555555';

/// 构造同一目录动作下具有稳定身份的组，核对口径迁移时的内容完整性。
FitnessExercise exercise(List<FitnessSet> sets) =>
    FitnessExercise(id: exerciseId, exerciseId: '0025', sets: sets);

/// 重量口径切换必须保留输入、组身份、其他动作和原始快照。
void main() {
  group('当前草稿的动作重量口径', () {
    test('重复目录动作全部迁移，保留实例顺序、组状态和其他动作', () {
      final source = [
        exercise(const [
          FitnessSet(
            id: setIdA,
            kind: 'warmup',
            weight: '20',
            reps: 8,
            completed: true,
            restDurationsSeconds: [15, 20],
          ),
        ]).copyWith(restSeconds: 45, warmupRestSeconds: 25),
        const FitnessExercise(
          id: setIdC,
          exerciseId: '0289',
          sets: [FitnessSet(id: setIdD, weight: '99', reps: 10)],
        ),
        const FitnessExercise(
          id: setIdB,
          exerciseId: '0025',
          restSeconds: 120,
          warmupRestSeconds: 60,
          sets: [FitnessSet(id: setIdC, weight: '30', reps: 9)],
        ),
      ];
      final original = source.map((item) => item.toJson()).toList();

      final result = fitnessSetExerciseWeightMode(
        source,
        exerciseId: '0025',
        sideWeight: true,
      );

      expect(result.map((item) => item.id), [exerciseId, setIdC, setIdB]);
      expect(result[1], same(source[1]));
      expect(result[0].restSeconds, 45);
      expect(result[0].warmupRestSeconds, 25);
      expect(result[2].restSeconds, 120);
      expect(result[2].warmupRestSeconds, 60);
      expect(result[0].sets.single.toJson(), {
        'id': setIdA,
        'kind': 'warmup',
        'weight': null,
        'weight_left': '20',
        'weight_right': '20',
        'reps': 8,
        'completed': true,
        'rest_durations_seconds': [15, 20],
      });
      expect(result[2].sets.single.toJson(), {
        'id': setIdC,
        'kind': 'working',
        'weight': null,
        'weight_left': '30',
        'weight_right': '30',
        'reps': 9,
        'completed': false,
        'rest_durations_seconds': [],
      });
      expect(source.map((item) => item.toJson()).toList(), original);
      result.removeLast();
      expect(source, hasLength(3));
    });

    test('切到左右保留不同侧重、未填侧和空组，不填造重量', () {
      final source = [
        exercise(const [
          FitnessSet(id: setIdA, reps: 5),
          FitnessSet(id: setIdB, weightLeft: '5', weightRight: '8', reps: 8),
          FitnessSet(id: setIdC, weightLeft: '7', reps: 9),
          FitnessSet(id: setIdD, weightRight: '11', reps: 10),
        ]),
      ];

      final result = fitnessSetExerciseWeightMode(
        source,
        exerciseId: '0025',
        sideWeight: true,
      );

      expect(
        result.single.sets.map(
          (set) => [set.weight, set.weightLeft, set.weightRight],
        ),
        [
          [null, null, null],
          [null, '5', '8'],
          [null, '7', null],
          [null, null, '11'],
        ],
      );
      expect(result.single.sets.map((set) => set.id), [
        setIdA,
        setIdB,
        setIdC,
        setIdD,
      ]);
      expect(result.single.sets.map((set) => set.reps), [5, 8, 9, 10]);
    });

    test('切回总重清空所有匹配实例的左右值，已有总重不换算', () {
      final source = [
        exercise(const [
          FitnessSet(id: setIdA, weightLeft: '5', weightRight: '8', reps: 8),
          FitnessSet(id: setIdB, weight: '20', reps: 9),
        ]),
        const FitnessExercise(
          id: setIdC,
          exerciseId: '0025',
          sets: [FitnessSet(id: setIdD, weightRight: '11', reps: 10)],
        ),
      ];
      final original = source.map((item) => item.toJson()).toList();

      final result = fitnessSetExerciseWeightMode(
        source,
        exerciseId: '0025',
        sideWeight: false,
      );

      expect(
        result
            .expand((item) => item.sets)
            .map((set) => [set.weight, set.weightLeft, set.weightRight]),
        [
          [null, null, null],
          ['20', null, null],
          [null, null, null],
        ],
      );
      expect(source.map((item) => item.toJson()).toList(), original);
    });
  });
}
