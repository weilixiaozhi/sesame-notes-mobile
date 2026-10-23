/// 日子业务的共同范围；日期选择、写边界与计算共用这些限制。
abstract final class DayLimits {
  static const minYear = 1901;
  static const maxYear = 2100;
  static const minLunarYear = 1900;
  static const maxIntervalDays = 36500;
}

/// 日期计算错误只携带稳定代码，展示层负责翻译。
class DayDateException implements Exception {
  final String code;
  final Object? cause;
  final StackTrace? stackTrace;

  /// 保留原始异常便于写边界诊断，文本输出不包含用户日期。
  const DayDateException(this.code, {this.cause, this.stackTrace});

  /// 返回不含用户输入的稳定错误代码。
  @override
  String toString() => 'DayDateException($code)';
}

/// 受支持范围内的公历纯日期，与本地时区及夏令时无关。
class DateOnly implements Comparable<DateOnly> {
  final int year;
  final int month;
  final int day;

  static final minimum = DateOnly(DayLimits.minYear, 1, 1);
  static final maximum = DateOnly(DayLimits.maxYear, 12, 31);
  static final _pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// 严格验证日期存在，不允许 DateTime 自动滚动非法年月日。
  factory DateOnly(int year, int month, int day) {
    if (year < DayLimits.minYear || year > DayLimits.maxYear) {
      throw const DayDateException('date_out_of_range');
    }
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) {
      throw const DayDateException('invalid_date');
    }
    return DateOnly._(year, month, day);
  }

  /// 存储经过校验的日期分量。
  const DateOnly._(this.year, this.month, this.day);

  /// 只接受完整 YYYY-MM-DD，不接受时间、空白或宽松日期格式。
  factory DateOnly.parse(String value) {
    try {
      if (!_pattern.hasMatch(value)) {
        throw const DayDateException('invalid_date');
      }
      return DateOnly(
        int.parse(value.substring(0, 4)),
        int.parse(value.substring(5, 7)),
        int.parse(value.substring(8, 10)),
      );
    } on DayDateException {
      rethrow;
    } catch (error, stackTrace) {
      throw DayDateException(
        'invalid_date',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 从设备已经选定时区的年月日读取今天，不再改变时区。
  factory DateOnly.fromDateTime(DateTime value) =>
      DateOnly(value.year, value.month, value.day);

  /// 从内部整数日序构造日期，运算结果仍受产品范围约束。
  factory DateOnly.fromDayNumber(int value) {
    if (value < minimum.dayNumber || value > maximum.dayNumber) {
      throw const DayDateException('date_out_of_range');
    }
    final utc = DateTime.fromMillisecondsSinceEpoch(
      value * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return DateOnly(utc.year, utc.month, utc.day);
  }

  /// 返回指定公历月份的实际天数。
  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  /// 纯日期的唯一持久化文本。
  String get iso8601 =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// UTC 仅作为整数日序算法内部载体。
  int get dayNumber =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// 向前或向后移动自然日，越界报错。
  DateOnly addDays(int count) => DateOnly.fromDayNumber(dayNumber + count);

  /// 返回目标减当前日期的有向自然日差。
  int daysUntil(DateOnly target) => target.dayNumber - dayNumber;

  /// 比较年月日顺序。
  @override
  int compareTo(DateOnly other) => dayNumber.compareTo(other.dayNumber);

  bool isBefore(DateOnly other) => compareTo(other) < 0;

  bool isAfter(DateOnly other) => compareTo(other) > 0;

  /// 只按年月日判断相等。
  @override
  bool operator ==(Object other) =>
      other is DateOnly &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  /// 与年月日相等语义一致。
  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso8601;
}

/// 原始日期历法代码。
abstract final class DayCalendarType {
  static const solar = 'solar';
  static const lunar = 'lunar';
}

/// 日子的固定分类及展示顺序。
abstract final class DayCategory {
  static const birthday = 'birthday';
  static const anniversary = 'anniversary';
  static const countdown = 'countdown';
  static const stage = 'stage';
  static const values = [birthday, anniversary, countdown, stage];
}

/// 日子的循环规则代码。
abstract final class DayRepeatType {
  static const none = 'none';
  static const yearly = 'yearly';
}

/// 日子的统计维度代码。
abstract final class DayStatisticType {
  static const year = 'year';
  static const day = 'day';
}

/// 倒数日的目标定义方式。
abstract final class DayCountdownMode {
  static const fixedDate = 'fixed_date';
  static const intervalDays = 'interval_days';
}

/// 用户选择的原始日期；农历月份始终为正数，闰月单独表达。
class OriginalDate {
  final String calendarType;
  final int originalYear;
  final int originalMonth;
  final int originalDay;
  final bool isLeapMonth;
  final DateOnly? solarDate;

  /// 接收尚未静态校验的完整日期定义及可选投影。
  const OriginalDate({
    required this.calendarType,
    required this.originalYear,
    required this.originalMonth,
    required this.originalDay,
    this.isLeapMonth = false,
    this.solarDate,
  });

  /// 从公历纯日期生成完整原始定义。
  factory OriginalDate.solar(DateOnly date) => OriginalDate(
    calendarType: DayCalendarType.solar,
    originalYear: date.year,
    originalMonth: date.month,
    originalDay: date.day,
    solarDate: date,
  );

  /// 只替换经校验计算得到的投影，不改变原始历法定义。
  OriginalDate withSolarDate(DateOnly date) => OriginalDate(
    calendarType: calendarType,
    originalYear: originalYear,
    originalMonth: originalMonth,
    originalDay: originalDay,
    isLeapMonth: isLeapMonth,
    solarDate: date,
  );

  /// 原始定义和公历投影全部参与相等判断。
  @override
  bool operator ==(Object other) =>
      other is OriginalDate &&
      calendarType == other.calendarType &&
      originalYear == other.originalYear &&
      originalMonth == other.originalMonth &&
      originalDay == other.originalDay &&
      isLeapMonth == other.isLeapMonth &&
      solarDate == other.solarDate;

  /// 与完整日期定义的相等语义一致。
  @override
  int get hashCode => Object.hash(
    calendarType,
    originalYear,
    originalMonth,
    originalDay,
    isLeapMonth,
    solarDate,
  );
}

/// 日子的权威业务定义；不存储下一次、年龄、跨度或倒计时结果。
class DayEventDefinition {
  final String category;
  final String name;
  final String repeatType;
  final String statisticType;
  final String? countdownMode;
  final int? intervalDays;
  final OriginalDate? event;
  final OriginalDate? start;
  final OriginalDate? end;

  /// 建立待校验的定义，持久化入口统一调用日期域静态校验。
  const DayEventDefinition({
    required this.category,
    required this.name,
    required this.repeatType,
    required this.statisticType,
    this.countdownMode,
    this.intervalDays,
    this.event,
    this.start,
    this.end,
  });
}

/// 日子记录展示模型；归属和同步身份从父日子本继承。
class DayEvent {
  final String id;
  final String dayBookId;
  final DayEventDefinition definition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverRevision;
  final String? sourceEventId;

  /// 仅供展示定位无法解析的本地投影，不写入数据库、文件或同步载荷。
  final bool hasUnreadableDate;

  /// 建立与 Drift Row 和生成 API 模型隔离的记录快照。
  const DayEvent({
    required this.id,
    required this.dayBookId,
    required this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverRevision,
    this.sourceEventId,
    this.hasUnreadableDate = false,
  });
}
