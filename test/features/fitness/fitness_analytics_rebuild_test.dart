import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_sync_status.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_analytics_page.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_body_map.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/widgets/app_analytics_period.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';

/// 统计对历史训练的读取次数，不以运行耗时判断缓存是否生效。
class _ReadCountingList extends ListBase<FitnessWorkout> {
  /// 保持不可变快照语义，记录顺序遍历和随机访问。
  _ReadCountingList(this.values);
  final List<FitnessWorkout> values;
  int reads = 0;

  @override
  int get length => values.length;

  @override
  set length(int value) => throw UnsupportedError('统计不得改写训练快照');

  /// 页面汇总每次读取一笔训练时递增。
  @override
  FitnessWorkout operator [](int index) {
    reads++;
    return values[index];
  }

  @override
  void operator []=(int index, FitnessWorkout value) =>
      throw UnsupportedError('统计不得改写训练快照');
}

/// 同一动作可迁移主肌群，目录变化必须使人体统计随之更新。
FitnessExerciseDefinition _definition(String target) =>
    FitnessExerciseDefinition(
      id: 'exercise',
      nameZh: '测试动作',
      nameZhHant: '測試動作',
      nameEn: 'Test exercise',
      bodyPart: 'chest',
      target: target,
      equipment: 'barbell',
      gifAsset: '',
      secondaryMuscles: const [],
      instructionsZh: const [],
      instructionsZhHant: const [],
      instructionsEn: const [],
    );

/// 固定归档日期和有效完成组，令范围与训练量变化可直接核对。
FitnessWorkout _workout(int year, String weight) => FitnessWorkout(
  id: 'workout-$year',
  name: '训练 $year',
  scheduledDate: '$year-11-06',
  status: 'completed',
  runSegments: [
    FitnessRunSegment(
      startedAt: DateTime.utc(year, 11, 6, 10),
      endedAt: DateTime.utc(year, 11, 6, 11),
    ),
  ],
  exercises: [
    FitnessExercise(
      id: 'exercise-instance',
      exerciseId: 'exercise',
      sets: [FitnessSet(id: 'set', weight: weight, reps: 8, completed: true)],
    ),
  ],
);

/// 人体筛选只调整展示，训练、目录、日期和周期变化仍应重新汇总。
void main() {
  testWidgets('人体筛选复用汇总，数据、范围和空间生命周期使缓存失效', (tester) async {
    final changes = StreamController<List<FitnessWorkout>>.broadcast();
    try {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var workouts = _ReadCountingList([
        _workout(2026, '20'),
        _workout(2025, '40'),
      ]);
      var catalog = [_definition('pectorals')];
      final date = DateTime(2026, 11, 6);
      final space = FitnessSpace(
        id: 'space',
        name: '训练空间',
        createdAt: date,
        updatedAt: date,
      );
      final spaceState =
          NotifierProvider<
            SimpleStateNotifier<AsyncValue<FitnessSpace?>>,
            AsyncValue<FitnessSpace?>
          >(() => SimpleStateNotifier((ref) => AsyncData(space)));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentFitnessSpaceProvider.overrideWith(
              (ref) => ref.watch(spaceState),
            ),
            fitnessSyncStatusProvider.overrideWith(
              (ref) async => const FitnessSyncStatus(isComplete: true),
            ),
            fitnessCatalogProvider.overrideWith((ref) async => catalog),
            fitnessTaxonomiesProvider.overrideWithValue(null),
            fitnessWorkoutBoundsProvider.overrideWith(
              (ref) => Stream.value((earliest: DateTime(2025), latest: date)),
            ),
            fitnessWorkoutsInRangeProvider.overrideWith((ref, range) async* {
              yield workouts;
              yield* changes.stream;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FitnessAnalyticsPage(embedded: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FitnessAnalyticsPage)),
      );

      /// 通过页面真实选择回调切换范围，不修改测试专用内部状态。
      Future<void> selectDate(DateTime value) async {
        tester
            .widget<AppAnalyticsPeriodHeader>(
              find.byType(AppAnalyticsPeriodHeader),
            )
            .onDateChanged(value);
        await tester.pumpAndSettle();
      }

      /// 读取人体图实际收到的已汇总训练量。
      FitnessBodyMap body() =>
          tester.widget<FitnessBodyMap>(find.byType(FitnessBodyMap));

      await selectDate(date);
      expect(body().bodyPartVolumeKg['chest'], 160);
      workouts.reads = 0;
      for (final part in ['chest', 'back', 'chest']) {
        body().onSelected(part);
        await tester.pumpAndSettle();
      }
      expect(workouts.reads, 0, reason: '人体展示筛选不应反复聚合全部历史完成组');

      workouts = _ReadCountingList([
        _workout(2026, '30'),
        _workout(2025, '40'),
      ]);
      changes.add(workouts);
      await tester.pumpAndSettle();
      expect(workouts.reads, greaterThan(0));
      expect(body().bodyPartVolumeKg['chest'], 240);

      workouts.reads = 0;
      catalog = [_definition('lats')];
      container.invalidate(fitnessCatalogProvider);
      await tester.pumpAndSettle();
      expect(workouts.reads, greaterThan(0));
      expect(body().bodyPartVolumeKg['back'], 240);
      expect(body().bodyPartVolumeKg.containsKey('chest'), isFalse);

      workouts.reads = 0;
      await selectDate(DateTime(2025, 11, 6));
      expect(workouts.reads, greaterThan(0));
      expect(body().bodyPartVolumeKg['back'], 320);

      workouts.reads = 0;
      container
          .read(fitnessAnalyticsPeriodProvider.notifier)
          .set(AnalyticsPeriod.year);
      await tester.pumpAndSettle();
      await selectDate(DateTime(2025, 11, 6));
      expect(workouts.reads, greaterThan(0));
      expect(body().bodyPartVolumeKg['back'], 320);

      // 同一列表对象恢复也必须重新聚合，证明不可用期间已经释放旧快照。
      for (final unavailable in <AsyncValue<FitnessSpace?>>[
        const AsyncData(null),
        const AsyncLoading(),
        AsyncError(StateError('空间加载失败'), StackTrace.current),
      ]) {
        workouts.reads = 0;
        container.read(spaceState.notifier).set(unavailable);
        // 加载态有持续旋转动画，只交付状态变更，不等待动画静止。
        await tester.pump();
        await tester.pump();
        expect(find.byType(FitnessBodyMap), findsNothing);
        expect(workouts.reads, 0);
        container.read(spaceState.notifier).set(AsyncData(space));
        await tester.pumpAndSettle();
        expect(workouts.reads, greaterThan(0), reason: '空间不可用期间不能保留并再次沿用旧汇总快照');
        expect(body().bodyPartVolumeKg['back'], 320);
      }

      workouts.reads = 0;
      container
          .read(spaceState.notifier)
          .set(
            AsyncData(
              FitnessSpace(
                id: 'other-space',
                name: '另一个训练空间',
                createdAt: date,
                updatedAt: date,
              ),
            ),
          );
      await tester.pumpAndSettle();
      expect(workouts.reads, greaterThan(0), reason: '切换空间即使数据引用相同也必须重新计算');
      expect(body().bodyPartVolumeKg['back'], 320);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('健身统计刷新范围回归失败：$error\n$stackTrace');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await changes.close();
    }
  });
}
