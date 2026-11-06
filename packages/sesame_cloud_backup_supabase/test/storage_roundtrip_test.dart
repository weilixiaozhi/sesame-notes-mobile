import 'dart:convert';
import 'dart:io';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:sesame_cloud_backup_supabase/src/supabase_storage_service.dart';

/// 用户目录只在协议适配层添加一次，列举结果可直接用于后续操作。
void main() {
  test('上传拒绝后可重试，文件完整传输及幂等删除只访问用户目录', () async {
    try {
      registerSupabaseBackend();
      addTearDown(() => CloudProviderRegistry.unregister('supabase'));
      expect(
          CloudProviderRegistry.backendOf('supabase')!
              .fields
              .where((field) => field.isSecret)
              .map((field) => field.key),
          ['anonKey', 'password']);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requested = <String>[];
      final uploaded = <String, String>{};
      final messages = <String>[];
      var rejectUpload = true;
      server.listen((request) async {
        try {
          requested.add(request.uri.path);
          final body = await utf8.decoder.bind(request).join();
          request.response.headers.contentType = ContentType.json;
          if (request.method == 'POST' &&
              request.uri.path.contains('/object/bucket/')) {
            expect(request.headers.value('x-upsert'), 'false');
            if (rejectUpload) {
              request.response.statusCode = 403;
              request.response.write(jsonEncode({
                'message': 'password-secret backup-plaintext',
                'code': '42501'
              }));
            } else if (uploaded.containsKey(request.uri.path)) {
              request.response.statusCode = 400;
              request.response.write(
                  '{"message":"The resource already exists","error":"Duplicate"}');
            } else {
              uploaded[request.uri.path] = body;
              request.response.write('{"Key":"ok"}');
            }
          } else if (request.uri.path == '/storage/v1/object/list/bucket') {
            expect(jsonDecode(body)['prefix'], 'users/account/backups');
            request.response.write(jsonEncode([
              if (uploaded.isNotEmpty)
                {
                  'name': 'a.snbak',
                  'id': 'x',
                  'metadata': {
                    'size': utf8.encode(uploaded.values.single).length
                  }
                }
            ]));
          } else if (request.method == 'DELETE' &&
              request.uri.path == '/storage/v1/object/bucket') {
            expect(jsonDecode(body)['prefixes'],
                ['users/account/backups/a.snbak']);
            uploaded.remove(
                '/storage/v1/object/bucket/users/account/backups/a.snbak');
            request.response.write('[]');
          } else if (request.uri.path ==
                  '/storage/v1/object/bucket/users/account/backups/a.snbak' &&
              uploaded.containsKey(request.uri.path)) {
            request.response.write(uploaded[request.uri.path]);
          } else {
            request.response.statusCode = 404;
            request.response
                .write('{"message":"not found","statusCode":"404"}');
          }
        } finally {
          await request.response.close();
        }
      });
      final client = supabase.SupabaseClient(
          'http://127.0.0.1:${server.port}', 'password-secret',
          authOptions:
              const supabase.AuthClientOptions(autoRefreshToken: false));
      addTearDown(client.dispose);
      await client.auth.recoverSession(jsonEncode({
        'access_token': 'password-secret',
        'token_type': 'bearer',
        'user': {'id': 'account'}
      }));
      final storage = SupabaseStorageService(client, 'bucket', null,
          CloudSyncLogger(onLog: (_, message) => messages.add(message)));
      final dir = await (Directory('../../Temp/cleanup-final-residual-20261017')
            ..createSync(recursive: true))
          .createTemp('supabase-stream-');
      addTearDown(() => dir.delete(recursive: true));
      final file =
          await File('${dir.path}/source').writeAsString('backup-plaintext');
      await expectLater(
        storage.uploadFile(path: 'backups/a.snbak', file: file),
        throwsA(isA<CloudStorageException>()
            .having((error) => error.statusCode, '上传拒绝状态', 403)
            .having((error) => error.originalError, '原始传输原因', isNotNull)
            .having((error) => error.originalStackTrace, '传输失败堆栈', isNotNull)
            .having(
                (error) => error.toString(),
                '安全错误提示',
                allOf(isNot(contains('password-secret')),
                    isNot(contains('backup-plaintext'))))),
      );
      expect(uploaded, isEmpty);
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
      expect(listed.single.path, 'backups/a.snbak');
      expect(listed.single.size, await file.length());
      expect(listed.single.metadata, {'size': await file.length()});
      expect(
        await storage.downloadFile(
            path: listed.single.path, destination: output),
        isTrue,
      );
      expect(await output.readAsBytes(), await file.readAsBytes());
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
      expect(requested.where((path) => path.startsWith('/rest/')), isEmpty,
          reason: '实际文件操作不得请求旁路数据表');
      expect(uploaded, isEmpty);
      expect(requested.any((path) => path.contains('account/users')), isFalse);
      expect(messages, isNotEmpty);
      for (final secret in [
        'password-secret',
        'backup-plaintext',
        'users/account'
      ]) {
        expect(messages.join('\n'), isNot(contains(secret)));
      }
    } catch (error, stackTrace) {
      printOnFailure('Supabase 文件拒绝与恢复链路验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
