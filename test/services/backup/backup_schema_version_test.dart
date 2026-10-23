import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';

import '../../helpers/test_isolation.dart';
import '../../helpers/database_schema_fixture.dart';

final _sourceVersionTime = DateTime.utc(2026, 10, 10, 12, 0, 0, 947);

/// 创建当前结构备份；仅版本边界用例会修改 SQLite 的版本标记。
Future<({File sqlite, File backup, BackupManifest manifest})> _backupFixture(
  Directory workspace, {
  int sourceVersion = currentSchemaVersion,
  bool includeAccountingRequests = false,
}) async {
  try {
    final file = File(p.join(workspace.path, 'source.sqlite'));
    final db = SesameDatabase.withExecutor(NativeDatabase(file));
    try {
      await db.customSelect('SELECT 1').get();
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'source-ledger',
              name: '快照账本',
              updatedAt: _sourceVersionTime,
            ),
          );
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: schemaFixtureMember,
              ledgerId: 'source-ledger',
              displayName: '快照成员',
              memberType: 'PLACEHOLDER',
              updatedAt: _sourceVersionTime,
            ),
          );
      await db.customStatement(
        "INSERT INTO categories(id,name,kind,level,updated_at) VALUES('category','订阅服务','expense',1,1000)",
      );
      await db.customStatement(
        'INSERT INTO sync_changes(entity_type,entity_id,action,payload,updated_at,'
        'mutation_id,frozen_request,account_id,rejection_reason) '
        "VALUES('category','category','upsert',?,?,'original-mutation',?,'account-a',?)",
        [
          '{ "name": "订阅服务", "level": "1" }\n',
          1000,
          '{"mutation_id":"original-mutation","payload":{"level":"1"}}',
          '记录内容未通过服务端校验，请检查并编辑后保存',
        ],
      );
      await db.customStatement(
        "INSERT INTO sync_state(account_id,device_id) VALUES('account-a','unknown')",
      );
      await db.customStatement(
        "INSERT INTO sync_state(account_id,device_id,server_cursor) VALUES('account-a','completed-zero','0')",
      );
    } finally {
      await db.close();
    }
    final raw = sqlite3.open(file.path);
    try {
      if (includeAccountingRequests) {
        raw.execute(
          'INSERT INTO transactions(id,ledger_id,tx_type,amount,happened_at,currency_code,native_amount,created_at,updated_at,note) '
          "VALUES('source-tx','source-ledger','expense','12.34',1000,'CNY','12.34',1000,2000,'早餐')",
        );
        raw.execute(
          'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,action,payload,updated_at,mutation_id,frozen_request,account_id) '
          "VALUES('transaction','source-tx','source-ledger','upsert',?,2000,'transaction-mutation',?,'account-a')",
          [
            '{"amount":"12.34"}',
            '{"mutation_id":"transaction-mutation","payload":{"amount":"12.34"}}',
          ],
        );
        raw.execute(
          'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,action,payload,updated_at,mutation_id,frozen_request,account_id) '
          "VALUES('recurring_transaction','source-rule','source-ledger','upsert',?,2000,'recurring-mutation',?,'account-a')",
          [
            '{"initial_state":{"occurrences":[{"payload":{"amount":"12.34"}}]}}',
            '{"mutation_id":"recurring-mutation","payload":{"initial_state":{"occurrences":[{"payload":{"amount":"12.34"}}]}}}',
          ],
        );
      }
      raw.execute('PRAGMA user_version=$sourceVersion');
    } finally {
      raw.close();
    }
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      dbSchemaVersion: sourceVersion,
      createdAt: DateTime.utc(2026, 10, 10),
      deviceId: 'backup-device',
      ledgers: const [
        ManifestLedger(
          ledgerBackupId: 'source-ledger',
          name: '快照账本',
          storageOrigin: LedgerStorageOrigin.local,
          originalLocalLedgerId: 'source-ledger',
          cloudProvider: null,
          originalCloudLedgerId: null,
          originalAccountId: null,
          ownerType: 'OWNER',
          pendingMutationCount: 0,
          openConflictCount: 0,
          lastSyncAt: null,
        ),
      ],
      accounts: const [],
    );
    final backup = File(p.join(workspace.path, 'source.snbak'));
    await backup.writeAsBytes(
      BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(manifest),
        await file.readAsBytes(),
      ),
    );
    return (sqlite: file, backup: backup, manifest: manifest);
  } catch (error, stackTrace) {
    debugPrint('生成历史备份夹具失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 真实历史结构含未知冻结证据；恢复只复制业务内容，不能据此拒绝整份备份。
Future<
  ({
    File sqlite,
    File backup,
    BackupManifest manifest,
    List<Map<String, Object?>> queueEvidence,
  })
>
_historicalBackupFixture(Directory workspace, int version) async {
  final file = File(p.join(workspace.path, 'historical-$version.sqlite'));
  await createHistoricalDatabaseFixture(file, version);
  final raw = sqlite3.open(file.path);
  late List<Map<String, Object?>> evidence;
  try {
    raw.execute("UPDATE ledgers SET deleted_at=NULL WHERE id='ledger'");
    raw.execute(
      'INSERT INTO transactions(id,ledger_id,tx_type,amount,happened_at,currency_code,native_amount,created_at,updated_at,note) '
      "VALUES('historical-tx','ledger','expense','12.34',1000,'CNY','12.34',1000,2000,'早餐')",
    );
    raw.execute(
      "UPDATE transactions SET payer_member_id=? WHERE id='historical-tx'",
      [schemaFixtureMember],
    );
    raw.execute(
      'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,action,payload,updated_at,mutation_id,frozen_request,account_id,base_revision,rejection_reason) '
      "VALUES('transaction','historical-tx','ledger','upsert',?,?,'unknown-result',?,'original-account',2,?)",
      [
        '{ "amount": "12.34", "exclude_from_stats": true }\n',
        version < 6 ? schemaFixtureTimestamp ~/ 1000 : schemaFixtureTimestamp,
        '{"mutation_id":"unknown-result","payload":{"amount":"12.34","exclude_from_stats":true}}',
        null,
      ],
    );
    evidence = [
      for (final row in raw.select(
        'SELECT entity_id,mutation_id,payload,frozen_request,account_id,base_revision,pushed_at,rejection_reason FROM sync_changes ORDER BY id',
      ))
        Map<String, Object?>.from(row),
    ];
  } finally {
    raw.close();
  }
  final sourceTime = version < 8
      ? schemaFixtureTimestamp ~/ 1000 * 1000
      : schemaFixtureTimestamp;
  final manifest = BackupManifest(
    formatVersion: backupFormatVersion,
    dbSchemaVersion: version,
    createdAt: DateTime.utc(2026, 10, 10),
    // 安装来源标识不等于同步会话设备，预览不能把它用于登录或队列激活。
    deviceId: 'backup-installation-id',
    ledgers: [
      ManifestLedger(
        ledgerBackupId: 'ledger',
        name: '原账本',
        storageOrigin: LedgerStorageOrigin.local,
        originalLocalLedgerId: 'ledger',
        cloudProvider: null,
        originalCloudLedgerId: null,
        originalAccountId: null,
        ownerType: 'OWNER',
        pendingMutationCount: 1,
        openConflictCount: 0,
        lastSyncAt: DateTime.fromMillisecondsSinceEpoch(
          sourceTime,
          isUtc: true,
        ),
      ),
    ],
    accounts: const [],
  );
  final backup = await File(p.join(workspace.path, 'historical-$version.snbak'))
      .writeAsBytes(
        BackupPayloadCodec.encode(
          BackupManifestCodec.encodeJson(manifest),
          await file.readAsBytes(),
        ),
      );
  return (
    sqlite: file,
    backup: backup,
    manifest: manifest,
    queueEvidence: evidence,
  );
}

/// 已知旧结构只升级提取副本，当前结构直接恢复，未知版本保持拒绝。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);
  late Directory workspace;
  late SesameDatabase live;

  setUp(() async {
    workspace = await createTestTempDirectory('backup_schema_');
    live = SesameDatabase.withExecutor(NativeDatabase.memory());
    await live.customStatement(
      "INSERT INTO ledgers(id,name,updated_at) VALUES('live-ledger','当前账本',1000)",
    );
  });

  tearDown(() async {
    await live.close();
    await workspace.delete(recursive: true);
  });

  /// 失败协议和隔离边界通过真实恢复入口验证，不在夹具中重写校验规则。
  Future<void> expectRejectedBackup(File backup, BackupOpenError reason) async {
    try {
      final original = await backup.readAsBytes();
      final before = await live.select(live.ledgers).get();
      final inspection = await Directory(
        p.join(workspace.path, 'inspection'),
      ).create();
      final importer = BackupImportService(tempDirOverride: inspection);
      await expectLater(
        importer.openBackup(backupFile: backup),
        throwsA(
          isA<BackupFormatException>().having(
            (error) => error.reason,
            'reason',
            reason,
          ),
        ),
      );
      expect(await backup.readAsBytes(), original);
      expect(await live.select(live.ledgers).get(), before);
      expect(await live.select(live.syncChanges).get(), isEmpty);
      expect(await inspection.list().toList(), isEmpty);
    } catch (error, stackTrace) {
      debugPrint('真实恢复入口拒绝测试失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    }
  }

  for (final version in [currentSchemaVersion]) {
    test('schema$version预览保留毫秒、冻结字节，原备份与主库不变', () async {
      final fixture = await _backupFixture(workspace, sourceVersion: version);
      final original = await fixture.backup.readAsBytes();
      final rawOriginal = await fixture.sqlite.readAsBytes();
      final importer = BackupImportService(tempDirOverride: workspace);
      final session = await importer.openBackup(backupFile: fixture.backup);
      try {
        expect(session.manifest.toJson(), {
          ...fixture.manifest.toJson(),
          'db_schema_version': currentSchemaVersion,
        });
        final pending = await session.sourceDb
            .select(session.sourceDb.syncChanges)
            .getSingle();
        expect(pending.rejectionCode, null, reason: '预览不得改写已有拒收事实');
        expect(pending.mutationId, 'original-mutation');
        expect(pending.payload, '{ "name": "订阅服务", "level": "1" }\n');
        expect(pending.accountId, 'account-a');
        final ledger = await session.sourceDb
            .select(session.sourceDb.ledgers)
            .getSingle();
        expect(
          ledger.updatedAt.millisecondsSinceEpoch,
          _sourceVersionTime.millisecondsSinceEpoch,
          reason: '当前备份保留原毫秒精度',
        );
        final member = await session.sourceDb
            .select(session.sourceDb.ledgerMembers)
            .getSingle();
        expect(
          member.updatedAt,
          _sourceVersionTime,
          reason: '当前成员版本的毫秒直接保留，不再执行秒转换',
        );
        expect(
          pending.frozenRequest,
          '{"mutation_id":"original-mutation","payload":{"level":"1"}}',
        );
        final preview = await importer.listRecoveryItems(session);
        expect(preview.single.name, '快照账本');
        final watermarks = await session.sourceDb
            .select(session.sourceDb.syncState)
            .get();
        expect(
          watermarks
              .singleWhere((row) => row.deviceId == 'unknown')
              .serverCursor,
          isNull,
        );
        expect(
          watermarks
              .singleWhere((row) => row.deviceId == 'completed-zero')
              .serverCursor,
          '0',
        );
        expect((await live.select(live.ledgers).getSingle()).name, '当前账本');
        expect(await fixture.backup.readAsBytes(), original);
        expect(await fixture.sqlite.readAsBytes(), rawOriginal);
      } finally {
        await session.close();
      }
    });
  }

  for (final version in [4, 5, 6, 7, 8, 9]) {
    test('schema$version自动升级副本并恢复业务，原件和冻结证据保留', () async {
      final fixture = await _historicalBackupFixture(workspace, version);
      final originalBackup = await fixture.backup.readAsBytes();
      final originalSqlite = await fixture.sqlite.readAsBytes();
      final importer = BackupImportService(tempDirOverride: workspace);
      final session = await importer.openBackup(backupFile: fixture.backup);
      try {
        expect(session.manifest.toJson(), {
          ...fixture.manifest.toJson(),
          'db_schema_version': currentSchemaVersion,
        });
        expect(session.manifest.deviceId, 'backup-installation-id');
        final queue = await session.sourceDb
            .customSelect(
              'SELECT entity_id,mutation_id,payload,frozen_request,account_id,base_revision,pushed_at,rejection_reason FROM sync_changes ORDER BY id',
            )
            .get();
        expect(queue.map((row) => row.data).toList(), fixture.queueEvidence);
        final pending = await session.sourceDb
            .select(session.sourceDb.syncChanges)
            .getSingle();
        expect(
          pending.updatedAt.millisecondsSinceEpoch,
          version < 6
              ? schemaFixtureTimestamp ~/ 1000 * 1000
              : schemaFixtureTimestamp,
        );
        final watermarks = await session.sourceDb
            .select(session.sourceDb.syncState)
            .getSingle();
        expect(watermarks.accountId, schemaFixtureAccount);
        expect(watermarks.deviceId, schemaFixtureDevice);
        expect(watermarks.serverCursor, version < 9 ? null : '0');
        expect(watermarks.dayEventsCursor, version < 9 ? null : '123');
        expect(watermarks.memosCursor, version < 9 ? null : '123');
        expect(watermarks.fitnessCursor, version < 9 ? null : '123');
        expect(watermarks.lastPushAt?.millisecondsSinceEpoch, 100000);
        expect(watermarks.lastPullAt?.millisecondsSinceEpoch, 200000);
        final members = await session.sourceDb
            .select(session.sourceDb.ledgerMembers)
            .get();
        expect(members, hasLength(2));
        for (final member in members) {
          expect(
            member.updatedAt.millisecondsSinceEpoch,
            schemaFixtureTimestamp ~/ 1000 * 1000,
          );
          expect(
            member.joinedAt.millisecondsSinceEpoch,
            (schemaFixtureTimestamp ~/ 1000 - 50) * 1000,
          );
          expect(
            member.createdAt.millisecondsSinceEpoch,
            (schemaFixtureTimestamp ~/ 1000 - 100) * 1000,
          );
          expect(
            member.deletedAt?.millisecondsSinceEpoch,
            member.id == schemaFixtureDeletedMember
                ? (schemaFixtureTimestamp ~/ 1000 + 20) * 1000
                : null,
          );
        }

        final preview = await importer.listRecoveryItems(session);
        expect(preview.single.transactionCount, 1);
        expect(preview.single.expenseTotal, 12.34);
        expect(preview.single.pendingCount, 1);
        expect(preview.single.memberCount, 1, reason: '提取升级不复活成员墓碑');
        final ledger = await session.sourceDb
            .select(session.sourceDb.ledgers)
            .getSingle();
        expect(
          ledger.updatedAt.millisecondsSinceEpoch,
          version < 8
              ? schemaFixtureTimestamp ~/ 1000 * 1000
              : schemaFixtureTimestamp,
        );
        expect(await live.select(live.transactions).get(), isEmpty);
        session.decisions['ledger'] = RecoveryDecision.restoreLocal;
        final result = await importer.apply(
          session: session,
          liveDb: live,
          localSelfId: 'self-live',
        );
        expect(result.entries.single.success, isTrue);
        final transaction = await live.select(live.transactions).getSingle();
        expect((transaction.amount, transaction.note), ('12.34', '早餐'));
        final restoredMembers = await live.select(live.ledgerMembers).get();
        final payer = restoredMembers.singleWhere(
          (member) => member.id == transaction.payerMemberId,
        );
        expect(payer.displayName, '历史成员');
        expect(payer.ledgerId, transaction.ledgerId);
        expect(
          restoredMembers.where((member) => member.displayName == '历史删除成员'),
          isEmpty,
        );
        expect(await live.select(live.syncChanges).get(), isEmpty);
        expect(await live.select(live.syncState).get(), isEmpty);
        expect(await fixture.backup.readAsBytes(), originalBackup);
        expect(await fixture.sqlite.readAsBytes(), originalSqlite);
      } finally {
        await session.close();
      }
      // 同一历史原件仍可再次打开，不会被上一次预览或恢复改写成当前版本。
      final reopened = await importer.openBackup(backupFile: fixture.backup);
      try {
        expect(reopened.manifest.dbSchemaVersion, currentSchemaVersion);
        expect(
          (await importer.listRecoveryItems(reopened)).single.expenseTotal,
          12.34,
        );
        expect(
          (await reopened.sourceDb
                  .select(reopened.sourceDb.ledgerMembers)
                  .get())
              .map((member) => member.updatedAt.millisecondsSinceEpoch),
          everyElement(schemaFixtureTimestamp ~/ 1000 * 1000),
          reason: '每次只升级独立提取副本，不修改原备份或重复放大成员时间',
        );
      } finally {
        await reopened.close();
      }
      expect(await fixture.backup.readAsBytes(), originalBackup);
    });
  }

  test('含现行冻结请求的备份可恢复记账，提取副本和工作库均保留原请求', () async {
    final fixture = await _backupFixture(
      workspace,
      sourceVersion: currentSchemaVersion,
      includeAccountingRequests: true,
    );
    final backupBytes = await fixture.backup.readAsBytes();
    final sourceBytes = await fixture.sqlite.readAsBytes();
    await live.customStatement(
      'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,action,payload,updated_at,mutation_id,frozen_request) '
      "VALUES('transaction','live-tx','live-ledger','upsert','{}',1000,'live-pending',?)",
      ['{"mutation_id":"live-pending","payload":{"amount":"9"}}'],
    );
    final existingQueue = await live.select(live.syncChanges).get();
    final importer = BackupImportService(tempDirOverride: workspace);
    final session = await importer.openBackup(backupFile: fixture.backup);
    try {
      final preview = await importer.listRecoveryItems(session);
      expect(preview.single.transactionCount, 1);
      expect(preview.single.expenseTotal, 12.34);
      final isolatedQueue = await session.sourceDb
          .select(session.sourceDb.syncChanges)
          .get();
      for (final entry in isolatedQueue.where(
        (entry) => entry.entityType != 'category',
      )) {
        final expectedPayload = entry.entityType == 'transaction'
            ? '{"amount":"12.34"}'
            : '{"initial_state":{"occurrences":[{"payload":{"amount":"12.34"}}]}}';
        final expectedMutation = entry.entityType == 'transaction'
            ? 'transaction-mutation'
            : 'recurring-mutation';
        expect(entry.payload, expectedPayload);
        expect(entry.mutationId, expectedMutation);
        expect(
          entry.frozenRequest,
          '{"mutation_id":"$expectedMutation","payload":$expectedPayload}',
        );
        expect(entry.pushedAt, isNull);
      }
      expect(
        isolatedQueue
            .singleWhere((entry) => entry.entityType == 'category')
            .frozenRequest,
        isNotNull,
      );
      session.decisions['source-ledger'] = RecoveryDecision.restoreLocal;
      final report = await importer.apply(
        session: session,
        liveDb: live,
        localSelfId: 'self-live',
      );
      expect(report.entries.single.success, isTrue);
      final restored = await live.select(live.transactions).getSingle();
      expect((restored.amount, restored.note), ('12.34', '早餐'));
      expect(await live.select(live.syncChanges).get(), existingQueue);
      expect(await fixture.backup.readAsBytes(), backupBytes);
      expect(await fixture.sqlite.readAsBytes(), sourceBytes);
    } catch (error, stackTrace) {
      debugPrint('含冻结请求的备份内容恢复失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    } finally {
      await session.close();
    }
  });

  for (final liveCursor in <String?>[null, '0', '900719925474099312345']) {
    test('本地恢复保留活动同步进度，记账水位=$liveCursor', () async {
      RecoverySession? session;
      try {
        final fixture = await _backupFixture(
          workspace,
          includeAccountingRequests: true,
        );
        final raw = sqlite3.open(fixture.sqlite.path);
        try {
          // 同账号设备的备份进度与活动库冲突，另有仅存在于备份中的设备。
          raw.execute(
            'UPDATE sync_state SET server_cursor=?,day_events_cursor=?,memos_cursor=?,fitness_cursor=?,last_push_at=?,last_pull_at=? '
            'WHERE account_id=? AND device_id=?',
            ['321', '41', '42', '43', 3000, 4000, 'account-a', 'unknown'],
          );
          raw.execute(
            'INSERT INTO sync_state(account_id,device_id,server_cursor) VALUES(?,?,?)',
            ['account-a', 'backup-only', '654'],
          );
        } finally {
          raw.close();
        }
        await fixture.backup.writeAsBytes(
          BackupPayloadCodec.encode(
            BackupManifestCodec.encodeJson(fixture.manifest),
            await fixture.sqlite.readAsBytes(),
          ),
        );

        // 同设备、其他设备和其他账号均属于当前库的消费进度，恢复内容不得替换这些事实。
        for (final values in <List<Object?>>[
          ['account-a', 'unknown', liveCursor, '12', '0', '34', 111000, 222000],
          ['account-a', 'completed-zero', '777', null, '23', '0', null, 333000],
          ['account-a', 'other-device', '888', '45', null, '67', 444000, null],
          ['account-b', 'unknown', null, '78', '89', null, 555000, 666000],
        ]) {
          await live.customStatement(
            'INSERT INTO sync_state(account_id,device_id,server_cursor,day_events_cursor,memos_cursor,fitness_cursor,last_push_at,last_pull_at) '
            'VALUES(?,?,?,?,?,?,?,?)',
            values,
          );
        }
        final progressBefore = [
          for (final row
              in await live
                  .customSelect(
                    'SELECT * FROM sync_state ORDER BY account_id,device_id',
                  )
                  .get())
            Map<String, Object?>.from(row.data),
        ];
        final importer = BackupImportService(tempDirOverride: workspace);
        session = await importer.openBackup(backupFile: fixture.backup);
        final sourceProgress = await session.sourceDb
            .select(session.sourceDb.syncState)
            .get();
        expect(
          sourceProgress
              .singleWhere((row) => row.deviceId == 'unknown')
              .serverCursor,
          '321',
        );
        expect(
          sourceProgress.any((row) => row.deviceId == 'backup-only'),
          isTrue,
        );
        session.decisions['source-ledger'] = RecoveryDecision.restoreLocal;

        final report = await importer.apply(
          session: session,
          liveDb: live,
          localSelfId: 'self-live',
          currentAccountId: 'account-a',
        );

        expect(report.entries.single.success, isTrue);
        final restored = await live.select(live.transactions).getSingle();
        expect((restored.amount, restored.note), ('12.34', '早餐'));
        expect(
          [
            for (final row
                in await live
                    .customSelect(
                      'SELECT * FROM sync_state ORDER BY account_id,device_id',
                    )
                    .get())
              Map<String, Object?>.from(row.data),
          ],
          progressBefore,
          reason: '业务恢复必须成功，所有账号设备的游标和推拉时间仍逐字段保留',
        );
      } catch (error, stackTrace) {
        debugPrint('本地恢复消费进度边界失败：记账水位=$liveCursor，$error\n$stackTrace');
        rethrow;
      } finally {
        await session?.close();
      }
    });
  }

  test('真实恢复入口拒绝未知历史和未来结构，原备份、原 SQLite 和主库均不修改', () async {
    final fixture = await _backupFixture(workspace);
    final rawOriginal = await fixture.sqlite.readAsBytes();
    for (final version in [0, 1, 2, 3, currentSchemaVersion + 1, 99]) {
      final manifest = BackupManifest.fromJson({
        ...fixture.manifest.toJson(),
        'db_schema_version': version,
      });
      final backup =
          await File(
            p.join(workspace.path, 'unsupported-$version.snbak'),
          ).writeAsBytes(
            BackupPayloadCodec.encode(
              BackupManifestCodec.encodeJson(manifest),
              rawOriginal,
            ),
          );
      await expectRejectedBackup(backup, BackupOpenError.unsupportedSchema);
    }
    expect(await fixture.sqlite.readAsBytes(), rawOriginal);
  });

  test('当前清单不能让其他 SQLite 版本通过，隔离文件清理且来源字节保留', () async {
    final fixture = await _backupFixture(workspace);
    for (final version in [7, 8, 9, currentSchemaVersion + 1]) {
      final raw = sqlite3.open(fixture.sqlite.path);
      try {
        raw.execute('PRAGMA user_version=$version');
      } finally {
        raw.close();
      }
      final sourceBytes = await fixture.sqlite.readAsBytes();
      final backup =
          await File(
            p.join(workspace.path, 'mismatched-$version.snbak'),
          ).writeAsBytes(
            BackupPayloadCodec.encode(
              BackupManifestCodec.encodeJson(fixture.manifest),
              sourceBytes,
            ),
          );
      await expectRejectedBackup(backup, BackupOpenError.corrupt);
      expect(await fixture.sqlite.readAsBytes(), sourceBytes);
    }
  });

  test('历史数据升级失败时清理隔离副本，原备份和活动库完整保留', () async {
    final fixture = await _historicalBackupFixture(workspace, 7);
    final raw = sqlite3.open(fixture.sqlite.path);
    try {
      raw.execute(
        "UPDATE ledgers SET updated_at='invalid-time' WHERE id='ledger'",
      );
    } finally {
      raw.close();
    }
    final sourceBytes = await fixture.sqlite.readAsBytes();
    final backup = await File(p.join(workspace.path, 'invalid-upgrade.snbak'))
        .writeAsBytes(
          BackupPayloadCodec.encode(
            BackupManifestCodec.encodeJson(fixture.manifest),
            sourceBytes,
          ),
        );
    await expectRejectedBackup(backup, BackupOpenError.corrupt);
    expect(await fixture.sqlite.readAsBytes(), sourceBytes);
    expect((await live.select(live.ledgers).getSingle()).name, '当前账本');
  });

  test('schema9成员编辑时间无法安全升级时拒绝恢复并保留原件和主库', () async {
    final fixture = await _historicalBackupFixture(workspace, 9);
    final raw = sqlite3.open(fixture.sqlite.path);
    try {
      raw.execute('UPDATE ledger_members SET updated_at=? WHERE id=?', [
        253402300800,
        schemaFixtureMember,
      ]);
    } finally {
      raw.close();
    }
    final sourceBytes = await fixture.sqlite.readAsBytes();
    final backup =
        await File(
          p.join(workspace.path, 'invalid-member-upgrade.snbak'),
        ).writeAsBytes(
          BackupPayloadCodec.encode(
            BackupManifestCodec.encodeJson(fixture.manifest),
            sourceBytes,
          ),
        );
    await expectRejectedBackup(backup, BackupOpenError.corrupt);
    expect(await fixture.sqlite.readAsBytes(), sourceBytes);
    expect((await live.select(live.ledgers).getSingle()).name, '当前账本');
    expect(await live.select(live.ledgerMembers).get(), isEmpty);
  });
}
