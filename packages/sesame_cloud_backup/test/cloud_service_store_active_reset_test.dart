/// 清理当前云服务配置时复位激活标记，清理其他配置保留原选择。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup/src/config/cloud_credential_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/test_backends.dart';

const _kActiveTypeKey = 'cloud_active_type';

CloudServiceConfig _webdavCfg() => const CloudServiceConfig(
      backendId: 'webdav',
      settings: {
        'url': 'https://dav.example.com',
        'username': 'u',
        'password': 'p',
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    registerTestBackends();
  });

  tearDown(unregisterTestBackends);

  group('clearConfig 激活标记复位', () {
    test('清除当前激活的云配置后 _kActiveType 复位为 local(僵尸脏值被清理)', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await activateTestCloudConfig(store, _webdavCfg());
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString(_kActiveTypeKey), 'webdav');

      await store.clearConfig('webdav');

      // 直接检查持久化标记:清掉激活的云配置后必须复位 local
      expect(sp.getString(_kActiveTypeKey), 'local',
          reason: '清掉激活的云配置后 _kActiveType 不得残留僵尸脏值(如 webdav)');
      expect((await store.loadActive()).isLocal, isTrue);
    });

    test('清除非激活配置不影响现有激活状态(回归保护)', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await activateTestCloudConfig(store, _webdavCfg());

      // 清一个非激活的 supabase 配置:不得误伤当前激活的 webdav
      await store.clearConfig('supabase');

      expect((await store.loadActive()).backendId, 'webdav',
          reason: '清非激活配置不得改变现有激活状态');
      expect(await store.load('supabase'), isNull);
      expect(await store.load('webdav'), isNotNull);
    });

    test('clearConfig(local) 为 no-op,不影响激活状态', () async {
      final store = CloudServiceStore(
        credentialStorage: SharedPreferencesCredentialStorage(),
      );
      await activateTestCloudConfig(store, _webdavCfg());

      await store.clearConfig(CloudServiceConfig.localBackendId);

      expect((await store.loadActive()).backendId, 'webdav');
      expect(await store.load('webdav'), isNotNull);
    });
  });
}
