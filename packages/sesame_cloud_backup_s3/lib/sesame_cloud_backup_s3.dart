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
/// 调用本函数完成注册后，`createCloudServices` 才能分发到 S3。
/// 重复调用安全（后者覆盖前者）。
void registerS3Backend() {
  CloudProviderRegistry.register(
    // 字段键与旧版扁平字段名的对应关系只有本 adapter 知道，核心包不参与。
    CloudBackend(
      id: 's3',
      displayName: 'S3',
      fields: const [
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
      importLegacy: (json) => {
        // 旧版 endpoint 可能带 http(s):// 前缀，迁移时统一剥离。
        'endpoint': (json['s3Endpoint'] as String?)
            ?.replaceFirst(RegExp(r'^https?://'), ''),
        'region': json['s3Region'],
        'accessKey': json['s3AccessKey'],
        'secretKey': json['s3SecretKey'],
        'bucket': json['s3Bucket'],
        'useSSL': json['s3UseSSL'],
        'port': json['s3Port'],
      },
    ),
    (config) async {
      // S3 初始化 - 不捕获异常，让错误向上传递以便调试
      final provider = S3Provider();
      await provider.initialize({
        'endpoint': config.settings['endpoint'],
        'region': config.settings['region'] ?? 'us-east-1',
        'accessKey': config.settings['accessKey'],
        'secretKey': config.settings['secretKey'],
        'bucket': config.settings['bucket'],
        'useSSL': config.settings['useSSL'] ?? true,
        'port': config.settings['port'],
      });

      // Auth service 直接从 provider 获取
      return (provider: provider, auth: provider.auth);
    },
  );
}
