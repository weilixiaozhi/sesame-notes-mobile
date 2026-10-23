import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';

class FitnessSessionSummary extends StatelessWidget {
  const FitnessSessionSummary({
    super.key,
    required this.exercises,
    this.execution = false,
  });
  final List<FitnessExercise> exercises;
  final bool execution;

  /// 处方统计全部配置组；执行摘要核验全部完成成绩，数据错误时显示失败状态。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    var volume = Decimal.zero;
    var sets = 0, count = 0;
    try {
      for (final e in exercises) {
        final included = e.sets.where((s) => !execution || s.completed);
        sets += included.length;
        if (included.isNotEmpty) count++;
        for (final s in included) {
          // 处方包含合法的未填完草稿，只有具备完整成绩字段的组才计算预估训练量。
          if (!execution && !fitnessSetIsValid(s)) continue;
          volume += fitnessSetVolume(
            execution ? s : s.copyWith(completed: true),
          );
        }
      }
    } catch (error, stackTrace) {
      logger.error('FitnessSessionSummary', '训练摘要数据无效', error, stackTrace);
      return AppStatusBanner(
        icon: AppIcons.error,
        message: l.fitnessLoadFailed,
        inset: true,
      );
    }
    final metrics = [
      (l.fitnessVolume, '$volume kg'),
      (l.fitnessSets, '$sets'),
      (l.fitnessExerciseTotal, '$count'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: AppDimens.p16,
                  color: AppTokens.borderStrong(context),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      metrics[i].$1,
                      textAlign: TextAlign.center,
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.textPrimary(context)),
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      metrics[i].$2,
                      textAlign: TextAlign.center,
                      style: AppTextTokens.boldTitle(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
