import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';

/// 将本地行收敛为纯展示模型，隐藏数据库类型。
DayBook dayBookFromRow(DayBookRow row) => DayBook(
  id: row.id,
  name: row.name,
  storageMode: row.storageMode,
  scopeAccountId: row.scopeAccountId,
  syncId: row.syncId,
  serverRevision: row.serverRevision,
  fullCursor: row.fullCursor,
  createdAt: row.createdAt.toUtc(),
  updatedAt: row.updatedAt.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
  pendingLocalDelete: row.pendingLocalDelete,
  isStale: row.isStale,
  isHidden: row.isHidden,
  sourceAccountId: row.sourceAccountId,
  sourceDayBookId: row.sourceDayBookId,
  sourceOperationId: row.sourceOperationId,
);

/// 严格读取完整定义；展示流可保留坏投影的原始定义及诊断标志。
DayEvent dayEventFromRow(DayEventRow row, {bool forDisplay = false}) {
  var hasUnreadableDate = false;

  /// 展示时只标记坏投影，原始年月日与数据库内容均保持不变。
  DateOnly? readDate(String value) {
    try {
      return DateOnly.parse(value);
    } on DayDateException {
      if (!forDisplay) rethrow;
      hasUnreadableDate = true;
      return null;
    }
  }

  final definition = DayEventDefinition(
    category: row.category,
    name: row.name,
    repeatType: row.repeatType,
    statisticType: row.statisticType,
    countdownMode: row.countdownMode,
    intervalDays: row.intervalDays,
    event: row.eventCalendarType == null
        ? null
        : OriginalDate(
            calendarType: row.eventCalendarType!,
            originalYear: row.eventOriginalYear!,
            originalMonth: row.eventOriginalMonth!,
            originalDay: row.eventOriginalDay!,
            isLeapMonth: row.eventIsLeapMonth!,
            solarDate: readDate(row.eventSolarDate!),
          ),
    start: row.startCalendarType == null
        ? null
        : OriginalDate(
            calendarType: row.startCalendarType!,
            originalYear: row.startOriginalYear!,
            originalMonth: row.startOriginalMonth!,
            originalDay: row.startOriginalDay!,
            isLeapMonth: row.startIsLeapMonth!,
            solarDate: readDate(row.startSolarDate!),
          ),
    end: row.endCalendarType == null
        ? null
        : OriginalDate(
            calendarType: row.endCalendarType!,
            originalYear: row.endOriginalYear!,
            originalMonth: row.endOriginalMonth!,
            originalDay: row.endOriginalDay!,
            isLeapMonth: row.endIsLeapMonth!,
            solarDate: readDate(row.endSolarDate!),
          ),
  );
  return DayEvent(
    id: row.id,
    dayBookId: row.dayBookId,
    definition: definition,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    serverRevision: row.serverRevision,
    deletedAt: row.deletedAt?.toUtc(),
    sourceEventId: row.sourceEventId,
    hasUnreadableDate: hasUnreadableDate,
  );
}

/// 把经过校验的完整定义展开为关系表列。
DayEventsCompanion dayEventToCompanion(DayEvent value) =>
    DayEventsCompanion.insert(
      id: value.id,
      dayBookId: value.dayBookId,
      category: value.definition.category,
      name: value.definition.name,
      repeatType: value.definition.repeatType,
      statisticType: value.definition.statisticType,
      countdownMode: d.Value(value.definition.countdownMode),
      intervalDays: d.Value(value.definition.intervalDays),
      eventCalendarType: d.Value(value.definition.event?.calendarType),
      eventOriginalYear: d.Value(value.definition.event?.originalYear),
      eventOriginalMonth: d.Value(value.definition.event?.originalMonth),
      eventOriginalDay: d.Value(value.definition.event?.originalDay),
      eventIsLeapMonth: d.Value(value.definition.event?.isLeapMonth),
      eventSolarDate: d.Value(value.definition.event?.solarDate?.iso8601),
      startCalendarType: d.Value(value.definition.start?.calendarType),
      startOriginalYear: d.Value(value.definition.start?.originalYear),
      startOriginalMonth: d.Value(value.definition.start?.originalMonth),
      startOriginalDay: d.Value(value.definition.start?.originalDay),
      startIsLeapMonth: d.Value(value.definition.start?.isLeapMonth),
      startSolarDate: d.Value(value.definition.start?.solarDate?.iso8601),
      endCalendarType: d.Value(value.definition.end?.calendarType),
      endOriginalYear: d.Value(value.definition.end?.originalYear),
      endOriginalMonth: d.Value(value.definition.end?.originalMonth),
      endOriginalDay: d.Value(value.definition.end?.originalDay),
      endIsLeapMonth: d.Value(value.definition.end?.isLeapMonth),
      endSolarDate: d.Value(value.definition.end?.solarDate?.iso8601),
      serverRevision: d.Value(value.serverRevision),
      createdAt: value.createdAt.toUtc(),
      updatedAt: value.updatedAt.toUtc(),
      deletedAt: d.Value(value.deletedAt?.toUtc()),
      sourceEventId: d.Value(value.sourceEventId),
    );

/// outbox 保存完整业务定义，日期投影已经由同一静态校验得出。
Map<String, Object?> dayEventPayload(DayEvent value) => {
  'name': value.definition.name,
  'category': value.definition.category,
  'repeat_type': value.definition.repeatType,
  'statistic_type': value.definition.statisticType,
  'countdown_mode': value.definition.countdownMode,
  'interval_days': value.definition.intervalDays,
  'event': _originalDatePayload(value.definition.event),
  'start': _originalDatePayload(value.definition.start),
  'end': _originalDatePayload(value.definition.end),
  'created_at': wireTimestamp(value.createdAt),
};

/// 原始日期只使用纯日期文本，避免时区转换改变日期。
Map<String, Object?>? _originalDatePayload(OriginalDate? value) => value == null
    ? null
    : {
        'calendar_type': value.calendarType,
        'original_year': value.originalYear,
        'original_month': value.originalMonth,
        'original_day': value.originalDay,
        'is_leap_month': value.isLeapMonth,
        'solar_date': value.solarDate!.iso8601,
      };
