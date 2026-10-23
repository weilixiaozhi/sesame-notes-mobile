import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:web_socket_channel/io.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/realtime_client.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 实时通知客户端：登录会话就绪后由 [realtimeCoordinatorProvider] 管理生命周期。
final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  ref.watch(cloudCapabilityProvider.select((value) => value.canSync));
  final client = ref.watch(apiClientProvider);
  final baseUrl = ref.watch(apiConfigProvider).baseUrl;

  // 通知风暴防抖：窗口内的 sync_change 合并为一轮 push+pull，避免把
  // 同步串行链（下拉刷新等待的 run()）拉到数秒。
  final syncTrigger = RealtimeSyncTrigger(
    sync: () async {
      if (!ref.mounted) return;
      final identity = ref.read(authIdentityGenerationProvider);
      final result = await ref.read(syncCoordinatorProvider).run();
      if (!ref.mounted ||
          identity != ref.read(authIdentityGenerationProvider) ||
          result.ok) {
        return;
      }
      final failure = result.failure;
      // 网络和服务短暂不可用仍属于本次补拉任务；权限、冲突或账号切换交给既有反馈与用户操作。
      if (failure != null &&
          const {
            'NETWORK_UNAVAILABLE',
            'CLOUD_SERVICE_UNAVAILABLE',
            'SYNC_OPERATION_FAILED',
          }.contains(failure.code)) {
        throw failure;
      }
      logger.warning(
        'RealtimeSync',
        '实时补拉等待后续操作: ${result.error ?? '仍有未完成的同步事项'}',
      );
    },
  );
  // 连接对象可跨令牌刷新复用，但账号/设备代次改变必须取消原身份的补拉和重试。
  ref.listen(authIdentityGenerationProvider, (_, _) {
    syncTrigger.cancelPending();
  });
  final realtimeClient = RealtimeClient(
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
      // 服务端批量落库会产生通知风暴：防抖合并窗口内的通知，避免每条
      // 通知各拉一轮、把同步串行链（下拉刷新等待的 run()）拖到数秒。
      logger.info('Realtime', '实时连接就绪或收到变更提示，防抖后触发增量拉取');
      syncTrigger.notify();
    },
  );
  ref.onDispose(() {
    // 先同步取消调度及在途取票，再异步关闭已捕获的通知通道。
    syncTrigger.dispose();
    realtimeClient.dispose();
  });
  return realtimeClient;
});

/// 实时 sync_change 通知的防抖触发。
///
/// 服务端批量落库时每条事件都会推一条 sync_change，逐条触发一轮
/// push+pull 会把同步编排器的串行链拉得很长（下拉刷新等待的 run()
/// 迟迟不返回）。本类把防抖窗口内的通知合并为一轮同步。
///
/// 同步执行期间的通知合并成一个立即尾随轮，失败只重试本次已知待办。
/// 重试次数和等待时间均有上限；成功、取消或用尽预算后不继续轮询。
class RealtimeSyncTrigger {
  /// 注入同步动作和计时器；恢复预算只服务已经收到的就绪或变更提示。
  RealtimeSyncTrigger({
    required this.sync,
    this.debounce = const Duration(seconds: 2),
    this.initialRetryDelay = const Duration(seconds: 5),
    this.maxRetryDelay = const Duration(seconds: 60),
    this.maxRetryAttempts = 5,
    RealtimeRetryScheduler? scheduleTimer,
  }) : scheduleTimer =
           scheduleTimer ?? ((delay, action) => Timer(delay, action)),
       assert(debounce >= Duration.zero),
       assert(initialRetryDelay > Duration.zero),
       assert(maxRetryDelay >= initialRetryDelay),
       assert(maxRetryAttempts >= 0);

  /// 合并窗口后执行的同步动作（一轮 push+pull）。
  final Future<void> Function() sync;

  /// 防抖窗口：窗口内重复通知只重置计时。
  final Duration debounce;

  /// 第一次失败后的等待时间，后续按倍数增长并限制在最大等待时间内。
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;

  /// 一次通知任务允许的重试次数，耗尽后等待新通知或用户主动同步。
  final int maxRetryAttempts;

  /// 定时器调度器（测试注入假时钟用）。
  final RealtimeRetryScheduler scheduleTimer;

  Timer? _timer;
  Timer? _retryTimer;
  bool _running = false;
  bool _pending = false;
  bool _disposed = false;
  int _retryAttempt = 0;
  int _generation = 0;

  /// 合并执行中或等待重试的通知，不以消息风暴重置失败退避或新增并发同步。
  void notify() {
    if (_disposed) return;
    if (_running) {
      _pending = true;
      return;
    }
    // 已排队的恢复轮会读取最新游标，期间的新通知不需要另设定时器。
    if (_retryTimer != null) return;
    _retryAttempt = 0;
    _timer?.cancel();
    _timer = scheduleTimer(debounce, () => unawaited(_run()));
  }

  /// 执行一轮并统一处理尾随和重试，迟到的异步结果不能重新激活已释放的调度器。
  Future<void> _run() async {
    if (_disposed || _running) return;
    _timer = null;
    _running = true;
    _pending = false;
    final generation = _generation;
    final succeeded = await _safeSync();
    if (_disposed || generation != _generation) return;
    _running = false;
    if (!succeeded) {
      _pending = false;
      _scheduleRetry();
      return;
    }
    _retryAttempt = 0;
    if (_pending) unawaited(_run());
  }

  /// 包含同步抛错与 Future 拒绝的共同错误边界，详细堆栈留在日志而不逃逸到定时器所在 Zone。
  Future<bool> _safeSync() async {
    try {
      await sync();
      return true;
    } catch (error, stackTrace) {
      logger.error(
        'RealtimeSync',
        '实时补拉未完成，将按本次通知的恢复预算处理',
        safeErrorSummary(error),
        stackTrace,
      );
      return false;
    }
  }

  /// 只为失败待办安排有限次退避，新的变更提示会合并到同一次恢复轮。
  void _scheduleRetry() {
    if (_disposed || _retryTimer != null) return;
    if (_retryAttempt >= maxRetryAttempts) {
      logger.warning('RealtimeSync', '实时补拉达到本次重试上限，等待新通知或手动同步');
      return;
    }
    final shifted = initialRetryDelay * (1 << _retryAttempt.clamp(0, 20));
    final delay = shifted > maxRetryDelay ? maxRetryDelay : shifted;
    _retryAttempt++;
    logger.info(
      'RealtimeSync',
      '实时补拉第 $_retryAttempt 次重试将在 ${delay.inMilliseconds} 毫秒后执行',
    );
    _retryTimer = scheduleTimer(delay, () {
      _retryTimer = null;
      if (!_disposed) unawaited(_run());
    });
  }

  /// 取消原身份的排队和尾随任务，迟到完成不能干扰下一身份的新同步轮。
  void cancelPending() {
    _generation++;
    _pending = false;
    _running = false;
    _retryAttempt = 0;
    _timer?.cancel();
    _timer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// 终止生命周期；在途动作完成或后续通知都不能复活调度器。
  void dispose() {
    _disposed = true;
    cancelPending();
  }
}

/// 实时协调器：登录后 start、登出后 stop，断线后按指数退避自动重连。
final realtimeCoordinatorProvider = Provider<RealtimeCoordinator>((ref) {
  final coordinator = RealtimeCoordinator(
    ref,
    client: ref.watch(realtimeClientProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// 重连计时器调度签名：生产走真实 [Timer]，测试注入受控实现。
typedef RealtimeRetryScheduler =
    Timer Function(Duration delay, void Function() action);

/// 实时通知生命周期管理。
///
/// 登录后 [start]、登出后 [stop]；断线时按指数退避重建通知连接。
/// 每次服务端确认连接就绪后安排一次游标补拉，覆盖断线期间未收到的通知。
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

  /// 账号事务覆盖同步队列与写屏障，禁止会话刷新在开闸瞬间提前恢复通知。
  bool _accountTransitionPending = false;

  /// 生命周期代次使旧取票失败、旧断线回调和旧定时器无法操作新连接。
  int _generation = 0;

  /// 容器结束后永久停止，不再读取已经销毁的 ref。
  bool _disposed = false;

  /// 客户端在所有者仍有效时捕获，销毁路径不依赖 ref.read。
  final RealtimeClient _client;

  /// 捕获通知客户端与重连策略，异步关闭无需再次访问容器。
  RealtimeCoordinator(
    this.ref, {
    RealtimeClient? client,
    RealtimeRetryScheduler? scheduleTimer,
    this.initialRetryDelay = defaultInitialRetryDelay,
    this.maxRetryDelay = defaultMaxRetryDelay,
  }) : _client = client ?? ref.read(realtimeClientProvider),
       scheduleTimer =
           scheduleTimer ?? ((delay, action) => Timer(delay, action));

  /// 建立实时通知连接并接管断线重连（登录成功后调用，已激活时幂等）。
  Future<void> start() async {
    if (_disposed || !ref.mounted || _active || _accountTransitionPending) {
      return;
    }
    // signIn 会在账号闸门内通知常驻装配；账号协调器负责开闸后的最终恢复。
    if (ref.read(syncGateProvider) ||
        !ref.read(cloudCapabilityProvider).canSync) {
      return;
    }
    _active = true;
    await _connect(++_generation);
  }

  /// 关闭实时通知连接并取消重连（登出/账号切换时调用）。
  Future<void> stop() async {
    _active = false;
    _generation++;
    _cancelRetry();
    _attempt = 0;
    try {
      await _client.stop();
    } catch (error, stackTrace) {
      logger.warning('Realtime', '实时通知关闭失败: $error', stackTrace);
    }
  }

  /// 账号协调器在最外层事务登记和结束时更新，通知启动等待最终身份收敛。
  void setAccountTransitionPending(bool pending) {
    if (_disposed) return;
    _accountTransitionPending = pending;
  }

  /// 建立一次连接；票据一次性，每次连接都重新签发。
  Future<void> _connect(int generation) async {
    if (!_isCurrent(generation)) return;
    try {
      await _client.start(
        onDisconnected: () => _handleDisconnected(generation),
      );
      if (!_isCurrent(generation)) return;
      // 连接成功：退避计数归零，下次断线从起始延迟开始。
      _attempt = 0;
    } catch (error, stackTrace) {
      if (!_isCurrent(generation)) return;
      // 通知通道失败后只安排 WS 重连，不启动 HTTP 轮询。
      // 鉴权类失败无需在此特判：access token 失效时刷新拦截器会尝试续期，
      // 刷新明确返回认证 401 才清空会话并 stop；网络或 5xx 保留会话与重连。
      logger.warning('Realtime', '实时通知连接失败，将退避重连并在就绪后补拉: $error', stackTrace);
      _scheduleRetry(generation);
    }
  }

  /// 断线回调：安排重连。已排队时不再重复排队，保证只有一个重连定时器。
  void _handleDisconnected(int generation) {
    if (!_isCurrent(generation)) return;
    logger.info('Realtime', '实时通知连接断开，准备重连');
    _scheduleRetry(generation);
  }

  /// 校验回调仍属于当前活跃的所有者与连接代次。
  bool _isCurrent(int generation) =>
      !_disposed &&
      ref.mounted &&
      _active &&
      generation == _generation &&
      ref.read(cloudCapabilityProvider).canSync;

  /// 为当前代次安排唯一重连任务，旧任务不得重启新身份的连接。
  void _scheduleRetry(int generation) {
    if (!_isCurrent(generation) || _retryTimer != null) return;
    final delay = _retryDelayFor(_attempt);
    _attempt++;
    logger.info('Realtime', '第 $_attempt 次重连将在 ${delay.inSeconds}s 后发起');
    _retryTimer = scheduleTimer(delay, () {
      if (!_isCurrent(generation)) return;
      _retryTimer = null;
      unawaited(_connect(generation));
    });
  }

  /// 同步取消当前已排队的重连。
  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// 先同步失效所有回调，再关闭已持有的客户端；销毁不读取容器状态。
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // stop 在首个 await 之前失效代次并取消计时器，关闭异常由同一入口记录。
    unawaited(stop());
  }

  /// 第 [attempt] 次重连的退避延迟：起始延迟按 2 的幂增长并封顶。
  Duration _retryDelayFor(int attempt) {
    final shifted = initialRetryDelay * (1 << attempt.clamp(0, _maxRetryShift));
    return shifted > maxRetryDelay ? maxRetryDelay : shifted;
  }
}
