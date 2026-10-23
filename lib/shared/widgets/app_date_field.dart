import 'app_form_section.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 循环记账和纪念日共用日期输入行，标签在输入框内静态排列。
class AppDateField extends StatelessWidget {
  /// 日期文字与尾部操作由业务提供，输入框和点击区域统一呈现。
  const AppDateField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.suffix,
    this.enabled = true,
    this.stacked = false,
  });

  final String label;
  final String valueText;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool enabled;
  final bool stacked;

  /// 日期行保留主题填充及圆角，尾部可放清除按钮或历法胶囊。
  @override
  Widget build(BuildContext context) => AppInputSurface(
    enabled: enabled,
    onTap: onTap,
    child: stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextTokens.caption(context).copyWith(
                  color: enabled
                      ? AppTokens.textSecondary(context)
                      : AppTokens.textDisabled(context),
                ),
              ),
              const SizedBox(height: AppDimens.p4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      valueText,
                      style: AppTextTokens.input(context).copyWith(
                        color: enabled
                            ? AppTokens.textPrimary(context)
                            : AppTokens.textDisabled(context),
                      ),
                    ),
                  ),
                  ?suffix,
                ],
              ),
            ],
          )
        : Row(
            children: [
              Flexible(
                child: Text(
                  '$label${Localizations.localeOf(context).languageCode == 'zh' ? '：' : ':'}',
                  style: AppTextTokens.input(context).copyWith(
                    color: enabled
                        ? AppTokens.textPrimary(context)
                        : AppTokens.textDisabled(context),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Text(
                  valueText,
                  // 日期不随标签长短单独缩小，窄屏时按正文大小换行。
                  style: AppTextTokens.input(context).copyWith(
                    color: enabled
                        ? AppTokens.textPrimary(context)
                        : AppTokens.textDisabled(context),
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: AppDimens.p8),
                Flexible(child: suffix!),
              ],
            ],
          ),
  );
}

/// 起止输入共用左右等宽布局，标签留在各自端点内。
class AppDateRangeFields extends StatelessWidget {
  const AppDateRangeFields({super.key, required this.start, required this.end});
  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: start),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.p8),
        child: Text('~'),
      ),
      Expanded(child: end),
    ],
  );
}
