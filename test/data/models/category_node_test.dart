import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/support/category_hierarchy.dart';

void main() {
  db.Category cat({
    required String id,
    required String name,
    int level = 1,
    int sortOrder = 0,
    String? parentId,
  }) {
    return db.Category(
      cloudRegistered: false,
      id: id,
      name: name,
      kind: 'expense',
      icon: 'x',
      sortOrder: sortOrder,
      parentId: parentId,
      level: level,
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  test('findOrphanCategories：parentId 指向缺失分类', () {
    final orphans = CategoryHierarchy.findOrphanCategories([
      cat(id: 'cat-1', name: 'A'),
      cat(id: 'cat-9', name: 'sub-of-missing', level: 2, parentId: 'cat-99'),
    ]);
    expect(orphans.map((c) => c.id), ['cat-9']);
  });

  test('getUsableCategories：排除父分类与孤儿', () {
    final usable = CategoryHierarchy.getUsableCategories([
      cat(id: 'cat-1', name: 'A', sortOrder: 1),
      cat(id: 'cat-10', name: 'A1', level: 2, parentId: 'cat-1', sortOrder: 1),
      cat(id: 'cat-2', name: 'B', sortOrder: 0),
      cat(
        id: 'cat-99',
        name: 'orphan',
        level: 2,
        parentId: 'cat-88',
        sortOrder: 3,
      ),
    ]);
    expect(usable.map((c) => c.name), [
      'B',
      'A1',
    ], reason: '父分类 A 不可选、孤儿不可选、叶子 B/A1 可选且排序');
  });
}
