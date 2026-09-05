import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

class AppListTile extends StatelessWidget {
  final IconData leading;
  final Widget? leadingWidget;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;
  const AppListTile({
    super.key,
    required this.leading,
    this.leadingWidget,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // 标题走 body 14px：设置行主标题比通用列表标题小一档，更紧凑
    final titleStyle = AppTextTokens.body(
      context,
    ).copyWith(color: AppTokens.textPrimary(context)); // ⭐ 使用 Token
    final subStyle = AppTextTokens.label(
      context,
    ).copyWith(color: AppTokens.textSecondary(context)); // ⭐ 使用 Token
    final tile = Padding(
      // 行垂直内边距走行距体系 token，与分割线呼吸距共同决定行间距
      padding: const EdgeInsets.symmetric(vertical: AppDimens.tileRowVertical),
      child: Row(
        children: [
          leadingWidget ??
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leading,
                  size: AppDimens.icon22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: subStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (enabled)
            Icon(
              AppIcons.chevronRight,
              size: AppDimens.icon20,
              color: AppTokens.iconTertiary(context),
            ), // ⭐ 使用 Token
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(onTap: enabled ? onTap : null, child: tile),
    );
  }
}
