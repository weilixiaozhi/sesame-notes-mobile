import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/diagnostics/presentation/acceptance_seed_dialog.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/current_private_book_provider.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

typedef _BookChoice = ({String id, String name, bool cloud});

/// 页头当前本只提供名称与标识，存储归属由选本目录自行展示。
typedef _CurrentBookChoice = ({String id, String name});

/// 每次打开选择器重新读取可见账本，查询仍走现有权限与发布校验。
final _ledgerChoicesProvider = FutureProvider.autoDispose<List<_BookChoice>>((
  ref,
) async {
  // 身份、发布状态与账本变更会使候选失效，旧目录不能延续到新的会话。
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  ref.watch(unpublishedCloudLedgersProvider);
  ref.watch(ledgerListRefreshProvider);
  ref.watch(accountingDataChangeSignalProvider);
  try {
    final books = await ref.read(ledgerActionsProvider).getAll();
    return books
        .map(
          (book) => (
            id: book.id,
            name: book.name,
            cloud: book.storageMode == 'cloud',
          ),
        )
        .toList();
  } catch (error, stack) {
    logger.error('DomainHeader', '加载账本选择列表失败', error, stack);
    rethrow;
  }
});

/// 四个业务域共用标题、本子上下文和域内页签；入口与内容页分开维护。
class DomainHeader extends ConsumerWidget {
  const DomainHeader({
    super.key,
    required this.mode,
    required this.tabIndex,
    required this.onTab,
    required this.onCalendar,
    required this.onProfile,
  });
  final AppMode mode;
  final int tabIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onCalendar;
  final VoidCallback onProfile;

  /// 账号密码页签使用独立当前本，普通备忘与工具保留普通备忘本上下文。
  bool get _credentialTab => mode == AppMode.memos && tabIndex == 4;

  /// 只订阅当前业务的本子，避免切换无关业务时触发额外加载。
  _CurrentBookChoice? _current(WidgetRef ref) => switch (mode) {
    AppMode.bookkeeping => switch (ref
        .watch(currentLedgerDisplayProvider)
        .value) {
      final book? => (id: book.id, name: book.name),
      _ => null,
    },
    AppMode.days => switch (ref.watch(currentDayBookProvider).value) {
      final book? => (id: book.id, name: book.name),
      _ => null,
    },
    AppMode.memos => switch (ref
        .watch(
          _credentialTab
              ? currentCredentialBookProvider
              : currentMemoBookProvider,
        )
        .value) {
      final book? => (id: book.id, name: book.name),
      _ => null,
    },
    AppMode.fitness => switch (ref.watch(currentFitnessSpaceProvider).value) {
      final book? => (id: book.id, name: book.name),
      _ => null,
    },
  };

  /// 业务标题与底栏使用同一组简短名称。
  static String label(AppLocalizations l, AppMode mode) => switch (mode) {
    AppMode.bookkeeping => l.shellMoney,
    AppMode.days => l.shellDays,
    AppMode.memos => l.shellMemos,
    AppMode.fitness => l.shellFitness,
  };

  /// 域内第三页签使用独立索引，日历与我的继续使用原共享索引。
  static List<int> tabs(AppMode mode) => switch (mode) {
    AppMode.fitness || AppMode.memos => const [0, 4, 1],
    _ => const [0, 1],
  };

  /// 管理入口始终可达，空本也能从这里新建。
  String _managementRoute() => switch (mode) {
    AppMode.bookkeeping => Routes.ledgers,
    AppMode.days => Routes.dayBooks,
    AppMode.memos => Routes.memoBooks,
    AppMode.fitness => Routes.fitnessSpaces,
  };

  /// 管理页面由现有路由承接，失败时保留当前视图。
  Future<void> _openRoute(BuildContext context, String route) async {
    try {
      await context.pushNamed(route);
    } catch (error, stack) {
      logger.error('DomainHeader', '打开业务入口失败 route=$route', error, stack);
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 本子弹层只改变当前业务上下文，保留正在查看的域内页签。
  Future<void> _chooseBook(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    try {
      final picked = await showAppSheet<String>(
        context: context,
        child: _DomainBookSheet(
          mode: mode,
          account: account,
          generation: generation,
          current: _current,
          credentials: _credentialTab,
        ),
      );
      if (picked == null || !context.mounted) return;
      if (picked == '__manage__') {
        await _openRoute(context, _managementRoute());
        return;
      }
      // 弹层打开期间登录身份变化时，丢弃旧目录的选择。
      if (account != ref.read(currentAccountIdProvider) ||
          generation != ref.read(authIdentityGenerationProvider)) {
        return;
      }
      final changed = _current(ref)?.id != picked;
      final completed = ref
          .read(productAnalyticsControllerProvider)
          .captureCompletion(
            pageId: productAnalyticsEntryPage(
              context,
              ref.read,
              fallbackPageId: productAnalyticsRootPage(mode, tabIndex),
            ),
            context: ref
                .read(productAnalyticsControllerProvider)
                .captureContext(),
          );
      switch (mode) {
        case AppMode.bookkeeping:
          await selectPublishedLedger(ref.read, picked);
        case AppMode.days:
          await ref.read(currentDayBookIdProvider.notifier).select(picked);
        case AppMode.memos:
          if (_credentialTab) {
            await ref
                .read(currentCredentialBookIdProvider.notifier)
                .select(picked);
          } else {
            await ref.read(currentMemoBookIdProvider.notifier).select(picked);
          }
        case AppMode.fitness:
          await ref.read(currentFitnessSpaceIdProvider.notifier).select(picked);
      }
      if (changed) {
        completed(switch (mode) {
          AppMode.bookkeeping => ProductAction.accountingLedgerSelect,
          AppMode.days => ProductAction.daysBookSelect,
          AppMode.memos =>
            _credentialTab
                ? ProductAction.credentialsBookSelect
                : ProductAction.memosBookSelect,
          AppMode.fitness => ProductAction.fitnessSpaceSelect,
        });
      }
    } catch (error, stack) {
      logger.error('DomainHeader', '切换当前本失败 mode=${mode.name}', error, stack);
      if (context.mounted) showToast(context, l.commonOperationFailed);
    }
  }

  /// 标题、选本和快捷入口保持同排，窄屏优先保留按钮触达面积。
  Widget _titleRow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    String bookName,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      const actionSize = AppDimens.actionButtonMinHeight;
      const bookMinimumWidth = AppDimens.domainActionSize + AppDimens.p32;
      // 先为选本、日历和头像留出完整按钮宽度，只有业务标题按剩余空间缩放。
      final titleMaximumWidth =
          (constraints.maxWidth -
                  actionSize * 2 -
                  bookMinimumWidth -
                  AppDimens.p8 -
                  AppDimens.p4)
              .clamp(AppDimens.p32, double.infinity);
      return Row(
        key: ValueKey('domain-title-row-${mode.name}'),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: titleMaximumWidth),
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label(l, mode),
                  key: ValueKey('domain-title-${mode.name}'),
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextTokens.domainTitle(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: bookName,
                child: TextButton(
                  key: ValueKey('domain-book-selector-${mode.name}'),
                  onPressed: () => _chooseBook(context, ref),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(bookMinimumWidth, actionSize),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p8,
                    ),
                    foregroundColor: AppTokens.textSecondary(context),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTokens.inputRadius(context),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          bookName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.label(context),
                        ),
                      ),
                      const SizedBox(width: AppDimens.p4),
                      const Icon(AppIcons.chevronDown, size: AppDimens.icon12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.p4),
          SizedBox.square(
            dimension: actionSize,
            child: IconButton(
              tooltip: l.tabCalendar,
              onPressed: onCalendar,
              icon: const Icon(AppIcons.calendar, size: AppDimens.icon20),
            ),
          ),
          SizedBox.square(
            dimension: actionSize,
            child: IconButton(
              tooltip: l.tabMine,
              onPressed: onProfile,
              icon: const ExcludeSemantics(
                child: SelfAvatar(size: AppDimens.icon20),
              ),
            ),
          ),
        ],
      );
    },
  );

  /// 眉题、紧凑标题行与域内页签共用安全区和页面边距。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final book = _current(ref);
    final indices = tabs(mode);
    final titles = switch (mode) {
      AppMode.bookkeeping => [l.shellMoneyDetails, l.tabAnalytics],
      AppMode.days => [l.shellDays, l.daysTools],
      AppMode.memos => [l.shellMemoNotes, l.memoCredentialsTitle, l.daysTools],
      AppMode.fitness => [
        l.shellFitnessTraining,
        l.shellFitnessPlans,
        l.tabAnalytics,
      ],
    };
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.domainPageInset,
          AppDimens.p8,
          AppDimens.domainPageInset,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(switch (mode) {
              AppMode.bookkeeping => 'MONEY, IN CLARITY',
              AppMode.days => 'MOMENTS THAT MATTER',
              AppMode.memos => 'SPACE FOR YOUR THOUGHTS',
              AppMode.fitness => 'A LITTLE STRONGER, EVERY DAY',
            }, style: AppTextTokens.domainEyebrow(context)),
            _titleRow(
              context,
              ref,
              l,
              book?.name ??
                  (mode == AppMode.fitness
                      ? l.shellChooseSpace
                      : l.shellChooseBook),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTokens.divider(context)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var index = 0; index < indices.length; index++)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppDimens.p20,
                              ),
                              child: Semantics(
                                selected: tabIndex == indices[index],
                                button: true,
                                child: InkWell(
                                  key: ValueKey(
                                    'domain-tab-${mode.name}-${indices[index]}',
                                  ),
                                  onTap: () => onTab(indices[index]),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: AppDimens.domainActionSize,
                                      minWidth: AppDimens.domainActionSize,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: tabIndex == indices[index]
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                          width:
                                              AppDimens.selectionIndicatorWidth,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      widthFactor: 1,
                                      child: Text(
                                        titles[index],
                                        maxLines: 1,
                                        softWrap: false,
                                        style: AppTextTokens.body(context)
                                            .copyWith(
                                              color: tabIndex == indices[index]
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : AppTokens.textSecondary(
                                                      context,
                                                    ),
                                              fontWeight:
                                                  tabIndex == indices[index]
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
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
                  if (kDebugMode) AcceptanceSeedAction(mode: mode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 候选目录与重试状态属于一次弹层会话，身份改变时立即清空并关闭。
class _DomainBookSheet extends ConsumerStatefulWidget {
  /// 打开时固定身份，当前本仅作为同一会话中的选中标识。
  const _DomainBookSheet({
    required this.mode,
    required this.account,
    required this.generation,
    required this.current,
    required this.credentials,
  });

  final AppMode mode;
  final String? account;
  final int generation;
  final _CurrentBookChoice? Function(WidgetRef) current;
  final bool credentials;

  /// 重试锁与关闭标志由弹层自身维护。
  @override
  ConsumerState<_DomainBookSheet> createState() => _DomainBookSheetState();
}

class _DomainBookSheetState extends ConsumerState<_DomainBookSheet> {
  bool _retrying = false;
  bool _closing = false;

  /// 异步结果与点击只属于打开弹层时的账号和会话。
  bool get _sameSession =>
      ref.read(currentAccountIdProvider) == widget.account &&
      ref.read(authIdentityGenerationProvider) == widget.generation;

  /// 本地查询重新订阅，已登录时再通过现有账号级同步发现云端目录。
  Future<void> _retryDirectory() async {
    if (_retrying || !_sameSession) return;
    setState(() => _retrying = true);
    try {
      switch (widget.mode) {
        case AppMode.bookkeeping:
          ref.invalidate(_ledgerChoicesProvider);
        case AppMode.days:
          ref.invalidate(dayBooksProvider);
        case AppMode.memos:
          ref.invalidate(memoBooksProvider);
        case AppMode.fitness:
          ref.invalidate(fitnessSpacesProvider);
      }
      if (widget.account != null) {
        // 不传本子标识，零缓存时也必须发起账号级目录发现。
        final result = await ref.read(syncCoordinatorProvider).refreshData();
        if (!mounted || !_sameSession) return;
        if (result.error != null) {
          logger.warning('DomainBookSheet', '重试本子目录未完成', result.error);
          showToast(context, result.error!);
        }
      }
    } catch (error, stackTrace) {
      logger.error(
        'DomainBookSheet',
        '重试本子目录失败 mode=${widget.mode.name}',
        error,
        stackTrace,
      );
      if (mounted && _sameSession) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  /// 身份变化先移除全部旧内容，再安全关闭当前弹层，不弹出其他路由。
  Widget _closeForIdentityChange() {
    if (!_closing) {
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
        Navigator.of(context).pop();
      });
    }
    return const SizedBox.shrink();
  }

  /// 点击时再次核对会话，避免身份变化与重建之间提交旧目录选项。
  void _choose(String id) {
    if (!_sameSession || _closing || _retrying) return;
    Navigator.of(context).pop(id);
  }

  /// 三个私有域共享目录发现门限，未完成与失败均不能展示成空目录。
  @override
  Widget build(BuildContext context) {
    final account = ref.watch(currentAccountIdProvider);
    final generation = ref.watch(authIdentityGenerationProvider);
    if (account != widget.account || generation != widget.generation) {
      return _closeForIdentityChange();
    }
    final l = AppLocalizations.of(context);
    final AsyncValue<List<_BookChoice>> books = switch (widget.mode) {
      AppMode.bookkeeping => ref.watch(_ledgerChoicesProvider),
      AppMode.days =>
        ref
            .watch(dayBooksForDisplayProvider)
            .whenData(
              (books) => books
                  .map(
                    (book) =>
                        (id: book.id, name: book.name, cloud: book.isCloud),
                  )
                  .toList(),
            ),
      AppMode.memos =>
        privateBooksForDisplay(
          ref.watch(
            widget.credentials
                ? memoCredentialBooksProvider
                : memoNormalBooksProvider,
          ),
          account,
          ref.watch(memoDirectoryStatusProvider),
        ).whenData(
          (books) => books
              .map(
                (book) => (id: book.id, name: book.name, cloud: book.isCloud),
              )
              .toList(),
        ),
      AppMode.fitness =>
        privateBooksForDisplay(
          ref.watch(fitnessSpacesProvider),
          account,
          ref.watch(fitnessDirectoryStatusProvider),
        ).whenData(
          (books) => books
              .map(
                (book) => (id: book.id, name: book.name, cloud: book.isCloud),
              )
              .toList(),
        ),
    };
    final selected = widget.current(ref);
    return AppSheet(
      title: widget.mode == AppMode.fitness
          ? l.shellChooseSpace
          : l.shellChooseBook,
      footer: TextButton.icon(
        onPressed: _retrying ? null : () => _choose('__manage__'),
        icon: const Icon(AppIcons.bookManagement),
        label: Text(switch (widget.mode) {
          AppMode.bookkeeping => l.ledgersTitle,
          AppMode.days => l.dayBooksTitle,
          AppMode.memos => l.memoBooksManagement,
          AppMode.fitness => l.fitnessSpacesManagement,
        }),
      ),
      child: _retrying
          ? const Center(child: CircularProgressIndicator())
          : books.when(
              skipLoadingOnReload: false,
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                logger.error(
                  'DomainBookSheet',
                  '加载本子目录失败 mode=${widget.mode.name}',
                  error,
                  stackTrace,
                );
                return AppLoadError(
                  message: l.commonOperationFailed,
                  onRetry: _retryDirectory,
                );
              },
              data: (books) => books.isEmpty
                  ? AppEmpty(
                      text: switch (widget.mode) {
                        AppMode.bookkeeping => l.ledgersEmpty,
                        AppMode.days => l.dayBookEmpty,
                        AppMode.memos => l.memoNoBooks,
                        AppMode.fitness => l.fitnessNoSpaces,
                      },
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final book in books)
                          AppRadioTile(
                            title: book.name,
                            selected: book.id == selected?.id,
                            subtitle: Text(
                              book.cloud
                                  ? l.memoStorageCloud
                                  : l.memoStorageLocal,
                            ),
                            onTap: () => _choose(book.id),
                          ),
                      ],
                    ),
            ),
    );
  }
}
