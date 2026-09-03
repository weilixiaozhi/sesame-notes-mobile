// LocalTransactionRepository 补充测试。
//
// 锚点：AA 指定分摊落 transaction_splits 关系表（与后端字段一致），
// 共享账本 Editor 记的交易通过 categoryId（Owner 分类 UUID）反查
// SharedLedgerCategories 镜像转 Category（与 picker/统计口径一致）。
// 覆盖分支：AA JSON 错误路径、缺失实体报错、共享 hydration、
// 批量 UUID 更新的快照覆盖语义。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart'
    show
        LocalTransactionRepository,
        TransactionSplitInput,
        TransactionUpdateBySyncIdData;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalTransactionRepository repo;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalTransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // UUID 主键表 insert 要求调用方提供 id，用自增序号生成确定性的测试 id。
  var ledgerSeq = 0;
  var txSeq = 0;

  /// 创建账本并返回 UUID
  Future<String> createLedger({String name = '账本'}) async {
    final now = DateTime.now().toUtc();
    final id = 'led-${ledgerSeq++}';
    await db
        .into(db.ledgers)
        .insert(LedgersCompanion.insert(id: id, name: name, updatedAt: now));
    return id;
  }

  /// 插入一笔交易。v1 下 currency_code/native_amount 为 NOT NULL，
  /// 未显式传币种时按本位币语义直写（币种 CNY、快照 = 原币金额）。
  Future<String> insertTx({
    required String ledgerId,
    String amount = '100',
    String? categoryId,
    int? aaMode,
  }) async {
    final now = DateTime.now().toUtc();
    return repo.insertTransactionCompanion(
      TransactionsCompanion.insert(
        id: 'tx-${txSeq++}',
        ledgerId: ledgerId,
        txType: 'expense',
        amount: amount,
        categoryId: d.Value(categoryId),
        aaMode: d.Value(aaMode),
        currencyCode: 'CNY',
        nativeAmount: amount,
        happenedAt: DateTime(2026, 8, 8, 12),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  group('AA 指定分摊关系表', () {
    test('addTransaction 写入指定分摊行并可读回', () async {
      final ledgerId = await createLedger();
      final txId = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: [
          TransactionSplitInput(memberId: 'u1', amount: '60.00'),
          TransactionSplitInput(memberId: 'v1', amount: '40.00'),
        ],
      );
      final rows = await repo.getTransactionSplits(txId);
      expect(rows, hasLength(2));
      expect(rows[0].memberId, 'u1');
      expect(rows[0].amount, '60.00');
      expect(rows[1].memberId, 'v1');
      expect(rows[1].amount, '40.00');
    });

    test('updateTransaction 整批替换分摊行', () async {
      final ledgerId = await createLedger();
      final txId = await insertTx(ledgerId: ledgerId, aaMode: 2);
      await repo.updateTransaction(
        id: txId,
        type: 'expense',
        amount: '200',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: [TransactionSplitInput(memberId: 'u2', amount: '200.00')],
      );
      final rows = await repo.getTransactionSplits(txId);
      expect(rows, hasLength(1));
      expect(rows[0].memberId, 'u2');
      expect(rows[0].amount, '200.00');
    });

    test('splits 传 null 清空分摊行(切换到人均/不分摊)', () async {
      final ledgerId = await createLedger();
      final txId = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: [TransactionSplitInput(memberId: 'u1', amount: '100.00')],
      );
      await repo.updateTransaction(
        id: txId,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 0,
        splits: const [],
      );
      expect(await repo.getTransactionSplits(txId), isEmpty);
    });
  });
  group('缺失实体报错', () {
    test('updateTransaction 不存在的 id 抛 StateError', () async {
      expect(
        () => repo.updateTransaction(
          id: 'no-such-tx',
          type: 'expense',
          amount: '100',
          happenedAt: DateTime(2026, 8, 8),
        ),
        throwsStateError,
      );
    });

    test('appendEditHistory 不存在的交易抛 StateError', () async {
      expect(
        () => repo.appendEditHistory(
          recordId: 'no-such-tx',
          version: 2,
          summary: '编辑',
        ),
        throwsStateError,
      );
    });
  });

  group('共享账本 category hydration', () {
    /// 写入 Owner 侧共享分类镜像（v1：categoryId 即 Owner 的分类 UUID）。
    Future<void> seedShared({
      required String ledgerId,
      required String categoryId,
      String name = '共享餐饮',
    }) => db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: ledgerId,
            categoryId: categoryId,
            name: name,
            kind: 'expense',
            updatedAt: DateTime(2026, 8, 8),
          ),
        );

    /// 插入共享账本 Editor 视角的交易：categoryId 指向 Owner 分类 UUID，
    /// 本地 Categories 表无该行，临时关闭 FK 以模拟同步 apply 写入路径。
    Future<String> insertSharedTx({
      required String ledgerId,
      required String categoryId,
    }) async {
      await db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        return await insertTx(ledgerId: ledgerId, categoryId: categoryId);
      } finally {
        await db.customStatement('PRAGMA foreign_keys = ON');
      }
    }

    test('transactionsWithCategoryAll / getRecentTransactionsWithCategory '
        '把共享镜像转 Category', () async {
      final ledgerId = await createLedger(name: '共享');
      await seedShared(ledgerId: ledgerId, categoryId: 'cat-h1');
      await insertSharedTx(ledgerId: ledgerId, categoryId: 'cat-h1');

      final all = await repo.transactionsWithCategoryAll();
      final hydrated = all.single;
      expect(hydrated.category, isNotNull);
      // v1 下镜像 categoryId 即 Owner 分类 UUID，直接作为 Category.id
      expect(hydrated.category?.id, 'cat-h1');

      final recent = await repo.getRecentTransactionsWithCategory(
        ledgerId: ledgerId,
        limit: 10,
      );
      expect(recent.single.category?.name, '共享餐饮');
    });

    test('getTransactionsByDate 走共享 hydration', () async {
      final ledgerId = await createLedger(name: '共享');
      await seedShared(ledgerId: ledgerId, categoryId: 'cat-h2');
      await insertSharedTx(ledgerId: ledgerId, categoryId: 'cat-h2');

      final rows = await repo.getTransactionsByDate(
        ledgerId: ledgerId,
        date: DateTime(2026, 8, 8),
      );
      expect(rows.single.category?.name, '共享餐饮');
    });

    test('categoryId 匹配不到共享分类 → category 保持 null', () async {
      final ledgerId = await createLedger(name: '共享');
      await insertSharedTx(ledgerId: ledgerId, categoryId: 'cat-missing');

      final all = await repo.transactionsWithCategoryAll();
      expect(all.single.category, isNull);
    });

    test('本地 category tombstone 阻止列表与日历从共享镜像复活分类', () async {
      final ledgerId = await createLedger(name: '共享');
      final deletedAt = DateTime.utc(2026, 8, 8);
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-deleted',
              name: '已删除餐饮',
              kind: 'expense',
              level: 1,
              updatedAt: deletedAt,
              deletedAt: d.Value(deletedAt),
            ),
          );
      await seedShared(
        ledgerId: ledgerId,
        categoryId: 'cat-deleted',
        name: '共享旧餐饮',
      );
      await insertTx(ledgerId: ledgerId, categoryId: 'cat-deleted');

      final all = await repo.transactionsWithCategoryAll(ledgerId: ledgerId);
      final calendar = await repo.getTransactionsByDate(
        ledgerId: ledgerId,
        date: DateTime(2026, 8, 8),
      );

      expect(all.single.category, isNull);
      expect(calendar.single.category, isNull);
    });

    test('watchTransactionsWithCategoryInMonth 输出 hydration 结果', () async {
      final ledgerId = await createLedger(name: '共享');
      await seedShared(ledgerId: ledgerId, categoryId: 'cat-h4');
      await insertSharedTx(ledgerId: ledgerId, categoryId: 'cat-h4');

      final rows = await repo
          .watchTransactionsWithCategoryInMonth(
            ledgerId: ledgerId,
            month: DateTime(2026, 8),
          )
          .first;
      expect(rows.single.category?.name, '共享餐饮');
    });
  });

  group('批量 UUID 更新快照语义', () {
    test('overwriteSnapshot=false 不动币种/AA；true 时按成对约束补快照', () async {
      final ledgerId = await createLedger(name: 'batch-snap');
      final now = DateTime.now().toUtc();
      // v1 主键即同步标识：syncId 参数实际就是 transactions.id
      await repo.insertTransactionCompanion(
        TransactionsCompanion.insert(
          id: 'snap-1',
          ledgerId: ledgerId,
          txType: 'expense',
          amount: '100',
          currencyCode: 'USD',
          nativeAmount: '720',
          happenedAt: DateTime(2026, 8, 8),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.insertTransactionCompanion(
        TransactionsCompanion.insert(
          id: 'snap-2',
          ledgerId: ledgerId,
          txType: 'expense',
          amount: '200',
          currencyCode: 'CNY',
          nativeAmount: '200',
          happenedAt: DateTime(2026, 8, 8),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 不覆盖快照：只改金额/类型，保留旧币种与快照
      await repo.updateTransactionsBatchBySyncId([
        TransactionUpdateBySyncIdData(
          syncId: 'snap-1',
          type: 'expense',
          amount: '150',
          happenedAt: DateTime(2026, 8, 8),
        ),
      ]);
      final keep = await repo.getTransactionBySyncId('snap-1');
      expect(keep?.amount, '150');
      expect(keep?.currencyCode, 'USD');
      expect(keep?.nativeAmount, '720');

      // 覆盖快照但缺币种 → 清空快照，避免破坏成对约束
      await repo.updateTransactionsBatchBySyncId([
        TransactionUpdateBySyncIdData(
          syncId: 'snap-2',
          type: 'expense',
          amount: '300',
          happenedAt: DateTime(2026, 8, 8),
          overwriteSnapshot: true,
          currencyCode: 'JPY',
        ),
      ]);
      final overwritten = await repo.getTransactionBySyncId('snap-2');
      expect(overwritten?.currencyCode, 'JPY');
      expect(overwritten?.nativeAmount, '300');
    });

    test('空更新列表直接返回空 map', () async {
      expect(await repo.updateTransactionsBatchBySyncId([]), isEmpty);
    });
  });

  group('watchRecentTransactions 与月内 watch', () {
    test('watchRecentTransactions limit 生效', () async {
      final ledgerId = await createLedger();
      await insertTx(ledgerId: ledgerId, amount: '100');
      await insertTx(ledgerId: ledgerId, amount: '200');

      final recent = await repo
          .watchRecentTransactions(ledgerId: ledgerId, limit: 1)
          .first;
      expect(recent.single.amount, '200');
    });

    test('watchTransactionsForCategoryInRange 按分类/类型过滤', () async {
      final ledgerId = await createLedger();
      final rows = await repo
          .watchTransactionsForCategoryInRange(
            ledgerId: ledgerId,
            start: DateTime(2026, 8, 1),
            end: DateTime(2026, 9, 1),
            type: 'expense',
          )
          .first;
      expect(rows, isEmpty);
    });
  });
}
