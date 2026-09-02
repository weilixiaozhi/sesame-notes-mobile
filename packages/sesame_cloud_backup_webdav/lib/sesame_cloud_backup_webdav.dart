/// WebDAV provider for sesame_cloud_backup.
///
/// This library provides WebDAV integration for the sesame_cloud_backup package,
/// enabling cloud synchronization using WebDAV protocol with Basic Auth.
///
/// 公共入口只暴露自注册函数，具体实现放在 src/ 下：adapter 的实现类一旦经
/// 本入口导出就成了跨包公共 API（任何新增符号自动进入兼容承诺），而主工程
/// 唯一需要的是在 Composition Root 调用 [registerWebDavBackend]。
/// 包内代码与测试直接 import src/ 下的文件。
///
/// To use this library:
///
/// ```dart
/// import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
///
/// registerWebDavBackend();
/// ```
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'src/webdav_provider.dart';

/// 把 WebDAV 后端自注册到核心包的 [CloudProviderRegistry]。
///
/// 插件化约定：核心包不依赖本 adapter；由主工程 Composition Root（main.dart）
/// 调用本函数完成注册后，`createCloudServices` 才能分发到 WebDAV。
/// 重复调用安全（后者覆盖前者）。
void registerWebDavBackend() {
  CloudProviderRegistry.register(
    // 字段键与旧版扁平字段名的对应关系只有本 adapter 知道，核心包不参与。
    CloudBackend(
      id: 'webdav',
      displayName: 'WebDAV',
      fields: const [
        CloudConfigField(
          key: 'url',
          labelKey: 'cloudBackupUrlLabel',
          isRequired: true,
        ),
        CloudConfigField(
          key: 'username',
          labelKey: 'cloudBackupUsernameLabel',
          isRequired: true,
        ),
        CloudConfigField(
          key: 'password',
          labelKey: 'cloudBackupPasswordLabel',
          kind: CloudConfigFieldKind.secret,
          isRequired: true,
        ),
        CloudConfigField(
          key: 'remotePath',
          labelKey: 'cloudBackupRemotePathLabel',
        ),
      ],
      importLegacy: (json) => {
        'url': json['webdavUrl'],
        'username': json['webdavUsername'],
        'password': json['webdavPassword'],
        'remotePath': json['webdavRemotePath'],
      },
    ),
    (config) async {
      final provider = WebDAVProvider();
      await provider.initialize({
        'url': config.settings['url'],
        'username': config.settings['username'],
        'password': config.settings['password'],
        'remotePath': config.settings['remotePath'] ?? '/',
      });

      // Auth service 直接从 provider 获取
      return (provider: provider, auth: provider.auth);
    },
  );
}
