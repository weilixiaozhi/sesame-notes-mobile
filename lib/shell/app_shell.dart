import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/features/statistics/presentation/calendar_actions.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/days/application/day_reminder_lifecycle.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_home_cards.dart';

import 'dart:async';

import 'package:sesame_notes/features/fitness/application/fitness_lifecycle.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_home_page.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_analytics_page.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_navigation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/features/statistics/presentation/calendar_page.dart';

import 'package:sesame_notes/features/ledgers/presentation/analytics_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/home_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/mine_page.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';

import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet_entry.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/features/days/presentation/days_home_page.dart';
import 'package:sesame_notes/features/days/presentation/days_tools_page.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/features/memos/presentation/memos_page.dart';
import 'package:sesame_notes/features/memos/presentation/memo_credentials_page.dart';
import 'package:sesame_notes/features/memos/presentation/memo_navigation.dart';

import 'package:sesame_notes/features/fitness/presentation/fitness_plans_page.dart';
import 'domain_header.dart';
import 'package:sesame_notes/diagnostics/presentation/acceptance_seed_dialog.dart';

/// 返回键先回当前业务首页，再由双击返回确认退出。
enum ShellBackAction { toDomainHomeTab, confirmExit }

/// 各业务域地位相同，返回操作不会隐式跳到另一个业务域。
ShellBackAction resolveShellBackAction({required int tabIndex}) => tabIndex == 0
    ? ShellBackAction.confirmExit
    : ShellBackAction.toDomainHomeTab;

/// 四个业务入口常驻底栏，页头承接当前本、域内导航和全局页面。
class SesameNotesApp extends ConsumerStatefulWidget {
  /// 创建保留业务页面状态的应用导航壳。
  const SesameNotesApp({super.key});
  @override
  ConsumerState<SesameNotesApp> createState() => _SesameNotesAppState();
}

class _SesameNotesAppState extends ConsumerState<SesameNotesApp>
    with WidgetsBindingObserver {
  final _visitedModes = <AppMode>{};
  final _domainTabs = <AppMode, int>{};
  DateTime? _lastBackPressTime;
  double _horizontalDrag = 0;
  int _lifecycleGeneration = 0;
  Future<void> _backgroundWrite = Future<void>.value();
  bool _backgroundRecordFailed = false;

  /// 页组索引保留共享日历与我的，避免现有通知和同步入口丢失目的地。
  List<Widget> get _pages => [
    HomePage(onViewAnalytics: () => _selectTab(1)),
    const AnalyticsPage(embedded: true),
    CalendarPage(
      onBack: () => _selectTab(_domainTabs[ref.read(currentModeProvider)] ?? 0),
    ),
    const DaysHomePage(),
    const DaysToolsPage(),
    const SizedBox.shrink(),
    const MemosPage(kind: MemoPageKind.home),
    const MemosPage(kind: MemoPageKind.tools),
    const MemoCredentialsPage(embedded: true),
    const FitnessHomePage(),
    const FitnessAnalyticsPage(embedded: true),
    const SizedBox.shrink(),
    const MinePage(),
    const FitnessPlansPage(embedded: true),
  ];

  /// 构建业务新增操作，所有页签共用外壳中的同一按钮。
  Widget _buildCreateButton({required AppMode mode, required int idx}) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.buttonRadius(context)),
        boxShadow: AppTokens.fabShadow(context),
      ),
      child: FilledButton.icon(
        key: const ValueKey('domain-create-button'),
        onPressed: _create,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p16,
            vertical: AppDimens.p12,
          ),
          textStyle: AppTextTokens.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(AppIcons.createEntry, size: AppDimens.icon20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            idx == 2
                ? l.shellAddCalendar
                : switch (mode) {
                    AppMode.bookkeeping => l.shellAddMoney,
                    AppMode.days => l.shellAddDay,
                    AppMode.memos =>
                      idx == 4
                          ? l.memoNewCard
                          : idx == 1
                          ? l.commonAdd
                          : l.shellAddMemo,
                    AppMode.fitness => l.shellAddFitness,
                  },
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }

  /// 周期选择与新增按钮在外壳中同排，切换明细和统计时保持新增按钮的位置与实例。
  Widget _buildFloatingActions({required AppMode mode, required int idx}) {
    final availableWidth =
        MediaQuery.sizeOf(context).width -
        MediaQuery.paddingOf(context).horizontal -
        AppDimens.domainPageInset -
        AppDimens.p16;
    final bookkeeping = mode == AppMode.bookkeeping;
    final statistics = idx == 1 && (bookkeeping || mode == AppMode.fitness);
    final periodProvider = bookkeeping
        ? ledgerAnalyticsPeriodProvider
        : fitnessAnalyticsPeriodProvider;
    return SizedBox(
      width: availableWidth,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: statistics
                  ? AppAnalyticsPeriodSwitcher(
                      period: ref.watch(periodProvider),
                      onChanged: (period) {
                        try {
                          ref.read(periodProvider.notifier).set(period);
                        } catch (error, stackTrace) {
                          logger.error(
                            'AppShell',
                            '切换统计周期失败 mode=${mode.name} period=${period.name}',
                            error,
                            stackTrace,
                          );
                          if (mounted) {
                            showToast(
                              context,
                              AppLocalizations.of(
                                context,
                              ).commonOperationFailed,
                            );
                          }
                        }
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: AppDimens.p16),
          // 两域统计为周期选择保留相同空间，新增按钮在大字号下保持可点击。
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  (availableWidth - AppDimens.p16) /
                  (statistics || bookkeeping && idx != 2 ? 2 : 1),
            ),
            child: _buildCreateButton(mode: mode, idx: idx),
          ),
        ],
      ),
    );
  }

  /// 启动时执行自动备份，异常不影响页面呈现。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      try {
        await ref.read(autoBackupCoordinatorProvider).runOnLaunch();
      } catch (error, stack) {
        logger.error('AppShell', '启动后台任务失败', error, stack);
      }
    });
  }

  /// 直接选择业务域，保留该业务上一次访问的页签。
  void _selectMode(AppMode mode) {
    if (ref.read(currentModeProvider) != mode) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: productAnalyticsRootPage(
              ref.read(currentModeProvider),
              ref.read(bottomTabIndexProvider),
            ),
            action: ProductAction.navigationModeSelect,
          );
    }
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(currentModeProvider.notifier).set(mode);
    ref.read(bottomTabIndexProvider.notifier).set(_domainTabs[mode] ?? 0);
    _lastBackPressTime = null;
  }

  /// 点击页签与横滑共用入口，不修改当前账期和业务筛选条件。
  void _selectTab(int index) {
    if (ref.read(bottomTabIndexProvider) != index) {
      final mode = ref.read(currentModeProvider);
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: productAnalyticsRootPage(
              mode,
              ref.read(bottomTabIndexProvider),
            ),
            action: ProductAction.navigationTabSelect,
          );
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final mode = ref.read(currentModeProvider);
    if (DomainHeader.tabs(mode).contains(index)) _domainTabs[mode] = index;
    ref.read(bottomTabIndexProvider.notifier).set(index);
    _lastBackPressTime = null;
  }

  /// 打开共享页面前记住当前域内位置，返回时恢复原来的上下文。
  void _openShared(int index) {
    _selectTab(index);
  }

  /// 横向手势只在当前业务域内切换页签，不改变年月或记录内容。
  void _endHorizontalDrag(DragEndDetails details) {
    final mode = ref.read(currentModeProvider);
    final tabs = DomainHeader.tabs(mode);
    final current = tabs.indexOf(ref.read(bottomTabIndexProvider));
    if (current < 0) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_horizontalDrag.abs() < AppDimens.p40 && velocity.abs() < 350) return;
    final direction = _horizontalDrag == 0 ? velocity : _horizontalDrag;
    final next = (current + (direction < 0 ? 1 : -1)).clamp(0, tabs.length - 1);
    if (next != current) _selectTab(tabs[next]);
  }

  /// 新增使用当前业务原有编辑器，错误在统一边界记录并给出可读提示。
  Future<void> _create() async {
    try {
      final index = ref.read(bottomTabIndexProvider);
      final mode = ref.read(currentModeProvider);
      if (index == 2) {
        await openCalendarActions(
          context,
          ref,
          ref.read(calendarSelectedDateProvider),
        );
      } else {
        switch (mode) {
          case AppMode.bookkeeping:
            await showTransactionEditorSheet(context);
          case AppMode.days:
            await openDayEditor(context, ref);
          case AppMode.memos:
            if (index == 4) {
              await openMemoCredentialEditor(context, ref);
            } else if (index == 0) {
              await openMemoEditor(context, ref);
            } else {
              await openMemoCreateSheet(context, ref);
            }
          case AppMode.fitness:
            await openFitnessActions(context, ref);
        }
      }
    } catch (error, stack) {
      logger.error('AppShell', '打开新增记录失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  @override
  void dispose() {
    _lifecycleGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 后台记录与前台锁定检查串行，校验完成前保持隐私遮罩。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final generation = ++_lifecycleGeneration;
    if (state == AppLifecycleState.inactive) {
      // 多任务切换时显示隐私模糊屏（仅在应用锁启用时）
      if (ref.read(appLockEnabledProvider)) {
        ref.read(showPrivacyScreenProvider.notifier).set(true);
      }
    } else if (state == AppLifecycleState.paused) {
      // 等待已有写入后记录本次离开，恢复时不能读到尚未提交的旧时间。
      _backgroundWrite = _backgroundWrite.then((_) => _recordBackgroundTime());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_checkAppLockOnResume(generation));
      // 前台恢复与各页面下拉复用同一入口：本地账本只重查本地快照，
      // 云账本由协调器执行串行 push/pull，避免生命周期层复制同步判断。
      unawaited(_refreshDataOnResume());
      // 切回前台时尝试一次自动备份（按天去重：当天已成功则内部跳过）。
      unawaited(ref.read(autoBackupCoordinatorProvider).runOnLaunch());
    }
  }

  /// App 恢复前台时刷新当前账本；失败只记录日志，不打断解锁与页面恢复。
  Future<void> _refreshDataOnResume() async {
    // 在首个 await 之前取容器,避免跨异步间隙使用 context。
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      // 主提醒恢复先读取一次设备时区，其他当地时间提醒共享这次刷新结果。
      final restored = await container
          .read(appReminderMonitorProvider)
          .restoreReminder();
      if (!mounted) return;
      if (restored) await container.read(dayReminderLifecycleProvider)();
    } catch (error, stackTrace) {
      logger.error(
        'AppLifecycle',
        '当地提醒恢复失败，保留系统原任务并在下次前台恢复时重试',
        error,
        stackTrace,
      );
    }
    if (!mounted) return;
    try {
      await container.read(fitnessLifecycleProvider)();
      if (!mounted) return;
      final ledgerId = container.read(currentLedgerIdProvider);
      final result = await container
          .read(syncCoordinatorProvider)
          .refreshData(ledgerId: ledgerId);
      if (!result.ok) {
        logger.warning('AppLifecycle', '前台恢复刷新未完成，继续展示本地数据', result.error);
      }
      // 前台恢复同时按需刷新成员公开资料(幂等 + 防抖,失败不阻塞)。
      unawaited(refreshLedgerMemberDirectory(container, ledgerId));
    } catch (error, stackTrace) {
      logger.error('AppLifecycle', '前台恢复刷新失败', error, stackTrace);
    }
  }

  /// 后台保存失败时保留诊断并要求下一次恢复验证身份。
  Future<void> _recordBackgroundTime() async {
    try {
      await AppLockService.recordBackgroundTime();
      _backgroundRecordFailed = false;
    } catch (error, stackTrace) {
      _backgroundRecordFailed = true;
      logger.error(
        'AppLock',
        '后台时间保存失败，恢复时需要解锁',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 先确定锁定状态，再解除遮罩；过期恢复回调不能清除下一轮后台保护。
  Future<void> _checkAppLockOnResume(int generation) async {
    try {
      await _backgroundWrite;
      if (!mounted || generation != _lifecycleGeneration) return;
      final shouldLock =
          _backgroundRecordFailed || await AppLockService.shouldLockOnResume();
      if (!mounted || generation != _lifecycleGeneration) return;
      if (shouldLock && ref.read(appLockEnabledProvider)) {
        ref.read(isAppLockedProvider.notifier).set(true);
      }
    } catch (error, stackTrace) {
      logger.error(
        'AppLock',
        '恢复时无法确认锁定状态，请解锁后继续',
        safeErrorSummary(error),
        stackTrace,
      );
      if (mounted &&
          generation == _lifecycleGeneration &&
          ref.read(appLockEnabledProvider)) {
        ref.read(isAppLockedProvider.notifier).set(true);
      }
    } finally {
      if (mounted && generation == _lifecycleGeneration) {
        ref.read(showPrivacyScreenProvider.notifier).set(false);
      }
    }
  }

  /// 页头、内容和底栏分别布局，浮动新增不会挤占导航目的地。
  @override
  Widget build(BuildContext context) {
    ref.watch(categoryPickerPrewarmProvider);
    final idx = ref.watch(bottomTabIndexProvider);
    final mode = ref.watch(currentModeProvider);
    final shared = idx == 2 || idx == 3;
    _visitedModes.add(mode);
    if (!shared) _domainTabs[mode] = idx;
    final pageIndex = idx == 3
        ? 12
        : idx == 2
        ? 2
        : idx == 4 && mode == AppMode.fitness
        ? 13
        : idx == 4 && mode == AppMode.memos
        ? 8
        : idx + mode.index * 3;
    final pages = _pages;
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (shared) {
          _selectTab(_domainTabs[ref.read(currentModeProvider)] ?? 0);
          return;
        }
        if (resolveShellBackAction(tabIndex: idx) ==
            ShellBackAction.toDomainHomeTab) {
          _selectTab(0);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          showToast(context, l.commonPressAgainToExit);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            if (!shared)
              DomainHeader(
                mode: mode,
                tabIndex: idx,
                onTab: _selectTab,
                onCalendar: () => _openShared(2),
                onProfile: () => _openShared(3),
              ),
            if (shared && idx == 3)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: () => _selectTab(
                          _domainTabs[ref.read(currentModeProvider)] ?? 0,
                        ),
                        icon: const Icon(AppIcons.chevronLeft),
                      ),
                      Expanded(
                        child: Text(
                          l.tabMine,
                          style: AppTextTokens.strongTitle(context),
                        ),
                      ),
                      AcceptanceSeedAction(mode: mode),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: idx != 2,
                child: GestureDetector(
                  key: const ValueKey('domain-content'),
                  onHorizontalDragStart: shared
                      ? null
                      : (_) => _horizontalDrag = 0,
                  onHorizontalDragUpdate: shared
                      ? null
                      : (details) => _horizontalDrag += details.delta.dx,
                  onHorizontalDragEnd: shared ? null : _endHorizontalDrag,
                  child: IndexedStack(
                    index: pageIndex,
                    children: [
                      for (var index = 0; index < pages.length; index++)
                        if (index == 2 ||
                            index == 12 ||
                            (index == 13
                                ? _visitedModes.contains(AppMode.fitness)
                                : _visitedModes.contains(
                                    AppMode.values[index ~/ 3],
                                  )))
                          TickerMode(
                            enabled: index == 2 || index == pageIndex,
                            child: pages[index],
                          )
                        else
                          const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // 保持浮动操作挂载，设置页即时隐藏，返回业务页时直接显示。
        floatingActionButton: Visibility(
          visible: idx != 3,
          maintainState: true,
          child: _buildFloatingActions(mode: mode, idx: idx),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FitnessRunningBanner(),
            AppBottomBar(
              currentIndex: shared ? -1 : mode.index,
              bottomPadding: MediaQuery.paddingOf(context).bottom,
              l10n: l,
              onTabTap: (index) => _selectMode(AppMode.values[index]),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底栏只承载四个稳定业务目的地，重复点击当前项保持当前页面。
class AppBottomBar extends StatelessWidget {
  /// 四个目的地共用选中状态与安全区，创建操作由独立按钮承接。
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.bottomPadding,
    required this.l10n,
    required this.onTabTap,
  });
  final int currentIndex;
  final double bottomPadding;
  final AppLocalizations l10n;
  final ValueChanged<int> onTabTap;

  /// 安全区只延伸背景，四个文字入口各占完整等宽触摸区域。
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppTokens.tabBarBackground(context),
    child: Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: AppDimens.bottomBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final mode in AppMode.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: currentIndex == mode.index,
                  child: InkWell(
                    key: ValueKey('domain-nav-${mode.name}'),
                    onTap: () => onTabTap(mode.index),
                    child: Center(
                      child: Text(
                        DomainHeader.label(l10n, mode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: MediaQuery.textScalerOf(
                          context,
                        ).clamp(maxScaleFactor: 1.3),
                        style: AppTextTokens.bottomNavigation(
                          context,
                          selected: currentIndex == mode.index,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
