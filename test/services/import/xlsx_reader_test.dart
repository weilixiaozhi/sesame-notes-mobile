// XLSX 公式单元格读取测试。
//
// 契约：无缓存结果的公式不能以 =SUM(...) 形式混入导入；
// 字面量公式（如 =3.14）可直接当值输出。

import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/infrastructure/parsers/csv_parser.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/xlsx_reader.dart';

void main() {
  test('公式单元格无缓存结果时报清晰错误', () {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow([TextCellValue('金额')]);
    sheet.updateCell(
      CellIndex.indexByString('A2'),
      const FormulaCellValue('=SUM(A1:A2)'),
    );
    final bytes = excel.encode()!;

    expect(
      () => XlsxReader.convertXlsxToCSV(Uint8List.fromList(bytes)),
      throwsA(isA<XlsxFormulaException>()),
    );
  });

  test('公式字面量可直接当值输出', () {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.updateCell(
      CellIndex.indexByString('A1'),
      const FormulaCellValue('3.14'),
    );
    final bytes = excel.encode()!;

    final csv = XlsxReader.convertXlsxToCSV(Uint8List.fromList(bytes));
    expect(csv, contains('3.14'));
    expect(csv, isNot(contains('=')));
  });

  test('首个工作表为空时读取后续唯一非空工作表', () {
    final excel = Excel.createExcel();
    excel['账单'].appendRow([TextCellValue('日期'), TextCellValue('金额')]);
    excel['账单'].appendRow([TextCellValue('2026-01-01'), IntCellValue(12)]);

    final csv = XlsxReader.convertXlsxToCSV(
      Uint8List.fromList(excel.encode()!),
    );

    expect(CsvParser.parse(csv), [
      ['日期', '金额'],
      ['2026-01-01', '12'],
    ]);
  });

  test('所有工作表都为空时报清晰错误', () {
    final excel = Excel.createExcel()..getDefaultSheet();
    excel['空表2'];

    expect(
      () => XlsxReader.convertXlsxToCSV(Uint8List.fromList(excel.encode()!)),
      throwsA(predicate((e) => e.toString().contains('工作表为空'))),
    );
  });

  test('多个工作表都有数据时明确拒绝猜测导入目标', () {
    final excel = Excel.createExcel();
    excel['Sheet1'].appendRow([TextCellValue('第一张表')]);
    excel['账单'].appendRow([TextCellValue('第二张表')]);

    expect(
      () => XlsxReader.convertXlsxToCSV(Uint8List.fromList(excel.encode()!)),
      throwsA(predicate((e) => e.toString().contains('多个非空工作表'))),
    );
  });

  test('XLSX 换行单元格经 CSV 解析后仍是一条记录', () {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow([TextCellValue('备注'), TextCellValue('金额')]);
    sheet.appendRow([TextCellValue('第一行\n第二行'), IntCellValue(12)]);

    final csv = XlsxReader.convertXlsxToCSV(
      Uint8List.fromList(excel.encode()!),
    );

    expect(CsvParser.parse(csv), [
      ['备注', '金额'],
      ['第一行\n第二行', '12'],
    ]);
  });
}
