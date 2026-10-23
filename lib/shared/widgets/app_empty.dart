import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'app_pull_to_refresh.dart';

/// 空态内容共用提示、图标和操作区，业务只提供文案与已有交互。
class AppEmpty extends StatelessWidget {
  final String? text;
  final String? subtext;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  /// 页面使用标准留白，内嵌卡片可交由外层提供间距。
  const AppEmpty({
    super.key,
    this.text,
    this.subtext,
    this.icon,
    this.action,
    this.padding = const EdgeInsets.all(AppDimens.p20),
  });

  /// 内容超出剩余高度时可滚动，短内容居中且不接管外层主滚动控制器。
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        primary: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppDimens.icon28,
                  color: AppTokens.iconTertiary(context),
                ),
                const SizedBox(height: AppDimens.p8),
              ],
              Text(
                text ?? AppLocalizations.of(context).commonEmpty,
                textAlign: TextAlign.center,
                style: AppTextTokens.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtext != null) ...[
                const SizedBox(height: AppDimens.p4),
                Text(
                  subtext!,
                  textAlign: TextAlign.center,
                  style: AppTextTokens.label(context),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppDimens.p12),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 空列表占满可视区域居中显示，同时保留下拉刷新手势。
class ScrollableEmpty extends StatelessWidget {
  const ScrollableEmpty({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: AppPullToRefresh.physics,
      child: SizedBox(height: constraints.maxHeight, child: child),
    ),
  );
}

/// 加载失败共用错误图标、友好提示和重试按钮，列表可保留下拉入口。
class AppLoadError extends StatelessWidget {
  /// 重试文案可由业务指定，空回调显示禁用按钮，内嵌时可复用外层留白。
  const AppLoadError({
    super.key,
    required this.onRetry,
    this.message,
    this.scrollable = false,
    this.retryLabel,
    this.padding = const EdgeInsets.all(AppDimens.p20),
  });

  final VoidCallback? onRetry;
  final String? message;
  final bool scrollable;
  final String? retryLabel;
  final EdgeInsetsGeometry padding;

  /// 弹层和页面内联同一内容，列表模式只补充滚动能力。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = AppEmpty(
      padding: padding,
      icon: AppIcons.error,
      text: message ?? l10n.analyticsLoadFailed,
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(AppIcons.refresh, size: AppDimens.icon16),
        label: Text(retryLabel ?? l10n.commonRetry),
      ),
    );
    return scrollable
        ? ListView(
            physics: AppPullToRefresh.physics,
            padding: EdgeInsets.zero,
            children: [content],
          )
        : content;
  }
}
