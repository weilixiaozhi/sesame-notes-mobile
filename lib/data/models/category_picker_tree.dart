import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_display.dart';

/// 仓储内部使用的 Drift 分类树。
class CategoryRowTree {
  const CategoryRowTree({required this.topLevel, required this.children});

  final List<Category> topLevel;
  final Map<String, List<Category>> children;
}

/// 记账页分类树：一级分类列表 + 父分类 ID → 二级分类列表的映射。
///
/// 设计意图：记账编辑页分类网格需要「全部一级 + 各一级的全部二级」，
/// 由 [LocalRepository.getCategoryTree] 一次构建。
class CategoryPickerTree {
  const CategoryPickerTree({required this.topLevel, required this.children});

  /// 一级分类（按 sortOrder 升序）
  final List<CategoryDisplay> topLevel;

  /// 父分类 UUID → 其子分类列表（仅含有子分类的父项；子列表按 sortOrder 升序）。
  final Map<String, List<CategoryDisplay>> children;

  /// 空树（无分类场景）
  static const empty = CategoryPickerTree(topLevel: [], children: {});
}
