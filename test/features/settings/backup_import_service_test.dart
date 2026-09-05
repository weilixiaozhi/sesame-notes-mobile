/// BackupImportService 恢复预览测试。
///
/// 需求锚点：
/// - 旧备份 manifest 缺 original_account_id 时，用备份 sqlite 的
///   scope_account_id 兜底归属账号（修复「已登录仍显示未知账号」）；
/// - 预览条目带账本本位币与累计支出总额（与账本管理页卡片同口径）。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('旧备份缺 original_account_id：scope_account_id 兜底 + 币种/支出统计', () async {
    final tmp = await Directory.systemTemp.createTemp('import_scope_');
    addTearDown(() => tmp.delete(recursive: true));
    final dbFile = File(p.join(tmp.path, 'src.sqlite'));
    final srcDb = SesameDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(srcDb.close);
    final now = DateTime.utc(2026, 8, 1);
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'cloud-1',
            name: '家庭账本',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('sync-1'),
            currency: const d.Value('USD'),
            scopeAccountId: const d.Value('acc-1'),
            updatedAt: now,
          ),
        );
    // 两笔支出：100 + 250.50（金额折算快照 native_amount 优先）
    await srcDb
        .into(srcDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't-1',
            ledgerId: 'cloud-1',
            txType: 'expense',
            amount: '100',
            happenedAt: now,
            currencyCode: 'USD',
            nativeAmount: '100',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't-2',
            ledgerId: 'cloud-1',
            txType: 'expense',
            amount: '250.50',
            happenedAt: now,
            currencyCode: 'USD',
            nativeAmount: '250.50',
            createdAt: now,
            updatedAt: now,
          ),
        );
    // 把 WAL 合并进主库，单文件字节即为完整数据
    await srcDb.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

    // 手工构造旧版 manifest：original_account_id 缺省（模拟历史备份）
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      dbSchemaVersion: srcDb.schemaVersion,
      createdAt: now,
      deviceId: '',
      appVersion: '',
      ledgers: [
        ManifestLedger(
          ledgerBackupId: 'cloud-1',
          name: '家庭账本',
          storageOrigin: LedgerStorageOrigin.cloud,
          originalLocalLedgerId: null,
          cloudProvider: 'sesame_notes',
          originalCloudLedgerId: 'cloud-1',
          originalAccountId: null,
          ownerType: 'OWNER',
          pendingMutationCount: 0,
          openConflictCount: 1,
          lastSyncAt: null,
        ),
      ],
      accounts: const [ManifestAccount(accountId: 'acc-1', accountName: '')],
    );
    final backup = File(p.join(tmp.path, 'old.snbak'));
    await backup.writeAsBytes(
      BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(manifest),
        await dbFile.readAsBytes(),
      ),
      flush: true,
    );

    final extractDir = Directory(p.join(tmp.path, 'extract'));
    await extractDir.create(recursive: true);
    final service = BackupImportService(tempDirOverride: extractDir);
    final liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(liveDb.close);
    final session = await service.openBackup(
      backupFile: backup,
      currentSchemaVersion: liveDb.schemaVersion,
    );
    addTearDown(session.close);
    final items = await service.listRecoveryItems(session);

    expect(items, hasLength(1));
    expect(
      items.single.accountReference?.accountId,
      'acc-1',
      reason: 'manifest 缺账号时用 scope_account_id 兜底（修复未知账号）',
    );
    expect(items.single.currency, 'USD');
    expect(items.single.expenseTotal, closeTo(350.5, 0.001));
    expect(items.single.transactionCount, 2);
    expect(items.single.conflictCount, 1, reason: '冲突数来自 manifest 统计');
  });
}
