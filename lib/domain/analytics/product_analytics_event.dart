import 'product_analytics_actions.dart';
import 'product_analytics_context.dart';
import 'product_analytics_pages.dart';

/// 在真实采集时刻创建的不可变事件，等待存储或上传不能改变发生时间与顺序。
class ProductAnalyticsEvent {
  /// 业务内容不属于统计协议，身份只用于本地隔离和认证校验。
  const ProductAnalyticsEvent({
    required this.eventId,
    required this.occurredAt,
    required this.sequence,
    required this.identity,
    required this.kind,
    required this.pageId,
    required this.sessionId,
    this.action,
    this.flowId,
  });
  final String eventId;
  final DateTime occurredAt;
  final int sequence;
  final ProductAnalyticsIdentity identity;
  final String kind;
  final String pageId;
  final String sessionId;
  final ProductAction? action;
  final String? flowId;

  /// 浏览与操作使用完整事件标识，活跃心跳只携带页面上下文。
  String? get eventName => switch (kind) {
    'page_view' => productAnalyticsPageViewName(pageId),
    'action' => action?.eventName,
    _ => null,
  };
}
