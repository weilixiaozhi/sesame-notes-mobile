// 未绑定账本首创变更的推送分批行为。
//
// 服务端按请求数组顺序逐条应用账本级变更并逐条校验 sync_id：
// 首创账本 upsert（可缺省 sync_id）与引用它的交易/成员同批推送时，
// 服务端先创建账本（生成 sync_id），随后批内其余变更因缺少 sync_id
// 被整批 412 拒绝——首创 outcome 携带的 sync_id 永远无法落库，
// 绑定形成死循环，同步永久失败。
//
// 因此：首创 upsert 必须单独先行推送，绑定建立后才推送其余账本级
// 变更；绑定未建立前，引用未绑定账本的账本级变更保持 pending（fail-closed）。
library;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Transaction,
        TransactionSplit,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// mocktail 需要为不可空参数注册 fallback 值（空请求占位，不会被交互）。
void _registerPushFallback() {
  registerFallbackValue(
    PostSyncPushRequest(
      (b) => b
        ..deviceId = 'dummy'
        ..changes = BuiltList<PostSyncPushRequestChangesInner>([]).toBuilder(),
    ),
  );
}

/// push change 的关键契约字段（生成 anyOf 变体逐类匹配取值）。
typedef _ChangeInfo = ({
  String entityType,
  String entityId,
  String mutationId,
  String? syncId,
});

/// 从单个 change 中提取 entity_type/entity_id/mutation_id/sync_id。
_ChangeInfo _changeInfo(PostSyncPushRequestChangesInner change) {
  final outerValue = change.anyOf.values.values.firstWhere((v) => v != null);
  final AnyOf inner = switch (outerValue) {
    PostSyncPushRequestChangesInnerAnyOf v => v.anyOf,
    PostSyncPushRequestChangesInnerAnyOf1 v => v.anyOf,
    PostSyncPushRequestChangesInnerAnyOf2 v => v.anyOf,
    PostSyncPushRequestChangesInnerAnyOf3 v => v.anyOf,
    PostSyncPushRequestChangesInnerAnyOf4 v => v.anyOf,
    PostSyncPushRequestChangesInnerAnyOf5 v => v.anyOf,
    _ => throw StateError('未知 push change 变体'),
  };
  final value = inner.values.values.firstWhere((v) => v != null);
  return switch (value) {
    PostSyncPushRequestChangesInnerAnyOfAnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOfAnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf1AnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf1AnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf2AnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf3AnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf3AnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf4AnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf4AnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf5AnyOf v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    PostSyncPushRequestChangesInnerAnyOf5AnyOf1 v => (
      entityType: v.entityType.name,
      entityId: v.entityId,
      mutationId: v.mutationId,
      syncId: v.syncId,
    ),
    _ => throw StateError('未知 push change 变体'),
  };
}

/// 最小合法交易 payload（mock 直接消费，不做服务端校验）。
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

/// 账本首创 upsert payload（服务端契约字段）。
String _ledgerPayload() => jsonEncode({
  'name': '待上云账本',
  'currency': 'CNY',
  'month_start_day': 1,
  'aa_enabled': false,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late SyncService service;
  late List<PostSyncPushRequest> pushedRequests;

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
    pushedRequests = [];
    // 模拟服务端行为：批内逐条 accepted；ledger 首创变更额外返回 sync_id
    // （真实服务端创建账本后经 outcome 下发同步身份）。
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      pushedRequests.add(request);
      final outcomes = <PostSyncPush200ResponseOutcomesInner>[];
      var changeId = 0;
      for (final change in request.changes) {
        final info = _changeInfo(change);
        changeId++;
        final builder = PostSyncPush200ResponseOutcomesInnerBuilder()
          ..mutationId = info.mutationId
          ..entityId = info.entityId
          ..status = PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
          ..changeId = '$changeId';
        if (info.entityType == 'ledger') builder.syncId = 'S-NEW';
        outcomes.add(builder.build());
      }
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              outcomes,
            ).toBuilder()
            ..serverCursor = '$changeId',
        ),
      );
    });
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedUnboundCloudLedger(String id) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: '待上云账本',
            storageMode: const d.Value('cloud'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> seedPendingLedgerUpsert(
    String ledgerId, {
    required String mutationId,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: ledgerId,
            ledgerId: d.Value(ledgerId),
            action: 'upsert',
            payload: _ledgerPayload(),
            updatedAt: DateTime.utc(2026, 8, 22, 10),
            mutationId: mutationId,
          ),
        );
  }

  Future<void> seedPendingTxChange(
    String ledgerId, {
    required String mutationId,
    String entityId = 'tx-1',
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: entityId,
            ledgerId: d.Value(ledgerId),
            action: 'upsert',
            payload: _txPayload(),
            updatedAt: DateTime.utc(2026, 8, 22, 10),
            mutationId: mutationId,
          ),
        );
  }

  test('未绑定账本首创 upsert 单独先行推送，绑定建立后才推送其余账本级变更', () async {
    await seedUnboundCloudLedger('led-1');
    await seedPendingLedgerUpsert('led-1', mutationId: 'm-led-1');
    await seedPendingTxChange('led-1', mutationId: 'm-tx-1');

    await service.push();

    expect(pushedRequests, hasLength(2), reason: '首创与后续变更必须分成两批');
    final first = pushedRequests[0].changes.map(_changeInfo).toList();
    expect(first, hasLength(1), reason: '首创批只含账本变更');
    expect(first.single.entityType, 'ledger');
    expect(first.single.syncId, isNull, reason: '首创批可缺省 sync_id');
    final second = pushedRequests[1].changes.map(_changeInfo).toList();
    expect(second, hasLength(1));
    expect(second.single.entityType, 'transaction');
    expect(second.single.syncId, 'S-NEW', reason: '绑定建立后必须携带服务端返回的 sync_id');
    // 服务端返回的 sync_id 已落库
    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('led-1'))).getSingle();
    expect(ledger.syncId, 'S-NEW');
    // 两批变更均已标记推送
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(pending, isEmpty);
  });

  test('绑定未建立前，引用未绑定账本的账本级变更保持 pending 不推送', () async {
    await seedUnboundCloudLedger('led-1');
    await seedPendingTxChange('led-1', mutationId: 'm-tx-1');

    await service.push();

    expect(
      pushedRequests,
      isEmpty,
      reason: '无首创变更时，缺 sync_id 的变更发出必被 412，必须保持本地',
    );
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(pending, hasLength(1));
  });

  test('混合批次：已绑定账本携带各自 sync_id，未绑定首创仍先行', () async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-bound',
            name: '已绑定账本',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('S100'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await seedPendingTxChange(
      'led-bound',
      mutationId: 'm-tx-bound',
      entityId: 'tx-b',
    );
    await seedUnboundCloudLedger('led-new');
    await seedPendingLedgerUpsert('led-new', mutationId: 'm-led-new');
    await seedPendingTxChange(
      'led-new',
      mutationId: 'm-tx-new',
      entityId: 'tx-n',
    );

    await service.push();

    expect(pushedRequests, hasLength(2));
    final first = pushedRequests[0].changes.map(_changeInfo).toList();
    expect(first.map((i) => i.entityType).toList(), ['ledger']);
    expect(first.single.syncId, isNull);
    final second = pushedRequests[1].changes.map(_changeInfo).toList();
    expect(second, hasLength(2));
    final byMutation = {for (final i in second) i.mutationId: i};
    expect(byMutation['m-tx-bound']!.syncId, 'S100');
    expect(byMutation['m-tx-new']!.syncId, 'S-NEW');
  });
}
