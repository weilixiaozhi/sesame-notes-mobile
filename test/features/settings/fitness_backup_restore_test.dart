import 'package:sesame_notes/data/models/private_book.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import '../../helpers/fitness_space_fixture.dart';
import '../../helpers/fitness_transfer_fixture.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late SesameDatabase source, live;
  late LocalBackupService backup;
  late BackupImportService restore;
  final account = fitnessId(800), otherAccount = fitnessId(801);
  setUp(() async {
    resetGlobalTestState();
    temp = await Directory('Temp').createTemp('fitness-spaces-backup-');
    final file = File('${temp.path}/source.sqlite');
    source = SesameDatabase.withExecutor(NativeDatabase(file));
    live = SesameDatabase.withExecutor(NativeDatabase.memory());
    backup = LocalBackupService(
      databaseFile: file,
      backupDir: Directory('${temp.path}/backups'),
    );
    restore = BackupImportService(tempDirOverride: temp);
  });
  tearDown(() async {
    await source.close();
    await live.close();
    await temp.delete(recursive: true);
  });
  Future<void> seed(
    SesameDatabase db, {
    String? owner,
    String? spaceId,
    int export = 100,
  }) async {
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(export: export),
      accountId: owner,
      fitnessSpaceId: spaceId,
      changeRecorder: owner == null
          ? null
          : ChangeRecorderImpl(db, accountIdGetter: () => owner),
    );
  }

  Future<RecoverySession> open() async {
    final file = await backup.createBackup(
      db: source,
      currentAccountId: account,
    );
    final session = await restore.openBackup(backupFile: file);
    addTearDown(session.close);
    return session;
  }

  Future<void> choose(
    RecoverySession session,
    String id,
    RecoveryDecision decision,
  ) async {
    session.fitnessSpaceDecisions[id] = decision;
    session.fitnessTargetSnapshots[id] = await FitnessDataTransfer.fingerprint(
      live,
      id,
    );
  }

  Future<List<FitnessEntityRow>> rows(SesameDatabase db, String id) =>
      (db.select(
        db.fitnessEntities,
      )..where((e) => e.fitnessSpaceId.equals(id))).get();

  test('默认恢复决策直接复用私有本规则，空空间也可独立勾选', () {
    final local = ManifestFitnessSpace(
      book: fixtureFitnessSpace(),
      entityCounts: const {},
      fullyDownloaded: true,
      runningCount: 0,
    );
    expect(
      defaultPrivateBookDecision(RestoreFitnessSpaceItem(local)),
      RestoreDecision.restoreLocal,
    );
    final cloud = ManifestFitnessSpace(
      book: FitnessSpace(
        id: fitnessId(900),
        name: '云空间',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        storageMode: 'cloud',
        scopeAccountId: account,
      ),
      entityCounts: const {},
      fullyDownloaded: true,
      runningCount: 0,
    );
    expect(
      defaultPrivateBookDecision(
        RestoreFitnessSpaceItem(cloud, canReconnect: true),
      ),
      RestoreDecision.reconnect,
    );
    expect(
      defaultPrivateBookDecision(RestoreFitnessSpaceItem(cloud)),
      RestoreDecision.forkCloudToLocal,
    );
  });
  test('快照按父空间过滤账号，保留多个本地与当前账号空间并校验各自计数', () async {
    await seed(source);
    await seed(source, owner: account);
    await seed(source, owner: otherAccount);
    final empty = await seedFitnessTestSpace(source, id: fitnessId(900));
    final session = await open();
    expect(session.manifest.fitnessSpaces.map((s) => s.id).toSet(), {
      testFitnessSpaceId(),
      testFitnessSpaceId(account),
      empty,
    });
    expect(session.manifest.toJson()['contents'], contains('fitness_spaces'));
    expect(
      session.manifest.toJson()['contents'],
      isNot(contains('fitness_sync_scopes')),
    );
    expect(session.recoveryRepository.listFitnessRecords(), hasLength(10));
    expect(
      session.manifest.fitnessSpaces
          .singleWhere((s) => s.id == empty)
          .recordCount,
      0,
    );
    expect(
      session.manifest.fitnessSpaces
          .singleWhere((s) => s.id == testFitnessSpaceId(account))
          .recoveryBranchCount,
      5,
    );
    expect(await live.select(live.fitnessSpaces).get(), isEmpty);
  });
  test('多空间一起恢复：本地同身份覆盖、云端独立复制，其他空间和账号原件保持不变', () async {
    await seed(source);
    await seed(source, owner: account);
    await seed(live);
    await seed(live, owner: account);
    final unrelated = await seedFitnessTestSpace(live, id: fitnessId(901));
    final originalCloud = await FitnessDataTransfer.fingerprint(
      live,
      testFitnessSpaceId(account),
    );
    final session = await open();
    await choose(session, testFitnessSpaceId(), RecoveryDecision.restoreLocal);
    await choose(
      session,
      testFitnessSpaceId(account),
      RecoveryDecision.forkCloudToLocal,
    );
    final report = await restore.apply(
      session: session,
      liveDb: live,
      localSelfId: 'local',
      currentAccountId: account,
    );
    final copied = report.fitnessSpaceResults[testFitnessSpaceId(account)]!;
    expect(
      report.fitnessSpaceResults[testFitnessSpaceId()],
      testFitnessSpaceId(),
    );
    expect(copied, isNot(testFitnessSpaceId(account)));
    expect(await rows(live, copied), hasLength(5));
    expect(await rows(live, testFitnessSpaceId()), hasLength(5));
    expect(
      await FitnessDataTransfer.fingerprint(live, testFitnessSpaceId(account)),
      originalCloud,
    );
    expect(
      await (live.select(
        live.fitnessSpaces,
      )..where((s) => s.id.equals(unrelated))).getSingleOrNull(),
      isNotNull,
    );
    expect(
      (await rows(live, copied)).every(
        (e) =>
            e.scopeAccountId == null &&
            e.syncId == null &&
            e.serverRevision == null,
      ),
      isTrue,
    );
    expect(
      await FitnessDataTransfer.skipped(live, fitnessDocument(), copied),
      5,
    );
  });
  test('恢复空空间只替换同 ID 空间，不能清空整个设备的健身数据', () async {
    final empty = await seedFitnessTestSpace(source, id: fitnessId(900));
    await seed(live);
    final before = await FitnessDataTransfer.fingerprint(
      live,
      testFitnessSpaceId(),
    );
    final session = await open();
    await choose(session, empty, RecoveryDecision.restoreLocal);
    await restore.apply(session: session, liveDb: live, localSelfId: 'local');
    expect(
      await FitnessDataTransfer.fingerprint(live, testFitnessSpaceId()),
      before,
    );
    expect(await rows(live, empty), isEmpty);
    expect(
      await (live.select(
        live.fitnessSpaces,
      )..where((s) => s.id.equals(empty))).getSingleOrNull(),
      isNotNull,
    );
  });
  test('目标预览之后改变时拒绝恢复，并回滚同批先恢复的其他空间', () async {
    await seed(source);
    await seed(source, spaceId: fitnessId(900), export: 101);
    final session = await open();
    for (final space in session.manifest.fitnessSpaces) {
      await choose(session, space.id, RecoveryDecision.restoreLocal);
    }
    await seedFitnessTestSpace(live, id: fitnessId(900));
    await expectLater(
      restore.apply(session: session, liveDb: live, localSelfId: 'local'),
      throwsStateError,
    );
    expect(await rows(live, testFitnessSpaceId()), isEmpty);
    expect(await live.select(live.fitnessImportReceipts).get(), isEmpty);
  });
  test('写入中失败或会话变化整批回滚空间、内容及回执', () async {
    await seed(source);
    final session = await open();
    await choose(session, testFitnessSpaceId(), RecoveryDecision.restoreLocal);
    await live.customStatement(
      "CREATE TRIGGER fail_restore BEFORE INSERT ON fitness_entities BEGIN SELECT RAISE(ABORT,'injected'); END",
    );
    await expectLater(
      restore.apply(session: session, liveDb: live, localSelfId: 'local'),
      throwsA(anything),
    );
    expect(await live.select(live.fitnessSpaces).get(), isEmpty);
    expect(await live.select(live.fitnessImportReceipts).get(), isEmpty);
    await live.customStatement('DROP TRIGGER fail_restore');
    var checks = 0;
    await expectLater(
      restore.apply(
        session: session,
        liveDb: live,
        localSelfId: 'local',
        validateContext: () {
          if (++checks == 2) throw StateError('account changed');
        },
      ),
      throwsStateError,
    );
    expect(await live.select(live.fitnessSpaces).get(), isEmpty);
  });
  test('恢复云端空间保留绑定并登记父恢复屏障，子记录使用新版本意图', () async {
    await seed(source, owner: account);
    await seed(live, owner: account);
    await live.delete(live.syncChanges).go();
    final session = await open();
    await choose(
      session,
      testFitnessSpaceId(account),
      RecoveryDecision.reconnect,
    );
    final report = await restore.apply(
      session: session,
      liveDb: live,
      localSelfId: 'local',
      currentAccountId: account,
    );
    expect(
      report.fitnessSpaceResults[testFitnessSpaceId(account)],
      testFitnessSpaceId(account),
    );
    final changes = await (live.select(
      live.syncChanges,
    )..orderBy([(c) => d.OrderingTerm.asc(c.id)])).get();
    expect(changes.first.entityType, 'fitness_space');
    expect(changes.first.payload, contains('"restore":true'));
    expect(
      changes.every(
        (c) =>
            c.accountId == account &&
            c.fitnessSpaceId == testFitnessSpaceId(account) &&
            c.frozenRequest == null,
      ),
      isTrue,
    );
    // 真实恢复落下的分支必须分别记录原账号和原空间，不能互相代替。
    final conflicts = await live.select(live.syncConflicts).get();
    expect(conflicts, isNotEmpty);
    for (final conflict in conflicts) {
      final payload = jsonDecode(conflict.remotePayload) as Map;
      final origin = payload['source'] as Map;
      expect(origin['account_id'], account);
      expect(origin['fitness_space_id'], testFitnessSpaceId(account));
    }

    // 旧分支没有独立的空间来源字段，恢复读取仍按数据库行保留真实账号。
    final legacy = conflicts.first;
    final legacyPayload =
        jsonDecode(legacy.remotePayload) as Map<String, dynamic>;
    final legacyOrigin = Map<String, dynamic>.from(
      legacyPayload['source'] as Map,
    )..remove('fitness_space_id');
    legacyOrigin['account_id'] = testFitnessSpaceId(account);
    legacyPayload['source'] = legacyOrigin;
    await (live.update(
      live.syncConflicts,
    )..where((row) => row.id.equals(legacy.id))).write(
      SyncConflictsCompanion(remotePayload: d.Value(jsonEncode(legacyPayload))),
    );
    final records = await FitnessDataTransfer.snapshot(
      live,
      fitnessSpaceId: testFitnessSpaceId(account),
      accountId: account,
      requireComplete: false,
    );
    // 父恢复屏障和被拒绝的子意图同时存在，捕获只保护子实体且不能丢失失败意图。
    final failedChild = changes.firstWhere(
      (change) => FitnessTransferFormat.types.contains(change.entityType),
    );
    for (final change in [changes.first, failedChild]) {
      await (live.update(
        live.syncChanges,
      )..where((row) => row.id.equals(change.id))).write(
        const SyncChangesCompanion(
          rejectionReason: d.Value('VALIDATION_FAILED'),
        ),
      );
    }
    final branches = await FitnessDataTransfer.captureBranches(live, records);
    expect(branches, isNotEmpty);
    expect(branches.every((branch) => branch.accountId == account), isTrue);
    expect(
      branches.every(
        (branch) => FitnessTransferFormat.types.contains(branch.entityType),
      ),
      isTrue,
    );
    expect(
      branches.map((branch) => branch.operationId),
      contains('pending:${failedChild.mutationId}'),
    );
    expect(
      (await (live.select(
            live.syncChanges,
          )..where((row) => row.id.equals(changes.first.id))).getSingle())
          .rejectionReason,
      'VALIDATION_FAILED',
      reason: '捕获子分支不能移除或重写独立的父恢复屏障',
    );
  });
  test('不完整空间标记随本地保护副本保留，不能冒充完整导出', () async {
    await seed(source, owner: account);
    await (source.update(source.fitnessSpaces)
          ..where((s) => s.id.equals(testFitnessSpaceId(account))))
        .write(const FitnessSpacesCompanion(isStale: d.Value(true)));
    final session = await open();
    expect(session.manifest.fitnessSpaces.single.fullyDownloaded, isFalse);
    await choose(
      session,
      testFitnessSpaceId(account),
      RecoveryDecision.forkCloudToLocal,
    );
    final report = await restore.apply(
      session: session,
      liveDb: live,
      localSelfId: 'local',
      currentAccountId: account,
    );
    final id = report.fitnessSpaceResults.values.single;
    await expectLater(
      FitnessDataTransfer.snapshot(live, fitnessSpaceId: id),
      throwsStateError,
    );
    expect(await rows(live, id), hasLength(5));
  });
  test('外部备份缺父表、错归属、损坏载荷与清单篡改拒绝于写入前', () async {
    await seed(source);
    final session = await open();
    final file = File('${temp.path}/tampered.sqlite');
    await session.extractedSqliteFile.copy(file.path);
    final db = sql.sqlite3.open(file.path);
    try {
      db.execute("DROP TRIGGER fitness_parent_immutable");
      db.execute("DROP TRIGGER fitness_parent_scope_update");
      db.execute(
        "UPDATE fitness_entities SET fitness_space_id='missing' WHERE entity_type='fitness_template'",
      );
    } finally {
      db.close();
    }
    final manifest = session.manifest.toJson();
    (manifest['fitness_spaces'] as List).add(
      (manifest['fitness_spaces'] as List).first,
    );
    // 非法归属不能被默认为本地空间，否则篡改标签会通过恢复预览。
    final invalidOrigin = session.manifest.toJson();
    ((invalidOrigin['fitness_spaces'] as List).first as Map)['storage_origin'] =
        'UNKNOWN';
    final inspection = await Directory('${temp.path}/inspection').create();
    final importer = BackupImportService(tempDirOverride: inspection);
    final originalSqlite = await session.extractedSqliteFile.readAsBytes();
    final tamperedSqlite = await file.readAsBytes();
    for (final invalid in [
      (
        name: 'missing-fitness-parent',
        manifest: session.manifest.toJson(),
        sqlite: tamperedSqlite,
        reason: BackupOpenError.corrupt,
      ),
      (
        name: 'duplicate-manifest-space',
        manifest: manifest,
        sqlite: originalSqlite,
        reason: BackupOpenError.invalidManifest,
      ),
      (
        name: 'invalid-storage-origin',
        manifest: invalidOrigin,
        sqlite: originalSqlite,
        reason: BackupOpenError.invalidManifest,
      ),
    ]) {
      // 只构造外部输入，所有格式、关系和清单判定仍由真实恢复入口执行。
      final backupFile = await File('${temp.path}/${invalid.name}.snbak')
          .writeAsBytes(
            BackupPayloadCodec.encode(
              Uint8List.fromList(utf8.encode(jsonEncode(invalid.manifest))),
              invalid.sqlite,
            ),
          );
      final original = await backupFile.readAsBytes();
      await expectLater(
        importer.openBackup(backupFile: backupFile),
        throwsA(
          isA<BackupFormatException>().having(
            (error) => error.reason,
            'reason',
            invalid.reason,
          ),
        ),
        reason: invalid.name,
      );
      expect(await backupFile.readAsBytes(), original);
      expect(await inspection.list().toList(), isEmpty);
      expect(await live.select(live.fitnessEntities).get(), isEmpty);
      expect(await live.select(live.syncChanges).get(), isEmpty);
    }
    expect(await live.select(live.fitnessSpaces).get(), isEmpty);
  });
}
