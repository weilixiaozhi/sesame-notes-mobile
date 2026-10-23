import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import '../../helpers/fitness_transfer_decoder.dart';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/features/settings/application/fitness_file_actions.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import '../../helpers/fitness_space_fixture.dart';
import '../../helpers/fitness_transfer_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sourceId = 'custom:${fitnessId(801)}',
      existingId = 'custom:${fitnessId(802)}';
  Map<String, dynamic> definition(String id, String name) => {
    'id': id,
    'name': name,
    'body_part': 'chest',
    'equipment': 'body weight',
    'icon': 'activity',
    'image': base64Encode([1, 2, 3]),
    'deleted': false,
  };
  FitnessTransferRecord preferences(String customId, String name) =>
      FitnessTransferRecord(
        id: fitnessId(700),
        entityType: 'fitness_preferences',
        fitnessSpaceId: testFitnessSpaceId(),
        payload: {
          ...FitnessPreferences(
            createdAt: fitnessFixtureTime,
            updatedAt: fitnessFixtureTime,
          ).toJson(),
          'custom_exercises': [definition(customId, name)],
          'pinned_exercise_ids': [customId],
          'exercise_rest_settings': {
            customId: {'rest_seconds': 60, 'warmup_rest_seconds': 15},
          },
          'exercise_weight_modes': {customId: true},
        },
      );
  FitnessTransferRecord template() => FitnessTransferRecord(
    id: fitnessId(701),
    entityType: 'fitness_template',
    fitnessSpaceId: testFitnessSpaceId(),
    payload: FitnessTemplate(
      name: '自定义动作训练',
      createdAt: fitnessFixtureTime,
      updatedAt: fitnessFixtureTime,
      exercises: [
        FitnessExercise(
          id: fitnessId(702),
          exerciseId: sourceId,
          sets: [FitnessSet(id: fitnessId(703), reps: 8)],
        ),
      ],
    ).toJson(),
  );

  test('完整 JSON 与跨空间导入保留自定义动作、图片、图标及所有动作引用', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final source = fitnessDocument(
      records: [template(), preferences(sourceId, '来源动作')],
    );
    final decoded = decodeFitnessTransfer(FitnessTransferFormat.encode(source));
    expect(decoded.records.last.payload['custom_exercises'], [
      definition(sourceId, '来源动作'),
    ]);
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(
        records: [preferences(existingId, '已有动作')],
        export: 201,
      ),
    );
    final before = (await db.select(db.fitnessEntities).get()).single;
    final oldCustomId =
        (jsonDecode(before.payload)['custom_exercises'] as List).single['id'];
    final result = await importFitnessFixture(db: db, document: decoded);
    expect(result.imported, 2);
    final rows = await db.select(db.fitnessEntities).get();
    final pref =
        jsonDecode(
              rows
                  .singleWhere((r) => r.entityType == 'fitness_preferences')
                  .payload,
            )
            as Map;
    final customs = pref['custom_exercises'] as List;
    expect(customs, hasLength(2));
    expect(customs.any((e) => e['id'] == oldCustomId), isTrue);
    final imported = customs.singleWhere((e) => e['name'] == '来源动作') as Map;
    expect(imported['id'], startsWith('custom:'));
    expect(imported['id'], isNot(sourceId));
    expect(imported['image'], definition(sourceId, '')['image']);
    expect(imported['icon'], 'activity');
    expect(pref['pinned_exercise_ids'], [imported['id']]);
    expect((pref['exercise_rest_settings'] as Map).keys, [imported['id']]);
    expect(pref['exercise_weight_modes'], {imported['id']: true});
    final importedTemplate = jsonDecode(
      rows.singleWhere((r) => r.entityType == 'fitness_template').payload,
    );
    expect(importedTemplate['exercises'][0]['exercise_id'], imported['id']);
    expect((await importFitnessFixture(db: db, document: decoded)).skipped, 2);
  });

  test('同一文件先选偏好后选训练，仍然使用已导入的自定义动作', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final full = fitnessDocument(
      records: [template(), preferences(sourceId, '来源动作')],
    );
    await importFitnessFixture(
      db: db,
      document: FitnessTransferDocument(full.exportId, full.exportedAt, [
        full.records.last,
      ], space: full.space),
    );
    final second = await importFitnessFixture(
      db: db,
      document: FitnessTransferDocument(full.exportId, full.exportedAt, [
        full.records.first,
      ], space: full.space),
    );
    expect(second.imported, 1);
    final rows = await db.select(db.fitnessEntities).get();
    final prefs = jsonDecode(
      rows.singleWhere((r) => r.entityType == 'fitness_preferences').payload,
    );
    final plan = jsonDecode(
      rows.singleWhere((r) => r.entityType == 'fitness_template').payload,
    );
    expect(
      plan['exercises'][0]['exercise_id'],
      prefs['custom_exercises'][0]['id'],
    );
  });

  test('未选择自定义动作定义时拒绝整批写入，可回预览重新选择', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    await expectLater(
      importFitnessFixture(
        db: db,
        document: fitnessDocument(records: [template()]),
      ),
      throwsFormatException,
    );
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect(await db.select(db.fitnessImportReceipts).get(), isEmpty);
  });

  test('匹配目录只读取目标空间，不能混入首页当前空间的自定义动作', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final space = testFitnessSpaceId();
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [preferences(existingId, '目标动作')]),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue(null),
        fitnessBuiltinCatalogProvider.overrideWith((_) async => []),
        fitnessCatalogProvider.overrideWith(
          (_) => throw StateError('不应读取当前空间'),
        ),
      ],
    );
    addTearDown(container.dispose);
    final actions = container.read(fitnessFileActionsProvider);
    final catalog = await actions.catalog(await actions.target(space));
    expect(catalog.map((e) => e.nameZh), ['目标动作']);
  });
}
