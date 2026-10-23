import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);
  test('每条本地变更持久化独立的 UUIDv4 mutation_id', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final recorder = ChangeRecorderImpl(db);

    for (var index = 0; index < 2; index++) {
      await recorder.recordUserGlobalChange(
        entityType: 'category',
        entityId: 'category-$index',
        action: 'upsert',
        payload: '{}',
        updatedAt: DateTime.utc(2026, 8, 20),
      );
    }

    final changes = await db.select(db.syncChanges).get();
    expect(changes.map((change) => change.mutationId).toSet(), hasLength(2));
    for (final change in changes) {
      expect(Uuid.isValidUUID(fromString: change.mutationId), isTrue);
      expect(change.mutationId[14], '4');
    }
  });

  group('普通编辑的拒收链与未知请求', () {
    const account = 'account-a';
    final stamp = DateTime.utc(2026, 10, 11, 8);
    late SesameDatabase db;
    late LocalRepository repo;
    late String ledgerId;

    setUp(() async {
      db = SesameDatabase.withExecutor(NativeDatabase.memory());
      repo = LocalRepository(
        db,
        accountIdGetter: () => account,
        changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => account),
      );
      ledgerId = await repo.createLedger(name: '拒收编辑测试本', storageMode: 'cloud');
      await db.delete(db.syncChanges).go();
    });
    tearDown(() => db.close());

    /// 实际仓储编辑与队列结果一起验证，失败日志保留堆栈和用例上下文。
    void editTest(String name, Future<void> Function() verify) {
      test(name, () async {
        try {
          await verify();
        } catch (error, stack) {
          logger.error(
            'ChangeRecorderTest',
            name,
            safeErrorSummary(error),
            stack,
          );
          rethrow;
        }
      });
    }

    /// 通过正式记账入口建立实体和原始意图，再模拟云端明确拒收及较新的只读基线。
    Future<SyncChange> rejectedTransaction({int? baseRevision = 7}) async {
      try {
        final id = await repo.addTransaction(
          ledgerId: ledgerId,
          type: 'expense',
          amount: '10',
          happenedAt: stamp,
        );
        final source = await db.select(db.syncChanges).getSingle();
        await (db.update(
          db.syncChanges,
        )..where((c) => c.id.equals(source.id))).write(
          SyncChangesCompanion(
            payload: d.Value(
              jsonEncode({
                ...jsonDecode(source.payload) as Map<String, dynamic>,
                'initial_history': true,
              }),
            ),
            baseRevision: d.Value(baseRevision),
            frozenRequest: const d.Value('{"original":"明确拒收"}'),
            rejectionReason: const d.Value('请先处理分类'),
            rejectionCode: const d.Value('INVALID_CATEGORY'),
          ),
        );
        await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
          const TransactionsCompanion(serverRevision: d.Value(9)),
        );
        return await (db.select(
          db.syncChanges,
        )..where((c) => c.id.equals(source.id))).getSingle();
      } catch (error, stack) {
        logger.error(
          'ChangeRecorderTest',
          '准备拒收交易失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    }

    /// 追加原链上的完整后继，区分尚未发送的修改与结果未知的冻结请求。
    Future<SyncChange> successor(SyncChange head, {bool frozen = false}) async {
      try {
        final id = await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: head.entityType,
                entityId: head.entityId,
                accountId: head.accountId == null
                    ? const d.Value(null)
                    : d.Value(head.accountId),
                ledgerId: d.Value(head.ledgerId),
                action: 'upsert',
                payload: jsonEncode({
                  ...jsonDecode(head.payload) as Map<String, dynamic>,
                  'amount': '20',
                }),
                updatedAt: stamp,
                mutationId: const Uuid().v4(),
                baseRevision: const d.Value(8),
                frozenRequest: frozen
                    ? const d.Value('{"original":"结果未知的完整请求"}')
                    : const d.Value(null),
              ),
            );
        return await (db.select(
          db.syncChanges,
        )..where((c) => c.id.equals(id))).getSingle();
      } catch (error, stack) {
        logger.error(
          'ChangeRecorderTest',
          '准备后继请求失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    }

    editTest('拒收队头后有未知冻结请求时，普通编辑保留原链并追加同实体后继', () async {
      final head = await rejectedTransaction();
      final unknown = await successor(head, frozen: true);
      await repo.updateTransaction(
        id: head.entityId,
        type: 'expense',
        amount: '30',
      );
      final after = await db.select(db.syncChanges).get();
      expect(after, hasLength(3));
      expect(after.singleWhere((c) => c.id == head.id), head);
      expect(after.singleWhere((c) => c.id == unknown.id), unknown);
      final edited = after.last;
      expect(edited.entityId, head.entityId);
      expect(edited.mutationId, isNot(unknown.mutationId));
      expect(edited.frozenRequest, isNull);
      expect(edited.rejectionReason, isNull);
      expect(jsonDecode(edited.payload)['amount'], '30');
      expect(
        jsonDecode(edited.payload).containsKey('initial_history'),
        isFalse,
      );
      expect(edited.baseRevision, 9);
      expect((await db.select(db.transactions).getSingle()).amount, '30');
    });

    editTest('明确拒收链的普通编辑保留最早base7和初始历史，不能抬高到当前server9', () async {
      final head = await rejectedTransaction();
      await successor(head);
      await repo.updateTransaction(
        id: head.entityId,
        type: 'expense',
        amount: '30',
      );
      final replacement = await db.select(db.syncChanges).getSingle();
      expect(replacement.entityId, head.entityId);
      expect(replacement.baseRevision, 7);
      expect(replacement.mutationId, isNot(head.mutationId));
      expect(replacement.rejectionReason, isNull);
      expect(replacement.frozenRequest, isNull);
      expect(jsonDecode(replacement.payload)['initial_history'], isTrue);
      expect(jsonDecode(replacement.payload)['amount'], '30');
      expect((await db.select(db.transactions).getSingle()).serverRevision, 9);
    });

    editTest('原始CREATE基线为空时，拒收编辑仍保留空基线', () async {
      final head = await rejectedTransaction(baseRevision: null);
      await repo.updateTransaction(
        id: head.entityId,
        type: 'expense',
        amount: '30',
      );
      final replacement = await db.select(db.syncChanges).getSingle();
      expect(replacement.entityId, head.entityId);
      expect(replacement.baseRevision, isNull);
      expect(jsonDecode(replacement.payload)['initial_history'], isTrue);
    });

    editTest('另一账号同实体的未知请求和确认记录不影响本账号拒收修正', () async {
      final head = await rejectedTransaction();
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: head.entityType,
              entityId: head.entityId,
              accountId: const d.Value('account-b'),
              ledgerId: d.Value(head.ledgerId),
              action: 'upsert',
              payload: '{"private":"B账号内容"}',
              updatedAt: stamp,
              mutationId: const Uuid().v4(),
              frozenRequest: const d.Value('{"private":"B账号冻结请求"}'),
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: head.entityType,
              entityId: head.entityId,
              accountId: const d.Value('account-b'),
              ledgerId: d.Value(head.ledgerId),
              action: 'upsert',
              payload: '{}',
              updatedAt: stamp,
              mutationId: const Uuid().v4(),
              pushedAt: d.Value(stamp),
            ),
          );
      final foreignBefore = (await db.select(db.syncChanges).get())
          .where((c) => c.accountId == 'account-b')
          .toList();
      await repo.updateTransaction(
        id: head.entityId,
        type: 'expense',
        amount: '30',
      );
      final all = await db.select(db.syncChanges).get();
      expect(all.where((c) => c.accountId == 'account-b'), foreignBefore);
      final own = all.singleWhere((c) => c.accountId == account);
      expect(own.baseRevision, 7);
      expect(jsonDecode(own.payload)['initial_history'], isTrue);
    });

    editTest('分类同名拒收后修改原分类只更换mutation，不新增分类实体', () async {
      final id = await repo.createCategory(name: '待确认分类', kind: 'expense');
      final head = await db.select(db.syncChanges).getSingle();
      await (db.update(
        db.syncChanges,
      )..where((c) => c.id.equals(head.id))).write(
        const SyncChangesCompanion(
          rejectionReason: d.Value('同名分类已存在'),
          rejectionCode: d.Value('CATEGORY_NAME_CONFLICT'),
          frozenRequest: d.Value('{"original":"分类请求"}'),
        ),
      );
      await repo.updateCategory(id, name: '已修正分类');
      final categories = await repo.categoryStore.getAllCategories();
      expect(categories.map((c) => c.id), [id]);
      expect(categories.single.name, '已修正分类');
      final replacement = await db.select(db.syncChanges).getSingle();
      expect(replacement.entityId, id);
      expect(replacement.mutationId, isNot(head.mutationId));
      expect(replacement.rejectionReason, isNull);
    });
  });
}
