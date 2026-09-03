import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_node.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';
import 'package:sesame_notes/data/repositories/support/shared_ledger_picker_filter.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 本地分类 Repository 实现（schema v1：UUID 主键 + 变更登记）。
///
/// 设计意图：
/// - 分类是 user-global 同步实体，主键即 UUID，离线创建由客户端生成，
///   本地与云端始终同一 id，主键即同步标识（无 sync_id / synthetic 负数 id）；
/// - 所有写操作与 recordUserGlobalChange 变更登记放同一事务：登记失败时
///   回滚写库，避免「本地已生效但云端永远不知道」的静默丢失；
/// - 分类金额列（交易侧）为规范化 decimal 字符串，统计聚合在 Dart 层用
///   Decimal 累加——SQL 的 SUM/AVG 对 TEXT 列不生效。
class LocalCategoryRepository {
  static const _uuid = Uuid();
  final SesameDatabase db;

  /// 变更登记器的惰性获取函数（见 support/change_recorder.dart）。
  ///
  /// 用 getter 而不是直接持有实例：changeTracker 挂在外层 LocalRepository
  /// 上且可能在运行期被替换（登录/登出时重建），每次取值都拿最新引用。
  final ChangeRecorder? Function()? trackerGetter;

  /// 当前云账号，用于让产生同步 mutation 的分类进入同一账号数据域。
  final String? Function()? accountIdGetter;

  LocalCategoryRepository(this.db, {this.trackerGetter, this.accountIdGetter});

  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      db.transaction(action);

  /// 构造契约形状的 category payload（规范化 snake_case，完整实体 JSON）。
  String _categoryPayload(Category c) {
    return jsonEncode({
      'id': c.id,
      'name': c.name,
      'kind': c.kind,
      'level': c.level,
      'sort_order': c.sortOrder,
      'icon': c.icon,
      'parent_id': c.parentId,
      'updated_at': c.updatedAt.toIso8601String(),
    });
  }

  /// 登记一条 category user-global 变更（tracker 未注入时为 no-op）。
  Future<void> _recordCategoryChange({
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    final tracker = trackerGetter?.call();
    if (tracker == null) return;
    final accountId = accountIdGetter?.call();
    if (accountId != null) {
      // scope 与 mutation 同事务落库；登记失败时二者一起回滚。
      await (db.update(db.categories)
            ..where((category) => category.id.equals(entityId)))
          .write(CategoriesCompanion(scopeAccountId: d.Value(accountId)));
    }
    await tracker.recordUserGlobalChange(
      entityType: 'category',
      entityId: entityId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
    );
  }

  /// 返回本地 category tombstone id，用于阻止共享镜像回退复活同一实体。
  Future<Set<String>> _tombstonedCategoryIds() async {
    final rows = await (db.select(
      db.categories,
    )..where((category) => category.deletedAt.isNotNull())).get();
    return rows.map((category) => category.id).toSet();
  }

  /// 创建一级分类；恢复回填传 [recordChanges] 为 false，避免历史快照反向推云。
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int level = 1,
    String? parentId,
    bool recordChanges = true,
  }) async {
    // 撞同名抛 DuplicateNameException。判重按「作用域唯一」契约:
    // 只在同一父级作用域内判重(parentId 为 null → 一级分类之间;非 null →
    // 同父的二级之间)。跨父级/跨层级允许同名(默认 seed 即有「购物>鞋子」
    // 「服装>鞋子」)。caller 显式 handle:
    //   - UI 主动建 → 先过 isCategoryNameDuplicate 警告;真冲突 try/catch 弹 toast
    //   - import / 自动记账等静默路径 → 使用 upsertCategory(get-or-create)
    // 静默复用会吞掉 caller 传的 icon/sortOrder。
    final dupQuery = db.select(db.categories)
      ..where(
        (c) => c.name.equals(name) & c.kind.equals(kind) & c.deletedAt.isNull(),
      );
    if (parentId == null) {
      dupQuery.where((c) => c.parentId.isNull());
    } else {
      final pid = parentId;
      dupQuery.where((c) => c.parentId.equals(pid));
    }
    final existing = await dupQuery.get();
    if (existing.isNotEmpty) {
      throw DuplicateNameException(entityType: 'category', name: name);
    }
    // 离线创建即生成 UUID 主键，本地与云端始终同一 id。
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    // 写库与变更登记同事务:登记失败时回滚,避免云端漏推新分类。
    await db.transaction(() async {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: name,
              kind: kind,
              level: level,
              icon: d.Value(icon),
              sortOrder: d.Value(sortOrder ?? 0),
              parentId: d.Value(parentId),
              updatedAt: now,
            ),
          );
      if (recordChanges) {
        await _recordCategoryChange(
          entityId: id,
          action: 'upsert',
          payload: _categoryPayload(
            Category(
              id: id,
              name: name,
              kind: kind,
              level: level,
              sortOrder: sortOrder ?? 0,
              icon: icon,
              parentId: parentId,
              updatedAt: now,
            ),
          ),
          updatedAt: now,
        );
      }
    });
    return id;
  }

  /// 创建二级分类；恢复回填传 [recordChanges] 为 false，避免历史快照反向推云。
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
  }) async {
    // 作用域唯一:仅在同一 parentId 下判重,跨父级允许同名二级分类
    final existing =
        await (db.select(db.categories)..where(
              (c) =>
                  c.name.equals(name) &
                  c.kind.equals(kind) &
                  c.parentId.equals(parentId) &
                  c.deletedAt.isNull(),
            ))
            .get();
    if (existing.isNotEmpty) {
      throw DuplicateNameException(entityType: 'category', name: name);
    }
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: name,
              kind: kind,
              icon: d.Value(icon),
              parentId: d.Value(parentId),
              level: 2,
              sortOrder: d.Value(sortOrder ?? 0),
              updatedAt: now,
            ),
          );
      if (recordChanges) {
        await _recordCategoryChange(
          entityId: id,
          action: 'upsert',
          payload: _categoryPayload(
            Category(
              id: id,
              name: name,
              kind: kind,
              level: 2,
              sortOrder: sortOrder ?? 0,
              icon: icon,
              parentId: parentId,
              updatedAt: now,
            ),
          ),
          updatedAt: now,
        );
      }
    });
    return id;
  }

  Future<void> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
  }) async {
    // 全部字段均未变更时直接返回:避免空 UPDATE,也不产生无意义同步信号。
    final hasAnyChange =
        name != null || icon != null || parentId != null || level != null;
    if (!hasAnyChange) return;

    // 写库与变更登记同事务(与 createCategory 模式对称)。
    await db.transaction(() async {
      final row =
          await (db.select(db.categories)
                ..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) return; // 目标不存在:静默跳过
      final now = DateTime.now().toUtc();
      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          name: name != null ? d.Value(name) : const d.Value.absent(),
          icon: icon != null ? d.Value(icon) : const d.Value.absent(),
          // parentId: '' 表示清空父分类,其他非空值表示设置父分类,
          // null 表示不改动。
          parentId: parentId != null
              ? (parentId.isEmpty ? const d.Value(null) : d.Value(parentId))
              : const d.Value.absent(),
          level: level != null ? d.Value(level) : const d.Value.absent(),
          // updatedAt 是同步 LWW 依据,任何字段变更都要推进。
          updatedAt: d.Value(now),
        ),
      );
      // payload 以变更后的完整实体构造(契约:payload 为完整实体 JSON)。
      final updated = Category(
        id: row.id,
        name: name ?? row.name,
        kind: row.kind,
        level: level ?? row.level,
        sortOrder: row.sortOrder,
        icon: icon ?? row.icon,
        parentId: parentId != null
            ? (parentId.isEmpty ? null : parentId)
            : row.parentId,
        updatedAt: now,
      );
      await _recordCategoryChange(
        entityId: id,
        action: 'upsert',
        payload: _categoryPayload(updated),
        updatedAt: now,
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    // 直接删分类必须 fail-loud:有子分类或交易时静默删分类会让交易 category_id
    // 指向已删除行,统计里变成"未分类"。调用方应先显式编排删除交易/提升子分类。
    final hasSub =
        await (db.select(db.categories)
              ..where((c) => c.parentId.equals(id) & c.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    final hasTx =
        await (db.select(db.transactions)
              ..where(
                (transaction) =>
                    transaction.categoryId.equals(id) &
                    transaction.deletedAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (hasSub != null || hasTx != null) {
      throw StateError(
        '分类(id=$id)存在子分类或关联交易,禁止直接删除;'
        '请先调用 deleteTransactionsByCategoryIds / promoteSubCategoriesToTopLevel / '
        'deleteCategoriesByIds 显式编排。',
      );
    }
    // 删除与登记变更同事务:登记失败时回滚,避免本地已删但云端仍持有投影。
    await db.transaction(() async {
      final row =
          await (db.select(db.categories)
                ..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) return;
      await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
      final now = DateTime.now().toUtc();
      await _recordCategoryChange(
        entityId: id,
        action: 'delete',
        payload: _categoryPayload(row.copyWith(updatedAt: now)),
        updatedAt: now,
      );
    });
  }

  Future<void> deleteCategoriesByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await db.transaction(() async {
      // 预查 ids 自身及其子分类(删除语义:先删子分类再删自身),
      // 供删除后逐条登记 category:delete 变更。
      final rows =
          await (db.select(db.categories)..where(
                (c) =>
                    (c.id.isIn(ids) | c.parentId.isIn(ids)) &
                    c.deletedAt.isNull(),
              ))
              .get();
      await (db.delete(db.categories)..where((c) => c.parentId.isIn(ids))).go();
      await (db.delete(db.categories)..where((c) => c.id.isIn(ids))).go();
      final now = DateTime.now().toUtc();
      for (final row in rows) {
        await _recordCategoryChange(
          entityId: row.id,
          action: 'delete',
          payload: _categoryPayload(row.copyWith(updatedAt: now)),
          updatedAt: now,
        );
      }
    });
  }

  /// 删除指定分类下的本地交易行。
  ///
  /// 业务层统一从 LocalRepository 调用，由外层复用交易仓储逐笔登记云端
  /// delete mutation；本方法保留给分类子仓储的数据操作测试。
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds) async {
    if (categoryIds.isEmpty) return 0;
    return await (db.delete(
      db.transactions,
    )..where((t) => t.categoryId.isIn(categoryIds))).go();
  }

  Future<int> promoteSubCategoriesToTopLevel(String parentId) async {
    return await db.transaction(() async {
      // 获取所有需要提升的二级分类
      final subCategories = await getSubCategories(parentId);
      if (subCategories.isEmpty) return 0;

      // 查当前一级分类的最大 sortOrder，确保提升后的分类排在已有分类之后
      final topLevel =
          await (db.select(db.categories)
                ..where(
                  (c) =>
                      c.parentId.isNull() &
                      c.level.equals(1) &
                      c.deletedAt.isNull(),
                )
                ..orderBy([
                  (c) => d.OrderingTerm(
                    expression: c.sortOrder,
                    mode: d.OrderingMode.desc,
                  ),
                ]))
              .get();
      // 从最大 sortOrder + 1 开始递增分配
      int nextSortOrder = topLevel.isEmpty ? 0 : topLevel.first.sortOrder + 1;
      final now = DateTime.now().toUtc();

      int promoted = 0;
      for (final sub in subCategories) {
        final assignedSortOrder = nextSortOrder++;
        await (db.update(
          db.categories,
        )..where((c) => c.id.equals(sub.id))).write(
          CategoriesCompanion(
            parentId: const d.Value(null),
            level: const d.Value(1),
            sortOrder: d.Value(assignedSortOrder),
            updatedAt: d.Value(now),
          ),
        );
        await _recordCategoryChange(
          entityId: sub.id,
          action: 'upsert',
          payload: _categoryPayload(
            sub.copyWith(
              parentId: const d.Value(null),
              level: 1,
              sortOrder: assignedSortOrder,
              updatedAt: now,
            ),
          ),
          updatedAt: now,
        );
        promoted++;
      }
      return promoted;
    });
  }

  Future<({String id, bool created})> upsertCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
  }) async {
    // 按 (name,kind) 找;有则复用,无则用给定 icon/sortOrder 建。
    // 作用域唯一契约下可能命中多行(跨父级同名,如两个「鞋子」),
    // 取 id 最小的一行保证结果确定 —— import 等按名调用方本就无法区分同名。
    final existing =
        await (db.select(db.categories)
              ..where(
                (c) =>
                    c.name.equals(name) &
                    c.kind.equals(kind) &
                    c.deletedAt.isNull(),
              )
              ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
            .get();
    if (existing.isNotEmpty) {
      return (id: existing.first.id, created: false);
    }
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: name,
              kind: kind,
              level: 1,
              icon: d.Value(icon),
              sortOrder: d.Value(sortOrder ?? 0),
              updatedAt: now,
            ),
          );
      await _recordCategoryChange(
        entityId: id,
        action: 'upsert',
        payload: _categoryPayload(
          Category(
            id: id,
            name: name,
            kind: kind,
            level: 1,
            sortOrder: sortOrder ?? 0,
            icon: icon,
            parentId: null,
            updatedAt: now,
          ),
        ),
        updatedAt: now,
      );
    });
    return (id: id, created: true);
  }

  Future<Category?> getCategoryById(String categoryId) async {
    return await (db.select(db.categories)
          ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// 按分类 UUID 反查分类（tx editor 的 initial selected 用）。
  ///
  /// schema v1 下所有分类 id 均为 UUID，主表与共享镜像（
  /// SharedLedgerCategories.categoryId = Owner 的分类 UUID）共用同一 id：
  /// 先查主表，未命中再扫共享镜像（可选按账本 UUID 限定范围）。
  Future<Category?> findCategoryBySyntheticId(
    String id, {
    String? ledgerSyncId,
  }) async {
    final local = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    // 本地已有 tombstone 时不得回退共享镜像，否则同一分类会被“复活”。
    if (local != null) return local.deletedAt == null ? local : null;
    return db.findSharedCategoryById(id, ledgerId: ledgerSyncId);
  }

  /// 共享账本 picker 过滤：直接委托 SesameDatabase 扩展
  /// （SharedLedgerPickerFilter），扩展内部已按 ledger 角色分派：
  /// Editor + 共享账本 → SharedLedgerCategories 转 Category 返回；
  /// 单人账本 / Owner → 主表 raw 数据。此处只做透传。
  Future<List<Category>> filterCategoriesForLedgerPicker(
    List<Category> all, {
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  }) async {
    final ctx = await db.loadLedgerPickerContext(ledgerId);
    final candidates = await db.filterCategoriesForLedger(
      all.where((category) => category.deletedAt == null).toList(),
      ctx,
      kind: kind,
      topLevelOnly: topLevelOnly,
    );
    final tombstonedIds = await _tombstonedCategoryIds();
    return candidates
        .where((category) => !tombstonedIds.contains(category.id))
        .toList();
  }

  Future<Map<String, Category>> getCategoriesByIds(Iterable<String> ids) async {
    final idList = ids.toList();
    if (idList.isEmpty) return const {};
    // 批量查询避免 N+1：单次 SELECT ... WHERE id IN (...) 取回全部
    final rows = await (db.select(
      db.categories,
    )..where((c) => c.id.isIn(idList) & c.deletedAt.isNull())).get();
    return {for (final r in rows) r.id: r};
  }

  Future<List<Category>> getTopLevelCategories(String kind) async {
    return await (db.select(db.categories)
          ..where(
            (c) =>
                c.kind.equals(kind) &
                c.level.equals(1) &
                c.parentId.isNull() &
                c.deletedAt.isNull(),
          )
          ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  Future<List<Category>> getSubCategories(String parentId) async {
    if (await getCategoryById(parentId) == null) return const [];
    return await (db.select(db.categories)
          ..where(
            (c) =>
                c.parentId.equals(parentId) &
                c.level.equals(2) &
                c.deletedAt.isNull(),
          )
          ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  Future<CategoryRowTree> getCategoryTree(String kind) async {
    // 一次查询取回该 kind 的全部 level 1+2 记录，按 sortOrder 排序后内存
    // 拆分一级/二级分组，避免 N+1 查询。
    final rows =
        await (db.select(db.categories)
              ..where((c) => c.kind.equals(kind) & c.deletedAt.isNull())
              ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
            .get();
    final topLevel = <Category>[];
    // 父分类 UUID → 子分类列表
    final children = <String, List<Category>>{};
    for (final row in rows) {
      if (row.level == 1 && row.parentId == null) {
        topLevel.add(row);
      } else if (row.level == 2 && row.parentId != null) {
        (children[row.parentId!] ??= []).add(row);
      }
    }
    return CategoryRowTree(topLevel: topLevel, children: children);
  }

  Future<List<Category>> getUsableCategories(String kind) async {
    final allCategories =
        await (db.select(db.categories)
              ..where((c) => c.kind.equals(kind) & c.deletedAt.isNull())
              ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
            .get();
    return CategoryHierarchy.getUsableCategories(allCategories);
  }

  Future<bool> isCategoryNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
  }) async {
    var expression =
        db.categories.name.equals(name) &
        db.categories.kind.equals(kind) &
        db.categories.deletedAt.isNull();

    // 作用域判重:parentId 为 null → 只和一级分类比;非 null → 只和同父的二级比。
    // 跨父级/跨层级同名是合法设计(见 createCategory 契约注释)。
    if (parentId == null) {
      expression = expression & db.categories.parentId.isNull();
    } else {
      expression = expression & db.categories.parentId.equals(parentId);
    }

    if (excludeId != null) {
      expression = expression & db.categories.id.equals(excludeId).not();
    }

    final query = db.select(db.categories)..where((c) => expression);
    final results = await query.get();
    return results.isNotEmpty;
  }

  Future<bool> hasSubCategories(String categoryId) async {
    if (await getCategoryById(categoryId) == null) return false;
    final count = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM categories '
          'WHERE parent_id = ? AND deleted_at IS NULL',
          variables: [d.Variable.withString(categoryId)],
          readsFrom: {db.categories},
        )
        .getSingle();

    final c = count.data['count'];
    if (c is int) return c > 0;
    if (c is BigInt) return c > BigInt.zero;
    if (c is num) return c > 0;
    return false;
  }

  Future<int> getSubCategoryCount(String categoryId) async {
    if (await getCategoryById(categoryId) == null) return 0;
    final result = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM categories '
          'WHERE parent_id = ? AND deleted_at IS NULL',
          variables: [d.Variable.withString(categoryId)],
          readsFrom: {db.categories},
        )
        .getSingle();

    final count = result.data['count'];
    if (count is int) return count;
    if (count is BigInt) return count.toInt();
    if (count is num) return count.toInt();
    return 0;
  }

  Future<int> getTransactionCountByCategory(String categoryId) async {
    if (await getCategoryById(categoryId) == null) return 0;
    final result = await db
        .customSelect(
          'SELECT COUNT(*) AS count FROM transactions '
          'WHERE category_id = ?1 AND deleted_at IS NULL',
          variables: [d.Variable.withString(categoryId)],
          readsFrom: {db.transactions},
        )
        .getSingle();

    final count = result.data['count'];
    if (count is int) return count;
    if (count is BigInt) return count.toInt();
    if (count is num) return count.toInt();
    return 0;
  }

  Future<Map<String, int>> getAllCategoryTransactionCounts() async {
    final result = await db
        .customSelect(
          '''
      SELECT
        c.id as category_id,
        COALESCE(COUNT(t.id), 0) as transaction_count
      FROM categories c
      LEFT JOIN transactions t
        ON c.id = t.category_id AND t.deleted_at IS NULL
      WHERE c.deleted_at IS NULL
      GROUP BY c.id
      ''',
          readsFrom: {db.categories, db.transactions},
        )
        .get();

    final Map<String, int> counts = {};
    for (final row in result) {
      final categoryId = row.data['category_id'];
      final count = row.data['transaction_count'];

      if (categoryId is String) {
        int countInt = 0;
        if (count is int) {
          countInt = count;
        } else if (count is BigInt) {
          countInt = count.toInt();
        } else if (count is num) {
          countInt = count.toInt();
        }

        counts[categoryId] = countInt;
      }
    }

    return counts;
  }

  /// 汇总指定账本内某分类的交易数量与账本币金额。
  ///
  /// 分类可跨账本复用，而 nativeAmount 的单位是各自账本本位币，因此必须用
  /// [ledgerId] 限定范围，避免直接相加不同币种的金额快照。
  Future<({int totalCount, double totalAmount, double averageAmount})>
  getCategorySummary(String categoryId, {required String ledgerId}) async {
    if (await getCategoryById(categoryId) == null) {
      return (totalCount: 0, totalAmount: 0.0, averageAmount: 0.0);
    }
    // 金额列是 TEXT decimal 字符串,SQL 的 SUM/AVG 对文本不生效,
    // Dart 层拉行后 Decimal 累加(与统计仓储口径一致)。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.ledgerId.equals(ledgerId) &
                  t.deletedAt.isNull(),
            ))
            .get();
    var total = Decimal.zero;
    var statCount = 0; // 参与统计的行数(即 AVG 的分母)
    for (final t in rows) {
      if (t.excludeFromStats) continue;
      // 折算快照优先,缺失才回退原币金额(契约:本位币交易二者相等)。
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        total += v;
        statCount++;
      }
    }
    // 中间累加全程 Decimal;average 是 final 展示值,除法转 double 计算
    // (decimal 3.x 的 / 返回 Rational,直接取 double 更简洁且不引入 scale 约定)。
    final totalDouble = total.toDouble();
    final average = statCount == 0 ? 0.0 : totalDouble / statCount;
    return (
      totalCount: rows.length,
      totalAmount: totalDouble,
      averageAmount: average,
    );
  }

  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    if (await getCategoryById(categoryId) == null) return const [];
    return await (db.select(db.transactions)
          ..where(
            (transaction) =>
                transaction.categoryId.equals(categoryId) &
                transaction.deletedAt.isNull(),
          )
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// 查询指定账本内某分类的交易，并按时间或账本币金额排序。
  ///
  /// 金额排序使用 nativeAmount；限定 [ledgerId] 后所有比较值才具有相同单位。
  Future<List<Transaction>> getTransactionsByCategoryWithSort(
    String categoryId, {
    required String ledgerId,
    String sortBy = 'time',
    bool ascending = false,
  }) async {
    if (await getCategoryById(categoryId) == null) return const [];
    final query = db.select(db.transactions)
      ..where(
        (transaction) =>
            transaction.categoryId.equals(categoryId) &
            transaction.ledgerId.equals(ledgerId) &
            transaction.deletedAt.isNull(),
      );

    if (sortBy == 'amount') {
      query.orderBy([
        (t) => d.OrderingTerm(
          // 账本维度「金额排序」按折算值:多币种下 5000 JPY(≈250 CNY)不应
          // 因原币面值大而排在 300 CNY 之前(与年报 largest 比较同口径)。
          // 注:decimal 字符串的字典序排序在位数不同时不是数值序,精确数值序
          // 需在 Dart 层用 Decimal 比较。
          expression: d.coalesce([t.nativeAmount, t.amount]),
          mode: ascending ? d.OrderingMode.asc : d.OrderingMode.desc,
        ),
      ]);
    } else {
      query.orderBy([
        (t) => d.OrderingTerm(
          expression: t.happenedAt,
          mode: ascending ? d.OrderingMode.asc : d.OrderingMode.desc,
        ),
      ]);
    }

    return await query.get();
  }

  /// 迁移分类直属交易；同步 mutation 由 LocalRepository 在外层事务登记。
  Future<int> migrateCategory({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    final beforeCount = await getTransactionCountByCategory(fromCategoryId);

    // 只搬交易（分类行不动），推进 updatedAt 保持同步 LWW 有效；
    // LocalRepository 在同一外层事务中登记受影响交易的 upsert。
    await (db.update(db.transactions)..where(
          (t) => t.categoryId.equals(fromCategoryId) & t.deletedAt.isNull(),
        ))
        .write(
          TransactionsCompanion(
            categoryId: d.Value(toCategoryId),
            updatedAt: d.Value(DateTime.now().toUtc()),
          ),
        );

    return beforeCount;
  }

  /// 迁移分类树；同步 mutation 由 LocalRepository 在外层事务登记。
  Future<({int migratedTransactions, int migratedSubCategories})>
  migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    return await db.transaction(() async {
      final now = DateTime.now().toUtc();
      final fromCategory =
          await (db.select(db.categories)..where(
                (c) => c.id.equals(fromCategoryId) & c.deletedAt.isNull(),
              ))
              .getSingle();

      int migratedTransactions = 0;
      int migratedSubCategories = 0;

      if (fromCategory.level == 1) {
        // 一级分类：处理子分类
        final subCategories = await getSubCategories(fromCategoryId);

        if (subCategories.isNotEmpty) {
          for (final sub in subCategories) {
            // 检查目标分类是否已有同名子分类
            final existingSub =
                await (db.select(db.categories)..where(
                      (c) =>
                          c.parentId.equals(toCategoryId) &
                          c.name.equals(sub.name) &
                          c.kind.equals(sub.kind) &
                          c.deletedAt.isNull(),
                    ))
                    .getSingleOrNull();

            if (existingSub != null) {
              // 合并到已有的同名子分类:交易改挂 existingSub,源子分类删除。
              final count =
                  await (db.update(db.transactions)..where(
                        (t) =>
                            t.categoryId.equals(sub.id) & t.deletedAt.isNull(),
                      ))
                      .write(
                        TransactionsCompanion(
                          categoryId: d.Value(existingSub.id),
                          updatedAt: d.Value(now),
                        ),
                      );
              migratedTransactions += count;

              await (db.delete(
                db.categories,
              )..where((c) => c.id.equals(sub.id))).go();
              await _recordCategoryChange(
                entityId: sub.id,
                action: 'delete',
                payload: _categoryPayload(sub.copyWith(updatedAt: now)),
                updatedAt: now,
              );
            } else {
              // 将子分类移动到新的父分类下
              await (db.update(
                db.categories,
              )..where((c) => c.id.equals(sub.id))).write(
                CategoriesCompanion(
                  parentId: d.Value(toCategoryId),
                  updatedAt: d.Value(now),
                ),
              );
              await _recordCategoryChange(
                entityId: sub.id,
                action: 'upsert',
                payload: _categoryPayload(
                  sub.copyWith(parentId: d.Value(toCategoryId), updatedAt: now),
                ),
                updatedAt: now,
              );
              migratedSubCategories++;
            }
          }
        }

        // 迁移一级分类自身的交易
        final directCount =
            await (db.update(db.transactions)..where(
                  (t) =>
                      t.categoryId.equals(fromCategoryId) &
                      t.deletedAt.isNull(),
                ))
                .write(
                  TransactionsCompanion(
                    categoryId: d.Value(toCategoryId),
                    updatedAt: d.Value(now),
                  ),
                );
        migratedTransactions += directCount;
      } else {
        // 二级分类：直接迁移交易
        final count =
            await (db.update(db.transactions)..where(
                  (t) =>
                      t.categoryId.equals(fromCategoryId) &
                      t.deletedAt.isNull(),
                ))
                .write(
                  TransactionsCompanion(
                    categoryId: d.Value(toCategoryId),
                    updatedAt: d.Value(now),
                  ),
                );
        migratedTransactions = count;
      }

      return (
        migratedTransactions: migratedTransactions,
        migratedSubCategories: migratedSubCategories,
      );
    });
  }

  Future<({int transactionCount, bool canMigrate})> getCategoryMigrationInfo({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    final transactionCount = await getTransactionCountByCategory(
      fromCategoryId,
    );

    final targetCategory =
        await (db.select(db.categories)
              ..where((c) => c.id.equals(toCategoryId) & c.deletedAt.isNull()))
            .getSingleOrNull();

    final canMigrate =
        transactionCount > 0 &&
        targetCategory != null &&
        fromCategoryId != toCategoryId;

    return (transactionCount: transactionCount, canMigrate: canMigrate);
  }

  Future<void> updateCategorySortOrders(
    List<({String id, int sortOrder})> updates,
  ) async {
    await db.transaction(() async {
      final now = DateTime.now().toUtc();
      for (final update in updates) {
        await (db.update(
          db.categories,
        )..where((c) => c.id.equals(update.id))).write(
          CategoriesCompanion(
            sortOrder: d.Value(update.sortOrder),
            updatedAt: d.Value(now),
          ),
        );
        // 登记需要完整 payload,读回更新后的行再构造。
        final row =
            await (db.select(db.categories)
                  ..where((c) => c.id.equals(update.id) & c.deletedAt.isNull()))
                .getSingleOrNull();
        if (row != null) {
          await _recordCategoryChange(
            entityId: row.id,
            action: 'upsert',
            payload: _categoryPayload(row),
            updatedAt: now,
          );
        }
      }
    });
  }

  Future<String> getCategoryFullName(String categoryId) async {
    final category =
        await (db.select(db.categories)
              ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
            .getSingleOrNull();
    if (category == null) return '';

    if (category.level == 1 || category.parentId == null) {
      return category.name;
    }

    final parent =
        await (db.select(db.categories)..where(
              (c) => c.id.equals(category.parentId!) & c.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (parent == null) {
      // 父分类缺失时降级返回子分类名,避免直接抛 StateError。
      return category.name;
    }

    return '${parent.name} / ${category.name}';
  }

  /// 监听单个分类行变化。
  ///
  /// 分类主键即 UUID 且为 user-global：共享账本镜像
  /// （SharedLedgerCategories.categoryId）引用的是与主表相同的分类 UUID，
  /// 因此无论 Owner/Editor 视角都只需按主表 id 监听。
  /// [ledgerSyncId] 保留仅为兼容既有调用方签名，不参与查询。
  Stream<Category?> watchCategory(String categoryId, {String? ledgerSyncId}) {
    return (db.select(db.categories)
          ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Stream<List<Transaction>> watchTransactionsByCategory(
    String categoryId, {
    String? ledgerId,
    bool includeSubCategories = false,
  }) {
    if (includeSubCategories) {
      // 一级分类需含其所有二级分类交易：先查子分类 id 列表，
      // 再按 categoryId.isIn([自身, ...子分类]) 查询交易
      return _watchTxByCategoryWithSubs(categoryId, ledgerId);
    }
    final txQuery = db.select(db.transactions)
      ..where(
        (transaction) =>
            transaction.categoryId.equals(categoryId) &
            transaction.deletedAt.isNull(),
      );

    if (ledgerId != null) {
      txQuery.where((t) => t.ledgerId.equals(ledgerId));
    }

    txQuery.orderBy([
      (t) =>
          d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
    ]);
    // 左连接既让本地分类软删时流立即刷新，也保留 Editor 仅存在于共享镜像、
    // 本地主表没有同 UUID 分类的合法交易。
    final joined = txQuery.join([
      d.leftOuterJoin(
        db.categories,
        db.categories.id.equalsExp(db.transactions.categoryId),
      ),
    ])..where(db.categories.id.isNull() | db.categories.deletedAt.isNull());
    return joined.watch().map(
      (rows) => rows.map((row) => row.readTable(db.transactions)).toList(),
    );
  }

  /// 监听本地一级分类及其所有二级分类的交易。
  ///
  /// 设计意图：分类汇总页进入一级分类时，需展示该一级分类下全部交易（含
  /// 直接挂在一级分类上的 + 挂在二级分类上的）。每次 emit 先查子分类 id
  /// 列表（categories 表变化时重查），再用 `categoryId.isIn(ids)` 查交易，
  /// 监听 transactions + categories 表保证子分类增删后列表实时刷新。
  Stream<List<Transaction>> _watchTxByCategoryWithSubs(
    String categoryId,
    String? ledgerId,
  ) {
    final ctrl = StreamController<List<Transaction>>();
    StreamSubscription? sub;

    Future<void> emit() async {
      try {
        final root = await getCategoryById(categoryId);
        if (root == null) {
          if (!ctrl.isClosed) ctrl.add(const []);
          return;
        }
        // 查询该一级分类的所有活跃二级分类 id。
        final subCats =
            await (db.select(db.categories)..where(
                  (c) =>
                      c.parentId.equals(categoryId) &
                      c.level.equals(2) &
                      c.deletedAt.isNull(),
                ))
                .get();
        final ids = <String>[categoryId, ...subCats.map((c) => c.id)];

        final q = db.select(db.transactions)
          ..where(
            (transaction) =>
                transaction.categoryId.isIn(ids) &
                transaction.deletedAt.isNull(),
          )
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ]);
        if (ledgerId != null) {
          q.where((t) => t.ledgerId.equals(ledgerId));
        }
        final list = await q.get();
        if (!ctrl.isClosed) ctrl.add(list);
      } catch (error, stackTrace) {
        logger.error('LocalCategoryRepository', '监听分类交易失败', error, stackTrace);
        if (!ctrl.isClosed) ctrl.addError(error, stackTrace);
      }
    }

    ctrl.onListen = () {
      emit();
      // 监听 tx 表(交易增删改)+ categories 表(子分类增删，需重算 id 列表)
      sub = db
          .tableUpdates(
            d.TableUpdateQuery.onAllTables([db.transactions, db.categories]),
          )
          .listen((_) => emit());
    };
    ctrl.onCancel = () async {
      await sub?.cancel();
    };
    return ctrl.stream;
  }

  Stream<List<Category>> watchCategoryWithSubs(String categoryId) {
    return db
        .customSelect(
          '''
      SELECT * FROM categories
      WHERE (id = ? OR parent_id = ?)
        AND deleted_at IS NULL
        AND EXISTS (
          SELECT 1 FROM categories root
          WHERE root.id = ? AND root.deleted_at IS NULL
        )
      ORDER BY level, sort_order
      ''',
          variables: [
            d.Variable.withString(categoryId),
            d.Variable.withString(categoryId),
            d.Variable.withString(categoryId),
          ],
          readsFrom: {db.categories},
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            return Category(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              kind: row.read<String>('kind'),
              icon: row.read<String?>('icon'),
              sortOrder: row.read<int>('sort_order'),
              parentId: row.read<String?>('parent_id'),
              level: row.read<int>('level'),
              updatedAt: row.read<DateTime>('updated_at'),
            );
          }).toList();
        });
  }

  Stream<List<({Category category, int transactionCount})>>
  watchCategoriesWithCount() async* {
    await for (final rows
        in db
            .customSelect(
              '''
      SELECT
        c.id as category_id,
        c.name as category_name,
        c.kind as category_kind,
        c.icon as category_icon,
        c.sort_order as category_sort_order,
        c.parent_id as category_parent_id,
        c.level as category_level,
        c.updated_at as category_updated_at,
        COUNT(t.id) as direct_count,
        (
          SELECT COUNT(t2.id)
          FROM transactions t2
          JOIN categories child ON child.id = t2.category_id
          WHERE child.parent_id = c.id
            AND child.deleted_at IS NULL
            AND t2.deleted_at IS NULL
        ) as child_count
      FROM categories c
      LEFT JOIN transactions t
        ON t.category_id = c.id AND t.deleted_at IS NULL
      WHERE c.kind != 'transfer'
        AND c.deleted_at IS NULL
      GROUP BY c.id, c.name, c.kind, c.icon, c.sort_order, c.parent_id, c.level, c.updated_at
      ORDER BY c.sort_order
      ''',
              readsFrom: {db.categories, db.transactions},
            )
            .watch()) {
      yield [
        for (final row in rows)
          (
            category: Category(
              id: row.read<String>('category_id'),
              name: row.read<String>('category_name'),
              kind: row.read<String>('category_kind'),
              icon: row.read<String?>('category_icon'),
              sortOrder: row.read<int>('category_sort_order'),
              parentId: row.read<String?>('category_parent_id'),
              level: row.read<int>('category_level'),
              updatedAt: row.read<DateTime>('category_updated_at'),
            ),
            transactionCount:
                row.read<int>('direct_count') + row.read<int>('child_count'),
          ),
      ];
    }
  }

  Future<List<Category>> getAllCategories() async {
    return await (db.select(db.categories)
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
        .get();
  }

  Future<List<Category>> getAllCategoriesIncludingShared() async {
    final result = [...await getAllCategories()];
    // 并入 SharedLedgerCategories 的镜像分类(按 categoryId 去重):schema v1
    // 下镜像行 categoryId 即 Owner 的分类 UUID,与主表共用同一 id,无需再
    // 合成负数 synthetic id。供跨账本列表按 categoryId 映射。
    final seen = <String>{for (final c in result) c.id};
    final tombstonedIds = await _tombstonedCategoryIds();
    final shared = await db.select(db.sharedLedgerCategories).get();
    for (final s in shared) {
      if (tombstonedIds.contains(s.categoryId)) continue;
      if (!seen.add(s.categoryId)) continue;
      result.add(
        Category(
          id: s.categoryId,
          name: s.name,
          kind: s.kind,
          icon: s.icon,
          sortOrder: s.sortOrder,
          parentId: s.parentId,
          level: s.level,
          updatedAt: s.updatedAt,
        ),
      );
    }
    return result;
  }

  Future<void> batchInsertCategories(
    List<CategoriesCompanion> categories,
  ) async {
    if (categories.isEmpty) return;
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(db.categories, categories);
      });
      // 登记 category:upsert 变更:批量插入(配置恢复/导入)后读回刚插入的
      // 行构造完整 payload,保证恢复的分类也能同步到云端。
      final ids = <String>[
        for (final c in categories)
          if (c.id.present) c.id.value,
      ];
      if (ids.isEmpty) return;
      final rows = await (db.select(
        db.categories,
      )..where((c) => c.id.isIn(ids))).get();
      for (final row in rows) {
        await _recordCategoryChange(
          entityId: row.id,
          action: 'upsert',
          payload: _categoryPayload(row),
          updatedAt: row.updatedAt,
        );
      }
    });
  }

  /// 单条插入原始 companion（低层 API，调用方自备 id/updatedAt）。
  ///
  /// 返回插入行的 UUID id（UUID 主键表 insert 要求 caller 必须提供 id，
  /// 插入成功即证明 id 存在）。变更登记不在此处做:调用方走
  /// [batchInsertCategories] 或业务方法（createCategory/upsertCategory）
  /// 时已统一登记,避免重复。
  Future<String> insertCategory(CategoriesCompanion category) async {
    await db.into(db.categories).insert(category);
    return category.id.value;
  }
}
