/// S3 provider for sesame_cloud_backup
///
/// Supports all S3-compatible storage services:
/// - AWS S3
/// - Cloudflare R2
/// - Backblaze B2
/// - MinIO (self-hosted)
/// - Aliyun OSS
/// - Tencent COS
/// - Qiniu Kodo
///
/// 公共入口只暴露自注册函数，具体实现放在 src/ 下：adapter 的实现类一旦经
/// 本入口导出就成了跨包公共 API（任何新增符号自动进入兼容承诺），而主工程
/// 唯一需要的是在 Composition Root 调用 [registerS3Backend]。
/// 包内代码与测试直接 import src/ 下的文件。
///
/// ## Usage
///
/// ```dart
/// import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
///
/// registerS3Backend();
/// ```
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'src/s3_provider.dart';

/// 把 S3 后端自注册到核心包的 [CloudProviderRegistry]。
///
/// 插件化约定：核心包不依赖本 adapter；由主工程 Composition Root（main.dart）
/// 调用本函数完成注册后，`createCloudProvider` 才能分发到 S3。
/// 重复调用安全（后者覆盖前者）。
void registerS3Backend({CloudSyncLogger? logger}) {
  CloudProviderRegistry.register(
    const CloudBackend(
      id: 's3',
      displayName: 'S3',
      fields: [
        CloudConfigField(
          key: 'endpoint',
          labelKey: 'cloudBackupEndpointLabel',
          isRequired: true,
        ),
        CloudConfigField(key: 'region', labelKey: 'cloudBackupRegionLabel'),
        CloudConfigField(
          key: 'accessKey',
          labelKey: 'cloudBackupAccessKeyLabel',
          kind: CloudConfigFieldKind.secret,
          isRequired: true,
        ),
        CloudConfigField(
          key: 'secretKey',
          labelKey: 'cloudBackupSecretKeyLabel',
          kind: CloudConfigFieldKind.secret,
          isRequired: true,
        ),
        CloudConfigField(
          key: 'bucket',
          labelKey: 'cloudBackupBucketLabel',
          isRequired: true,
        ),
        CloudConfigField(
          key: 'port',
          labelKey: 'cloudBackupPortLabel',
          kind: CloudConfigFieldKind.number,
        ),
        CloudConfigField(
          key: 'useSSL',
          labelKey: 'cloudBackupSslLabel',
          kind: CloudConfigFieldKind.boolean,
          defaultValue: true,
        ),
      ],
    ),
    (config) async {
      // S3 初始化 - 不捕获异常，让错误向上传递以便调试
      final provider = S3Provider(logger: logger);
      await provider.initialize({
        'endpoint': config.settings['endpoint'],
        'region': config.settings['region'] ?? 'us-east-1',
        'accessKey': config.settings['accessKey'],
        'secretKey': config.settings['secretKey'],
        'bucket': config.settings['bucket'],
        'useSSL': config.settings['useSSL'] ?? true,
        'port': config.settings['port'],
      });

      return provider;
    },
  );
}
