import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  /// 构造测试条目（name/icon 不参与断言，直接占位）
  CategoryTemplateItem item(
    String key, {
    int level = 1,
    String? parentKey,
    bool added = false,
  }) => CategoryTemplateItem(
    key: key,
    name: key,
    iconName: 'icon',
    syncId: templateItemSyncId(level, key),
    level: level,
    parentKey: parentKey,
    alreadyAdded: added,
  );

  /// 构造已存在分类轻量记录（默认 expense）。
  /// 分类主键是确定性 UUID，模板条目的 syncId 与已有分类的 id 直接匹配。
  ExistingCategoryLite lite({
    required String id,
    String name = '',
    int level = 1,
    String? parentId,
  }) => (id: id, name: name, level: level, parentId: parentId);

  group('ExistingCategoryIndex', () {
    test('固定身份命中后改名或移动层级仍识别为同一个官方分类', () {
      final id = templateItemSyncId(1, 'dining');
      final index = ExistingCategoryIndex([
        lite(id: id, name: '我的餐饮', level: 2, parentId: 'custom-parent'),
      ]);
      expect(index.containsCanonical(id), isTrue);
      expect(index.parentBlock(id, '餐饮'), isNull);
      expect(index.isValidParent(id), isFalse);
    });

    test('同名自定义分类不会成为官方身份或父分类', () {
      final id = templateItemSyncId(1, 'dining');
      final index = ExistingCategoryIndex([lite(id: 'random-v4', name: '餐饮')]);
      expect(index.containsCanonical(id), isFalse);
      expect(index.isValidParent(id), isFalse);
      expect(
        index.parentBlock(id, '餐饮'),
        CategoryTemplateBlockReason.duplicateName,
      );
      expect(
        index.childBlock(
          id: templateItemSyncId(2, 'dining_breakfast'),
          name: '早餐',
          parentId: id,
          parentName: '餐饮',
        ),
        CategoryTemplateBlockReason.parentDuplicateName,
      );
    });

    test('固定子身份命中不因名称或父关系改变重复添加', () {
      final id = templateItemSyncId(2, 'dining_breakfast');
      final index = ExistingCategoryIndex([
        lite(id: id, name: '任意名', level: 2, parentId: 'parent-1'),
      ]);
      expect(
        index.childBlock(
          id: id,
          name: '早餐',
          parentId: templateItemSyncId(1, 'dining'),
          parentName: '餐饮',
        ),
        isNull,
      );
      expect(index.containsCanonical(id), isTrue);
    });

    test('同名不同父可共存，同父同名不同身份只阻挡不认领', () {
      final parent = templateItemSyncId(1, 'dining');
      final child = templateItemSyncId(2, 'dining_breakfast');
      final index = ExistingCategoryIndex([
        lite(id: parent, name: '餐饮'),
        lite(id: 'custom-child', name: '早餐', level: 2, parentId: parent),
      ]);
      expect(index.containsCanonical(child), isFalse);
      expect(
        index.childBlock(
          id: child,
          name: '早餐',
          parentId: parent,
          parentName: '餐饮',
        ),
        CategoryTemplateBlockReason.duplicateName,
      );
      expect(index.hasNameCollision('早餐', 'another-parent'), isFalse);
    });

    test('官方父层级被改动时阻止新子项，不另造父身份', () {
      final parent = templateItemSyncId(1, 'dining');
      final index = ExistingCategoryIndex([
        lite(id: parent, name: '餐饮', level: 2, parentId: 'other'),
      ]);
      expect(
        index.childBlock(
          id: templateItemSyncId(2, 'dining_breakfast'),
          name: '早餐',
          parentId: parent,
          parentName: '餐饮',
        ),
        CategoryTemplateBlockReason.parentHierarchyChanged,
      );
    });

    test('名称比较只规范首尾Unicode空白，不折叠大小写或兼容字符', () {
      final index = ExistingCategoryIndex([
        lite(id: 'custom', name: '\u0085餐饮\uFEFF'),
        lite(id: 'latin', name: 'ABC'),
        lite(id: 'full-width', name: 'ＡＢＣ'),
      ]);
      expect(index.hasNameCollision('餐饮', null), isTrue);
      expect(index.hasNameCollision('abc', null), isFalse);
      expect(index.hasNameCollision('ABC', null), isTrue);
    });

    test('官方与同名旧自定义同时存在时仅认官方，原数据不变', () {
      final official = templateItemSyncId(1, 'dining');
      final rows = [
        lite(id: official, name: '餐饮'),
        lite(id: 'random', name: '餐饮'),
      ];
      final index = ExistingCategoryIndex(rows);
      expect(index.parentBlock(official, '餐饮'), isNull);
      expect(index.containsCanonical(official), isTrue);
      expect(rows.map((row) => row.id), [official, 'random']);
    });
  });

  group('toggleFlatSelection', () {
    test('勾选加入、再点移除', () {
      var selected = <String>{};
      selected = toggleFlatSelection(selected, 'dining');
      expect(selected, {'dining'});
      selected = toggleFlatSelection(selected, 'medical');
      expect(selected, {'dining', 'medical'});
      selected = toggleFlatSelection(selected, 'dining');
      expect(selected, {'medical'});
    });
  });

  group('computeSelectAll', () {
    test('flat 全选只含未添加条目', () {
      final items = [
        item('dining', added: true),
        item('medical'),
        item('sports'),
      ];
      expect(computeFlatSelectAll(items), {'medical', 'sports'});
    });

    test('hierarchical 全选仅包含未添加子分类，父分类由子项派生', () {
      final groups = [
        CategoryTemplateGroup(
          parent: item('dining'),
          children: [
            item('dining_breakfast', level: 2, parentKey: 'dining'),
            item('dining_lunch', level: 2, parentKey: 'dining', added: true),
          ],
        ),
        CategoryTemplateGroup(
          parent: item('shopping', added: true),
          children: [item('shopping_bag', level: 2, parentKey: 'shopping')],
        ),
      ];
      expect(computeHierarchicalSelectAll(groups), {
        'dining_breakfast',
        // dining_lunch 已添加 → 不选
        // shopping 已添加 → 不选
        'shopping_bag',
      });
    });

    test('全选后逐个取消子分类不会残留父分类写入', () {
      final parent = item('dining');
      final children = [
        item('dining_breakfast', level: 2, parentKey: 'dining'),
        item('dining_lunch', level: 2, parentKey: 'dining'),
      ];
      var selected = computeHierarchicalSelectAll([
        CategoryTemplateGroup(parent: parent, children: children),
      ]);
      for (final child in children) {
        selected = toggleFlatSelection(selected, child.key);
      }
      expect(selected, isEmpty);
      expect(
        buildInsertPlan(
          allItems: [parent, ...children],
          selectedKeys: selected,
        ).total,
        0,
      );
    });
  });

  group('buildInsertPlan', () {
    test('父先子后，子的 parentSyncId 指向对应父', () {
      final all = [
        item('dining'),
        item('dining_breakfast', level: 2, parentKey: 'dining'),
        item('medical'),
      ];
      final plan = buildInsertPlan(
        allItems: all,
        selectedKeys: {'dining', 'dining_breakfast', 'medical'},
      );
      expect(plan.parentsToCreate.map((e) => e.key), ['dining', 'medical']);
      expect(plan.childrenToCreate, hasLength(1));
      expect(plan.childrenToCreate.single.child.key, 'dining_breakfast');
      expect(
        plan.childrenToCreate.single.parentSyncId,
        templateItemSyncId(1, 'dining'),
      );
      expect(plan.total, 3);
    });

    test('已添加条目即使在选中集中也被剔除', () {
      final all = [item('dining', added: true), item('medical')];
      final plan = buildInsertPlan(
        allItems: all,
        selectedKeys: {'dining', 'medical'},
      );
      expect(plan.parentsToCreate.map((e) => e.key), ['medical']);
      expect(plan.total, 1);
    });

    test('混合"已有父 + 新子"：父不进 parentsToCreate，子的父引用指向已有父', () {
      final all = [
        item('dining', added: true),
        item('dining_dinner', level: 2, parentKey: 'dining'),
      ];
      final plan = buildInsertPlan(
        allItems: all,
        selectedKeys: {'dining_dinner'},
      );
      expect(plan.parentsToCreate, isEmpty);
      expect(
        plan.childrenToCreate.single.parentSyncId,
        templateItemSyncId(1, 'dining'),
      );
      expect(plan.total, 1);
    });

    test('单独勾子类且父未在表 → 计划自动补父（父先子后）', () {
      final all = [
        item('dining'),
        item('dining_breakfast', level: 2, parentKey: 'dining'),
        item('dining_lunch', level: 2, parentKey: 'dining'),
      ];
      final plan = buildInsertPlan(
        allItems: all,
        selectedKeys: {'dining_breakfast', 'dining_lunch'},
      );
      expect(plan.parentsToCreate.map((e) => e.key), [
        'dining',
      ], reason: '子类不能脱离父存在，父未选中也应自动并入待建父');
      expect(plan.childrenToCreate.map((e) => e.child.key), [
        'dining_breakfast',
        'dining_lunch',
      ]);
      expect(plan.total, 3);
    });

    test('父显式选中 + 子选中 → 父不重复并入', () {
      final all = [
        item('dining'),
        item('dining_breakfast', level: 2, parentKey: 'dining'),
      ];
      final plan = buildInsertPlan(
        allItems: all,
        selectedKeys: {'dining', 'dining_breakfast'},
      );
      expect(plan.parentsToCreate, hasLength(1));
    });
  });

  group('buildTemplateItems（需 l10n）', () {
    test('flat 条目：数量/层级/确定性 id 与 seed 同源，alreadyAdded 随索引变化', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // 无已存在 → 全部可添加（等价于"分类被删除后释放回模板"）
      final none = buildFlatTemplateItems(l10n, ExistingCategoryIndex([]));
      expect(none, hasLength(SeedService.flatExpenseCategoryKeys.length));
      expect(none.every((e) => e.level == 1 && !e.alreadyAdded), isTrue);
      // 条目 syncId 与 seed 确定性 id 同源
      expect(
        none.first.syncId,
        SeedService.deterministicCategorySyncId(
          level: 1,
          key: SeedService.flatExpenseCategoryKeys.first,
        ),
      );

      // 确定性 id 命中（seed 分类 id == 模板条目 syncId）→ alreadyAdded
      final diningSid = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );
      final withDining = buildFlatTemplateItems(
        l10n,
        ExistingCategoryIndex([lite(id: diningSid, name: '餐饮')]),
      );
      expect(
        withDining.firstWhere((e) => e.key == 'dining').alreadyAdded,
        isTrue,
      );
      expect(withDining.where((e) => e.alreadyAdded), hasLength(1));
    });

    test('flat 条目：同名自定义只阻挡，不能认领为官方', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final diningName = SeedService.getTranslatedCategoryName('dining', l10n);
      final items = buildFlatTemplateItems(
        l10n,
        ExistingCategoryIndex([lite(id: 'random-v4', name: diningName)]),
      );
      final dining = items.firstWhere((e) => e.key == 'dining');
      expect(dining.alreadyAdded, isFalse);
      expect(dining.blockedReason, CategoryTemplateBlockReason.duplicateName);
      expect(dining.canAdd, isFalse);
      expect(items.where((e) => e.alreadyAdded), isEmpty);
    });

    test('hierarchical 组：父子 alreadyAdded 按各自 level 的确定性 id 独立判定', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final groups = buildHierarchicalTemplateGroups(
        l10n,
        ExistingCategoryIndex([]),
      );
      expect(
        groups,
        hasLength(SeedService.hierarchicalExpenseCategories.length),
      );

      final dining = groups.firstWhere((g) => g.parent.key == 'dining');
      expect(
        dining.children.map((e) => e.key),
        SeedService.hierarchicalExpenseCategories['dining'],
      );
      expect(dining.children.every((e) => e.parentKey == 'dining'), isTrue);

      // 仅父已添加：父 alreadyAdded、子仍可添加（父已在表 → 子可单选）
      final parentSid = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );
      final g2 = buildHierarchicalTemplateGroups(
        l10n,
        ExistingCategoryIndex([lite(id: parentSid, name: '餐饮')]),
      ).firstWhere((g) => g.parent.key == 'dining');
      expect(g2.parent.alreadyAdded, isTrue);
      expect(g2.children.every((e) => !e.alreadyAdded), isTrue);

      // 仅某个子已添加：父不受影响
      final childSid = SeedService.deterministicCategorySyncId(
        level: 2,
        key: 'dining_breakfast',
      );
      final g3 = buildHierarchicalTemplateGroups(
        l10n,
        ExistingCategoryIndex([
          lite(id: childSid, name: '早餐', level: 2, parentId: 'parent-1'),
        ]),
      ).firstWhere((g) => g.parent.key == 'dining');
      expect(g3.parent.alreadyAdded, isFalse);
      expect(
        g3.children.firstWhere((e) => e.key == 'dining_breakfast').alreadyAdded,
        isTrue,
      );
    });

    test('hierarchical 组：同名自定义父阻止整分支，不认领父子身份', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final parentName = SeedService.getTranslatedParentCategoryName(
        'dining',
        l10n,
      );
      final childName = SeedService.getTranslatedSubCategoryName(
        'dining_breakfast',
        l10n,
      );
      final groups = buildHierarchicalTemplateGroups(
        l10n,
        ExistingCategoryIndex([
          lite(id: 'random-v4', name: parentName),
          lite(
            id: 'random-v4-2',
            name: childName,
            level: 2,
            parentId: 'random-v4',
          ),
        ]),
      ).firstWhere((g) => g.parent.key == 'dining');
      expect(groups.parent.alreadyAdded, isFalse);
      expect(
        groups.parent.blockedReason,
        CategoryTemplateBlockReason.duplicateName,
      );
      expect(
        groups.children
            .firstWhere((e) => e.key == 'dining_breakfast')
            .alreadyAdded,
        isFalse,
        reason: '同名自定义子不是官方身份',
      );
      expect(
        groups.children.every(
          (item) =>
              item.blockedReason ==
              CategoryTemplateBlockReason.parentDuplicateName,
        ),
        isTrue,
      );
      expect(computeHierarchicalSelectAll([groups]), isEmpty);
      // 父分支受阻不会改变任何子项身份。
      expect(
        groups.children
            .where((e) => e.key != 'dining_breakfast')
            .every((e) => !e.alreadyAdded),
        isTrue,
      );
    });

    test('templateItemSyncId 与 seed 确定性 syncId 同源（跨模板去重契约）', () {
      for (final level in [1, 2]) {
        expect(
          templateItemSyncId(level, 'dining'),
          SeedService.deterministicCategorySyncId(level: level, key: 'dining'),
        );
      }
    });
  });
  test('模板共享稳定身份且所有二级分类引用有效父级', () {
    final flat = {
      for (final key in SeedService.flatExpenseCategoryKeys)
        templateItemSyncId(1, key),
    };
    final hierarchical = {
      for (final entry
          in SeedService.hierarchicalExpenseCategories.entries) ...[
        templateItemSyncId(1, entry.key),
        for (final key in entry.value) templateItemSyncId(2, key),
      ],
    };
    expect(officialCategoryIdentities.keys.toSet(), {...flat, ...hierarchical});
    expect(
      templateItemSyncId(1, 'dining'),
      'ffec6471-df8b-5bb3-8a05-93ef863ca958',
    );
    for (final identity in officialCategoryIdentities.values) {
      if (identity.level == 2) {
        expect(officialCategoryIdentities[identity.parentId]?.level, 1);
      }
    }
  });

  test('待确认父项连同未建立的子项不可再次选择', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final groups = buildHierarchicalTemplateGroups(
      l10n,
      ExistingCategoryIndex([], pendingIds: {templateItemSyncId(1, 'dining')}),
    );
    final dining = groups.firstWhere((group) => group.parent.key == 'dining');
    expect(dining.parent.pendingConfirmation, isTrue);
    expect(
      dining.children.every((item) => item.pendingConfirmation && !item.canAdd),
      isTrue,
    );
    expect(
      buildInsertPlan(
        allItems: [dining.parent, ...dining.children],
        selectedKeys: {'dining_breakfast'},
      ).total,
      0,
    );
  });

  test('父层级改变时已存在项保留，尚未创建的依赖子项不可选择', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final groups = buildHierarchicalTemplateGroups(
      l10n,
      ExistingCategoryIndex([
        lite(
          id: templateItemSyncId(1, 'dining'),
          name: '餐饮',
          level: 2,
          parentId: 'other',
        ),
      ]),
    );
    final dining = groups.firstWhere((group) => group.parent.key == 'dining');
    expect(dining.parent.alreadyAdded, isTrue);
    expect(
      dining.children.every(
        (item) =>
            item.blockedReason ==
            CategoryTemplateBlockReason.parentHierarchyChanged,
      ),
      isTrue,
    );
    expect(computeHierarchicalSelectAll([dining]), isEmpty);
  });
}
