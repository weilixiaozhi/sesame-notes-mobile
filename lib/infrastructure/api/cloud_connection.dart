import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/network/request_deadline.dart';

/// 网络接口恢复后仍需实际 HTTP 响应，才能确认云服务可访问。
enum CloudConnectionStatus { unknown, offline, online }

/// 原生网络接口通知只提供连接事实，不探测服务器或定时发送 HTTP。
final cloudNetworkEventsProvider = Provider<Stream<bool>>((ref) {
  return const EventChannel(
    'com.sesame_notes.network',
  ).receiveBroadcastStream().cast<bool>().distinct();
});

/// 当前云服务连接状态；同步积压、认证与业务失败由各自状态表达。
final cloudConnectionProvider =
    NotifierProvider<CloudConnectionNotifier, CloudConnectionStatus>(
      CloudConnectionNotifier.new,
    );

/// 合并系统接口与实际请求结果，并隔离账号和网络变化前的在途回调。
class CloudConnectionNotifier extends Notifier<CloudConnectionStatus> {
  int _generation = 0;
  bool? _networkAvailable;

  /// 监听接口变化；通道不可用时保持待确认，交由实际请求判定。
  @override
  CloudConnectionStatus build() {
    _generation++;
    final subscription = ref
        .watch(cloudNetworkEventsProvider)
        .listen(
          _networkChanged,
          onError: (Object error, StackTrace stackTrace) {
            logger.error('CloudConnection', '无法读取网络接口状态', error, stackTrace);
          },
        );
    ref.onDispose(() {
      // Notifier 重建会复用实例，销毁时递增代次使旧请求立即失效。
      _generation++;
      unawaited(subscription.cancel());
    });
    return _networkAvailable == false
        ? CloudConnectionStatus.offline
        : CloudConnectionStatus.unknown;
  }

  /// 请求记录当前代次，后续账号或接口切换会使该请求的状态回写失效。
  int get generation => _generation;

  /// 只有系统确认无网络接口时才前置阻止在线动作，传输失败仍允许主动重试。
  bool get isNetworkUnavailable => _networkAvailable == false;

  /// 账号身份变化时清除上一账号的响应事实，保留系统已经确认的无网状态。
  void resetForAccountChange() {
    _generation++;
    state = _networkAvailable == false
        ? CloudConnectionStatus.offline
        : CloudConnectionStatus.unknown;
  }

  /// 无网络立即显示离线；接口恢复只解除无网事实，等待请求确认云服务。
  void _networkChanged(bool available) {
    if (!ref.mounted || available == _networkAvailable) return;
    final previous = _networkAvailable;
    _networkAvailable = available;
    _generation++;
    if (!available) {
      state = CloudConnectionStatus.offline;
    } else if (previous == false || state == CloudConnectionStatus.offline) {
      state = CloudConnectionStatus.unknown;
    }
  }

  /// 收到任何 HTTP 状态都说明服务端可访问，业务是否成功另行处理。
  void responseReceived(int generation) {
    if (!_accepts(generation)) return;
    state = CloudConnectionStatus.online;
  }

  /// 仅连接和传输超时改变可达状态；取消、解析和业务异常不推断为断网。
  void requestFailed(int generation, DioException error) {
    if (!_accepts(generation)) return;
    if (error.response?.statusCode != null) {
      state = CloudConnectionStatus.online;
    } else if (error.error is CloudRequestDeadlineExceeded ||
        switch (error.type) {
          DioExceptionType.connectionError ||
          DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.badCertificate => true,
          _ => false,
        }) {
      state = CloudConnectionStatus.offline;
    }
  }

  /// 回写必须属于当前账号及当前网络代次，并且 provider 仍然有效。
  bool _accepts(int generation) =>
      ref.mounted && _generation == generation && _networkAvailable != false;
}

/// 在生产 Dio 链路记录连接事实，不改写原始响应或业务错误。
class CloudConnectionInterceptor extends Interceptor {
  static const _generationKey = 'sesame_connection_generation';
  final CloudConnectionNotifier connection;
  final bool Function() isActive;

  /// 客户端生命周期由装配方提供，销毁后的在途回调只透传原结果。
  CloudConnectionInterceptor({
    required this.connection,
    required this.isActive,
  });

  /// 保存发出请求时的账号与网络代次。
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_generationKey] = connection.generation;
    handler.next(options);
  }

  /// HTTP 响应可以确认可达，即使后续响应解析失败也不等于离线。
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final generation = response.requestOptions.extra[_generationKey];
    if (isActive() && generation is int) {
      connection.responseReceived(generation);
    }
    handler.next(response);
  }

  /// 区分服务端响应与传输失败，认证拦截器继续正常处理原错误。
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final generation = error.requestOptions.extra[_generationKey];
    if (isActive() && generation is int) {
      connection.requestFailed(generation, error);
    }
    handler.next(error);
  }
}
