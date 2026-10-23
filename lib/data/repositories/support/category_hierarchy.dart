import 'package:sesame_notes/data/db.dart';

/// 叶子分类与孤儿分类筛选。
class CategoryHierarchy {
  /// 找出所有孤儿二级分类：parentId 指向的分类不在一级列表里。
  ///
  /// 仅父分类存在于一级列表的子分类可见。
  static List<Category> findOrphanCategories(List<Category> allCategories) {
    final topLevelIds = allCategories
        .where((c) => c.level == 1 || c.parentId == null)
        .map((c) => c.id)
        .toSet();
    return allCategories
        .where((c) => c.parentId != null && !topLevelIds.contains(c.parentId))
        .toList();
  }

  /// 获取可用于记账的分类（叶子分类）
  ///
  /// 可用分类 = 没有子分类的分类
  /// - 如果是一级分类且有子分类 -> 不可用（需要选择子分类）
  /// - 如果是一级分类且没有子分类 -> 可用
  /// - 如果是二级分类 -> 可用
  ///
  /// 此方法用于：
  /// 1. AI 记账时匹配分类
  /// 2. AI 提示词中传递分类列表
  /// 3. 分类兜底选择
  static List<Category> getUsableCategories(List<Category> allCategories) {
    // 找出所有作为父分类的 ID
    final parentIds = allCategories
        .where((c) => c.parentId != null)
        .map((c) => c.parentId!)
        .toSet();

    // 孤儿二级分类（父分类缺失）与树构建口径一致：管理页不可见，记账也不能选，
    // 避免出现「管理里没有、记账里却能选」的怪现象。
    final orphanIds = findOrphanCategories(
      allCategories,
    ).map((c) => c.id).toSet();

    // 过滤出可用分类：不是父分类、且不是孤儿分类的分类
    return allCategories
        .where((c) => !parentIds.contains(c.id) && !orphanIds.contains(c.id))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
