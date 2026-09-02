import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// 为每个请求注入可跨客户端与服务端关联的请求 ID。
///
/// 设计意图：为每个请求生成唯一 UUID 写入 `x-request-id` 头，
/// 服务端 Fastify 以同一值回显并在日志关联；调用方已显式指定时不覆盖
/// （例如 E2E 需要复现固定请求链路）。
class RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('x-request-id', () => const Uuid().v4());
    handler.next(options);
  }
}

/// 对 401 响应执行单飞刷新，并最多重放原请求一次。
///
/// 设计意图：并发请求同时 401 时只发起一次 refresh（单飞），
/// 其余请求挂在同一个 Future 上等待；刷新成功用新 token 重放，
/// 失败则全部放行错误，避免各自刷新造成 token 轮换竞争。
class AuthRefreshInterceptor extends Interceptor {
  static const _refreshPath = '/api/v1/auth/refresh';
  static const _retriedKey = 'sesame_auth_retried';

  /// 用于重放请求的 Dio 实例。
  final Dio dio;

  /// 刷新回调：返回新 access token；由上层注入真实的 refresh 调用。
  final Future<String> Function() refresh;

  /// 判断错误是否为 401 未授权。
  final bool Function(DioException error)? isUnauthorized;

  AuthRefreshInterceptor({
    required this.dio,
    required this.refresh,
    this.isUnauthorized,
  });

  /// 正在进行的单飞刷新 Future（null = 无进行中刷新）。
  Future<String>? _inFlight;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final unauthorized =
        isUnauthorized?.call(err) ?? err.response?.statusCode == 401;
    final request = err.requestOptions;
    if (!unauthorized ||
        request.path == _refreshPath ||
        request.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    try {
      // 单飞：复用进行中的刷新 Future，避免并发 401 各自刷新。
      final newToken = _inFlight ??= refresh();
      final token = await newToken;
      if (token.isEmpty) {
        handler.next(err);
        return;
      }

      // 用新 token 重放原请求（含原 headers/body/query）。
      final opts = request;
      // 标记写在原 RequestOptions 上，确保重放后的 401 不会再次进入刷新链。
      opts.extra[_retriedKey] = true;
      opts.headers['Authorization'] = 'Bearer $token';
      final response = await dio.fetch<dynamic>(opts);
      handler.resolve(response);
    } catch (_) {
      // 刷新失败：放行原始 401，由调用方处理（如引导重新登录）。
      handler.next(err);
    } finally {
      _inFlight = null;
    }
  }
}
