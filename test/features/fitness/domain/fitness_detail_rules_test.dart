import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

const exerciseId = '11111111-1111-4111-8111-111111111111';
const setIdA = '22222222-2222-4222-8222-222222222222';
const setIdB = '33333333-3333-4333-8333-333333333333';
const setIdC = '44444444-4444-4444-8444-444444444444';
const setIdD = '55555555-5555-4555-8555-555555555555';

final now = DateTime.utc(2026, 9, 14, 12);

FitnessExercise exercise(List<FitnessSet> sets) =>
    FitnessExercise(id: exerciseId, exerciseId: '0025', sets: sets);

FitnessRestTimer timer({
  DateTime? endsAt,
  String status = 'running',
  int remainingSeconds = 10,
  int durationSeconds = 10,
  int elapsedSeconds = 0,
  String? setId = setIdA,
}) => FitnessRestTimer(
  status: status,
  endsAt: status == 'running'
      ? endsAt ?? now.add(const Duration(seconds: 10))
      : null,
  remainingSeconds: remainingSeconds,
  durationSeconds: durationSeconds,
  elapsedSeconds: elapsedSeconds,
  exerciseId: setId == null ? null : exerciseId,
  setId: setId,
);

FitnessWorkout workout({
  FitnessRestTimer? restTimer,
  String status = 'in_progress',
  String setId = setIdA,
  bool completed = true,
}) => FitnessWorkout(
  id: setIdB,
  name: '训练',
  scheduledDate: '2026-09-14',
  status: status,
  runSegments: [FitnessRunSegment(startedAt: now)],
  exercises: [
    FitnessExercise(
      id: exerciseId,
      exerciseId: '0025',
      sets: [
        FitnessSet(id: setId, weight: '20', reps: 8, completed: completed),
      ],
    ),
  ],
  restTimer: restTimer,
);

void main() {
  group('键盘一键改', () {
    test('向下批量修改包含本行，只改同类型组与当前维度', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, kind: 'warmup', weight: '5', reps: 5),
        FitnessSet(id: setIdB, weight: '20', reps: 8),
        FitnessSet(id: setIdC, weight: '30', reps: 9),
        FitnessSet(id: setIdD, weight: '40', reps: 10),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 1,
        field: 'weight',
        value: '35',
        action: 'below',
      );
      // 含本行向下写入正式组，热身组与其它字段不变。
      expect(sets.map((s) => s.weight), ['5', '35', '35', '35']);
      expect(sets.map((s) => s.reps), [5, 8, 9, 10]);
      expect(sets.map((s) => s.id), [setIdA, setIdB, setIdC, setIdD]);
      expect(sets.map((s) => s.kind), [
        'warmup',
        'working',
        'working',
        'working',
      ]);
    });

    test('向上批量修改包含本行且不跨越组类型', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, kind: 'warmup', weight: '5', reps: 5),
        FitnessSet(id: setIdB, kind: 'warmup', weight: '6', reps: 6),
        FitnessSet(id: setIdC, weight: '20', reps: 8),
        FitnessSet(id: setIdD, weight: '30', reps: 9),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 2,
        field: 'reps',
        value: '12',
        action: 'above',
      );
      // 向上只覆盖正式组（含本行），热身组的次数保持原值。
      expect(sets.map((s) => s.reps), [5, 6, 12, 9]);
      expect(sets.map((s) => s.weight), ['5', '6', '20', '30']);
    });

    test('记录左右时按行同时写入两侧，并清除总重量口径', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, weight: '20', reps: 8),
        FitnessSet(id: setIdB, weight: '30', reps: 9),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 0,
        field: 'weight_left',
        value: '35',
        action: 'below',
      );
      expect(sets.map((s) => [s.weight, s.weightLeft, s.weightRight]), [
        [null, '35', '35'],
        [null, '35', '35'],
      ]);
    });

    test('写总重量时清除该组已有的左右重量', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, weightLeft: '5', weightRight: '6', reps: 8),
        FitnessSet(id: setIdB, weightLeft: '7', weightRight: '8', reps: 9),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 0,
        field: 'weight',
        value: '20',
        action: 'below',
      );
      expect(sets.map((s) => [s.weight, s.weightLeft, s.weightRight]), [
        ['20', null, null],
        ['20', null, null],
      ]);
    });

    test('改动后不再满足完成条件的组落回未完成', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, weight: '20', reps: 8, completed: true),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 0,
        field: 'reps',
        value: '',
        action: 'below',
      );
      expect(sets.single.reps, isNull);
      expect(sets.single.completed, isFalse);
    });

    test('新增一组复制当前行配置，插在本行之后且保持未完成', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, weight: '20', reps: 8),
        FitnessSet(id: setIdB, weight: '30', reps: 9),
      ]);
      final sets = fitnessFillSets(
        source,
        setIndex: 0,
        field: 'weight',
        value: '25',
        action: 'add',
      );
      expect(sets, hasLength(3));
      expect(sets[0].weight, '25');
      expect(sets[2].id, setIdB);
      expect(sets[1].id, isNot(setIdA));
      expect(
        [sets[1].weight, sets[1].reps, sets[1].completed],
        ['25', 8, false],
      );
    });

    for (final scenario in [
      (
        label: '右侧新增保留不同的左侧重量',
        field: 'weight_right',
        value: '8',
        left: '5',
        right: '8',
        completed: true,
      ),
      (
        label: '清空右侧后新增保留左侧并撤销完成状态',
        field: 'weight_right',
        value: '',
        left: '5',
        right: null,
        completed: false,
      ),
      (
        label: '左侧新增仅提交左侧的新重量',
        field: 'weight_left',
        value: '12',
        left: '12',
        right: '8',
        completed: true,
      ),
    ]) {
      test(scenario.label, () {
        final source = exercise(const [
          FitnessSet(
            id: setIdA,
            weightLeft: '5',
            weightRight: '8',
            reps: 8,
            completed: true,
            restDurationsSeconds: [15],
          ),
          FitnessSet(id: setIdB, weightLeft: '9', weightRight: '11', reps: 9),
        ]);

        final sets = fitnessFillSets(
          source,
          setIndex: 0,
          field: scenario.field,
          value: scenario.value,
          action: 'add',
        );

        expect(sets, hasLength(3));
        expect(sets[0].id, setIdA);
        expect(sets[1].id, isNot(setIdA));
        expect(sets[2], same(source.sets[1]));
        for (final set in sets.take(2)) {
          expect(set.weight, isNull);
          expect(set.weightLeft, scenario.left);
          expect(set.weightRight, scenario.right);
          expect(set.reps, 8);
        }
        expect(sets[0].completed, scenario.completed);
        expect(
          sets[0].restDurationsSeconds,
          scenario.completed ? [15] : isEmpty,
        );
        expect(sets[1].completed, isFalse);
        expect(sets[1].restDurationsSeconds, isEmpty);
        // 编辑与复制返回新列表，调用方持有的原始训练快照保持原值。
        expect(source.sets.first.weightLeft, '5');
        expect(source.sets.first.weightRight, '8');
        expect(source.sets.first.completed, isTrue);
      });
    }

    for (final field in ['weight_left', 'weight_right']) {
      for (final action in ['above', 'below']) {
        test('$field向$action批量填充仍同时更新同类型组的两侧', () {
          final source = exercise(const [
            FitnessSet(
              id: setIdA,
              kind: 'warmup',
              weightLeft: '1',
              weightRight: '2',
              reps: 5,
            ),
            FitnessSet(id: setIdB, weightLeft: '5', weightRight: '8', reps: 8),
            FitnessSet(id: setIdC, weightLeft: '7', weightRight: '9', reps: 9),
            FitnessSet(
              id: setIdD,
              weightLeft: '10',
              weightRight: '11',
              reps: 10,
            ),
          ]);

          final sets = fitnessFillSets(
            source,
            setIndex: 2,
            field: field,
            value: '35',
            action: action,
          );

          expect(
            sets.map((set) => [set.weightLeft, set.weightRight]),
            action == 'above'
                ? [
                    ['1', '2'],
                    ['35', '35'],
                    ['35', '35'],
                    ['10', '11'],
                  ]
                : [
                    ['1', '2'],
                    ['5', '8'],
                    ['35', '35'],
                    ['35', '35'],
                  ],
          );
          expect(sets.map((set) => set.reps), [5, 8, 9, 10]);
          expect(sets.map((set) => set.id), [setIdA, setIdB, setIdC, setIdD]);
        });
      }
    }
  });

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

    test('空列表和未命中目录动作不改变已有内容', () {
      expect(
        fitnessSetExerciseWeightMode(
          const [],
          exerciseId: '0025',
          sideWeight: true,
        ),
        isEmpty,
      );
      final source = [
        exercise(const [FitnessSet(id: setIdA, weight: '20')]),
      ];

      final result = fitnessSetExerciseWeightMode(
        source,
        exerciseId: '0289',
        sideWeight: false,
      );

      expect(result.single, same(source.single));
      expect(result.single.sets.single.weight, '20');
    });
  });

  group('组类型切换', () {
    test('切到热身落到交界处，切到正式落到正式组最前，数值保留', () {
      final source = exercise(const [
        FitnessSet(id: setIdA, kind: 'warmup', weight: '5', reps: 5),
        FitnessSet(id: setIdB, weight: '20', reps: 8),
        FitnessSet(id: setIdC, weight: '30', reps: 9),
      ]);
      final toWarmup = fitnessEditSets(source.sets, 1, 'toggleKind');
      expect(toWarmup.map((s) => s.id), [setIdA, setIdB, setIdC]);
      expect(toWarmup.map((s) => s.kind), ['warmup', 'warmup', 'working']);
      expect([toWarmup[1].weight, toWarmup[1].reps], ['20', 8]);
      final toWorking = fitnessEditSets(source.sets, 0, 'toggleKind');
      expect(toWorking.map((s) => s.kind), ['working', 'working', 'working']);
      expect(toWorking.map((s) => s.id), [setIdA, setIdB, setIdC]);
    });
  });

  group('休息到点与提示归属', () {
    test('只有计时运行中且剩余归零才算到点', () {
      final running = timer();
      expect(fitnessRestCompleted(running, now), isFalse);
      expect(
        fitnessRestCompleted(running, now.add(const Duration(seconds: 10))),
        isTrue,
      );
      expect(
        fitnessRestCompleted(
          running.copyWith(status: 'paused', endsAt: null, remainingSeconds: 0),
          now,
        ),
        isFalse,
      );
      expect(fitnessRestCompleted(null, now), isFalse);
    });

    test('旧提示不能跳过或重启刚被其它页面更新的计时', () {
      final shown = timer();
      expect(
        fitnessRestPromptStillCurrent(workout(restTimer: shown), shown),
        isTrue,
      );
      expect(
        fitnessRestPromptStillCurrent(
          workout(
            restTimer: shown.copyWith(
              endsAt: now.add(const Duration(minutes: 5)),
            ),
          ),
          shown,
        ),
        isFalse,
      );
      expect(fitnessRestPromptStillCurrent(workout(), shown), isFalse);
      expect(
        fitnessRestPromptStillCurrent(
          workout(restTimer: shown, status: 'completed'),
          shown,
        ),
        isFalse,
      );
      expect(fitnessRestPromptStillCurrent(null, shown), isFalse);
    });
  });

  group('休息结算', () {
    test('按实际运行秒数写入触发组，同一次计时只结算一次', () {
      final resting = workout(restTimer: timer());
      final settled = fitnessSettleRest(
        resting,
        now.add(const Duration(seconds: 11)),
      );
      expect(settled.restTimer, isNull);
      // 到期后按实际运行的 10 秒结算，不把到期后的等待算进时长。
      expect(settled.exercises.single.sets.single.restDurationsSeconds, [10]);
      // 结算结果只存在于副本，原数据由调用方决定是否落库。
      expect(
        resting.exercises.single.sets.single.restDurationsSeconds,
        isEmpty,
      );
      expect(resting.restTimer, isNotNull);
      expect(
        fitnessSettleRest(
          settled,
          now.add(const Duration(minutes: 30)),
        ).exercises.single.sets.single.restDurationsSeconds,
        [10],
      );
    });

    test('暂停期间不累计等待时间，未勾选组不归属休息记录', () {
      final paused = fitnessSettleRest(
        workout(
          restTimer: timer(
            status: 'paused',
            remainingSeconds: 10,
            elapsedSeconds: 5,
          ),
        ),
        now.add(const Duration(hours: 2)),
      );
      expect(paused.exercises.single.sets.single.restDurationsSeconds, [5]);
      final unchecked = fitnessSettleRest(
        workout(restTimer: timer(), completed: false),
        now.add(const Duration(seconds: 11)),
      );
      expect(
        unchecked.exercises.single.sets.single.restDurationsSeconds,
        isEmpty,
      );
    });
  });
}
