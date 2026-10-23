import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';

import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/user_display_name_resolver.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/shared/widgets/currency_flag.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/format_money.dart';
import 'package:sesame_notes/shared/widgets/amount_text.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/shared/widgets/app_detail.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 记录详情 Bottom Sheet。
///
/// 列表项点击 → 打开本 Sheet(展示详情) → 点"编辑记账"进入编辑器。
/// 详情 Sheet 让用户先看再改,并集中展示协作成员与编辑历史(共享账本场景)。
///
/// 所有成员展示名由交易所属账本的统一身份上下文解析。
///
/// [aaEnabled] 账本是否开启分摊。开启时底部常驻「编辑分摊(左) + 编辑记账(右)」,
/// 未开启时底部仅常驻「编辑记账」;删除 icon 始终置于右上角 trailing。
///
/// [onEditAa] 编辑分摊回调;仅 [aaEnabled] 为 true 时使用,跳 [AaEditPage]。
/// 不分摊的交易也允许进入,默认选中不分摊,在页内可切到其他分摊方式。
Future<void> showTransactionDetailSheet({
  required BuildContext context,
  required TransactionDisplay transaction,
  required CategoryDisplay? category,
  bool aaEnabled = false,
  required Future<void> Function(ProductAnalyticsContext context) onEdit,
  Future<void> Function()? onEditAa,
  required Future<void> Function(ProductAnalyticsContext context) onDelete,
}) {
  // 打开交易详情(交易身份页面)时按需刷新成员公开资料(幂等 + 防抖)。
  final container = ProviderScope.containerOf(context, listen: false);
  final analyticsContext = container
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  trackProductEntryAction(
    context,
    container.read,
    fallbackPageId: 'accounting',
    action: ProductAction.accountingTransactionOpenClick,
    context: analyticsContext,
  );
  unawaited(refreshLedgerMemberDirectory(container, transaction.ledgerId));
  return showAppSheet<void>(
    context: context,
    child: productAnalyticsPresentation(
      context: context,
      read: container.read,
      pageId: 'accounting.transaction',
      analyticsContext: analyticsContext,
      child: _TransactionDetailBody(
        analyticsContext: analyticsContext,
        transaction: transaction,
        category: category,
        aaEnabled: aaEnabled,
        onEdit: onEdit,
        onEditAa: onEditAa,
        onDelete: onDelete,
      ),
    ),
  );
}

class _TransactionDetailBody extends ConsumerStatefulWidget {
  final ProductAnalyticsContext analyticsContext;
  final TransactionDisplay transaction;
  final CategoryDisplay? category;

  /// 账本是否开启分摊。决定底部按钮态(单/双)与右上角删除 icon 是否影响布局。
  final bool aaEnabled;
  final Future<void> Function(ProductAnalyticsContext context) onEdit;

  /// 编辑分摊回调;仅 [aaEnabled] 为 true 时使用。
  final Future<void> Function()? onEditAa;
  final Future<void> Function(ProductAnalyticsContext context) onDelete;

  const _TransactionDetailBody({
    required this.analyticsContext,
    required this.transaction,
    required this.category,
    this.aaEnabled = false,
    required this.onEdit,
    this.onEditAa,
    required this.onDelete,
  });

  /// 详情实例持有访问生命周期，数据刷新与重建不会重复记录访问。
  @override
  ConsumerState<_TransactionDetailBody> createState() =>
      _TransactionDetailBodyState();
}

class _TransactionDetailBodyState
    extends ConsumerState<_TransactionDetailBody> {
  /// 关闭详情前固定编辑操作身份，后续入口只记录一次点击并沿用该操作流。
  Future<void> _editTransaction() async {
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: widget.analyticsContext);
    try {
      Navigator.pop(context);
      await widget.onEdit(analyticsContext);
    } catch (error, stackTrace) {
      logger.error(
        'TransactionDetail',
        '打开记账编辑失败',
        error.runtimeType,
        stackTrace,
      );
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 格式化日期时间为本地 yyyy-MM-dd HH:mm。
  String _fmt(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  /// AA 分摊明细区块(只读,与编辑分摊页对齐)。
  ///
  /// 布局:分摊方式 / 支出人 / 参与人 三行,均为只读信息行。
  /// - 分摊方式:不分摊/人均分摊/指定分摊(右对齐值);
  /// - 参与人:昵称前若干人逗号隔开,剩余以「…(x人)」省略;全选显示「全部成员(x人)」。
  /// 指定分摊时仍逐人展示金额行(只读),与人均保持区块结构一致。
  List<Widget> _buildAaSection(
    BuildContext context,
    AppLocalizations l10n,
    TransactionDisplay t,
    UserDisplayNameResolver resolver, {
    required ({List<String>? participantIds, Map<String, String>? splits})
    aaModel,
  }) {
    final mode = AaMode.fromDb(t.aaMode);
    final currency = t.currencyCode.trim().isNotEmpty ? t.currencyCode : 'CNY';
    final widgets = <Widget>[
      AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
      _SectionLabel(text: l10n.aaSplitMode),
      // 分摊方式(右对齐值)
      AppDetailInfoRow(
        label: l10n.aaSplitMode,
        value: mode == AaMode.custom
            ? l10n.aaModeCustom
            : mode == AaMode.perPerson
            ? l10n.aaModePerPerson
            : l10n.aaModeNoSplit,
      ),
    ];
    // 支出人展示解析后的名称，未解析到时使用统一兜底文案。
    final paidById = t.payerMemberId;
    final paidByName = resolver.resolve(paidById);
    final paidByNameDisplay = paidByName.isEmpty
        ? l10n.aaUnknownUser
        : paidByName;
    widgets.add(
      AppDetailInfoRow(label: l10n.aaPayer, value: paidByNameDisplay),
    );
    if (mode == AaMode.noSplit) {
      return widgets;
    }
    // 参与人展示:昵称前若干人逗号隔开,剩余「…(x人)」;全选显示「全部成员(x人)」。
    final ids = aaModel.participantIds;
    widgets.add(
      AppDetailInfoRow(
        label: l10n.aaParticipants,
        value: '',
        valueWidget: _participantsValue(context, l10n, ids, resolver),
      ),
    );
    if (mode == AaMode.custom) {
      // 指定分摊:逐人金额(只读)，label 为参与人名。
      final splits = aaModel.splits ?? const {};
      final Map<String, String> displaySplits;
      try {
        displaySplits = originalSplitAmounts(
          splits,
          amount: t.amount,
          nativeAmount: t.nativeAmount,
          payerMemberId: t.payerMemberId,
        );
      } on FormatException {
        widgets.add(
          AppDetailInfoRow(label: l10n.aaSplitMode, value: l10n.commonError),
        );
        return widgets;
      }
      for (final e in splits.entries) {
        final name = resolver.resolve(e.key);
        final nameDisplay = name.isEmpty ? l10n.aaUnknownUser : name;
        widgets.add(
          AppDetailInfoRow(
            label: nameDisplay,
            value: formatMoneyWithCurrency(
              double.tryParse(displaySplits[e.key]!) ?? 0,
              currencyCode: currency,
            ),
          ),
        );
      }
    }
    return widgets;
  }

  /// 构建信息行右对齐值样式(与 [AppDetailInfoRow] 默认值一致)。
  TextStyle _infoValueStyle(BuildContext context) => AppTextTokens.body(
    context,
  ).copyWith(color: AppTokens.textPrimary(context));

  /// 构建参与人展示组件:昵称前若干人逗号隔开,剩余以「…(x人)」省略。
  ///
  /// 全选([ids]==null)时显示「全部成员」;否则展示前 2 人 + 「…(x人)」。
  Widget _participantsValue(
    BuildContext context,
    AppLocalizations l10n,
    List<String>? ids,
    UserDisplayNameResolver resolver,
  ) {
    final style = _infoValueStyle(context);
    if (ids == null || ids.isEmpty) {
      return Text(
        l10n.aaParticipantsAll,
        style: style,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final count = ids.length;
    final headCount = count <= 2 ? count : 2;
    final spans = <TextSpan>[];
    for (var i = 0; i < headCount; i++) {
      final id = ids[i];
      final name = resolver.resolve(id);
      final display = name.isEmpty ? l10n.aaUnknownUser : name;
      if (i > 0) spans.add(TextSpan(text: '、'));
      spans.add(TextSpan(text: display));
    }
    // 单人已全部展示，不拼「（1人）」；双人保留人数标注；超过 2 人时
    // 尾部表达被省略的人数。
    final tail = count > 2
        ? '…（${count - 2}${l10n.aaParticipantsUnit}）'
        : (count == 2 ? '（$count${l10n.aaParticipantsUnit}）' : '');
    spans.add(TextSpan(text: tail));
    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = widget.transaction;
    final ledger = ref.watch(ledgerByIdProvider(t.ledgerId)).value;
    if (ledger?.archivedAt != null) {
      return AppSheet(
        child: Text(
          l10n.ledgersArchivedRestoreRequired,
          style: AppTextTokens.body(
            context,
          ).copyWith(color: AppTokens.error(context)),
        ),
      );
    }
    final historyAsync = ref.watch(recordEditHistoryProvider(t.id));
    final categoryName = widget.category?.name ?? l10n.homeDetailCategory;
    // 归档状态动态订阅；分摊开关沿用调用参数，AA 区块按当前交易分摊态渲染。
    final aaOn = widget.aaEnabled;

    // 按交易所属账本订阅身份，成员目录与账号资料更新后自动重建。
    final identity = ref
        .watch(ledgerIdentityProvider(t.ledgerId))
        .asData
        ?.value;
    final resolver =
        (identity ??
                LedgerIdentity(
                  selfMemberId: '',
                  localSelfName: l10n.mineLocalName,
                  unknownName: l10n.aaUnknownUser,
                ))
            .resolver;

    return AppDetailSheet(
      // 删除 icon 内嵌到内容区分类标题行右侧(与分类标题同行对齐),
      // 不用 AppSheet.trailing,避免 trailing 单独成行撑高 header、
      // 与分类标题错位。
      footer: aaOn
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await widget.onEditAa?.call();
                    },

                    child: Text(l10n.aaEditSplitButton),
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                Expanded(
                  child: AppPrimaryButton(
                    onPressed: _editTransaction,
                    label: l10n.homeDetailEditButton,
                  ),
                ),
              ],
            )
          // 未开启分摊时仅剩「编辑记账」一个按钮,需占满整行宽度,与
          // 开启分摊时的双按钮布局(两个 Expanded)在视觉宽度上保持一致。
          : AppPrimaryButton(
              onPressed: _editTransaction,
              label: l10n.homeDetailEditButton,
            ),
      header: AppDetailHeader(
        iconBackgroundColor: AppTokens.surfaceCategoryIcon(context),
        icon: CategoryIconWidget(
          category: widget.category,
          size: AppDimens.icon20,
        ),
        title: categoryName,
        subtitle: t.note,
        onDelete: () async {
          final analyticsContext = ref
              .read(productAnalyticsControllerProvider)
              .captureContext(parent: widget.analyticsContext);
          Navigator.pop(context);
          await widget.onDelete(analyticsContext);
        },
      ),
      children: [
        // 2. 信息区
        AppDetailInfoRow(label: l10n.homeDetailDate, value: _fmt(t.happenedAt)),
        AppDetailInfoRow(
          label: l10n.homeDetailAmount,
          // 金额为规范化 Decimal 字符串(单位:元),直接解析。
          value: formatMoneyCompact(double.parse(t.amount)),
          // 主金额:显示交易原币种 + 原金额(与列表项一致)。
          // 设计意图:记账时的币种和金额不受账本币种变更影响,
          valueWidget: AmountText(
            value: -double.parse(t.amount),
            signed: true,
            showCurrency: true,
            currencyCode: t.currencyCode,
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
        ),
        if (t.currencyCode.isNotEmpty)
          AppDetailInfoRow(
            label: l10n.homeDetailCurrency,
            value: t.currencyCode,
            // 全局统一「ISO + (符号)」展示；右对齐与其他信息行一致
            valueWidget: Align(
              alignment: Alignment.centerRight,
              child: currencyFlagLabel(
                t.currencyCode,
                textStyle: AppTextTokens.body(
                  context,
                ).copyWith(color: AppTokens.textPrimary(context)),
              ),
            ),
          ),
        if (ledger != null &&
            t.nativeAmount.isNotEmpty &&
            t.nativeAmount != t.amount)
          AppDetailInfoRow(
            label: l10n.homeDetailNativeAmount,
            // ≈ 折算金额：符号+金额统一走唯一来源 formatMoneyWithCurrency
            value:
                '≈ ${formatMoneyWithCurrency(double.parse(t.nativeAmount), currencyCode: ledger.currency)}',
          ),
        // 2.5 AA 分摊明细(仅账本开启 AA 时展示,功能隔离)
        // 指定分摊存关系表,异步读取后渲染;人均/不分摊不落行,回显 null = 全部成员。
        if (aaOn)
          FutureBuilder<List<TransactionSplitDisplay>>(
            future: ref.read(transactionActionsProvider).getSplits(t.id),
            builder: (context, snapshot) {
              final rows = snapshot.data ?? const <TransactionSplitDisplay>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildAaSection(
                  context,
                  l10n,
                  t,
                  resolver,
                  aaModel: aaRowsToEditModel(rows),
                ),
              );
            },
          ),
        // 3. 协作成员(共享账本才显示:有 createdBy/lastEditedBy 时)
        if (t.createdByMemberId != null || t.lastEditedByMemberId != null) ...[
          AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
          _SectionLabel(text: l10n.homeDetailMembers),
          if (t.createdByMemberId != null)
            _MemberRow(
              label: l10n.homeDetailCreator,
              name: resolver.resolve(t.createdByMemberId),
            ),
          if (t.lastEditedByMemberId != null)
            _MemberRow(
              label: l10n.homeDetailLastEditor,
              name: resolver.resolve(t.lastEditedByMemberId),
            ),
        ],
        // 4. 编辑记录(仅供查看)
        AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
          child: Row(
            children: [
              _SectionLabel(text: l10n.homeDetailEditHistory, dense: true),
              const SizedBox(width: AppDimens.p4),
              Text(
                l10n.homeDetailEditHistoryHint,
                style: AppTextTokens.caption(
                  context,
                ).copyWith(color: AppTokens.textTertiary(context)),
              ),
            ],
          ),
        ),
        historyAsync.when(
          data: (h) => h.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                  child: Text(
                    l10n.homeDetailNoHistory,
                    style: AppTextTokens.label(
                      context,
                    ).copyWith(color: AppTokens.textTertiary(context)),
                  ),
                )
              : Column(
                  children: [
                    for (final e in h)
                      _HistoryRow(e, (id) => resolver.resolve(id)),
                  ],
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.p12),
            child: Center(
              child: SizedBox(
                width: AppDimens.icon16,
                height: AppDimens.icon16,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimens.progressStrokeWidth,
                ),
              ),
            ),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
            child: Text(
              l10n.homeDetailNoHistory,
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textTertiary(context)),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.p16),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool dense;
  const _SectionLabel({required this.text, this.dense = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: dense ? 0 : AppDimens.p8),
    child: Text(
      text,
      style: AppTextTokens.label(context).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTokens.textSecondary(context),
      ),
    ),
  );
}

class _MemberRow extends StatelessWidget {
  final String label;
  final String name;
  const _MemberRow({required this.label, required this.name});

  /// 成员名称保留未知身份回退，布局复用统一的详情信息行。
  @override
  Widget build(BuildContext context) {
    // 解析不到的统一映射「未知」,绝不渲染空名或原始 id。
    final displayName = name.isEmpty
        ? AppLocalizations.of(context).aaUnknownUser
        : name;
    return AppDetailInfoRow(label: label, value: displayName);
  }
}

/// 编辑历史行:vN 标签 + 摘要 + 操作者 · 时间。
class _HistoryRow extends StatelessWidget {
  final RecordEditHistoryDisplay h;
  final String Function(String?) displayNameOf;
  const _HistoryRow(this.h, this.displayNameOf);

  @override
  Widget build(BuildContext context) {
    // 操作者解析不到时统一「未知」,不隐藏该行也不裸显 id。
    final operator = displayNameOf(h.operatorMemberId);
    final operatorName = operator.isEmpty
        ? AppLocalizations.of(context).aaUnknownUser
        : operator;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本号标签 vN
          DetailListTag(
            label: 'v${h.version}',
            foregroundColor: AppTokens.primary(context),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p4,
              vertical: AppDimens.p4,
            ),
            emphasized: true,
          ),
          const SizedBox(width: AppDimens.p8),
          // 摘要 + 操作者·时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.summary,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(color: AppTokens.textPrimary(context)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.p4),
                  child: Text.rich(
                    TextSpan(
                      text: operatorName,
                      style: AppTextTokens.caption(
                        context,
                      ).copyWith(color: AppTokens.textTertiary(context)),
                      children: [
                        TextSpan(
                          text: ' · ${_fmtDate(h.createdAt)}',
                          style: AppTextTokens.dateSecondary(
                            context,
                          ).copyWith(color: AppTokens.textTertiary(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}
