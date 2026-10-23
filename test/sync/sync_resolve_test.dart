import 'dart:async';
import 'dart:convert';
import '../helpers/sync_response.dart';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/models/ledger_sync_state.dart';
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
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
                value: PostSyncPushRequestChangesInnerAnyOf2(
                  (b) => b
                    ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf>(
                      value: PostSyncPushRequestChangesInnerAnyOf2AnyOf(
                        (b) => b
                          ..mutationId = 'm'
                          ..entityType =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
                                  .ledger
                          ..entityId = 'x'
                          ..ledgerId = 'x'
                          ..action =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
                                  .upsert
                          ..updatedAt = DateTime.now()
                          ..payload =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
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
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    mockApi = _MockSyncApi();
    final client = SesameApiClient();
    service = SyncService(
      currentAccountIdGetter: () => 'account-a',
      client: client,
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      repo: LocalLedgerRepository(db),
      localSelfIdLoader: () async => 'local-self-1',
    );
    repo = LocalRepository(
      db,
      accountIdGetter: () => 'account-a',
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account-a'),
    );
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
            accountId: d.Value('account-a'),
            ledgerId: d.Value(ledgerId),
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
        currentAccountIdGetter: () => 'account-a',
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
        (invocation) async => Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(
            invocation.namedArguments[#postSyncPushRequest]
                as PostSyncPushRequest,
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
        'account-a',
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
      ).called(2);
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
    expect(
      await service.localStateProtection(ledgerId),
      LocalStateProtection.protected,
    );
  });

  test('full 收到 412：本地无未推送修改时不生成保护 Fork，仅标记 stale（无数据可丢）', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S-OLD')),
    );
    await db.delete(db.syncChanges).go(); // 已完成首次上云，构造真正无待确认修改的状态。
    when(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
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
    expect(
      await service.localStateProtection(ledgerId),
      LocalStateProtection.notNeeded,
    );
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
                ..ownerId = 'account-a'
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
        includeRecurringState: any(named: 'includeRecurringState'),
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
                ..ownerId = 'account-a'
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
    expect(conflicts, hasLength(1));
    expect(
      conflicts.single.status,
      'RESOLVED_REMOTE',
      reason: '放弃本地分支后只保留已解决的冲突历史',
    );
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingle();
    expect(ledger.syncId, 'S-NEW');
    expect(ledger.bindingStatus, isNull);
  });

  /// 提供空的新时间线，验证旧分支只能在成功保护后被替换。
  void stubRebindSnapshot(
    String ledgerId, {
    Future<void> Function()? beforeResponse,
  }) {
    when(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer((_) async {
      await beforeResponse?.call();
      return Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: GetSyncFull200Response(
          (b) => b
            ..ledger = GetSyncFull200ResponseLedger(
              (b) => b
                ..id = ledgerId
                ..ownerId = 'account-a'
                ..syncId = 'S-NEW'
                ..name = '云端账本'
                ..currency = 'CNY'
                ..monthStartDay = 1
                ..aaEnabled = false
                ..updatedAt = DateTime.utc(2026, 8, 22),
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
      );
    });
  }

  for (final failDuringCopy in [false, true]) {
    test('保护${failDuringCopy ? '复制交易' : '创建账本'}失败后放弃必须重试，失败保留完整分支', () async {
      final seeded = await seedCloudTx();
      await seedConflict(seeded.txId, seeded.ledgerId);
      final transactionsBefore = await db.select(db.transactions).get();
      final pendingBefore = await db.select(db.syncChanges).get();
      final conflictsBefore = await db.select(db.syncConflicts).get();
      // 让真实复制事务失败；交易阶段失败同时验证已插入的副本账本会回滚。
      await db.customStatement(
        failDuringCopy
            ? '''CREATE TRIGGER fail_protection BEFORE INSERT ON transactions
                 WHEN EXISTS (SELECT 1 FROM ledgers
                   WHERE id = NEW.ledger_id AND origin_type = 'DR_PROTECT')
                 BEGIN SELECT RAISE(ABORT, 'injected fork copy failure'); END'''
            : '''CREATE TRIGGER fail_protection BEFORE INSERT ON ledgers
                 WHEN NEW.origin_type = 'DR_PROTECT'
                 BEGIN SELECT RAISE(ABORT, 'injected fork insert failure'); END''',
      );
      final mismatch = DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/full'),
          statusCode: 412,
        ),
      );
      when(
        () => mockApi.getSyncFull(
          includeRecurringState: any(named: 'includeRecurringState'),
          ledgerId: any(named: 'ledgerId'),
          syncId: any(named: 'syncId'),
        ),
      ).thenThrow(mismatch);

      await expectLater(
        service.full(ledgerId: seeded.ledgerId),
        throwsA(same(mismatch)),
      );
      final ledger = await (db.select(
        db.ledgers,
      )..where((row) => row.id.equals(seeded.ledgerId))).getSingle();
      expect(ledger.bindingStatus, 'stale');
      expect(await db.select(db.transactions).get(), transactionsBefore);
      expect(await db.select(db.syncChanges).get(), pendingBefore);
      expect(await db.select(db.syncConflicts).get(), conflictsBefore);
      expect(await db.select(db.ledgers).get(), hasLength(1));
      expect(
        await service.localStateProtection(seeded.ledgerId),
        LocalStateProtection.failed,
      );

      stubRebindSnapshot(seeded.ledgerId);
      await expectLater(
        service.abandonLocalChanges(ledgerId: seeded.ledgerId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            '友好错误信息',
            '修改仍保留，副本创建失败，请重试',
          ),
        ),
      );
      expect(await db.select(db.transactions).get(), transactionsBefore);
      expect(await db.select(db.syncChanges).get(), pendingBefore);
      expect(await db.select(db.syncConflicts).get(), conflictsBefore);
      expect(await db.select(db.ledgers).get(), [ledger]);
      expect(
        await service.localStateProtection(seeded.ledgerId),
        LocalStateProtection.failed,
      );

      await db.customStatement('DROP TRIGGER fail_protection');
      await service.abandonLocalChanges(ledgerId: seeded.ledgerId);
      final forks = await (db.select(
        db.ledgers,
      )..where((row) => row.originType.equals('DR_PROTECT'))).get();
      expect(forks, hasLength(1));
      final copied = await (db.select(
        db.transactions,
      )..where((row) => row.ledgerId.equals(forks.single.id))).get();
      expect(copied.single.amount, transactionsBefore.single.amount);
      expect(await db.select(db.syncChanges).get(), isEmpty);
      expect(
        (await db.select(db.syncConflicts).get()).where(
          (c) => c.status == 'OPEN',
        ),
        isEmpty,
      );
      final rebound = await (db.select(
        db.ledgers,
      )..where((row) => row.id.equals(seeded.ledgerId))).getSingle();
      expect(rebound.syncId, 'S-NEW');
      expect(rebound.bindingStatus, isNull);
    });
  }

  /// 触发时间线不匹配，使同步服务尝试保护并进入失效绑定状态。
  Future<void> pauseForMismatch(String ledgerId) async {
    when(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
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
  }

  test('保护状态可重建服务读取，旧时间线、旧修改和不可用副本不能证明成功', () async {
    final seeded = await seedCloudTx();
    await pauseForMismatch(seeded.ledgerId);
    final restartedService = SyncService(
      currentAccountIdGetter: () => 'account-a',
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
    );
    expect(
      await restartedService.localStateProtection(seeded.ledgerId),
      LocalStateProtection.protected,
    );
    final fork = await (db.select(
      db.ledgers,
    )..where((row) => row.originType.equals('DR_PROTECT'))).getSingle();
    final pending = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(seeded.txId))).getSingle();

    // mutation id、队列顺序、时间戳相同，内容改变也必须重新保护。
    await (db.update(db.syncChanges)..where((row) => row.id.equals(pending.id)))
        .write(const SyncChangesCompanion(payload: d.Value('{"amount":"42"}')));
    expect(
      await restartedService.localStateProtection(seeded.ledgerId),
      LocalStateProtection.failed,
    );
    await (db.update(db.syncChanges)..where((row) => row.id.equals(pending.id)))
        .write(pending.toCompanion(true));
    await (db.update(db.ledgers)
          ..where((row) => row.id.equals(seeded.ledgerId)))
        .write(const LedgersCompanion(syncId: d.Value('OTHER-TIMELINE')));
    expect(
      await restartedService.localStateProtection(seeded.ledgerId),
      LocalStateProtection.failed,
    );
    await (db.update(db.ledgers)
          ..where((row) => row.id.equals(seeded.ledgerId)))
        .write(const LedgersCompanion(syncId: d.Value('S1')));

    for (final unavailable in [
      LedgersCompanion(deletedAt: d.Value(DateTime.utc(2026, 8, 22))),
      const LedgersCompanion(storageMode: d.Value('cloud')),
      const LedgersCompanion(syncId: d.Value('S-FORK')),
      const LedgersCompanion(bindingStatus: d.Value('pending_local_move')),
      const LedgersCompanion(originBackupId: d.Value('dr-protect')),
    ]) {
      await (db.update(
        db.ledgers,
      )..where((row) => row.id.equals(fork.id))).write(unavailable);
      expect(
        await restartedService.localStateProtection(seeded.ledgerId),
        LocalStateProtection.failed,
      );
      await (db.update(
        db.ledgers,
      )..where((row) => row.id.equals(fork.id))).write(fork.toCompanion(false));
    }
    expect(
      await restartedService.localStateProtection(seeded.ledgerId),
      LocalStateProtection.protected,
    );
    await repo.addTransaction(
      ledgerId: seeded.ledgerId,
      type: 'expense',
      amount: '42',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    expect(
      await restartedService.localStateProtection(seeded.ledgerId),
      LocalStateProtection.failed,
    );
  });

  test('只有 OPEN 冲突也需要保护，冲突内容更新后旧副本不能证明成功', () async {
    final seeded = await seedCloudTx();
    await seedConflict(seeded.txId, seeded.ledgerId);
    await db.delete(db.syncChanges).go();
    await pauseForMismatch(seeded.ledgerId);
    expect(
      await service.localStateProtection(seeded.ledgerId),
      LocalStateProtection.protected,
    );
    await db
        .update(db.syncConflicts)
        .write(
          const SyncConflictsCompanion(
            localPayload: d.Value('{"amount":"42"}'),
          ),
        );
    expect(
      await service.localStateProtection(seeded.ledgerId),
      LocalStateProtection.failed,
    );
  });

  test('保护仓储缺失时有修改不能放弃，无业务修改无需创建副本', () async {
    final seeded = await seedCloudTx();
    service = SyncService(
      currentAccountIdGetter: () => 'account-a',
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
    );
    await pauseForMismatch(seeded.ledgerId);
    expect(
      await service.localStateProtection(seeded.ledgerId),
      LocalStateProtection.failed,
    );
    stubRebindSnapshot(seeded.ledgerId);
    await expectLater(
      service.abandonLocalChanges(ledgerId: seeded.ledgerId),
      throwsA(isA<StateError>()),
    );
    expect(await db.select(db.transactions).get(), hasLength(1));
    expect(await db.select(db.syncChanges).get(), isNotEmpty);
    await db.delete(db.syncChanges).go();
    expect(
      await service.localStateProtection(seeded.ledgerId),
      LocalStateProtection.notNeeded,
    );
    await service.abandonLocalChanges(ledgerId: seeded.ledgerId);
    expect(await db.select(db.ledgers).get(), hasLength(1));
  });

  for (final keepLocal in [false, true]) {
    test('冲突读取排队期间账号变化，${keepLocal ? '保留本地' : '采用云端'}不得提交旧账号决策', () async {
      final seeded = await seedCloudTx();
      await seedConflict(seeded.txId, seeded.ledgerId);
      await (db.update(db.transactions)
            ..where((row) => row.id.equals(seeded.txId)))
          .write(const TransactionsCompanion(amount: d.Value('10')));
      var accountId = 'account-a';
      final scoped = SyncService(
        client: SesameApiClient(),
        db: db,
        deviceId: 'dev-1',
        currentAccountIdGetter: () => accountId,
      );
      final locked = Completer<void>();
      final unlock = Completer<void>();
      final blocking = db.transaction(() async {
        locked.complete();
        await unlock.future;
      });
      await locked.future;
      final decision = keepLocal
          ? scoped.resolveConflictKeepLocal('conf-1')
          : scoped.resolveConflictAdoptRemote('conf-1');
      final expectation = expectLater(decision, throwsA(isA<StateError>()));
      accountId = 'account-b';
      unlock.complete();
      await blocking;
      await expectation;
      expect((await db.select(db.transactions).get()).single.amount, '10');
      expect((await db.select(db.syncConflicts).get()).single.status, 'OPEN');
      expect(
        (await db.select(db.syncChanges).get()).any(
          (row) => row.accountId == 'account-b',
        ),
        isFalse,
      );
    });
  }

  test('重新下载响应迟到且账号已变化时，原分支、队列与游标保持不变', () async {
    final seeded = await seedCloudTx();
    await pauseForMismatch(seeded.ledgerId);
    var accountId = 'account-a';
    final scoped = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      repo: LocalLedgerRepository(db),
      localSelfIdLoader: () async => 'self',
      currentAccountIdGetter: () => accountId,
    );
    final requestStarted = Completer<void>();
    final responseReady = Completer<void>();
    stubRebindSnapshot(
      seeded.ledgerId,
      beforeResponse: () async {
        requestStarted.complete();
        await responseReady.future;
      },
    );
    final beforeLedgers = await db.select(db.ledgers).get();
    final beforePending = await db.select(db.syncChanges).get();
    final beforeState = await db.select(db.syncState).get();
    final abandoning = scoped.abandonLocalChanges(ledgerId: seeded.ledgerId);
    final expectation = expectLater(abandoning, throwsA(isA<StateError>()));
    await requestStarted.future;
    accountId = 'account-b';
    responseReady.complete();
    await expectation;
    expect(await db.select(db.ledgers).get(), beforeLedgers);
    expect(await db.select(db.syncChanges).get(), beforePending);
    expect(await db.select(db.syncState).get(), beforeState);
  });

  test('放弃请求等待期间的新修改也必须先复制到保护副本', () async {
    final seeded = await seedCloudTx();
    await pauseForMismatch(seeded.ledgerId);
    final requestStarted = Completer<void>();
    final responseReady = Completer<void>();
    stubRebindSnapshot(
      seeded.ledgerId,
      beforeResponse: () async {
        requestStarted.complete();
        await responseReady.future;
      },
    );
    final abandoning = service.abandonLocalChanges(ledgerId: seeded.ledgerId);
    await requestStarted.future;
    await repo.addTransaction(
      ledgerId: seeded.ledgerId,
      type: 'expense',
      amount: '42',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    responseReady.complete();
    await abandoning;

    final forks = await (db.select(
      db.ledgers,
    )..where((row) => row.originType.equals('DR_PROTECT'))).get();
    final copiedAmounts = <List<String>>[];
    for (final fork in forks) {
      final transactions = await (db.select(
        db.transactions,
      )..where((row) => row.ledgerId.equals(fork.id))).get();
      copiedAmounts.add(transactions.map((row) => row.amount).toList());
    }
    expect(copiedAmounts, contains(unorderedEquals(['10', '42'])));
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      await (db.select(db.transactions)..where(
            (row) =>
                row.ledgerId.equals(seeded.ledgerId) & row.deletedAt.isNull(),
          ))
          .get(),
      isEmpty,
    );
  });

  test('放弃请求返回时账本已转本地，必须停止重绑且保留队列和数据', () async {
    final seeded = await seedCloudTx();
    await pauseForMismatch(seeded.ledgerId);
    final requestStarted = Completer<void>();
    final responseReady = Completer<void>();
    stubRebindSnapshot(
      seeded.ledgerId,
      beforeResponse: () async {
        requestStarted.complete();
        await responseReady.future;
      },
    );
    final abandoning = service.abandonLocalChanges(ledgerId: seeded.ledgerId);
    final expectation = expectLater(abandoning, throwsA(isA<StateError>()));
    await requestStarted.future;
    await (db.update(
      db.ledgers,
    )..where((row) => row.id.equals(seeded.ledgerId))).write(
      const LedgersCompanion(
        storageMode: d.Value('local'),
        syncId: d.Value(null),
        bindingStatus: d.Value(null),
      ),
    );
    final ledgersBefore = await db.select(db.ledgers).get();
    final transactionsBefore = await db.select(db.transactions).get();
    final pendingBefore = await db.select(db.syncChanges).get();
    responseReady.complete();
    await expectation;
    expect(await db.select(db.ledgers).get(), ledgersBefore);
    expect(await db.select(db.transactions).get(), transactionsBefore);
    expect(await db.select(db.syncChanges).get(), pendingBefore);
  });

  test('重绑 full 失败时保留 pending 与冲突，不提前破坏本地分支', () async {
    final seeded = await seedCloudTx();
    await (db.update(db.ledgers)..where((l) => l.id.equals(seeded.ledgerId)))
        .write(const LedgersCompanion(bindingStatus: d.Value('stale')));
    await seedConflict(seeded.txId, seeded.ledgerId);
    when(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
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
