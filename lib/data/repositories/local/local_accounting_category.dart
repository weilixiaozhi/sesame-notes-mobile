import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';

import 'local_accounting_context.dart';
import '../contracts/accounting_repositories.dart';

/// 分类写入与跨仓储协作共享事务、账号和同步变更登记。
mixin LocalCategoryOperations on LocalAccountingContext {
  /// 官方模板的固定身份写入由分类仓储原子处理，未确认墓碑不会进入可见目录。
  @override
  Future<CanonicalCategoryInsertResult> insertCanonicalCategory({
    required String id,
    required String name,
    required String kind,
    required int level,
    String? icon,
    int? sortOrder,
    String? parentId,
    bool restoreLocalDeleted = false,
  }) => categoryStore.insertCanonicalCategory(
    id: id,
    name: name,
    kind: kind,
    level: level,
    icon: icon,
    sortOrder: sortOrder,
    parentId: parentId,
    restoreLocalDeleted: restoreLocalDeleted,
  );

  /// 创建分类，并透传是否登记同步变更；恢复回填使用 false。
  @override
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int level = 1,
    String? parentId,
    bool recordChanges = true,
    String? ledgerId,
  }) => categoryStore.createCategory(
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    level: level,
    parentId: parentId,
    recordChanges: recordChanges,
    ledgerId: ledgerId,
  );

  /// 创建子分类，并透传是否登记同步变更；恢复回填使用 false。
  @override
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
    String? ledgerId,
  }) => categoryStore.createSubCategory(
    parentId: parentId,
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    recordChanges: recordChanges,
    ledgerId: ledgerId,
  );

  /// 提供 updateCategory 对应的持久化能力。
  @override
  Future<void> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
    String? ledgerId,
  }) => categoryStore.updateCategory(
    id,
    name: name,
    icon: icon,
    parentId: parentId,
    level: level,
    ledgerId: ledgerId,
  );

  /// 提供 deleteCategory 对应的持久化能力。
  Future<void> deleteCategory(String id) => categoryStore.deleteCategory(id);

  /// 提供 deleteCategoriesByIds 对应的持久化能力。
  @override
  Future<void> deleteCategoriesByIds(List<String> ids) =>
      categoryStore.deleteCategoriesByIds(ids);

  /// 提供 promoteSubCategoriesToTopLevel 对应的持久化能力。
  @override
  Future<int> promoteSubCategoriesToTopLevel(String parentId) =>
      categoryStore.promoteSubCategoriesToTopLevel(parentId);

  /// 提供 upsertCategory 对应的持久化能力。
  Future<({String id, bool created})> upsertCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    String? ledgerId,
  }) => categoryStore.upsertCategory(
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    ledgerId: ledgerId,
  );

  /// 迁移分类直属交易，并为实际变化的云交易登记完整 upsert 快照。
  Future<int> migrateCategory({
    required String fromCategoryId,
    required String toCategoryId,
  }) => guard(
    'migrateCategory($fromCategoryId->$toCategoryId)',
    () => db.transaction(() async {
      final scope = accountIdGetter?.call();
      final ledgerIds = await categoryManagedLedgerIds(db, scope);
      final rows =
          await (db.select(db.transactions)..where(
                (t) =>
                    t.categoryId.equals(fromCategoryId) &
                    t.ledgerId.isIn(ledgerIds) &
                    t.deletedAt.isNull(),
              ))
              .get();
      final migrated = await categoryStore.migrateCategory(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      await ensureCloudChangesCanBeRecorded(rows);
      await transactionStore.recordBatchTxChanges(rows.map((row) => row.id));
      return migrated;
    }),
  );

  /// 迁移分类树下的全部交易（含二级分类交易）到目标分类，返回迁移交易数；
  /// 只为 categoryId 真正变化的云交易登记 upsert。
  @override
  Future<int> migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) => guard(
    'migrateCategoryTransactions($fromCategoryId->$toCategoryId)',
    () => db.transaction(() async {
      final scope = accountIdGetter?.call();
      final ledgerIds = await categoryManagedLedgerIds(db, scope);
      final childIds =
          (await (db.select(db.categories)..where(
                    (c) =>
                        categoryScopePredicate(c, scope) &
                        c.parentId.equals(fromCategoryId) &
                        c.deletedAt.isNull(),
                  ))
                  .get())
              .map((row) => row.id);
      final sourceIds = {fromCategoryId, ...childIds};
      final before =
          await (db.select(db.transactions)..where(
                (t) =>
                    t.categoryId.isIn(sourceIds) &
                    t.ledgerId.isIn(ledgerIds) &
                    t.deletedAt.isNull(),
              ))
              .get();

      final result = await categoryStore.migrateCategoryTransactions(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      final after = {
        for (final row
            in await (db.select(db.transactions)..where(
                  (t) =>
                      t.id.isIn(before.map((row) => row.id).toList()) &
                      t.deletedAt.isNull(),
                ))
                .get())
          row.id: row,
      };
      final changed = before.where(
        (row) => after[row.id]?.categoryId != row.categoryId,
      );
      await ensureCloudChangesCanBeRecorded(changed);
      await transactionStore.recordBatchTxChanges(changed.map((row) => row.id));
      return result;
    }),
  );

  /// 提供 updateCategorySortOrders 对应的持久化能力。
  @override
  Future<void> updateCategorySortOrders(
    List<({String id, int sortOrder})> updates,
  ) => categoryStore.updateCategorySortOrders(updates);

  /// 提供 batchInsertCategories 对应的持久化能力。
  Future<void> batchInsertCategories(List<CategoriesCompanion> categories) =>
      categoryStore.batchInsertCategories(categories);

  /// 提供 insertCategory 对应的持久化能力。
  Future<String> insertCategory(CategoriesCompanion category) =>
      categoryStore.insertCategory(category);
}
