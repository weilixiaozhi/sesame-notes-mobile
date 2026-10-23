import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart' hide RecurringTransaction;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

/// 只替代 HTTP 传输；同步投影、确认与 SQLite 事务使用真实实现。
class _SyncApi extends Mock implements SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => registerFallbackValue(
      PostSyncPushRequest(
        (builder) => builder
          ..deviceId = 'device'
          ..changes = ListBuilder<PostSyncPushRequestChangesInner>(),
      ),
    ),
  );

  late SesameDatabase db;
  late LocalRepository repo;
  late SyncService service;
  late _SyncApi api;
  late String ledgerId;
  late String ruleId;
  late Map<String, dynamic> original;
  final firstDay = DateTime.utc(2024, 1, 1);
  final metadataT0 = DateTime.utc(2024, 1, 1, 12);

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = _SyncApi();
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
    ledgerId = await repo.createLedger(name: '隔离云端游标账本', storageMode: 'cloud');
    await (db.update(
      db.ledgers,
    )..where((row) => row.id.equals(ledgerId))).write(
      const LedgersCompanion(
        syncId: d.Value('10000000-0000-4000-8000-000000000007'),
      ),
    );
    ruleId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: firstDay,
      timeZone: 'UTC',
      note: '原元数据',
    );
    final queued = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(ruleId))).getSingle();
    original = Map<String, dynamic>.from(jsonDecode(queued.payload) as Map)
      // pull 返回完整实体，包含 push 外壳携带的实体及账本身份。
      ..['id'] = ruleId
      ..['ledger_id'] = ledgerId
      ..['updated_at'] = metadataT0.toIso8601String();
    await (db.update(db.recurringTransactions)
          ..where((row) => row.id.equals(ruleId)))
        .write(RecurringTransactionsCompanion(updatedAt: d.Value(metadataT0)));
    // 建立已同步基线；后续被测写入是否排队由各用例独立断言。
    await db.delete(db.syncChanges).go();
  });
  tearDown(() => db.close());

  Future<void> editMetadata() => repo.updateRecurringTransaction(
    id: ruleId,
    ledgerId: ledgerId,
    type: 'expense',
    amount: '99.1234567890',
    frequency: 'daily',
    interval: 1,
    startDate: firstDay,
    note: '本地人工编辑',
    timeZone: 'UTC',
  );

  /// 将真实协议事件交给同步服务，断言投影及游标提交均完成。
  Future<void> pull(
    Map<String, dynamic> payload, {
    required int cursor,
    required DateTime envelopeTime,
    String action = 'upsert',
    bool invalid = false,
  }) async {
    final page = standardSerializers.deserializeWith(
      GetSyncPull200Response.serializer,
      {
        'changes': [
          {
            'change_id': '$cursor',
            'entity_type': 'recurring_transaction',
            'entity_id': ruleId,
            'ledger_id': ledgerId,
            'action': action,
            'payload': payload,
            'updated_at': envelopeTime.toIso8601String(),
            'device_id': '10000000-0000-4000-8000-000000000005',
            'mutation_id': '10000000-0000-4000-8000-000000000006',
          },
        ],
        'server_cursor': '$cursor',
        'has_more': false,
      },
    )!;
    when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
        statusCode: 200,
        data: page,
      ),
    );
    if (invalid) {
      await expectLater(service.pull(), throwsFormatException);
      expect(await db.select(db.syncPullErrors).get(), hasLength(1));
      return;
    }
    expect(await service.pull(), 1);
    expect(await db.select(db.syncPullErrors).get(), isEmpty);
    expect((await db.select(db.syncState).getSingle()).serverCursor, '$cursor');
  }

  for (final pending in [false, true]) {
    test('历史规则先写入后删除保留原墓碑，较新元数据及待推=$pending不能复活', () async {
      // 空库接收迁入的完整规则，再按真实增量顺序接收原历史删除事件。
      await db.delete(db.recurringTransactions).go();
      await pull(
        {...original, 'last_generated_date': '2024-01-03T00:00:00.000Z'},
        cursor: 1,
        envelopeTime: metadataT0.add(const Duration(days: 1)),
      );
      if (pending) await editMetadata();
      final before = await db.select(db.recurringTransactions).getSingle();
      final queue = await db.select(db.syncChanges).get();
      final historicalDeletion = metadataT0.subtract(const Duration(hours: 6));
      await pull(
        {'deleted_at': historicalDeletion.toIso8601String()},
        cursor: 2,
        envelopeTime: historicalDeletion,
        action: 'delete',
      );
      final after = await db.select(db.recurringTransactions).getSingle();
      expect(after.deletedAt?.toUtc(), historicalDeletion);
      expect(after.amount, before.amount);
      expect(after.note, before.note);
      expect(after.updatedAt, before.updatedAt);
      expect(after.lastGeneratedDate, before.lastGeneratedDate);
      expect(await db.select(db.syncChanges).get(), queue);
      expect(await repo.getRecurringTransactionsByLedger(ledgerId), isEmpty);
    });
  }

  for (final invalid in ['缺协议', '无效协议', '缺时区', '无效时区']) {
    for (final pending in [false, true]) {
      test('$invalid不能投影或默认补猜，待推=$pending时原规则和发生进度不变', () async {
        if (pending) await editMetadata();
        final before = (await db.select(db.recurringTransactions).get()).single;
        final later = metadataT0.add(const Duration(days: 1));
        final payload = {
          ...original,
          'amount': '99',
          'updated_at': later.toIso8601String(),
          'last_generated_date': '2024-01-03T00:00:00.000Z',
        };
        switch (invalid) {
          case '缺协议':
            payload.remove('protocol_version');
          case '无效协议':
            payload['protocol_version'] = 2;
          case '缺时区':
            payload.remove('time_zone');
          case '无效时区':
            payload['time_zone'] = 'Not/AZone';
        }
        await pull(payload, cursor: 1, envelopeTime: later, invalid: true);
        expect(
          (await db.select(db.recurringTransactions).get()).single,
          before,
        );
        expect(await db.select(db.transactions).get(), isEmpty);
      });
    }
  }

  test('连续生成只排发生交易，不改规则元数据时钟也不排整条规则', () async {
    final before = (await repo.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    await repo.generateRecurringTransaction(
      recurring: before,
      happenedAt: firstDay,
    );
    final next = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    await repo.generateRecurringTransaction(
      recurring: next,
      happenedAt: DateTime.utc(2024, 1, 2),
    );
    final after = (await repo.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    expect(after.updatedAt.toUtc(), metadataT0);
    expect(after.amount, before.amount);
    expect(after.note, before.note);
    expect(after.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 2));
    final queued = await db.select(db.syncChanges).get();
    expect(queued, hasLength(2));
    expect(queued.every((row) => row.entityType == 'transaction'), isTrue);
    expect(
      queued.map((row) => jsonDecode(row.payload)['occurrence_date']).toSet(),
      {'2024-01-01', '2024-01-02'},
    );
  });

  test('远端最大游标独立合并，保留待推送的本地元数据与原队列', () async {
    await editMetadata();
    final local = (await repo.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    final pending = (await db.select(db.syncChanges).get()).single;
    final t2 = local.updatedAt.toUtc().add(const Duration(days: 1));
    await pull(
      {...original, 'last_generated_date': '2024-01-03T00:00:00.000Z'},
      cursor: 1,
      envelopeTime: t2,
    );
    var after = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    expect(after.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 3));
    expect(after.amount, local.amount);
    expect(after.note, local.note);
    expect(after.updatedAt, local.updatedAt);
    expect((await db.select(db.syncChanges).get()).single, pending);
    // 即使另一个事件元数据时间更晚，pending 副本仍受保护，游标不能倒退。
    await pull(
      {
        ...original,
        'amount': '22',
        'updated_at': t2.toIso8601String(),
        'last_generated_date': '2024-01-02T00:00:00.000Z',
      },
      cursor: 2,
      envelopeTime: t2,
    );
    after = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    expect(after.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 3));
    expect(after.amount, local.amount);
    expect(after.updatedAt, local.updatedAt);
    expect((await db.select(db.syncChanges).get()).single, pending);
  });

  test('人工编辑已确认后，较晚游标事件的旧载荷时钟不能回退元数据', () async {
    await editMetadata();
    final local = (await repo.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
      expect(
        syncRequestChanges(request).single['entity_type'],
        'recurring_transaction',
      );
      return Response(
        requestOptions: RequestOptions(path: '/api/v1/sync/push'),
        data: acknowledgeSyncRequest(request),
        statusCode: 200,
      );
    });
    await service.push();
    expect((await db.select(db.syncChanges).get()).single.pushedAt, isNotNull);
    final t2 = local.updatedAt.toUtc().add(const Duration(days: 1));
    await pull(
      {...original, 'last_generated_date': '2024-01-03T00:00:00.000Z'},
      cursor: 101,
      envelopeTime: t2,
    );
    var after = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    expect(after.amount, local.amount);
    expect(after.note, local.note);
    expect(after.updatedAt, local.updatedAt);
    expect(after.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 3));
    // 真正较新的元数据允许应用，但旧游标仍不能覆盖已确认的较大进度。
    await pull(
      {
        ...original,
        'amount': '55',
        'note': '远端后续编辑',
        'updated_at': t2.toIso8601String(),
        'last_generated_date': '2024-01-02T00:00:00.000Z',
      },
      cursor: 102,
      envelopeTime: t2,
    );
    after = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
    expect(after.amount, '55');
    expect(after.note, '远端后续编辑');
    expect(after.updatedAt.toUtc(), t2);
    expect(after.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 3));
    expect(
      (await db.select(db.syncChanges).get()).where(
        (row) => row.pushedAt == null,
      ),
      isEmpty,
    );
  });
}
