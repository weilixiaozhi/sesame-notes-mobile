import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/dimens.dart';

/// 内容选择与预览弹窗：统一左侧标题、内容留白和右侧操作按钮。
class AppContentDialog extends StatelessWidget {
  /// 创建内容弹窗；长内容滚动时保留标题和底部操作。
  const AppContentDialog({
    super.key,
    required this.title,
    this.icon,
    required this.content,
    required this.actions,
    this.expandContent = false,
    this.minContentHeight = 0,
  });

  final String title;
  final IconData? icon;
  final Widget content;
  final List<Widget> actions;
  final bool expandContent;
  final double minContentHeight;

  /// 按配置选择弹窗的尺寸规范构建可滚动内容区域。
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: AppDimens.p8),
                  ],
                  Expanded(
                    child: Semantics(
                      namesRoute: true,
                      header: true,
                      child: Text(
                        title,
                        style: DialogTheme.of(context).titleTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: expandContent ? FlexFit.tight : FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minContentHeight),
                  child: DefaultTextStyle.merge(
                    style: DialogTheme.of(context).contentTextStyle,
                    child: content,
                  ),
                ),
              ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                // 普通宽度保持右对齐同行，空间不足时由原生布局把操作完整竖排。
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  overflowAlignment: OverflowBarAlignment.end,
                  spacing: AppDimens.p12,
                  overflowSpacing: AppDimens.p12,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
