// 成员支出模块 — 按支出人(paidByUserId)统计账本全部支出,
// 顶部展示成员支出合计,下方按成员分层展示金额、笔数与占比。
//
// 数据源为本地 memberExpenseStatsProvider(按 paidByUserId 聚合),
// 含真实成员 + 虚拟用户;paidByUserId 为空的交易不计入(无法归属支出人)。
import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/aa_participant_avatar.dart';
import 'package:sesame_notes/shared/widgets/format_money.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 成员支出模块
///
/// 汇总卡突出成员支出合计，成员卡分层展示姓名、金额、笔数与占比。
/// 作为内容版块内嵌在编辑账本页中，卡片外边距与页面内 Material Card 对齐。
///
/// 常驻显示:新建态/本地账本(无 ledgerId)时数据默认归 0,
/// 直接展示空态。
class MemberStatsSection extends ConsumerWidget {
  const MemberStatsSection({super.key, required this.ledgerId});

  /// 账本 id(UUID 字符串);null = 新建态。
  ///
  /// 为 null 时不拉取统计,汇总卡不展示总支出金额,
  /// 内容区直接展示"暂无记账"空态。
  final String? ledgerId;

  /// 根据统计加载状态展示汇总卡与成员列表。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = ledgerId;
    // 新建态(无 ledgerId):不 watch 本地统计,直接归 0 空态。
    final statsAsync = id != null
        ? ref.watch(memberExpenseStatsProvider(id))
        : const AsyncValue<List<MemberExpenseStatItem>>.data([]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(context, ref, l10n, statsAsync),
        const SizedBox(height: AppDimens.p20),
        SectionTitle(
          title: l10n.sharedMembersStatsDistribution,
          padding: const EdgeInsets.only(bottom: AppDimens.p12),
          trailing: Expanded(
            child: Text(
              l10n.sharedMembersStatsSortHint,
              textAlign: TextAlign.end,
              style: AppTextTokens.label(context),
            ),
          ),
        ),
        // 模块内嵌在页面滚动视图中,加载 / 错误态只需占位展示,不撑满全屏。
        statsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.p20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) {
            logger.error(
              'MemberStatsSection',
              '成员支出统计加载失败 ledger=$id',
              error,
              stack,
            );
            return AppEmpty(
              text: l10n.commonOperationFailed,
              icon: AppIcons.error,
              padding: const EdgeInsets.all(AppDimens.p16),
            );
          },
          data: (stats) => _buildMemberList(context, stats, l10n, id),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.p4,
            AppDimens.p8,
            AppDimens.p4,
            0,
          ),
          child: Text(
            l10n.sharedMembersStatsScopeHint,
            style: AppTextTokens.label(context),
          ),
        ),
      ],
    );
  }

  /// 汇总卡将成员支出合计与金额分行展示，金额使用统计大数样式。
  Widget _buildTitle(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<List<MemberExpenseStatItem>> statsAsync,
  ) {
    // 总支出带账本币种符号展示,与成员条目金额口径一致。
    final stats = statsAsync.value;
    final currencyCode = ledgerId == null
        ? null
        : ref.watch(ledgerByIdProvider(ledgerId!)).value?.currency;
    // 合计金额 / 总笔数 / 支出人数统一走同一份汇总口径，与各成员条目同源。
    final summary = stats == null || stats.isEmpty
        ? null
        : MemberExpenseSummary.from(stats);
    final amount = summary == null
        ? null
        : formatMoneyWithCurrency(
            summary.totalExpense,
            currencyCode: currencyCode,
          );
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppDimens.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.sharedMembersExpenseTotal,
                  style: AppTextTokens.label(context),
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              DetailListTag(
                label: l10n.sharedMembersStatsAllTime,
                foregroundColor: AppTokens.textSecondary(context),
                backgroundColor: AppTokens.surfaceInput(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p8,
                  vertical: AppDimens.p4,
                ),
              ),
            ],
          ),
          if (amount != null && summary != null) ...[
            const SizedBox(height: AppDimens.p8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: AppTextTokens.display3(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.p8),
            Text(
              l10n.sharedMembersStatsSummary(
                summary.memberCount,
                summary.txCount,
                currencyCode ?? '',
              ),
              style: AppTextTokens.label(context),
            ),
          ],
        ],
      ),
    );
  }

  /// 各成员支出条目列表。
  Widget _buildMemberList(
    BuildContext context,
    List<MemberExpenseStatItem> stats,
    AppLocalizations l10n,
    String? ledgerId,
  ) {
    if (stats.isEmpty) {
      return AppEmpty(
        text: l10n.sharedMembersStatsEmpty,
        padding: const EdgeInsets.all(AppDimens.p16),
      );
    }
    final summary = MemberExpenseSummary.from(stats);
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final s in stats) ...[
            _MemberStatTile(ledgerId: ledgerId, stat: s, summary: summary),
            if (s != stats.last)
              AppTokens.cardDivider(
                context,
                indent: 0,
                verticalGap: 0,
                height: 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _MemberStatTile extends ConsumerWidget {
  const _MemberStatTile({
    required this.ledgerId,
    required this.stat,
    required this.summary,
  });

  /// 所属账本 id(供参与人头像统一解析)。
  final String? ledgerId;

  final MemberExpenseStatItem stat;

  /// 全账本成员支出汇总(合计金额用于计算本人占比与细条长度)。
  final MemberExpenseSummary summary;

  /// 成员信息与金额在首行对齐，次行展示笔数和占比，细条辅助比较。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final displayName = stat.displayName;
    final share = summary.sharePercentOf(stat);
    return Padding(
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AaParticipantAvatar(
            ledgerId: ledgerId ?? '',
            participantId: stat.participantId,
            isSelf: stat.isSelf,
            size: AppDimens.icon40,
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: AppDimens.p8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        // 窄屏大额数字按可用宽度缩放，保留完整币种与金额。
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatMoneyWithCurrency(
                              stat.expenseTotal,
                              currencyCode: ledgerId == null
                                  ? null
                                  : ref
                                        .watch(ledgerByIdProvider(ledgerId!))
                                        .value
                                        ?.currency,
                            ),
                            style: AppTextTokens.strongTitle(context).copyWith(
                              color: AppTokens.error(context),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.p4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sharedMembersStatsTxCount(stat.txCount),
                        style: AppTextTokens.label(context),
                      ),
                    ),
                    if (summary.totalExpense > 0)
                      Text(
                        '${share.toStringAsFixed(0)}%',
                        style: AppTextTokens.label(context),
                      ),
                  ],
                ),
                if (summary.totalExpense > 0) ...[
                  const SizedBox(height: AppDimens.p8),
                  ExcludeSemantics(
                    child: LinearProgressIndicator(
                      value: share / 100,
                      minHeight: AppDimens.p4,
                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                      color: AppTokens.primary(context),
                      backgroundColor: AppTokens.surfaceInput(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
