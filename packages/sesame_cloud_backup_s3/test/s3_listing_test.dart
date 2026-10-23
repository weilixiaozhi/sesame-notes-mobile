import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/src/s3_client.dart';
import 'package:sesame_cloud_backup_s3/src/s3_exceptions.dart';
import 'package:sesame_cloud_backup_s3/src/s3_storage_service.dart';

/// 使用真实 HTTP、签名和 XML 解析，仅在服务端响应处注入故障。
Future<({S3Client client, S3StorageService storage, List<Uri> requests})>
    listingServer(List<(int, String)> responses) async {
  try {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final requests = <Uri>[];
    server.listen((request) async {
      try {
        final index = requests.length;
        requests.add(request.uri);
        final response = index < responses.length
            ? responses[index]
            : (500, '<Error><Code>UnexpectedRequest</Code></Error>');
        request.response.statusCode = response.$1;
        request.response.headers.contentType =
            ContentType('application', 'xml', charset: 'utf-8');
        request.response.write(response.$2);
      } catch (error, stack) {
        stderr.writeln('S3 列举测试服务响应失败：$error\n$stack');
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
      secretKey: 'secret',
    );
    addTearDown(client.dispose);
    return (
      client: client,
      storage: S3StorageService(client, 'bucket'),
      requests: requests
    );
  } catch (error, stack) {
    stderr.writeln('S3 列举测试初始化失败：$error\n$stack');
    rethrow;
  }
}

/// 构造可携带命名空间的列表页，正文由用例明确指定。
String listingPage(String body) =>
    '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">'
    '$body</ListBucketResult>';

/// 验证只有全部页面解析成功时才发布文件清单。
void main() {
  for (final path in ['backups', 'backups/']) {
    test('目录 $path 使用完整路径边界且忽略目录标记对象', () async {
      final fixture = await listingServer([
        (
          200,
          listingPage('<IsTruncated>false</IsTruncated>'
              '<Contents><Key>backups/</Key><Size>0</Size></Contents>'
              '<Contents><Key>backups/file.snbak</Key><Size>8</Size></Contents>')
        ),
      ]);
      final files = await fixture.storage.list(path: path);
      expect(fixture.requests.single.queryParameters['prefix'], 'backups/');
      expect(files.map((file) => file.path), ['backups/file.snbak']);
    });
  }

  test('空路径列举桶根目录，连接探测不发送对象前缀', () async {
    final fixture = await listingServer([
      (200, listingPage('<IsTruncated>false</IsTruncated>')),
    ]);
    expect(await fixture.storage.list(path: ''), isEmpty);
    await expectLater(fixture.storage.delete(path: ''),
        throwsA(isA<CloudStorageException>()));
    expect(fixture.requests.single.queryParameters, {'list-type': '2'});
  });

  test('完整跨页清单保留不透明令牌、特殊字符 Key 和真实元数据', () async {
    final fixture = await listingServer([
      (
        200,
        listingPage('<IsTruncated>true</IsTruncated>'
            '<NextContinuationToken>a+/= &amp; b</NextContinuationToken>'
            '<Contents><Key>备份/a &amp; b.snbak</Key><Size>17</Size>'
            '<LastModified>2026-10-13T01:00:00.000Z</LastModified></Contents>'),
      ),
      (
        200,
        '<s:ListBucketResult xmlns:s="http://s3.amazonaws.com/doc/2006-03-01/">'
            '<s:IsTruncated>false</s:IsTruncated>'
            '<s:Contents><s:Key>备份/second.snbak</s:Key></s:Contents>'
            '</s:ListBucketResult>',
      ),
    ]);
    final files = await fixture.storage.list(path: '备份/');
    expect(
        files.map((file) => file.path), ['备份/a & b.snbak', '备份/second.snbak']);
    expect(files.first.size, 17);
    expect(files.first.lastModified, DateTime.utc(2026, 10, 13, 1));
    expect(files.last.size, isNull);
    expect(files.last.lastModified, isNull);
    expect(fixture.requests, hasLength(2));
    expect(fixture.requests.last.queryParameters, {
      'list-type': '2',
      'prefix': '备份/',
      'continuation-token': 'a+/= & b',
    });
  });

  for (final value in ['false', '0']) {
    test('明确结束且没有 Contents 的列表为空：$value', () async {
      final fixture = await listingServer([
        (200, listingPage('<IsTruncated>$value</IsTruncated>')),
      ]);
      expect(await fixture.storage.list(path: 'backups/'), isEmpty);
      expect(fixture.requests, hasLength(1));
    });
  }

  final invalidPages = {
    'XML 损坏': '<ListBucketResult>',
    '错误响应根': '<Error><Code>InternalError</Code></Error>',
    '缺少分页状态': listingPage(''),
    '未知分页状态': listingPage('<IsTruncated>unknown</IsTruncated>'),
    '分页状态重复': listingPage(
        '<IsTruncated>false</IsTruncated><IsTruncated>true</IsTruncated>'),
    '嵌套字段不能代替列表分页状态':
        listingPage('<Error><IsTruncated>false</IsTruncated></Error>'),
    '截断但缺少令牌': listingPage('<IsTruncated>true</IsTruncated>'),
    '截断但令牌为空': listingPage('<IsTruncated>true</IsTruncated>'
        '<NextContinuationToken> </NextContinuationToken>'),
    '对象缺少身份': listingPage('<IsTruncated>false</IsTruncated>'
        '<Contents><Size>17</Size></Contents>'),
    '对象身份为空': listingPage('<IsTruncated>false</IsTruncated>'
        '<Contents><Key></Key></Contents>'),
  };
  for (final entry in invalidPages.entries) {
    test('后续页${entry.key}时整次列举失败，不返回已读取的部分清单', () async {
      final fixture = await listingServer([
        (
          200,
          listingPage('<IsTruncated>true</IsTruncated>'
              '<NextContinuationToken>page-2</NextContinuationToken>'
              '<Contents><Key>backups/first.snbak</Key></Contents>'),
        ),
        (200, entry.value),
      ]);
      await expectLater(
        fixture.client.listObjects(bucket: 'bucket', prefix: 'backups/'),
        throwsA(isA<S3Exception>()
            .having((error) => error.message, '友好错误', contains('云端备份列表响应无效'))
            .having((error) => error.originalException, '原始解析失败', isNotNull)),
      );
      expect(fixture.requests, hasLength(2));
    });
  }

  test('分页令牌形成循环时明确失败，不继续重读或返回重复对象', () async {
    final fixture = await listingServer([
      for (final token in ['page-a', 'page-b', 'page-a'])
        (
          200,
          listingPage('<IsTruncated>1</IsTruncated>'
              '<NextContinuationToken>$token</NextContinuationToken>'
              '<Contents><Key>backups/$token.snbak</Key></Contents>'),
        ),
    ]);
    await expectLater(
        fixture.client.listObjects(bucket: 'bucket', prefix: 'backups/'),
        throwsA(isA<S3Exception>()
            .having((error) => error.message, '原因', contains('分页未前进'))));
    expect(fixture.requests, hasLength(3));
  });

  for (final status in [403, 404, 500]) {
    test('HTTP $status 仍为失败，不能把权限、桶缺失或服务故障当空目录', () async {
      final fixture = await listingServer([
        (status, '<Error><Code>Unavailable</Code></Error>'),
      ]);
      await expectLater(
          fixture.client.listObjects(bucket: 'bucket', prefix: 'backups/'),
          throwsA(isA<S3Exception>()
              .having((error) => error.statusCode, 'HTTP 状态', status)));
    });
  }
}
