import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';
import 'package:sesame_notes/shared/widgets/press_key.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 记账专用数字、四则运算及日期键，计算和保存使用不同的触发时机。
class TransactionAmountKeypad extends StatelessWidget {
  /// 数字与等号按下生效，取消时回滚；完成松手时保存。
  const TransactionAmountKeypad({
    super.key,
    required this.date,
    required this.calculating,
    required this.isDoneEnabled,
    required this.onAppend,
    required this.onOperator,
    required this.onEquals,
    required this.onPickDate,
    required this.onSubmit,
    required this.onRollback,
    this.activeOperator,
    this.enabled = true,
  });

  final DateTime date;
  final bool calculating, isDoneEnabled, enabled;
  final String? activeOperator;
  final ValueChanged<String> onAppend, onOperator;
  final VoidCallback onEquals, onPickDate, onSubmit, onRollback;

  /// 数字键沿用主题键盘表面和行高比例，滑出不会遗留误输入。
  Widget _number(BuildContext context, String value, double height) => PressKey(
    key: ValueKey('transaction_digit_${value == '.' ? 'dot' : value}'),
    enabled: enabled,
    scale: 0.94,
    onDown: () => onAppend(value),
    onCancel: onRollback,
    backgroundColor: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    child: Center(
      child: Text(
        value,
        style: AppTextTokens.input(
          context,
        ).copyWith(fontSize: height * 0.36, fontWeight: FontWeight.w600),
      ),
    ),
  );

  /// 运算符四个热区共享一列，待输入的运算符使用主题主色提示。
  Widget _operators(BuildContext context, double height) => Material(
    key: const ValueKey('keypad_op_bar'),
    color: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (final operation in const <String, String>{
          '+': 'plus',
          '-': 'minus',
          '×': 'multiply',
          '÷': 'divide',
        }.entries)
          Expanded(
            child: PressKey(
              key: ValueKey('transaction_operator_${operation.value}'),
              enabled: enabled,
              onDown: () => onOperator(operation.key),
              onCancel: onRollback,
              backgroundColor: activeOperator == operation.key
                  ? AppTokens.primary(context).withValues(alpha: 0.15)
                  : null,
              child: Center(
                child: Text(
                  operation.key == '-' ? '−' : operation.key,
                  style: AppTextTokens.input(context).copyWith(
                    fontSize: height * 0.36,
                    fontWeight: FontWeight.w600,
                    color: activeOperator == operation.key
                        ? AppTokens.primary(context)
                        : AppTokens.textPrimary(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  /// 日期与时间共用日期滚轮入口，键位短屏时等比缩放保持完整。
  Widget _date(BuildContext context) => PressKey(
    key: const ValueKey('editor_date'),
    enabled: enabled,
    scale: 0.94,
    onDown: onPickDate,
    backgroundColor: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    child: Semantics(
      button: true,
      label: AppLocalizations.of(context).homeSelectDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${date.year}/${date.month}/${date.day}',
                style: AppTextTokens.dateSecondary(
                  context,
                ).copyWith(color: AppTokens.textPrimary(context)),
              ),
              const SizedBox(height: AppDimens.p4),
              Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: AppTextTokens.dateSecondary(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// 算式时先执行等号，结果确认后才保存；提交期间禁止任何操作。
  Widget _done(BuildContext context, double height) {
    final available = enabled && (calculating || isDoneEnabled);
    final color = available
        ? AppTokens.buttonPrimaryText(context)
        : AppTokens.textSecondary(context);
    return _TransactionDoneKey(
      calculating: calculating,
      enabled: available,
      onEquals: onEquals,
      onRollback: onRollback,
      onSubmit: onSubmit,
      backgroundColor: available
          ? AppTokens.buttonPrimary(context)
          : AppTokens.buttonDisabled(context),
      child: Center(
        child: calculating
            ? Text(
                '=',
                style: AppTextTokens.input(context).copyWith(
                  color: color,
                  fontSize: height * 0.43,
                  fontWeight: FontWeight.w800,
                ),
              )
            : Icon(
                AppIcons.keyboardReturn,
                size: height * 0.43,
                color: color,
                semanticLabel: AppLocalizations.of(context).commonFinish,
              ),
      ),
    );
  }

  /// 三行数字和独立运算列保持等宽，底行是日期、零、小数点与完成。
  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaler.scale(1).clamp(0.85, 1.0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = ((constraints.maxHeight - 3 * KeypadLayout.rowGap) / 4)
              .clamp(0.0, double.infinity);
          final width = ((constraints.maxWidth - 3 * KeypadLayout.gap) / 4)
              .clamp(0.0, double.infinity);
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
                    SizedBox(width: width, child: _operators(context, height)),
                  ],
                ),
              ),
              const SizedBox(height: KeypadLayout.rowGap),
              SizedBox(
                key: const ValueKey('keypad_bottom_row'),
                height: height,
                child: Row(
                  // 整行按键使用同一高度，日期文字的缩放只影响内容，不改变键位背景。
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: width, child: _date(context)),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(
                      width: width,
                      child: _number(context, '0', height),
                    ),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(
                      width: width,
                      child: _number(context, '.', height),
                    ),
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

/// 同一次等号手势在面板重建后仍只计算，松手不会误触新的完成保存。
class _TransactionDoneKey extends StatefulWidget {
  /// 保存按下瞬间的操作模式，避免计算后按钮状态切换影响当前手势。
  const _TransactionDoneKey({
    required this.calculating,
    required this.enabled,
    required this.onEquals,
    required this.onRollback,
    required this.onSubmit,
    required this.backgroundColor,
    required this.child,
  });

  final bool calculating, enabled;
  final VoidCallback onEquals, onRollback, onSubmit;
  final Color backgroundColor;
  final Widget child;

  /// 单次手势模式随按键生命周期保存。
  @override
  State<_TransactionDoneKey> createState() => _TransactionDoneKeyState();
}

class _TransactionDoneKeyState extends State<_TransactionDoneKey> {
  bool? _calculatingAtPress;

  /// 等号在按下时计算，完成只记录本次手势等待松手确认。
  void _down() {
    _calculatingAtPress = widget.calculating;
    if (_calculatingAtPress == true) widget.onEquals();
  }

  /// 松手读取按下瞬间的模式，等号不会在求值之后直接保存交易。
  void _up() {
    final save = _calculatingAtPress == false;
    setState(() => _calculatingAtPress = null);
    if (save) widget.onSubmit();
  }

  /// 滑出时只回滚等号求值，尚未执行的保存无需撤销。
  void _cancel() {
    final calculate = _calculatingAtPress == true;
    setState(() => _calculatingAtPress = null);
    if (calculate) widget.onRollback();
  }

  /// 按键回调在状态变化后仍保持同一个资源和手势边界。
  @override
  Widget build(BuildContext context) => PressKey(
    key: const ValueKey('transaction_done'),
    enabled: widget.enabled || _calculatingAtPress == true,
    scale: 0.94,
    onDown: _down,
    onUp: _up,
    onCancel: _cancel,
    backgroundColor: widget.backgroundColor,
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    child: widget.child,
  );
}
