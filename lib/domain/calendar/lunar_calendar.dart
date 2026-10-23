import 'dart:developer' as developer;

import 'package:tyme/tyme.dart' as tyme;

import 'package:sesame_notes/data/models/day_event.dart';

/// 真实农历月份；日序只供域内部先过滤边界再构造纯日期。
class LunarMonthInfo {
  final int month;
  final bool isLeapMonth;
  final int days;
  final int firstDayNumber;

  /// 保存月份长度、闰标志及月首日序。
  const LunarMonthInfo({
    required this.month,
    required this.isLeapMonth,
    required this.days,
    required this.firstDayNumber,
  });
}

/// 节日工具的固定节日实例。
class DayHoliday {
  final String code;
  final DateOnly date;

  /// 保存节日代码与发生日期。
  const DayHoliday(this.code, this.date);
}

/// 农历转换和节气库的唯一业务门面。
class LunarCalendar {
  const LunarCalendar();

  /// 共用月历读取农历、节日和节气，返回可展示的日期信息。
  ({String lunarDate, String label, bool isFestival}) dayInfo(DateTime date) =>
      _guard('dayInfo', () {
        final solar = tyme.SolarDay.fromYmd(date.year, date.month, date.day);
        final lunar = solar.getLunarDay();
        final month = lunar.getLunarMonth().getName();
        final day = lunar.getName();
        final festival =
            lunar.getFestival()?.getName() ?? solar.getFestival()?.getName();
        final term = solar.getTermDay();
        return (
          lunarDate: '$month$day',
          label:
              festival ??
              (term.getDayIndex() == 0
                  ? term.getSolarTerm().getName()
                  : lunar.getDay() == 1
                  ? month
                  : day),
          isFestival: festival != null || term.getDayIndex() == 0,
        );
      });

  /// 农历原始年月日使用历法库自带的中文月名与日名，闰月保留在月名中。
  String chineseDateLabel(OriginalDate original) {
    final parts = chineseDateParts(original);
    return '${original.originalYear} ${parts.month}${parts.day}';
  }

  /// 外显日期与滚轮使用同一历法库月名、日名，保留闰月。
  ({String month, String day}) chineseDateParts(OriginalDate original) =>
      _guard('dateLabel', () {
        if (original.calendarType != DayCalendarType.lunar ||
            original.originalYear < DayLimits.minLunarYear ||
            original.originalYear > DayLimits.maxYear) {
          throw const DayDateException('invalid_lunar_date');
        }
        final day = tyme.LunarDay.fromYmd(
          original.originalYear,
          original.isLeapMonth
              ? -original.originalMonth
              : original.originalMonth,
          original.originalDay,
        );
        return (month: day.getLunarMonth().getName(), day: day.getName());
      });

  /// 将真实农历原始日期转换为受支持的公历日期。
  DateOnly toSolar(OriginalDate original) => _guard('toSolar', () {
    if (original.calendarType != DayCalendarType.lunar ||
        original.originalYear < DayLimits.minLunarYear ||
        original.originalYear > DayLimits.maxYear ||
        original.originalMonth < 1 ||
        original.originalMonth > 12 ||
        original.originalDay < 1 ||
        original.originalDay > 30) {
      throw const DayDateException('invalid_lunar_date');
    }
    final month = _month(
      original.originalYear,
      original.originalMonth,
      original.isLeapMonth,
    );
    if (month == null || original.originalDay > month.days) {
      throw const DayDateException('invalid_lunar_date');
    }
    return DateOnly.fromDayNumber(
      month.firstDayNumber + original.originalDay - 1,
    );
  });

  /// 将公历日期转换为正月份及独立闰标志。
  OriginalDate fromSolar(DateOnly date) => _guard('fromSolar', () {
    final lunar = tyme.SolarDay.fromYmd(
      date.year,
      date.month,
      date.day,
    ).getLunarDay();
    final month = lunar.getLunarMonth();
    return OriginalDate(
      calendarType: DayCalendarType.lunar,
      originalYear: lunar.getYear(),
      originalMonth: month.getMonth(),
      originalDay: lunar.getDay(),
      isLeapMonth: month.isLeap(),
      solarDate: date,
    );
  });

  /// 按真实月份顺序返回普通月及紧随其后的闰月。
  List<LunarMonthInfo> months(int year) => _guard('months', () {
    if (year < DayLimits.minLunarYear || year > DayLimits.maxYear) {
      throw const DayDateException('date_out_of_range');
    }
    return tyme.LunarYear.fromYear(year)
        .getMonths()
        .map(
          (month) => LunarMonthInfo(
            month: month.getMonth(),
            isLeapMonth: month.isLeap(),
            days: month.getDayCount(),
            firstDayNumber: _solarDayNumber(month.getFirstDay().getSolarDay()),
          ),
        )
        .toList(growable: false);
  });

  /// 年循环只构造指定月份；缺失指定闰月时明确返回无候选。
  int? yearlyDayNumber(OriginalDate original, int year) => _guard(
    'yearlyOccurrence',
    () {
      final month = _month(year, original.originalMonth, original.isLeapMonth);
      if (month == null) return null;
      final day = original.originalDay > month.days
          ? month.days
          : original.originalDay;
      return month.firstDayNumber + day - 1;
    },
  );

  /// 直接定位所需月份，不为单次转换计算全年十二至十三个月。
  LunarMonthInfo? _month(int year, int number, bool leap) {
    if (leap && tyme.LunarYear.fromYear(year).getLeapMonth() != number) {
      return null;
    }
    final month = tyme.LunarMonth.fromYm(year, leap ? -number : number);
    return LunarMonthInfo(
      month: number,
      isLeapMonth: leap,
      days: month.getDayCount(),
      firstDayNumber: _solarDayNumber(month.getFirstDay().getSolarDay()),
    );
  }

  /// 返回从今天起至明年同日前的节日，按发生日期从近到远排列。
  List<DayHoliday> upcomingHolidays(DateOnly today) =>
      _guard('upcomingHolidays', () {
        // 闰日的周年边界落在次年二月末；上界日序允许超出产品年份范围。
        final nextYear = today.year + 1;
        final lastDay = DateOnly.daysInMonth(nextYear, today.month);
        final endNumber =
            DateTime.utc(
              nextYear,
              today.month,
              today.day > lastDay ? lastDay : today.day,
            ).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
        // 两个公历年的节日各自已有稳定升序，依次合并后仍保持最近日期优先。
        return [
          for (
            var year = today.year;
            year <= nextYear && year <= DayLimits.maxYear;
            year++
          )
            for (final holiday in holidays(year))
              if (holiday.date.dayNumber >= today.dayNumber &&
                  holiday.date.dayNumber < endNumber)
                holiday,
        ];
      });

  /// 返回目标公历年内的固定节日。
  List<DayHoliday> holidays(int year) => _guard('holidays', () {
    final first = DateOnly(year, 1, 1);
    final last = DateOnly(year, 12, 31);
    final result = <DayHoliday>[
      DayHoliday('new_year', first),
      DayHoliday('labour_day', DateOnly(year, 5, 1)),
      DayHoliday('national_day', DateOnly(year, 10, 1)),
      DayHoliday(
        'qingming',
        DateOnly.fromDayNumber(
          _solarDayNumber(tyme.SolarTerm.fromName(year, '清明').getSolarDay()),
        ),
      ),
    ];
    const lunarFestivals = [
      ('spring_festival', 1, 1),
      ('lantern_festival', 1, 15),
      ('dragon_boat', 5, 5),
      ('qixi', 7, 7),
      ('mid_autumn', 8, 15),
      ('double_ninth', 9, 9),
    ];
    final firstLunarYear = fromSolar(first).originalYear;
    final lastLunarYear = fromSolar(last).originalYear;
    for (
      var lunarYear = firstLunarYear;
      lunarYear <= lastLunarYear;
      lunarYear++
    ) {
      for (final (code, month, day) in lunarFestivals) {
        final number = _solarDayNumber(
          tyme.LunarDay.fromYmd(lunarYear, month, day).getSolarDay(),
        );
        // 先用无时区日序过滤，再创建有产品边界的日期，边缘年份不会被相邻年中断。
        if (number >= first.dayNumber && number <= last.dayNumber) {
          result.add(DayHoliday(code, DateOnly.fromDayNumber(number)));
        }
      }
      final eve =
          _solarDayNumber(
            tyme.LunarDay.fromYmd(lunarYear + 1, 1, 1).getSolarDay(),
          ) -
          1;
      if (eve >= first.dayNumber && eve <= last.dayNumber) {
        result.add(
          DayHoliday('lunar_new_year_eve', DateOnly.fromDayNumber(eve)),
        );
      }
    }
    result.sort((a, b) {
      final date = a.date.compareTo(b.date);
      return date != 0 ? date : a.code.compareTo(b.code);
    });
    return result;
  });

  /// 库类型只在门面内出现，跨模块传递纯数值和业务对象。
  int _solarDayNumber(tyme.SolarDay solar) =>
      DateTime.utc(
        solar.getYear(),
        solar.getMonth(),
        solar.getDay(),
      ).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// 捕获外部日期库异常并保留堆栈，日志不包含输入日期和名称。
  T _guard<T>(String operation, T Function() work) {
    try {
      return work();
    } on DayDateException {
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        '历法计算失败：$operation',
        name: 'Days.Calendar',
        error: error.runtimeType.toString(),
        stackTrace: stackTrace,
      );
      throw DayDateException(
        'calendar_calculation_failed',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
