/// Supabase provider for sesame_cloud_backup.
///
/// This library provides Supabase integration for the sesame_cloud_backup package,
/// enabling cloud synchronization using Supabase's storage and authentication services.
///
/// 公共入口只暴露自注册函数，具体实现放在 src/ 下：adapter 的实现类一旦经
/// 本入口导出就成了跨包公共 API（任何新增符号自动进入兼容承诺），而主工程
/// 唯一需要的是在 Composition Root 调用 [registerSupabaseBackend]。
/// 包内代码与测试直接 import src/ 下的文件。
///
/// To use this library:
///
/// ```dart
/// import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
///
/// registerSupabaseBackend();
/// ```
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'src/supabase_provider.dart';

/// 把 Supabase 后端自注册到核心包的 [CloudProviderRegistry]。
///
/// 插件化约定：核心包不依赖本 adapter；由主工程 Composition Root（main.dart）
/// 调用本函数完成注册后，`createCloudProvider` 才能分发到 Supabase。
/// 重复调用安全（后者覆盖前者）。
void registerSupabaseBackend({CloudSyncLogger? logger}) {
  CloudProviderRegistry.register(
    const CloudBackend(
      id: 'supabase',
      displayName: 'Supabase',
      fields: [
        CloudConfigField(
          key: 'url',
          labelKey: 'cloudBackupUrlLabel',
          isRequired: true,
        ),
        CloudConfigField(
          key: 'anonKey',
          labelKey: 'cloudBackupAnonKeyLabel',
          kind: CloudConfigFieldKind.secret,
          isRequired: true,
        ),
        CloudConfigField(key: 'bucket', labelKey: 'cloudBackupBucketLabel'),
        // 账号与密码随配置一并保存（Supabase 存储要求登录，
        // 凭据在配置保存后创建服务时自动登录，无独立登录入口）。
        CloudConfigField(
          key: 'account',
          labelKey: 'cloudBackupAccountLabel',
          isRequired: true,
        ),
        CloudConfigField(
          key: 'password',
          labelKey: 'cloudBackupPasswordLabel',
          kind: CloudConfigFieldKind.secret,
          isRequired: true,
        ),
      ],
    ),
    (config) async {
      final provider = SupabaseProvider(logger: logger);
      try {
        await provider.initialize({
          'url': config.settings['url'],
          'anonKey': config.settings['anonKey'],
          'bucket': config.settings['bucket'] ?? 'sesame-notes-backups',
          'account': config.settings['account'],
          'password': config.settings['password'],
          // 使用默认的 users/{userId}/ 结构，基础包支持但业务层不配置
          'pathPrefix': null,
        });

        return provider;
      } catch (error, stackTrace) {
        // 构建失败时调用方拿不到 provider，必须在此释放已创建的 SDK 资源。
        logger?.error('Supabase 备份连接创建失败：${error.runtimeType}\n$stackTrace');
        try {
          await provider.dispose();
        } catch (cleanupError, cleanupStackTrace) {
          logger?.error(
              'Supabase 失败连接清理异常：${cleanupError.runtimeType}\n$cleanupStackTrace');
        }
        rethrow;
      }
    },
  );
}
