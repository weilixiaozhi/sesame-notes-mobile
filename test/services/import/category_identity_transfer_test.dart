import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/features/settings/infrastructure/ledger_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart'
    show transferId;
import 'dart:convert';

/// 文件分类来源身份和目标身份分别冻结，重名来源不会先被名称集合吞并。
void main() {
  test('分类来源指纹和导入身份与网页黄金向量一致', () {
    final hash = ledgerCategoryFileHash([
      {
        'date': '2026-09-30',
        'type': 'expense',
        'amount': '1',
        'currency': 'CNY',
        'category': '餐饮',
        'sub_category': '午餐',
        'category_icon': 'utensils',
        'sub_category_icon': 'soup',
      },
    ]);
    expect(
      hash,
      'f46b1764dc81c6da12e396c2cb064615f0efd5375337e3c6f3df0558f2b7c0c0',
    );
    expect(
      transferId([
        'category-import',
        'd4d1c885-9a7a-4c87-968e-70b7dbe565f5',
        jsonEncode(['category-row', hash, 0]),
      ]),
      '1bff8a1e-d503-4b13-89a5-b934c372502b',
    );
  });
  const fields = [
    'date',
    'amount',
    'category',
    'sub_category',
    'category_scope',
    'category_id',
    'parent_category_id',
  ];
  const rows = [
    ['2026-10-29', '10', '餐饮', '午餐', 'account:owner', 'child-a', 'parent-a'],
    ['2026-10-29', '20', '餐饮', '午餐', 'account:owner', 'child-b', 'parent-b'],
  ];
  final mapped = [
    for (final row in rows)
      {for (var i = 0; i < fields.length; i++) fields[i]: row[i]},
  ];
  final hash = ledgerCategoryFileHash(mapped);

  test('来源父分类身份等于自身时拒绝该行，不丢弃子草稿后误绑父分类', () {
    final bad = <String, int>{};
    final data = buildLedgerImportData(
      rows: const [
        ['2026-10-29', '10', '餐饮', '午餐', 'account:owner', 'same-id', 'same-id'],
      ],
      dataStart: 0,
      targetLedgerId: 'target',
      mapping: {for (var i = 0; i < fields.length; i++) fields[i]: i},
      categoryMapping: const {},
      skippedTypes: {},
      badRows: bad,
    );
    expect(data.transactions, isEmpty);
    expect(data.categories, isEmpty);
    expect(bad.values.single, 1);
  });

  test('同一来源身份的父关系或内容不一致时坏行不遗留孤儿父草稿', () {
    final bad = <String, int>{};
    final data = buildLedgerImportData(
      rows: const [
        [
          '2026-10-29',
          '10',
          '餐饮',
          '午餐',
          'account:owner',
          'same-child',
          'parent-a',
        ],
        [
          '2026-10-29',
          '20',
          '购物',
          '晚餐',
          'account:owner',
          'same-child',
          'parent-b',
        ],
      ],
      dataStart: 0,
      targetLedgerId: 'target',
      mapping: {for (var i = 0; i < fields.length; i++) fields[i]: i},
      categoryMapping: const {},
      skippedTypes: {},
      badRows: bad,
    );
    expect(data.transactions, hasLength(1));
    expect(data.categories.map((c) => c.name), ['餐饮', '午餐']);
    expect(bad.values.single, 1);
  });

  test('同名父子来源按 ID 独立新建并在重试中保持全部身份', () {
    final sources = [
      for (var i = 0; i < mapped.length; i++)
        ledgerImportCategorySource(mapped[i], fileHash: hash, rowIndex: i)!,
    ];
    final mapping = {
      for (final source in sources) source: importCreateCategory,
    };
    ImportData build() => buildLedgerImportData(
      rows: rows,
      dataStart: 0,
      targetLedgerId: 'target',
      mapping: {for (var i = 0; i < fields.length; i++) fields[i]: i},
      categoryMapping: mapping,
      requireExplicitMapping: true,
      skippedTypes: {},
      badRows: {},
      categorySourceHash: hash,
    );
    final first = build();
    final retry = build();
    expect(first.categories, hasLength(4));
    expect(first.categories.map((c) => c.id).toSet(), hasLength(4));
    expect(
      first.categories.map((c) => c.id),
      retry.categories.map((c) => c.id),
    );
    expect(
      first.transactions.map((t) => t.categorySourceKey).toSet(),
      hasLength(2),
    );
    final children = first.categories.where((c) => c.level == 2).toList();
    expect(children[0].parentId, isNot(children[1].parentId));
  });

  test('缺来源身份的同名行必须分别选择，不能自动认领名称', () {
    final legacy = [
      {'category': '餐饮'},
      {'category': '餐饮'},
    ];
    final a = ledgerImportCategorySource(
      legacy[0],
      fileHash: 'file',
      rowIndex: 0,
    )!;
    final b = ledgerImportCategorySource(
      legacy[1],
      fileHash: 'file',
      rowIndex: 1,
    )!;
    expect(a, isNot(b));
    final bad = <String, int>{};
    final data = buildLedgerImportData(
      rows: rows,
      dataStart: 0,
      targetLedgerId: 'target',
      mapping: {for (var i = 0; i < fields.length; i++) fields[i]: i},
      categoryMapping: const {},
      requireExplicitMapping: true,
      skippedTypes: {},
      badRows: bad,
    );
    expect(data.transactions, isEmpty);
    expect(data.categories, isEmpty);
    expect(bad.values.single, 2);
  });
}
