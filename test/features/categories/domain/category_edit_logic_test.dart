import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/categories/domain/category_edit_logic.dart';

/// 分类保存按明确父级选择生成仓储要求的归属参数。
void main() {
  group('resolveCategoryPlacement 保存时的父子落点', () {
    test('选中父分类：挂到该父下并置为二级', () {
      expect(
        resolveCategoryPlacement(
          selectedParentId: 'cat-10',
          currentParentId: null,
        ),
        'cat-10',
      );
    });

    test('未选父分类且原为二级：清空父级并降为一级', () {
      expect(
        resolveCategoryPlacement(
          selectedParentId: null,
          currentParentId: 'old-parent',
        ),
        '',
        reason: '空串是仓储约定的「清空父分类」语义',
      );
    });

    test('未选父分类且原为一级：父级不改动', () {
      expect(
        resolveCategoryPlacement(selectedParentId: null, currentParentId: null),
        null,
        reason: 'null 表示不改动 parentId',
      );
    });
  });
}
