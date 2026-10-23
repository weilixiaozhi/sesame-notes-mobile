/// 测试用后端描述符：模拟 adapter 自注册时提交的内容。
///
/// 核心包通过描述符处理字段，不依赖具体后端实现。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// WebDAV 形态的测试后端（含一个凭据字段）。
const testWebdavBackend = CloudBackend(
  id: 'webdav',
  displayName: 'WebDAV',
  fields: [
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
);

/// Supabase 形态的测试后端，初始化所需账号与密码随配置提供。
const testSupabaseBackend = CloudBackend(
  id: 'supabase',
  displayName: 'Supabase',
  fields: [
    CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
    CloudConfigField(
      key: 'anonKey',
      labelKey: 'anon',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(key: 'bucket', labelKey: 'bucket'),
    CloudConfigField(key: 'account', labelKey: 'account', isRequired: true),
    CloudConfigField(
      key: 'password',
      labelKey: 'password',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
  ],
);

/// S3 形态的测试后端（含数字与开关字段）。
const testS3Backend = CloudBackend(
  id: 's3',
  displayName: 'S3',
  fields: [
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
);

/// 三个测试后端的全集，供注册 / 注销复用。
final testBackends = [testWebdavBackend, testSupabaseBackend, testS3Backend];

/// 注册全部测试后端（setUp 用）。
void registerTestBackends() {
  for (final backend in testBackends) {
    CloudProviderRegistry.register(
      backend,
      (config) async => null,
    );
  }
}

/// 注销全部测试后端（tearDown 用）。
void unregisterTestBackends() {
  for (final backend in testBackends) {
    CloudProviderRegistry.unregister(backend.id);
  }
}

/// 测试状态准备沿用真实保存和校验入口，配置不完整时直接报告夹具错误。
Future<void> activateTestCloudConfig(
  CloudServiceStore store,
  CloudServiceConfig config,
) async {
  try {
    await store.saveOnly(config);
    if (!await store.activate(config.backendId)) {
      throw StateError('测试云备份配置不完整：${config.backendId}');
    }
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}
