/// 自定义月度周期工具(账本级 monthStartDay,1-31)。
///
/// 约定:
/// - 全库统一半开区间 [start, end)
/// - 周期按「起始月」命名:startDay=10 时「2026年6月」= 2026-06-10 ~ 2026-07-10
/// - startDay=1 全部退化为自然月,单代码路径
/// - 当月缺少设定日时以当月最后一天为起点,下一月重新按设定日计算
///
/// ⚠️ 两个语义不可混用:
/// - [periodForLabel]:标签 (year, month) → 范围。统计/图表用。
/// - [labelForDate]:日期 → 它所属周期的标签。「今天是几月」「滚动定位」用。
/// 把 DateTime(y, m, 1) 当日期喂给 containing 类逻辑会整体偏移一个周期。
library;

typedef DateRange = ({DateTime start, DateTime end});

/// 将设定日限制在有效日历日范围内。
int _clampDay(int startDay) => startDay.clamp(1, 31);

/// 计算当月的实际起点,短月取月末,避免 DateTime 将日期溢出到下月。
DateTime _periodStart(int year, int month, int startDay) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, _clampDay(startDay).clamp(1, lastDay));
}

/// 标签 (year, month) 对应的周期范围:[y-m-startDay, y-(m+1)-startDay)。
DateRange periodForLabel(int year, int month, int startDay) {
  return (
    start: _periodStart(year, month, startDay),
    end: _periodStart(year, month + 1, startDay),
  );
}

/// [date] 所属周期的「标签月」,返回 DateTime(y, m, 1)(仅作 key / 显示)。
/// 规则:日期达到当月实际起点时归当月,否则归上月。
/// [date] 必须是本地时间 DateTime;传 UTC 会在临近零点时错一天。
DateTime labelForDate(DateTime date, int startDay) {
  final start = _periodStart(date.year, date.month, startDay);
  if (!date.isBefore(start)) return DateTime(date.year, date.month, 1);
  return DateTime(date.year, date.month - 1, 1); // 0月 → 上年12月,Dart 自动借位
}

/// 「year 年」= [当年1月周期起点, 次年1月周期起点),恰 12 个完整周期。
DateRange yearRangeFor(int year, int startDay) {
  return (
    start: _periodStart(year, 1, startDay),
    end: _periodStart(year + 1, 1, startDay),
  );
}
