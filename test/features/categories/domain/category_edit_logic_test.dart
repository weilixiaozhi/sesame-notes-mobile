import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/categories/domain/category_edit_logic.dart';

/// 分类领域只依赖可用名称集合，不加载 Flutter 图标实现。
void main() {
  const availableIconKeys = {'category', 'utensils'};
  group('resolveCategoryFormIcon 表单初始图标', () {
    test('新建分类（无图标）回退默认图标', () {
      expect(
        resolveCategoryFormIcon(null, availableIconKeys: availableIconKeys),
        'category',
      );
      expect(
        resolveCategoryFormIcon('', availableIconKeys: availableIconKeys),
        'category',
      );
    });

    test('已有分类的有效图标原样沿用', () {
      expect(
        resolveCategoryFormIcon(
          'utensils',
          availableIconKeys: availableIconKeys,
        ),
        'utensils',
      );
    });

    test('图标不在图标库中时回退默认图标', () {
      expect(
        resolveCategoryFormIcon(
          'not-a-lucide-icon',
          availableIconKeys: availableIconKeys,
        ),
        'category',
      );
    });
  });

  group('resolveCategoryPlacement 保存时的父子落点', () {
    test('选中父分类：挂到该父下并置为二级', () {
      expect(
        resolveCategoryPlacement(selectedParentId: 'cat-10', currentLevel: 1),
        (parentId: 'cat-10', level: 2),
      );
    });

    test('未选父分类且原为二级：清空父级并降为一级', () {
      expect(
        resolveCategoryPlacement(selectedParentId: null, currentLevel: 2),
        (parentId: '', level: 1),
        reason: '空串是仓储约定的「清空父分类」语义',
      );
    });

    test('未选父分类且原为一级：父级不改动', () {
      expect(
        resolveCategoryPlacement(selectedParentId: null, currentLevel: 1),
        (parentId: null, level: 1),
        reason: 'null 表示不改动 parentId',
      );
    });
  });
}
