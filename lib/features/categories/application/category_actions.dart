/// 分类用例编排：UI 与仓储之间的唯一入口。
///
/// 分类删除、迁移和排序在应用层编排事务与同步登记，页面负责交互和结果刷新。
library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/published_ledger_queries.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';

import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';

/// 已打开的分类页面只接受发起账号的编辑，切号后需要重新建立页面上下文。
class CategorySessionChangedException implements Exception {
  /// 提供固定且可直接展示的会话失效说明。
  const CategorySessionChangedException();

  /// 不包含账号资料、用户分类正文或底层异常文本。
  @override
  String toString() => '账号已变化，请重新打开分类页面后操作。';
}

/// 别人的私有分类和共享账本镜像不能作为当前账号的管理对象。
class CategoryOwnershipException implements Exception {
  /// 保留固定的可展示说明，避免暴露底层数据。
  const CategoryOwnershipException();

  /// 提示从本人分类目录重新选择管理对象。
  @override
  String toString() => '此分类不属于当前账号，请从自己的分类目录重新选择。';
}

/// 只展示已知固定的会话及归属提示，其他异常继续采用页面通用文案。
String categoryActionErrorMessage(Object error, String fallback) {
  if (error is DataMutationPausedException) return error.userMessage;
  if (error is CategorySessionChangedException ||
      error is CategoryOwnershipException ||
      error is CategoryReviewChangedException ||
      error is CategoryMigrationTargetException) {
    return error.toString();
  }
  if (error is StateError && error.message == categoryOwnerUnconfirmedMessage) {
    return categoryOwnerUnconfirmedMessage;
  }
  return fallback;
}

/// 分类用例编排。
class CategoryActions {
  /// 用例对象固定所属账号与身份代次，旧页面不能借新仓储写入另一个账号。
  CategoryActions(this.ref)
    : _account = ref.read(currentAccountIdProvider),
      _generation = ref.read(authIdentityGenerationProvider);

  /// 每次用例通过 Ref 读取当前仓储和同步协调器，使用最新会话依赖。
  final Ref ref;
  final String? _account;
  final int _generation;

  /// 仓储只在原会话仍有效时提供给调用方。
  CategoryRepository get _repo {
    _requireSession();
    return ref.read(categoryDataAccessProvider);
  }

  /// 查询直接读取同一数据库中的分类仓储，并保持页面发起会话约束。
  CategoryQueryRepository get _queries {
    _requireSession();
    return ref.read(categoryQueriesProvider);
  }

  /// 令牌刷新不改变身份，退出、切号和重新登录会令旧编辑上下文失效。
  void _requireSession() {
    if (!ref.mounted ||
        ref.read(currentAccountIdProvider) != _account ||
        ref.read(authIdentityGenerationProvider) != _generation) {
      throw const CategorySessionChangedException();
    }
  }

  /// 表单的已有分类及父级快照必须与发起账号共同组成完整身份。
  void requireCategoryContext(CategoryDisplay? category) {
    _requireSession();
    if (category != null && category.scopeAccountId != _account) {
      throw const CategoryOwnershipException();
    }
  }

  /// 显式账本中的本地类别使用本地域，云类别仍须属于当前账号且拥有管理权限。
  Future<void> requireCategoryContextForLedger(
    CategoryDisplay? category, {
    String? ledgerId,
  }) async {
    try {
      _requireSession();
      if (ledgerId == null) {
        requireCategoryContext(category);
        return;
      }
      final ledger = await ref
          .read(ledgerDataAccessProvider)
          .getLedgerById(ledgerId);
      _requireSession();
      if (ledger == null ||
          ledger.deletedAt != null ||
          (ledger.storageMode == 'cloud' &&
              (_account == null ||
                  ledger.scopeAccountId != _account ||
                  ledger.ownerAccountId != _account))) {
        throw const CategoryOwnershipException();
      }
      final targetScope = categoryScopeForLedger(ledger);
      if ((ledger.storageMode == 'cloud' && targetScope != _account) ||
          (category != null && category.scopeAccountId != targetScope)) {
        throw const CategoryOwnershipException();
      }
    } catch (error, stack) {
      logger.error(
        'CategoryActions',
        '分类账本上下文校验失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 分类摘要只返回已发布且属于同一分类目录的账本标识，查询期间保持原会话。
  Future<String?> getCategoryDetailsLedgerId(
    CategoryDisplay? category, {
    String? ledgerId,
  }) async {
    try {
      await requireCategoryContextForLedger(category, ledgerId: ledgerId);
      if (category == null) return null;
      final targetId = ledgerId ?? ref.read(currentLedgerIdProvider);
      if (targetId == null || targetId.isEmpty) return null;
      final ledger = await readPublishedLedger(ref.read, targetId);
      _requireSession();
      // 本地类别只能查看本地域；云类别只能查看其所有者的私有账本。
      if (ledger == null ||
          categoryScopeForLedger(ledger) != category.scopeAccountId ||
          (ledger.storageMode == 'cloud' &&
              ledger.ownerAccountId != category.scopeAccountId)) {
        return null;
      }
      return ledger.id;
    } catch (error, stack) {
      logger.error(
        'CategoryActions',
        '读取分类摘要账本失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 查询跨异步边界仍绑定原页面的账号。
  Future<T> _read<T>(Future<T> Function(CategoryQueryRepository) action) async {
    try {
      final value = await action(_queries);
      _requireSession();
      return value;
    } catch (error, stack) {
      logger.error(
        'CategoryActions',
        '分类查询未完成',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 所有分类写入共用串行闸门与原会话事务，任一身份变化回滚全部步骤。
  Future<T> _mutation<T>(Future<T> Function(CategoryRepository) action) async {
    try {
      _requireSession();
      return await ref
          .read(syncCoordinatorProvider)
          .runDataMutation(
            () => _repo.runInTransaction(() async {
              final value = await action(_repo);
              _requireSession();
              return value;
            }),
          );
    } catch (error, stack) {
      logger.error(
        'CategoryActions',
        '分类修改未提交',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  // ==================== 查询 ====================

  /// 按 id 取分类；分类已删除时返回 null。
  Future<CategoryDisplay?> getById(String id, {String? ledgerId}) => _read(
    (repo) async =>
        (await repo.getCategoryById(id, ledgerId: ledgerId))?.toDisplay(),
  );

  /// 取指定 kind 的一级分类。
  Future<List<CategoryDisplay>> getTopLevel(String kind, {String? ledgerId}) =>
      _read(
        (repo) async =>
            (ledgerId == null
                    ? await repo.getTopLevelCategories(kind)
                    : (await repo.getAllCategories(ledgerId: ledgerId)).where(
                        (c) =>
                            c.kind == kind &&
                            c.level == 1 &&
                            c.parentId == null,
                      ))
                .map((row) => row.toDisplay())
                .toList(growable: false),
      );

  /// 取某分类的直接子分类。
  Future<List<CategoryDisplay>> getSubCategories(
    String parentId, {
    String? ledgerId,
  }) => _read(
    (repo) async =>
        (ledgerId == null
                ? await repo.getSubCategories(parentId)
                : (await repo.getAllCategories(
                    ledgerId: ledgerId,
                  )).where((c) => c.parentId == parentId && c.level == 2))
            .map((row) => row.toDisplay())
            .toList(growable: false),
  );

  /// 该分类是否已有子分类。
  Future<bool> hasSubCategories(String categoryId, {String? ledgerId}) => _read(
    (repo) async => ledgerId == null
        ? await repo.hasSubCategories(categoryId)
        : (await repo.getAllCategories(
            ledgerId: ledgerId,
          )).any((c) => c.parentId == categoryId && c.level == 2),
  );

  /// 该分类下的交易笔数。
  Future<int> countTransactions(String categoryId, {String? ledgerId}) => _read(
    (repo) =>
        repo.getTransactionCountByCategory(categoryId, ledgerId: ledgerId),
  );

  /// 作用域判重：二级分类只与同一父级下的兄弟比，一级分类只与其他一级比，
  /// 跨父级允许同名（默认种子数据即有「购物>鞋子」「服装>鞋子」）。
  Future<bool> isNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
    String? ledgerId,
  }) => _read(
    (repo) => repo.isCategoryNameDuplicate(
      name: name,
      kind: kind,
      excludeId: excludeId,
      parentId: parentId,
      ledgerId: ledgerId,
    ),
  );

  /// 周期账单分类选择：固定支出类型，且允许挂到二级分类
  /// （topLevelOnly=false，父分类带子分类时父分类自身仍可选）。
  Future<List<CategoryDisplay>> filterForRecurringPicker({String? ledgerId}) =>
      filterForPicker(ledgerId: ledgerId, kind: 'expense', topLevelOnly: false);

  /// 按账本上下文过滤可选分类：共享账本 Editor 视角替换为镜像表内容。
  Future<List<CategoryDisplay>> filterForPicker({
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  }) => _read(
    (repo) async => (await repo.filterCategoriesForLedgerPicker(
      await repo.getAllCategories(ledgerId: ledgerId),
      ledgerId: ledgerId,
      kind: kind,
      topLevelOnly: topLevelOnly,
    )).map((row) => row.toDisplay()).toList(growable: false),
  );

  // ==================== 用例 ====================

  /// 新建一级分类，返回新分类 id。
  Future<String> create({
    required String name,
    required String kind,
    String? icon,
    String? ledgerId,
  }) => _mutation(
    (repo) => repo.createCategory(
      name: name,
      kind: kind,
      icon: icon,
      ledgerId: ledgerId,
    ),
  );

  /// 新建二级分类，返回新分类 id。
  Future<String> createSub({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    String? ledgerId,
  }) => _mutation(
    (repo) => repo.createSubCategory(
      parentId: parentId,
      name: name,
      kind: kind,
      icon: icon,
      ledgerId: ledgerId,
    ),
  );

  /// 更新分类；[parentId] 传空串表示清空父分类（二级降为一级）。
  Future<void> update(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
    String? ledgerId,
  }) => _mutation(
    (repo) => repo.updateCategory(
      id,
      name: name,
      icon: icon,
      parentId: parentId,
      level: level,
      ledgerId: ledgerId,
    ),
  );

  /// 拖拽排序：批量写回 sortOrder（排序变更已随写入登记云端变更）。
  Future<void> reorder(List<({String id, int sortOrder})> updates) =>
      _mutation((repo) => repo.updateCategorySortOrders(updates));

  /// 清空未使用分类：未使用分类名下没有交易，直接删除即可。
  Future<void> delete(List<String> ids) =>
      _mutation((repo) => repo.deleteCategoriesByIds(ids));

  /// 策略 0：删除分类及其下全部数据（含二级分类与其交易）。
  ///
  /// [subCategoryIds] 为待删一级分类的二级分类 id，其交易同样清空；
  /// 删除二级分类时留空即可。
  Future<void> deleteCascade(
    List<String> ids, {
    List<String> subCategoryIds = const [],
  }) => _mutation((repo) async {
    final currentChildren = <String>{};
    for (final id in ids) {
      currentChildren.addAll(
        (await _queries.getSubCategories(id)).map((c) => c.id),
      );
    }
    final confirmedChildren = subCategoryIds.toSet();
    // 只删除用户确认的分类集合；等待期间树成员变化则需要重新确认。
    if (currentChildren.length != confirmedChildren.length ||
        !currentChildren.containsAll(confirmedChildren)) {
      throw const CategoryReviewChangedException();
    }
    await repo.deleteTransactionsByCategoryIds([...ids, ...subCategoryIds]);
    await repo.deleteCategoriesByIds(ids);
  });

  /// 策略 2：删除一级分类，其二级分类提升为一级后保留。
  Future<void> deletePromotingChildren(List<String> ids) =>
      _mutation((repo) async {
        await repo.deleteTransactionsByCategoryIds(ids);
        for (final id in ids) {
          await repo.promoteSubCategoriesToTopLevel(id);
        }
        await repo.deleteCategoriesByIds(ids);
      });

  /// 策略 1：把源分类（含其二级分类）的全部交易统一迁移到目标分类，
  /// 再删除源分类及其子分类（子分类本身不随迁）。
  Future<void> migrateAndDelete(List<String> ids, String targetId) =>
      _mutation((repo) async {
        if (ids.contains(targetId)) {
          throw const CategoryMigrationTargetException();
        }
        for (final id in ids) {
          await repo.migrateCategoryTransactions(
            fromCategoryId: id,
            toCategoryId: targetId,
          );
        }
        // deleteCategoriesByIds 级联删除源分类的子分类（其交易已全部迁出）
        await repo.deleteCategoriesByIds(ids);
      });
}

/// 分类用例编排 provider。
final categoryActionsProvider = Provider<CategoryActions>((ref) {
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  return CategoryActions(ref);
});
