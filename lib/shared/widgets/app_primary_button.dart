import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 全宽主操作统一继承按钮主题，忙碌时保留文案并阻止重复触发。
class AppPrimaryButton extends StatelessWidget {
  /// 业务层负责异步操作与错误反馈，按钮只呈现当前可用状态。
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool fullWidth;

  /// 进度指示器占用固定位置，长文案允许换行，加载时保持按钮名称可读。
  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: busy ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            SizedBox.square(
              dimension: AppDimens.icon20,
              child: CircularProgressIndicator(
                strokeWidth: AppDimens.progressStrokeWidth,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppDimens.p8),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 页面底部操作区统一留白与安全区，按钮状态由表单提供。
class AppEditorFooter extends StatelessWidget {
  /// 页面只传入动作和状态，底部系统区域由操作区处理。
  const AppEditorFooter({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  /// 外层已处理安全区时 SafeArea 自动消除重复底部留白。
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(AppDimens.p16),
      child: AppPrimaryButton(label: label, onPressed: onPressed, busy: busy),
    ),
  );
}
