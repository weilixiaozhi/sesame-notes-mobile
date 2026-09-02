import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:web_socket_channel/io.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/realtime_client.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 实时通知客户端：登录会话就绪后由 [realtimeCoordinatorProvider] 管理生命周期。
final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final client = ref.watch(apiClientProvider);
  final baseUrl = ref.watch(apiConfigProvider).baseUrl;

  return RealtimeClient(
    // 每次连接取 30 秒单次票据（后端防止 Access Token 泄漏进 WS URL）。
    ticketProvider: () async {
      final resp = await RealtimeApi(
        client.dio,
        client.serializers,
      ).postWsTicket();
      return resp.data!.ticket;
    },
    connect: (ticket) {
      // WS 端点由 HTTP baseUrl 推导：http→ws, https→wss。
      final wsUri = Uri.parse(
        '${baseUrl.replaceFirst('http', 'ws')}/api/v1/ws?ticket=$ticket',
      );
      return ChannelRealtimeSocket(IOWebSocketChannel.connect(wsUri));
    },
    onSyncChange: () async {
      // WS 只通知「有新变更」，数据仍走 Pull 游标补齐。
      logger.info('Realtime', '收到 sync_change 通知，触发增量拉取');
      await ref.read(syncCoordinatorProvider).run();
    },
  );
});

/// 实时协调器：登录后 start、登出后 stop，断线后按指数退避自动重连。
final realtimeCoordinatorProvider = Provider<RealtimeCoordinator>((ref) {
  return RealtimeCoordinator(ref);
});

/// 重连计时器调度签名：生产走真实 [Timer]，测试注入受控实现。
typedef RealtimeRetryScheduler =
    Timer Function(Duration delay, void Function() action);

/// 实时通知生命周期管理。
///
/// 登录后 [start]、登出后 [stop]；连接被对端断开时按指数退避自动重连，
/// 使静默跨端变更不必等待手动刷新、resumed 或本地写触发。
class RealtimeCoordinator {
  /// 首次重连等待；每次失败翻倍，直到 [defaultMaxRetryDelay]。
  static const defaultInitialRetryDelay = Duration(seconds: 2);

  /// 重连等待上限，防止服务端长时间不可用时退避无限增长。
  static const defaultMaxRetryDelay = Duration(seconds: 60);

  /// 退避位移上限：2^10 × 2s 已远超上限，用于防止位移溢出。
  static const _maxRetryShift = 10;

  final Ref ref;

  /// 重连计时器调度器。
  final RealtimeRetryScheduler scheduleTimer;

  /// 重连起始等待（测试可缩短）。
  final Duration initialRetryDelay;

  /// 重连等待上限。
  final Duration maxRetryDelay;

  Timer? _retryTimer;

  /// 连续失败次数：连接成功后归零。
  int _attempt = 0;

  /// 生命周期开关：登录态为 true，登出/账号切换为 false。
  bool _active = false;

  RealtimeCoordinator(
    this.ref, {
    RealtimeRetryScheduler? scheduleTimer,
    this.initialRetryDelay = defaultInitialRetryDelay,
    this.maxRetryDelay = defaultMaxRetryDelay,
  }) : scheduleTimer =
           scheduleTimer ?? ((delay, action) => Timer(delay, action));

  RealtimeClient get _client => ref.read(realtimeClientProvider);

  /// 建立实时通知连接并接管断线重连（登录成功后调用，已激活时幂等）。
  Future<void> start() async {
    if (_active) return;
    _active = true;
    await _connect();
  }

  /// 关闭实时通知连接并取消重连（登出/账号切换时调用）。
  Future<void> stop() async {
    _active = false;
    _cancelRetry();
    _attempt = 0;
    try {
      await _client.stop();
    } catch (e) {
      logger.warning('Realtime', '实时通知关闭失败: $e');
    }
  }

  /// 建立一次连接；票据一次性，每次连接都重新签发。
  Future<void> _connect() async {
    if (!_active) return;
    try {
      await _client.start(onDisconnected: _handleDisconnected);
      // 连接成功：退避计数归零，下次断线从起始延迟开始。
      _attempt = 0;
    } catch (e) {
      // 通知通道失败不阻断主流程：数据一致性由 Pull 游标保证。
      // 鉴权类失败无需在此特判：access token 失效时刷新拦截器会尝试续期，
      // 续期失败则清空会话，会话为 null 会走到 stop() 取消重连。
      logger.warning('Realtime', '实时通知连接失败（降级为轮询拉取）: $e');
      _scheduleRetry();
    }
  }

  /// 断线回调：安排重连。已排队时不再重复排队，保证只有一个重连定时器。
  void _handleDisconnected() {
    if (!_active) return;
    logger.info('Realtime', '实时通知连接断开，准备重连');
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_active || _retryTimer != null) return;
    final delay = _retryDelayFor(_attempt);
    _attempt++;
    logger.info('Realtime', '第 $_attempt 次重连将在 ${delay.inSeconds}s 后发起');
    _retryTimer = scheduleTimer(delay, () {
      _retryTimer = null;
      unawaited(_connect());
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// 第 [attempt] 次重连的退避延迟：起始延迟按 2 的幂增长并封顶。
  Duration _retryDelayFor(int attempt) {
    final shifted = initialRetryDelay * (1 << attempt.clamp(0, _maxRetryShift));
    return shifted > maxRetryDelay ? maxRetryDelay : shifted;
  }
}
