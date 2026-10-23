import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';

/// 分类和日子表单共用标题、输入卡片及区块间距。
class AppFormSection extends StatelessWidget {
  /// 业务字段只提供标题和内容，视觉规格由通用区块统一承载。
  const AppFormSection({
    super.key,
    this.title,
    required this.child,
    this.disabled = false,
    this.compact = false,
    this.trailing,
    this.titleTrailing,
  });

  final String? title;
  final Widget child;
  final bool disabled;
  final bool compact;
  final Widget? trailing;
  final Widget? titleTrailing;

  /// 标题位于卡片外，字段之间保留统一留白。
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (title != null) ...[
        SectionTitle(
          title: title!,
          disabled: disabled,
          trailing: trailing,
          titleTrailing: titleTrailing,
        ),
        const SizedBox(height: AppDimens.p8),
      ],
      SectionCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(compact ? AppDimens.p8 : AppDimens.p16),
        child: child,
      ),
      SizedBox(height: compact ? AppDimens.p8 : AppDimens.p16),
    ],
  );
}

/// 分类所属项、日期和规则选择共用的灰底输入行。
class AppSelectionField extends StatelessWidget {
  /// 主副标题允许自然换行，禁用状态同时收起箭头和点击行为。
  const AppSelectionField({
    super.key,
    this.title,
    this.child,
    this.subtitle,
    this.enabled = true,
    this.onTap,
    this.isPlaceholder = false,
    this.suffix,
  }) : assert((title == null) != (child == null));

  final String? title;
  final Widget? child;
  final String? subtitle;
  final bool isPlaceholder;
  final Widget? suffix;
  final bool enabled;
  final VoidCallback? onTap;

  /// 复用分类选择框的触达区域、填充、文字和箭头规格。
  @override
  Widget build(BuildContext context) => AppInputSurface(
    enabled: enabled,
    onTap: onTap,
    child: Row(
      children: [
        Expanded(
          child:
              child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    style: AppTextTokens.input(context).copyWith(
                      color: !enabled
                          ? AppTokens.textDisabled(context)
                          : isPlaceholder
                          ? AppTokens.textTertiary(context)
                          : AppTokens.textPrimary(context),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimens.p4),
                      child: Text(
                        subtitle!,
                        style: AppTextTokens.label(context).copyWith(
                          color: enabled
                              ? AppTokens.textSecondary(context)
                              : AppTokens.textDisabled(context),
                        ),
                      ),
                    ),
                ],
              ),
        ),
        ?suffix,
        if (suffix == null && enabled && onTap != null) ...[
          const SizedBox(width: AppDimens.p8),
          Icon(
            AppIcons.chevronRight,
            color: AppTokens.iconTertiary(context),
            size: AppDimens.icon16,
          ),
        ],
      ],
    ),
  );
}

/// 所有点击型输入共用主题形状和点击区域，字段只负责内部内容。
class AppInputSurface extends StatelessWidget {
  const AppInputSurface({
    super.key,
    required this.child,
    this.enabled = true,
    this.onTap,
  });
  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    customBorder:
        (enabled
            ? InputDecorationTheme.of(context).enabledBorder
            : InputDecorationTheme.of(context).disabledBorder) ??
        InputDecorationTheme.of(context).border,
    child: InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        constraints: const BoxConstraints(
          minHeight: AppDimens.actionButtonMinHeight,
        ),
      ),
      child: child,
    ),
  );
}
