import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';

/// 首页主金额将币种、整数和小数分层，完整数值仍作为同一个读屏标签。
class HomeMoneyHero extends StatelessWidget {
  /// 金额只在展示层保留两位小数，不改变汇总来源和计算精度。
  const HomeMoneyHero({
    super.key,
    required this.value,
    required this.currency,
    required this.label,
  });

  final double value;
  final String currency;
  final String label;

  /// 超长金额整体缩放，符号和两位小数不会截断或换行。
  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0.00', 'en_US').format(value.abs());
    final parts = formatted.split('.');
    final symbol = getCurrencySymbol(currency.toUpperCase());
    return Semantics(
      label: '$label $symbol $formatted',
      excludeSemantics: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(symbol, style: AppTextTokens.moneyHeroCurrency(context)),
              const SizedBox(width: AppDimens.p4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: parts.first,
                      style: AppTextTokens.moneyHero(context),
                    ),
                    TextSpan(
                      text: '.${parts.last}',
                      style: AppTextTokens.moneyHeroFraction(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
