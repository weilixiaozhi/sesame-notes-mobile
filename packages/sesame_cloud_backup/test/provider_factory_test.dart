// createCloudServices 分派行为锁定：adapter 后端一律经注册表分发。
//
// 需求锚点：
// - 本地后端是核心包原生空服务，直接返回 (null, null)，不查注册表；
// - 已注册后端必须经 CloudProviderRegistry builder 创建；
// - 未注册后端抛 StateError（提示 Composition Root 完成注册）；
// - 无效配置直接返回 (null, null)。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'utils/test_backends.dart';

const _supabaseCfg = CloudServiceConfig(
  backendId: 'supabase',
  settings: {'url': 'https://example.supabase.co', 'anonKey': 'anon'},
);

void main() {
  setUp(registerTestBackends);
  tearDown(unregisterTestBackends);

  test('本地后端直接返回空服务，不依赖任何注册', () async {
    final services = await createCloudServices(CloudServiceConfig.local);
    expect(services.provider, isNull);
    expect(services.auth, isNull);
  });

  test('已注册后端：经注册表 builder 创建并透传结果', () async {
    var called = 0;
    CloudProviderRegistry.register(testSupabaseBackend, (config) async {
      called++;
      expect(config.backendId, 'supabase');
      return (provider: null, auth: null);
    });

    final services = await createCloudServices(_supabaseCfg);

    expect(called, 1, reason: '已注册后端必须走注册表 builder');
    expect(services.provider, isNull);
    expect(services.auth, isNull);
  });

  test('未注册后端：抛 StateError 提示在 Composition Root 注册', () async {
    CloudProviderRegistry.unregister('supabase');
    await expectLater(createCloudServices(_supabaseCfg), throwsStateError);
  });

  test('无效配置：返回空服务且不抛错', () async {
    const invalid = CloudServiceConfig(
      backendId: 'supabase',
      settings: {'url': 'https://example.supabase.co'},
    );
    final services = await createCloudServices(invalid);
    expect(services.provider, isNull);
    expect(services.auth, isNull);
  });

  test('后端自定义校验优先于必填项非空判定', () async {
    final strict = CloudBackend(
      id: 'strict',
      displayName: 'Strict',
      fields: const [
        CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
      ],
      importLegacy: (json) => {'url': json['url']},
      validate: (settings) =>
          (settings['url'] as String?)?.startsWith('https://') ?? false,
    );
    CloudProviderRegistry.register(
      strict,
      (config) async => (provider: null, auth: null),
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
