import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import '../helpers/cloud_service_fixture.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// 在真实偏好插件边界拒绝提交，验证返回 false 后的缓存与持久化状态。
class _FailingPreferencesStore extends InMemorySharedPreferencesStore {
  /// 初始数据遵循插件的平台键前缀。
  _FailingPreferencesStore() : super.withData({});

  String? rejectedKey;

  /// 未被拒绝的键沿用插件内存实现，拒绝的写入不改变持久层。
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == 'flutter.$rejectedKey') return false;
    return super.setValue(valueType, key, value);
  }

  /// 模拟删除提交被拒绝，原配置应仍可读取。
  @override
  Future<bool> remove(String key) async {
    if (key == 'flutter.$rejectedKey') return false;
    return super.remove(key);
  }
}

/// 与偏好存储分离的凭据替身，用于核对配置失败时保留的凭据内容。
class _CredentialStorage implements CloudCredentialStorage {
  final values = <String, String>{};

  /// 返回独立安全存储中的原始凭据。
  @override
  Future<String?> read(String backendId) async => values[backendId];

  /// 保存实际凭据内容，避免与普通配置偏好混在同一存储中。
  @override
  Future<void> write(String backendId, String value) async {
    values[backendId] = value;
  }

  /// 删除指定后端的独立凭据。
  @override
  Future<void> delete(String backendId) async => values.remove(backendId);
}

const _config = CloudServiceConfig(
  backendId: 'test-backup',
  settings: {'url': 'https://backup.example', 'password': 'existing-secret'},
);

/// 配置提交必须核对平台结果，测试不连接真实云端或读取用户偏好。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FailingPreferencesStore platform;
  late _CredentialStorage credentials;
  late CloudServiceStore store;

  setUp(() {
    final original = SharedPreferencesStorePlatform.instance;
    SharedPreferences.resetStatic();
    platform = _FailingPreferencesStore();
    SharedPreferencesStorePlatform.instance = platform;
    credentials = _CredentialStorage();
    store = CloudServiceStore(credentialStorage: credentials);
    CloudProviderRegistry.register(
      const CloudBackend(
        id: 'test-backup',
        displayName: 'Test backup',
        fields: [
          CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
          CloudConfigField(
            key: 'password',
            labelKey: 'password',
            kind: CloudConfigFieldKind.secret,
            isRequired: true,
          ),
        ],
      ),
      (_) async => null,
    );
    addTearDown(() {
      CloudProviderRegistry.unregister('test-backup');
      SharedPreferencesStorePlatform.instance = original;
      SharedPreferences.resetStatic();
    });
  });

  test('激活写入失败不能返回成功，当前缓存与重新加载都保留原选择', () async {
    await store.saveOnly(_config);
    platform.rejectedKey = CloudServiceStore.activeTypeKey;
    await expectLater(store.activate('test-backup'), throwsStateError);
    expect((await store.loadActive()).isLocal, isTrue);
    SharedPreferences.resetStatic();
    expect((await store.loadActive()).isLocal, isTrue);
  });

  test('切回本地提交失败仍保留已激活的云配置', () async {
    await activateTestCloudConfig(store, _config);
    platform.rejectedKey = CloudServiceStore.activeTypeKey;
    await expectLater(store.activate('local'), throwsStateError);
    expect((await store.loadActive()).backendId, 'test-backup');
    SharedPreferences.resetStatic();
    expect((await store.loadActive()).backendId, 'test-backup');
  });

  test('配置落盘失败不推进激活标记，也不保留虚假的内存配置', () async {
    platform.rejectedKey = CloudServiceStore.configKeyFor('test-backup');
    await expectLater(store.saveOnly(_config), throwsStateError);
    expect(await store.load('test-backup'), isNull);
    expect(await store.activate('test-backup'), isFalse);
    expect((await store.loadActive()).isLocal, isTrue);
    SharedPreferences.resetStatic();
    expect(await store.load('test-backup'), isNull);
    expect((await store.loadActive()).isLocal, isTrue);
  });

  test('修改连接位置保存失败保留原配置和既有凭据，不能假报成功', () async {
    await activateTestCloudConfig(store, _config);
    final originalCredentials = credentials.values['test-backup'];
    platform.rejectedKey = CloudServiceStore.configKeyFor('test-backup');
    await expectLater(
      store.saveOnly(
        CloudServiceConfig(
          backendId: 'test-backup',
          settings: {..._config.settings, 'url': 'https://changed.example'},
        ),
      ),
      throwsStateError,
    );
    expect((await store.loadActive()).settings, _config.settings);
    expect(credentials.values['test-backup'], originalCredentials);
    expect(jsonDecode(credentials.values['test-backup']!), {
      'password': 'existing-secret',
    });
    SharedPreferences.resetStatic();
    expect((await store.loadActive()).settings, _config.settings);
  });

  test('清除配置提交失败不删除凭据或切换激活状态', () async {
    await activateTestCloudConfig(store, _config);
    platform.rejectedKey = CloudServiceStore.configKeyFor('test-backup');
    await expectLater(store.clearConfig('test-backup'), throwsStateError);
    expect((await store.loadActive()).settings, _config.settings);
    SharedPreferences.resetStatic();
    expect((await store.loadActive()).settings, _config.settings);
  });
}
