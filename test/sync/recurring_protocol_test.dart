import 'dart:convert';
import 'dart:typed_data';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, RecurringTransaction, Category, ExchangeRateOverride;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import '../helpers/test_isolation.dart';
import '../helpers/sync_response.dart';

class MockSyncApi extends Mock implements SyncApi {}

/// 真实传输边界读取冻结原文，避免生成 SDK 替身把非法日期先归一化。
class _RejectingFrozenDateAdapter implements HttpClientAdapter {
  final bodies = <String>[];

  /// 服务端只拒绝该条周期日期，回执直接使用请求原有身份。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = options.data as String;
    bodies.add(body);
    final wire = jsonDecode(body) as Map;
    final change = (wire['changes'] as List).single as Map;
    expect((change['payload'] as Map)['occurrence_date'], '2024-02-30');
    return ResponseBody.fromString(
      jsonEncode({
        'server_cursor': '100',
        'outcomes': [
          {
            'mutation_id': change['mutation_id'],
            'entity_id': change['entity_id'],
            'status': 'invalid',
            'code': 'INVALID_OCCURRENCE_DATE',
            'message': '周期发生日期无效',
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  /// 内存传输夹具不持有外部资源。
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => registerFallbackValue(
      PostSyncPushRequest(
        (b) => b
          ..deviceId = 'device'
          ..changes = ListBuilder<PostSyncPushRequestChangesInner>(),
      ),
    ),
  );
  late SesameDatabase db;
  late LocalRepository repo;
  late SyncService service;
  late MockSyncApi api;
  late String ledgerId;
  late String txId;
  final day = DateTime.utc(2024, 1, 1);
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = MockSyncApi();
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
      accountIdGetter: () => 'account',
    );
    service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'device',
      apiOverride: api,
      currentAccountIdGetter: () => 'account',
    );
    ledgerId = await repo.createLedger(name: '云账本', storageMode: 'cloud');
    await (db.update(db.ledgers)..where((row) => row.id.equals(ledgerId)))
        .write(const LedgersCompanion(syncId: d.Value('sync')));
    final ruleId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: day,
      timeZone: 'UTC',
    );
    final rule = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    expect(rule.id, ruleId);
    await db.delete(db.syncChanges).go();
    txId = await repo.generateRecurringTransaction(
      recurring: rule,
      happenedAt: day,
    );
  });
  tearDown(() => db.close());

  Future<void> duplicate({
    bool deleted = false,
    bool editAfterSend = false,
  }) async {
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
      final wire =
          standardSerializers.serialize(
                request,
                specifiedType: const FullType(PostSyncPushRequest),
              )
              as Map;
      final change = (wire['changes'] as List).single as Map;
      final payload = change['payload'] as Map;
      expect(payload['occurrence_date'], '2024-01-01');
      if (editAfterSend) {
        await repo.updateTransaction(
          id: txId,
          type: 'expense',
          amount: '77',
          note: '本地稍后编辑',
        );
      }
      final remote = {
        ...payload,
        'id': txId,
        'ledger_id': ledgerId,
        'amount': '22',
        'native_amount': '22',
        'note': '另一端修正',
        'revision': 3,
        'created_at': day.toIso8601String(),
        'updated_at': day.toIso8601String(),
      };
      return Response(
        requestOptions: RequestOptions(path: '/api/v1/sync/push'),
        data: acknowledgeSyncRequest(
          request,
          overrides: [
            PostSyncPush200ResponseOutcomesInner(
              (b) => b
                ..mutationId = change['mutation_id'] as String
                ..entityId = txId
                ..status =
                    PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored
                ..currentRevision = 3
                ..currentDeleted = deleted
                ..currentEntity = deleted ? null : JsonObject(remote),
            ),
          ],
        ),
      );
    });
    await service.push();
  }

  test('重复发生采用服务端人工修正快照并确认队首', () async {
    await duplicate();
    final row = (await repo.getTransactionById(txId))!;
    expect(row.amount, '22');
    expect(row.note, '另一端修正');
    expect(row.serverRevision, 3);
    expect((await db.select(db.syncChanges).get()).single.pushedAt, isNotNull);
  });
  test('重复发生收到远端墓碑不会复活', () async {
    await duplicate(deleted: true);
    expect(await repo.getTransactionById(txId), isNull);
    final row = (await db.select(db.transactions).get()).single;
    expect(row.serverRevision, 3);
    expect(row.occurrenceDate, '2024-01-01');
  });
  test('在途后继人工编辑保留并显式冲突，不盲重放覆盖远端', () async {
    await duplicate(editAfterSend: true);
    expect((await repo.getTransactionById(txId))!.amount, '77');
    final pending = (await db.select(db.syncChanges).get())
        .where((row) => row.pushedAt == null)
        .toList();
    expect(pending, hasLength(1));
    expect(jsonDecode(pending.single.payload)['amount'], '77');
    final conflict = (await db.select(db.syncConflicts).get()).single;
    expect(conflict.status, 'OPEN');
    expect(conflict.remoteRevision, 3);
    verify(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).called(1);
  });
  for (final rejection in [
    (
      code: 'INVALID_RECURRING_OCCURRENCE',
      message: '新周期账单必须携带可验证的发生日期',
      reason: '周期记账的发生身份、日期或排期无效，请检查关联的周期账单后重试。',
    ),
    (
      code: 'INVALID_RECURRING',
      message: '交易周期账单不存在或不属于当前账本',
      reason: '关联的周期账单在云端不可用，请先处理周期账单的同步问题。',
    ),
  ]) {
    test('周期拒收${rejection.code}保留单条错误，同账本普通交易仍正常确认', () async {
      await (db.update(db.transactions)..where((row) => row.id.equals(txId)))
          .write(const TransactionsCompanion(occurrenceDate: d.Value(null)));
      await db.delete(db.recurringTransactions).go();
      final pending = (await db.select(db.syncChanges).get()).single;
      final payload = jsonDecode(pending.payload) as Map<String, dynamic>;
      payload.remove('occurrence_date');
      await (db.update(db.syncChanges)
            ..where((row) => row.id.equals(pending.id)))
          .write(SyncChangesCompanion(payload: d.Value(jsonEncode(payload))));
      final ordinaryId = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8',
        happenedAt: day,
      );
      when(
        () => api.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
        final changes = syncRequestChanges(request);
        expect(
          changes.map((change) => change['entity_id']),
          containsAll([txId, ordinaryId]),
        );
        final rejectedPayload =
            changes.singleWhere(
                  (change) => change['entity_id'] == txId,
                )['payload']
                as Map;
        expect(rejectedPayload['occurrence_date'], isNull);
        return Response(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          data: acknowledgeSyncRequest(
            request,
            overrides: [
              PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = pending.mutationId
                  ..entityId = txId
                  ..status =
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                  ..code = rejection.code
                  ..message = rejection.message,
              ),
            ],
          ),
        );
      });
      await service.push();
      final changes = await db.select(db.syncChanges).get();
      final retained = changes.singleWhere((row) => row.entityId == txId);
      expect(retained.pushedAt, isNull);
      expect(retained.rejectionCode, rejection.code);
      expect(retained.rejectionReason, rejection.reason);
      expect(
        changes.singleWhere((row) => row.entityId == ordinaryId).pushedAt,
        isNotNull,
      );
      expect((await repo.getTransactionById(txId))!.amount, '10');
      verify(
        () => api.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).called(1);
    });
  }
  for (final invalidDate in <Object>['2024-02-30', '2024-2-03', 20240203]) {
    test('未冻结的非法发生日期$invalidDate准备失败，原记录和全部待推请求保持不变', () async {
      final pending = await db.select(db.syncChanges).getSingle();
      final payload = jsonDecode(pending.payload) as Map<String, dynamic>;
      payload['occurrence_date'] = invalidDate;
      await (db.update(db.syncChanges)
            ..where((row) => row.id.equals(pending.id)))
          .write(SyncChangesCompanion(payload: d.Value(jsonEncode(payload))));
      final ordinaryId = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8',
        happenedAt: day,
      );
      final beforeQueue = await db.select(db.syncChanges).get();
      final beforeEntities = await db.select(db.transactions).get();
      await expectLater(
        service.push(),
        throwsA(
          isA<SyncOperationFailure>()
              .having(
                (failure) => failure.code,
                'code',
                'SYNC_OCCURRENCE_DATE_INVALID',
              )
              .having((failure) => failure.target?.id, 'target', txId),
        ),
      );
      final afterQueue = await db.select(db.syncChanges).get();
      expect(afterQueue, beforeQueue, reason: '准备失败不能改正文、身份或冻结/回执状态');
      expect(await db.select(db.transactions).get(), beforeEntities);
      expect(
        afterQueue.every(
          (row) => row.frozenRequest == null && row.pushedAt == null,
        ),
        isTrue,
      );
      expect(
        afterQueue
            .singleWhere((row) => row.entityId == ordinaryId)
            .rejectionCode,
        isNull,
      );
      verifyZeroInteractions(api);
    });
  }

  test('结果未知的非法日期冻结请求仍原字节发送，由服务端明确拒收', () async {
    final pending = await db.select(db.syncChanges).getSingle();
    final payload = jsonDecode(pending.payload) as Map<String, dynamic>;
    payload['occurrence_date'] = '2024-02-30';
    final frozen =
        '${const JsonEncoder.withIndent('  ').convert({'mutation_id': pending.mutationId, 'entity_type': 'transaction', 'entity_id': txId, 'ledger_id': ledgerId, 'sync_id': 'sync', 'action': 'upsert', 'updated_at': pending.updatedAt.toUtc().toIso8601String(), 'payload': payload})}\n';
    await (db.update(
      db.syncChanges,
    )..where((row) => row.id.equals(pending.id))).write(
      SyncChangesCompanion(
        payload: d.Value(jsonEncode(payload)),
        frozenRequest: d.Value(frozen),
      ),
    );
    final client = SesameApiClient(
      basePathOverride: 'https://frozen-date.test',
    );
    final adapter = _RejectingFrozenDateAdapter();
    client.dio.httpClientAdapter = adapter;
    final realService = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
    );
    try {
      await realService.push();
      expect(adapter.bodies, hasLength(1));
      expect(adapter.bodies.single, contains(frozen));
      final retained = await db.select(db.syncChanges).getSingle();
      expect(retained.mutationId, pending.mutationId);
      expect(retained.frozenRequest, frozen);
      expect(retained.payload, jsonEncode(payload));
      expect(retained.rejectionCode, 'INVALID_OCCURRENCE_DATE');
      expect(retained.pushedAt, isNull);
      expect(
        (await repo.getTransactionById(txId))!.occurrenceDate,
        '2024-01-01',
      );
    } finally {
      client.dio.close(force: true);
    }
  });

  test('交易删除按身份发送，不因无关发生日期无效阻断', () async {
    final pending = await db.select(db.syncChanges).getSingle();
    final payload = jsonDecode(pending.payload) as Map<String, dynamic>;
    payload['occurrence_date'] = '2024-02-30';
    await (db.update(
      db.syncChanges,
    )..where((row) => row.id.equals(pending.id))).write(
      SyncChangesCompanion(
        action: const d.Value('delete'),
        payload: d.Value(jsonEncode(payload)),
      ),
    );
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
      final change = syncRequestChanges(request).single;
      expect(change['action'], 'delete');
      expect(change['mutation_id'], pending.mutationId);
      expect((change['payload'] as Map)['occurrence_date'], '2024-02-30');
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(request),
      );
    });
    await service.push();
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
    verify(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).called(1);
  });
  test('生产规则删除保留UTC时间并正常确认上传，历史来源保持不变', () async {
    await db
        .update(db.syncChanges)
        .write(SyncChangesCompanion(pushedAt: d.Value(day)));
    final ruleId = (await db.select(db.recurringTransactions).get()).single.id;
    await repo.deleteRecurringTransaction(ruleId);
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
      final wire =
          standardSerializers.serialize(
                request,
                specifiedType: const FullType(PostSyncPushRequest),
              )
              as Map;
      final changes = wire['changes'] as List;
      expect(changes, hasLength(1));
      expect((changes.single as Map)['action'], 'delete');
      return Response(
        requestOptions: RequestOptions(path: '/api/v1/sync/push'),
        data: acknowledgeSyncRequest(request),
      );
    });
    await service.push();
    expect(
      (await db.select(db.syncChanges).get()).every(
        (row) => row.pushedAt != null,
      ),
      isTrue,
    );
    expect((await repo.getTransactionById(txId))!.recurringId, ruleId);
  });

  test('规则删除正文缺少冗余时间仍按队列时刻上传，删除身份和历史来源保持不变', () async {
    try {
      await db
          .update(db.syncChanges)
          .write(SyncChangesCompanion(pushedAt: d.Value(day)));
      final ruleId =
          (await db.select(db.recurringTransactions).get()).single.id;
      await repo.deleteRecurringTransaction(ruleId);
      await (db.update(db.syncChanges)..where((row) => row.pushedAt.isNull()))
          .write(const SyncChangesCompanion(payload: d.Value('{}')));
      final before = await (db.select(
        db.syncChanges,
      )..where((row) => row.pushedAt.isNull())).getSingle();
      final sent = <Map<String, dynamic>>[];
      when(
        () => api.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
        sent.addAll(syncRequestChanges(request));
        return Response(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          data: acknowledgeSyncRequest(request),
        );
      });
      await service.push();
      final request = sent.single;
      expect(request['entity_type'], 'recurring_transaction');
      expect(request['entity_id'], ruleId);
      expect(request['mutation_id'], before.mutationId);
      expect(request['action'], 'delete');
      expect(request['payload'], jsonDecode(before.payload));
      expect(request['updated_at'], before.updatedAt.toIso8601String());
      final after = await (db.select(
        db.syncChanges,
      )..where((row) => row.id.equals(before.id))).getSingle();
      expect(after.entityId, before.entityId);
      expect(after.mutationId, before.mutationId);
      expect(after.updatedAt, before.updatedAt);
      expect(after.pushedAt, isNotNull);
      expect(
        await (db.select(
          db.syncChanges,
        )..where((row) => row.pushedAt.isNull())).get(),
        isEmpty,
      );
      expect((await repo.getTransactionById(txId))!.recurringId, ruleId);
      verify(
        () => api.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).called(1);
    } catch (error, stack) {
      logger.error(
        'RecurringProtocolTest',
        '周期删除队列时间回归失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  });
}
