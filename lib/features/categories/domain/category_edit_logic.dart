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

/// 所属关系的保存值；空串用于明确移出原分类，null 表示关系保持不变。
String? resolveCategoryPlacement({
  required String? selectedParentId,
  required String? currentParentId,
}) {
  if (selectedParentId != null) return selectedParentId;
  return currentParentId == null ? null : '';
}
