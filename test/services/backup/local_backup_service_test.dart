import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode;

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import '../../helpers/test_isolation.dart';

/// 覆盖备份完整性、损坏拒绝、账号隔离和保留数量。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late Directory tmp;
  late File dbFile;
  late Directory backupDir;
  late SesameDatabase db;
  late LocalBackupService service;

  setUp(() async {
    tmp = await createTestTempDirectory('local_backup_test_');
    dbFile = File(p.join(tmp.path, 'sesame_notes.sqlite'));
    backupDir = Directory(p.join(tmp.path, 'backups'));
    db = SesameDatabase.withExecutor(NativeDatabase(dbFile));
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

    final backup = await service.createBackup(db: db, deviceId: 'dev-1');

    expect(
      p.basename(backup.path),
      matches(RegExp(r'^sesame_notes_\d{8}_\d{6}_\d{6}_[0-9a-f-]{36}\.snbak$')),
    );
    expect(await backup.exists(), isTrue);

    final (manifest, sqliteBytes) = await openBackup(backup);
    expect(manifest.formatVersion, 1);
    expect(manifest.dbSchemaVersion, db.schemaVersion);
    expect(manifest.deviceId, 'dev-1');
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

  /// 通过当前账号密码卡片触发真实备份确认，避免直接调用内部准备和发布步骤。
  Future<void> addCredentialPreview() async {
    final stamp = DateTime.utc(2026, 10, 19);
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: '11111111-1111-4111-8111-111111111111',
            name: '账号密码',
            type: 'credentials',
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
    await db
        .into(db.memoEntries)
        .insert(
          MemoEntriesCompanion.insert(
            id: '22222222-2222-4222-8222-222222222222',
            memoBookId: '11111111-1111-4111-8111-111111111111',
            bookType: 'credentials',
            title: '账号',
            bodyFormat: const d.Value('fields_v1'),
            body: const d.Value('{"fields":[{"label":"账号","value":"user"}]}'),
            orderKey: const d.Value(0),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  test('冻结同一微秒连续备份保留独立内容，确认期间身份不变且其他创建被单飞拒绝', () async {
    var now = DateTime(2026, 10, 19, 12, 0, 0, 321, 456);
    service = LocalBackupService(
      backupDir: backupDir,
      databaseFile: dbFile,
      clock: () => now,
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: '第一份快照',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    final first = await service.createBackup(db: db);
    final firstBytes = await first.readAsBytes();
    await (db.update(db.ledgers)..where((row) => row.id.equals('ledger-1')))
        .write(const LedgersCompanion(name: d.Value('第二份快照')));
    await addCredentialPreview();
    String? allocatedName;
    final second = await service.createBackup(
      db: db,
      confirm: (snapshot) async {
        allocatedName = snapshot.fileName;
        now = now.add(const Duration(days: 1));
        await expectLater(service.createBackup(db: db), throwsStateError);
        return true;
      },
    );
    expect(second.path, isNot(first.path));
    expect(p.basename(second.path), allocatedName);
    expect(await first.readAsBytes(), firstBytes);
    expect((await openBackup(first)).$1.ledgers.single.name, '第一份快照');
    expect((await openBackup(second)).$1.ledgers.single.name, '第二份快照');
    final backups = await service.listBackups();
    expect(backups.map((backup) => backup.file.path), [
      second.path,
      first.path,
    ]);
    expect(backups.first.createdAt.microsecond, 457);
    expect(backups.last.createdAt.microsecond, 456);
    expect(
      (await backupDir.list().toList()).where(
        (entry) => entry.path.endsWith('.pending'),
      ),
      isEmpty,
    );
  });

  test('确认期间发布目标被占用时拒绝覆盖，只清理本次拥有的提交标记', () async {
    await addCredentialPreview();
    late File existing;
    await expectLater(
      service.createBackup(
        db: db,
        confirm: (snapshot) async {
          await backupDir.create(recursive: true);
          existing = File(p.join(backupDir.path, snapshot.fileName));
          await existing.writeAsString('已存在的恢复点');
          return true;
        },
      ),
      throwsA(isA<PathExistsException>()),
    );
    expect(await existing.readAsString(), '已存在的恢复点');
    expect(await File('${existing.path}.pending').exists(), isFalse);
    expect(await backupDir.list().toList(), hasLength(1));
  });

  test('文件写盘后会话变化时拒绝发布，未提交快照不会进入列表', () async {
    final guarded = LocalBackupService(
      backupDir: backupDir,
      databaseFile: dbFile,
      accountIdGetter: () =>
          backupDir.existsSync() &&
              backupDir.listSync().any(
                (entry) => entry.path.endsWith('.pending'),
              )
          ? 'account-b'
          : 'account-a',
    );
    await expectLater(
      guarded.createBackup(
        db: db,
        currentAccountId: 'account-a',
        trigger: BackupTrigger.automatic,
      ),
      throwsStateError,
    );
    expect(await guarded.listBackups(), isEmpty);
    expect(await backupDir.list().toList(), isEmpty);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
  for (final rollback in [false, true]) {
    test('同目录跨实例${rollback ? '时钟回拨' : '冻结同一微秒'}时递增命名并交付存在的新文件', () async {
      try {
        final frozen = DateTime(2026, 10, 19, 12, 0, 0, 123, 456);
        final services = [
          LocalBackupService(
            backupDir: backupDir,
            databaseFile: dbFile,
            maxBackups: 1,
            clock: () => frozen,
          ),
          LocalBackupService(
            backupDir: Directory(p.relative(backupDir.path)),
            databaseFile: dbFile,
            maxBackups: 1,
            clock: () =>
                rollback ? frozen.subtract(const Duration(days: 1)) : frozen,
          ),
        ];
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: 'cross-instance',
                name: '快照0',
                storageMode: const d.Value('local'),
                updatedAt: frozen,
              ),
            );
        File? previous;
        for (var index = 0; index < services.length; index++) {
          await (db.update(db.ledgers)
                ..where((row) => row.id.equals('cross-instance')))
              .write(LedgersCompanion(name: d.Value('快照$index')));
          final current = services[index];
          final file = await current.createBackup(db: db);

          expect(await file.exists(), isTrue);
          expect(
            p.basename(file.path),
            startsWith('sesame_notes_20261019_120000_${123456 + index}_'),
            reason: '时间部分必须严格递增，排序不能取决于随机 UUID',
          );
          if (previous != null) expect(await previous.exists(), isFalse);
          expect((await openBackup(file)).$1.ledgers.single.name, '快照$index');
          final backups = await current.listBackups();
          expect(backups, hasLength(1));
          expect(backups.single.file.absolute.path, file.absolute.path);
          previous = file;
        }
      } catch (error, stackTrace) {
        logger.error('LocalBackupTest', '跨实例备份顺序验证失败', error, stackTrace);
        rethrow;
      }
    });
  }
  test('目录已有未来时间快照时恢复持久顺序基线，新快照不会被一份上限误删', () async {
    try {
      await backupDir.create(recursive: true);
      final existing = await File(
        p.join(
          backupDir.path,
          'sesame_notes_20991231_120000_654321_ffffffff-ffff-4fff-8fff-ffffffffffff.snbak',
        ),
      ).writeAsString('已存在的未来时间快照');
      service = LocalBackupService(
        backupDir: backupDir,
        databaseFile: dbFile,
        maxBackups: 1,
        clock: () => DateTime(2026, 10, 19),
      );

      final file = await service.createBackup(db: db);

      expect(await file.exists(), isTrue);
      expect(
        p.basename(file.path),
        startsWith('sesame_notes_20991231_120000_654322_'),
      );
      expect(await existing.exists(), isFalse);
      expect((await service.listBackups()).single.file.path, file.path);
    } catch (error, stackTrace) {
      logger.error('LocalBackupTest', '持久备份顺序基线验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('未提交或崩溃残留备份不进入恢复列表和保留清理', () async {
    try {
      await backupDir.create(recursive: true);
      final incomplete = File(
        p.join(
          backupDir.path,
          'sesame_notes_20261019_120000_123456_00000000-0000-4000-8000-000000000000.snbak',
        ),
      );
      final pending = File('${incomplete.path}.pending');
      await pending.create(exclusive: true);
      await incomplete.writeAsString('未完成的快照');
      service = LocalBackupService(
        backupDir: backupDir,
        databaseFile: dbFile,
        maxBackups: 0,
      );

      expect(await service.listBackups(), isEmpty);
      await service.pruneBackups();

      expect(await incomplete.readAsString(), '未完成的快照');
      expect(await pending.exists(), isTrue);
    } catch (error, stackTrace) {
      logger.error('LocalBackupTest', '未提交快照隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('微秒备份按上限保留最新三十份', () async {
    try {
      await backupDir.create(recursive: true);
      const identity = '00000000-0000-4000-8000-000000000000';
      for (var i = 0; i < 32; i++) {
        final fileName =
            'sesame_notes_20261019_120000_${i.toString().padLeft(6, '0')}_$identity.snbak';
        await File(p.join(backupDir.path, fileName)).writeAsBytes([i]);
      }

      await service.pruneBackups();
      final files = await service.listBackups();

      expect(files, hasLength(30));
      expect(files.first.createdAt.microsecond, 31);
      expect(files.last.createdAt.microsecond, 2);
      expect(
        files.any(
          (file) => file.fileName == 'sesame_notes_20261019_120000.snbak',
        ),
        isFalse,
      );
    } catch (error, stackTrace) {
      logger.error('LocalBackupTest', '备份保留上限验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('秒级备份与微秒备份共同按上限保留，恢复中的原文件暂缓清理', () async {
    await backupDir.create(recursive: true);
    const identity = '00000000-0000-4000-8000-000000000000';
    final leased = await File(
      p.join(backupDir.path, 'sesame_notes_20260701_090000.snbak'),
    ).writeAsString('读取中的旧备份');
    final expired = await File(
      p.join(backupDir.path, 'sesame_notes_20260702_090000.snbak'),
    ).writeAsString('超出保留数量的旧备份');
    final seconds = await File(
      p.join(backupDir.path, 'sesame_notes_20261019_120000.snbak'),
    ).writeAsString('仍应保留的秒级备份');
    final micros = await File(
      p.join(
        backupDir.path,
        'sesame_notes_20261019_120000_000001_$identity.snbak',
      ),
    ).writeAsString('新备份');
    service = LocalBackupService(backupDir: backupDir, maxBackups: 2);

    final all = await service.listBackups();
    expect(all.map((item) => item.file.path), [
      micros.path,
      seconds.path,
      expired.path,
      leased.path,
    ]);
    expect(all[1].createdAt, DateTime(2026, 10, 19, 12));
    await LocalBackupService.withBackupFileRead(leased, () async {
      await service.pruneBackups();
      expect(await expired.exists(), isFalse);
      expect(await leased.readAsString(), '读取中的旧备份');
      expect(await seconds.readAsString(), '仍应保留的秒级备份');
      expect(await micros.readAsString(), '新备份');
    });
    await service.pruneBackups();
    expect(await leased.exists(), isFalse);
    expect(await service.listBackups(), hasLength(2));
  });

  test('非正式名称和非法日期不进入备份列表，也不会被保留清理删除', () async {
    await backupDir.create(recursive: true);
    final names = [
      'sesame_notes_emergency_20260701_100000.snbak',
      'sesame_notes_invalid.snbak',
      'sesame_notes_20260230_120000.snbak',
      'sesame_notes_20261019_126099.snbak',
      'sesame_notes_20260230_120000_123456_00000000-0000-4000-8000-000000000000.snbak',
      'sesame_notes_20261019_126099_123456_00000000-0000-4000-8000-000000000000.snbak',
      'sesame_notes_20261019_120000_123456_------------------------------------.snbak',
      'readme.txt',
    ];
    for (final name in names) {
      await File(p.join(backupDir.path, name)).writeAsString('保留原文件');
    }
    expect(await service.listBackups(), isEmpty);
    await service.pruneBackups();
    for (final name in names) {
      expect(await File(p.join(backupDir.path, name)).readAsString(), '保留原文件');
    }
  });

  test('读取目录失败明确抛错，不能伪装为没有备份', () async {
    final occupied = await File(
      p.join(tmp.path, 'occupied'),
    ).writeAsString('文件');
    final broken = LocalBackupService(backupDir: Directory(occupied.path));
    await expectLater(
      broken.listBackups(),
      throwsA(isA<FileSystemException>()),
    );
    expect(await occupied.readAsString(), '文件');
  });
  test('真实恢复入口拒绝合法分帧中的损坏 SQLite，当前库与原文件保持不变', () async {
    try {
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
      final before = await db.select(db.ledgers).get();
      final valid = await service.createBackup(db: db);
      final (manifest, _) = await openBackup(valid);
      final corruptSqlite = await File(
        p.join(tmp.path, 'corrupt.sqlite'),
      ).writeAsString('this is not a SQLite database');
      final badFile = await File(p.join(backupDir.path, 'corrupt.snbak'))
          .writeAsBytes(
            BackupPayloadCodec.encode(
              BackupManifestCodec.encodeJson(manifest),
              await corruptSqlite.readAsBytes(),
            ),
          );
      final original = await badFile.readAsBytes();
      final inspection = await Directory(
        p.join(tmp.path, 'inspection'),
      ).create();
      final importer = BackupImportService(tempDirOverride: inspection);

      await expectLater(
        importer.openBackup(backupFile: badFile),
        throwsA(
          isA<BackupFormatException>().having(
            (error) => error.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
      expect(
        await db.select(db.ledgers).get(),
        before,
        reason: '只读校验不得关闭当前数据库或改变其中的原记录',
      );
      expect(await badFile.readAsBytes(), original);
      expect(await inspection.list().toList(), isEmpty);
    } catch (error, stack) {
      logger.error('LocalBackupTest', '损坏备份校验必须保持当前库可用', error, stack);
      rethrow;
    }
  });

  group('账号域过滤', () {
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
              ownerAccountId: const d.Value('user-mine'),
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
              ownerAccountId: const d.Value('user-other'),
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
