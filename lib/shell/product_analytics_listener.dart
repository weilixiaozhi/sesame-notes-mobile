import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/logging/logger_service.dart';
import '../providers/product_analytics_providers.dart';
import '../router/product_analytics_routes.dart';
import '../shared/presentation/analytics/product_analytics_page_state.dart';
import '../infrastructure/api/api_client_provider.dart';
import '../shared/providers/account_state_provider.dart';
import '../shared/providers/ui_state_providers.dart';

/// 应用外壳只把路由、生命周期和触摸桥接给采集用例，不操作队列或传输。
class ProductAnalyticsListener extends ConsumerStatefulWidget {
  /// enabled 沿用应用启动及隐私遮罩的共同可见性边界。
  const ProductAnalyticsListener({
    super.key,
    required this.router,
    required this.enabled,
    required this.child,
  });
  final GoRouter router;
  final bool enabled;
  final Widget child;

  /// 保留全局监听器的绑定生命周期。
  @override
  ConsumerState<ProductAnalyticsListener> createState() =>
      _ProductAnalyticsListenerState();
}

class _ProductAnalyticsListenerState
    extends ConsumerState<ProductAnalyticsListener>
    with WidgetsBindingObserver {
  late final ProductAnalyticsPageState _pages;
  late final ProductAnalyticsVisibility _visibility;
  Timer? _retry;
  bool _foreground = true;
  bool _scheduled = false;

  /// 订阅界面真实提交与系统可见性，重绘只触发一次帧末判定。
  @override
  void initState() {
    super.initState();
    _pages = ref.read(productAnalyticsPageStateProvider)
      ..addListener(_schedule);
    _visibility = ref.read(productAnalyticsVisibilityProvider);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _visibility.foreground = _foreground && widget.enabled;
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_schedule);
    _retry = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_visibility.foreground) {
        unawaited(ref.read(productAnalyticsControllerProvider).flush());
      }
    });
    _schedule();
  }

  /// 系统前后台只改变运行态，可见性策略仍由应用装配提供。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _visibility.foreground = _foreground && widget.enabled;
    if (_foreground) {
      _schedule();
    } else {
      _observe();
    }
  }

  /// 路由实例替换后释放旧绑定，隐私边界改变后立即更新运行态。
  @override
  void didUpdateWidget(ProductAnalyticsListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_schedule);
      widget.router.routerDelegate.addListener(_schedule);
    }
    _visibility.foreground = _foreground && widget.enabled;
    _schedule();
  }

  /// 释放监听资源，外壳退场后不保留可见状态。
  @override
  void dispose() {
    _retry?.cancel();
    _pages.removeListener(_schedule);
    widget.router.routerDelegate.removeListener(_schedule);
    WidgetsBinding.instance.removeObserver(this);
    _visibility.foreground = false;
    super.dispose();
  }

  /// 合并同一帧的通知，避免中间路由和构建状态进入统计。
  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _observe();
    });
  }

  /// 路由识别在应用适配层，访问判定在纯采集用例中完成。
  void _observe({bool interaction = false}) {
    try {
      final route = productAnalyticsRoute(widget.router);
      final page = productAnalyticsCurrentPage(widget.router, ref.read);
      final presentation = _pages.presentation(route.key);
      final key = '${route.key}:$page:${presentation?.key.hashCode ?? ''}';
      final context = productAnalyticsRouteContext(widget.router, ref.read);
      final controller = ref.read(productAnalyticsControllerProvider);
      if (interaction) {
        controller.interactPage(pageId: page, visitKey: key, context: context);
      } else {
        controller.observePage(pageId: page, visitKey: key, context: context);
      }
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '页面统计暂不可用，界面功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 根状态变化与真实触摸共用同一个用例入口，不消费触摸事件。
  @override
  Widget build(BuildContext context) {
    ref.listen(accountStateProvider, (_, _) => _schedule());
    ref.listen(authSessionProvider, (_, _) {
      if (_visibility.foreground) {
        unawaited(ref.read(productAnalyticsControllerProvider).flush());
      }
    });
    ref.listen(currentModeProvider, (_, _) => _schedule());
    ref.listen(bottomTabIndexProvider, (_, _) => _schedule());
    return Listener(
      onPointerDown: (_) => _observe(interaction: true),
      child: widget.child,
    );
  }
}
