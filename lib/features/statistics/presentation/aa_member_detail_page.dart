import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_member_detail_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/aa_participant_avatar.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 成员账单详情页（按支出人维度汇总）。
///
/// 内容结构（自上而下）：
/// 1. 头部：返回 + 成员头像 + 成员名 / 账本名；
/// 2. 汇总卡：账单汇总 - 总付 / 分摊实付 / 应摊，底部展示该成员应收（应付）金额；
/// 3. 分摊方式：人均分摊 / 指定金额 / 不分摊 笔数三卡；
/// 4. 账单列表：按日期分组的账单卡片，每笔含分类 / 分摊方式徽标 / 备注 /
///    时间·付款人 / 账单总额；AA 账单展开分摊明细，
///    不分摊账单无分摊明细。
///
/// 数据源为 [aaMemberDetailProvider]：展示该成员作为支出人的全部支出明细
/// （含不分摊，即首页列表按成员筛选）；虚拟用户 / 账本 owner / 协作者均可
/// 从分摊详情表进入查看，本人标记与汇总口径和分摊详情表完全一致。
class AaMemberDetailPage extends ConsumerWidget {
  const AaMemberDetailPage({super.key, required this.args});

  /// 路由入参（账本 id + 参与人标识 + 展示名 / 本人标记）。
  final AaMemberDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (ref.watch(ledgerByIdProvider(args.ledgerId)).value?.archivedAt !=
        null) {
      return Scaffold(
        body: Column(
          children: [
            _buildHeader(context, null),
            Expanded(
              child: AppEmpty(text: l10n.ledgersArchivedRestoreRequired),
            ),
          ],
        ),
      );
    }
    final detailAsync = ref.watch(
      aaMemberDetailProvider((
        ledgerId: args.ledgerId,
        participantId: args.participantId,
      )),
    );

    return Scaffold(
      body: Column(
        children: [
          // 数据未就绪时头部也能渲染成员名（名称已随路由参数传入）。
          _buildHeader(context, detailAsync.value?.ledgerName),
          Expanded(
            child: detailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) {
                // 原始异常只进日志,页面展示统一友好文案,避免泄露实现细节。
                logger.error(
                  'AaMemberDetailPage',
                  '成员账单详情加载失败 participant=${args.participantId}',
                  e,
                  st,
                );
                return AppEmpty(
                  text: l10n.commonOperationFailed,
                  icon: AppIcons.error,
                );
              },
              data: (data) => data == null
                  ? AppEmpty(text: l10n.aaStatisticsMemberTxEmpty)
                  : _buildBody(context, ref, l10n, data),
            ),
          ),
        ],
      ),
    );
  }

  /// 成员头像与姓名放入统一头部插槽，返回行为和安全区由头部维护。
  Widget _buildHeader(BuildContext context, String? ledgerName) =>
      PrimaryHeader(
        title: args.displayName,
        showBack: true,
        titleWidget: Row(
          children: [
            AaParticipantAvatar(
              ledgerId: args.ledgerId,
              participantId: args.participantId,
              isSelf: args.isSelf,
              size: AppDimens.icon28,
            ),
            const SizedBox(width: AppDimens.p8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    args.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ledgerName != null && ledgerName.isNotEmpty)
                    Text(
                      ledgerName,
                      style: AppTextTokens.label(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AaMemberDetailData data,
  ) {
    // 汇总/分摊方式/单笔账单均按账本本位币口径，与分摊详情表一致。
    final currencyCode = ref
        .watch(ledgerByIdProvider(args.ledgerId))
        .value
        ?.currency;
    // 总付 = 全部账单合计（含不分摊支出），口径由数据模型统一给出。
    final totalAmount = data.totalBillAmount;
    final aaCount = data.bills.where((b) => b.mode == AaMode.perPerson).length;
    final customCount = data.bills.where((b) => b.mode == AaMode.custom).length;
    final noSplitCount = data.bills
        .where((b) => b.mode == AaMode.noSplit)
        .length;
    // 账单列表扁平化索引:日期标题 + 单笔账单行,交给 ListView.builder 懒加载,
    // 避免几百笔账单时每次 build 都创建整棵 Widget 树。
    final entries = data.bills.isEmpty
        ? const <Object>[]
        : _flattenBillEntries(data.bills);

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.p16),
      itemCount: 2 + (data.bills.isEmpty ? 1 : entries.length),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(
            context,
            l10n,
            data,
            totalAmount,
            currencyCode,
          );
        }
        if (index == 1) {
          // 汇总卡与分摊方式卡使用统一的区块间距。
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p16),
            child: _buildSplitMethod(
              context,
              l10n,
              aaCount,
              customCount,
              noSplitCount,
            ),
          );
        }
        if (data.bills.isEmpty) {
          return _buildEmptyCard(l10n);
        }
        final entry = entries[index - 2];
        if (entry is _BillDateHeader) {
          return DaySectionHeader(
            dateText: entry.dateKey,
            expense: entry.dayTotal,
            currencyCode: currencyCode ?? '',
          );
        }
        if (entry is _BillRowEntry) {
          return _buildBillRowItem(context, l10n, entry, currencyCode);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 汇总卡：账单汇总 - 总付 / 分摊实付 / 应摊，
  /// 底部展示该成员应收 / 应付金额（与分摊详情表净额口径一致）。
  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    AaMemberDetailData data,
    double totalAmount,
    String? currencyCode,
  ) {
    final net = data.member.net;
    final netLabel = net.abs() < 0.005
        ? l10n.aaStatisticsSettled
        : (net > 0
              ? l10n.aaStatisticsNetReceiveAmount
              : l10n.aaStatisticsNetPayAmount);
    // 应收/应付沿用分摊详情表的语义色：正数绿色、负数红色、结清中性色。
    final netColor = net.abs() < 0.005
        ? AppTokens.textTertiary(context)
        : (net > 0 ? AppTokens.success(context) : AppTokens.error(context));

    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题行：与分摊统计页其他卡片一致使用中性色小字。
          Row(
            children: [
              Icon(
                AppIcons.receipt,
                size: AppDimens.icon12,
                color: AppTokens.textTertiary(context),
              ),
              const SizedBox(width: AppDimens.p4),
              Text(
                l10n.aaStatisticsBillSummary,
                style: AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.textSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.p16),
          // 总付 / 分摊实付 / 应摊：三个指标共用同一套标签在上、数值在下的
          // 居中样式，与分摊详情表的成员指标视觉一致；总付含不分摊支出，
          // 分摊实付/应摊口径与分摊详情表一致。
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  context,
                  l10n.aaStatisticsPaidAll,
                  formatMoneyWithCurrency(
                    totalAmount,
                    currencyCode: currencyCode ?? '',
                  ),
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  context,
                  l10n.aaStatisticsPaid,
                  formatMoneyWithCurrency(
                    data.member.totalPaid,
                    currencyCode: currencyCode ?? '',
                  ),
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  context,
                  l10n.aaStatisticsShare,
                  formatMoneyWithCurrency(
                    data.member.totalShouldPay,
                    currencyCode: currencyCode ?? '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.p16),
          AppTokens.cardDivider(context, indent: 0, verticalGap: 0, height: 1),
          const SizedBox(height: AppDimens.p12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                netLabel,
                style: AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.textSecondary(context)),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatMoneyWithCurrency(
                      net.abs(),
                      currencyCode: currencyCode ?? '',
                    ),
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600, color: netColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 汇总卡指标列：标签在上、数值在下，二者均水平居中。
  /// 标签与分摊详情表一致用 11px 三级色，数值统一用 12px 主色加粗。
  Widget _buildSummaryMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextTokens.caption(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
        const SizedBox(height: AppDimens.p4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextTokens.label(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokens.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  /// 分摊方式：人均分摊 / 指定金额 / 不分摊 笔数三卡。
  /// 三个方式统一中性样式，不按方式区分颜色，避免视觉杂乱。
  Widget _buildSplitMethod(
    BuildContext context,
    AppLocalizations l10n,
    int aaCount,
    int customCount,
    int noSplitCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
          child: Text(
            l10n.aaSplitMode,
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.textTertiary(context)),
          ),
        ),
        const SizedBox(height: AppDimens.p8),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                context,
                aaCount,
                l10n.aaStatisticsModePerPerson,
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Expanded(
              child: _buildMethodCard(
                context,
                customCount,
                l10n.aaStatisticsModeCustom,
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Expanded(
              child: _buildMethodCard(
                context,
                noSplitCount,
                l10n.aaModeNoSplit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 分摊方式摘要复用全局卡片，数值与说明使用统一文字层级。
  Widget _buildMethodCard(BuildContext context, int count, String label) {
    final number = AppTokens.textPrimary(context);
    final text = AppTokens.textTertiary(context);
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p8,
        vertical: AppDimens.p12,
      ),
      showShadow: false,
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextTokens.display1(
              context,
            ).copyWith(color: number, height: 1),
          ),
          const SizedBox(height: AppDimens.p4),
          Text(
            label,
            style: AppTextTokens.caption(context).copyWith(color: text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 把账单列表展平为「日期标题 + 单笔账单」的索引序列。
  ///
  /// 设计意图:ListView.builder 需要扁平的 item 序列才能按需构建;
  /// 每行记录是否组首/组尾,由 [_buildBillRowItem] 据此绘制连续卡片
  /// 的圆角、内部分割线与组尾间距。
  List<Object> _flattenBillEntries(List<AaMemberBill> bills) {
    final groups = <String, List<AaMemberBill>>{};
    for (final b in bills) {
      final key = _dateKey(b.tx.happenedAt);
      (groups[key] ??= []).add(b);
    }

    final entries = <Object>[];
    for (final entry in groups.entries) {
      final dayTotal = entry.value.fold<double>(
        0,
        (sum, b) => sum + b.totalAmount,
      );
      entries.add(_BillDateHeader(entry.key, dayTotal));
      final dayBills = entry.value;
      for (var i = 0; i < dayBills.length; i++) {
        entries.add(
          _BillRowEntry(
            bill: dayBills[i],
            isFirstInGroup: i == 0,
            isLastInGroup: i == dayBills.length - 1,
          ),
        );
      }
    }
    return entries;
  }

  /// 单笔账单行容器:组首行负责卡片顶部圆角与阴影,组尾行负责底部圆角
  /// 与组间距,中间行仅提供表面底色 + 上分割线,整体视觉等同单张
  /// SectionCard,但每一行可被 ListView.builder 独立懒加载。
  Widget _buildBillRowItem(
    BuildContext context,
    AppLocalizations l10n,
    _BillRowEntry entry,
    String? currencyCode,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: entry.isLastInGroup ? AppDimens.p16 : 0),
      decoration: BoxDecoration(
        color: AppTokens.surface(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            entry.isFirstInGroup ? AppTokens.cardRadius(context) : 0,
          ),
          bottom: Radius.circular(
            entry.isLastInGroup ? AppTokens.cardRadius(context) : 0,
          ),
        ),
        // 整组卡片阴影由组首/组尾行承载(中间行表面覆盖组首下缘),
        // 视觉上仍是一张卡片的外围阴影。
        boxShadow: (entry.isFirstInGroup || entry.isLastInGroup)
            ? AppTokens.cardShadow(context)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!entry.isFirstInGroup)
            AppTokens.cardDivider(
              context,
              indent: 0,
              verticalGap: 0,
              height: 1,
            ),
          _buildBillRow(context, l10n, entry.bill, currencyCode),
        ],
      ),
    );
  }

  /// 单笔账单：分类图标 + 分类名/分摊方式徽标 + 备注 + 时间·付款人 +
  /// 右侧账单总额；AA 账单下方展开分摊明细，不分摊无明细。
  Widget _buildBillRow(
    BuildContext context,
    AppLocalizations l10n,
    AaMemberBill bill,
    String? currencyCode,
  ) {
    final categoryName = CategoryUtils.getDisplayName(
      bill.category?.name,
      context,
    );
    final time = bill.tx.happenedAt.toLocal();
    final timeText =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    // 单笔账单金额为账本本位币口径(与汇总卡/分摊详情表一致),
    // 避免多币种账本下原币金额与汇总口径混用。

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.p16,
            AppDimens.p12,
            AppDimens.p16,
            AppDimens.p8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分类图标与首页列表项共用圆角方形轮廓和分类配色。
              CategoryIconWidget(
                category: bill.category,
                size: AppDimens.icon20,
                showBackground: true,
                backgroundSize: AppDimens.p36,
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            categoryName,
                            style: AppTextTokens.title(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimens.p4),
                        _buildSplitBadge(context, bill.mode, l10n),
                      ],
                    ),
                    if (bill.tx.note != null && bill.tx.note!.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.p4),
                      Text(
                        bill.tx.note!,
                        style: AppTextTokens.caption(
                          context,
                        ).copyWith(color: AppTokens.textSecondary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      '$timeText · ${l10n.aaStatisticsPayerPrefix}: '
                      '${bill.payerName}',
                      style: AppTextTokens.caption(
                        context,
                      ).copyWith(color: AppTokens.textTertiary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.p12),
              // 右侧显示账单总额，本人应摊金额位于下方分摊明细。
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(
                    value: bill.totalAmount,
                    signed: false,
                    showCurrency: true,
                    currencyCode: currencyCode ?? '',
                    scaleDown: true,
                    style: AppTextTokens.label(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTokens.error(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 分摊明细：仅 AA 账单渲染；不分摊账单无分摊明细。
        if (bill.splits.isNotEmpty)
          SectionCard(
            margin: const EdgeInsets.fromLTRB(
              AppDimens.p16,
              0,
              AppDimens.p16,
              AppDimens.p12,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p12,
              vertical: AppDimens.p8,
            ),
            color: AppTokens.surfaceSecondary(context),
            showShadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.aaStatisticsSplitDetail,
                  style: AppTextTokens.caption(
                    context,
                  ).copyWith(color: AppTokens.textTertiary(context)),
                ),
                const SizedBox(height: AppDimens.p4),
                for (final s in bill.splits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.p3),
                    child: Row(
                      children: [
                        AaParticipantAvatar(
                          ledgerId: args.ledgerId,
                          participantId: s.participantId,
                          isSelf: s.isSelf,
                          size: AppDimens.icon20,
                        ),
                        const SizedBox(width: AppDimens.p4),
                        Expanded(
                          child: Text(
                            s.displayName,
                            style: AppTextTokens.caption(
                              context,
                            ).copyWith(color: AppTokens.textSecondary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatMoneyWithCurrency(
                                s.amount,
                                currencyCode: currencyCode ?? '',
                              ),
                              style: AppTextTokens.caption(
                                context,
                              ).copyWith(color: AppTokens.textPrimary(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 分摊方式徽标：三种方式统一中性色，不按方式区分颜色。
  Widget _buildSplitBadge(
    BuildContext context,
    AaMode mode,
    AppLocalizations l10n,
  ) {
    final color = AppTokens.textSecondary(context);
    final bg = AppTokens.surfaceSecondary(context);
    final label = switch (mode) {
      AaMode.perPerson => l10n.aaStatisticsModePerPerson,
      AaMode.custom => l10n.aaStatisticsModeCustom,
      AaMode.noSplit => l10n.aaModeNoSplit,
    };
    return DetailListTag(
      label: label,
      foregroundColor: color,
      backgroundColor: bg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p4,
        vertical: AppDimens.p4,
      ),
    );
  }

  /// 账单为空时由全局卡片和空态组件共同呈现。
  Widget _buildEmptyCard(AppLocalizations l10n) {
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p32),
      child: AppEmpty(
        text: l10n.aaStatisticsMemberTxEmpty,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// 日期分组 key（yyyy-MM-dd），与全局 [DaySectionHeader] 的日期格式一致。
  String _dateKey(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

/// 账单列表扁平化条目:日期分组标题(日期 + 当日支出合计)。
class _BillDateHeader {
  final String dateKey;
  final double dayTotal;

  const _BillDateHeader(this.dateKey, this.dayTotal);
}

/// 账单列表扁平化条目:单笔账单行。
///
/// [isFirstInGroup]/[isLastInGroup] 用于渲染组卡片的首尾圆角、分割线与
/// 组尾间距,保证懒加载拆分后视觉与整张卡片一致。
class _BillRowEntry {
  final AaMemberBill bill;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _BillRowEntry({
    required this.bill,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });
}
