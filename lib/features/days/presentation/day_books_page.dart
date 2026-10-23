import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/days/application/day_book_actions.dart';
import 'package:sesame_notes/shared/presentation/private_book_editor.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/day_sync_status.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/book_selection_actions.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/day_sync_status_provider.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/book_overview_card.dart';
import 'package:sesame_notes/shared/widgets/day_book_counts.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 日子本管理使用账本概览卡片，点击卡片切本，编辑入口直接打开设置。
class DayBooksPage extends ConsumerWidget {
  const DayBooksPage({super.key});

  /// 云端优先；分区标题只在本分区有本时出现，避免出现空标题。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(currentDayBookIdProvider).value;
    final accountId = ref.watch(currentAccountIdProvider);
    final statuses = accountId == null
        ? null
        : ref.watch(daySyncStatusProvider).value;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.dayBooksTitle,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.add,
                tooltip: l10n.dayBookNew,
                onPressed: () => context.pushNamed(Routes.dayBookEdit),
              ),
            ],
          ),
          Expanded(
            child: ref
                .watch(dayBooksForDisplayProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      AppLoadError(onRetry: () => refreshDays(context, ref)),
                  data: (books) => RefreshIndicator(
                    onRefresh: () => refreshDays(context, ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p8,
                      ),
                      children: [
                        for (final mode in [
                          if (books.any((b) => b.isCloud)) 'cloud',
                          if (books.any((b) => !b.isCloud)) 'local',
                        ]) ...[
                          BookSectionTitle(
                            title: mode == 'local'
                                ? l10n.dayLocal
                                : l10n.dayCloud,
                          ),
                          for (final book in books.where(
                            (book) => book.storageMode == mode,
                          ))
                            _buildBookCard(
                              context,
                              ref,
                              book,
                              selected == book.id,
                              statuses
                                  ?.where(
                                    (status) => status.dayBookId == book.id,
                                  )
                                  .firstOrNull,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// 统计与同步说明由日子本提供，卡片标题、状态位置及编辑按钮复用账本组件。
  Widget _buildBookCard(
    BuildContext context,
    WidgetRef ref,
    DayBook book,
    bool selected,
    DayBookSyncStatus? status,
  ) {
    final l10n = AppLocalizations.of(context);
    final events =
        ref.watch(dayEventsProvider(book.id)).value ?? const <DayEvent>[];
    final messages = [
      if (book.isStale)
        l10n.dayBookStale
      else if (book.isCloud && book.syncId == null)
        l10n.dayBookPending,
      if (status != null) ...[
        if (status.pendingCount > 0) l10n.daySyncPending(status.pendingCount),
        if (status.rejectedCount > 0)
          l10n.daySyncRejected(status.rejectedCount),
        if (status.conflictCount > 0)
          l10n.daySyncConflicts(status.conflictCount),
      ],
    ];
    return BookOverviewCard(
      title: book.name,
      selected: selected,
      onTap: () async {
        final completed = ref
            .read(productAnalyticsControllerProvider)
            .captureCompletion(
              pageId: 'days.books',
              context: ref
                  .read(productAnalyticsControllerProvider)
                  .captureContext(),
            );
        try {
          await selectBook(ref.read, mode: AppMode.days, bookId: book.id);
          if (!selected) completed(ProductAction.daysBookSelect);
          if (!context.mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (error, stackTrace) {
          logger.error('DayBooks', '切换日子本失败', error, stackTrace);
          if (context.mounted) showToast(context, l10n.dayTargetUnavailable);
        }
      },
      onEdit: () => context.pushNamed(Routes.dayBookEdit, extra: book),
      editTooltip: l10n.dayBookEdit,
      notice: messages.isEmpty
          ? null
          : Text(messages.join(' · '), style: AppTextTokens.label(context)),
      child: DayBookCounts(
        counts: {
          for (final category in dayCategoryOrder)
            category: events
                .where((event) => event.definition.category == category)
                .length,
        },
      ),
    );
  }
}

class DayBookEditPage extends ConsumerWidget {
  const DayBookEditPage({super.key, this.book});
  final DayBook? book;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PrivateBookEditor(
      actions: ref.watch(dayBookActionsProvider),
      book: book,
      title: l.dayBookNew,
      nameLabel: l.dayName,
      selection: () => ref.read(currentDayBookIdProvider.notifier),
      deleteMessage: (count) =>
          '${l.dayDeleteBook(book?.name ?? '', count)}${book?.isCloud == true ? '\n${l.dayCloudDeleteHint}' : ''}',
    );
  }
}
