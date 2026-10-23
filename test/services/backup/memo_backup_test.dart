import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_recovery_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('备份清单拒绝日记本类型', () {
    expect(
      () => ManifestMemoBook.fromJson({'type': 'diary', 'entry_count': 0}),
      throwsFormatException,
    );
  });
  late Directory dir;
  late SesameDatabase db;
  late MemoRepository repo;
  late LocalBackupService service;
  String? account;
  var generation = 0;
  const bookId = '11111111-1111-4111-8111-111111111111';
  const entryId = '22222222-2222-4222-8222-222222222222';
  final now = DateTime.utc(2026, 9, 8, 1, 2, 3, 456);
  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    dir = await (Directory(
      'Temp',
    )..createSync(recursive: true)).createTemp('memo-backup-test-');
    final file = File('${dir.path}/live.sqlite');
    db = SesameDatabase.withExecutor(NativeDatabase(file));
    account = null;
    generation = 0;
    repo = MemoRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
    );
    service = LocalBackupService(
      databaseFile: file,
      backupDir: Directory('${dir.path}/backups'),
      accountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
    );
    await repo.createBook(
      id: bookId,
      name: '卡片',
      type: 'credentials',
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveEntry(
      MemoEntry(
        id: entryId,
        memoBookId: bookId,
        bookType: 'credentials',
        title: '账号',
        bodyJson: encodeMemoFields(const [
          MemoField(label: '账号', value: ' \u0000 user '),
          MemoField(label: '密码', value: ' \u0000🔑\n '),
        ]),
        createdAt: now,
        updatedAt: now,
      ),
      await repo.target(bookId),
      preserveTimes: true,
    );
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
    await logger.clear();
  });
  test('取消不落文件；确认计数绑定快照；自动不提示；读取原始密码与毫秒时间', () async {
    await expectLater(
      service.createBackup(
        db: db,
        confirm: (snapshot) async {
          expect(snapshot.manifest.memoCardCount, 1);
          return false;
        },
      ),
      throwsStateError,
    );
    expect(await service.listBackups(), isEmpty);
    final file = await service.createBackup(
      db: db,
      confirm: (snapshot) async {
        expect(snapshot.manifest.memoCardCount, 1);
        await repo.deleteEntry(entryId, await repo.target(bookId));
        return true;
      },
    );
    final frame = BackupPayloadCodec.decode(await file.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(frame.manifestJson);
    final sqlite = await File(
      '${dir.path}/read.sqlite',
    ).writeAsBytes(frame.sqliteBytes);
    final read = BackupRecoveryRepository.open(sqlite.path);
    try {
      read.validateMemoManifest(manifest);
      expect(
        read.listMemoEntries(bookId).single.fields[1].value,
        ' \u0000🔑\n ',
      );
      expect(read.listMemoEntries(bookId).single.createdAt, now);
    } finally {
      read.close();
    }
    await service.createBackup(
      db: db,
      trigger: BackupTrigger.automatic,
      confirm: (_) async => throw StateError('must not prompt'),
    );
  });
  test('快照过滤另一账号正文及空闲页，换号或下载未完成拒绝交付', () async {
    const foreign = '33333333-3333-4333-8333-333333333333';
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: foreign,
            name: 'FOREIGN_PASSWORD_SENTINEL',
            type: 'normal',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('other'),
            syncId: const d.Value('foreign-sync'),
            serverRevision: const d.Value(1),
            fullCursor: const d.Value('1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final file = await service.createBackup(
      db: db,
      trigger: BackupTrigger.automatic,
    );
    expect(
      latin1
          .decode(await file.readAsBytes())
          .contains('FOREIGN_PASSWORD_SENTINEL'),
      isFalse,
    );
    await expectLater(
      service.createBackup(
        db: db,
        confirm: (_) async {
          generation++;
          return true;
        },
      ),
      throwsStateError,
    );
    account = 'other';
    await (db.update(db.memoBooks)..where((b) => b.id.equals(foreign))).write(
      const MemoBooksCompanion(fullCursor: d.Value(null)),
    );
    await expectLater(
      service.createBackup(db: db, trigger: BackupTrigger.automatic),
      throwsStateError,
    );
  });
  test('整本恢复原值原时间，预览后子项变化整批回滚；隐藏现场转独立副本', () async {
    final file = await service.createBackup(
      db: db,
      trigger: BackupTrigger.automatic,
    );
    final importer = BackupImportService(tempDirOverride: dir);
    final session = await importer.openBackup(backupFile: file);
    try {
      session.memoBookDecisions[bookId] = RecoveryDecision.restoreLocal;
      session.memoTargetSnapshots.addAll(
        await importer.captureMemoTargets(db, [bookId]),
      );
      await repo.renameBook(await repo.target(bookId), 'changed');
      await expectLater(
        importer.apply(session: session, liveDb: db, localSelfId: 'local'),
        throwsStateError,
      );
      expect((await repo.getBook(bookId))!.name, 'changed');
      session.memoTargetSnapshots.addAll(
        await importer.captureMemoTargets(db, [bookId]),
      );
      final result = await importer.apply(
        session: session,
        liveDb: db,
        localSelfId: 'local',
      );
      expect(result.memoBookResults[bookId], bookId);
      expect((await repo.getBook(bookId))!.name, '卡片');
      expect(
        (await repo.getEntries(bookId)).single.fields[1].value,
        ' \u0000🔑\n ',
      );
      expect((await repo.getEntries(bookId)).single.createdAt, now);
      await (db.update(db.memoBooks)..where((b) => b.id.equals(bookId))).write(
        const MemoBooksCompanion(isHidden: d.Value(true)),
      );
      session.memoTargetSnapshots.addAll(
        await importer.captureMemoTargets(db, [bookId]),
      );
      final copy = await importer.apply(
        session: session,
        liveDb: db,
        localSelfId: 'local',
      );
      expect(copy.memoBookResults[bookId], isNot(bookId));
      expect((await repo.getBooks()).single.id, copy.memoBookResults[bookId]);
      expect(
        (await (db.select(
          db.memoBooks,
        )..where((b) => b.id.equals(bookId))).getSingle()).isHidden,
        isTrue,
      );
    } finally {
      await session.close();
    }
  });
}
