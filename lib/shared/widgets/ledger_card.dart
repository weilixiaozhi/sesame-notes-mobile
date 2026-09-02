/// 账本卡片组件
///
/// 展示账本基本信息，同步状态通过 syncStatusProvider 单独获取
library;

import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/presentation/format_utils.dart';
import 'currency_flag.dart';
import 'format_money.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 账本卡片
class LedgerCard extends ConsumerWidget {
  final LedgerDisplayItem ledger;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 右下角编辑按钮回调 —— 与 [onLongPress] 调同一个入口（进入编辑二级页面）。
  /// 长按是不可发现的手势,必须有一个可见的等价入口。
  final VoidCallback? onMore;
  final bool selected;

  const LedgerCard({
    super.key,
    required this.ledger,
    this.onTap,
    this.onLongPress,
    this.onMore,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    // 同步状态/上传中信号：随新同步层接入后恢复；当前统一视为未同步。
    final isUploading = false;
    final isSynced = false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p4,
        ),
        decoration: BoxDecoration(
          color: AppTokens.surface(context),
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: AppTokens.isDark(context)
              ? Border.all(color: AppTokens.border(context), width: 1)
              : null,
          boxShadow: AppTokens.isDark(context)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          child: Stack(
            children: [
              // 左侧色条：仅选中时显示
              if (selected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimens.radius12),
                        bottomLeft: Radius.circular(AppDimens.radius12),
                      ),
                    ),
                  ),
                ),

              // 底层：账本信息（始终显示）
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部：名称 + 状态图标
                    Row(
                      children: [
                        // 账本名称
                        // 裸 RichText 默认 textScaler 为 noScaling（不随系统/全局缩放），
                        // 显式透传 MediaQuery 的 textScaler，使账本名随全局 0.85 一同缩小。
                        Expanded(
                          child: RichText(
                            textScaler: MediaQuery.textScalerOf(context),
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: translateLedgerName(
                                    context,
                                    ledger.name,
                                  ),
                                  style: AppTextTokens.boldTitle(context)
                                      .copyWith(
                                        color: AppTokens.textPrimary(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 共享账本角标 + 成员数,图标与成员管理入口保持一致
                        if (ledger.isShared) ...[
                          const SizedBox(width: AppDimens.p4),
                          Icon(
                            AppIcons.people,
                            size: AppDimens.icon12,
                            color: primaryColor,
                          ),
                          const SizedBox(width: AppDimens.p4),
                          Text(
                            '${ledger.memberCount}',
                            style: AppTextTokens.label(
                              context,
                            ).copyWith(color: primaryColor),
                          ),
                        ],

                        const SizedBox(width: AppDimens.p8),

                        // 状态图标
                        _buildStatusIcon(context, ref, isSynced, isUploading),
                      ],
                    ),

                    const SizedBox(height: AppDimens.p12),

                    // 统计数据（本地和远程都显示）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 币种：全局统一「ISO + (符号)」展示
                        Row(
                          children: [
                            Text(
                              '${l10n.ledgersCurrency}：',
                              style: AppTextTokens.body(context).copyWith(
                                color: AppTokens.textSecondary(context),
                              ),
                            ),
                            currencyFlagLabel(
                              context,
                              ledger.currency,
                              textStyle: AppTextTokens.body(context).copyWith(
                                color: AppTokens.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.p4),
                        // 记账笔数
                        Text(
                          l10n.ledgersRecords('${ledger.transactionCount}'),
                          style: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.textSecondary(context)),
                        ),
                        const SizedBox(height: AppDimens.p4),
                        // 支出：账本累计支出总额（数据即 expenseTotal；中性显示，不取负、不染色）
                        Text(
                          l10n.ledgersExpense(
                            // 符号+金额统一走唯一来源 formatMoneyWithCurrency
                            formatMoneyWithCurrency(
                              ledger.expenseTotal,
                              currencyCode: ledger.currency,
                            ),
                          ),
                          style: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.textPrimary(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 右下角编辑按钮(进入编辑二级页面)
              if (onMore != null)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: IconButton(
                    onPressed: onMore,
                    tooltip: l10n.ledgersEdit,
                    icon: Icon(
                      AppIcons.edit,
                      size: AppDimens.icon20,
                      color: AppTokens.iconSecondary(context),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 状态图标
  ///
  /// 图标策略(UI 不判断具体后端实现,只认两个输入):
  /// 1. 账本归属 storage_mode → 是否画"云"图标;
  /// 2. 激活后端枚举 → 画哪种云:Sesame Notes Cloud=cloudy,其它云后端=database。
  /// 颜色语义:绿=已同步,红=未同步/有备份但当前未配置云,灰=纯本地。
  ///
  /// 为什么用 storage_mode 判断云图标:归属模型下用户可以把云端账本移回本地,
  /// 此时 syncId 已清空;反过来也存在"标了 cloud 但 syncId 还没补上"的中间态。
  /// 判断"这本账会不会同步"的唯一权威是 storage_mode,图标必须跟它保持一致,
  /// 否则用户看到云图标却发现根本不同步。
  Widget _buildStatusIcon(
    BuildContext context,
    WidgetRef ref,
    bool isSynced,
    bool isUploading,
  ) {
    // 优先显示上传中状态
    if (isUploading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    // 云端账本:恒为云形图标（快照备份型后端的状态显示随备份功能重建）。
    if (ledger.isCloudLedger) {
      // 已同步：在线绿；其余（未同步 / 有备份但云状态脱钩）统一离线灰。
      final color = isSynced
          ? AppTokens.statusOnline(context)
          : AppTokens.statusOffline(context);
      return Icon(AppIcons.cloudQueue, color: color, size: AppDimens.icon20);
    }

    // 纯本地账本(storage_mode='local'):默认灰色硬盘图标表达"纯本地无备份"。
    return const Icon(
      AppIcons.localStorage,
      color: AppTokens.brandLocal,
      size: AppDimens.icon20,
    );
  }
}
