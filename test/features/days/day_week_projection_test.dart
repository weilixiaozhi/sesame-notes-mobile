import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/presentation/days_home_page.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_week_strip.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/app_expandable_calendar.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 记录投影实际读取事件列表的次数，避免使用设备耗时作为性能断言。
class _CountingEvents extends ListBase<DayEvent> {
  /// 事件快照只允许读取，内容更新由新的列表表示。
  _CountingEvents(this.values);
  final List<DayEvent> values;
  int reads = 0;

  @override
  int get length => values.length;

  @override
  set length(int value) => throw UnsupportedError('事件快照不可修改');

  /// 顺序投影与重复遍历都经过索引读取。
  @override
  DayEvent operator [](int index) {
    reads++;
    return values[index];
  }

  @override
  void operator []=(int index, DayEvent value) =>
      throw UnsupportedError('事件快照不可修改');
}

/// 固定生日用于验证跨年循环、标签更新与切月投影。
DayEvent _birthday(String name) => DayEvent(
  id: 'birthday',
  dayBookId: 'book',
  definition: DayEventDefinition(
    category: DayCategory.birthday,
    name: name,
    repeatType: DayRepeatType.yearly,
    statisticType: DayStatisticType.year,
    event: OriginalDate.solar(DateOnly(2000, 11, 6)),
  ),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 11, 1),
);

/// 使用实际日历组件和本地化，测试与真实页面共用标签、周月切换逻辑。
Widget _app(Widget child) => MaterialApp(
  locale: const Locale('zh'),
  theme: AppTheme.lightTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// 周月切换和同月选日不重复派生事件，新数据与月份变化必须重新计算。
void main() {
  testWidgets('周月展示复用当前投影，事件与月份变化替换缓存', (tester) async {
    try {
      var events = _CountingEvents([_birthday('原生日')]);
      var selected = DateOnly(2026, 11, 6);
      late StateSetter update;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return DayWeekStrip(
                today: DateOnly(2026, 11, 6),
                selectedDay: selected,
                events: events,
                onDateSelected: (date) =>
                    setState(() => selected = DateOnly.fromDateTime(date)),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(events.reads, greaterThan(0));
      events.reads = 0;
      await tester.tap(
        find.byKey(const ValueKey('days-calendar-range-toggle')),
      );
      await tester.pumpAndSettle();
      expect(events.reads, 0, reason: '展开月历不应重新读取并派生全本事件');
      tester
          .widget<AppExpandableCalendar>(find.byType(AppExpandableCalendar))
          .onDateSelected(DateTime(2026, 11, 20));
      await tester.pumpAndSettle();
      expect(events.reads, 0, reason: '同月选日仅改变高亮和倒计时基准');

      /// 读取真实日历传入的业务标记，核对缓存更新后的名称和日期。
      List<String>? labels(DateTime date) =>
          (tester
                      .widget<AppExpandableCalendar>(
                        find.byType(AppExpandableCalendar),
                      )
                      .dayMarkerBuilder(
                        tester.element(find.byType(AppExpandableCalendar)),
                        date,
                        false,
                      )
                  as AppCalendarLabels?)
              ?.labels;

      expect(labels(DateTime(2026, 11, 6)), ['原生日']);
      final updated = _CountingEvents([_birthday('新生日')]);
      update(() => events = updated);
      await tester.pumpAndSettle();
      expect(updated.reads, greaterThan(0));
      expect(labels(DateTime(2026, 11, 6)), ['新生日']);

      updated.reads = 0;
      update(() => selected = DateOnly(2026, 12, 6));
      await tester.pumpAndSettle();
      expect(updated.reads, greaterThan(0));
      expect(labels(DateTime(2026, 11, 6)), isNull);
      updated.reads = 0;
      update(() => selected = DateOnly(2026, 11, 6));
      await tester.pumpAndSettle();
      expect(updated.reads, greaterThan(0), reason: '页面只保留当前一份月份投影');
      expect(labels(DateTime(2026, 11, 6)), ['新生日']);

      update(() => events = _CountingEvents([]));
      await tester.pumpAndSettle();
      expect(labels(DateTime(2026, 11, 6)), isNull);
      updated.reads = 0;
      update(() => events = updated);
      await tester.pumpAndSettle();
      expect(updated.reads, greaterThan(0), reason: '空列表已经替换旧事件快照');
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('日子日历投影复用回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  testWidgets('日子首页选日后继续传递原始事件快照', (tester) async {
    try {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final events = [_birthday('生日')];
      final stamp = DateTime(2026, 11, 6);
      final book = DayBook(
        id: 'book',
        name: '日子',
        createdAt: stamp,
        updatedAt: stamp,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentDayBookProvider.overrideWithValue(AsyncData(book)),
            currentDayBookIdProvider.overrideWithBuild(
              (ref, notifier) => book.id,
            ),
            dayTodayProvider.overrideWithValue(DateOnly(2026, 11, 6)),
            dayEventsProvider.overrideWith((ref, id) => Stream.value(events)),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DaysHomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final first = tester.widget<DayWeekStrip>(find.byType(DayWeekStrip));
      expect(first.events, same(events));
      first.onDateSelected(DateTime(2026, 11, 20));
      await tester.pumpAndSettle();
      expect(
        tester.widget<DayWeekStrip>(find.byType(DayWeekStrip)).events,
        same(events),
      );
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('日子首页事件快照回归失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
