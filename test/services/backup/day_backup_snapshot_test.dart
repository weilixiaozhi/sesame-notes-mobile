import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode, SqliteException;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import '../../helpers/test_isolation.dart';

/// 在真实在线复制结束边界插入故障或并发提交，控制独立需求时序。
class _BoundaryBackup extends LocalBackupService {
  _BoundaryBackup({
    required super.databaseFile,
    required super.backupDir,
    super.accountIdGetter,
    super.sessionGenerationGetter,
    this.afterSnapshot,
    this.fail = false,
    this.fault,
  });
  final Future<void> Function()? afterSnapshot;
  final bool fail;
  final Object? fault;

  @override
  Future<void> copyDatabaseSnapshot(File source, File destination) async {
    if (fail) throw fault ?? const FileSystemException('snapshot failure');
    await super.copyDatabaseSnapshot(source, destination);
    await afterSnapshot?.call();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late File liveFile;
  late SesameDatabase db;
  late LocalBackupService service;
  final now = DateTime.utc(2026, 9, 7);

  setUp(() async {
    resetGlobalTestState();
    final parent = Directory('Temp')..createSync(recursive: true);
    temp = await parent.createTemp('day-backup-');
    liveFile = File('${temp.path}/live.sqlite');
    db = SesameDatabase.withExecutor(NativeDatabase(liveFile));
    service = LocalBackupService(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
    );
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  /// 固定夹具直接表达三种可备份父本，不依赖清单构造逻辑。
  Future<void> book(String id, {String? account, bool hidden = false}) async {
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: id,
            name: id,
            createdAt: now,
            updatedAt: now,
            storageMode: d.Value(account == null ? 'local' : 'cloud'),
            scopeAccountId: d.Value(account),
            serverRevision: d.Value(account == null ? null : 1),
            syncId: d.Value(account == null ? null : 'binding-$id'),
            fullCursor: d.Value(account == null ? null : '42'),
            isHidden: d.Value(hidden),
          ),
        );
  }

  test('已下载后身份失效的云日子本仍可完整备份并明确标记内容不完整', () async {
    await book('stale-cloud', account: 'A');
    await (db.update(db.dayBooks)..where((row) => row.id.equals('stale-cloud')))
        .write(const DayBooksCompanion(isStale: d.Value(true)));
    final backup = await LocalBackupService(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
      accountIdGetter: () => 'A',
    ).createBackup(db: db);
    final framed = BackupPayloadCodec.decode(await backup.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
    expect(manifest.dayBooks.single.dayBookId, 'stale-cloud');
    expect(manifest.dayBooks.single.fullyDownloaded, isFalse);
  });

  test('同源清单仅含当前账号与本机，空本和隐藏保护副本均保留', () async {
    await book('local-empty');
    await book('hidden-protection', hidden: true);
    await book('current-cloud', account: 'A');
    await book('foreign-cloud', account: 'B');
    for (final account in ['A', 'B']) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'ledger-$account',
              name: 'ledger-$account',
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(account),
              updatedAt: now,
            ),
          );
    }
    await db
        .into(db.dayEvents)
        .insert(
          DayEventsCompanion.insert(
            id: 'event-A',
            dayBookId: 'current-cloud',
            category: 'birthday',
            name: '生日',
            repeatType: 'yearly',
            statisticType: 'year',
            createdAt: now,
            updatedAt: now,
            eventCalendarType: const d.Value('solar'),
            eventOriginalYear: const d.Value(2000),
            eventOriginalMonth: const d.Value(1),
            eventOriginalDay: const d.Value(1),
            eventIsLeapMonth: const d.Value(false),
            eventSolarDate: const d.Value('2000-01-01'),
            serverRevision: const d.Value(1),
          ),
        );
    await db
        .into(db.dayImportReceipts)
        .insert(
          DayImportReceiptsCompanion.insert(
            targetDayBookId: 'current-cloud',
            exportId: 'export',
            sourceEntryId: 'old-source',
            importedAt: now,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'day_event',
            entityId: 'event-A',
            dayBookId: const d.Value('current-cloud'),
            accountId: const d.Value('A'),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: 'pending',
            rejectionReason: const d.Value('请修正'),
          ),
        );
    final file = await service.createBackup(db: db, currentAccountId: 'A');
    final framed = BackupPayloadCodec.decode(await file.readAsBytes());
    final manifest =
        jsonDecode(utf8.decode(framed.manifestJson)) as Map<String, dynamic>;
    expect((manifest['ledgers'] as List).map((e) => e['ledger_backup_id']), [
      'ledger-A',
    ]);
    expect(manifest['contents'], containsAll(['day_books', 'day_events']));
    final entries = (manifest['day_books'] as List)
        .cast<Map<String, dynamic>>();
    expect(
      entries.map((e) => e['day_book_id']),
      unorderedEquals(['local-empty', 'hidden-protection', 'current-cloud']),
    );
    final cloud = entries.singleWhere(
      (e) => e['day_book_id'] == 'current-cloud',
    );
    expect(cloud['event_count'], 1);
    expect(cloud['category_counts'], {
      'birthday': 1,
      'anniversary': 0,
      'countdown': 0,
      'stage': 0,
    });
    expect(cloud['pending_count'], 1);
    expect(cloud['rejected_count'], 1);
    expect(cloud['fully_downloaded'], isTrue);
    expect(
      entries.singleWhere(
        (e) => e['day_book_id'] == 'hidden-protection',
      )['is_hidden'],
      isTrue,
    );
    final extracted = File('${temp.path}/read.sqlite')
      ..writeAsBytesSync(framed.sqliteBytes);
    final snapshot = sqlite3.open(extracted.path, mode: OpenMode.readOnly);
    try {
      expect(
        snapshot.select('SELECT id FROM day_books').map((r) => r['id']),
        unorderedEquals(entries.map((e) => e['day_book_id'])),
      );
      expect(
        snapshot.select('SELECT * FROM day_import_receipts'),
        hasLength(1),
      );
      expect(snapshot.select('SELECT * FROM sync_changes'), hasLength(1));
      expect(snapshot.select('PRAGMA foreign_key_check'), isEmpty);
    } finally {
      snapshot.close();
    }
    expect(
      await db.select(db.dayBooks).get(),
      hasLength(4),
      reason: '快照过滤不得修改实时库',
    );
  });

  test('其他账号当前行与已删除空闲页标记不进入备份字节', () async {
    await book('local-empty');
    await book('FOREIGN_ACCOUNT_PRIVATE_MARKER', account: 'B');
    await db.customStatement('PRAGMA secure_delete = OFF');
    await db.customStatement(
      'CREATE TABLE temporary_deleted_material (value TEXT)',
    );
    await db.customStatement(
      'INSERT INTO temporary_deleted_material VALUES (?)',
      ['DELETED_PRIVATE_MARKER' * 500],
    );
    await db.customStatement('DELETE FROM temporary_deleted_material');
    final file = await service.createBackup(db: db, currentAccountId: 'A');
    final bytes = latin1.decode(await file.readAsBytes());
    expect(bytes, isNot(contains('FOREIGN_ACCOUNT_PRIVATE_MARKER')));
    expect(bytes, isNot(contains('DELETED_PRIVATE_MARKER')));
  });

  test('在线快照包含已提交 WAL 内容并可独立打开', () async {
    await book('local-before');
    await db.customStatement('PRAGMA journal_mode = WAL');
    await db.customStatement('PRAGMA wal_autocheckpoint = 0');
    final reader = sqlite3.open(liveFile.path, mode: OpenMode.readOnly);
    reader.execute('BEGIN');
    reader.select('SELECT * FROM day_books');
    try {
      await book('wal-committed');
      final file = await service.createBackup(db: db);
      final framed = BackupPayloadCodec.decode(await file.readAsBytes());
      final extracted = File('${temp.path}/wal-snapshot.sqlite')
        ..writeAsBytesSync(framed.sqliteBytes);
      final snapshot = sqlite3.open(extracted.path, mode: OpenMode.readOnly);
      try {
        expect(
          snapshot.select('SELECT id FROM day_books').map((r) => r['id']),
          contains('wal-committed'),
        );
        expect(
          snapshot.select('PRAGMA integrity_check').single.values.single,
          'ok',
        );
      } finally {
        snapshot.close();
      }
    } finally {
      reader.execute('ROLLBACK');
      reader.close();
    }
  });

  test('快照复制后实时新增不进入清单，清单和SQLite来自同一时刻', () async {
    await book('snapshot-member');
    service = _BoundaryBackup(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
      afterSnapshot: () => book('after-snapshot'),
    );
    final file = await service.createBackup(db: db);
    final framed = BackupPayloadCodec.decode(await file.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
    expect(manifest.dayBooks.map((b) => b.dayBookId), ['snapshot-member']);
    expect(await db.select(db.dayBooks).get(), hasLength(2));
  });

  test('在线复制失败没有成功文件，原库和重试入口保留', () async {
    await book('source-intact');
    service = _BoundaryBackup(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
      fail: true,
    );
    await expectLater(
      service.createBackup(db: db),
      throwsA(isA<FileSystemException>()),
    );
    expect(await service.listBackups(), isEmpty);
    expect((await db.select(db.dayBooks).get()).single.id, 'source-intact');
    service = LocalBackupService(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
    );
    expect(await service.createBackup(db: db), isA<File>());
    expect(
      temp.listSync().whereType<Directory>().where(
        (d) => d.path.contains('backup-snapshot-'),
      ),
      isEmpty,
    );
  });

  test('备份错误日志只保留错误类型和安全码，不包含SQLite参数或原始消息', () async {
    await book('source-intact');
    service = _BoundaryBackup(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
      fail: true,
      fault: SqliteException(
        extendedResultCode: 19,
        message: 'PRIVATE_LOG_MARKER',
        causingStatement: 'INSERT INTO payload VALUES (?)',
        parametersToStatement: ['PRIVATE_LOG_MARKER'],
      ),
    );
    await expectLater(
      service.createBackup(db: db),
      throwsA(isA<SqliteException>()),
    );
    final errors = logger.logs
        .where((entry) => entry.tag == 'LocalBackup' && entry.error != null)
        .map((entry) => entry.error.toString())
        .join('\n');
    expect(errors.contains('PRIVATE_LOG_MARKER'), isFalse);
    expect(errors, contains('SqliteException'));
    expect(errors, contains('19'));
  });

  test('同账号会话generation改变则废弃快照，不发布迟到备份', () async {
    await book('cloud-A', account: 'A');
    var generation = 1;
    service = _BoundaryBackup(
      databaseFile: liveFile,
      backupDir: Directory('${temp.path}/backups'),
      accountIdGetter: () => 'A',
      sessionGenerationGetter: () => generation,
      afterSnapshot: () async {
        generation++;
      },
    );
    await expectLater(
      service.createBackup(db: db, currentAccountId: 'A'),
      throwsStateError,
    );
    expect(await service.listBackups(), isEmpty);
    expect((await db.select(db.dayBooks).get()).single.id, 'cloud-A');
  });
}
