import '../../helpers/fitness_transfer_decoder.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import '../../helpers/fitness_space_fixture.dart';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/fitness_transfer_fixture.dart';
import '../../helpers/test_isolation.dart';

void main() {
  for (final settings in [
    const <String, FitnessExerciseRest>{},
    const {
      '0025': FitnessExerciseRest(restSeconds: 90, warmupRestSeconds: 15),
      '0001': FitnessExerciseRest(restSeconds: 120, warmupRestSeconds: 0),
    },
  ]) {
    test('真实健身偏好包含动作休息配置时 CSV 往返保持完整 $settings', () {
      final records = fitnessFixture();
      final index = records.indexWhere(
        (r) => r.entityType == 'fitness_preferences',
      );
      final previous = records[index];
      final payload = FitnessPreferences(
        defaultRestSeconds: 90,
        exerciseRestSettings: settings,
        createdAt: fitnessFixtureTime,
        updatedAt: fitnessFixtureTime,
      ).toJson();
      records[index] = FitnessTransferRecord(
        id: previous.id,
        entityType: previous.entityType,
        fitnessSpaceId: previous.fitnessSpaceId,
        payload: payload,
      );
      final decoded = decodeFitnessTransfer(
        FitnessTransferFormat.encode(fitnessDocument(records: records)),
      );
      expect(
        decoded.records.firstWhere((r) => r.id == previous.id).payload,
        payload,
      );
    });
  }

  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('完整 JSON 保留层级、精确重量、执行状态和关联，不含文件版本', () {
    final original = fitnessDocument();
    final bytes = FitnessTransferFormat.encode(original);
    final list = jsonDecode(utf8.decode(bytes)) as List;
    expect(list, hasLength(5));
    expect(utf8.decode(bytes), isNot(contains('schema_version')));
    final decoded = decodeFitnessTransfer(bytes);
    for (var i = 0; i < original.records.length; i++) {
      expect(decoded.records[i].id, original.records[i].id);
      final expected = original.records[i].payload;
      // 可选空休息记录采用领域模型的规范输出，所有实际内容仍逐项比较。
      final canonical = switch (original.records[i].entityType) {
        'fitness_template' => FitnessTemplate.fromJson(expected).toJson(),
        'fitness_plan' => FitnessPlan.fromJson(expected).toJson(),
        'fitness_workout' => FitnessWorkout.fromJson(expected).toJson(),
        _ => FitnessPreferences.fromJson(expected).toJson(),
      };
      expect(decoded.records[i].payload, canonical);
    }
  });

  test('计划和模板的官方来源标记在 JSON 导入导出中完整保留', () {
    final records = fitnessFixture();
    for (final index in [0, 1]) {
      records[index] = FitnessTransferRecord(
        id: records[index].id,
        entityType: records[index].entityType,
        fitnessSpaceId: records[index].fitnessSpaceId,
        payload: {
          ...records[index].payload,
          'catalog_origin': {
            'source': 'official',
            'item_id': fitnessId(90 + index),
            'revision': 2,
          },
        },
      );
    }

    final decoded = decodeFitnessTransfer(
      FitnessTransferFormat.encode(fitnessDocument(records: records)),
    );
    for (final index in [0, 1]) {
      expect(
        decoded.records[index].payload['catalog_origin'],
        records[index].payload['catalog_origin'],
      );
    }
  });

  test('JSON 拒绝非法编码、重复身份和无效业务关系', () {
    expect(() => decodeFitnessTransfer([0xff]), throwsFormatException);
    final rows =
        jsonDecode(utf8.decode(FitnessTransferFormat.encode(fitnessDocument())))
            as List;
    expect(
      () =>
          decodeFitnessTransfer(utf8.encode(jsonEncode([...rows, rows.first]))),
      throwsFormatException,
    );
    rows[0]['exercises'][0]['sets'][0]['weight'] = '-1';
    expect(
      () => decodeFitnessTransfer(utf8.encode(jsonEncode(rows))),
      throwsA(isA<Exception>()),
    );
    expect(
      () => decodeFitnessTransfer(utf8.encode('[{')),
      throwsFormatException,
    );
  });
  // 外部文件可能来自更新版本：多余字段既不拦导入，也不落库（读端只增不减）。
  test('导入文件带未知字段不拦导入，且不写进数据库', () async {
    final rows =
        jsonDecode(utf8.decode(FitnessTransferFormat.encode(fitnessDocument())))
            as List<dynamic>;
    final first = rows.first as Map<String, dynamic>;
    first['future_top_field'] = 'v2';
    final exercises = first['exercises'] as List<dynamic>?;
    if (exercises != null && exercises.isNotEmpty) {
      (exercises.first as Map<String, dynamic>)['future_nested_field'] = 42;
    }

    final document = decodeFitnessTransfer(utf8.encode(jsonEncode(rows)));
    expect(
      document.records.first.payload.containsKey('future_top_field'),
      isFalse,
    );

    final result = await importFitnessFixture(db: db, document: document);
    expect(result.imported, greaterThan(0));
    final stored = await db.select(db.fitnessEntities).get();
    expect(
      stored.any(
        (row) =>
            row.payload.contains('future_top_field') ||
            row.payload.contains('future_nested_field'),
      ),
      isFalse,
      reason: '未知字段不得落库',
    );
  });

  test('严格业务验证：遗漏/额外字段、空名、负值、错误组型和跨类型来源拒绝', () {
    for (final mutate in <void Function(List<FitnessTransferRecord>)>[
      (r) => r[0].payload.remove('name'),
      (r) => r[0].payload['remark'] = '禁止备注',
      (r) => r[0].payload['name'] = ' ',
      (r) => r[4].payload['weight'] = '-1',
      (r) => r[2].payload['source_plan_id'] = fitnessId(1),
      (r) => (r[2].payload['exercises'] as List)[0]['sets'][1]['reps'] = null,
      (r) => r[2].payload['run_segments'][1]['ended_at'] =
          '2026-09-11T06:00:00.000Z',
    ]) {
      final records = fitnessFixture();
      mutate(records);
      expect(
        () => FitnessTransferFormat.encode(fitnessDocument(records: records)),
        throwsA(isA<Exception>()),
      );
    }
  });

  test('目标导入全图映射、源记录未修改、重复/并发点击不重复、墓碑不复活', () async {
    final document = decodeFitnessTransfer(
      FitnessTransferFormat.encode(fitnessDocument()),
    );
    final results = await Future.wait([
      importFitnessFixture(db: db, document: document),
      importFitnessFixture(db: db, document: document),
    ]);
    expect(
      results.map((r) => r.imported).reduce((a, b) => a + b),
      fitnessFixture().length,
    );
    expect(await db.select(db.fitnessEntities).get(), hasLength(5));
    expect(await db.select(db.fitnessImportReceipts).get(), hasLength(5));
    final rows = await db.select(db.fitnessEntities).get();
    final plan = rows.singleWhere((r) => r.entityType == 'fitness_plan');
    final workout = rows.singleWhere(
      (r) =>
          r.entityType == 'fitness_workout' &&
          jsonDecode(r.payload)['source_kind'] == 'plan',
    );
    final template = rows.singleWhere(
      (r) => r.entityType == 'fitness_template',
    );
    final wp = jsonDecode(workout.payload) as Map;
    expect(wp['source_plan_id'], plan.id);
    expect(wp['source_template_id'], template.id);
    final slot = jsonDecode(plan.payload)['days'][0]['slot']['id'];
    expect(wp['occurrence_key'], '${plan.id}:0:0:$slot');
    expect(wp['exercises'][0]['sets'][0]['completed'], false);
    expect(wp['rest_timer'], {
      ...document.records[2].payload['rest_timer'] as Map,
      'exercise_id': wp['exercises'][0]['id'],
      'set_id': wp['exercises'][0]['sets'][1]['id'],
    });
    expect(wp['exercises'][0]['sets'][1]['rest_durations_seconds'], [17, 42]);
    expect(
      rows.every((r) => r.scopeAccountId == null && r.storageMode == 'local'),
      true,
    );
    await (db.update(
      db.fitnessEntities,
    )..where((r) => r.id.equals(workout.id))).write(
      FitnessEntitiesCompanion(deletedAt: d.Value(fitnessFixtureTime)),
    );
    final retry = await importFitnessFixture(db: db, document: document);
    expect(retry.imported, 0);
    expect(retry.skipped, 5);
    expect(
      (await (db.select(
        db.fitnessEntities,
      )..where((r) => r.id.equals(workout.id))).getSingle()).deletedAt,
      isNotNull,
    );
    expect(document.records[2].payload['source_plan_id'], fitnessId(2));
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('缺失来源的合法计划训练跨本机/账号导入保持独立派生ID及关系', () async {
    final document = fitnessDocument(records: [fitnessFixture()[2]]);
    final decoded = decodeFitnessTransfer(
      FitnessTransferFormat.encode(document),
    );
    final local = await importFitnessFixture(db: db, document: decoded);
    final account = fitnessId(800);
    final cloud = await importFitnessFixture(
      db: db,
      document: decoded,
      accountId: account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    expect(local.ids[fitnessId(3)], isNot(cloud.ids[fitnessId(3)]));
    final rows = await db.select(db.fitnessEntities).get();
    expect(rows, hasLength(2));
    for (final row in rows) {
      final mapping = row.scopeAccountId == null ? local.ids : cloud.ids;
      final payload = jsonDecode(row.payload) as Map;
      expect(payload['source_plan_id'], mapping[fitnessId(2)]);
      expect(payload['source_plan_id'], isNot(fitnessId(2)));
      expect(payload['source_template_id'], mapping[fitnessId(1)]);
      expect(
        payload['occurrence_key'],
        '${mapping[fitnessId(2)]}:0:0:${mapping[fitnessId(30)]}',
      );
    }
  });

  test('账号导入同事务登记upsert及首建墓碑，另账号不受影响', () async {
    final account = fitnessId(800);
    final source = fitnessFixture();
    source[2] = FitnessTransferRecord(
      fitnessSpaceId: testFitnessSpaceId(),
      id: source[2].id,
      entityType: source[2].entityType,
      payload: source[2].payload,
      deletedAt: fitnessFixtureTime,
    );
    final result = await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: source),
      accountId: account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    expect(result.imported, fitnessFixture().length);
    final rows = await db.select(db.fitnessEntities).get();
    expect(
      rows.every(
        (r) =>
            r.scopeAccountId == account &&
            r.storageMode == 'cloud' &&
            r.serverRevision == 0,
      ),
      true,
    );
    expect(
      rows.singleWhere((r) => r.entityType == 'fitness_preferences').id,
      testFitnessSpaceId(account),
    );
    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(5));
    expect(changes.every((r) => r.action == 'upsert'), true);
    expect(
      changes.every(
        (r) =>
            r.accountId == account &&
            r.ledgerId == null &&
            r.memoBookId == null,
      ),
      true,
    );
  });

  test('同步登记失败和进行中训练冲突均整笔回滚数据及回执', () async {
    await expectLater(
      importFitnessFixture(
        db: db,
        document: fitnessDocument(),
        accountId: fitnessId(800),
      ),
      throwsStateError,
    );
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect(await db.select(db.fitnessImportReceipts).get(), isEmpty);
    await importFitnessFixture(db: db, document: fitnessDocument());
    final before = await FitnessDataTransfer.fingerprint(
      db,
      testFitnessSpaceId(),
    );
    await expectLater(
      importFitnessFixture(db: db, document: fitnessDocument(export: 101)),
      throwsA(isA<Exception>()),
    );
    expect(
      await FitnessDataTransfer.fingerprint(db, testFitnessSpaceId()),
      before,
    );
  });

  test('覆盖已有账号偏好保留不可变创建时间并前推修改版本', () async {
    final account = fitnessId(800);
    final recorder = ChangeRecorderImpl(db, accountIdGetter: () => account);
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [fitnessFixture().last]),
      accountId: account,
      changeRecorder: recorder,
    );
    final original = await (db.select(
      db.fitnessEntities,
    )..where((r) => r.id.equals(testFitnessSpaceId(account)))).getSingle();
    final prefs = fitnessFixture().last;
    prefs.payload['created_at'] = '2020-01-01T00:00:00.000Z';
    prefs.payload['updated_at'] = '2020-01-01T00:00:00.000Z';
    prefs.payload['default_rest_seconds'] = 30;
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [prefs], export: 101),
      accountId: account,
      changeRecorder: recorder,
    );
    final actual = await (db.select(
      db.fitnessEntities,
    )..where((r) => r.id.equals(testFitnessSpaceId(account)))).getSingle();
    expect(actual.createdAt, original.createdAt);
    expect(actual.updatedAt.isAfter(original.updatedAt), true);
    expect(jsonDecode(actual.payload)['created_at'], fitnessTime);
    expect(jsonDecode(actual.payload)['default_rest_seconds'], 30);
  });

  test('提交期间换号整笔回滚；严格校验失败前不产生任何写入', () async {
    var checks = 0;
    await expectLater(
      importFitnessFixture(
        db: db,
        document: fitnessDocument(),
        validateContext: () {
          if (++checks == 4) throw StateError('session changed');
        },
      ),
      throwsStateError,
    );
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect(await db.select(db.fitnessImportReceipts).get(), isEmpty);
    final bad = fitnessFixture();
    bad[4].payload['weight'] = '0';
    await expectLater(
      importFitnessFixture(
        db: db,
        document: fitnessDocument(records: bad),
      ),
      throwsA(isA<Exception>()),
    );
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
  });

  test('已有偏好在确认导入后替换一次，恢复替换本地内容并保留账号', () async {
    await importFitnessFixture(db: db, document: fitnessDocument());
    final prefs = fitnessFixture().last;
    prefs.payload['default_rest_seconds'] = 0;
    final replacement = fitnessDocument(records: [prefs], export: 101);
    await importFitnessFixture(db: db, document: replacement);
    final p = await (db.select(
      db.fitnessEntities,
    )..where((r) => r.entityType.equals('fitness_preferences'))).getSingle();
    expect(jsonDecode(p.payload)['default_rest_seconds'], 0);
    final account = fitnessId(800);
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [fitnessFixture()[4]], export: 102),
      accountId: account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [], export: 103),
      replaceContents: true,
    );
    final rows = await db.select(db.fitnessEntities).get();
    expect(rows, hasLength(1));
    expect(rows.single.scopeAccountId, account);
    final receipts = await db.select(db.fitnessImportReceipts).get();
    expect(receipts, hasLength(1));
    expect(receipts.single.fitnessSpaceId, testFitnessSpaceId(account));
  });

  test('未完整下载/失效账号禁止完整导出，完整账号只读自己的域', () async {
    final account = fitnessId(800);
    await expectLater(
      FitnessDataTransfer.snapshot(
        db,
        accountId: account,
        fitnessSpaceId: testFitnessSpaceId(account),
      ),
      throwsStateError,
    );
    await seedFitnessTestSpace(db, account: account);
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [fitnessFixture()[4]]),
      accountId: account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    expect(
      await FitnessDataTransfer.snapshot(
        db,
        accountId: account,
        fitnessSpaceId: testFitnessSpaceId(account),
      ),
      hasLength(1),
    );
    await (db.update(db.fitnessEntities)
          ..where((r) => r.scopeAccountId.equals(account)))
        .write(const FitnessEntitiesCompanion(isStale: d.Value(true)));
    await expectLater(
      FitnessDataTransfer.snapshot(
        db,
        accountId: account,
        fitnessSpaceId: testFitnessSpaceId(account),
      ),
      throwsStateError,
    );
  });

  test('退出保护按空间复制，保留原本地空间与偏好，回执随副本重映射且重试幂等', () async {
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: [fitnessFixture().last]),
    );
    final originalLocal = await FitnessDataTransfer.fingerprint(
      db,
      testFitnessSpaceId(),
    );
    final account = fitnessId(800);
    final source = fitnessFixture();
    source.last.payload['default_rest_seconds'] = 45;
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: source, export: 101),
      accountId: account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    final repository = FitnessSpaceRepository(
      db,
      accountIdGetter: () => account,
    );
    final copy = await repository.copyToLocalForAccountExit(
      testFitnessSpaceId(account),
      'exit-A',
    );
    expect(
      await repository.copyToLocalForAccountExit(
        testFitnessSpaceId(account),
        'exit-A',
      ),
      copy,
    );
    expect(copy, isNot(testFitnessSpaceId()));
    expect(
      await FitnessDataTransfer.fingerprint(db, testFitnessSpaceId()),
      originalLocal,
    );
    final rows = await FitnessDataTransfer.snapshot(db, fitnessSpaceId: copy);
    expect(rows, hasLength(5));
    expect(
      rows
          .singleWhere((r) => r.entityType == 'fitness_preferences')
          .payload['default_rest_seconds'],
      45,
    );
    expect(
      await FitnessDataTransfer.skipped(
        db,
        fitnessDocument(records: source, export: 101),
        copy,
      ),
      5,
    );
    final branches = await (db.select(
      db.syncConflicts,
    )..where((c) => c.fitnessSpaceId.equals(copy))).get();
    expect(branches, hasLength(5));
    expect(branches.every((c) => c.status == 'RESOLVED_REMOTE'), isTrue);
  });
}
