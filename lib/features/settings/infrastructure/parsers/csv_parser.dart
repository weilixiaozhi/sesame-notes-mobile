import 'package:csv/csv.dart';

/// CSV 解析工具类。
class CsvParser {
  /// 解析 CSV 文本为二维字符串数组。
  ///
  /// 标准分隔格式交给项目既有的 csv 包按完整文本解析，确保引号内换行仍属于
  /// 同一字段；解析前额外执行严格引号校验，避免依赖包的宽松容错静默改列。
  static List<List<String>> parse(String input) {
    var text = input;
    if (text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF) {
      text = text.substring(1);
    }
    if (text.trim().isEmpty) return const [];

    final delimiter = _detectDelimiter(_logicalRecords(text));
    // 支付宝等导出文件会在逗号字段中混入 tab；只有 tab 本身不是分隔符时
    // 才移除，避免改变正常 TSV 的列边界。
    if (delimiter != '\t') text = text.replaceAll('\t', '');
    _validateSyntax(text, delimiter);

    final List<List<String>> parsed;
    if (delimiter == 'space') {
      parsed = _logicalRecords(text).map(_splitSpaceSeparatedLine).toList();
    } else {
      parsed = Csv(fieldDelimiter: delimiter, autoDetect: false)
          .decode(text)
          .map((row) {
            return row.map((field) => field.toString().trim()).toList();
          })
          .toList();
    }

    // `,,`、`"",""` 等记录没有业务数据，与物理空行采用同一过滤口径。
    return parsed
        .where((row) => row.any((field) => field.trim().isNotEmpty))
        .toList(growable: false);
  }

  /// 按逻辑记录切分文本；引号字段中的 CR/LF 原样保留在当前记录。
  static List<String> _logicalRecords(String text) {
    final records = <String>[];
    var start = 0;
    var inQuotes = false;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < text.length && text[i + 1] == '"') {
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }
      if (!inQuotes && (ch == '\r' || ch == '\n')) {
        records.add(text.substring(start, i));
        if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        start = i + 1;
      }
    }
    if (start < text.length) records.add(text.substring(start));
    return records;
  }

  /// 自动检测分隔符（不统计引号内部字符）。
  ///
  /// 优先级为逗号、制表符、分号、竖线；全部未出现时才考虑连续空格。
  static String _detectDelimiter(List<String> records) {
    final counts = <String, int>{',': 0, '\t': 0, ';': 0, '|': 0};
    final maxRecords = records.length < 50 ? records.length : 50;
    var hasMultiSpaces = false;
    for (var i = 0; i < maxRecords; i++) {
      final record = records[i];
      var inQuotes = false;
      var spaceRun = 0;
      for (var j = 0; j < record.length; j++) {
        final ch = record[j];
        if (ch == '"') {
          if (inQuotes && j + 1 < record.length && record[j + 1] == '"') {
            j++;
          } else {
            inQuotes = !inQuotes;
          }
          spaceRun = 0;
          continue;
        }
        if (inQuotes) continue;
        if (counts.containsKey(ch)) counts[ch] = counts[ch]! + 1;
        if (ch == ' ') {
          spaceRun++;
          if (spaceRun >= 2) hasMultiSpaces = true;
        } else {
          spaceRun = 0;
        }
      }
    }

    String? best;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        best = entry.key;
        bestCount = entry.value;
      }
    }
    if (best != null) return best;
    return hasMultiSpaces ? 'space' : ',';
  }

  /// 校验双引号只能完整包裹字段，且闭引号后只能出现分隔符、换行或 EOF。
  static void _validateSyntax(String text, String delimiter) {
    const fieldStart = 0;
    const unquoted = 1;
    const quoted = 2;
    const afterQuote = 3;
    var state = fieldStart;

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      final isDelimiter = delimiter == 'space' ? ch == ' ' : ch == delimiter;
      final isNewline = ch == '\r' || ch == '\n';

      switch (state) {
        case fieldStart:
          if (ch == '"') {
            state = quoted;
          } else if (!isDelimiter && !isNewline) {
            state = unquoted;
          }
        case unquoted:
          if (ch == '"') {
            throw const FormatException('CSV 非引号字段中包含双引号');
          }
          if (isDelimiter || isNewline) state = fieldStart;
        case quoted:
          if (ch != '"') continue;
          if (i + 1 < text.length && text[i + 1] == '"') {
            i++;
          } else {
            state = afterQuote;
          }
        case afterQuote:
          if (isDelimiter || isNewline) {
            state = fieldStart;
          } else {
            throw const FormatException('CSV 闭引号后包含非法字符');
          }
      }
    }
    if (state == quoted) throw const FormatException('CSV 引号未闭合');
  }

  /// 拆分空格分隔记录；引号内空格与换行仍属于字段内容。
  static List<String> _splitSpaceSeparatedLine(String line) {
    final out = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var spaceRun = 0;

    void pushBuffer() {
      out.add(buffer.toString().trim());
      buffer.clear();
    }

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        spaceRun = 0;
        continue;
      }
      if (!inQuotes && ch == ' ') {
        spaceRun++;
        continue;
      }
      if (!inQuotes && spaceRun > 0) {
        if (buffer.isNotEmpty) pushBuffer();
        spaceRun = 0;
      }
      buffer.write(ch);
    }
    if (buffer.isNotEmpty) pushBuffer();
    return out;
  }
}
