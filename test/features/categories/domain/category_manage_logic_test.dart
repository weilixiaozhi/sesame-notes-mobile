import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/domain/category_manage_logic.dart';

/// 构造分类展示快照。
CategoryDisplay _cat({
  required String id,
  required String name,
  required int level,
  int sortOrder = 0,
  String? parentId,
}) => CategoryDisplay(
  id: id,
  name: name,
  kind: 'expense',
  icon: 'category',
  sortOrder: sortOrder,
  parentId: parentId,
  level: level,
);

/// 分类 + 笔数。
CategoryWithCount _row(CategoryDisplay category, int transactionCount) =>
    (category: category, transactionCount: transactionCount);

/// 管理页预设数据：购物总笔数包含子分类，休闲为未使用分类。
List<CategoryWithCount> _manageFixture() => [
  _row(_cat(id: 'cat-1', name: '餐饮', level: 1, sortOrder: 0), 5),
  _row(_cat(id: 'cat-2', name: '交通', level: 1, sortOrder: 1), 3),
  _row(_cat(id: 'cat-3', name: '购物', level: 1, sortOrder: 2), 4),
  _row(
    _cat(id: 'cat-4', name: '服装', level: 2, parentId: 'cat-3', sortOrder: 0),
    2,
  ),
  _row(_cat(id: 'cat-6', name: '休闲', level: 1, sortOrder: 3), 0),
];

/// 子分类面板预设数据：购物含服装(2 笔)、鞋帽(1 笔)。
List<CategoryWithCount> _dialogFixture() => [
  _row(_cat(id: 'cat-1', name: '餐饮', level: 1, sortOrder: 0), 5),
  _row(_cat(id: 'cat-2', name: '交通', level: 1, sortOrder: 1), 3),
  _row(_cat(id: 'cat-3', name: '购物', level: 1, sortOrder: 2), 5),
  _row(
    _cat(id: 'cat-4', name: '服装', level: 2, parentId: 'cat-3', sortOrder: 0),
    2,
  ),
  _row(
    _cat(id: 'cat-5', name: '鞋帽', level: 2, parentId: 'cat-3', sortOrder: 1),
    1,
  ),
];

List<String> _idsOf(Iterable<CategoryWithCount> rows) => [
  for (final row in rows) row.category.id,
];

void main() {
  group('buildDeleteImpactScope 删除影响范围', () {
    test('含二级策略列出选中父分类及其全部子分类', () {
      // 5 个父分类 × 3 个子分类，全部被选中
      final all = <CategoryWithCount>[
        for (int p = 0; p < 5; p++) ...[
          _row(_cat(id: 'parent-$p', name: '父分类$p', level: 1, sortOrder: p), 6),
          for (int c = 0; c < 3; c++)
            _row(
              _cat(
                id: 'child-$p-$c',
                name: '子分类$p-$c',
                level: 2,
                sortOrder: c,
                parentId: 'parent-$p',
              ),
              2,
            ),
        ],
      ];
      final selected = {for (int p = 0; p < 5; p++) 'parent-$p'};

      final scope = buildDeleteImpactScope(
        all,
        selected,
        includeParents: true,
        option: 0,
      );

      expect(scope, hasLength(20), reason: '5 个父分类 + 各 3 个子分类');
      for (int p = 0; p < 5; p++) {
        expect(
          scope.any(
            (row) => row.item.category.id == 'parent-$p' && !row.isChild,
          ),
          isTrue,
        );
        for (int c = 0; c < 3; c++) {
          expect(
            scope.any(
              (row) => row.item.category.id == 'child-$p-$c' && row.isChild,
            ),
            isTrue,
          );
        }
      }
      // 展示顺序：逐个父分类后紧跟其子分类
      expect(scope.take(4).map((row) => row.item.category.id), [
        'parent-0',
        'child-0-0',
        'child-0-1',
        'child-0-2',
      ]);
    });

    test('迁移策略同样列出子分类，提升策略只列出选中父分类', () {
      final all = _manageFixture();
      expect(
        buildDeleteImpactScope(
          all,
          {'cat-3'},
          includeParents: true,
          option: 1,
        ).map((row) => row.item.category.id),
        ['cat-3', 'cat-4'],
      );
      expect(
        buildDeleteImpactScope(
          all,
          {'cat-3'},
          includeParents: true,
          option: 2,
        ).map((row) => row.item.category.id),
        ['cat-3'],
        reason: '提升策略保留子分类，影响范围不含子分类行',
      );
    });

    test('子分类面板不展示子分类行', () {
      final all = _dialogFixture();
      expect(
        buildDeleteImpactScope(
          all,
          {'cat-4'},
          includeParents: false,
          option: 0,
        ).map((row) => row.item.category.id),
        ['cat-4'],
      );
    });
  });

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

    test('provider 刷新后直属与总计同步更新', () {
      final all = _dialogFixture()
          .map(
            (row) => switch (row.category.id) {
              'cat-3' => _row(row.category, 6),
              'cat-4' => _row(row.category, 3),
              _ => row,
            },
          )
          .toList();
      final breakdown = parentTransactionBreakdown(
        all,
        all.firstWhere((row) => row.category.id == 'cat-3').category,
      );
      expect(breakdown.directCount, 2, reason: '6 - (3 + 1)');
      expect(breakdown.totalCount, 6);
    });

    test('父分类不在快照中时直属笔数为 0', () {
      final parent = _cat(id: 'cat-3', name: '购物', level: 1, sortOrder: 2);
      final children = _dialogFixture()
          .where((row) => row.category.parentId == 'cat-3')
          .toList();
      final breakdown = parentTransactionBreakdown(children, parent);
      expect(breakdown.directCount, 0);
      expect(breakdown.totalCount, 3, reason: '只有子分类汇总时全部计入子分类');
    });
  });

  group('拖动排序写回', () {
    test('相邻交换生成新顺序与批量更新', () {
      final subs = _dialogFixture()
          .where((row) => row.category.parentId == 'cat-3')
          .toList();

      final reordered = applyReorder(subs, 0, 1);

      expect(_idsOf(reordered), ['cat-5', 'cat-4']);
      expect(reorderUpdates(reordered), [
        (id: 'cat-5', sortOrder: 0),
        (id: 'cat-4', sortOrder: 1),
      ]);
    });

    test('首个元素移到末尾时下标即 sortOrder', () {
      final all = _manageFixture();
      final topLevel = all
          .where((row) => row.category.level == 1)
          .toList(growable: false);

      final reordered = applyReorder(topLevel, 0, 3);

      expect(_idsOf(reordered), ['cat-2', 'cat-3', 'cat-6', 'cat-1']);
      expect(reorderUpdates(reordered).last, (id: 'cat-1', sortOrder: 3));
    });
  });

  group('orderCategoriesParentFirst 选择网格顺序', () {
    test('先父后子，同级按 sortOrder 升序', () {
      // 故意打乱传入顺序：验证重排为 餐饮 → 早餐/午餐 → 交通
      final all = <CategoryWithCount>[
        _row(_cat(id: 'cat-4', name: '交通', level: 1, sortOrder: 1), 5),
        _row(
          _cat(
            id: 'cat-3',
            name: '午餐',
            level: 2,
            parentId: 'cat-1',
            sortOrder: 1,
          ),
          2,
        ),
        _row(_cat(id: 'cat-1', name: '餐饮', level: 1, sortOrder: 0), 3),
        _row(
          _cat(
            id: 'cat-2',
            name: '早餐',
            level: 2,
            parentId: 'cat-1',
            sortOrder: 0,
          ),
          1,
        ),
      ];

      expect(_idsOf(orderCategoriesParentFirst(all)), [
        'cat-1',
        'cat-2',
        'cat-3',
        'cat-4',
      ]);
    });
  });
}
