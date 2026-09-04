/// 恢复流程明文打开测试。
///
/// 需求锚点：
/// - .snbak 为明文分帧文件，任何设备可直接解帧打开；
/// - 恢复页打开备份时直接解帧进入 Step 2；
/// - selectBackup 只改变选中态，不改变步骤；
/// - BackupPayloadCodec 明文分帧往返一致；长度字段损坏抛 corrupt。
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
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

  test('本机 .snbak 明文分帧：直接打开进入 step2', () async {
    final tmp = await Directory.systemTemp.createTemp('plain_open_restore_');
    addTearDown(() => tmp.delete(recursive: true));
    final srcFile = File(p.join(tmp.path, 'src.sqlite'));
    final backupDir = Directory(p.join(tmp.path, 'backups'));
    final extractDir = Directory(p.join(tmp.path, 'extract'));
    await extractDir.create(recursive: true);

    // 源库生成明文分帧 .snbak（备份目录供恢复列表枚举）。
    final srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
    addTearDown(srcDb.close);
    await LocalBackupService(
      backupDir: backupDir,
      databaseFile: srcFile,
    ).createBackup(db: srcDb);

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

    // 明文分帧，直接解帧打开，成功进入 step 2。
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

  test('BackupPayloadCodec：明文分帧往返一致，长度字段损坏抛 corrupt', () {
    final manifestJson = Uint8List.fromList([1, 2, 3, 4]);
    final sqliteBytes = Uint8List.fromList([5, 6, 7, 8, 9]);

    final encoded = BackupPayloadCodec.encode(manifestJson, sqliteBytes);
    final decoded = BackupPayloadCodec.decode(encoded);
    expect(decoded.manifestJson, manifestJson);
    expect(decoded.sqliteBytes, sqliteBytes);

    // 篡改 SQLite 长度字段（越界）→ corrupt
    final tampered = Uint8List.fromList(encoded);
    ByteData.sublistView(tampered).setUint32(4, 0xFFFFFFFF);
    expect(
      () => BackupPayloadCodec.decode(tampered),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.corrupt,
        ),
      ),
    );
  });
}
