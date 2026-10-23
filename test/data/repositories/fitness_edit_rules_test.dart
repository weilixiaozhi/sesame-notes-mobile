import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

import '../../helpers/fitness_running_fixture.dart';
import '../../helpers/fitness_space_fixture.dart';

const exerciseId = '11111111-1111-4111-8111-111111111111';
const setId = '22222222-2222-4222-8222-222222222222';
const slotId = '33333333-3333-4333-8333-333333333333';
const planId = '44444444-4444-4444-8444-444444444444';

/// 组精度断言用模板：重量固定 20.125，改名写入不得改动组数据。
FitnessTemplate templateFixture({String name = '原模板'}) => FitnessTemplate(
  name: name,
  exercises: const [
    FitnessExercise(
      id: exerciseId,
      exerciseId: '0025',
      sets: [FitnessSet(id: setId, weight: '20.125', reps: 8)],
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessRepository repo;
  late DateTime now;

  setUp(() async {
    now = DateTime(2026, 9, 11, 12);
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = await createFitnessTestRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('模板改名显式落库，空白名被拒，写失败整体回滚保留原值与组精度', () async {
    final created = await repo.saveTemplate(templateFixture());
    final stored = (await repo.getTemplates()).single;
    expect(stored.id, created.id);
    expect(stored.name, '原模板');
    expect(stored.exercises.single.sets.single.weight, '20.125');

    // 显式保存才更新名称，组数据与精度原样保留
    final renamed = await repo.saveTemplate(stored.copyWith(name: '上肢力量'));
    expect(renamed.name, '上肢力量');
    expect(renamed.exercises.single.sets.single.weight, '20.125');
    expect((await repo.getTemplates()).single.name, '上肢力量');

    // 空白名被拒，已保存的名称不被覆盖
    await expectLater(
      repo.saveTemplate(renamed.copyWith(name: '   ')),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getTemplates()).single.name, '上肢力量');

    // 写入失败：整条记录回滚，名称、组精度与时间戳保持原值
    final before = (await repo.getTemplates()).single.toJson();
    await db.customStatement(
      "CREATE TRIGGER fitness_test_rename BEFORE UPDATE ON fitness_entities WHEN json_extract(NEW.payload,'\$.name')='失败名称' BEGIN SELECT RAISE(ABORT,'test'); END",
    );
    await expectLater(
      repo.saveTemplate(renamed.copyWith(name: '失败名称')),
      throwsA(anything),
    );
    expect((await repo.getTemplates()).single.toJson(), before);
    expect((await repo.getTemplates()).single.name, '上肢力量');

    // 排除故障后重试同一份草稿写入成功，组精度不受影响
    await db.customStatement('DROP TRIGGER fitness_test_rename');
    expect(
      (await repo.saveTemplate(renamed.copyWith(name: '失败名称'))).name,
      '失败名称',
    );
    expect(
      (await repo.getTemplates()).single.exercises.single.sets.single.weight,
      '20.125',
    );
  });

  test('超范围次数不阻断结束，已完成组改成无效输入即撤销完成并保留重量', () async {
    final running = await runningWorkoutFixture(repo);
    final completed = await repo.saveWorkout(
      running.copyWith(
        exercises: [
          const FitnessExercise(
            id: exerciseId,
            exerciseId: '0025',
            sets: [
              FitnessSet(id: setId, weight: '20', reps: 8, completed: true),
            ],
          ),
        ],
      ),
    );
    expect(completed.exercises.single.sets.single.completed, isTrue);

    // 超范围次数输入不会产生成绩值，因此落库时只剩重量
    expect(fitnessPositiveInt('${FitnessDefaults.maxInteger + 1}'), isNull);
    final revoked = await repo.saveWorkout(
      completed.copyWith(
        exercises: [
          completed.exercises.single.copyWith(
            sets: [completed.exercises.single.sets.single.copyWith(reps: null)],
          ),
        ],
      ),
    );
    expect(revoked.exercises.single.sets.single.completed, isFalse);
    expect(revoked.exercises.single.sets.single.reps, isNull);
    expect(revoked.exercises.single.sets.single.weight, '20');

    // 超范围次数本身写不进库，写入失败不留下半条记录
    await expectLater(
      repo.saveWorkout(
        revoked.copyWith(
          exercises: [
            revoked.exercises.single.copyWith(
              sets: [
                revoked.exercises.single.sets.single.copyWith(
                  reps: FitnessDefaults.maxInteger + 1,
                ),
              ],
            ),
          ],
        ),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await repo.getWorkout(revoked.id))!.exercises.single.sets.single.reps,
      isNull,
    );

    // 结束不被无效组阻断，撤销完成后的重量随记录一起保留
    final finished = await repo.finishWorkout(running.id);
    expect(finished.status, 'completed');
    expect(finished.exercises.single.sets.single.completed, isFalse);
    expect(finished.exercises.single.sets.single.weight, '20');
  });

  test('计划至少一天训练才可保存，安排按日序号生成训练且停用保留内容', () async {
    // 全部为休息日的计划不是有效计划，保存被拒且不落库
    await expectLater(
      repo.savePlan(
        FitnessPlan(
          id: planId,
          name: '空计划',
          startDate: '2026-09-11',
          cycleDays: 2,
          days: const [
            FitnessPlanDay(dayIndex: 0),
            FitnessPlanDay(dayIndex: 1),
          ],
        ),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(await repo.getPlans(), isEmpty);
    expect(await repo.getWorkouts(), isEmpty);

    // 拖动排序后训练落在第 1 天：生成日随日序号后移，保存即启用
    final draft = FitnessPlan(
      id: planId,
      name: 'My first plan',
      startDate: '2026-09-11',
      cycleDays: 3,
      days: [
        const FitnessPlanDay(dayIndex: 0),
        FitnessPlanDay(
          dayIndex: 1,
          slot: FitnessPlanSlot(
            id: slotId,
            name: 'First template',
            exercises: templateFixture().exercises,
          ),
        ),
        const FitnessPlanDay(dayIndex: 2),
      ],
    );
    final saved = await repo.savePlan(draft);
    expect(saved.name, 'My first plan');
    expect(saved.status, 'in_progress');
    final generated = (await repo.getWorkouts()).single;
    expect(generated.scheduledDate, '2026-09-12');

    // 停用保留已生成内容，不因关闭而删除或重建
    final closed = await repo.savePlan(saved.copyWith(status: 'closed'));
    expect(closed.status, 'closed');
    expect((await repo.getWorkouts()).single.id, generated.id);
    expect((await repo.getWorkouts()).single.scheduledDate, '2026-09-12');
  });
}
