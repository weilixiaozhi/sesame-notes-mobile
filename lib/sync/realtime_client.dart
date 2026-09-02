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
/// - 收到 {type:'sync_change'} 仅触发 [onSyncChange] 回调（通知去拉取），
///   事件本身不作为状态来源——变更数据一律经 Pull 游标获取；
/// - 连接被对端关闭或通道异常时回调 [start] 传入的 onDisconnected，由调用方
///   安排重连；票据一次性，重连一律走新的 [start] 重新取票。
class RealtimeClient {
  /// 票据获取回调（通常走 RealtimeApi.postWsTicket）。
  final Future<String> Function() ticketProvider;

  /// 连接工厂：票据 → 已建立的 socket（测试可注入假实现）。
  final RealtimeSocket Function(String ticket) connect;

  /// 收到 sync_change 通知时的回调。
  final Future<void> Function()? onSyncChange;

  RealtimeSocket? _socket;
  StreamSubscription<dynamic>? _sub;
  bool _running = false;

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
    if (_running) return;
    _running = true;
    _stopping = false;
    _disconnectNotified = false;
    _onDisconnected = onDisconnected;
    try {
      // 每次连接都重新取票据（30 秒单次，过期即失效）。
      final ticket = await ticketProvider();
      final socket = connect(ticket);
      _socket = socket;

      _sub = socket.messages.listen(
        _onMessage,
        onError: (Object error, StackTrace stackTrace) {
          logger.warning('RealtimeClient', '实时通知连接异常: $error', stackTrace);
          _notifyDisconnected();
        },
        onDone: _notifyDisconnected,
      );
    } catch (e, st) {
      // 取票或建连失败后必须释放幂等状态，否则后续 start 会永久短路。
      _running = false;
      try {
        await _sub?.cancel();
        await _socket?.close();
      } catch (cleanupError, cleanupStackTrace) {
        logger.warning(
          'RealtimeClient',
          '连接失败后的资源清理异常: $cleanupError',
          cleanupStackTrace,
        );
      } finally {
        _sub = null;
        _socket = null;
      }
      logger.error('RealtimeClient', '建立实时通知连接失败', e, st);
      rethrow;
    }
  }

  /// 处理连接中断：释放本连接资源并通知调用方安排重连。
  ///
  /// 主动 [stop] 不是断线，不通知；通道异常会先触发 onError 再触发 onDone，
  /// 用 [_disconnectNotified] 去重，保证一次断线只通知一次。
  void _notifyDisconnected() {
    if (_stopping || _disconnectNotified) return;
    _disconnectNotified = true;
    final sub = _sub;
    _sub = null;
    _socket = null;
    _running = false;
    // 断线时底层通道已由对端关闭（dart:io WebSocket 出错后必定关闭流），
    // 这里只需停止订阅，socket 引用置空后即可回收。
    unawaited(sub?.cancel());
    _onDisconnected?.call();
  }

  void _onMessage(dynamic raw) {
    try {
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      // 仅 sync_change 需要行动：通知去拉取，不携带任何业务数据。
      if (message['type'] == 'sync_change') {
        onSyncChange?.call();
      }
    } catch (_) {
      // 非法消息忽略：WS 通知通道不承载关键路径，解析失败不中断。
    }
  }

  /// 关闭连接并停止监听；主动关闭不会触发断线通知。
  Future<void> stop() async {
    _stopping = true;
    _running = false;
    _onDisconnected = null;
    await _sub?.cancel();
    _sub = null;
    await _socket?.close();
    _socket = null;
  }
}
