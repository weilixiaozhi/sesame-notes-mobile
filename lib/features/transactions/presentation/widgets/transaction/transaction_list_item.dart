import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models.dart' show LedgerMemberDisplay;
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/collaborator_avatar.dart';
import 'package:sesame_notes/shared/widgets/amount_text.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 交易行支持账单与分类明细两种展示，数据、图标操作及协作信息共用。
/// 账单主行优先备注，次行展示分类路径；默认模式保留分类主行与备注次行。
class TransactionListItem extends ConsumerWidget {
  /// 折算副行只读取交易所属账本，首页选本变化不改变历史快照的币种。
  final String ledgerId;

  /// 首页账单使用备注主行和中性金额，其他内页保持既有布局。
  final bool billPresentation;

  /// 平铺账单可由页面统一提供边距，其他列表保持默认行内留白。
  final double horizontalPadding;

  /// 账单次行的完整分类路径，由调用方按当前账本解析。
  final String? categoryPath;

  /// AA 徽标由账本开关和交易分摊模式共同决定，不以共享账本判断。
  final bool participatesInAa;
  final db.CategoryDisplay? category; // 可选的分类对象，用于显示自定义图标
  final String title;

  /// 交易金额:规范化 Decimal 字符串(单位:元)。
  final String amount;

  /// 多币种:交易原币种(null/等于账本本位币 → 维持无符号纯数字;
  /// 外币 → 金额前显示其币种符号,如 JP¥/US$,一眼区分原币)。
  final String? currencyCode;

  /// 多币种:折账本本位币快照(Decimal 字符串)。外币交易在金额右下角显示 ≈ 折算小字。
  final String? nativeAmount;
  final VoidCallback? onTap;
  final VoidCallback? onCategoryTap; // 点击分类图标/名称的回调
  final String? categoryName; // 分类名称，用于显示
  final DateTime? happenedAt; // 交易时间，用于显示时分

  // 批量选择模式相关
  final bool isSelectionMode; // 是否处于选择模式
  final bool isSelected; // 是否被选中
  final VoidCallback? onSelectionChanged; // 选中状态改变回调
  final bool showFullDate; // 是否显示完整日期（年-月-日 时:分）

  /// 最后编辑时间。列表项第二行 HH:mm 优先读本字段(语义"最后编辑时分")，
  /// 为 null 时回退 [happenedAt]。
  final DateTime? lastEditedAt;

  /// 共享账本成员表(用于解析协作头像)。非 null 即表示共享账本,
  /// 第二行展示真实头像 + 创建人/编辑人重叠(与详情页一致)。
  /// null = 单人账本或不展示头像。
  final Map<String, LedgerMemberDisplay>? collaboratorMap;

  /// 交易创建人 userId(来自 Transaction.createdByUserId)。
  final String? creatorUserId;

  /// 交易最后编辑人 userId(来自 Transaction.lastEditedByUserId)。
  final String? editorUserId;

  /// 是否为共享账本。仅共享账本渲染协作头像;非共享账本(单人账本)不渲染。
  final bool isShared;

  const TransactionListItem({
    super.key,
    required this.ledgerId,
    this.category,
    required this.title,
    required this.amount,
    this.currencyCode,
    this.nativeAmount,
    this.onTap,
    this.onCategoryTap,
    this.categoryName,
    this.happenedAt,
    this.lastEditedAt,
    this.collaboratorMap,
    this.creatorUserId,
    this.editorUserId,
    this.isShared = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.showFullDate = false,
    this.billPresentation = false,
    this.horizontalPadding = AppDimens.p12,
    this.categoryPath,
    this.participatesInAa = false,
  });

  /// 账本信息未确认时不猜测本位币，原币金额仍可正常显示。
  bool _isForeign(String? base) {
    final cc = currencyCode;
    if (cc == null || cc.isEmpty || base == null) return false;
    return cc.toUpperCase() != base.toUpperCase();
  }

  /// 第二行时间源:优先 lastEditedAt(最后编辑时分),回退 happenedAt(记账时间)。
  /// 列表项第二行的 HH:mm 语义是「最后编辑时间」,但创建后从未编辑的记录
  /// lastEditedAt 为 null,此时用记账时间兜底,保证每条记录都有时分可展示。
  DateTime? get _effectiveTime => (lastEditedAt ?? happenedAt)?.toLocal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayTitle = billPresentation && title.trim().isNotEmpty
        ? title.trim()
        : categoryName ?? title;
    return DetailListItem(
      horizontalPadding: horizontalPadding,
      onTap: isSelectionMode ? onSelectionChanged : onTap,
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onSelectionChanged?.call(),
            )
          : DetailListIcon(
              onTap: onCategoryTap,
              backgroundColor: AppTokens.surfaceCategoryIcon(context),
              child: CategoryIconWidget(
                category: category,
                size: AppDimens.icon20,
              ),
            ),
      title: displayTitle,
      titleWidget: billPresentation ? _billTitle(context, displayTitle) : null,
      subtitle: _buildSecondLine(context),
      trailing: DetailListValues(
        // 主金额:显示交易原币种 + 原金额(用户记账时选的币种和输入的金额)。
        // 设计意图:记账时的币种和金额不受其他币种组件影响,
        // 账本币种仅作为汇率换算基准。
        // 金额为 Decimal 字符串(单位:元),直接解析,无需再 /100。
        value: AmountText(
          value: -double.parse(amount),
          signed: true,
          showCurrency: true,
          currencyCode: currencyCode,
          style: billPresentation
              ? AppTextTokens.body(context).copyWith(
                  color: AppTokens.textPrimary(context),
                  fontWeight: FontWeight.w600,
                )
              : AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.error(context)),
        ),
        // 副行:外币交易时显示折算到账本本位币的结果(≈ 本位币金额)。
        // 仅当交易币种≠账本本位币且折算值≠原金额时展示(逻辑兜底:
        // 账本币种=记账币种时无需换算)。
        secondary: Builder(
          builder: (context) {
            // 没有折算副行时不额外查询账本，普通本币列表保持现有读取成本。
            if (nativeAmount == null || amount == nativeAmount) {
              return const SizedBox.shrink();
            }
            final ledgerCurrency = ref
                .watch(ledgerDisplayByIdProvider(ledgerId))
                .value
                ?.currency;
            if (!_isForeign(ledgerCurrency)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppDimens.p4),
              child: Text(
                '≈ ${getCurrencySymbol(ledgerCurrency!)} ${double.parse(nativeAmount ?? amount).toStringAsFixed(2)}',
                style: AppTextTokens.caption(
                  context,
                ).copyWith(color: AppTokens.textTertiary(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 备注占用可用宽度，AA 徽标保持完整，不挤掉金额或图标点击区域。
  Widget _billTitle(BuildContext context, String value) => Row(
    children: [
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTokens.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      if (participatesInAa) ...[
        const SizedBox(width: AppDimens.p4),
        DetailListTag(
          label: 'AA',
          foregroundColor: AppTokens.primary(context),
          backgroundColor: AppTokens.domainAccentBackground(context),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p4,
            vertical: AppDimens.selectionBadgeGap,
          ),
        ),
      ],
    ],
  );

  /// 账单次行显示分类路径，其他场景显示备注；协作头像、时间及排除标记完整保留。
  Widget _buildSecondLine(BuildContext context) {
    final parts = <Widget>[];

    // 账单把分类路径放在次行，分类明细等页面仍把备注作为补充信息。
    final note = billPresentation
        ? categoryPath ?? categoryName
        : (categoryName != null && title.isNotEmpty && title != categoryName)
        ? title
        : null;
    if (note != null && note.isNotEmpty) {
      parts.add(Text(note, maxLines: 1, overflow: TextOverflow.ellipsis));
    }

    // 时间部分
    final time = _effectiveTime;
    if (time != null) {
      String timeText;
      if (showFullDate) {
        // 完整日期模式(年-月-日 时:分),用于非首页场景
        timeText =
            '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (time.hour != 0 || time.minute != 0 || time.second != 0) {
        // HH:mm(列表项时分格式)
        timeText =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        timeText = '';
      }
      if (timeText.isNotEmpty) {
        // 时间文本在共享/非共享账本均展示,不受 isShared 影响。
        final timeWidget = Text(
          timeText,
          style: AppTextTokens.dateSecondary(context),
        );
        if (isShared) {
          // 仅共享账本渲染协作头像:collaboratorMap == null 表示成员表尚未加载,
          // 传 membersLoading 让组件先显示默认头像占位，数据到位后再切真实头像。
          final isMembersLoading = collaboratorMap == null;
          final creator = (!isMembersLoading && creatorUserId != null)
              ? collaboratorMap![creatorUserId]
              : null;
          final editor = (!isMembersLoading && editorUserId != null)
              ? collaboratorMap![editorUserId]
              : null;
          parts.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CollaboratorAvatarGroup(
                  creator: creator,
                  editor: editor,
                  creatorUserId: creatorUserId,
                  editorUserId: editorUserId,
                  radius: 9,
                  membersLoading: isMembersLoading,
                ),
                const SizedBox(width: AppDimens.p4),
                timeWidget,
              ],
            ),
          );
        } else {
          // 单人/本地账本:只渲染时间,不渲染协作头像(避免出现空占位圆)。
          parts.add(timeWidget);
        }
      }
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    // 用 · 连接各部分(头像+时间作为一组,不拆分)
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
            child: Text(
              '·',
              style: AppTextTokens.caption(
                context,
              ).copyWith(color: AppTokens.textTertiary(context)),
            ),
          ),
        );
      }
      children.add(parts[i]);
    }

    return DetailListSubtitle(
      child: Wrap(
        spacing: 0,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
