import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

/// 通过真实仓储生成完整记录与同步变更，任何失败整批回滚。
Future<void> fillAcceptanceFitness(
  FitnessRepository repository, {
  bool paused = false,
}) => repository.db.transaction(() async {
  final running = (await repository.getWorkouts())
      .where((w) => w.status == 'in_progress')
      .firstOrNull;
  if (running != null) throw FitnessRunningWorkoutException(running);

  final now = repository.clock();
  var time = now.subtract(const Duration(minutes: 40));
  // 可控时钟留下真实运行段和休息记录，不直接拼装已完成状态。
  final repo = FitnessRepository(
    repository.db,
    spaceId: repository.spaceId,
    spaceIdGetter: repository.spaceIdGetter,
    syncId: repository.target.syncId,
    syncIdGetter: repository.syncIdGetter,
    accountIdGetter: repository.accountIdGetter,
    generationGetter: repository.generationGetter,
    changeRecorder: repository.changeRecorder,
    clock: () => time,
  );
  final suffix = const Uuid().v4().substring(0, 8);
  final templates = <FitnessTemplate>[];
  for (final (name, exerciseId) in [('力量 A', '0025'), ('力量 B', '0043')]) {
    templates.add(
      await repo.saveTemplate(
        FitnessTemplate(
          name: '验收$name $suffix',
          exercises: [
            FitnessExercise(
              id: const Uuid().v4(),
              exerciseId: exerciseId,
              sets: [
                FitnessSet(
                  id: const Uuid().v4(),
                  kind: 'warmup',
                  weight: '10',
                  reps: 12,
                ),
                FitnessSet(id: const Uuid().v4(), weight: '20', reps: 10),
                FitnessSet(id: const Uuid().v4(), weight: '25', reps: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
  final completed = await repo.startFromTemplate(templates.first.id);
  await repo.saveWorkout(completed.copyWith(name: '验收已完成 $suffix'));
  for (final set in completed.exercises.single.sets) {
    time = time.add(const Duration(minutes: 3));
    await repo.setGroupCompleted(
      completed.id,
      completed.exercises.single.id,
      set.id,
      true,
    );
  }
  // 勾选最后一组只结算休息，训练必须由用户明确结束，这里按真实流程收尾。
  await repo.finishWorkout(completed.id);

  time = now;
  final days = [
    for (var i = 0; i < 3; i++)
      FitnessPlanDay(
        dayIndex: i,
        slot: i == 1
            ? null
            : FitnessPlanSlot(
                id: const Uuid().v4(),
                name: templates[i == 0 ? 0 : 1].name,
                sourceTemplateId: templates[i == 0 ? 0 : 1].id,
                exercises: templates[i == 0 ? 0 : 1].exercises,
              ),
      ),
  ];
  for (final (name, status, start) in [
    ('进行中计划', 'in_progress', fitnessDate(now)),
    (
      '未开始计划',
      'in_progress',
      fitnessDate(DateTime(now.year, now.month, now.day + 7)),
    ),
    ('已关闭计划', 'closed', null),
  ]) {
    await repo.savePlan(
      FitnessPlan(
        name: '验收$name $suffix',
        status: status,
        startDate: start,
        cycleDays: 3,
        days: days,
      ),
    );
  }
  final blank = await repo.createBlankWorkout(name: '验收未开始 $suffix');
  await repo.saveWorkout(
    blank.copyWith(
      exercises: fitnessSnapshotExercises(
        templates.last.exercises,
        newIds: true,
      ),
    ),
  );
  final active = await repo.startFromTemplate(templates.first.id);
  await repo.saveWorkout(active.copyWith(name: '验收训练 $suffix'));
  await repo.setGroupCompleted(
    active.id,
    active.exercises.single.id,
    active.exercises.single.sets.first.id,
    true,
  );
  if (paused) await repo.pauseWorkout(active.id);
  // 原仓储再次核对点击时的会话，切号发生在异步间隙也必须整批回滚。
  await repository.getWorkouts();
});
