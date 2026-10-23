import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:sesame_notes/features/settings/infrastructure/parsers/csv_parser.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/xlsx_reader.dart';

/// 在工作簿里补上 Excel、WPS 会写出的内置数字格式声明（numFmtId 41）。
///
/// 内置格式按规范不需要重新定义，但 Excel、WPS 会冗余写进 xl/styles.xml，
/// excel 包把这种写法当错误抛出，导致整份文件导入失败。
Uint8List _withBuiltInNumFormats(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes, verify: false);
  final styles = archive.findFile('xl/styles.xml')!;
  final document = XmlDocument.parse(utf8.decode(styles.content as List<int>));
  document.rootElement.children.insert(
    0,
    XmlElement(
      XmlName('numFmts'),
      <XmlAttribute>[XmlAttribute(XmlName('count'), '1')],
      <XmlNode>[
        XmlElement(XmlName('numFmt'), <XmlAttribute>[
          XmlAttribute(XmlName('numFmtId'), '41'),
          XmlAttribute(
            XmlName('formatCode'),
            '_ * #,##0_ ;_ * \\-#,##0_ ;_ * "-"_ ;_ @_ ',
          ),
        ]),
      ],
    ),
  );
  final content = Uint8List.fromList(utf8.encode(document.toXmlString()));
  archive.addFile(ArchiveFile('xl/styles.xml', content.length, content));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// 删掉共享字符串部件及其关系，模拟只有数字、日期的工作簿（这类工作簿不带该部件）。
Uint8List _withoutSharedStrings(Uint8List bytes) {
  final source = ZipDecoder().decodeBytes(bytes, verify: false);
  final archive = Archive();
  for (final file in source.files) {
    if (file.name == 'xl/sharedStrings.xml') continue;
    final content = Uint8List.fromList(file.content as List<int>);
    archive.addFile(ArchiveFile(file.name, content.length, content));
  }
  final rels = archive.findFile('xl/_rels/workbook.xml.rels')!;
  final document = XmlDocument.parse(utf8.decode(rels.content as List<int>));
  for (final node in document.findAllElements('Relationship').toList()) {
    if ((node.getAttribute('Type') ?? '').endsWith('/sharedStrings')) {
      node.parent?.children.remove(node);
    }
  }
  final content = Uint8List.fromList(utf8.encode(document.toXmlString()));
  archive.addFile(
    ArchiveFile('xl/_rels/workbook.xml.rels', content.length, content),
  );
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

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

  test('字符串公式字面量还原双引号转义', () {
    final excel = Excel.createExcel();
    excel['Sheet1'].updateCell(
      CellIndex.indexByString('A1'),
      const FormulaCellValue('"say ""hi"""'),
    );
    final csv = XlsxReader.convertXlsxToCSV(
      Uint8List.fromList(excel.encode()!),
    );
    expect(CsvParser.parse(csv), [
      ['say "hi"'],
    ]);
  });

  test('以引号开头和结尾的公式表达式不能伪装成字面量', () {
    final excel = Excel.createExcel();
    excel['Sheet1'].updateCell(
      CellIndex.indexByString('A1'),
      const FormulaCellValue('"a"&"b"'),
    );
    expect(
      () => XlsxReader.convertXlsxToCSV(Uint8List.fromList(excel.encode()!)),
      throwsA(isA<XlsxFormulaException>()),
    );
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

  test('Excel、WPS 冗余声明内置数字格式时仍能导入', () {
    final excel = Excel.createExcel();
    excel['Sheet1'].appendRow([TextCellValue('名称'), TextCellValue('妈妈生日')]);
    final bytes = _withBuiltInNumFormats(Uint8List.fromList(excel.encode()!));

    expect(CsvParser.parse(XlsxReader.convertXlsxToCSV(bytes)), [
      ['名称', '妈妈生日'],
    ]);
  });

  test('缺少共享字符串部件的工作簿仍能导入', () {
    final excel = Excel.createExcel();
    excel['Sheet1'].appendRow([IntCellValue(12), DoubleCellValue(2.5)]);
    final bytes = _withoutSharedStrings(Uint8List.fromList(excel.encode()!));

    expect(CsvParser.parse(XlsxReader.convertXlsxToCSV(bytes)), [
      ['12', '2.5'],
    ]);
  });

  test('不是 xlsx 的文件给出可执行的修复提示', () {
    final text = Uint8List.fromList(utf8.encode('名称,日期\n生日,2026-09-14'));

    expect(
      () => XlsxReader.convertXlsxToCSV(text),
      throwsA(
        isA<XlsxDecodeException>().having(
          (e) => e.message,
          'message',
          contains('Excel 工作簿'),
        ),
      ),
    );
  });
}
