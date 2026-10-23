import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

/// XLSX 含无法求值的公式单元格时抛出。
///
/// 与普通解析错误区分：调用方据此展示「请先在 Excel 中另存为值」的专用
/// 提示，而不是笼统的「操作失败」。公式在 Excel 中另存为值后即可正常导入。
class XlsxFormulaException implements Exception {
  final String formula;
  const XlsxFormulaException(this.formula);

  @override
  String toString() => '公式单元格无法取到计算结果: $formula，请先在 Excel 中另存为值';
}

/// XLSX 结构不合法时抛出，[message] 直接面向用户。
class XlsxDecodeException extends FormatException {
  const XlsxDecodeException(super.message);
}

/// XLSX 文件读取工具
///
/// 将 Excel 文件转换为 CSV 格式字符串，便于后续使用现有的 CSV 解析逻辑
class XlsxReader {
  /// 使用静态函数进入工作 isolate，只传递文件字节，不捕获页面或容器引用。
  static Future<String> convertXlsxToCSVAsync(Uint8List bytes) async {
    try {
      return await compute(convertXlsxToCSV, bytes, debugLabel: 'xlsx-import');
    } catch (_) {
      // 保持公式与格式异常类型，调用方据此展示具体的导入失败原因。
      rethrow;
    }
  }

  /// 自定义数字格式的起始 id；小于该值的 numFmtId 都是 Excel 内置格式。
  static const _firstCustomNumFmtId = 164;

  /// 空共享字符串表：表格里没有文本单元格时用它补全缺失的部件。
  static const _emptySharedStrings =
      '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="0" uniqueCount="0"/>';

  static const _sharedStringsRelationship =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings';

  /// 读取 XLSX 文件字节并转换为 CSV 格式字符串
  ///
  /// 参数:
  /// - [bytes]: XLSX 文件的字节数据
  ///
  /// 返回:
  /// - CSV 格式的字符串，每行用 \n 分隔，字段用逗号分隔
  static String convertXlsxToCSV(Uint8List bytes) {
    try {
      // 解码 Excel 文件；解码前先修掉会让解析器整体报错的工作簿写法
      final excel = Excel.decodeBytes(_repairWorkbook(bytes));

      if (excel.tables.isEmpty) {
        throw const XlsxDecodeException('Excel 文件为空或无法读取');
      }

      // 只自动选择唯一有实际单元格值的工作表：空的默认 Sheet1 不应挡住
      // 后续账单表，多张有数据时也不能擅自丢弃其中任意一张。
      final nonEmptySheets = excel.tables.values.where((sheet) {
        return sheet.rows.any(
          (row) => row.any((cell) {
            final value = cell?.value;
            return value != null && value.toString().trim().isNotEmpty;
          }),
        );
      }).toList();
      if (nonEmptySheets.isEmpty) {
        throw const XlsxDecodeException('工作表为空，没有可导入的数据');
      }
      if (nonEmptySheets.length > 1) {
        throw const XlsxDecodeException('存在多个非空工作表，请仅保留一个账单工作表后重试');
      }
      final sheet = nonEmptySheets.single;

      // 转换为 CSV 格式
      final csvLines = <String>[];

      for (final row in sheet.rows) {
        final fields = row.map((cell) {
          // 获取单元格值
          final value = cell?.value;

          if (value == null) {
            return '';
          }

          // 转换为字符串
          String text;
          if (value is SharedString) {
            text = value.toString();
          } else if (value is TextCellValue) {
            text = value.value.toString();
          } else if (value is IntCellValue) {
            text = value.value.toString();
          } else if (value is DoubleCellValue) {
            text = value.value.toString();
          } else if (value is BoolCellValue) {
            text = value.value.toString();
          } else if (value is DateCellValue) {
            // 日期格式化为 YYYY-MM-DD
            final date = value.asDateTimeLocal();
            text =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          } else if (value is TimeCellValue) {
            // TimeCellValue 直接转字符串
            text = value.toString();
          } else if (value is DateTimeCellValue) {
            final dt = value.asDateTimeLocal();
            text =
                '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
          } else if (value is FormulaCellValue) {
            // excel 包对数值公式只暴露公式串，取不到缓存结果。
            // 字面量公式（如 "3.14"）可直接当值；真正的表达式无法计算，
            // 抛清晰错误让用户先在 Excel 中另存为值，避免 =SUM(...) 混入导入。
            final raw = value.formula.trim();
            if (raw.isEmpty) {
              text = '';
            } else if (RegExp(r'^[+-]?\d+(\.\d+)?$').hasMatch(raw)) {
              text = raw;
            } else if (RegExp(r'^"(?:[^"]|"")*"$').hasMatch(raw)) {
              // Excel 字符串字面量用连续两个双引号表达一个引号；表达式不能按文本截取。
              text = raw.substring(1, raw.length - 1).replaceAll('""', '"');
            } else {
              throw XlsxFormulaException(raw);
            }
          } else {
            text = value.toString();
          }

          // CSV 转义：如果包含逗号、双引号、换行符，需要用双引号包裹
          if (text.contains(',') ||
              text.contains('"') ||
              text.contains('\n') ||
              text.contains('\r')) {
            // 双引号需要转义为两个双引号
            text = text.replaceAll('"', '""');
            return '"$text"';
          }

          return text;
        }).toList();

        csvLines.add(fields.join(','));
      }

      return csvLines.join('\n');
    } on XlsxFormulaException {
      // 公式异常语义明确，原样上抛供调用方展示专用提示，
      // 不能包成通用「解析失败」丢失原因。
      rethrow;
    } on XlsxDecodeException {
      // 已带可执行原因（含重试建议）的失败同样原样上抛。
      rethrow;
    } catch (e) {
      throw const XlsxDecodeException(
        '无法解析 Excel 文件，请确认文件未损坏，并以「Excel 工作簿 (*.xlsx)」格式另存后重试',
      );
    }
  }

  /// 修正会让 excel 包拒绝整个工作簿的写法，没有需要修复的内容时返回原始字节。
  ///
  /// 1. Excel、WPS 会把内置数字格式（numFmtId < 164）冗余写进 xl/styles.xml 的
  ///    numFmts，excel 包把这种合法写法当错误抛出。
  /// 2. 工作表里没有文本单元格时（例如只剩日期和数字），工作簿不带
  ///    xl/sharedStrings.xml。excel 用空的关系目标拼出 "xl/"，正好命中压缩包里的
  ///    目录条目，于是把空内容当 XML 解析而失败。
  static Uint8List _repairWorkbook(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes, verify: false);
    } catch (_) {
      // 不是 zip 容器：多为 CSV 被改名成 .xlsx，或文件已损坏
      throw const XlsxDecodeException(
        '文件不是有效的 Excel 工作簿（.xlsx），请确认另存为时选择的格式是「Excel 工作簿」，或直接选择 .csv 文件导入',
      );
    }
    // 两处修复互不依赖，都要执行，不能用短路或
    final droppedFormats = _dropBuiltInNumFormats(archive);
    final addedSharedStrings = _addMissingSharedStrings(archive);
    if (!droppedFormats && !addedSharedStrings) return bytes;
    for (final entry in archive.files) {
      // 目录条目没有内容，压缩写出会留下空的 deflate 流，一律按存储方式写。
      if (!entry.isFile) entry.compress = false;
    }
    final rebuilt = ZipEncoder().encode(archive);
    return rebuilt == null ? bytes : Uint8List.fromList(rebuilt);
  }

  /// 删除 xl/styles.xml 里重复声明的内置数字格式，返回是否有改动。
  ///
  /// 内置格式在解析器内有标准定义，删除重复项不会丢失单元格格式。
  static bool _dropBuiltInNumFormats(Archive archive) {
    final styles = archive.findFile('xl/styles.xml');
    final document = styles == null ? null : _parseXml(styles);
    if (document == null) return false;
    var removed = false;
    for (final group in document.findAllElements('numFmts')) {
      var removedHere = false;
      for (final node in group.findElements('numFmt').toList()) {
        final id = int.tryParse(node.getAttribute('numFmtId') ?? '');
        if (id == null || id >= _firstCustomNumFmtId) continue;
        node.parent?.children.remove(node);
        removedHere = true;
      }
      if (!removedHere) continue;
      group.setAttribute(
        'count',
        group.findElements('numFmt').length.toString(),
      );
      removed = true;
    }
    if (removed) {
      _replaceEntry(archive, 'xl/styles.xml', document.toXmlString());
    }
    return removed;
  }

  /// 补全缺失的 xl/sharedStrings.xml 及其关系，返回是否有改动。
  static bool _addMissingSharedStrings(Archive archive) {
    if (archive.findFile('xl/sharedStrings.xml') != null) return false;
    final relations = archive.findFile('xl/_rels/workbook.xml.rels');
    final document = relations == null ? null : _parseXml(relations);
    if (document == null) return false;
    final roots = document.findAllElements('Relationships');
    if (roots.isEmpty) return false;
    final used = document
        .findAllElements('Relationship')
        .map((node) => node.getAttribute('Id') ?? '')
        .toSet();
    // 取一个未被占用的 rId，避免与既有关系冲突
    var index = used.length + 1;
    while (used.contains('rId$index')) {
      index++;
    }
    roots.first.children.add(
      XmlElement(XmlName('Relationship'), <XmlAttribute>[
        XmlAttribute(XmlName('Id'), 'rId$index'),
        XmlAttribute(XmlName('Type'), _sharedStringsRelationship),
        XmlAttribute(XmlName('Target'), 'sharedStrings.xml'),
      ]),
    );
    _replaceEntry(
      archive,
      'xl/_rels/workbook.xml.rels',
      document.toXmlString(),
    );
    _replaceEntry(archive, 'xl/sharedStrings.xml', _emptySharedStrings);
    return true;
  }

  /// 解析归档条目；内容不是可用 XML 时返回 null，由调用方按原样处理。
  static XmlDocument? _parseXml(ArchiveFile file) {
    try {
      return XmlDocument.parse(utf8.decode(file.content as List<int>));
    } catch (_) {
      return null;
    }
  }

  /// 用文本内容替换归档条目；新条目按未压缩内容登记，由编码器按需压缩。
  static void _replaceEntry(Archive archive, String name, String content) {
    final bytes = Uint8List.fromList(utf8.encode(content));
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
}
