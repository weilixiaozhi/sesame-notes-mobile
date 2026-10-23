/// CloudServiceStore 单元测试。
///
/// 覆盖:
/// - 各云端后端配置可存取、可清除,清除后 load 返回 null;
/// - 敏感字段进安全存储,SharedPreferences 中不留凭据;
/// - 清除当前激活后端后 loadActive() 自动回退本地存储;
/// - clearConfig(local) 不影响激活状态;
/// - 只读取当前配置与安全凭据，旧键不参与配置和激活;
/// - 核心不认识任何后端:未注册的第四后端同样能存取。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup/src/config/cloud_credential_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'utils/test_backends.dart';

/// 内存凭据存储：模拟生产安全存储，验证配置与凭据分开存取。
class _MemoryCredentialStorage implements CloudCredentialStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String backendId) async => _data[backendId];

  @override
  Future<void> write(String backendId, String value) async =>
      _data[backendId] = value;

  @override
  Future<void> delete(String backendId) async => _data.remove(backendId);

  String? peek(String backendId) => _data[backendId];
}

CloudServiceConfig _webdavCfg() => const CloudServiceConfig(
      backendId: 'webdav',
      settings: {
        'url': 'https://dav.example.com',
        'username': 'u',
        'password': 'p',
      },
    );

CloudServiceConfig _supabaseCfg() => const CloudServiceConfig(
      backendId: 'supabase',
      settings: {
        'url': 'https://xxx.supabase.co',
        'anonKey': 'anon-key',
        'account': 'backup@example.test',
        'password': 'fixture-password',
      },
    );

CloudServiceConfig _s3Cfg() => const CloudServiceConfig(
      backendId: 's3',
      settings: {
        'endpoint': 's3.example.com',
        'accessKey': 'ak',
        'secretKey': 'sk',
        'bucket': 'bucket',
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    registerTestBackends();
  });

  tearDown(unregisterTestBackends);

  group('仅使用当前配置与安全凭据', () {
    test('只有旧扁平配置时视为未配置，读取和激活均不改写存储', () async {
      final legacyRaw = jsonEncode({
        'webdavUrl': 'https://dav.example.com',
        'webdavUsername': 'u',
        'webdavPassword': 'legacy-pw',
      });
      SharedPreferences.setMockInitialValues({
        'cloud_webdav_cfg': legacyRaw,
        CloudServiceStore.activeTypeKey: 'webdav',
      });
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);

      expect(await store.load('webdav'), isNull);
      await expectLater(store.loadActive(), throwsStateError);
      expect(await store.activate('webdav'), isFalse);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('cloud_webdav_cfg'), legacyRaw);
      expect(sp.getString(CloudServiceStore.configKeyFor('webdav')), isNull);
      expect(sp.getString(CloudServiceStore.activeTypeKey), 'webdav');
      expect(secure.peek('webdav'), isNull);
    });

    test('当前配置只有旧明文凭据时不导入凭据，也不改写存储', () async {
      final configRaw = jsonEncode({
        'backendId': 'webdav',
        'settings': {'url': 'https://dav.example.com', 'username': 'u'},
      });
      final legacyRaw = jsonEncode({'password': 'legacy-pw'});
      SharedPreferences.setMockInitialValues({
        CloudServiceStore.configKeyFor('webdav'): configRaw,
        'cloud_credential_webdav': legacyRaw,
      });
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);

      final loaded = await store.load('webdav');
      expect(loaded, isNotNull);
      expect(loaded!.settings['url'], 'https://dav.example.com');
      expect(loaded.settings['password'], isNull);
      expect(await store.activate('webdav'), isFalse);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString(CloudServiceStore.configKeyFor('webdav')), configRaw);
      expect(sp.getString('cloud_credential_webdav'), legacyRaw);
      expect(sp.getString(CloudServiceStore.activeTypeKey), isNull);
      expect(secure.peek('webdav'), isNull);
    });
  });

  group('clearConfig', () {
    test('清除 WebDAV 配置后 load 返回 null', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_webdavCfg());
      expect(await store.load('webdav'), isNotNull);

      await store.clearConfig('webdav');
      expect(await store.load('webdav'), isNull);
    });

    test('清除 Supabase 配置后 load 返回 null', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_supabaseCfg());
      expect(await store.load('supabase'), isNotNull);

      await store.clearConfig('supabase');
      expect(await store.load('supabase'), isNull);
    });

    test('清除 S3 配置后 load 返回 null', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_s3Cfg());
      expect(await store.load('s3'), isNotNull);

      await store.clearConfig('s3');
      expect(await store.load('s3'), isNull);
    });

    test('清除激活中的后端后 loadActive 自动回退本地存储', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await activateTestCloudConfig(store, _webdavCfg());
      expect((await store.loadActive()).backendId, 'webdav');

      await store.clearConfig('webdav');
      // 配置 key 缺失 → 回退 local
      final active = await store.loadActive();
      expect(active.isLocal, isTrue);
    });

    test('clearConfig(local) 为 no-op', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await activateTestCloudConfig(store, _webdavCfg());

      // 不应抛出,也不影响其他配置与激活状态
      await store.clearConfig(CloudServiceConfig.localBackendId);
      expect(await store.load('webdav'), isNotNull);
      expect((await store.loadActive()).backendId, 'webdav');
    });

    test('清除一个后端不影响其他后端配置', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_webdavCfg());
      await store.saveOnly(_s3Cfg());

      await store.clearConfig('webdav');
      expect(await store.load('webdav'), isNull);
      expect(await store.load('s3'), isNotNull);
    });
  });

  group('敏感字段分存', () {
    test('凭据字段只进安全存储，SharedPreferences 不留密文', () async {
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(_webdavCfg());

      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(CloudServiceStore.configKeyFor('webdav'))!;
      expect(raw, isNot(contains('"password"')));
      expect(jsonDecode(secure.peek('webdav')!), containsPair('password', 'p'));

      // 读回时凭据合并回来，业务无感知。
      expect((await store.load('webdav'))!.settings['password'], 'p');
    });

    test('后端未声明的键不落盘', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(
        const CloudServiceConfig(
          backendId: 'webdav',
          settings: {'url': 'https://dav.example.com', 'stray': 'x'},
        ),
      );
      expect(
          (await store.load('webdav'))!.settings.containsKey('stray'), isFalse);
    });

    test('后端未注册时整份配置进安全存储，绝不明文落盘', () async {
      CloudProviderRegistry.unregister('webdav');
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(_webdavCfg());

      final sp = await SharedPreferences.getInstance();
      expect(
        sp.getString(CloudServiceStore.configKeyFor('webdav')),
        isNot(contains('dav.example.com')),
      );
      expect(jsonDecode(secure.peek('webdav')!), containsPair('password', 'p'));
    });
  });

  group('保存与激活的配置守卫', () {
    test('保存配置不自动激活，完整凭据校验后才切换服务', () async {
      final store = CloudServiceStore(
        credentialStorage: _MemoryCredentialStorage(),
      );
      await store.saveOnly(_webdavCfg());
      expect((await store.loadActive()).isLocal, isTrue);
      expect(await store.activate('webdav'), isTrue);
      expect((await store.loadActive()).settings, _webdavCfg().settings);

      await store.saveOnly(const CloudServiceConfig(
        backendId: 'supabase',
        settings: {'url': 'https://backup.example', 'account': 'backup@test'},
      ));
      expect(await store.activate('supabase'), isFalse);
      expect((await store.loadActive()).backendId, 'webdav');
    });

    test('延迟注册后可读取并激活完整配置，读取不改写原存储', () async {
      CloudProviderRegistry.unregister('webdav');
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(_webdavCfg());
      final originalCredentials = secure.peek('webdav');
      final sp = await SharedPreferences.getInstance();
      final originalConfig =
          sp.getString(CloudServiceStore.configKeyFor('webdav'));
      registerTestBackends();

      expect((await store.load('webdav'))!.settings, _webdavCfg().settings);
      expect(await store.activate('webdav'), isTrue);
      expect((await store.loadActive()).settings, _webdavCfg().settings);
      expect(secure.peek('webdav'), originalCredentials);
      expect(sp.getString(CloudServiceStore.configKeyFor('webdav')),
          originalConfig);
    });

    test('损坏凭据的读取和激活明确失败，保留原文且不推进激活状态', () async {
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(_webdavCfg());
      const damaged = 'secret-original invalid-json';
      await secure.write('webdav', damaged);

      await expectLater(store.load('webdav'), throwsStateError);
      await expectLater(store.activate('webdav'), throwsStateError);
      expect(secure.peek('webdav'), damaged);
      expect((await store.loadActive()).isLocal, isTrue);
    });

    test('配置位置与后端身份不一致时拒绝读取及激活，保留故障原文', () async {
      final invalid = jsonEncode(_s3Cfg().toJson());
      SharedPreferences.setMockInitialValues({
        CloudServiceStore.configKeyFor('webdav'): invalid,
      });
      final store = CloudServiceStore(
        credentialStorage: _MemoryCredentialStorage(),
      );

      await expectLater(store.load('webdav'), throwsStateError);
      await expectLater(store.activate('webdav'), throwsStateError);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString(CloudServiceStore.configKeyFor('webdav')), invalid);
      expect((await store.loadActive()).isLocal, isTrue);
    });

    test('显式修改完整配置更新连接与凭据，敏感内容始终分存', () async {
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await activateTestCloudConfig(store, _webdavCfg());
      const changed = CloudServiceConfig(
        backendId: 'webdav',
        settings: {
          'url': 'https://changed.example.com',
          'username': 'changed-user',
          'password': 'changed-secret',
        },
      );
      await store.saveOnly(changed);

      expect((await store.loadActive()).settings, changed.settings);
      final sp = await SharedPreferences.getInstance();
      final plain = sp.getString(CloudServiceStore.configKeyFor('webdav'))!;
      expect(plain, isNot(contains('changed-secret')));
      expect(
          jsonDecode(secure.peek('webdav')!), {'password': 'changed-secret'});
    });

    test('缺失本机凭据时普通配置可读，激活保持不可用', () async {
      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(const CloudServiceConfig(
        backendId: 's3',
        settings: {'endpoint': 'backup.example', 'bucket': 'backups'},
      ));

      final saved = await store.load('s3');
      expect(
          saved!.settings, {'endpoint': 'backup.example', 'bucket': 'backups'});
      expect(await store.activate('s3'), isFalse);
      expect((await store.loadActive()).isLocal, isTrue);
      expect(jsonDecode(secure.peek('s3')!), isEmpty);
    });
  });

  group('后端开放性', () {
    test('未内置于核心的第四后端：注册即可存取，核心无需改动', () async {
      const backend = CloudBackend(
        id: 'oss',
        displayName: 'Aliyun OSS',
        fields: [
          CloudConfigField(key: 'endpoint', labelKey: 'e', isRequired: true),
          CloudConfigField(
            key: 'token',
            labelKey: 't',
            kind: CloudConfigFieldKind.secret,
            isRequired: true,
          ),
        ],
      );
      CloudProviderRegistry.register(
        backend,
        (config) async => null,
      );
      addTearDown(() => CloudProviderRegistry.unregister('oss'));

      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      const cfg = CloudServiceConfig(
        backendId: 'oss',
        settings: {'endpoint': 'oss-cn-hz.aliyuncs.com', 'token': 'tk'},
      );
      await activateTestCloudConfig(store, cfg);

      expect(CloudProviderRegistry.isConfigValid(cfg), isTrue);
      expect((await store.loadActive()).settings['token'], 'tk');
      expect(CloudProviderRegistry.backends.map((b) => b.id), contains('oss'));
    });

    test('未注册后端的配置判定为不可用', () {
      CloudProviderRegistry.unregister('s3');
      expect(CloudProviderRegistry.isConfigValid(_s3Cfg()), isFalse);
    });
  });
}
