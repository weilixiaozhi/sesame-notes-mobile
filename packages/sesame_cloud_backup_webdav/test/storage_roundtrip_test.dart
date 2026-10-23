import 'dart:io';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:sesame_cloud_backup_webdav/src/webdav_storage_service.dart';

/// 用真实协议解析验证远程前缀不会泄漏到业务层路径。
void main() {
  test('列举出的路径可以下载和删除上传的同一个对象', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final objects = <String, String>{
      '/prefix/backups/a.snbak.metadata.json': 'legacy-metadata',
    };
    final requests = <String>[];
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      try {
        final path = request.uri.path;
        requests.add('${request.method} $path');
        if (request.method == 'OPTIONS') {
          request.response.headers.set('allow', 'PUT, GET, DELETE, PROPFIND');
        } else if (request.method == 'MKCOL') {
          request.response.statusCode = 201;
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
        } else if (request.method == 'DELETE' && objects.remove(path) != null) {
          request.response.statusCode = 204;
        } else {
          request.response.statusCode = 404;
        }
      } finally {
        await request.response.close();
      }
    });
    final client = webdav.newClient('http://127.0.0.1:${server.port}',
        user: 'u', password: 'p');
    final storage = WebDAVStorageService(client, '/prefix/');
    final dir = await (Directory('../../Temp/cleanup-final-residual-20261017')
          ..createSync(recursive: true))
        .createTemp('webdav-stream-');
    addTearDown(() => dir.delete(recursive: true));
    final file = await File('${dir.path}/source').writeAsString('snapshot');
    await storage.uploadFile(
      path: 'backups/a.snbak',
      file: file,
      metadata: const {'origin': 'snapshot'},
    );
    expect(
      objects['/prefix/backups/a.snbak.metadata.json'],
      'legacy-metadata',
      reason: '上传真实备份不能写入或覆盖旁路文件',
    );
    expect(
        requests.where((path) =>
            path.startsWith('PUT ') && path.endsWith('.metadata.json')),
        isEmpty);
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
    expect(await output.readAsString(), 'snapshot');
    final listed = await storage.list(path: 'backups/');
    expect(listed.single.path, 'backups/a.snbak');
    expect(listed.single.size, 8);
    expect(listed.any((file) => file.path.endsWith('.metadata.json')), isFalse);
    expect(
      await storage.downloadFile(path: listed.single.path, destination: output),
      isTrue,
    );
    expect(await output.readAsString(), 'snapshot');
    await storage.delete(path: listed.single.path);
    await storage.delete(path: listed.single.path);
    expect(await storage.list(path: 'backups/'), isEmpty);
    final missingOutput = File('${dir.path}/deleted-output');
    expect(
      await storage.downloadFile(
          path: listed.single.path, destination: missingOutput),
      isFalse,
    );
    expect(await missingOutput.exists(), isFalse);
    expect(objects, isEmpty);
  });
}
