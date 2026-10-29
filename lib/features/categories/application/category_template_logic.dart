import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:uuid/uuid.dart';

/// 模板仅描述名称、图标和树结构，不携带用户分类身份或已添加状态。
class CategoryTemplateItem {
  final String key;
  final String name;
  final String iconName;

  /// 创建只读模板节点，key 仅在资源目录内区分节点。
  const CategoryTemplateItem({
    required this.key,
    required this.name,
    required this.iconName,
  });
}

/// 一个父模板及其可选子模板。
class CategoryTemplateGroup {
  final CategoryTemplateItem parent;
  final List<CategoryTemplateItem> children;

  /// 保留模板资源原有顺序。
  const CategoryTemplateGroup({required this.parent, required this.children});
}

/// 一次提交的不可变计划，失败重试必须复用这一批身份。
class TemplateInsertPlan {
  final List<CategoryCreateDraft> items;

  /// 冻结提交内容，防止等待确认或重试时重新生成分类身份。
  TemplateInsertPlan(Iterable<CategoryCreateDraft> items)
    : items = List.unmodifiable(items);

  int get total => items.length;
}

/// 合并一级与分层模板，以资源 key 去重；用户目录不参与模板构建。
List<CategoryTemplateGroup> buildCategoryTemplateGroups(AppLocalizations l10n) {
  final templates = SeedService.categoryTemplates;
  return [
    for (final key in templates.keys)
      CategoryTemplateGroup(
        parent: CategoryTemplateItem(
          key: key,
          name: SeedService.getTranslatedCategoryName(key, l10n),
          iconName: SeedService.getDefaultIcon(key),
        ),
        children: [
          for (final child in templates[key] ?? <String>[])
            CategoryTemplateItem(
              key: child,
              name: SeedService.getTranslatedCategoryName(child, l10n),
              iconName: SeedService.getDefaultIcon(child),
            ),
        ],
      ),
  ];
}

/// 返回新的选择集合，不改变调用者的选择。
Set<String> toggleTemplateSelection(Set<String> selected, String key) {
  final next = {...selected};
  if (!next.add(key)) next.remove(key);
  return next;
}

/// 新建时子项包含所属项；追加时任意选中节点都作为目标分类的子项。
Set<String> effectiveTemplateSelection({
  required List<CategoryTemplateGroup> groups,
  required Set<String> selectedKeys,
  required bool appendToParent,
}) {
  final selected = <String>{};
  for (final group in groups) {
    final children = group.children.where(
      (child) => selectedKeys.contains(child.key),
    );
    selected.addAll(children.map((child) => child.key));
    if (selectedKeys.contains(group.parent.key) ||
        (!appendToParent && children.isNotEmpty)) {
      selected.add(group.parent.key);
    }
  }
  return selected;
}

/// 用户确认一次创建时分配身份；显式目标父只接收新子项，不新增模板父项。
TemplateInsertPlan buildInsertPlan({
  required List<CategoryTemplateGroup> groups,
  required Set<String> selectedKeys,
  String? targetParentId,
  String Function()? newId,
}) {
  try {
    if (targetParentId != null && targetParentId.isEmpty) {
      throw ArgumentError('目标父分类身份不能为空');
    }
    final allocate = newId ?? const Uuid().v4;
    final items = <CategoryCreateDraft>[];
    for (final group in groups) {
      final children = group.children
          .where((child) => selectedKeys.contains(child.key))
          .toList();
      if (targetParentId != null) {
        // 追加模式将每个明确选中的节点平铺到目标下，不沿用模板层级。
        for (final node in [
          if (selectedKeys.contains(group.parent.key)) group.parent,
          ...children,
        ]) {
          items.add(
            CategoryCreateDraft(
              id: allocate(),
              name: node.name,
              icon: node.iconName,

              parentId: targetParentId,
            ),
          );
        }
        continue;
      }
      if (targetParentId == null &&
          children.isEmpty &&
          !selectedKeys.contains(group.parent.key)) {
        continue;
      }
      // 同一批的多个子项共用本次父身份，不查询或认领同名既有父项。
      final parentId = targetParentId ?? allocate();
      if (targetParentId == null) {
        items.add(
          CategoryCreateDraft(
            id: parentId,
            name: group.parent.name,
            icon: group.parent.iconName,
          ),
        );
      }
      for (final child in children) {
        items.add(
          CategoryCreateDraft(
            id: allocate(),
            name: child.name,
            icon: child.iconName,

            parentId: parentId,
          ),
        );
      }
    }
    return TemplateInsertPlan(items);
  } catch (error, stack) {
    Error.throwWithStackTrace(StateError('无法准备分类添加内容：$error'), stack);
  }
}

/// 本地事务同时写分类与同步队列；同计划重试只识别相同 ID，不按名称复用。
Future<int> executeTemplateInsertPlan({
  required CategoryRepository repo,
  required TemplateInsertPlan plan,
  void Function()? assertCurrent,
}) => repo.runInTransaction(() async {
  assertCurrent?.call();
  final created = await repo.createCategoryBatch(items: plan.items);
  assertCurrent?.call();
  return created;
});
