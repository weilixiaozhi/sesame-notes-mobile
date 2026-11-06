import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/infrastructure/analytics/product_analytics_service.dart';

/// 插件内存缓存与平台存储分离，模拟队列持久化失败。
class _Store extends InMemorySharedPreferencesStore {
  /// 每个用例使用独立平台存储，避免复用插件内存缓存。
  _Store() : super.empty();
  bool rejectWrites = false;

  /// 拒绝事件队列写入时保持平台存储原样，其他偏好正常保存。
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    try {
      if (rejectWrites && key.contains('product_analytics_v1_')) return false;
      return await super.setValue(type, key, value);
    } catch (error, stackTrace) {
      logger.error(
        'AnalyticsPersistenceTest',
        '准备队列持久化结果失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}

/// 上传只返回受控确认，不访问真实统计服务。
class _Adapter implements HttpClientAdapter {
  /// 注入成功或失败回包，保留生产请求和确认流程。
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  /// 请求仅交给本用例的返回函数，不执行网络传输。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  /// 测试传输不持有外部连接。
  @override
  void close({bool force = false}) {}
}

/// 固定事件身份，核对恢复持久化后发送的仍是原事件。
ProductAnalyticsEvent _event(DateTime now) => ProductAnalyticsEvent(
  eventId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  occurredAt: now,
  sequence: 1,
  identity: const ProductAnalyticsIdentity('account', 1),
  kind: 'page_view',
  pageId: 'memos',
  sessionId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
);

/// 验证未落盘事件禁止发送，恢复平台存储后原事件可以继续交付。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesStorePlatform previous;
  late _Store store;
  late SharedPreferences preferences;
  setUp(() async {
    previous = SharedPreferencesStorePlatform.instance;
    store = _Store();
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = store;
    preferences = await SharedPreferences.getInstance();
  });
  tearDown(() async {
    await logger.clear();
    SharedPreferencesStorePlatform.instance = previous;
    SharedPreferences.resetStatic();
  });

  test('平台拒绝写入时不能把偏好内存缓存当作已确认落盘', () async {
    final now = DateTime.utc(2026, 11, 6);
    final event = _event(now);
    final batches = <List<dynamic>>[];
    final dio = Dio()
      ..httpClientAdapter = _Adapter((request) {
        batches.add((request.data as Map)['events'] as List<dynamic>);
        return ResponseBody.fromString(
          jsonEncode({'accepted': 1, 'duplicates': 0}),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
    final service = ProductAnalyticsService(
      dio: dio,
      preferences: preferences,
      accountId: () => 'account',
      accessToken: () => 'token',
      identityGeneration: () => 1,
      clock: () => now,
    );
    try {
      store.rejectWrites = true;
      await service.record(event);
      await service.flush();
      expect(batches, isEmpty, reason: '仍未落盘的事件不能当作可靠队列发送');
      store.rejectWrites = false;
      await service.flush();
      expect(batches.last.map((value) => value['event_id']), [event.eventId]);
    } catch (error, stack) {
      printOnFailure('统计持久化失败重试回归失败：$error\n$stack');
      rethrow;
    } finally {
      service.dispose();
      dio.close();
    }
  });
}
