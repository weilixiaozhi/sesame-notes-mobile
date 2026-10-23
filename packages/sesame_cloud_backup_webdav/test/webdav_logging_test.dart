import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';

/// 实际文件故障保留安全诊断，旧旁路文件清理失败不阻断真实备份操作。
void main() {
  test('对象上传拒绝记录上下文且不暴露凭据、路径或备份正文', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final requests = <String>[];
    server.listen((request) async {
      try {
        requests.add('${request.method} ${request.uri.path}');
        await request.drain<void>();
        if (request.method.toUpperCase() == 'PROPFIND') {
          request.response.statusCode = HttpStatus.multiStatus;
          request.response.write(
            '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:"></d:multistatus>',
          );
        } else if (request.method.toUpperCase() == 'OPTIONS') {
          request.response.headers.set('allow', 'PUT, GET, DELETE, PROPFIND');
        } else if (request.method.toUpperCase() == 'PUT') {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.write('password-secret backup-plaintext');
        } else {
          request.response.statusCode = HttpStatus.created;
        }
      } finally {
        await request.response.close();
      }
    });
    final messages = <String>[];
    registerWebDavBackend(
      logger: CloudSyncLogger(onLog: (level, message) {
        expect(level.name, 'error');
        messages.add(message);
      }),
    );
    addTearDown(() => CloudProviderRegistry.unregister('webdav'));
    final provider = (await createCloudProvider(CloudServiceConfig(
      backendId: 'webdav',
      settings: {
        'url': 'http://127.0.0.1:${server.port}',
        'username': 'private-account',
        'password': 'password-secret',
        'remotePath': '/private-path/',
      },
    )))!;
    addTearDown(provider.dispose);
    final directory = await (Directory('../../Temp/cleanup-residual-20261017')
          ..createSync(recursive: true))
        .createTemp('webdav-log-');
    addTearDown(() => directory.delete(recursive: true));
    final source = await File('${directory.path}/source.snbak')
        .writeAsString('backup-plaintext');

    await expectLater(
      provider.storage.uploadFile(
        path: 'private-backup.snbak',
        file: source,
        metadata: const {'note': 'backup-plaintext'},
      ),
      throwsA(isA<CloudStorageException>()
          .having((error) => error.originalError, '原始 SDK 原因', isNotNull)
          .having((error) => error.originalStackTrace, '实际传输失败堆栈', isNotNull)
          .having((error) => error.statusCode, 'HTTP 状态', 403)),
    );

    expect(requests.any((path) => path.endsWith('.metadata.json')), isFalse,
        reason: requests.toString());
    expect(messages, hasLength(1));
    expect(messages.single, contains('WebDAV'));
    expect(messages.single, contains('文件上传失败'));
    for (final secret in [
      'password-secret',
      'backup-plaintext',
      'private-account',
      'private-path',
    ]) {
      expect(messages.single, isNot(contains(secret)));
    }
  });

  for (final scenario in [
    (primaryStatus: 204, sidecarStatus: 404),
    (primaryStatus: 204, sidecarStatus: 403),
    (primaryStatus: 204, sidecarStatus: 500),
    (primaryStatus: 403, sidecarStatus: 403),
  ]) {
    final sidecarStatus = scenario.sidecarStatus;
    test(
        scenario.primaryStatus == 403
            ? '真实文件删除被拒时保留对象且不清理旧旁路'
            : '旧旁路清理返回$sidecarStatus仍可上传、下载和删除真实备份', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requests = <String>[];
      String? uploaded;
      server.listen((request) async {
        try {
          final method = request.method.toUpperCase();
          final path = request.uri.path;
          requests.add('$method $path');
          if (method == 'PROPFIND') {
            await request.drain<void>();
            request.response.statusCode = HttpStatus.multiStatus;
            request.response.write(
              '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:"></d:multistatus>',
            );
          } else if (method == 'OPTIONS') {
            await request.drain<void>();
            request.response.headers.set('allow', 'PUT, GET, DELETE, PROPFIND');
          } else if (method == 'MKCOL') {
            await request.drain<void>();
            request.response.statusCode = HttpStatus.created;
          } else if (path.endsWith('.metadata.json')) {
            await request.drain<void>();
            request.response.statusCode = sidecarStatus;
            request.response.write('password-secret backup-plaintext');
          } else if (method == 'PUT') {
            expect(request.headers.value('if-none-match'), '*');
            uploaded = await request.fold<String>('',
                (contents, bytes) => contents + String.fromCharCodes(bytes));
            request.response.statusCode = HttpStatus.created;
          } else if (method == 'GET' && uploaded != null) {
            request.response.write(uploaded);
          } else if (method == 'DELETE') {
            if (scenario.primaryStatus == 403) {
              request.response.statusCode = HttpStatus.forbidden;
              request.response.write('password-secret backup-plaintext');
            } else if (uploaded == null) {
              request.response.statusCode = HttpStatus.notFound;
            } else {
              uploaded = null;
              request.response.statusCode = HttpStatus.noContent;
            }
          } else {
            request.response.statusCode = HttpStatus.notFound;
          }
        } catch (error, stack) {
          stderr.writeln('WebDAV 文件与旁路清理测试响应失败：$error\n$stack');
          rethrow;
        } finally {
          await request.response.close();
        }
      });
      final messages = <String>[];
      registerWebDavBackend(
        logger: CloudSyncLogger(onLog: (_, message) => messages.add(message)),
      );
      addTearDown(() => CloudProviderRegistry.unregister('webdav'));
      final provider = (await createCloudProvider(CloudServiceConfig(
        backendId: 'webdav',
        settings: {
          'url': 'http://127.0.0.1:${server.port}',
          'username': 'private-account',
          'password': 'password-secret',
          'remotePath': '/private-path/',
        },
      )))!;
      addTearDown(provider.dispose);
      final directory = await (Directory('../../Temp/cleanup-residual-20261017')
            ..createSync(recursive: true))
          .createTemp('webdav-sidecar-');
      addTearDown(() => directory.delete(recursive: true));
      final source = await File('${directory.path}/source.snbak')
          .writeAsString('backup-plaintext');
      await provider.storage.uploadFile(
        path: 'private-backup.snbak',
        file: source,
        metadata: const {'note': 'backup-plaintext'},
      );
      expect(uploaded, 'backup-plaintext');
      expect(
          requests.where((path) =>
              path.startsWith('PUT ') && path.endsWith('.metadata.json')),
          isEmpty);
      final restored = File('${directory.path}/restored.snbak');
      expect(
          await provider.storage.downloadFile(
              path: 'private-backup.snbak', destination: restored),
          isTrue);
      expect(await restored.readAsBytes(), await source.readAsBytes());
      if (scenario.primaryStatus == 403) {
        await expectLater(
          provider.storage.delete(path: 'private-backup.snbak'),
          throwsA(isA<CloudStorageException>()
              .having((error) => error.statusCode, '实际文件拒绝状态', 403)),
        );
        expect(uploaded, 'backup-plaintext');
        expect(
            requests.where((path) => path.endsWith('.metadata.json')), isEmpty);
        expect(messages, hasLength(1));
      } else {
        await provider.storage.delete(path: 'private-backup.snbak');
        expect(uploaded, isNull, reason: '真实文件成功删除后旁路清理失败不能反转结果');
        if (sidecarStatus == 403) {
          // 重试时主文件已不存在，旧旁路拒绝清理仍不能阻断幂等删除。
          await provider.storage.delete(path: 'private-backup.snbak');
        }
        final attempts = sidecarStatus == 403 ? 2 : 1;
        expect(
            requests.where((path) =>
                path.startsWith('DELETE ') && path.endsWith('.metadata.json')),
            hasLength(attempts));
        expect(messages, sidecarStatus == 404 ? isEmpty : hasLength(attempts));
      }
      for (final message in messages) {
        expect(message, contains('WebDAV'));
        expect(message, contains('$sidecarStatus'));
        for (final secret in [
          'password-secret',
          'backup-plaintext',
          'private-account',
          'private-path',
        ]) {
          expect(message, isNot(contains(secret)));
        }
      }
    });
  }
}
