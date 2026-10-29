import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart'
    show CategoryCreateDraft, CategoryParentUnavailableException;
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/support/category_row_tree.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/models/expense_type.dart';
import 'package:sesame_notes/data/repositories/support/category_field_validation.dart';
import 'package:sesame_notes/data/repositories/support/category_hierarchy.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';
import 'package:sesame_notes/data/repositories/support/shared_ledger_picker_filter.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 构造契约形状的 category 同步载荷（规范化 snake_case，完整实体 JSON）。
///
/// - 本地 level 使用生成枚举的字符串名称，HTTP 序列化器将其输出为整数；
/// - 正文保留分类修改时间用于本地读取，同步包络以队列的毫秒时钟为准。
String categorySyncPayload(Category c) {
  validateCategoryFields(icon: c.icon, sortOrder: c.sortOrder);
  return jsonEncode({
    'id': c.id,
    'name': c.name,
    'kind': c.kind,
    'level': c.level.toString(),
    'sort_order': c.sortOrder,
    'icon': c.icon,
    'parent_id': c.parentId,
    'updated_at': c.updatedAt.toUtc().toIso8601String(),
    if (c.serverVersionToken != null) 'base_token': c.serverVersionToken,
  });
}

/// 本地分类仓储按账号或纯本地域保存独立的分类目录与同步意图。
///
/// 设计意图：
/// - 分类身份由 UUID 与所属账号域共同决定，确定性默认 UUID 在不同域独立存在；
/// - 所有写操作与 recordUserGlobalChange 变更登记放同一事务：登记失败时
///   回滚写库，避免「本地已生效但云端永远不知道」的静默丢失。
class LocalCategoryRepository implements CategoryQueryRepository {
  static const _uuid = Uuid();
  final SesameDatabase db;

  /// 变更登记器的惰性获取函数（见 support/change_recorder.dart）。
  ///
  /// 用 getter 而不是直接持有实例：changeTracker 挂在外层 LocalRepository
  /// 上且可能在运行期被替换（登录/登出时重建），每次取值都拿最新引用。
  final ChangeRecorder? Function()? trackerGetter;

  /// 当前云账号，用于让产生同步 mutation 的分类进入同一账号数据域。
  final String? Function()? accountIdGetter;

  /// 显式域只用于已验证的账本上下文，空串对应纯本地域。
  final String? categoryScopeId;

  /// 注入会话身份和变更登记器，账本操作可以指定独立的分类域。
  LocalCategoryRepository(
    this.db, {
    this.trackerGetter,
    this.accountIdGetter,
    this.categoryScopeId,
  });

  /// 分类管理使用当前账号，纯本地账本使用自己的本地域。
  String? get _scope {
    final account = accountIdGetter?.call();
    if (categoryScopeId == null) return account;
    if (categoryScopeId!.isEmpty) return null;
    if (categoryScopeId != account) throw StateError('分类不属于当前账号');
    return categoryScopeId;
  }

  /// 所有主表查询从同一个精确域谓词开始，后续条件不能混入其他账号。
  d.SimpleSelectStatement<Categories, Category> _categories() =>
      db.select(db.categories)..where((c) => categoryScopePredicate(c, _scope));

  /// 分类修改始终限定当前目录，不依赖 UUID 的全局唯一性。
  d.UpdateStatement<Categories, Category> _updateCategories() =>
      db.update(db.categories)..where((c) => categoryScopePredicate(c, _scope));

  /// 关联记账操作只覆盖使用同一分类目录的本人账本。
  d.Expression<bool> _transactionScope(Transactions row) =>
      row.ledgerId.isInQuery(
        db.selectOnly(db.ledgers)
          ..addColumns([db.ledgers.id])
          ..where(categoryLedgerPredicate(db.ledgers, _scope)),
      );

  /// 分类统计与迁移只查询使用当前分类域的本人交易。
  d.SimpleSelectStatement<Transactions, Transaction> _transactions() =>
      db.select(db.transactions)..where(_transactionScope);

  /// 修改分类引用时保持其他账号及纯本地副本的交易独立。
  d.UpdateStatement<Transactions, Transaction> _updateTransactions() =>
      db.update(db.transactions)..where(_transactionScope);

  /// 删除分类对应交易时不按裸 UUID 扩大到其他分类域。
  d.DeleteStatement<Transactions, Transaction> _deleteTransactions() =>
      db.delete(db.transactions)..where(_transactionScope);

  /// 查询返回前复核发起会话，过期异步响应不会被新的账号消费。
  Future<T> _readScoped<T>(Future<T> Function() query) async {
    final session = accountIdGetter?.call();
    try {
      final value = await query();
      if (accountIdGetter?.call() != session) {
        throw StateError('账号已变化，请重新打开分类页面');
      }
      return value;
    } catch (error, stack) {
      logger.error(
        'LocalCategoryRepository',
        '读取分类目录失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 跨 await 的写入复核发起会话，切换账号时整次修改回滚。
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    final session = accountIdGetter?.call();
    try {
      return await db.transaction(() async {
        if (accountIdGetter?.call() != session) {
          throw StateError('账号已变化，请重新打开分类页面');
        }
        final result = await action();
        if (accountIdGetter?.call() != session) {
          throw StateError('账号已变化，请重新打开分类页面');
        }
        return result;
      });
    } catch (error, stack) {
      logger.error(
        'LocalCategoryRepository',
        '分类修改未提交',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 验证账本可见性和写权限后建立相同会话下的精确分类域仓储。
  Future<LocalCategoryRepository> _forEditableLedger(String ledgerId) async {
    final session = accountIdGetter?.call();
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
    if (accountIdGetter?.call() != session) throw StateError('账号已变化，请重新操作');
    if (ledger == null ||
        ledger.deletedAt != null ||
        (ledger.storageMode == 'cloud' &&
            (session == null || ledger.scopeAccountId != session))) {
      throw StateError('账本不存在或不属于当前账号');
    }
    if (ledger.storageMode == 'cloud' && ledger.ownerAccountId != session) {
      throw StateError('共享账本的分类由账本所有者管理');
    }
    return LocalCategoryRepository(
      db,
      trackerGetter: trackerGetter,
      accountIdGetter: accountIdGetter,
      categoryScopeId: categoryScopeForLedger(ledger) ?? '',
    );
  }

  /// 按单个账本取得其独立目录；共享账本只使用该账本的所有者镜像。
  Future<List<Category>> _categoriesForLedger(String ledgerId) async {
    try {
      final session = accountIdGetter?.call();
      final ledger = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(ledgerId))).getSingle();
      if (accountIdGetter?.call() != session ||
          ledger.deletedAt != null ||
          (ledger.storageMode == 'cloud' &&
              (session == null || ledger.scopeAccountId != session))) {
        throw StateError('账本不存在或当前账号已变化');
      }
      final catalog = await readLedgerCategoryCatalog(db, ledgerId);
      if (accountIdGetter?.call() != session) throw StateError('账号已变化，请重新操作');
      return catalog.values.toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (error, stack) {
      logger.error(
        'LocalCategoryRepository',
        '读取账本分类失败: ledger=$ledgerId',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 父子关系必须形成当前目录中的合法两级树，不能引用另一账号的同名分类。
  Future<void> _validatePlacement({
    required String? id,
    required int level,
    required String? parentId,
  }) async {
    if (level != 1 && level != 2) throw StateError('分类层级无效');
    if (id != null && parentId == id) throw StateError('分类不能选择自身作为所属分类');
    if (level == 1 && parentId != null) throw StateError('父分类不能设置所属分类');
    if (level == 2 && parentId == null) throw StateError('子分类必须选择有效的父分类');
    if (parentId == null) return;
    final parent =
        await (_categories()..where(
              (c) =>
                  c.id.equals(parentId) &
                  c.deletedAt.isNull() &
                  c.level.equals(1) &
                  c.parentId.isNull(),
            ))
            .getSingleOrNull();
    if (parent == null) throw StateError('所属分类不存在或不属于当前分类目录');
    if (id != null && await hasSubCategories(id)) {
      throw StateError('分类仍有子分类，不能移入其他分类');
    }
  }

  /// 在原 LWW 规则内保留真实毫秒，并让同实体尚未确认的编辑严格前进。
  /// 只用于人工修改；种子初始化和确保注册沿用实体原时间。
  Future<DateTime> _nextEditTime(Category category) async {
    final accountId = _scope;
    final previous =
        await (db.select(db.syncChanges)
              ..where(
                (change) =>
                    change.entityType.equals('category') &
                    change.entityId.equals(category.id) &
                    change.pushedAt.isNull() &
                    (accountId == null
                        ? change.accountId.isNull()
                        : change.accountId.equals(accountId)),
              )
              ..orderBy([(change) => d.OrderingTerm.desc(change.id)])
              ..limit(1))
            .getSingleOrNull();
    var baseline = category.updatedAt.millisecondsSinceEpoch;
    if (previous != null) {
      final precise = previous.updatedAt.millisecondsSinceEpoch;
      if (precise > baseline) baseline = precise;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
      now > baseline ? now : baseline + 1,
      isUtc: true,
    );
  }

  /// 登记一条 category user-global 变更（tracker 未注入时为 no-op）。
  Future<void> _recordCategoryChange({
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    final accountId = _scope;
    final tracker = trackerGetter?.call();
    // 纯本地域的分类没有云 mutation，账号目录的分类必须已经属于本账号。
    if (accountId == null || tracker == null) return;
    if (accountIdGetter?.call() != accountId) throw StateError('分类不属于当前账号');
    final row =
        await (_categories()..where((category) => category.id.equals(entityId)))
            .getSingleOrNull();
    if (row == null || row.scopeAccountId != accountId) {
      throw StateError('分类不存在或不属于当前账号');
    }
    await tracker.recordUserGlobalChange(
      entityType: 'category',
      entityId: entityId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
    );
  }

  /// 当前目录的墓碑身份用于过滤外部传入的旧分类快照。
  Future<Set<String>> _tombstonedCategoryIds() => _readScoped(() async {
    final rows =
        await (_categories()
              ..where((category) => category.deletedAt.isNotNull()))
            .get();
    return rows.map((category) => category.id).toSet();
  });

  /// 按一次操作冻结的 UUID 创建分类；父先子后，任何失败回滚整批写入及同步事件。
  Future<int> createCategoryBatch({
    required List<CategoryCreateDraft> items,
    String? ledgerId,
    bool recordChanges = true,
  }) => runInTransaction(() async {
    if (ledgerId != null) {
      return (await _forEditableLedger(
        ledgerId,
      )).createCategoryBatch(items: items, recordChanges: recordChanges);
    }
    final ids = <String>{};
    for (final item in items) {
      if (!Uuid.isValidUUID(fromString: item.id) || !ids.add(item.id)) {
        throw StateError('分类创建身份无效，请重新选择分类');
      }
      normalizeName(item.name);
      requireExpenseType(item.kind);
      validateCategoryFields(icon: item.icon, sortOrder: item.sortOrder);
    }
    final ordered = [...items]..sort((a, b) => a.level.compareTo(b.level));
    final catalog = await _categories().get();
    final existingIds = catalog.map((row) => row.id).toSet();
    final nextOrders = <String?, int>{};
    for (final row in catalog.where((row) => row.deletedAt == null)) {
      final next = row.sortOrder + 1;
      if (next > (nextOrders[row.parentId] ?? 0)) {
        nextOrders[row.parentId] = next;
      }
    }
    var created = 0;
    for (final item in ordered) {
      // 同一操作重试只认本域 UUID；已编辑或删除的记录不会被重放覆盖。
      if (existingIds.contains(item.id)) continue;
      if (item.level == 2 &&
          item.parentId != null &&
          !items.any(
            (parent) => parent.id == item.parentId && parent.level == 1,
          )) {
        final parent =
            await (_categories()..where(
                  (row) =>
                      row.id.equals(item.parentId!) &
                      row.deletedAt.isNull() &
                      row.level.equals(1) &
                      row.parentId.isNull(),
                ))
                .getSingleOrNull();
        if (parent == null) throw const CategoryParentUnavailableException();
      }
      await _validatePlacement(
        id: item.id,
        level: item.level,
        parentId: item.parentId,
      );
      final order = item.sortOrder ?? nextOrders[item.parentId] ?? 0;
      validateCategoryFields(icon: item.icon, sortOrder: order);
      nextOrders[item.parentId] = order + 1;
      final now = DateTime.now().toUtc();
      final row = Category(
        id: item.id,
        name: normalizeName(item.name),
        kind: item.kind,
        level: item.level,
        sortOrder: order,
        icon: item.icon,
        parentId: item.parentId,
        scopeAccountId: _scope,
        cloudRegistered: false,
        updatedAt: now,
      );
      await db.into(db.categories).insert(row.toCompanion(true));
      if (recordChanges) {
        await _recordCategoryChange(
          entityId: row.id,
          action: 'upsert',
          payload: categorySyncPayload(row),
          updatedAt: now,
        );
      }
      existingIds.add(row.id);
      created++;
    }
    return created;
  });

  /// 每次主动创建分配新身份；同名同图标分类也保持独立。
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int? level,
    String? parentId,
    bool recordChanges = true,
    String? ledgerId,
  }) => runInTransaction(() async {
    final expectedLevel = parentId == null ? 1 : 2;
    if (level != null && level != expectedLevel) {
      throw StateError('分类关系与层级不一致');
    }
    final id = _uuid.v4();
    await createCategoryBatch(
      items: [
        CategoryCreateDraft(
          id: id,
          name: name,
          kind: kind,
          parentId: parentId,
          icon: icon,
          sortOrder: sortOrder,
        ),
      ],
      ledgerId: ledgerId,
      recordChanges: recordChanges,
    );
    return id;
  });

  /// 在明确父身份下创建二级分类，父分类归属由批量写入入口验证。
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
    String? ledgerId,
  }) => createCategory(
    parentId: parentId,
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    level: 2,
    recordChanges: recordChanges,
    ledgerId: ledgerId,
  );

  /// 修改当前目录中的分类名称、图标和两级归属。
  Future<void> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
    String? ledgerId,
  }) async {
    if (ledgerId != null) {
      await runInTransaction(
        () async => (await _forEditableLedger(ledgerId)).updateCategory(
          id,
          name: name,
          icon: icon,
          parentId: parentId,
          level: level,
        ),
      );
      return;
    }
    if (name != null) name = normalizeName(name);
    // 全部字段均未变更时直接返回:避免空 UPDATE,也不产生无意义同步信号。
    final hasAnyChange =
        name != null || icon != null || parentId != null || level != null;
    if (!hasAnyChange) return;

    // 写库与变更登记同事务(与 createCategory 模式对称)。
    await runInTransaction(() async {
      final row =
          await (_categories()
                ..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
              .getSingleOrNull();
      // 分类不存在或已被删除即拒绝：静默跳过会让分类编辑页弹出"已更新"，
      // 而改名/改图标/改父级整条丢失，也不登记云端变更。
      if (row == null) {
        throw StateError('分类不存在或已删除，无法更新: $id');
      }
      final now = await _nextEditTime(row);
      final effectiveParent = parentId == null
          ? row.parentId
          : parentId.isEmpty
          ? null
          : parentId;
      final effectiveLevel = effectiveParent == null ? 1 : 2;
      if (level != null && level != effectiveLevel) {
        throw StateError('分类关系与层级不一致');
      }
      await _validatePlacement(
        id: id,
        level: effectiveLevel,
        parentId: effectiveParent,
      );
      validateCategoryFields(icon: icon);
      await (_updateCategories()..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          name: name != null ? d.Value(name) : const d.Value.absent(),
          icon: icon != null ? d.Value(icon) : const d.Value.absent(),
          // parentId: '' 表示清空父分类,其他非空值表示设置父分类,
          // null 表示不改动。
          parentId: parentId != null
              ? (parentId.isEmpty ? const d.Value(null) : d.Value(parentId))
              : const d.Value.absent(),
          level: d.Value(effectiveLevel),
          // updatedAt 是同步 LWW 依据,任何字段变更都要推进。
          updatedAt: d.Value(now),
        ),
      );
      // payload 以变更后的完整实体构造(契约:payload 为完整实体 JSON)。
      final updated = Category(
        id: row.id,
        name: name ?? row.name,
        kind: row.kind,
        level: effectiveLevel,
        sortOrder: row.sortOrder,
        icon: icon ?? row.icon,
        parentId: parentId != null
            ? (parentId.isEmpty ? null : parentId)
            : row.parentId,
        updatedAt: now,
        scopeAccountId: row.scopeAccountId,
        serverVersionToken: row.serverVersionToken,
        cloudRegistered: row.cloudRegistered,
      );
      await _recordCategoryChange(
        entityId: id,
        action: 'upsert',
        payload: categorySyncPayload(updated),
        updatedAt: now,
      );
    });
  }

  /// 删除当前目录中没有子级与交易引用的分类。
  Future<void> deleteCategory(String id) => runInTransaction(() async {
    await requireKnownCategoryLedgerOwners(db, _scope, [id]);
    // 直接删分类必须 fail-loud:有子分类或交易时静默删分类会让交易 category_id
    // 指向已删除行,统计里变成"未分类"。调用方应先显式编排删除交易/提升子分类。
    final hasSub =
        await (_categories()
              ..where((c) => c.parentId.equals(id) & c.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    final hasTx =
        await (_transactions()
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
    await runInTransaction(() async {
      final row =
          await (_categories()
                ..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) return;
      final now = await _nextEditTime(row);
      await _detachDeletedRecurringCategoryReferences([id]);
      await (_updateCategories()..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(deletedAt: d.Value(now), updatedAt: d.Value(now)),
      );
      await _recordCategoryChange(
        entityId: id,
        action: 'delete',
        payload: categorySyncPayload(row.copyWith(updatedAt: now)),
        updatedAt: now,
      );
    });
  });

  /// 按当前目录删除指定分类及其直接子级，保留其他域的同 UUID。
  Future<void> deleteCategoriesByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await runInTransaction(() async {
      // 预查 ids 自身及其子分类(删除语义:先删子分类再删自身),
      // 供删除后逐条登记 category:delete 变更。
      final rows =
          await (_categories()..where(
                (c) =>
                    (c.id.isIn(ids) | c.parentId.isIn(ids)) &
                    c.deletedAt.isNull(),
              ))
              .get();
      await requireKnownCategoryLedgerOwners(db, _scope, rows.map((c) => c.id));
      final referenced =
          await (_transactions()
                ..where(
                  (t) =>
                      t.categoryId.isIn(rows.map((c) => c.id)) &
                      t.deletedAt.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      // 最终按最新分类树检查引用，零计数快照过期时保留全部实体与同步意图。
      if (referenced != null) {
        throw const CategoryReviewChangedException();
      }
      await _detachDeletedRecurringCategoryReferences(
        rows.map((row) => row.id),
      );
      // 新请求按子级优先登记；已经冻结的旧请求仍原样重放。
      rows.sort(
        (a, b) =>
            (b.parentId == null ? 0 : 1).compareTo(a.parentId == null ? 0 : 1),
      );
      for (final row in rows) {
        final now = await _nextEditTime(row);
        await (_updateCategories()..where((c) => c.id.equals(row.id))).write(
          CategoriesCompanion(deletedAt: d.Value(now), updatedAt: d.Value(now)),
        );
        await _recordCategoryChange(
          entityId: row.id,
          action: 'delete',
          payload: categorySyncPayload(row.copyWith(updatedAt: now)),
          updatedAt: now,
        );
      }
    });
  }

  /// 删除分类前保护待确认的历史导入，并清理已删除周期发生的弱分类引用。
  Future<void> _detachDeletedRecurringCategoryReferences(
    Iterable<String> categoryIds,
  ) async {
    if (categoryIds.isEmpty) return;
    final ids = categoryIds.toList(growable: false);
    final ledgers = await (db.select(
      db.ledgers,
    )..where((l) => categoryLedgerPredicate(l, _scope))).get();
    final ledgerIds = ledgers.map((l) => l.id).toList();
    if (ledgerIds.isEmpty) return;
    final pending = await db
        .customSelect(
          '''
      WITH pending_history AS (
        SELECT COALESCE(json_extract(frozen_request, '\$.payload'), payload) AS payload
        FROM sync_changes
        WHERE entity_type = 'recurring_transaction' AND pushed_at IS NULL
          AND ledger_id IN (${List.filled(ledgerIds.length, '?').join(',')})
          AND COALESCE(account_id, '') = ?
      )
      SELECT 1 AS pending FROM pending_history c
      WHERE json_type(c.payload, '\$.initial_state') = 'object'
        AND (
          json_extract(c.payload, '\$.category_id') IN (${List.filled(ids.length, '?').join(',')})
          OR EXISTS (
            SELECT 1 FROM json_each(c.payload, '\$.initial_state.occurrences') occurrence
            WHERE json_extract(occurrence.value, '\$.payload.category_id')
              IN (${List.filled(ids.length, '?').join(',')})
          )
        )
      LIMIT 1
      ''',
          variables: [
            ...ledgerIds,
            _scope ?? '',
            ...ids,
            ...ids,
          ].map(d.Variable.withString).toList(),
          readsFrom: {db.syncChanges, db.ledgers},
        )
        .getSingleOrNull();
    if (pending != null) {
      throw StateError('周期历史尚未完成同步，请完成同步后再删除其引用分类');
    }
    await LocalRecurringTransactionRepository(
      db,
      trackerGetter: trackerGetter,
    ).clearCategoryReferences(ids, categoryScope: _scope);
    // 明确删除分类只清理周期墓碑的弱引用，不改金额、来源、删除状态或同步队列。
    await (_updateTransactions()..where(
          (row) =>
              row.categoryId.isIn(categoryIds) &
              row.deletedAt.isNotNull() &
              row.recurringId.isNotNull() &
              row.occurrenceDate.isNotNull(),
        ))
        .write(const TransactionsCompanion(categoryId: d.Value(null)));
  }

  /// 删除指定分类下的本地交易行。
  ///
  /// 业务层统一从 LocalRepository 调用，由外层复用交易仓储逐笔登记云端
  /// delete mutation；本方法保留给分类子仓储的数据操作测试。
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds) =>
      runInTransaction(() async {
        if (categoryIds.isEmpty) return 0;
        await requireKnownCategoryLedgerOwners(db, _scope, categoryIds);
        return await (_deleteTransactions()
              ..where((t) => t.categoryId.isIn(categoryIds)))
            .go();
      });

  /// 按原身份上提子分类，保留账单引用且允许目标目录存在同名分类。
  Future<int> promoteSubCategoriesToTopLevel(String parentId) async {
    return await runInTransaction(() async {
      // 获取所有需要提升的二级分类
      final subCategories = await getSubCategories(parentId);
      if (subCategories.isEmpty) return 0;
      await requireKnownCategoryLedgerOwners(db, _scope, [
        parentId,
        ...subCategories.map((c) => c.id),
      ]);

      // 查当前一级分类的最大 sortOrder，确保提升后的分类排在已有分类之后
      final topLevel =
          await (_categories()
                ..where((c) => c.parentId.isNull() & c.deletedAt.isNull())
                ..orderBy([
                  (c) => d.OrderingTerm(
                    expression: c.sortOrder,
                    mode: d.OrderingMode.desc,
                  ),
                ]))
              .get();
      // 从最大 sortOrder + 1 开始递增分配
      int nextSortOrder = topLevel.isEmpty ? 0 : topLevel.first.sortOrder + 1;

      int promoted = 0;
      for (final sub in subCategories) {
        final now = await _nextEditTime(sub);
        final assignedSortOrder = nextSortOrder++;
        await (_updateCategories()..where((c) => c.id.equals(sub.id))).write(
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
          payload: categorySyncPayload(
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

  /// UUID 必须在指定账本或当前账号目录中解析，不能回退到其他域。
  @override
  Future<Category?> getCategoryById(String categoryId, {String? ledgerId}) =>
      _readScoped(() async {
        if (ledgerId != null) {
          final categories = await _categoriesForLedger(ledgerId);
          return categories.where((c) => c.id == categoryId).firstOrNull;
        }
        return await (_categories()
              ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
            .getSingleOrNull();
      });

  /// 共享账本 picker 过滤：直接委托 SesameDatabase 扩展
  /// （SharedLedgerPickerFilter），扩展内部已按 ledger 角色分派：
  /// Editor + 共享账本 → SharedLedgerCategories 转 Category 返回；
  /// 单人账本 / Owner → 主表 raw 数据。此处只做透传。
  @override
  Future<List<CategorySnapshot>> filterCategoriesForLedgerPicker(
    List<CategorySnapshot> all, {
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  }) => _readScoped(() async {
    final ctx = await db.loadLedgerPickerContext(ledgerId);
    final source = ledgerId == null
        ? all.where((c) => c.scopeAccountId == _scope).toList()
        : await getAllCategories(ledgerId: ledgerId);
    final candidates = await db.filterCategoriesForLedger(
      source.where((category) => category.deletedAt == null).toList(),
      ctx,
      kind: kind,
      topLevelOnly: topLevelOnly,
    );
    // 指定账本的目录独立判定存活，其他账号的同 UUID 墓碑不能遮蔽共享分类。
    if (ledgerId != null) return candidates;
    final tombstonedIds = await _tombstonedCategoryIds();
    return candidates
        .where((category) => !tombstonedIds.contains(category.id))
        .toList();
  });

  /// 批量读取当前账号或指定账本的精确分类身份。
  @override
  Future<Map<String, Category>> getCategoriesByIds(
    Iterable<String> ids, {
    String? ledgerId,
  }) => _readScoped(() async {
    final idList = ids.toList();
    if (idList.isEmpty) return const {};
    if (ledgerId != null) {
      final categories = await _categoriesForLedger(ledgerId);
      final wanted = idList.toSet();
      return {
        for (final c in categories)
          if (wanted.contains(c.id)) c.id: c,
      };
    }
    // 批量查询避免 N+1：单次 SELECT ... WHERE id IN (...) 取回全部
    final rows =
        await (_categories()
              ..where((c) => c.id.isIn(idList) & c.deletedAt.isNull()))
            .get();
    return {for (final r in rows) r.id: r};
  });

  /// 读取当前目录内合法一级分类。
  @override
  Future<List<Category>> getTopLevelCategories(
    String kind, {
    String? ledgerId,
  }) => _readScoped(() async {
    if (ledgerId != null) {
      return (await getAllCategories(
        ledgerId: ledgerId,
      )).where((c) => c.kind == kind && c.parentId == null).toList();
    }
    return await (_categories()
          ..where(
            (c) =>
                c.kind.equals(kind) &
                c.parentId.isNull() &
                c.deletedAt.isNull(),
          )
          ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
        .get();
  });

  /// 读取当前目录中指定一级分类的直接子级。
  @override
  Future<List<Category>> getSubCategories(String parentId) =>
      _readScoped(() async {
        if (await getCategoryById(parentId) == null) return const [];
        return await (_categories()
              ..where((c) => c.parentId.equals(parentId) & c.deletedAt.isNull())
              ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
            .get();
      });

  /// 当前目录的合法叶子分类可以用于记账。
  @override
  Future<List<Category>> getUsableCategories(String kind) =>
      _readScoped(() async {
        final allCategories =
            await (_categories()
                  ..where((c) => c.kind.equals(kind) & c.deletedAt.isNull())
                  ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
                .get();
        return CategoryHierarchy.getUsableCategories(allCategories);
      });

  /// 只检测当前目录内的活跃子级。
  @override
  Future<bool> hasSubCategories(String categoryId) => _readScoped(() async {
    if (await getCategoryById(categoryId) == null) return false;
    return (await (_categories()
              ..where(
                (c) => c.parentId.equals(categoryId) & c.deletedAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull()) !=
        null;
  });

  /// 统计同分类域本人账本中的活跃交易。
  @override
  Future<int> getTransactionCountByCategory(
    String categoryId, {
    String? ledgerId,
  }) => _readScoped(() async {
    if (ledgerId == null) {
      await requireKnownCategoryLedgerOwners(db, _scope, [categoryId]);
    }
    if (await getCategoryById(categoryId, ledgerId: ledgerId) == null) return 0;
    final count = db.transactions.id.count();
    final query = db.selectOnly(db.transactions)
      ..addColumns([count])
      ..where(
        (ledgerId == null
                ? _transactionScope(db.transactions)
                : db.transactions.ledgerId.equals(ledgerId)) &
            db.transactions.categoryId.equals(categoryId) &
            db.transactions.deletedAt.isNull(),
      );
    return (await query.getSingle()).read(count) ?? 0;
  });

  /// 数据库按当前目录聚合直属交易数量，不跨域合并相同 UUID。
  Future<Map<String, int>> getAllCategoryTransactionCounts() =>
      _readScoped(() async {
        final categories =
            await (_categories()..where((c) => c.deletedAt.isNull())).get();
        await requireKnownCategoryLedgerOwners(
          db,
          _scope,
          categories.map((c) => c.id),
        );
        final count = db.transactions.id.count();
        final query =
            (_categories()..where((c) => c.deletedAt.isNull())).join([
                d.leftOuterJoin(
                  db.transactions,
                  db.transactions.categoryId.equalsExp(db.categories.id) &
                      db.transactions.deletedAt.isNull() &
                      _transactionScope(db.transactions),
                ),
              ])
              ..addColumns([count])
              ..groupBy([db.categories.id, db.categories.scopeAccountId]);
        return {
          for (final row in await query.get())
            row.readTable(db.categories).id: row.read(count) ?? 0,
        };
      });

  /// 迁移分类直属交易；同步 mutation 由 LocalRepository 在外层事务登记。
  Future<int> migrateCategory({
    required String fromCategoryId,
    required String toCategoryId,
  }) => runInTransaction(() async {
    if (fromCategoryId == toCategoryId) {
      throw const CategoryMigrationTargetException();
    }
    await requireKnownCategoryLedgerOwners(db, _scope, [
      fromCategoryId,
      toCategoryId,
    ]);
    if (await getCategoryById(fromCategoryId) == null ||
        await getCategoryById(toCategoryId) == null) {
      throw StateError('迁移分类不存在或不属于当前分类目录');
    }
    final beforeCount = await getTransactionCountByCategory(fromCategoryId);

    // 只搬交易（分类行不动），推进 updatedAt 保持同步 LWW 有效；
    // LocalRepository 在同一外层事务中登记受影响交易的 upsert。
    await (_updateTransactions()..where(
          (t) => t.categoryId.equals(fromCategoryId) & t.deletedAt.isNull(),
        ))
        .write(
          TransactionsCompanion(
            categoryId: d.Value(toCategoryId),
            updatedAt: d.Value(DateTime.now().toUtc()),
          ),
        );

    return beforeCount;
  });

  /// 迁移分类树下的全部交易到目标分类，返回迁移的交易数。
  ///
  /// 一级分类：连同其全部二级分类的交易一并改挂到 [toCategoryId]，
  /// 子分类本身不移动（调用方随后用 deleteCategoriesByIds 级联删除源分类
  /// 及其子分类）。二级分类：仅迁移自身交易。
  /// 同步 mutation 由 LocalRepository 在外层事务登记。
  Future<int> migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) async {
    return await runInTransaction(() async {
      final now = DateTime.now().toUtc();
      final fromCategory =
          await (_categories()..where(
                (c) => c.id.equals(fromCategoryId) & c.deletedAt.isNull(),
              ))
              .getSingle();
      if (await getCategoryById(toCategoryId) == null) {
        throw StateError('目标分类不存在或不属于当前分类目录');
      }

      // 汇总需要迁移交易的源分类 id：一级分类包含其全部二级分类
      final sourceIds = <String>[fromCategoryId];
      if (fromCategory.parentId == null) {
        final subCategories = await getSubCategories(fromCategoryId);
        sourceIds.addAll(subCategories.map((sub) => sub.id));
      }
      // 事务内读取最新树，避免旧选择器把刚迁入的子分类选为迁移后会被删除的目标。
      if (sourceIds.contains(toCategoryId)) {
        throw const CategoryMigrationTargetException();
      }
      await requireKnownCategoryLedgerOwners(db, _scope, [
        ...sourceIds,
        toCategoryId,
      ]);

      // 一次 UPDATE 把源分类（含二级）的全部交易统一改挂到目标分类
      return await (_updateTransactions()
            ..where((t) => t.categoryId.isIn(sourceIds) & t.deletedAt.isNull()))
          .write(
            TransactionsCompanion(
              categoryId: d.Value(toCategoryId),
              updatedAt: d.Value(now),
            ),
          );
    });
  }

  /// 在同目录事务内保存排序与原分类身份的同步意图。
  Future<void> updateCategorySortOrders(
    List<({String id, int sortOrder})> updates,
  ) async {
    await runInTransaction(() async {
      for (final update in updates) {
        validateCategoryFields(sortOrder: update.sortOrder);
        final before =
            await (_categories()..where(
                  (category) =>
                      category.id.equals(update.id) &
                      category.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (before == null) continue;
        final now = await _nextEditTime(before);
        await (_updateCategories()..where((c) => c.id.equals(update.id))).write(
          CategoriesCompanion(
            sortOrder: d.Value(update.sortOrder),
            updatedAt: d.Value(now),
          ),
        );
        // 登记需要完整 payload,读回更新后的行再构造。
        final row =
            await (_categories()
                  ..where((c) => c.id.equals(update.id) & c.deletedAt.isNull()))
                .getSingleOrNull();
        if (row != null) {
          await _recordCategoryChange(
            entityId: row.id,
            action: 'upsert',
            payload: categorySyncPayload(row.copyWith(updatedAt: now)),
            updatedAt: now,
          );
        }
      }
    });
  }

  /// 监听固定账本所有者的分类树，共享成员只读取该账本镜像。
  @override
  Stream<CategoryRowTree> watchCategoryPickerTree({
    required String ledgerId,
    required String kind,
  }) => _watchRead(
    () async {
      final ledger =
          await (db.select(db.ledgers)..where(
                (row) => row.id.equals(ledgerId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (ledger == null) {
        return const CategoryRowTree(topLevel: [], children: {});
      }
      final account = accountIdGetter?.call();
      if (ledger.storageMode == 'cloud' &&
          (account == null || ledger.scopeAccountId != account)) {
        throw StateError('账本不存在或不属于当前账号');
      }
      final categories = await readLedgerCategoryCatalog(db, ledgerId);
      final topLevel = <Category>[];
      final children = <String, List<Category>>{};
      for (final row in categories.values.where((row) => row.kind == kind)) {
        if (row.parentId == null) {
          topLevel.add(row);
        } else if (row.parentId != null) {
          (children[row.parentId!] ??= []).add(row);
        }
      }
      return CategoryRowTree(topLevel: topLevel, children: children);
    },
    updatesQuery: d.TableUpdateQuery.onAllTables([
      db.categories,
      db.sharedLedgerCategories,
      db.ledgers,
    ]),
  );

  /// 数据变化重新读取精确分类域，发起会话失效时不向新账号返回旧结果。
  Stream<T> _watchRead<T>(
    Future<T> Function() read, {
    d.TableUpdateQuery? updatesQuery,
  }) {
    final controller = StreamController<T>();
    final session = accountIdGetter?.call();
    StreamSubscription? updates;

    /// 单次读取在开始与返回边界均复核身份，保留实际错误堆栈。
    Future<void> emit() async {
      try {
        if (accountIdGetter?.call() != session) {
          throw StateError('账号已变化，请重新打开分类页面');
        }
        final result = await read();
        if (accountIdGetter?.call() != session) {
          throw StateError('账号已变化，请重新打开分类页面');
        }
        if (!controller.isClosed) controller.add(result);
      } catch (error, stack) {
        logger.error(
          'LocalCategoryRepository',
          '读取分类响应流失败',
          safeErrorSummary(error),
          stack,
        );
        if (!controller.isClosed) controller.addError(error, stack);
      }
    }

    controller.onListen = () {
      emit();
      updates = db
          .tableUpdates(
            updatesQuery ??
                d.TableUpdateQuery.onAllTables([
                  db.categories,
                  db.transactions,
                  db.ledgers,
                  db.sharedLedgerCategories,
                ]),
          )
          .listen((_) => emit());
    };
    controller.onCancel = () async => updates?.cancel();
    return controller.stream;
  }

  /// 分类交易按所属账本解析，缺省仅统计当前账号自己的分类目录。
  @override
  Stream<List<Transaction>> watchTransactionsByCategory(
    String categoryId, {
    String? ledgerId,
    bool includeSubCategories = false,
  }) => _watchRead(() async {
    final categories = await getAllCategories(ledgerId: ledgerId);
    if (!categories.any((c) => c.id == categoryId)) return <Transaction>[];
    final ids = <String>{
      categoryId,
      if (includeSubCategories)
        for (final c in categories)
          if (c.parentId == categoryId) c.id,
    };
    final query = ledgerId == null
        ? _transactions()
        : db.select(db.transactions);
    query.where((t) => t.categoryId.isIn(ids) & t.deletedAt.isNull());
    if (ledgerId != null) query.where((t) => t.ledgerId.equals(ledgerId));
    query.orderBy([(t) => d.OrderingTerm.desc(t.happenedAt)]);
    return query.get();
  });

  /// 当前目录中的根及其直接子分类，另一账号的同 UUID 不参与根存在性判断。
  @override
  Stream<List<Category>> watchCategoryWithSubs(
    String categoryId, {
    String? ledgerId,
  }) => _watchRead(() async {
    final categories = await getAllCategories(ledgerId: ledgerId);
    if (!categories.any((c) => c.id == categoryId)) return <Category>[];
    return categories
        .where((c) => c.id == categoryId || c.parentId == categoryId)
        .toList()
      ..sort((a, b) {
        final level = (a.parentId == null ? 0 : 1).compareTo(
          b.parentId == null ? 0 : 1,
        );
        return level == 0 ? a.sortOrder.compareTo(b.sortOrder) : level;
      });
  });

  /// 数据库按精确域聚合直属笔数，内存按同域父子树合计，避免跨账号同 UUID 混算。
  @override
  Stream<List<({Category category, int transactionCount})>>
  watchCategoriesWithCount() => _watchRead(() async {
    final categories = await getAllCategories();
    final counts = await getAllCategoryTransactionCounts();
    final childCounts = <String, int>{};
    for (final child in categories) {
      if (child.parentId != null) {
        childCounts.update(
          child.parentId!,
          (n) => n + (counts[child.id] ?? 0),
          ifAbsent: () => counts[child.id] ?? 0,
        );
      }
    }
    return [
      for (final c in categories)
        (
          category: c,
          transactionCount: (counts[c.id] ?? 0) + (childCounts[c.id] ?? 0),
        ),
    ];
  });

  /// 读取当前账号目录，传账本时精确解析本地、本人或共享镜像域。
  @override
  Future<List<Category>> getAllCategories({String? ledgerId}) =>
      _readScoped(() async {
        if (ledgerId != null) return _categoriesForLedger(ledgerId);
        return await (_categories()
              ..where((c) => c.deletedAt.isNull())
              ..orderBy([(c) => d.OrderingTerm(expression: c.sortOrder)]))
            .get();
      });

  /// 导出分类必须提供所属账本，缺省只返回当前账号自己的目录。
  @override
  Future<List<Category>> getAllCategoriesIncludingShared({String? ledgerId}) =>
      getAllCategories(ledgerId: ledgerId);

  /// 批量导入当前目录并按原实体身份登记同步意图。
  Future<void> batchInsertCategories(
    List<CategoriesCompanion> categories,
  ) async {
    if (categories.isEmpty) return;
    for (final category in categories) {
      requireExpenseType(category.kind.value);
      if (category.scopeAccountId.present &&
          category.scopeAccountId.value != _scope) {
        throw StateError('导入分类不属于当前分类目录');
      }
    }
    await runInTransaction(() async {
      for (final row in categories) {
        normalizeName(row.name.value);
        validateCategoryFields(
          icon: row.icon.present ? row.icon.value : null,
          sortOrder: row.sortOrder.present ? row.sortOrder.value : 0,
        );
      }
      await db.batch((batch) {
        batch.insertAll(db.categories, [
          for (final row in categories)
            row.copyWith(scopeAccountId: d.Value(_scope)),
        ]);
      });
      // 登记 category:upsert 变更:批量插入(配置恢复/导入)后读回刚插入的
      // 行构造完整 payload,保证恢复的分类也能同步到云端。
      final ids = <String>[
        for (final c in categories)
          if (c.id.present) c.id.value,
      ];
      if (ids.isEmpty) return;
      final rows = await (_categories()..where((c) => c.id.isIn(ids))).get();
      for (final row in rows) {
        await _validatePlacement(
          id: row.id,
          level: row.level,
          parentId: row.parentId,
        );
        await _recordCategoryChange(
          entityId: row.id,
          action: 'upsert',
          payload: categorySyncPayload(row),
          updatedAt: row.updatedAt,
        );
      }
    });
  }

  /// 单条插入原始 companion（低层 API，调用方自备 id/updatedAt）。
  ///
  /// 返回插入行的 UUID id（UUID 主键表 insert 要求 caller 必须提供 id，
  /// 插入成功即证明 id 存在）。变更登记不在此处做:调用方走
  /// [batchInsertCategories] 或业务方法（createCategory）
  /// 时已统一登记,避免重复。
  Future<String> insertCategory(CategoriesCompanion category) =>
      runInTransaction(() async {
        requireExpenseType(category.kind.value);
        if (category.scopeAccountId.present &&
            category.scopeAccountId.value != _scope) {
          throw StateError('分类不属于当前分类目录');
        }
        normalizeName(category.name.value);
        validateCategoryFields(
          icon: category.icon.present ? category.icon.value : null,
          sortOrder: category.sortOrder.present ? category.sortOrder.value : 0,
        );
        await _validatePlacement(
          id: category.id.value,
          level: category.level.present ? category.level.value : 1,
          parentId: category.parentId.present ? category.parentId.value : null,
        );
        await db
            .into(db.categories)
            .insert(category.copyWith(scopeAccountId: d.Value(_scope)));
        return category.id.value;
      });
}
