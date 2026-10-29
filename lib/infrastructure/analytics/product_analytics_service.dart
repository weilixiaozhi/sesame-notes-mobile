import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/analytics/product_banner_dimensions.dart';

import '../../core/logging/logger_service.dart';
import '../../domain/analytics/product_analytics_actions.dart';
import '../../domain/analytics/product_analytics_ports.dart';
import '../../domain/analytics/product_analytics_event.dart';
import '../../domain/analytics/product_analytics_pages.dart';

/// 已登录账号的可靠事件队列；本地归属只用于隔离，不进入上报正文。
class ProductAnalyticsService implements ProductAnalyticsEventWriter {
  /// 请求认证与刷新由应用统一 Dio 管理，身份读取必须返回当前实时状态。
  ProductAnalyticsService({
    required this.dio,
    required this.preferences,
    required this.accountId,
    required this.accessToken,
    required this.identityGeneration,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final Dio dio;
  final SharedPreferences preferences;
  final String? Function() accountId;
  final String? Function() accessToken;
  final int Function() identityGeneration;
  final DateTime Function() clock;
  Future<void> _pending = Future.value();
  Future<void>? _flushInFlight;
  CancelToken? _request;
  bool _disposed = false;
  DateTime? _retryAfter;

  /// 环境和账号共同组成缓存键，切换服务端后不能把旧环境事件补报到新环境。
  String _key(String account) =>
      'product_analytics_v1_${sha256.convert(utf8.encode('${dio.options.baseUrl}|$account'))}';

  /// 账号退出或更换时取消在途传输；未确认事件继续保留在原账号队列。
  @override
  void identityChanged() {
    _request?.cancel('统计队列账号已变化');
    _retryAfter = null;
  }

  /// 释放服务只取消网络，不清空尚未补报的本地事件。
  @override
  void dispose() {
    _disposed = true;
    _request?.cancel('统计服务已释放');
  }

  /// 所有读写串行执行，防止上报确认覆盖期间追加的事件。
  Future<void> _serialize(Future<void> Function() action) {
    final next = _pending.then((_) async {
      if (_disposed) return;
      try {
        await action();
      } catch (error, stackTrace) {
        logger.error(
          'ProductAnalytics',
          '使用统计暂不可用，应用功能不受影响',
          error,
          stackTrace,
        );
      }
    });
    _pending = next;
    return next;
  }

  /// 仅由前台真实页面或交互调用；先持久化再传输，重试沿用同一个事件 ID。
  @override
  Future<void> record(ProductAnalyticsEvent event) {
    final account = event.identity.account;
    final generation = event.identity.generation;
    final kind = event.kind;
    final pageId = event.pageId;
    final sessionId = event.sessionId;
    final flowId = event.flowId;
    final sequence = event.sequence;
    final eventName = event.eventName;
    return _serialize(() async {
      if (account == null ||
          accountId() != account ||
          identityGeneration() != generation) {
        return;
      }
      // 固定事件契约拒绝无效组合，避免一个无效动作导致整批离线事件被服务端拒绝。
      if (!productAnalyticsPageIds.contains(pageId) ||
          !Uuid.isValidUUID(fromString: sessionId) ||
          !Uuid.isValidUUID(fromString: event.eventId) ||
          sequence < 1 ||
          sequence > 2147483647 ||
          !_validOptionalUuid(flowId) ||
          !ProductBannerDimensions.validEvent(
            eventName,
            pageId,
            event.banner?.toJson() ?? const {},
          ) ||
          (kind != 'action' && event.action != null) ||
          !_validEventName(kind, pageId, eventName)) {
        throw ArgumentError('统计事件标识无效');
      }
      final queue = _read(account);
      queue.add({
        'event_id': event.eventId,
        'occurred_at': event.occurredAt.toUtc().toIso8601String(),
        'kind': kind,
        'page_id': pageId,
        'platform': 'app',
        'event_name': ?eventName,
        'session_id': sessionId,
        'event_sequence': sequence,
        'flow_id': ?flowId,
        ...?event.banner?.toJson(),
      });
      // 只保留有界统计积压，避免长时间离线占用不断增长的偏好文件。
      if (queue.length > 5000) {
        queue.removeRange(0, queue.length - 5000);
        logger.warning('ProductAnalytics', '离线事件已达到容量上限，已保留最近 5000 条');
      }
      await _save(account, queue);
    });
  }

  /// 重试只传输已有事件，不产生新的活跃或浏览事件。
  @override
  Future<void> flush() {
    final active = _flushInFlight;
    if (active != null) return active;
    late final Future<void> pending;
    pending = _flushOnce().whenComplete(() {
      if (identical(_flushInFlight, pending)) _flushInFlight = null;
    });
    _flushInFlight = pending;
    return pending;
  }

  /// 只在读取快照和确认时占用本地写锁，慢网络期间新事件仍立即落盘。
  Future<void> _flushOnce() async {
    final account = accountId();
    final token = accessToken();
    if (_disposed ||
        account == null ||
        token == null ||
        token.isEmpty ||
        _retryAfter != null && clock().isBefore(_retryAfter!)) {
      return;
    }
    final generation = identityGeneration();
    var batch = <Map<String, dynamic>>[];
    await _serialize(() async {
      final queue = _read(account);
      await _save(account, queue);
      batch = queue.take(100).toList(growable: false);
    });
    if (_disposed ||
        batch.isEmpty ||
        accountId() != account ||
        identityGeneration() != generation) {
      return;
    }
    final cancel = CancelToken();
    _request = cancel;
    try {
      final response = await dio.post<Object?>(
        '/api/v1/analytics/events',
        data: {'events': batch},
        cancelToken: cancel,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          extra: {'sesame_request_identity': generation},
        ),
      );
      final body = response.data;
      if (body is! Map ||
          body['accepted'] is! int ||
          body['duplicates'] is! int ||
          body['accepted'] < 0 ||
          body['duplicates'] < 0 ||
          body['accepted'] + body['duplicates'] != batch.length) {
        throw const FormatException('ANALYTICS_ACK_INVALID');
      }
      // 回包即使跨越退出，只能确认原账号这批 UUID，绝不写入新账号队列。
      await _acknowledge(account, batch);
      _retryAfter = null;
    } on DioException catch (error, stackTrace) {
      if (error.response?.statusCode == 400) {
        await _acknowledge(account, batch);
        logger.warning(
          'ProductAnalytics',
          '服务端拒绝无效统计批次，已移除该批事件：${error.response?.statusCode}',
        );
      } else if (!CancelToken.isCancel(error)) {
        _retryAfter = clock().add(const Duration(seconds: 30));
        logger.error(
          'ProductAnalytics',
          '统计上传失败，已保留队列等待重试',
          error.type,
          stackTrace,
        );
      }
    } catch (error, stackTrace) {
      _retryAfter = clock().add(const Duration(seconds: 30));
      logger.error('ProductAnalytics', '统计确认失败，已保留队列等待重试', error, stackTrace);
    } finally {
      if (identical(_request, cancel)) _request = null;
    }
  }

  /// 精确移除服务器已确认的 UUID，保留上传期间追加的新事件。
  Future<void> _acknowledge(String account, List<Map<String, dynamic>> batch) =>
      _serialize(() async {
        final ids = batch.map((event) => event['event_id']).toSet();
        final current = _read(account)
          ..removeWhere((event) => ids.contains(event['event_id']));
        await _save(account, current);
      });

  /// 读取时剔除过期与异常未来时间，并以 UUID 去重，避免损坏条目阻塞后续批次。
  List<Map<String, dynamic>> _read(String account) {
    try {
      final raw = preferences.getString(_key(account));
      if (raw == null) return [];
      final now = clock().toUtc();
      final seen = <String>{};
      final result = <Map<String, dynamic>>[];
      var invalid = 0;
      for (final row in jsonDecode(raw) as List) {
        if (row is! Map) {
          invalid++;
          continue;
        }
        final id = row['event_id'];
        final occurred = DateTime.tryParse('${row['occurred_at']}');
        final kind = row['kind'];
        final eventName = row['event_name'];
        final page = row['page_id'];
        final sessionId = row['session_id'];
        final sequence = row['event_sequence'];
        final flowId = row['flow_id'];
        if (id is! String ||
            !Uuid.isValidUUID(fromString: id) ||
            row['occurred_at'] is! String ||
            occurred == null ||
            !occurred.isAfter(now.subtract(const Duration(days: 90))) ||
            occurred.isAfter(now.add(const Duration(minutes: 4))) ||
            !productAnalyticsPageIds.contains(page) ||
            row['platform'] != 'app' ||
            sessionId is! String ||
            !Uuid.isValidUUID(fromString: sessionId) ||
            sequence is! int ||
            sequence < 1 ||
            sequence > 2147483647 ||
            !_validOptionalUuid(flowId) ||
            !ProductBannerDimensions.validEvent(
              eventName is String ? eventName : null,
              page,
              row,
            ) ||
            !_validEventName(kind, page, eventName) ||
            !seen.add(id)) {
          invalid++;
          continue;
        }
        // 重建固定字段，损坏缓存中的任意正文和未知字段不会进入请求正文。
        result.add({
          'event_id': id,
          'occurred_at': row['occurred_at'],
          'kind': kind,
          'page_id': page,
          'platform': 'app',
          'event_name': ?eventName,
          'session_id': sessionId,
          'event_sequence': sequence,
          'flow_id': ?flowId,
          ...?ProductBannerDimensions.parse(row)?.toJson(),
        });
      }
      if (invalid > 0) {
        logger.warning('ProductAnalytics', '已过滤 $invalid 条无效或重复统计事件');
      }
      return result;
    } catch (error, stackTrace) {
      logger.error('ProductAnalytics', '统计队列读取失败，将重新建立队列', error, stackTrace);
      return [];
    }
  }

  /// 写入失败显式记录，不把未落盘内容当作可靠上报成功。
  Future<void> _save(String account, List<Map<String, dynamic>> queue) async {
    final saved = queue.isEmpty
        ? await preferences.remove(_key(account))
        : await preferences.setString(_key(account), jsonEncode(queue));
    if (!saved) throw StateError('统计队列保存失败');
  }

  /// 操作流只接收随机 UUID，尚未形成明确业务流时允许空值。
  bool _validOptionalUuid(Object? value) =>
      value == null || value is String && Uuid.isValidUUID(fromString: value);

  /// 新记录与离线恢复共用类型约束，页面事件必须与页面上下文精确对应。
  bool _validEventName(Object? kind, Object? pageId, Object? name) =>
      switch (kind) {
        'active' => name == null,
        'page_view' =>
          pageId is String && name == productAnalyticsPageViewName(pageId),
        'action' => ProductAction.values.any(
          (action) => action.eventName == name,
        ),
        _ => false,
      };
}
