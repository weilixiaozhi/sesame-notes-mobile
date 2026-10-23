import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/currency_flag.dart';
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';
import 'package:sesame_notes/shared/widgets/press_key.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 底部计算键盘的金额行：币种占一列，金额占两列，删除占一列。
class TransactionAmountBar extends StatelessWidget {
  /// 金额和结果使用十进制字符串，完整保留负号和大金额精度。
  const TransactionAmountBar({
    super.key,
    required this.amountStr,
    required this.txCurrency,
    required this.ledgerBase,
    required this.conversionPreview,
    required this.rateFetching,
    required this.rateMissing,
    required this.rateMissingHint,
    required this.onPickCurrency,
    required this.onEditRate,
    required this.onDeleteOne,
    required this.onClearAmount,
    required this.onRollback,
    this.resultPreview,
    this.rate,
    this.readOnly = false,
  });

  final String amountStr, txCurrency, ledgerBase, rateMissingHint;
  final String? resultPreview, conversionPreview, rate;
  final bool rateFetching, rateMissing, readOnly;
  final VoidCallback onPickCurrency,
      onEditRate,
      onDeleteOne,
      onClearAmount,
      onRollback;

  /// 币种入口和数字键共享尺寸与表面，长币种标签等比缩放。
  Widget _currency(BuildContext context, double height) => InkWell(
    key: const ValueKey('amount_currency_chip'),
    onTap: readOnly ? null : onPickCurrency,
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    child: Container(
      decoration: BoxDecoration(
        color: AppTokens.keyDigit(context),
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: currencyFlagLabel(
            txCurrency,
            textStyle: AppTextTokens.input(context).copyWith(
              fontSize: (height * 0.36).clamp(12.0, 20.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );

  /// 草稿锚定右侧滚动，最新输入始终可见；汇率折算使用独立入口。
  Widget _amount(BuildContext context, double height) {
    final foreign = txCurrency != ledgerBase;
    final textSize = (height * 0.46).clamp(12.0, 21.0);
    return GestureDetector(
      key: const ValueKey('amount_area'),
      behavior: HitTestBehavior.opaque,
      onTap: readOnly
          ? null
          : () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AppTokens.keyDigit(context),
          borderRadius: BorderRadius.circular(AppDimens.radius4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amountStr,
                        key: const ValueKey('editor_amount'),
                        style: AppTextTokens.amountInput(
                          context,
                        ).copyWith(fontSize: textSize, height: 1.0),
                      ),
                      if (resultPreview != null) ...[
                        const SizedBox(width: AppDimens.p4),
                        Text(
                          '= $resultPreview',
                          key: const ValueKey('editor_amount_result'),
                          style: AppTextTokens.input(context).copyWith(
                            fontSize: textSize,
                            color: AppTokens.textTertiary(context),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (foreign)
              InkWell(
                key: const ValueKey('amount_rate_editor'),
                onTap: readOnly ? null : onEditRate,
                child: Text(
                  conversionPreview ??
                      (rateFetching
                          ? '≈ … $ledgerBase'
                          : rate != null
                          ? '1 $txCurrency = $rate $ledgerBase'
                          : rateMissingHint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTokens.caption(context).copyWith(
                    fontSize: (height * 0.22).clamp(8.0, 12.0),
                    color: rateMissing
                        ? AppTokens.error(context)
                        : AppTokens.textSecondary(context),
                    height: 1.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 删除按下退一位，长按清空草稿，取消手势由面板恢复输入。
  Widget _delete(BuildContext context, double height) => PressKey(
    key: const ValueKey('amount_delete_key'),
    enabled: !readOnly,
    onDown: onDeleteOne,
    onCancel: onRollback,
    onLongPress: onClearAmount,
    backgroundColor: AppTokens.keyDigit(context),
    borderRadius: BorderRadius.circular(AppDimens.radius4),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.backspace,
              size: (height * 0.34).clamp(12.0, 16.0),
              color: AppTokens.textSecondary(context),
              semanticLabel: MaterialLocalizations.of(
                context,
              ).deleteButtonTooltip,
            ),
            const SizedBox(height: AppDimens.p4),
            Text(
              AppLocalizations.of(context).txDeleteLongPress,
              style: AppTextTokens.caption(context).copyWith(
                fontSize: (height * 0.17).clamp(6.0, 8.0),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// 三个金额区块与下方四列键位保持一致的宽度和间距。
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = ((constraints.maxWidth - 3 * KeypadLayout.gap) / 4).clamp(
        0.0,
        double.infinity,
      );
      final height = constraints.maxHeight;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: width, child: _currency(context, height)),
          const SizedBox(width: KeypadLayout.gap),
          SizedBox(
            width: 2 * width + KeypadLayout.gap,
            child: _amount(context, height),
          ),
          const SizedBox(width: KeypadLayout.gap),
          SizedBox(width: width, child: _delete(context, height)),
        ],
      );
    },
  );
}
