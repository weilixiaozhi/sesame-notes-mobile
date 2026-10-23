import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_import.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/ledger_lookup.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';

import 'local_accounting_context.dart';

/// maintenance 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalMaintenanceOperations on LocalAccountingContext {
  /// 读取账本本位币（大写）。
  ///
  /// 不过滤 tombstone：已删账本的历史交易仍按其真实本位币折算与计数；
  /// 行不存在或缺少币种时明确失败。
  @override
  Future<String> ledgerBaseCurrency(String ledgerId) async {
    final ledger = await findLedgerRow(db, ledgerId);
    if (ledger == null) {
      throw StateError('账本不存在，无法读取本位币: $ledgerId');
    }
    if (ledger.currency.isEmpty) {
      throw StateError('账本缺少本位币: $ledgerId');
    }
    return ledger.currency.toUpperCase();
  }

  /// 前台操作显式校验账本可写（存在且未归档），后台同步和维护逻辑不调用此限制。
  ///
  /// 账本行缺失（已删除或被同步 tombstone）同样拒绝：过期页面里的保存/清空
  /// 若放行，会以零副作用"成功"返回并弹出成功提示，把账本已不存在这件事藏起来。
  @override
  Future<void> requireActiveLedger(String ledgerId) =>
      guard('requireActiveLedger($ledgerId)', () async {
        final ledger = await getLedgerById(ledgerId);
        if (ledger == null) {
          throw StateError('账本已不存在，请刷新后重试');
        }
        if (ledger.archivedAt != null) {
          throw StateError('账本已归档，请先恢复使用');
        }
      });

  /// 清空账本交易，并复用单笔删除入口保证云账本逐笔登记 delete mutation。
  @override
  Future<int> clearLedgerTransactions(String ledgerId) => guard(
    'clearLedgerTransactions($ledgerId)',
    () => db.transaction(() async {
      final ids =
          (await (db.select(db.transactions)..where(
                    (t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull(),
                  ))
                  .get())
              .map((t) => t.id);
      return deleteTransactionRowsByIds(ids);
    }),
  );

  /// 云交易若缺少记录器必须中止，避免本地已改而远端永远收不到 mutation。
  @override
  Future<void> ensureCloudChangesCanBeRecorded(
    Iterable<Transaction> rows,
  ) async {
    if (changeTracker != null) return;
    final ledgerIds = rows.map((row) => row.ledgerId).toSet().toList();
    if (ledgerIds.isEmpty) return;
    final cloudLedger =
        await (db.select(db.ledgers)
              ..where(
                (ledger) =>
                    ledger.id.isIn(ledgerIds) &
                    ledger.storageMode.equals('cloud'),
              )
              ..limit(1))
            .getSingleOrNull();
    if (cloudLedger != null) {
      throw StateError('云账本暂时无法登记同步变更，请稍后重试');
    }
  }

  /// 统计账本尚未推送成功的同步变更条数。
  ///
  /// 云端账本导入完成后用于提示「N 条记录待同步至云端」；本地账本不产生
  /// 同步事件，恒为 0。pushed_at 非 null 表示服务端已确认（或标记处理）。
  @override
  Future<int> countPendingSyncChanges(String ledgerId) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM sync_changes '
          'WHERE ledger_id = ?1 AND pushed_at IS NULL',
          variables: [d.Variable.withString(ledgerId)],
          readsFrom: {db.syncChanges},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  /// 提供 countUnconvertedForeignTx 对应的持久化能力。
  @override
  Future<int> countUnconvertedForeignTx(String ledgerId) async {
    final base = await ledgerBaseCurrency(ledgerId);
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM transactions t '
          'WHERE t.ledger_id = ?1 '
          'AND t.deleted_at IS NULL '
          "AND UPPER(COALESCE(t.currency_code, ?2)) != ?2 "
          'AND COALESCE(t.native_amount, t.amount) = t.amount',
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(base),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  /// 提供 countForeignCurrencyTx 对应的持久化能力。
  @override
  Future<int> countForeignCurrencyTx(String ledgerId) async {
    final base = await ledgerBaseCurrency(ledgerId);
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM transactions t '
          'WHERE t.ledger_id = ?1 '
          'AND t.deleted_at IS NULL '
          "AND UPPER(COALESCE(t.currency_code, ?2)) != ?2",
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(base),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  /// 将业务导入输入转换为数据库写入值，沿用事务内的批量关系与同步登记。
  @override
  Future<List<String>> importTransactions({
    required List<TransactionImport> transactions,
    bool recordChanges = true,
  }) => guard(
    'importTransactions',
    () => insertTransactionsBatchWithRelations(
      transactions: [
        for (final item in transactions)
          TransactionsCompanion.insert(
            id: item.id,
            ledgerId: item.ledgerId,
            txType: item.txType,
            amount: item.amount,
            categoryId: d.Value(item.categoryId),
            happenedAt: item.happenedAt,
            note: d.Value(item.note),
            currencyCode: item.currencyCode,
            nativeAmount: item.nativeAmount,
            payerMemberId: d.Value(item.payerMemberId),
            createdByMemberId: item.createdByMemberId == null
                ? const d.Value.absent()
                : d.Value(item.createdByMemberId),
            lastEditedByMemberId: item.lastEditedByMemberId == null
                ? const d.Value.absent()
                : d.Value(item.lastEditedByMemberId),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          ),
      ],
      recordChanges: recordChanges,
    ),
  );

  /// 删除指定分类下的交易；云账本逐笔登记 delete，本地账本只改本地数据。
  @override
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds) {
    if (categoryIds.isEmpty) return Future.value(0);
    return guard(
      'deleteTransactionsByCategoryIds',
      () => db.transaction(() async {
        final requested = categoryIds.toSet();
        final categories = await categoryStore.getCategoriesByIds(requested);
        if (categories.length != requested.length) {
          throw StateError('分类不存在或不属于当前账号');
        }
        final scope = accountIdGetter?.call();
        // 相关云账本的所有者必须先确认，不能把缺失归属静默当成没有交易。
        await requireKnownCategoryLedgerOwners(db, scope, requested);
        final ledgerIds = await categoryManagedLedgerIds(db, scope);
        final ids =
            (await (db.select(db.transactions)..where(
                      (t) =>
                          t.categoryId.isIn(requested) &
                          t.ledgerId.isIn(ledgerIds) &
                          t.deletedAt.isNull(),
                    ))
                    .get())
                .map((t) => t.id);
        return deleteTransactionRowsByIds(ids);
      }),
    );
  }

  /// 按周期模板生成交易，并在同一事务内推进最后生成日期。
  @override
  Future<String> generateRecurringTransaction({
    required RecurringTransactionSnapshot recurring,
    required DateTime happenedAt,
  }) => guard(
    'generateRecurringTransaction recurring=${recurring.id}',
    () => db.transaction(() async {
      final current =
          await (db.select(db.recurringTransactions)..where(
                (row) => row.id.equals(recurring.id) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (current == null || !current.enabled) {
        throw StateError('周期账单已变更，请刷新后重试。');
      }
      // 归档只影响入口展示，既有周期规则仍补记；删除账本才终止生成。
      final ledger = await getLedgerById(current.ledgerId);
      if (ledger == null) throw StateError('账本已不存在，周期账单未生成。');
      final day = recurringCalendarDate(happenedAt);
      final dayKey = recurringDateKey(day);
      final txId = recurringOccurrenceId(current.ledgerId, current.id, dayKey);
      final existing = await (db.select(
        db.transactions,
      )..where((row) => row.id.equals(txId))).getSingleOrNull();
      if (existing != null &&
          (existing.recurringId != current.id ||
              existing.occurrenceDate != dayKey)) {
        throw StateError('周期发生标识冲突，原交易未修改。');
      }
      final next = nextRecurringDate(
        current,
        recurringToday(current.timeZone, DateTime.now()),
      );
      if (next != day) {
        // 并发扫描已完成相同发生时返回原身份，不覆盖人工编辑，也不复活墓碑。
        if (existing != null &&
            current.lastGeneratedDate != null &&
            !day.isAfter(
              recurringCalendarDate(current.lastGeneratedDate!.toUtc()),
            )) {
          return txId;
        }
        throw StateError('周期排期已变更，请重新计算下一发生日期。');
      }
      if (existing == null) {
        final ledgerOwner =
            await (db.select(db.ledgerMembers)..where(
                  (member) =>
                      member.ledgerId.equals(current.ledgerId) &
                      member.role.equals('owner') &
                      member.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        final (currency, nativeAmount) = await currencyService.resolveCurrency(
          ledgerId: current.ledgerId,
          amount: current.amount,
          currencyCode: current.currencyCode,
          requireRate: true,
        );
        await transactionStore.addTransaction(
          transactionId: txId,
          recurringId: current.id,
          occurrenceDate: dayKey,
          ledgerId: current.ledgerId,
          type: current.txType,
          amount: current.amount,
          currencyCode: currency,
          nativeAmount: nativeAmount,
          categoryId: current.categoryId,
          happenedAt: recurringOccurrenceInstant(day, current.timeZone),
          note: current.note,
          payerMemberId: ledgerOwner?.id,
        );
      }
      await updateLastGeneratedDate(current.id, day);
      return txId;
    }),
  );
}
