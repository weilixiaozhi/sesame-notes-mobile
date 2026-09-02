/// 日历页组件测试。
///
/// 需求期望：
/// 1. 进入日历页自动选中今天（当天交易列表直接可见）；
/// 2. 任何路径写入数据后，日历当日列表自动刷新（不依赖手动 tick）；
/// 3. 切到其他月后选中态清空，回到本月自动重新选中今天；
/// 4. 重新进入日历 tab 且无选中时，自动选中今天。
///
/// 说明：
/// - 整个文件共享同一个内存数据库，避免同一进程内第二个 drift 实例的
///   tableUpdates 流不可靠，保证随机测试顺序下行为一致；
/// - 切月用日历头部箭头按钮（确定性点击），不用手势 fling。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/statistics/presentation/calendar_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/avatar_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;

  setUpAll(() async {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    // createLedger 返回新账本的 UUID；后续写入/查询均以该 id 为锚点。
    ledgerId = await repo.createLedger(name: '测试账本', storageMode: 'local');
  });

  tearDownAll(() async => db.close());

  /// 轮询 pump 直到 Finder 命中（日历骨架含 PulseSkeleton 持续动画，禁用 pumpAndSettle）。
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (tester.elementList(finder).isNotEmpty) return;
    }
    fail('pumpUntilFound: $finder 在超时内未出现');
  }

  Future<void> pumpUntilGone(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (tester.elementList(finder).isEmpty) return;
    }
    fail('pumpUntilGone: $finder 在超时内未消失');
  }

  /// 点击日历头部箭头切月，并等待翻页完成。
  Future<void> tapChevron(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// 卸载整棵树并冲刷 drift 流取消时产生的 0 毫秒 Timer，
  /// 避免 flutter_test 判定「仍有 pending timer」而挂起。
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> pumpCalendar(
    WidgetTester tester, {
    SyncCoordinator? syncCoordinator,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          repositoryProvider.overrideWithValue(repo),
          currentLedgerIdProvider.overrideWith(
            () => SimpleStateNotifier<String>((ref) => ledgerId),
          ),
          avatarPathProvider.overrideWith((ref) async => null),
          localSelfIdProvider.overrideWith((ref) async => 'local-self'),
          if (syncCoordinator != null)
            syncCoordinatorProvider.overrideWithValue(syncCoordinator),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CalendarPage(),
        ),
      ),
    );
  }

  testWidgets('下拉刷新调用统一刷新入口并传入当前账本', (tester) async {
    final sync = _MockSyncCoordinator();
    when(
      () => sync.refreshData(ledgerId: ledgerId),
    ).thenAnswer((_) async => const SyncRunResult());
    await pumpCalendar(tester, syncCoordinator: sync);
    await pumpUntilFound(tester, find.byType(RefreshIndicator));

    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await indicator.onRefresh();

    verify(() => sync.refreshData(ledgerId: ledgerId)).called(1);
    await disposeTree(tester);
  });

  testWidgets('进入日历自动选中今天；直接写库后当日列表自动刷新；回到本月自动重新选中今天', (tester) async {
    await pumpCalendar(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)));
    final addTxFinder = find.text(l10n.calendarAddTransaction);

    // 1) 进入页面自动选中今天：当天交易列表的“在该日记账”按钮直接可见。
    await pumpUntilFound(tester, addTxFinder);

    // 2) 绕过 UI/手动 tick 直接写库，当日列表应自动刷新出新交易。
    final now = DateTime.now();
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '1234',
      happenedAt: now,
      note: '自动刷新验证',
    );
    await pumpUntilFound(tester, find.text('自动刷新验证'));

    // 3) 切到下一月：选中态清空，当天列表隐藏。
    await tapChevron(tester, AppIcons.chevronRight);
    await pumpUntilGone(tester, addTxFinder);

    // 4) 切回本月：自动重新选中今天，列表恢复。
    await tapChevron(tester, AppIcons.chevronLeft);
    await pumpUntilFound(tester, addTxFinder);

    await disposeTree(tester);
  });

  testWidgets('重新进入日历 tab 且无选中日期时，自动选中今天', (tester) async {
    await pumpCalendar(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)));
    final addTxFinder = find.text(l10n.calendarAddTransaction);
    await pumpUntilFound(tester, addTxFinder);

    // 先切到下一月清空选中态。
    await tapChevron(tester, AppIcons.chevronRight);
    await pumpUntilGone(tester, addTxFinder);

    // 模拟先切走再切回日历 tab。
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CalendarPage)),
      listen: false,
    );
    container.read(bottomTabIndexProvider.notifier).set(1);
    await tester.pump();
    container.read(bottomTabIndexProvider.notifier).set(2);

    // 重新进入后应自动回到本月并选中今天。
    await pumpUntilFound(tester, addTxFinder);

    await disposeTree(tester);
  });

  testWidgets('回到今天按钮仅在未选中今天时显示', (tester) async {
    await pumpCalendar(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)));
    final addTxFinder = find.text(l10n.calendarAddTransaction);
    final todayAction = find.text(l10n.calendarToday);

    // 进入页面自动选中今天：「回到今天」应隐藏。
    await pumpUntilFound(tester, addTxFinder);
    expect(todayAction, findsNothing);

    // 当前月选中非今天日期：「回到今天」出现。
    final now = DateTime.now();
    final otherDay = now.day == 15 ? 16 : 15;
    await tester.tap(find.text('$otherDay'));
    await tester.pump();
    expect(todayAction, findsOneWidget);

    // 切到其他月（选中态清空）：保留按钮作为唯一返回入口。
    await tapChevron(tester, AppIcons.chevronRight);
    expect(todayAction, findsOneWidget);

    // 点击「回到今天」：回到本月并选中今天，按钮隐藏。
    await tester.tap(todayAction);
    await tester.pump();
    await pumpUntilFound(tester, addTxFinder);
    expect(todayAction, findsNothing);

    await disposeTree(tester);
  });

  testWidgets('日历格子金额与折线图同口径：无币种符号、无负号、两位小数去尾零', (tester) async {
    await pumpCalendar(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)));
    final addTxFinder = find.text(l10n.calendarAddTransaction);
    await pumpUntilFound(tester, addTxFinder);

    // 选一个不受其他用例写入影响的日期（其他用例都写「今天」）：
    // 今天若为 1 号则写 2 号，否则写 1 号，保证格子金额只来自本用例。
    final now = DateTime.now();
    final targetDay = now.day == 1 ? 2 : 1;
    // schema 金额为 decimal 字符串（单位=元）：2400 元直接入库，
    // 展示层不直接做分→元换算，聚合后经 formatChartValueLabel 缩写为 2.4k。
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '2400',
      happenedAt: DateTime(now.year, now.month, targetDay, 12),
      note: '日历格子金额口径验证',
    );

    // 新口径：2.4k（无 ¥ 前缀、无负号、去掉末尾 0），与 formatChartValueLabel 一致。
    await pumpUntilFound(tester, find.text('2.4k'));
    expect(find.text('-¥2.4k'), findsNothing, reason: '日历格子不得再展示币种符号和负号');
    expect(find.text('2.4k'), findsOneWidget, reason: '2400 元按 k 缩写且去尾零为 2.4k');

    await disposeTree(tester);
  });
}
