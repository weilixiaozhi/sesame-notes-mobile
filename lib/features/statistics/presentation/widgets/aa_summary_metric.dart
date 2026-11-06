import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// AA 汇总与成员详情共用标签在上、数值在下的指标列。
class AaSummaryMetric extends StatelessWidget {
  /// 页面负责指标口径与金额格式，差额可传入应收或应付的语义色。
  const AaSummaryMetric({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  /// 长金额等比缩小以完整显示，列宽及横向均分由所属行决定。
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: AppTextTokens.caption(
          context,
        ).copyWith(color: AppTokens.textTertiary(context)),
      ),
      const SizedBox(height: AppDimens.p4),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          maxLines: 1,
          style: AppTextTokens.label(context).copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTokens.textPrimary(context),
          ),
        ),
      ),
    ],
  );
}
