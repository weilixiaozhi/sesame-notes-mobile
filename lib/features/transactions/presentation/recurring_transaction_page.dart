import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class RecurringTransactionPage extends ConsumerWidget {
  const RecurringTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringTransactionsAsync = ref.watch(
      recurringTransactionDisplaysProvider,
    );

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: AppLocalizations.of(context).recurringTransactionTitle,
            showBack: true,
            actions: [
              // 统一使用圆圈加号图标（与分类管理新增入口一致）；
              // 右缘留白由 PrimaryHeader 默认 padding 提供，不叠加额外 padding
              HeaderIconAction(
                icon: AppIcons.addCircle,
                tooltip: AppLocalizations.of(context).recurringTransactionAdd,
                onPressed: () => _addRecurringTransaction(context, ref),
              ),
            ],
          ),
          Expanded(
            child: recurringTransactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                // 原始异常只进日志,页面展示统一友好文案 + 重试。
                logger.error(
                  'RecurringTransactionPage',
                  '周期账单列表加载失败',
                  error,
                  stack,
                );
                final l10n = AppLocalizations.of(context);
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.commonOperationFailed,
                        style: TextStyle(
                          color: AppTokens.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: AppDimens.p8),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(
                          recurringTransactionDisplaysProvider,
                        ),
                        icon: const Icon(
                          AppIcons.refresh,
                          size: AppDimens.icon16,
                        ),
                        label: Text(l10n.analyticsRetry),
                      ),
                    ],
                  ),
                );
              },
              data: (recurringTransactions) {
                if (recurringTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.repeat,
                          size: 64,
                          color: AppTokens.textTertiary(context),
                        ),
                        const SizedBox(height: AppDimens.p16),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).recurringTransactionEmpty,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTokens.textSecondary(context),
                              ),
                        ),
                        const SizedBox(height: AppDimens.p8),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).recurringTransactionEmptyHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTokens.textTertiary(context),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                    vertical: AppDimens.p16,
                  ),
                  itemCount:
                      recurringTransactions.length +
                      1, // +1 for usage guide card
                  itemBuilder: (context, index) {
                    // 第一个显示使用说明卡片
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.p12),
                        child: _UsageGuideCard(),
                      );
                    }
                    // 后续显示周期记账卡片
                    final recurring = recurringTransactions[index - 1];
                    return _RecurringTransactionCard(recurring: recurring);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addRecurringTransaction(BuildContext context, WidgetRef ref) async {
    final result = await context.pushNamed<bool>(
      Routes.recurringTransactionEdit,
    );
    // 如果返回 true，表示数据已更改，强制刷新列表
    if (result == true) {
      ref.invalidate(recurringTransactionDisplaysProvider);
    }
  }
}

class _RecurringTransactionCard extends ConsumerStatefulWidget {
  final RecurringTransactionDisplay recurring;

  const _RecurringTransactionCard({required this.recurring});

  @override
  ConsumerState<_RecurringTransactionCard> createState() =>
      _RecurringTransactionCardState();
}

class _RecurringTransactionCardState
    extends ConsumerState<_RecurringTransactionCard> {
  /// 开关切换进行中标记:防止连点与切换期间重复提交。
  bool _toggling = false;

  RecurringTransactionDisplay get recurring => widget.recurring;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.p8),
      decoration: BoxDecoration(
        color: AppTokens.surface(context),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: AppTokens.isDark(context)
            ? Border.all(
                color: recurring.enabled
                    ? primaryColor.withValues(alpha: 0.3)
                    : AppTokens.border(context),
                width: 1,
              )
            : null,
        boxShadow: AppTokens.isDark(context) ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            final result = await context.pushNamed<bool>(
              Routes.recurringTransactionEdit,
              extra: recurring,
            );
            // 如果返回 true，表示数据已更改，强制刷新列表
            if (result == true) {
              ref.invalidate(recurringTransactionDisplaysProvider);
            }
          },
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.p12),
            child: Row(
              children: [
                // 左侧：类型指示条（全局仅支出模式）
                Container(
                  width: 3,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTokens.error(context),
                    borderRadius: BorderRadius.circular(AppDimens.radius4),
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                // 中间：信息区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 第一行：分类名称
                      Builder(
                        builder: (context) {
                          // 分类名走 FutureProvider.family 缓存,避免每次
                          // build 都为卡片重新发起数据库查询。
                          final categoryId = recurring.categoryId;
                          final categoryName = categoryId == null
                              ? null
                              : ref
                                    .watch(categoryByIdProvider(categoryId))
                                    .value
                                    ?.name;
                          return Text(
                            CategoryUtils.getDisplayName(categoryName, context),
                            style: AppTextTokens.strongTitle(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                          );
                        },
                      ),
                      const SizedBox(height: AppDimens.p4),
                      // 第二行：账本 + 频率 + 时间
                      Row(
                        children: [
                          // 账本
                          Builder(
                            builder: (context) {
                              final ledgerName =
                                  ref
                                      .watch(
                                        ledgerByIdProvider(recurring.ledgerId),
                                      )
                                      .value
                                      ?.name ??
                                  '';
                              return Text(
                                ledgerName,
                                style: AppTextTokens.label(context).copyWith(
                                  color: AppTokens.textTertiary(context),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.p4,
                            ),
                            child: Text(
                              '·',
                              style: AppTextTokens.label(context).copyWith(
                                color: AppTokens.textTertiary(context),
                              ),
                            ),
                          ),
                          // 频率
                          Text(
                            _getFrequencyDescription(context),
                            style: AppTextTokens.label(
                              context,
                            ).copyWith(color: AppTokens.textTertiary(context)),
                          ),
                          // 下次生成时间（如果有）
                          if (recurring.lastGeneratedDate != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.p4,
                              ),
                              child: Text(
                                '·',
                                style: AppTextTokens.label(context).copyWith(
                                  color: AppTokens.textTertiary(context),
                                ),
                              ),
                            ),
                            Icon(AppIcons.clock, size: 11, color: primaryColor),
                            const SizedBox(width: 3),
                            Text(
                              DateFormat.Md().format(
                                recurring.lastGeneratedDate!,
                              ),
                              style: AppTextTokens.label(
                                context,
                              ).copyWith(color: primaryColor),
                            ),
                          ],
                        ],
                      ),
                      // 备注（如果有）
                      if (recurring.note != null &&
                          recurring.note!.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.p4),
                        Text(
                          recurring.note!,
                          style: AppTextTokens.caption(
                            context,
                          ).copyWith(color: AppTokens.textSecondary(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                // 右侧：金额 + 开关
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 金额（decimal 字符串 → double 展示）
                    AmountText(
                      value: recurring.txType == 'expense'
                          ? -double.parse(recurring.amount)
                          : double.parse(recurring.amount),
                      signed: true,
                      style: AppTextTokens.boldTitle(context).copyWith(
                        color: recurring.txType == 'expense'
                            ? AppTokens.error(context)
                            : AppTokens.success(context),
                      ),
                    ),
                    const SizedBox(height: AppDimens.p4),
                    // 开关
                    Transform.scale(
                      scale: 0.65,
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: recurring.enabled,
                        onChanged: _toggling
                            ? null
                            : (value) async {
                                await _toggle(value);
                              },
                        activeThumbColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 频率展示文案:间隔为 1 时用「每天/每周/…」,否则用「每 N 天/…」。
  String _getFrequencyDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frequency = RecurringFrequency.fromString(recurring.frequency);
    final interval = recurring.interval;

    if (interval == 1) {
      switch (frequency) {
        case RecurringFrequency.daily:
          return l10n.recurringTransactionDaily;
        case RecurringFrequency.weekly:
          return l10n.recurringTransactionWeekly;
        case RecurringFrequency.monthly:
          return l10n.recurringTransactionMonthly;
        case RecurringFrequency.yearly:
          return l10n.recurringTransactionYearly;
      }
    } else {
      switch (frequency) {
        case RecurringFrequency.daily:
          return l10n.recurringTransactionEveryNDays(interval);
        case RecurringFrequency.weekly:
          return l10n.recurringTransactionEveryNWeeks(interval);
        case RecurringFrequency.monthly:
          return l10n.recurringTransactionEveryNMonths(interval);
        case RecurringFrequency.yearly:
          return l10n.recurringTransactionEveryNYears(interval);
      }
    }
  }

  /// 切换周期账单开关。
  ///
  /// 写库成功后立即失效列表流并等待刷新，确保界面反映持久化结果；
  /// 失败时保持原开关状态并用 toast 提示。
  Future<void> _toggle(bool value) async {
    if (_toggling) return;
    setState(() => _toggling = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(transactionActionsProvider)
          .toggleRecurring(recurring.id, value);
      logger.debug('Recurring', '周期账单开关已切换 id=${recurring.id} enabled=$value');
      // 失效后等待数据流首帧,确保列表刷新完成,再收尾。
      ref.invalidate(recurringTransactionDisplaysProvider);
      await ref.read(recurringTransactionDisplaysProvider.future);
    } catch (e, st) {
      logger.warning(
        'Recurring',
        '周期账单开关切换失败 id=${recurring.id} enabled=$value',
        '$e\n$st',
      );
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _toggling = false);
      }
    }
  }
}

/// 使用说明卡片
class _UsageGuideCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SectionCard(
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info, size: AppDimens.icon20, color: primaryColor),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recurringTransactionUsageTitle,
                  style: AppTextTokens.strongTitle(
                    context,
                  ).copyWith(color: AppTokens.textPrimary(context)),
                ),
                const SizedBox(height: AppDimens.p4),
                Text(
                  l10n.recurringTransactionUsageContent,
                  style: AppTextTokens.label(context).copyWith(
                    color: AppTokens.textSecondary(context),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
