/// 账本卡片组件
///
/// 展示账本基本信息与需要处理的上传失败
library;

import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/currency_flag.dart';
import 'package:sesame_notes/shared/widgets/format_money.dart';
import 'package:sesame_notes/shared/widgets/book_overview_card.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 账本卡片
class LedgerCard extends ConsumerWidget {
  final LedgerDisplayItem ledger;
  final VoidCallback? onTap;

  /// 右下角编辑按钮打开账本设置页。
  final VoidCallback? onMore;

  /// 恢复归档账本；提交期间传入 null 禁用按钮。
  final VoidCallback? onRestore;

  /// 删除归档账本；由调用方提供确认和错误处理。
  final VoidCallback? onDelete;
  final bool selected;

  const LedgerCard({
    super.key,
    required this.ledger,
    this.onTap,
    this.onMore,
    this.onRestore,
    this.onDelete,
    this.selected = false,
  });

  /// 构建账本概览，归档账本在标题行提供恢复和删除操作。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    final rejected =
        ledger.isCloudLedger &&
        (ref.watch(ledgerSyncRejectionsProvider(ledger.id)).value?.isNotEmpty ??
            false);

    return BookOverviewCard(
      title: translateLedgerName(context, ledger.name),
      selected: selected && !ledger.isArchived,
      onTap: ledger.isArchived ? null : onTap,
      onEdit: ledger.isArchived ? null : onMore,
      editTooltip: l10n.ledgersEdit,
      headerActions: [
        // 共享成员数由账本领域提供。
        if (ledger.isShared) ...[
          const SizedBox(width: AppDimens.p4),
          Icon(AppIcons.people, size: AppDimens.icon12, color: primaryColor),
          const SizedBox(width: AppDimens.p4),
          Text(
            '${ledger.memberCount}',
            style: AppTextTokens.label(context).copyWith(color: primaryColor),
          ),
        ],
        if (ledger.isArchived) ...[
          TextButton(onPressed: onRestore, child: Text(l10n.ledgersRestore)),
          IconButton(
            onPressed: onDelete,
            tooltip: l10n.ledgersDeleteConfirm,
            icon: const Icon(AppIcons.delete, size: AppDimens.icon20),
            color: AppTokens.error(context),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
      notice: rejected
          ? Text(
              '有记录未上传，需要处理',
              style: AppTextTokens.label(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.error),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 币种和累计金额沿用统一格式化入口。
          Row(
            children: [
              Text(
                '${l10n.ledgersCurrency}：',
                style: AppTextTokens.body(
                  context,
                ).copyWith(color: AppTokens.textSecondary(context)),
              ),
              currencyFlagLabel(
                ledger.currency,
                textStyle: AppTextTokens.body(
                  context,
                ).copyWith(color: AppTokens.textSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.p4),
          Text(
            l10n.ledgersRecords('${ledger.transactionCount}'),
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
          const SizedBox(height: AppDimens.p4),
          Text(
            l10n.ledgersExpense(
              formatMoneyWithCurrency(
                ledger.expenseTotal,
                currencyCode: ledger.currency,
              ),
            ),
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}
