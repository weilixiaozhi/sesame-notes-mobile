// WebSocket 实时通知客户端测试（WS 只通知有新变更，数据仍走 Pull 游标）。
//
// 需求锚点：
// - 连接前先经 POST /api/v1/ws/ticket 获取 30 秒单次票据；
// - 收到 {type:'sync_change'} 触发 onSyncChange 回调（仅通知去拉取）；
// - 非 sync_change 消息（如 ready/heartbeat）不触发回调；
// - stop 后停止监听；
// - 取票或建连失败后必须释放运行状态，后续 start 可以重试；
// - 对端关闭/通道异常必须通知断线（供协调器安排重连），主动 stop 不通知。
library;

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

    test('收到 sync_change 触发回调（仅通知，不携带数据）', () async {
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

      expect(events, ['sync'], reason: 'sync_change 必须触发一次回调');
      await client.stop();
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

  @override
  Stream<dynamic> get messages => _controller.stream;

  @override
  Future<void> close() => _controller.close();

  void emit(String message) => _controller.add(message);

  Future<void> dropByPeer() => _controller.close();

  Future<void> errorThenDone(Object error) async {
    _controller.addError(error);
    await _controller.close();
  }
}
