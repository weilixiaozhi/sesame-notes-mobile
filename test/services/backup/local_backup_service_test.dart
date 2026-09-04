/// LocalBackupService 单元测试。
///
/// - 备份文件 = 明文分帧 .snbak，内容为 Manifest JSON + SQLite 体；
/// - 命名 sesame_notes_ 加时间戳加 .snbak，时间戳字典序即时间序；
/// - 保留最近 N 份（默认 7，可配置）+ 紧急备份 3 份；
/// - Manifest 统计字段（pending/open conflict/last revision）来自实时数据库；
/// - 损坏文件恢复拒绝，live DB 0 mutation。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late Directory tmp;
  late File dbFile;
  late Directory backupDir;
  late SesameDatabase db;
  late LocalBackupService service;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('local_backup_test_');
    dbFile = File(p.join(tmp.path, 'sesame_notes.sqlite'));
    backupDir = Directory(p.join(tmp.path, 'backups'));
    db = SesameDatabase.forTesting(NativeDatabase(dbFile));
    service = LocalBackupService(backupDir: backupDir, databaseFile: dbFile);
  });

  tearDown(() async {
    try {
      await db.close();
    } catch (_) {}
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  /// 以明文分帧打开 .snbak，返回 (manifest, sqlite 字节)。
  Future<(BackupManifest, List<int>)> openBackup(File file) async {
    final framed = BackupPayloadCodec.decode(await file.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
    return (manifest, framed.sqliteBytes);
  }

  test('createBackup 生成明文分帧 .snbak：SQLite 数据完整', () async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    final backup = await service.createBackup(
      db: db,
      deviceId: 'dev-1',
      appVersion: '1.0.0+1',
    );

    expect(
      p.basename(backup.path),
      matches(RegExp(r'^sesame_notes_\d{8}_\d{6}\.snbak$')),
    );
    expect(await backup.exists(), isTrue);

    final (manifest, sqliteBytes) = await openBackup(backup);
    expect(manifest.formatVersion, 1);
    expect(manifest.dbSchemaVersion, db.schemaVersion);
    expect(manifest.deviceId, 'dev-1');
    expect(manifest.appVersion, '1.0.0+1');
    expect(manifest.ledgers, hasLength(1));
    expect(manifest.ledgers[0].name, '私人账本');
    expect(manifest.ledgers[0].storageOrigin, LedgerStorageOrigin.local);
    expect(manifest.ledgers[0].originalLocalLedgerId, 'ledger-1');

    // SQLite 体是完整库：独立只读连接可查询
    final sqliteFile = File(p.join(tmp.path, 'extracted.sqlite'));
    await sqliteFile.writeAsBytes(sqliteBytes);
    final checkDb = sqlite3.open(sqliteFile.path, mode: OpenMode.readOnly);
    final rows = checkDb.select('SELECT name FROM ledgers');
    checkDb.close();
    expect(rows.map((r) => r['name']), contains('私人账本'));
  });

  test(
    'Manifest 统计字段：pending mutation / open conflict / last revision',
    () async {
      // 云端账本 + 3 条 pending + 1 个 OPEN 冲突 + 1 条已同步交易(rev 5)
      final ledgerId = 'ledger-cloud-1';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: '云端账本',
              storageMode: const d.Value('cloud'),
              syncId: const d.Value('sync-1'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      for (var i = 0; i < 3; i++) {
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'transaction',
                entityId: 'tx-$i',
                ledgerId: d.Value(ledgerId),
                action: 'upsert',
                payload: '{}',
                updatedAt: DateTime.utc(2026, 8, 1),
                mutationId: 'm-$i',
              ),
            );
      }
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: 'tx-pushed',
              ledgerId: d.Value(ledgerId),
              action: 'upsert',
              payload: '{}',
              updatedAt: DateTime.utc(2026, 8, 1),
              mutationId: 'm-pushed',
              pushedAt: d.Value(DateTime.utc(2026, 8, 1)),
            ),
          );
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: 'conflict-1',
              ledgerId: ledgerId,
              entityType: 'transaction',
              entityId: 'tx-0',
              localPayload: '{}',
              remotePayload: '{}',
              baseRevision: 1,
              remoteRevision: 3,
              localMutationId: 'm-0',
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-synced',
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '10',
              happenedAt: DateTime.utc(2026, 8, 1),
              currencyCode: 'CNY',
              nativeAmount: '10',
              serverRevision: d.Value(5),
              createdAt: DateTime.utc(2026, 8, 1),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );

      final backup = await service.createBackup(db: db);
      final (manifest, _) = await openBackup(backup);
      final entry = manifest.ledgers.single;
      expect(entry.pendingMutationCount, 3, reason: '仅未推送变更计数');
      expect(entry.openConflictCount, 1);
      expect(entry.lastSyncAt, isNotNull);
      expect(entry.storageOrigin, LedgerStorageOrigin.cloud);
      expect(entry.originalCloudLedgerId, ledgerId);
      expect(entry.originalAccountId, isNull);
    },
  );

  test('listBackups 仅列 .snbak、过滤 tmp/emergency、按时间戳倒序', () async {
    await backupDir.create(recursive: true);
    for (final name in [
      'sesame_notes_20260701_090000.snbak',
      'sesame_notes_20260703_090000.snbak',
      'sesame_notes_20260702_090000.snbak',
      'sesame_notes_emergency_20260704_090000.snbak',
      'sesame_notes_20260705_090000.snbak.tmp',
      // 旧格式 .sqlite 不进恢复列表（.snbak 专属）
      'sesame_notes_20260706_090000.sqlite',
    ]) {
      await File(p.join(backupDir.path, name)).writeAsBytes([0]);
    }

    final list = await service.listBackups();

    expect(list.map((b) => b.fileName), [
      'sesame_notes_20260703_090000.snbak',
      'sesame_notes_20260702_090000.snbak',
      'sesame_notes_20260701_090000.snbak',
    ]);
  });

  test('pruneBackups 默认保留 7 份正式 + 3 份紧急，删最旧保最新', () async {
    await backupDir.create(recursive: true);
    for (var i = 1; i <= 10; i++) {
      final ts = '202607${i.toString().padLeft(2, '0')}_090000';
      await File(
        p.join(backupDir.path, 'sesame_notes_$ts.snbak'),
      ).writeAsBytes([0]);
    }
    for (var i = 1; i <= 5; i++) {
      final ts = '202607${i.toString().padLeft(2, '0')}_100000';
      await File(
        p.join(backupDir.path, 'sesame_notes_emergency_$ts.snbak'),
      ).writeAsBytes([0]);
    }

    await service.pruneBackups();

    final remaining = (await backupDir.list().toList())
        .map((e) => p.basename(e.path))
        .toList();
    expect(
      remaining
          .where(
            (n) =>
                n.startsWith('sesame_notes_') &&
                !n.startsWith('sesame_notes_emergency_'),
          )
          .length,
      7,
      reason: '默认保留最近 7 份正式备份',
    );
    expect(
      remaining.where((n) => n.startsWith('sesame_notes_emergency_')).length,
      3,
    );
    expect(remaining.contains('sesame_notes_20260701_090000.snbak'), isFalse);
    expect(remaining.contains('sesame_notes_20260710_090000.snbak'), isTrue);
  });

  test('pruneBackups 支持可配置保留份数', () async {
    final custom = LocalBackupService(
      backupDir: backupDir,
      databaseFile: dbFile,
      maxBackups: 2,
    );
    await backupDir.create(recursive: true);
    for (var i = 1; i <= 4; i++) {
      final ts = '202607${i.toString().padLeft(2, '0')}_090000';
      await File(
        p.join(backupDir.path, 'sesame_notes_$ts.snbak'),
      ).writeAsBytes([0]);
    }
    await custom.pruneBackups();
    final remaining = (await backupDir.list().toList())
        .map((e) => p.basename(e.path))
        .toList();
    expect(remaining.where((n) => n.endsWith('.snbak')), hasLength(2));
    expect(remaining, contains('sesame_notes_20260704_090000.snbak'));
  });

  test('restoreFromBackup 拒绝损坏文件：中止且当前库保持可用（live DB 0 mutation）', () async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: 'food',
            storageMode: const d.Value('local'),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    await backupDir.create(recursive: true);
    final badFile = File(
      p.join(backupDir.path, 'sesame_notes_20260701_090000.snbak'),
    );
    await badFile.writeAsString('this is not a backup');

    final result = await service.restoreFromBackup(db: db, backupFile: badFile);
    expect(result.status, RestoreStatus.integrityFailed);

    final names = (await db.select(db.ledgers).get()).map((l) => l.name);
    expect(names, contains('food'), reason: '校验失败在第一步即中止，数据未动');
  });

  test('restoreFromBackup 成功：数据回到备份点、生成紧急备份（.snbak）', () async {
    // 备份点：仅 ledger-1
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: 'food',
            storageMode: const d.Value('local'),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    final backup = await service.createBackup(db: db);
    // 还原原语输入是解帧后的原始 .sqlite（.snbak 解帧由上层紧急通道负责）
    final (_, sqliteBytes) = await openBackup(backup);
    final sqliteBackup = File(p.join(tmp.path, 'extracted_backup.sqlite'));
    await sqliteBackup.writeAsBytes(sqliteBytes);
    // 备份后变更：增 ledger-2——恢复后应回滚
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-2',
            name: 'travel',
            storageMode: const d.Value('local'),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    final result = await service.restoreFromBackup(
      db: db,
      backupFile: sqliteBackup,
    );
    expect(result.status, RestoreStatus.success);

    final reopened = SesameDatabase.forTesting(NativeDatabase(dbFile));
    final names = (await reopened.select(reopened.ledgers).get()).map(
      (l) => l.name,
    );
    expect(names, contains('food'));
    expect(names, isNot(contains('travel')));
    await reopened.close();

    // 恢复前的现场已存为紧急备份（.snbak）
    final emergencyCount = (await backupDir.list().toList())
        .where(
          (e) =>
              p
                  .basename(e.path)
                  .startsWith(LocalBackupService.emergencyPrefix) &&
              e.path.endsWith('.snbak'),
        )
        .length;
    expect(emergencyCount, 1);
  });

  group('账号域过滤（10.5.7）', () {
    test('备份快照只含本地域与当前账号域：其他账号的云账本/分类/汇率/mutation 不入 .snbak', () async {
      // 本地域账本（保留）
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'local-1',
              name: '本地账本',
              storageMode: const d.Value('local'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      // 当前账号域账本（保留）
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'cloud-mine',
              name: '我的云账本',
              storageMode: const d.Value('cloud'),
              syncId: const d.Value('sync-mine'),
              scopeAccountId: const d.Value('user-mine'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      // 其他账号域账本（必须被过滤）
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'cloud-other',
              name: '别人的云账本',
              storageMode: const d.Value('cloud'),
              syncId: const d.Value('sync-other'),
              scopeAccountId: const d.Value('user-other'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      // 账号域分类与汇率覆盖
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-mine',
              name: '我的分类',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('user-mine'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-other',
              name: '别人分类',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('user-other'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      await db
          .into(db.exchangeRateOverrides)
          .insert(
            ExchangeRateOverridesCompanion.insert(
              id: 'rate-other',
              baseCurrency: 'CNY',
              quoteCurrency: 'USD',
              rate: '7.5',
              scopeAccountId: const d.Value('user-other'),
              updatedAt: DateTime.utc(2026, 8, 1),
            ),
          );
      // 其他账号的 mutation
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'ledger',
              entityId: 'cloud-other',
              ledgerId: const d.Value('cloud-other'),
              action: 'upsert',
              payload: '{}',
              updatedAt: DateTime.utc(2026, 8, 1),
              mutationId: const Uuid().v4(),
              accountId: const d.Value('user-other'),
            ),
          );

      final backup = await service.createBackup(
        db: db,
        currentAccountId: 'user-mine',
      );
      final (_, sqliteBytes) = await openBackup(backup);
      final snapshotDb = sqlite3.openInMemory();
      snapshotDb.execute('PRAGMA foreign_keys = ON');
      try {
        snapshotDb.execute('PRAGMA journal_mode = MEMORY');
        // 以字节落临时库后重新打开，验证快照内容
        snapshotDb.close();
        final file = File(p.join(tmp.path, 'snapshot.sqlite'));
        await file.writeAsBytes(sqliteBytes);
        final check = sqlite3.open(file.path);
        try {
          final ledgers = check
              .select('SELECT id FROM ledgers')
              .map((r) => r['id'] as String)
              .toList();
          expect(ledgers, containsAll(['local-1', 'cloud-mine']));
          expect(
            ledgers,
            isNot(contains('cloud-other')),
            reason: '其他账号云账本不得进入备份',
          );
          final cats = check
              .select('SELECT id FROM categories')
              .map((r) => r['id'] as String)
              .toList();
          expect(cats, contains('cat-mine'));
          expect(cats, isNot(contains('cat-other')));
          final rates = check
              .select('SELECT id FROM exchange_rate_overrides')
              .map((r) => r['id'] as String)
              .toList();
          expect(rates, isNot(contains('rate-other')));
          final changes = check
              .select('SELECT account_id FROM sync_changes')
              .map((r) => r['account_id'] as String?)
              .toList();
          expect(changes.whereType<String>(), isNot(contains('user-other')));
        } finally {
          check.close();
        }
      } finally {
        snapshotDb.close();
      }
    });
  });
}
