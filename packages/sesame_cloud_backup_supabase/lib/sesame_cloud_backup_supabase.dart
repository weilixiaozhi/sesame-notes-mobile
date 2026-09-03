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
/// 调用本函数完成注册后，`createCloudServices` 才能分发到 Supabase。
/// 重复调用安全（后者覆盖前者）。
void registerSupabaseBackend() {
  CloudProviderRegistry.register(
    // 字段键与旧版扁平字段名的对应关系只有本 adapter 知道，核心包不参与。
    CloudBackend(
      id: 'supabase',
      displayName: 'Supabase',
      fields: const [
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
      importLegacy: (json) => {
        'url': json['supabaseUrl'],
        'anonKey': json['supabaseAnonKey'],
        'bucket': json['supabaseBucket'],
        'account': json['supabaseAccount'] ?? json['supabaseEmail'],
      },
    ),
    (config) async {
      // 创建并初始化 Supabase provider
      // 包内会处理重复初始化的问题
      final provider = SupabaseProvider();
      await provider.initialize({
        'url': config.settings['url'],
        'anonKey': config.settings['anonKey'],
        'bucket': config.settings['bucket'] ?? 'sesame-notes-backups',
        // 使用默认的 users/{userId}/ 结构，基础包支持但业务层不配置
        'pathPrefix': null,
      });

      // 凭配置内账号密码自动登录：上传/下载/连接测试都经本构建器创建服务，
      // 登录失败向上抛，由调用方按失败处理（自动备份记 dirty）。
      final account = (config.settings['account'] as String?)?.trim();
      final password = (config.settings['password'] as String?) ?? '';
      if (account != null && account.isNotEmpty) {
        await provider.auth.signInWithAccount(
          account: account,
          password: password,
        );
      }

      // Auth service 直接从 provider 获取
      return (provider: provider, auth: provider.auth);
    },
  );
}
