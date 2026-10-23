import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_supabase/src/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _first = {'url': 'https://first.invalid', 'anonKey': 'test-key'};
const _second = {'url': 'https://second.invalid', 'anonKey': 'test-key'};

/// 监听真实 SDK 的认证流关闭，确认 dispose 已到达底层资源。
Future<void> _closed(SupabaseClient client) {
  final closed = Completer<void>();
  final subscription = client.auth.onAuthStateChange.listen(
    (_) {},
    onDone: closed.complete,
  );
  addTearDown(subscription.cancel);
  return closed.future;
}

/// 在回环地址接收真实 SDK 请求，响应内容由用例控制。
Future<HttpServer> _authServer(
  FutureOr<void> Function(HttpRequest request, Map<String, dynamic> body) reply,
) async {
  try {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      try {
        final contents = await utf8.decoder.bind(request).join();
        final body = contents.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(contents) as Map<String, dynamic>;
        request.response.headers.contentType = ContentType.json;
        await reply(request, body);
      } catch (error, stack) {
        stderr.writeln('Supabase 测试响应失败：$error\n$stack');
        rethrow;
      } finally {
        await request.response.close();
      }
    });
    return server;
  } catch (error, stack) {
    stderr.writeln('Supabase 测试服务创建失败：$error\n$stack');
    rethrow;
  }
}

/// 使用真实客户端验证资源生命周期，配置登录只访问本机测试服务。
void main() {
  test('释放适配器会关闭 SDK 认证流，重复释放安全', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    await provider.initialize(_first);
    final closed = _closed(provider.client!);
    await provider.dispose();
    await closed.timeout(const Duration(seconds: 5));
    expect(provider.client, isNull);
    expect(() => provider.storage, throwsA(isA<CloudConfigurationException>()));
    await provider.dispose();
  });

  test('切换配置先关闭旧客户端，再使用新地址创建客户端', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    await provider.initialize(_first);
    final original = provider.client!;
    final closed = _closed(original);
    await provider.initialize(_second);
    await closed.timeout(const Duration(seconds: 5));
    expect(identical(provider.client, original), isFalse);
    expect(provider.client!.rest.url, startsWith(_second['url']!));
  });

  test('并发备份和连接测试互不共享客户端，释放一方不影响另一方', () async {
    final first = SupabaseProvider();
    final second = SupabaseProvider();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await Future.wait([first.initialize(_first), second.initialize(_first)]);
    expect(identical(first.client, second.client), isFalse);
    var secondClosed = false;
    final secondDone = _closed(second.client!).then((_) => secondClosed = true);
    await first.dispose();
    expect(secondClosed, isFalse);
    expect(second.client, isNotNull);
    await second.dispose();
    await secondDone.timeout(const Duration(seconds: 5));
  });

  test('紧邻初始化的释放和再次初始化按调用顺序执行', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    final initialized = provider.initialize(_first);
    final disposed = provider.dispose();
    await Future.wait([initialized, disposed]);
    expect(provider.client, isNull);
    await provider.initialize(_second);
    expect(provider.client!.rest.url, startsWith(_second['url']!));
  });

  test('无效配置不会污染后续初始化队列', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    await expectLater(
      provider.initialize({}),
      throwsA(isA<CloudConfigurationException>()),
    );
    await provider.initialize(_first);
    expect(provider.client, isNotNull);
  });

  test('工厂按配置完成登录，账号修剪、密码原值和默认用户目录均保持', () async {
    final loginBodies = <Map<String, dynamic>>[];
    final storageRequests = <String>[];
    final server = await _authServer((request, body) {
      if (request.uri.path == '/auth/v1/token') {
        expect(request.uri.queryParameters['grant_type'], 'password');
        loginBodies.add(body);
        request.response.write(jsonEncode({
          'access_token': 'test-token',
          'token_type': 'bearer',
          'user': {'id': 'account', 'email': 'account@example.com'},
        }));
      } else {
        storageRequests.add(request.uri.path);
        expect(body['prefix'], 'users/account');
        expect(request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer test-token');
        request.response.write('[]');
      }
    });
    registerSupabaseBackend();
    addTearDown(() => CloudProviderRegistry.unregister('supabase'));
    final provider = await createCloudProvider(CloudServiceConfig(
      backendId: 'supabase',
      settings: {
        'url': 'http://127.0.0.1:${server.port}',
        'anonKey': 'test-key',
        'account': '  account@example.com  ',
        'password': '  password with spaces  ',
      },
    ));
    expect(provider, isA<SupabaseProvider>());
    final supabase = provider! as SupabaseProvider;
    try {
      expect(supabase.client!.auth.currentUser!.id, 'account');
      expect(loginBodies.single['email'], 'account@example.com');
      expect(loginBodies.single['password'], '  password with spaces  ');
      expect(await supabase.storage.list(path: ''), isEmpty);
      await expectLater(supabase.storage.delete(path: ''),
          throwsA(isA<CloudStorageException>()));
      expect(storageRequests, ['/storage/v1/object/list/sesame-notes-backups']);
    } finally {
      await supabase.dispose();
    }
  });

  test('配置登录错误保留认证类型、服务端错误码和原始异常，并关闭SDK资源', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    Future<void>? closed;
    final server = await _authServer((request, body) {
      closed = _closed(provider.client!);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.headers.set('x-supabase-api-version', '2024-01-01');
      request.response.write(jsonEncode({
        'message': 'Invalid login credentials',
        'code': 'invalid_credentials',
        'error_code': 'invalid_credentials',
      }));
    });
    await expectLater(
      provider.initialize({
        'url': 'http://127.0.0.1:${server.port}',
        'anonKey': 'test-key',
        'account': 'account@example.com',
        'password': 'incorrect-password',
      }),
      throwsA(isA<CloudAuthException>()
          .having((error) => error.code, '认证错误码', 'invalid_credentials')
          .having((error) => error.originalError, 'SDK 原始认证错误',
              isA<AuthApiException>())),
    );
    expect(closed, isNotNull);
    await closed!.timeout(const Duration(seconds: 5));
    expect(provider.client, isNull);
    expect(() => provider.storage, throwsA(isA<CloudConfigurationException>()));
    await provider.initialize(_first);
    expect(provider.client, isNotNull, reason: '一次认证失败不能阻断后续初始化队列');
  });

  test('配置登录缺少用户时按认证失败处理，释放客户端而不发布可用存储', () async {
    final provider = SupabaseProvider();
    addTearDown(provider.dispose);
    Future<void>? closed;
    final server = await _authServer((request, body) {
      closed = _closed(provider.client!);
      request.response.write('{}');
    });
    await expectLater(
      provider.initialize({
        'url': 'http://127.0.0.1:${server.port}',
        'anonKey': 'test-key',
        'account': 'account@example.com',
        'password': 'test-password',
      }),
      throwsA(isA<CloudAuthException>()
          .having((error) => error.message, '用户会话缺失提示', contains('未返回用户会话'))),
    );
    expect(closed, isNotNull);
    await closed!.timeout(const Duration(seconds: 5));
    expect(provider.client, isNull);
    expect(() => provider.storage, throwsA(isA<CloudConfigurationException>()));
  });
}
