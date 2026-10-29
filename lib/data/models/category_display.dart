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
    this.scopeAccountId,
  });

  final String id;
  final String name;
  final String kind;
  final int level;
  final int sortOrder;
  final String? icon;
  final String? parentId;

  /// 父关系是应用分类角色的唯一来源。
  bool get isParent => parentId == null;

  /// 子分类具有明确的父分类身份，最多只支持这一层关系。
  bool get isChild => parentId != null;

  /// 分类所属账号；空值对应独立的纯本地目录。
  final String? scopeAccountId;
}
