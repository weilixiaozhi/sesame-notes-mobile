/// 分类用例编排：UI 与仓储之间的唯一入口。
///
/// 设计意图：分类的删除 / 迁移 / 排序都是多步编排（删交易 → 删分类 → 登记
/// 云端变更 → 提升子分类），过去散落在页面里，既难测试也容易漏步骤。收敛到
/// 本类后，页面只负责交互与提示，数据编排留在 application 层；刷新策略仍由
/// 页面按原样触发，保证本次重构是纯搬迁、零行为变化。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 分类用例编排。
class CategoryActions {
  CategoryActions(this.ref);

  /// 持有 Ref 是为了与 [LedgerStorageActions] 保持一致的编排入口形态：
  /// 用例内部需要读取会话、失效缓存等 Provider 时无需再往 UI 冒泡。
  final Ref ref;

  LocalRepository get _repo => ref.read(repositoryProvider);

  // ==================== 查询 ====================

  /// 按 id 取分类；分类已删除时返回 null。
  Future<CategoryDisplay?> getById(String id) async =>
      (await _repo.getCategoryById(id))?.toDisplay();

  /// 取指定 kind 的一级分类。
  Future<List<CategoryDisplay>> getTopLevel(String kind) async =>
      (await _repo.getTopLevelCategories(
        kind,
      )).map((row) => row.toDisplay()).toList(growable: false);

  /// 取某分类的直接子分类。
  Future<List<CategoryDisplay>> getSubCategories(String parentId) async =>
      (await _repo.getSubCategories(
        parentId,
      )).map((row) => row.toDisplay()).toList(growable: false);

  /// 取全部分类（不含共享镜像）。
  Future<List<CategoryDisplay>> getAll() async =>
      (await _repo.getAllCategories())
          .map((row) => row.toDisplay())
          .toList(growable: false);

  /// 该分类是否已有子分类。
  Future<bool> hasSubCategories(String categoryId) =>
      _repo.hasSubCategories(categoryId);

  /// 该分类下的交易笔数。
  Future<int> countTransactions(String categoryId) =>
      _repo.getTransactionCountByCategory(categoryId);

  /// 作用域判重：二级分类只与同一父级下的兄弟比，一级分类只与其他一级比，
  /// 跨父级允许同名（默认种子数据即有「购物>鞋子」「服装>鞋子」）。
  Future<bool> isNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
  }) => _repo.isCategoryNameDuplicate(
    name: name,
    kind: kind,
    excludeId: excludeId,
    parentId: parentId,
  );

  /// 按账本上下文过滤可选分类：共享账本 Editor 视角替换为镜像表内容。
  Future<List<CategoryDisplay>> filterForPicker({
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  }) async => (await _repo.filterCategoriesForLedgerPicker(
    await _repo.getAllCategories(),
    ledgerId: ledgerId,
    kind: kind,
    topLevelOnly: topLevelOnly,
  )).map((row) => row.toDisplay()).toList(growable: false);

  /// 带分类的交易列表（分类选择器用其统计每个分类的笔数）。
  Future<List<({TransactionDisplay t, CategoryDisplay? category})>>
  transactionsWithCategory({String? ledgerId}) async =>
      (await _repo.transactionsWithCategoryAll(ledgerId: ledgerId))
          .map(
            (row) =>
                (t: row.t.toDisplay(), category: row.category?.toDisplay()),
          )
          .toList(growable: false);

  // ==================== 用例 ====================

  /// 新建一级分类，返回新分类 id。
  Future<String> create({
    required String name,
    required String kind,
    String? icon,
  }) => _repo.createCategory(name: name, kind: kind, icon: icon);

  /// 新建二级分类，返回新分类 id。
  Future<String> createSub({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
  }) => _repo.createSubCategory(
    parentId: parentId,
    name: name,
    kind: kind,
    icon: icon,
  );

  /// 更新分类；[parentId] 传空串表示清空父分类（二级降为一级）。
  Future<void> update(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
  }) => _repo.updateCategory(
    id,
    name: name,
    icon: icon,
    parentId: parentId,
    level: level,
  );

  /// 拖拽排序：批量写回 sortOrder（排序变更已随写入登记云端变更）。
  Future<void> reorder(List<({String id, int sortOrder})> updates) =>
      _repo.updateCategorySortOrders(updates);

  /// 清空未使用分类：未使用分类名下没有交易，直接删除即可。
  Future<void> delete(List<String> ids) => _repo.deleteCategoriesByIds(ids);

  /// 策略 0：删除分类及其下全部数据（含二级分类与其交易）。
  ///
  /// [subCategoryIds] 为待删一级分类的二级分类 id，其交易同样清空；
  /// 删除二级分类时留空即可。
  Future<void> deleteCascade(
    List<String> ids, {
    List<String> subCategoryIds = const [],
  }) async {
    await _repo.deleteTransactionsByCategoryIds([...ids, ...subCategoryIds]);
    await _repo.deleteCategoriesByIds(ids);
  }

  /// 策略 2：删除一级分类，其二级分类提升为一级后保留。
  Future<void> deletePromotingChildren(List<String> ids) async {
    await _repo.deleteTransactionsByCategoryIds(ids);
    for (final id in ids) {
      await _repo.promoteSubCategoriesToTopLevel(id);
    }
    await _repo.deleteCategoriesByIds(ids);
  }

  /// 策略 1：把源分类的交易与子分类迁移到目标分类，再删除源分类。
  Future<void> migrateAndDelete(List<String> ids, String targetId) async {
    for (final id in ids) {
      await _repo.migrateCategoryTransactions(
        fromCategoryId: id,
        toCategoryId: targetId,
      );
    }
    await _repo.deleteCategoriesByIds(ids);
  }
}

/// 分类用例编排 provider。
final categoryActionsProvider = Provider<CategoryActions>(
  (ref) => CategoryActions(ref),
);
