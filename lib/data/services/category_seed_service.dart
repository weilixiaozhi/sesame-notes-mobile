import 'package:drift/drift.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:sesame_notes/utils/default_category_seed_catalog.dart';

/// 分类首次初始化的持久化能力，调用方传入纯内容项，名称映射留在上层。
class CategorySeedService {
  /// 工具类不持有会话或界面状态。
  CategorySeedService._();

  /// 系统默认分类没有用户编辑时钟，后续真实修改由仓储推进时间。
  static final _updatedAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// 正式账号使用固定目录，只在本域没有分类与墓碑时初始化。
  static Future<void> ensureAccountSeed(
    SesameDatabase db,
    String accountId,
  ) async {
    try {
      if (accountId.isEmpty) throw StateError('分类初始化缺少账号归属');
      await ensureCategories(
        db,
        accountDefaultCategorySeeds,
        scopeAccountId: accountId,
      );
    } catch (error, stack) {
      logger.error(
        'CategorySeedService',
        '初始化账号正式分类目录失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 在同一事务内检查首次条件并写入完整父子目录，已有用户内容和墓碑保持原样。
  static Future<void> ensureCategories(
    SesameDatabase db,
    Iterable<CategorySeedItem> categories, {
    String? scopeAccountId,
  }) async {
    try {
      await db.transaction(() async {
        final existing =
            await (db.select(db.categories)
                  ..where((c) => categoryScopePredicate(c, scopeAccountId))
                  ..limit(1))
                .getSingleOrNull();
        if (existing != null) return;
        if (scopeAccountId == null) {
          final referenced = await db
              .customSelect(
                'SELECT 1 FROM transactions t JOIN ledgers l ON l.id=t.ledger_id '
                "WHERE l.storage_mode='local' AND t.category_id IS NOT NULL UNION "
                'SELECT 1 FROM recurring_transactions r JOIN ledgers l ON l.id=r.ledger_id '
                "WHERE l.storage_mode='local' AND r.category_id IS NOT NULL LIMIT 1",
              )
              .get();
          // 历史记录中的未知分类需要先确认来源，默认目录不能接管这些引用。
          if (referenced.isNotEmpty) return;
        }

        for (final category in categories) {
          await db
              .into(db.categories)
              .insert(
                CategoriesCompanion.insert(
                  id: defaultCategoryId(
                    level: category.level,
                    key: category.key,
                  ),
                  scopeAccountId: Value(scopeAccountId),
                  name: category.name,
                  kind: 'expense',
                  icon: Value(category.icon),
                  sortOrder: Value(category.sortOrder),
                  level: category.level,
                  parentId: Value(
                    category.parentKey == null
                        ? null
                        : defaultCategoryId(level: 1, key: category.parentKey!),
                  ),
                  updatedAt: _updatedAt,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      });
    } catch (error, stack) {
      logger.error(
        'CategorySeedService',
        '默认分类目录写入失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }
}
