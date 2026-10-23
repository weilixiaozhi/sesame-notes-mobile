import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/logging/logger_service.dart';
import '../../domain/analytics/product_analytics_context.dart';
import '../../domain/analytics/product_analytics_ports.dart';

/// 按环境、身份和命名空间隔离随机关联，键只在本机使用。
class PreferencesAnalyticsFlowStore implements ProductAnalyticsFlowStore {
  /// 有效期及容量是存储边界，业务实体含义由上层命名空间定义。
  PreferencesAnalyticsFlowStore({
    required this.preferences,
    required this.environment,
    required this.currentIdentity,
    DateTime Function()? clock,
    this.maxAge = const Duration(days: 90),
    this.maxEntries = 1000,
  }) : clock = clock ?? DateTime.now;
  final SharedPreferences preferences;
  final String environment;
  final ProductAnalyticsIdentity Function() currentIdentity;
  final DateTime Function() clock;
  final Duration maxAge;
  final int maxEntries;
  Future<void> _pending = Future.value();
  bool _disposed = false;

  /// 真实身份及代次都匹配才允许读取或更新本地关联。
  bool _owns(ProductAnalyticsIdentity identity) {
    final current = currentIdentity();
    return identity.account != null &&
        identity.account == current.account &&
        identity.generation == current.generation;
  }

  /// 命名空间与账号共同限定存储键，不把业务索引写入上传队列。
  String _storageKey(ProductAnalyticsIdentity identity, String namespace) =>
      'product_analytics_flows_${sha256.convert(utf8.encode('$environment|${identity.account}|$namespace'))}';

  /// 串行更新避免在途清理覆盖之后建立的新关联。
  Future<void> _serialize(Future<void> Function() action) {
    final next = _pending.then((_) async {
      if (_disposed) return;
      try {
        await action();
      } catch (error, stack) {
        logger.error(
          'ProductAnalytics',
          '操作关联暂不可用，业务数据不受影响',
          error.runtimeType,
          stack,
        );
      }
    });
    _pending = next;
    return next;
  }

  /// 只恢复合法且未过期的 UUID，损坏条目独立剔除。
  Map<String, ({String flowId, DateTime observedAt})> _load(
    ProductAnalyticsIdentity identity,
    String namespace,
  ) {
    final raw = preferences.getString(_storageKey(identity, namespace));
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    final now = clock().toUtc();
    final result = <String, ({String flowId, DateTime observedAt})>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (entry.key is! String || value is! Map) continue;
      final flow = value['flow_id'];
      final observed = DateTime.tryParse('${value['observed_at']}');
      if (flow is String &&
          Uuid.isValidUUID(fromString: flow) &&
          observed != null &&
          observed.isAfter(now.subtract(maxAge)) &&
          !observed.isAfter(now.add(const Duration(minutes: 4)))) {
        result[entry.key as String] = (flowId: flow, observedAt: observed);
      }
    }
    return result;
  }

  /// 写入结果必须得到本地存储确认，失败交给统一诊断边界处理。
  Future<void> _save(
    ProductAnalyticsIdentity identity,
    String namespace,
    Map<String, ({String flowId, DateTime observedAt})> values,
  ) async {
    final body = {
      for (final entry in values.entries)
        entry.key: {
          'flow_id': entry.value.flowId,
          'observed_at': entry.value.observedAt.toUtc().toIso8601String(),
        },
    };
    final saved = body.isEmpty
        ? await preferences.remove(_storageKey(identity, namespace))
        : await preferences.setString(
            _storageKey(identity, namespace),
            jsonEncode(body),
          );
    if (!saved) throw StateError('操作关联未成功保存');
  }

  /// 读取时同步清理过期内容，不为缺失的关联制造随机值。
  @override
  Future<String?> read({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
  }) async {
    String? result;
    await _serialize(() async {
      if (!_owns(identity)) return;
      final values = _load(identity, namespace);
      result = values[key]?.flowId;
      await _save(identity, namespace, values);
    });
    return result;
  }

  /// 同一个流保留最初观察时间，新的流才开始新的有效期。
  @override
  Future<void> remember({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
    required String flowId,
  }) => _serialize(() async {
    if (!_owns(identity) || !Uuid.isValidUUID(fromString: flowId)) return;
    final values = _load(identity, namespace);
    final previous = values.remove(key);
    values[key] = (
      flowId: flowId,
      observedAt: previous?.flowId == flowId
          ? previous!.observedAt
          : clock().toUtc(),
    );
    if (values.length > maxEntries) values.remove(values.keys.first);
    await _save(identity, namespace, values);
  });

  /// 精确清理指定旧流，迟到确认不能删除后续同键的新流。
  @override
  Future<void> forget({
    required ProductAnalyticsIdentity identity,
    required String namespace,
    required String key,
    required String? expectedFlowId,
  }) => _serialize(() async {
    if (!_owns(identity) || expectedFlowId == null) return;
    final values = _load(identity, namespace);
    if (values[key]?.flowId != expectedFlowId) return;
    values.remove(key);
    await _save(identity, namespace, values);
  });

  /// 释放实例只阻止后续工作，不移除已保存的关联。
  @override
  void dispose() => _disposed = true;
}
