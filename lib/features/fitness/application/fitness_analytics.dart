import '../../../core/logging/logger_service.dart';
import '../../../domain/analytics/product_analytics_context.dart';
import '../../../domain/analytics/product_analytics_ports.dart';
import '../../../shared/application/product_analytics_controller.dart';

/// 训练用例解释本地记录与随机流的关联，通用采集和存储不认识训练实体。
class FitnessAnalytics {
  /// 身份与会话由通用控制器提供，关联只通过领域端口存取。
  FitnessAnalytics({
    required this.controller,
    required Future<ProductAnalyticsFlowStore> Function() store,
  }) : _storeFactory = store;
  final ProductAnalyticsController controller;
  final Future<ProductAnalyticsFlowStore> Function() _storeFactory;
  static const _namespace = 'fitness.workout';

  /// 导航前固定本次交互上下文，再恢复确实观察到的训练开始关联。
  Future<ProductAnalyticsContext> navigationContext(String workoutId) async {
    final entered = controller.captureContext();
    return entered.withFlowId(
      await restore(identity: entered.identity, workoutId: workoutId),
    );
  }

  /// 缺少已观察到的开始时保持无关联，不根据训练状态补造开始事件。
  Future<String?> restore({
    required ProductAnalyticsIdentity identity,
    required String workoutId,
  }) async {
    if (identity.account == null) return null;
    try {
      return await (await _storeFactory()).read(
        identity: identity,
        namespace: _namespace,
        key: workoutId,
      );
    } catch (error, stack) {
      logger.error(
        'FitnessAnalytics',
        '训练统计关联暂不可用，训练功能不受影响',
        error.runtimeType,
        stack,
      );
      return null;
    }
  }

  /// 仅真实开始成功后保存关联，业务记录索引不会进入统计上传正文。
  Future<void> remember({
    required ProductAnalyticsContext context,
    required String workoutId,
  }) async {
    if (context.identity.account == null || context.flowId == null) return;
    try {
      await (await _storeFactory()).remember(
        identity: context.identity,
        namespace: _namespace,
        key: workoutId,
        flowId: context.flowId!,
      );
    } catch (error, stack) {
      logger.error(
        'FitnessAnalytics',
        '训练统计关联暂不可用，训练记录不受影响',
        error.runtimeType,
        stack,
      );
    }
  }

  /// 真实完成或删除只清理对应流，迟到回执保留后续重新开始的关联。
  Future<void> forget({
    required ProductAnalyticsContext context,
    required String workoutId,
  }) async {
    if (context.identity.account == null) return;
    try {
      await (await _storeFactory()).forget(
        identity: context.identity,
        namespace: _namespace,
        key: workoutId,
        expectedFlowId: context.flowId,
      );
    } catch (error, stack) {
      logger.error(
        'FitnessAnalytics',
        '训练统计关联暂不可用，训练记录不受影响',
        error.runtimeType,
        stack,
      );
    }
  }
}
