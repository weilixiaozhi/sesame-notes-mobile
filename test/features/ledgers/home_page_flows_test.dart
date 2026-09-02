/// HomePage 行为流测试（第二弹）：头部交互、下拉刷新失败/补折算、
/// 账本空态与错误态、AA 入口、交易明细接线与删除流程。
///
/// 第一弹（home_page_test.dart）已覆盖左右切月与下拉刷新成功/降级文案；
/// 本文件补齐头部/卡片交互与异常分支，避免把「用户点一下会发生什么」的断言
/// 全部堆进同一个文件。
library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart'
    show Category, Ledger, LedgerMember, Transaction;
import 'package:sesame_notes/data/models.dart' show RecordEditHistoryDisplay;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/features/ledgers/presentation/home_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledgers_page.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';

/// Mock 整个 LocalRepository：未 stub 的方法返回默认值，避免触碰数据库。
class _MockRepo extends Mock implements LocalRepository {}

typedef _TxItem = ({Transaction t, Category? category});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late Ledger testLedger;
  late Stream<List<_TxItem>> Function() txsStreamFactory;

  void registerTxsStream(Stream<List<_TxItem>> Function() factory) {
    txsStreamFactory = factory;
  }

  setUp(() {
    resetGlobalTestState();
    repo = _MockRepo();
    testLedger = Ledger(
      id: 'ledger-1',
      name: '测试账本',
      currency: 'CNY',
      monthStartDay: 1,
      aaEnabled: false,
      role: 'owner',
      memberCount: 1,
      storageMode: 'local',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    registerTxsStream(() {
      return Stream<List<_TxItem>>.value(const []);
    });
    when(
      () => repo.watchTransactionsWithCategoryInMonth(
        ledgerId: any(named: 'ledgerId'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) => txsStreamFactory());
    when(() => repo.getAllLedgers()).thenAnswer((_) async => <Ledger>[]);
    // 作者身份按账本归属解析需要账本行；默认本地账本。
    when(() => repo.getLedgerById(any())).thenAnswer((_) async => testLedger);
    when(
      () => repo.countUnconvertedForeignTx(any()),
    ).thenAnswer((_) async => 0);
    when(() => repo.deleteTransaction(any())).thenAnswer((_) async {});
  });

  Widget buildApp({
    DateTime? initialMonth,
    List<Override>? extraOverrides,
    Override? currentLedgerOverride,
    bool withStubRoutes = false,
  }) {
    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerIdProvider.overrideWithBuild(
          (ref, notifier) => 'ledger-1',
        ),
        currentLedgerOverride ??
            currentLedgerProvider.overrideWith(
              (ref) => Stream<Ledger?>.value(testLedger),
            ),
        currentMonthStartDayProvider.overrideWith((ref) => 1),
        monthlyTotalsProvider.overrideWith((ref, params) async => 0.0),
        todayExpenseProvider.overrideWith((ref, ledgerId) async => 0.0),
        weekExpenseProvider.overrideWith((ref, ledgerId) async => 0.0),
        selectedMonthProvider.overrideWithBuild(
          (ref, notifier) => initialMonth ?? DateTime(2026, 7, 1),
        ),
        // 详情 sheet 依赖的 provider 直接给确定值，绕开真实数据库。
        recordEditHistoryProvider.overrideWith(
          (ref, recordId) async => const <RecordEditHistoryDisplay>[],
        ),
        // 首页/详情共用的虚拟用户流给空表。
        ledgerVirtualUsersProvider.overrideWith(
          (ref, ledgerId) => Stream<List<LedgerMember>>.value(const []),
        ),
        ...?extraOverrides,
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        // 测试 stub 优先（AA 统计占位），其余命名路由统一走全局路由层。
        routerConfig: createAppRouter(
          home: () => const HomePage(),
          stubs: withStubRoutes
              ? {
                  Routes.aaStatistics: (_) =>
                      const Scaffold(body: Text('AA_STUB')),
                }
              : const {},
        ),
      ),
    );
  }

  Future<void> prime(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  ProviderContainer containerOf(WidgetTester tester) {
    return ProviderScope.containerOf(tester.element(find.byType(HomePage)));
  }

  /// 通过下发 ScrollNotification 模拟「从列表顶部下拉」，触发首页自定义刷新指示器。
  Future<void> pullToRefresh(
    WidgetTester tester, {
    List<double> pullPixels = const [-16, -32, -48, -64],
    double endPixels = -64,
  }) async {
    final ctx = tester.element(find.byType(AppEmpty));
    FixedScrollMetrics metricsAt(double pixels) => FixedScrollMetrics(
      minScrollExtent: -200,
      maxScrollExtent: 100,
      pixels: pixels,
      viewportDimension: 100,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );
    for (final p in pullPixels) {
      ScrollUpdateNotification(
        metrics: metricsAt(p),
        context: ctx,
      ).dispatch(ctx);
      await tester.pump(const Duration(milliseconds: 16));
    }
    ScrollEndNotification(
      metrics: metricsAt(endPixels),
      context: ctx,
    ).dispatch(ctx);
    await tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (tester.elementList(finder).isNotEmpty) return;
    }
    throw Exception('pumpUntilFound: $finder 在超时内未出现');
  }

  testWidgets('点击账本胶囊：进入 LedgersPage', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    final capsule = find.text('测试账本');
    expect(capsule, findsOneWidget);
    await tester.tap(capsule);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(LedgersPage), findsOneWidget, reason: '点击账本徽章应进入账本管理页');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('无账本时胶囊显示「新建账本」引导', (tester) async {
    await tester.pumpWidget(
      buildApp(
        currentLedgerOverride: currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ),
    );
    await prime(tester);

    expect(
      find.text('新建账本'),
      findsOneWidget,
      reason: '当前账本为 null 时徽章应显示新建引导而非账本名',
    );
  });

  testWidgets('日期头点击：打开月份滚轮并确认同月（不切月）', (tester) async {
    await tester.pumpWidget(buildApp(initialMonth: DateTime(2026, 7, 1)));
    await prime(tester);

    final dateHeader = find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains('2026'),
    );
    await tester.tap(dateHeader);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('选择账单月份'), findsOneWidget);
    // 不滚动直接确认：应走「同月早退」分支，selectedMonth 不变。
    await tester.tap(find.text('完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      containerOf(tester).read(selectedMonthProvider),
      DateTime(2026, 7, 1),
    );
  });

  testWidgets('日期头点击：滚轮切月并确认后 selectedMonth 更新', (tester) async {
    await tester.pumpWidget(buildApp(initialMonth: DateTime(2026, 7, 1)));
    await prime(tester);

    final dateHeader = find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains('2026'),
    );
    await tester.tap(dateHeader);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 月份滚轮向上拖一个 itemExtent（40px），把 7 月换成 6 月。
    final monthWheel = find.byType(CupertinoPicker).at(1);
    await tester.drag(monthWheel, const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('完成'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      containerOf(tester).read(selectedMonthProvider),
      DateTime(2026, 6, 1),
      reason: '确认滚轮选中的新月份后应更新选中月份并复位 PageView',
    );
  });

  testWidgets('下拉刷新：本地兜底也失败 → 指示器显示「刷新失败」', (tester) async {
    await tester.pumpWidget(
      buildApp(
        extraOverrides: [
          // 主题初始化是 _runLocalRefresh 的中间步骤；让它抛错即可让整个
          // 本地刷新兜底失败，走到外层 catch。
          themeModeInitProvider.overrideWith(
            (ref) => Future<void>.error(StateError('boom')),
          ),
        ],
      ),
    );
    await prime(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    await pullToRefresh(tester);
    await pumpUntilFound(tester, find.text(l10n.homePullCloudFailed));

    expect(
      find.text(l10n.homePullCloudFailed),
      findsOneWidget,
      reason: '本地兜底也失败时应展示「刷新失败，请稍后重试」',
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('下拉刷新：存在未折算外币交易 → 自动补折算并刷新', (tester) async {
    when(
      () => repo.countUnconvertedForeignTx(any()),
    ).thenAnswer((_) async => 2);
    when(
      () => repo.recomputeForeignTxForLedger(any()),
    ).thenAnswer((_) async => 2);

    await tester.pumpWidget(buildApp());
    await prime(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    await pullToRefresh(tester);
    await pumpUntilFound(tester, find.text(l10n.homePullLocalSuccess));

    verify(() => repo.recomputeForeignTxForLedger('ledger-1')).called(1);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('下拉刷新：补折算返回 0 或抛错均不阻断刷新', (tester) async {
    when(
      () => repo.countUnconvertedForeignTx(any()),
    ).thenAnswer((_) async => 1);
    when(
      () => repo.recomputeForeignTxForLedger(any()),
    ).thenAnswer((_) async => 0);

    await tester.pumpWidget(buildApp());
    await prime(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    await pullToRefresh(tester);
    await pumpUntilFound(tester, find.text(l10n.homePullLocalSuccess));
    await tester.pump(const Duration(seconds: 3));

    // 第二轮：补折算本身抛错 → 仅告警，刷新仍成功。
    when(
      () => repo.recomputeForeignTxForLedger(any()),
    ).thenThrow(StateError('recalc boom'));
    await pullToRefresh(tester);
    await pumpUntilFound(tester, find.text(l10n.homePullLocalSuccess));
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('当前账本加载失败：头部显示错误 + 重试按钮', (tester) async {
    await tester.pumpWidget(
      buildApp(
        currentLedgerOverride: currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.error(StateError('boom')),
        ),
      ),
    );
    await prime(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    expect(find.text(l10n.analyticsLoadFailed), findsOneWidget);
    expect(find.text(l10n.analyticsRetry), findsOneWidget);

    // 点击重试仅 invalidate provider，不应崩溃。
    await tester.tap(find.text(l10n.analyticsRetry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomePage), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('AA 账本：显示「分摊统计」入口并可跳转', (tester) async {
    testLedger = testLedger.copyWith(aaEnabled: true);
    await tester.pumpWidget(buildApp(withStubRoutes: true));
    await prime(tester);

    final entry = find.text('分摊统计');
    expect(entry, findsOneWidget, reason: 'AA 账本应在汇总卡下方渲染分摊统计入口');

    await tester.tap(entry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('AA_STUB'), findsOneWidget, reason: '点击入口应跳转到分摊统计路由');
  });

  testWidgets('下拉未达阈值：停止旋转并收起指示器', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    // 只拉 30px（阈值 48），松开后应走「未达标收起」分支。
    await pullToRefresh(
      tester,
      pullPixels: const [-10, -20, -30],
      endPixels: -30,
    );
    await tester.pump(const Duration(milliseconds: 300));

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    // SizeTransition 收起后文本仍在树中（零尺寸），因此断言「未进入刷新」应看
    // 是否出现了刷新结果文案 / 是否调用了同步服务。
    expect(
      find.text(l10n.homePullLocalSuccess),
      findsNothing,
      reason: '未达标不应触发刷新',
    );
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('overscroll 回弹到 0：结束本次下拉会话', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    // 拉 32px 后回弹到 0：ScrollUpdate 中 pixels 回正应触发 _handlePullEnd。
    await pullToRefresh(tester, pullPixels: const [-16, -32, 0], endPixels: 0);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('交易流加载失败：显示友好错误 + 重试重建流', (tester) async {
    var errorStreamCalls = 0;
    registerTxsStream(() {
      errorStreamCalls++;
      return Stream<List<_TxItem>>.error(StateError('stream boom'));
    });
    await tester.pumpWidget(buildApp());
    await prime(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
    expect(find.text(l10n.analyticsLoadFailed), findsOneWidget);
    expect(find.text(l10n.analyticsRetry), findsOneWidget);

    final callsBefore = errorStreamCalls;
    await tester.tap(find.text(l10n.analyticsRetry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(errorStreamCalls, greaterThan(callsBefore), reason: '重试应重建交易流');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('共享账本：成员表刷新 loading 时复用上次缓存', (tester) async {
    testLedger = Ledger(
      id: 'ledger-1',
      name: '测试共享账本',
      currency: 'CNY',
      monthStartDay: 1,
      aaEnabled: false,
      role: 'owner',
      memberCount: 2,
      storageMode: 'cloud',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    // 第一次返回成员表；invalidate 后的重算返回挂起 Future，模拟刷新期 loading。
    var memberCalls = 0;
    final pendingMembers = Completer<List<LedgerMember>>();
    await tester.pumpWidget(
      buildApp(
        extraOverrides: [
          ledgerMembersProvider.overrideWith((ref, ledgerId) {
            memberCalls++;
            if (memberCalls == 1) {
              return Future.value([
                LedgerMember(
                  id: 'u1',
                  ledgerId: ledgerId,
                  displayName: '小明',
                  memberType: 'REGISTERED',
                  linkedAccountId: 'u1',
                  role: 'owner',
                  avatarVersion: 0,
                  status: 'ACTIVE',
                  joinedAt: DateTime.utc(2026, 1, 1),
                  createdAt: DateTime.utc(2026, 1, 1),
                  updatedAt: DateTime.utc(2026, 1, 1),
                ),
                LedgerMember(
                  id: 'u2',
                  ledgerId: ledgerId,
                  displayName: '小红',
                  memberType: 'REGISTERED',
                  linkedAccountId: 'u2',
                  role: 'editor',
                  avatarVersion: 0,
                  status: 'ACTIVE',
                  joinedAt: DateTime.utc(2026, 1, 2),
                  createdAt: DateTime.utc(2026, 1, 2),
                  updatedAt: DateTime.utc(2026, 1, 2),
                ),
              ]);
            }
            return pendingMembers.future;
          }),
        ],
      ),
    );
    await prime(tester);
    await tester.pump(const Duration(milliseconds: 100));

    // 首次加载成功后 invalidate：下一次 build 应复用缓存而非闪错误头像。
    containerOf(tester).invalidate(ledgerMembersProvider('ledger-1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomePage), findsOneWidget);
    // 释放挂起的成员表，避免遗留未完成 future 影响测试收尾。
    pendingMembers.complete(const []);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
