import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/selectable_card.dart';
import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'section_card.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 本列表的存储分区标题，与本概览卡片保持同一横向边距。
class BookSectionTitle extends StatelessWidget {
  /// 分区名称由业务提供。
  const BookSectionTitle({super.key, required this.title});

  final String title;

  /// 分区标题共用全局区块组件和账本列表留白。
  @override
  Widget build(BuildContext context) => SectionTitle(
    title: title,
    padding: const EdgeInsets.fromLTRB(
      AppDimens.p12,
      AppDimens.p8,
      AppDimens.p12,
      AppDimens.p8,
    ),
  );
}

/// 本列表的分区空态保留简短说明，不挤占另一分区的内容。
class BookSectionEmpty extends StatelessWidget {
  /// 可选操作用于本列表明确提供的创建入口。
  const BookSectionEmpty({super.key, required this.text, this.action});

  final String text;
  final Widget? action;

  /// 空态与分区标题对齐，操作按钮按现有列表规范排列。
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppDimens.p12,
      AppDimens.p4,
      AppDimens.p12,
      AppDimens.p12,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text, style: AppTextTokens.label(context)),
        if (action != null) ...[const SizedBox(height: AppDimens.p8), action!],
      ],
    ),
  );
}

/// 账本与日子本共用的概览卡片，业务状态和统计内容由所属功能提供。
class BookOverviewCard extends StatelessWidget {
  /// 统一标题、选中角标和右下角编辑入口的布局。
  const BookOverviewCard({
    super.key,
    required this.title,
    required this.child,
    this.headerActions = const [],
    this.notice,
    this.selected = false,
    this.compact = false,
    this.onTap,
    this.onEdit,
    this.editTooltip,
  });

  final String title;
  final Widget child;
  final List<Widget> headerActions;
  final Widget? notice;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final String? editTooltip;

  /// 卡片点击与编辑按钮分开响应，选中角标只作装饰。
  @override
  Widget build(BuildContext context) => SectionCard(
    onTap: onTap,
    selected: selected,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.symmetric(
      horizontal: AppDimens.p12,
      vertical: AppDimens.p4,
    ),
    child: Stack(
      children: [
        Padding(
          padding: compact
              ? EdgeInsets.fromLTRB(
                  AppDimens.p12,
                  AppDimens.p12,
                  onEdit == null
                      ? AppDimens.p12
                      : AppDimens.p12 + AppDimens.p40,
                  AppDimens.p12,
                )
              : const EdgeInsets.all(AppDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: AppTextTokens.boldTitle(context)),
                  ),
                  ...headerActions,
                ],
              ),
              if (notice != null) ...[
                const SizedBox(height: AppDimens.p8),
                notice!,
              ],
              SizedBox(height: compact ? AppDimens.p4 : AppDimens.p12),
              child,
            ],
          ),
        ),
        if (onEdit != null)
          Positioned(
            right: AppDimens.p4,
            bottom: AppDimens.p4,
            child: IconButton(
              onPressed: onEdit,
              tooltip: editTooltip,
              icon: const Icon(AppIcons.edit, size: AppDimens.icon20),
              style: IconButton.styleFrom(
                foregroundColor: AppTokens.iconSecondary(context),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (selected) const SelectableCardCheckBadge(),
      ],
    ),
  );
}
