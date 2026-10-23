import 'package:intl/intl.dart';

/// 日期解析工具类
/// 支持多种常见日期格式的自动解析
class DateParser {
  DateParser._();

  /// 尝试解析日期字符串，支持多种格式
  ///
  /// 支持的格式包括：
  /// - ISO 8601: 2024-11-05, 2024-11-05T12:30:45
  /// - 中文格式: 2024年11月5日, 2024年11月05日 12:30:45
  /// - 常见格式: 2024/11/05, 2024-11-05 12:30:45
  ///
  /// [dateStr] 待解析的日期字符串
  /// [fallback] 解析失败时返回的默认值，默认为当前时间
  ///
  /// 返回解析后的 DateTime 对象
  static DateTime parse(String? dateStr, {DateTime? fallback}) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return fallback ?? DateTime.now();
    }

    // 1. 尝试标准 ISO 8601 格式
    DateTime? result = _tryParseIso(dateStr);
    if (result != null) return result.toLocal();

    // 2. 尝试中文日期格式
    result = _tryParseChineseDate(dateStr);
    if (result != null) return result;

    // 3. 尝试常见日期格式
    result = _tryParseCommonFormats(dateStr);
    if (result != null) return result;

    // 4. 所有格式都失败，返回默认值
    return fallback ?? DateTime.now();
  }

  /// 尝试解析 ISO 8601 标准格式
  static DateTime? _tryParseIso(String dateStr, {bool strict = false}) {
    try {
      if (strict) {
        final match = RegExp(
          r'^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?(?:Z|[+-](\d{2}):?(\d{2}))?)?$',
        ).firstMatch(dateStr);
        if (match == null) return null;
        final parts = [for (var i = 1; i <= 6; i++) int.parse(match[i] ?? '0')];
        final date = DateTime(parts[0], parts[1], parts[2]);
        if (date.year != parts[0] ||
            date.month != parts[1] ||
            date.day != parts[2] ||
            parts[3] > 23 ||
            parts[4] > 59 ||
            parts[5] > 59) {
          return null;
        }
        // 偏移量同样校验小时、分钟分量，不能交给宽松解析器滚动到其他日期。
        // 这里只约束时间格式，不以实际地理时区范围限制导入数据。
        if (match[7] != null &&
            (int.parse(match[7]!) > 23 || int.parse(match[8]!) > 59)) {
          return null;
        }
      }
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// 尝试解析中文日期格式
  ///
  /// 支持格式：
  /// - 2024年11月5日
  /// - 2024年11月05日
  /// - 2024年11月5日 12:30
  /// - 2024年11月5日 12:30:45
  static DateTime? _tryParseChineseDate(String dateStr, {bool strict = false}) {
    final trimmed = dateStr.trim();

    // 匹配 "YYYY年MM月DD日 [HH:mm[:ss]]" 格式
    final regex = RegExp(
      r'(\d{4})年(\d{1,2})月(\d{1,2})日(?:\s+(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?',
    );

    final match = regex.firstMatch(trimmed);
    if (match == null) return null;
    if (strict && (match.start != 0 || match.end != trimmed.length)) {
      return null;
    }

    try {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
      final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;

      final date = DateTime(year, month, day, hour, minute, second);
      if (strict &&
          (date.year != year ||
              date.month != month ||
              date.day != day ||
              date.hour != hour ||
              date.minute != minute ||
              date.second != second)) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  /// 尝试使用常见日期格式解析。
  ///
  /// 这些格式都是**无时区信息的裸墙钟时间**(斜杠分隔、单数字月份、MM/dd/yyyy 等,
  /// 过不了 DateTime.parse),按口径一律解析为**本地时间**(`parse` 默认 utc=false)。
  /// 切勿用 `parse(str, /*utc=*/true)` 强标 UTC —— 那会让 CSV 导入的本地时间在
  /// 本地(如 UTC+8)展示时整体 +8 小时。
  static DateTime? _tryParseCommonFormats(
    String dateStr, {
    bool strict = false,
  }) {
    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy/MM/dd HH:mm',
      'yyyy-MM-dd',
      'yyyy/M/d',
      'yyyy/MM/dd',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy HH:mm',
      'MM/dd/yyyy',
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yyyy HH:mm',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
    ];

    for (final format in formats) {
      try {
        // utc=false(默认):按本地墙钟解析,不做时区偏移。
        return strict
            ? DateFormat(format).parseStrict(dateStr)
            : DateFormat(format).parse(dateStr);
      } catch (_) {
        // 继续尝试下一个格式
      }
    }

    return null;
  }

  /// 尝试解析日期字符串，失败时返回 null
  ///
  /// 与 [parse] 方法的区别是：解析失败时返回 null 而不是当前时间。
  /// 注意不能复用 [parse] 的 fallback 语义——[parse] 内部
  /// `fallback ?? DateTime.now()` 会把 null 兜回当前时间，
  /// 导致"失败返回 null"的契约失效，坏数据被静默当作今天导入。
  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return null;
    }

    final iso = _tryParseIso(dateStr);
    if (iso != null) return iso.toLocal();
    final chinese = _tryParseChineseDate(dateStr);
    if (chinese != null) return chinese;
    final common = _tryParseCommonFormats(dateStr);
    if (common != null) return common;
    return null;
  }

  /// 导入边界复用原有日期格式，拒绝日期溢出与尾随垃圾，不改变界面日期的既有宽松行为。
  static DateTime? tryParseStrict(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final text = value.trim();
    final iso = _tryParseIso(text, strict: true);
    if (iso != null) return iso.toLocal();
    return _tryParseChineseDate(text, strict: true) ??
        _tryParseCommonFormats(text, strict: true);
  }
}
