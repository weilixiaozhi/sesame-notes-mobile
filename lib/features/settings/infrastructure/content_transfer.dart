import '../../../data/models/day_book.dart' show normalizeDayName;
import 'dart:convert';

import '../../../data/models/day_event.dart';
import '../../../data/models/memo.dart';
import '../../../data/models/memo_fields.dart';
import '../../days/domain/day_date_rules.dart';
import 'transfer_table.dart';

/// 从用户字段建立业务对象，日期真实性仍由日子领域规则统一判断。
DayEvent transferDay(
  Map<String, Object?> row,
  String id,
  String bookId,
  DateTime now,
) {
  final category = switch (transferText(row, 'category').trim().toLowerCase()) {
    '生日' || 'birthday' => DayCategory.birthday,
    '纪念日' || 'anniversary' => DayCategory.anniversary,
    '倒数日' || 'countdown' => DayCategory.countdown,
    '阶段' || 'stage' => DayCategory.stage,
    _ => throw const FormatException('类别：应为生日、纪念日、倒数日或阶段'),
  };
  OriginalDate? date(String field, String calendarField, String leapField) {
    final raw = transferText(row, field).trim();
    if (raw.isEmpty) return null;
    final parts = RegExp(
      r'^(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})日?$',
    ).firstMatch(raw);
    if (parts == null) throw FormatException('$field：日期格式应为 YYYY-MM-DD');
    final calendar = switch (transferText(
      row,
      calendarField,
    ).trim().toLowerCase()) {
      '' || '公历' || '阳历' || 'solar' => DayCalendarType.solar,
      '农历' || '阴历' || 'lunar' => DayCalendarType.lunar,
      _ => throw FormatException('$calendarField：应为公历或农历'),
    };
    return OriginalDate(
      calendarType: calendar,
      originalYear: int.parse(parts[1]!),
      originalMonth: int.parse(parts[2]!),
      originalDay: int.parse(parts[3]!),
      isLeapMonth: transferBool(row[leapField], leapField),
    );
  }

  final repeated =
      category == DayCategory.birthday || category == DayCategory.anniversary;
  final repeat = switch (transferText(
    row,
    'repeat_type',
  ).trim().toLowerCase()) {
    '' => repeated ? 'yearly' : 'none',
    '每年' || 'yearly' => 'yearly',
    '不重复' || 'none' => 'none',
    _ => throw const FormatException('重复规则：应为每年或不重复'),
  };
  final mode = switch (transferText(row, 'countdown_mode').trim()) {
    '' =>
      category == DayCategory.countdown
          ? (row['interval_days'] == null ? 'fixed_date' : 'interval_days')
          : null,
    '固定日期' || 'fixed_date' => 'fixed_date',
    '间隔天数' || 'interval_days' => 'interval_days',
    _ => throw const FormatException('倒数方式：无效'),
  };
  final statistic = switch (transferText(row, 'statistic_type').trim()) {
    '天' || 'day' => 'day',
    '年' || 'year' => 'year',
    _ => throw const FormatException('统计方式：应为天或年'),
  };
  final created = transferTimestamp(row['created_at'], now, '创建时间');
  final updated = transferTimestamp(row['updated_at'], created, '修改时间');
  if (updated.isBefore(created)) throw const FormatException('修改时间不能早于创建时间');
  final definition = validateAndProject(
    DayEventDefinition(
      name: normalizeDayName(transferText(row, 'name')),
      category: category,
      repeatType: repeat,
      statisticType: statistic,
      countdownMode: mode,
      intervalDays: row['interval_days'] == null
          ? null
          : int.tryParse(row['interval_days'].toString()),
      event: date('date', 'calendar', 'is_leap_month'),
      start: date('start_date', 'start_calendar', 'start_is_leap_month'),
      end: date('end_date', 'end_calendar', 'end_is_leap_month'),
    ),
  );
  return DayEvent(
    id: id,
    dayBookId: bookId,
    definition: definition,
    createdAt: created,
    updatedAt: updated,
  );
}

MemoEntry transferMemo(
  Map<String, Object?> row,
  String id,
  MemoBook book,
  DateTime now,
  int index, {
  Map<String, Object?> record = const {},
  List<({String header, String? label})> cardFields = const [],
}) {
  final created = transferTimestamp(row['created_at'], now, '创建时间');
  final updated = transferTimestamp(row['updated_at'], created, '修改时间');
  if (updated.isBefore(created)) throw const FormatException('修改时间不能早于创建时间');
  final card = book.type == 'credentials';
  Object? body = row['body'];
  if (!card && body is String) {
    body = {
      'ops': [
        {'insert': body.endsWith('\n') ? body : '$body\n'},
      ],
    };
  }
  // 卡片字段由映射页逐列确认：关闭的列与空单元格都不生成字段。
  final fields = card
      ? [
          for (final (:header, :label) in cardFields)
            if (label != null &&
                label.trim().isNotEmpty &&
                transferText(record, header).isNotEmpty)
              MemoField(
                label: label.trim(),
                value: transferText(record, header),
              ),
        ]
      : const <MemoField>[];
  final entry = MemoEntry(
    id: id,
    memoBookId: book.id,
    bookType: book.type,
    title: transferText(row, 'title'),
    createdAt: created,
    updatedAt: updated,
    bodyJson: card ? encodeMemoFields(fields) : jsonEncode(body),
    orderKey: card ? index : null,
  );
  entry.validate();
  return entry;
}
