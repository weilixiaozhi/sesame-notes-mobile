/// CloudServiceStore 单元测试。
///
/// 覆盖:
/// - 各云端后端配置可存取、可清除,清除后 load 返回 null;
/// - 敏感字段进安全存储,SharedPreferences 中不留凭据;
/// - 清除当前激活后端后 loadActive() 自动回退本地存储;
/// - clearConfig(local) 不影响激活状态;
/// - 旧版扁平配置(v1)读取时经后端描述符迁移为 v2;
/// - 核心不认识任何后端:未注册的第四后端同样能存取。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup/src/config/cloud_credential_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'utils/test_backends.dart';

/// 内存凭据存储：模拟生产安全存储，用于验证明文键迁移与清理。
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
      // saveAndActivate 同时写入配置并激活
      await store.saveAndActivate(_webdavCfg());
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
      await store.saveAndActivate(_webdavCfg());

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

  group('saveImported 凭据合并', () {
    test('脱敏占位符不会覆盖本机 WebDAV 密码', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_webdavCfg()); // 本机密码 'p'

      await store.saveImported(
        const CloudServiceConfig(
          backendId: 'webdav',
          settings: {
            'url': 'https://dav.example.com',
            'username': 'u',
            'password': '***',
          },
        ),
      );

      expect((await store.load('webdav'))!.settings['password'], 'p');
    });

    test('外部配置携带真实凭据也保留本机 WebDAV 密码', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveOnly(_webdavCfg());

      await store.saveImported(
        const CloudServiceConfig(
          backendId: 'webdav',
          settings: {
            'url': 'https://dav.example.com',
            'username': 'u',
            'password': 'new-password',
          },
        ),
      );

      expect((await store.load('webdav'))!.settings['password'], 'p');
    });

    test('导入的配置不落盘未在本机存在的凭据字段', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await store.saveImported(_supabaseCfg());

      final loaded = await store.load('supabase');
      expect(loaded, isNotNull);
      expect(loaded!.settings['anonKey'], isNull);
      expect(loaded.settings['url'], 'https://xxx.supabase.co');
    });
  });

  group('明文凭证迁移与清理', () {
    test('读取时自动把 cloud_credential_* 明文搬进安全存储并删除明文键', () async {
      SharedPreferences.setMockInitialValues({
        CloudServiceStore.configKeyFor('webdav'): jsonEncode({
          'backendId': 'webdav',
          'settings': {
            'url': 'https://dav.example.com',
            'username': 'u',
          },
        }),
        'cloud_credential_webdav': jsonEncode({
          'password': 'legacy-pw',
        }),
      });

      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      final loaded = await store.load('webdav');

      // 旧明文凭据被合并回配置，业务无感知。
      expect(loaded, isNotNull);
      expect(loaded!.settings['password'], 'legacy-pw');
      // 明文键已被删除，凭据只存在于（模拟的）安全存储中。
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('cloud_credential_webdav'), isNull);
      expect(secure.peek('webdav'), isNotNull);
    });

    test('saveOnly 写入后不残留明文凭证键', () async {
      SharedPreferences.setMockInitialValues({
        'cloud_credential_webdav': jsonEncode({
          'password': 'stale',
        }),
      });

      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      await store.saveOnly(_webdavCfg());

      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('cloud_credential_webdav'), isNull);
      expect(secure.peek('webdav'), isNotNull);
      expect((await store.load('webdav'))!.settings['password'], 'p');
    });
  });

  group('旧版扁平配置迁移', () {
    test('v1 配置读取时迁移为 v2 并删除旧键', () async {
      SharedPreferences.setMockInitialValues({
        'cloud_webdav_cfg': jsonEncode({
          'type': 'webdav',
          'name': 'WebDAV',
          'webdavUrl': 'https://dav.example.com',
          'webdavUsername': 'u',
          'webdavPassword': 'legacy-pw',
          'webdavRemotePath': '/backup',
        }),
        CloudServiceStore.activeTypeKey: 'webdav',
      });

      final secure = _MemoryCredentialStorage();
      final store = CloudServiceStore(credentialStorage: secure);
      final loaded = await store.loadActive();

      expect(loaded.backendId, 'webdav');
      expect(loaded.settings['url'], 'https://dav.example.com');
      expect(loaded.settings['remotePath'], '/backup');
      // 迁移后凭据进安全存储，旧键不再保留明文。
      expect(jsonDecode(secure.peek('webdav')!),
          containsPair('password', 'legacy-pw'));

      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('cloud_webdav_cfg'), isNull);
      expect(
        sp.getString(CloudServiceStore.configKeyFor('webdav')),
        isNot(contains('legacy-pw')),
      );
    });

    test('后端未注册时旧版配置不迁移且按未配置处理', () async {
      CloudProviderRegistry.unregister('webdav');
      SharedPreferences.setMockInitialValues({
        'cloud_webdav_cfg': jsonEncode({
          'webdavUrl': 'https://dav.example.com',
          'webdavPassword': 'legacy-pw',
        }),
      });

      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      expect(await store.load('webdav'), isNull);
    });
  });

  group('后端开放性', () {
    test('未内置于核心的第四后端：注册即可存取，核心无需改动', () async {
      final backend = CloudBackend(
        id: 'oss',
        displayName: 'Aliyun OSS',
        fields: const [
          CloudConfigField(key: 'endpoint', labelKey: 'e', isRequired: true),
          CloudConfigField(
            key: 'token',
            labelKey: 't',
            kind: CloudConfigFieldKind.secret,
            isRequired: true,
          ),
        ],
        importLegacy: (json) => {'endpoint': json['ossEndpoint']},
      );
      CloudProviderRegistry.register(
        backend,
        (config) async => (provider: null, auth: null),
      );
      addTearDown(() => CloudProviderRegistry.unregister('oss'));

      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      const cfg = CloudServiceConfig(
        backendId: 'oss',
        settings: {'endpoint': 'oss-cn-hz.aliyuncs.com', 'token': 'tk'},
      );
      await store.saveAndActivate(cfg);

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
