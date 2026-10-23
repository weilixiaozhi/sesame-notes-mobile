import 'package:flutter/widgets.dart';
import '../../../domain/analytics/product_analytics_context.dart';
import 'product_analytics_page_state.dart';

/// 通用界面登记只接收展示身份与状态容器，不读取路由、业务或应用装配。
class ProductAnalyticsPresentation extends StatefulWidget {
  /// routePage 区分路由内模式与独立业务弹层，二者都不直接写事件。
  const ProductAnalyticsPresentation({
    super.key,
    required this.registry,
    required this.ownerRouteKey,
    required this.pageId,
    required this.child,
    this.analyticsContext,
    this.routePage = false,
  });
  final ProductAnalyticsPageState registry;
  final String? ownerRouteKey;
  final String pageId;
  final Widget child;
  final ProductAnalyticsContext? analyticsContext;
  final bool routePage;

  /// 一个展示实例对应独立登记键，重建继续复用该身份。
  @override
  State<ProductAnalyticsPresentation> createState() =>
      _ProductAnalyticsPresentationState();
}

class _ProductAnalyticsPresentationState
    extends State<ProductAnalyticsPresentation> {
  final _key = Object();

  /// 首帧观察之前登记，统一监听器在帧结束后读取实际展示状态。
  @override
  void initState() {
    super.initState();
    _publish();
  }

  /// 登记容器或路由归属改变时先释放原登记，再发布当前页面。
  @override
  void didUpdateWidget(ProductAnalyticsPresentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registry != widget.registry ||
        oldWidget.ownerRouteKey != widget.ownerRouteKey ||
        oldWidget.routePage != widget.routePage) {
      _remove(oldWidget);
    }
    _publish();
  }

  /// 无路由宿主时不伪造页面；组件本身仍能独立展示。
  void _publish() {
    final routeKey = widget.ownerRouteKey;
    if (routeKey == null) return;
    if (widget.routePage) {
      widget.registry.show(routeKey, widget.pageId, owner: _key);
    } else if (widget.analyticsContext case final context?) {
      widget.registry.present((
        key: _key,
        routeKey: routeKey,
        pageId: widget.pageId,
        context: context,
      ));
    } else {
      widget.registry.dismiss(_key);
    }
  }

  /// 只释放本实例拥有的登记，不干扰其他弹层。
  void _remove(ProductAnalyticsPresentation value) {
    if (value.routePage && value.ownerRouteKey != null) {
      value.registry.remove(value.ownerRouteKey!, owner: _key);
    } else {
      value.registry.dismiss(_key);
    }
  }

  /// 实际退场时恢复下方页面。
  @override
  void dispose() {
    _remove(widget);
    super.dispose();
  }

  /// 统计登记不改变布局、导航或手势。
  @override
  Widget build(BuildContext context) => widget.child;
}
