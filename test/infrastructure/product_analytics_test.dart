import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/infrastructure/analytics/product_analytics_service.dart';

/// 统计上报只允许受控字段和当前有效身份，业务内容不能进入遥测。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('统计上报只包含受控字段，不附带业务内容', () async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final now = DateTime.utc(2026, 10, 12);
      final batches = <List<dynamic>>[];
      final service = ProductAnalyticsService(
        dio: Dio()
          ..httpClientAdapter = _Adapter((request) {
            final batch = (request.data as Map)['events'] as List;
            batches.add(jsonDecode(jsonEncode(batch)) as List);
            return _json({'accepted': batch.length, 'duplicates': 0});
          }),
        preferences: preferences,
        accountId: () => 'a',
        accessToken: () => 'token',
        identityGeneration: () => 1,
        clock: () => now,
      );
      addTearDown(service.dispose);
      await _record(
        service,
        sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        account: 'a',
        kind: 'action',
        pageId: 'accounting.transaction.editor',
        eventName: ProductAction.accountingTransactionCreated.eventName,
      );
      await service.flush();
      expect(batches.single.single.keys.toSet(), {
        'event_id',
        'occurred_at',
        'kind',
        'page_id',
        'platform',
        'event_name',
        'session_id',
        'event_sequence',
      });
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('无效操作和已失效身份不进入离线队列', () async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final service = ProductAnalyticsService(
        dio: Dio(),
        preferences: preferences,
        accountId: () => 'a',
        accessToken: () => 'token',
        identityGeneration: () => 2,
      );
      addTearDown(service.dispose);
      await _record(
        service,
        sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        account: 'a',
        kind: 'action',
        pageId: 'memos.editor',
        eventName: 'private_note_title',
      );
      await _record(
        service,
        sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        account: 'a',
        kind: 'action',
        pageId: 'memos.editor',
        eventName: 'memos_note_saved',
        generation: 1,
      );
      expect(preferences.getKeys(), isEmpty);
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}

/// 测试响应为协议 JSON，不请求真实网络。
ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

/// 可编排 HTTP 返回值的测试传输。
class _Adapter implements HttpClientAdapter {
  /// 注入受控响应，保留生产服务实际生成的上报正文。
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  /// 返回注入的协议响应，不向真实服务发送测试事件。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  /// 测试适配器不持有外部网络连接。
  @override
  void close({bool force = false}) {}
}

/// 构造受控统计事件，允许校验未知操作和失效身份的拒收边界。
Future<void> _record(
  ProductAnalyticsService service, {
  required String account,
  required String kind,
  required String pageId,
  required String sessionId,
  required String eventName,
  int? generation,
}) => service.record(
  ProductAnalyticsEvent(
    eventId: const Uuid().v4(),
    occurredAt: service.clock(),
    sequence: 1,
    identity: ProductAnalyticsIdentity(
      account,
      generation ?? service.identityGeneration(),
    ),
    kind: kind,
    pageId: pageId,
    sessionId: sessionId,
    action: ProductAction.values
        .where((value) => value.eventName == eventName)
        .firstOrNull,
  ),
);
