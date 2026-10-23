import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import '../../helpers/fitness_space_fixture.dart';

/// 用真实仓储验证应用用例保留计时状态以及固定会话的写入保护。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessActions actions;
  var generation = 0;

  setUp(() async {
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repository = await createFitnessTestRepository(
      db,
      generationGetter: () => generation,
      clock: () => DateTime(2026, 9, 19, 12),
    );
    actions = FitnessActions(
      queryPort: repository,
      workoutPort: repository,
      libraryPort: repository,
      preferencesPort: repository,
    );
  });
  tearDown(() => db.close());

  test('旧编辑草稿只覆盖输入字段，保留刚更新的运行和休息状态', () async {
    final draft = await actions.createBlankWorkout(name: '初始');
    await actions.startWorkout(draft.id);
    final running = await actions.startRest(draft.id, seconds: 90);
    final saved = await actions.saveWorkoutDraft(draft.copyWith(name: '新名称'));
    expect(saved.name, '新名称');
    expect(saved.status, running.status);
    expect(
      saved.runSegments.map((s) => s.toJson()),
      running.runSegments.map((s) => s.toJson()),
    );
    expect(saved.restTimer?.toJson(), running.restTimer?.toJson());
  });

  test('改名读取最新训练，不覆盖刚开始的休息', () async {
    final draft = await actions.createBlankWorkout();
    await actions.startWorkout(draft.id);
    final running = await actions.startRest(draft.id, seconds: 120);
    final saved = await actions.renameWorkout(draft.id, '改名');
    expect(saved.name, '改名');
    expect(saved.restTimer?.toJson(), running.restTimer?.toJson());
  });

  test('保存器绑定的会话失效后不能把旧草稿写入新会话', () async {
    final draft = await actions.createBlankWorkout(name: '原内容');
    generation++;
    await expectLater(
      actions.saveWorkoutDraft(draft.copyWith(name: '迟到写入')),
      throwsA(
        isA<FitnessValidationException>().having(
          (error) => error.code,
          'code',
          'FITNESS_SESSION_CHANGED',
        ),
      ),
    );
    final row = await (db.select(
      db.fitnessEntities,
    )..where((entity) => entity.id.equals(draft.id))).getSingle();
    expect((jsonDecode(row.payload) as Map)['name'], '原内容');
  });
}
