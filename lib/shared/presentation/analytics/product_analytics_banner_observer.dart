import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/logging/logger_service.dart';
import '../../../domain/analytics/product_analytics_actions.dart';
import '../../../domain/analytics/product_banner_dimensions.dart';
import '../../application/product_analytics_controller.dart';

/// 图片实际显示后观察可见面积，统计请求统一交给已有采集用例。
class ProductAnalyticsBannerObserver extends StatefulWidget {
  /// banner 为空表示图片尚未显示或解码失败，不采集素材曝光与点击。
  const ProductAnalyticsBannerObserver({
    super.key,
    required this.controller,
    required this.banner,
    required this.onTap,
    required this.builder,
  });
  final ProductAnalyticsController controller;
  final ProductBannerDimensions? banner;
  final VoidCallback onTap;
  final Widget Function(VoidCallback onTap) builder;

  /// 观察实例只保存可见面积和帧调度状态，去重归属由统一访问用例维护。
  @override
  State<ProductAnalyticsBannerObserver> createState() =>
      _ProductAnalyticsBannerObserverState();
}

class _ProductAnalyticsBannerObserverState
    extends State<ProductAnalyticsBannerObserver> {
  final _visibilityKey = UniqueKey();
  double _visibleFraction = 0;
  bool _scheduled = false;

  /// 页面访问状态更新后重验图片，后台补报本身不会触发这里。
  @override
  void initState() {
    super.initState();
    widget.controller.addVisibilityListener(_schedule);
  }

  /// 路由遮挡或恢复改变当前路由依赖，在帧完成后判定实际曝光。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  /// 账号或环境切换可以重建采集用例，旧观察者必须立即解除。
  @override
  void didUpdateWidget(ProductAnalyticsBannerObserver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeVisibilityListener(_schedule);
      widget.controller.addVisibilityListener(_schedule);
    }
    _schedule();
  }

  /// 合并同一帧的图片与路由通知，避免未提交的中间状态计数。
  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _track(ProductAction.bannerImpression);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// 曝光要求至少半张图片可见；真实点击直接进入当前路由和前台身份校验。
  void _track(ProductAction action) {
    try {
      final banner = widget.banner;
      if (banner == null ||
          action == ProductAction.bannerImpression && _visibleFraction < .5 ||
          ModalRoute.isCurrentOf(context) != true ||
          !TickerMode.valuesOf(context).enabled) {
        return;
      }
      widget.controller.trackBanner(
        pageId: banner.pageId,
        action: action,
        banner: banner,
      );
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '横幅可见性统计失败，入口功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 点击立即进入业务导航，不等待存储、上传或统计确认。
  void _tap() {
    _track(ProductAction.bannerImpression);
    _track(ProductAction.bannerClick);
    widget.onTap();
  }

  /// 可见面积来自实际绘制，图片下载或普通组件重建不能替代曝光。
  @override
  Widget build(BuildContext context) {
    ModalRoute.isCurrentOf(context);
    TickerMode.valuesOf(context);
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        _visibleFraction = info.visibleFraction;
        _schedule();
      },
      child: widget.builder(_tap),
    );
  }

  /// 页面释放后不保留回调或可见面积通知。
  @override
  void dispose() {
    widget.controller.removeVisibilityListener(_schedule);
    VisibilityDetectorController.instance.forget(_visibilityKey);
    super.dispose();
  }
}
