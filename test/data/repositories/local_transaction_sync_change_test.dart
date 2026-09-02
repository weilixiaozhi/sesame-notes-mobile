// 回归测试：交易写路径必须登记 sync_changes，云端账本的本地记账才能上行。
//
// add/update/deleteTransaction 与批量导入路径此前不登记变更，交易永远推不上云端。
// 本测试断言「写交易 → sync_changes 生成 → push 消费」完整闭环，
// 与 ledger 登记模式对称（仅云端账本进同步通道）。
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import '../../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

class _ThrowingChangeRecorder implements ChangeRecorder {
  /// 模拟同步变更登记失败，验证交易更新不会先行提交。
  Never _fail() => throw StateError('record change failed');

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async => _fail();

  @override
  Future<void> recordLedgerChanges({
    required List<SyncChangeRecord> changes,
  }) async => _fail();

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async => _fail();

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) async => _fail();
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_registerPushFallback);

  late SesameDatabase db;
  late LocalRepository repo;
  late String cloudLedgerId;
  late String localLedgerId;

  setUp(() {
    // 重置 prefs mock / 通知单例 / 平台 TestValue，防止跨用例残留（logger 依赖 prefs）。
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    // 生产同款注入：ChangeRecorderImpl 直接落 sync_changes 表。
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    cloudLedgerId = await repo.createLedger(name: '云端账本', storageMode: 'cloud');
    localLedgerId = await repo.createLedger(name: '本地账本', storageMode: 'local');
  });

  tearDown(() async {
    await db.close();
  });

  /// 只取交易实体的待推送变更（账本自身登记不算）。
  Future<List<SyncChange>> txChanges() async {
    final rows = await db.select(db.syncChanges).get();
    return rows.where((c) => c.entityType == 'transaction').toList();
  }

  /// 准备账本切换到 USD 时使用的 CNY→USD 汇率。
  Future<void> seedUsdBaseRate() => repo.upsertAutoRates(
    base: 'USD',
    rateDate: '2026-08-21',
    rates: {'CNY': '0.14'},
    source: 'test',
    fetchedAt: DateTime.utc(2026, 8, 21),
  );

  /// 写入一笔待重算的 CNY 交易；AA 参数仅供指定分摊边界用例使用。
  Future<String> seedCnyTransaction(
    String ledgerId, {
    int? aaMode,
    List<TransactionSplitInput>? splits,
  }) => repo.addTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '100',
    currencyCode: 'CNY',
    nativeAmount: '100',
    happenedAt: DateTime.utc(2026, 8, 21),
    aaMode: aaMode,
    splits: splits,
  );

  test('addTransaction 云端账本 → 登记 transaction upsert 变更（完整 payload）', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '12.34',
      categoryId: null,
      happenedAt: DateTime.utc(2026, 8, 21, 10),
      note: '测试记账',
    );

    final changes = await txChanges();
    expect(changes.length, 1);
    final ch = changes.single;
    expect(ch.entityId, id);
    expect(ch.ledgerId, cloudLedgerId);
    expect(ch.action, 'upsert');

    // payload 为完整实体 JSON（契约：push 侧按完整快照 upsert），
    // 时间为 UTC ISO8601（存储回读不保证 UTC 标志，契约以 payload 为准）。
    final payload = jsonDecode(ch.payload) as Map<String, dynamic>;
    expect(payload['tx_type'], 'expense');
    expect(payload['amount'], '12.34');
    expect(payload['happened_at'], endsWith('Z'));
    expect(DateTime.parse(payload['happened_at'] as String).isUtc, isTrue);
    expect(payload['currency_code'], 'CNY');
    expect(payload['native_amount'], '12.34');
    // 3.7：member 直写契约（无 version 字段，revision 由服务端 CAS 维护）
    expect(payload['version'], isNull);
    expect(payload.containsKey('payer_member_id'), isTrue);
    expect(payload['note'], '测试记账');
  });

  test('addTransaction 本地账本 → 不登记变更（仅云端账本进同步通道）', () async {
    await repo.addTransaction(
      ledgerId: localLedgerId,
      type: 'expense',
      amount: '5',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    expect(await txChanges(), isEmpty);
  });

  test('updateTransaction → 追加 upsert 变更（member 直写 payload，无版本字段）', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final version = await repo.updateTransaction(
      id: id,
      type: 'expense',
      amount: '20',
      note: '改金额',
    );
    expect(version, 2);

    final changes = await txChanges();
    expect(changes.length, 2);
    expect(changes.last.action, 'upsert');
    expect(changes.last.entityId, id);
    final payload = jsonDecode(changes.last.payload) as Map<String, dynamic>;
    expect(payload['amount'], '20');
    // member 直写契约，payload 不携带本地版本（revision 服务端 CAS 维护）
    expect(payload['version'], isNull);
    expect(payload.containsKey('payer_member_id'), isTrue);
  });

  test('新建带操作者 → 只登记一条 upsert，payload 已含付款人与作者', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
      operatorMemberId: 'member-alice',
    );

    final changes = await txChanges();
    expect(changes.map((change) => change.action), ['upsert']);
    expect(changes.single.entityId, id);
    final payload = jsonDecode(changes.single.payload) as Map<String, dynamic>;
    expect(payload['payer_member_id'], 'member-alice');
    expect(payload['created_by_member_id'], 'member-alice');
    expect(payload['last_edited_by_member_id'], 'member-alice');
  });

  test('编辑带操作者 → 只追加一条 upsert，payload 为最终作者快照', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
      operatorMemberId: 'member-alice',
    );
    await repo.updateTransaction(
      id: id,
      type: 'expense',
      amount: '20',
      operatorMemberId: 'member-bob',
    );

    final changes = await txChanges();
    expect(changes.map((change) => change.action), ['upsert', 'upsert']);
    final payload = jsonDecode(changes.last.payload) as Map<String, dynamic>;
    // 付款人与创建人 first-write-wins，编辑只换编辑人。
    expect(payload['payer_member_id'], 'member-alice');
    expect(payload['created_by_member_id'], 'member-alice');
    expect(payload['last_edited_by_member_id'], 'member-bob');
  });

  test('本地账本带操作者 → 只回填本地字段，不登记同步变更', () async {
    final id = await repo.addTransaction(
      ledgerId: localLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
      operatorMemberId: 'local-member',
    );

    final row = await repo.getTransactionById(id);
    expect(row?.payerMemberId, 'local-member');
    expect(row?.createdByMemberId, 'local-member');
    expect(row?.lastEditedByMemberId, 'local-member');
    expect(await txChanges(), isEmpty);
  });

  test('replaceTransactionSplits → 触发父交易完整 upsert，本地账本不登记', () async {
    final cloudTxId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '100',
      happenedAt: DateTime.utc(2026, 8, 21),
      aaMode: 2,
    );
    await db.delete(db.syncChanges).go();

    await repo.replaceTransactionSplits(cloudTxId, const [
      TransactionSplitInput(memberId: 'member-a', amount: '60'),
      TransactionSplitInput(memberId: 'member-b', amount: '40'),
    ]);

    final cloudChanges = await txChanges();
    expect(cloudChanges.length, 1);
    expect(cloudChanges.single.action, 'upsert');
    final payload =
        jsonDecode(cloudChanges.single.payload) as Map<String, dynamic>;
    expect(payload['splits'], [
      {'member_id': 'member-a', 'amount': '60'},
      {'member_id': 'member-b', 'amount': '40'},
    ]);

    final localTxId = await repo.addTransaction(
      ledgerId: localLedgerId,
      type: 'expense',
      amount: '20',
      happenedAt: DateTime.utc(2026, 8, 21),
      aaMode: 2,
    );
    await db.delete(db.syncChanges).go();
    await repo.replaceTransactionSplits(localTxId, const [
      TransactionSplitInput(memberId: 'local-member', amount: '20'),
    ]);
    expect(await txChanges(), isEmpty);
  });

  test('updateTransactionLedger → 按新旧账本类型登记 delete/upsert', () async {
    final cloudTargetId = await repo.createLedger(
      name: '云端目标',
      storageMode: 'cloud',
    );
    final localTargetId = await repo.createLedger(
      name: '本地目标',
      storageMode: 'local',
    );

    final cloudToCloud = await seedCnyTransaction(cloudLedgerId);
    await db.delete(db.syncChanges).go();
    await repo.updateTransactionLedger(
      id: cloudToCloud,
      ledgerId: cloudTargetId,
    );
    var changes = await txChanges();
    expect(changes.map((change) => change.action), ['delete', 'upsert']);
    expect(changes.map((change) => change.ledgerId), [
      cloudLedgerId,
      cloudTargetId,
    ]);

    final cloudToLocal = await seedCnyTransaction(cloudLedgerId);
    await db.delete(db.syncChanges).go();
    await repo.updateTransactionLedger(
      id: cloudToLocal,
      ledgerId: localTargetId,
    );
    changes = await txChanges();
    expect(changes.map((change) => change.action), ['delete']);
    expect(changes.single.ledgerId, cloudLedgerId);

    final localToCloud = await seedCnyTransaction(localLedgerId);
    await db.delete(db.syncChanges).go();
    await repo.updateTransactionLedger(
      id: localToCloud,
      ledgerId: cloudTargetId,
    );
    changes = await txChanges();
    expect(changes.map((change) => change.action), ['upsert']);
    expect(changes.single.ledgerId, cloudTargetId);

    final localToLocal = await seedCnyTransaction(localLedgerId);
    await db.delete(db.syncChanges).go();
    await repo.updateTransactionLedger(
      id: localToLocal,
      ledgerId: localTargetId,
    );
    expect(await txChanges(), isEmpty);
  });

  test('deleteTransaction → 登记 delete 变更', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    await repo.deleteTransaction(id);

    final changes = await txChanges();
    expect(changes.map((c) => c.action).toList(), ['upsert', 'delete']);
    expect(changes.last.entityId, id);
    expect(changes.last.ledgerId, cloudLedgerId);
  });

  test('deleteTransaction 已同步交易 → delete 保留删除前 serverRevision', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    await (db.update(db.transactions)..where((row) => row.id.equals(id))).write(
      const TransactionsCompanion(serverRevision: d.Value(7)),
    );
    await db.delete(db.syncChanges).go();

    await repo.deleteTransaction(id);

    final change = (await txChanges()).single;
    expect(change.action, 'delete');
    expect(change.baseRevision, 7);
  });

  test(
    'insertTransactionsBatchWithRelations 转发 recordChanges（true 登记 / false 不登记）',
    () async {
      TransactionsCompanion companion(String ledgerId, String suffix) =>
          TransactionsCompanion.insert(
            id: 'tx-batch-$suffix',
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '1',
            happenedAt: DateTime.utc(2026, 8, 21),
            currencyCode: 'CNY',
            nativeAmount: '1',
            createdAt: DateTime.utc(2026, 8, 21),
            updatedAt: DateTime.utc(2026, 8, 21),
          );

      await repo.insertTransactionsBatchWithRelations(
        transactions: [
          companion(cloudLedgerId, 'a'),
          companion(cloudLedgerId, 'b'),
        ],
        recordChanges: true,
      );
      expect((await txChanges()).length, 2);

      await repo.insertTransactionsBatchWithRelations(
        transactions: [companion(cloudLedgerId, 'c')],
        recordChanges: false,
      );
      expect((await txChanges()).length, 2, reason: 'recordChanges=false 不应登记');
    },
  );

  test('按 UUID 批量更新遵守 recordChanges：true 登记，false 仅回填', () async {
    final batchRepo = LocalTransactionRepository(
      db,
      trackerGetter: () => repo.changeTracker,
    );
    final recordId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final restoreId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '20',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final oldUpdatedAt = DateTime.utc(2020, 1, 1);
    await (db.update(db.transactions)..where((row) => row.id.equals(recordId)))
        .write(TransactionsCompanion(updatedAt: d.Value(oldUpdatedAt)));
    await db.delete(db.syncChanges).go();

    await batchRepo.updateTransactionsBatchBySyncId([
      TransactionUpdateBySyncIdData(
        syncId: recordId,
        type: 'expense',
        amount: '11',
        happenedAt: DateTime.utc(2026, 8, 22),
      ),
    ]);

    var changes = await txChanges();
    expect(changes, hasLength(1));
    expect(changes.single.entityId, recordId);
    expect(changes.single.action, 'upsert');
    final updated = (await repo.getTransactionById(recordId))!;
    expect(updated.updatedAt.isAfter(oldUpdatedAt), isTrue);
    expect(
      changes.single.updatedAt.isAtSameMomentAs(updated.updatedAt),
      isTrue,
    );
    expect(
      (jsonDecode(changes.single.payload) as Map<String, dynamic>)['amount'],
      '11',
    );

    await db.delete(db.syncChanges).go();
    await batchRepo.updateTransactionsBatchBySyncId([
      TransactionUpdateBySyncIdData(
        syncId: restoreId,
        type: 'expense',
        amount: '21',
        happenedAt: DateTime.utc(2026, 8, 22),
      ),
    ], recordChanges: false);

    changes = await txChanges();
    expect(changes, isEmpty, reason: '远端快照回填不得反向生成 upsert');
    expect((await repo.getTransactionById(restoreId))?.amount, '21');
  });

  test('按 UUID 批量更新分层处理 tombstone：业务忽略，回放 upsert 复活', () async {
    final batchRepo = LocalTransactionRepository(
      db,
      trackerGetter: () => repo.changeTracker,
    );
    final businessId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final replayId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '20',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final deletedAt = DateTime.utc(2026, 8, 22);
    await (db.update(db.transactions)
          ..where((row) => row.id.isIn([businessId, replayId])))
        .write(TransactionsCompanion(deletedAt: d.Value(deletedAt)));
    await db.delete(db.syncChanges).go();

    await batchRepo.updateTransactionsBatchBySyncId([
      TransactionUpdateBySyncIdData(
        syncId: businessId,
        type: 'expense',
        amount: '11',
        happenedAt: DateTime.utc(2026, 8, 23),
      ),
    ]);
    await batchRepo.updateTransactionsBatchBySyncId([
      TransactionUpdateBySyncIdData(
        syncId: replayId,
        type: 'expense',
        amount: '21',
        happenedAt: DateTime.utc(2026, 8, 23),
      ),
    ], recordChanges: false);

    final business = await batchRepo.getTransactionBySyncId(businessId);
    final replay = await batchRepo.getTransactionBySyncId(replayId);
    expect(business?.amount, '10', reason: '业务批量编辑不得改写 tombstone');
    expect(business?.deletedAt, isNotNull);
    expect(replay?.amount, '21');
    expect(replay?.deletedAt, isNull, reason: '远端 upsert 快照应复活旧 tombstone');
    expect(await txChanges(), isEmpty);
  });

  test('按 UUID 批量删除遵守 recordChanges，并在删前保留 CAS revision', () async {
    final batchRepo = LocalTransactionRepository(
      db,
      trackerGetter: () => repo.changeTracker,
    );
    final recordId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final restoreId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '20',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    await (db.update(db.transactions)..where((t) => t.id.equals(recordId)))
        .write(const TransactionsCompanion(serverRevision: d.Value(7)));
    await db.delete(db.syncChanges).go();

    expect(await batchRepo.deleteTransactionsBatchBySyncIds([recordId]), 1);

    var changes = await txChanges();
    expect(changes, hasLength(1));
    expect(changes.single.entityId, recordId);
    expect(changes.single.action, 'delete');
    expect(changes.single.baseRevision, 7);

    await db.delete(db.syncChanges).go();
    expect(
      await batchRepo.deleteTransactionsBatchBySyncIds([
        restoreId,
      ], recordChanges: false),
      1,
    );
    changes = await txChanges();
    expect(changes, isEmpty, reason: '远端 delete 回放不得反向生成 delete');
  });

  test('按 UUID 批量删除分层处理 tombstone：业务保留，回放可物理清理', () async {
    final batchRepo = LocalTransactionRepository(
      db,
      trackerGetter: () => repo.changeTracker,
    );
    final businessId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final replayId = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '20',
      happenedAt: DateTime.utc(2026, 8, 21),
    );
    final deletedAt = DateTime.utc(2026, 8, 22);
    await (db.update(db.transactions)
          ..where((row) => row.id.isIn([businessId, replayId])))
        .write(TransactionsCompanion(deletedAt: d.Value(deletedAt)));
    await db.delete(db.syncChanges).go();

    expect(await batchRepo.deleteTransactionsBatchBySyncIds([businessId]), 0);
    expect(
      await batchRepo.deleteTransactionsBatchBySyncIds([
        replayId,
      ], recordChanges: false),
      1,
    );

    expect(await batchRepo.getTransactionBySyncId(businessId), isNotNull);
    expect(await batchRepo.getTransactionBySyncId(replayId), isNull);
    expect(await txChanges(), isEmpty);
  });

  test('recalc 云端交易同步 nativeAmount、updatedAt 与 upsert 快照', () async {
    await seedUsdBaseRate();
    final id = await seedCnyTransaction(cloudLedgerId);
    final oldUpdatedAt = DateTime.utc(2025);
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(updatedAt: d.Value(oldUpdatedAt)),
    );
    await db.delete(db.syncChanges).go();

    expect(
      await repo.recalcNativeAmountsForLedger(
        cloudLedgerId,
        'USD',
        previousBase: 'CNY',
      ),
      1,
    );

    final tx = (await repo.getTransactionById(id))!;
    final change = (await txChanges()).single;
    final payload = jsonDecode(change.payload) as Map<String, dynamic>;
    expect(tx.nativeAmount, '14');
    expect(tx.updatedAt.isAfter(oldUpdatedAt), isTrue);
    expect(change.action, 'upsert');
    expect(change.entityId, id);
    expect(change.updatedAt, tx.updatedAt);
    expect(payload['native_amount'], '14');
  });

  test('recalc 登记失败时交易金额与 updatedAt 原子回滚', () async {
    await seedUsdBaseRate();
    final id = await seedCnyTransaction(cloudLedgerId);
    final oldUpdatedAt = DateTime.utc(2025);
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(updatedAt: d.Value(oldUpdatedAt)),
    );
    await db.delete(db.syncChanges).go();
    repo.changeTracker = _ThrowingChangeRecorder();

    await expectLater(
      repo.recalcNativeAmountsForLedger(
        cloudLedgerId,
        'USD',
        previousBase: 'CNY',
      ),
      throwsA(isA<StateError>()),
    );

    final tx = (await repo.getTransactionById(id))!;
    expect(tx.nativeAmount, '100');
    // 存储回读不保留 UTC 标志（与 payload 契约一致），同一时刻即视为未变。
    expect(tx.updatedAt.isAtSameMomentAs(oldUpdatedAt), isTrue);
    expect(await txChanges(), isEmpty);
  });

  test('recalc AA 指定分摊：splits 按比例换算，总和恒等于新 nativeAmount', () async {
    await seedUsdBaseRate();
    final id = await seedCnyTransaction(
      cloudLedgerId,
      aaMode: 2,
      splits: const [
        TransactionSplitInput(memberId: 'member-a', amount: '60'),
        TransactionSplitInput(memberId: 'member-b', amount: '40'),
      ],
    );
    await db.delete(db.syncChanges).go();

    expect(
      await repo.recalcNativeAmountsForLedger(
        cloudLedgerId,
        'USD',
        previousBase: 'CNY',
      ),
      1,
    );

    final after = (await repo.getTransactionById(id))!;
    expect(after.nativeAmount, '14');
    // 60×0.14=8.4，40×0.14=5.6：分账金额随本位币切换同步换算。
    expect((await repo.getTransactionSplits(id)).map((s) => s.amount), [
      '8.4',
      '5.6',
    ]);
    final splitSum = (await repo.getTransactionSplits(
      id,
    )).map((s) => Decimal.parse(s.amount)).fold(Decimal.zero, (a, b) => a + b);
    expect(splitSum, Decimal.parse(after.nativeAmount));
    // 同步 payload 携带的分摊合计必须与新 native_amount 恒等，
    // 否则服务端 AA_SPLIT_TOTAL_MISMATCH 直接拒绝整条交易。
    final change = (await txChanges()).single;
    final payload = jsonDecode(change.payload) as Map<String, dynamic>;
    final payloadSplitSum = (payload['splits'] as List)
        .map((s) => Decimal.parse((s as Map)['amount'] as String))
        .fold(Decimal.zero, (a, b) => a + b);
    expect(payloadSplitSum, Decimal.parse(payload['native_amount'] as String));
  });

  test('recalc 本地账本只更新本地快照，不登记同步变更', () async {
    await seedUsdBaseRate();
    final id = await seedCnyTransaction(localLedgerId);
    await db.delete(db.syncChanges).go();

    expect(
      await repo.recalcNativeAmountsForLedger(
        localLedgerId,
        'USD',
        previousBase: 'CNY',
      ),
      1,
    );

    expect((await repo.getTransactionById(id))!.nativeAmount, '14');
    expect(await txChanges(), isEmpty);
  });

  test('recalc recordChanges=false 不登记云端交易同步变更', () async {
    await seedUsdBaseRate();
    final id = await seedCnyTransaction(cloudLedgerId);
    await db.delete(db.syncChanges).go();

    expect(
      await repo.recalcNativeAmountsForLedger(
        cloudLedgerId,
        'USD',
        previousBase: 'CNY',
        recordChanges: false,
      ),
      1,
    );

    expect((await repo.getTransactionById(id))!.nativeAmount, '14');
    expect(await txChanges(), isEmpty);
  });

  test('登记后 push 可消费：请求含 transaction 变更且 payload 可反序列化', () async {
    final id = await repo.addTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '12.34',
      happenedAt: DateTime.utc(2026, 8, 21, 10),
      note: '测试',
    );

    final mockApi = _MockSyncApi();
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: PostSyncPush200Response((b) => b..serverCursor = '100'),
        statusCode: 200,
      ),
    );
    final service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
    );
    await service.push();

    // 逐层解开 one-of（生成模型 anyOf 声明为基类 AnyOf，实际是 AnyOf1 包装，
    // 这里用 dynamic 取 value）：inner → AnyOf1 → transaction 变体（upsert/delete 均带 entityType）。
    final captured = verify(
      () => mockApi.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final req = captured.single as PostSyncPushRequest;
    // 请求里同时含账本与交易变更（createLedger 也登记），只挑交易变更断言。
    final txChanges = req.changes
        .map((c) => (c.anyOf as dynamic).value.anyOf.value as dynamic)
        .where((v) => v.entityType.name == 'transaction')
        .toList();
    expect(txChanges.length, 1);
    final txVariant = txChanges.single;
    expect(txVariant.action.name, 'upsert');
    expect(txVariant.entityId, id);
    expect(txVariant.ledgerId, cloudLedgerId);
    // payload 已由 push 侧反序列化为生成模型（否则 _deser 抛错）——走到这里即消费成功。
  });
}
