// 导出明细 CSV 服务测试。
//
// 重点契约：数据库金额为“元”口径的 decimal 字符串（如 '12.50'），
// 导出直接保留两位小数，防止报销/对账时金额错位。

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
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

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('导出金额 = 库内 decimal 字符串元，保留两位小数', () async {
    final tx = Transaction(
      id: 'tx-1',
      ledgerId: 'led-1',
      txType: 'expense',
      amount: '12.50', // 库内 decimal 字符串元 = 12.50 元
      categoryId: null,
      happenedAt: DateTime(2026, 8, 5, 10, 30),
      note: null,
      recurringId: null,
      createdByMemberId: null,
      lastEditedByMemberId: null,
      excludeFromStats: false,
      currencyCode: 'CNY',
      nativeAmount: '12.50',
      version: 1,
      lastEditedAt: null,
      payerMemberId: null,
      aaMode: null,
      createdAt: DateTime(2026, 8, 5, 10, 30),
      updatedAt: DateTime(2026, 8, 5, 10, 30),
    );

    when(
      () => repo.transactionsWithCategoryAll(ledgerId: any(named: 'ledgerId')),
    ).thenAnswer((_) async => [(t: tx, category: null)]);
    when(() => repo.getLedgerById(any())).thenAnswer(
      (_) async => Ledger(
        id: 'led-1',
        name: '默认账本',
        currency: 'CNY',
        monthStartDay: 1,
        aaEnabled: false,
        role: 'owner',
        memberCount: 1,
        storageMode: 'local',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    when(
      () => repo.getAllCategoriesIncludingShared(),
    ).thenAnswer((_) async => <Category>[]);

    final outputDir = Directory.systemTemp.createTempSync(
      'sesame_notes_export_test',
    );
    addTearDown(() {
      if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
    });

    final result = await exportDetailCsv(
      repo: repo,
      ledgerId: 'led-1',
      labels: _labels,
      categoryLabel: (name) => name ?? '未分类',
      onProgress: (_) {},
      outputDirOverride: outputDir,
    );

    final file = outputDir.listSync().whereType<File>().firstWhere(
      (f) => f.path.contains('sesame_notes_'),
    );
    final content = await file.readAsString();
    final lines = content.split('\n');
    expect(lines, hasLength(2));

    // 表头:类型,分类,二级分类,金额,币种,备注,时间
    final dataColumns = lines[1].split(',');
    expect(dataColumns, hasLength(7));
    expect(dataColumns[3], '12.50', reason: '库内金额为元口径 decimal 字符串，导出保留两位小数');
    expect(content, isNot(contains('1250.00')));

    expect(result.path, isNotEmpty);
    expect(result.displayPath, isNotEmpty);
  });
}
