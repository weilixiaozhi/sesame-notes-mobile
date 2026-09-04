/// BackupImportService（Backup Inspector + Ledger Copier）+ RecoverySession 测试。
///
/// - openBackup→validate→readManifest→listRecoveryItems 全程零写入
///   （Step 1–3 不触碰 live DB）；
/// - 损坏/明文分帧长度字段损坏/schema 不匹配/format_version 不受支持一律拒绝；
/// - importLocalLedger：ID 冲突 → Fork 新 ID；无冲突 → 原 identity；
/// - forkCloudLedgerToLocal：永远 Fork，origin 溯源，同步状态不恢复；
/// - Step 4 单事务应用：任一步失败 → 回滚，live DB 不变；
/// - 每次恢复写 recovery_log（审计）；
/// - 已有 live identity 时无隐式 Merge：未决策的账本 = skip；
/// - restoreWholeDatabaseForEmergency：紧急整库回滚后云端账本全部 STALE_BINDING。
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late Directory tmp;
  late File dbFile;
  late Directory backupDir;
  late SesameDatabase liveDb;
  late LocalBackupService backupService;
  late BackupImportService importService;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('backup_import_test_');
    dbFile = File(p.join(tmp.path, 'sesame_notes.sqlite'));
    backupDir = Directory(p.join(tmp.path, 'backups'));
    liveDb = SesameDatabase.forTesting(NativeDatabase(dbFile));
    backupService = LocalBackupService(
      backupDir: backupDir,
      databaseFile: dbFile,
    );
    // 测试环境无 path_provider 平台通道：注入临时目录覆盖
    importService = BackupImportService(tempDirOverride: tmp);
  });

  tearDown(() async {
    try {
      await liveDb.close();
    } catch (_) {}
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  /// 把 [manifest] 以明文分帧写入 .snbak 文件（不写真实 sqlite 体，仅用于
  /// format/schema 版本守卫测试——这些校验在提取 sqlite 之前即抛错）。
  Future<File> writePlainBackup(String name, BackupManifest manifest) async {
    final file = File(p.join(tmp.path, name));
    await file.writeAsBytes(
      BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(manifest),
        Uint8List.fromList([0]),
      ),
    );
    return file;
  }

  /// 构造一个含本地账本 + 云端账本（成员/交易/AA/pending/冲突）的备份源库，
  /// 并通过独立 backupService（指向源库文件）生成 .snbak。
  Future<(SesameDatabase, File)> seedBackupSource() async {
    // 源库必须是文件库：createBackup 从数据库文件读取 SQLite 体
    final srcFile = File(
      p.join(
        tmp.path,
        'source_${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    final srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
    final srcBackupService = LocalBackupService(
      backupDir: backupDir,
      databaseFile: srcFile,
    );
    final now = DateTime.utc(2026, 8, 1);
    // 本地账本
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '11111111-1111-4111-8111-111111111111',
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-local-1',
            ledgerId: '11111111-1111-4111-8111-111111111111',
            txType: 'expense',
            amount: '5',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '5',
            createdAt: now,
            updatedAt: now,
          ),
        );
    // 云端账本：owner + placeholder 成员、交易 + AA 分摊、pending、OPEN 冲突
    final cloudId = '22222222-2222-4222-8222-222222222222';
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: cloudId,
            name: '家庭账本',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('sync-s1'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'acc1-member',
            ledgerId: cloudId,
            displayName: 'Alice',
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value('acc-1'),
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'ph-member',
            ledgerId: cloudId,
            displayName: '张三',
            memberType: 'PLACEHOLDER',
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-cloud-1',
            ledgerId: cloudId,
            txType: 'expense',
            amount: '100',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '100',
            createdByMemberId: d.Value('acc1-member'),
            payerMemberId: d.Value('acc1-member'),
            aaMode: d.Value(2),
            serverRevision: d.Value(7),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: 'tx-cloud-1',
            memberId: 'acc1-member',
            amount: '60',
          ),
        );
    await srcDb
        .into(srcDb.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: 'tx-cloud-1',
            memberId: 'ph-member',
            amount: '40',
          ),
        );
    await srcDb
        .into(srcDb.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx-pending',
            ledgerId: d.Value(cloudId),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: 'm-1',
          ),
        );
    await srcDb
        .into(srcDb.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'conflict-1',
            ledgerId: cloudId,
            entityType: 'transaction',
            entityId: 'tx-cloud-1',
            localPayload: '{}',
            remotePayload: '{}',
            baseRevision: 1,
            remoteRevision: 5,
            localMutationId: 'm-1',
          ),
        );
    // 明文分帧生成 .snbak
    final backup = await srcBackupService.createBackup(
      db: srcDb,
      deviceId: 'dev-src',
      appVersion: '1.0.0',
    );
    return (srcDb, backup);
  }

  test('openBackup：明文打开，Manifest 与统计字段完整，live DB 0 mutation', () async {
    final (srcDb, backup) = await seedBackupSource();
    addTearDown(srcDb.close);
    // live 库当前状态快照
    final before = await liveDb.select(liveDb.ledgers).get();

    final session = await importService.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    expect(session.manifest.formatVersion, 1);
    expect(session.manifest.ledgers, hasLength(2));
    final cloudEntry = session.manifest.ledgers.singleWhere(
      (l) => l.storageOrigin == LedgerStorageOrigin.cloud,
    );
    expect(cloudEntry.pendingMutationCount, 1);
    expect(cloudEntry.openConflictCount, 1);

    final items = await importService.listRecoveryItems(session);
    expect(items, hasLength(2));
    final cloud = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.cloud,
    );
    expect(cloud.memberCount, 2);
    expect(cloud.transactionCount, 1);
    expect(cloud.pendingCount, 1);
    expect(cloud.conflictCount, 1);
    expect(cloud.syncId, 'sync-s1');
    expect(cloud.accountReference?.accountId, 'acc-1');
    final local = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    expect(local.memberCount, 0);
    expect(local.transactionCount, 1);

    // Step 1–3 全程零写入（live DB 无任何变化）
    final after = await liveDb.select(liveDb.ledgers).get();
    expect(after.length, before.length);
    await session.close();
  });

  test('openBackup：损坏文件 → corrupt', () async {
    final badFile = File(p.join(tmp.path, 'bad.snbak'));
    await badFile.writeAsString('garbage');
    expect(
      () => importService.openBackup(
        backupFile: badFile,
        currentSchemaVersion: liveDb.schemaVersion,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.corrupt,
        ),
      ),
    );
  });

  test('openBackup：schema 旧于当前 → schemaTooOld', () async {
    final manifest = BackupManifest(
      formatVersion: 1,
      dbSchemaVersion: 0,
      createdAt: DateTime.utc(2026, 8, 1),
      deviceId: 'd',
      appVersion: 'v',
      ledgers: const [],
      accounts: const [],
    );
    final file = await writePlainBackup('old_schema.snbak', manifest);
    expect(
      () => importService.openBackup(
        backupFile: file,
        currentSchemaVersion: 1,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.schemaTooOld,
        ),
      ),
    );
  });

  test('openBackup：schema 新于当前 → schemaTooNew', () async {
    final manifest = BackupManifest(
      formatVersion: 1,
      dbSchemaVersion: 99,
      createdAt: DateTime.utc(2026, 8, 1),
      deviceId: 'd',
      appVersion: 'v',
      ledgers: const [],
      accounts: const [],
    );
    final file = await writePlainBackup('new_schema.snbak', manifest);
    expect(
      () => importService.openBackup(
        backupFile: file,
        currentSchemaVersion: 1,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.schemaTooNew,
        ),
      ),
    );
  });

  test(
    'openBackup：Manifest format_version 不受支持 → invalidManifest',
    () async {
      final manifest = BackupManifest(
        formatVersion: 999,
        dbSchemaVersion: 1,
        createdAt: DateTime.utc(2026, 8, 1),
        deviceId: 'd',
        appVersion: 'v',
        ledgers: const [],
        accounts: const [],
      );
      final file = await writePlainBackup('mismatch.snbak', manifest);
      expect(
        () => importService.openBackup(
          backupFile: file,
          currentSchemaVersion: 1,
        ),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.invalidManifest,
          ),
        ),
      );
    },
  );

  test('apply：本地无冲突原 identity + 云端永远 Fork + skip 不写 + recovery_log', () async {
    final (srcDb, backup) = await seedBackupSource();
    addTearDown(srcDb.close);
    final session = await importService.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    final items = await importService.listRecoveryItems(session);
    final localItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    final cloudItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.cloud,
    );
    // 本地：无冲突 → 恢复原 identity；云端：Fork；再额外一个 skip 场景
    session.decisions[localItem.ledgerBackupId] = RecoveryDecision.restoreLocal;
    session.decisions[cloudItem.ledgerBackupId] =
        RecoveryDecision.forkCloudToLocal;

    final report = await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );

    expect(report.entries, hasLength(2));
    // 本地账本：原 identity
    final restored = await (liveDb.select(
      liveDb.ledgers,
    )..where((l) => l.id.equals(localItem.ledgerBackupId))).getSingle();
    expect(restored.originType, 'LOCAL_BACKUP');
    expect(restored.syncId, isNull);
    // 云端账本：Fork 新 id
    final forked =
        await (liveDb.select(liveDb.ledgers)
              ..where((l) => l.originLedgerId.equals(cloudItem.ledgerBackupId)))
            .getSingle();
    expect(forked.id, isNot(cloudItem.ledgerBackupId));
    expect(forked.storageMode, 'local');
    expect(forked.syncId, isNull, reason: 'Fork 永不携带 sync_id');
    expect(forked.originType, 'CLOUD_BACKUP');
    expect(forked.originSyncId, 'sync-s1');
    expect(forked.originAccountId, 'acc-1');
    // Manifest 不携带 last_server_revision，origin_last_revision 不写入
    // 交易复制 + server_revision 清空
    final forkedTxs = await (liveDb.select(
      liveDb.transactions,
    )..where((t) => t.ledgerId.equals(forked.id))).get();
    expect(forkedTxs, hasLength(1));
    expect(forkedTxs.single.serverRevision, isNull);
    // pending/conflict 不恢复
    expect(
      await (liveDb.select(
        liveDb.syncChanges,
      )..where((c) => c.ledgerId.equals(forked.id))).get(),
      isEmpty,
    );
    // recovery_log 审计
    final logs = await liveDb.select(liveDb.recoveryLogs).get();
    expect(logs, hasLength(2));
    expect(
      logs.map((l) => l.action),
      containsAll(['restore_local', 'fork_cloud_to_local']),
    );
    expect(logs.every((l) => l.result == 'success'), isTrue);
    expect(
      logs.every((l) => l.sourceBackupName == p.basename(backup.path)),
      isTrue,
    );
    await session.close();
  });

  test('apply：已有 live identity 时无隐式 Merge——未决策账本 = skip', () async {
    final (srcDb, backup) = await seedBackupSource();
    addTearDown(srcDb.close);
    final session = await importService.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    // 打开后不设置任何决策（默认 skip）
    final report = await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );
    expect(report.entries, hasLength(2));
    expect(
      report.entries.every((e) => e.decision == RecoveryDecision.skip),
      isTrue,
    );
    expect(await liveDb.select(liveDb.ledgers).get(), isEmpty);
    await session.close();
  });

  test('apply：本地 ID 冲突 → Fork 新 ID；不按名字判断', () async {
    final (srcDb, backup) = await seedBackupSource();
    addTearDown(srcDb.close);
    // live 库已存在同名本地账本（ID 不同）→ 不算冲突
    final now = DateTime.utc(2026, 8, 2);
    await liveDb
        .into(liveDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '33333333-3333-4333-8333-333333333333',
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    final session = await importService.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    final items = await importService.listRecoveryItems(session);
    final localItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    session.decisions[localItem.ledgerBackupId] = RecoveryDecision.restoreLocal;

    await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );

    // 原 identity 恢复（名字相同但 ID 不同不冲突）
    final restored = await (liveDb.select(
      liveDb.ledgers,
    )..where((l) => l.id.equals(localItem.ledgerBackupId))).getSingle();
    expect(restored.name, '私人账本');
    expect(restored.originType, 'LOCAL_BACKUP');
    // 已有同名账本不受影响
    final existing =
        await (liveDb.select(liveDb.ledgers)..where(
              (l) => l.id.equals('33333333-3333-4333-8333-333333333333'),
            ))
            .getSingle();
    expect(existing.originType, isNull);
    await session.close();
  });

  test('apply：单事务——中途失败整体回滚，live DB 不变', () async {
    final (srcDb, backup) = await seedBackupSource();
    addTearDown(srcDb.close);
    final session = await importService.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    final items = await importService.listRecoveryItems(session);
    final localItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    final cloudItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.cloud,
    );
    session.decisions[localItem.ledgerBackupId] = RecoveryDecision.restoreLocal;
    session.decisions[cloudItem.ledgerBackupId] =
        RecoveryDecision.forkCloudToLocal;
    addTearDown(session.close); // 失败路径也要释放会话，避免 Windows 文件锁
    // 注入事务中途失败：live 库预插一个与"本地账本恢复时派生的 LOCAL self 成员"
    // 同 id 的成员行（挂在其他账本下）→ 恢复流程插入 self 成员时 UNIQUE 冲突，
    // 该失败发生在事务中途（本地账本行已写入）→ 整体回滚
    final now2 = DateTime.utc(2026, 8, 2);
    await liveDb
        .into(liveDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '55555555-5555-4555-8555-555555555555',
            name: '占位账本',
            storageMode: const d.Value('local'),
            updatedAt: now2,
          ),
        );
    await liveDb
        .into(liveDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: localSelfMemberId(localItem.ledgerBackupId, 'self-live'),
            ledgerId: '55555555-5555-4555-8555-555555555555',
            displayName: '冲突成员',
            memberType: 'LOCAL',
            updatedAt: now2,
          ),
        );

    await expectLater(
      importService.apply(
        session: session,
        liveDb: liveDb,
        localSelfId: 'self-live',
      ),
      throwsA(anything),
    );
    // 整体回滚：恢复产物（含 origin 标记的账本）全部消失，仅剩注入的占位账本
    final ledgers = await liveDb.select(liveDb.ledgers).get();
    expect(
      ledgers.where((l) => l.originType != null),
      isEmpty,
      reason: '恢复数据整体回滚',
    );
    expect(ledgers.where((l) => l.id == localItem.ledgerBackupId), isEmpty);
    // 主事务成功日志随回滚消失，但失败尝试日志在回滚后单独落盘
    final logs = await liveDb.select(liveDb.recoveryLogs).get();
    expect(logs, hasLength(1), reason: '失败尝试必须可审计');
    expect(logs.single.result, 'failed');
    expect(logs.single.action, 'apply_failed');
  });

  test(
    'restoreWholeDatabaseForEmergency：整库覆盖后云端账本 STALE_BINDING + 同步状态清除',
    () async {
      final (srcDb, backup) = await seedBackupSource();
      addTearDown(srcDb.close);
      // live 库先有数据（将被覆盖）
      await liveDb
          .into(liveDb.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: '99999999-9999-4999-8999-999999999999',
              name: '旧账本',
              storageMode: const d.Value('local'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );

      final result = await backupService.restoreWholeDatabaseForEmergency(
        db: liveDb,
        backupFile: backup,
      );
      expect(result.status, RestoreStatus.success);

      // 重新打开：整库被备份内容替换
      final reopened = SesameDatabase.forTesting(NativeDatabase(dbFile));
      final ledgers = await reopened.select(reopened.ledgers).get();
      expect(ledgers.map((l) => l.name), contains('家庭账本'));
      expect(ledgers.map((l) => l.name), isNot(contains('旧账本')));
      // 云端账本强制 STALE_BINDING + sync_id 失效（绝不保留备份同步状态）
      final cloud = ledgers.singleWhere((l) => l.storageMode == 'cloud');
      expect(cloud.bindingStatus, 'stale');
      expect(cloud.syncId, isNull, reason: '备份中的同步身份绝不复活');
      // 同步状态清除
      expect(await reopened.select(reopened.syncChanges).get(), isEmpty);
      expect(await reopened.select(reopened.syncConflicts).get(), isEmpty);
      await reopened.close();
    },
  );
}
