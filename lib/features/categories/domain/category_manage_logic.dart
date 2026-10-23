/// 分类管理页与子分类面板的删除 / 迁移 / 排序纯计算规则。
library;

import 'package:sesame_notes/data/models/category_display.dart';

/// 分类 + 交易笔数：分类管理页与子分类面板共用的展示单元。
///
/// 一级分类的笔数为「含全部子分类」的汇总口径。
typedef CategoryWithCount = ({CategoryDisplay category, int transactionCount});

/// 删除影响范围：选中分类，以及「含二级」策略下其全部直接子分类。
///
/// 返回顺序即展示顺序：逐个选中分类输出自身，紧随其后是缩进展示的子分类；
/// 提升策略（[option] == 2）保留子分类，因此不含子分类行。
List<({CategoryWithCount item, bool isChild})> buildDeleteImpactScope(
  List<CategoryWithCount> all,
  Set<String> selectedIds, {
  required bool includeParents,
  required int option,
}) {
  final scope = <({CategoryWithCount item, bool isChild})>[];
  for (final item in all) {
    if (!selectedIds.contains(item.category.id)) continue;
    scope.add((item: item, isChild: false));
    // 删除或迁移父分类都会移除其子分类；提升策略保留子分类。
    if (!includeParents || option == 2) continue;
    for (final child in all) {
      if (child.category.parentId == item.category.id) {
        scope.add((item: child, isChild: true));
      }
    }
  }
  return scope;
}

/// 单个分类的受影响笔数。
///
/// 一级分类的笔数已包含全部子分类，删除 / 迁移整棵树时直接取该值即可；
/// 提升策略只清理父分类的直接记录，需要扣减子分类笔数。
int affectedTransactionCount(
  CategoryWithCount item,
  List<CategoryWithCount> all, {
  required bool includeParents,
  required int option,
}) {
  if (!includeParents || option != 2) return item.transactionCount;
  final childrenCount = all
      .where((child) => child.category.parentId == item.category.id)
      .fold(0, (sum, child) => sum + child.transactionCount);
  return item.transactionCount - childrenCount;
}

/// 删除影响总计：只累计选中分类，子分类笔数已含在父分类内，不重复累计。
int totalAffectedTransactionCount(
  List<CategoryWithCount> all,
  Set<String> selectedIds, {
  required bool includeParents,
  required int option,
}) => all
    .where((item) => selectedIds.contains(item.category.id))
    .fold(
      0,
      (sum, item) =>
          sum +
          affectedTransactionCount(
            item,
            all,
            includeParents: includeParents,
            option: option,
          ),
    );

/// 迁移目标候选：排除选中分类本身。
///
/// [excludeChildrenOfSelected] 为 true（管理页删除父分类整棵树）时，
/// 一并排除选中父分类下的子分类；子分类面板只删选中项本身，传 false。
List<CategoryWithCount> selectMigrateTargets(
  List<CategoryWithCount> all,
  Set<String> selectedIds, {
  required bool excludeChildrenOfSelected,
}) => [
  for (final item in all)
    if (!selectedIds.contains(item.category.id) &&
        !(excludeChildrenOfSelected &&
            item.category.parentId != null &&
            selectedIds.contains(item.category.parentId)))
      item,
];

/// 清理未使用分类：交易笔数为 0 的分类（父分类笔数已含子分类）。
List<CategoryWithCount> selectUnusedCategories(List<CategoryWithCount> all) => [
  for (final item in all)
    if (item.transactionCount == 0) item,
];

/// 待删一级分类的全部二级分类 id（策略 A 需要连子分类的交易一起清空）。
List<String> collectSubCategoryIds(
  List<CategoryWithCount> all,
  List<String> selectedIds,
) {
  final ids = <String>[];
  for (final id in selectedIds) {
    ids.addAll(
      all
          .where((item) => item.category.parentId == id)
          .map((item) => item.category.id),
    );
  }
  return ids;
}

/// 子分类面板的父分类笔数：直属笔数 = 总笔数 - 子分类笔数（不为负）。
///
/// [parent] 不在 [all] 中时，视为「总笔数 == 子分类汇总」，直属笔数为 0。
({int directCount, int totalCount}) parentTransactionBreakdown(
  List<CategoryWithCount> all,
  CategoryDisplay parent,
) {
  final childrenCount = all
      .where((item) => item.category.parentId == parent.id)
      .fold<int>(0, (sum, item) => sum + item.transactionCount);
  final totalCount = all
      .firstWhere(
        (item) => item.category.id == parent.id,
        orElse: () => (category: parent, transactionCount: childrenCount),
      )
      .transactionCount;
  return (
    directCount: (totalCount - childrenCount).clamp(0, totalCount),
    totalCount: totalCount,
  );
}

/// 拖动排序：把 [oldIndex] 处元素移动到 [newIndex]。
///
/// reorderable_grid_view 的 newIndex 为「直接插入位置」，无需做减 1 修正。
List<CategoryWithCount> applyReorder(
  List<CategoryWithCount> ordered,
  int oldIndex,
  int newIndex,
) {
  final next = List<CategoryWithCount>.from(ordered);
  final moved = next.removeAt(oldIndex);
  next.insert(newIndex, moved);
  return next;
}

/// 新顺序 → 批量排序更新（下标即 sortOrder）。
List<({String id, int sortOrder})> reorderUpdates(
  List<CategoryWithCount> ordered,
) => [
  for (final entry in ordered.asMap().entries)
    (id: entry.value.category.id, sortOrder: entry.key),
];

/// 分类选择网格的展示顺序：先父后子——列完一个一级分类及其全部二级分类，
/// 再列下一个；同级内部按 sortOrder 升序。
List<CategoryWithCount> orderCategoriesParentFirst(
  List<CategoryWithCount> all,
) {
  final parents = all.where((i) => i.category.level == 1).toList()
    ..sort((a, b) => a.category.sortOrder.compareTo(b.category.sortOrder));

  final ordered = <CategoryWithCount>[];
  for (final parent in parents) {
    ordered.add(parent);
    final children =
        all.where((i) => i.category.parentId == parent.category.id).toList()
          ..sort(
            (a, b) => a.category.sortOrder.compareTo(b.category.sortOrder),
          );
    ordered.addAll(children);
  }
  return ordered;
}
