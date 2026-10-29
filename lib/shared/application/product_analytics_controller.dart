import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../core/logging/logger_service.dart';
import '../../domain/analytics/product_analytics_actions.dart';
import '../../domain/analytics/product_analytics_context.dart';
import '../../domain/analytics/product_analytics_event.dart';
import '../../domain/analytics/product_analytics_ports.dart';
import '../../domain/analytics/product_visit_tracker.dart';
import '../../domain/analytics/product_banner_dimensions.dart';

/// 采集用例统一管理身份、会话、访问与动作；不依赖界面或传输实现。
class ProductAnalyticsController {
  /// 运行态和时钟由装配层提供，写入端可以异步准备而不延迟交互上下文捕获。
  ProductAnalyticsController({
    required Future<ProductAnalyticsEventWriter> Function() writer,
    required ProductAnalyticsRuntime Function() runtime,
    DateTime Function()? clock,
  }) : _writerFactory = writer,
       _runtimeReader = runtime,
       _clock = clock ?? DateTime.now;
  final Future<ProductAnalyticsEventWriter> Function() _writerFactory;
  final ProductAnalyticsRuntime Function() _runtimeReader;
  Future<ProductAnalyticsEventWriter>? _activeWriter;
  final DateTime Function() _clock;
  final _sessions = ProductAnalyticsSessionTracker();
  ProductVisitTracker _visits = ProductVisitTracker();
  bool _disposed = false;
  int _sequence = 0;
  String? _visiblePage;
  final _bannerImpressions = <(String, String, String, int)>{};
  final _visibilityListeners = <void Function()>{};

  /// 图片展示观察者在页面访问或可见性改变后重验当前素材，不自行制造页面访问。
  void addVisibilityListener(void Function() listener) =>
      _visibilityListeners.add(listener);

  /// 页面组件释放时移除观察回调，不影响其他采集者。
  void removeVisibilityListener(void Function() listener) =>
      _visibilityListeners.remove(listener);

  /// 通知只承载内存可见性，观察失败不得影响已有页面采集。
  void _notifyVisibility() {
    for (final listener in _visibilityListeners.toList()) {
      try {
        listener();
      } catch (error, stack) {
        logger.error('ProductAnalytics', '素材可见性观察失败', error.runtimeType, stack);
      }
    }
  }

  /// 只有当前真实页面的有效前台账号可记录横幅，曝光跟随页面访问周期去重。
  void trackBanner({
    required String pageId,
    required ProductAction action,
    required ProductBannerDimensions banner,
  }) {
    try {
      final state = _snapshot();
      if (_disposed ||
          !state.enabled ||
          state.identity.account == null ||
          _visiblePage != pageId ||
          !banner.isValid ||
          banner.pageId != pageId ||
          (action != ProductAction.bannerImpression &&
              action != ProductAction.bannerClick)) {
        return;
      }
      if (action == ProductAction.bannerImpression &&
          !_bannerImpressions.add(banner.key)) {
        return;
      }
      _enqueue('action', pageId, captureContext(), action, banner);
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '横幅统计暂不可用，入口功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 无法读取身份时返回不可采集状态，统计异常不阻止业务操作。
  ProductAnalyticsRuntime _snapshot() {
    try {
      return _runtimeReader();
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '使用统计状态暂不可用，业务功能不受影响',
        error.runtimeType,
        stack,
      );
      return const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity(null, -1),
        enabled: false,
      );
    }
  }

  /// 读取当前身份代次，不读取或暴露认证凭据。
  ProductAnalyticsIdentity currentIdentity() => _snapshot().identity;

  /// 只由真实交互维持会话，显式父上下文保持原账号及操作流。
  ProductAnalyticsContext captureContext({
    ProductAnalyticsContext? parent,
    bool newFlow = false,
  }) {
    final state = _snapshot();
    final identity = parent?.identity ?? state.identity;
    final eligible =
        !_disposed &&
        state.enabled &&
        identity.account != null &&
        _same(identity, state.identity);
    try {
      return ProductAnalyticsContext(
        identity: identity,
        sessionId: eligible ? _sessions.interact(identity, _clock()) : null,
        flowId: newFlow ? const Uuid().v4() : parent?.flowId,
        initiatedInForeground: eligible,
      );
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '使用会话暂不可用，业务功能不受影响',
        error.runtimeType,
        stack,
      );
      return ProductAnalyticsContext(
        identity: identity,
        flowId: parent?.flowId,
      );
    }
  }

  /// 明确的新建或重新进入操作分配独立随机流。
  ProductAnalyticsContext beginFlow() => captureContext(newFlow: true);

  /// 只有账号与身份代次都相同才允许复用操作上下文。
  bool _same(ProductAnalyticsIdentity a, ProductAnalyticsIdentity b) =>
      a.account == b.account && a.generation == b.generation;

  /// 点击使用当前可见会话，异步完成可以沿用最初真实交互的上下文。
  void trackAction({
    required String pageId,
    required ProductAction action,
    ProductAnalyticsContext? context,
  }) {
    final captured = context ?? captureContext();
    final state = _snapshot();
    if (_disposed ||
        !captured.initiatedInForeground ||
        !_same(captured.identity, state.identity)) {
      return;
    }
    _enqueue('action', pageId, captured, action);
  }

  /// 写入前固定采集出口，页面退出后无需再次访问页面依赖或借用新账号。
  void Function(ProductAction) captureCompletion({
    required String pageId,
    required ProductAnalyticsContext context,
  }) {
    if (_disposed ||
        !context.initiatedInForeground ||
        context.sessionId == null ||
        !_same(context.identity, currentIdentity())) {
      return (_) {};
    }
    return (action) {
      if (!_disposed && _same(context.identity, currentIdentity())) {
        _enqueue('action', pageId, context, action);
      }
    };
  }

  /// 可见页面改变产生一次访问；同页恢复只记录活跃。
  void observePage({
    required String? pageId,
    required String visitKey,
    ProductAnalyticsContext? context,
  }) {
    try {
      _observePage(pageId: pageId, visitKey: visitKey, context: context);
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '页面统计暂不可用，界面功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 先校验上下文再推进访问状态，迟到页面不能消耗当前账号的首个访问或节流窗口。
  bool _observePage({
    required String? pageId,
    required String visitKey,
    ProductAnalyticsContext? context,
  }) {
    final state = _snapshot();
    final visible = !_disposed && state.enabled;
    if (visible &&
        state.identity.account != null &&
        context != null &&
        !_same(context.identity, state.identity)) {
      return false;
    }
    final kind = _visits.observe(
      account: state.identity.account,
      page: pageId,
      visible: visible,
      now: _clock(),
      visitKey: visitKey,
    );
    final nextPage = visible && state.identity.account != null ? pageId : null;
    final changed = _visiblePage != nextPage || kind == 'page_view';
    _visiblePage = nextPage;
    if (kind == 'page_view') _bannerImpressions.clear();
    if (!visible || state.identity.account == null || pageId == null) {
      if (changed) _notifyVisibility();
      return false;
    }
    if (kind != null) _enqueue(kind, pageId, captureContext(parent: context));
    if (changed) _notifyVisibility();
    return true;
  }

  /// 真实触摸只按节流规则记录活跃，不把重绘或补报计为交互。
  void interactPage({
    required String? pageId,
    required String visitKey,
    ProductAnalyticsContext? context,
  }) {
    try {
      if (!_observePage(pageId: pageId, visitKey: visitKey, context: context)) {
        return;
      }
      final captured = captureContext(parent: context);
      if (pageId != null && _visits.interact(_clock())) {
        _enqueue('active', pageId, captured);
      }
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '交互统计暂不可用，界面功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 事件只携带受控字段和随机关联，缺少有效会话时记录诊断并忽略。
  void _enqueue(
    String kind,
    String page,
    ProductAnalyticsContext context, [
    ProductAction? action,
    ProductBannerDimensions? banner,
  ]) {
    if (_disposed || context.identity.account == null) return;
    if (context.sessionId == null) {
      logger.warning('ProductAnalytics', '缺少有效使用会话，本次事件未采集');
      return;
    }
    try {
      final event = ProductAnalyticsEvent(
        eventId: const Uuid().v4(),
        occurredAt: _clock().toUtc(),
        sequence: ++_sequence,
        identity: context.identity,
        kind: kind,
        pageId: page,
        sessionId: context.sessionId!,
        action: action,
        flowId: context.flowId,
        banner: banner,
      );
      unawaited(_record(event));
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '统计事件暂时无法创建，业务功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 真正需要写入时才装配存储与网络，未登录界面不创建无用依赖。
  Future<ProductAnalyticsEventWriter> _writer() {
    final pending = _writerFactory();
    _activeWriter = pending;
    return pending;
  }

  /// 等待写入端准备后再次验证身份，统计失败独立于业务结果。
  Future<void> _record(ProductAnalyticsEvent event) async {
    try {
      final writer = await _writer();
      if (_disposed || !_same(event.identity, currentIdentity())) return;
      await writer.record(event);
      await writer.flush();
    } catch (error, stack) {
      logger.error(
        'ProductAnalytics',
        '使用统计暂不可用，业务功能不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 补报只消费已记录事件，不延长会话或重新分配事件身份。
  Future<void> flush() async {
    try {
      final state = _snapshot();
      if (!_disposed && state.enabled && state.identity.account != null) {
        await (await _writer()).flush();
      }
    } catch (error, stack) {
      logger.error('ProductAnalytics', '统计补报暂不可用', error.runtimeType, stack);
    }
  }

  /// 身份变化立即清空运行期会话和访问判定，并停止原身份请求。
  void identityChanged() {
    _sessions.reset();
    _visits = ProductVisitTracker();
    _visiblePage = null;
    _bannerImpressions.clear();
    _notifyVisibility();
    if (_activeWriter != null) unawaited(_cancelIdentity());
  }

  /// 写入端尚未就绪时也能安全完成身份取消。
  Future<void> _cancelIdentity() async {
    try {
      final pending = _activeWriter;
      if (pending != null) (await pending).identityChanged();
    } catch (error, stack) {
      logger.error('ProductAnalytics', '统计身份切换暂不可用', error.runtimeType, stack);
    }
  }

  /// 用例释放后停止采集，写入端生命周期由其装配者统一管理。
  void dispose() {
    _disposed = true;
    _sessions.reset();
    _visibilityListeners.clear();
    _bannerImpressions.clear();
  }
}
