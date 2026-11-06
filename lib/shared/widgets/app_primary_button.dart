import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
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
    this.destructive = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool fullWidth;

  /// 删除等破坏性操作使用主题错误底色，其余规格沿用主按钮主题。
  final bool destructive;

  /// 空闲时展示操作图标，忙碌时相同位置用于进度提示。
  final IconData? icon;

  /// 图标和进度占用同一位置，长文案允许换行，加载时保持按钮名称可读。
  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: busy ? null : onPressed,
      style: destructive
          ? FilledButton.styleFrom(backgroundColor: AppTokens.error(context))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            SizedBox.square(
              dimension: AppDimens.icon20,
              child: CircularProgressIndicator(
                strokeWidth: AppDimens.progressStrokeWidth,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else if (icon != null)
            Icon(icon, size: AppDimens.icon20),
          if (busy || icon != null) const SizedBox(width: AppDimens.p8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 次操作沿用描边按钮主题，与主操作共享文字和最小点击高度。
class AppSecondaryButton extends StatelessWidget {
  /// 图标与文案共用标准间距，调用方只决定动作和是否全宽。
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final IconData? icon;

  /// 文字可以自然换行，尺寸和文字规格来自已有公共规范。
  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppDimens.actionButtonMinHeight),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimens.icon20),
            const SizedBox(width: AppDimens.p8),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 主次操作共用等宽等高布局，较高的文案决定两边的实际点击高度。
class AppPairedActions extends StatelessWidget {
  /// 业务页面提供文案、图标、回调和忙碌状态，按钮规格统一维护。
  const AppPairedActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.primaryButtonKey,
    this.secondaryButtonKey,
    this.primaryIcon,
    this.secondaryIcon,
    this.busy = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final Key? primaryButtonKey;
  final Key? secondaryButtonKey;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;
  final bool busy;

  /// 横向均分可用宽度，文案放大或换行时两种原生按钮一起增高。
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AppSecondaryButton(
            key: secondaryButtonKey,
            label: secondaryLabel,
            icon: secondaryIcon,
            onPressed: busy ? null : onSecondaryPressed,
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        Expanded(
          child: AppPrimaryButton(
            key: primaryButtonKey,
            label: primaryLabel,
            icon: primaryIcon,
            onPressed: onPrimaryPressed,
            busy: busy,
          ),
        ),
      ],
    ),
  );
}

/// 页面底部操作区统一留白与安全区，按钮状态由表单提供。
class AppEditorFooter extends StatelessWidget {
  /// 页面只传入动作和状态，底部系统区域由操作区处理。
  const AppEditorFooter({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.primaryButtonKey,
    this.secondaryButtonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final Key? primaryButtonKey;
  final Key? secondaryButtonKey;

  /// 外层已处理安全区时 SafeArea 自动消除重复底部留白。
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(AppDimens.p16),
      child: secondaryLabel == null
          ? AppPrimaryButton(
              key: primaryButtonKey,
              label: label,
              onPressed: onPressed,
              busy: busy,
            )
          : AppPairedActions(
              primaryLabel: label,
              onPrimaryPressed: onPressed,
              secondaryLabel: secondaryLabel!,
              onSecondaryPressed: onSecondaryPressed,
              primaryButtonKey: primaryButtonKey,
              secondaryButtonKey: secondaryButtonKey,
              busy: busy,
            ),
    ),
  );
}
