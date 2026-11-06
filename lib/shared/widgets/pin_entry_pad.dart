import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'press_key.dart';
import 'pin_input_controller.dart';

/// 应用锁、PIN 设置和当前 PIN 验证共用输入主体。
class PinEntryPanel extends StatelessWidget {
  /// 页面持有输入资源和认证流程，面板只展示标题、圆点与按键。
  const PinEntryPanel({
    super.key,
    required this.title,
    required this.controller,
    required this.onNumberTap,
    this.leading,
    this.onBiometric,
  });

  final String title;
  final PinInputController controller;
  final ValueChanged<String> onNumberTap;
  final Widget? leading;
  final VoidCallback? onBiometric;

  /// 圆点监听草稿变化，安全区和页面头部由调用页面安排。
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Spacer(flex: 2),
      if (leading != null) ...[leading!, const SizedBox(height: AppDimens.p20)],
      Text(
        title,
        style: AppTextTokens.boldTitle(
          context,
        ).copyWith(color: AppTokens.textPrimary(context)),
      ),
      const SizedBox(height: AppDimens.p32),
      ListenableBuilder(
        listenable: controller,
        builder: (context, _) => _PinDotIndicator(
          filledCount: controller.length,
          isError: controller.hasError,
        ),
      ),
      const Spacer(flex: 1),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p40),
        child: _PinNumberPad(
          onNumberTap: onNumberTap,
          onDelete: controller.deleteDigit,
          onBiometric: onBiometric,
        ),
      ),
      const SizedBox(height: AppDimens.p32),
    ],
  );
}

/// PIN 码圆点展示固定长度与当前输入状态。
class _PinDotIndicator extends StatelessWidget {
  final int filledCount;
  final bool isError;

  /// 圆点仅接收位数和错误状态，不读取 PIN 内容。
  const _PinDotIndicator({required this.filledCount, required this.isError});

  /// 已填圆点使用实色，错误状态由主题错误色标示。
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(PinInputController.pinLength, (index) {
        final filled = index < filledCount;
        final dotSize = 14.0;
        final color = isError
            ? AppTokens.error(context)
            : (filled ? primaryColor : AppTokens.border(context));

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: AppDimens.p8),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        );
      }),
    );
  }
}

/// PIN 数字键盘固定保留生物识别、零和删除三个底行位置。
class _PinNumberPad extends StatelessWidget {
  final ValueChanged<String> onNumberTap;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  /// 生物识别回调可用时显示入口，否则保留相同键位占位。
  const _PinNumberPad({
    required this.onNumberTap,
    required this.onDelete,
    required this.onBiometric,
  });

  /// 数字和操作共用同一组圆形按键及行列间距。
  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'del'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimens.p4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key == 'bio') {
                return _buildKeyButton(
                  context,
                  child: onBiometric != null
                      ? Icon(
                          AppIcons.fingerprint,
                          size: AppDimens.icon28,
                          color: AppTokens.textPrimary(context),
                        )
                      : const SizedBox.shrink(),
                  onTap: onBiometric,
                );
              }
              if (key == 'del') {
                return _buildKeyButton(
                  context,
                  child: Icon(
                    AppIcons.backspace,
                    size: AppDimens.icon22,
                    color: AppTokens.textPrimary(context),
                  ),
                  onTap: onDelete,
                );
              }
              return _buildKeyButton(
                context,
                child: Text(
                  key,
                  style: AppTextTokens.display2(
                    context,
                  ).copyWith(color: AppTokens.textPrimary(context)),
                ),
                onTap: () => onNumberTap(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  /// 数字与操作共用按压反馈，触觉在按下时触发，提交在松手时完成。
  Widget _buildKeyButton(
    BuildContext context, {
    required Widget child,
    VoidCallback? onTap,
  }) {
    final size = 72.0;
    return PressKey(
      enabled: onTap != null,
      scale: 0.94,
      // 触觉在按下瞬间触发，视觉按压态立即呈现；数字提交仍走松手，避免误触
      onDown: onTap == null ? null : () => HapticFeedback.lightImpact(),
      onUp: onTap,
      backgroundColor: onTap != null
          ? AppTokens.surfaceSecondary(context)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}
