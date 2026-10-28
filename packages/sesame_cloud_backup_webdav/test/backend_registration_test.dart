/// WebDAV 后端的敏感字段和必要配置约束。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';

void main() {
  setUp(registerWebDavBackend);
  tearDown(() => CloudProviderRegistry.unregister('webdav'));

  test('密码必须进入安全存储', () {
    final backend = CloudProviderRegistry.backendOf('webdav');

    expect(backend, isNotNull);
    expect(
      backend!.fields.where((f) => f.isSecret).map((f) => f.key),
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
}
