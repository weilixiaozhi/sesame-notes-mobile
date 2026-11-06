import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/infrastructure/analytics/product_analytics_service.dart';

/// 插件内存缓存与真正落盘分离，统计调用次数并模拟平台拒绝写入。
class _Store extends InMemorySharedPreferencesStore {
  /// 每个用例使用独立平台存储，避免复用插件内存缓存。
  _Store() : super.empty();
  int writes = 0;
  int removals = 0;
  bool rejectWrites = false;

  /// 只记录事件队列，不混入日志等其他持久化调用。
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key.contains('product_analytics_v1_')) {
      writes++;
      if (rejectWrites) return false;
    }
    return super.setValue(type, key, value);
  }

  /// 队列清空后重复刷新不应重复调用平台删除。
  @override
  Future<bool> remove(String key) async {
    if (key.contains('product_analytics_v1_')) removals++;
    return super.remove(key);
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

/// 事件身份固定，重试和持久化优化都不能更改原事件。
ProductAnalyticsEvent _event(DateTime now) => ProductAnalyticsEvent(
  eventId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  occurredAt: now,
  sequence: 1,
  identity: const ProductAnalyticsIdentity('account', 1),
  kind: 'page_view',
  pageId: 'memos',
  sessionId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
);

/// 验证跳过的是重复落盘，存储失败与数据清洗仍进入真实持久化边界。
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

  test('未变离线重试不重复写队列，确认后空闲刷新不重复删除', () async {
    var now = DateTime.utc(2026, 11, 6);
    var failing = true;
    var requests = 0;
    final dio = Dio()
      ..httpClientAdapter = _Adapter((request) {
        requests++;
        return ResponseBody.fromString(
          failing ? '{}' : jsonEncode({'accepted': 1, 'duplicates': 0}),
          failing ? 503 : 200,
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
      await service.record(_event(now));
      expect(store.writes, 1);
      await service.flush();
      now = now.add(const Duration(seconds: 31));
      await service.flush();
      expect(requests, 2);
      expect(store.writes, 1, reason: '读取上传快照不重复写同一份队列');
      failing = false;
      now = now.add(const Duration(seconds: 31));
      await service.flush();
      expect(store.removals, 1);
      for (var i = 0; i < 5; i++) {
        await service.flush();
      }
      expect(store.removals, 1);
      expect(requests, 3);
    } catch (error, stack) {
      printOnFailure('统计重复落盘回归失败：$error\n$stack');
      rethrow;
    } finally {
      service.dispose();
      dio.close();
    }
  });

  test('平台拒绝写入时不能把偏好内存缓存当作已确认落盘', () async {
    final now = DateTime.utc(2026, 11, 6);
    var requests = 0;
    final dio = Dio()
      ..httpClientAdapter = _Adapter((request) {
        requests++;
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
      await service.record(_event(now));
      await service.flush();
      expect(store.writes, 2);
      expect(requests, 0, reason: '仍未落盘的事件不能当作可靠队列发送');
      store.rejectWrites = false;
      await service.flush();
      expect(store.writes, 3);
      expect(requests, 1);
      expect(store.removals, 1);
    } catch (error, stack) {
      printOnFailure('统计持久化失败重试回归失败：$error\n$stack');
      rethrow;
    } finally {
      service.dispose();
      dio.close();
    }
  });
}
