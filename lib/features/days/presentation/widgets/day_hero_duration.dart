import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 主卡放大时长中的数字，单位和方向保持正文尺度，读屏保留完整原语义。
class DayHeroDuration extends StatelessWidget {
  /// 只有既有规则产生纯天数表达时才传入相对天数，其他时长保持完整文案。
  const DayHeroDuration({super.key, required this.label, this.relativeDays});
  final String label;
  final int? relativeDays;

  /// 阶段、周年和过期表达不被折算成另一个业务口径。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = AppTokens.dayHeroText(context);
    final number = RegExp(r'\d+').firstMatch(label);
    if (relativeDays == 0 || number == null) {
      return Text(
        label,
        key: const ValueKey('day-hero-duration'),
        style: AppTextTokens.display2(context).copyWith(color: color),
      );
    }
    final days = relativeDays;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Text.rich(
        key: const ValueKey('day-hero-duration'),
        TextSpan(
          children: [
            if (days == null && number.start > 0)
              TextSpan(text: label.substring(0, number.start)),
            TextSpan(
              text: days?.abs().toString() ?? number.group(0),
              style: AppTextTokens.heroNumber(context).copyWith(color: color),
            ),
            TextSpan(
              text: days == null
                  ? label.substring(number.end)
                  : days > 0
                  ? l.dayHeroDaysAfter
                  : l.dayHeroDaysBefore,
            ),
          ],
        ),
        style: AppTextTokens.body(context).copyWith(color: color),
      ),
    );
  }
}
