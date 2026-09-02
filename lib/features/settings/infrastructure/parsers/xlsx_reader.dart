import 'dart:typed_data';
import 'package:excel/excel.dart';

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

/// XLSX 文件读取工具
///
/// 将 Excel 文件转换为 CSV 格式字符串，便于后续使用现有的 CSV 解析逻辑
class XlsxReader {
  /// 读取 XLSX 文件字节并转换为 CSV 格式字符串
  ///
  /// 参数:
  /// - [bytes]: XLSX 文件的字节数据
  ///
  /// 返回:
  /// - CSV 格式的字符串，每行用 \n 分隔，字段用逗号分隔
  static String convertXlsxToCSV(Uint8List bytes) {
    try {
      // 解码 Excel 文件
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('Excel 文件为空或无法读取');
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
        throw Exception('工作表为空');
      }
      if (nonEmptySheets.length > 1) {
        throw Exception('存在多个非空工作表，请仅保留一个账单工作表后重试');
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
            } else if (RegExp(r'^".*"$').hasMatch(raw)) {
              text = raw.substring(1, raw.length - 1);
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
    } catch (e) {
      throw Exception('解析 Excel 文件失败: $e');
    }
  }
}
