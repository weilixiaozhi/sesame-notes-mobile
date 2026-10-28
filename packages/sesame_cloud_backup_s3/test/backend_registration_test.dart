/// S3 后端的敏感字段、安全默认值和必要配置约束。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';

void main() {
  setUp(registerS3Backend);
  tearDown(() => CloudProviderRegistry.unregister('s3'));

  test('访问密钥进入安全存储且默认启用SSL', () {
    final backend = CloudProviderRegistry.backendOf('s3');

    expect(backend, isNotNull);
    expect(
      backend!.fields.where((f) => f.isSecret).map((f) => f.key),
      ['accessKey', 'secretKey'],
      reason: '访问密钥属凭据，必须进安全存储',
    );
    expect(
      backend.fields.singleWhere((f) => f.key == 'useSSL').defaultValue,
      isTrue,
      reason: 'SSL 默认开启',
    );
  });

  test('必填项缺失时配置判定为不可用', () {
    expect(
      CloudProviderRegistry.isConfigValid(
        const CloudServiceConfig(
          backendId: 's3',
          settings: {
            'endpoint': 's3.example.com',
            'accessKey': 'ak',
            'secretKey': 'sk',
          },
        ),
      ),
      isFalse,
      reason: 'bucket 为必填',
    );
  });
}
