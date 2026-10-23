import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';

/// 验证节日滚动年度范围、日期边界与日期排序。
void main() {
  const calendar = LunarCalendar();

  test('年末跨年展示未来节日，过滤过去和一年以外的日期', () {
    final holidays = calendar.upcomingHolidays(DateOnly(2023, 12, 31));
    expect(holidays.first.date, DateOnly(2024, 1, 1));
    expect(holidays.last.date, DateOnly(2024, 10, 11));
    expect(holidays, hasLength(11));
    expect(
      holidays.singleWhere((e) => e.code == 'spring_festival').date,
      DateOnly(2024, 2, 10),
    );
    for (var index = 1; index < holidays.length; index++) {
      expect(
        holidays[index].date.compareTo(holidays[index - 1].date),
        greaterThanOrEqualTo(0),
      );
    }
  });

  test('保留今天的节日，明年同日不重复列入', () {
    final holidays = calendar.upcomingHolidays(DateOnly(2024, 10, 1));
    expect(holidays.first.code, 'national_day');
    expect(holidays.first.date, DateOnly(2024, 10, 1));
    expect(holidays.where((e) => e.code == 'national_day'), hasLength(1));
    expect(
      holidays.every((e) => e.date.isBefore(DateOnly(2025, 10, 1))),
      isTrue,
    );
  });

  test('闰日可跨至次年，日期上界不发生越界异常', () {
    final holidays = calendar.upcomingHolidays(DateOnly(2024, 2, 29));
    expect(holidays.first.date, DateOnly(2024, 4, 4));
    expect(holidays.last.date, DateOnly(2025, 2, 12));
    expect(calendar.upcomingHolidays(DateOnly.maximum), isEmpty);
    expect(
      calendar.upcomingHolidays(DateOnly.minimum).first.date,
      DateOnly.minimum,
    );
  });
}
