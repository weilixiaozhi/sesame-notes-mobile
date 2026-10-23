import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/models/fitness_sync_status.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_analytics_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/analytics_page.dart';
import 'package:sesame_notes/features/statistics/application/analytics_queries.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/app_analytics_period.dart';
import 'package:sesame_notes/shared/widgets/capsule_switcher.dart';
import 'package:sesame_notes/shared/widgets/date_wheel_column.dart';
import 'package:sesame_notes/shared/widgets/wheel_date_picker.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 页面保留真实周期和日期行为，统计读数固定为空以隔离数据库与网络。
class _EmptyAnalyticsQueries extends Fake implements AnalyticsQueries {
  /// 空序列让页面呈现真实空态，日期切换仍经过正常查询入口。
  @override
  Future<AnalyticsData> load({
    required String ledgerId,
    required String type,
    required AnalyticsPeriod period,
    required int selectedYear,
    required int monthStartDay,
    required DateRange current,
  }) async => const AnalyticsData(
    catData: [],
    series: DailyAnalyticsSeries([]),
    txCount: 0,
    sum: 0,
  );
}

/// 两类页面共享测试容器，真实周期提供者保持独立且不访问持久化层。
Future<ProviderContainer> _container({bool datesEnabled = false}) async {
  final now = DateTime.now();
  final bounds = (earliest: DateTime(now.year - 1, 1), latest: now);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      // 布局使用本次夹具的日期快照，午夜调度由独立时钟回归验证。
      localTodayProvider.overrideWithBuild(
        (ref, notifier) => DateTime(now.year, now.month, now.day),
      ),
      dataChangeSignalProvider.overrideWith((ref) => const Stream.empty()),
      currentMonthStartDayProvider.overrideWithValue(1),
      currentLedgerCurrencyProvider.overrideWithValue('CNY'),
      analyticsHasAnyExpenseProvider.overrideWith((ref) async => datesEnabled),
      analyticsDataRangeProvider.overrideWith((ref) async => bounds),
      analyticsQueriesProvider.overrideWithValue(_EmptyAnalyticsQueries()),
      ledgerUnconvertedForeignTxCountProvider.overrideWith((ref) async => 0),
      ledgerForeignTxCountProvider.overrideWith((ref) async => 0),
      currentFitnessSpaceProvider.overrideWithValue(
        AsyncData(
          datesEnabled
              ? FitnessSpace(
                  id: 'analytics-test-space',
                  name: '训练空间',
                  createdAt: now,
                  updatedAt: now,
                )
              : null,
        ),
      ),
      fitnessWorkoutsInRangeProvider.overrideWith(
        (ref, range) => Stream.value([]),
      ),
      fitnessWorkoutBoundsProvider.overrideWith((ref) => Stream.value(bounds)),
      fitnessCatalogProvider.overrideWith((ref) async => []),
      fitnessSyncStatusProvider.overrideWith(
        (ref) async => const FitnessSyncStatus(isComplete: true),
      ),
    ],
  );
  try {
    // 提前解析全局空态，避免首次挂载时依赖不相关的加载时间。
    await container.read(analyticsHasAnyExpenseProvider.future);
    await container.read(analyticsDataRangeProvider.future);
    return container;
  } catch (error, stack) {
    container.dispose();
    debugPrint('创建统计页面回归环境失败：$error');
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
}

/// 真实主题和中文文案下加载完整页面，页面身份切换时清除上一业务的本地状态。
Future<void> _pumpPage(
  WidgetTester tester,
  ProviderContainer container, {
  required bool fitness,
  bool embedded = false,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, page) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: page!,
        ),
        home: fitness
            ? FitnessAnalyticsPage(embedded: embedded)
            : AnalyticsPage(embedded: embedded),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 在真实底部入口点击指定周期，避免通过写提供者跳过用户交互。
Future<void> _selectPeriod(WidgetTester tester, AnalyticsPeriod period) async {
  final context = tester.element(find.byType(AppAnalyticsPeriodSwitcher));
  final l = AppLocalizations.of(context);
  final label = switch (period) {
    AnalyticsPeriod.week => l.analyticsWeek,
    AnalyticsPeriod.month => l.analyticsMonth,
    AnalyticsPeriod.year => l.analyticsYear,
  };
  await tester.tap(
    find.descendant(
      of: find.byType(AppAnalyticsPeriodSwitcher),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

/// 日期选择通过实际滚轮滚动一年，再点击完成提交业务页面的日期状态。
Future<DateTime> _selectPreviousYear(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('analytics_date_action')));
  await tester.pumpAndSettle();
  expect(find.byType(WheelDatePicker), findsOneWidget);
  final yearWheel = find.byType(AppWheelColumn).first;
  await tester.drag(yearWheel, const Offset(0, 40));
  await tester.pumpAndSettle();
  final context = tester.element(find.byType(WheelDatePicker));
  await tester.tap(find.text(AppLocalizations.of(context).commonDone));
  await tester.pumpAndSettle();
  expect(find.byType(WheelDatePicker), findsNothing);
  return tester
      .widget<AppAnalyticsPeriodHeader>(find.byType(AppAnalyticsPeriodHeader))
      .selectedDate;
}

/// 验证真实统计页面的布局和交互，防止业务各自维护入口造成位置与样式漂移。
void main() {
  testWidgets('记账与健身各周期的头部、子周期和底部入口使用相同布局', (tester) async {
    try {
      final container = await _container();
      addTearDown(container.dispose);
      final layouts = <AnalyticsPeriod, (Rect, Rect, TextStyle?)>{};
      for (final fitness in [false, true]) {
        await _pumpPage(tester, container, fitness: fitness);
        final switcherElement = tester.element(
          find.byType(AppAnalyticsPeriodSwitcher),
        );
        for (final period in AnalyticsPeriod.values) {
          await _selectPeriod(tester, period);
          final header = find.byType(AppAnalyticsPeriodHeader);
          final date = find.byKey(const ValueKey('analytics_date_action'));
          final subPeriods = find.byKey(
            const ValueKey('analytics_sub_periods'),
          );
          final dateText = tester.widget<Text>(
            find.descendant(of: date, matching: find.byType(Text)),
          );
          final dateRect = tester.getRect(date);
          final subRect = tester.getRect(subPeriods);
          expect(
            tester.widget<AppAnalyticsPeriodHeader>(header).period,
            period,
          );
          expect(
            dateText.style,
            AppTextTokens.strongTitle(tester.element(date)),
          );
          expect(dateRect.left, AppDimens.domainPageInset);
          expect(subRect.left, dateRect.left);
          expect(subRect.top, greaterThanOrEqualTo(dateRect.bottom));
          expect(find.byType(AppAnalyticsPeriodSwitcher), findsOneWidget);
          final switcherRect = tester.getRect(
            find.byType(AppAnalyticsPeriodSwitcher),
          );
          expect(switcherRect.width, 144);
          expect(switcherRect.left, AppDimens.domainPageInset);
          expect(switcherRect.top, greaterThan(subRect.bottom));
          expect(
            tester.element(find.byType(AppAnalyticsPeriodSwitcher)),
            same(switcherElement),
            reason: '周期切换不能卸载重建底部入口',
          );
          final actual = (dateRect, subRect, dateText.style);
          if (!fitness) {
            layouts[period] = actual;
          } else {
            expect(actual, layouts[period], reason: '同周期两业务的头部必须对齐');
          }
          expect(tester.takeException(), isNull);
        }
      }
    } catch (error, stack) {
      debugPrint('统计页面统一布局回归失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  for (final fitness in [false, true]) {
    testWidgets('${fitness ? '健身' : '记账'}嵌入外壳时没有重复周期入口', (tester) async {
      try {
        final container = await _container();
        addTearDown(container.dispose);
        await _pumpPage(tester, container, fitness: fitness, embedded: true);
        expect(find.byType(AppAnalyticsPeriodHeader), findsOneWidget);
        expect(find.byType(AppAnalyticsPeriodSwitcher), findsNothing);
        expect(find.byType(CapsuleSwitcher<AnalyticsPeriod>), findsNothing);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('统计嵌入布局回归失败：fitness=$fitness，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });

    testWidgets('${fitness ? '健身' : '记账'}日期选择、回本期与另一业务周期互不干扰', (tester) async {
      try {
        final container = await _container(datesEnabled: true);
        addTearDown(container.dispose);
        await _pumpPage(tester, container, fitness: fitness);
        await _selectPeriod(tester, AnalyticsPeriod.year);
        final previous = await _selectPreviousYear(tester);
        expect(previous.year, DateTime.now().year - 1);
        final headerFinder = find.byType(AppAnalyticsPeriodHeader);
        final l = AppLocalizations.of(tester.element(headerFinder));
        expect(find.text(l.analyticsBackToThisYear), findsOneWidget);
        await _selectPeriod(tester, AnalyticsPeriod.month);
        expect(
          tester
              .widget<AppAnalyticsPeriodHeader>(headerFinder)
              .selectedDate
              .year,
          DateTime.now().year,
          reason: '切换周期后使用该周期自己的日期',
        );
        await _selectPeriod(tester, AnalyticsPeriod.year);
        expect(
          tester
              .widget<AppAnalyticsPeriodHeader>(headerFinder)
              .selectedDate
              .year,
          previous.year,
          reason: '切回年视图保留已选年份',
        );
        expect(
          container.read(
            fitness
                ? ledgerAnalyticsPeriodProvider
                : fitnessAnalyticsPeriodProvider,
          ),
          AnalyticsPeriod.month,
          reason: '另一业务维持自己的周期',
        );
        final dateRect = tester.getRect(
          find.byKey(const ValueKey('analytics_date_action')),
        );
        final current = find.text(l.analyticsBackToThisYear);
        expect(tester.getCenter(current).dy, dateRect.center.dy);
        await tester.tap(current);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AppAnalyticsPeriodHeader>(headerFinder)
              .selectedDate
              .year,
          DateTime.now().year,
        );
        expect(find.text(l.analyticsBackToThisYear), findsNothing);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('统计日期与周期隔离回归失败：fitness=$fitness，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });

    testWidgets('${fitness ? '健身' : '记账'}窄屏大字号切换周期没有布局溢出', (tester) async {
      try {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = await _container(datesEnabled: true);
        addTearDown(container.dispose);
        await _pumpPage(tester, container, fitness: fitness, textScale: 2);
        for (final period in AnalyticsPeriod.values) {
          await _selectPeriod(tester, period);
          expect(
            find.byType(AppAnalyticsPeriodSwitcher).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
        await _selectPreviousYear(tester);
        final l = AppLocalizations.of(
          tester.element(find.byType(AppAnalyticsPeriodHeader)),
        );
        expect(
          find.text(l.analyticsBackToThisYear).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: '历史周期日期与回本期入口不能挤出窄屏');
      } catch (error, stack) {
        debugPrint('统计窄屏大字号回归失败：fitness=$fitness，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });
  }
}
