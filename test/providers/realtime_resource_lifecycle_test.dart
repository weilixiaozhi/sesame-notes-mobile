import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/sync/realtime_client.dart';

/// 记录连接池释放协议；挂起响应支持验证销毁不会强制中断已经开始的请求。
class _LifecycleAdapter implements HttpClientAdapter {
  final response = Completer<ResponseBody>();
  final entered = Completer<void>();
  final closeForces = <bool>[];

  /// 接收一个在途请求，由测试控制响应时机。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    entered.complete();
    return response.future;
  }

  /// 保存所有者传入的关闭参数。
  @override
  void close({bool force = false}) => closeForces.add(force);
}

/// 记录通知资源是否随着容器或配置结束而关闭。
class _LifecycleSocket implements RealtimeSocket {
  final controller = StreamController<dynamic>();
  Object? closeError;
  int closeCalls = 0;

  @override
  Stream<dynamic> get messages => controller.stream;

  /// 停止消息流，保留关闭状态供测试检查。
  @override
  Future<void> close() async {
    closeCalls++;
    await controller.close();
    if (closeError case final error?) throw error;
  }
}

/// 构造仅含真实通知生命周期所需依赖的容器。
ProviderContainer _container() => ProviderContainer(
  overrides: [
    apiConfigProvider.overrideWithValue(
      const ApiConfig(baseUrl: 'https://example.test'),
    ),
    cloudNetworkEventsProvider.overrideWithValue(const Stream<bool>.empty()),
  ],
);

/// 建立有效内存身份，令实时协调器可以发起连接。
void _signIn(ProviderContainer container) {
  container
      .read(authSessionProvider.notifier)
      .signIn(
        const AuthSession(
          accessToken: 'at',
          userId: 'user-a',
          deviceId: 'device-a',
        ),
      );
}

/// 校验通知及HTTP资源在所有者结束后不会复活。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final clearConfig in [true, false]) {
    test('${clearConfig ? '清空配置' : '关闭同步'}取消真实通知提供者的在途取票及重试', () {
      fakeAsync((async) {
        var config = const ApiConfig(baseUrl: 'https://example.test');
        final container = ProviderContainer(
          overrides: [
            apiConfigProvider.overrideWith((_) => config),
            cloudNetworkEventsProvider.overrideWithValue(
              const Stream<bool>.empty(),
            ),
          ],
        );
        _signIn(container);
        final adapter = _LifecycleAdapter();
        container.read(apiClientProvider).dio.httpClientAdapter = adapter;
        final coordinator = container.read(realtimeCoordinatorProvider);
        unawaited(coordinator.start());
        async.flushMicrotasks();
        async.elapse(Duration.zero);
        expect(adapter.entered.isCompleted, isTrue);
        if (clearConfig) {
          config = const ApiConfig(baseUrl: '');
          container.invalidate(apiConfigProvider);
        } else {
          container.read(accountSyncEnabledProvider.notifier).setEnabled(false);
        }
        // 真实依赖重建会同步失效原连接所有者，迟到失败不能创建退避计时器。
        container.read(realtimeCoordinatorProvider);
        adapter.response.complete(ResponseBody.fromString('{}', 503));
        async.flushMicrotasks();
        unawaited(coordinator.start());
        async.elapse(const Duration(minutes: 5));
        expect(async.pendingTimers, isEmpty);
        container.dispose();
      });
    });
  }

  test('API客户端随配置重建释放旧连接池，令牌轮换复用当前连接池', () {
    var config = const ApiConfig(baseUrl: 'https://first.test');
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        apiConfigProvider.overrideWith((_) => config),
      ],
    );
    final first = container.read(apiClientProvider);
    final firstAdapter = _LifecycleAdapter();
    first.dio.httpClientAdapter = firstAdapter;
    _signIn(container);
    container.read(authSessionProvider.notifier).updateToken('rotated');
    expect(container.read(apiClientProvider), same(first));
    expect(firstAdapter.closeForces, isEmpty);

    config = const ApiConfig(baseUrl: 'https://second.test');
    container.invalidate(apiConfigProvider);
    final second = container.read(apiClientProvider);
    expect(second, isNot(same(first)));
    expect(firstAdapter.closeForces, [false]);
    final secondAdapter = _LifecycleAdapter();
    second.dio.httpClientAdapter = secondAdapter;
    container.dispose();
    expect(secondAdapter.closeForces, [false]);
  });

  test('容器销毁温和释放HTTP连接池，在途响应继续完成且迟到401不刷新', () async {
    final container = _container();
    _signIn(container);
    final client = container.read(apiClientProvider);
    final adapter = _LifecycleAdapter();
    client.dio.httpClientAdapter = adapter;
    final pending = expectLater(
      client.dio.get<void>('/pending'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    await adapter.entered.future;
    container.dispose();
    expect(adapter.closeForces, [false]);
    adapter.response.complete(ResponseBody.fromString('{}', 401));
    await pending;
  });

  test('容器销毁时已经发送的HTTP业务请求仍能取得成功响应', () async {
    final container = _container();
    final client = container.read(apiClientProvider);
    final adapter = _LifecycleAdapter();
    client.dio.httpClientAdapter = adapter;
    final pending = client.dio.post<void>('/mutation', data: {'value': 1});
    await adapter.entered.future;
    container.dispose();
    expect(adapter.closeForces, [false]);
    adapter.response.complete(ResponseBody.fromString('{}', 200));
    expect((await pending).statusCode, 200);
  });

  test('容器销毁关闭活动通知连接，旧协调器再次start保持停止', () async {
    var calls = 0;
    final socket = _LifecycleSocket();
    final client = RealtimeClient(
      ticketProvider: () async => 'ticket-${++calls}',
      connect: (_) => socket,
    );
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        realtimeClientProvider.overrideWithValue(client),
      ],
    );
    _signIn(container);
    final coordinator = container.read(realtimeCoordinatorProvider);
    await coordinator.start();
    container.dispose();
    await pumpEventQueue();
    expect(socket.controller.isClosed, isTrue);
    await coordinator.start();
    expect(calls, 1);
  });

  test('配置重建释放原通知连接，旧所有者不会关闭新配置连接', () async {
    var config = const ApiConfig(baseUrl: 'https://first.test');
    final sockets = <_LifecycleSocket>[];
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        apiConfigProvider.overrideWith((_) => config),
        realtimeClientProvider.overrideWith((ref) {
          final baseUrl = ref.watch(apiConfigProvider).baseUrl;
          final client = RealtimeClient(
            ticketProvider: () async => baseUrl,
            connect: (_) {
              final socket = _LifecycleSocket();
              sockets.add(socket);
              return socket;
            },
          );
          ref.onDispose(client.dispose);
          return client;
        }),
      ],
    );
    _signIn(container);
    final first = container.read(realtimeCoordinatorProvider);
    await first.start();
    config = const ApiConfig(baseUrl: 'https://second.test');
    container.invalidate(apiConfigProvider);
    final second = container.read(realtimeCoordinatorProvider);
    await second.start();
    await first.start();
    expect(sockets, hasLength(2));
    expect(sockets.first.controller.isClosed, isTrue);
    expect(sockets.last.controller.isClosed, isFalse);
    container.dispose();
    await pumpEventQueue();
    expect(sockets.last.controller.isClosed, isTrue);
  });

  test('销毁时关闭失败仍释放订阅并永久停止旧协调器，不安排重连', () async {
    var tickets = 0;
    final socket = _LifecycleSocket()..closeError = StateError('模拟关闭失败');
    final client = RealtimeClient(
      ticketProvider: () async => 'ticket-${++tickets}',
      connect: (_) => socket,
    );
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        realtimeClientProvider.overrideWithValue(client),
      ],
    );
    _signIn(container);
    final coordinator = container.read(realtimeCoordinatorProvider);
    await coordinator.start();

    container.dispose();
    await pumpEventQueue();
    await coordinator.start();

    expect(socket.controller.isClosed, isTrue);
    expect(socket.closeCalls, 1);
    expect(tickets, 1);
  });

  test('取票中销毁协调器后迟到结果不能建连或排队重试', () {
    fakeAsync((async) {
      final ticket = Completer<String>();
      var calls = 0;
      var connections = 0;
      final client = RealtimeClient(
        ticketProvider: () {
          calls++;
          return ticket.future;
        },
        connect: (_) {
          connections++;
          throw StateError('销毁后不能进入连接工厂');
        },
      );
      final container = ProviderContainer(
        overrides: [
          cloudNetworkEventsProvider.overrideWithValue(
            const Stream<bool>.empty(),
          ),
          apiConfigProvider.overrideWithValue(
            const ApiConfig(baseUrl: 'https://example.test'),
          ),
          realtimeClientProvider.overrideWithValue(client),
        ],
      );
      _signIn(container);
      unawaited(container.read(realtimeCoordinatorProvider).start());
      container.dispose();
      ticket.complete('late-ticket');
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));
      expect(calls, 1);
      expect(connections, 0);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('断线退避中销毁取消定时器，不再请求票据', () {
    fakeAsync((async) {
      var calls = 0;
      final client = RealtimeClient(
        ticketProvider: () async {
          calls++;
          throw StateError('暂时无法获取票据');
        },
        connect: (_) => throw StateError('票据失败不能建连'),
      );
      final container = ProviderContainer(
        overrides: [
          cloudNetworkEventsProvider.overrideWithValue(
            const Stream<bool>.empty(),
          ),
          apiConfigProvider.overrideWithValue(
            const ApiConfig(baseUrl: 'https://example.test'),
          ),
          realtimeClientProvider.overrideWithValue(client),
        ],
      );
      _signIn(container);
      unawaited(container.read(realtimeCoordinatorProvider).start());
      async.flushMicrotasks();
      expect(async.pendingTimers, hasLength(1));
      container.dispose();
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));
      expect(calls, 1);
      expect(async.pendingTimers, isEmpty);
    });
  });
}
