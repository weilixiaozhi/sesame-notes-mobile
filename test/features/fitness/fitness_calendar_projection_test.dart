import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_home_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/app_expandable_calendar.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 训练快照的读取计数用来检测按日期反复扫描整个列表的回归。
class _CountingWorkouts extends ListBase<FitnessWorkout> {
  /// 训练模型保持固定，查询和日历仅有读取权限。
  _CountingWorkouts(this.values);
  final List<FitnessWorkout> values;
  int reads = 0;

  @override
  int get length => values.length;

  @override
  set length(int value) => throw UnsupportedError('训练快照不可修改');

  /// 列表迭代的每个训练读取均被记录。
  @override
  FitnessWorkout operator [](int index) {
    reads++;
    return values[index];
  }

  @override
  void operator []=(int index, FitnessWorkout value) =>
      throw UnsupportedError('训练快照不可修改');
}

/// 页面展示不会调用写入，仅隔离菜单预先读取的业务入口。
class _Actions extends Fake implements FitnessActions {}

/// 用真实运行片段表达已完成、暂停和跨午夜训练。
FitnessWorkout _workout(
  String id,
  String scheduledDate,
  String status, [
  List<FitnessRunSegment> segments = const [],
]) => FitnessWorkout(
  id: id,
  name: id,
  scheduledDate: scheduledDate,
  status: status,
  runSegments: segments,
);

/// 独立按日查询作为行为基准，验证区间投影只改变工作量而不改变日期语义。
void main() {
  test('一次区间投影与逐日查询一致，包含暂停间隙、跨午夜和重复状态', () {
    try {
      final start = DateTime(2026, 11, 1);
      final until = DateTime(2026, 11, 9);
      final now = DateTime(2026, 11, 7, 12);
      final data = [
        _workout('z-running', '2026-11-01', 'in_progress', [
          FitnessRunSegment(startedAt: DateTime(2026, 11, 4, 23)),
        ]),
        _workout('a-paused', '2026-11-02', 'in_progress', [
          FitnessRunSegment(
            startedAt: DateTime(2026, 11, 2, 9),
            endedAt: DateTime(2026, 11, 3, 1),
          ),
          FitnessRunSegment(
            startedAt: DateTime(2026, 11, 5, 22),
            endedAt: DateTime(2026, 11, 6, 1),
          ),
        ]),
        _workout('done', '2026-10-30', 'completed', [
          FitnessRunSegment(
            startedAt: DateTime(2026, 10, 31, 23),
            endedAt: DateTime(2026, 11, 2, 1),
          ),
        ]),
        _workout('planned', '2026-11-07', 'scheduled'),
        _workout('planned-again', '2026-11-07', 'scheduled'),
        _workout('outside', '2026-11-09', 'scheduled'),
      ];
      final counted = _CountingWorkouts(data);
      final projected = fitnessCalendarWorkoutStatuses(
        counted,
        start: start,
        until: until,
        now: now,
      );
      expect(counted.reads, data.length, reason: '每次投影只遍历一次训练快照');
      for (
        var date = start;
        date.isBefore(until);
        date = DateTime(date.year, date.month, date.day + 1)
      ) {
        final expected = {
          for (final workout in fitnessWorkoutsOnDate(
            data,
            fitnessDate(date),
            now: now,
          ))
            (
              status: workout.status,
              paused:
                  workout.status == 'in_progress' &&
                  workout.runSegments.isNotEmpty &&
                  workout.runSegments.last.endedAt != null,
            ),
        }.toList();
        expect(
          projected[fitnessDate(date)] ?? [],
          expected,
          reason: '日期${fitnessDate(date)}的状态、去重和顺序须与明细一致',
        );
      }
      expect(projected.containsKey('2026-10-30'), isFalse);
      expect(projected.containsKey('2026-11-09'), isFalse);
      expect(
        projected['2026-11-04']!.any((state) => state.paused),
        isFalse,
        reason: '暂停间隙不能被投影为训练日',
      );
    } catch (error, stackTrace) {
      debugPrint('健身日历区间投影回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('跨多年运行区间仅生成可见日期', () {
    try {
      final projected = fitnessCalendarWorkoutStatuses(
        [
          _workout('long', '1900-01-01', 'completed', [
            FitnessRunSegment(
              startedAt: DateTime(1900),
              endedAt: DateTime(2200, 12, 31),
            ),
          ]),
        ],
        start: DateTime(2026, 11, 1),
        until: DateTime(2026, 11, 8),
        now: DateTime(2026, 11, 6),
      );
      expect(projected.keys, [
        for (var day = 1; day <= 7; day++)
          '2026-11-${day.toString().padLeft(2, '0')}',
      ]);
      expect(projected.values.every((values) => values.length == 1), isTrue);
    } catch (error, stackTrace) {
      debugPrint('健身跨年投影边界回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  testWidgets('训练首页展开月历只扫描有限次快照，日期标签保持可用', (tester) async {
    try {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateUtils.dateOnly(DateTime.now());
      final data = _CountingWorkouts([
        for (var index = 0; index < 300; index++)
          _workout(
            'planned-$index',
            fitnessDate(DateTime(now.year, now.month, index % 28 + 1)),
            'scheduled',
          ),
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentFitnessSpaceIdProvider.overrideWithBuild(
              (ref, notifier) => 'space',
            ),
            localTodayProvider.overrideWithBuild((ref, notifier) => now),
            fitnessActionsProvider.overrideWithValue(_Actions()),
            fitnessTemplatesProvider.overrideWith((ref) => Stream.value([])),
            fitnessWorkoutsInRangeProvider.overrideWith(
              (ref, range) => Stream.value(data),
            ),
            fitnessCalendarPlansProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FitnessHomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      data.reads = 0;
      await tester.tap(
        find.byKey(const ValueKey('fitness-calendar-range-toggle')),
      );
      await tester.pumpAndSettle();
      expect(
        data.reads,
        lessThanOrEqualTo(data.length * 3),
        reason: '展开月历不能为每个日期重新扫描和排序全月训练',
      );
      final calendar = tester.widget<AppExpandableCalendar>(
        find.byType(AppExpandableCalendar),
      );
      expect(calendar.expanded, isTrue);
      final context = tester.element(find.byType(AppExpandableCalendar));
      final labels =
          calendar.dayMarkerBuilder(
                context,
                DateTime(now.year, now.month, 1),
                false,
              )
              as AppCalendarLabels;
      expect(labels.labels, [
        AppLocalizations.of(context).fitnessCalendarPlanned,
      ]);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('训练首页日历遍历量回归失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
