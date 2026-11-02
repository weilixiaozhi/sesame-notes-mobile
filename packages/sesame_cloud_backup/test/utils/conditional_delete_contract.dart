import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 仅监听回环地址的对象存储替身，保留真实 HTTP 条件与对象版本变化。
class _ConditionalServer {
  _ConditionalServer(this.server, this.webDav);

  final HttpServer server;
  final bool webDav;
  final objects = <String, List<int>>{};
  final etags = <String, String>{};
  final requests = <({String method, String key, String? match})>[];
  bool ignoreReadCondition = false;
  bool ignoreDeleteCondition = false;
  bool collideProbe = false;
  bool replaceAfterRejectedDelete = false;
  bool omitEtags = false;
  var nextVersion = 1;
  static const prefix = 'sesame_notes_backups';
  static const userKey = '$prefix/user.snbak';

  Uri get endpoint => Uri.parse('http://127.0.0.1:${server.port}/');
  String get root => webDav ? 'root' : 'bucket';

  /// 先注册稳定用户对象，探针测试只能改变本次独占的新对象。
  static Future<_ConditionalServer> create(bool webDav) async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final fixture = _ConditionalServer(server, webDav);
      fixture.objects[userKey] = [1, 2, 3];
      fixture.etags[userKey] = '"original"';
      server.listen(fixture.respond);
      return fixture;
    } catch (error, stack) {
      stderr.writeln('条件存储测试初始化失败：$error\n$stack');
      rethrow;
    }
  }

  /// 给 S3 和 WebDAV 返回等价列表，ETag 原样进入实际解析器。
  String listing(String path) {
    if (!webDav) {
      return '<ListBucketResult><IsTruncated>false</IsTruncated>'
          '${objects.entries.map((entry) => '<Contents><Key>${entry.key}</Key><Size>${entry.value.length}</Size>${omitEtags ? '' : '<ETag>${etags[entry.key]}</ETag>'}</Contents>').join()}'
          '</ListBucketResult>';
    }
    return '<?xml version="1.0"?><d:multistatus xmlns:d="DAV:">'
        '<d:response><d:href>$path</d:href><d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>'
        '${objects.entries.map((entry) => '<d:response><d:href>/$root/${entry.key}</d:href><d:propstat><d:prop><d:resourcetype/><d:getcontentlength>${entry.value.length}</d:getcontentlength>${omitEtags ? '' : '<d:getetag>${etags[entry.key]}</d:getetag>'}</d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>').join()}'
        '</d:multistatus>';
  }

  /// 错误条件、忽略条件和外部替换均由测试明确开启，不接触真实后端。
  Future<void> respond(HttpRequest request) async {
    try {
      final method = request.method.toUpperCase();
      final path = request.uri.path;
      final listingRequest = method == 'PROPFIND' ||
          method == 'GET' && request.uri.queryParameters['list-type'] == '2';
      final key =
          path.startsWith('/$root/') ? path.substring(root.length + 2) : '';
      final match = request.headers.value('if-match');
      requests.add((method: method, key: key, match: match));
      if (!webDav) {
        expect(request.headers.value('authorization'),
            startsWith('AWS4-HMAC-SHA256 '));
        if (match != null) {
          expect(request.headers.value('authorization'), contains('if-match'));
        }
      }
      if (method == 'OPTIONS') {
        expect(match, isNull, reason: '认证协商不能代替真实GET条件验证');
        await request.drain<void>();
        request.response.headers.set('allow', 'PUT, GET, DELETE, PROPFIND');
      } else if (method == 'MKCOL') {
        await request.drain<void>();
        request.response.statusCode = 201;
      } else if (listingRequest) {
        await request.drain<void>();
        request.response.statusCode = webDav ? 207 : 200;
        request.response.headers.contentType =
            ContentType('application', 'xml');
        request.response.write(listing(path));
      } else if (method == 'PUT') {
        expect(request.headers.value('if-none-match'), '*');
        final body = await request
            .fold<List<int>>([], (all, bytes) => all..addAll(bytes));
        if (collideProbe && key.contains('.sesame_cleanup_probe_')) {
          objects[key] = [9];
          etags[key] = '"collision-owned-by-other"';
          request.response.statusCode = 412;
        } else if (objects.containsKey(key)) {
          request.response.statusCode = 412;
        } else {
          objects[key] = body;
          etags[key] = '"version-${nextVersion++}"';
          request.response.statusCode = 201;
        }
      } else if (!objects.containsKey(key)) {
        request.response.statusCode = 404;
      } else if (method == 'GET') {
        if (match != null && match != etags[key] && !ignoreReadCondition) {
          request.response.statusCode = 412;
        } else {
          request.response.add(objects[key]!);
        }
      } else if (method == 'DELETE') {
        if (match != null && match != etags[key] && !ignoreDeleteCondition) {
          request.response.statusCode = 412;
          if (replaceAfterRejectedDelete &&
              key.contains('.sesame_cleanup_probe_')) {
            objects[key] = [7, 8];
            etags[key] = '"replacement"';
          }
        } else {
          objects.remove(key);
          etags.remove(key);
          request.response.statusCode = 204;
        }
      } else {
        request.response.statusCode = 405;
      }
    } catch (error, stack) {
      stderr.writeln('条件存储测试响应失败：$error\n$stack');
      rethrow;
    } finally {
      await request.response.close();
    }
  }
}

/// 从测试工作目录向上定位仓库，所有临时文件均放在该仓库根 Temp。
Future<Directory> _temporaryDirectory() async {
  try {
    var root = Directory.current;
    while (!Directory('${root.path}/lib/features').existsSync()) {
      if (root.parent.path == root.path) throw StateError('未找到项目根目录');
      root = root.parent;
    }
    final temp = await Directory('${root.path}/Temp').create(recursive: true);
    return await temp.createTemp('conditional-delete-test-');
  } catch (error, stack) {
    stderr.writeln('条件存储测试临时目录创建失败：$error\n$stack');
    rethrow;
  }
}

/// 同一安全契约分别穿过两个后端的真实传输、签名和列表解析。
void conditionalDeleteContract({
  required bool webDav,
  required CloudStorageService Function(Uri endpoint) createStorage,
  required void Function(CloudStorageService storage) closeStorage,
}) {
  late _ConditionalServer fixture;
  late CloudStorageService storage;
  late CloudConditionalDeleteStorage conditional;
  late Directory directory;

  setUp(() async {
    directory = await _temporaryDirectory();
    fixture = await _ConditionalServer.create(webDav);
    storage = createStorage(fixture.endpoint);
    conditional = storage as CloudConditionalDeleteStorage;
  });
  tearDown(() async {
    closeStorage(storage);
    await fixture.server.close(force: true);
    await directory.delete(recursive: true);
  });

  test('列举保留强ETag，条件读取和删除失败保留用户对象，普通请求不继承条件头', () async {
    final listed = await storage.list(path: _ConditionalServer.prefix);
    expect(listed.single.metadata?['etag'], '"original"');
    final file = File('${directory.path}/read');
    expect(
        await conditional.downloadIfMatch(
            path: _ConditionalServer.userKey,
            destination: file,
            expectedETag: '"original"'),
        isTrue);
    expect(await file.readAsBytes(), [1, 2, 3]);
    await expectLater(
        conditional.downloadIfMatch(
            path: _ConditionalServer.userKey,
            destination: File('${directory.path}/changed'),
            expectedETag: '"other"'),
        throwsA(isA<CloudStorageException>()
            .having((error) => error.statusCode, '条件读取状态', 412)));
    await expectLater(
        conditional.deleteIfMatch(
            path: _ConditionalServer.userKey, expectedETag: '"other"'),
        throwsA(isA<CloudStorageException>()
            .having((error) => error.statusCode, '条件删除状态', 412)));
    expect(fixture.objects[_ConditionalServer.userKey], [1, 2, 3]);
    expect(
        await storage.downloadFile(
            path: _ConditionalServer.userKey,
            destination: File('${directory.path}/normal')),
        isTrue);
    expect(
        fixture.requests.lastWhere((request) => request.method == 'GET').match,
        isNull);
    await storage.delete(path: _ConditionalServer.userKey);
    expect(fixture.requests.last.match, isNull);
  });

  test('自有空探针证明错误GET和DELETE条件均412，正确条件可删除且成功验证复用', () async {
    await conditional.verifyConditionalDelete(
        prefix: _ConditionalServer.prefix);
    expect(fixture.objects, {
      _ConditionalServer.userKey: [1, 2, 3]
    });
    final count = fixture.requests.length;
    await conditional.verifyConditionalDelete(
        prefix: _ConditionalServer.prefix);
    expect(fixture.requests, hasLength(count));
    final probeDeletes =
        fixture.requests.where((request) => request.method == 'DELETE');
    expect(probeDeletes.length, 2);
    expect(
        probeDeletes.every((request) =>
            request.key.contains('.sesame_cleanup_probe_') &&
            request.match != null),
        isTrue);
    expect(
        fixture.requests.where((request) =>
            request.method == 'GET' &&
            request.key.contains('.sesame_cleanup_probe_') &&
            (request.match?.startsWith('"cleanup-') ?? false)),
        hasLength(1));
  });

  for (final operation in ['GET', 'DELETE']) {
    test('服务忽略$operation条件时安全拒绝，不拿用户文件试探或退回无条件删', () async {
      fixture.ignoreReadCondition = operation == 'GET';
      fixture.ignoreDeleteCondition = operation == 'DELETE';
      await expectLater(
          conditional.verifyConditionalDelete(
              prefix: _ConditionalServer.prefix),
          throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
      expect(fixture.objects[_ConditionalServer.userKey], [1, 2, 3]);
      expect(
          fixture.requests.where((request) => request.method == 'DELETE').every(
              (request) =>
                  request.key.contains('.sesame_cleanup_probe_') &&
                  request.match != null),
          isTrue);
    });
  }

  test('条件创建碰撞时没有探针所有权，不删除碰撞对象', () async {
    fixture.collideProbe = true;
    await expectLater(
        conditional.verifyConditionalDelete(prefix: _ConditionalServer.prefix),
        throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
    expect(fixture.requests.where((request) => request.method == 'DELETE'),
        isEmpty);
    expect(
        fixture.objects.values
            .any((bytes) => bytes.length == 1 && bytes.single == 9),
        isTrue);
    expect(fixture.objects[_ConditionalServer.userKey], [1, 2, 3]);
  });

  test('探针被另一方替换时不清理新身份，也不授删除能力', () async {
    fixture.replaceAfterRejectedDelete = true;
    await expectLater(
        conditional.verifyConditionalDelete(prefix: _ConditionalServer.prefix),
        throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
    expect(
        fixture.objects.values.any(
            (bytes) => bytes.length == 2 && bytes[0] == 7 && bytes[1] == 8),
        isTrue);
    expect(fixture.requests.where((request) => request.method == 'DELETE'),
        hasLength(1));
  });

  test('缺少可靠ETag时拒绝能力且不做无条件探针清理', () async {
    fixture.omitEtags = true;
    await expectLater(
        conditional.verifyConditionalDelete(prefix: _ConditionalServer.prefix),
        throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
    expect(fixture.requests.where((request) => request.method == 'DELETE'),
        isEmpty);
    expect(fixture.objects[_ConditionalServer.userKey], [1, 2, 3]);
  });

  test('弱标记、通配符、空标记和头部注入都在发请求之前拒绝', () async {
    for (final tag in ['', '*', 'W/"weak"', 'plain', '""', '"line\nbreak"']) {
      await expectLater(
          conditional.deleteIfMatch(
              path: _ConditionalServer.userKey, expectedETag: tag),
          throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
      await expectLater(
          conditional.downloadIfMatch(
              path: _ConditionalServer.userKey,
              destination: File('${directory.path}/invalid'),
              expectedETag: tag),
          throwsA(isA<CloudConditionalDeleteUnsupportedException>()));
    }
    expect(fixture.requests, isEmpty);
  });
}
