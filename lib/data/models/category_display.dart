/// 分类展示模型。
library;

/// UI 消费的不可变分类快照，不暴露 Drift 行对象。
class CategoryDisplay {
  const CategoryDisplay({
    required this.id,
    required this.name,
    required this.kind,
    required this.level,
    required this.sortOrder,
    this.icon,
    this.parentId,
  });

  final String id;
  final String name;
  final String kind;
  final int level;
  final int sortOrder;
  final String? icon;
  final String? parentId;
}
