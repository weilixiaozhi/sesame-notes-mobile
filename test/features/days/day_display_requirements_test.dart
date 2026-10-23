import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations_zh.dart';

/// 验证纪念日时长、农历周岁和倒数日状态的业务口径。
void main() {
  final l10n = AppLocalizationsZh();
  final today = DateOnly(2026, 9, 8);

  test('各类别统计使用真实年月日与总天数，统一方向和零分量', () {
    final start = OriginalDate.solar(DateOnly(2000, 3, 19));
    for (final category in [DayCategory.birthday, DayCategory.anniversary]) {
      final definition = DayEventDefinition(
        category: category,
        name: '记录',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: start,
      );
      expect(dayStatisticLabel(l10n, definition, today), '已过26年5个月20天');
      expect(
        dayStatisticLabel(
          l10n,
          definition,
          today,
          statisticType: DayStatisticType.day,
        ),
        '已过9669天',
      );
      final unit = category == DayCategory.birthday ? '周岁' : '周年';
      expect(dayMilestoneLabel(l10n, definition, today), '26$unit');
      expect(
        dayMilestoneLabel(l10n, definition, DateOnly(2027, 3, 19)),
        '27$unit',
      );
    }
    final stage = DayEventDefinition(
      category: DayCategory.stage,
      name: '至今',
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.year,
      start: start,
    );
    expect(dayStatisticLabel(l10n, stage, today), '共26年5个月20天');
    expect(dayStatisticLabel(l10n, stage, today.addDays(1)), '共26年5个月21天');
    expect(
      dayStatisticLabel(
        l10n,
        stage,
        today,
        statisticType: DayStatisticType.day,
      ),
      '共9669天',
    );
    expect(
      dayRelativeDuration(
        l10n,
        DayStatisticType.year,
        today,
        DateOnly(2027, 1, 29),
      ),
      '还有4个月21天',
    );
    expect(
      dayRelativeDuration(
        l10n,
        DayStatisticType.year,
        today,
        DateOnly(2028, 1, 29),
      ),
      '还有1年4个月21天',
    );
    expect(
      dayRelativeDuration(l10n, DayStatisticType.year, today, today.addDays(1)),
      '还有1天',
    );
    expect(
      dayRelativeDuration(
        l10n,
        DayStatisticType.year,
        today,
        DateOnly(2027, 9, 8),
      ),
      '还有1年',
    );
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
