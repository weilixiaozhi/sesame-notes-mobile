import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/features/statistics/application/calendar_providers.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import 'package:sesame_notes/features/statistics/presentation/calendar_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shell/app_shell.dart';
import 'package:sesame_notes/theme/app_theme.dart';

import '../helpers/test_isolation.dart';

/// 导航生命周期测试不执行磁盘备份，只隔离应用启动的独立副作用。
class _DisabledBackup extends Fake implements AutoBackupService {
  /// 保留启动入口的异步完成方式，不创建快照文件。
  @override
  Future<AutoBackupOutcome> runOnLaunch() async => AutoBackupOutcome.skipped;
}

/// 通过真实 Riverpod 生命周期统计各业务是否具有活动订阅。
class _SubscriptionProbe {
  final starts = <String, int>{};
  final active = <String, int>{};

  /// 暂停、恢复和销毁都按当前实例计数，允许自动释放后重新建立查询。
  void bind(Ref ref, String domain) {
    starts.update(domain, (value) => value + 1, ifAbsent: () => 1);
    var listening = true;
    active.update(domain, (value) => value + 1, ifAbsent: () => 1);

    /// 同一实例重复收到取消或销毁通知时只扣减一次。
    void stop() {
      if (!listening) return;
      listening = false;
      active[domain] = active[domain]! - 1;
    }

    ref.onCancel(stop);
    ref.onDispose(stop);
    ref.onResume(() {
      if (listening) return;
      listening = true;
      active[domain] = active[domain]! + 1;
    });
  }
}

/// 实际导航壳控制挂载与可见性，查询替身只替换数据来源。
void main() {
  setUp(resetGlobalTestState);

  testWidgets('日历首次访问才订阅，隐藏暂停，返回恢复数据和月份状态', (tester) async {
    final probe = _SubscriptionProbe();
    final controllers = <StreamController<List<MemoEntry>>>{};
    final analytics = ProductAnalyticsController(
      writer: () async => throw StateError('导航测试不应上传统计'),
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity(null, 0),
        enabled: false,
      ),
    );
    addTearDown(analytics.dispose);
    try {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final initialDate = DateTime(2026, 11, 6);
      final book = MemoBook(
        id: 'shell-calendar-memos',
        name: '日历笔记',
        type: memoBookTypeNormal,
        createdAt: initialDate,
        updatedAt: initialDate,
      );
      var title = '切换前的笔记';

      /// 重新订阅直接读取最新快照，已订阅流也能收到后台写入。
      MemoEntry snapshot(DateTime date) => MemoEntry(
        id: 'calendar-note',
        memoBookId: book.id,
        bookType: memoBookTypeNormal,
        title: title,
        isSummary: true,
        createdAt: date,
        updatedAt: date,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentModeProvider.overrideWithBuild(
              (ref, notifier) => AppMode.days,
            ),
            currentDayBookProvider.overrideWithValue(const AsyncData(null)),
            currentDayBookIdProvider.overrideWithBuild(
              (ref, notifier) async => null,
            ),
            dayTodayProvider.overrideWithValue(DateOnly(2026, 11, 6)),
            currentLedgerDisplayProvider.overrideWithValue(
              const AsyncData(null),
            ),
            accountStateProvider.overrideWithBuild(
              (ref, notifier) => AccountState.local,
            ),
            categoryPickerPrewarmProvider.overrideWith((ref) {}),
            fitnessRunningWorkoutProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
            autoBackupCoordinatorProvider.overrideWithValue(_DisabledBackup()),
            productAnalyticsControllerProvider.overrideWithValue(analytics),
            calendarSelectedDateProvider.overrideWithBuild(
              (ref, notifier) => initialDate,
            ),
            unifiedCalendarTotalsProvider.overrideWith((ref, query) async {
              probe.bind(ref, 'accounting');
              return {};
            }),
            transactionsByDateProvider.overrideWith((ref, query) async => []),
            calendarDayEventsProvider.overrideWith((ref, month) {
              probe.bind(ref, 'days');
              return const AsyncData(CalendarDayEvents({}, []));
            }),
            currentMemoBookProvider.overrideWithValue(AsyncData(book)),
            currentCredentialBookProvider.overrideWithValue(
              const AsyncData(null),
            ),
            unifiedMemoCountsProvider.overrideWith((ref, query) {
              probe.bind(ref, 'memo-counts');
              return Stream.value({});
            }),
            memoEntriesProvider.overrideWith((ref, query) {
              probe.bind(ref, 'memos');
              final controller = StreamController<List<MemoEntry>>();
              controllers.add(controller);
              ref.onDispose(() {
                controllers.remove(controller);
                unawaited(controller.close());
              });
              controller.add([snapshot(query.date!)]);
              return controller.stream;
            }),
            fitnessWorkoutsInRangeProvider.overrideWith((ref, query) {
              probe.bind(ref, 'fitness');
              return Stream.value([]);
            }),
            fitnessCalendarPlansProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SesameNotesApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(SesameNotesApp));
      final l = AppLocalizations.of(context);
      final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
      expect(find.byType(CalendarPage, skipOffstage: false), findsNothing);
      expect(probe.starts, isEmpty, reason: '未打开日历时不创建跨业务查询');

      await tester.tap(find.byTooltip(l.tabCalendar));
      await tester.pumpAndSettle();
      const domains = ['accounting', 'days', 'memo-counts', 'memos', 'fitness'];
      for (final domain in domains) {
        expect(probe.active[domain], greaterThan(0), reason: '$domain 已开始订阅');
      }
      final calendarState = tester.state(find.byType(CalendarPage));
      final chosenDate = DateTime(2027, 2, 10);
      tester
          .widget<AppCalendar<Object>>(find.byType(AppCalendar<Object>))
          .onPageChanged(chosenDate);
      await tester.pumpAndSettle();
      expect(find.text('切换前的笔记'), findsOneWidget);

      await tester.tap(find.byTooltip(backTooltip));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);
      expect(find.byType(CalendarPage, skipOffstage: false), findsOneWidget);
      for (final domain in domains) {
        expect(probe.active[domain], 0, reason: '$domain 在隐藏页面暂停');
      }
      title = '隐藏期间更新的笔记';
      for (final controller in controllers) {
        controller.add([snapshot(chosenDate)]);
      }
      await tester.pumpAndSettle();
      expect(
        find.text('隐藏期间更新的笔记', skipOffstage: false),
        findsNothing,
        reason: '隐藏页面不因后台数据更新重建',
      );

      await tester.tap(find.byTooltip(l.tabCalendar));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(CalendarPage)), same(calendarState));
      final calendar = tester.widget<AppCalendar<Object>>(
        find.byType(AppCalendar<Object>),
      );
      expect(calendar.focusedDay, DateTime(2027, 2));
      expect(calendar.selectedDayPredicate(chosenDate), isTrue);
      expect(find.text('隐藏期间更新的笔记'), findsOneWidget);
      for (final domain in domains) {
        expect(probe.active[domain], greaterThan(0), reason: '$domain 返回时恢复');
      }
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('导航页面订阅生命周期回归失败：$error\n$stackTrace');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      for (final controller in controllers.toList()) {
        await controller.close();
      }
    }
  });
}
