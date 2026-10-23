import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import 'network_messages.dart';

/// 总期限造成的内部取消携带独立标记，调用者主动取消不会被判为网络超时。
class CloudRequestDeadlineExceeded extends TimeoutException {
  /// 错误原因只包含固定网络文案与期限，不携带请求正文或认证材料。
  CloudRequestDeadlineExceeded(Duration timeout)
    : super(cloudNetworkErrorMessage, timeout);
}

/// 限制单个云请求的完整等待时间，缓慢持续收包、上传及认证重放共用同一预算。
class RequestDeadlineInterceptor extends Interceptor {
  /// 默认等待三十秒；测试可缩短期限，连接和收包空闲超时仍由 Dio 分别处理。
  RequestDeadlineInterceptor({this.timeout = const Duration(seconds: 30)})
    : assert(timeout.inMicroseconds > 0);

  final Duration timeout;
  static const _stateKey = 'sesame_request_deadline_state';

  /// 每次请求使用独立取消令牌，调用者共享令牌只单向传递取消，不被请求超时污染。
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final previous = options.extra[_stateKey];
      // 认证拦截器使用同一 RequestOptions 重放，必须继续首次请求的剩余预算。
      final state = previous is _RequestDeadlineState && !previous.finished
          ? previous
          : _RequestDeadlineState(options, timeout);
      options.extra[_stateKey] = state;
      options.cancelToken = state.token;
      handler.next(options);
    } catch (error, stack) {
      logger.error(
        'CloudRequest',
        '创建云请求取消边界失败',
        safeErrorSummary(error),
        stack,
      );
      handler.reject(
        DioException(requestOptions: options, error: error, stackTrace: stack),
      );
    }
  }

  /// 成功后及时释放定时器和调用者取消订阅，不影响调用者随后发起的新请求。
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final state = response.requestOptions.extra[_stateKey];
    if (state is _RequestDeadlineState) state.finish();
    handler.next(response);
  }

  /// 总期限取消映射为网络超时；用户主动取消保留原来的取消类型与原因。
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final state = error.requestOptions.extra[_stateKey];
    if (state is _RequestDeadlineState) {
      state.finish();
      if (state.expired) {
        handler.next(
          DioException(
            requestOptions: error.requestOptions,
            type: DioExceptionType.receiveTimeout,
            error: TimeoutException(cloudNetworkErrorMessage, timeout),
            message: cloudNetworkErrorMessage,
            stackTrace: error.stackTrace,
          ),
        );
        return;
      }
    }
    handler.next(error);
  }
}

/// 一次请求及其认证重放共享的期限状态；内部令牌实际中止传输和响应流。
class _RequestDeadlineState {
  /// 绑定调用者取消信号并启动总期限，调用者已经取消时不创建额外计时器。
  _RequestDeadlineState(RequestOptions options, Duration timeout) {
    token.requestOptions = options;
    final caller = options.cancelToken;
    if (caller?.isCancelled == true) {
      token.cancel(caller!.cancelError?.error);
      return;
    }
    _callerCancellation = caller?.whenCancel.asStream().listen((error) {
      if (!token.isCancelled) token.cancel(error.error);
    });
    _timer = Timer(timeout, () {
      if (finished || token.isCancelled) return;
      expired = true;
      logger.warning(
        'CloudRequest',
        '云请求等待超时，已取消在途请求',
        'timeout_ms=${timeout.inMilliseconds}',
      );
      // 取消会传到 Dio 适配器和响应流，不能只让外层 Future 提前返回。
      token.cancel(CloudRequestDeadlineExceeded(timeout));
    });
  }

  final token = CancelToken();
  Timer? _timer;
  StreamSubscription<DioException>? _callerCancellation;
  bool expired = false;
  bool finished = false;

  /// 完成状态幂等，认证重放的内外层响应可安全共用同一个清理入口。
  void finish() {
    if (finished) return;
    finished = true;
    _timer?.cancel();
    _timer = null;
    unawaited(_callerCancellation?.cancel());
    _callerCancellation = null;
  }
}
