// 同步引擎的 sync_id 绑定行为。
//
// 账本级 push 必须携带同步身份；首次上云由服务端
// 生成并经 outcome 返回落库；full 携带本地 binding 供服务端校验，
// 412 SYNC_ID_MISMATCH 时禁止静默覆盖（本地分支保留）。
library;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/sync/ledger_sync_state.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Transaction,
        TransactionSplit,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// mocktail 需要为不可空参数注册 fallback 值（仅占位，不会被交互）。
void _registerPushFallback() {
  registerFallbackValue(
    PostSyncPushRequest(
      (b) => b
        ..deviceId = 'dummy'
        ..changes = BuiltList<PostSyncPushRequestChangesInner>([
          PostSyncPushRequestChangesInner(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf(
                  (b) => b
                    ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf>(
                      value: PostSyncPushRequestChangesInnerAnyOfAnyOf(
                        (b) => b
                          ..mutationId = 'm'
                          ..entityType =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
                                  .ledger
                          ..entityId = 'x'
                          ..ledgerId = 'x'
                          ..action =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
                                  .upsert
                          ..updatedAt = DateTime.now()
                          ..payload =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfPayload(
                                (b) => b
                                  ..name = 'x'
                                  ..currency = 'CNY'
                                  ..monthStartDay = 1
                                  ..aaEnabled = false,
                              ).toBuilder(),
                      ),
                    ),
                ),
              ),
          ),
        ]).toBuilder(),
    ),
  );
}

/// 从 push 请求的第一个 change 中提取 sync_id（嵌套 anyOf 结构）。
///
/// 生成模型的 anyOf 静态类型为 one_of 基类 AnyOf（无 value getter），
/// 运行时按实体变体类型匹配取值。
String? _firstChangeSyncId(PostSyncPushRequest req) {
  final outerValue = req.changes.first.anyOf.values.values.firstWhere(
    (v) => v != null,
  );
  return switch (outerValue) {
    PostSyncPushRequestChangesInnerAnyOf v => _anyOfSyncId(v.anyOf),
    PostSyncPushRequestChangesInnerAnyOf1 v => _anyOfSyncId(v.anyOf),
    PostSyncPushRequestChangesInnerAnyOf2 v => _anyOfSyncId(v.anyOf),
    PostSyncPushRequestChangesInnerAnyOf3 v => _anyOfSyncId(v.anyOf),
    PostSyncPushRequestChangesInnerAnyOf4 v => _anyOfSyncId(v.anyOf),
    PostSyncPushRequestChangesInnerAnyOf5 v => _anyOfSyncId(v.anyOf),
    _ => null,
  };
}

/// 从实体变体（upsert/delete）中读取 sync_id。
String? _anyOfSyncId(AnyOf anyOf) {
  final value = anyOf.values.values.firstWhere((v) => v != null);
  return switch (value) {
    PostSyncPushRequestChangesInnerAnyOfAnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOfAnyOf1 v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf1AnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf1AnyOf1 v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf2AnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1 v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf3AnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf3AnyOf1 v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf4AnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf4AnyOf1 v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf5AnyOf v => v.syncId,
    PostSyncPushRequestChangesInnerAnyOf5AnyOf1 v => v.syncId,
    _ => null,
  };
}

/// 最小合法交易 payload（服务端契约字段，测试侧由 mock 直接消费）。
String _txPayload() => jsonEncode({
  'tx_type': 'expense',
  'amount': '10',
  'happened_at': '2026-08-22T10:00:00.000Z',
  'note': null,
  'category_id': null,
  'exclude_from_stats': false,
  'currency_code': 'CNY',
  'native_amount': '10',
  'recurring_id': null,
  'paid_by_user_id': null,
  'aa_mode': null,
  'splits': <Object>[],
  'version': 1,
  'last_edited_at': null,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late SyncService service;

  setUpAll(_registerPushFallback);

  setUp(() {
    resetGlobalTestState();
  });

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

  Future<void> seedCloudLedger(String id, {String? syncId}) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: '云端账本',
            storageMode: const d.Value('cloud'),
            syncId: d.Value(syncId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> seedPendingTxChange(String ledgerId) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx-1',
            // ledger_id 可空列需 Value 包装；payload 为非空列直接传 String
            ledgerId: d.Value(ledgerId),
            action: 'upsert',
            payload: _txPayload(),
            updatedAt: DateTime.utc(2026, 8, 22, 10),
            mutationId: 'm-tx-1',
          ),
        );
  }

  PostSyncPush200Response pushOk({String? outcomeSyncId}) =>
      PostSyncPush200Response(
        (b) => b
          ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>([
            PostSyncPush200ResponseOutcomesInner(
              (b) => b
                // per-mutation 协议：outcome 必须携带 mutation_id 与队列行对应
                ..mutationId = 'm-tx-1'
                ..entityId = 'led-1'
                ..status =
                    PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
                ..changeId = '1'
                ..syncId = outcomeSyncId,
            ),
          ]).toBuilder()
          ..serverCursor = '1',
      );

  void mockPushOk({String? outcomeSyncId}) {
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: pushOk(outcomeSyncId: outcomeSyncId),
        statusCode: 200,
      ),
    );
  }

  test('push：账本级变更携带本地 sync_id（绑定已建立）', () async {
    await seedCloudLedger('led-1', syncId: 'S100');
    await seedPendingTxChange('led-1');
    mockPushOk();

    await service.push();

    final captured = verify(
      () => mockApi.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final req = captured.single as PostSyncPushRequest;
    expect(_firstChangeSyncId(req), 'S100');
  });

  test('push：首次上云（无 sync_id）请求缺省，outcome 返回后落库建立绑定', () async {
    await seedCloudLedger('led-1'); // sync_id 为 NULL
    await seedPendingTxChange('led-1');
    mockPushOk(outcomeSyncId: 'S-NEW');

    await service.push();

    final captured = verify(
      () => mockApi.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final req = captured.single as PostSyncPushRequest;
    expect(_firstChangeSyncId(req), isNull);
    // outcome 返回的 sync_id 已落库
    final rows = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals('led-1'))).get();
    expect(rows.single.syncId, 'S-NEW');
  });

  test('full：携带本地 sync_id 请求（服务端校验同步身份）', () async {
    await seedCloudLedger('led-1', syncId: 'S100');
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-1'
            ..syncId = 'S100'
            ..name = '云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = DateTime.now().toUtc(),
        ).toBuilder()
        ..transactions = BuiltList<Transaction>().toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
        ..members = BuiltList<Member>().toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '10',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    await service.full(ledgerId: 'led-1');

    verify(
      () => mockApi.getSyncFull(ledgerId: 'led-1', syncId: 'S100'),
    ).called(1);
  });

  test('full：本地无该账本时首次绑定（快照 sync_id 落库）', () async {
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-new'
            ..syncId = 'S-FIRST'
            ..name = '新云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = DateTime.now().toUtc(),
        ).toBuilder()
        ..transactions = BuiltList<Transaction>().toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
        ..members = BuiltList<Member>().toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '5',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    await service.full(ledgerId: 'led-new');

    // 首次绑定：请求不带 sync_id，返回的快照 sync_id 落库
    final captured = verify(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: captureAny(named: 'syncId'),
      ),
    ).captured;
    expect(captured.single, isNull);
    final rows = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals('led-new'))).get();
    expect(rows.single.syncId, 'S-FIRST');
  });

  test('full：快照中的各类实体必须在当前账号域复活 tombstone', () async {
    await seedCloudLedger('led-1', syncId: 'S100');
    final deletedAt = DateTime.utc(2026, 8, 23);
    final updatedAt = DateTime.utc(2026, 8, 24);
    await (db.update(db.ledgers)..where((row) => row.id.equals('led-1'))).write(
      LedgersCompanion(deletedAt: d.Value(deletedAt)),
    );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'transaction-1',
            ledgerId: 'led-1',
            txType: 'expense',
            amount: '1',
            happenedAt: deletedAt,
            currencyCode: 'CNY',
            nativeAmount: '1',
            serverRevision: const d.Value(1),
            createdAt: deletedAt,
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'category-1',
            name: '已删除分类',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('user-1'),
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'recurring-1',
            ledgerId: 'led-1',
            txType: 'expense',
            amount: '1',
            currencyCode: 'CNY',
            frequency: 'monthly',
            startDate: deletedAt,
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.exchangeRateOverrides)
        .insert(
          ExchangeRateOverridesCompanion.insert(
            id: 'rate-1',
            baseCurrency: 'CNY',
            quoteCurrency: 'USD',
            rate: '7.0',
            scopeAccountId: const d.Value('user-1'),
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-1'
            ..syncId = 'S100'
            ..name = '云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = updatedAt,
        ).toBuilder()
        ..transactions = BuiltList<Transaction>([
          Transaction(
            (b) => b
              ..id = 'transaction-1'
              ..ledgerId = 'led-1'
              ..txType = TransactionTxTypeEnum.expense
              ..amount = '2'
              ..happenedAt = updatedAt
              ..excludeFromStats = false
              ..currencyCode = 'CNY'
              ..nativeAmount = '2'
              ..splits = BuiltList<TransactionSplit>().toBuilder()
              ..revision = 2
              ..updatedAt = updatedAt
              ..createdAt = deletedAt,
          ),
        ]).toBuilder()
        ..categories = BuiltList<Category>([
          Category(
            (b) => b
              ..id = 'category-1'
              ..name = '餐饮'
              ..kind = CategoryKindEnum.expense
              ..level = CategoryLevelEnum.n1
              ..sortOrder = 0
              ..updatedAt = updatedAt,
          ),
        ]).toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>([
          RecurringTransaction(
            (b) => b
              ..id = 'recurring-1'
              ..ledgerId = 'led-1'
              ..txType = RecurringTransactionTxTypeEnum.expense
              ..amount = '2'
              ..currencyCode = 'CNY'
              ..frequency = RecurringTransactionFrequencyEnum.monthly
              ..interval = 1
              ..startDate = deletedAt
              ..enabled = true
              ..updatedAt = updatedAt,
          ),
        ]).toBuilder()
        ..members = BuiltList<Member>().toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>([
          ExchangeRateOverride(
            (b) => b
              ..id = 'rate-1'
              ..baseCurrency = 'CNY'
              ..quoteCurrency = 'USD'
              ..rate = '7.5'
              ..updatedAt = updatedAt,
          ),
        ]).toBuilder()
        ..serverCursor = '10',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    // 登录态拉取：覆盖行必须归属当前账号域，否则多账号下会与本地域
    // partial unique 冲突（同币对两行）或写错域。
    final svc = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );
    await svc.full(ledgerId: 'led-1');

    final rate = await (db.select(
      db.exchangeRateOverrides,
    )..where((t) => t.id.equals('rate-1'))).getSingle();
    final ledger = await (db.select(
      db.ledgers,
    )..where((t) => t.id.equals('led-1'))).getSingle();
    final category = await (db.select(
      db.categories,
    )..where((t) => t.id.equals('category-1'))).getSingle();
    expect(rate.scopeAccountId, 'user-1');
    expect(rate.rate, '7.5');
    expect(ledger.scopeAccountId, 'user-1');
    expect(category.scopeAccountId, 'user-1');

    final deletedAtByEntity = <String, Future<DateTime?>>{
      'ledger': Future.value(ledger.deletedAt),
      'transaction':
          (db.select(db.transactions)
                ..where((row) => row.id.equals('transaction-1')))
              .getSingle()
              .then((row) => row.deletedAt),
      'category': Future.value(category.deletedAt),
      'recurring_transaction':
          (db.select(db.recurringTransactions)
                ..where((row) => row.id.equals('recurring-1')))
              .getSingle()
              .then((row) => row.deletedAt),
      'exchange_rate_override': Future.value(rate.deletedAt),
    };
    for (final entry in deletedAtByEntity.entries) {
      expect(
        await entry.value,
        isNull,
        reason: 'full 快照应复活 ${entry.key} tombstone',
      );
    }
  });

  test('full：有待推送账本删除时必须保留本地 tombstone', () async {
    final deletedAt = DateTime.utc(2026, 8, 23);
    final updatedAt = DateTime.utc(2026, 8, 24);
    await seedCloudLedger('led-1', syncId: 'S100');
    await (db.update(db.ledgers)..where((row) => row.id.equals('led-1'))).write(
      LedgersCompanion(deletedAt: d.Value(deletedAt)),
    );
    final storedDeletedAt = (await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('led-1'))).getSingle()).deletedAt;
    expect(storedDeletedAt, isNotNull);
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: 'led-1',
            ledgerId: const d.Value('led-1'),
            action: 'delete',
            payload: '{}',
            updatedAt: updatedAt,
            mutationId: 'pending-ledger-delete',
            accountId: const d.Value('user-1'),
          ),
        );
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-1'
            ..syncId = 'S100'
            ..name = '云端仍存在的账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = updatedAt,
        ).toBuilder()
        ..transactions = BuiltList<Transaction>().toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
        ..members = BuiltList<Member>().toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '11',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );
    final svc = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );

    await svc.full(ledgerId: 'led-1');

    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('led-1'))).getSingle();
    expect(ledger.deletedAt, storedDeletedAt);
  });

  test('member：增量与 full upsert 都必须复活本地 tombstone', () async {
    final deletedAt = DateTime.utc(2026, 8, 23);
    final updatedAt = DateTime.utc(2026, 8, 24);
    await seedCloudLedger('led-1', syncId: 'S100');
    for (final id in ['member-delta', 'member-full']) {
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: id,
              ledgerId: 'led-1',
              displayName: '旧成员',
              memberType: 'PLACEHOLDER',
              status: const d.Value('REMOVED'),
              updatedAt: deletedAt,
              deletedAt: d.Value(deletedAt),
            ),
          );
    }
    final deltaChange = GetSyncPull200ResponseChangesInner(
      (b) => b
        ..changeId = 'member-change-1'
        ..ledgerId = 'led-1'
        ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.member
        ..entityId = 'member-delta'
        ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
        ..mutationId = 'remote-member-delta'
        ..payload = MapBuilder<String, JsonObject?>({
          'display_name': JsonObject('增量复活成员'),
          'updated_at': JsonObject(updatedAt.toIso8601String()),
        })
        ..updatedAt = updatedAt
        ..deviceId = 'remote-device',
    );
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              deltaChange,
            ]).toBuilder()
            ..serverCursor = '20'
            ..hasMore = false,
        ),
      ),
    );

    await service.pull();
    final deltaDeletedAt =
        (await (db.select(
              db.ledgerMembers,
            )..where((member) => member.id.equals('member-delta'))).getSingle())
            .deletedAt;

    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-1'
            ..syncId = 'S100'
            ..name = '云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..updatedAt = updatedAt,
        ).toBuilder()
        ..transactions = BuiltList<Transaction>().toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
        ..members = BuiltList<Member>([
          for (final id in ['member-delta', 'member-full'])
            Member(
              (b) => b
                ..id = id
                ..ledgerId = 'led-1'
                ..displayName = 'full 复活成员'
                ..memberType = MemberMemberTypeEnum.PLACEHOLDER
                ..status = MemberStatusEnum.ACTIVE
                ..updatedAt = updatedAt,
            ),
        ]).toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '21',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    await service.full(ledgerId: 'led-1');
    final fullDeletedAt =
        (await (db.select(
              db.ledgerMembers,
            )..where((member) => member.id.equals('member-full'))).getSingle())
            .deletedAt;
    expect(
      [deltaDeletedAt, fullDeletedAt],
      everyElement(isNull),
      reason: '远端当前存在的成员必须清除旧 tombstone，恢复为可读实体',
    );
  });

  test('member：接受邀请的 pull 自动 full，补齐历史且不越过未拉取的全局事件', () async {
    final acceptedAt = DateTime.utc(2026, 8, 28, 10);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-1',
            name: '邀请占位账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('user-1'),
            updatedAt: acceptedAt.add(const Duration(minutes: 1)),
          ),
        );
    service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );
    final changes = [
      GetSyncPull200ResponseChangesInner(
        (b) => b
          ..changeId = '1'
          ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.ledger
          ..entityId = 'led-1'
          ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
          ..mutationId = 'accepted-ledger'
          ..payload = MapBuilder<String, JsonObject?>({
            'sync_id': JsonObject('S100'),
            'name': JsonObject('受邀账本'),
            'currency': JsonObject('CNY'),
            'month_start_day': JsonObject(1),
            'aa_enabled': JsonObject(false),
            'requires_full': JsonObject(true),
          })
          ..updatedAt = acceptedAt
          ..deviceId = 'remote-device',
      ),
      GetSyncPull200ResponseChangesInner(
        (b) => b
          ..changeId = '2'
          ..ledgerId = 'led-1'
          ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.member
          ..entityId = 'member-1'
          ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
          ..mutationId = 'member-active-change'
          ..payload = MapBuilder<String, JsonObject?>({
            'display_name': JsonObject('注册成员'),
            'member_type': JsonObject('REGISTERED'),
            'linked_account_id': JsonObject('user-1'),
            'role': JsonObject('editor'),
            'status': JsonObject('ACTIVE'),
          })
          ..updatedAt = acceptedAt.add(const Duration(seconds: 1))
          ..deviceId = 'remote-device',
      ),
    ];
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>(
              changes,
            ).toBuilder()
            ..serverCursor = '2'
            ..hasMore = false,
        ),
      ),
    );
    final fullResp = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = 'led-1'
            ..syncId = 'S100'
            ..name = '家庭共享账本'
            ..currency = 'JPY'
            ..monthStartDay = 7
            ..aaEnabled = true
            ..updatedAt = acceptedAt.add(const Duration(seconds: 2)),
        ).toBuilder()
        ..transactions = BuiltList<Transaction>([
          Transaction(
            (b) => b
              ..id = 'transaction-before-invite'
              ..ledgerId = 'led-1'
              ..txType = TransactionTxTypeEnum.expense
              ..amount = '10'
              ..happenedAt = acceptedAt.subtract(const Duration(days: 1))
              ..excludeFromStats = false
              ..currencyCode = 'CNY'
              ..nativeAmount = '10'
              ..recurringId = 'recurring-before-invite'
              ..createdByMemberId = 'member-owner'
              ..lastEditedByMemberId = 'member-owner'
              ..payerMemberId = 'member-owner'
              ..splits = BuiltList<TransactionSplit>([
                TransactionSplit(
                  (b) => b
                    ..memberId = 'member-owner'
                    ..amount = '10',
                ),
              ]).toBuilder()
              ..revision = 1
              ..updatedAt = acceptedAt.subtract(const Duration(days: 1))
              ..createdAt = acceptedAt.subtract(const Duration(days: 1)),
          ),
        ]).toBuilder()
        ..categories = BuiltList<Category>().toBuilder()
        ..recurringTransactions = BuiltList<RecurringTransaction>([
          RecurringTransaction(
            (b) => b
              ..id = 'recurring-before-invite'
              ..ledgerId = 'led-1'
              ..txType = RecurringTransactionTxTypeEnum.expense
              ..amount = '10'
              ..currencyCode = 'CNY'
              ..frequency = RecurringTransactionFrequencyEnum.monthly
              ..interval = 1
              ..startDate = acceptedAt.subtract(const Duration(days: 30))
              ..enabled = true
              ..updatedAt = acceptedAt,
          ),
        ]).toBuilder()
        ..members = BuiltList<Member>([
          Member(
            (b) => b
              ..id = 'member-owner'
              ..ledgerId = 'led-1'
              ..displayName = '账本 Owner'
              ..memberType = MemberMemberTypeEnum.REGISTERED
              ..status = MemberStatusEnum.ACTIVE
              ..updatedAt = acceptedAt,
          ),
          Member(
            (b) => b
              ..id = 'member-1'
              ..ledgerId = 'led-1'
              ..displayName = '注册成员'
              ..memberType = MemberMemberTypeEnum.REGISTERED
              ..status = MemberStatusEnum.ACTIVE
              ..updatedAt = acceptedAt.add(const Duration(seconds: 1)),
          ),
        ]).toBuilder()
        ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
        ..serverCursor = '9',
    );
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: fullResp,
        statusCode: 200,
      ),
    );

    expect(await service.pull(), 2);

    verify(
      () => mockApi.getSyncFull(ledgerId: 'led-1', syncId: null),
    ).called(1);
    final transaction =
        await (db.select(db.transactions)
              ..where((row) => row.id.equals('transaction-before-invite')))
            .getSingleOrNull();
    expect(transaction?.recurringId, 'recurring-before-invite');
    expect(
      await (db.select(db.recurringTransactions)
            ..where((row) => row.id.equals('recurring-before-invite')))
          .getSingleOrNull(),
      isNotNull,
    );
    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('led-1'))).getSingle();
    final member = await (db.select(
      db.ledgerMembers,
    )..where((row) => row.id.equals('member-1'))).getSingle();
    expect(ledger.name, '家庭共享账本');
    expect(ledger.currency, 'JPY');
    expect(ledger.monthStartDay, 7);
    expect(ledger.aaEnabled, isTrue);
    expect(ledger.syncId, 'S100');
    expect(ledger.bindingStatus, isNull);
    expect(
      ledgerSyncStateOf(
        storageMode: ledger.storageMode,
        syncId: ledger.syncId,
        bindingStatus: ledger.bindingStatus,
      ),
      LedgerSyncState.cloudBound,
    );
    expect(ledger.selfMemberId, 'member-1');
    expect(ledger.role, 'editor');
    expect(member.linkedAccountId, 'user-1');
    expect(member.role, 'editor');
    expect(
      (await (db.select(
            db.syncState,
          )..where((row) => row.deviceId.equals('dev-1'))).getSingle())
          .serverCursor,
      '2',
      reason: '单账本 full 不能把全局 pull 游标推进到尚未应用的事件之后',
    );
  });

  test('member：旧 cursor 可先建立受邀账本，再以本人 REMOVED 快照撤权', () async {
    final acceptedAt = DateTime.utc(2026, 8, 28, 10);
    final removedAt = acceptedAt.add(const Duration(seconds: 2));
    service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );
    final changes = [
      GetSyncPull200ResponseChangesInner(
        (b) => b
          ..changeId = '1'
          ..ledgerId = 'led-1'
          ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.ledger
          ..entityId = 'led-1'
          ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
          ..mutationId = 'accepted-ledger'
          ..payload = MapBuilder<String, JsonObject?>({
            'sync_id': JsonObject('S100'),
            'name': JsonObject('受邀账本'),
            'currency': JsonObject('CNY'),
            'month_start_day': JsonObject(1),
            'aa_enabled': JsonObject(false),
            'requires_full': JsonObject(true),
          })
          ..updatedAt = acceptedAt
          ..deviceId = 'remote-device',
      ),
      for (final status in ['ACTIVE', 'REMOVED'])
        GetSyncPull200ResponseChangesInner(
          (b) => b
            ..changeId = status == 'ACTIVE' ? '2' : '3'
            ..ledgerId = 'led-1'
            ..entityType =
                GetSyncPull200ResponseChangesInnerEntityTypeEnum.member
            ..entityId = 'member-1'
            ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
            ..mutationId = 'member-$status-change'
            ..payload = MapBuilder<String, JsonObject?>({
              'display_name': JsonObject('注册成员'),
              'member_type': JsonObject('REGISTERED'),
              'linked_account_id': JsonObject('user-1'),
              'role': JsonObject('editor'),
              'status': JsonObject(status),
              'updated_at': JsonObject(
                status == 'ACTIVE'
                    ? acceptedAt
                          .add(const Duration(seconds: 1))
                          .toIso8601String()
                    : removedAt.toIso8601String(),
              ),
            })
            ..updatedAt = status == 'ACTIVE'
                ? acceptedAt.add(const Duration(seconds: 1))
                : removedAt
            ..deviceId = 'remote-device',
        ),
    ];
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>(
              changes,
            ).toBuilder()
            ..serverCursor = '3'
            ..hasMore = false,
        ),
      ),
    );

    expect(await service.pull(), 3);

    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('led-1'))).getSingle();
    final member = await (db.select(
      db.ledgerMembers,
    )..where((row) => row.id.equals('member-1'))).getSingle();
    expect(ledger.syncId, 'S100');
    expect(ledger.scopeAccountId, 'user-1');
    expect(ledger.selfMemberId, 'member-1');
    expect(ledger.role, 'editor');
    expect(ledger.deletedAt?.toUtc(), removedAt);
    expect(member.memberType, 'REGISTERED');
    expect(member.linkedAccountId, 'user-1');
    expect(member.role, 'editor');
    expect(member.status, 'REMOVED');
    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('full：412 SYNC_ID_MISMATCH 时抛错且不落库（禁止静默覆盖另一条时间线）', () async {
    await seedCloudLedger('led-1', syncId: 'S-OLD');
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/full'),
          statusCode: 412,
        ),
      ),
    );

    await expectLater(
      service.full(ledgerId: 'led-1'),
      throwsA(isA<DioException>()),
    );

    // 本地 binding 保持旧值（等待用户决策，不自动接受新时间线）
    final rows = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals('led-1'))).get();
    expect(rows.single.syncId, 'S-OLD');
  });
}
