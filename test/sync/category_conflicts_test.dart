import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import '../helpers/test_isolation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_conflict_state.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/sync/internal/category_conflicts_handler.dart';
import 'package:sesame_notes/sync/internal/sync_runtime.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncRuntime runtime;
  late CategoryConflictsHandler handler;
  late String account;
  late int generation;
  late List<Map<String, dynamic>> server;
  late List<String> sent;
  late List<Map<String, dynamic>> projected;
  late Future<Map<String, dynamic>> Function(String, String) resolve;
  const category = '10000000-0000-4000-8000-000000000001';
  const candidateId = '20000000-0000-4000-8000-000000000001';
  const head = '30000000-0000-4000-8000-000000000001';
  final token = 'a' * 64;
  final nextToken = 'b' * 64;
  Map<String, dynamic> state({
    String name = '云端饮食',
    String? version,
    bool deleted = false,
  }) => {
    'id': category,
    'owner_id': account,
    'name': name,
    'kind': 'expense',
    'level': 1,
    'parent_id': null,
    'sort_order': 1,
    'icon': null,
    'updated_at': '2026-01-01T00:00:00.000Z',
    'deleted_at': deleted ? '2026-01-01T00:00:00.000Z' : null,
    'version_token': version ?? token,
  };
  Map<String, dynamic> candidate({
    String id = candidateId,
    String mutation = head,
    bool deleted = false,
    String device = 'device',
  }) => {
    'id': id,
    'category_id': category,
    'template_key': 'food',
    'source_device_id': device,
    'source_mutation_id': mutation,
    'candidate_version': 1,
    'action': 'upsert',
    'local_payload': {
      'name': '本地饮食',
      'kind': 'expense',
      'level': 1,
      'sort_order': 2,
      'icon': null,
      'parent_id': null,
    },
    'local_updated_at': '2026-01-01T00:00:00.000Z',
    'cloud_snapshot': state(deleted: deleted),
    'status': 'pending',
    'resolution': null,
    'created_at': '2026-01-01T00:00:00.000Z',
    'resolved_at': null,
  };
  Map<String, dynamic> receipt({
    String version = '',
    String device = 'device',
  }) => {
    'conflict_id': candidateId,
    'candidate_version': 2,
    'source_device_id': device,
    'source_mutation_id': head,
    'resolution': 'cloud',
    'category_state': state(version: version.isEmpty ? nextToken : version),
  };
  Future<SyncChange> queue(
    String mutation, {
    String? base,
    String? frozen,
  }) async {
    final id = await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: category,
            action: 'upsert',
            payload: jsonEncode({
              'name': mutation,
              'level': '1',
              'updated_at': '2026-01-01T00:00:00.000Z',
              'base_token': ?base,
            }),
            updatedAt: DateTime.utc(2026),
            mutationId: mutation,
            accountId: d.Value(account),
            frozenRequest: d.Value(frozen),
          ),
        );
    return (db.select(
      db.syncChanges,
    )..where((c) => c.id.equals(id))).getSingle();
  }

  setUp(() {
    resetGlobalTestState();
    account = 'A';
    generation = 1;
    server = [];
    sent = [];
    projected = [];
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient(
      basePathOverride: 'http://unused.invalid',
      serializers: apiSerializers,
    );
    runtime = SyncRuntime(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
      generation: 1,
    );
    resolve = (id, body) async => receipt();
    handler = CategoryConflictsHandler(
      runtime,
      CategoryConflictPorts(
        list: (cursor) async => {
          'items': server,
          'next_cursor': null,
          'has_more': false,
        },
        resolve: (id, body) {
          sent.add(body);
          return resolve(id, body);
        },
        project: (value, scope) async {
          expect(scope, account);
          projected.add(value);
        },
      ),
    );
  });
  tearDown(() async {
    client.dio.close();
    await db.close();
  });

  test('同ID多设备候选独立保存且不新增可见分类', () async {
    await handler.remember(candidate(), account);
    await handler.remember(
      candidate(id: 'second', mutation: 'other', device: 'other'),
      account,
    );
    expect(await db.select(db.syncConflicts).get(), hasLength(2));
    expect(await db.select(db.categories).get(), isEmpty);
    final issues = await readSyncIssues(db, account: account);
    expect(issues.where((i) => i.target.type == 'category'), hasLength(2));
    expect(issues.first.remote, isNot(contains('_category_conflict')));
  });
  test('同一服务端候选重复刷新按ID更新，冻结决策和其他来源保持独立', () async {
    final source = await queue(head, frozen: 'immutable source request');
    await handler.remember(
      candidate(id: 'another-candidate', mutation: 'other'),
      account,
    );
    await handler.remember(candidate(), account);
    await (db.update(
      db.syncConflicts,
    )..where((row) => row.id.equals(candidateId))).write(
      const SyncConflictsCompanion(
        resolutionRequest: d.Value('immutable decision'),
      ),
    );
    final other = await (db.select(
      db.syncConflicts,
    )..where((row) => row.id.equals('another-candidate'))).getSingle();
    await handler.remember({...candidate(), 'candidate_version': 2}, account);
    final candidates = await db.select(db.syncConflicts).get();
    expect(candidates, hasLength(2));
    final updated = candidates.singleWhere((row) => row.id == candidateId);
    expect(updated.remoteRevision, 2);
    expect(updated.resolutionRequest, 'immutable decision');
    expect(candidates.singleWhere((row) => row.id == other.id), other);
    expect(await db.select(db.syncChanges).getSingle(), source);
  });
  test('已解决候选确认源请求时落库失败，候选及源请求一并回滚', () async {
    final source = await queue(head, frozen: 'immutable source request');
    await db.customStatement(
      "CREATE TRIGGER fail_source_confirmation BEFORE UPDATE ON sync_changes WHEN OLD.mutation_id='$head' BEGIN SELECT RAISE(ABORT, 'injected source confirmation failure'); END;",
    );
    final resolved = {
      ...candidate(),
      'status': 'resolved',
      'resolution': 'cloud',
      'resolved_at': '2026-01-01T00:00:01.000Z',
    };
    await expectLater(
      handler.remember(resolved, account),
      throwsA(isA<Exception>()),
    );
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    expect(await db.select(db.syncChanges).getSingle(), source);
    expect(projected, isEmpty);
    await db.customStatement('DROP TRIGGER fail_source_confirmation');
    await handler.remember(resolved, account);
    expect(
      (await db.select(db.syncConflicts).getSingle()).status,
      'RESOLVED_REMOTE',
    );
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
  });
  test('未知回执冻结完整决策，重试仅清源head并保留后继基线', () async {
    await queue(head, frozen: 'original frozen');
    final successor = await queue('successor', base: token);
    await handler.remember(candidate(), account);
    resolve = (id, body) async => throw DioException(
      requestOptions: RequestOptions(path: '/resolve'),
      type: DioExceptionType.connectionError,
    );
    await expectLater(
      handler.resolve(
        candidateId,
        keepLocal: false,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    final frozen =
        (await db.select(db.syncConflicts).getSingle()).resolutionRequest;
    expect(frozen, isNotNull);
    expect(
      (await readSyncIssues(
        db,
        account: account,
      )).firstWhere((i) => i.id == candidateId).resolutionPending,
      isTrue,
    );
    resolve = (id, body) async => receipt(version: 'c' * 64);
    await handler.retry(candidateId);
    expect(sent, [frozen, frozen]);
    final rows = await db.select(db.syncChanges).get();
    expect(rows.first.pushedAt, isNotNull);
    expect(rows.last.payload, successor.payload);
    expect(rows.last.pushedAt, isNull);
    expect(projected, isEmpty);
  });
  test('显示后云快照变化不得隐式确认新token', () async {
    await handler.remember(candidate(), account);
    final changed = candidate()..['cloud_snapshot'] = state(version: nextToken);
    await handler.remember(changed, account);
    await expectLater(
      handler.resolve(
        candidateId,
        keepLocal: true,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    expect(sent, isEmpty);
    expect(
      (await db.select(db.syncConflicts).getSingle()).resolutionRequest,
      isNull,
    );
  });
  test('云墓碑必须明确恢复且只提交原ID候选', () async {
    await handler.remember(candidate(deleted: true), account);
    await expectLater(
      handler.resolve(
        candidateId,
        keepLocal: true,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    expect(sent, isEmpty);
    await handler.resolve(
      candidateId,
      keepLocal: true,
      expectedDecisionVersion: '1:$token',
      restoreDeleted: true,
    );
    expect(jsonDecode(sent.single)['restore_deleted'], isTrue);
    expect(await db.select(db.categories).get(), isEmpty);
  });
  test('本地删除候选遇云已删无需恢复确认，也不发送restore标记', () async {
    final deleted = candidate(deleted: true)
      ..['action'] = 'delete'
      ..['local_payload'] = null;
    await handler.remember(deleted, account);
    await handler.resolve(
      candidateId,
      keepLocal: true,
      expectedDecisionVersion: '1:$token',
    );
    final body = jsonDecode(sent.single) as Map;
    expect(body['choice'], 'local');
    expect(body.containsKey('restore_deleted'), isFalse);
  });
  test('确认响应迟到换账号不写库且原冻结请求仍保留', () async {
    await queue(head);
    await handler.remember(candidate(), account);
    final waiting = Completer<Map<String, dynamic>>();
    resolve = (id, body) => waiting.future;
    final operation = handler.resolve(
      candidateId,
      keepLocal: false,
      expectedDecisionVersion: '1:$token',
    );
    while (sent.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    account = 'B';
    generation++;
    waiting.complete(receipt());
    await expectLater(operation, throwsStateError);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNull);
    expect(
      (await db.select(db.syncConflicts).getSingle()).resolutionRequest,
      isNotNull,
    );
    expect(
      (await readSyncIssues(
        db,
        account: 'B',
      )).where((i) => i.target.type == 'category'),
      isEmpty,
    );
    expect(projected, isEmpty);
  });
  test('别的设备解决只清它的来源，不能清本机同ID编辑', () async {
    await queue(head);
    await handler.remember(candidate(device: 'other-device'), account);
    await handler.acceptResolution(receipt(device: 'other-device'), account);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNull);
    expect(projected, isEmpty);
  });
  test('CAS明确失败清冻结决策并刷新，候选及本地原请求不丢失', () async {
    await queue(head);
    final refreshed = candidate()
      ..['cloud_snapshot'] = state(version: nextToken);
    server = [refreshed];
    await handler.remember(candidate(), account);
    resolve = (id, body) async => throw DioException(
      requestOptions: RequestOptions(path: '/resolve'),
      response: Response(
        requestOptions: RequestOptions(path: '/resolve'),
        statusCode: 409,
      ),
    );
    await expectLater(
      handler.resolve(
        candidateId,
        keepLocal: true,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    final row = await db.select(db.syncConflicts).getSingle();
    expect(row.status, 'OPEN');
    expect(row.resolutionRequest, isNull);
    expect(
      categoryDecisionVersion(jsonDecode(row.remotePayload)),
      '1:$nextToken',
    );
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNull);
  });
  for (final replay in [false, true]) {
    test('正常${replay ? '重放不' : '首次仅已知基线'}续接未冻结后继', () async {
      final source = await queue(head, base: token);
      await queue('known', base: token);
      await queue('unknown');
      await queue('frozen', base: token, frozen: 'unchanged original');
      final rawOutcome = {
        'mutation_id': head,
        'entity_id': category,
        'status': replay ? 'ignored' : 'accepted',
        'change_id': '4',
        'category_state': state(version: nextToken),
      };
      // 走生产 DTO 序列化器，服务端夹具保持数值 level。
      final outcome = apiSerializers.deserializeWith(
        api.PostSyncPush200ResponseOutcomesInner.serializer,
        rawOutcome,
      )!;
      expect(await handler.applyOutcome(source, outcome, account), isTrue);
      final rows = await db.select(db.syncChanges).get();
      expect(
        jsonDecode(rows[1].payload)['base_token'],
        replay ? token : nextToken,
      );
      expect(jsonDecode(rows[2].payload).containsKey('base_token'), isFalse);
      expect(jsonDecode(rows[3].payload)['base_token'], token);
      expect(rows[3].frozenRequest, 'unchanged original');
      expect(projected, isEmpty);
    });
  }
  test('旧分类删除冻结完整JSON重放，字符串level、null和未知字段不丢失', () async {
    final original = {
      'mutation_id': head,
      'entity_type': 'category',
      'entity_id': category,
      'ledger_id': null,
      'action': 'delete',
      'updated_at': '2026-01-01T00:00:00.123Z',
      'payload': {
        'name': '旧版本饮食',
        'kind': 'expense',
        'level': '1',
        'icon': null,
        'parent_id': null,
        'sort_order': 3,
        'unknown': {
          'order': [null, 2, '1'],
        },
        'updated_at': '2026-01-01T00:00:00.123Z',
      },
    };
    final originalBytes = jsonEncode(original);
    final source = await queue(head, frozen: originalBytes);
    final sync = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
    );
    final decoded = sync.pushCoordinator.pendingFromFrozen(
      source.copyWith(action: 'delete'),
    );
    final encoded = runtime.modelMap(
      decoded,
      api.PostSyncPushRequestChangesInner.serializer,
    );
    expect(jsonEncode(encoded), originalBytes);
    String? sentChange;
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, '/api/v1/sync/push');
          final body = options.data as Map;
          sentChange = jsonEncode((body['changes'] as List).single);
          handler.resolve(
            Response(
              requestOptions: options,
              data: {'server_cursor': '0', 'outcomes': []},
            ),
          );
        },
      ),
    );
    await client.getSyncApi().postSyncPush(
      postSyncPushRequest: api.PostSyncPushRequest(
        (b) => b
          ..deviceId = 'device'
          ..changes.add(decoded),
      ),
    );
    expect(sentChange, originalBytes);
    expect(
      (await db.select(db.syncChanges).getSingle()).frozenRequest,
      originalBytes,
    );
  });
  Future<void> projectCloudState(
    SyncService service,
    Map<String, dynamic> value,
  ) => service.projectionHandler.upsertCategory(
    apiSerializers.deserializeWith(api.Category.serializer, {
      ...value,
      'level': '1',
    })!,
    accountId: account,
  );

  /// 本机草稿保留原云基线，不能用云投影入口把乐观编辑时钟伪装成服务端观测。
  Future<void> seedLocalDraft(String name) async {
    await db
        .into(db.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion.insert(
            id: category,
            name: name,
            kind: 'expense',
            level: 1,
            scopeAccountId: d.Value(account),
            serverVersionToken: d.Value(token),
            cloudRegistered: const d.Value(true),
            updatedAt: DateTime.utc(2026, 1, 1, 0, 0, 5),
          ),
        );
  }

  SyncService replayService(
    Map<String, dynamic> historical,
    List<String> bodies, {
    bool loseFirstReceipt = true,
  }) {
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, response) {
          if (!options.path.endsWith('/resolve')) {
            response.reject(
              DioException(
                requestOptions: options,
                error: 'unexpected request',
              ),
            );
            return;
          }
          bodies.add(jsonEncode(options.data));
          if (loseFirstReceipt && bodies.length == 1) {
            response.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            response.resolve(
              Response(requestOptions: options, data: historical),
              true,
            );
          }
        },
      ),
    );
    return SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
    );
  }

  for (final scenario in [
    (label: '同秒后续编辑', time: '2026-01-01T00:00:00.900Z', deleted: false),
    (label: '另一端较晚编辑', time: '2026-01-01T00:00:02.000Z', deleted: false),
    (label: '另一端后续删除', time: '2026-01-01T00:00:02.000Z', deleted: true),
  ]) {
    test('历史确认回执保留已投影的${scenario.label}，只确认原head', () async {
      await queue(head, base: token, frozen: 'original source request');
      final bodies = <String>[];
      final service = replayService(receipt(), bodies);
      await service.categoryConflicts.remember(candidate(), account);
      await expectLater(
        service.resolveCategoryConflict(
          candidateId,
          keepLocal: false,
          expectedDecisionVersion: '1:$token',
        ),
        throwsA(isA<CategoryDecisionException>()),
      );
      final frozen =
          (await db.select(db.syncConflicts).getSingle()).resolutionRequest;
      final current = state(name: '另一端更新后的饮食', version: 'c' * 64)
        ..['updated_at'] = scenario.time
        ..['deleted_at'] = scenario.deleted ? scenario.time : null;
      await projectCloudState(service, current);
      final before = await db.select(db.categories).getSingle();
      await service.retryCategoryConflictResolution(candidateId);
      expect(bodies, hasLength(2));
      expect(bodies.first, bodies.last);
      expect(jsonDecode(bodies.last), jsonDecode(frozen!));
      expect(await db.select(db.categories).getSingle(), before);
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
      expect(
        (await db.select(db.syncConflicts).getSingle()).resolutionRequest,
        isNull,
      );
    });
  }

  for (final scenario in [
    (currentMs: 950, receiptMs: 980, applies: true),
    (currentMs: 980, receiptMs: 950, applies: false),
  ]) {
    test('确认回执按毫秒排序 ${scenario.currentMs}→${scenario.receiptMs}', () async {
      final currentTime = DateTime.utc(
        2026,
      ).add(Duration(milliseconds: scenario.currentMs));
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: category,
              name: '已观测的分类墓碑',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('A'),
              updatedAt: currentTime,
              deletedAt: d.Value(currentTime),
              serverVersionToken: d.Value('c' * 64),
              cloudRegistered: const d.Value(true),
            ),
          );
      final authoritative = state(name: '确认的恢复状态', version: 'd' * 64)
        ..['updated_at'] = DateTime.utc(
          2026,
        ).add(Duration(milliseconds: scenario.receiptMs)).toIso8601String();
      await handler.acceptResolution(
        receipt(device: 'another-device')..['category_state'] = authoritative,
        account,
      );
      expect(projected, scenario.applies ? [authoritative] : isEmpty);
      final original = await db.select(db.categories).getSingle();
      expect(original.id, category);
      expect(original.scopeAccountId, account);
      expect(original.updatedAt, currentTime);
    });
  }

  test('旧目录S0与展示基线S1不同仍采用首次确认S2，覆盖较新的本地意图', () async {
    await queue(head, base: token, frozen: 'original local intent');
    final bodies = <String>[];
    final confirmed = state(name: '确认采用的云端饮食', version: 'c' * 64)
      ..['updated_at'] = '2026-01-01T00:00:00.500Z';
    final service = replayService(
      receipt()..['category_state'] = confirmed,
      bodies,
    );
    await seedLocalDraft('尚未上传的本地改名');
    final displayed = candidate()
      ..['cloud_snapshot'] = (state(version: nextToken)
        ..['updated_at'] = '2026-01-01T00:00:00.400Z');
    await service.categoryConflicts.remember(displayed, account);
    await expectLater(
      service.resolveCategoryConflict(
        candidateId,
        keepLocal: false,
        expectedDecisionVersion: '1:$nextToken',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    await service.retryCategoryConflictResolution(candidateId);
    final adopted = await db.select(db.categories).getSingle();
    expect(adopted.name, confirmed['name']);
    expect(adopted.serverVersionToken, confirmed['version_token']);
    expect(adopted.id, category);
    expect(bodies.first, bodies.last);
  });

  test('首次确认直接成功也采用S2，不误把旧S0目录的本地意图当新云状态', () async {
    await queue(head, base: token, frozen: 'original local intent');
    final bodies = <String>[];
    final confirmed = state(name: '首次确认的云端饮食', version: 'c' * 64)
      ..['updated_at'] = '2026-01-01T00:00:00.500Z';
    final service = replayService(
      receipt()..['category_state'] = confirmed,
      bodies,
      loseFirstReceipt: false,
    );
    await seedLocalDraft('较新的本地意图');
    await service.categoryConflicts.remember(
      candidate()..['cloud_snapshot'] = state(version: nextToken),
      account,
    );
    await service.resolveCategoryConflict(
      candidateId,
      keepLocal: false,
      expectedDecisionVersion: '1:$nextToken',
    );
    final adopted = await db.select(db.categories).getSingle();
    expect(adopted.name, confirmed['name']);
    expect(adopted.serverVersionToken, confirmed['version_token']);
    expect(bodies, hasLength(1));
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
  });

  for (final hasSuccessor in [false, true]) {
    test('本机草稿并行收到新云态，重建服务后旧确认不倒退，后继=$hasSuccessor', () async {
      final bodies = <String>[];
      final historical = receipt();
      final service = replayService(historical, bodies);
      await projectCloudState(service, state(name: '原云端分类', version: token));
      final repository = LocalRepository(
        db,
        accountIdGetter: () => account,
        changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => account),
      );
      await repository.updateCategory(category, name: '尚未确认的本机改名');
      final source = await db.select(db.syncChanges).getSingle();
      historical['source_mutation_id'] = source.mutationId;
      await service.pushCoordinator.freezePending(source, account);
      await service.categoryConflicts.remember(
        candidate(mutation: source.mutationId),
        account,
      );
      await expectLater(
        service.resolveCategoryConflict(
          candidateId,
          keepLocal: false,
          expectedDecisionVersion: '1:$token',
        ),
        throwsA(isA<CategoryDecisionException>()),
      );
      SyncChange? successor;
      if (hasSuccessor) {
        await repository.updateCategory(category, name: '后继本机改名');
        successor = (await db.select(db.syncChanges).get()).last;
      }
      final latest = state(name: '另一端后来确认的分类', version: 'c' * 64)
        ..['updated_at'] = '2026-01-01T00:00:02.950Z';
      await projectCloudState(service, latest);
      await projectCloudState(
        service,
        state(name: '更旧的分类事件', version: 'd' * 64)
          ..['updated_at'] = '2026-01-01T00:00:01.920Z',
      );
      final local = await db.select(db.categories).getSingle();
      expect(local.name, hasSuccessor ? '后继本机改名' : '尚未确认的本机改名');
      expect(local.serverVersionToken, token);
      expect(
        (jsonDecode(local.observedCloudState!) as Map)['version_token'],
        'c' * 64,
      );

      final rebuilt = SyncService(
        client: client,
        db: db,
        deviceId: 'device',
        currentAccountIdGetter: () => account,
        sessionGenerationGetter: () => generation,
      );
      await rebuilt.retryCategoryConflictResolution(candidateId);
      final adopted = await db.select(db.categories).getSingle();
      expect(adopted.id, category);
      expect(adopted.scopeAccountId, account);
      expect(adopted.name, hasSuccessor ? '后继本机改名' : latest['name']);
      expect(adopted.serverVersionToken, hasSuccessor ? token : 'c' * 64);
      expect(bodies.first, bodies.last);
      final changes = await db.select(db.syncChanges).get();
      expect(changes.first.pushedAt, isNotNull);
      if (successor != null) expect(changes.last, successor);
    });
  }

  test('push重放优先采用权威当前状态而非历史确认回执', () async {
    final source = await queue(head, base: token, frozen: 'original source');
    final service = replayService(receipt(), <String>[]);
    await service.categoryConflicts.remember(candidate(), account);
    await projectCloudState(
      service,
      state(name: '已投影目录', version: 'c' * 64)
        ..['updated_at'] = '2026-01-01T00:00:02.000Z',
    );
    final fresh = state(name: '权威当前目录', version: 'd' * 64)
      ..['updated_at'] = '2026-01-01T00:00:03.000Z';
    final response = {
      'mutation_id': head,
      'entity_id': category,
      'status': 'ignored',
      'category_resolution': receipt(),
      'category_state': fresh,
    };
    final outcome = apiSerializers.deserializeWith(
      api.PostSyncPush200ResponseOutcomesInner.serializer,
      response,
    )!;
    expect(
      await service.categoryConflicts.applyOutcome(source, outcome, account),
      isTrue,
    );
    final adopted = await db.select(db.categories).getSingle();
    expect(adopted.name, fresh['name']);
    expect(adopted.serverVersionToken, fresh['version_token']);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
  });
  test('上传回执迟于新云态到达，来源确认后显示新云态而非已确认草稿', () async {
    final service = replayService(receipt(), <String>[]);
    await projectCloudState(service, state(name: '原分类', version: token));
    final repository = LocalRepository(
      db,
      accountIdGetter: () => account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    await repository.updateCategory(category, name: '已上传的本机修改');
    final source = await db.select(db.syncChanges).getSingle();
    final frozen = (await service.pushCoordinator.freezePending(
      source,
      account,
    ))!;
    final sentAt = DateTime.parse(
      (jsonDecode(frozen.payload) as Map)['updated_at'] as String,
    );
    final observed = state(name: '另一端后来的修改', version: 'c' * 64)
      ..['updated_at'] = sentAt
          .add(const Duration(milliseconds: 20))
          .toIso8601String();
    await projectCloudState(service, observed);
    final earlier = state(name: '已上传的本机修改', version: nextToken)
      ..['updated_at'] = sentAt.toIso8601String();
    final outcome = apiSerializers.deserializeWith(
      api.PostSyncPush200ResponseOutcomesInner.serializer,
      {
        'mutation_id': source.mutationId,
        'entity_id': category,
        'status': 'accepted',
        'change_id': '70',
        'category_state': {...earlier, 'level': '1'},
      },
    )!;
    await service.pushCoordinator.applyPendingOutcome(frozen, outcome, account);
    final visible = await db.select(db.categories).getSingle();
    expect(visible.name, observed['name']);
    expect(visible.serverVersionToken, 'c' * 64);
    expect(visible.id, category);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
  });
  test('历史确认重试不改冻结后继或其基线，也不覆盖目录', () async {
    await queue(head, base: token, frozen: 'original source request');
    final successor = await queue(
      'successor',
      base: token,
      frozen: 'immutable successor request',
    );
    final bodies = <String>[];
    final service = replayService(receipt(), bodies);
    await service.categoryConflicts.remember(candidate(), account);
    await expectLater(
      service.resolveCategoryConflict(
        candidateId,
        keepLocal: false,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    await projectCloudState(
      service,
      state(name: '较新目录饮食', version: 'c' * 64)
        ..['updated_at'] = '2026-01-01T00:00:02.000Z',
    );
    final before = await db.select(db.categories).getSingle();
    await service.retryCategoryConflictResolution(candidateId);
    final changes = await db.select(db.syncChanges).get();
    expect(changes.first.pushedAt, isNotNull);
    expect(changes.last, successor);
    expect(await db.select(db.categories).getSingle(), before);
    expect(bodies.first, bodies.last);
  });
  test('正式SDK经过真实Dio序列化和level响应边界完成候选确认，丢回执不换body', () async {
    await queue(head);
    final bodies = <String>[];
    var posts = 0;
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/api/v1/category-conflicts') {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'items': [candidate()],
                  'has_more': false,
                  'next_cursor': null,
                },
              ),
              true,
            );
          } else if (options.path.endsWith('/resolve')) {
            bodies.add(jsonEncode(options.data));
            posts++;
            if (posts == 1) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            } else {
              handler.resolve(
                Response(requestOptions: options, data: receipt()),
                true,
              );
            }
          } else {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'unexpected request',
              ),
            );
          }
        },
      ),
    );
    final service = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
    );
    await service.refreshCategoryConflicts();
    expect(await db.select(db.categories).get(), isEmpty);
    await expectLater(
      service.resolveCategoryConflict(
        candidateId,
        keepLocal: false,
        expectedDecisionVersion: '1:$token',
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    final intent =
        (await db.select(db.syncConflicts).getSingle()).resolutionRequest;
    expect(intent, isNotNull);
    await service.retryCategoryConflictResolution(candidateId);
    expect(bodies, hasLength(2));
    expect(bodies.first, bodies.last);
    expect(jsonDecode(bodies.first), jsonDecode(intent!));
    final row = await db.select(db.categories).getSingle();
    expect(row.id, category);
    expect(row.name, '云端饮食');
    expect(row.serverVersionToken, nextToken);
    expect(row.scopeAccountId, account);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
    expect(
      (await db.select(db.syncConflicts).getSingle()).resolutionRequest,
      isNull,
    );
  });
}
