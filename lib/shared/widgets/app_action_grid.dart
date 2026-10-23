import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 图标入口只携带业务名称，添加语义由弹层标题统一提供。
typedef AppIconAction<T> = ({T value, IconData icon, String label});

/// 添加弹层共用等宽图标网格，小屏和大字号按可读宽度自动换行。
class AppActionGrid<T> extends StatelessWidget {
  const AppActionGrid({
    super.key,
    required this.actions,
    required this.onSelected,
  });
  final List<AppIconAction<T>> actions;
  final ValueChanged<T> onSelected;

  /// 测量最长名称后决定列数，既保留五列横排，也避免长译文溢出。
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = AppTextTokens.caption(context);
      var minimum = AppDimens.actionButtonMinHeight;
      for (final action in actions) {
        final painter = TextPainter(
          text: TextSpan(text: action.label, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        minimum = minimum < painter.width + AppDimens.p8
            ? painter.width + AppDimens.p8
            : minimum;
        painter.dispose();
      }
      final columns = (constraints.maxWidth / minimum).floor().clamp(
        1,
        actions.length,
      );
      return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: AppDimens.p8,
        children: [
          for (final action in actions)
            SizedBox(
              width: constraints.maxWidth / columns,
              child: Semantics(
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppTokens.buttonRadius(context),
                  ),
                  onTap: () => onSelected(action.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.p16,
                      horizontal: AppDimens.p4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          action.icon,
                          size: AppDimens.icon28,
                          color: AppTokens.isDark(context)
                              ? AppTokens.textPrimary(context)
                              : AppTokens.primary(context),
                        ),
                        const SizedBox(height: AppDimens.p8),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: style,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
