import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 同步提示共用横幅外观和实时读屏语义，状态与操作由业务提供。
class AppStatusBanner extends StatelessWidget {
  const AppStatusBanner({
    super.key,
    required this.icon,
    required this.message,
    this.onTap,
    this.action,
    this.inset = false,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onTap;
  final Widget? action;
  final bool inset;

  /// 整条横幅可作为处理入口，普通同步进度保持只读。
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Material(
      color: inset
          ? AppTokens.surface(context)
          : AppTokens.surfaceSecondary(context),
      borderRadius: inset
          ? BorderRadius.circular(AppTokens.cardRadius(context))
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: inset
            ? BorderRadius.circular(AppTokens.cardRadius(context))
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: inset ? AppDimens.p12 : AppDimens.p16,
            vertical: AppDimens.p8,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: inset
                    ? AppTokens.primary(context)
                    : AppTokens.textSecondary(context),
                size: inset ? AppDimens.icon16 : AppDimens.icon20,
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Text(
                  message,
                  style: inset
                      ? AppTextTokens.label(context)
                      : AppTextTokens.body(context),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: AppDimens.p8),
                Flexible(child: action!),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
