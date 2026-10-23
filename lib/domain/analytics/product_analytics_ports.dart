import 'product_analytics_context.dart';
import 'product_analytics_event.dart';

/// 统计用例的事件写入出口，具体存储与上传由基础设施实现。
abstract interface class ProductAnalyticsEventWriter {
  /// 固定统计字段，不接收业务正文或设备唯一身份。
  Future<void> record(ProductAnalyticsEvent event);

  /// 尝试发送已经持久化的事件，重试不能制造新事件。
  Future<void> flush();

  /// 身份变化后停止原身份的在途上传。
  void identityChanged();

  /// 释放运行期资源，不删除未确认的持久队列。
  void dispose();
}

/// 随机操作关联的通用本地存储，命名空间和键的业务含义由应用用例解释。
abstract interface class ProductAnalyticsFlowStore {
  /// 只读取同一身份和环境下尚未过期的关联。
  Future<String?> read({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
  });

  /// 保存已观察到的关联，同一关联的有效期不因恢复而延长。
  Future<void> remember({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
    required String flowId,
  });

  /// 仅删除与预期随机流相同的关联，迟到回执不能删除后续操作。
  Future<void> forget({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
    required String? expectedFlowId,
  });

  /// 释放当前实例，已保存的数据保持不变。
  void dispose();
}
