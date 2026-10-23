import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 账本基础设置中的周期模板；卡片只展示状态，进入编辑页才能修改。
class RecurringTransactionSection extends ConsumerWidget {
  const RecurringTransactionSection({
    super.key,
    required this.ledgerId,
    this.readOnly = false,
    this.drafts = const [],
    this.onDraftsChanged,
    this.draftCurrency,
  });
  final String? ledgerId;
  final bool readOnly;
  final List<RecurringTransactionDisplay> drafts;
  final ValueChanged<List<RecurringTransactionDisplay>>? onDraftsChanged;
  final String? draftCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Future<void> edit([RecurringTransactionDisplay? recurring]) async {
      if (ledgerId == null) {
        final result = await context.pushNamed<Object>(
          Routes.recurringTransactionEdit,
          queryParameters: {'draftCurrency': ?draftCurrency},
          extra: recurring,
        );
        if (!context.mounted || result == null) return;
        final updated = [...drafts];
        final index = recurring == null ? -1 : updated.indexOf(recurring);
        if (result is RecurringTransactionDisplay) {
          if (index < 0) {
            updated.add(result);
          } else {
            updated[index] = result;
          }
        } else if (result == true && index >= 0) {
          updated.removeAt(index);
        }
        onDraftsChanged?.call(updated);
        return;
      }
      final result = await context.pushNamed<bool>(
        Routes.recurringTransactionEdit,
        queryParameters: {'ledgerId': ledgerId!},
        extra: recurring,
      );
      if (result == true && context.mounted) {
        ref.invalidate(recurringTransactionDisplaysProvider);
      }
    }

    Widget cards(List<RecurringTransactionDisplay> items) => Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.p8),
            child: _RecurringCard(
              recurring: item,
              onTap: readOnly ? null : () => edit(item),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: l10n.recurringTransactionTitle,
          padding: EdgeInsets.zero,
          trailing: readOnly
              ? null
              : TextButton.icon(
                  onPressed: () => edit(),
                  icon: const Icon(AppIcons.add, size: AppDimens.icon16),
                  label: Text(l10n.recurringTransactionAdd),
                ),
        ),
        const SizedBox(height: AppDimens.p8),
        if (ledgerId == null)
          cards(drafts)
        else
          ref
              .watch(recurringTransactionDisplaysProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => AppLoadError(
                  message: l10n.commonOperationFailed,
                  retryLabel: l10n.analyticsRetry,
                  onRetry: () =>
                      ref.invalidate(recurringTransactionDisplaysProvider),
                ),
                data: (all) {
                  final items = all
                      .where((item) => item.ledgerId == ledgerId)
                      .toList();
                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return cards(items);
                },
              ),
      ],
    );
  }
}

class _RecurringCard extends ConsumerWidget {
  const _RecurringCard({required this.recurring, this.onTap});
  final RecurringTransactionDisplay recurring;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = recurring.categoryId == null
        ? null
        : recurring.ledgerId.isEmpty
        ? ref.watch(categoryByIdProvider(recurring.categoryId!)).value
        : ref
              .watch(
                categorySubsMapProvider((
                  categoryId: recurring.categoryId!,
                  ledgerId: recurring.ledgerId,
                )),
              )
              .value?[recurring.categoryId];
    final frequency = switch (recurring.frequency) {
      'daily' => l10n.recurringTransactionDaily,
      'weekly' => l10n.recurringTransactionWeekly,
      'yearly' => l10n.recurringTransactionYearly,
      _ => l10n.recurringTransactionMonthly,
    };
    final interval = switch (recurring.frequency) {
      'daily' => l10n.recurringTransactionEveryNDays(recurring.interval),
      'weekly' => l10n.recurringTransactionEveryNWeeks(recurring.interval),
      'yearly' => l10n.recurringTransactionEveryNYears(recurring.interval),
      _ => l10n.recurringTransactionEveryNMonths(recurring.interval),
    };
    return SectionCard(
      margin: EdgeInsets.zero,
      child: AppListTile(
        onTap: onTap,
        leading: AppIcons.repeat,
        leadingWidget: CategoryIconWidget(
          category: category,
          showBackground: true,
        ),
        title: category == null
            ? l10n.categoryTitle
            : CategoryUtils.getDisplayName(category.name, context),
        subtitle: [
          frequency,
          interval,
          if (recurring.frequency == 'weekly' && recurring.dayOfWeek != null)
            DateFormat.EEEE(
              l10n.localeName,
            ).format(DateTime(2026, 1, 4 + recurring.dayOfWeek!)),
          if (recurring.frequency == 'yearly' && recurring.monthOfYear != null)
            DateFormat.MMMM(
              l10n.localeName,
            ).format(DateTime(2026, recurring.monthOfYear!)),
          if ((recurring.frequency == 'monthly' ||
                  recurring.frequency == 'yearly') &&
              recurring.dayOfMonth != null)
            l10n.dayOfMonth(recurring.dayOfMonth!),
          recurring.timeZone,
        ].join(' · '),
        subtitleMaxLines: null,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${recurring.currencyCode} ${recurring.amount}',
              style: AppTextTokens.body(context),
            ),
            const SizedBox(height: AppDimens.p4),
            Text(
              recurring.enabled
                  ? l10n.recurringTransactionEnabled
                  : l10n.recurringTransactionDisabled,
              style: AppTextTokens.caption(context).copyWith(
                color: recurring.enabled
                    ? AppTokens.primary(context)
                    : AppTokens.textTertiary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
