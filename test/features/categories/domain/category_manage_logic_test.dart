import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/domain/category_manage_logic.dart';

/// 构造分类展示快照。
CategoryDisplay _cat({
  required String id,
  required String name,
  required int level,
  String? parentId,
}) => CategoryDisplay(
  id: id,
  name: name,
  kind: 'expense',
  icon: 'category',
  sortOrder: 0,
  parentId: parentId,
  level: level,
);

/// 分类 + 笔数。
CategoryWithCount _row(CategoryDisplay category, int transactionCount) =>
    (category: category, transactionCount: transactionCount);

/// 管理页预设数据：购物总笔数包含子分类，休闲为未使用分类。
List<CategoryWithCount> _manageFixture() => [
  _row(_cat(id: 'cat-1', name: '餐饮', level: 1), 5),
  _row(_cat(id: 'cat-2', name: '交通', level: 1), 3),
  _row(_cat(id: 'cat-3', name: '购物', level: 1), 4),
  _row(_cat(id: 'cat-4', name: '服装', level: 2, parentId: 'cat-3'), 2),
  _row(_cat(id: 'cat-6', name: '休闲', level: 1), 0),
];

/// 子分类面板预设数据：购物含服装(2 笔)、鞋帽(1 笔)。
List<CategoryWithCount> _dialogFixture() => [
  _row(_cat(id: 'cat-1', name: '餐饮', level: 1), 5),
  _row(_cat(id: 'cat-2', name: '交通', level: 1), 3),
  _row(_cat(id: 'cat-3', name: '购物', level: 1), 5),
  _row(_cat(id: 'cat-4', name: '服装', level: 2, parentId: 'cat-3'), 2),
  _row(_cat(id: 'cat-5', name: '鞋帽', level: 2, parentId: 'cat-3'), 1),
];

List<String> _idsOf(Iterable<CategoryWithCount> rows) => [
  for (final row in rows) row.category.id,
];

void main() {
  group('删除影响笔数口径', () {
    test('含二级/迁移策略：父分类与总计都含子分类笔数且不重复累计', () {
      final all = _manageFixture();
      final shopping = all.firstWhere((row) => row.category.id == 'cat-3');

      expect(
        affectedTransactionCount(
          shopping,
          all,
          includeParents: true,
          option: 0,
        ),
        4,
        reason: '父分类行直接展示含子分类的汇总笔数',
      );
      expect(
        totalAffectedTransactionCount(
          all,
          {'cat-3'},
          includeParents: true,
          option: 0,
        ),
        4,
        reason: '子分类笔数已含在父分类内，总计不得再加一遍',
      );
    });

    test('保留子分类策略：父分类与总计只计直接记录', () {
      final all = _manageFixture();
      expect(
        totalAffectedTransactionCount(
          all,
          {'cat-3'},
          includeParents: true,
          option: 2,
        ),
        2,
        reason: '购物 4 笔扣除服装的 2 笔后仅剩直接记录',
      );
    });

    test('多选时总计等于各选中分类之和', () {
      final all = _manageFixture();
      expect(
        totalAffectedTransactionCount(
          all,
          {'cat-1', 'cat-3'},
          includeParents: true,
          option: 0,
        ),
        9,
        reason: '餐饮 5 笔 + 购物 4 笔',
      );
    });
  });

  group('selectMigrateTargets 迁移候选', () {
    test('管理页排除选中父分类及其子分类', () {
      final all = _manageFixture();
      expect(
        _idsOf(
          selectMigrateTargets(all, {'cat-3'}, excludeChildrenOfSelected: true),
        ),
        ['cat-1', 'cat-2', 'cat-6'],
        reason: '购物与其子分类服装都随删除消失，不能作为迁移目标',
      );
    });

    test('子分类面板只排除选中子分类，父分类与其他子分类仍可选', () {
      final all = _dialogFixture();
      expect(
        _idsOf(
          selectMigrateTargets(all, {
            'cat-4',
          }, excludeChildrenOfSelected: false),
        ),
        ['cat-1', 'cat-2', 'cat-3', 'cat-5'],
        reason: '删除子分类不动父分类，原父可承接迁移数据',
      );
    });
  });

  group('selectUnusedCategories 清理未使用分类', () {
    test('只挑出零交易分类', () {
      expect(_idsOf(selectUnusedCategories(_manageFixture())), ['cat-6']);
    });

    test('全部分类都有交易时返回空', () {
      final all = _manageFixture()
          .where((row) => row.category.id != 'cat-6')
          .toList();
      expect(selectUnusedCategories(all), isEmpty);
    });
  });

  group('collectSubCategoryIds 待删子分类', () {
    test('收集选中一级分类的全部二级分类 id', () {
      expect(collectSubCategoryIds(_manageFixture(), ['cat-3']), [
        'cat-4',
      ], reason: '策略 A 需要连子分类的交易一起清空');
    });

    test('多选时按选中顺序拼接各自子分类', () {
      final all = _dialogFixture();
      expect(collectSubCategoryIds(all, ['cat-3', 'cat-1']), [
        'cat-4',
        'cat-5',
      ]);
    });
  });
  group('parentTransactionBreakdown 子分类面板笔数', () {
    test('直属笔数 = 总笔数 - 子分类笔数', () {
      final all = _dialogFixture();
      final breakdown = parentTransactionBreakdown(
        all,
        all.firstWhere((row) => row.category.id == 'cat-3').category,
      );
      expect(breakdown.directCount, 2, reason: '5 笔包含服装 2 笔 + 鞋帽 1 笔');
      expect(breakdown.totalCount, 5);
    });

    test('父分类不在快照中时直属笔数为 0', () {
      final parent = _cat(id: 'cat-3', name: '购物', level: 1);
      final children = _dialogFixture()
          .where((row) => row.category.parentId == 'cat-3')
          .toList();
      final breakdown = parentTransactionBreakdown(children, parent);
      expect(breakdown.directCount, 0);
      expect(breakdown.totalCount, 3, reason: '只有子分类汇总时全部计入子分类');
    });
  });
}
