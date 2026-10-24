import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_connection_providers.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StreamController<bool> network;
  late ProviderContainer container;
  late Dio dio;
  late _Adapter adapter;

  setUp(() {
    network = StreamController<bool>.broadcast();
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        cloudNetworkEventsProvider.overrideWithValue(network.stream),
        syncCoordinatorProvider.overrideWith(_SyncSpy.new),
      ],
    );
    dio = container.read(apiClientProvider).dio;
    adapter = _Adapter();
    dio.httpClientAdapter = adapter;
  });

  tearDown(() async {
    container.dispose();
    await network.close();
  });

  /// 等待接口事件与恢复回调提交，避免依赖生产网络或定时器。
  Future<void> emit(bool available) async {
    network.add(available);
    await Future<void>.delayed(Duration.zero);
  }

  /// 用不同账号建立会话，所有请求仍经过生产 Dio 拦截器。
  void signIn(String userId) {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          AuthSession(accessToken: 'token', userId: userId, deviceId: 'device'),
        );
  }

  test('接口恢复仅为待确认，实际 HTTP 响应才表明云服务可访问', () async {
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
    await emit(false);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.offline,
    );
    expect(
      container.read(cloudConnectionProvider.notifier).isNetworkUnavailable,
      isTrue,
    );
    await emit(true);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
    expect(
      container.read(cloudConnectionProvider.notifier).isNetworkUnavailable,
      isFalse,
    );
    await dio.get<void>('/connection');
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.online,
    );
    await emit(true);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.online,
    );
  });

  test('HTTP 403 和 503 是服务器响应，不能把业务或服务错误当作断网', () async {
    for (final status in [403, 503]) {
      adapter.fetchResponse = (_) async =>
          ResponseBody.fromString('{}', status);
      await expectLater(
        dio.get<void>('/connection'),
        throwsA(isA<DioException>()),
      );
      expect(
        container.read(cloudConnectionProvider),
        CloudConnectionStatus.online,
      );
    }
  });

  test('连接与超时错误表明云端不可访问，取消和本地解析错误保持原状态', () async {
    await dio.get<void>('/connection');
    for (final type in [DioExceptionType.cancel, DioExceptionType.unknown]) {
      adapter.fetchResponse = (options) async => throw DioException(
        requestOptions: options,
        type: type,
        error: const FormatException('解析失败'),
      );
      await expectLater(
        dio.get<void>('/connection'),
        throwsA(isA<DioException>()),
      );
      expect(
        container.read(cloudConnectionProvider),
        CloudConnectionStatus.online,
      );
    }
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      adapter.fetchResponse = (options) async =>
          throw DioException(requestOptions: options, type: type);
      await expectLater(
        dio.get<void>('/connection'),
        throwsA(isA<DioException>()),
      );
      expect(
        container.read(cloudConnectionProvider),
        CloudConnectionStatus.offline,
      );
    }
  });

  test('断网前发出的成功响应不能覆盖已经收到的无网事实', () async {
    final response = Completer<ResponseBody>();
    final started = Completer<void>();
    adapter.fetchResponse = (_) {
      started.complete();
      return response.future;
    };
    final request = dio.get<void>('/connection');
    await started.future;
    await emit(false);
    response.complete(ResponseBody.fromString('{}', 200));
    await request;
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.offline,
    );
  });

  test('换号和同账号退出重登后，旧请求不能改变新的连接状态', () async {
    for (final nextUser in ['b', 'a']) {
      signIn('a');
      final response = Completer<ResponseBody>();
      final started = Completer<void>();
      adapter.fetchResponse = (_) {
        started.complete();
        return response.future;
      };
      final request = dio.get<void>('/connection');
      await started.future;
      container.read(authSessionProvider.notifier).signOut();
      signIn(nextUser);
      response.complete(ResponseBody.fromString('{}', 200));
      await request;
      expect(
        container.read(cloudConnectionProvider),
        CloudConnectionStatus.unknown,
      );
    }
  });

  test('客户端销毁后的请求回调不再更新 provider 或抛出销毁异常', () async {
    final response = Completer<ResponseBody>();
    final started = Completer<void>();
    adapter.fetchResponse = (_) {
      started.complete();
      return response.future;
    };
    final request = dio.get<void>('/connection');
    await started.future;
    container.invalidate(apiClientProvider);
    response.complete(ResponseBody.fromString('{}', 200));
    await request;
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
  });

  test('连接状态重新创建后，旧监听代次的请求不能更新新状态', () async {
    final response = Completer<ResponseBody>();
    final started = Completer<void>();
    adapter.fetchResponse = (_) {
      started.complete();
      return response.future;
    };
    final request = dio.get<void>('/connection');
    await started.future;
    container.invalidate(cloudConnectionProvider);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
    response.complete(ResponseBody.fromString('{}', 200));
    await request;
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
  });

  test('网络每次从断开到恢复只触发一次同步，HTTP 响应与重复接口通知不触发', () async {
    signIn('a');
    container.read(cloudConnectionSyncProvider);
    final sync = container.read(syncCoordinatorProvider) as _SyncSpy;
    await emit(true);
    expect(sync.calls, 0);
    await emit(false);
    await emit(true);
    await emit(true);
    await dio.get<void>('/connection');
    expect(sync.calls, 1);
    await emit(false);
    await emit(true);
    expect(sync.calls, 2);
  });

  test('本地身份不自动同步，缓存登录身份在恢复后进入统一刷新入口', () async {
    container.read(cloudConnectionSyncProvider);
    final sync = container.read(syncCoordinatorProvider) as _SyncSpy;
    await emit(false);
    await emit(true);
    expect(sync.calls, 0);
    container
        .read(accountStateProvider.notifier)
        .restoreFromCache(const CloudProfile(userId: 'a'));
    await emit(false);
    await emit(true);
    expect(sync.calls, 1);
    expect(container.read(authSessionProvider), isNull);
  });

  test('账号清理和全量恢复闸门期间，原生重连不能启动刷新', () async {
    signIn('a');
    container.read(cloudConnectionSyncProvider);
    final sync = container.read(syncCoordinatorProvider) as _SyncSpy;
    container.read(syncGateProvider.notifier).hold();
    await emit(false);
    await emit(true);
    expect(sync.calls, 0);
    container.read(syncGateProvider.notifier).release();
    container.read(restoreGateProvider.notifier).hold();
    await emit(false);
    await emit(true);
    expect(sync.calls, 0);
    container.read(restoreGateProvider.notifier).release();
  });
}

/// 注入服务端响应或在途请求，不执行外部 HTTP。
class _Adapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions) fetchResponse = (_) async =>
      ResponseBody.fromString('{}', 200);

  /// 由各需求用例控制返回结果。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => fetchResponse(options);

  /// 测试适配器没有底层连接。
  @override
  void close({bool force = false}) {}
}

/// 记录恢复时是否进入现有同步协调器，不触碰本地数据库。
class _SyncSpy extends SyncCoordinator {
  _SyncSpy(super.ref);
  int calls = 0;

  /// 入口负责缓存会话恢复与账号级同步。
  @override
  Future<SyncRunResult> refreshData({String? ledgerId}) async {
    calls++;
    return const SyncRunResult();
  }
}
