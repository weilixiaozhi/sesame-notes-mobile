import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import '../helpers/fitness_space_fixture.dart';
import '../helpers/fitness_running_fixture.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart' as fitness;
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import '../helpers/test_isolation.dart';

const owner = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const otherOwner = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const templateId = '11111111-1111-4111-8111-111111111111';
const workoutId = '22222222-2222-4222-8222-222222222222';
const remoteWorkoutId = '33333333-3333-4333-8333-333333333333';
const binding = '44444444-4444-4444-8444-444444444444';
final instant = DateTime.utc(2026, 9, 11, 8, 30, 0, 123);

Map<String, dynamic> templatePayload({String name = '初始模板'}) =>
    fitness.FitnessTemplate(
      id: templateId,
      exercises: const [
        fitness.FitnessExercise(
          id: '66666666-6666-4666-8666-666666666666',
          exerciseId: '0025',
        ),
      ],
      name: name,
      createdAt: instant,
      updatedAt: instant,
    ).toJson();

Map<String, dynamic> workout({String name = '远端训练', bool running = false}) =>
    fitness.FitnessWorkout(
      id: workoutId,
      name: name,
      scheduledDate: '2026-09-11',
      status: running ? 'in_progress' : 'scheduled',
      runSegments: running
          ? [fitness.FitnessRunSegment(startedAt: instant)]
          : [],
      createdAt: instant,
      updatedAt: instant,
    ).toJson();

Map<String, dynamic> remote(
  String id,
  Map<String, dynamic> payload, {
  int revision = 1,
  String syncId = binding,
  bool deleted = false,
}) => {
  ...payload,
  'id': id,
  'sync_id': syncId,
  'fitness_space_id': testFitnessSpaceId(owner),
  'revision': revision,
  'deleted_at': deleted ? instant.toIso8601String() : null,
};

Map<String, dynamic> full({
  List<Map<String, dynamic>> templates = const [],
  List<Map<String, dynamic>> workouts = const [],
  String cursor = '10',
}) => {
  'fitness_space': {
    'id': testFitnessSpaceId(owner),
    'name': '测试健身空间',
    'sync_id': binding,
    'revision': 1,
    'created_at': DateTime.utc(2026).toIso8601String(),
    'updated_at': instant.toIso8601String(),
    'deleted_at': null,
  },
  'fitness_plans': [],
  'fitness_workouts': workouts,
  'fitness_templates': templates,
  'fitness_preferences': [],
  'server_cursor': cursor,
};

Map<String, dynamic> accepted(
  Map<String, dynamic> change, {
  int revision = 1,
}) => {
  'outcomes': [
    {
      'mutation_id': change['mutation_id'],
      'entity_id': change['entity_id'],
      'status': 'accepted',
      'revision': revision,
      'sync_id': binding,
      'change_id': '${revision + 10}',
    },
  ],
  'server_cursor': '${revision + 10}',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessRepository repo;
  late SyncService sync;
  late _Adapter adapter;
  late String? account;
  late int generation;

  setUp(() async {
    resetGlobalTestState();
    account = owner;
    generation = 1;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      clock: () => instant,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    ));
    adapter = _Adapter();
    final client = SesameApiClient(dio: Dio()..httpClientAdapter = adapter);
    sync = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
      fitnessEnabled: true,
    );
    addTearDown(() => client.dio.close(force: true));
    addTearDown(db.close);
  });

  Future<FitnessEntityRow> row(String id) => (db.select(
    db.fitnessEntities,
  )..where((e) => e.id.equals(id))).getSingle();
  Future<List<SyncChange>> pending() =>
      (db.select(db.syncChanges)..where((c) => c.pushedAt.isNull())).get();
  Future<void> bound() async {
    adapter.respond = (request, _) async {
      final snapshot = full(templates: [remote(templateId, templatePayload())]);
      return request.path.endsWith('/fitness-spaces')
          ? {
              'fitness_spaces': [
                {...snapshot['fitness_space'] as Map, 'entity_count': 1},
              ],
              'server_cursor': '10',
            }
          : snapshot;
    };
    await sync.discoverFitnessSpaces();
  }

  Future<void> editTemplate(String name) => repo.saveTemplate(
    fitness.FitnessTemplate(
      id: templateId,
      exercises: const [
        fitness.FitnessExercise(
          id: '66666666-6666-4666-8666-666666666666',
          exerciseId: '0025',
        ),
      ],
      name: name,
    ),
  );

  for (final missingRevision in [true, false]) {
    test('健身父空间${missingRevision ? '缺少冲突版本保留本地队列' : '明确不存在可采用远端墓碑'}', () async {
      final spaces = FitnessSpaceRepository(
        db,
        accountIdGetter: () => account,
        changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
      );
      final id = testFitnessSpaceId(owner);
      await spaces.renameBook(await spaces.target(id), '本地改名');
      adapter.respond = (_, data) async {
        final change = (data!['changes'] as List).single as Map;
        return {
          'outcomes': [
            {
              'mutation_id': change['mutation_id'],
              'entity_id': id,
              'status': 'conflict',
              if (!missingRevision) 'current_revision': 0,
              'current_deleted': true,
              'current_entity': null,
            },
          ],
          'server_cursor': '12',
        };
      };
      if (missingRevision) {
        await expectLater(sync.push(), throwsA(isA<FormatException>()));
        expect(await db.select(db.syncConflicts).get(), isEmpty);
        final change = (await pending()).single;
        expect(change.frozenRequest, isNotNull);
        expect(change.rejectionReason, isNull);
        expect(jsonDecode(change.payload)['name'], '本地改名');
        final space = await (db.select(
          db.fitnessSpaces,
        )..where((space) => space.id.equals(id))).getSingle();
        expect(space.name, '本地改名');
        expect(space.deletedAt, isNull);
      } else {
        await sync.push();
        final conflict = await db.select(db.syncConflicts).getSingle();
        expect(conflict.remoteRevision, 0);
        await sync.resolveConflictAdoptRemote(conflict.id);
        final space = await (db.select(
          db.fitnessSpaces,
        )..where((space) => space.id.equals(id))).getSingle();
        expect(space.deletedAt, isNotNull);
        expect(await pending(), isEmpty);
        expect(
          (await db.select(db.syncConflicts).getSingle()).status,
          'RESOLVED_REMOTE',
        );
      }
    });
  }

  test('空间与其他本共用父依赖：父空间确认之后才上传子记录', () async {
    const id = '77777777-7777-4777-8777-777777777777';
    final recorder = ChangeRecorderImpl(db, accountIdGetter: () => account);
    await FitnessSpaceRepository(
      db,
      accountIdGetter: () => account,
      changeRecorder: recorder,
    ).createBook(id: id, name: '新空间', storageMode: 'cloud');
    final scoped = FitnessRepository(
      db,
      spaceId: id,
      accountIdGetter: () => account,
      changeRecorder: recorder,
      clock: () => instant,
    );
    await scoped.saveTemplate(
      fitness.FitnessTemplate.fromJson(templatePayload()),
    );
    final sent = <Map<String, dynamic>>[];
    adapter.respond = (_, body) async {
      final change = Map<String, dynamic>.from(
        (body!['changes'] as List).single as Map,
      );
      sent.add(change);
      expect(change['fitness_space_id'], id);
      if (sent.length == 1) {
        expect(change['entity_type'], 'fitness_space');
        expect(change['sync_id'], isNull);
      } else {
        expect(change['entity_type'], 'fitness_template');
        expect(change['sync_id'], binding);
      }
      return accepted(change);
    };
    await sync.push();
    expect(sent, hasLength(2));
    expect(await pending(), isEmpty);
    expect((await scoped.getTemplates()).single.name, '初始模板');
    expect(await repo.getTemplates(), isEmpty);
  });

  test('真实生成客户端发送首创完整payload，保留null和毫秒，明确所属空间', () async {
    await editTemplate('初始模板');
    adapter.respond = (_, body) async {
      final change = (body!['changes'] as List).single as Map<String, dynamic>;
      expect(change['entity_type'], 'fitness_template');
      expect(change['ledger_id'], isNull);
      expect(change['day_book_id'], isNull);
      expect(change['memo_book_id'], isNull);
      expect(change['sync_id'], binding);
      expect(change['fitness_space_id'], repo.spaceId);
      expect(change['base_revision'], 0);
      expect(change['payload'], templatePayload());
      expect(jsonDecode((await pending()).single.frozenRequest!), change);
      return accepted(change);
    };
    await sync.push();
    expect(await pending(), isEmpty);
    expect((await row(templateId)).serverRevision, 1);
    expect((await row(templateId)).syncId, binding);
    expect(await db.select(db.ledgers).get(), isEmpty);
  });

  test('响应丢失后新编辑不改变冻结请求，确认后以新基线发送后继', () async {
    await bound();
    await editTemplate('离线模板');
    var fail = true;
    final sent = <Map<String, dynamic>>[];
    adapter.respond = (options, body) async {
      final change = (body!['changes'] as List).single as Map<String, dynamic>;
      sent.add(change);
      if (fail) {
        fail = false;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return accepted(change, revision: sent.length == 2 ? 2 : 3);
    };
    await expectLater(sync.push(), throwsA(isA<DioException>()));
    final frozen = (await pending()).single.frozenRequest;
    await editTemplate('远端模板');
    expect(await pending(), hasLength(2));
    expect((await pending()).first.frozenRequest, frozen);
    await sync.push();
    expect(sent[0], sent[1]);
    expect(sent[2]['base_revision'], 2);
    expect(sent[2]['mutation_id'], isNot(sent[1]['mutation_id']));
    expect((await repo.getTemplates()).single.name, '远端模板');
    expect((await row(templateId)).serverRevision, 3);
    expect(await pending(), isEmpty);
  });

  test('在途响应只确认旧版本，不覆盖更新输入；相同账号换代拒绝迟到确认', () async {
    await bound();
    await editTemplate('离线模板');
    adapter.respond = (_, body) async {
      await editTemplate('远端模板');
      generation++;
      return accepted(
        (body!['changes'] as List).single as Map<String, dynamic>,
        revision: 2,
      );
    };
    await expectLater(sync.push(), throwsA(isA<StateError>()));
    expect(jsonDecode((await row(templateId)).payload)['name'], '远端模板');
    expect((await row(templateId)).serverRevision, 1);
    expect(await pending(), hasLength(2));
    expect((await pending()).first.frozenRequest, isNotNull);
  });

  test('确认身份不匹配不标记成功，保留冻结请求供重试', () async {
    await editTemplate('离线模板');
    adapter.respond = (_, body) async {
      final response = accepted(
        (body!['changes'] as List).single as Map<String, dynamic>,
      );
      (response['outcomes'] as List).single['entity_id'] = workoutId;
      return response;
    };
    await expectLater(sync.push(), throwsA(isA<FormatException>()));
    expect((await pending()).single.frozenRequest, isNotNull);
    expect((await row(templateId)).serverRevision, 0);
  });

  test('完整快照中的空训练和永久墓碑保留，完整状态只在提交后发布', () async {
    adapter.respond = (_, _) async => full(
      templates: [remote(templateId, templatePayload())],
      workouts: [remote(workoutId, workout(), deleted: true)],
    );
    await sync.fullFitnessSpace(repo.spaceId);
    expect((await row(workoutId)).deletedAt, instant);
    expect(jsonDecode((await row(workoutId)).payload)['exercises'], isEmpty);
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
    expect(await db.select(db.syncState).get(), isEmpty);
    expect((await db.select(db.fitnessSpaces).getSingle()).fullCursor, '10');
    expect((await row(templateId)).createdAt, instant);
  });

  test('完整快照无效/账号切换/重复ID均不部分写入', () async {
    adapter.respond = (_, _) async => full(
      templates: [remote(templateId, templatePayload())],
      workouts: [
        remote(workoutId, {...workout(), 'scheduled_date': '2026-02-30'}),
      ],
    );
    await expectLater(sync.fullFitnessSpace(repo.spaceId), throwsA(anything));
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect((await db.select(db.fitnessSpaces).getSingle()).fullCursor, '0');
    adapter.respond = (_, _) async {
      account = otherOwner;
      return full(templates: [remote(templateId, templatePayload())]);
    };
    await expectLater(
      sync.fullFitnessSpace(repo.spaceId),
      throwsA(isA<StateError>()),
    );
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    account = owner;
    adapter.respond = (_, _) async => full(
      templates: [
        remote(templateId, templatePayload()),
        remote(templateId, templatePayload(name: '72')),
      ],
    );
    await expectLater(
      sync.fullFitnessSpace(repo.spaceId),
      throwsA(isA<FormatException>()),
    );
    expect((await db.select(db.fitnessSpaces).getSingle()).fullCursor, '0');
  });

  test('全量事务中途失败回滚全部实体及完整水位，取消后可以重试', () async {
    await db.customStatement(
      "CREATE TRIGGER fitness_fail BEFORE INSERT ON fitness_entities "
      "WHEN NEW.id='$workoutId' BEGIN SELECT RAISE(ABORT, 'injected'); END",
    );
    adapter.respond = (_, _) async => full(
      templates: [remote(templateId, templatePayload())],
      workouts: [remote(workoutId, workout())],
    );
    await expectLater(sync.fullFitnessSpace(repo.spaceId), throwsA(anything));
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect(await db.select(db.syncState).get(), isEmpty);
    await db.customStatement('DROP TRIGGER fitness_fail');
    await sync.fullFitnessSpace(repo.spaceId);
    expect(await db.select(db.fitnessEntities).get(), hasLength(2));
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
  });

  test('网络取消与过旧full保留既有完整缓存和水位', () async {
    await bound();
    adapter.respond = (options, _) async => throw DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
    );
    await expectLater(
      sync.fullFitnessSpace(repo.spaceId),
      throwsA(isA<DioException>()),
    );
    expect((await row(templateId)).serverRevision, 1);
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
    adapter.respond = (_, _) async => full(cursor: '9');
    await expectLater(
      sync.fullFitnessSpace(repo.spaceId),
      throwsA(isA<FormatException>()),
    );
    expect((await db.select(db.syncState).getSingle()).fitnessCursor, '10');
  });

  test('健身增量失败不推进该域水位，成功的记账域仍独立提交', () async {
    await bound();
    await db
        .update(db.syncState)
        .write(const SyncStateCompanion(serverCursor: d.Value('10')));
    adapter.respond = (_, _) async => {
      'changes': [
        {
          'change_id': '11',
          'entity_type': 'fitness_template',
          'entity_id': templateId,
          'ledger_id': null,
          'day_book_id': null,
          'memo_book_id': null,
          'fitness_space_id': testFitnessSpaceId(owner),
          'action': 'upsert',
          'payload': remote(templateId, templatePayload(name: ''), revision: 2),
          'updated_at': instant.toIso8601String(),
          'mutation_id': 'remote',
          'device_id': 'remote',
        },
      ],
      'server_cursor': '20',
      'has_more': false,
    };
    await expectLater(sync.pull(), throwsA(anything));
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '20');
    expect(state.fitnessCursor, '10');
    expect((await row(templateId)).serverRevision, 1);
    expect(
      (await db.select(db.syncPullErrors).getSingle()).entityType,
      'fitness_template',
    );
  });

  test('冲突保留最新本机内容并暂停实体，采用本机创建新CAS操作', () async {
    await bound();
    await editTemplate('离线模板');
    var calls = 0;
    adapter.respond = (_, body) async {
      calls++;
      final change = (body!['changes'] as List).single as Map<String, dynamic>;
      return {
        'outcomes': [
          {
            'mutation_id': change['mutation_id'],
            'entity_id': templateId,
            'status': 'conflict',
            'current_revision': 2,
            'current_deleted': false,
            'current_entity': remote(
              templateId,
              templatePayload(name: '远端模板'),
              revision: 2,
            ),
          },
        ],
        'server_cursor': '20',
      };
    };
    await sync.push();
    await editTemplate('本地模板');
    await sync.push();
    expect(calls, 1);
    expect((await repo.getTemplates()).single.name, '本地模板');
    final conflict = await db.select(db.syncConflicts).getSingle();
    await sync.resolveConflictKeepLocal(conflict.id);
    final resolution = (await pending()).single;
    expect(resolution.baseRevision, 2);
    expect(resolution.mutationId, isNot(conflict.localMutationId));
    expect(jsonDecode(resolution.payload)['name'], '本地模板');
    adapter.respond = (_, body) async => accepted(
      (body!['changes'] as List).single as Map<String, dynamic>,
      revision: 3,
    );
    await sync.push();
    expect((await row(templateId)).serverRevision, 3);
  });

  test('远端墓碑冲突不允许复活，跨账号不能处理原账号冲突', () async {
    await bound();
    await editTemplate('离线模板');
    adapter.respond = (_, _) async => full(
      templates: [
        remote(templateId, templatePayload(), revision: 2, deleted: true),
      ],
      cursor: '20',
    );
    await sync.fullFitnessSpace(repo.spaceId);
    final conflict = await db.select(db.syncConflicts).getSingle();
    await sync.resolveConflictKeepLocal(conflict.id);
    expect(await pending(), isEmpty, reason: '云端墓碑不生成复活请求');
    final localCopies = await (db.select(
      db.fitnessEntities,
    )..where((e) => e.scopeAccountId.isNull())).get();
    expect(localCopies, isNotEmpty);
    expect(
      localCopies.any((e) => jsonDecode(e.payload)['name'] == '离线模板'),
      isTrue,
    );
    account = otherOwner;
    await expectLater(
      sync.resolveConflictAdoptRemote(conflict.id),
      throwsA(isA<StateError>()),
    );
    expect((await row(templateId)).deletedAt, instant);
    account = owner;
    await sync.resolveConflictAdoptRemote(conflict.id);
    expect((await row(templateId)).deletedAt, instant);
    expect(await pending(), isEmpty);
  });

  test('未知结果full不覆盖本机分支，也不冒充该请求已确认', () async {
    await bound();
    await editTemplate('离线模板');
    adapter.respond = (options, _) async => throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
    await expectLater(sync.push(), throwsA(isA<DioException>()));
    adapter.respond = (_, _) async => full(
      templates: [
        remote(templateId, templatePayload(name: '远端模板'), revision: 3),
      ],
      cursor: '20',
    );
    await expectLater(
      sync.fullFitnessSpace(repo.spaceId),
      throwsA(isA<StateError>()),
    );
    expect((await db.select(db.fitnessSpaces).getSingle()).fullCursor, '10');
    expect((await db.select(db.syncState).getSingle()).fitnessCursor, '10');
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
    expect((await repo.getTemplates()).single.name, '离线模板');
    expect((await pending()).single.frozenRequest, isNotNull);
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    adapter.respond = (_, body) async => accepted(
      Map<String, dynamic>.from((body!['changes'] as List).single as Map),
      revision: 2,
    );
    await sync.push();
    adapter.respond = (_, _) async => full(
      templates: [
        remote(templateId, templatePayload(name: '远端模板'), revision: 3),
      ],
      cursor: '20',
    );
    await sync.fullFitnessSpace(repo.spaceId);
    expect((await repo.getTemplates()).single.name, '远端模板');
    expect((await row(templateId)).serverRevision, 3);
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
    expect((await db.select(db.fitnessSpaces).getSingle()).fullCursor, '20');
  });

  test('两个离线端同时开始不同训练，完整性阻断直到明确结束本机采用远端', () async {
    await runningWorkoutFixture(repo, id: workoutId, name: '本机正在训练');
    adapter.respond = (_, _) async => full(
      workouts: [
        remote(remoteWorkoutId, workout(name: '另一设备正在训练', running: true)),
      ],
    );
    await sync.fullFitnessSpace(repo.spaceId);
    expect((await repo.getWorkout(workoutId))!.status, 'in_progress');
    expect(await repo.getWorkout(remoteWorkoutId), isNull);
    await expectLater(
      FitnessDataTransfer.snapshot(
        db,
        fitnessSpaceId: repo.spaceId,
        accountId: owner,
      ),
      throwsStateError,
    );
    final conflict = await db.select(db.syncConflicts).getSingle();
    await expectLater(
      sync.resolveConflictKeepLocal(conflict.id),
      throwsA(isA<StateError>()),
    );
    await sync.resolveConflictAdoptRemote(conflict.id);
    expect((await repo.getWorkout(workoutId))!.status, 'completed');
    expect(
      (await repo.getWorkout(workoutId))!.runSegments.single.endedAt,
      isNotNull,
    );
    expect((await repo.getWorkout(remoteWorkoutId))!.status, 'in_progress');
    expect((await pending()).single.entityId, workoutId);
    expect(jsonDecode((await pending()).single.payload)['status'], 'completed');
    expect(
      fitnessTestComplete(await db.select(db.fitnessSpaces).getSingle()),
      isTrue,
    );
  });

  test('远端阻塞场次改变时保留旧分支，只有一个OPEN并可采用新场次', () async {
    await runningWorkoutFixture(repo, id: workoutId);
    adapter.respond = (_, _) async =>
        full(workouts: [remote(remoteWorkoutId, workout(running: true))]);
    await sync.fullFitnessSpace(repo.spaceId);
    const replacement = '55555555-5555-4555-8555-555555555555';
    adapter.respond = (_, _) async => full(
      cursor: '20',
      workouts: [remote(replacement, workout(name: '新的云训练', running: true))],
    );
    await sync.fullFitnessSpace(repo.spaceId);
    final conflicts = await db.select(db.syncConflicts).get();
    expect(conflicts, hasLength(2));
    expect(
      jsonDecode(
        conflicts
            .singleWhere(
              (c) => c.localMutationId.startsWith('fitness-superseded:'),
            )
            .remotePayload,
      )['id'],
      remoteWorkoutId,
    );
    final current = conflicts.singleWhere((c) => c.status == 'OPEN');
    expect(jsonDecode(current.remotePayload)['id'], replacement);
    await sync.resolveConflictAdoptRemote(current.id);
    expect((await repo.getWorkout(replacement))!.status, 'in_progress');
    expect((await repo.getWorkout(workoutId))!.status, 'completed');
  });

  test('首建墓碑直接携带deleted_at冻结，避免已删除进行中训练短暂复活', () async {
    await runningWorkoutFixture(repo, id: workoutId);
    await repo.deleteWorkout(workoutId);
    final sent = <Map<String, dynamic>>[];
    adapter.respond = (_, body) async {
      final change = (body!['changes'] as List).single as Map<String, dynamic>;
      sent.add(change);
      return accepted(change, revision: sent.length);
    };
    await sync.push();
    expect(sent.first['deleted_at'], instant.toIso8601String());
    expect(sent.first['action'], 'upsert');
    expect((sent.first['payload'] as Map)['status'], 'in_progress');
    expect((await row(workoutId)).deletedAt, instant);
    expect(await repo.getWorkouts(), isEmpty);
  });

  test('明确413保留拒绝内容，用户修正后创建可发送的新请求', () async {
    await bound();
    await editTemplate('离线模板');
    adapter.statusCode = 413;
    adapter.respond = (_, _) async => {'message': 'budget'};
    await sync.push();
    final rejected = (await pending()).single;
    expect(rejected.rejectionReason, 'SYNC_BUDGET');
    expect((await repo.getTemplates()).single.name, '离线模板');
    await editTemplate('远端模板');
    final corrected = (await pending()).single;
    expect(corrected.mutationId, isNot(rejected.mutationId));
    expect(corrected.frozenRequest, isNull);
    adapter.statusCode = 200;
    adapter.respond = (_, body) async => accepted(
      Map<String, dynamic>.from((body!['changes'] as List).single as Map),
      revision: 2,
    );
    await sync.push();
    expect(await pending(), isEmpty);
    expect((await repo.getTemplates()).single.name, '远端模板');
  });

  test('明确412保留冻结请求与实体并标记不完整，不清零绑定后冒充新建', () async {
    await bound();
    await editTemplate('离线模板');
    adapter.statusCode = 412;
    adapter.respond = (_, _) async => {
      'error': {'code': 'BINDING_STALE', 'message': 'stale'},
    };
    await sync.push();
    expect(
      (await (db.select(
        db.fitnessSpaces,
      )..where((b) => b.id.equals(repo.spaceId))).getSingle()).isStale,
      isTrue,
    );
    expect((await row(templateId)).syncId, binding);
    expect((await pending()).single.frozenRequest, isNotNull);
    expect(
      fitnessTestComplete(
        await (db.select(
          db.fitnessSpaces,
        )..where((b) => b.id.equals(repo.spaceId))).getSingle(),
      ),
      isFalse,
    );
  });
}

class _Adapter implements HttpClientAdapter {
  late Future<Map<String, dynamic>> Function(
    RequestOptions,
    Map<String, dynamic>?,
  )
  respond;
  int statusCode = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    Map<String, dynamic>? body;
    if (stream != null) {
      final bytes = BytesBuilder();
      await for (final chunk in stream) {
        bytes.add(chunk);
      }
      if (bytes.length > 0) {
        body =
            jsonDecode(utf8.decode(bytes.takeBytes())) as Map<String, dynamic>;
      }
    }
    return ResponseBody.fromString(
      jsonEncode(await respond(options, body)),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
