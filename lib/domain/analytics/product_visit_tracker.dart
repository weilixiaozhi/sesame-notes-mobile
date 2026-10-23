/// 可测试的前台访问判定；路由重建和凭据刷新不会制造重复浏览。
class ProductVisitTracker {
  String? _account;
  String? _page;
  String? _visitKey;
  bool _visible = false;
  DateTime? _lastActive;

  /// 首次进入或实际切页记录浏览，恢复同页仅记录活跃。
  String? observe({
    required String? account,
    required String? page,
    required bool visible,
    required DateTime now,
    String? visitKey,
  }) {
    final changedAccount = _account != account;
    if (changedAccount) {
      _account = account;
      _page = null;
      _visitKey = null;
      _lastActive = null;
      _visible = false;
    }
    if (!visible || account == null || page == null) {
      _visible = false;
      if (visible && page == null) _page = null;
      return null;
    }
    final newPage = _page != page || _visitKey != (visitKey ?? page);
    final resumed = !_visible;
    _visible = true;
    _page = page;
    _visitKey = visitKey ?? page;
    if (newPage || resumed) {
      _lastActive = now;
      return newPage ? 'page_view' : 'active';
    }
    return null;
  }

  /// 持续使用同页以实际触摸触发活跃；跨北京时间自然日立即记录，不依赖定时心跳。
  bool interact(DateTime now) {
    if (!_visible || _account == null || _page == null) return false;
    final prior = _lastActive;
    final china = now.toUtc().add(const Duration(hours: 8));
    final previous = prior?.toUtc().add(const Duration(hours: 8));
    if (prior != null &&
        now.difference(prior) < const Duration(minutes: 5) &&
        previous!.year == china.year &&
        previous.month == china.month &&
        previous.day == china.day) {
      return false;
    }
    _lastActive = now;
    return true;
  }
}
