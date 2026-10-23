import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/src/webdav_storage_service.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

/// 并发上传同一路径时，每个请求都必须独立携带条件创建头。
void main() {
  test('先完成的上传不能撤销另一在途上传的 If-None-Match', () async {
    var root = Directory.current;
    while (!File('${root.path}/pubspec.yaml').existsSync() ||
        !Directory('${root.path}/packages').existsSync()) {
      if (root.parent.path == root.path) throw StateError('无法定位仓库临时目录');
      root = root.parent;
    }
    final directory = await (Directory('${root.path}/Temp/review-20261022')
          ..createSync(recursive: true))
        .createTemp('webdav-concurrent-');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final firstPut = Completer<void>();
    final secondOptions = Completer<void>();
    final releaseFirst = Completer<void>();
    final releaseSecond = Completer<void>();
    var optionsCount = 0;
    String? stored;
    final conditions = <String?>[];
    server.listen((request) async {
      try {
        if (request.method == 'PROPFIND') {
          await request.drain<void>();
          request.response.statusCode = 207;
          request.response.write('<d:multistatus xmlns:d="DAV:"/>');
        } else if (request.method == 'OPTIONS') {
          if (++optionsCount == 2) {
            secondOptions.complete();
            await releaseSecond.future;
          }
        } else if (request.method == 'PUT') {
          final contents = await request.fold<String>(
              '', (text, bytes) => text + String.fromCharCodes(bytes));
          final condition = request.headers.value('if-none-match');
          conditions.add(condition);
          if (stored == null) {
            stored = contents;
            firstPut.complete();
            await releaseFirst.future;
            request.response.statusCode = 201;
          } else if (condition == '*') {
            request.response.statusCode = 412;
          } else {
            stored = contents;
            request.response.statusCode = 204;
          }
        }
      } catch (error, stackTrace) {
        stderr.writeln('WebDAV 并发测试响应失败：${error.runtimeType}\n$stackTrace');
        rethrow;
      } finally {
        await request.response.close();
      }
    });
    final client = webdav.newClient('http://127.0.0.1:${server.port}');
    final storage = WebDAVStorageService(client, '/backups');
    try {
      final firstFile =
          await File('${directory.path}/first').writeAsString('first');
      final secondFile =
          await File('${directory.path}/second').writeAsString('second');
      final first = storage.uploadFile(path: 'same.snbak', file: firstFile);
      await firstPut.future.timeout(const Duration(seconds: 5));
      final second = expectLater(
          storage.uploadFile(path: 'same.snbak', file: secondFile),
          throwsA(isA<CloudFileAlreadyExistsException>()));
      await secondOptions.future.timeout(const Duration(seconds: 5));
      releaseFirst.complete();
      await first;
      releaseSecond.complete();
      await second;
      expect(stored, 'first');
      expect(conditions, ['*', '*']);
      expect(client.c.options.headers.containsKey('If-None-Match'), isFalse);
    } catch (error, stackTrace) {
      stderr.writeln('WebDAV 并发条件创建测试失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    } finally {
      if (!releaseFirst.isCompleted) releaseFirst.complete();
      if (!releaseSecond.isCompleted) releaseSecond.complete();
      client.c.close(force: true);
      await server.close(force: true);
      await directory.delete(recursive: true);
    }
  });
}
