import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/sync/realtime_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RealtimeClient', () {
    late FakeTicketApi ticketApi;
    late FakeSocketFactory sockets;

    setUp(() {
      ticketApi = FakeTicketApi();
      sockets = FakeSocketFactory();
    });

    test('连接前获取票据，成功后建立连接', () async {
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );

      await client.start();

      expect(ticketApi.calls, 1, reason: '必须先取票据');
      expect(sockets.opened, 1, reason: '拿到票据后必须建立连接');
      expect(sockets.lastTicket, 'ticket-1', reason: '连接必须携带票据');
      await client.stop();
    });

    test('ready 补齐断线窗口且 sync_change 继续触发增量同步', () async {
      final events = <String>[];
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
        onSyncChange: () async => events.add('sync'),
      );

      await client.start();
      sockets.emit('{"type":"ready","server_time":"2026-01-01T00:00:00Z"}');
      sockets.emit(
        '{"type":"sync_change","server_time":"2026-01-01T00:00:01Z"}',
      );
      // 等待异步回调执行。
      await Future<void>.delayed(Duration.zero);

      expect(events, ['sync', 'sync'], reason: '就绪补拉与变更通知都必须进入同步调度');
      await client.stop();
    });

    test('同连接 ready 去重，重连后无新通知也必须再次补拉', () async {
      var pulls = 0;
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
        onSyncChange: () async => pulls++,
      );
      addTearDown(client.stop);
      await client.start();
      sockets.emit('{"type":"ready"}');
      sockets.emit('{"type":"ready"}');
      await Future<void>.delayed(Duration.zero);
      expect(pulls, 1);

      await sockets.dropByPeer();
      await Future<void>.delayed(Duration.zero);
      await client.start();
      sockets.emit('{"type":"ready"}');
      await Future<void>.delayed(Duration.zero);
      expect(pulls, 2, reason: '远端写入即使发生在断线期间，ready 也必须补拉');
    });

    test('补拉回调异常记录日志且后续通知仍可恢复', () async {
      var attempts = 0;
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
        onSyncChange: () async {
          if (++attempts == 1) throw StateError('暂时无法补拉');
        },
      );
      addTearDown(client.stop);
      await client.start();
      sockets.emit('{"type":"ready"}');
      await Future<void>.delayed(Duration.zero);
      sockets.emit('{"type":"sync_change"}');
      await Future<void>.delayed(Duration.zero);
      expect(attempts, 2);
    });

    test('未知类型消息不触发回调', () async {
      final events = <String>[];
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
        onSyncChange: () async => events.add('sync'),
      );

      await client.start();
      sockets.emit('{"type":"heartbeat"}');

      expect(events, isEmpty, reason: '非 sync_change 不得触发拉取');
      await client.stop();
    });

    test('start 幂等：重复调用只建一次连接', () async {
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );

      await client.start();
      await client.start();

      expect(sockets.opened, 1, reason: '已运行时重复 start 必须幂等');
      await client.stop();
    });

    test('退出后返回的在途票据不得建立连接', () async {
      final ticket = Completer<String>();
      final client = RealtimeClient(
        ticketProvider: () => ticket.future,
        connect: sockets.open,
      );
      addTearDown(client.stop);

      final connecting = client.start();
      await client.stop();
      ticket.complete('ticket-a');
      await connecting;

      expect(sockets.opened, 0, reason: '退出必须使尚未完成的取票失效');
    });

    test('销毁使在途票据永久失效，重复启动不能创建连接', () async {
      final ticket = Completer<String>();
      var calls = 0;
      final client = RealtimeClient(
        ticketProvider: () {
          calls++;
          return ticket.future;
        },
        connect: sockets.open,
      );
      final connecting = client.start();
      client.dispose();
      ticket.complete('late-ticket');
      await connecting;
      await client.start();
      expect(calls, 1);
      expect(sockets.opened, 0, reason: '销毁必须永久阻止旧所有者再建连');
    });

    test('销毁同步摘下连接，重复启动不能复活已经关闭的通道', () async {
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );
      await client.start();
      client.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(sockets.sockets.single.isClosed, isTrue);
      await client.start();
      expect(sockets.opened, 1);
    });

    test('换号后返回的旧票据不得覆盖新账号连接', () async {
      final ticket = Completer<String>();
      var calls = 0;
      final client = RealtimeClient(
        ticketProvider: () =>
            ++calls == 1 ? ticket.future : Future.value('ticket-b'),
        connect: sockets.open,
      );
      addTearDown(client.stop);

      final oldConnection = client.start();
      await client.stop();
      await client.start();
      ticket.complete('ticket-a');
      await oldConnection;

      expect(sockets.opened, 1, reason: '换号后只能保留新账号的连接');
      expect(sockets.lastTicket, 'ticket-b');
    });

    test('旧账号的取票失败不得清理新账号连接或破坏启动幂等', () async {
      final ticket = Completer<String>();
      var calls = 0;
      final events = <String>[];
      final client = RealtimeClient(
        ticketProvider: () =>
            ++calls == 1 ? ticket.future : Future.value('ticket-b'),
        connect: sockets.open,
        onSyncChange: () async => events.add('sync-b'),
      );
      addTearDown(client.stop);

      final oldConnection = client.start();
      await client.stop();
      await client.start();
      ticket.completeError(StateError('账号 A 的票据已失效'));
      await oldConnection;
      await client.start();
      sockets.emit('{"type":"sync_change"}');
      await Future<void>.delayed(Duration.zero);

      expect(sockets.opened, 1, reason: '旧账号异常不能释放新连接的运行状态');
      expect(events, ['sync-b'], reason: '新账号连接必须继续处理通知');
    });

    test('旧连接关闭完成时不得清空期间建立的新连接', () async {
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );
      addTearDown(client.stop);
      await client.start();
      final firstSocket = sockets.sockets.single;
      firstSocket.closeDelay = Completer<void>();

      final stopping = client.stop();
      await firstSocket.closeStarted.future;
      await client.start();
      firstSocket.closeDelay!.complete();
      await stopping;
      await client.stop();

      expect(
        sockets.sockets.last.isClosed,
        isTrue,
        reason: '新连接必须仍被持有，退出才能正确关闭它',
      );
    });

    test('首次取票失败后再次 start 可以重新取票并连接', () async {
      var calls = 0;
      final client = RealtimeClient(
        ticketProvider: () async {
          calls++;
          if (calls == 1) throw StateError('ticket failed');
          return 'ticket-2';
        },
        connect: sockets.open,
      );

      await expectLater(client.start(), throwsStateError);
      await client.start();

      expect(calls, 2, reason: '失败后不能被旧 _running 状态永久短路');
      expect(sockets.opened, 1);
      expect(sockets.lastTicket, 'ticket-2');
      await client.stop();
    });

    test('对端关闭连接时通知断线，且重连重新取票', () async {
      var disconnects = 0;
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );

      await client.start(onDisconnected: () => disconnects++);
      await sockets.dropByPeer();
      await Future<void>.delayed(Duration.zero);

      expect(disconnects, 1, reason: '对端断开必须通知调用方安排重连');
      expect(sockets.opened, 1, reason: '断线通知本身不得建连');

      // 断线后运行状态已释放：再次 start 即重连，须重新取票。
      await client.start(onDisconnected: () => disconnects++);

      expect(ticketApi.calls, 2, reason: '票据一次性，重连必须重新取');
      expect(sockets.opened, 2, reason: '重连必须建立新连接');
      expect(sockets.lastTicket, 'ticket-2');
      await client.stop();
    });

    test('主动 stop 不通知断线', () async {
      var disconnects = 0;
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );

      await client.start(onDisconnected: () => disconnects++);
      await client.stop();
      await Future<void>.delayed(Duration.zero);

      expect(disconnects, 0, reason: '主动关闭不是断线，不得触发重连');
    });

    test('关闭失败原样交给调用方，旧连接已摘下且下一次启动仍能建连', () async {
      final failure = StateError('模拟连接关闭失败');
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );
      await client.start();
      final oldSocket = sockets.sockets.single;
      oldSocket.closeError = failure;

      await expectLater(client.stop(), throwsA(same(failure)));
      expect(oldSocket.isClosed, isTrue);
      await client.start();
      expect(ticketApi.calls, 2);
      expect(sockets.opened, 2);
      expect(sockets.sockets.last.isClosed, isFalse);
      await client.stop();
      expect(sockets.sockets.last.isClosed, isTrue);
    });

    test('通道异常后紧跟的 done 只通知一次断线', () async {
      var disconnects = 0;
      final client = RealtimeClient(
        ticketProvider: ticketApi.fetch,
        connect: sockets.open,
      );

      await client.start(onDisconnected: () => disconnects++);
      await sockets.errorThenDone(StateError('socket boom'));
      await Future<void>.delayed(Duration.zero);

      expect(disconnects, 1, reason: 'error 与随后的 done 只应产生一次断线通知');
    });
  });
}

/// 假票据接口：按调用序号签发票据。
class FakeTicketApi {
  int calls = 0;

  Future<String> fetch() async {
    calls++;
    return 'ticket-$calls';
  }
}

/// 假 Socket 工厂：记录打开次数与票据，可模拟服务端消息与断线。
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

  /// 模拟对端主动断开（stream done）。
  Future<void> dropByPeer() => _last.dropByPeer();

  /// 模拟通道异常：error 之后紧跟 done（dart:io WebSocket 的真实行为）。
  Future<void> errorThenDone(Object error) => _last.errorThenDone(error);
}

class _FakeSocket implements RealtimeSocket {
  final _controller = StreamController<dynamic>();
  final closeStarted = Completer<void>();
  Completer<void>? closeDelay;
  Object? closeError;

  bool get isClosed => _controller.isClosed;

  @override
  Stream<dynamic> get messages => _controller.stream;

  /// 记录关闭进度，并支持测试等待旧连接关闭完成的并发窗口。
  @override
  Future<void> close() async {
    if (!closeStarted.isCompleted) closeStarted.complete();
    await _controller.close();
    await closeDelay?.future;
    if (closeError case final error?) throw error;
  }

  void emit(String message) => _controller.add(message);

  Future<void> dropByPeer() => _controller.close();

  Future<void> errorThenDone(Object error) async {
    _controller.addError(error);
    await _controller.close();
  }
}
