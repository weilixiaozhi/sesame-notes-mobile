import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// WS 连接抽象：隔离 web_socket_channel 类型，测试可注入假实现。
abstract class RealtimeSocket {
  Stream<dynamic> get messages;
  Future<void> close();
}

/// 生产实现：包装 [WebSocketChannel]。
class ChannelRealtimeSocket implements RealtimeSocket {
  final WebSocketChannel channel;

  ChannelRealtimeSocket(this.channel);

  @override
  Stream<dynamic> get messages => channel.stream;

  @override
  Future<void> close() => channel.sink.close();
}

/// WebSocket 实时通知客户端（WS 只通知有新变更，数据仍走 Pull 游标）。
///
/// 设计意图：
/// - 连接前先经 POST /api/v1/ws/ticket 获取 30 秒单次票据，避免把 Access Token
///   放入 WS URL 和访问日志（后端票据机制）；
/// - 收到 ready 或 sync_change 时触发 [onSyncChange] 回调（通知去拉取），
///   事件本身不作为状态来源——变更数据一律经 Pull 游标获取；
/// - 连接被对端关闭或通道异常时回调 [start] 传入的 onDisconnected，由调用方
///   安排重连；票据一次性，重连一律走新的 [start] 重新取票。
class RealtimeClient {
  /// 票据获取回调（通常走 RealtimeApi.postWsTicket）。
  final Future<String> Function() ticketProvider;

  /// 连接工厂：票据 → 已建立的 socket（测试可注入假实现）。
  final RealtimeSocket Function(String ticket) connect;

  /// 连接就绪或收到变更提示时安排游标补拉，回调不消费消息中的业务状态。
  final Future<void> Function()? onSyncChange;

  RealtimeSocket? _socket;
  StreamSubscription<dynamic>? _sub;
  bool _running = false;

  /// 所有者结束后永久拒绝新连接，区别于允许下一会话重启的 stop。
  bool _disposed = false;

  /// 每个连接仅消费一次 ready，重复握手消息不能反复排队补拉。
  bool _readyReceived = false;

  /// 连接代次：退出或开始新连接后，旧取票结果不能再创建或清理连接。
  int _generation = 0;

  /// 主动关闭标记：区分 [stop] 引发的 onDone 与真实断线。
  bool _stopping = false;

  /// 本次连接的断线通知是否已发出（error 与随后的 done 会连续触发）。
  bool _disconnectNotified = false;

  /// 当前连接绑定的断线处理器，由 [start] 注入。
  void Function()? _onDisconnected;

  RealtimeClient({
    required this.ticketProvider,
    required this.connect,
    this.onSyncChange,
  });

  /// 建立连接并开始监听；重复调用为幂等（已运行则直接返回）。
  ///
  /// [onDisconnected] 在连接被对端关闭或通道异常时回调一次，用于安排重连。
  Future<void> start({void Function()? onDisconnected}) async {
    if (_disposed || _running) return;
    final generation = ++_generation;
    _running = true;
    _readyReceived = false;
    _stopping = false;
    _disconnectNotified = false;
    _onDisconnected = onDisconnected;
    try {
      // 每次连接都重新取票据（30 秒单次，过期即失效）。
      final ticket = await ticketProvider();
      if (generation != _generation) return;
      final socket = connect(ticket);
      _socket = socket;

      _sub = socket.messages.listen(
        (raw) {
          if (generation == _generation) unawaited(_onMessage(raw));
        },
        onError: (Object error, StackTrace stackTrace) {
          if (generation != _generation) return;
          logger.warning(
            'RealtimeClient',
            '实时通知连接异常',
            '${safeErrorSummary(error)}\n$stackTrace',
          );
          _notifyDisconnected(generation);
        },
        onDone: () => _notifyDisconnected(generation),
      );
    } catch (e, st) {
      // 握手异常可能包含携带单次票据的 URL，日志只保留错误类型与调用位置。
      logger.error('RealtimeClient', '建立实时通知连接失败', safeErrorSummary(e), st);
      if (generation != _generation) return;
      // 取票或建连失败后必须释放幂等状态，否则后续 start 会永久短路。
      _running = false;
      final sub = _sub;
      final socket = _socket;
      _sub = null;
      _socket = null;
      try {
        await sub?.cancel();
        await socket?.close();
      } catch (cleanupError, cleanupStackTrace) {
        logger.warning(
          'RealtimeClient',
          '连接失败后的资源清理异常',
          '${safeErrorSummary(cleanupError)}\n$cleanupStackTrace',
        );
      }
      if (generation == _generation) rethrow;
    }
  }

  /// 处理连接中断：释放本连接资源并通知调用方安排重连。
  ///
  /// 主动 [stop] 不是断线，不通知；通道异常会先触发 onError 再触发 onDone，
  /// 用 [_disconnectNotified] 去重，保证一次断线只通知一次。
  void _notifyDisconnected(int generation) {
    if (generation != _generation || _stopping || _disconnectNotified) return;
    _disconnectNotified = true;
    final sub = _sub;
    _sub = null;
    _socket = null;
    _running = false;
    // 断线时底层通道已由对端关闭（dart:io WebSocket 出错后必定关闭流），
    // 这里只需停止订阅，socket 引用置空后即可回收。
    unawaited(_cancelDisconnectedSubscription(sub));
    try {
      _onDisconnected?.call();
    } catch (error, stackTrace) {
      logger.warning(
        'RealtimeClient',
        '实时通知断线收尾失败',
        '${safeErrorSummary(error)}\n$stackTrace',
      );
    }
  }

  /// 断线后的异步订阅清理保留错误边界，避免异常逃出消息调度所在区域。
  Future<void> _cancelDisconnectedSubscription(
    StreamSubscription<dynamic>? subscription,
  ) async {
    try {
      await subscription?.cancel();
    } catch (error, stackTrace) {
      logger.warning(
        'RealtimeClient',
        '实时通知订阅释放失败',
        '${safeErrorSummary(error)}\n$stackTrace',
      );
    }
  }

  /// 授权连接就绪后补齐断线窗口；变更提示与补拉共用上层去重调度。
  Future<void> _onMessage(dynamic raw) async {
    try {
      if (!_running || _stopping) return;
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      if (message['type'] == 'ready') {
        if (_readyReceived) return;
        _readyReceived = true;
        // ready 在服务端完成授权与订阅后发送，此时开始补拉可覆盖断线期间已提交的变更。
        await onSyncChange?.call();
      } else if (message['type'] == 'sync_change') {
        await onSyncChange?.call();
      }
    } catch (error, stackTrace) {
      logger.warning(
        'RealtimeClient',
        '实时同步提示处理失败',
        '${safeErrorSummary(error)}\n$stackTrace',
      );
    }
  }

  /// 关闭连接并停止监听；主动关闭不会触发断线通知。
  Future<void> stop() async {
    _generation++;
    _stopping = true;
    _running = false;
    _onDisconnected = null;
    // 异步关闭期间允许下一会话建连；先摘下旧资源，避免关闭回调覆盖新连接。
    final sub = _sub;
    final socket = _socket;
    _sub = null;
    _socket = null;
    await Future.wait<void>([
      if (sub != null) sub.cancel(),
      if (socket != null) socket.close(),
    ]);
  }

  /// 同步使在途票据失效，再由独立错误边界完成资源释放。
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_closeDisposedConnection());
  }

  /// 容器销毁无法等待异步关闭，详细失败日志由客户端自身收口。
  Future<void> _closeDisposedConnection() async {
    try {
      await stop();
    } catch (error, stackTrace) {
      logger.warning(
        'RealtimeClient',
        '通知客户端销毁时关闭失败',
        '${safeErrorSummary(error)}\n$stackTrace',
      );
    }
  }
}
