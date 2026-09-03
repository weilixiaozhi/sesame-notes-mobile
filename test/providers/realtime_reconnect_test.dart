/// 实时通知断线自动重连测试。
///
/// 需求锚点：
/// - 连接断开（对端关闭/通道异常）后由 RealtimeCoordinator 自动安排重连，
///   不依赖 auth session 变化；
/// - 重连必须重新取票据（票据一次性，不可复用）；
/// - 重连按指数退避递增，连接成功后退避归零；
/// - stop（登出/账号切换）取消挂起的重连定时器，主动关闭不触发重连；
/// - 重连成功后收到 sync_change 仍然触发拉取。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/realtime_client.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTicketApi tickets;
  late FakeSocketFactory sockets;
  late FakeRetryScheduler scheduler;
  late List<String> syncCalls;

  setUp(() {
    tickets = FakeTicketApi();
    sockets = FakeSocketFactory();
    scheduler = FakeRetryScheduler();
    syncCalls = [];
  });

  /// 装配容器：客户端换成假实现，协调器注入受控重连调度器。
  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        realtimeClientProvider.overrideWithValue(
          RealtimeClient(
            ticketProvider: tickets.fetch,
            connect: sockets.open,
            onSyncChange: () async => syncCalls.add('sync'),
          ),
        ),
        realtimeCoordinatorProvider.overrideWith(
          (ref) => RealtimeCoordinator(ref, scheduleTimer: scheduler.schedule),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// 冲刷异步队列：重连链路含 await 取票与断线回调通知。
  Future<void> pump() async {
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('断线后自动重连，重连重新取票据', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    expect(tickets.calls, 1);
    expect(sockets.opened, 1);

    await sockets.dropByPeer();
    await pump();

    expect(scheduler.delays, [
      RealtimeCoordinator.defaultInitialRetryDelay,
    ], reason: '断线必须自动安排一次重连');

    scheduler.fireLast();
    await pump();

    expect(tickets.calls, 2, reason: '票据一次性，重连必须重新取票');
    expect(sockets.opened, 2, reason: '重连必须建立新连接');
    expect(sockets.lastTicket, 'ticket-2');
  });

  test('重连成功后收到 sync_change 仍触发拉取', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await sockets.dropByPeer();
    await pump();
    scheduler.fireLast();
    await pump();

    sockets.emit('{"type":"sync_change"}');
    await pump();

    expect(syncCalls, ['sync'], reason: '重连后必须能收到跨端变更通知');
  });

  test('首次连接失败也安排重连', () async {
    tickets.failures = {1};
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await pump();

    expect(scheduler.delays, hasLength(1), reason: '连接失败必须安排重试');
    scheduler.fireLast();
    await pump();

    expect(sockets.opened, 1, reason: '重试成功后建立连接');
    expect(sockets.lastTicket, 'ticket-2');
  });

  test('重连失败按指数退避递增，连接成功后归零', () async {
    tickets.failures = {2, 3};
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await sockets.dropByPeer();
    await pump();
    expect(scheduler.delays.last, const Duration(seconds: 2));

    scheduler.fireLast();
    await pump();
    expect(scheduler.delays.last, const Duration(seconds: 4));

    scheduler.fireLast();
    await pump();
    expect(
      scheduler.delays.last,
      const Duration(seconds: 8),
      reason: '连续失败必须按 2 的幂递增退避',
    );

    // 第 4 次取票成功，退避计数归零。
    scheduler.fireLast();
    await pump();
    expect(sockets.opened, 2, reason: '重连成功');

    await sockets.dropByPeer();
    await pump();
    expect(
      scheduler.delays.last,
      RealtimeCoordinator.defaultInitialRetryDelay,
      reason: '连接成功后退避必须归零',
    );
  });

  test('连续重连失败时退避封顶在上限', () async {
    tickets.failures = {2, 3, 4, 5, 6, 7};
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    // 连续 6 轮「断线 → 重连失败」：2→4→8→16→32→60→60（64s 起被封顶）。
    for (var i = 0; i < 6; i++) {
      await sockets.dropByPeer();
      await pump();
      scheduler.fireLast();
      await pump();
    }

    expect(scheduler.delays, [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
      const Duration(seconds: 16),
      const Duration(seconds: 32),
      RealtimeCoordinator.defaultMaxRetryDelay,
      RealtimeCoordinator.defaultMaxRetryDelay,
    ], reason: '退避按 2 的幂增长，并封顶在上限');
  });

  test('stop 取消挂起的重连定时器', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await sockets.dropByPeer();
    await pump();
    expect(scheduler.scheduled, hasLength(1));

    await coordinator.stop();

    expect(
      scheduler.scheduled.single.cancelled,
      isTrue,
      reason: '登出/账号切换必须取消重连定时器',
    );
  });

  test('stop 后定时器到期也不重连', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await sockets.dropByPeer();
    await pump();
    await coordinator.stop();

    scheduler.fireLast();
    await pump();

    expect(tickets.calls, 1, reason: 'stop 后不得再取票重连');
    expect(sockets.opened, 1);
  });

  test('主动 stop 不触发重连', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await coordinator.stop();
    await pump();

    expect(scheduler.delays, isEmpty, reason: '主动关闭不是断线');
    expect(sockets.opened, 1);
  });

  test('会话刷新导致重复 start 时不重复建连', () async {
    final container = buildContainer();
    final coordinator = container.read(realtimeCoordinatorProvider);

    await coordinator.start();
    await coordinator.start();

    expect(tickets.calls, 1, reason: '已激活的协调器重复 start 必须幂等');
    expect(sockets.opened, 1);
  });
}

/// 假票据接口：按调用序号签发票据，可指定失败序号。
class FakeTicketApi {
  int calls = 0;
  Set<int> failures = const {};

  Future<String> fetch() async {
    calls++;
    if (failures.contains(calls)) throw StateError('票据 $calls 签发失败');
    return 'ticket-$calls';
  }
}

/// 假 Socket 工厂：记录建连次数与票据，可模拟服务端消息与断线。
class FakeSocketFactory {
  int opened = 0;
  String? lastTicket;
  final sockets = <_FakeSocket>[];

  RealtimeSocket open(String ticket) {
    opened++;
    lastTicket = ticket;
    final socket = _FakeSocket();
    sockets.add(socket);
    return socket;
  }

  _FakeSocket get _last => sockets.last;

  void emit(String message) => _last.emit(message);

  /// 模拟对端主动断开。
  Future<void> dropByPeer() => _last.close();
}

class _FakeSocket implements RealtimeSocket {
  final _controller = StreamController<dynamic>();

  @override
  Stream<dynamic> get messages => _controller.stream;

  @override
  Future<void> close() => _controller.close();

  void emit(String message) => _controller.add(message);
}

/// 受控重连调度器：记录退避延迟，由测试手动触发到期。
class FakeRetryScheduler {
  final delays = <Duration>[];
  final scheduled = <_ScheduledRetry>[];

  Timer schedule(Duration delay, void Function() action) {
    delays.add(delay);
    final retry = _ScheduledRetry(action);
    scheduled.add(retry);
    return retry;
  }

  /// 触发最近一次排队的重连；已取消的定时器不会触发（与真实 Timer 一致）。
  void fireLast() => scheduled.last.fire();
}

class _ScheduledRetry implements Timer {
  final void Function() action;
  bool cancelled = false;
  bool _fired = false;

  _ScheduledRetry(this.action);

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled && !_fired;

  @override
  int get tick => 0;

  void fire() {
    if (cancelled || _fired) return;
    _fired = true;
    action();
  }
}
