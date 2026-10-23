import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'keypad_constants.dart';
import 'press_key.dart';

/// 训练等专用数字输入使用四个业务操作，独立于记账计算键盘。
class AmountKeypad extends StatelessWidget {
  /// 数字与退格按下生效，滑出回滚；确认只在松手时执行。
  const AmountKeypad({
    super.key,
    required this.onAppend,
    required this.onSubmit,
    required this.actions,
    required this.onBackspace,
    required this.onClear,
    this.onRollback,
    this.allowDecimal = true,
  }) : assert(actions.length == 4);

  final ValueChanged<String> onAppend;
  final VoidCallback onSubmit, onBackspace, onClear;
  final VoidCallback? onRollback;
  final bool allowDecimal;
  final List<({String label, String? subtitle, VoidCallback onPressed})>
  actions;

  /// 数字和小数点沿用主题数字表面，业务限制通过enabled控制。
  Widget _number(
    BuildContext context,
    String value,
    double height, {
    bool enabled = true,
  }) => PressKey(
    enabled: enabled,
    scale: 0.94,
    onDown: () => onAppend(value),
    onCancel: onRollback,
    backgroundColor: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppTokens.keyRadius(context)),
    child: Center(
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: enabled
              ? AppTokens.textPrimary(context)
              : AppTokens.textDisabled(context),
          fontSize: height * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  /// 业务操作长条只调用原动作回调，不承担金额运算或记账保存。
  Widget _actions(BuildContext context) => Material(
    key: const ValueKey('keypad_action_bar'),
    color: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppTokens.keyRadius(context)),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (final action in actions)
          Expanded(
            child: PressKey(
              onUp: action.onPressed,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTokens.textPrimary(context),
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: AppDimens.p4),
                        Text(
                          action.subtitle!,
                          textAlign: TextAlign.center,
                          style: AppTextTokens.caption(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  /// 删除键保留单点退格、长按清空与取消回滚。
  Widget _delete(BuildContext context) => PressKey(
    onDown: onBackspace,
    onLongPress: onClear,
    onCancel: onRollback,
    backgroundColor: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppTokens.keyRadius(context)),
    child: Center(
      child: Icon(
        AppIcons.backspace,
        color: AppTokens.textPrimary(context),
        semanticLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
      ),
    ),
  );

  /// 确认键沿用训练输入关闭/确认动作，不显示记账保存或等号。
  Widget _done(BuildContext context, double height) => PressKey(
    onUp: onSubmit,
    scale: 0.94,
    backgroundColor: AppTokens.buttonPrimary(context),
    borderRadius: BorderRadius.circular(AppTokens.keyRadius(context)),
    child: Center(
      child: Icon(
        AppIcons.keyboardReturn,
        size: height * 0.43,
        color: AppTokens.buttonPrimaryText(context),
        semanticLabel: AppLocalizations.of(context).commonFinish,
      ),
    ),
  );

  /// 四行数字布局保持训练键盘的尺寸、触发时机与底行排列。
  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaler.scale(1).clamp(0.85, 1.0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = (constraints.maxHeight - 3 * KeypadLayout.rowGap) / 4;
          final width = (constraints.maxWidth - 3 * KeypadLayout.gap) / 4;
          return Column(
            children: [
              SizedBox(
                key: const ValueKey('keypad_num_grid'),
                height: 3 * height + 2 * KeypadLayout.rowGap,
                child: Row(
                  children: [
                    SizedBox(
                      width: 3 * width + 2 * KeypadLayout.gap,
                      child: Column(
                        children: [
                          for (var row = 0; row < 3; row++) ...[
                            if (row > 0)
                              const SizedBox(height: KeypadLayout.rowGap),
                            Expanded(
                              child: Row(
                                children: [
                                  for (
                                    var column = 0;
                                    column < 3;
                                    column++
                                  ) ...[
                                    if (column > 0)
                                      const SizedBox(width: KeypadLayout.gap),
                                    SizedBox(
                                      width: width,
                                      child: _number(
                                        context,
                                        '${row * 3 + column + 1}',
                                        height,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: _actions(context)),
                  ],
                ),
              ),
              const SizedBox(height: KeypadLayout.rowGap),
              SizedBox(
                key: const ValueKey('keypad_bottom_row'),
                height: height,
                child: Row(
                  children: [
                    SizedBox(
                      width: width,
                      child: _number(
                        context,
                        '.',
                        height,
                        enabled: allowDecimal,
                      ),
                    ),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(
                      width: width,
                      child: _number(context, '0', height),
                    ),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: _delete(context)),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: _done(context, height)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
