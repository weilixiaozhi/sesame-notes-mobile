import 'dart:convert';
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

final _sourceVersionTime = DateTime.utc(2026, 10, 10, 12, 0, 0, 947);

/// 创建当前结构备份，保留原始内容和同步证据。
Future<({File sqlite, File backup, BackupManifest manifest})> _backupFixture(
  Directory workspace, {
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
              id: '20000000-0000-4000-8000-000000000011',
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
    } finally {
      raw.close();
    }
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      dbSchemaVersion: currentSchemaVersion,
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
    debugPrint('生成备份夹具失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 当前结构只读恢复，其他版本拒绝且保留原件与活动数据。
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

  test('当前结构预览保留毫秒、冻结字节，原备份与主库不变', () async {
    final fixture = await _backupFixture(workspace);
    final manifestJson = fixture.manifest.toJson();
    final ledgerJson =
        (manifestJson['ledgers'] as List).single as Map<String, dynamic>;
    expect(ledgerJson, isNot(contains('last_sync_at')));
    // 可选展示元数据不参与恢复，读取只依赖当前声明字段。
    ledgerJson.addAll({
      'last_sync_at': _sourceVersionTime.toIso8601String(),
      'extra_display_notes': {'title': '附加展示信息'},
    });
    await fixture.backup.writeAsBytes(
      BackupPayloadCodec.encode(
        utf8.encode(jsonEncode(manifestJson)),
        await fixture.sqlite.readAsBytes(),
      ),
    );
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
      expect(member.updatedAt, _sourceVersionTime, reason: '成员编辑时间保持原毫秒精度');
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
        watermarks.singleWhere((row) => row.deviceId == 'unknown').serverCursor,
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

  test('含现行冻结请求的备份可恢复记账，提取副本和工作库均保留原请求', () async {
    final fixture = await _backupFixture(
      workspace,
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
    for (final version in [
      ...List.generate(currentSchemaVersion, (version) => version),
      currentSchemaVersion + 1,
      99,
    ]) {
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
}
