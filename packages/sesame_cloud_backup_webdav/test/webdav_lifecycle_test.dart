import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/src/webdav_provider.dart';

const _listing =
    '<?xml version="1.0" encoding="UTF-8"?><d:multistatus xmlns:d="DAV:"></d:multistatus>';

/// 只监听回环地址，使用真实 HTTP 验证关闭、超时和重配置的行为。
class _Server {
  _Server(this.server, this.subscription);
  final HttpServer server;
  final StreamSubscription<HttpRequest> subscription;

  /// 客户端取消后，服务端尚未发送的响应允许以连接关闭结束。
  static Future<_Server> start(
      Future<void> Function(HttpRequest) handler) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((request) async {
      try {
        await request.drain<void>();
        await handler(request);
      } on SocketException {
        // 测试主动关闭客户端时允许断开连接。
      } on HttpException {
        // 测试主动关闭客户端时允许响应未完成。
      }
    });
    return _Server(server, subscription);
  }

  /// 测试配置不使用公网服务或真实凭据。
  Map<String, dynamic> config([String user = 'test']) => {
        'url': 'http://127.0.0.1:${server.port}',
        'username': user,
        'password': 'test-only',
      };

  /// 关闭测试监听器及其全部连接。
  Future<void> close() async {
    await server.close(force: true);
    await subscription.cancel();
  }
}

/// 返回一个合法的空目录响应。
Future<void> _reply(HttpRequest request, {int status = 207}) async {
  request.response.statusCode = status;
  request.response.headers.contentType = ContentType('application', 'xml');
  if (status == 207) request.response.write(_listing);
  await request.response.close();
}

/// 所有等待均有测试级截止时间，失败时仍释放本地服务与挂起响应。
void main() {
  test('释放适配器立即中止在途目录请求，旧存储引用也不能继续使用', () async {
    final started = Completer<void>();
    final gate = Completer<void>();
    var hold = false;
    final server = await _Server.start((request) async {
      if (hold) {
        if (!started.isCompleted) started.complete();
        await gate.future;
      }
      await _reply(request);
    });
    final provider = WebDAVProvider();
    try {
      await provider.initialize(server.config());
      final storage = provider.storage;
      hold = true;
      final failed = expectLater(
          storage.list(path: 'slow'), throwsA(isA<CloudStorageException>()));
      await started.future.timeout(const Duration(seconds: 5));
      await provider.dispose();
      await failed.timeout(const Duration(seconds: 5));
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
      await expectLater(
          storage.list(path: 'closed'), throwsA(isA<CloudStorageException>()));
      await provider.dispose();
    } finally {
      if (!gate.isCompleted) gate.complete();
      await provider.dispose();
      await server.close();
    }
  });

  test('初始化等待期间释放后不能发布迟到连接，也不补发创建目录请求', () async {
    final started = Completer<void>();
    final gate = Completer<void>();
    final methods = <String>[];
    final server = await _Server.start((request) async {
      methods.add(request.method);
      if (!started.isCompleted) started.complete();
      await gate.future;
      await _reply(request);
    });
    final provider = WebDAVProvider();
    try {
      final failed = expectLater(provider.initialize(server.config()),
          throwsA(isA<CloudConfigurationException>()));
      await started.future.timeout(const Duration(seconds: 5));
      await provider.dispose();
      await failed.timeout(const Duration(seconds: 5));
      expect(methods, ['PROPFIND']);
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
    } finally {
      if (!gate.isCompleted) gate.complete();
      await provider.dispose();
      await server.close();
    }
  });

  test('旧初始化失败不能关闭新配置的客户端', () async {
    final started = Completer<void>();
    final gate = Completer<void>();
    final slow = await _Server.start((request) async {
      if (!started.isCompleted) started.complete();
      await gate.future;
      await _reply(request);
    });
    final fastAuthorization = <String?>[];
    final fast = await _Server.start((request) async {
      fastAuthorization
          .add(request.headers.value(HttpHeaders.authorizationHeader));
      if (fastAuthorization.last == null) {
        // 服务端声明 Basic 认证后，客户端才使用本次配置的凭据重试。
        request.response.headers
            .set(HttpHeaders.wwwAuthenticateHeader, 'Basic realm="test"');
        await _reply(request, status: HttpStatus.unauthorized);
        return;
      }
      await _reply(request);
    });
    final provider = WebDAVProvider();
    try {
      final oldFailed = expectLater(provider.initialize(slow.config('old')),
          throwsA(isA<CloudConfigurationException>()));
      await started.future.timeout(const Duration(seconds: 5));
      await provider.initialize(fast.config('new'));
      await oldFailed.timeout(const Duration(seconds: 5));
      expect(await provider.storage.list(path: ''), isEmpty);
      expect(fastAuthorization.last,
          'Basic ${base64Encode(utf8.encode('new:test-only'))}');
    } finally {
      if (!gate.isCompleted) gate.complete();
      await provider.dispose();
      await slow.close();
      await fast.close();
    }
  });

  test('目录响应超时会失败并关闭客户端，不把超时当作目录缺失', () async {
    final gate = Completer<void>();
    final methods = <String>[];
    final server = await _Server.start((request) async {
      methods.add(request.method);
      await gate.future;
      await _reply(request);
    });
    final provider =
        WebDAVProvider(requestTimeout: const Duration(milliseconds: 100));
    try {
      await expectLater(
        provider
            .initialize(server.config())
            .timeout(const Duration(seconds: 5)),
        throwsA(isA<CloudConfigurationException>()),
      );
      expect(methods, ['PROPFIND']);
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
    } finally {
      if (!gate.isCompleted) gate.complete();
      await provider.dispose();
      await server.close();
    }
  });

  test('只有404会创建目录，认证或服务端错误直接失败', () async {
    for (final status in [404, 401, 403, 500]) {
      final methods = <String>[];
      final server = await _Server.start((request) async {
        methods.add(request.method);
        await _reply(request, status: request.method == 'MKCOL' ? 201 : status);
      });
      final provider = WebDAVProvider();
      try {
        if (status == 404) {
          await provider.initialize(server.config());
          expect(methods, ['PROPFIND', 'MKCOL']);
        } else {
          await expectLater(provider.initialize(server.config()),
              throwsA(isA<CloudConfigurationException>()));
          expect(methods, ['PROPFIND']);
        }
      } finally {
        await provider.dispose();
        await server.close();
      }
    }
  });

  test('不同适配器的连接独立，重复关闭不影响另一实例', () async {
    final authorization = <String?>[];
    final server = await _Server.start((request) async {
      authorization.add(request.headers.value(HttpHeaders.authorizationHeader));
      if (authorization.last == null) {
        // 每个客户端独立完成认证协商，关闭另一实例不会改变其认证头。
        request.response.headers
            .set(HttpHeaders.wwwAuthenticateHeader, 'Basic realm="test"');
        await _reply(request, status: HttpStatus.unauthorized);
        return;
      }
      await _reply(request);
    });
    final first = WebDAVProvider();
    final second = WebDAVProvider();
    try {
      await Future.wait([
        first.initialize(server.config('first')),
        second.initialize(server.config('second'))
      ]);
      await first.dispose();
      await first.dispose();
      expect(await second.storage.list(path: ''), isEmpty);
      expect(authorization.last,
          'Basic ${base64Encode(utf8.encode('second:test-only'))}');
      await expectLater(
        second.storage.list(path: '../escape'),
        throwsA(isA<CloudStorageException>()),
      );
    } finally {
      await first.dispose();
      await second.dispose();
      await server.close();
    }
  });
}
