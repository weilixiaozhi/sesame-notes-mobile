import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';

/// 成功状态必须对应当前启用且可用的备份服务。
void main() {
  CloudBackupOverview overview({String? succeeded, bool valid = true}) =>
      CloudBackupOverview(
        active: CloudBackupSelection(
          backendId: 'webdav',
          settings: const {},
          isValid: valid,
        ),
        backends: const [],
        lastSuccessAt: DateTime.utc(2026, 10, 22),
        lastSuccessProvider: succeeded,
      );

  test('切换到新服务后，其他服务的成功记录不能显示当前已备份', () {
    expect(
      cloudBackupStatusOf(overview(succeeded: 's3')),
      CloudBackupStatusKind.activeNoSuccess,
    );
    expect(
      cloudBackupStatusOf(overview(succeeded: 'webdav')),
      CloudBackupStatusKind.success,
    );
  });

  test('配置不可用时即使当前服务曾成功也必须提示失败', () {
    expect(
      cloudBackupStatusOf(overview(succeeded: 'webdav', valid: false)),
      CloudBackupStatusKind.failed,
    );
  });
}
