import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<CategoryTemplateGroup> groups;
  setUp(() async {
    groups = buildCategoryTemplateGroups(
      await AppLocalizations.delegate.load(const Locale('zh')),
    );
  });

  test('统一库完整合并为52父107子，资源键互不重复', () {
    expect(groups, hasLength(52));
    expect(groups.expand((group) => group.children), hasLength(107));
    final keys = [
      for (final group in groups) group.parent.key,
      ...groups.expand((group) => group.children).map((child) => child.key),
    ];
    expect(keys.toSet(), hasLength(159));
  });

  test('父可单选，多个子项只带入一个父，取消子项保留明确父选择', () {
    expect(
      buildInsertPlan(
        groups: groups,
        selectedKeys: {'dining'},
      ).items.single.level,
      1,
    );
    final selected = {'dining', 'dining_lunch', 'dining_breakfast'};
    final plan = buildInsertPlan(groups: groups, selectedKeys: selected);
    expect(plan.total, 3);
    final parent = plan.items.first;
    expect(
      plan.items.skip(1).every((child) => child.parentId == parent.id),
      isTrue,
    );
    selected.removeAll({'dining_lunch', 'dining_breakfast'});
    expect(
      effectiveTemplateSelection(
        groups: groups,
        selectedKeys: selected,
        appendToParent: false,
      ),
      {'dining'},
    );
  });

  test('两次明确创建身份不同，同一计划内容不可变且不依赖已有分类', () {
    final first = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
    );
    final second = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
    );
    expect(
      first.items
          .map((item) => item.id)
          .toSet()
          .intersection(second.items.map((item) => item.id).toSet()),
      isEmpty,
    );
    expect(() => first.items.clear(), throwsUnsupportedError);
  });

  test('明确已有分类时所有节点均可作为子项平铺加入，包括没有子项的旅行', () {
    final plan = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining', 'dining_lunch', 'beverage_coffee', 'travel'},
      targetParentId: 'chosen-parent',
    );
    expect(plan.total, 4);
    expect(
      plan.items.every(
        (item) => item.level == 2 && item.parentId == 'chosen-parent',
      ),
      isTrue,
    );
    expect(
      plan.items.map((item) => item.name),
      containsAll(['餐饮', '午餐', '咖啡', '旅行']),
    );
    expect(
      buildInsertPlan(
        groups: groups,
        selectedKeys: {'dining'},
        targetParentId: 'chosen-parent',
      ).total,
      1,
    );
    expect(
      effectiveTemplateSelection(
        groups: groups,
        selectedKeys: {'travel', 'dining_lunch'},
        appendToParent: true,
      ),
      {'travel', 'dining_lunch'},
    );
  });
}
