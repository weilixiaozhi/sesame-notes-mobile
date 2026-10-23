import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/utils/text_validation.dart';

/// 模板项不可添加的原因；同名用户分类不会被认领为官方分类。
enum CategoryTemplateBlockReason {
  duplicateName,
  parentDuplicateName,
  parentHierarchyChanged,
}

/// 官方模板的稳定身份和当前目录状态，名称只用于显示与冲突提示。
class CategoryTemplateItem {
  final String key;
  final String name;
  final String iconName;
  final String syncId;
  final int level;
  final String? parentKey;
  final bool alreadyAdded;
  final CategoryTemplateBlockReason? blockedReason;
  final bool pendingConfirmation;

  const CategoryTemplateItem({
    required this.key,
    required this.name,
    required this.iconName,
    required this.syncId,
    required this.level,
    this.parentKey,
    required this.alreadyAdded,
    this.blockedReason,
    this.pendingConfirmation = false,
  });

  bool get canAdd =>
      !alreadyAdded && blockedReason == null && !pendingConfirmation;
}

/// 分层模板保留父与子展示顺序。
class CategoryTemplateGroup {
  final CategoryTemplateItem parent;
  final List<CategoryTemplateItem> children;

  const CategoryTemplateGroup({required this.parent, required this.children});
}

/// 只读写入计划，依赖的父分类总在子分类之前处理。
class TemplateInsertPlan {
  final List<CategoryTemplateItem> parentsToCreate;
  final List<({CategoryTemplateItem child, String parentSyncId})>
  childrenToCreate;

  const TemplateInsertPlan({
    required this.parentsToCreate,
    required this.childrenToCreate,
  });

  int get total => parentsToCreate.length + childrenToCreate.length;
}

/// 写入结果区分实际新增、恢复、跳过和需要用户确认的意图。
class TemplateInsertResult {
  final int created;
  final int restored;
  final int skipped;
  final List<CategoryTemplateItem> pending;
  final List<CategoryTemplateItem> localRestoreRequired;

  const TemplateInsertResult({
    required this.created,
    required this.restored,
    required this.skipped,
    required this.pending,
    required this.localRestoreRequired,
  });
}

/// 模板判断仅需身份、名称和父子关系，避免依赖数据库生成模型。
typedef ExistingCategoryLite = ({
  String id,
  String name,
  int level,
  String? parentId,
});

/// 官方身份按固定 ID 匹配；同名不同 ID 只阻止添加，不合并或迁移引用。
class ExistingCategoryIndex {
  final Map<String, ExistingCategoryLite> _byId;
  final Set<String> pendingIds;

  ExistingCategoryIndex(
    Iterable<ExistingCategoryLite> categories, {
    this.pendingIds = const {},
  }) : _byId = {for (final category in categories) category.id: category};

  bool containsCanonical(String id) => _byId.containsKey(id);

  bool isValidParent(String id) {
    final row = _byId[id];
    return row != null && row.level == 1 && row.parentId == null;
  }

  /// 与仓储采用相同 Unicode 首尾空白规则，不折叠大小写或兼容字符。
  bool hasNameCollision(String name, String? parentId) {
    final normalized = normalizeName(name);
    return _byId.values.any(
      (row) =>
          row.parentId == parentId && normalizeName(row.name) == normalized,
    );
  }

  CategoryTemplateBlockReason? parentBlock(String id, String name) {
    if (containsCanonical(id)) return null;
    return hasNameCollision(name, null)
        ? CategoryTemplateBlockReason.duplicateName
        : null;
  }

  CategoryTemplateBlockReason? childBlock({
    required String id,
    required String name,
    required String parentId,
    required String parentName,
  }) {
    if (containsCanonical(id)) return null;
    if (containsCanonical(parentId) && !isValidParent(parentId)) {
      return CategoryTemplateBlockReason.parentHierarchyChanged;
    }
    if (!containsCanonical(parentId) && hasNameCollision(parentName, null)) {
      return CategoryTemplateBlockReason.parentDuplicateName;
    }
    return hasNameCollision(name, parentId)
        ? CategoryTemplateBlockReason.duplicateName
        : null;
  }
}

/// 使用与默认种子相同的、语言无关的官方身份。
String templateItemSyncId(int level, String key) =>
    SeedService.deterministicCategorySyncId(level: level, key: key);

/// 构建一级模板，已存在与同名阻挡分别呈现。
List<CategoryTemplateItem> buildFlatTemplateItems(
  AppLocalizations l10n,
  ExistingCategoryIndex existing,
) => [
  for (final key in SeedService.flatExpenseCategoryKeys)
    () {
      final id = templateItemSyncId(1, key);
      final name = SeedService.getTranslatedCategoryName(key, l10n);
      return CategoryTemplateItem(
        key: key,
        name: name,
        iconName: SeedService.getDefaultIcon(key),
        syncId: id,
        level: 1,
        alreadyAdded: existing.containsCanonical(id),
        blockedReason: existing.parentBlock(id, name),
        pendingConfirmation: existing.pendingIds.contains(id),
      );
    }(),
];

/// 构建分层模板；父分类被改名仍复用其身份，层级改变则阻止依赖的子项。
List<CategoryTemplateGroup> buildHierarchicalTemplateGroups(
  AppLocalizations l10n,
  ExistingCategoryIndex existing,
) => [
  for (final entry in SeedService.hierarchicalExpenseCategories.entries)
    () {
      final parentId = templateItemSyncId(1, entry.key);
      final parentName = SeedService.getTranslatedParentCategoryName(
        entry.key,
        l10n,
      );
      return CategoryTemplateGroup(
        parent: CategoryTemplateItem(
          key: entry.key,
          name: parentName,
          iconName: SeedService.getDefaultIcon(entry.key),
          syncId: parentId,
          level: 1,
          alreadyAdded: existing.containsCanonical(parentId),
          blockedReason: existing.parentBlock(parentId, parentName),
          pendingConfirmation: existing.pendingIds.contains(parentId),
        ),
        children: [
          for (final key in entry.value)
            () {
              final id = templateItemSyncId(2, key);
              final name = SeedService.getTranslatedSubCategoryName(key, l10n);
              return CategoryTemplateItem(
                key: key,
                name: name,
                iconName: SeedService.getDefaultIcon(key),
                syncId: id,
                level: 2,
                parentKey: entry.key,
                alreadyAdded: existing.containsCanonical(id),
                blockedReason: existing.childBlock(
                  id: id,
                  name: name,
                  parentId: parentId,
                  parentName: parentName,
                ),
                pendingConfirmation:
                    existing.pendingIds.contains(id) ||
                    (!existing.containsCanonical(parentId) &&
                        existing.pendingIds.contains(parentId)),
              );
            }(),
        ],
      );
    }(),
];

/// 返回新的选择集合，不修改调用方状态。
Set<String> toggleFlatSelection(Set<String> selected, String key) {
  final next = {...selected};
  if (!next.add(key)) next.remove(key);
  return next;
}

Set<String> computeFlatSelectAll(List<CategoryTemplateItem> items) => {
  for (final item in items)
    if (item.canAdd) item.key,
};

/// 父项由选中的子项派生，取消所有子项不会残留父项写入。
Set<String> computeHierarchicalSelectAll(List<CategoryTemplateGroup> groups) =>
    {
      for (final group in groups)
        for (final child in group.children)
          if (child.canAdd) child.key,
    };

/// 选择仅生成有效的稳定 ID 计划，不在展示期间写入数据库。
TemplateInsertPlan buildInsertPlan({
  required List<CategoryTemplateItem> allItems,
  required Set<String> selectedKeys,
}) {
  final byKey = {for (final item in allItems) item.key: item};
  final parents = <CategoryTemplateItem>[];
  final children = <({CategoryTemplateItem child, String parentSyncId})>[];
  final plannedParents = <String>{};
  for (final item in allItems) {
    if (!selectedKeys.contains(item.key) || !item.canAdd) continue;
    if (item.level == 1) {
      parents.add(item);
      plannedParents.add(item.key);
    }
  }
  for (final item in allItems) {
    if (!selectedKeys.contains(item.key) || !item.canAdd || item.level != 2) {
      continue;
    }
    final parent = byKey[item.parentKey];
    if (parent == null || (!parent.alreadyAdded && !parent.canAdd)) continue;
    if (!parent.alreadyAdded && plannedParents.add(parent.key)) {
      parents.add(parent);
    }
    children.add((child: item, parentSyncId: parent.syncId));
  }
  return TemplateInsertPlan(
    parentsToCreate: parents,
    childrenToCreate: children,
  );
}

/// 原子执行官方身份写入；仓储再次检查最新目录、墓碑和名称冲突。
/// 会话检查在事务内每次异步边界复核，失效时整笔本地写入回滚。
Future<TemplateInsertResult> executeTemplateInsertPlan({
  required CategoryRepository repo,
  required TemplateInsertPlan plan,
  required List<db.CategoryDisplay> existingCategories,
  Set<String> restoreLocalDeletedIds = const {},
  void Function()? assertCurrent,
}) => repo.runInTransaction(() async {
  assertCurrent?.call();
  var topSort = 0;
  for (final row in existingCategories) {
    if (row.level == 1 && row.sortOrder > topSort) topSort = row.sortOrder;
  }
  var created = 0;
  var restored = 0;
  var skipped = 0;
  final pending = <CategoryTemplateItem>[];
  final restoreRequired = <CategoryTemplateItem>[];
  final unavailableParents = <String>{};

  /// 只有 created/restored 改变可见目录，待确认与跳过不计入成功数量。
  void collect(
    CategoryTemplateItem item,
    CanonicalCategoryInsertResult result,
  ) {
    switch (result) {
      case CanonicalCategoryInsertResult.created:
        created++;
      case CanonicalCategoryInsertResult.restored:
        restored++;
      case CanonicalCategoryInsertResult.pendingConfirmation:
        pending.add(item);
      case CanonicalCategoryInsertResult.localRestoreRequired:
        restoreRequired.add(item);
      case CanonicalCategoryInsertResult.unchanged:
      case CanonicalCategoryInsertResult.nameConflict:
      case CanonicalCategoryInsertResult.parentUnavailable:
        skipped++;
    }
  }

  for (final item in plan.parentsToCreate) {
    assertCurrent?.call();
    final result = await repo.insertCanonicalCategory(
      id: item.syncId,
      name: item.name,
      kind: 'expense',
      level: 1,
      icon: item.iconName,
      sortOrder: topSort + 1,
      restoreLocalDeleted: restoreLocalDeletedIds.contains(item.syncId),
    );
    assertCurrent?.call();
    collect(item, result);
    if (result == CanonicalCategoryInsertResult.created) topSort++;
    if (result != CanonicalCategoryInsertResult.created &&
        result != CanonicalCategoryInsertResult.restored &&
        result != CanonicalCategoryInsertResult.unchanged) {
      unavailableParents.add(item.syncId);
    }
  }
  final childSort = <String, int>{};
  for (final entry in plan.childrenToCreate) {
    if (unavailableParents.contains(entry.parentSyncId)) {
      skipped++;
      continue;
    }
    var lastSort = childSort[entry.parentSyncId] ?? -1;
    for (final row in existingCategories) {
      if (row.parentId == entry.parentSyncId && row.sortOrder > lastSort) {
        lastSort = row.sortOrder;
      }
    }
    assertCurrent?.call();
    final result = await repo.insertCanonicalCategory(
      id: entry.child.syncId,
      name: entry.child.name,
      kind: 'expense',
      level: 2,
      parentId: entry.parentSyncId,
      icon: entry.child.iconName,
      sortOrder: lastSort + 1,
      restoreLocalDeleted: restoreLocalDeletedIds.contains(entry.child.syncId),
    );
    assertCurrent?.call();
    collect(entry.child, result);
    if (result == CanonicalCategoryInsertResult.created) {
      childSort[entry.parentSyncId] = lastSort + 1;
    }
  }
  assertCurrent?.call();
  return TemplateInsertResult(
    created: created,
    restored: restored,
    skipped: skipped,
    pending: List.unmodifiable(pending),
    localRestoreRequired: List.unmodifiable(restoreRequired),
  );
});
