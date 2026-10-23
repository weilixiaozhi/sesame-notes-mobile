import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalLedgerRepository repo;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalLedgerRepository(db, accountIdGetter: () => 'acc-1');
  });

  tearDown(() async => db.close());

  /// 构造一个含完整数据的云端源账本：owner + placeholder + local self 成员、
  /// 交易（payer/created_by 引用成员）、AA 分摊、编辑历史、pending 队列、OPEN 冲突。
  Future<String> seedCloudLedger({SesameDatabase? backupDb}) async {
    final sourceDatabase = backupDb ?? db;
    try {
      final ledgerId = '11111111-1111-4111-8111-111111111111';
      final now = DateTime.utc(2026, 8, 1);
      // owner（REGISTERED，绑定账号 acc-1）：云端账本的 self 是 REGISTERED 成员
      final ownerId = registeredMemberId(ledgerId, 'acc-1');
      await sourceDatabase
          .into(sourceDatabase.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: '家庭账本',
              currency: const d.Value('CNY'),
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('acc-1'),
              ownerAccountId: const d.Value('acc-1'),
              syncId: const d.Value('sync-s1'),
              selfMemberId: d.Value(ownerId),
              updatedAt: now,
            ),
          );
      await sourceDatabase
          .into(sourceDatabase.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: ownerId,
              ledgerId: ledgerId,
              displayName: 'Alice',
              memberType: 'REGISTERED',
              linkedAccountId: const d.Value('acc-1'),
              role: const d.Value('owner'),
              updatedAt: now,
            ),
          );
      // 占位成员（原虚拟用户，AA 参与人）
      await sourceDatabase
          .into(sourceDatabase.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: 'member-placeholder-1',
              ledgerId: ledgerId,
              displayName: '张三',
              memberType: 'PLACEHOLDER',
              updatedAt: now,
            ),
          );
      // LOCAL self（本机成员，Fork 时不复制、按 localSelfId 重新派生）
      await sourceDatabase
          .into(sourceDatabase.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: 'member-local-self',
              ledgerId: ledgerId,
              displayName: '',
              memberType: 'LOCAL',
              role: const d.Value('owner'),
              updatedAt: now,
            ),
          );
      // 交易：payer=Alice，created_by=Alice，AA 分摊含张三
      await sourceDatabase
          .into(sourceDatabase.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-1',
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '100',
              happenedAt: now,
              currencyCode: 'CNY',
              nativeAmount: '100',
              createdByMemberId: d.Value(ownerId),
              payerMemberId: d.Value(ownerId),
              aaMode: d.Value(2),
              serverRevision: d.Value(7),
              version: d.Value(3),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await sourceDatabase.batch((b) {
        b.insertAll(sourceDatabase.transactionSplits, [
          TransactionSplitsCompanion.insert(
            transactionId: 'tx-1',
            memberId: ownerId,
            amount: '60',
          ),
          TransactionSplitsCompanion.insert(
            transactionId: 'tx-1',
            memberId: 'member-placeholder-1',
            amount: '40',
          ),
        ]);
      });
      await sourceDatabase
          .into(sourceDatabase.recordEditHistories)
          .insert(
            RecordEditHistoriesCompanion.insert(
              recordId: 'tx-1',
              version: 2,
              operatorMemberId: d.Value(ownerId),
              summary: '改金额',
              createdAt: d.Value(now),
            ),
          );
      // pending 队列 + OPEN 冲突（不得随 Fork 复制）
      await sourceDatabase
          .into(sourceDatabase.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: 'tx-2',
              ledgerId: d.Value(ledgerId),
              action: 'upsert',
              payload: '{}',
              updatedAt: now,
              mutationId: 'm-1',
            ),
          );
      await sourceDatabase
          .into(sourceDatabase.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: 'conflict-1',
              accountId: d.Value('account'),
              ledgerId: d.Value(ledgerId),
              entityType: 'transaction',
              entityId: 'tx-1',
              localPayload: '{}',
              remotePayload: '{}',
              baseRevision: 1,
              remoteRevision: 5,
              localMutationId: 'm-1',
            ),
          );
      return ledgerId;
    } catch (error, stack) {
      throw StateError('云账本测试数据初始化失败: $error\n$stack');
    }
  }

  test('Cloud→Local Fork：新 ledger_id + 同步身份全清 + origin 七字段', () async {
    final sourceId = await seedCloudLedger();
    final newId = '22222222-2222-4222-8222-222222222221';

    final result = await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      originAccountId: 'acc-1',
      originSyncId: 'sync-s1',
      originLastRevision: 7,
    );

    expect(result, newId);
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(newId))).getSingle();
    expect(fork.name, '家庭账本');
    expect(fork.storageMode, 'local');
    expect(fork.syncId, isNull, reason: 'LOCAL 账本 sync_id 恒 NULL');
    expect(fork.bindingStatus, isNull);
    expect(fork.originType, 'CLOUD_BACKUP');
    expect(fork.originLedgerId, sourceId);
    expect(fork.originSyncId, 'sync-s1');
    expect(fork.originAccountId, 'acc-1');
    expect(fork.originBackupId, 'backup-1');
    expect(fork.originLastRevision, 7);
    expect(fork.detachedAt, isNotNull);
  });

  test(
    'Fork 成员重映射：REGISTERED 派生 / PLACEHOLDER 新 UUID / LOCAL self 派生',
    () async {
      final sourceId = await seedCloudLedger();
      final newId = '22222222-2222-4222-8222-222222222222';
      await repo.forkCloudLedgerToLocal(
        sourceLedgerId: sourceId,
        newLedgerId: newId,
        localSelfId: 'self-device-1',
        originBackupId: 'backup-1',
      );

      final members = await (db.select(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.equals(newId))).get();
      // 3 类成员：新 LOCAL self + 重映射 REGISTERED + 新 PLACEHOLDER
      expect(members, hasLength(3));
      final owner = members.singleWhere((m) => m.memberType == 'REGISTERED');
      expect(
        owner.id,
        registeredMemberId(newId, 'acc-1'),
        reason: 'REGISTERED 按新 ledgerId 派生',
      );
      expect(owner.linkedAccountId, 'acc-1');
      final placeholder = members.singleWhere(
        (m) => m.memberType == 'PLACEHOLDER',
      );
      expect(
        placeholder.id,
        isNot('member-placeholder-1'),
        reason: 'PLACEHOLDER 必须生成新 UUID',
      );
      expect(placeholder.displayName, '张三');
      final self = members.singleWhere((m) => m.memberType == 'LOCAL');
      expect(
        self.id,
        localSelfMemberId(newId, 'self-device-1'),
        reason: 'LOCAL self 按新账本派生',
      );
      // 源账本成员不被改动
      expect(
        await (db.select(
          db.ledgerMembers,
        )..where((m) => m.ledgerId.equals(sourceId))).get(),
        hasLength(3),
      );
    },
  );

  test('Fork 交易/AA 分摊/编辑历史复制且成员引用重写；server_revision 清空', () async {
    final sourceId = await seedCloudLedger();
    final newId = '22222222-2222-4222-8222-222222222223';
    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
    );

    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(newId))).get();
    expect(txs, hasLength(1));
    final tx = txs.single;
    expect(tx.id, isNot('tx-1'), reason: '交易复制生成新 id');
    expect(tx.amount, '100');
    expect(tx.serverRevision, isNull, reason: 'server_revision 不得恢复');
    expect(tx.version, 3, reason: '本地编辑版本保留（业务状态）');
    expect(tx.payerMemberId, registeredMemberId(newId, 'acc-1'));
    expect(tx.createdByMemberId, registeredMemberId(newId, 'acc-1'));

    final splits = await (db.select(
      db.transactionSplits,
    )..where((s) => s.transactionId.equals(tx.id))).get();
    expect(splits.map((s) => s.amount).toSet(), {'60', '40'});
    // 分摊参与人引用全部指向新账本成员
    final newMemberIds = (await (db.select(
      db.ledgerMembers,
    )..where((m) => m.ledgerId.equals(newId))).get()).map((m) => m.id).toSet();
    for (final s in splits) {
      expect(newMemberIds, contains(s.memberId), reason: 'AA 分摊引用必须重写到新成员');
    }

    final history = await (db.select(
      db.recordEditHistories,
    )..where((h) => h.recordId.equals(tx.id))).get();
    expect(history, hasLength(1));
    expect(history.single.operatorMemberId, registeredMemberId(newId, 'acc-1'));
  });

  test('Fork 与备份复制只搬活跃成员和交易，不复活 tombstone', () async {
    final sourceId = await seedCloudLedger();
    final deletedAt = DateTime.utc(2026, 8, 2);
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'deleted-member',
            ledgerId: sourceId,
            displayName: '已删除成员',
            memberType: 'PLACEHOLDER',
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'deleted-transaction',
            ledgerId: sourceId,
            txType: 'expense',
            amount: '999',
            happenedAt: deletedAt,
            currencyCode: 'CNY',
            nativeAmount: '999',
            payerMemberId: const d.Value('deleted-member'),
            createdAt: deletedAt,
            updatedAt: deletedAt,
            deletedAt: d.Value(deletedAt),
          ),
        );
    const targetId = '22222222-2222-4222-8222-222222222299';

    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: targetId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
    );

    final members = await (db.select(
      db.ledgerMembers,
    )..where((member) => member.ledgerId.equals(targetId))).get();
    final transactions = await (db.select(
      db.transactions,
    )..where((transaction) => transaction.ledgerId.equals(targetId))).get();
    expect(
      members.map((member) => member.displayName),
      isNot(contains('已删除成员')),
    );
    expect(transactions, hasLength(1));
    expect(transactions.single.amount, '100');
  });

  test('Fork 清同步状态：pending 队列/OPEN 冲突不复制', () async {
    final sourceId = await seedCloudLedger();
    final newId = '22222222-2222-4222-8222-222222222224';
    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
    );

    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(newId))).get();
    expect(pending, isEmpty, reason: 'pending mutation 不随恢复复制');
    final conflicts = await (db.select(
      db.syncConflicts,
    )..where((c) => c.ledgerId.equals(newId))).get();
    expect(conflicts, isEmpty, reason: 'OPEN conflict 不随恢复复制');
    // 源账本状态保留（备份源只读语义）
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(sourceId))).get(),
      hasLength(1),
    );
  });

  test('安全副本保留无账号关联的云快照成员并重映射全部账务引用', () async {
    final sourceId = await seedCloudLedger();
    final ownerId = registeredMemberId(sourceId, 'acc-1');
    final otherId = registeredMemberId(sourceId, 'acc-2');
    await (db.update(db.ledgerMembers)
          ..where((member) => member.id.equals(ownerId)))
        .write(const LedgerMembersCompanion(linkedAccountId: d.Value(null)));
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: otherId,
            ledgerId: sourceId,
            displayName: 'Bob',
            memberType: 'REGISTERED',
            updatedAt: DateTime.utc(2026, 8),
          ),
        );
    await (db.update(db.transactions)..where((row) => row.id.equals('tx-1')))
        .write(TransactionsCompanion(lastEditedByMemberId: d.Value(otherId)));
    await (db.update(db.transactionSplits)
          ..where((row) => row.memberId.equals('member-placeholder-1')))
        .write(const TransactionSplitsCompanion(amount: d.Value('20')));
    await db
        .into(db.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: 'tx-1',
            memberId: otherId,
            amount: '20',
          ),
        );
    const targetId = '22222222-2222-4222-8222-222222222278';

    await repo.protectCloudLedgerToLocalFork(
      sourceLedgerId: sourceId,
      targetLedgerId: targetId,
      localSelfId: 'self-device-1',
      currentAccountId: 'acc-1',
    );

    final members = await (db.select(
      db.ledgerMembers,
    )..where((row) => row.ledgerId.equals(targetId))).get();
    final ids = members.map((member) => member.id).toSet();
    final book = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals(targetId))).getSingle();
    final transaction = await (db.select(
      db.transactions,
    )..where((row) => row.ledgerId.equals(targetId))).getSingle();
    final splits = await (db.select(
      db.transactionSplits,
    )..where((row) => row.transactionId.equals(transaction.id))).get();
    final history = await (db.select(
      db.recordEditHistories,
    )..where((row) => row.recordId.equals(transaction.id))).getSingle();
    expect(ids, contains(book.selfMemberId));
    expect(book.selfMemberId, registeredMemberId(targetId, 'acc-1'));
    expect(
      members
          .where((member) => member.originMemberId == otherId)
          .single
          .memberType,
      'PLACEHOLDER',
    );
    expect([
      transaction.createdByMemberId,
      transaction.lastEditedByMemberId,
      transaction.payerMemberId,
      history.operatorMemberId,
      ...splits.map((split) => split.memberId),
    ], everyElement(isIn(ids)));
    expect(ids, isNot(contains(ownerId)));
    expect(ids, isNot(contains(otherId)));
  });

  test('Fork 后继续编辑：sync_id 恒 NULL 且永不入队', () async {
    final sourceId = await seedCloudLedger();
    final newId = '22222222-2222-4222-8222-222222222225';
    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
    );
    // 编辑 Fork 账本
    await repo.updateLedger(id: newId, name: '改名后的家庭账本');
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(newId))).getSingle();
    expect(fork.name, '改名后的家庭账本');
    expect(fork.syncId, isNull);
    // 本地账本编辑不登记同步变更（trackerGetter 为 null 时本来就不登记；此处验证无队列行）
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.ledgerId.equals(newId))).get();
    expect(pending, isEmpty);
  });

  test('本地账本恢复（无 ID 冲突）：原 identity + LOCAL_BACKUP origin', () async {
    // 备份源中的本地账本：源数据放在独立只读源库（backup.sqlite 语义）
    final sourceId = '33333333-3333-4333-8333-333333333331';
    final now = DateTime.utc(2026, 8, 1);
    final sourceDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    await sourceDb
        .into(sourceDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sourceId,
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await sourceDb
        .into(sourceDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'local-self-src',
            ledgerId: sourceId,
            displayName: '',
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    await sourceDb
        .into(sourceDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-local-1',
            ledgerId: sourceId,
            txType: 'expense',
            amount: '5',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '5',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 无冲突：目标 id = 源 id（原 identity 恢复）；live 库此时不含该 ID
    final result = await repo.restoreLocalLedger(
      sourceLedgerId: sourceId,
      targetLedgerId: sourceId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      sourceDb: sourceDb,
    );
    expect(result, sourceId);
    final restored = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(sourceId))).getSingle();
    expect(restored.name, '私人账本');
    expect(restored.syncId, isNull);
    expect(restored.originType, 'LOCAL_BACKUP');
    expect(restored.originLedgerId, sourceId);
    expect(restored.originBackupId, 'backup-1');
    expect(restored.detachedAt, isNotNull);
    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(sourceId))).get();
    expect(txs, hasLength(1));
    // 源库保持只读语义：未被改写
    final srcLedgers = await sourceDb.select(sourceDb.ledgers).get();
    expect(srcLedgers, hasLength(1));
  });

  test('当前账号 == 源 owner 账号 → self 指向重映射 REGISTERED 成员', () async {
    final sourceId = await seedCloudLedger();
    final newId = '22222222-2222-4222-8222-222222222226';
    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      currentAccountId: 'acc-1', // 当前登录账号 == 源 owner 账号
    );
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(newId))).getSingle();
    expect(
      fork.selfMemberId,
      registeredMemberId(newId, 'acc-1'),
      reason: '身份可验证：self 指向重映射后的张三（REGISTERED）',
    );
    final self = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.id.equals(fork.selfMemberId!))).getSingle();
    expect(self.memberType, 'REGISTERED');
    // 不创建额外 LOCAL self（禁止第二个 self）
    final locals =
        await (db.select(db.ledgerMembers)..where(
              (m) => m.ledgerId.equals(newId) & m.memberType.equals('LOCAL'),
            ))
            .get();
    expect(locals, isEmpty);
  });

  test('独立云备份由其他账号恢复 → 创建新 LOCAL self，历史成员保留', () async {
    final backupDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(backupDb.close);
    final sourceId = await seedCloudLedger(backupDb: backupDb);
    final newId = '22222222-2222-4222-8222-222222222227';
    await repo.forkCloudLedgerToLocal(
      sourceLedgerId: sourceId,
      newLedgerId: newId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      currentAccountId: 'acc-2', // 当前登录的是 B（≠ 源 owner acc-1）
      sourceDb: backupDb,
    );
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(newId))).getSingle();
    expect(
      fork.selfMemberId,
      localSelfMemberId(newId, 'self-device-1'),
      reason: '账号不匹配：self 指向新 LOCAL 我',
    );
    final self = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.id.equals(fork.selfMemberId!))).getSingle();
    expect(self.memberType, 'LOCAL');
    // 历史成员原样保留（张三 REGISTERED + PLACEHOLDER）
    final members = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.ledgerId.equals(newId))).get();
    expect(
      members.any(
        (m) => m.memberType == 'REGISTERED' && m.linkedAccountId == 'acc-1',
      ),
      isTrue,
      reason: '历史成员不因账号不匹配而丢失',
    );
  });

  test('本地备份跨设备 → 复制源 LOCAL self 为权威，不创建第二个 self', () async {
    // 源库：本地账本 + LOCAL self（旧设备 D1 派生）
    final srcId = '33333333-3333-4333-8333-333333333340';
    final srcDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(srcDb.close);
    final now = DateTime.utc(2026, 8, 1);
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: srcId,
            name: '本地账本',
            storageMode: const d.Value('local'),
            selfMemberId: const d.Value('self-member-d1'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'self-member-d1',
            ledgerId: srcId,
            displayName: '旧设备我',
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-d1',
            ledgerId: srcId,
            txType: 'expense',
            amount: '5',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '5',
            createdByMemberId: d.Value('self-member-d1'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 恢复原 identity（跨设备，新设备 localSelfId = self-device-2）
    final restoredId = await repo.restoreLocalLedger(
      sourceLedgerId: srcId,
      targetLedgerId: srcId,
      localSelfId: 'self-device-2',
      originBackupId: 'backup-1',
      sourceDb: srcDb,
    );
    expect(restoredId, srcId);
    final restored = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(srcId))).getSingle();
    expect(
      restored.selfMemberId,
      'self-member-d1',
      reason: '源 LOCAL self 是历史我的权威，原 identity 时 id 不变',
    );
    // 没有第二个 self（不按新设备 localSelfId 派生）
    final locals =
        await (db.select(db.ledgerMembers)..where(
              (m) => m.ledgerId.equals(srcId) & m.memberType.equals('LOCAL'),
            ))
            .get();
    expect(locals, hasLength(1));
    expect(locals.single.id, 'self-member-d1');
    // 历史交易引用保持指向同一 self
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(srcId))).getSingle();
    expect(tx.createdByMemberId, 'self-member-d1');
  });

  test('本地备份跨设备且 ID 冲突 → Fork 时 LOCAL self 按原成员确定性派生', () async {
    final srcId = '33333333-3333-4333-8333-333333333341';
    final srcDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(srcDb.close);
    final now = DateTime.utc(2026, 8, 1);
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: srcId,
            name: '本地账本',
            storageMode: const d.Value('local'),
            selfMemberId: const d.Value('self-member-d1'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'self-member-d1',
            ledgerId: srcId,
            displayName: '旧设备我',
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    // 目标库已存在同 ID（冲突 → Fork）
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: srcId,
            name: '同名账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    final forkId = '44444444-4444-4444-8444-444444444445';
    final restoredId = await repo.restoreLocalLedger(
      sourceLedgerId: srcId,
      targetLedgerId: forkId,
      localSelfId: 'self-device-2',
      originBackupId: 'backup-1',
      sourceDb: srcDb,
    );
    expect(restoredId, forkId);
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(forkId))).getSingle();
    expect(
      fork.selfMemberId,
      localSelfMemberIdFromOriginal(forkId, 'self-member-d1'),
      reason: 'Fork 时 LOCAL self 按原成员 id 确定性派生，不创建第二个 self',
    );
    final locals =
        await (db.select(db.ledgerMembers)..where(
              (m) => m.ledgerId.equals(forkId) & m.memberType.equals('LOCAL'),
            ))
            .get();
    expect(locals, hasLength(1));
    expect(locals.single.id, fork.selfMemberId);
  });

  test('本地账本 ID 冲突：Fork 新 ID，不按名字判断', () async {
    final sourceId = '33333333-3333-4333-8333-333333333332';
    final now = DateTime.utc(2026, 8, 1);
    // 备份源：独立只读源库
    final sourceDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    await sourceDb
        .into(sourceDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sourceId,
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    // 目标机已存在同名账本（名字相同但 ID 不同）：不构成冲突
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '44444444-4444-4444-8444-444444444444',
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    // 无 ID 冲突 → 原 identity
    final noConflict = await repo.restoreLocalLedger(
      sourceLedgerId: sourceId,
      targetLedgerId: sourceId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      sourceDb: sourceDb,
    );
    expect(noConflict, sourceId, reason: '名字相同但 ID 不同不算冲突（不按名字判断）');
    // 同名不同 ID 的现有账本不受影响
    final existing =
        await (db.select(db.ledgers)..where(
              (l) => l.id.equals('44444444-4444-4444-8444-444444444444'),
            ))
            .getSingle();
    expect(existing.originType, isNull);
  });

  /// 构造带分类引用的源云账本：账本(scope=acc-1) + 交易列表，每笔交易引用给定分类。
  Future<String> seedCloudLedgerWithCategories(
    String ledgerId, {
    required List<({String txId, String categoryId})> txs,
  }) async {
    final now = DateTime.utc(2026, 8, 1);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '分类源账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('acc-1'),
            ownerAccountId: const d.Value('acc-1'),
            syncId: const d.Value('sync-cat'),
            updatedAt: now,
          ),
        );
    await db.batch((b) {
      b.insertAll(db.transactions, [
        for (final tx in txs)
          TransactionsCompanion.insert(
            id: tx.txId,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '10',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '10',
            categoryId: d.Value(tx.categoryId),
            createdAt: now,
            updatedAt: now,
          ),
      ]);
    });
    return ledgerId;
  }

  test('云转本地隐藏 Fork：同原身份与内容的本地目录直接复用，账号域保持原样', () async {
    const localCatId = 'local-cat-1';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: localCatId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: localCatId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('acc-1'),
            cloudRegistered: const d.Value(true),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    final sourceId = await seedCloudLedgerWithCategories(
      'cloud-src-1',
      txs: [(txId: 'tx-1', categoryId: localCatId)],
    );
    final categoriesBefore = await db.select(db.categories).get();

    await repo.forkCloudLedgerToLocalPendingMove(
      sourceLedgerId: sourceId,
      newLedgerId: 'fork-1',
      localSelfId: 'self-device-1',
      currentAccountId: 'acc-1',
      originSyncId: 'sync-cat',
    );

    expect(await db.select(db.categories).get(), categoriesBefore);
    final forkTx = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals('fork-1'))).getSingle();
    expect(forkTx.categoryId, localCatId, reason: '本地副本引用相同身份的本地域分类');
  });

  test('云转本地隐藏 Fork：目标同名不同身份分类保留冲突，整个副本原子回滚', () async {
    const localCatId = 'local-cat-2';
    const cloudCatId = 'cloud-cat-2';
    final now = DateTime.utc(2026, 8, 1);
    await db.batch((b) {
      b.insertAll(db.categories, [
        CategoriesCompanion.insert(
          id: localCatId,
          name: '餐饮',
          kind: 'expense',
          level: 1,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: cloudCatId,
          name: '餐饮',
          kind: 'expense',
          level: 1,
          scopeAccountId: const d.Value('acc-1'),
          updatedAt: now,
        ),
      ]);
    });
    final sourceId = await seedCloudLedgerWithCategories(
      'cloud-src-2',
      txs: [(txId: 'tx-2', categoryId: cloudCatId)],
    );

    final categoriesBefore = await db.select(db.categories).get();
    final transactionsBefore = await db.select(db.transactions).get();
    final ledgersBefore = await db.select(db.ledgers).get();
    await expectLater(
      repo.forkCloudLedgerToLocalPendingMove(
        sourceLedgerId: sourceId,
        newLedgerId: 'fork-2',
        localSelfId: 'self-device-1',
        currentAccountId: 'acc-1',
        originSyncId: 'sync-cat',
      ),
      throwsA(isA<CategoryCloneConflict>()),
    );
    expect(await db.select(db.categories).get(), categoriesBefore);
    expect(await db.select(db.transactions).get(), transactionsBefore);
    expect(await db.select(db.ledgers).get(), ledgersBefore);
    final cloudCat = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(cloudCatId))).getSingle();
    expect(cloudCat.scopeAccountId, 'acc-1', reason: '账号域原分类仍在原域');
  });

  test('云转本地隐藏 Fork：来源同名不同身份分类导致冲突，目标目录和交易全部回滚', () async {
    final now = DateTime.utc(2026, 8, 1);
    await db.batch((b) {
      b.insertAll(db.categories, [
        CategoriesCompanion.insert(
          id: 'cloud-cat-a',
          name: '餐饮',
          kind: 'expense',
          level: 1,
          scopeAccountId: const d.Value('acc-1'),
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'cloud-cat-b',
          name: '餐饮',
          kind: 'expense',
          level: 1,
          scopeAccountId: const d.Value('acc-1'),
          updatedAt: now,
        ),
      ]);
    });
    final sourceId = await seedCloudLedgerWithCategories(
      'cloud-src-3',
      txs: [
        (txId: 'tx-a', categoryId: 'cloud-cat-a'),
        (txId: 'tx-b', categoryId: 'cloud-cat-b'),
      ],
    );

    final categoriesBefore = await db.select(db.categories).get();
    final transactionsBefore = await db.select(db.transactions).get();
    final ledgersBefore = await db.select(db.ledgers).get();
    await expectLater(
      repo.forkCloudLedgerToLocalPendingMove(
        sourceLedgerId: sourceId,
        newLedgerId: 'fork-3',
        localSelfId: 'self-device-1',
        currentAccountId: 'acc-1',
        originSyncId: 'sync-cat',
      ),
      throwsA(isA<CategoryCloneConflict>()),
    );
    final localCats = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, null))).get();
    expect(localCats, isEmpty);
    expect(await db.select(db.categories).get(), categoriesBefore);
    expect(await db.select(db.transactions).get(), transactionsBefore);
    expect(await db.select(db.ledgers).get(), ledgersBefore);
  });

  test('本地账本恢复：目标库缺失的被引用分类按原 id 从备份导入本地域', () async {
    final sourceId = '55555555-5555-4555-8555-555555555555';
    final now = DateTime.utc(2026, 8, 1);
    // 备份源：本地账本 + 父子分类 + 交易引用子分类
    final sourceDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    await sourceDb
        .into(sourceDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sourceId,
            name: '备份账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await sourceDb.batch((b) {
      b.insertAll(sourceDb.categories, [
        CategoriesCompanion.insert(
          id: 'bk-parent',
          name: '购物',
          kind: 'expense',
          level: 1,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'bk-child',
          name: '服装',
          kind: 'expense',
          level: 2,
          parentId: d.Value('bk-parent'),
          updatedAt: now,
        ),
      ]);
    });
    await sourceDb
        .into(sourceDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'bk-tx',
            ledgerId: sourceId,
            txType: 'expense',
            amount: '10',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '10',
            categoryId: d.Value('bk-child'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await repo.restoreLocalLedger(
      sourceLedgerId: sourceId,
      targetLedgerId: sourceId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-1',
      sourceDb: sourceDb,
    );

    // 缺失分类按原 id 导入本地域（父子链完整），不另造新 id
    final child = await (db.select(
      db.categories,
    )..where((c) => c.id.equals('bk-child'))).getSingle();
    expect(child.scopeAccountId, isNull, reason: '恢复导入的分类落本地域');
    expect(child.parentId, 'bk-parent', reason: '父链按原 id 一并导入');
    expect(
      await (db.select(
        db.categories,
      )..where((c) => c.id.equals('bk-parent'))).getSingleOrNull(),
      isNotNull,
    );
    expect(
      await db.select(db.categories).get(),
      hasLength(2),
      reason: '导入恒按原 id，不制造额外行',
    );
    // 恢复交易引用原 id
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(sourceId))).getSingle();
    expect(tx.categoryId, 'bk-child', reason: '恢复交易分类引用不悬空');
  });

  test('本地账本恢复：账号域同 id 分类保持原样，父子链完整导入本地域', () async {
    final sourceId = '66666666-6666-4666-8666-666666666666';
    final now = DateTime.utc(2026, 8, 1);
    // 目标库已有同 id 父子分类（账号域）
    await db.batch((b) {
      b.insertAll(db.categories, [
        CategoriesCompanion.insert(
          id: 'bk-parent-2',
          name: '购物',
          kind: 'expense',
          level: 1,
          scopeAccountId: const d.Value('acc-1'),
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'bk-child-2',
          name: '服装',
          kind: 'expense',
          level: 2,
          parentId: d.Value('bk-parent-2'),
          scopeAccountId: const d.Value('acc-1'),
          updatedAt: now,
        ),
      ]);
    });
    final accountCategoriesBefore = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, 'acc-1'))).get();
    final sourceDb = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    await sourceDb
        .into(sourceDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sourceId,
            name: '备份账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await sourceDb.batch((b) {
      b.insertAll(sourceDb.categories, [
        CategoriesCompanion.insert(
          id: 'bk-parent-2',
          name: '购物',
          kind: 'expense',
          level: 1,
          updatedAt: now,
        ),
        CategoriesCompanion.insert(
          id: 'bk-child-2',
          name: '服装',
          kind: 'expense',
          level: 2,
          parentId: d.Value('bk-parent-2'),
          updatedAt: now,
        ),
      ]);
    });
    await sourceDb
        .into(sourceDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'bk-tx-2',
            ledgerId: sourceId,
            txType: 'expense',
            amount: '10',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '10',
            categoryId: d.Value('bk-child-2'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await repo.restoreLocalLedger(
      sourceLedgerId: sourceId,
      targetLedgerId: sourceId,
      localSelfId: 'self-device-1',
      originBackupId: 'backup-2',
      sourceDb: sourceDb,
    );

    final accountCategoriesAfter = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, 'acc-1'))).get();
    expect(accountCategoriesAfter, accountCategoriesBefore);
    final imported = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, null))).get();
    expect(imported.map((c) => c.id).toSet(), {'bk-parent-2', 'bk-child-2'});
    final child = imported.singleWhere((c) => c.id == 'bk-child-2');
    expect(child.parentId, 'bk-parent-2');
    expect(child.cloudRegistered, isFalse);
    final restoredTransaction = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(sourceId))).getSingle();
    expect(restoredTransaction.categoryId, child.id);
  });
}
