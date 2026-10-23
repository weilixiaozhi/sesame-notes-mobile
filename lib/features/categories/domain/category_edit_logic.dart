/// 分类编辑表单的纯计算规则：初始图标与保存时的父子落点。
library;

/// 新建分类的默认图标：未选择或原图标失效时统一回退到它。
const String defaultCategoryIcon = 'category';

/// 表单初始图标：已有分类的有效图标原样沿用，缺失或不在图标库中时回退默认图标。
String resolveCategoryFormIcon(
  String? existingIcon, {
  required Set<String> availableIconKeys,
}) {
  if (existingIcon != null &&
      existingIcon.isNotEmpty &&
      availableIconKeys.contains(existingIcon)) {
    return existingIcon;
  }
  return defaultCategoryIcon;
}

/// 保存时的父子落点（parentId / level）。
///
/// - 选中了父分类 → 挂到该父下，level 为 2；
/// - 未选父分类且原为二级 → parentId 传空串清空父级，level 降为 1；
/// - 未选父分类且原为一级 → parentId 传 null 表示不改动，level 为 1。
({String? parentId, int level}) resolveCategoryPlacement({
  required String? selectedParentId,
  required int currentLevel,
}) {
  if (selectedParentId != null) return (parentId: selectedParentId, level: 2);
  return (parentId: currentLevel == 2 ? '' : null, level: 1);
}
