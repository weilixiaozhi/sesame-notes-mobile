import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 验证配置解析异常不把原始 JSON 中的凭据写入插件日志。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('配置故障仅记录一次上下文与异常类型', () async {
    SharedPreferences.setMockInitialValues({
      'cloud_active_type': 'webdav',
      'cloud_cfg_webdav': 'password-secret backup-plaintext invalid-json',
    });
    final messages = <String>[];
    final store = CloudServiceStore(
      logger: CloudSyncLogger(onLog: (level, message) {
        expect(level.name, 'warning');
        messages.add(message);
      }),
    );

    await expectLater(store.loadActive(), throwsStateError);
    expect(messages, hasLength(1));
    expect(messages.single, contains('webdav'));
    expect(messages.single, contains('配置'));
    expect(messages.single, contains('FormatException'));
    expect(messages.single, isNot(contains('password-secret')));
    expect(messages.single, isNot(contains('backup-plaintext')));
  });
}
