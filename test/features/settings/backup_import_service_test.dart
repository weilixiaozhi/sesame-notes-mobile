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

  test('当前备份以清单账号归属恢复，并保留币种和支出统计', () async {
    final tmp = await Directory('Temp').createTemp('import_scope_');
    addTearDown(() => tmp.delete(recursive: true));
    final dbFile = File(p.join(tmp.path, 'src.sqlite'));
    final srcDb = SesameDatabase.withExecutor(NativeDatabase(dbFile));
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

    // 当前清单明确记录云端账本的来源账号。
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      dbSchemaVersion: srcDb.schemaVersion,
      createdAt: now,
      deviceId: '',
      dayBooks: const [],
      ledgers: [
        ManifestLedger(
          ledgerBackupId: 'cloud-1',
          name: '家庭账本',
          storageOrigin: LedgerStorageOrigin.cloud,
          originalLocalLedgerId: null,
          cloudProvider: 'sesame_notes',
          originalCloudLedgerId: 'cloud-1',
          originalAccountId: 'acc-1',
          ownerType: 'OWNER',
          pendingMutationCount: 0,
          openConflictCount: 1,
          lastSyncAt: null,
        ),
      ],
      accounts: const [ManifestAccount(accountId: 'acc-1', accountName: '')],
    );
    final backup = File(p.join(tmp.path, 'current.snbak'));
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
    final liveDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(liveDb.close);
    final session = await service.openBackup(backupFile: backup);
    addTearDown(session.close);
    final items = await service.listRecoveryItems(session);

    expect(items, hasLength(1));
    expect(
      items.single.accountReference?.accountId,
      'acc-1',
      reason: '账号归属取自清单',
    );
    expect(items.single.currency, 'USD');
    expect(items.single.expenseTotal, closeTo(350.5, 0.001));
    expect(items.single.transactionCount, 2);
    expect(items.single.conflictCount, 1, reason: '冲突数来自 manifest 统计');
  });
}
