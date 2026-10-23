import 'package:uuid/uuid.dart';

/// 异步操作固定开始时的统计身份，空账号也必须保留，避免完成时归属新登录账号。
class ProductAnalyticsIdentity {
  /// 保存认证账号与身份代次，不持有凭据、页面或业务数据。
  const ProductAnalyticsIdentity(this.account, this.generation);
  final String? account;
  final int generation;
}

/// 应用层只接收已解析的身份与采集许可，不读取界面、路由或认证组件。
class ProductAnalyticsRuntime {
  /// enabled 表示当前应用已经启动、可见且允许采集。
  const ProductAnalyticsRuntime({
    required this.identity,
    required this.enabled,
  });
  final ProductAnalyticsIdentity identity;
  final bool enabled;
}

/// 一个实际事件的不可变归属，异步成功沿用点击时捕获的会话和操作流。
class ProductAnalyticsContext {
  /// 会话与操作流均使用独立随机 UUID，不以业务记录标识替代。
  const ProductAnalyticsContext({
    required this.identity,
    this.sessionId,
    this.flowId,
    this.initiatedInForeground = false,
  });
  final ProductAnalyticsIdentity identity;
  final String? sessionId;
  final String? flowId;
  final bool initiatedInForeground;

  /// 只替换操作流，保留本次动作已经捕获的身份和会话。
  ProductAnalyticsContext withFlowId(String? value) => ProductAnalyticsContext(
    identity: identity,
    sessionId: sessionId,
    flowId: value,
    initiatedInForeground: initiatedInForeground,
  );
}

/// 操作已经开始等待时仍使用原会话，仅新分配随机操作流。
ProductAnalyticsContext beginProductAnalyticsFlowFrom(
  ProductAnalyticsContext context,
) => context.withFlowId(const Uuid().v4());

/// 前台真实交互维持账号会话；三十分钟闲置或身份变化时切换随机会话。
class ProductAnalyticsSessionTracker {
  String? _account;
  int? _generation;
  String? _session;
  DateTime? _lastInteraction;

  /// 只由真实页面访问或交互调用，后台重传不会调用该入口。
  String? interact(ProductAnalyticsIdentity identity, DateTime now) {
    if (identity.account == null) {
      reset();
      return null;
    }
    final changed =
        _account != identity.account || _generation != identity.generation;
    final previous = _lastInteraction;
    if (changed ||
        _session == null ||
        previous == null ||
        now.difference(previous) >= const Duration(minutes: 30)) {
      _session = const Uuid().v4();
    }
    _account = identity.account;
    _generation = identity.generation;
    _lastInteraction = now;
    return _session;
  }

  /// 退出和账号切换立即清空当前会话，旧异步上下文仍由身份校验拒绝。
  void reset() {
    _account = null;
    _generation = null;
    _session = null;
    _lastInteraction = null;
  }
}
