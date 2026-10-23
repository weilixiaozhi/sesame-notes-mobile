import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

void main() {
  group('periodForLabel', () {
    test('startDay=1 退化为自然月', () {
      final r = periodForLabel(2026, 6, 1);
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 7, 1));
    });
    test('startDay=10: 6月 = [6.10, 7.10)', () {
      final r = periodForLabel(2026, 6, 10);
      expect(r.start, DateTime(2026, 6, 10));
      expect(r.end, DateTime(2026, 7, 10));
    });
    test('12月跨年进位', () {
      final r = periodForLabel(2026, 12, 10);
      expect(r.end, DateTime(2027, 1, 10));
    });
    test('2月 startDay=28 不溢出', () {
      final r = periodForLabel(2026, 2, 28);
      expect(r.start, DateTime(2026, 2, 28));
      expect(r.end, DateTime(2026, 3, 28));
    });

    test('31日按各月末日回退，后续月份恢复设定日', () {
      expect(periodForLabel(2026, 1, 31), (
        start: DateTime(2026, 1, 31),
        end: DateTime(2026, 2, 28),
      ));
      expect(periodForLabel(2026, 2, 31), (
        start: DateTime(2026, 2, 28),
        end: DateTime(2026, 3, 31),
      ));
      expect(periodForLabel(2028, 2, 31), (
        start: DateTime(2028, 2, 29),
        end: DateTime(2028, 3, 31),
      ));
      expect(periodForLabel(2026, 4, 31), (
        start: DateTime(2026, 4, 30),
        end: DateTime(2026, 5, 31),
      ));
    });

    test('29日和30日仅在当月缺少设定日时回退', () {
      expect(periodForLabel(2026, 2, 29), (
        start: DateTime(2026, 2, 28),
        end: DateTime(2026, 3, 29),
      ));
      expect(periodForLabel(2028, 2, 30), (
        start: DateTime(2028, 2, 29),
        end: DateTime(2028, 3, 30),
      ));
      expect(periodForLabel(2026, 4, 30), (
        start: DateTime(2026, 4, 30),
        end: DateTime(2026, 5, 30),
      ));
    });
  });

  group('labelForDate', () {
    test('日 >= startDay 归当月(含起始日当天)', () {
      expect(labelForDate(DateTime(2026, 6, 10), 10), DateTime(2026, 6, 1));
      expect(labelForDate(DateTime(2026, 6, 28), 10), DateTime(2026, 6, 1));
    });
    test('日 < startDay 归上月', () {
      expect(labelForDate(DateTime(2026, 6, 9), 10), DateTime(2026, 5, 1));
    });
    test('1月初借位到上年12月', () {
      expect(labelForDate(DateTime(2026, 1, 5), 10), DateTime(2025, 12, 1));
    });
    test('startDay=1 恒归当月', () {
      expect(labelForDate(DateTime(2026, 1, 1), 1), DateTime(2026, 1, 1));
    });

    test('31日账期以当月实际起点归属，月底当日属于新周期', () {
      expect(labelForDate(DateTime(2026, 1, 30), 31), DateTime(2025, 12));
      expect(labelForDate(DateTime(2026, 1, 31), 31), DateTime(2026, 1));
      expect(labelForDate(DateTime(2026, 2, 27), 31), DateTime(2026, 1));
      expect(labelForDate(DateTime(2026, 2, 28), 31), DateTime(2026, 2));
      expect(labelForDate(DateTime(2028, 2, 28), 31), DateTime(2028, 1));
      expect(labelForDate(DateTime(2028, 2, 29), 31), DateTime(2028, 2));
      expect(labelForDate(DateTime(2026, 3, 30), 31), DateTime(2026, 2));
      expect(labelForDate(DateTime(2026, 3, 31), 31), DateTime(2026, 3));
      expect(labelForDate(DateTime(2026, 4, 29), 31), DateTime(2026, 3));
      expect(labelForDate(DateTime(2026, 4, 30), 31), DateTime(2026, 4));
    });
  });

  group('标签与账期范围一致', () {
    test('31日的当前周期覆盖月底回退和恢复后的所有日期', () {
      expect(_periodContaining(DateTime(2028, 2, 28, 23, 59), 31), (
        start: DateTime(2028, 1, 31),
        end: DateTime(2028, 2, 29),
      ));
      expect(_periodContaining(DateTime(2028, 2, 29), 31), (
        start: DateTime(2028, 2, 29),
        end: DateTime(2028, 3, 31),
      ));
      for (final year in [2026, 2028]) {
        for (var offset = 0; offset < 150; offset++) {
          final date = DateTime(year, 1, 1 + offset);
          final range = _periodContaining(date, 31);
          expect(date.isBefore(range.start), isFalse, reason: '$date');
          expect(date.isBefore(range.end), isTrue, reason: '$date');
        }
      }
    });
    test('任意日期落在自己的周期内(连续 70 天无缝)', () {
      const sd = 15;
      for (int offset = 0; offset < 70; offset++) {
        final date = DateTime(2026, 5, 1).add(Duration(days: offset));
        final r = _periodContaining(date, sd);
        expect(
          !date.isBefore(r.start) && date.isBefore(r.end),
          isTrue,
          reason: '$date 应落在 [${r.start}, ${r.end})',
        );
      }
    });
    test('startDay=28 跨 2 月无缝(最难边界)', () {
      const sd = 28;
      for (int offset = 0; offset < 70; offset++) {
        final date = DateTime(2026, 2, 1).add(Duration(days: offset));
        final r = _periodContaining(date, sd);
        expect(
          !date.isBefore(r.start) && date.isBefore(r.end),
          isTrue,
          reason: '$date 应落在 [${r.start}, ${r.end})',
        );
      }
    });
  });

  group('yearRangeFor', () {
    test('年 = [当年1月周期起点, 次年1月周期起点)', () {
      final r = yearRangeFor(2026, 10);
      expect(r.start, DateTime(2026, 1, 10));
      expect(r.end, DateTime(2027, 1, 10));
    });
    test('31日年周期仍为十二个完整月周期', () {
      expect(yearRangeFor(2026, 31), (
        start: DateTime(2026, 1, 31),
        end: DateTime(2027, 1, 31),
      ));
    });
  });
}

/// 验证标签归属与范围生成两条生产路径的一致性。
DateRange _periodContaining(DateTime date, int startDay) {
  final label = labelForDate(date, startDay);
  return periodForLabel(label.year, label.month, startDay);
}
