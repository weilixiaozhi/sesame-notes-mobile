import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/logger_service.dart';
import '../../data/models/app_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/route_consts.dart';
import '../../theme/app_visual_theme.dart';
import '../../theme/dimens.dart';
import '../providers/app_banner_provider.dart';

/// 固定位置的图片入口，远端图与跳转作为整体切换，任何失败均保持本地可用。
class AppBannerEntry extends ConsumerWidget {
  /// 页面负责执行已有的安全导航与反馈，组件只传递白名单路由。
  const AppBannerEntry({super.key, required this.slot, required this.onOpen});

  final AppBannerSlot slot;
  final ValueChanged<String> onOpen;

  /// 图片铺满横幅，沿用主题圆角；首帧与远端加载期间均可点击默认入口。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(appBannersProvider).asData?.value[slot];
    final visual = AppVisualTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(visual.radius(AppThemeRadius.card)),
      child: AspectRatio(
        aspectRatio: AppDimens.bannerAspectRatio,
        child: remote == null
            ? _builtin(context)
            : Image.memory(
                remote.bytes,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, synchronous) =>
                    frame != null || synchronous
                    ? _surface(context, child, remote.target)
                    : _builtin(context),
                errorBuilder: (context, error, stackTrace) {
                  logger.error(
                    'AppBanner',
                    '${slot.id} 横幅显示失败，使用内置入口',
                    safeErrorSummary(error),
                    stackTrace,
                  );
                  return _builtin(context);
                },
              ),
      ),
    );
  }

  /// 内置图片无需服务器；极端资源故障仍保留有名称且可点击的默认入口。
  Widget _builtin(BuildContext context) => _surface(
    context,
    Image.asset(
      slot.assetPath,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) {
        logger.error(
          'AppBanner',
          '${slot.id} 内置图片读取失败',
          safeErrorSummary(error),
          stackTrace,
        );
        final visual = AppVisualTheme.of(context);
        return ColoredBox(
          color: visual.color(AppThemeColor.brandSoft),
          child: Center(child: Text(_label(context, slot.defaultTarget))),
        );
      },
    ),
    slot.defaultTarget,
  );

  /// 整张横幅提供触控、键盘和读屏入口，标签跟随实际跳转及当前界面语言。
  Widget _surface(BuildContext context, Widget image, AppBannerTarget target) =>
      Semantics(
        button: true,
        label: _label(context, target),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(child: image),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => onOpen(_route(target)),
                excludeFromSemantics: false,
              ),
            ),
          ],
        ),
      );

  /// 各受控目标的读屏文案复用应用已有本地化资源。
  String _label(BuildContext context, AppBannerTarget target) {
    final l = AppLocalizations.of(context);
    return switch (target) {
      AppBannerTarget.fitnessPlanLibrary => l.fitnessPlanLibrary,
      AppBannerTarget.fitnessTemplateLibrary => l.fitnessTemplateLibrary,
      AppBannerTarget.fitnessExercises => l.fitnessExercises,
      AppBannerTarget.fitnessPlans => l.fitnessMyPlans,
      AppBannerTarget.fitnessTemplates => l.fitnessMyTemplates,
    };
  }

  /// 路由只由客户端白名单映射，不执行服务器传来的字符串路径。
  String _route(AppBannerTarget target) => switch (target) {
    AppBannerTarget.fitnessPlanLibrary => Routes.fitnessPlanLibrary,
    AppBannerTarget.fitnessTemplateLibrary => Routes.fitnessTemplateLibrary,
    AppBannerTarget.fitnessExercises => Routes.fitnessExercises,
    AppBannerTarget.fitnessPlans => Routes.fitnessPlans,
    AppBannerTarget.fitnessTemplates => Routes.fitnessTemplates,
  };
}
