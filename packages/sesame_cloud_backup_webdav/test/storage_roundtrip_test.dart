import 'dart:io';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:sesame_cloud_backup_webdav/src/webdav_storage_service.dart';

/// 用真实协议解析验证远程前缀不会泄漏到业务层路径。
void main() {
  test('文件拒绝不改动对象，重试后列举、下载和幂等删除保留同一路径身份', () async {
    try {
      registerWebDavBackend();
      addTearDown(() => CloudProviderRegistry.unregister('webdav'));
      expect(
          CloudProviderRegistry.backendOf('webdav')!
              .fields
              .where((field) => field.isSecret)
              .map((field) => field.key),
          ['password']);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final objects = <String, String>{
        '/prefix/backups/notes.json': 'unrelated-content',
      };
      final requests = <String>[];
      var rejectUpload = true;
      var rejectDelete = true;
      final messages = <String>[];
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        try {
          final path = request.uri.path;
          requests.add('${request.method} $path');
          if (request.method == 'OPTIONS') {
            request.response.headers.set('allow', 'PUT, GET, DELETE, PROPFIND');
          } else if (request.method == 'MKCOL') {
            request.response.statusCode = 201;
          } else if ((request.method == 'PUT' && rejectUpload) ||
              (request.method == 'DELETE' && rejectDelete)) {
            await request.drain<void>();
            request.response.statusCode = 403;
            request.response.write('password-secret backup-plaintext');
          } else if (request.method == 'PUT' &&
              request.headers.value('if-none-match') == '*' &&
              objects.containsKey(path)) {
            await request.drain<void>();
            request.response.statusCode = 412;
          } else if (request.method == 'PUT') {
            objects[path] = await request.fold<String>(
                '', (v, bytes) => v + String.fromCharCodes(bytes));
            request.response.statusCode = 201;
          } else if (request.method == 'PROPFIND') {
            await request.drain<void>();
            request.response.statusCode = 207;
            request.response.write(
                '''<?xml version="1.0"?><d:multistatus xmlns:d="DAV:"><d:response><d:href>$path</d:href><d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>${objects.entries.map((entry) => '<d:response><d:href>${entry.key}</d:href><d:propstat><d:prop><d:resourcetype/><d:getcontentlength>${entry.value.length}</d:getcontentlength></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>').join()}</d:multistatus>''');
          } else if (request.method == 'GET' && objects.containsKey(path)) {
            request.response.write(objects[path]);
          } else if (request.method == 'DELETE' &&
              objects.remove(path) != null) {
            request.response.statusCode = 204;
          } else {
            request.response.statusCode = 404;
          }
        } finally {
          await request.response.close();
        }
      });
      final client = webdav.newClient('http://127.0.0.1:${server.port}',
          user: 'private-account', password: 'password-secret');
      final storage = WebDAVStorageService(client, '/prefix/',
          logger:
              CloudSyncLogger(onLog: (_, message) => messages.add(message)));
      final dir = await (Directory('../../Temp/cleanup-final-residual-20261017')
            ..createSync(recursive: true))
          .createTemp('webdav-stream-');
      addTearDown(() => dir.delete(recursive: true));
      final file =
          await File('${dir.path}/source').writeAsString('backup-plaintext');
      await expectLater(
        storage.uploadFile(path: 'backups/a.snbak', file: file),
        throwsA(isA<CloudStorageException>()
            .having((error) => error.statusCode, '上传拒绝状态', 403)
            .having((error) => error.originalError, '原始传输原因', isNotNull)
            .having((error) => error.originalStackTrace, '传输失败堆栈', isNotNull)),
      );
      expect(objects.containsKey('/prefix/backups/a.snbak'), isFalse);
      rejectUpload = false;
      await storage.uploadFile(
        path: 'backups/a.snbak',
        file: file,
        metadata: const {'origin': 'snapshot'},
      );
      final replacement = await File('${dir.path}/replacement')
          .writeAsString('different snapshot');
      await expectLater(
          storage.uploadFile(path: 'backups/a.snbak', file: replacement),
          throwsA(isA<CloudFileAlreadyExistsException>()));
      final output = File('${dir.path}/output');
      expect(
          await storage.downloadFile(
              path: 'backups/a.snbak', destination: output),
          isTrue);
      expect(await output.readAsBytes(), await file.readAsBytes());
      final listed = await storage.list(path: 'backups/');
      expect(listed.map((file) => file.path).toSet(), {
        'backups/a.snbak',
        'backups/notes.json',
      });
      final backup = listed.singleWhere((file) => file.name == 'a.snbak');
      expect(backup.size, await file.length());
      expect(
        await storage.downloadFile(path: backup.path, destination: output),
        isTrue,
      );
      expect(await output.readAsBytes(), await file.readAsBytes());
      await expectLater(
        storage.delete(path: backup.path),
        throwsA(isA<CloudStorageException>()
            .having((error) => error.statusCode, '删除拒绝状态', 403)),
      );
      expect(objects['/prefix/backups/a.snbak'], 'backup-plaintext');
      rejectDelete = false;
      await storage.delete(path: backup.path);
      await storage.delete(path: backup.path);
      expect(
        (await storage.list(path: 'backups/')).single.path,
        'backups/notes.json',
      );
      final missingOutput = File('${dir.path}/deleted-output');
      expect(
        await storage.downloadFile(
            path: backup.path, destination: missingOutput),
        isFalse,
      );
      expect(await missingOutput.exists(), isFalse);
      expect(objects, {'/prefix/backups/notes.json': 'unrelated-content'});
      expect(
        requests.where((request) => request.startsWith('DELETE ')),
        everyElement('DELETE /prefix/backups/a.snbak'),
      );
      expect(messages, isNotEmpty);
      for (final secret in [
        'password-secret',
        'backup-plaintext',
        'private-account',
        '/prefix/'
      ]) {
        expect(messages.join('\n'), isNot(contains(secret)));
      }
    } catch (error, stackTrace) {
      printOnFailure('WebDAV 文件拒绝与恢复链路验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
