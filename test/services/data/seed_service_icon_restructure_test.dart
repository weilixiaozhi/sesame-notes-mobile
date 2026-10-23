import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/theme/icons/category_icons.dart';

void main() {
  group('分类默认图标', () {
    test('所有 seed 分类 key 的默认图标均命中 lucideIconLibrary（零回退）', () {
      // 合并一级 + 二级分类的所有 key，确保无任何 key 回退到 'category' 兜底
      final allKeys = <String>{
        ...SeedService.flatExpenseCategoryKeys,
        ...SeedService.hierarchicalExpenseCategories.values.expand((c) => c),
        ...SeedService.hierarchicalExpenseCategories.keys,
      };

      final gaps = <String>[];
      for (final key in allKeys) {
        final iconName = SeedService.getDefaultIcon(key);
        if (!lucideIconLibrary.containsKey(iconName)) {
          gaps.add('key="$key" → icon="$iconName" 未在注册表中登记');
        }
      }

      expect(
        gaps,
        isEmpty,
        reason: '存在未登记图标，运行时会回退到兜底图标: \n${gaps.join('\n')}',
      );
    });

    test('未知 key 回退到 category 兜底图标名', () {
      // 边界条件：传入不存在的 key，应返回 'category' 而非 null
      expect(
        SeedService.getDefaultIcon('non_existent_key_xyz'),
        'category',
        reason: '未知 key 应回退到 "category" 默认图标名',
      );
    });
  });

  group('确定性 syncId 计算 (deterministicCategorySyncId)', () {
    test('相同 level/key 产生相同 syncId（确定性）', () {
      final id1 = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );
      final id2 = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );

      expect(id1, id2, reason: '相同输入必须产生相同 syncId（UUID v5 确定性）');
    });

    test('不同 level 产生不同 syncId（level 参与哈希）', () {
      // syncId 把 level 掺入哈希，同 key 不同 level 算出不同 syncId。
      // 这保证一级「dining」和二级「dining」不会因 syncId 碰撞被云端去重。
      final level1Id = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'shopping_shoes',
      );
      final level2Id = SeedService.deterministicCategorySyncId(
        level: 2,
        key: 'shopping_shoes',
      );

      expect(
        level1Id,
        isNot(equals(level2Id)),
        reason: '同 key 不同 level 必须产生不同 syncId，防止跨层级碰撞去重',
      );
    });

    test('不同 key 产生不同 syncId', () {
      final id1 = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'transport',
      );
      final id2 = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );

      expect(id1, isNot(equals(id2)), reason: '不同 key 必须产生不同 syncId');
    });

    test('syncId 为合法 UUID v5 格式', () {
      final id = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'dining',
      );

      // UUID v5 格式：8-4-4-4-12，version 位为 5
      expect(id.length, 36, reason: 'UUID 字符串长度应为 36（含 4 个连字符）');
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(id),
        isTrue,
        reason: '应为合法 UUID v5 格式（version=5）',
      );
    });
  });
}
