import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/infrastructure/api/api_interceptors.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/core/network/request_deadline.dart';

import '../../helpers/test_isolation.dart';

const _deadline = Duration(milliseconds: 100);

/// 传输资源实际监听 Dio 取消信号，持续数据流不能绕过请求总期限。
class _Adapter implements HttpClientAdapter {
  _Adapter({this.drip = false, this.upload = false});
  bool drip;
  final bool upload;
  int calls = 0;
  int aborted = 0;
  int chunks = 0;
  final List<void Function()> _release = [];

  /// 模拟持续收包或停滞发送；取消后停止生产数据，并结束适配器等待。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (!drip && !upload) return ResponseBody.fromString('{}', 200);
    final body = StreamController<Uint8List>();
    final response = Completer<ResponseBody>();
    Timer? timer;
    StreamSubscription<Uint8List>? sending;
    var released = false;

    /// 幂等释放模拟传输，证明期限到达后没有后台继续上传或收包。
    void release() {
      if (released) return;
      released = true;
      timer?.cancel();
      unawaited(sending?.cancel());
      unawaited(body.close());
      if (!response.isCompleted) {
        response.complete(ResponseBody.fromString('{}', 200));
      }
    }

    _release.add(release);
    unawaited(
      cancelFuture?.then((_) {
        aborted++;
        release();
      }),
    );
    if (upload) {
      sending = requestStream?.listen(
        (_) => chunks++,
        onError: (Object error, StackTrace stack) {
          // 上传转换流会发出本请求令牌的取消异常，模拟传输应据此释放上传源。
          if (error is DioException &&
              CancelToken.isCancel(error) &&
              identical(error, options.cancelToken?.cancelError)) {
            release();
            return;
          }
          // 其他上传错误保留完整堆栈并令测试失败，不能被预期超时断言掩盖。
          Error.throwWithStackTrace(error, stack);
        },
      );
      return response.future;
    }
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      chunks++;
      body.add(Uint8List.fromList([32]));
    });
    return ResponseBody(
      body.stream,
      200,
      onClose: release,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  /// 测试结束清除传输资源，不保留未完成的流或定时器。
  @override
  void close({bool force = false}) {
    for (final release in _release) {
      release();
    }
  }
}

/// 固定认证失败响应，用于验证等待刷新也消耗原请求的总期限。
class _UnauthorizedAdapter implements HttpClientAdapter {
  int calls = 0;

  /// 不连接真实网络，只把请求送进真实 401 刷新拦截器。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      '{}',
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  /// 无常驻传输资源需要清理。
  @override
  void close({bool force = false}) {}
}

/// 总期限与调用者取消通过生产装配测试，时限缩短而不真实等待三十秒。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late Dio dio;
  setUp(() {
    resetGlobalTestState();
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'http://deadline.test'),
        ),
        apiRequestDeadlineProvider.overrideWithValue(_deadline),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    dio = container.read(apiClientProvider).dio;
  });
  tearDown(() {
    dio.close(force: true);
    container.dispose();
  });

  test('生产请求有发送时限，持续滴流在总期限终止且取消底层流', () async {
    final adapter = _Adapter(drip: true);
    dio.httpClientAdapter = adapter;
    expect(dio.options.connectTimeout, const Duration(seconds: 5));
    expect(dio.options.receiveTimeout, const Duration(seconds: 3));
    expect(dio.options.sendTimeout, _deadline);
    final elapsed = Stopwatch()..start();
    await expectLater(
      dio.get<void>('/slow'),
      throwsA(
        isA<DioException>()
            .having(
              (error) => error.type,
              '错误类型',
              DioExceptionType.receiveTimeout,
            )
            .having(
              cloudOperationErrorMessage,
              '友好提示',
              cloudNetworkErrorMessage,
            ),
      ),
    );
    expect(elapsed.elapsed, lessThan(const Duration(seconds: 1)));
    expect(adapter.aborted, 1);
    expect(adapter.chunks, greaterThan(1));
    final stoppedAt = adapter.chunks;
    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(adapter.chunks, stoppedAt);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.offline,
    );
  });

  test('慢上传总期限实际取消上传源，不留下后台继续发送', () async {
    final adapter = _Adapter(upload: true);
    dio.httpClientAdapter = adapter;
    final upload = Stream<Uint8List>.periodic(
      const Duration(milliseconds: 10),
      (_) => Uint8List.fromList([1]),
    );
    await expectLater(
      dio.post<void>('/upload', data: upload),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          '错误类型',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
    expect(adapter.aborted, 1);
    expect(adapter.chunks, greaterThan(1));
    final stoppedAt = adapter.chunks;
    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(adapter.chunks, stoppedAt);
  });

  test('单个请求超时不取消调用者令牌，同一令牌仍可用于新请求', () async {
    final adapter = _Adapter(drip: true);
    dio.httpClientAdapter = adapter;
    final caller = CancelToken();
    await expectLater(
      dio.get<void>('/slow', cancelToken: caller),
      throwsA(isA<DioException>()),
    );
    expect(caller.isCancelled, isFalse);
    adapter.drip = false;
    await dio.get<void>('/fast', cancelToken: caller);
    await Future<void>.delayed(const Duration(milliseconds: 130));
    expect(adapter.calls, 2);
    expect(adapter.aborted, 1);
    expect(caller.isCancelled, isFalse);
  });

  test('调用者主动取消共享请求保留取消原因，不误报网络超时', () async {
    final adapter = _Adapter(drip: true);
    dio.httpClientAdapter = adapter;
    final caller = CancelToken();
    final first = dio.get<void>('/one', cancelToken: caller);
    final second = dio.get<void>('/two', cancelToken: caller);
    final cancelled = throwsA(
      isA<DioException>()
          .having((error) => error.type, '错误类型', DioExceptionType.cancel)
          .having((error) => error.error, '取消原因', '用户取消'),
    );
    final observed = Future.wait([
      expectLater(first, cancelled),
      expectLater(second, cancelled),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    caller.cancel('用户取消');
    await observed;
    expect(adapter.aborted, 2);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.unknown,
    );
  });

  test('401刷新等待仍受原请求总期限约束，迟到刷新不会再发原请求', () async {
    final refresh = Completer<String>();
    var refreshCalls = 0;
    final authDio = Dio(BaseOptions(baseUrl: 'http://deadline.test'));
    final adapter = _UnauthorizedAdapter();
    authDio.httpClientAdapter = adapter;
    authDio.interceptors.add(
      AuthRefreshInterceptor(
        dio: authDio,
        refresh: () {
          refreshCalls++;
          return refresh.future;
        },
      ),
    );
    authDio.interceptors.add(RequestDeadlineInterceptor(timeout: _deadline));
    addTearDown(() => authDio.close(force: true));
    await expectLater(
      authDio.get<void>('/protected'),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          '错误类型',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
    expect(refreshCalls, 1);
    refresh.complete('late-token');
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(adapter.calls, 1);
  });
}
