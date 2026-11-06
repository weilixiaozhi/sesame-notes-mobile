import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_workout_page.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_clock.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_exercise_editor.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_home_cards.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_rest_completion_listener.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_rest_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';

/// 计时展示不执行持久化操作，保留详情页需要的固定目标。
class _Actions extends Fake implements FitnessActions {
  /// 使用稳定的本机空间身份。
  @override
  PrivateBookTarget get target =>
      (bookId: 'space', accountId: null, syncId: null, generation: 0);
}

/// 记录生产时钟的生命周期，不因测试观察主动保持时钟存活。
final class _ClockObserver extends ProviderObserver {
  bool active = false;
  int starts = 0;

  /// 第一个实际界面订阅创建时钟。
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (context.provider == fitnessClockProvider) {
      active = true;
      starts++;
    }
  }

  /// 最后一个界面订阅释放后计时器应随提供者结束。
  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (context.provider == fitnessClockProvider) active = false;
  }
}

/// 时间读取与周期任务使用同一可控时钟，推进虚拟秒数不会混入宿主时间。
class _Fixture {
  DateTime now = DateTime(2026, 11, 6, 12);
  final observer = _ClockObserver();

  /// 构造包含真实时间段的训练状态。
  FitnessWorkout workout({
    String status = 'in_progress',
    bool paused = false,
    FitnessRestTimer? rest,
  }) => FitnessWorkout(
    id: 'workout',
    name: '训练',
    scheduledDate: '2026-11-06',
    status: status,
    runSegments: status == 'scheduled'
        ? []
        : [
            FitnessRunSegment(
              startedAt: now.subtract(const Duration(seconds: 10)),
              endedAt: paused || status == 'completed' ? now : null,
            ),
          ],
    restTimer: rest,
  );

  /// 只替换业务数据端，界面的秒表仍执行生产实现。
  Widget app(Widget child, {FitnessWorkout? running}) => ProviderScope(
    observers: [observer],
    overrides: [
      localClockNowProvider.overrideWithValue(() => now),
      fitnessActionsProvider.overrideWithValue(_Actions()),
      reminderSettingsProvider.overrideWithBuild(
        (ref, notifier) =>
            const ReminderSettings(isEnabled: false, hour: 21, minute: 0),
      ),
      fitnessRunningWorkoutProvider.overrideWith((_) => Stream.value(running)),
      fitnessTemplatesProvider.overrideWith((_) => Stream.value([])),
      fitnessPreferencesProvider.overrideWith(
        (_) => Stream.value(const FitnessPreferences()),
      ),
      fitnessCatalogProvider.overrideWith((_) async => []),
      fitnessWorkoutProvider(
        'workout',
      ).overrideWith((_) => Stream.value(running)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh'),
      home: Scaffold(body: child),
    ),
  );

  /// 按秒推进真实计时源，额外帧用于交付流通知与自动释放。
  Future<void> advance(WidgetTester tester, int seconds) async {
    for (var i = 0; i < seconds; i++) {
      now = now.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();
    }
  }
}

/// 每项检查结束后卸载页面，避免页面观察者和动画影响下一项。
Future<void> _checked(WidgetTester tester, Future<void> Function() body) async {
  final previous = debugOnRebuildDirtyWidget;
  try {
    await body();
  } catch (error, stack) {
    debugPrint('健身计时检查失败：$error\n$stack');
    rethrow;
  } finally {
    debugOnRebuildDirtyWidget = previous;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }
}

/// 覆盖空闲资源释放、时长正确性、局部重建和休息到期提示。
void main() {
  for (final state in ['empty', 'disabled', 'paused']) {
    testWidgets(
      '全局休息提示在 $state 状态不启动秒表',
      (tester) => _checked(tester, () async {
        final fixture = _Fixture();
        final running = state == 'empty'
            ? null
            : fixture.workout(
                rest: FitnessRestTimer(
                  status: state == 'paused' ? 'paused' : 'running',
                  endsAt: fixture.now.add(const Duration(seconds: 10)),
                  remainingSeconds: 10,
                ),
              );
        await tester.pumpWidget(
          fixture.app(
            Stack(
              children: [
                FitnessRestCompletionListener(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  enabled: state != 'disabled',
                ),
              ],
            ),
            running: running,
          ),
        );
        await tester.pump();
        await fixture.advance(tester, 3);
        expect(fixture.observer.starts, 0);
        expect(
          find.byKey(const ValueKey('fitness-rest-completed-banner')),
          findsNothing,
        );
      }),
    );
  }

  for (final state in ['scheduled', 'completed', 'paused']) {
    testWidgets(
      '$state 训练卡不订阅秒表且时长保持不变',
      (tester) => _checked(tester, () async {
        final fixture = _Fixture();
        final workout = fixture.workout(
          status: state == 'paused' ? 'in_progress' : state,
          paused: state == 'paused',
        );
        await tester.pumpWidget(
          fixture.app(FitnessHomeWorkoutCard(workout: workout)),
        );
        await tester.pump();
        final expected = state == 'scheduled' ? '00:00:00' : '00:00:10';
        expect(find.text(expected), findsOneWidget);
        await fixture.advance(tester, 3);
        expect(find.text(expected), findsOneWidget);
        expect(fixture.observer.starts, 0);
      }),
    );
  }

  testWidgets(
    '训练卡每秒只更新时间文本，动作计数保持原构建',
    (tester) => _checked(tester, () async {
      final fixture = _Fixture();
      await tester.pumpWidget(
        fixture.app(FitnessHomeWorkoutCard(workout: fixture.workout())),
      );
      await tester.pump();
      await tester.pump();
      var cardBuilds = 0;
      var countBuilds = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is FitnessHomeWorkoutCard) cardBuilds++;
        if (element.widget is FitnessExerciseCounts) countBuilds++;
      };
      await fixture.advance(tester, 3);
      expect(find.text('00:00:13'), findsOneWidget);
      expect(cardBuilds, 0);
      expect(countBuilds, 0);
    }),
  );

  testWidgets(
    '训练详情计时不重建动作编辑器',
    (tester) => _checked(tester, () async {
      final fixture = _Fixture();
      await tester.pumpWidget(
        fixture.app(
          const FitnessWorkoutPage(
            workoutId: 'workout',
            analyticsContext: ProductAnalyticsContext(
              identity: ProductAnalyticsIdentity(null, 0),
            ),
          ),
          running: fixture.workout(),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(FitnessExerciseEditor), findsOneWidget);
      var editorBuilds = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is FitnessExerciseEditor) editorBuilds++;
      };
      await fixture.advance(tester, 3);
      expect(find.text('00:00:13'), findsOneWidget);
      expect(editorBuilds, 0);
    }),
  );

  testWidgets(
    '休息到期呈现提示并释放秒表，提示持续保留',
    (tester) => _checked(tester, () async {
      final fixture = _Fixture();
      final workout = fixture.workout(
        rest: FitnessRestTimer(
          endsAt: fixture.now.add(const Duration(seconds: 2)),
          remainingSeconds: 2,
          durationSeconds: 2,
        ),
      );
      await tester.pumpWidget(
        fixture.app(
          Stack(
            children: [
              FitnessRestCompletionListener(
                navigatorKey: GlobalKey<NavigatorState>(),
                enabled: true,
              ),
            ],
          ),
          running: workout,
        ),
      );
      await tester.pump();
      expect(fixture.observer.active, isTrue);
      expect(
        find.byKey(const ValueKey('fitness-rest-completed-banner')),
        findsNothing,
      );
      await fixture.advance(tester, 2);
      expect(
        find.byKey(const ValueKey('fitness-rest-completed-banner')),
        findsOneWidget,
      );
      expect(fixture.observer.active, isFalse);
      await fixture.advance(tester, 3);
      expect(
        find.byKey(const ValueKey('fitness-rest-completed-banner')),
        findsOneWidget,
      );
      expect(fixture.observer.active, isFalse);
    }),
  );

  testWidgets(
    '暂停后重新运行的时长立即对齐真实时间',
    (tester) => _checked(tester, () async {
      final fixture = _Fixture();
      final workout = fixture.workout();
      await tester.pumpWidget(
        fixture.app(
          TickerMode(
            enabled: false,
            child: FitnessWorkoutElapsedText(workout: workout),
          ),
        ),
      );
      await tester.pump();
      fixture.now = fixture.now.add(const Duration(seconds: 20));
      await tester.pumpWidget(
        fixture.app(
          TickerMode(
            enabled: true,
            child: FitnessWorkoutElapsedText(workout: workout),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('00:00:30'), findsOneWidget);
    }),
  );

  testWidgets(
    '训练详情在休息到期时只弹出一次结束态',
    (tester) => _checked(tester, () async {
      final fixture = _Fixture();
      final workout = fixture.workout(
        rest: FitnessRestTimer(
          endsAt: fixture.now.add(const Duration(seconds: 2)),
          remainingSeconds: 2,
          durationSeconds: 2,
        ),
      );
      await tester.pumpWidget(
        fixture.app(
          const FitnessWorkoutPage(
            workoutId: 'workout',
            analyticsContext: ProductAnalyticsContext(
              identity: ProductAnalyticsIdentity(null, 0),
            ),
          ),
          running: workout,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(FitnessRestSheet), findsNothing);
      await fixture.advance(tester, 2);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(FitnessRestSheet), findsOneWidget);
      final sheetContext = tester.element(find.byType(FitnessRestSheet));
      expect(
        find.text(AppLocalizations.of(sheetContext).fitnessRestCompletedTitle),
        findsWidgets,
      );
      await fixture.advance(tester, 3);
      expect(find.byType(FitnessRestSheet), findsOneWidget);
    }),
  );
}
