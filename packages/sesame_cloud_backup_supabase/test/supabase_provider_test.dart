import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_supabase/src/supabase_provider.dart';

/// 验证存储配置类型、登录凭据的安全归属与连接初始化守卫。
void main() {
  test('配置接受可选桶，拒绝缺失或类型错误，密钥和密码只进安全存储', () {
    try {
      registerSupabaseBackend();
      final provider = SupabaseProvider();
      const valid = {
        'url': 'https://example.supabase.co',
        'anonKey': 'test-key'
      };
      final backend = CloudProviderRegistry.backendOf('supabase')!;
      expect(
          backend.fields
              .where((field) => field.isSecret)
              .map((field) => field.key),
          ['anonKey', 'password']);
      for (final settings in [
        valid,
        {...valid, 'bucket': 'user-data'}
      ]) {
        expect(provider.validateConfig(settings), isTrue);
      }
      for (final settings in [
        <String, dynamic>{},
        for (final key in valid.keys) {...valid}..remove(key),
        {...valid, 'bucket': 123}
      ]) {
        expect(provider.validateConfig(settings), isFalse,
            reason: settings.keys.toString());
      }
      const registered = {
        ...valid,
        'account': 'user@example.com',
        'password': 'secret'
      };
      expect(
          CloudProviderRegistry.isConfigValid(const CloudServiceConfig(
              backendId: 'supabase', settings: registered)),
          isTrue);
      for (final key in registered.keys) {
        expect(
            CloudProviderRegistry.isConfigValid(CloudServiceConfig(
                backendId: 'supabase', settings: {...registered}..remove(key))),
            isFalse,
            reason: key);
      }
    } catch (error, stackTrace) {
      printOnFailure('Supabase 配置边界验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      CloudProviderRegistry.unregister('supabase');
    }
  });

  test('未初始化不得读取存储，无效配置在建立连接前拒绝', () async {
    try {
      final provider = SupabaseProvider();
      expect(
          () => provider.storage, throwsA(isA<CloudConfigurationException>()));
      await expectLater(
          provider.initialize({}), throwsA(isA<CloudConfigurationException>()));
    } catch (error, stackTrace) {
      printOnFailure('Supabase 初始化守卫验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
