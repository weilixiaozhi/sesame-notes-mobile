import 'dart:convert';
import 'package:sesame_notes/features/categories/application/category_actions.dart';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

import '../../helpers/test_isolation.dart';

/// 源头失败的堆栈标记：中间层日志不得重复携带它。
const _historyFailureMarker = 'history-write-failed-source';

/// 在真实历史写入后注入失败，验证整个编辑事务可以撤销已写入的数据。
class _FailingHistoryRepository extends LocalRepository {
  _FailingHistoryRepository(
    super.db, {
    super.changeTracker,
    super.accountIdGetter,
  });

  bool failHistory = false;

  /// 保留真实落库行为，只控制历史写入是否报告失败。
  @override
  Future<int> appendEditHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  }) async {
    final result = await super.appendEditHistory(
      recordId: recordId,
      version: version,
      operatorMemberId: operatorMemberId,
      summary: summary,
    );
    if (failHistory) {
      // 捕获并抛出异常实例，让上游拿到同一条堆栈事实。
      try {
        throw StateError(_historyFailureMarker);
      } catch (error, stackTrace) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late _FailingHistoryRepository repo;
  late ProviderContainer container;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = _FailingHistoryRepository(
      db,
      accountIdGetter: () => 'transaction-account',
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => 'transaction-account',
      ),
    );
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('分类级联删除末尾失败，交易、分类及同步队列全部回滚', () async {
    final ledger = await repo.createLedger(name: '分类回滚', storageMode: 'cloud');
    final category = await repo.createCategory(name: '餐饮', kind: 'expense');
    final transaction = await repo.addTransaction(
      ledgerId: ledger,
      type: 'expense',
      amount: '28',
      happenedAt: DateTime.utc(2026, 9, 13),
      categoryId: category,
    );
    final pending = await db.select(db.syncChanges).get();
    await db.customStatement(
      "CREATE TRIGGER fail_category_delete BEFORE UPDATE OF deleted_at ON categories WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL BEGIN SELECT RAISE(ABORT, 'injected delete failure'); END;",
    );
    await expectLater(
      container.read(categoryActionsProvider).deleteCascade([category]),
      throwsA(isA<Exception>()),
    );
    expect(await repo.getTransactionById(transaction), isNotNull);
    expect(await repo.categoryStore.getCategoryById(category), isNotNull);
    expect(await db.select(db.syncChanges).get(), pending);
    await db.customStatement('DROP TRIGGER fail_category_delete');
    await container.read(categoryActionsProvider).deleteCascade([category]);
    expect(await repo.getTransactionById(transaction), isNull);
    expect(await repo.categoryStore.getCategoryById(category), isNull);
    final tombstone = await (db.select(
      db.categories,
    )..where((row) => row.id.equals(category))).getSingle();
    expect(tombstone.deletedAt, isNotNull);
    expect(tombstone.id, category, reason: '删除保留同一分类身份，初始化不会重建副本');
  });

  for (final storageMode in ['cloud', 'local']) {
    test('$storageMode 编辑历史失败全部回滚，重试仅增加一个版本与一条历史', () async {
      final ledgerId = await repo.createLedger(
        name: '测试账本',
        storageMode: storageMode,
      );
      final id = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime.utc(2026, 9, 6),
        note: '原备注',
      );
      final original = (await repo.getTransactionById(id))!;
      await repo.appendEditHistory(
        recordId: id,
        version: original.version,
        summary: '原历史',
      );
      final originalChanges = await db.select(db.syncChanges).get();
      final originalHistories = await db.select(db.recordEditHistories).get();
      final actions = container.read(transactionActionsProvider);

      repo.failHistory = true;
      await expectLater(
        actions.edit(
          id: id,
          type: 'expense',
          amount: '20.00',
          note: '新备注',
          historySummary: '新历史',
        ),
        throwsA(isA<StateError>()),
      );

      // 回读所有持久化字段和旧队列，不能只检查金额或新历史行数。
      expect(await repo.getTransactionById(id), original);
      expect(await db.select(db.syncChanges).get(), originalChanges);
      expect(await db.select(db.recordEditHistories).get(), originalHistories);

      repo.failHistory = false;
      final version = await actions.edit(
        id: id,
        type: 'expense',
        amount: '20.00',
        note: '新备注',
        historySummary: '新历史',
      );

      final updated = (await repo.getTransactionById(id))!;
      expect(version, original.version + 1);
      expect(updated.version, version);
      expect(updated.amount, '20.00');
      expect(updated.nativeAmount, '20');
      expect(updated.note, '新备注');
      final histories = await db.select(db.recordEditHistories).get();
      expect(histories, hasLength(originalHistories.length + 1));
      expect(histories.last.version, version);
      expect(histories.last.summary, '新历史');

      final changes = await db.select(db.syncChanges).get();
      if (storageMode == 'cloud') {
        expect(changes, hasLength(originalChanges.length + 1));
        final mutation = changes.last;
        expect(mutation.entityType, 'transaction');
        expect(mutation.entityId, id);
        expect(mutation.baseRevision, 1);
        expect(jsonDecode(mutation.payload)['amount'], '20.00');
        expect(
          changes.map((change) => change.mutationId).toSet(),
          hasLength(changes.length),
        );
      } else {
        expect(changes, isEmpty);
      }
      // 编辑历史仅保存在本机，不生成独立的同步 mutation。
      expect(
        changes.any((change) => change.entityType == 'record_edit_history'),
        isFalse,
      );
    });
  }

  test('失败逐层上抛时保留各层上下文，堆栈事实不重复记录', () async {
    // 最小两层链路：需求层编辑交易 → 仓储守卫 requireActiveLedger。
    final ledgerId = await repo.createLedger(
      name: '日志账本',
      storageMode: 'cloud',
    );
    final id = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime.utc(2026, 9, 8),
    );
    // 账本归档后前台编辑必须被守卫拦截，异常穿过两层日志后上抛。
    await repo.setLedgerArchived(ledgerId, true);
    await logger.clear();

    await expectLater(
      container
          .read(transactionActionsProvider)
          .edit(
            id: id,
            type: 'expense',
            amount: '20.00',
            historySummary: '新历史',
          ),
      throwsA(isA<StateError>()),
    );

    final entries = logger.logs;
    // 需求层保留"哪条交易"的上下文，仓储层保留"哪个操作"的上下文。
    final actionEntry = entries.singleWhere(
      (entry) => entry.tag == 'TransactionActions',
    );
    expect(actionEntry.message, contains(id));
    final repositoryEntry = entries.singleWhere(
      (entry) => entry.tag == 'LocalRepository',
    );
    expect(repositoryEntry.message, contains('requireActiveLedger'));
    // 异常对象随上抛一路传递，两层都能给出稳定错误摘要。
    expect(actionEntry.error, isNotNull);
    expect(repositoryEntry.error, isNotNull);
    // 中间层已经 rethrow，堆栈由承载异常的源头记录，不再重复落一份。
    expect(actionEntry.stackTrace, isNull);
    // 仓储守卫是这条 StateError 的源头，堆栈由它记录（且只记这一份）。
    expect(repositoryEntry.stackTrace, isNotNull);
  });
}
