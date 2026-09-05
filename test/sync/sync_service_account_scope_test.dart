/// SyncService.push 账号域过滤测试（一期不变量：B 永远推不到 A 的 mutation）。
///
/// 锚点：注入账号上下文后，push 只发送当前账号的 mutation；
/// account_id 为 null 的旧数据一律不上传；已注入 getter 但当前未登录时必须
/// fail-closed，不得把任何账号的 mutation 发给无身份请求；未注入上下文时保持旧行为。
library;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:one_of/any_of.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';

import '../helpers/test_isolation.dart';

class MockSyncApi extends Mock implements SyncApi {}

/// 构造增量同步事件的 JSON payload。
MapBuilder<String, JsonObject?> _eventPayload(Map<String, Object?> data) =>
    MapBuilder<String, JsonObject?>({
      for (final entry in data.entries)
        entry.key: entry.value == null ? null : JsonObject(entry.value),
    });

/// 构造一条远端 upsert 事件，统一验证各实体的 tombstone 复活契约。
GetSyncPull200ResponseChangesInner _upsertEvent({
  required String changeId,
  required GetSyncPull200ResponseChangesInnerEntityTypeEnum entityType,
  required String entityId,
  required Map<String, Object?> payload,
  required DateTime updatedAt,
  String? ledgerId,
}) => GetSyncPull200ResponseChangesInner((builder) {
  builder
    ..changeId = changeId
    ..entityType = entityType
    ..entityId = entityId
    ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
    ..mutationId = 'remote-$entityId'
    ..payload = _eventPayload(payload)
    ..updatedAt = updatedAt
    ..deviceId = 'remote-device';
  if (ledgerId != null) builder.ledgerId = ledgerId;
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late MockSyncApi api;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    api = MockSyncApi();
    // mocktail 需要为不可空参数注册 fallback 值（仅占位，不会被交互）
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
  });

  tearDown(() async => db.close());

  SyncService buildService({String? Function()? accountIdGetter}) {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    return SyncService(
      client: client,
      db: db,
      deviceId: 'device-1',
      apiOverride: api,
      currentAccountIdGetter: accountIdGetter,
    );
  }

  Future<void> recordChange({required String? accountId}) async {
    final recorder = ChangeRecorderImpl(db, accountIdGetter: () => accountId);
    await recorder.recordLedgerChange(
      entityType: 'ledger',
      entityId: 'ledger-1',
      ledgerId: 'ledger-1',
      action: 'upsert',
      payload:
          '{"name":"x","currency":"CNY","month_start_day":1,"aa_enabled":false}',
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// mock push 成功：outcome 空列表 + cursor 0（本测试只关心请求载荷）。
  void mockPushOk() {
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              [],
            ).toBuilder()
            ..serverCursor = '0',
        ),
      ),
    );
  }

  test('账号 A 上下文：只推送 A 的 mutation，B 与 null 的旧数据不上传', () async {
    await recordChange(accountId: 'user-a');
    await recordChange(accountId: 'user-b');
    await recordChange(accountId: null);

    mockPushOk();
    final service = buildService(accountIdGetter: () => 'user-a');
    await service.push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    expect(captured, hasLength(1));
    final request = captured.single as PostSyncPushRequest;
    expect(request.changes, hasLength(1), reason: '只推 A 的一条');
  });

  test('账号 A 上下文且 A 无 mutation：不发请求', () async {
    await recordChange(accountId: 'user-b');
    final service = buildService(accountIdGetter: () => 'user-a');
    await service.push();
    verifyNever(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    );
  });

  test('已注入账号上下文但当前未登录：不推送任何 mutation', () async {
    await recordChange(accountId: 'user-a');
    await recordChange(accountId: 'user-b');
    await recordChange(accountId: null);

    final service = buildService(accountIdGetter: () => null);
    await service.push();

    verifyNever(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    );
  });

  test('未注入账号上下文（旧行为）：未绑定账本首创先行单独成批，其余变更绑定后推送', () async {
    await recordChange(accountId: null);
    await recordChange(accountId: 'user-b');
    mockPushOk();
    final service = buildService(accountIdGetter: null);
    await service.push();
    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    // 同一账本的首创只推首行（同批第二个会因账本已存在被服务端 412）；
    // mock 未返回 sync_id（未建立绑定）时其余行保持 pending 等待绑定
    expect(captured, hasLength(1));
    final request = captured.single as PostSyncPushRequest;
    expect(request.changes, hasLength(1));
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    // mock 返回空 outcome 列表（不确认推送），两行均保持 pending
    expect(pending, hasLength(2));
  });

  test('pull：各类远端 upsert 必须在当前账号域复活 tombstone', () async {
    final deletedAt = DateTime.utc(2026, 8, 23);
    final updatedAt = DateTime.utc(2026, 8, 24);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-a',
            name: '已删除账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('user-a'),
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'transaction-a',
            ledgerId: 'ledger-a',
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
            id: 'category-a',
            name: '已删除分类',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('user-a'),
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'recurring-a',
            ledgerId: 'ledger-a',
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
            id: 'rate-a',
            baseCurrency: 'CNY',
            quoteCurrency: 'USD',
            rate: '7.0',
            scopeAccountId: const d.Value('user-a'),
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );

    final changes = <GetSyncPull200ResponseChangesInner>[
      _upsertEvent(
        changeId: '1',
        entityType: GetSyncPull200ResponseChangesInnerEntityTypeEnum.ledger,
        entityId: 'ledger-a',
        ledgerId: 'ledger-a',
        updatedAt: updatedAt,
        payload: {
          'name': '云账本',
          'currency': 'CNY',
          'month_start_day': 1,
          'aa_enabled': false,
          'updated_at': updatedAt.toIso8601String(),
        },
      ),
      _upsertEvent(
        changeId: '2',
        entityType:
            GetSyncPull200ResponseChangesInnerEntityTypeEnum.transaction,
        entityId: 'transaction-a',
        ledgerId: 'ledger-a',
        updatedAt: updatedAt,
        payload: {
          'ledger_id': 'ledger-a',
          'tx_type': 'expense',
          'amount': '2',
          'happened_at': updatedAt.toIso8601String(),
          'exclude_from_stats': false,
          'currency_code': 'CNY',
          'native_amount': '2',
          'revision': 2,
          'splits': <Object>[],
          'created_at': deletedAt.toIso8601String(),
          'updated_at': updatedAt.toIso8601String(),
        },
      ),
      _upsertEvent(
        changeId: '3',
        entityType: GetSyncPull200ResponseChangesInnerEntityTypeEnum.category,
        entityId: 'category-a',
        updatedAt: updatedAt,
        payload: {
          'name': '餐饮',
          'kind': 'expense',
          'level': 1,
          'sort_order': 0,
          'updated_at': updatedAt.toIso8601String(),
        },
      ),
      _upsertEvent(
        changeId: '4',
        entityType: GetSyncPull200ResponseChangesInnerEntityTypeEnum
            .recurringTransaction,
        entityId: 'recurring-a',
        ledgerId: 'ledger-a',
        updatedAt: updatedAt,
        payload: {
          'ledger_id': 'ledger-a',
          'tx_type': 'expense',
          'amount': '2',
          'currency_code': 'CNY',
          'frequency': 'monthly',
          'interval': 1,
          'start_date': deletedAt.toIso8601String(),
          'enabled': true,
          'updated_at': updatedAt.toIso8601String(),
        },
      ),
      _upsertEvent(
        changeId: '5',
        entityType: GetSyncPull200ResponseChangesInnerEntityTypeEnum
            .exchangeRateOverride,
        entityId: 'rate-a',
        updatedAt: updatedAt,
        payload: {
          'base_currency': 'CNY',
          'quote_currency': 'USD',
          'rate': '7.5',
          'updated_at': updatedAt.toIso8601String(),
        },
      ),
    ];
    when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (builder) => builder
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>(
              changes,
            ).toBuilder()
            ..serverCursor = '5'
            ..hasMore = false,
        ),
      ),
    );

    await buildService(accountIdGetter: () => 'user-a').pull();

    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('ledger-a'))).getSingle();
    final category = await (db.select(
      db.categories,
    )..where((row) => row.id.equals('category-a'))).getSingle();
    final rate = await (db.select(
      db.exchangeRateOverrides,
    )..where((row) => row.id.equals('rate-a'))).getSingle();
    expect(ledger.scopeAccountId, 'user-a');
    expect(category.scopeAccountId, 'user-a');
    expect(rate.scopeAccountId, 'user-a');

    final deletedAtByEntity = <String, Future<DateTime?>>{
      'ledger': Future.value(ledger.deletedAt),
      'transaction':
          (db.select(db.transactions)
                ..where((row) => row.id.equals('transaction-a')))
              .getSingle()
              .then((row) => row.deletedAt),
      'category': Future.value(category.deletedAt),
      'recurring_transaction':
          (db.select(db.recurringTransactions)
                ..where((row) => row.id.equals('recurring-a')))
              .getSingle()
              .then((row) => row.deletedAt),
      'exchange_rate_override': Future.value(rate.deletedAt),
    };
    for (final entry in deletedAtByEntity.entries) {
      expect(
        await entry.value,
        isNull,
        reason: '${entry.key} 的远端 upsert 应清除本地 tombstone',
      );
    }
  });
}
