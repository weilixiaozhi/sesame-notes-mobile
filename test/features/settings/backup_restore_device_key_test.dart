/// 恢复流程设备密钥测试。
///
/// 需求锚点：
/// - 本机备份统一用设备密钥（localSelfId 派生）加密（DEVICE_LOCAL slot）；
/// - 恢复页打开备份时自动用本机设备密钥解密；
/// - 设备密钥不匹配（其他设备）→ 打开失败。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/identity/local_user_identity.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
  });

  test('设备密钥加密的本机备份：自动用本机设备密钥打开', () async {
    final tmp = await Directory.systemTemp.createTemp('device_key_restore_');
    addTearDown(() => tmp.delete(recursive: true));
    final srcFile = File(p.join(tmp.path, 'src.sqlite'));
    final backupDir = Directory(p.join(tmp.path, 'backups'));
    final extractDir = Directory(p.join(tmp.path, 'extract'));
    await extractDir.create(recursive: true);

    // 源库 + 设备密钥（与恢复方同一 localSelfId）生成 .snbak
    final srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
    addTearDown(srcDb.close);
    final localSelfId = await LocalSelfId.getOrCreate();
    // 生成设备密钥加密的 .snbak（备份目录供恢复列表枚举）。
    await LocalBackupService(
      backupDir: backupDir,
      databaseFile: srcFile,
    ).createBackup(
      db: srcDb,
      secrets: BackupSecrets(
        deviceKey: BackupCrypto.deviceKeyFromLocalSelfId(localSelfId),
      ),
    );

    final liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(liveDb.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(liveDb),
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(
            backupService: LocalBackupService(
              backupDir: backupDir,
              databaseFile: File(p.join(tmp.path, 'live.sqlite')),
            ),
            importService: BackupImportService(tempDirOverride: extractDir),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(backupRestoreFlowProvider.notifier);
    await notifier.loadBackups();
    final item = notifier.state.backups.single;

    // 设备密钥由 localSelfId 派生，打开时自动解密，应成功进入 step 2。
    await notifier.openBackup(file: item);
    expect(notifier.state.step, 2);
    expect(notifier.state.error, RestoreFlowError.none);
    // 关闭会话释放提取的临时文件，tearDown 才能删除临时目录。
    await notifier.back();
  });

  test('点选备份：selectBackup 只改选中态，不打开', () async {
    final tmp = await Directory.systemTemp.createTemp('select_backup_');
    addTearDown(() => tmp.delete(recursive: true));
    final backupDir = Directory(p.join(tmp.path, 'backups'));
    await backupDir.create(recursive: true);
    final file = File(
      p.join(backupDir.path, 'sesame_notes_20260801_120000.snbak'),
    );
    await file.writeAsBytes([1, 2, 3]);

    final container = ProviderContainer(
      overrides: [
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(
            backupService: LocalBackupService(backupDir: backupDir),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(backupRestoreFlowProvider.notifier);
    await notifier.loadBackups();
    final item = notifier.state.backups.single;

    notifier.selectBackup(item);
    expect(notifier.state.selected?.pathKey, item.pathKey);
    expect(notifier.state.step, 1, reason: '点选不改变步骤');
  });
}
