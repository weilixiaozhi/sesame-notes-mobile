import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/features/settings/infrastructure/ledger_transfer.dart';

/// 标准账单表：日期/类型/金额/币种/分类/备注。
const _mapping = <String, int?>{
  'date': 0,
  'type': 1,
  'amount': 2,
  'currency': 3,
  'category': 4,
  'note': 5,
};

/// 带二级分类与图标列的账单表。
const _mappingWithIcons = <String, int?>{
  'date': 0,
  'type': 1,
  'amount': 2,
  'currency': 3,
  'category': 4,
  'sub_category': 5,
  'category_icon': 6,
  'sub_category_icon': 7,
};

/// 坏行（坏日期、坏金额）与跳过类型（收入）混在合法行里。
const _rowsWithBadLines = <List<String>>[
  ['日期', '类型', '金额', '币种', '分类'],
  ['2026-01-01', '支出', '12.50', 'CNY', '餐饮'],
  ['2026-01-02', '收入', '20.00', 'CNY', '红包'],
  ['bad-date', '支出', '5.00', 'CNY', '餐饮'],
  ['2026-01-04', '支出', 'abc', 'CNY', '交通'],
];

void main() {
  group('parseImportAmount 金额解析', () {
    test('非法千分位分组一律拒绝', () {
      for (final raw in [
        '12,34',
        '1,23,456',
        '1,2345',
        '12,345,67',
        ',123',
        '1,234,',
        '1,,234',
      ]) {
        expect(parseImportAmount(raw), isNull, reason: '$raw 不是合法千分位分组');
      }
    });

    test('货币符号前缀剥离后按数值解析', () {
      for (final raw in [r'$100', '¥100', '€100', '£100']) {
        expect(parseImportAmount(raw)?.toString(), '100', reason: raw);
      }
      expect(parseImportAmount(r'$1,234.50')?.toString(), '1234.5');
    });

    test('合法千分位按精确 Decimal 归一', () {
      expect(parseImportAmount('1,234.50')?.toString(), '1234.5');
      expect(parseImportAmount('123,456,789')?.toString(), '123456789');
      expect(parseImportAmount('1234.5')?.toString(), '1234.5');
      expect(parseImportAmount('  12.50  ')?.toString(), '12.5');
    });

    test('括号与正负号只剥离符号，数值始终为正', () {
      expect(parseImportAmount('(100)')?.toString(), '100');
      expect(parseImportAmount('(1,234.50)')?.toString(), '1234.5');
      expect(parseImportAmount('-100')?.toString(), '100');
      expect(parseImportAmount('+100')?.toString(), '100');
      expect(parseImportAmount('100)'), isNull);
      expect(parseImportAmount('(100'), isNull);
    });

    test('空值、非正数与畸形写法一律拒绝', () {
      for (final raw in [
        '',
        '   ',
        'abc',
        '0',
        '0.00',
        '-0',
        '1.2.3',
        '100.',
        '.5',
        '1e3',
        '12元',
      ]) {
        expect(parseImportAmount(raw), isNull, reason: '$raw 不是合法正数金额');
      }
    });
  });

  group('buildLedgerImportData 账单构建', () {
    ImportData build(
      List<List<String>> rows, {
      Map<String, int?> mapping = _mapping,
      Map<String, int>? badRows,
      Map<String, int>? skippedTypes,
    }) => buildLedgerImportData(
      rows: rows,
      dataStart: 1,
      targetLedgerId: 'ledger-1',
      mapping: mapping,
      categoryMapping: const {},
      skippedTypes: skippedTypes ?? {},
      badRows: badRows ?? {},
    );

    test('坏日期、坏金额与非支出类型行跳过，只构建有效记录', () {
      final badRows = <String, int>{};
      final skippedTypes = <String, int>{};

      final data = build(
        _rowsWithBadLines,
        badRows: badRows,
        skippedTypes: skippedTypes,
      );

      expect(data.transactions, hasLength(1), reason: '只有一行完全合法');
      final tx = data.transactions.single;
      expect(tx.amount.toString(), '12.5');
      expect(tx.type, 'expense');
      expect(tx.currencyCode, 'CNY');
      expect(tx.categoryName, '餐饮');
      expect(tx.happenedAt.year, 2026);
      expect(tx.happenedAt.month, 1);
      expect(tx.happenedAt.day, 1);
      expect(badRows, {'amount': 1, 'date': 1});
      expect(skippedTypes, {'收入': 1});
      expect(data.categories.map((category) => category.name), [
        '餐饮',
      ], reason: '坏行不得创建孤儿分类');
    });

    test('分类图标列按层级透传到分类创建', () {
      const rows = <List<String>>[
        ['日期', '类型', '金额', '币种', '分类', '二级分类', '分类图标', '二级分类图标'],
        ['2026-01-01', '支出', '18.00', 'CNY', '餐饮', '主食', '🍜', '🍚'],
      ];

      final data = build(rows, mapping: _mappingWithIcons);

      expect(data.transactions, hasLength(1));
      expect(data.transactions.single.categoryParentName, '餐饮');
      expect(data.transactions.single.categoryName, '主食');
      expect(data.categories, hasLength(2));
      expect(
        data.categories.map(
          (category) => (
            category.level,
            category.name,
            category.icon,
            category.parentName,
          ),
        ),
        [(1, '餐饮', '🍜', null), (2, '主食', '🍚', '餐饮')],
        reason: '一级分类先建、图标列逐层透传',
      );
    });

    test('非法时区偏移计为坏日期行，不产生交易或分类', () {
      final badRows = <String, int>{};
      final data = build(const [
        ['日期', '类型', '金额', '币种', '分类', '备注'],
        ['2026-09-27T12:00:00+08:00', '支出', '10', 'CNY', '餐饮', '合法'],
        ['2026-09-27T12:00:00+99:99', '支出', '20', 'CNY', '错误分类甲', ''],
        ['2026-09-27T12:00:00-0060', '支出', '30', 'CNY', '错误分类乙', ''],
      ], badRows: badRows);

      expect(badRows, {'date': 2});
      expect(data.transactions, hasLength(1));
      expect(
        data.transactions.single.happenedAt.toUtc(),
        DateTime.utc(2026, 9, 27, 4),
      );
      expect(data.categories.map((category) => category.name), ['餐饮']);
    });

    test('千分位合法的金额按精确 Decimal 进入记录', () {
      final data = build(const <List<String>>[
        ['日期', '类型', '金额', '币种', '分类'],
        ['2026-01-01', '支出', '€1,234.50', 'CNY', '餐饮'],
      ]);

      expect(data.transactions.single.amount.toString(), '1234.5');
    });
  });
}
