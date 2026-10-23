import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';

/// 创建保留原始公历日期的固定测试输入。
OriginalDate solar(String value) => OriginalDate.solar(DateOnly.parse(value));

/// 创建循环规则测试的具体日期倒数。
DayEventDefinition fixed(String value, {String repeat = DayRepeatType.none}) =>
    DayEventDefinition(
      category: DayCategory.countdown,
      name: '日期',
      repeatType: repeat,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.fixedDate,
      event: solar(value),
    );

/// 创建包含起日的倒数测试输入。
DayEventDefinition interval(int days, {String start = '2026-09-01'}) =>
    DayEventDefinition(
      category: DayCategory.countdown,
      name: '周期',
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.intervalDays,
      intervalDays: days,
      start: solar(start),
    );

/// 创建农历固定输入，不用待测算法生成期望。
OriginalDate lunar(int year, int month, int day, {bool leap = false}) =>
    OriginalDate(
      calendarType: DayCalendarType.lunar,
      originalYear: year,
      originalMonth: month,
      originalDay: day,
      isLeapMonth: leap,
    );

/// 创建农历循环输入。
DayEventDefinition lunarRepeat(OriginalDate original, String repeat) =>
    DayEventDefinition(
      category: DayCategory.countdown,
      name: '农历',
      repeatType: repeat,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.fixedDate,
      event: original,
    );

void main() {
  test('拒绝废弃的倒数循环和周岁枚举，不静默改写', () {
    const rules = DayDateRules();
    for (final repeat in ['yearly', 'monthly', 'interval_days']) {
      expect(
        () => rules.validateAndProject(fixed('2026-09-09', repeat: repeat)),
        throwsA(isA<DayDateException>()),
      );
    }
    expect(
      () => rules.validateAndProject(
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '生日',
          repeatType: DayRepeatType.yearly,
          statisticType: 'age',
          event: solar('2000-01-01'),
        ),
      ),
      throwsA(isA<DayDateException>()),
    );
  });

  const rules = DayDateRules();
  const calendar = LunarCalendar();
  final invalid = isA<DayDateException>();

  group('纯日期和名称边界', () {
    test('拒绝不存在的日期、非规范文本与范围外输入', () {
      for (final input in [
        '2026-02-30',
        '2025-02-29',
        '2026-2-01',
        '2026-01-01T00:00:00Z',
        ' 2026-01-01',
        '1900-12-31',
        '2101-01-01',
      ]) {
        expect(() => DateOnly.parse(input), throwsA(invalid), reason: input);
      }
      expect(DateOnly.parse('1975-05-01').iso8601, '1975-05-01');
      expect(DateOnly.minimum.iso8601, '1901-01-01');
      expect(DateOnly.maximum.iso8601, '2100-12-31');
    });

    test('D12 D13 自然日差不会受夏令时影响', () {
      expect(
        DateOnly.parse('2026-01-01').daysUntil(DateOnly.parse('2026-09-06')),
        248,
      );
      expect(
        DateOnly.parse('2026-09-06').daysUntil(DateOnly.parse('2026-01-01')),
        -248,
      );
      expect(
        DateOnly.parse('2025-03-08').daysUntil(DateOnly.parse('2025-03-10')),
        2,
      );
      expect(
        DateOnly.parse('2026-09-01').daysUntil(DateOnly.parse('2026-09-01')),
        0,
      );
    });

    test('名称使用共同空白表和 Unicode 码点上限', () {
      expect(normalizeDayName('\u0085\uFEFF 家庭\t日子 \u3000'), '家庭\t日子');
      expect(normalizeDayName('😀' * 100).runes.length, 100);
      expect(() => normalizeDayName('😀' * 101), throwsA(invalid));
      expect(() => normalizeDayName('\u0085 \uFEFF'), throwsA(invalid));
      expect(() => normalizeDayName('\u200B'), throwsA(invalid));
    });
  });

  group('公历日期规则', () {
    test('生日年月日统计保留未来原始日期', () {
      final future = DayEventDefinition(
        category: DayCategory.birthday,
        name: '出生',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: solar('2026-09-07'),
      );
      expect(
        rules.validateAndProject(future).statisticType,
        DayStatisticType.year,
      );
      expect(
        rules.validateAndProject(future).event!.solarDate!.iso8601,
        '2026-09-07',
      );
    });

    test('D02 年循环从原始闰日定位，不累积回落结果', () {
      final definition = DayEventDefinition(
        category: DayCategory.anniversary,
        name: '周年',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: solar('2000-02-29'),
      );
      expect(
        rules.nextOccurrence(definition, DateOnly.parse('2025-01-01'))!.iso8601,
        '2025-02-28',
      );
      expect(
        rules.nextOccurrence(definition, DateOnly.parse('2028-01-01'))!.iso8601,
        '2028-02-29',
      );
      expect(definition.event!.originalDay, 29);
    });

    test('固定日期倒数只发生一次，不生成后续月份', () {
      final events = rules.eventsInRange(
        fixed('2026-01-31', repeat: DayRepeatType.none),
        DateOnly.parse('2026-01-01'),
        DateOnly.parse('2026-03-31'),
      );
      expect(events.map((e) => e.date.iso8601), ['2026-01-31']);
    });

    test('X天倒数包含起日，过期后不生成下次', () {
      final definition = interval(5);
      for (final sample in {
        '2026-08-30': '2026-09-05',
        '2026-09-05': '2026-09-05',
        '2026-09-06': null,
      }.entries) {
        expect(
          rules.nextOccurrence(definition, DateOnly.parse(sample.key))?.iso8601,
          sample.value,
        );
      }
      expect(
        rules
            .eventsInRange(
              definition,
              DateOnly.parse('2026-09-01'),
              DateOnly.parse('2026-09-15'),
            )
            .map((e) => e.date.iso8601),
        ['2026-09-05'],
      );
    });

    test('X等于1只有起日，校验间隔范围并保留未来起点', () {
      expect(
        rules.nextOccurrence(interval(1), DateOnly.parse('2026-09-03')),
        isNull,
      );
      expect(
        rules.nextOccurrence(interval(1), DateOnly.parse('2026-09-02')),
        isNull,
      );
      expect(
        rules
            .nextOccurrence(interval(1), DateOnly.parse('2026-08-30'))!
            .iso8601,
        '2026-09-01',
      );
      expect(
        rules
            .eventsInRange(
              interval(1),
              DateOnly.parse('2026-09-01'),
              DateOnly.parse('2026-09-05'),
            )
            .map((e) => e.date.iso8601),
        ['2026-09-01'],
      );
      for (final value in [0, -1, 36501]) {
        expect(
          () => rules.validateAndProject(interval(value)),
          throwsA(invalid),
        );
      }
      expect(
        rules
            .validateAndProject(interval(36500, start: '1901-01-01'))
            .intervalDays,
        36500,
      );
    });

    test('D11 工具允许零并与倒数包含起日区别', () {
      final start = DateOnly.parse('2026-09-01');
      final result = rules.offsetDates(start, 5);
      expect(result.before.iso8601, '2026-08-27');
      expect(result.after.iso8601, '2026-09-06');
      expect(rules.offsetDates(start, 0).before, start);
      expect(rules.offsetDates(start, 0).after, start);
      expect(() => rules.offsetDates(DateOnly.minimum, 1), throwsA(invalid));
      expect(() => rules.offsetDates(DateOnly.maximum, 1), throwsA(invalid));
      expect(() => rules.offsetDates(start, -1), throwsA(invalid));
    });

    test('D14 D15 D26 跨度使用原始起点的整年月共同锚点', () {
      final samples = [
        ('2020-02-29', '2021-02-28', (1, 0, 0)),
        ('2026-01-31', '2026-02-28', (0, 1, 0)),
        ('2026-01-31', '2026-03-30', (0, 1, 30)),
        ('2020-02-29', '2024-02-28', (3, 11, 30)),
        ('2026-09-06', '2026-09-06', (0, 0, 0)),
      ];
      for (final (start, end, expected) in samples) {
        final result = rules.span(DateOnly.parse(start), DateOnly.parse(end));
        expect(
          (result.years, result.months, result.days),
          expected,
          reason: '$start $end',
        );
      }
      expect(
        () => rules.span(
          DateOnly.parse('2026-09-07'),
          DateOnly.parse('2026-09-06'),
        ),
        throwsA(invalid),
      );
    });

    test('至今阶段只保存开始端点，日历不伪造每天的结束事件', () {
      final definition = DayEventDefinition(
        category: DayCategory.stage,
        name: '至今',
        repeatType: DayRepeatType.none,
        statisticType: DayStatisticType.year,
        start: solar('2026-09-01'),
      );
      expect(rules.validateAndProject(definition).end, isNull);
      final events = rules.eventsInRange(
        definition,
        DateOnly(2026, 9, 1),
        DateOnly(2026, 9, 30),
      );
      expect(events.map((e) => (e.date.iso8601, e.kind)), [
        ('2026-09-01', 'start'),
      ]);
      expect(rules.nextOccurrence(definition, DateOnly(2026, 9, 8)), isNull);
    });

    test('D16 阶段同日起止合并并拒绝逆序', () {
      final same = DayEventDefinition(
        category: DayCategory.stage,
        name: '阶段',
        repeatType: DayRepeatType.none,
        statisticType: DayStatisticType.year,
        start: solar('2026-09-06'),
        end: solar('2026-09-06'),
      );
      final events = rules.eventsInRange(
        same,
        DateOnly.parse('2026-09-01'),
        DateOnly.parse('2026-09-30'),
      );
      expect(events, hasLength(1));
      expect(events.single.kind, 'start_end');
      expect(rules.nextOccurrence(same, DateOnly.parse('2026-09-01')), isNull);
      expect(
        () => rules.validateAndProject(
          DayEventDefinition(
            category: DayCategory.stage,
            name: '逆序',
            repeatType: DayRepeatType.none,
            statisticType: DayStatisticType.day,
            start: solar('2026-09-07'),
            end: solar('2026-09-06'),
          ),
        ),
        throwsA(invalid),
      );
    });

    test('越过上界的首目标拒绝，已过期倒数返回无候选', () {
      expect(
        () => rules.validateAndProject(interval(2, start: '2100-12-31')),
        throwsA(invalid),
      );
      expect(
        rules.nextOccurrence(
          interval(3, start: '2100-12-25'),
          DateOnly.parse('2100-12-31'),
        ),
        isNull,
      );
      expect(
        rules.eventsInRange(
          fixed('2000-02-29'),
          DateOnly.parse('1999-01-01'),
          DateOnly.parse('1999-12-31'),
        ),
        isEmpty,
      );
    });
  });

  group('静态组合与投影写边界', () {
    test('拒绝不存在的枚举、半端点、不适用字段与错误投影', () {
      final invalidDefinitions = [
        DayEventDefinition(
          category: 'unknown',
          name: '非法',
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.day,
        ),
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '生日',
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.year,
          event: solar('2000-01-01'),
        ),
        DayEventDefinition(
          category: DayCategory.anniversary,
          name: '纪念',
          repeatType: DayRepeatType.yearly,
          statisticType: 'age',
          event: solar('2000-01-01'),
        ),
        DayEventDefinition(
          category: DayCategory.stage,
          name: '缺失开始的阶段',
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.day,
          end: solar('2000-01-01'),
        ),
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '生日',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          intervalDays: 1,
          event: solar('2000-01-01'),
        ),
        DayEventDefinition(
          category: DayCategory.countdown,
          name: '倒数',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.day,
          countdownMode: DayCountdownMode.intervalDays,
          intervalDays: 5,
          start: solar('2000-01-01'),
        ),
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '生日',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          event: OriginalDate(
            calendarType: DayCalendarType.solar,
            originalYear: 2000,
            originalMonth: 1,
            originalDay: 1,
            solarDate: DateOnly.parse('2000-01-02'),
          ),
        ),
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '生日',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          event: const OriginalDate(
            calendarType: DayCalendarType.solar,
            originalYear: 2000,
            originalMonth: 1,
            originalDay: 1,
            isLeapMonth: true,
          ),
        ),
      ];
      for (final definition in invalidDefinitions) {
        expect(() => rules.validateAndProject(definition), throwsA(invalid));
      }
    });
  });

  group('HKO独立农历黄金向量', () {
    test('普通二月和闰二月月首月末，原始小月30日拒绝', () {
      final vectors = [
        (lunar(2023, 2, 1), '2023-02-20'),
        (lunar(2023, 2, 30), '2023-03-21'),
        (lunar(2023, 2, 1, leap: true), '2023-03-22'),
        (lunar(2023, 2, 29, leap: true), '2023-04-19'),
      ];
      for (final (original, expected) in vectors) {
        expect(calendar.toSolar(original).iso8601, expected);
        final reverse = calendar.fromSolar(DateOnly.parse(expected));
        expect(
          (
            reverse.originalYear,
            reverse.originalMonth,
            reverse.originalDay,
            reverse.isLeapMonth,
          ),
          (
            original.originalYear,
            original.originalMonth,
            original.originalDay,
            original.isLeapMonth,
          ),
        );
      }
      expect(
        () => calendar.toSolar(lunar(2023, 2, 30, leap: true)),
        throwsA(invalid),
      );
    });

    test('农历固定日期倒数只发生一次，不在闰月重复', () {
      final events = rules.eventsInRange(
        lunarRepeat(lunar(2023, 2, 30), DayRepeatType.none),
        DateOnly.parse('2023-03-01'),
        DateOnly.parse('2023-05-31'),
      );
      expect(events.map((e) => e.date.iso8601), ['2023-03-21']);
    });

    test('D05 闰月年循环在缺少闰二月的年份不发生', () {
      final definition = DayEventDefinition(
        category: DayCategory.anniversary,
        name: '农历周年',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: lunar(2023, 2, 1, leap: true),
      );
      expect(
        rules.eventsInRange(
          definition,
          DateOnly.parse('2024-01-01'),
          DateOnly.parse('2024-12-31'),
        ),
        isEmpty,
      );
      expect(
        rules.nextOccurrence(definition, DateOnly.parse('2023-03-22'))!.iso8601,
        '2023-03-22',
      );
      expect(
        rules.nextOccurrence(definition, DateOnly.parse('2023-03-23'))!.year,
        greaterThan(2024),
      );
    });

    test('D17 两个不同历法端点完整保留', () {
      final stage = DayEventDefinition(
        category: DayCategory.stage,
        name: '阶段',
        repeatType: DayRepeatType.none,
        statisticType: DayStatisticType.year,
        start: lunar(2023, 2, 1, leap: true),
        end: solar('2023-04-19'),
      );
      final validated = rules.validateAndProject(stage);
      expect(validated.start!.calendarType, DayCalendarType.lunar);
      expect(validated.start!.isLeapMonth, isTrue);
      expect(validated.start!.solarDate!.iso8601, '2023-03-22');
      expect(validated.end!.calendarType, DayCalendarType.solar);
      expect(validated.end!.solarDate!.iso8601, '2023-04-19');
    });

    test('1901公历下界允许对应农历1900年', () {
      final lunarDate = calendar.fromSolar(DateOnly.minimum);
      expect(
        (
          lunarDate.originalYear,
          lunarDate.originalMonth,
          lunarDate.originalDay,
        ),
        (1900, 11, 11),
      );
      expect(calendar.toSolar(lunar(1900, 11, 11)), DateOnly.minimum);
      expect(() => calendar.toSolar(lunar(1900, 11, 10)), throwsA(invalid));
    });

    test('D25 2023固定节日按公历年筛选且闰月不重复', () {
      final holidays = calendar.holidays(2023);
      expect(holidays.map((e) => (e.code, e.date.iso8601)), [
        ('new_year', '2023-01-01'),
        ('lunar_new_year_eve', '2023-01-21'),
        ('spring_festival', '2023-01-22'),
        ('lantern_festival', '2023-02-05'),
        ('qingming', '2023-04-05'),
        ('labour_day', '2023-05-01'),
        ('dragon_boat', '2023-06-22'),
        ('qixi', '2023-08-22'),
        ('mid_autumn', '2023-09-29'),
        ('national_day', '2023-10-01'),
        ('double_ninth', '2023-10-23'),
      ]);
    });

    test('边界公历年份不会被应过滤的越界农历候选中断', () {
      for (final year in [1901, 2100]) {
        final holidays = calendar.holidays(year);
        expect(holidays, hasLength(11));
        expect(holidays.every((e) => e.date.year == year), isTrue);
      }
    });
  });
}
