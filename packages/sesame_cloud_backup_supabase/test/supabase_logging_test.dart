import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/src/supabase_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// 实际文件传输失败保留一次脱敏诊断，文件操作不依赖旁路数据表。
void main() {
  test('对象上传拒绝保留状态和原始堆栈，日志不含令牌、路径或服务端正文', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final requests = <String>[];
    server.listen((request) async {
      try {
        requests.add(request.uri.path);
        await request.drain<void>();
        request.response.headers.contentType = ContentType.json;
        if (request.uri.path.startsWith('/storage/v1/object/')) {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.write(jsonEncode({
            'message': 'password-secret backup-plaintext',
            'code': '42501',
          }));
        } else {
          request.response.write('{"Key":"backup"}');
        }
      } finally {
        await request.response.close();
      }
    });
    final client = supabase.SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'password-secret',
      authOptions: const supabase.AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(client.dispose);
    await client.auth.recoverSession(jsonEncode({
      'access_token': 'password-secret',
      'token_type': 'bearer',
      'user': {'id': 'private-account'},
    }));
    final messages = <String>[];
    final storage = SupabaseStorageService(
      client,
      'private-bucket',
      'private-path',
      CloudSyncLogger(onLog: (level, message) {
        expect(level.name, 'error');
        messages.add(message);
      }),
    );
    final directory = await (Directory('../../Temp/cleanup-residual-20261017')
          ..createSync(recursive: true))
        .createTemp('supabase-log-');
    addTearDown(() => directory.delete(recursive: true));
    final source = await File('${directory.path}/source.snbak')
        .writeAsString('backup-plaintext');

    await expectLater(
      storage.uploadFile(
        path: 'private-backup.snbak',
        file: source,
        metadata: const {'note': 'backup-plaintext'},
      ),
      throwsA(isA<CloudStorageException>()
          .having((error) => error.originalError, '原始传输失败原因', isNotNull)
          .having((error) => error.statusCode, 'HTTP状态', 403)
          .having((error) => error.originalStackTrace, '传输失败堆栈', isNotNull)
          .having(
            (error) => error.toString(),
            '上层日志可安全记录的异常',
            allOf(isNot(contains('password-secret')),
                isNot(contains('backup-plaintext'))),
          )),
    );

    expect(messages, hasLength(1));
    expect(requests.where((path) => path == '/rest/v1/file_metadata'), isEmpty);
    expect(messages.single, contains('Supabase'));
    expect(messages.single, contains('文件上传失败'));
    expect(messages.single, contains('HTTP=403'));
    for (final secret in [
      'password-secret',
      'backup-plaintext',
      'private-account',
      'private-path',
    ]) {
      expect(messages.single, isNot(contains(secret)));
    }
  });
}
