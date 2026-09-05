/// 手动立即备份编排（performManualBackup）测试。
///
/// 需求锚点：
/// - 本机备份页「立即备份」与备份同步区块「立即上传」共用本编排：
///   本地 .snbak 快照 + 云端上传（未配置第三方时 no-op）+ 成功记录；
/// - 成功写入 backup_state 单例行（lastSuccessAt + currentProvider）与
///   当天去重标记（last_backup_date）。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 内存版设备 id 存储（替代安全存储平台通道）。
class _MemoryDeviceIdStore implements DeviceIdStore {
  String? _value;
  @override
  Future<String?> read() async => _value;
  @override
  Future<void> write(String id) async => _value = id;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'performManualBackup：生成 .snbak 快照并记录成功状态',
    () async {
      SharedPreferences.setMockInitialValues({});
      final tmp = await Directory.systemTemp.createTemp('manual_bk_');
      addTearDown(() => tmp.delete(recursive: true));
      final dbFile = File(p.join(tmp.path, 'live.sqlite'));
      final db = SesameDatabase.forTesting(NativeDatabase(dbFile));
      addTearDown(db.close);
      final backupDir = Directory(p.join(tmp.path, 'backups'));
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          deviceIdentityProvider.overrideWithValue(
            DeviceIdentity(_MemoryDeviceIdStore()),
          ),
          localBackupServiceProvider.overrideWithValue(
            LocalBackupService(backupDir: backupDir, databaseFile: dbFile),
          ),
        ],
      );
      addTearDown(container.dispose);

      await performManualBackup(read: container.read);

      // 备份文件落盘
      expect(
        backupDir.listSync().whereType<File>().where(
          (f) => f.path.endsWith(LocalBackupService.backupExtension),
        ),
        isNotEmpty,
      );
      // 成功状态落库（未配置第三方时 currentProvider 为 null）
      final row = await (db.select(
        db.backupState,
      )..where((b) => b.id.equals(0))).getSingleOrNull();
      expect(row?.lastSuccessAt, isNotNull);
      // 当天去重标记
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(LocalBackupService.prefsKeyLastBackupDate),
        LocalBackupService.todayString(),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('auto_sync 关闭时自动路径跳过云端上传（手动上传不受开关限制）', () async {
    SharedPreferences.setMockInitialValues({
      LocalBackupService.prefsKeyAutoSync: false,
    });
    // 非 .snbak 文件:开关关闭时应直接返回,连文件校验都不触发。
    final fake = File('fake.txt');
    await uploadBackupFileIfAutoSyncEnabled(fake);
    // 开关打开时同样的文件应抛「仅允许上传 .snbak」。
    SharedPreferences.setMockInitialValues({});
    await expectLater(
      () => uploadBackupFileIfAutoSyncEnabled(fake),
      throwsStateError,
    );
  });
}
