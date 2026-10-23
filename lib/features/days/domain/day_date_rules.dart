import 'dart:math' as math;

import '../../../data/models/day_book.dart';
import '../../../data/models/day_event.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';

/// 固定分类顺序与业务枚举保持一致。
const dayCategoryOrder = [
  DayCategory.birthday,
  DayCategory.anniversary,
  DayCategory.countdown,
  DayCategory.stage,
];

/// 仓储注入的纯函数端口，不依赖设备今天或展示环境。
DayEventDefinition validateAndProject(DayEventDefinition definition) =>
    const DayDateRules().validateAndProject(definition);

/// 历法转换只改变原始日期的表达，实际公历日期保持不变。
///
/// 缺少公历投影的损坏日期不能参与转换：抛出稳定错误码，
/// 调用方保留原输入并要求用户先重新确认，而不是被切换绕过。
OriginalDate convertDayCalendar(OriginalDate date, String calendar) {
  if (date.calendarType == calendar) return date;
  final solar = date.solarDate;
  if (solar == null) throw const DayDateException('unreadable_projection');
  return calendar == DayCalendarType.solar
      ? OriginalDate.solar(solar)
      : const LunarCalendar().fromSolar(solar);
}

/// 年月日跨度的非负分量。
class DaySpan {
  final int years;
  final int months;
  final int days;

  /// 保存从原始起点计算的跨度。
  const DaySpan(this.years, this.months, this.days);
}

/// 日历中的单次派生事件。
class DayOccurrence {
  final DateOnly date;
  final String kind;

  /// 保存发生日期与普通、开始、结束或同日起止标识。
  const DayOccurrence(this.date, {this.kind = 'event'});
}

/// 日子定义校验和日期计算的共同入口。
class DayDateRules {
  static const _lunar = LunarCalendar();

  const DayDateRules();

  /// 静态验证定义并重新计算每个原始端点的公历投影。
  DayEventDefinition validateAndProject(DayEventDefinition definition) {
    final d = definition;
    final name = normalizeDayName(d.name);
    final standardStatistic =
        d.statisticType == DayStatisticType.year ||
        d.statisticType == DayStatisticType.day;
    final onlyEvent = d.event != null && d.start == null && d.end == null;
    final noCountdown = d.countdownMode == null && d.intervalDays == null;
    final valid = switch (d.category) {
      DayCategory.birthday =>
        onlyEvent &&
            noCountdown &&
            d.repeatType == DayRepeatType.yearly &&
            standardStatistic,
      DayCategory.anniversary =>
        onlyEvent &&
            noCountdown &&
            d.repeatType == DayRepeatType.yearly &&
            standardStatistic,
      DayCategory.countdown
          when d.countdownMode == DayCountdownMode.fixedDate =>
        onlyEvent &&
            d.intervalDays == null &&
            standardStatistic &&
            d.repeatType == DayRepeatType.none,
      DayCategory.countdown
          when d.countdownMode == DayCountdownMode.intervalDays =>
        d.event == null &&
            d.end == null &&
            d.start != null &&
            d.intervalDays != null &&
            d.intervalDays! >= 1 &&
            d.intervalDays! <= DayLimits.maxIntervalDays &&
            standardStatistic &&
            d.repeatType == DayRepeatType.none,
      DayCategory.stage =>
        d.event == null &&
            d.start != null &&
            noCountdown &&
            d.repeatType == DayRepeatType.none &&
            standardStatistic,
      _ => false,
    };
    if (!valid) throw const DayDateException('invalid_definition');
    final event = _project(d.event);
    final start = _project(d.start);
    final end = _project(d.end);
    if (d.category == DayCategory.stage &&
        end != null &&
        end.solarDate!.isBefore(start!.solarDate!)) {
      throw const DayDateException('stage_end_before_start');
    }
    if (d.countdownMode == DayCountdownMode.intervalDays) {
      // 倒数仅有一个目标，含起日且保存前必须验证范围。
      start!.solarDate!.addDays(d.intervalDays! - 1);
    }
    return DayEventDefinition(
      category: d.category,
      name: name,
      repeatType: d.repeatType,
      statisticType: d.statisticType,
      countdownMode: d.countdownMode,
      intervalDays: d.intervalDays,
      event: event,
      start: start,
      end: end,
    );
  }

  /// 验证原始日期真实性；传入投影必须与重新计算的结果一致。
  OriginalDate? _project(OriginalDate? original) {
    if (original == null) return null;
    final DateOnly solar;
    if (original.calendarType == DayCalendarType.solar &&
        !original.isLeapMonth) {
      solar = DateOnly(
        original.originalYear,
        original.originalMonth,
        original.originalDay,
      );
    } else if (original.calendarType == DayCalendarType.lunar) {
      solar = _lunar.toSolar(original);
    } else {
      throw const DayDateException('invalid_calendar');
    }
    if (original.solarDate != null && original.solarDate != solar) {
      throw const DayDateException('projection_mismatch');
    }
    return original.withSolarDate(solar);
  }

  /// 查找不早于今天和原始起点的下一次。
  DateOnly? nextOccurrence(DayEventDefinition definition, DateOnly today) {
    return _nextOccurrence(validateAndProject(definition), today);
  }

  /// 已完成静态校验的定义直接生成下一次日期，排序时复用同一份公历投影。
  DateOnly? _nextOccurrence(DayEventDefinition definition, DateOnly today) {
    if (definition.category == DayCategory.stage) return null;
    return _occurrences(definition, today, DateOnly.maximum).firstOrNull?.date;
  }

  /// 计算闭区间内的事件。
  List<DayOccurrence> eventsInRange(
    DayEventDefinition definition,
    DateOnly from,
    DateOnly to,
  ) {
    if (to.isBefore(from)) throw const DayDateException('invalid_date_range');
    return _occurrences(
      validateAndProject(definition),
      from,
      to,
    ).toList(growable: false);
  }

  /// 日历网格允许相邻月跨出边界，先裁剪再使用统一事件算法。
  List<DayOccurrence> eventsInCalendarRange(
    DayEventDefinition definition,
    DateTime from,
    DateTime to,
  ) {
    final fromNumber =
        DateTime.utc(from.year, from.month, from.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final toNumber =
        DateTime.utc(to.year, to.month, to.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    if (toNumber < fromNumber) {
      throw const DayDateException('invalid_date_range');
    }
    final start = math.max<int>(fromNumber, DateOnly.minimum.dayNumber);
    final end = math.min<int>(toNumber, DateOnly.maximum.dayNumber);
    final validated = validateAndProject(definition);
    if (end < start) return const [];
    return _occurrences(
      validated,
      DateOnly.fromDayNumber(start),
      DateOnly.fromDayNumber(end),
    ).toList(growable: false);
  }

  /// 首页和日历共同使用有界候选生成器；查找下一次时只消费首项。
  Iterable<DayOccurrence> _occurrences(
    DayEventDefinition d,
    DateOnly from,
    DateOnly to,
  ) sync* {
    if (d.category == DayCategory.stage) {
      final start = d.start!.solarDate!;
      final end = d.end?.solarDate;
      if (!start.isBefore(from) && !start.isAfter(to)) {
        yield DayOccurrence(start, kind: start == end ? 'start_end' : 'start');
      }
      if (end != null &&
          end != start &&
          !end.isBefore(from) &&
          !end.isAfter(to)) {
        yield DayOccurrence(end, kind: 'end');
      }
      return;
    }
    final original = d.event ?? d.start!;
    final origin = original.solarDate!;
    final lower = math.max<int>(from.dayNumber, origin.dayNumber);
    if (lower > to.dayNumber) return;
    if (d.countdownMode == DayCountdownMode.intervalDays) {
      final interval = d.intervalDays!;
      final first = origin.dayNumber + interval - 1;
      if (first >= lower && first <= to.dayNumber) {
        yield DayOccurrence(DateOnly.fromDayNumber(first));
      }
      return;
    }
    if (d.category == DayCategory.countdown ||
        d.repeatType == DayRepeatType.none) {
      if (origin.dayNumber >= lower && !origin.isAfter(to)) {
        yield DayOccurrence(origin);
      }
      return;
    }
    final lowerDate = DateOnly.fromDayNumber(lower);
    if (original.calendarType == DayCalendarType.solar) {
      for (var year = lowerDate.year; year <= to.year; year++) {
        final date = _solarAnchor(
          year,
          original.originalMonth,
          original.originalDay,
        );
        if (date.dayNumber >= lower && !date.isAfter(to)) {
          yield DayOccurrence(date);
        }
      }
      return;
    }
    final firstYear = _lunar.fromSolar(lowerDate).originalYear;
    final lastYear = _lunar.fromSolar(to).originalYear;
    for (var year = firstYear; year <= lastYear; year++) {
      final number = _lunar.yearlyDayNumber(original, year);
      if (number != null && number >= lower && number <= to.dayNumber) {
        yield DayOccurrence(DateOnly.fromDayNumber(number));
      }
    }
  }

  /// 从原始日号一次定位目标月份，只对真实短月进行周期回落。
  DateOnly _solarAnchor(int year, int month, int originalDay) => DateOnly(
    year,
    month,
    math.min<int>(originalDay, DateOnly.daysInMonth(year, month)),
  );

  /// 使用原始起点作为整年和整月共同锚点。
  DaySpan span(DateOnly start, DateOnly end) {
    if (end.isBefore(start)) throw const DayDateException('invalid_date_range');
    var years = end.year - start.year;
    if (_solarAnchor(start.year + years, start.month, start.day).isAfter(end)) {
      years--;
    }
    var months = 0;
    var anchor = _solarAnchor(start.year + years, start.month, start.day);
    for (var candidate = 1; candidate <= 11; candidate++) {
      final targetMonth =
          (start.year + years) * 12 + start.month - 1 + candidate;
      if (targetMonth > end.year * 12 + end.month - 1) break;
      final date = _solarAnchor(
        targetMonth ~/ 12,
        targetMonth % 12 + 1,
        start.day,
      );
      if (date.isAfter(end)) break;
      months = candidate;
      anchor = date;
    }
    return DaySpan(years, months, anchor.daysUntil(end));
  }

  /// 日期工具计算前后日期，允许零天。
  ({DateOnly before, DateOnly after}) offsetDates(DateOnly start, int days) {
    if (days < 0 || days > DayLimits.maxIntervalDays) {
      throw const DayDateException('invalid_interval');
    }
    return (before: start.addDays(-days), after: start.addDays(days));
  }

  /// 解析工具输入并按自然日推算前后日期，非法文本与越界都不产生结果。
  ({DateOnly before, DateOnly after, int count}) offsetDatesFromText(
    DateOnly start,
    String text,
  ) {
    final count = int.tryParse(text);
    if (count == null) throw const DayDateException('invalid_interval');
    final dates = offsetDates(start, count);
    return (before: dates.before, after: dates.after, count: count);
  }

  /// 只按当前本固定分组排序，日期候选为每条记录计算一次。
  List<DayEvent> sortEvents(
    Iterable<DayEvent> events,
    DateOnly today, {
    required String dayBookId,
    Map<String, DateOnly?>? calculatedNext,
  }) {
    final rows = events
        .where((e) => e.dayBookId == dayBookId && e.deletedAt == null)
        .map((event) {
          // 同一记录只校验和投影一次，分组与候选日期共用校验后的定义。
          final definition = validateAndProject(event.definition);
          return (
            event: event,
            definition: definition,
            next: calculatedNext?.containsKey(event.id) == true
                ? calculatedNext![event.id]
                : _nextOccurrence(definition, today),
          );
        })
        .toList();
    rows.sort((a, b) {
      final category = DayCategory.values
          .indexOf(a.definition.category)
          .compareTo(DayCategory.values.indexOf(b.definition.category));
      if (category != 0) return category;
      if (a.definition.category == DayCategory.stage) {
        final start = b.definition.start!.solarDate!.compareTo(
          a.definition.start!.solarDate!,
        );
        return start != 0 ? start : _stableOrder(a.event, b.event);
      }
      if (a.next != null || b.next != null) {
        if (a.next == null) return 1;
        if (b.next == null) return -1;
        final date = a.next!.compareTo(b.next!);
        if (date != 0) return date;
      } else if (a.definition.category == DayCategory.countdown) {
        final date = _singleTarget(
          b.definition,
        ).compareTo(_singleTarget(a.definition));
        if (date != 0) return date;
      }
      return _stableOrder(a.event, b.event);
    });
    return rows.map((row) => row.event).toList(growable: false);
  }

  /// 当前本最近卡片排除阶段与过期单次，今天仍参与候选。
  DayEvent? recentEvent(
    Iterable<DayEvent> events,
    DateOnly today, {
    required String dayBookId,
    Map<String, DateOnly?>? calculatedNext,
  }) {
    final rows = events
        .where(
          (e) =>
              e.dayBookId == dayBookId &&
              e.deletedAt == null &&
              e.definition.category != DayCategory.stage,
        )
        .map(
          (event) => (
            event: event,
            next: calculatedNext?.containsKey(event.id) == true
                ? calculatedNext![event.id]
                : nextOccurrence(event.definition, today),
          ),
        )
        .where((row) => row.next != null)
        .toList();
    rows.sort((a, b) {
      final date = a.next!.compareTo(b.next!);
      if (date != 0) return date;
      final category = DayCategory.values
          .indexOf(a.event.definition.category)
          .compareTo(DayCategory.values.indexOf(b.event.definition.category));
      return category != 0 ? category : _stableOrder(a.event, b.event);
    });
    return rows.firstOrNull?.event;
  }

  /// 返回不循环倒数的唯一原始目标。
  DateOnly _singleTarget(DayEventDefinition d) =>
      d.event?.solarDate ?? d.start!.solarDate!.addDays(d.intervalDays! - 1);

  /// 创建审计时间和实体 ID 是跨设备一致的并列键。
  int _stableOrder(DayEvent a, DayEvent b) {
    final created = a.createdAt.compareTo(b.createdAt);
    return created != 0 ? created : a.id.compareTo(b.id);
  }
}
