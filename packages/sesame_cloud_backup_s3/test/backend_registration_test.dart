/// S3 adapter 自注册契约测试。
///
/// 需求锚点：字段声明与旧版扁平配置的迁移规则归 adapter 所有，核心包不保存
/// 任何 S3 字段名；注册后核心即可按描述符存取配置。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';

void main() {
  setUp(registerS3Backend);
  tearDown(() => CloudProviderRegistry.unregister('s3'));

  test('注册后核心可取得后端描述符', () {
    final backend = CloudProviderRegistry.backendOf('s3');

    expect(backend, isNotNull);
    expect(backend!.displayName, 'S3');
    expect(
      backend.fields.where((f) => f.isSecret).map((f) => f.key),
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

  test('旧版扁平配置迁移为新版 settings（剥离 endpoint 协议前缀）', () {
    final backend = CloudProviderRegistry.backendOf('s3')!;

    expect(
      backend.importLegacy({
        'type': 's3',
        'name': 'S3',
        's3Endpoint': 'https://s3.example.com',
        's3Region': 'us-east-1',
        's3AccessKey': 'ak',
        's3SecretKey': 'sk',
        's3Bucket': 'bkt',
        's3UseSSL': false,
        's3Port': 9000,
      }),
      {
        'endpoint': 's3.example.com',
        'region': 'us-east-1',
        'accessKey': 'ak',
        'secretKey': 'sk',
        'bucket': 'bkt',
        'useSSL': false,
        'port': 9000,
      },
    );
  });
}
