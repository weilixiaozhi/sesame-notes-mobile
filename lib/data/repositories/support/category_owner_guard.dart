import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';

/// 尚未确认账本所有者时，不能把相关分类的未知使用量当作零。
const categoryOwnerUnconfirmedMessage = '账本的分类归属尚未确认，请先同步账本，再统计、迁移或清理相关分类。';

/// 当前私有目录遇到相关未知所有者账本时暂停统计与管理；本地域独立处理。
Future<void> requireKnownCategoryLedgerOwners(
  SesameDatabase db,
  String? scope,
  Iterable<String> categoryIds,
) async {
  if (scope == null) return;
  final ids = categoryIds.toSet();
  if (ids.isEmpty) return;
  try {
    final unknownQuery = db.selectOnly(db.ledgers)
      ..addColumns([db.ledgers.id])
      ..where(
        db.ledgers.storageMode.equals('cloud') &
            db.ledgers.scopeAccountId.equals(scope) &
            (db.ledgers.ownerAccountId.isNull() |
                db.ledgers.ownerAccountId.equals('')),
      );
    final unknown = await unknownQuery.get();
    final ledgerIds = [for (final row in unknown) row.read(db.ledgers.id)!];
    if (ledgerIds.isEmpty) return;

    // 分类引用包括历史墓碑，未知所有者不能让删除过程清理错误域的弱引用。
    final transactionQuery = db.selectOnly(db.transactions)
      ..addColumns([db.transactions.id])
      ..where(
        db.transactions.ledgerId.isIn(ledgerIds) &
            db.transactions.categoryId.isIn(ids),
      )
      ..limit(1);
    final recurringQuery = db.selectOnly(db.recurringTransactions)
      ..addColumns([db.recurringTransactions.id])
      ..where(
        db.recurringTransactions.ledgerId.isIn(ledgerIds) &
            db.recurringTransactions.categoryId.isIn(ids),
      )
      ..limit(1);
    if (await transactionQuery.getSingleOrNull() != null ||
        await recurringQuery.getSingleOrNull() != null) {
      throw StateError(categoryOwnerUnconfirmedMessage);
    }

    // 冻结请求代表实际在途意图，未冻结时才读取当前载荷；周期初始历史也有分类引用。
    final ledgerSlots = List.filled(ledgerIds.length, '?').join(',');
    final categorySlots = List.filled(ids.length, '?').join(',');
    final pending = await db
        .customSelect(
          '''
      WITH pending AS (
        SELECT COALESCE(json_extract(frozen_request, '\$.payload'), payload) AS body
        FROM sync_changes
        WHERE account_id = ? AND ledger_id IN ($ledgerSlots)
          AND pushed_at IS NULL
          AND entity_type IN ('transaction', 'recurring_transaction')
      )
      SELECT 1 AS blocked FROM pending
      WHERE json_extract(body, '\$.category_id') IN ($categorySlots)
        OR EXISTS (
          SELECT 1 FROM json_each(body, '\$.initial_state.occurrences') occurrence
          WHERE json_extract(occurrence.value, '\$.payload.category_id') IN ($categorySlots)
        )
      LIMIT 1
      ''',
          variables: [
            scope,
            ...ledgerIds,
            ...ids,
            ...ids,
          ].map(d.Variable.withString).toList(),
          readsFrom: {db.syncChanges, db.ledgers},
        )
        .getSingleOrNull();
    if (pending != null) throw StateError(categoryOwnerUnconfirmedMessage);
  } catch (error, stack) {
    logger.error(
      'CategoryOwner',
      '分类管理暂停，相关账本所有者未确认',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
