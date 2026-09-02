/// 恢复矩阵补测：行 19/20。
///
/// - 行 19：Local Fork 后再做本地备份 → 新备份延续 origin_* 溯源
///   （备份 sqlite 的 ledgers 行携带 origin 列，恢复时仍可溯源）；
/// - 行 20：空备份（无账本）→ 打开成功、预览为空、应用为无操作 + 提示；
/// - 行 4 补充：登录 A 场景下选择 Local Fork（不自动重连备份）。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/domain/backup_envelope.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late Directory tmp;
  late Directory backupDir;
  late SesameDatabase liveDb;
  late BackupImportService importService;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('recovery_matrix_');
    backupDir = Directory(p.join(tmp.path, 'backups'));
    liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
    importService = BackupImportService(tempDirOverride: tmp);
  });

  tearDown(() async {
    try {
      await liveDb.close();
    } catch (_) {}
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  /// 生成一个含云端账本的备份源 .snbak。
  Future<(SesameDatabase, File)> seedSource({bool withLedger = true}) async {
    final srcFile = File(
      p.join(tmp.path, 'src_${DateTime.now().microsecondsSinceEpoch}.sqlite'),
    );
    final srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
    final srcService = LocalBackupService(
      backupDir: backupDir,
      databaseFile: srcFile,
    );
    if (withLedger) {
      await srcDb
          .into(srcDb.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: '22222222-2222-4222-8222-222222222222',
              name: '家庭账本',
              storageMode: const d.Value('cloud'),
              syncId: const d.Value('sync-s1'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
    }
    final backup = await srcService.createBackup(
      db: srcDb,
      secrets: BackupSecrets(password: 'pw-123456'),
    );
    return (srcDb, backup);
  }

  test('Local Fork 后再做本地备份，新备份延续 origin_* 溯源', () async {
    final (srcDb, backup) = await seedSource();
    addTearDown(srcDb.close);
    // Fork 目标使用文件库（同一文件随后被再次备份）
    final liveFile = File(p.join(tmp.path, 'live.sqlite'));
    final liveDb2 = SesameDatabase.forTesting(NativeDatabase(liveFile));
    addTearDown(liveDb2.close);
    final session = await importService.openBackup(
      backupFile: backup,
      password: 'pw-123456',
      currentSchemaVersion: liveDb2.schemaVersion,
    );
    final items = await importService.listRecoveryItems(session);
    session.decisions[items.single.ledgerBackupId] =
        RecoveryDecision.forkCloudToLocal;
    await importService.apply(
      session: session,
      liveDb: liveDb2,
      localSelfId: 'self-live',
    );
    await session.close();

    // Fork 出的本地账本
    final fork = await (liveDb2.select(
      liveDb2.ledgers,
    )..where((l) => l.originType.equals('CLOUD_BACKUP'))).getSingle();
    expect(fork.originLedgerId, '22222222-2222-4222-8222-222222222222');
    expect(fork.originSyncId, 'sync-s1');

    // 对含 Fork 账本的同一文件库再做一次本地备份
    final service2 = LocalBackupService(
      backupDir: backupDir,
      databaseFile: liveFile,
    );
    final secondBackup = await service2.createBackup(
      db: liveDb2,
      secrets: BackupSecrets(password: 'pw-123456'),
    );
    expect(secondBackup.path.endsWith('.snbak'), isTrue);

    // 新备份的 sqlite 体里，Fork 账本行延续 origin 溯源
    final envelope = BackupEnvelopeCodec.decode(
      await secondBackup.readAsBytes(),
    );
    final payload = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      password: 'pw-123456',
    );
    final framed = BackupPayloadCodec.decode(payload);
    final sqliteFile = File(p.join(tmp.path, 'second_extract.sqlite'));
    await sqliteFile.writeAsBytes(framed.sqliteBytes);
    final check = sqlite3.open(sqliteFile.path, mode: OpenMode.readOnly);
    final rows = check.select(
      'SELECT origin_type, origin_ledger_id, origin_sync_id, origin_backup_id FROM ledgers WHERE origin_type IS NOT NULL',
    );
    check.close();
    expect(rows, hasLength(1), reason: '行 19：新备份延续 origin_* 溯源');
    expect(
      rows.first['origin_ledger_id'],
      '22222222-2222-4222-8222-222222222222',
    );
    expect(rows.first['origin_sync_id'], 'sync-s1');
    expect(rows.first['origin_backup_id'], isNotNull);
  });

  test('空备份（无账本）→ 打开成功、预览为空、应用为无操作', () async {
    final (srcDb, backup) = await seedSource(withLedger: false);
    addTearDown(srcDb.close);
    final session = await importService.openBackup(
      backupFile: backup,
      password: 'pw-123456',
      currentSchemaVersion: liveDb.schemaVersion,
    );
    expect(session.manifest.ledgers, isEmpty);
    final items = await importService.listRecoveryItems(session);
    expect(items, isEmpty, reason: '空备份无恢复条目');

    // 应用 = 无操作：live DB 零写入、recovery_log 零写入
    final report = await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );
    expect(report.entries, isEmpty);
    expect(await liveDb.select(liveDb.ledgers).get(), isEmpty);
    expect(await liveDb.select(liveDb.recoveryLogs).get(), isEmpty);
    await session.close();
  });

  test('登录 A 场景选择 Local Fork，绝不自动重连备份', () async {
    final (srcDb, backup) = await seedSource();
    addTearDown(srcDb.close);
    final session = await importService.openBackup(
      backupFile: backup,
      password: 'pw-123456',
      currentSchemaVersion: liveDb.schemaVersion,
    );
    final items = await importService.listRecoveryItems(session);
    // 用户显式选择 Fork（即使当前已登录 A，也绝不把备份静默接回云端）
    session.decisions[items.single.ledgerBackupId] =
        RecoveryDecision.forkCloudToLocal;
    final report = await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );
    expect(report.entries.single.decision, RecoveryDecision.forkCloudToLocal);
    final fork = await liveDb.select(liveDb.ledgers).getSingle();
    expect(fork.storageMode, 'local');
    expect(fork.syncId, isNull, reason: '不产生任何活跃同步身份');
    expect(fork.bindingStatus, isNull);
    await session.close();
  });
}
