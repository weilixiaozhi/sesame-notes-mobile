// 同步服务 410 游标过期 → 全量 resync 测试。
//
// 锚点：服务端清理同步历史后,旧游标请求返回 410 SYNC_CURSOR_EXPIRED,
// 客户端必须对全部云端账本执行 full 快照收敛,并用服务端返回的最新游标覆盖本地。
library;

import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide ExchangeRateOverride, Transaction, Category, RecurringTransaction;

class _MockSyncApi extends Mock implements SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late SyncService service;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    mockApi = _MockSyncApi();
    final client = SesameApiClient();
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('pull 收到 410 时对云端账本执行 full 并更新游标', () async {
    // seed:云端账本 + 旧游标(本地账本不应被 full 覆盖)。
    final now = DateTime.now().toUtc();
    await db.batch((b) {
      b.insertAll(db.ledgers, [
        LedgersCompanion.insert(
          id: 'led-cloud',
          name: '云端账本',
          storageMode: const d.Value('cloud'),
          updatedAt: now,
        ),
        LedgersCompanion.insert(
          id: 'led-local',
          name: '本地账本',
          storageMode: const d.Value('local'),
          updatedAt: now,
        ),
      ]);
      b.insertAll(db.transactions, [
        TransactionsCompanion.insert(
          id: 'tx-removed-remotely',
          ledgerId: 'led-cloud',
          txType: 'expense',
          amount: '10',
          happenedAt: now,
          currencyCode: 'CNY',
          nativeAmount: '10',
          createdAt: now,
          updatedAt: now,
        ),
        TransactionsCompanion.insert(
          id: 'tx-pending-local',
          ledgerId: 'led-cloud',
          txType: 'expense',
          amount: '20',
          happenedAt: now,
          currencyCode: 'CNY',
          nativeAmount: '20',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      b.insert(
        db.recurringTransactions,
        RecurringTransactionsCompanion.insert(
          id: 'recurring-removed-remotely',
          ledgerId: 'led-cloud',
          txType: 'expense',
          amount: '30',
          currencyCode: 'CNY',
          frequency: 'monthly',
          startDate: now,
          updatedAt: now,
        ),
      );
      b.insertAll(db.ledgerMembers, [
        LedgerMembersCompanion.insert(
          id: 'virtual-user-removed-remotely',
          ledgerId: 'led-cloud',
          displayName: '云端占位成员',
          memberType: 'PLACEHOLDER',
          updatedAt: now,
        ),
        LedgerMembersCompanion.insert(
          id: 'registered-member-not-in-virtual-users',
          ledgerId: 'led-cloud',
          displayName: '注册成员',
          memberType: 'REGISTERED',
          linkedAccountId: const d.Value('account-1'),
          updatedAt: now,
        ),
      ]);
    });
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx-pending-local',
            ledgerId: const d.Value('led-cloud'),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: 'mutation-pending-local',
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'dev-1',
            serverCursor: const d.Value('999'),
          ),
        );

    // pull 抛 410;full 返回空账本快照,游标前进到 1000。
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/pull'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          statusCode: 410,
        ),
      ),
    );
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-cloud'
            ..syncId = 'S-410'
            ..name = '云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = now,
        ).toBuilder()
        ..transactions = BuiltList<Transaction>().toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
        ..members = BuiltList<Member>().toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '1000',
    );
    // 3.1：full 携带本地 sync_id（此处 seed 行无 binding → null），stub 需显式覆盖
    when(
      () => mockApi.getSyncFull(
        ledgerId: 'led-cloud',
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    final applied = await service.pull();

    // full 只对云端账本执行,本地账本不受影响。
    verify(
      () => mockApi.getSyncFull(
        ledgerId: 'led-cloud',
        syncId: any(named: 'syncId'),
      ),
    ).called(1);
    verifyNever(() => mockApi.getSyncFull(ledgerId: 'led-local'));
    expect(applied, 0);
    // 游标被 full 响应覆盖。
    final state = await (db.select(
      db.syncState,
    )..where((s) => s.deviceId.equals('dev-1'))).getSingle();
    expect(state.serverCursor, '1000');

    // full 是服务端权威快照：快照中消失的云端交易必须 tombstone，
    // 但未推送的本地交易属于待合并分支，不能被快照静默删除。
    final removed = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('tx-removed-remotely'))).getSingle();
    final pending = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('tx-pending-local'))).getSingle();
    final recurring = await (db.select(
      db.recurringTransactions,
    )..where((t) => t.id.equals('recurring-removed-remotely'))).getSingle();
    final virtualUser = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.id.equals('virtual-user-removed-remotely'))).getSingle();
    final registeredMember =
        await (db.select(db.ledgerMembers)..where(
              (m) => m.id.equals('registered-member-not-in-virtual-users'),
            ))
            .getSingle();
    expect(removed.deletedAt, isNotNull);
    expect(pending.deletedAt, isNull);
    expect(recurring.deletedAt, isNotNull);
    expect(virtualUser.deletedAt, isNotNull);
    expect(registeredMember.deletedAt, isNull);
  });

  test('非 410 错误原样抛出,不触发 resync', () async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-cloud',
            name: '云端账本',
            storageMode: const d.Value('cloud'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'dev-1',
            serverCursor: const d.Value('5'),
          ),
        );
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/pull'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          statusCode: 500,
        ),
      ),
    );

    await expectLater(service.pull(), throwsA(isA<DioException>()));
    verifyNever(() => mockApi.getSyncFull(ledgerId: any(named: 'ledgerId')));
  });
}
