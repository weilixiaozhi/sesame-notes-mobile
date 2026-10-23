import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/src/s3_provider.dart';

/// 使用延迟的真实 HTTP 探测验证连接取消与错误清理。
void main() {
  test('释放在途初始化后不能发布失效存储服务', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<HttpRequest>();
    server.listen(received.complete);
    final provider = S3Provider();
    try {
      final initializing = provider.initialize({
        'endpoint': '127.0.0.1',
        'port': server.port,
        'useSSL': false,
        'accessKey': 'key',
        'secretKey': 'secret',
        'bucket': 'bucket',
      });
      final failed = expectLater(
          initializing, throwsA(isA<CloudConfigurationException>()));
      final request = await received.future;
      await provider.dispose();
      request.response.write(
          '<ListBucketResult><IsTruncated>false</IsTruncated></ListBucketResult>');
      await request.response.close();
      await failed;
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
    } catch (error, stackTrace) {
      stderr.writeln('S3 生命周期测试失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    } finally {
      await provider.dispose();
      await server.close(force: true);
    }
  });

  test('初始化失败提示和日志不会输出服务端响应正文', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      try {
        request.response.statusCode = 403;
        request.response.write('<Error><Code>SignatureDoesNotMatch</Code>'
            '<Message>private-secret-response</Message></Error>');
      } finally {
        await request.response.close();
      }
    });
    final messages = <String>[];
    final provider = S3Provider(
        logger: CloudSyncLogger(onLog: (_, message) => messages.add(message)));
    try {
      await expectLater(
          provider.initialize({
            'endpoint': '127.0.0.1',
            'port': server.port,
            'useSSL': false,
            'accessKey': 'key',
            'secretKey': 'secret',
            'bucket': 'bucket',
          }),
          throwsA(isA<CloudConfigurationException>().having(
              (error) => error.toString(),
              '友好提示',
              isNot(contains('private-secret-response')))));
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
      expect(messages, hasLength(1));
      expect(messages.single, isNot(contains('private-secret-response')));
    } catch (error, stackTrace) {
      stderr.writeln('S3 错误隔离测试失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    } finally {
      await provider.dispose();
      await server.close(force: true);
    }
  });
}
