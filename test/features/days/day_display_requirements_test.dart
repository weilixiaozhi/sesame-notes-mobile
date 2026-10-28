import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations_zh.dart';

/// 验证纪念日时长、农历周岁和倒数日状态的业务口径。
void main() {
  final l10n = AppLocalizationsZh();
  final today = DateOnly(2026, 9, 8);

  test('闰日生日在平年二月末达到对应周岁', () {
    expect(
      dayMilestoneLabel(
        l10n,
        DayEventDefinition(
          category: DayCategory.birthday,
          name: '闰日',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          event: OriginalDate.solar(DateOnly(2000, 2, 29)),
        ),
        DateOnly(2025, 2, 28),
      ),
      '25周岁',
    );
  });

  test('农历生日的周岁按实际公历出生日期计算，出生前不显示负年龄', () {
    final definition = DayEventDefinition(
      category: DayCategory.birthday,
      name: '农历生日',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.day,
      event: OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: 2023,
        originalMonth: 1,
        originalDay: 1,
        solarDate: DateOnly(2023, 1, 22),
      ),
    );
    expect(dayMilestoneLabel(l10n, definition, DateOnly(2025, 1, 21)), '1周岁');
    expect(dayMilestoneLabel(l10n, definition, DateOnly(2025, 1, 22)), '2周岁');
    expect(dayMilestoneLabel(l10n, definition, DateOnly(2023, 1, 21)), isNull);
  });

  test('倒数日两种统计选项目标前后只显示还有、今天、已过期', () {
    for (final statistic in [DayStatisticType.year, DayStatisticType.day]) {
      for (final repeat in [DayRepeatType.none]) {
        final definition = DayEventDefinition(
          category: DayCategory.countdown,
          name: '目标',
          repeatType: repeat,
          statisticType: statistic,
          countdownMode: DayCountdownMode.fixedDate,
          event: OriginalDate.solar(today),
        );
        expect(dayStatisticLabel(l10n, definition, today.addDays(-1)), '还有1天');
        expect(dayStatisticLabel(l10n, definition, today), '今天');
        expect(dayStatisticLabel(l10n, definition, today.addDays(1)), '已过期');
      }
    }
  });
}
