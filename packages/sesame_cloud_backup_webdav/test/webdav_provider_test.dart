import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:sesame_cloud_backup_webdav/src/webdav_provider.dart';

/// 验证后端配置边界、密码安全归属与初始化前的访问约束。
void main() {
  test('配置接受合法可选路径，拒绝缺失或类型错误，密码只进安全存储', () {
    try {
      registerWebDavBackend();
      final provider = WebDAVProvider();
      const valid = {
        'url': 'https://dav.example.com',
        'username': 'user',
        'password': 'secret',
      };
      final backend = CloudProviderRegistry.backendOf('webdav')!;
      expect(
          backend.fields
              .where((field) => field.isSecret)
              .map((field) => field.key),
          ['password']);
      for (final settings in [
        valid,
        {...valid, 'remotePath': '/SesameNotes/'}
      ]) {
        expect(provider.validateConfig(settings), isTrue);
        expect(
            CloudProviderRegistry.isConfigValid(
                CloudServiceConfig(backendId: 'webdav', settings: settings)),
            isTrue);
      }
      for (final settings in [
        <String, dynamic>{},
        for (final key in valid.keys) {...valid}..remove(key),
        {...valid, 'remotePath': 123}
      ]) {
        expect(provider.validateConfig(settings), isFalse,
            reason: settings.keys.toString());
        expect(
            CloudProviderRegistry.isConfigValid(
                CloudServiceConfig(backendId: 'webdav', settings: settings)),
            isFalse);
      }
    } catch (error, stackTrace) {
      printOnFailure('WebDAV 配置边界验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      CloudProviderRegistry.unregister('webdav');
    }
  });

  test('未初始化不得读取存储，无效配置在建立连接前拒绝', () async {
    try {
      final provider = WebDAVProvider();
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
      await expectLater(
          provider.initialize({}), throwsA(isA<CloudConfigurationException>()));
    } catch (error, stackTrace) {
      printOnFailure('WebDAV 初始化守卫验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
