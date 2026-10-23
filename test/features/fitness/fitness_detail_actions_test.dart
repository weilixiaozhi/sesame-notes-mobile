import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

import '../../helpers/fitness_running_fixture.dart';
import '../../helpers/fitness_space_fixture.dart';

const exerciseInstance = '11111111-1111-4111-8111-111111111111';
const otherInstance = '22222222-2222-4222-8222-222222222222';
const setIdA = '33333333-3333-4333-8333-333333333333';
const setIdB = '44444444-4444-4444-8444-444444444444';
const warmupSetId = '55555555-5555-4555-8555-555555555555';

/// 详情编辑只搬运组数据，落库口径与页面保存保持一致。
FitnessExercise exerciseFor(
  String exerciseId, {
  String id = exerciseInstance,
  List<FitnessSet> sets = const [],
}) => FitnessExercise(id: id, exerciseId: exerciseId, sets: sets);

void main() {
  late SesameDatabase db;
  late FitnessRepository repo;
  var now = DateTime(2026, 9, 14, 12);
  setUp(() async {
    now = DateTime(2026, 9, 14, 12);
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = await createFitnessTestRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('一键改区间落库：只改当前动作的当前维度，批量修改不启动训练', () async {
    final draft = await repo.createBlankWorkout(name: '键盘');
    final exercise = exerciseFor(
      '0025',
      sets: const [
        FitnessSet(id: setIdA, weight: '20', reps: 8),
        FitnessSet(id: setIdB, weight: '30', reps: 9),
      ],
    );
    final other = exerciseFor(
      '0025',
      id: otherInstance,
      sets: const [FitnessSet(id: warmupSetId, weight: '5', reps: 5)],
    );
    await repo.saveWorkout(draft.copyWith(exercises: [exercise, other]));

    final filled = fitnessFillSets(
      exercise,
      setIndex: 0,
      field: 'weight',
      value: '35',
      action: 'below',
    );
    await repo.saveWorkout(
      draft.copyWith(
        exercises: [
          exercise.copyWith(sets: filled),
          other,
        ],
      ),
    );

    final saved = (await repo.getWorkout(draft.id))!;
    expect(saved.exercises.first.sets.map((s) => s.weight), ['35', '35']);
    expect(saved.exercises.first.sets.map((s) => s.reps), [8, 9]);
    // 批量修改不跨动作。
    expect(saved.exercises.last.sets.single.weight, '5');
    // 编辑成绩不会顺带启动训练。
    expect(saved.status, 'scheduled');
    expect(saved.runSegments, isEmpty);
  });

  test('切换记录左右：既有总重迁移成两侧，显式关闭后清空左右并保留关闭口径', () async {
    await repo.saveTemplate(
      const FitnessTemplate(
        name: '口径',
        exercises: [
          FitnessExercise(
            id: exerciseInstance,
            exerciseId: '0025',
            sets: [
              FitnessSet(id: setIdA, weight: '20', reps: 8),
              FitnessSet(id: setIdB, weight: '30', reps: 9),
            ],
          ),
        ],
      ),
    );
    // 用户显式切换到左右口径，偏好与组数据一起落库。
    expect(
      (await repo.setExerciseSideWeight('0025', true)).exerciseWeightModes,
      {'0025': true},
    );
    var template = (await repo.getTemplates()).single;
    await repo.saveTemplate(
      template.copyWith(
        exercises: [
          template.exercises.single.copyWith(
            sets: [
              for (final set in template.exercises.single.sets)
                fitnessMigrateSetWeight(set, side: true),
            ],
          ),
        ],
      ),
    );
    var sets = (await repo.getTemplates()).single.exercises.single.sets;
    expect(sets.map((s) => [s.weight, s.weightLeft, s.weightRight]), [
      [null, '20', '20'],
      [null, '30', '30'],
    ]);
    // 显式关闭同样落库，避免又被器械默认值推回左右口径。
    expect(
      (await repo.setExerciseSideWeight('0025', false)).exerciseWeightModes,
      {'0025': false},
    );
    template = (await repo.getTemplates()).single;
    await repo.saveTemplate(
      template.copyWith(
        exercises: [
          template.exercises.single.copyWith(
            sets: [
              for (final set in template.exercises.single.sets)
                fitnessMigrateSetWeight(set, side: false),
            ],
          ),
        ],
      ),
    );
    sets = (await repo.getTemplates()).single.exercises.single.sets;
    expect(sets.map((s) => [s.weight, s.weightLeft, s.weightRight]), [
      [null, null, null],
      [null, null, null],
    ]);
  });

  test('已有总重数据优先于哑铃默认口径，切换后按左右迁移', () async {
    final workout = await repo.saveWorkout(
      (await runningWorkoutFixture(repo)).copyWith(
        exercises: [
          exerciseFor(
            '0289',
            sets: const [FitnessSet(id: setIdA, weight: '20', reps: 8)],
          ),
        ],
      ),
    );
    final stored = (await repo.getWorkout(workout.id))!;
    // 哑铃动作默认左右，但该组只有总重量：按数据呈现总重口径。
    expect(
      fitnessUsesSideWeight(
        await repo.getPreferences(),
        exerciseId: '0289',
        equipment: 'dumbbell',
        dataUsesSideWeight: fitnessSideWeightFromSets(
          stored.exercises.single.sets,
        ),
      ),
      isFalse,
    );
    await repo.setExerciseSideWeight('0289', true);
    final saved = await repo.saveWorkout(
      stored.copyWith(
        exercises: [
          stored.exercises.single.copyWith(
            sets: [
              for (final set in stored.exercises.single.sets)
                fitnessMigrateSetWeight(set, side: true),
            ],
          ),
        ],
      ),
    );
    final set = saved.exercises.single.sets.single;
    expect([set.weight, set.weightLeft, set.weightRight], [null, '20', '20']);
    expect(
      fitnessUsesSideWeight(
        await repo.getPreferences(),
        exerciseId: '0289',
        equipment: 'dumbbell',
        dataUsesSideWeight: fitnessSideWeightFromSets(
          saved.exercises.single.sets,
        ),
      ),
      isTrue,
    );
  });

  test('其他训练切换偏好后重新编辑旧训练，保留其总重成绩并正常保存', () async {
    final first = await repo.createBlankWorkout(name: '总重记录');
    await repo.saveWorkout(
      first.copyWith(
        exercises: [
          exerciseFor(
            '0025',
            sets: const [
              FitnessSet(id: setIdA, weight: '20', reps: 8),
              FitnessSet(id: setIdB, weight: '30', reps: 8),
            ],
          ),
        ],
      ),
    );
    final second = await repo.createBlankWorkout(name: '分侧记录');
    await repo.setExerciseSideWeight('0025', true);
    await repo.saveWorkout(
      second.copyWith(
        exercises: [
          exerciseFor(
            '0025',
            sets: const [
              FitnessSet(
                id: warmupSetId,
                weightLeft: '10',
                weightRight: '10',
                reps: 8,
              ),
            ],
          ),
        ],
      ),
    );
    final previous = (await repo.getWorkout(first.id))!;
    final exercise = previous.exercises.single;
    expect(
      fitnessUsesSideWeight(
        await repo.getPreferences(),
        exerciseId: exercise.exerciseId,
        dataUsesSideWeight: fitnessSideWeightFromSets(exercise.sets),
      ),
      isFalse,
    );
    await repo.saveWorkout(
      previous.copyWith(
        exercises: [
          exercise.copyWith(
            sets: [
              exercise.sets.first.copyWith(weight: '22'),
              exercise.sets.last,
            ],
          ),
        ],
      ),
    );
    final saved = (await repo.getWorkout(first.id))!;
    expect(saved.exercises.single.sets.map((set) => set.weight), ['22', '30']);
    expect(
      saved.exercises.single.sets.every(
        (set) => set.weightLeft == null && set.weightRight == null,
      ),
      isTrue,
    );
  });

  test('组类型切换落盘并移到交界处，暂停写入已结束的训练段', () async {
    final running = await repo.saveWorkout(
      (await runningWorkoutFixture(repo)).copyWith(
        exercises: [
          exerciseFor(
            '0025',
            sets: const [
              FitnessSet(id: warmupSetId, kind: 'warmup', weight: '5', reps: 5),
              FitnessSet(id: setIdA, weight: '20', reps: 8),
              FitnessSet(id: setIdB, weight: '30', reps: 9),
            ],
          ),
        ],
      ),
    );
    final stored = (await repo.getWorkout(running.id))!;
    final toggled = fitnessEditSets(
      stored.exercises.single.sets,
      1,
      'toggleKind',
    );
    await repo.saveWorkout(
      stored.copyWith(
        exercises: [stored.exercises.single.copyWith(sets: toggled)],
      ),
    );
    final saved = (await repo.getWorkout(running.id))!;
    // 正式组切热身落到热身与正式组的交界处，组内数值保留。
    expect(saved.exercises.single.sets.map((s) => s.id), [
      warmupSetId,
      setIdA,
      setIdB,
    ]);
    expect(saved.exercises.single.sets.map((s) => s.kind), [
      'warmup',
      'warmup',
      'working',
    ]);
    expect(saved.exercises.single.sets[1].weight, '20');

    final paused = await repo.pauseWorkout(running.id);
    expect(paused.runSegments.last.endedAt, isNotNull);
    expect(
      (await repo.getWorkout(running.id))!.runSegments.last.endedAt,
      isNotNull,
    );
  });
}
