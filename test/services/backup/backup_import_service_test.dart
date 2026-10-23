import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

/// 覆盖恢复身份策略、覆盖语义和写入失败时的整笔事务回滚。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late Directory tmp;
  late SesameDatabase liveDb;
  late BackupImportService importService;

  setUp(() async {
    tmp = await createTestTempDirectory('backup_import_test_');
    liveDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    // 测试环境无 path_provider 平台通道：注入临时目录覆盖
    importService = BackupImportService(tempDirOverride: tmp);
  });

  tearDown(() async {
    try {
      await liveDb.close();
    } catch (_) {}
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  /// 构造含本地与云端账本、成员、分摊和同步事实的确定备份输入。
  Future<File> seedBackupSource() async {
    // SQLite 文件与清单直接组成备份帧，恢复用例只验证读取和写入规则。
    final srcFile = File(
      p.join(
        tmp.path,
        'source_${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    final srcDb = SesameDatabase.withExecutor(NativeDatabase(srcFile));
    try {
      final now = DateTime.utc(2026, 8, 1);
      // 整组夹具在一次事务中提交，备份读取的是完整已提交状态。
      await srcDb.transaction(() async {
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
                scopeAccountId: const d.Value('account-a'),
                ownerAccountId: const d.Value('acc-1'),
                syncId: const d.Value('sync-s1'),
                archiveServerCursor: const d.Value('9223372036854775807'),
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
                accountId: d.Value('account-a'),
                ledgerId: d.Value(cloudId),
                entityType: 'transaction',
                entityId: 'tx-cloud-1',
                localPayload: '{}',
                remotePayload: '{}',
                baseRevision: 1,
                remoteRevision: 5,
                localMutationId: 'm-1',
              ),
            );
      });
      // 合并已提交的 WAL，确保单文件字节包含全部成员、交易和分摊。
      await srcDb.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      final manifest = BackupManifest(
        formatVersion: backupFormatVersion,
        dbSchemaVersion: currentSchemaVersion,
        createdAt: now,
        deviceId: 'dev-src',
        ledgers: const [
          ManifestLedger(
            ledgerBackupId: '11111111-1111-4111-8111-111111111111',
            name: '私人账本',
            storageOrigin: LedgerStorageOrigin.local,
            originalLocalLedgerId: '11111111-1111-4111-8111-111111111111',
            cloudProvider: null,
            originalCloudLedgerId: null,
            originalAccountId: null,
            ownerType: 'OWNER',
            pendingMutationCount: 0,
            openConflictCount: 0,
            lastSyncAt: null,
          ),
          ManifestLedger(
            ledgerBackupId: '22222222-2222-4222-8222-222222222222',
            name: '家庭账本',
            storageOrigin: LedgerStorageOrigin.cloud,
            originalLocalLedgerId: null,
            cloudProvider: 'sesame_notes',
            originalCloudLedgerId: '22222222-2222-4222-8222-222222222222',
            originalAccountId: 'acc-1',
            ownerType: 'OWNER',
            pendingMutationCount: 1,
            openConflictCount: 1,
            lastSyncAt: null,
          ),
        ],
        accounts: const [
          ManifestAccount(accountId: 'acc-1', accountName: 'Alice'),
        ],
      );
      final backup = File(p.join(tmp.path, 'recovery.snbak'));
      await backup.writeAsBytes(
        BackupPayloadCodec.encode(
          BackupManifestCodec.encodeJson(manifest),
          await srcFile.readAsBytes(),
        ),
        flush: true,
      );
      return backup;
    } catch (error, stackTrace) {
      stderr.writeln('构造备份测试夹具失败：$error\n$stackTrace');
      rethrow;
    } finally {
      // 源连接只服务于夹具构造，返回备份文件前即释放文件句柄。
      await srcDb.close();
    }
  }

  test('apply：本地无冲突原 identity + 云端永远 Fork + skip 不写 + recovery_log', () async {
    final backup = await seedBackupSource();
    final session = await importService.openBackup(backupFile: backup);
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

  test('apply：本地同 ID 冲突且目标为本地账本 → 覆盖（备份快照替换现有数据）', () async {
    final backup = await seedBackupSource();
    final sourceId = '11111111-1111-4111-8111-111111111111';
    final now = DateTime.utc(2026, 8, 2);
    // live 库已有同 ID 本地账本，且数据比备份更新：改名 + 新交易 + 新成员 +
    // 残留同步队列行。恢复后这些「更新的数据」必须被备份快照整体替换。
    await liveDb
        .into(liveDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sourceId,
            name: '私人账本（新）',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await liveDb
        .into(liveDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'local-self-live',
            ledgerId: sourceId,
            displayName: '我',
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    await liveDb
        .into(liveDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-live-new',
            ledgerId: sourceId,
            txType: 'expense',
            amount: '999',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '999',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await liveDb
        .into(liveDb.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx-live-new',
            ledgerId: d.Value(sourceId),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: 'm-live',
          ),
        );

    final session = await importService.openBackup(backupFile: backup);
    final items = await importService.listRecoveryItems(session);
    final localItem = items.singleWhere(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    session.decisions[localItem.ledgerBackupId] = RecoveryDecision.restoreLocal;

    final report = await importService.apply(
      session: session,
      liveDb: liveDb,
      localSelfId: 'self-live',
    );

    // 覆盖不 Fork：目标 id = 备份账本原 id，同名账本只有一个
    final entry = report.entries.singleWhere(
      (e) => e.decision == RecoveryDecision.restoreLocal,
    );
    expect(entry.targetLedgerId, sourceId, reason: '同 ID 本地账本覆盖不生成新 id');
    expect(entry.detail, 'overwrite');
    final restored = await (liveDb.select(
      liveDb.ledgers,
    )..where((l) => l.id.equals(sourceId))).getSingle();
    expect(restored.name, '私人账本', reason: '现有改名被备份快照替换');
    expect(restored.storageMode, 'local');
    expect(restored.syncId, isNull);
    expect(restored.originType, 'LOCAL_BACKUP');
    expect(restored.originLedgerId, sourceId);
    final sameName = await (liveDb.select(
      liveDb.ledgers,
    )..where((l) => l.name.equals('私人账本'))).get();
    expect(sameName, hasLength(1), reason: '覆盖不得产生第二个同名账本');

    // 现有更新的交易被清除，只剩备份快照的交易（金额 5）
    final txs = await (liveDb.select(
      liveDb.transactions,
    )..where((t) => t.ledgerId.equals(sourceId))).get();
    expect(txs, hasLength(1));
    expect(txs.single.amount, '5');
    // 旧成员被级联清除，恢复按「我是谁」规则重建 self
    final members = await (liveDb.select(
      liveDb.ledgerMembers,
    )..where((m) => m.ledgerId.equals(sourceId))).get();
    expect(members.map((m) => m.id), isNot(contains('local-self-live')));
    // 残留同步队列行被清除
    expect(
      await (liveDb.select(
        liveDb.syncChanges,
      )..where((c) => c.ledgerId.equals(sourceId))).get(),
      isEmpty,
    );
    // 审计日志记录覆盖动作（云端账本未决策 → skip 也写日志，按 action 过滤）
    final log = (await liveDb.select(liveDb.recoveryLogs).get()).singleWhere(
      (l) => l.action == 'restore_local',
    );
    expect(log.detail, contains('overwrite'));
    await session.close();
  });

  test('apply：单事务——中途失败整体回滚，live DB 不变', () async {
    final backup = await seedBackupSource();
    final session = await importService.openBackup(backupFile: backup);
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
}
