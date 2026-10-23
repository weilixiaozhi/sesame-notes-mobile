import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_editor_validation.dart';

void main() {
  final today = DateOnly(2026, 9, 7);
  final future = DayEventDefinition(
    category: DayCategory.birthday,
    name: 'A',
    repeatType: DayRepeatType.yearly,
    statisticType: DayStatisticType.year,
    event: OriginalDate.solar(DateOnly(2026, 9, 8)),
  );
  test('至今阶段不接受未来开始日，固定未来结束日仍允许', () {
    final definition = DayEventDefinition(
      category: DayCategory.stage,
      name: '阶段',
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      start: OriginalDate.solar(today.addDays(1)),
    );
    expect(
      () => validateDayEditorDefinition(definition, today),
      throwsA(isA<DayDateException>()),
    );
    expect(
      validateDayEditorDefinition(
        DayEventDefinition(
          category: DayCategory.stage,
          name: '阶段',
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.day,
          start: OriginalDate.solar(today),
          end: OriginalDate.solar(today.addDays(1)),
        ),
        today,
      ).end,
      isNotNull,
    );
  });
  test('新增未来生日被拒绝', () {
    expect(
      () => validateDayEditorDefinition(future, today),
      throwsA(isA<DayDateException>()),
    );
  });
  test('跨时区后只编辑名称保留已保存的出生日期', () {
    expect(
      validateDayEditorDefinition(
        future,
        today,
        original: future,
      ).event?.solarDate,
      DateOnly(2026, 9, 8),
    );
  });
  test('将过去出生日期改成未来仍被拒绝', () {
    final old = DayEventDefinition(
      category: DayCategory.birthday,
      name: 'A',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2000, 1, 1)),
    );
    expect(
      () => validateDayEditorDefinition(future, today, original: old),
      throwsA(isA<DayDateException>()),
    );
  });
  test('仅切换公农历保留同一实际出生日期，跨时区后仍可保存', () {
    final old = DayEventDefinition(
      category: DayCategory.birthday,
      name: 'A',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2023, 1, 22)),
    );
    const value = DayEventDefinition(
      category: DayCategory.birthday,
      name: 'A',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2023,
        originalMonth: 1,
        originalDay: 1,
      ),
    );
    expect(
      validateDayEditorDefinition(
        value,
        DateOnly(2023, 1, 21),
        original: old,
      ).event?.solarDate,
      DateOnly(2023, 1, 22),
    );
  });
}
