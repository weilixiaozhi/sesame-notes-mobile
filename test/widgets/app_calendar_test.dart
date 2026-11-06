import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 使用真实卡片内边距验证手机七列月历，保留日期选择与翻月的状态更新。
Future<void> _openCalendar(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  bool dark = false,
  ValueChanged<DateTime>? onDateSelected,
  ValueChanged<DateTime>? onMonthChanged,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var focused = DateTime(2026, 11);
  var selected = DateTime(2026, 11, 6);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.p12),
          child: StatefulBuilder(
            builder: (context, setState) => SectionCard(
              margin: EdgeInsets.zero,
              child: AppCalendar(
                firstDay: DateTime(1900),
                lastDay: DateTime(2200, 12, 31),
                focusedDay: focused,
                currentDay: DateTime(2026, 11, 6),
                adaptiveRows: true,
                showWeekDividers: true,
                selectedDayPredicate: (date) =>
                    DateUtils.isSameDay(date, selected),
                onDaySelected: (date, _) {
                  setState(() => selected = focused = date);
                  onDateSelected?.call(date);
                },
                onPageChanged: (date) {
                  setState(() => selected = focused = date);
                  onMonthChanged?.call(date);
                },
                dayMarkerBuilder: (context, date, outside) {
                  final labels = date.month != 11
                      ? const <CalendarDayLabel>[]
                      : switch (date.day) {
                          6 => const [
                            CalendarDayLabel(
                              '妈妈生日',
                              tone: CalendarDayLabelTone.peach,
                            ),
                          ],
                          7 => const [
                            CalendarDayLabel(
                              '力量训练',
                              tone: CalendarDayLabelTone.sage,
                            ),
                          ],
                          12 => const [
                            CalendarDayLabel(
                              '周年纪念',
                              tone: CalendarDayLabelTone.peach,
                            ),
                            CalendarDayLabel(
                              '备忘录 2',
                              tone: CalendarDayLabelTone.purple,
                            ),
                          ],
                          25 => const [
                            CalendarDayLabel(
                              '很长的训练名称仍可查看完整内容',
                              tone: CalendarDayLabelTone.sage,
                            ),
                          ],
                          _ => const <CalendarDayLabel>[],
                        };
                  return AppCalendarDayMarkers(
                    key: ValueKey('markers-${date.month}-${date.day}'),
                    labels: labels,
                    amountText: date.month != 11
                        ? null
                        : switch (date.day) {
                            2 => '-¥28',
                            7 => '-¥36',
                            12 => '-¥68',
                            21 => '-¥123456789.12',
                            _ => null,
                          },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 日期和标签的直接容器代表可见边界，便于验证实际留白而非文字基线。
Finder _cellContent(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(Container)).first;

/// 验证真实布局的紧凑内容流、可读性和原有日期导航。
void main() {
  testWidgets('无账目生日紧贴日期，空日期不占标记高度', (tester) async {
    await _openCalendar(tester);
    final date = tester.getRect(_cellContent('6'));
    final birthday = tester.getRect(_cellContent('妈妈生日'));
    expect(birthday.top - date.bottom, closeTo(AppDimens.p4, 0.01));
    expect(
      tester.getSize(find.byKey(const ValueKey('markers-11-5'))).height,
      0,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('markers-11-6')),
        matching: find.byType(AppCalendarValue),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('事项在金额前且仅内容较多的一周增高，日期顶部保持对齐', (tester) async {
    await _openCalendar(tester);
    final anniversary = tester.getRect(_cellContent('周年纪念'));
    final memo = tester.getRect(_cellContent('备忘录 2'));
    final amount = tester.getRect(find.text('-¥68'));
    expect(anniversary.bottom, lessThanOrEqualTo(memo.top));
    expect(memo.bottom, lessThanOrEqualTo(amount.top));
    expect(
      tester.getRect(_cellContent('2')).top,
      tester.getRect(_cellContent('6')).top,
    );
    final busyWeek =
        tester.getTopLeft(_cellContent('16')).dy -
        tester.getTopLeft(_cellContent('9')).dy;
    final lightWeek =
        tester.getTopLeft(_cellContent('23')).dy -
        tester.getTopLeft(_cellContent('16')).dy;
    expect(busyWeek, greaterThan(lightWeek));
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('窄屏大字体保持单列内可读，业务标签跟随${dark ? '深' : '浅'}色主题', (tester) async {
      await _openCalendar(tester, width: 320, scale: 2, dark: dark);
      for (final text in [
        '妈妈生日',
        '周年纪念',
        '备忘录 2',
        '力量训练',
        '很长的训练名称仍可查看完整内容',
        '-¥123456789.12',
      ]) {
        final rect = tester.getRect(find.text(text));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
      }
      final context = tester.element(find.text('妈妈生日'));
      expect(
        tester.widget<Text>(find.text('妈妈生日')).style!.color,
        AppTokens.peachForeground(context),
      );
      expect(
        tester.widget<Text>(find.text('备忘录 2')).style!.color,
        AppTokens.purpleForeground(context),
      );
      expect(
        tester.widget<Text>(find.text('力量训练')).style!.color,
        AppTokens.sageForeground(context),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('点击事项选择对应日期，箭头与横滑保持翻月能力', (tester) async {
    DateTime? selected;
    DateTime? focused;
    await _openCalendar(
      tester,
      onDateSelected: (date) => selected = date,
      onMonthChanged: (date) => focused = date,
    );
    await tester.tap(find.text('周年纪念'));
    await tester.pumpAndSettle();
    expect(DateUtils.isSameDay(selected, DateTime(2026, 11, 12)), isTrue);
    await tester.tap(find.byType(IconButton).last);
    await tester.pumpAndSettle();
    expect(DateUtils.isSameDay(focused, DateTime(2026, 12)), isTrue);
    await tester.drag(find.byType(Table), const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(DateUtils.isSameDay(focused, DateTime(2026, 11)), isTrue);
    expect(find.text('妈妈生日'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
