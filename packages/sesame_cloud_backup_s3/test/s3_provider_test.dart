import 'dart:io';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/src/s3_client.dart';
import 'package:sesame_cloud_backup_s3/src/s3_provider.dart';
import 'package:sesame_cloud_backup_s3/src/s3_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('S3Provider', () {
    late S3Provider provider;

    setUp(() {
      provider = S3Provider();
    });

    test('validateConfig should return false for missing keys', () {
      expect(provider.validateConfig({}), isFalse);
      expect(
        provider.validateConfig({
          'endpoint': 's3.example.com',
          'accessKey': 'ak',
          'secretKey': 'sk',
        }),
        isFalse,
      );
    });

    test('validateConfig should return true for valid config', () {
      expect(
        provider.validateConfig({
          'endpoint': 's3.example.com',
          'accessKey': 'ak',
          'secretKey': 'sk',
          'bucket': 'bucket',
        }),
        isTrue,
      );
    });

    test('错误类型和越界端口返回 false，不能抛类型错误', () {
      const valid = {
        'endpoint': 's3.example.com',
        'accessKey': 'ak',
        'secretKey': 'sk',
        'bucket': 'bucket',
      };
      for (final field in valid.keys) {
        expect(provider.validateConfig({...valid, field: 1}), isFalse);
      }
      for (final port in [0, 65536, '9000']) {
        expect(provider.validateConfig({...valid, 'port': port}), isFalse);
      }
    });

    test('uninitialized storage getter throws CloudConfigurationException', () {
      expect(
        () => provider.storage,
        throwsA(isA<CloudConfigurationException>()),
      );
    });

    test('initialize with invalid config throws CloudConfigurationException',
        () async {
      expect(
        () => provider.initialize({}),
        throwsA(isA<CloudConfigurationException>()),
      );
      expect(
        () => provider.initialize({
          'endpoint': 's3.example.com',
          'accessKey': 'ak',
          'secretKey': 'sk',
          // 缺 bucket
        }),
        throwsA(isA<CloudConfigurationException>()),
      );
    });
  });

  group('S3StorageService 路径校验', () {
    test('uploadFile 拒绝 ../ 穿越路径', () async {
      final client = S3Client(
        endpoint: 'localhost',
        region: 'us-east-1',
        accessKey: 'ak',
        secretKey: 'sk',
        useSSL: false,
      );
      try {
        final storage = S3StorageService(client, 'bucket');
        // 校验发生在任何文件读取或网络请求之前。
        await expectLater(
          storage.uploadFile(
            path: '../secret.snbak',
            file: File('../../Temp/cloud-interface-20261016/unused.snbak'),
          ),
          throwsA(isA<CloudStorageException>()),
        );
      } finally {
        client.dispose();
      }
    });
  });
}
