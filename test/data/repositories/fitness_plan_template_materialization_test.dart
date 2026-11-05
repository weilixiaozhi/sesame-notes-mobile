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
import 'package:uuid/uuid.dart';

import '../../helpers/fitness_space_fixture.dart';

/// 建立编排时选定的模板快照，节点身份与模板身份各自独立。
FitnessPlanDay _selectedDay(int index, FitnessTemplate? template) =>
    FitnessPlanDay(
      dayIndex: index,
      slot: template == null
          ? null
          : FitnessPlanSlot(
              id: const Uuid().v4(),
              sourceTemplateId: template.id,
              name: template.name,
              exercises: fitnessSnapshotExercises(template.exercises),
            ),
    );

/// 验证新建与已有计划共用原子保存契约时，最终内容与编排选择保持一致。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessRepository repository;
  late FitnessLibrary library;
  late Map<String, FitnessTemplate> officialTemplates;
  var now = DateTime(2026, 11, 5, 12);

  setUp(() async {
    now = DateTime(2026, 11, 5, 12);
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = await createFitnessTestRepository(db, clock: () => now);
    library = FitnessLibrary.fromJson(
      jsonDecode(await File('assets/fitness/library.json').readAsString())
          as Map<String, dynamic>,
    );
    officialTemplates = {
      for (final template in library.templates)
        template.id: template.toFitnessTemplate(
          const Locale('zh'),
          id: template.id,
        ),
    };
  });
  tearDown(() => db.close());

  test('自建计划原子保存实际引用的库模板，重复引用只复制一份', () async {
    final official = officialTemplates.values.first;
    final personal = await repository.saveTemplate(
      official.copyWith(
        id: '',
        name: '个人胸部训练',
        exercises: [official.exercises.first],
        catalogOrigin: null,
      ),
    );
    final plan = FitnessPlan(
      name: '混合训练计划',
      startDate: '2026-11-05',
      status: 'closed',
      cycleDays: 3,
      days: [
        _selectedDay(0, official),
        _selectedDay(1, personal),
        _selectedDay(2, official),
      ],
    );

    final saved = await repository.savePlan(
      plan,
      officialTemplates: officialTemplates,
    );
    final copies = await repository.getTemplates();
    expect(saved.catalogOrigin, isNull);
    expect(copies, hasLength(2));
    final source = saved.days.first.slot!.sourceTemplateId;
    expect(source, isNot(official.id));
    expect(saved.days[2].slot!.sourceTemplateId, source);
    expect(saved.days[1].slot!.sourceTemplateId, personal.id);
    expect(saved.days[1].slot!.name, personal.name);
    expect(saved.days[1].slot!.exercises, hasLength(1));
    expect(
      copies
          .where((template) => template.id == source)
          .single
          .catalogOrigin
          ?.toJson(),
      official.catalogOrigin?.toJson(),
    );
  });

  test('官方计划改选个人版本后不再复制未选模板，也不隐式替换个人内容', () async {
    final official = officialTemplates.values.first;
    final personal = await repository.importCatalogTemplate(official);
    final edited = await repository.saveTemplate(
      personal.copyWith(name: '我选的轻量版', exercises: [personal.exercises.last]),
    );
    final original = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: now,
    );
    final chosen = original.plan.copyWith(
      status: 'closed',
      days: [
        _selectedDay(0, edited),
        for (var i = 1; i < original.plan.cycleDays; i++) _selectedDay(i, null),
      ],
    );

    final saved = await repository.savePlan(
      chosen,
      officialTemplates: officialTemplates,
    );
    expect(await repository.getTemplates(), hasLength(1));
    expect(saved.catalogOrigin?.itemId, library.plans.first.id);
    expect(saved.days.first.slot!.sourceTemplateId, edited.id);
    expect(saved.days.first.slot!.name, '我选的轻量版');
    expect(
      saved.days.first.slot!.exercises.single.exerciseId,
      edited.exercises.single.exerciseId,
    );
    expect((await repository.getTemplates()).single.name, '我选的轻量版');
  });

  test('已有计划选择库模板只改变下一周期，已生成训练保持原样', () async {
    final official = officialTemplates.values.first;
    final personal = await repository.saveTemplate(
      official.copyWith(id: '', name: '原训练', catalogOrigin: null),
    );
    final saved = await repository.savePlan(
      FitnessPlan(
        name: '进行中的计划',
        startDate: '2026-11-05',
        status: 'in_progress',
        cycleDays: 2,
        days: [_selectedDay(0, personal), _selectedDay(1, null)],
      ),
    );
    final history = await repository.getWorkouts();
    final changed = await repository.savePlan(
      saved.copyWith(days: [_selectedDay(0, official), _selectedDay(1, null)]),
      officialTemplates: officialTemplates,
    );
    expect(changed.days.first.slot!.sourceTemplateId, personal.id);
    final pendingSource =
        changed.pendingSchedule!.days.first.slot!.sourceTemplateId;
    expect(pendingSource, isNot(official.id));
    expect(pendingSource, isNot(personal.id));
    expect(
      (await repository.getWorkouts()).map((w) => w.toJson()),
      history.map((w) => w.toJson()),
    );

    now = DateTime(2026, 11, 7, 12);
    await repository.refreshSchedule();
    final later = await repository.getWorkouts();
    expect(
      later
          .where((w) => w.scheduledDate == '2026-11-07')
          .single
          .sourceTemplateId,
      pendingSource,
    );
    expect(
      later.where((w) => w.scheduledDate == '2026-11-05').single.name,
      '原训练',
    );
  });

  test('保存中的官方模板校验失败会回滚全部依赖和计划', () async {
    final first = officialTemplates.values.first;
    final second = officialTemplates.values.elementAt(1);
    final invalid = second.copyWith(exercises: const []);
    final plan = FitnessPlan(
      name: '不能部分保存的计划',
      startDate: '2026-11-05',
      status: 'closed',
      cycleDays: 2,
      days: [_selectedDay(0, first), _selectedDay(1, invalid)],
    );

    await expectLater(
      repository.savePlan(plan, officialTemplates: officialTemplates),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(await repository.getTemplates(), isEmpty);
    expect(await repository.getPlans(), isEmpty);
    expect(await repository.getWorkouts(), isEmpty);
  });
}
