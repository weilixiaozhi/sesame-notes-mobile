import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/src/s3_client.dart';
import 'package:sesame_cloud_backup_s3/src/s3_storage_service.dart';

/// 文件通道的签名、字节与条件创建必须同时成立。
void main() {
  for (final status in [403, 503]) {
    test('HTTP $status 保留错误状态和原始位置，日志不泄露服务端正文', () async {
      final directory =
          await (Directory('../../Temp/architecture-refactor-20261013')
                ..createSync(recursive: true))
              .createTemp('s3-error-');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        try {
          await request.drain<void>();
          request.response.statusCode = status;
          request.response.write('secret-key private-payload');
        } finally {
          await request.response.close();
        }
      });
      final messages = <String>[];
      final client = S3Client(
          endpoint: '127.0.0.1',
          port: server.port,
          useSSL: false,
          region: 'test',
          accessKey: 'access-secret',
          secretKey: 'secret-key');
      final storage = S3StorageService(client, 'private-bucket',
          logger:
              CloudSyncLogger(onLog: (_, message) => messages.add(message)));
      try {
        final source = await File('${directory.path}/private.snbak')
            .writeAsString('private-payload');
        await expectLater(
            storage.uploadFile(path: 'private.snbak', file: source),
            throwsA(
              isA<CloudStorageException>()
                  .having((error) => error.statusCode, 'HTTP 状态', status)
                  .having((error) => error.originalStackTrace.toString(),
                      '源失败位置', contains('CloudHttpFileTransfer.upload'))
                  .having((error) => error.originalError, '原始原因', isNotNull)
                  .having((error) => error.toString(), '安全提示',
                      isNot(contains('secret-key'))),
            ));
        expect(messages, hasLength(1));
        expect(messages.single, contains('HTTP=$status'));
        for (final secret in [
          'secret-key',
          'access-secret',
          'private-payload',
          'private-bucket'
        ]) {
          expect(messages.single, isNot(contains(secret)));
        }
      } finally {
        client.dispose();
        await server.close(force: true);
        await directory.delete(recursive: true);
      }
    });
  }

  test('本地源文件读取失败保留 FileSystemException 而不是二次包装类型', () async {
    final client = S3Client(
        endpoint: 'unused.invalid',
        region: 'test',
        accessKey: 'key',
        secretKey: 'secret');
    final storage = S3StorageService(client, 'bucket');
    try {
      await expectLater(
          storage.uploadFile(
              path: 'backup.snbak',
              file: File(
                  '../../Temp/architecture-refactor-20261013/missing/source.snbak')),
          throwsA(isA<CloudStorageException>()
              .having((error) => error.originalError, '文件系统原因',
                  isA<FileSystemException>())
              .having((error) => error.originalStackTrace, '原始堆栈', isNotNull)));
    } finally {
      client.dispose();
    }
  });

  test('特殊路径真实签名传输保留编码、摘要、元数据、列表与幂等删除', () async {
    const specialKey = "ledgers/中文账本/a+b c%d!'()*.snbak";
    const encodedPath =
        '/bucket/ledgers/%E4%B8%AD%E6%96%87%E8%B4%A6%E6%9C%AC/a%2Bb%20c%25d%21%27%28%29%2A.snbak';
    final dir = await (Directory('../../Temp/cleanup-final-residual-20261017')
          ..createSync(recursive: true))
        .createTemp('s3-stream-');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final objects = <String, List<int>>{};
    final methods = <String>[];
    server.listen((request) async {
      try {
        final path = request.uri.path;
        final isListing = request.method == 'GET' &&
            path == '/bucket' &&
            request.uri.queryParameters['list-type'] == '2';
        // 对象操作检查真实路径；列表按目录前缀请求桶根。
        if (!isListing && request.uri.toString() != '/bucket/missing') {
          expect(request.uri.toString(), encodedPath);
          expect(request.uri.pathSegments,
              ['bucket', 'ledgers', '中文账本', "a+b c%d!'()*.snbak"]);
        }
        expect(request.headers.value(HttpHeaders.authorizationHeader),
            startsWith('AWS4-HMAC-SHA256 '));
        expect(request.headers.value(HttpHeaders.hostHeader),
            '127.0.0.1:${server.port}');
        methods.add(request.method);
        if (request.method != 'PUT') {
          expect(request.headers.value('x-amz-content-sha256'),
              'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
        }
        if (isListing) {
          expect(request.uri.queryParameters,
              {'list-type': '2', 'prefix': 'ledgers/'});
          request.response.headers.contentType =
              ContentType('application', 'xml', charset: 'utf-8');
          request.response.write('<ListBucketResult>'
              '<IsTruncated>false</IsTruncated>'
              '${objects.isEmpty ? '' : '<Contents><Key>$specialKey</Key><Size>${objects.values.single.length}</Size><LastModified>2026-10-17T00:00:00.000Z</LastModified></Contents>'}'
              '</ListBucketResult>');
        } else if (request.method == 'PUT') {
          final bytes =
              await request.fold<List<int>>([], (a, b) => a..addAll(b));
          expect(request.headers.value('x-amz-content-sha256'),
              sha256.convert(bytes).toString());
          expect(request.headers.value('if-none-match'), '*');
          expect(request.headers.value('x-amz-meta-encoding'), 'base64');
          if (objects.containsKey(path)) {
            request.response.statusCode = 412;
          } else {
            objects[path] = bytes;
          }
        } else if (request.method == 'DELETE') {
          objects.remove(path);
          request.response.statusCode = HttpStatus.noContent;
        } else if (objects.containsKey(path)) {
          request.response.add(objects[path]!);
        } else {
          request.response.statusCode = 404;
        }
      } catch (error, stack) {
        stderr.writeln('S3 特殊路径文件传输测试响应失败：$error\n$stack');
        rethrow;
      } finally {
        await request.response.close();
      }
    });
    final client = S3Client(
        endpoint: '127.0.0.1',
        port: server.port,
        useSSL: false,
        region: 'test',
        accessKey: 'key',
        secretKey: 'secret');
    final storage = S3StorageService(client, 'bucket');
    try {
      final file = await File('${dir.path}/source')
          .writeAsBytes(List.generate(100003, (i) => i % 256));
      await storage.uploadFile(
          path: specialKey, file: file, metadata: const {'encoding': 'base64'});
      final replacement = await File('${dir.path}/replacement')
          .writeAsString('different snapshot');
      await expectLater(
          storage.uploadFile(
              path: specialKey,
              file: replacement,
              metadata: const {'encoding': 'base64'}),
          throwsA(isA<CloudFileAlreadyExistsException>()));
      final listed = await storage.list(path: 'ledgers/');
      expect(listed.single.path, specialKey);
      expect(listed.single.size, await file.length());
      expect(listed.single.lastModified, DateTime.utc(2026, 10, 17));
      final output = File('${dir.path}/output');
      expect(
          await storage.downloadFile(
              path: listed.single.path, destination: output),
          isTrue);
      expect(await output.readAsBytes(), await file.readAsBytes());
      expect(
          await storage.downloadFile(
              path: 'missing', destination: File('${dir.path}/missing')),
          isFalse);
      expect(objects, hasLength(1));
      await storage.delete(path: specialKey);
      await storage.delete(path: specialKey);
      expect(await storage.list(path: 'ledgers/'), isEmpty);
      final missingOutput = File('${dir.path}/deleted-output');
      expect(
          await storage.downloadFile(
              path: specialKey, destination: missingOutput),
          isFalse);
      expect(await missingOutput.exists(), isFalse);
      expect(methods.toSet(), {'PUT', 'GET', 'DELETE'});
      expect(methods.where((method) => method == 'PUT'), hasLength(2));
      expect(methods.where((method) => method == 'DELETE'), hasLength(2));
      expect(objects, isEmpty);
    } finally {
      client.dispose();
      await server.close(force: true);
      await dir.delete(recursive: true);
    }
  });
}
