// 冲突解决（保留本地=rebase / 采用云端）+ STALE_BINDING。
//
// 「保留本地」= 基于最新 remote revision 重新提交
// （无 force overwrite）；「采用云端」= 采纳服务端当前状态并清冲突；
// 412 SYNC_ID_MISMATCH → STALE_BINDING，同步暂停等待用户决策。
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

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_registerPushFallback);

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late SyncService service;
  late LocalRepository repo;

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
      repo: LocalLedgerRepository(db),
      localSelfIdLoader: () async => 'local-self-1',
    );
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
  });

  tearDown(() async {
    await db.close();
  });

  /// 建云端账本 + 交易（server_revision=1），返回 (txId, ledgerId)。
  Future<({String txId, String ledgerId})> seedCloudTx() async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S1')),
    );
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
      TransactionsCompanion(serverRevision: d.Value(1)),
    );
    return (txId: txId, ledgerId: ledgerId);
  }

  /// 预置 OPEN 冲突（本地 base=1、云端 revision=3）。
  /// remotePayload 为服务端完整快照形状（含 ledger_id，adopt 写回需要）。
  Future<void> seedConflict(
    String txId,
    String ledgerId, {
    bool remoteDeleted = false,
  }) async {
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'conf-1',
            ledgerId: ledgerId,
            entityType: 'transaction',
            entityId: txId,
            localPayload: '{"tx_type":"expense","amount":"20","note":"本地修改"}',
            remotePayload: remoteDeleted
                ? '{"deleted":true,"revision":3}'
                : jsonEncode({
                    'id': txId,
                    'ledger_id': ledgerId,
                    'tx_type': 'expense',
                    'amount': '30',
                    'happened_at': '2026-08-22T10:00:00.000Z',
                    'note': '云端修改',
                    'category_id': null,
                    'exclude_from_stats': false,
                    'currency_code': 'CNY',
                    'native_amount': '30',
                    'recurring_id': null,
                    'created_by_user_id': null,
                    'last_edited_by_user_id': null,
                    'paid_by_user_id': null,
                    'created_by_member_id': null,
                    'last_edited_by_member_id': null,
                    'payer_member_id': null,
                    'aa_mode': null,
                    'splits': <Object>[],
                    'revision': 3,
                    'last_edited_at': null,
                    'updated_at': '2026-08-22T11:00:00.000Z',
                    'created_at': '2026-08-22T11:00:00.000Z',
                  }),
            baseRevision: 1,
            remoteRevision: 3,
            localMutationId: 'm-1',
          ),
        );
    await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
      TransactionsCompanion(amount: d.Value('20'), note: d.Value('本地修改')),
    );
  }

  test(
    '保留本地：resolution mutation base=最新 remote revision，旧 pending 清除，冲突 RESOLVED_LOCAL',
    () async {
      final seeded = await seedCloudTx();
      final txId = seeded.txId;
      final scopedService = SyncService(
        client: SesameApiClient(),
        db: db,
        deviceId: 'dev-1',
        apiOverride: mockApi,
        currentAccountIdGetter: () => 'account-1',
      );
      // 模拟本地编辑产生 pending（base=1）
      await repo.updateTransaction(
        id: txId,
        type: 'expense',
        amount: '20',
        note: '本地修改',
      );
      await seedConflict(txId, seeded.ledgerId);
      when(
        () => mockApi.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: PostSyncPush200Response(
            (b) => b
              ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>([
                PostSyncPush200ResponseOutcomesInner(
                  (b) => b
                    ..mutationId = 'res-m1'
                    ..entityId = txId
                    ..status =
                        PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
                    ..changeId = '100'
                    ..revision = 4,
                ),
              ]).toBuilder()
              ..serverCursor = '100',
          ),
          statusCode: 200,
        ),
      );

      await scopedService.resolveConflictKeepLocal('conf-1');

      // resolution mutation：base=3（最新 remote revision），payload 为本地最新值
      final pending = await (db.select(
        db.syncChanges,
      )..where((c) => c.entityId.equals(txId) & c.pushedAt.isNull())).get();
      expect(pending.length, 1);
      expect(pending.single.baseRevision, 3);
      expect(
        pending.single.accountId,
        'account-1',
        reason: 'resolution mutation 必须归属当前账号，否则账号域 push 无法选中',
      );
      final payload =
          jsonDecode(pending.single.payload) as Map<String, dynamic>;
      expect(payload['amount'], '20');
      // 冲突已解决
      final conflicts = await db.select(db.syncConflicts).get();
      expect(conflicts.single.status, 'RESOLVED_LOCAL');
      expect(conflicts.single.resolvedAt, isNotNull);

      await scopedService.push();
      verify(
        () => mockApi.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).called(1);
    },
  );

  test(
    '采用云端：本地实体被云端 payload 覆盖 + server_revision 更新，冲突 RESOLVED_REMOTE',
    () async {
      final seeded = await seedCloudTx();
      final txId = seeded.txId;
      await seedConflict(txId, seeded.ledgerId);

      await service.resolveConflictAdoptRemote('conf-1');

      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.amount, '30');
      expect(tx.note, '云端修改');
      expect(tx.serverRevision, 3);
      // 该实体 pending 清空
      final pending = await (db.select(
        db.syncChanges,
      )..where((c) => c.entityId.equals(txId) & c.pushedAt.isNull())).get();
      expect(pending, isEmpty);
      final conflicts = await db.select(db.syncConflicts).get();
      expect(conflicts.single.status, 'RESOLVED_REMOTE');
    },
  );

  test('采用云端（云端已删除）：本地同步删除，不复活', () async {
    final seeded = await seedCloudTx();
    final txId = seeded.txId;
    await seedConflict(txId, seeded.ledgerId, remoteDeleted: true);

    await service.resolveConflictAdoptRemote('conf-1');

    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.deletedAt, isNotNull);
    expect(tx.serverRevision, 3);
    final conflicts = await db.select(db.syncConflicts).get();
    expect(conflicts.single.status, 'RESOLVED_REMOTE');
  });

  test('full 收到 412：先保护本地状态为 Local Safety Fork，再标记 STALE_BINDING', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S-OLD')),
    );
    // 本地存在未推送修改（有数据可丢，必须保护）
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '66',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
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
      service.full(ledgerId: ledgerId),
      throwsA(isA<DioException>()),
    );

    // 原行标记 STALE_BINDING（同步暂停，不静默覆盖）
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingle();
    expect(ledger.bindingStatus, 'stale');
    // 本地状态已保护为 DR_PROTECT Fork：新 id、local、同步身份全清、数据复制
    final forks =
        await (db.select(db.ledgers)..where(
              (l) =>
                  l.originType.equals('DR_PROTECT') &
                  l.originLedgerId.equals(ledgerId),
            ))
            .get();
    expect(forks, hasLength(1));
    final fork = forks.single;
    expect(fork.id, isNot(ledgerId));
    expect(fork.storageMode, 'local');
    expect(fork.syncId, isNull);
    expect(fork.bindingStatus, isNull);
    expect(fork.selfMemberId, isNotNull);
    final forkTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(fork.id))).get();
    expect(forkTxs, hasLength(1));
  });

  test('full 收到 412：本地无未推送修改时不生成保护 Fork，仅标记 stale（无数据可丢）', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S-OLD')),
    );
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
      service.full(ledgerId: ledgerId),
      throwsA(isA<DioException>()),
    );

    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingle();
    expect(ledger.bindingStatus, 'stale');
    final forks =
        await (db.select(db.ledgers)..where(
              (l) =>
                  l.originType.equals('DR_PROTECT') &
                  l.originLedgerId.equals(ledgerId),
            ))
            .get();
    expect(forks, isEmpty);
  });

  test('已是 STALE_BINDING 时 full 失败关闭，不重复请求旧时间线', () async {
    final ledgerId = await repo.createLedger(
      name: '已暂停账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      const LedgersCompanion(
        syncId: d.Value('S-OLD'),
        bindingStatus: d.Value('stale'),
      ),
    );

    await expectLater(
      service.full(ledgerId: ledgerId),
      throwsA(isA<StateError>()),
    );

    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('非 STALE_BINDING 不得放弃本地修改', () async {
    final seeded = await seedCloudTx();
    final pendingBefore = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(seeded.ledgerId))).get();

    await expectLater(
      service.abandonLocalChanges(ledgerId: seeded.ledgerId),
      throwsA(isA<StateError>()),
    );

    final pendingAfter = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(seeded.ledgerId))).get();
    expect(
      pendingAfter,
      hasLength(pendingBefore.length),
      reason: '非 stale 状态不得清理 pending',
    );
    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('412 → 保护 Fork → 手动 abandon：原行重绑成功且保护副本保留', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S-OLD')),
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '88',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
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

    // 第一次 full：412 → 自动保护 + stale
    await expectLater(
      service.full(ledgerId: ledgerId),
      throwsA(isA<DioException>()),
    );
    final forks =
        await (db.select(db.ledgers)..where(
              (l) =>
                  l.originType.equals('DR_PROTECT') &
                  l.originLedgerId.equals(ledgerId),
            ))
            .get();
    expect(forks, hasLength(1));
    final forkId = forks.single.id;

    // 用户手动 abandon（唯一允许放弃本地修改的路径）：full 返回新时间线
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: GetSyncFull200Response(
          (b) => b
            ..ledger = GetSyncFull200ResponseLedger(
              (b) => b
                ..id = ledgerId
                ..syncId = 'S-NEW'
                ..name = '云端账本'
                ..currency = 'CNY'
                ..monthStartDay = 1
                ..aaEnabled = false
                ..updatedAt = DateTime.now().toUtc(),
            ).toBuilder()
            ..transactions = BuiltList<Transaction>().toBuilder()
            ..categories = BuiltList<Category>().toBuilder()
            ..recurringTransactions = BuiltList<RecurringTransaction>()
                .toBuilder()
            ..members = BuiltList<Member>().toBuilder()
            ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>()
                .toBuilder()
            ..serverCursor = '9',
        ),
        statusCode: 200,
      ),
    );
    await service.abandonLocalChanges(ledgerId: ledgerId);

    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingle();
    expect(ledger.syncId, 'S-NEW');
    expect(ledger.bindingStatus, isNull);
    // 保护副本原样保留（本地修改 88 元仍在副本中，未因 abandon 丢失）
    final kept = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(forkId))).getSingle();
    expect(kept.storageMode, 'local');
    final forkTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(forkId))).get();
    expect(forkTxs, hasLength(1));
    expect(forkTxs.single.amount, '88');
  });

  test('放弃本地修改：清该账本 pending 并重拉 full（binding 恢复 bound）', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(
        syncId: d.Value('S-OLD'),
        bindingStatus: d.Value('stale'),
      ),
    );
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '99',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    await seedConflict(txId, ledgerId);
    // full 返回新时间线快照（sync_id=S-NEW）
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: GetSyncFull200Response(
          (b) => b
            ..ledger = GetSyncFull200ResponseLedger(
              (b) => b
                ..id = ledgerId
                ..syncId = 'S-NEW'
                ..name = '云端账本'
                ..currency = 'CNY'
                ..monthStartDay = 1
                ..aaEnabled = false
                ..updatedAt = DateTime.now().toUtc(),
            ).toBuilder()
            ..transactions = BuiltList<Transaction>().toBuilder()
            ..categories = BuiltList<Category>().toBuilder()
            ..recurringTransactions = BuiltList<RecurringTransaction>()
                .toBuilder()
            ..members = BuiltList<Member>().toBuilder()
            ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>()
                .toBuilder()
            ..serverCursor = '5',
        ),
        statusCode: 200,
      ),
    );

    await service.abandonLocalChanges(ledgerId: ledgerId);

    // pending 清空、binding 恢复（新 sync_id + bound）
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(ledgerId))).get();
    expect(pending, isEmpty);
    final conflicts = await (db.select(
      db.syncConflicts,
    )..where((c) => c.ledgerId.equals(ledgerId))).get();
    expect(conflicts, isEmpty, reason: '放弃本地分支后不得遗留旧时间线冲突');
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingle();
    expect(ledger.syncId, 'S-NEW');
    expect(ledger.bindingStatus, isNull);
  });

  test('重绑 full 失败时保留 pending 与冲突，不提前破坏本地分支', () async {
    final seeded = await seedCloudTx();
    await (db.update(db.ledgers)..where((l) => l.id.equals(seeded.ledgerId)))
        .write(const LedgersCompanion(bindingStatus: d.Value('stale')));
    await seedConflict(seeded.txId, seeded.ledgerId);
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/sync/full')),
    );
    final pendingBefore = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(seeded.ledgerId))).get();

    await expectLater(
      service.abandonLocalChanges(ledgerId: seeded.ledgerId),
      throwsA(isA<DioException>()),
    );

    final pendingAfter = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(seeded.ledgerId))).get();
    final conflictsAfter = await (db.select(
      db.syncConflicts,
    )..where((c) => c.ledgerId.equals(seeded.ledgerId))).get();
    expect(pendingAfter, hasLength(pendingBefore.length));
    expect(conflictsAfter, hasLength(1));
  });
}
