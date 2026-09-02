/// 测试用后端描述符：模拟 adapter 自注册时提交的内容。
///
/// 字段名刻意与真实 adapter 不同（authKey 而非 webdavPassword），用于证明
/// 核心包不依赖任何后端字段名——只要描述符一致，任意后端都能存取。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// WebDAV 形态的测试后端（含一个凭据字段）。
final testWebdavBackend = CloudBackend(
  id: 'webdav',
  displayName: 'WebDAV',
  fields: const [
    CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
    CloudConfigField(key: 'username', labelKey: 'user', isRequired: true),
    CloudConfigField(
      key: 'password',
      labelKey: 'pw',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(key: 'remotePath', labelKey: 'path'),
  ],
  importLegacy: (json) => {
    'url': json['webdavUrl'],
    'username': json['webdavUsername'],
    'password': json['webdavPassword'],
    'remotePath': json['webdavRemotePath'],
  },
);

/// Supabase 形态的测试后端（anonKey 属凭据）。
final testSupabaseBackend = CloudBackend(
  id: 'supabase',
  displayName: 'Supabase',
  fields: const [
    CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
    CloudConfigField(
      key: 'anonKey',
      labelKey: 'anon',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(key: 'bucket', labelKey: 'bucket'),
    CloudConfigField(key: 'account', labelKey: 'account'),
  ],
  importLegacy: (json) => {
    'url': json['supabaseUrl'],
    'anonKey': json['supabaseAnonKey'],
    'bucket': json['supabaseBucket'],
    'account': json['supabaseAccount'] ?? json['supabaseEmail'],
  },
);

/// S3 形态的测试后端（含数字与开关字段）。
final testS3Backend = CloudBackend(
  id: 's3',
  displayName: 'S3',
  fields: const [
    CloudConfigField(key: 'endpoint', labelKey: 'endpoint', isRequired: true),
    CloudConfigField(key: 'region', labelKey: 'region'),
    CloudConfigField(
      key: 'accessKey',
      labelKey: 'ak',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(
      key: 'secretKey',
      labelKey: 'sk',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(key: 'bucket', labelKey: 'bucket', isRequired: true),
    CloudConfigField(
      key: 'port',
      labelKey: 'port',
      kind: CloudConfigFieldKind.number,
    ),
    CloudConfigField(
      key: 'useSSL',
      labelKey: 'ssl',
      kind: CloudConfigFieldKind.boolean,
      defaultValue: true,
    ),
  ],
  importLegacy: (json) => {
    'endpoint': json['s3Endpoint'],
    'region': json['s3Region'],
    'accessKey': json['s3AccessKey'],
    'secretKey': json['s3SecretKey'],
    'bucket': json['s3Bucket'],
    'useSSL': json['s3UseSSL'],
    'port': json['s3Port'],
  },
);

/// 三个测试后端的全集，供注册 / 注销复用。
final testBackends = [testWebdavBackend, testSupabaseBackend, testS3Backend];

/// 注册全部测试后端（setUp 用）。
void registerTestBackends() {
  for (final backend in testBackends) {
    CloudProviderRegistry.register(
      backend,
      (config) async => (provider: null, auth: null),
    );
  }
}

/// 注销全部测试后端（tearDown 用）。
void unregisterTestBackends() {
  for (final backend in testBackends) {
    CloudProviderRegistry.unregister(backend.id);
  }
}
