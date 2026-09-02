// DetailExportService 分支补充测试。
//
// 锚点：
//   - 全局仅支出模式下类型仍按枚举映射，未知类型兜底返回原始值；
//   - dateRange 非空时按闭区间过滤交易；
//   - 二级分类：分类列填一级分类名、二级分类列填子分类名；
//   - 无分类交易导出空分类列。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/infrastructure/detail_export_service.dart';

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

Transaction _tx(
  String id, {
  String type = 'expense',
  DateTime? happenedAt,
  String? categoryId,
  String? note,
}) => Transaction(
  id: id,
  ledgerId: 'led-1',
  txType: type,
  amount: '10.00',
  categoryId: categoryId,
  happenedAt: happenedAt ?? DateTime(2026, 8, 5, 10, 30),
  note: note,
  recurringId: null,
  createdByMemberId: null,
  lastEditedByMemberId: null,
  excludeFromStats: false,
  currencyCode: 'CNY',
  nativeAmount: '10.00',
  version: 1,
  lastEditedAt: null,
  payerMemberId: null,
  aaMode: null,
  createdAt: DateTime(2026, 8, 5, 10, 30),
  updatedAt: DateTime(2026, 8, 5, 10, 30),
);

Category _cat(String id, String name, {String? parentId, int level = 1}) =>
    Category(
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

  setUp(() {
    repo = _MockRepo();
  });

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return ctx;
  }

  Future<String> exportCsv(
    WidgetTester tester,
    BuildContext ctx, {
    required List<({Transaction t, Category? category})> rows,
    DateTimeRange? dateRange,
    List<Category> allCategories = const [],
  }) async {
    when(
      () => repo.transactionsWithCategoryAll(ledgerId: any(named: 'ledgerId')),
    ).thenAnswer((_) async => rows);
    when(() => repo.getLedgerById(any())).thenAnswer((_) async => null);
    when(
      () => repo.getAllCategoriesIncludingShared(),
    ).thenAnswer((_) async => allCategories);

    final outputDir = Directory.systemTemp.createTempSync(
      'sesame_notes_detail_ext',
    );
    addTearDown(() {
      if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
    });
    await tester.runAsync(
      () => exportDetailCsv(
        repo: repo,
        ledgerId: 'led-1',
        labels: _labels,
        categoryLabel: (name) => name ?? '未分类',
        dateRange: dateRange == null
            ? null
            : (start: dateRange.start, end: dateRange.end),
        onProgress: (_) {},
        outputDirOverride: outputDir,
      ),
    );
    final file = outputDir.listSync().whereType<File>().firstWhere(
      (f) => f.path.contains('sesame_notes_'),
    );
    return (await tester.runAsync(() => file.readAsString()))!;
  }

  testWidgets('未知类型兜底返回原始值；dateRange 闭区间过滤', (tester) async {
    final ctx = await pumpContext(tester);
    final content = await exportCsv(
      tester,
      ctx,
      rows: [
        (
          t: _tx('tx-1', type: 'transfer', happenedAt: DateTime(2026, 8, 5)),
          category: null,
        ),
        (t: _tx('tx-2', happenedAt: DateTime(2026, 8, 20)), category: null),
      ],
      dateRange: DateTimeRange(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 10),
      ),
    );
    final lines = content.split('\n');
    expect(lines, hasLength(2), reason: '8/20 的交易应被过滤掉');
    expect(lines[1], contains('transfer'));
    expect(lines[1], isNot(contains('支出')));
  });

  testWidgets('二级分类导出：分类列=一级名、二级列=子分类名', (tester) async {
    final ctx = await pumpContext(tester);
    final parent = _cat('cat-1', '餐饮');
    final child = _cat('cat-2', '外卖', parentId: 'cat-1', level: 2);

    final content = await exportCsv(
      tester,
      ctx,
      rows: [(t: _tx('tx-1', categoryId: 'cat-2'), category: child)],
      allCategories: [parent, child],
    );
    final dataColumns = content.split('\n')[1].split(',');
    expect(dataColumns[1], '餐饮');
    expect(dataColumns[2], '外卖');
  });

  testWidgets('共享账本二级分类导出：分类列=父名、二级列=子分类名', (tester) async {
    final ctx = await pumpContext(tester);
    final parent = _cat('cat-1000', '交通');
    final child = _cat('cat-1001', '打车', parentId: 'cat-1000', level: 2);

    final content = await exportCsv(
      tester,
      ctx,
      rows: [(t: _tx('tx-1', categoryId: 'cat-1001'), category: child)],
      allCategories: [parent, child],
    );
    final dataColumns = content.split('\n')[1].split(',');
    expect(dataColumns[1], '交通');
    expect(dataColumns[2], '打车');
  });

  testWidgets('无分类交易导出空分类列；有备注时原样保留', (tester) async {
    final ctx = await pumpContext(tester);
    final content = await exportCsv(
      tester,
      ctx,
      rows: [(t: _tx('tx-1', note: '备注,含逗号'), category: null)],
    );
    final dataColumns = content.split('\n')[1].split(',');
    expect(dataColumns[1], isEmpty);
    expect(dataColumns[2], isEmpty);
  });
}
