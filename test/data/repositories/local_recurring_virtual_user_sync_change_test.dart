// 回归测试：周期交易模板与占位成员写路径必须登记 sync_changes。
//
// recurring_transaction / member 两类 ledger-scoped 实体写路径必须登记，
// 本地创建/修改/删除才能上行云端。
// 与 transaction 登记模式一致：仅云端账本进同步通道，写库与登记同一事务。
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
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import '../../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// mocktail 的不可空参数 fallback（仅占位，不会被交互）。
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
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    cloudLedgerId = await repo.createLedger(name: '云端账本', storageMode: 'cloud');
    localLedgerId = await repo.createLedger(name: '本地账本', storageMode: 'local');
  });

  tearDown(() async {
    await db.close();
  });

  /// 按实体类型取待推送变更。
  Future<List<SyncChange>> changesOf(String entityType) async {
    final rows = await db.select(db.syncChanges).get();
    return rows.where((c) => c.entityType == entityType).toList();
  }

  group('周期交易模板', () {
    test('addRecurringTransaction 云端账本 → 登记 upsert 变更（完整 payload）', () async {
      final id = await repo.addRecurringTransaction(
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '88.00',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );

      final changes = await changesOf('recurring_transaction');
      expect(changes.length, 1);
      final ch = changes.single;
      expect(ch.entityId, id);
      expect(ch.ledgerId, cloudLedgerId);
      expect(ch.action, 'upsert');
      final payload = jsonDecode(ch.payload) as Map<String, dynamic>;
      expect(payload['tx_type'], 'expense');
      expect(payload['amount'], '88.00');
      expect(payload['frequency'], 'monthly');
      expect(payload['interval'], 1);
      expect(payload['enabled'], isTrue);
      expect(payload['start_date'], isNotEmpty);
    });

    test('addRecurringTransaction 本地账本 → 不登记', () async {
      await repo.addRecurringTransaction(
        ledgerId: localLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'weekly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );
      expect(await changesOf('recurring_transaction'), isEmpty);
    });

    test('batchInsertRecurringTransactions 默认只登记云账本 upsert', () async {
      final now = DateTime.utc(2026, 8, 21);
      await db.delete(db.syncChanges).go();

      await repo.batchInsertRecurringTransactions([
        RecurringTransactionsCompanion.insert(
          id: 'rec-batch-cloud',
          ledgerId: cloudLedgerId,
          txType: 'expense',
          amount: '10',
          currencyCode: 'CNY',
          frequency: 'monthly',
          interval: const d.Value(1),
          startDate: now,
          updatedAt: now,
        ),
        RecurringTransactionsCompanion.insert(
          id: 'rec-batch-local',
          ledgerId: localLedgerId,
          txType: 'expense',
          amount: '20',
          currencyCode: 'CNY',
          frequency: 'monthly',
          interval: const d.Value(1),
          startDate: now,
          updatedAt: now,
        ),
      ]);

      final changes = await changesOf('recurring_transaction');
      expect(changes, hasLength(1));
      expect(changes.single.entityId, 'rec-batch-cloud');
      expect(changes.single.ledgerId, cloudLedgerId);
      expect(changes.single.action, 'upsert');
      final payload =
          jsonDecode(changes.single.payload) as Map<String, dynamic>;
      expect(payload['amount'], '10');
    });

    test(
      'batchInsertRecurringTransactions recordChanges=false 只回填不反向推云',
      () async {
        final now = DateTime.utc(2026, 8, 21);
        await db.delete(db.syncChanges).go();

        await repo.batchInsertRecurringTransactions([
          RecurringTransactionsCompanion.insert(
            id: 'rec-batch-restore',
            ledgerId: cloudLedgerId,
            txType: 'expense',
            amount: '30',
            currencyCode: 'CNY',
            frequency: 'weekly',
            interval: const d.Value(1),
            startDate: now,
            updatedAt: now,
          ),
        ], recordChanges: false);

        expect(
          (await repo.getRecurringTransactionsByLedger(
            cloudLedgerId,
          )).map((row) => row.id),
          contains('rec-batch-restore'),
        );
        expect(
          await changesOf('recurring_transaction'),
          isEmpty,
          reason: '恢复批量回填不得把云端快照重新排队推送',
        );
      },
    );

    test('updateRecurringTransaction → 追加 upsert 变更', () async {
      final id = await repo.addRecurringTransaction(
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );
      await repo.updateRecurringTransaction(
        id: id,
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '20',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );

      final changes = await changesOf('recurring_transaction');
      expect(changes.map((c) => c.action).toList(), ['upsert', 'upsert']);
      expect(changes.last.entityId, id);
      final payload = jsonDecode(changes.last.payload) as Map<String, dynamic>;
      expect(payload['amount'], '20');
    });

    test('周期模板跨云账本移动使用新 UUID，并登记旧 delete 与新 upsert', () async {
      final targetLedgerId = await repo.createLedger(
        name: '目标云账本',
        storageMode: 'cloud',
      );
      final oldId = await repo.addRecurringTransaction(
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );
      await db.delete(db.syncChanges).go();

      await repo.updateRecurringTransaction(
        id: oldId,
        ledgerId: targetLedgerId,
        type: 'expense',
        amount: '20',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );

      final sourceRows = await repo.getRecurringTransactionsByLedger(
        cloudLedgerId,
      );
      final targetRows = await repo.getRecurringTransactionsByLedger(
        targetLedgerId,
      );
      final changes = await changesOf('recurring_transaction');
      expect(sourceRows, isEmpty);
      expect(targetRows, hasLength(1));
      expect(targetRows.single.id, isNot(oldId));
      expect(changes.map((change) => change.action), ['delete', 'upsert']);
      expect(changes.map((change) => change.entityId), [
        oldId,
        targetRows.single.id,
      ]);
      expect(changes.map((change) => change.ledgerId), [
        cloudLedgerId,
        targetLedgerId,
      ]);
    });

    test('deleteRecurringTransaction → 登记 delete 变更', () async {
      final id = await repo.addRecurringTransaction(
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'monthly',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 21),
      );
      await repo.deleteRecurringTransaction(id);

      final changes = await changesOf('recurring_transaction');
      expect(changes.map((c) => c.action).toList(), ['upsert', 'delete']);
      expect(changes.last.ledgerId, cloudLedgerId);
    });

    test('generateRecurringTransaction 云端账本 → 同时登记交易与最新生成锚点', () async {
      final id = await repo.addRecurringTransaction(
        ledgerId: cloudLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 20),
      );
      final recurring = (await repo.getRecurringTransactionsByLedger(
        cloudLedgerId,
      )).singleWhere((row) => row.id == id);
      await db.delete(db.syncChanges).go();
      final generatedAt = DateTime.utc(2026, 8, 21);

      final transactionId = await repo.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: generatedAt,
      );

      final transactionChanges = await changesOf('transaction');
      expect(transactionChanges.length, 1);
      expect(transactionChanges.single.entityId, transactionId);
      expect(transactionChanges.single.action, 'upsert');
      final recurringChanges = await changesOf('recurring_transaction');
      expect(recurringChanges.length, 1);
      expect(recurringChanges.single.entityId, id);
      final payload =
          jsonDecode(recurringChanges.single.payload) as Map<String, dynamic>;
      expect(
        DateTime.parse(payload['last_generated_date'] as String),
        generatedAt,
      );
    });

    test('generateRecurringTransaction 本地账本 → 只落库，不登记同步变更', () async {
      final id = await repo.addRecurringTransaction(
        ledgerId: localLedgerId,
        type: 'expense',
        amount: '10',
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2026, 8, 20),
      );
      final recurring = (await repo.getRecurringTransactionsByLedger(
        localLedgerId,
      )).singleWhere((row) => row.id == id);
      await db.delete(db.syncChanges).go();

      await repo.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: DateTime.utc(2026, 8, 21),
      );

      expect(await changesOf('transaction'), isEmpty);
      expect(await changesOf('recurring_transaction'), isEmpty);
    });
  });

  group('占位成员', () {
    test(
      'create / rename / delete 云端账本 → upsert / upsert / delete 变更',
      () async {
        final id = await repo.createPlaceholderMember(
          ledgerId: cloudLedgerId,
          name: '小明',
        );
        await repo.renameMember(id: id, name: '小明同学');
        final deleted = await repo.deleteMember(id);
        expect(deleted, isTrue);

        final changes = await changesOf('member');
        expect(changes.map((c) => c.action).toList(), [
          'upsert',
          'upsert',
          'delete',
        ]);
        expect(changes.every((c) => c.entityId == id), isTrue);
        expect(changes.every((c) => c.ledgerId == cloudLedgerId), isTrue);
        final payload = jsonDecode(changes[1].payload) as Map<String, dynamic>;
        expect(payload['display_name'], '小明同学');
      },
    );

    test('本地账本虚拟用户 → 不登记', () async {
      final id = await repo.createPlaceholderMember(
        ledgerId: localLedgerId,
        name: '本地',
      );
      await repo.renameMember(id: id, name: '本地改名');
      expect(await changesOf('member'), isEmpty);
    });
  });

  test('登记后 push 可消费：首创账本先行，绑定后 recurring_transaction 变更可反序列化', () async {
    await repo.addRecurringTransaction(
      ledgerId: cloudLedgerId,
      type: 'expense',
      amount: '66.60',
      frequency: 'monthly',
      interval: 1,
      startDate: DateTime.utc(2026, 8, 21),
    );

    final mockApi = _MockSyncApi();
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final req =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      // 首创账本批返回 accepted + sync_id 建立绑定；其余批返回空 outcome
      // （本测试只关心请求载荷与反序列化）。
      final outcomes = <PostSyncPush200ResponseOutcomesInner>[];
      for (final change in req.changes) {
        final variant = (change.anyOf as dynamic).value.anyOf.value as dynamic;
        if (variant.entityType.name == 'ledger') {
          outcomes.add(
            PostSyncPush200ResponseOutcomesInner(
              (b) => b
                ..mutationId = variant.mutationId
                ..entityId = variant.entityId
                ..status =
                    PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
                ..changeId = '1'
                ..syncId = 'S-BOUND',
            ),
          );
        }
      }
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              outcomes,
            ).toBuilder()
            ..serverCursor = '100',
        ),
        statusCode: 200,
      );
    });
    final service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
    );
    await service.push();

    final captured = verify(
      () => mockApi.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    // 未绑定账本首创先行单独成批，绑定建立后周期模板随后推送
    expect(captured, hasLength(2));
    final req = captured.last as PostSyncPushRequest;
    final recurring = req.changes
        .map((c) => (c.anyOf as dynamic).value.anyOf.value as dynamic)
        .where((v) => v.entityType.name == 'recurringTransaction')
        .toList();
    expect(recurring.length, 1);
    expect(recurring.single.action.name, 'upsert');
    // payload 已由 push 侧反序列化为生成模型（否则 _deser 抛错）——消费成功。
  });
}
