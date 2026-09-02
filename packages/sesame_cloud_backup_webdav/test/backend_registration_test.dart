/// WebDAV adapter 自注册契约测试。
///
/// 需求锚点：字段声明与旧版扁平配置的迁移规则归 adapter 所有，核心包不保存
/// 任何 WebDAV 字段名；注册后核心即可按描述符存取配置。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';

void main() {
  setUp(registerWebDavBackend);
  tearDown(() => CloudProviderRegistry.unregister('webdav'));

  test('注册后核心可取得后端描述符', () {
    final backend = CloudProviderRegistry.backendOf('webdav');

    expect(backend, isNotNull);
    expect(backend!.displayName, 'WebDAV');
    expect(
      backend.fields.map((f) => f.key),
      ['url', 'username', 'password', 'remotePath'],
    );
    expect(
      backend.fields.where((f) => f.isSecret).map((f) => f.key),
      ['password'],
      reason: '密码属凭据，必须进安全存储',
    );
  });

  test('必填项缺失时配置判定为不可用', () {
    expect(
      CloudProviderRegistry.isConfigValid(
        const CloudServiceConfig(
          backendId: 'webdav',
          settings: {'url': 'https://dav.example.com', 'username': 'u'},
        ),
      ),
      isFalse,
    );
  });

  test('旧版扁平配置迁移为新版 settings', () {
    final backend = CloudProviderRegistry.backendOf('webdav')!;

    expect(
      backend.importLegacy({
        'type': 'webdav',
        'name': 'WebDAV',
        'webdavUrl': 'https://dav.example.com',
        'webdavUsername': 'u',
        'webdavPassword': 'p',
        'webdavRemotePath': '/backup',
      }),
      {
        'url': 'https://dav.example.com',
        'username': 'u',
        'password': 'p',
        'remotePath': '/backup',
      },
    );
  });
}
