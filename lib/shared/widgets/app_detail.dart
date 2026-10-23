import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'app_sheet.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 只读详情共用弹层骨架、首部分割和常驻底部操作区。
class AppDetailSheet extends StatelessWidget {
  const AppDetailSheet({
    super.key,
    required this.header,
    required this.children,
    required this.footer,
  });

  final Widget header;
  final List<Widget> children;
  final Widget footer;

  /// 内容超出可用高度时独立滚动，底部操作始终留在弹层内。
  @override
  Widget build(BuildContext context) => AppSheet(
    footer: footer,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: AppDimens.p12),
          AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
          ...children,
        ],
      ),
    ),
  );
}

/// 详情弹层共用图标、标题、副标题和右侧删除入口。
class AppDetailHeader extends StatelessWidget {
  /// 业务可为图标指定语义底色，标题、删除入口与布局统一维护。
  const AppDetailHeader({
    super.key,
    required this.icon,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    required this.onDelete,
  });

  final Widget icon;

  /// 分类等业务图标的底色，空值时使用通用明细背景。
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Future<void> Function() onDelete;

  /// 标题和副标题允许换行，确保系统大字号仍可读取完整记录名称。
  @override
  Widget build(BuildContext context) => Row(
    children: [
      DetailListIcon(
        size: AppDimens.p36,
        backgroundColor: iconBackgroundColor,
        child: icon,
      ),
      const SizedBox(width: AppDimens.p12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextTokens.strongTitle(
                context,
              ).copyWith(color: AppTokens.textPrimary(context)),
            ),
            if (subtitle?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.p4),
                child: Text(
                  subtitle!,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(color: AppTokens.textSecondary(context)),
                ),
              ),
          ],
        ),
      ),
      IconButton(
        onPressed: onDelete,
        icon: Icon(
          AppIcons.delete,
          size: AppDimens.icon20,
          color: AppTokens.error(context),
        ),
        constraints: const BoxConstraints(
          minWidth: AppDimens.p32,
          minHeight: AppDimens.p32,
        ),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        tooltip: AppLocalizations.of(context).commonDelete,
      ),
    ],
  );
}

/// 详情信息统一使用左侧次要标签和右侧主要内容，长值可完整换行。
class AppDetailInfoRow extends StatelessWidget {
  const AppDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final int? maxLines;

  /// 标签最多占半行，其余宽度留给右侧内容，避免短标签也挤占半行。
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
            child: Text(
              label,
              style: AppTextTokens.body(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  valueWidget ??
                  Text(
                    value,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: AppTokens.textPrimary(context)),
                    textAlign: TextAlign.right,
                    maxLines: maxLines,
                    overflow: maxLines == null ? null : TextOverflow.ellipsis,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
