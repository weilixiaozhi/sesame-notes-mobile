import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:sesame_cloud_backup_s3/src/s3_client.dart';
import 'package:sesame_cloud_backup_s3/src/s3_provider.dart';
import 'package:sesame_cloud_backup_s3/src/s3_storage_service.dart';

/// 验证 S3 配置、安全默认值和上传路径在连接前的拒绝边界。
void main() {
  const valid = {
    'endpoint': 's3.example.com',
    'accessKey': 'ak',
    'secretKey': 'sk',
    'bucket': 'bucket'
  };

  test('合法配置可用，缺失字段及错误类型拒绝，密钥分存且默认启用SSL', () {
    try {
      registerS3Backend();
      final provider = S3Provider();
      final backend = CloudProviderRegistry.backendOf('s3')!;
      expect(
          backend.fields
              .where((field) => field.isSecret)
              .map((field) => field.key),
          ['accessKey', 'secretKey']);
      expect(
          backend.fields
              .singleWhere((field) => field.key == 'useSSL')
              .defaultValue,
          isTrue);
      expect(provider.validateConfig(valid), isTrue);
      expect(
          CloudProviderRegistry.isConfigValid(
              const CloudServiceConfig(backendId: 's3', settings: valid)),
          isTrue);
      for (final key in valid.keys) {
        final missing = {...valid}..remove(key);
        expect(provider.validateConfig(missing), isFalse, reason: key);
        expect(
            CloudProviderRegistry.isConfigValid(
                CloudServiceConfig(backendId: 's3', settings: missing)),
            isFalse,
            reason: key);
        expect(provider.validateConfig({...valid, key: 1}), isFalse,
            reason: key);
      }
      for (final port in [0, 65536, '9000']) {
        expect(provider.validateConfig({...valid, 'port': port}), isFalse,
            reason: '$port');
      }
    } catch (error, stackTrace) {
      printOnFailure('S3 配置边界验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      CloudProviderRegistry.unregister('s3');
    }
  });

  test('未初始化不得读取存储，无效配置在建立连接前拒绝', () async {
    try {
      final provider = S3Provider();
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
      for (final settings in [
        <String, dynamic>{},
        {...valid}..remove('bucket')
      ]) {
        await expectLater(provider.initialize(settings),
            throwsA(isA<CloudConfigurationException>()));
      }
    } catch (error, stackTrace) {
      printOnFailure('S3 初始化守卫验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('上传在读取文件或请求网络前拒绝目录穿越', () async {
    final client = S3Client(
        endpoint: 'localhost',
        region: 'us-east-1',
        accessKey: 'ak',
        secretKey: 'sk',
        useSSL: false);
    try {
      final storage = S3StorageService(client, 'bucket');
      await expectLater(
          storage.uploadFile(
              path: '../secret.snbak',
              file: File('../../Temp/cloud-interface-20261016/unused.snbak')),
          throwsA(isA<CloudStorageException>()));
    } catch (error, stackTrace) {
      printOnFailure('S3 路径安全验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      client.dispose();
    }
  });
}
