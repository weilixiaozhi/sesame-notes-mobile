import 'package:sesame_notes/data/models/category_display.dart';

/// 记账页分类树：一级分类列表 + 父分类 ID → 二级分类列表的映射。
///
/// 展示层只持有分类展示对象，不依赖数据库生成行。
class CategoryPickerTree {
  const CategoryPickerTree({required this.topLevel, required this.children});

  /// 一级分类（按 sortOrder 升序）
  final List<CategoryDisplay> topLevel;

  /// 父分类 UUID → 其子分类列表（仅含有子分类的父项；子列表按 sortOrder 升序）。
  final Map<String, List<CategoryDisplay>> children;

  /// 空树（无分类场景）
  static const empty = CategoryPickerTree(topLevel: [], children: {});
}
