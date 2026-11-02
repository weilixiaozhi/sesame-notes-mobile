import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';

/// 实际文件故障保留安全诊断，操作仅访问目标文件。
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

    expect(
      requests.where((path) => path.startsWith('PUT ')),
      everyElement('PUT /private-path/private-backup.snbak'),
    );
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

  for (final primaryStatus in [204, 403]) {
    test(primaryStatus == 403 ? '文件删除被拒时保留对象并记录安全诊断' : '文件支持上传下载和幂等删除',
        () async {
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
          } else if (method == 'PUT') {
            expect(request.headers.value('if-none-match'), '*');
            uploaded = await request.fold<String>('',
                (contents, bytes) => contents + String.fromCharCodes(bytes));
            request.response.statusCode = HttpStatus.created;
          } else if (method == 'GET' && uploaded != null) {
            request.response.write(uploaded);
          } else if (method == 'DELETE') {
            if (primaryStatus == 403) {
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
          stderr.writeln('WebDAV 文件操作测试响应失败：$error\n$stack');
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
          .createTemp('webdav-file-');
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
        requests.where((path) => path.startsWith('PUT ')),
        everyElement('PUT /private-path/private-backup.snbak'),
      );
      final restored = File('${directory.path}/restored.snbak');
      expect(
          await provider.storage.downloadFile(
              path: 'private-backup.snbak', destination: restored),
          isTrue);
      expect(await restored.readAsBytes(), await source.readAsBytes());
      if (primaryStatus == 403) {
        await expectLater(
          provider.storage.delete(path: 'private-backup.snbak'),
          throwsA(isA<CloudStorageException>()
              .having((error) => error.statusCode, '实际文件拒绝状态', 403)),
        );
        expect(uploaded, 'backup-plaintext');
        expect(messages, hasLength(1));
      } else {
        await provider.storage.delete(path: 'private-backup.snbak');
        expect(uploaded, isNull);
        await provider.storage.delete(path: 'private-backup.snbak');
        expect(messages, isEmpty);
      }
      expect(
        requests.where((path) => path.startsWith('DELETE ')),
        everyElement('DELETE /private-path/private-backup.snbak'),
      );
      for (final message in messages) {
        expect(message, contains('WebDAV'));
        expect(message, contains('$primaryStatus'));
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
