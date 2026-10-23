import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/cloud_service_fixture.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart' hide LogLevel;
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';

import '../helpers/test_isolation.dart';

/// 保留真实 HTTP 通道，让备份用例贯穿 S3 注册、存储服务和 XML 分页解析。
class _CloudBackupBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

/// 本地 S3 服务只保存合成备份字节，并可使业务目录的分页响应缺少续页令牌。
class _BackupServer {
  /// 请求状态与对象内容归属于同一次测试，避免用例之间共享远程数据。
  _BackupServer._(this.server);

  final HttpServer server;
  final objects = <String, String>{};
  final downloaded = <String>[];
  final deleted = <String>[];
  final listQueries = <Map<String, String>>[];
  var pageSize = 3;
  var omitContinuationToken = false;

  /// 启动真实端口并注册释放，异常日志包含测试服务堆栈。
  static Future<_BackupServer> start() async {
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final fixture = _BackupServer._(server);
      server.listen(fixture._respond);
      return fixture;
    } catch (error, stack) {
      stderr.writeln('S3 备份测试服务启动失败：$error\n$stack');
      rethrow;
    }
  }

  /// 协议服务支持列表、上传、下载和删除，未知对象保持真实 404 语义。
  Future<void> _respond(HttpRequest request) async {
    try {
      final key = request.uri.path.replaceFirst('/bucket/', '');
      if (request.uri.queryParameters['list-type'] == '2') {
        request.response.headers.contentType = ContentType(
          'application',
          'xml',
          charset: 'utf-8',
        );
        final prefix = request.uri.queryParameters['prefix'];
        if (prefix == null) {
          // 初始化连接检查不代表业务目录已完整读取。
          request.response.write(
            '<ListBucketResult><IsTruncated>false</IsTruncated></ListBucketResult>',
          );
          return;
        }
        listQueries.add(request.uri.queryParameters);
        final keys =
            objects.keys.where((key) => key.startsWith(prefix)).toList()
              ..sort();
        final token = request.uri.queryParameters['continuation-token'];
        final offset = token == null ? 0 : int.parse(token.substring(7));
        final page = keys.skip(offset).take(pageSize).toList();
        final truncated = offset + page.length < keys.length;
        final continuation = truncated && !omitContinuationToken
            ? '<NextContinuationToken>offset-${offset + page.length}</NextContinuationToken>'
            : '';
        request.response.write(
          '<ListBucketResult><IsTruncated>$truncated</IsTruncated>'
          '$continuation${page.map((key) => '<Contents><Key>$key</Key></Contents>').join()}'
          '</ListBucketResult>',
        );
      } else if (request.method == 'PUT') {
        final contents = await utf8.decoder.bind(request).join();
        if (objects.containsKey(key)) {
          request.response.statusCode = 412;
        } else {
          objects[key] = contents;
        }
      } else if (request.method == 'GET' && objects.containsKey(key)) {
        downloaded.add(key);
        request.response.write(objects[key]);
      } else if (request.method == 'DELETE') {
        deleted.add(key);
        objects.remove(key);
        request.response.statusCode = 204;
      } else {
        request.response.statusCode = 404;
      }
    } catch (error, stack) {
      stderr.writeln('S3 备份测试服务响应失败：$error\n$stack');
      rethrow;
    } finally {
      await request.response.close();
    }
  }

  /// 通过真实配置注册入口连接本地服务，不替换存储接口或备份编排。
  Future<void> activate() async {
    try {
      registerS3Backend();
      addTearDown(() => CloudProviderRegistry.unregister('s3'));
      await activateTestCloudConfig(
        CloudServiceStore(),
        CloudServiceConfig(
          backendId: 's3',
          settings: {
            'endpoint': '127.0.0.1',
            'port': server.port,
            'useSSL': false,
            'bucket': 'bucket',
            'accessKey': 'test-key',
            'secretKey': 'test-secret',
          },
        ),
      );
    } catch (error, stack) {
      stderr.writeln('S3 备份测试配置失败：$error\n$stack');
      rethrow;
    }
  }

  /// 文件名沿用按时间倒序选择和清理的业务约定，正文使用真实 Base64 传输格式。
  void addBackup(int day) {
    objects[backupPath(day)] = base64Encode(utf8.encode('snapshot-$day'));
  }
}

/// 构造可按时间戳排序的云端逻辑路径。
String backupPath(int day) =>
    '$cloudBackupDirectory/sesame_notes_202610${day.toString().padLeft(2, '0')}_120000_000000_00000000-0000-4000-8000-000000000000.snbak';

/// 验证列表协议错误不会改变恢复选择或触发基于部分清单的清理。
void main() {
  final binding = _CloudBackupBinding();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory temporary;

  setUp(() async {
    try {
      SharedPreferences.setMockInitialValues({});
      temporary = await createTestTempDirectory('s3-backup-listing-');
      await logger.clear();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathChannel,
        (call) async => temporary.path,
      );
    } catch (error, stack) {
      stderr.writeln('S3 备份场景初始化失败：$error\n$stack');
      rethrow;
    }
  });

  tearDown(() async {
    try {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathChannel,
        null,
      );
      await logger.clear();
      await temporary.delete(recursive: true);
    } catch (error, stack) {
      stderr.writeln('S3 备份场景清理失败：$error\n$stack');
      rethrow;
    }
  });

  test('跨页读取完成后恢复真正最新的备份，下载字节保持一致', () async {
    final server = await _BackupServer.start();
    server.pageSize = 1;
    server.addBackup(1);
    server.addBackup(13);
    await server.activate();

    final file = await downloadLatestCloudBackup();

    expect(file, isNotNull);
    expect(await file!.readAsString(), 'snapshot-13');
    expect(server.downloaded, [backupPath(13)]);
    expect(server.listQueries, hasLength(2));
    expect(server.listQueries.last['continuation-token'], 'offset-1');
    await releaseDownloadedCloudBackup(file);
    expect(await file.parent.exists(), isFalse);
  });

  test('缺续页令牌时恢复明确失败，不能把旧页当最新备份下载', () async {
    final server = await _BackupServer.start();
    server.pageSize = 1;
    server.omitContinuationToken = true;
    server.addBackup(1);
    server.addBackup(13);
    await server.activate();

    await expectLater(
      downloadLatestCloudBackup(),
      throwsA(isA<CloudStorageException>()),
    );
    expect(server.listQueries, hasLength(1));
    expect(server.downloaded, isEmpty);
    expect(server.objects, hasLength(2));
    expect(temporary.listSync(), isEmpty);
  });

  test('上传后按全部页面清理旧备份，最终保留最新五份真实对象', () async {
    final server = await _BackupServer.start();
    for (var day = 1; day <= 7; day++) {
      server.addBackup(day);
    }
    await server.activate();
    final file = await File(
      '${temporary.path}/${backupPath(13).split('/').last}',
    ).writeAsString('snapshot-13');

    expect(await uploadBackupFile(file), 's3');

    expect(server.listQueries, hasLength(3));
    expect(server.deleted, [backupPath(3), backupPath(2), backupPath(1)]);
    expect(server.objects.keys.toSet(), {
      for (final day in [4, 5, 6, 7, 13]) backupPath(day),
    });
    expect(
      utf8.decode(base64Decode(server.objects[backupPath(13)]!)),
      'snapshot-13',
    );
  });

  test('云端正式秒级与微秒备份共同保留最新五份，其他文件保持不变', () async {
    try {
      final server = await _BackupServer.start();
      const identity = '00000000-0000-4000-8000-000000000000';

      /// 同一秒的不同快照使用独立微秒身份，保留策略不依赖 UUID 的随机顺序。
      String keyFor(int index) =>
          '$cloudBackupDirectory/sesame_notes_20261019_120000_${index.toString().padLeft(6, '0')}_$identity.snbak';

      final legacy = '$cloudBackupDirectory/sesame_notes_20261019_120000.snbak';
      final other = '$cloudBackupDirectory/user-kept.snbak';
      server.objects[legacy] = base64Encode(utf8.encode('snapshot-old'));
      server.objects[other] = base64Encode(utf8.encode('用户保留的文件'));
      for (var i = 1; i <= 6; i++) {
        server.objects[keyFor(i)] = base64Encode(utf8.encode('snapshot-$i'));
      }
      await server.activate();
      final file = await File(
        '${temporary.path}/${keyFor(7).split('/').last}',
      ).writeAsString('snapshot-7');

      expect(await uploadBackupFile(file), 's3');
      expect(server.deleted, [keyFor(2), keyFor(1), legacy]);
      expect(server.objects.keys.toSet(), {
        other,
        for (var i = 3; i <= 7; i++) keyFor(i),
      });

      final latest = await downloadLatestCloudBackup();
      expect(latest, isNotNull);
      expect(await latest!.readAsString(), 'snapshot-7');
      await releaseDownloadedCloudBackup(latest);
    } catch (error, stackTrace) {
      stderr.writeln('正式备份云端保留验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('云端仅有正式秒级备份时仍可下载最新内容', () async {
    final server = await _BackupServer.start();
    final older = '$cloudBackupDirectory/sesame_notes_20260701_120000.snbak';
    final newer = '$cloudBackupDirectory/sesame_notes_20260702_120000.snbak';
    server.objects[older] = base64Encode(utf8.encode('older-content'));
    server.objects[newer] = base64Encode(utf8.encode('newest-content'));
    await server.activate();

    final latest = await downloadLatestCloudBackup();
    expect(latest, isNotNull);
    try {
      expect(await latest!.readAsString(), 'newest-content');
      expect(server.downloaded, [newer]);
      expect(server.deleted, isEmpty);
    } finally {
      if (latest != null) await releaseDownloadedCloudBackup(latest);
    }
  });

  test('未移除提交标记的本地快照不能进入云端上传', () async {
    try {
      final server = await _BackupServer.start();
      await server.activate();
      final file = await File(
        '${temporary.path}/sesame_notes_20261019_120000.snbak',
      ).writeAsString('未完成的快照');
      final pending = await File(
        '${file.path}.pending',
      ).create(exclusive: true);

      await expectLater(uploadBackupFile(file), throwsStateError);

      expect(server.objects, isEmpty);
      expect(await pending.exists(), isTrue);
      expect(await file.readAsString(), '未完成的快照');
    } catch (error, stackTrace) {
      stderr.writeln('未提交备份上传保护验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('上传成功但列表不完整时跳过清理，保留既有备份并记录清理失败', () async {
    final server = await _BackupServer.start();
    server.pageSize = 6;
    server.omitContinuationToken = true;
    for (var day = 1; day <= 7; day++) {
      server.addBackup(day);
    }
    await server.activate();
    final before = Map<String, String>.from(server.objects);
    final file = await File(
      '${temporary.path}/${backupPath(13).split('/').last}',
    ).writeAsString('snapshot-13');

    expect(await uploadBackupFile(file), 's3');

    expect(server.deleted, isEmpty);
    expect(server.objects, {
      ...before,
      backupPath(13): base64Encode(utf8.encode('snapshot-13')),
    });
    expect(
      logger.logs.where(
        (entry) =>
            entry.level == LogLevel.warning &&
            entry.message.contains('云端备份清理失败'),
      ),
      hasLength(1),
    );
  });
}
