import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/day_text.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 管理页和备份预览共用四行分类统计，缺少的分类仍显示零。
class DayBookCounts extends StatelessWidget {
  const DayBookCounts({super.key, required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colon = l10n.localeName.startsWith('zh') ? '：' : ': ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.p4,
      children: [
        for (final category in [
          DayCategory.birthday,
          DayCategory.anniversary,
          DayCategory.countdown,
          DayCategory.stage,
        ])
          Text(
            '${dayCategoryLabel(l10n, category)}$colon${counts[category] ?? 0}',
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
      ],
    );
  }
}
