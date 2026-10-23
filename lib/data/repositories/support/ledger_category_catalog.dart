import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';

import 'category_scope.dart';

/// 分类管理仅遍历所属域的本地账本或云端所有者账本，共享协作者账本独立维护。
Future<Set<String>> categoryManagedLedgerIds(
  SesameDatabase db,
  String? scope,
) async {
  try {
    final rows = await (db.select(
      db.ledgers,
    )..where((row) => categoryLedgerPredicate(row, scope))).get();
    return rows.map((row) => row.id).toSet();
  } catch (error, stackTrace) {
    logger.error('LedgerCategories', '读取分类管理所属账本失败', error, stackTrace);
    rethrow;
  }
}

/// 解析一本账本的分类目录；本地账本使用本地域，云端所有者使用自己的账号域，成员使用账本镜像。
Future<Map<String, Category>> readLedgerCategoryCatalog(
  SesameDatabase db,
  String ledgerId, {
  Iterable<String>? categoryIds,
}) async {
  try {
    final ledger =
        await (db.select(
              db.ledgers,
            )..where((row) => row.id.equals(ledgerId) & row.deletedAt.isNull()))
            .getSingleOrNull();
    if (ledger == null) return const {};
    final ids = categoryIds?.toSet();
    if (ids?.isEmpty == true) return const {};
    final scope = categoryScopeForLedger(ledger);
    if (ledger.storageMode == 'cloud' && scope != ledger.scopeAccountId) {
      // 镜像仅代表这个账本的所有者，私人分类的同 ID 内容和墓碑都不能影响它。
      final query = db.select(
        db.sharedLedgerCategories,
      )..where((row) => row.ledgerId.equals(ledgerId) & row.deletedAt.isNull());
      if (ids != null) query.where((row) => row.categoryId.isIn(ids));
      final shared = await query.get();
      return {
        for (final row in shared)
          row.categoryId: Category(
            cloudRegistered: true,
            id: row.categoryId,
            name: row.name,
            kind: row.kind,
            level: row.level,
            sortOrder: row.sortOrder,
            icon: row.icon,
            parentId: row.parentId,
            scopeAccountId: scope,
            updatedAt: row.updatedAt,
          ),
      };
    }
    final query = db.select(db.categories)
      ..where(
        (row) => categoryScopePredicate(row, scope) & row.deletedAt.isNull(),
      )
      ..orderBy([(row) => d.OrderingTerm.asc(row.sortOrder)]);
    if (ids != null) query.where((row) => row.id.isIn(ids));
    final rows = await query.get();
    return {for (final row in rows) row.id: row};
  } catch (error, stackTrace) {
    logger.error('LedgerCategories', '读取账本所属分类目录失败', error, stackTrace);
    rethrow;
  }
}

/// 按不同账本批量解析交易分类，分类同名或同 ID 不改变账本的真实归属。
Future<List<({Transaction t, Category? category})>> readTransactionCategories(
  SesameDatabase db,
  List<Transaction> transactions,
) async {
  try {
    final idsByLedger = <String, Set<String>>{};
    for (final row in transactions) {
      if (row.categoryId case final id?) {
        (idsByLedger[row.ledgerId] ??= {}).add(id);
      }
    }
    final categories = <String, Map<String, Category>>{};
    for (final entry in idsByLedger.entries) {
      categories[entry.key] = await readLedgerCategoryCatalog(
        db,
        entry.key,
        categoryIds: entry.value,
      );
    }
    return [
      for (final row in transactions)
        (t: row, category: categories[row.ledgerId]?[row.categoryId]),
    ];
  } catch (error, stackTrace) {
    logger.error('LedgerCategories', '解析交易所属分类失败', error, stackTrace);
    rethrow;
  }
}
