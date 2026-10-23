import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import '../../../data/models/day_book.dart';
import '../../../data/models/day_event.dart';
import '../../days/domain/day_date_rules.dart';
import 'content_transfer.dart';
import 'transfer_table.dart';

/// 日子 CSV 的稳定导入身份与已静态校验的记录。
class DayCsvDocument {
  final String exportId;
  final List<DayEvent> entries;

  /// 记录 ID 仅作来源条目标识，导入仓储会生成新活跃身份。
  const DayCsvDocument({required this.exportId, required this.entries});
}

/// 日子使用普通表格字段，可选来源标识区分独立记录与相同内容的导出分包。
class DayCsvService {
  static const maxEventsPerPart = 1000;
  static const maxFileBytes = 64 * 1024 * 1024;
  static final headers = transferFields[TransferKind.days]!
      .map((f) => f.key)
      .toList();

  /// 读取普通表格，按映射后的内容派生重试稳定的导入身份和条目身份。
  static DayCsvDocument decode(List<int> bytes) {
    try {
      if (bytes.length > maxFileBytes) throw const FormatException('纪念日文件过大');
      final table = TransferTable.parse(utf8.decode(bytes), TransferKind.days);
      final mapping = table.detect(TransferKind.days);
      final rows = [
        for (var i = 0; i < table.records.length; i++)
          table.mapped(i, TransferKind.days, mapping),
      ];
      final id = transferId([TransferKind.days.name, rows]);
      final bookId = transferId([id, 'book']);
      final now = DateTime.now().toUtc();
      return DayCsvDocument(
        exportId: id,
        entries: [
          for (var i = 0; i < rows.length; i++)
            transferDay(
              rows[i],
              transferId([
                id,
                [i],
              ]),
              bookId,
              now,
            ),
        ],
      );
    } on DayDateException catch (error) {
      throw FormatException('纪念日日期或定义无效：${error.code}');
    }
  }

  /// 验证记录归属与日子定义，按条数和实际 UTF-8 字节拆分普通 CSV。
  static List<Uint8List> encode({
    required DayBook book,
    required List<DayEvent> entries,
    int maxBytes = maxFileBytes,
  }) {
    if (maxBytes < 1 || maxBytes > maxFileBytes) {
      throw const FormatException('纪念日文件大小限制无效');
    }
    const encoder = CsvEncoder(
      fieldDelimiter: ',',
      lineDelimiter: '\n',
      addBom: true,
    );
    final rows = <List<String>>[];
    String date(OriginalDate? value) => value == null
        ? ''
        : '${value.originalYear.toString().padLeft(4, '0')}-${value.originalMonth.toString().padLeft(2, '0')}-${value.originalDay.toString().padLeft(2, '0')}';
    for (final event in entries.where((e) => e.deletedAt == null)) {
      if (event.dayBookId != book.id) throw const FormatException('纪念日不属于导出目标');
      final d = validateAndProject(event.definition);
      final row = <String, Object?>{
        // 稳定来源身份参与导入指纹，导入仓储仍为目标本生成新的活跃记录身份。
        'id': event.id,
        'name': d.name,
        'category': d.category,
        'date': date(d.event),
        'calendar': d.event?.calendarType,
        'is_leap_month': d.event?.isLeapMonth,
        'repeat_type': d.repeatType,
        'statistic_type': d.statisticType,
        'start_date': date(d.start),
        'start_calendar': d.start?.calendarType,
        'start_is_leap_month': d.start?.isLeapMonth,
        'end_date': date(d.end),
        'end_calendar': d.end?.calendarType,
        'end_is_leap_month': d.end?.isLeapMonth,
        'countdown_mode': d.countdownMode,
        'interval_days': d.intervalDays,
        'created_at': event.createdAt.toUtc().toIso8601String(),
        'updated_at': event.updatedAt.toUtc().toIso8601String(),
      };
      rows.add([for (final h in headers) row[h]?.toString() ?? '']);
    }
    final parts = <Uint8List>[];
    final header = encoder.convert([headers]);
    const rowEncoder = CsvEncoder(fieldDelimiter: ',', lineDelimiter: '\n');
    final headerBytes = utf8.encode(header).length;
    var current = StringBuffer(header);
    var size = headerBytes, count = 0;
    if (size > maxBytes) throw const FormatException('表头超过文件大小限制');
    for (final row in rows) {
      final encoded = rowEncoder.convert([row]);
      final bytes = utf8.encode(encoded).length + 1;
      if (headerBytes + bytes > maxBytes) {
        throw const FormatException('单条纪念日超过文件大小限制');
      }
      if (size + bytes > maxBytes || count == maxEventsPerPart) {
        parts.add(Uint8List.fromList(utf8.encode(current.toString())));
        current = StringBuffer(header);
        size = headerBytes;
        count = 0;
      }
      current.write('\n$encoded');
      size += bytes;
      count++;
    }
    parts.add(Uint8List.fromList(utf8.encode(current.toString())));
    return parts;
  }
}
