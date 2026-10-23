import 'package:flutter/foundation.dart';
import '../../../domain/analytics/product_analytics_context.dart';

/// 弹层页面绑定来源路由及自身实例，业务内容不进入页面状态。
typedef ProductAnalyticsPresentationState = ({
  Object key,
  String routeKey,
  String pageId,
  ProductAnalyticsContext context,
});

/// 同一路由内的查看和编辑共享页面状态，访问事件与动作来源读取同一结果。
class ProductAnalyticsPageState extends ChangeNotifier {
  final _pages = <String, ({String pageId, Object owner})>{};
  final _presentations = <Object, ProductAnalyticsPresentationState>{};
  bool _disposed = false;

  /// 路由实例键只用于本地页面归属，不写入埋点正文。
  String? page(String routeKey) => _pages[routeKey]?.pageId;

  /// 同一路由上最后呈现的业务弹层优先，其他路由的页面不会借用它。
  ProductAnalyticsPresentationState? presentation(String routeKey) =>
      _presentations.values
          .where((value) => value.routeKey == routeKey)
          .lastOrNull;

  /// 页面实例只登记一次；字段变化更新同一实例，不因重建改变层叠顺序。
  void present(ProductAnalyticsPresentationState value) {
    if (_disposed || _presentations[value.key] == value) return;
    _presentations[value.key] = value;
    notifyListeners();
  }

  /// 弹层真正退出后恢复其下方页面，重开会产生新的页面实例。
  void dismiss(Object key) {
    if (_disposed || _presentations.remove(key) == null) return;
    notifyListeners();
  }

  /// 只有真实页面模式改变才通知统一监听器，同页重建不重复计数。
  void show(String routeKey, String pageId, {required Object owner}) {
    final previous = _pages[routeKey];
    if (_disposed ||
        previous?.pageId == pageId && identical(previous?.owner, owner)) {
      return;
    }
    _pages[routeKey] = (pageId: pageId, owner: owner);
    notifyListeners();
  }

  /// 退场释放对应实例，其他路由的当前模式不受影响。
  void remove(String routeKey, {required Object owner}) {
    if (_disposed || !identical(_pages[routeKey]?.owner, owner)) return;
    _pages.remove(routeKey);
    notifyListeners();
  }

  /// 账号容器释放后停止接收页面销毁通知。
  @override
  void dispose() {
    _disposed = true;
    _pages.clear();
    _presentations.clear();
    super.dispose();
  }
}
