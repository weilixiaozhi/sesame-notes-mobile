/// 提供方工厂按后端注册表分发，本地或无效配置返回空提供方。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'utils/test_backends.dart';

const _supabaseCfg = CloudServiceConfig(
  backendId: 'supabase',
  settings: {
    'url': 'https://example.supabase.co',
    'anonKey': 'anon',
    'account': 'backup@example.test',
    'password': 'fixture-password',
  },
);

/// 工厂只负责分派，提供方初始化由注册构建器完成。
class _Provider extends Fake implements CloudProvider {}

/// 验证工厂返回原提供方，配置无效和构建失败均保留准确边界。
void main() {
  setUp(registerTestBackends);
  tearDown(unregisterTestBackends);

  test('本地后端直接返回空服务，不依赖任何注册', () async {
    final provider = await createCloudProvider(CloudServiceConfig.local);
    expect(provider, isNull);
  });

  test('已注册后端：经注册表 builder 创建并透传结果', () async {
    var called = 0;
    final expected = _Provider();
    CloudProviderRegistry.register(testSupabaseBackend, (config) async {
      called++;
      expect(config, same(_supabaseCfg));
      return expected;
    });

    final provider = await createCloudProvider(_supabaseCfg);

    expect(called, 1, reason: '已注册后端必须走注册表 builder');
    expect(provider, same(expected));
  });

  test('未注册后端：抛 StateError 提示在 Composition Root 注册', () async {
    CloudProviderRegistry.unregister('supabase');
    await expectLater(createCloudProvider(_supabaseCfg), throwsStateError);
  });

  test('无效配置：返回空服务且不抛错', () async {
    const invalid = CloudServiceConfig(
      backendId: 'supabase',
      settings: {'url': 'https://example.supabase.co'},
    );
    var called = false;
    CloudProviderRegistry.register(testSupabaseBackend, (_) async {
      called = true;
      return _Provider();
    });
    final provider = await createCloudProvider(invalid);
    expect(provider, isNull);
    expect(called, isFalse, reason: '无效配置不能初始化后端连接');
  });

  test('提供方构建失败保留原始异常，由后端负责释放未返回的资源', () async {
    final failure = StateError('连接初始化失败');
    CloudProviderRegistry.register(testSupabaseBackend, (_) async {
      throw failure;
    });
    await expectLater(
        createCloudProvider(_supabaseCfg), throwsA(same(failure)));
  });

  test('后端自定义校验优先于必填项非空判定', () async {
    final strict = CloudBackend(
      id: 'strict',
      displayName: 'Strict',
      fields: const [
        CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
      ],
      validate: (settings) =>
          (settings['url'] as String?)?.startsWith('https://') ?? false,
    );
    CloudProviderRegistry.register(
      strict,
      (config) async => null,
    );
    addTearDown(() => CloudProviderRegistry.unregister('strict'));

    const httpCfg = CloudServiceConfig(
      backendId: 'strict',
      settings: {'url': 'http://insecure.example.com'},
    );
    expect(CloudProviderRegistry.isConfigValid(httpCfg), isFalse);
    expect(
      CloudProviderRegistry.isConfigValid(
        const CloudServiceConfig(
          backendId: 'strict',
          settings: {'url': 'https://secure.example.com'},
        ),
      ),
      isTrue,
    );
  });
}
