import 'dart:convert';
import 'dart:io';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:sesame_cloud_backup_supabase/src/supabase_storage_service.dart';

/// 用户目录只在协议适配层添加一次，列举结果可直接用于后续操作。
void main() {
  for (final sidecarStatus in [404, 403, 500]) {
    test('旁路设施返回$sidecarStatus时文件上传下载及删除仍只使用用户目录', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requested = <String>[];
      final uploaded = <String, String>{};
      final metadataMethods = <String>[];
      server.listen((request) async {
        try {
          requested.add(request.uri.path);
          final body = await utf8.decoder.bind(request).join();
          request.response.headers.contentType = ContentType.json;
          if (request.method == 'POST' &&
              request.uri.path.contains('/object/bucket/')) {
            expect(request.headers.value('x-upsert'), 'false');
            if (uploaded.containsKey(request.uri.path)) {
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
                  'metadata': {'size': 8}
                }
            ]));
          } else if (request.method == 'DELETE' &&
              request.uri.path == '/storage/v1/object/bucket') {
            expect(jsonDecode(body)['prefixes'],
                ['users/account/backups/a.snbak']);
            uploaded.remove(
                '/storage/v1/object/bucket/users/account/backups/a.snbak');
            request.response.write('[]');
          } else if (request.uri.path == '/rest/v1/file_metadata') {
            metadataMethods.add(request.method);
            request.response.statusCode = sidecarStatus;
            request.response.write(jsonEncode({
              'message': 'metadata facility unavailable',
              'code': 'facility_unavailable',
            }));
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
          'http://127.0.0.1:${server.port}', 'key',
          authOptions:
              const supabase.AuthClientOptions(autoRefreshToken: false));
      addTearDown(client.dispose);
      await client.auth.recoverSession(jsonEncode({
        'access_token': 'token',
        'token_type': 'bearer',
        'user': {'id': 'account'}
      }));
      final storage = SupabaseStorageService(client, 'bucket');
      final dir = await (Directory('../../Temp/cleanup-final-residual-20261017')
            ..createSync(recursive: true))
          .createTemp('supabase-stream-');
      addTearDown(() => dir.delete(recursive: true));
      final file = await File('${dir.path}/source').writeAsString('snapshot');
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
      expect(await output.readAsString(), 'snapshot');
      final listed = await storage.list(path: 'backups/');
      expect(listed.single.path, 'backups/a.snbak');
      expect(listed.single.size, 8);
      expect(listed.single.metadata, {'size': 8});
      expect(
        await storage.downloadFile(
            path: listed.single.path, destination: output),
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
      expect(metadataMethods, isEmpty, reason: '实际文件操作不得请求旁路数据表');
      expect(uploaded, isEmpty);
      expect(requested.any((path) => path.contains('account/users')), isFalse);
    });
  }
}
