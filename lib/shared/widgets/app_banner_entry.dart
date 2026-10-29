import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/analytics/product_banner_dimensions.dart';
import '../../providers/product_analytics_providers.dart';
import '../../infrastructure/api/api_client_provider.dart';
import '../presentation/analytics/product_analytics_banner_observer.dart';
import '../application/product_analytics_controller.dart';

import '../../core/logging/logger_service.dart';
import '../../data/models/app_banner.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/route_consts.dart';
import '../../theme/app_visual_theme.dart';
import '../../theme/dimens.dart';
import '../providers/app_banner_provider.dart';

/// 固定位置的图片入口，远端图与跳转作为整体切换，任何失败均保持本地可用。
class AppBannerEntry extends ConsumerStatefulWidget {
  /// 页面负责执行已有的安全导航与反馈，组件只传递白名单路由。
  const AppBannerEntry({
    super.key,
    required this.slot,
    required this.onOpen,
    this.onOpenOfficial,
  });

  final AppBannerSlot slot;
  final ValueChanged<String> onOpen;
  final Future<void> Function(AppBannerTarget target, String id)?
  onOpenOfficial;

  /// 生命周期观察只负责配置刷新，曝光由独立图片观察者处理。
  @override
  ConsumerState<AppBannerEntry> createState() => _AppBannerEntryState();
}

class _AppBannerEntryState extends ConsumerState<AppBannerEntry>
    with WidgetsBindingObserver {
  bool _current = false;
  ProductAnalyticsController? _analytics;
  int _activeIndex = 0;
  String _signature = '';
  final _failedSlides = <String>{};
  Object? _sourceSnapshot;
  bool _opening = false;

  /// 页面进入前台时允许按节流重新读取后台配置。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// 路由重新成为当前页面时刷新，图片与目标随后整体替换。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.isCurrentOf(context) == true;
    if (current && !_current) _scheduleRefresh();
    _current = current;
  }

  /// 返回前台重新检查配置，隐藏的路由不发起刷新。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _scheduleRefresh();
  }

  /// 帧末进行节流校验，避免在组件构建期间修改提供者状态。
  void _scheduleRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final state = WidgetsBinding.instance.lifecycleState;
        if (ModalRoute.isCurrentOf(context) != true ||
            state != null && state != AppLifecycleState.resumed ||
            !ref.read(apiConfigProvider).isConfigured) {
          return;
        }
        if (ref.read(appBannerRefreshGateProvider).claim(DateTime.now())) {
          ref.invalidate(appBannersProvider);
        }
      } catch (error, stack) {
        logger.error(
          'AppBanner',
          '前台横幅刷新失败，保留本地入口',
          safeErrorSummary(error),
          stack,
        );
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// 页面释放后不再响应系统生命周期。
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 图片铺满横幅，沿用主题圆角；首帧与远端加载期间均可点击默认入口。
  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(appBannersProvider);
    final source = banners.isLoading
        ? null
        : banners.asData?.value[widget.slot];
    if (!identical(source, _sourceSnapshot)) {
      _sourceSnapshot = source;
      _failedSlides.clear();
    }
    final entries = banners.isLoading
        ? <ResolvedAppBanner>[]
        : (source ?? const <ResolvedAppBanner>[])
              .where(
                (entry) =>
                    !_failedSlides.contains('${entry.id}:${entry.version}'),
              )
              .toList();
    final signature = entries
        .map((entry) => '${entry.id}:${entry.version}')
        .join('|');
    if (_signature != signature) {
      _signature = signature;
      _activeIndex = 0;
    }
    _analytics = GoRouter.maybeOf(context) == null
        ? null
        : ref.watch(productAnalyticsControllerProvider);
    final visual = AppVisualTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(visual.radius(AppThemeRadius.card)),
      child: AspectRatio(
        aspectRatio: AppDimens.bannerAspectRatio,
        child: entries.isEmpty
            ? _builtin(context)
            : entries.length == 1
            ? _slide(context, entries.single, true)
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    key: ValueKey('banner-carousel-$signature'),
                    itemCount: entries.length,
                    onPageChanged: (index) =>
                        setState(() => _activeIndex = index),
                    itemBuilder: (context, index) =>
                        _slide(context, entries[index], index == _activeIndex),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppDimens.p8,
                    child: IgnorePointer(
                      child: Center(
                        child: Semantics(
                          label: '${_activeIndex + 1}/${entries.length}',
                          child: Container(
                            key: const ValueKey('banner-pagination'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.p8,
                              vertical: AppDimens.p4,
                            ),
                            decoration: BoxDecoration(
                              color: visual.color(AppThemeColor.overlay),
                              borderRadius: BorderRadius.circular(
                                visual.radius(AppThemeRadius.button),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  var index = 0;
                                  index < entries.length;
                                  index++
                                )
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.p3,
                                    ),
                                    child: Container(
                                      width: AppDimens.cloudStatusDotSize,
                                      height: AppDimens.cloudStatusDotSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: visual
                                            .color(AppThemeColor.trainingText)
                                            .withValues(
                                              alpha: index == _activeIndex
                                                  ? 1
                                                  : .45,
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 邻页预加载只绘制图片，只有当前页可把素材身份交给曝光观察器。
  Widget _slide(BuildContext context, ResolvedAppBanner remote, bool active) =>
      Image.memory(
        remote.bytes,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, synchronous) =>
            frame != null || synchronous
            ? _surface(
                context,
                child,
                remote.target,
                active
                    ? ProductBannerDimensions(
                        id: remote.id,
                        slot: widget.slot.id,
                        source: 'remote',
                        version: remote.version,
                      )
                    : null,
                targetId: remote.targetId,
              )
            : _builtin(context, track: false),
        errorBuilder: (context, error, stackTrace) {
          logger.error(
            'AppBanner',
            '${widget.slot.id} 横幅显示失败，使用内置入口',
            safeErrorSummary(error),
            stackTrace,
          );
          _discard(remote);
          return _builtin(context, track: false);
        },
      );

  /// 渲染阶段失败的素材在下一帧移出轮播，其他有效图片和入口继续可用。
  void _discard(ResolvedAppBanner banner) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _failedSlides.add('${banner.id}:${banner.version}')) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// 内置图片无需服务器；极端资源故障仍保留有名称且可点击的默认入口。
  Widget _builtin(BuildContext context, {bool track = true}) => Image.asset(
    widget.slot.assetPath,
    fit: BoxFit.cover,
    excludeFromSemantics: true,
    frameBuilder: (context, child, frame, synchronous) => _surface(
      context,
      child,
      widget.slot.defaultTarget,
      track && (frame != null || synchronous)
          ? ProductBannerDimensions(
              id: 'builtin:${widget.slot.id}',
              slot: widget.slot.id,
              source: 'builtin',
              version: 0,
            )
          : null,
    ),
    errorBuilder: (context, error, stackTrace) {
      logger.error(
        'AppBanner',
        '${widget.slot.id} 内置图片读取失败',
        safeErrorSummary(error),
        stackTrace,
      );
      final visual = AppVisualTheme.of(context);
      return _surface(
        context,
        ColoredBox(
          color: visual.color(AppThemeColor.brandSoft),
          child: Center(
            child: Text(_label(context, widget.slot.defaultTarget)),
          ),
        ),
        widget.slot.defaultTarget,
        null,
      );
    },
  );

  /// 整张横幅提供触控、键盘和读屏入口，标签跟随实际跳转及当前界面语言。
  Widget _surface(
    BuildContext context,
    Widget image,
    AppBannerTarget target,
    ProductBannerDimensions? banner, {
    String? targetId,
  }) {
    /// 统计观察器只包裹回调，不改变可点击面积或读屏含义。
    Widget surface(VoidCallback onTap) => Semantics(
      button: true,
      label: _label(context, target),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(child: image),
          Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap, excludeFromSemantics: false),
          ),
        ],
      ),
    );
    final analytics = _analytics;
    if (analytics == null) return surface(() => _open(target, targetId));
    return ProductAnalyticsBannerObserver(
      controller: analytics,
      banner: banner,
      onTap: () => _open(target, targetId),
      builder: surface,
    );
  }

  /// 具体官方内容交给健身模块读取与导航，重复点击不并行打开多个详情。
  Future<void> _open(AppBannerTarget target, String? targetId) async {
    if (_opening) return;
    _opening = true;
    try {
      if (targetId != null &&
          widget.onOpenOfficial != null &&
          (target == AppBannerTarget.officialPlan ||
              target == AppBannerTarget.officialTemplate)) {
        await widget.onOpenOfficial!(target, targetId);
      } else {
        widget.onOpen(_route(target));
      }
    } catch (error, stack) {
      logger.error(
        'AppBanner',
        '横幅跳转失败，打开对应内容库',
        safeErrorSummary(error),
        stack,
      );
      if (mounted) widget.onOpen(_route(target));
    } finally {
      _opening = false;
    }
  }

  /// 各受控目标的读屏文案复用应用已有本地化资源。
  String _label(BuildContext context, AppBannerTarget target) {
    final l = AppLocalizations.of(context);
    return switch (target) {
      AppBannerTarget.fitnessPlanLibrary => l.fitnessPlanLibrary,
      AppBannerTarget.fitnessTemplateLibrary => l.fitnessTemplateLibrary,
      AppBannerTarget.fitnessExercises => l.fitnessExercises,
      AppBannerTarget.fitnessPlans => l.fitnessMyPlans,
      AppBannerTarget.fitnessTemplates => l.fitnessMyTemplates,
      AppBannerTarget.officialPlan => l.fitnessPlanLibrary,
      AppBannerTarget.officialTemplate => l.fitnessTemplateLibrary,
    };
  }

  /// 路由只由客户端白名单映射，不执行服务器传来的字符串路径。
  String _route(AppBannerTarget target) => switch (target) {
    AppBannerTarget.fitnessPlanLibrary => Routes.fitnessPlanLibrary,
    AppBannerTarget.fitnessTemplateLibrary => Routes.fitnessTemplateLibrary,
    AppBannerTarget.fitnessExercises => Routes.fitnessExercises,
    AppBannerTarget.fitnessPlans => Routes.fitnessPlans,
    AppBannerTarget.fitnessTemplates => Routes.fitnessTemplates,
    AppBannerTarget.officialPlan => Routes.fitnessPlanLibrary,
    AppBannerTarget.officialTemplate => Routes.fitnessTemplateLibrary,
  };
}
