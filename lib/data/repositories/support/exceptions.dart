/// Repository 层的异常类型。
///
/// 用于让 caller 把"撞了不允许的状态"显式 handle,而不是被静默吞掉。
library;

/// 分类树或关联记录超出已确认范围时，要求重新查看而不扩大删除操作。
class CategoryReviewChangedException implements Exception {
  /// 固定提示不包含账号资料、分类正文或底层错误。
  const CategoryReviewChangedException();

  /// 提醒使用最新分类与记录重新确认。
  @override
  String toString() => '分类或关联记录已变化，请重新查看并确认后操作。';
}

/// 迁移目标不能属于待删除的来源集合或其最新子分类树。
class CategoryMigrationTargetException implements Exception {
  /// 保持固定文案，错误不会暴露分类内容。
  const CategoryMigrationTargetException();

  /// 引导选择迁移后仍会保留的独立目标。
  @override
  String toString() => '迁移目标属于待处理的分类，请重新选择独立的目标分类。';
}

/// 创建实体时撞了已有的同名条目。
///
/// 分类名按账号域和父分类判重，创建时发现同作用域的规范化名称已存在即抛出。
/// 页面据此提示修改名称，导入流程使用自身的分类匹配规则。
class DuplicateNameException implements Exception {
  const DuplicateNameException({required this.entityType, required this.name});

  /// 实体类型（如 'category'），给日志和上层 UI 区分。
  final String entityType;
  final String name;

  @override
  String toString() =>
      'DuplicateNameException: $entityType "$name" already exists';
}
