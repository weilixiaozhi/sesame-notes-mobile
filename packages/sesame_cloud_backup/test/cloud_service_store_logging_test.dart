import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 验证配置解析异常不把原始 JSON 中的凭据写入插件日志。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('配置解析失败时日志不能泄漏原始凭据和备份正文', () async {
    SharedPreferences.setMockInitialValues({
      'cloud_active_type': 'webdav',
      'cloud_cfg_webdav': 'password-secret backup-plaintext invalid-json',
    });
    final messages = <String>[];
    final store = CloudServiceStore(
      logger: CloudSyncLogger(onLog: (_, message) {
        messages.add(message);
      }),
    );

    await expectLater(store.loadActive(), throwsStateError);
    expect(messages, isNotEmpty);
    expect(messages.join('\n'), isNot(contains('password-secret')));
    expect(messages.join('\n'), isNot(contains('backup-plaintext')));
  });
}
