import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/detail_export_service.dart';
import '../../helpers/test_isolation.dart';

const _labels = (
  type: '类型',
  category: '分类',
  subCategory: '二级分类',
  amount: '金额',
  currency: '币种',
  note: '备注',
  time: '时间',
  expense: '支出',
);

class _MockRepo extends Mock implements LocalRepository {}

/// 分类查询独立注入，导入导出不能依赖组合仓储的查询转发。
class _CategoryQueries extends Mock implements CategoryQueryRepository {}

/// 构造带完整金额快照的支出交易。
Transaction _tx(
  String id, {
  String type = 'expense',
  String amount = '10.00',
  DateTime? happenedAt,
  String? categoryId,
  String? note,
}) => Transaction(
  id: id,
  ledgerId: 'led-1',
  txType: type,
  amount: amount,
  categoryId: categoryId,
  happenedAt: happenedAt ?? DateTime(2026, 8, 5, 10, 30),
  note: note,
  recurringId: null,
  createdByMemberId: null,
  lastEditedByMemberId: null,
  currencyCode: 'CNY',
  nativeAmount: amount,
  version: 1,
  lastEditedAt: null,
  payerMemberId: null,
  aaMode: null,
  createdAt: DateTime(2026, 8, 5, 10, 30),
  updatedAt: DateTime(2026, 8, 5, 10, 30),
);

/// 构造指定层级与父分类的分类记录。
Category _cat(String id, String name, {String? parentId, int level = 1}) =>
    Category(
      cloudRegistered: false,
      id: id,
      name: name,
      kind: 'expense',
      icon: null,
      sortOrder: 0,
      parentId: parentId,
      level: level,
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late _CategoryQueries categoryQueries;

  setUp(() {
    resetGlobalTestState();
    repo = _MockRepo();
    categoryQueries = _CategoryQueries();
    when(() => repo.getLedgerById('led-1')).thenAnswer(
      (_) async => Ledger(
        id: 'led-1',
        name: '本地账本',
        currency: 'CNY',
        monthStartDay: 1,
        aaEnabled: false,
        role: 'owner',
        memberCount: 1,
        storageMode: 'local',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
  });

  /// 将注入的交易与分类导出到临时目录并读取 CSV 内容。
  Future<({String content, DetailExportResult result})> exportCsv({
    required List<({Transaction t, Category? category})> rows,
    DetailExportDateRange? dateRange,
    List<Category> allCategories = const [],
  }) async {
    when(
      () => repo.transactionsWithCategoryAll(ledgerId: any(named: 'ledgerId')),
    ).thenAnswer((_) async => rows);
    when(
      () => categoryQueries.getAllCategoriesIncludingShared(ledgerId: 'led-1'),
    ).thenAnswer((_) async => allCategories);

    final taskTemp = Directory('Temp')..createSync(recursive: true);
    final outputDir = taskTemp.createTempSync('detail-export-');
    addTearDown(() {
      if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
    });
    final result = await exportDetailCsv(
      repo: repo,
      categoryQueries: categoryQueries,
      ledgerId: 'led-1',
      labels: _labels,
      categoryLabel: (name) => name ?? '未分类',
      dateRange: dateRange,
      onProgress: (_) {},
      business: '记账',
      ledgerName: '默认账本',
      outputDirectory: outputDir,
    );
    final file = outputDir.listSync().whereType<File>().firstWhere(
      (f) => f.path.contains('sesame_notes_'),
    );
    return (content: await file.readAsString(), result: result);
  }

  for (final type in ['income', 'transfer', 'custom']) {
    test('明细导出拒绝 $type 且不生成文件', () async {
      final taskTemp = Directory('Temp')..createSync(recursive: true);
      final outputDir = taskTemp.createTempSync('expense-export-');
      addTearDown(() => outputDir.deleteSync(recursive: true));
      when(
        () => repo.transactionsWithCategoryAll(ledgerId: 'led-1'),
      ).thenAnswer(
        (_) async => [(t: _tx('tx-invalid', type: type), category: null)],
      );
      when(
        () =>
            categoryQueries.getAllCategoriesIncludingShared(ledgerId: 'led-1'),
      ).thenAnswer((_) async => []);

      await expectLater(
        exportDetailCsv(
          repo: repo,
          categoryQueries: categoryQueries,
          ledgerId: 'led-1',
          labels: _labels,
          categoryLabel: (name) => name ?? '',
          onProgress: (_) {},
          business: '记账',
          ledgerName: '默认账本',
          outputDirectory: outputDir,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(outputDir.listSync(), isEmpty);
    });
  }

  test('支出类型使用本地化文案；dateRange 闭区间过滤', () async {
    final (:content, result: _) = await exportCsv(
      rows: [
        (t: _tx('tx-1', happenedAt: DateTime(2026, 8, 5)), category: null),
        (t: _tx('tx-2', happenedAt: DateTime(2026, 8, 20)), category: null),
      ],
      dateRange: (start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 10)),
    );
    final lines = content.split('\n');
    expect(lines, hasLength(2), reason: '8/20 的交易应被过滤掉');
    expect(lines[1], contains('支出'));
  });

  test('二级分类导出：分类列=一级名、二级列=子分类名', () async {
    final parent = _cat('cat-1', '餐饮');
    final child = _cat('cat-2', '外卖', parentId: 'cat-1', level: 2);

    final (:content, result: _) = await exportCsv(
      rows: [(t: _tx('tx-1', categoryId: 'cat-2'), category: child)],
      allCategories: [parent, child],
    );
    final dataColumns = content.split('\n')[1].split(',');
    expect(dataColumns[1], '餐饮');
    expect(dataColumns[2], '外卖');
  });

  test('无分类交易导出空分类列；有备注时原样保留', () async {
    final (:content, result: _) = await exportCsv(
      rows: [(t: _tx('tx-1', note: '备注,含逗号'), category: null)],
    );
    final dataColumns = content.split('\n')[1].split(',');
    expect(dataColumns[1], isEmpty);
    expect(dataColumns[2], isEmpty);
  });

  test('导出金额 = 库内 decimal 字符串元，保留两位小数', () async {
    final (:content, :result) = await exportCsv(
      rows: [(t: _tx('tx-1', amount: '12.50'), category: null)],
    );
    final lines = content.split('\n');
    expect(lines, hasLength(2));

    // 表头:类型,分类,二级分类,金额,币种,备注,时间
    final dataColumns = lines[1].split(',');
    expect(dataColumns, hasLength(12));
    expect(dataColumns[3], '12.50', reason: '库内金额为元口径 decimal 字符串，导出保留两位小数');
    expect(content, isNot(contains('1250.00')));

    expect(result.path, isNotEmpty);
    expect(result.displayPath, isNotEmpty);
  });

  for (final amount in ['999999999999999999.99', '1.123456789']) {
    test('导出金额 $amount 保留完整十进制数值', () async {
      final (:content, result: _) = await exportCsv(
        rows: [(t: _tx('precise', amount: amount), category: null)],
      );
      expect(content.split('\n')[1].split(',')[3], amount);
    });
  }
}
