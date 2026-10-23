import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import '../../helpers/fitness_space_fixture.dart';
import '../../helpers/fitness_running_fixture.dart';
import '../../helpers/test_isolation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

const a = '11111111-1111-4111-8111-111111111111';
const b = '22222222-2222-4222-8222-222222222222';
const c = '33333333-3333-4333-8333-333333333333';
const e = '44444444-4444-4444-8444-444444444444';
const s = '55555555-5555-4555-8555-555555555555';
const slot = '66666666-6666-4666-8666-666666666666';
const secondSlot = '77777777-7777-4777-8777-777777777777';

FitnessExercise exercise({int rest = 90}) => FitnessExercise(
  id: e,
  exerciseId: '0025',
  restSeconds: rest,
  sets: [const FitnessSet(id: s, weight: '20', reps: 10)],
);
FitnessTemplate template({
  String id = a,
  String name = '力量',
  int rest = 90,
  bool extraSet = false,
}) => FitnessTemplate(
  id: id,
  name: name,
  exercises: [
    exercise(rest: rest).copyWith(
      sets: [
        ...exercise(rest: rest).sets,
        if (extraSet) const FitnessSet(id: c, weight: '20', reps: 10),
      ],
    ),
  ],
);
FitnessPlan plan({
  String id = b,
  String start = '2026-09-11',
  String status = 'in_progress',
  int cycle = 2,
}) => FitnessPlan(
  id: id,
  name: '计划',
  startDate: start,
  cycleDays: cycle,
  status: status,
  days: List.generate(
    cycle,
    (i) => FitnessPlanDay(
      dayIndex: i,
      slot: i == 0
          ? FitnessPlanSlot(
              id: slot,
              name: '力量',
              sourceTemplateId: a,
              exercises: [exercise()],
            )
          : null,
    ),
  ),
);

class _SwitchingRecorder extends ChangeRecorderImpl {
  final void Function() afterSave;
  _SwitchingRecorder(
    super.db, {
    required super.accountIdGetter,
    required this.afterSave,
  });
  @override
  Future<void> recordFitnessChange({
    required String entityType,
    required String entityId,
    required String fitnessSpaceId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) async {
    await super.recordFitnessChange(
      entityType: entityType,
      entityId: entityId,
      fitnessSpaceId: fitnessSpaceId,
      accountId: accountId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
      baseRevision: baseRevision,
    );
    afterSave();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessRepository repo;
  late DateTime now;
  String? account;
  var generation = 0;
  Future<FitnessRepository> repository() async =>
      (await createFitnessTestRepository(
        db,
        accountIdGetter: () => account,
        generationGetter: () => generation,
        clock: () => now,
        changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
      ));
  setUp(() async {
    now = DateTime(2026, 9, 11, 12);
    account = null;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = await repository();
  });
  tearDown(() => db.close());

  test('官方模板复用只接受同源副本，副本缺失或来源不符时给出明确结果', () async {
    final library = FitnessLibrary.fromJson(
      jsonDecode(await File('assets/fitness/library.json').readAsString())
          as Map<String, dynamic>,
    );
    final official = library.templates.first;
    final copy = await repo.importCatalogTemplate(
      official.toFitnessTemplate(const Locale('zh'), id: official.id),
    );

    final reused = await repo.importCatalogTemplate(
      official.toFitnessTemplate(const Locale('zh'), id: official.id),
      reuseTemplateId: copy.id,
    );
    expect(reused.id, copy.id);
    expect(await repo.getTemplates(), hasLength(1));

    // 选择的副本已删除时创建新副本，而不是静默失败。
    await repo.deleteTemplate(copy.id);
    final created = await repo.importCatalogTemplate(
      official.toFitnessTemplate(const Locale('zh'), id: official.id),
      reuseTemplateId: copy.id,
    );
    expect(created.id, isNot(copy.id));
    expect(await repo.getTemplates(), hasLength(1));

    // 复用其他官方来源的副本会被拒绝，避免来源标记与内容错配。
    final other = library.templates[1];
    final otherCopy = await repo.importCatalogTemplate(
      other.toFitnessTemplate(const Locale('zh'), id: other.id),
    );
    await expectLater(
      repo.importCatalogTemplate(
        official.toFitnessTemplate(const Locale('zh'), id: official.id),
        reuseTemplateId: otherCopy.id,
      ),
      throwsA(isA<FitnessValidationException>()),
    );
  });

  test('复用改过的官方模板时预览和快照一致，删除模板仍保留选择的配置', () async {
    final library = FitnessLibrary.fromJson(
      jsonDecode(await File('assets/fitness/library.json').readAsString())
          as Map<String, dynamic>,
    );
    final official = library.templates.first;
    final copy = await repo.importCatalogTemplate(
      official.toFitnessTemplate(const Locale('zh'), id: official.id),
    );
    final edited = await repo.saveTemplate(
      copy.copyWith(name: '轻量版', exercises: [exercise(rest: 42)]),
    );
    final draft = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: now,
      reusableTemplateIds: {official.id: edited.id},
      reusableTemplates: {edited.id: edited},
    );
    expect(draft.plan.days.first.slot!.name, '轻量版');
    final saved = await repo.importCatalogPlan(
      draft.plan,
      draft.officialTemplates,
      reusableTemplateIds: draft.reusableTemplateIds,
    );
    expect(saved.days.first.slot!.name, '轻量版');
    expect(saved.days.first.slot!.exercises.single.restSeconds, 42);
    await repo.deleteTemplate(edited.id);
    now = now.add(const Duration(days: 4));
    await repo.refreshSchedule();
    final workouts = await repo.getWorkouts();
    expect(
      workouts
          .where((w) => w.sourceTemplateId == edited.id)
          .every(
            (w) => w.name == '轻量版' && w.exercises.single.restSeconds == 42,
          ),
      isTrue,
    );
  });

  test('官方计划原子复制模板并重映射所有用户来源身份', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    final library = FitnessLibrary.fromJson(source);
    final draft = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: now,
    );

    final saved = await repo.importCatalogPlan(
      draft.plan,
      draft.officialTemplates,
    );
    final templates = await repo.getTemplates();
    expect(templates, hasLength(3));
    expect(saved.catalogOrigin?.itemId, library.plans.first.id);
    expect(
      templates.map((template) => template.catalogOrigin?.itemId).toSet(),
      draft.officialTemplates.keys.toSet(),
    );
    expect(
      saved.days
          .where((day) => day.slot != null)
          .every(
            (day) => templates.any(
              (template) => template.id == day.slot!.sourceTemplateId,
            ),
          ),
      isTrue,
    );
    expect(
      saved.days.map((day) => day.slot?.sourceTemplateId),
      everyElement(isNot(isIn(draft.officialTemplates.keys))),
    );

    final reusable = {
      for (final template in templates)
        template.catalogOrigin!.itemId: template.id,
    };
    final secondDraft = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: now,
      reusableTemplateIds: reusable,
    );
    final second = await repo.importCatalogPlan(
      secondDraft.plan,
      secondDraft.officialTemplates,
      reusableTemplateIds: reusable,
    );
    expect(await repo.getTemplates(), hasLength(3));
    expect(await repo.getPlans(), hasLength(2));
    expect(
      second.days
          .where((day) => day.slot != null)
          .map((day) => day.slot!.sourceTemplateId)
          .toSet(),
      reusable.values.toSet(),
    );
  });

  test('官方计划复制中途失败会回滚模板和计划', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    final library = FitnessLibrary.fromJson(source);
    final draft = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: now,
    );
    final templates = {...draft.officialTemplates};
    final invalidId = templates.keys.elementAt(1);
    templates[invalidId] = templates[invalidId]!.copyWith(exercises: const []);

    await expectLater(
      repo.importCatalogPlan(draft.plan, templates),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(await repo.getTemplates(), isEmpty);
    expect(await repo.getPlans(), isEmpty);
  });

  test('自定义动作增改删、偏好并发保存和训练引用保留', () async {
    const custom = FitnessCustomExercise(
      id: 'custom:$a',
      name: '自创划船',
      bodyPart: 'back',
      equipment: 'dumbbell',
      icon: 'dumbbell',
    );
    final stale = await repo.getPreferences();
    await repo.saveCustomExercise(custom);
    expect((await repo.getPreferences()).customExercises.single.name, '自创划船');
    await repo.savePreferences(stale.copyWith(soundEnabled: false));
    expect((await repo.getPreferences()).customExercises.single.id, custom.id);
    await repo.saveCustomExercise(
      FitnessCustomExercise.fromJson({...custom.toJson(), 'name': '单臂划船'}),
    );
    final saved = await repo.saveTemplate(
      template().copyWith(
        exercises: [exercise().copyWith(exerciseId: custom.id)],
      ),
    );
    final prefs = await repo.getPreferences();
    await repo.savePreferences(
      prefs.copyWith(
        pinnedExerciseIds: [custom.id],
        exerciseRestSettings: {
          custom.id: const FitnessExerciseRest(
            restSeconds: 60,
            warmupRestSeconds: 30,
          ),
        },
      ),
    );
    await repo.deleteCustomExercise(custom.id);
    final deleted = await repo.getPreferences();
    expect(deleted.customExercises.single.deleted, isTrue);
    expect(deleted.customExercises.single.definition.nameZh, '单臂划船');
    expect(deleted.pinnedExerciseIds, isEmpty);
    expect(deleted.exerciseRestSettings, isEmpty);
    expect(
      (await repo.getTemplates())
          .singleWhere((e) => e.id == saved.id)
          .exercises
          .single
          .exerciseId,
      custom.id,
    );
    await expectLater(
      repo.saveCustomExercise(custom),
      throwsA(isA<FitnessValidationException>()),
    );
    await expectLater(
      repo.saveCustomExercise(
        FitnessCustomExercise.fromJson({
          ...custom.toJson(),
          'id': 'custom:$b',
          'name': ' ',
        }),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getPreferences()).customExercises, hasLength(1));
  });

  test('所有读取限定当前空间，其他账号不能通过旧空间 ID 读取或写入', () async {
    final first = await createFitnessTestRepository(
      db,
      spaceId: a,
      accountIdGetter: () => 'account-a',
      clock: () => now,
      changeRecorder: ChangeRecorderImpl(
        db,
        accountIdGetter: () => 'account-a',
      ),
    );
    final second = await createFitnessTestRepository(
      db,
      spaceId: b,
      accountIdGetter: () => 'account-a',
      clock: () => now,
    );
    await first.saveTemplate(template(id: c));
    final workout = await first.startFromTemplate(c);
    expect(await second.getTemplates(), isEmpty);
    expect(await second.getWorkouts(), isEmpty);
    await expectLater(
      second.savePlan(
        plan(id: s, status: 'closed').copyWith(
          days: [
            FitnessPlanDay(
              dayIndex: 0,
              slot: FitnessPlanSlot(
                id: slot,
                name: '跨空间来源',
                sourceTemplateId: c,
                exercises: [exercise()],
              ),
            ),
            const FitnessPlanDay(dayIndex: 1),
          ],
        ),
      ),
      throwsA(
        isA<FitnessValidationException>().having(
          (error) => error.code,
          'code',
          'FITNESS_SOURCE_SPACE',
        ),
      ),
    );
    final foreign = FitnessRepository(
      db,
      spaceId: a,
      accountIdGetter: () => 'account-b',
      clock: () => now,
    );
    expect(await foreign.getTemplates(), isEmpty);
    expect(await foreign.watchTemplates().first, isEmpty);
    expect(await foreign.watchWorkout(workout.id).first, isNull);
    expect(
      await foreign
          .watchWorkoutsInRange(
            now.subtract(const Duration(days: 1)),
            now.add(const Duration(days: 1)),
          )
          .first,
      isEmpty,
    );
    expect(await foreign.watchRecentExerciseIds().first, isEmpty);
    expect((await foreign.watchWorkoutBounds().first).earliest, isNull);
    await expectLater(foreign.saveTemplate(template(id: c)), throwsStateError);
    expect((await first.getTemplates()).single.id, c);
  });

  test('模板直接复用为当天训练，保存不能改期且不影响原记录', () async {
    await repo.saveTemplate(template());
    final workout = await repo.startFromTemplate(a);
    expect(workout.scheduledDate, fitnessDate(now));
    expect(workout.sourceTemplateId, a);
    for (final date in ['2026-09-10', '2026-09-12']) {
      await expectLater(
        repo.saveWorkout(workout.copyWith(scheduledDate: date)),
        throwsA(isA<FitnessValidationException>()),
      );
    }
    final saved = await repo.saveWorkout(workout.copyWith(name: '可编辑名称'));
    expect(saved.scheduledDate, workout.scheduledDate);
    expect(saved.name, '可编辑名称');
    expect(await repo.getWorkouts(), hasLength(1));
  });

  test('新建和填写不计时，任意组首次勾选开始，全部取消也继续', () async {
    final draft = await repo.createBlankWorkout();
    expect(draft.status, 'scheduled');
    expect(draft.runSegments, isEmpty);
    now = now.add(const Duration(minutes: 5));
    final secondSet = exercise().sets.single.copyWith(id: c);
    await repo.saveWorkout(
      draft.copyWith(
        exercises: [
          exercise().copyWith(sets: [exercise().sets.single, secondSet]),
        ],
      ),
    );
    expect(
      fitnessElapsed((await repo.getWorkout(draft.id))!, now),
      Duration.zero,
    );
    final started = await repo.setGroupCompleted(draft.id, e, c, true);
    expect(started.status, 'in_progress');
    expect(started.exercises.single.sets.first.completed, isFalse);
    expect(started.runSegments.single.startedAt, now.toUtc());
    now = now.add(const Duration(seconds: 7));
    final unchecked = await repo.setGroupCompleted(draft.id, e, c, false);
    expect(unchecked.exercises.single.sets.every((s) => !s.completed), isTrue);
    expect(unchecked.status, 'in_progress');
    expect(unchecked.runSegments.single.endedAt, isNull);
    expect(fitnessElapsed(unchecked, now).inSeconds, 7);
    await repo.setGroupCompleted(draft.id, e, s, true);
    expect((await repo.getWorkout(draft.id))!.runSegments, hasLength(1));
  });

  test('无效组或另一场已运行时，首次勾选不能留下部分开始状态', () async {
    final draft = await repo.createBlankWorkout();
    await repo.saveWorkout(
      draft.copyWith(
        exercises: [
          exercise().copyWith(
            sets: [exercise().sets.single.copyWith(reps: null)],
          ),
        ],
      ),
    );
    await expectLater(
      repo.setGroupCompleted(draft.id, e, s, true),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getWorkout(draft.id))!.runSegments, isEmpty);
    await repo.saveWorkout(draft.copyWith(exercises: [exercise()]));
    await runningWorkoutFixture(repo);
    await expectLater(
      repo.setGroupCompleted(draft.id, e, s, true),
      throwsA(isA<FitnessRunningWorkoutException>()),
    );
    final unchanged = (await repo.getWorkout(draft.id))!;
    expect(unchanged.status, 'scheduled');
    expect(unchanged.runSegments, isEmpty);
    expect(unchanged.exercises.single.sets.single.completed, isFalse);
  });

  test('暂停不累计，零组结束保留时长，重新开始延续并防止并行训练', () async {
    final w = await runningWorkoutFixture(repo);
    now = now.add(const Duration(seconds: 12));
    final paused = await repo.pauseWorkout(w.id);
    now = now.add(const Duration(minutes: 3));
    expect(fitnessElapsed(paused, now).inSeconds, 12);
    expect(await repo.pauseWorkout(w.id), isA<FitnessWorkout>());
    await expectLater(
      runningWorkoutFixture(repo),
      throwsA(isA<FitnessRunningWorkoutException>()),
    );
    final ended = await repo.finishWorkout(w.id);
    expect(ended.status, 'completed');
    expect(ended.exercises, isEmpty);
    expect(fitnessElapsed(ended, now).inSeconds, 12);
    final restarted = await repo.startWorkout(w.id);
    now = now.add(const Duration(seconds: 8));
    expect(fitnessElapsed(restarted, now).inSeconds, 20);
    final resumed = await repo.startWorkout(w.id);
    expect(resumed.runSegments, hasLength(2));
    expect(fitnessElapsed(await repo.finishWorkout(w.id), now).inSeconds, 20);
  });

  test('最后一组勾选保留休息，手动结束结算，重启继续累计', () async {
    await repo.saveTemplate(template(extraSet: true));
    var w = await repo.startFromTemplate(a);
    now = now.add(const Duration(seconds: 10));
    w = await repo.setGroupCompleted(w.id, e, c, true);
    expect(w.status, 'in_progress');
    await repo.setGroupCompleted(w.id, e, c, false);
    expect((await repo.getWorkout(w.id))!.runSegments.last.endedAt, isNull);
    now = now.add(const Duration(seconds: 5));
    await repo.setGroupCompleted(w.id, e, c, true);
    now = now.add(const Duration(seconds: 5));
    w = await repo.setGroupCompleted(w.id, e, s, true);
    expect(w.status, 'in_progress');
    expect(w.restTimer!.setId, s);
    expect(w.runSegments.last.endedAt, isNull);
    w = await repo.finishWorkout(w.id);
    expect(w.status, 'completed');
    expect(w.restTimer, isNull);
    expect(w.runSegments.last.endedAt, now.toUtc());
    now = now.add(const Duration(seconds: 100));
    expect(fitnessElapsed((await repo.getWorkout(w.id))!, now).inSeconds, 20);
    w = await repo.startWorkout(w.id);
    now = now.add(const Duration(seconds: 7));
    expect(fitnessElapsed(w, now).inSeconds, 27);
  });

  test('首次勾选休息写入失败，开始状态与完成组整体回滚', () async {
    final draft = await repo.createBlankWorkout();
    await repo.saveWorkout(draft.copyWith(exercises: [exercise()]));
    await db.customStatement(
      "CREATE TRIGGER fitness_test_auto_finish BEFORE UPDATE ON fitness_entities WHEN json_extract(NEW.payload,'\$.rest_timer') IS NOT NULL BEGIN SELECT RAISE(ABORT,'test'); END",
    );
    await expectLater(
      repo.setGroupCompleted(draft.id, e, s, true),
      throwsA(anything),
    );
    final saved = (await repo.getWorkout(draft.id))!;
    expect(saved.status, 'scheduled');
    expect(saved.runSegments, isEmpty);
    expect(saved.exercises.single.sets.single.completed, isFalse);
    await db.customStatement('DROP TRIGGER fitness_test_auto_finish');
    expect(
      (await repo.setGroupCompleted(draft.id, e, s, true)).status,
      'in_progress',
    );
  });

  test('同一天反复使用模板创建独立训练，微调和手动更新均不覆盖其他记录', () async {
    await repo.saveTemplate(template());
    var first = await repo.startFromTemplate(a);
    first = await repo.saveWorkout(
      first.copyWith(
        name: '本次微调',
        exercises: [
          exercise().copyWith(
            sets: [const FitnessSet(id: s, weight: '45', reps: 8)],
          ),
        ],
      ),
    );
    first = await repo.setGroupCompleted(first.id, e, s, true);
    first = await repo.finishWorkout(first.id);
    final before = first.toJson();
    final second = await repo.startFromTemplate(a);
    expect(second.id, isNot(first.id));
    expect(second.scheduledDate, first.scheduledDate);
    expect(second.exercises.single.sets.single.weight, '20');
    expect((await repo.getWorkout(first.id))!.toJson(), before);
    final source = await repo.updateWorkoutTemplate(first.id);
    expect(source.id, a);
    expect(source.name, '力量');
    expect(source.exercises.single.sets.single.weight, '45');
    expect(source.exercises.single.sets.single.completed, isFalse);
    expect((await repo.getWorkout(second.id))!.toJson(), second.toJson());
    await repo.finishWorkout(second.id);
    final third = await repo.startFromTemplate(a);
    expect({first.id, second.id, third.id}, hasLength(3));
    expect(third.exercises.single.sets.single.weight, '45');
    expect((await repo.getWorkout(first.id))!.toJson(), before);
    expect(await repo.getWorkouts(), hasLength(3));
  });

  test('手动更新拒绝空白训练、空动作及已删除来源，不新建或复活模板', () async {
    final blank = await repo.createBlankWorkout();
    await expectLater(
      repo.updateWorkoutTemplate(blank.id),
      throwsA(isA<FitnessValidationException>()),
    );
    await repo.saveTemplate(template());
    final workout = await repo.startFromTemplate(a);
    await repo.saveWorkout(workout.copyWith(exercises: []));
    await expectLater(
      repo.updateWorkoutTemplate(workout.id),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getTemplates()).single.exercises, hasLength(1));
    await repo.saveWorkout(workout);
    await repo.deleteTemplate(a);
    final before = (await repo.getWorkout(workout.id))!.toJson();
    await expectLater(
      repo.updateWorkoutTemplate(workout.id),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(await repo.getTemplates(), isEmpty);
    expect((await repo.getWorkout(workout.id))!.toJson(), before);
  });

  test('全局与单动作休息设置按最后写入覆盖，跨旧训练生效并区分热身', () async {
    await repo.saveTemplate(template(extraSet: true));
    final first = await repo.startFromTemplate(a);
    await repo.finishWorkout(first.id);
    final second = await repo.startFromTemplate(a);
    await repo.setExerciseRestSettings([
      '0025',
      '0289',
    ], const FitnessExerciseRest(restSeconds: 60, warmupRestSeconds: 30));
    await repo.setExerciseRestSettings([
      '0025',
    ], const FitnessExerciseRest(restSeconds: 90, warmupRestSeconds: 45));
    final done = await repo.setGroupCompleted(second.id, e, s, true);
    expect(done.restTimer!.durationSeconds, 90);
    await repo.pauseWorkout(second.id);
    final resumed = await repo.startWorkout(second.id);
    expect(resumed.restTimer!.durationSeconds, 90);
    expect(
      (await repo.getPreferences()).exerciseRestSettings['0289']!.restSeconds,
      60,
    );
    await repo.finishWorkout(second.id);
    await repo.startWorkout(first.id);
    final changed = await repo.saveWorkout(
      (await repo.getWorkout(first.id))!.copyWith(
        exercises: [
          exercise().copyWith(
            sets: [
              exercise().sets.single.copyWith(kind: 'warmup'),
              const FitnessSet(id: c, reps: 10),
            ],
          ),
        ],
      ),
    );
    final warmup = await repo.setGroupCompleted(changed.id, e, s, true);
    expect(warmup.restTimer!.durationSeconds, 45);
    await repo.setExerciseRestSettings([
      '0025',
    ], const FitnessExerciseRest(restSeconds: 20, warmupRestSeconds: 0));
    await repo.setGroupCompleted(first.id, e, s, false);
    expect(
      (await repo.setGroupCompleted(first.id, e, s, true)).restTimer,
      isNull,
    );
    await expectLater(
      repo.setExerciseRestSettings([
        'invalid',
      ], const FitnessExerciseRest(restSeconds: 90, warmupRestSeconds: 45)),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await repo.getPreferences()).exerciseRestSettings['0025']!.restSeconds,
      20,
    );
  });

  test('多个计划同时启用独立生成，关闭和重新开启一个不影响另一个', () async {
    await repo.savePlan(plan(id: b));
    await repo.savePlan(plan(id: c));
    final stored = (await repo.getPlans()).first;
    expect(stored.toJson()['status'], 'in_progress');
    expect(stored.toJson().containsKey('enabled'), isFalse);
    await expectLater(
      repo.savePlan(
        (await repo.getPlans())
            .firstWhere((p) => p.id == b)
            .copyWith(status: 'enabled'),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await repo.getPlans()).where((p) => p.status == 'in_progress'),
      hasLength(2),
    );
    final first = await repo.getWorkouts();
    expect(first.map((w) => w.sourcePlanId).toSet(), {b, c});
    expect(first.map((w) => w.id).toSet(), hasLength(first.length));
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'closed'),
    );
    now = now.add(const Duration(days: 2));
    await repo.refreshSchedule();
    final paused = await repo.getWorkouts();
    expect(
      paused.where((w) => w.sourcePlanId == b).length,
      first.where((w) => w.sourcePlanId == b).length,
    );
    expect(
      paused.where((w) => w.sourcePlanId == c).length,
      greaterThan(first.where((w) => w.sourcePlanId == c).length),
    );
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'in_progress'),
      restartDate: fitnessDate(now),
    );
    expect(
      (await repo.getPlans()).where((p) => p.status == 'in_progress'),
      hasLength(2),
    );
    final resumed = await repo.getWorkouts();
    await repo.refreshSchedule();
    expect(await repo.getWorkouts(), hasLength(resumed.length));
    await repo.startWorkout(resumed.first.id);
    await expectLater(
      repo.startWorkout(resumed.last.id),
      throwsA(isA<FitnessRunningWorkoutException>()),
    );
  });

  test('首次启用预生成未来完整周期，每天一次训练、休息日只作标记', () async {
    final p = plan(start: '2026-09-20').copyWith(
      days: [
        FitnessPlanDay(
          dayIndex: 0,
          slot: FitnessPlanSlot(id: slot, name: '训练', exercises: [exercise()]),
        ),
        const FitnessPlanDay(dayIndex: 1),
      ],
    );
    final saved = await repo.savePlan(p);
    final workouts = await repo.getWorkouts();
    expect(workouts.length, 1);
    expect(workouts.single.scheduledDate, '2026-09-20');
    expect(
      workouts.every(
        (w) =>
            w.scheduledDate == '2026-09-20' &&
            w.status == 'scheduled' &&
            !w.exercises.single.sets.single.completed,
      ),
      isTrue,
    );
    expect(saved.generationState.generatedCycles.single.restDates, [
      '2026-09-21',
    ]);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('重复刷新不重建发生身份，训练安排日不可修改且墓碑不复活', () async {
    await repo.savePlan(plan());
    final w = (await repo.getWorkouts()).single;
    await expectLater(
      repo.saveWorkout(w.copyWith(scheduledDate: '2026-09-15')),
      throwsA(isA<FitnessValidationException>()),
    );
    await repo.refreshSchedule();
    expect((await repo.getWorkouts()).single.scheduledDate, w.scheduledDate);
    await repo.deleteWorkout(w.id);
    await repo.refreshSchedule();
    await repo.savePlan((await repo.getPlans()).single);
    expect(await repo.getWorkouts(), isEmpty);
    final tombstones = await db.select(db.fitnessEntities).get();
    expect(tombstones.where((r) => r.id == w.id).single.deletedAt, isNotNull);
    expect(
      jsonDecode(
        tombstones.where((r) => r.id == w.id).single.payload,
      )['occurrence_key'],
      w.occurrenceKey,
    );
    // 模拟另一设备回放尚未推进的周期快照，也不能补回已删除事项。
    final stale = (await repo.getPlans()).single.copyWith(
      generationState: const FitnessGenerationState(),
    );
    await db.customStatement(
      'UPDATE fitness_entities SET payload=? WHERE id=?',
      [jsonEncode(stale.toJson()), b],
    );
    await repo.refreshSchedule();
    expect(await repo.getWorkouts(), isEmpty);
  });

  test('跨过多个启用周期补齐至当前，永不虚构执行成绩', () async {
    await repo.savePlan(plan());
    now = DateTime(2026, 9, 18);
    await repo.refreshSchedule();
    await repo.refreshSchedule();
    final workouts = await repo.getWorkouts();
    expect(workouts.map((w) => w.scheduledDate).toSet(), {
      '2026-09-11',
      '2026-09-13',
      '2026-09-15',
      '2026-09-17',
    });
    expect(
      workouts.every((w) => w.runSegments.isEmpty && w.status == 'scheduled'),
      isTrue,
    );
  });

  test('模板与计划副本独立，编辑周期只在下个未生成边界生效', () async {
    await repo.saveTemplate(template());
    await repo.savePlan(plan());
    await repo.saveTemplate(template(name: '模板已改', rest: 0));
    final original = (await repo.getWorkouts()).single;
    var p = (await repo.getPlans()).single;
    final edited = FitnessSchedule(
      cycleDays: 3,
      days: [
        FitnessPlanDay(
          dayIndex: 0,
          slot: FitnessPlanSlot(
            id: slot,
            name: '下一周期',
            exercises: [exercise(rest: 30)],
          ),
        ),
        const FitnessPlanDay(dayIndex: 1),
        const FitnessPlanDay(dayIndex: 2),
      ],
    );
    p = await repo.savePlan(
      p.copyWith(name: '改名计划', cycleDays: edited.cycleDays, days: edited.days),
    );
    expect(p.cycleDays, 2);
    expect(p.pendingSchedule!.cycleDays, 3);
    expect((await repo.getWorkout(original.id))!.sourcePlanName, '计划');
    expect(
      (await repo.getWorkout(original.id))!.exercises.single.restSeconds,
      90,
    );
    now = DateTime(2026, 9, 13);
    await repo.refreshSchedule();
    final current = (await repo.getPlans()).single;
    expect(current.cycleDays, 3);
    expect(current.pendingSchedule, isNull);
    expect(current.generationState.nextCycleStartDate, '2026-09-16');
    final next = (await repo.getWorkouts()).firstWhere(
      (w) => w.id != original.id,
    );
    expect(next.name, '下一周期');
    expect(next.sourcePlanName, '改名计划');
    await expectLater(
      repo.savePlan(current.copyWith(startDate: '2026-09-14')),
      throwsA(isA<FitnessValidationException>()),
    );
  });

  test('关闭保留旧训练，重新开启从所选日期开始完整周期', () async {
    final p = plan(cycle: 3).copyWith(
      days: List.generate(
        3,
        (i) => FitnessPlanDay(
          dayIndex: i,
          slot: FitnessPlanSlot(
            id: [slot, secondSlot, c][i],
            name: '第$i日',
            exercises: [exercise()],
          ),
        ),
      ),
    );
    await repo.savePlan(p);
    now = DateTime(2026, 9, 12);
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'closed'),
    );
    now = DateTime(2026, 9, 18);
    await repo.refreshSchedule();
    expect((await repo.getWorkouts()).length, 3);
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'in_progress'),
      restartDate: fitnessDate(now),
    );
    final dates = (await repo.getWorkouts())
        .map((w) => w.scheduledDate)
        .toSet();
    expect(dates, {
      '2026-09-11',
      '2026-09-12',
      '2026-09-13',
      '2026-09-18',
      '2026-09-19',
      '2026-09-20',
    });
    now = DateTime(2026, 9, 20);
    await repo.refreshSchedule();
    expect((await repo.getWorkouts()).length, 6);
  });

  test('保存后一直关闭的计划可重新选日期启用，且不补关闭期间安排', () async {
    await repo.savePlan(plan(status: 'closed'));
    now = DateTime(2026, 9, 16);
    final saved = await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'in_progress'),
      restartDate: fitnessDate(now),
    );
    expect((await repo.getWorkouts()).single.scheduledDate, '2026-09-16');
    expect(saved.generationState.generatedCycles.single.restDates, [
      '2026-09-17',
    ]);
    now = DateTime(2026, 9, 17);
    await repo.refreshSchedule();
    expect((await repo.getWorkouts()).single.scheduledDate, '2026-09-16');
  });

  test('待生效修改可撤回，启停计划保留尚未生效的修改', () async {
    var p = await repo.savePlan(plan());
    final original = p.days;
    p = await repo.savePlan(
      p.copyWith(
        days: [
          p.days.first.copyWith(slot: p.days.first.slot!.copyWith(name: '修改')),
          p.days.last,
        ],
      ),
    );
    p = await repo.savePlan(
      p.copyWith(
        status: 'closed',
        cycleDays: p.pendingSchedule!.cycleDays,
        days: p.pendingSchedule!.days,
      ),
    );
    expect(p.pendingSchedule!.days.first.slot!.name, '修改');
    p = await repo.savePlan(p.copyWith(days: original));
    expect(p.pendingSchedule, isNull);
    p = await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'in_progress'),
      restartDate: fitnessDate(now),
    );
    expect(p.days.first.slot!.name, '力量');
  });

  test('无日期草稿可保存，启用和恢复必须显式选日期，关闭保留训练', () async {
    final draft = await repo.savePlan(
      plan(status: 'closed').copyWith(startDate: null),
    );
    await expectLater(
      repo.savePlan(
        (await repo.getPlans())
            .firstWhere((p) => p.id == b)
            .copyWith(status: 'paused'),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(draft.startDate, isNull);
    expect(
      () => FitnessPlan.fromJson({...draft.toJson(), 'status': 'paused'}),
      throwsFormatException,
    );
    expect(await repo.getWorkouts(), isEmpty);
    await expectLater(
      repo.savePlan(
        (await repo.getPlans())
            .firstWhere((p) => p.id == b)
            .copyWith(status: 'in_progress'),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    await expectLater(
      repo.savePlan(
        (await repo.getPlans())
            .firstWhere((p) => p.id == b)
            .copyWith(status: 'in_progress'),
        restartDate: '2026-09-10',
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'in_progress'),
      restartDate: '2026-09-11',
    );
    final before = (await repo.getWorkouts()).single;
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'closed'),
    );
    now = DateTime(2026, 9, 20);
    await repo.refreshSchedule();
    expect((await repo.getWorkouts()).single.toJson(), before.toJson());
    expect((await repo.getPlans()).single.status, 'closed');
    await expectLater(
      repo.savePlan(
        (await repo.getPlans())
            .firstWhere((p) => p.id == b)
            .copyWith(status: 'in_progress'),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
  });

  test('恢复覆盖同计划对应日期全部旧训练，其他来源和区间外保留，休息标记更新', () async {
    await repo.saveTemplate(template());
    await repo.savePlan(plan());
    await repo.savePlan(plan(id: c));
    final standalone = await repo.startFromTemplate(a);
    await repo.finishWorkout(standalone.id);
    final old = (await repo.getWorkouts()).firstWhere(
      (w) => w.sourcePlanId == b,
    );
    await repo.startWorkout(old.id);
    await repo.finishWorkout(old.id);
    await repo.savePlan(
      (await repo.getPlans())
          .firstWhere((p) => p.id == b)
          .copyWith(status: 'closed'),
    );
    var paused = (await repo.getPlans()).firstWhere((p) => p.id == b);
    paused = await repo.savePlan(
      paused.copyWith(
        days: [
          const FitnessPlanDay(dayIndex: 0),
          paused.days.first.copyWith(dayIndex: 1),
        ],
      ),
    );
    // 与编辑页一致，重新启用时提交待生效的日程。
    final restarted = await repo.savePlan(
      paused.copyWith(
        status: 'in_progress',
        cycleDays: paused.pendingSchedule!.cycleDays,
        days: paused.pendingSchedule!.days,
      ),
      restartDate: '2026-09-11',
    );
    final workouts = await repo.getWorkouts();
    expect(await repo.getWorkout(old.id), isNull);
    expect(
      workouts.where((w) => w.sourcePlanId == b).single.scheduledDate,
      '2026-09-12',
    );
    expect(workouts.where((w) => w.sourcePlanId == c), hasLength(1));
    expect(await repo.getWorkout(standalone.id), isNotNull);
    expect(fitnessCalendarRestDays([restarted]).map((r) => r.date).toList(), [
      '2026-09-11',
    ]);
    await repo.refreshSchedule();
    expect(await repo.getWorkouts(), hasLength(workouts.length));
    expect(restarted.generationState.generatedCycles.map((c) => c.cycleIndex), [
      0,
      1,
    ]);
  });

  test('训练修改不回写，手动更新模板后下一周期读取新配置且已有训练不变', () async {
    await repo.saveTemplate(template());
    await repo.savePlan(plan());
    final original = (await repo.getWorkouts()).single;
    var w = await repo.startWorkout(original.id);
    final changed = w.exercises.single.copyWith(
      restSeconds: 45,
      warmupRestSeconds: 15,
      sets: [
        w.exercises.single.sets.single.copyWith(weight: '35.5', reps: 12),
        const FitnessSet(id: c, weight: '30', reps: 9),
      ],
    );
    w = await repo.saveWorkout(w.copyWith(exercises: [changed]));
    expect(
      (await repo.getTemplates()).single.exercises.single.sets.single.weight,
      '20',
    );
    expect(
      (await repo.getTemplates()).single.exercises.single.sets,
      hasLength(1),
    );
    final source = await repo.updateWorkoutTemplate(w.id);
    expect(source.name, '力量');
    expect((await repo.getWorkout(w.id))!.toJson(), w.toJson());
    expect(source.exercises.single.sets.map((s) => s.weight), ['35.5', '30']);
    expect(source.exercises.single.sets.map((s) => s.reps), [12, 9]);
    expect(source.exercises.single.restSeconds, 45);
    await repo.setExerciseRestSettings([
      '0025',
    ], const FitnessExerciseRest(restSeconds: 20, warmupRestSeconds: 5));
    expect((await repo.getTemplates()).single.toJson(), source.toJson());
    await repo.finishWorkout(w.id);
    final completed = await repo.getWorkout(w.id);
    now = DateTime(2026, 9, 13);
    await repo.refreshSchedule();
    final next = (await repo.getWorkouts()).firstWhere(
      (item) => item.id != w.id,
    );
    expect(next.scheduledDate, '2026-09-13');
    expect(next.exercises.single.sets.map((s) => s.weight), ['35.5', '30']);
    expect(next.exercises.single.sets.map((s) => s.reps), [12, 9]);
    expect(next.exercises.single.sets.every((s) => !s.completed), isTrue);
    expect(next.exercises.single.restSeconds, 20);
    expect(next.exercises.single.warmupRestSeconds, 5);
    expect((await repo.getWorkout(w.id))!.toJson(), completed!.toJson());
  });

  test('删除模板保留计划训练，录入不复活已删来源', () async {
    await repo.saveTemplate(template());
    await repo.savePlan(plan());
    final w = (await repo.getWorkouts()).single;
    await repo.deleteTemplate(a);
    expect(await repo.getTemplates(), isEmpty);
    expect((await repo.getWorkout(w.id))!.sourcePlanName, '计划');
    final ended = await repo.startWorkout(w.id);
    await repo.saveWorkout(
      ended.copyWith(
        exercises: [ended.exercises.single.copyWith(restSeconds: 30)],
      ),
    );
    expect(await repo.getTemplates(), isEmpty);
  });

  test('关闭时配置日期不会启动，首次启用使用已配置日期，停用保留已生成内容', () async {
    var p = await repo.savePlan(plan(status: 'closed'));
    p = await repo.savePlan(p.copyWith(startDate: '2026-09-16'));
    expect(p.status, 'closed');
    expect(await repo.getWorkouts(), isEmpty);
    p = await repo.savePlan(p.copyWith(status: 'in_progress'));
    expect((await repo.getWorkouts()).single.scheduledDate, '2026-09-16');
    p = await repo.savePlan(
      p.copyWith(status: 'closed', startDate: '2026-09-18'),
    );
    expect(p.status, 'closed');
    expect((await repo.getWorkouts()).single.scheduledDate, '2026-09-16');
    now = DateTime(2026, 9, 20);
    await repo.refreshSchedule();
    expect(await repo.getWorkouts(), hasLength(1));
  });

  test('删除计划保留所有已生成训练和休息，包含完成记录', () async {
    await repo.saveTemplate(template());
    await repo.savePlan(plan());
    await repo.savePlan(plan(id: c));
    final blank = await repo.createBlankWorkout();
    now = DateTime(2026, 9, 15);
    await repo.refreshSchedule();
    final own = (await repo.getWorkouts())
        .where((w) => w.sourcePlanId == b)
        .toList();
    expect(own, hasLength(3));
    await repo.startWorkout(own[0].id);
    await repo.finishWorkout(own[0].id);
    await repo.startWorkout(own[1].id);
    final before = (await repo.getWorkouts()).map((w) => w.toJson()).toList();
    await repo.deletePlan(b);
    final remaining = await repo.getWorkouts();
    expect(remaining.where((w) => w.sourcePlanId == b), hasLength(3));
    expect(remaining.map((w) => w.toJson()).toList(), before);
    expect(remaining.where((w) => w.sourcePlanId == c), hasLength(3));
    expect(await repo.getWorkout(blank.id), isNotNull);
    expect((await repo.getTemplates()).single.id, a);
    expect(
      fitnessCalendarRestDays(
        await repo.getPlans(includeDeleted: true),
      ).where((day) => day.sourcePlanId == b),
      isNotEmpty,
    );
    expect((await repo.getPlans()).where((p) => p.id == b), isEmpty);
    expect(
      (await db.select(db.fitnessEntities).get())
          .singleWhere((row) => row.id == b)
          .deletedAt,
      isNotNull,
    );
    await repo.refreshSchedule();
    expect(
      (await repo.getWorkouts()).where((w) => w.sourcePlanId == b),
      hasLength(3),
    );
  });

  test('空训练直接结束，重新开始同一记录累计时段且不含结束间隔', () async {
    final w = await runningWorkoutFixture(repo, id: c);
    now = now.add(const Duration(minutes: 5));
    var ended = await repo.finishWorkout(w.id);
    expect(fitnessElapsed(ended, now), const Duration(minutes: 5));
    await repo.finishWorkout(w.id);
    now = now.add(const Duration(hours: 1));
    expect((await repo.getWorkout(w.id))!.status, 'completed');
    await repo.startWorkout(w.id);
    now = now.add(const Duration(minutes: 2));
    ended = await repo.finishWorkout(w.id);
    expect(fitnessElapsed(ended, now), const Duration(minutes: 7));
    expect((await repo.getWorkouts()).length, 1);
    final stats = fitnessStatistics(
      await repo.getWorkouts(),
      startDate: '2026-09-11',
      endDate: '2026-09-11',
    );
    expect(stats.durationByDate, hasLength(1));
    expect(stats.trainingDays, 0);
    expect(stats.totalDuration, const Duration(minutes: 7));
  });

  test('只有一场运行，失败的新建不会留下多余待训练', () async {
    await repo.saveTemplate(template());
    final w = await runningWorkoutFixture(repo);
    await expectLater(
      repo.startFromTemplate(a),
      throwsA(isA<FitnessRunningWorkoutException>()),
    );
    expect((await repo.getWorkouts()).length, 1);
    expect((await repo.getWorkout(w.id))!.status, 'in_progress');
  });

  test('并发开始仍只有一场，SQLite事务保护跨页面竞争', () async {
    final outcomes = await Future.wait(
      [
        runningWorkoutFixture(repo, id: a),
        runningWorkoutFixture(repo, id: b),
      ].map(
        (future) => future.then<Object>((w) => w, onError: (Object e) => e),
      ),
    );
    expect(outcomes.whereType<FitnessWorkout>().length, 1);
    expect(outcomes.whereType<FitnessRunningWorkoutException>().length, 1);
    expect((await repo.getWorkouts()).length, 2);
    expect(
      (await repo.getWorkouts()).where((w) => w.status == 'in_progress'),
      hasLength(1),
    );
  });

  test('组完成启动休息，后台按截止恢复，暂停增减与结束重启一致', () async {
    await repo.saveTemplate(template(extraSet: true));
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    expect(w.restTimer!.durationSeconds, 90);
    now = now.add(const Duration(seconds: 20));
    w = await repo.pauseRest(w.id);
    expect(fitnessRestRemaining(w.restTimer, now), 70);
    now = now.add(const Duration(hours: 2));
    expect(fitnessRestRemaining(w.restTimer, now), 70);
    w = await repo.adjustRest(w.id, 10);
    w = await repo.resumeRest(w.id);
    now = now.add(const Duration(seconds: 30));
    expect(fitnessRestRemaining(w.restTimer, now), 50);
    w = await repo.setGroupCompleted(w.id, e, s, false);
    expect(fitnessRestRemaining(w.restTimer, now), 50);
    w = await repo.finishWorkout(w.id);
    expect(w.restTimer, isNull);
    w = await repo.startWorkout(w.id);
    expect(w.restTimer, isNull);
  });

  test('休息增减同步截止时间，减到零不为负数且不修改默认时长', () async {
    var w = await runningWorkoutFixture(repo);
    final defaults = (await repo.getPreferences()).defaultRestSeconds;
    w = await repo.startRest(w.id, seconds: 15);
    now = now.add(const Duration(seconds: 10));
    w = await repo.adjustRest(w.id, 10);
    expect(fitnessRestRemaining(w.restTimer, now), 15);
    expect(w.restTimer!.endsAt, now.toUtc().add(const Duration(seconds: 15)));
    w = await repo.adjustRest(w.id, -10);
    expect(fitnessRestRemaining(w.restTimer, now), 5);
    w = await repo.adjustRest(w.id, -10);
    expect(fitnessRestRemaining(w.restTimer, now), 0);
    expect(w.restTimer!.endsAt, now.toUtc());
    expect((await repo.getPreferences()).defaultRestSeconds, defaults);
  });

  test('休息弹层结算后，较早的成绩自动保存不能覆盖实际休息记录', () async {
    await repo.saveTemplate(template());
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    now = now.add(const Duration(seconds: 12));
    await repo.skipRest(w.id);
    final saved = await repo.saveWorkout(
      w.copyWith(
        exercises: [
          w.exercises.single.copyWith(
            sets: [w.exercises.single.sets.single.copyWith(weight: '25')],
          ),
        ],
      ),
    );
    expect(saved.restTimer, isNull);
    expect(saved.exercises.single.sets.single.weight, '25');
    expect(saved.exercises.single.sets.single.restDurationsSeconds, [12]);
  });

  test('每组休息保留实际秒数，暂停调整重启到期均不冒充预设时长', () async {
    await repo.saveTemplate(template());
    var w = await repo.startFromTemplate(a);
    w = await repo.saveWorkout(
      w.copyWith(
        exercises: [
          exercise().copyWith(
            sets: [
              exercise().sets.single,
              exercise().sets.single.copyWith(id: c),
            ],
          ),
        ],
      ),
    );
    await repo.setGroupCompleted(w.id, e, s, true);
    now = now.add(const Duration(seconds: 17));
    await repo.pauseRest(w.id);
    now = now.add(const Duration(hours: 1));
    await repo.adjustRest(w.id, 30);
    await repo.resumeRest(w.id);
    now = now.add(const Duration(seconds: 8));
    // 手动重启仍归到同一组，并将上一段25秒单独保存。
    w = await repo.startRest(w.id, seconds: 20);
    expect(w.exercises.single.sets.first.restDurationsSeconds, [25]);
    now = now.add(const Duration(seconds: 40));
    w = await repo.setGroupCompleted(w.id, e, c, true);
    expect(w.exercises.single.sets.first.restDurationsSeconds, [25, 20]);
    expect(w.status, 'in_progress');
    expect(w.restTimer!.setId, c);
    now = now.add(const Duration(seconds: 11));
    w = await repo.finishWorkout(w.id);
    expect(w.exercises.single.sets.last.restDurationsSeconds, [11]);
    w = (await (await repository()).getWorkout(w.id))!;
    expect(w.exercises.single.sets.first.restDurationsSeconds, [25, 20]);
    final savedTemplate = await repo.saveWorkoutAsTemplate(
      w.id,
      name: 'Snapshot',
    );
    expect(
      savedTemplate.exercises
          .expand((e) => e.sets)
          .every((s) => s.restDurationsSeconds.isEmpty),
      isTrue,
    );
    w = await repo.setGroupCompleted(w.id, e, s, false);
    expect(w.exercises.single.sets.first.restDurationsSeconds, isEmpty);
    expect(w.exercises.single.sets.last.restDurationsSeconds, [11]);
  });

  test('历史勾选不启动休息，零默认关闭，新偏好不追改已有动作', () async {
    await repo.saveTemplate(template(rest: 0));
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    expect(w.restTimer, isNull);
    await repo.savePreferences(
      const FitnessPreferences(defaultRestSeconds: 30),
    );
    expect((await repo.getTemplates()).single.exercises.single.restSeconds, 0);
    await repo.finishWorkout(w.id);
    await repo.setGroupCompleted(w.id, e, s, false);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    expect(w.status, 'completed');
    expect(w.restTimer, isNull);
  });

  test('无效完成被拒绝，已完成组编辑成不完整时取消确认，结束永不阻断', () async {
    await repo.saveTemplate(template());
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    w = await repo.saveWorkout(
      w.copyWith(
        exercises: [
          w.exercises.single.copyWith(
            sets: [w.exercises.single.sets.single.copyWith(reps: null)],
          ),
        ],
      ),
    );
    expect(w.exercises.single.sets.single.completed, isFalse);
    await expectLater(
      repo.setGroupCompleted(w.id, e, s, true),
      throwsA(isA<FitnessValidationException>()),
    );
    w = await repo.finishWorkout(w.id);
    expect(w.exercises.single.sets.single.reps, isNull);
    expect(
      fitnessStatistics(
        [w],
        startDate: '2026-09-11',
        endDate: '2026-09-11',
      ).trainingDays,
      0,
    );
  });

  test('历史编辑不改变运行事实，重新开始排除汇总，替换清空旧成绩', () async {
    await repo.saveTemplate(template());
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    now = now.add(const Duration(minutes: 1));
    w = await repo.finishWorkout(w.id);
    final saved = await repo.saveWorkout(w.copyWith(name: '历史修改'));
    expect(saved.status, 'completed');
    expect(saved.runSegments.single.endedAt, w.runSegments.single.endedAt);
    expect(
      fitnessStatistics(
        [saved],
        startDate: '2026-09-01',
        endDate: '2026-09-11',
      ).volumeKg.toString(),
      '200',
    );
    await expectLater(
      repo.saveWorkout(saved.copyWith(runSegments: [])),
      throwsA(isA<FitnessValidationException>()),
    );
    w = await repo.startWorkout(w.id);
    expect(
      fitnessStatistics(
        [w],
        startDate: '2026-09-01',
        endDate: '2026-09-30',
      ).durationByDate.length,
      0,
    );
    w = await repo.saveWorkout(
      w.copyWith(exercises: [w.exercises.single.copyWith(exerciseId: '0274')]),
    );
    expect(w.exercises.single.sets.single.completed, isFalse);
    expect(w.exercises.single.sets.single.weight, isNull);
  });

  test('旧自动保存不能覆盖结束或重启后的状态与时段', () async {
    final running = await runningWorkoutFixture(repo);
    now = now.add(const Duration(minutes: 1));
    final ended = await repo.finishWorkout(running.id);
    await expectLater(
      repo.saveWorkout(running.copyWith(name: '迟到输入')),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getWorkout(running.id))!.status, 'completed');
    now = now.add(const Duration(hours: 1));
    final restarted = await repo.startWorkout(running.id);
    await expectLater(
      repo.saveWorkout(running.copyWith(name: '更早的输入')),
      throwsA(isA<FitnessValidationException>()),
    );
    await expectLater(
      repo.saveWorkout(ended.copyWith(name: '旧历史')),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await repo.getWorkout(running.id))!.runSegments.length,
      restarted.runSegments.length,
    );
  });

  test('历史另存模板保留未完成组配置，完成状态不带入且来源保持不变', () async {
    await repo.saveTemplate(template());
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    w = await repo.saveWorkout(
      w.copyWith(
        exercises: [
          w.exercises.single.copyWith(
            sets: [
              ...w.exercises.single.sets,
              const FitnessSet(id: c, weight: '10', reps: 12),
            ],
          ),
        ],
      ),
    );
    await repo.finishWorkout(w.id);
    final t = await repo.saveWorkoutAsTemplate(w.id, name: '另存');
    expect(t.exercises.single.sets.length, 2);
    expect(t.exercises.single.sets.every((s) => !s.completed), isTrue);
    expect(t.exercises.single.sets.last.reps, 12);
    expect(
      (await repo.getTemplates())
          .firstWhere((t) => t.id == a)
          .exercises
          .single
          .sets
          .length,
      1,
    );
  });

  test('账号切换隔离所有实体，旧实例拒绝写入，队列归属当前账号', () async {
    await repo.saveTemplate(template());
    account = c;
    generation++;
    repo = await repository();
    expect(await repo.getTemplates(), isEmpty);
    final w = await runningWorkoutFixture(repo);
    await repo.savePreferences(
      const FitnessPreferences(defaultRestSeconds: 120),
    );
    final oldRepo = repo;
    account = b;
    generation++;
    repo = await repository();
    expect(await repo.getWorkouts(), isEmpty);
    expect(
      (await repo.getPreferences()).defaultRestSeconds,
      FitnessDefaults.restSeconds,
    );
    await expectLater(
      oldRepo.finishWorkout(w.id),
      throwsA(isA<FitnessValidationException>()),
    );
    await expectLater(
      repo.startWorkout(w.id),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await db.select(db.syncChanges).get()).every((q) => q.accountId == c),
      isTrue,
    );
    account = null;
    generation++;
    repo = await repository();
    expect((await repo.getTemplates()).single.id, a);
  });

  test('outbox落盘失败整体回滚，重试只留一场与固定mutation', () async {
    account = a;
    repo = await repository();
    await db.customStatement(
      "CREATE TRIGGER fitness_test_fail BEFORE INSERT ON sync_changes BEGIN SELECT RAISE(ABORT,'test'); END",
    );
    await expectLater(runningWorkoutFixture(repo, id: c), throwsA(anything));
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    await db.customStatement('DROP TRIGGER fitness_test_fail');
    await runningWorkoutFixture(repo, id: c);
    final q = (await db.select(db.syncChanges).get()).single;
    await runningWorkoutFixture(repo, id: c);
    expect(
      (await db.select(db.syncChanges).get()).single.mutationId,
      q.mutationId,
    );
    expect(q.ledgerId, isNull);
    expect(q.dayBookId, isNull);
    expect(q.memoBookId, isNull);
  });

  test('刷新事务中切换账号整批回滚，不留下另一账号的训练或队列', () async {
    account = c;
    repo = await repository();
    await repo.savePlan(plan());
    final before = await db.select(db.fitnessEntities).get(),
        queues = await db.select(db.syncChanges).get();
    now = DateTime(2026, 9, 15);
    repo = (await createFitnessTestRepository(
      db,
      clock: () => now,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      changeRecorder: _SwitchingRecorder(
        db,
        accountIdGetter: () => account,
        afterSave: () {
          account = a;
          generation++;
        },
      ),
    ));
    await expectLater(
      repo.refreshSchedule(),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      (await db.select(db.fitnessEntities).get()).map((r) => r.payload),
      before.map((r) => r.payload),
    );
    expect(
      (await db.select(db.syncChanges).get()).map((q) => q.mutationId),
      queues.map((q) => q.mutationId),
    );
  });

  test('结束本地写失败保留进行中和已保存组，恢复后同一训练结束', () async {
    await repo.saveTemplate(template(extraSet: true));
    var w = await repo.startFromTemplate(a);
    w = await repo.setGroupCompleted(w.id, e, s, true);
    await db.customStatement(
      "CREATE TRIGGER fitness_test_finish BEFORE UPDATE ON fitness_entities WHEN NEW.entity_type='fitness_workout' BEGIN SELECT RAISE(ABORT,'test'); END",
    );
    await expectLater(repo.finishWorkout(w.id), throwsA(anything));
    final saved = (await repo.getWorkout(w.id))!;
    expect(saved.status, 'in_progress');
    expect(saved.exercises.single.sets.first.completed, isTrue);
    expect(saved.restTimer, isNotNull);
    await db.customStatement('DROP TRIGGER fitness_test_finish');
    expect((await repo.finishWorkout(w.id)).status, 'completed');
  });

  test('真实数据库重开恢复毫秒运行时间、输入和休息截止', () async {
    final directory = await createTestTempDirectory('fitness-persistence-');
    final file = File('${directory.path}/fitness.sqlite');
    var persistent = SesameDatabase.withExecutor(NativeDatabase(file));
    try {
      var local = (await createFitnessTestRepository(
        persistent,
        clock: () => now,
      ));
      await local.saveTemplate(template(extraSet: true));
      now = now.add(const Duration(milliseconds: 123));
      var w = await local.startFromTemplate(a);
      w = await local.setGroupCompleted(w.id, e, s, true);
      await persistent.close();
      now = now.add(const Duration(seconds: 45));
      persistent = SesameDatabase.withExecutor(NativeDatabase(file));
      local = (await createFitnessTestRepository(persistent, clock: () => now));
      final recovered = (await local.getWorkout(w.id))!;
      expect(
        recovered.runSegments.single.startedAt,
        w.runSegments.single.startedAt,
      );
      expect(fitnessRestRemaining(recovered.restTimer, now), 45);
      expect(recovered.exercises.single.sets.first.completed, isTrue);
      expect(fitnessElapsed(recovered, now), const Duration(seconds: 45));
    } finally {
      await persistent.close();
      await directory.delete(recursive: true);
    }
  });

  test('新训练安排不接受过去', () async {
    await repo.saveTemplate(template());
    await expectLater(
      repo.savePlan(plan(start: '2026-09-10')),
      throwsA(isA<FitnessValidationException>()),
    );
  });
}
