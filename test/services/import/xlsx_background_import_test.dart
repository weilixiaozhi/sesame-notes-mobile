import 'dart:async';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/xlsx_reader.dart';

import '../../helpers/test_isolation.dart';
import '../../helpers/test_platform_file.dart';

/// 使用真实导入入口，验证工作线程转换不阻塞主事件循环且保持异常语义。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
  });

  test('一万行工作簿转换期间主事件循环持续响应', () async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Sheet1'];
    sheet.appendRow([
      TextCellValue('日期'),
      TextCellValue('金额'),
      TextCellValue('备注'),
    ]);
    for (var i = 0; i < 10000; i++) {
      sheet.appendRow([
        TextCellValue('2026-09-21'),
        IntCellValue(i),
        TextCellValue('账单$i'),
      ]);
    }
    final file = TestPlatformFile(
      name: 'large.xlsx',
      bytes: workbook.encode()!,
    );
    final container = ProviderContainer();
    var ticks = 0;
    final timer = Timer.periodic(
      const Duration(milliseconds: 1),
      (_) => ticks++,
    );
    try {
      final text = await container
          .read(importActionsProvider)
          .readFile(file, isCancelled: () => false, onProgress: (_) {});
      expect(ticks, greaterThan(1), reason: '转换完成前主事件循环必须能多次响应');
      expect(text.split('\n'), hasLength(10001));
      expect(text, contains('账单9999'));
    } finally {
      timer.cancel();
      container.dispose();
      await logger.clear();
    }
  });

  test('工作线程的公式异常保持应用可识别类型', () async {
    final workbook = Excel.createExcel();
    workbook['Sheet1'].updateCell(
      CellIndex.indexByString('A1'),
      const FormulaCellValue('=SUM(B1:B2)'),
    );
    final container = ProviderContainer();
    try {
      await expectLater(
        container
            .read(importActionsProvider)
            .readFile(
              TestPlatformFile(name: 'formula.xlsx', bytes: workbook.encode()!),
              isCancelled: () => false,
              onProgress: (_) {},
            ),
        throwsA(isA<ImportFileFormulaException>()),
      );
      await expectLater(
        XlsxReader.convertXlsxToCSVAsync(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<XlsxDecodeException>()),
      );
    } finally {
      container.dispose();
      await logger.clear();
    }
  });
}
