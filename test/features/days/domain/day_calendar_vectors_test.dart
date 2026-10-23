import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';

/// 将独立固定样本作为原始输入，不调用待测转换生成预期。
OriginalDate _original(Map<String, dynamic> sample) => OriginalDate(
  calendarType: DayCalendarType.lunar,
  originalYear: sample['year'] as int,
  originalMonth: sample['month'] as int,
  originalDay: sample['day'] as int,
  isLeapMonth: sample['is_leap_month'] as bool,
);

/// 构造以身份而非名字区分的排序输入。
DayEvent _event(
  String id,
  String category,
  String date, {
  String book = 'A',
  String repeat = DayRepeatType.none,
  String? end,
  DateTime? created,
}) => DayEvent(
  id: id,
  dayBookId: book,
  createdAt: created ?? DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  definition: DayEventDefinition(
    category: category,
    name: '同名记录',
    repeatType:
        category == DayCategory.birthday || category == DayCategory.anniversary
        ? DayRepeatType.yearly
        : repeat,
    statisticType: DayStatisticType.day,
    countdownMode: category == DayCategory.countdown
        ? DayCountdownMode.fixedDate
        : null,
    event: category == DayCategory.stage
        ? null
        : OriginalDate.solar(DateOnly.parse(date)),
    start: category == DayCategory.stage
        ? OriginalDate.solar(DateOnly.parse(date))
        : null,
    end: end == null ? null : OriginalDate.solar(DateOnly.parse(end)),
  ),
);

void main() {
  const rules = DayDateRules();
  const lunar = LunarCalendar();

  test('月历农历、节气、节日与闰月使用固定日期样本', () {
    for (final (date, label, lunarDate) in [
      (DateTime(2026, 9, 7), '白露', '七月廿六'),
      (DateTime(2026, 9, 9), '廿八', '七月廿八'),
      (DateTime(2026, 9, 10), '教师节', '七月廿九'),
      (DateTime(2026, 9, 11), '八月', '八月初一'),
      (DateTime(2026, 9, 23), '秋分', '八月十三'),
      (DateTime(2026, 9, 25), '中秋节', '八月十五'),
      (DateTime(2026, 2, 16), '除夕', '十二月廿九'),
      (DateTime(2026, 2, 17), '春节', '正月初一'),
      (DateTime(2023, 3, 22), '闰二月', '闰二月初一'),
    ]) {
      final info = lunar.dayInfo(date);
      expect(info.label, label, reason: '$date');
      expect(info.lunarDate, lunarDate, reason: '$date');
    }
    for (final date in [DateTime(1899, 12, 31), DateTime(2201, 1, 1)]) {
      expect(lunar.dayInfo(date).lunarDate, isNotEmpty);
    }
  });

  test('跨年份的节日日期仍包含农历与节日名称', () {
    for (final year in [2027, 2028, 2030]) {
      final info = lunar.dayInfo(DateTime(year, 1, 1));
      expect(info.label, '元旦');
      expect(info.isFestival, isTrue);
      expect(info.lunarDate, isNotEmpty);
    }
  });

  test('双端共享固定黄金向量与严格非法农历输入', () {
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/day_calendar_vectors.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    for (final sample
        in (fixture['lunar_to_solar'] as List).cast<Map<String, dynamic>>()) {
      final original = _original(sample);
      final expected = DateOnly.parse(sample['solar_date'] as String);
      expect(lunar.toSolar(original), expected, reason: sample.toString());
      expect(lunar.fromSolar(expected), original.withSolarDate(expected));
    }
    for (final sample
        in (fixture['invalid_lunar'] as List).cast<Map<String, dynamic>>()) {
      expect(
        () => lunar.toSolar(_original(sample)),
        throwsA(
          isA<DayDateException>().having(
            (error) => error.code,
            'code',
            sample['error'],
          ),
        ),
      );
    }
    for (final sample
        in (fixture['spans'] as List).cast<Map<String, dynamic>>()) {
      final result = rules.span(
        DateOnly.parse(sample['start'] as String),
        DateOnly.parse(sample['end'] as String),
      );
      expect(
        (result.years, result.months, result.days),
        (sample['years'], sample['months'], sample['days']),
      );
    }
    for (final sample
        in (fixture['name_normalization'] as List)
            .cast<Map<String, dynamic>>()) {
      if (sample['expected'] == null) {
        expect(
          () => normalizeDayName(sample['input'] as String),
          throwsException,
        );
      } else {
        expect(normalizeDayName(sample['input'] as String), sample['expected']);
      }
    }
  });

  test('闰月生日按农历寻找下次周年，统计使用年月日', () {
    const original = OriginalDate(
      calendarType: DayCalendarType.lunar,
      originalYear: 2023,
      originalMonth: 2,
      originalDay: 1,
      isLeapMonth: true,
    );
    const definition = DayEventDefinition(
      category: DayCategory.birthday,
      name: '生日',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: original,
    );
    final next = rules.nextOccurrence(
      definition,
      DateOnly.parse('2026-09-06'),
    )!;
    expect(next.iso8601, '2042-03-22');
    expect(
      rules.validateAndProject(definition).statisticType,
      DayStatisticType.year,
    );
  });

  test('D18 D19 近期卡片包含今天、排除阶段过期倒数并严格隔离本', () {
    final today = DateOnly.parse('2026-09-06');
    final entries = [
      _event('stage', DayCategory.stage, '2026-09-06', end: '2026-09-07'),
      _event('expired', DayCategory.countdown, '2026-09-05'),
      _event('other-book', DayCategory.birthday, '2000-09-06', book: 'B'),
      _event('b', DayCategory.birthday, '2000-09-06'),
      _event('anniversary', DayCategory.anniversary, '2000-09-06'),
      _event('a', DayCategory.birthday, '2000-09-06'),
    ];
    expect(rules.recentEvent(entries, today, dayBookId: 'A')!.id, 'a');
    expect(rules.recentEvent(entries, today, dayBookId: 'B')!.id, 'other-book');
    expect(rules.recentEvent(entries.take(2), today, dayBookId: 'A'), isNull);
    expect(
      rules
          .sortEvents(entries.reversed, today, dayBookId: 'A')
          .map((e) => e.id),
      ['a', 'b', 'anniversary', 'expired', 'stage'],
    );
  });

  test('倒数顺序为未到目标优先、过期目标降序', () {
    final today = DateOnly.parse('2100-12-31');
    final entries = [
      _event('older', DayCategory.countdown, '2100-12-28'),
      _event(
        'exhausted',
        DayCategory.countdown,
        '2100-01-01',
        repeat: DayRepeatType.none,
      ),
      _event('newer', DayCategory.countdown, '2100-12-30'),
      _event('today', DayCategory.countdown, '2100-12-31'),
      _event('stage-old', DayCategory.stage, '2000-01-01', end: '2000-01-02'),
      _event('stage-new', DayCategory.stage, '2001-01-01', end: '2001-01-02'),
    ];
    expect(rules.sortEvents(entries, today, dayBookId: 'A').map((e) => e.id), [
      'today',
      'newer',
      'older',
      'exhausted',
      'stage-new',
      'stage-old',
    ]);
  });

  test('D24 可见网格裁剪边界且使用与首页相同的目标', () {
    final definition = _event(
      'edge',
      DayCategory.birthday,
      '1901-01-01',
    ).definition;
    final occurrences = rules.eventsInCalendarRange(
      definition,
      DateTime(1900, 12, 30),
      DateTime(1901, 2, 3),
    );
    expect(occurrences.map((e) => e.date.iso8601), ['1901-01-01']);
    expect(
      occurrences.single.date,
      rules.nextOccurrence(definition, DateOnly.minimum),
    );
    expect(
      rules.eventsInCalendarRange(
        definition,
        DateTime(2101, 1, 1),
        DateTime(2101, 1, 31),
      ),
      isEmpty,
    );
    final monthly = _event(
      'month',
      DayCategory.countdown,
      '2026-01-31',
      repeat: DayRepeatType.none,
    ).definition;
    expect(
      rules
          .eventsInCalendarRange(
            monthly,
            DateTime(2026, 2, 23),
            DateTime(2026, 4, 5),
          )
          .map((e) => e.date.iso8601),
      isEmpty,
    );
  });
}
