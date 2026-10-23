import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

class AppListTile extends StatelessWidget {
  final IconData? leading;
  final Widget? leadingWidget;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;
  final int? titleMaxLines;
  final int? subtitleMaxLines;
  const AppListTile({
    super.key,
    this.leading,
    this.leadingWidget,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.trailing,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ListTileTheme.of(context);
    final titleStyle = theme.titleTextStyle ?? AppTextTokens.body(context);
    final subStyle = theme.subtitleTextStyle ?? AppTextTokens.label(context);
    final tile = Padding(
      // 行垂直内边距走行距体系 token，与分割线呼吸距共同决定行间距
      padding: const EdgeInsets.symmetric(vertical: AppDimens.tileRowVertical),
      child: Row(
        children: [
          if (leadingWidget != null || leading != null) ...[
            leadingWidget ??
                Container(
                  width: AppDimens.p36,
                  height: AppDimens.p36,
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
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: titleMaxLines,
                  overflow: titleMaxLines == null
                      ? null
                      : TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: subStyle,
                    maxLines: subtitleMaxLines,
                    overflow: subtitleMaxLines == null
                        ? null
                        : TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          // 只读信息不展示跳转提示，调用方提供的状态或操作独立保留。
          else if (enabled && onTap != null)
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

/// 设置开关行复用普通设置行的排版，整行点击与开关操作保持一致。
class AppSwitchTile extends StatelessWidget {
  /// 图标可选，业务负责状态持久化和异步期间的禁用。
  const AppSwitchTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final IconData? leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool compact;

  /// 合并行标题与开关的辅助功能语义，避免同一设置被重复朗读。
  @override
  Widget build(BuildContext context) {
    final control = Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // 紧凑开关贴齐缩放锚点，右侧可见边缘与设置值对齐。
      padding: compact ? EdgeInsets.zero : null,
    );
    return MergeSemantics(
      child: AppListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        titleMaxLines: null,
        subtitleMaxLines: null,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: compact
            ? Transform.scale(
                key: const ValueKey('compact-switch'),
                scale: AppDimens.compactSwitchScale,
                alignment: AlignmentDirectional.centerEnd.resolve(
                  Directionality.of(context),
                ),
                // 缩放只影响绘制，保留整行和开关原有热区，右侧边缘保持固定。
                transformHitTests: false,
                child: control,
              )
            : control,
      ),
    );
  }
}
