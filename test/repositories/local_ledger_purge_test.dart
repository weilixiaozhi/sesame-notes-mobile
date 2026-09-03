/// 退出登录 purge 云端账本（P0-1）单元测试。
///
/// 需求锚点：
/// 退出登录 = 这台设备不再持有云账号数据——storage_mode='cloud' 的账本
/// 及其全部关联数据（交易、编辑历史、同步变更、成员/共享分类镜像、虚拟用户、
/// 周期交易）必须整本清除，重登后由全量同步拉回；
/// storage_mode='local' 的账本一行都不动（那是这台设备自己的数据）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 直接经 db 层给指定账本插一条待推送同步变更（云端账本才有）。
  Future<void> seedSyncChange(
    String ledgerId,
    String entityType,
    String entityId,
  ) {
    return db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            ledgerId: d.Value(ledgerId),
            action: 'upsert',
            payload: '{}',
            updatedAt: DateTime.now().toUtc(),
            mutationId: const Uuid().v4(),
          ),
        );
  }

  /// 构造一本带全套关联数据的云端账本：交易 + 编辑历史 + 同步变更 +
  /// 成员镜像 + 共享分类镜像 + 虚拟用户 + 周期交易。
  Future<String> seedCloudLedger(String name) async {
    final id = await repo.createLedger(name: name); // createLedger 默认 cloud
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    await db
        .into(db.recordEditHistories)
        .insert(
          RecordEditHistoriesCompanion.insert(
            recordId: txId,
            version: 1,
            operatorMemberId: d.Value(null),
            summary: '改金额',
          ),
        );
    await seedSyncChange(id, 'ledger', id);
    await seedSyncChange(id, 'transaction', txId);
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: const Uuid().v4(),
            ledgerId: id,
            displayName: '协作者',
            memberType: 'REGISTERED',
            linkedAccountId: d.Value('user-editor-1'),
            avatarUrl: d.Value(null),
            role: d.Value('editor'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: id,
            categoryId: 'cat-1',
            name: '餐饮',
            kind: 'expense',
            icon: d.Value(null),
            sortOrder: d.Value(0),
            level: d.Value(1),
            parentId: d.Value(null),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: const Uuid().v4(),
            ledgerId: id,
            displayName: '小明',
            memberType: 'PLACEHOLDER',
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: const Uuid().v4(),
            ledgerId: id,
            txType: 'expense',
            amount: '10.00',
            currencyCode: 'CNY',
            frequency: 'monthly',
            startDate: DateTime(2026, 8, 1),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  /// 构造一本带交易的本地账本。
  Future<String> seedLocalLedger(String name) async {
    final id = await repo.createLedger(name: name, storageMode: 'local');
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '20.00',
      happenedAt: DateTime(2026, 7, 6),
    );
    return id;
  }

  test('purge 后云端账本整本消失，本地账本一行不动', () async {
    final cloudA = await seedCloudLedger('云端A');
    final cloudB = await seedCloudLedger('云端B');
    final localC = await seedLocalLedger('本地C');

    await repo.purgeAllCloudLedgers();

    // 云端账本行与全部关联数据清零。
    expect(await repo.getLedgerById(cloudA), isNull, reason: '云端账本 A 应被整本清除');
    expect(await repo.getLedgerById(cloudB), isNull, reason: '云端账本 B 应被整本清除');
    expect(
      (await db.select(db.transactions).get()).where(
        (t) => t.ledgerId == cloudA || t.ledgerId == cloudB,
      ),
      isEmpty,
    );
    expect(
      (await db.select(db.recordEditHistories).get()),
      isEmpty,
      reason: '编辑历史随交易级联清除',
    );
    expect(
      (await db.select(db.syncChanges).get()),
      isEmpty,
      reason: '待推送变更随账本清除',
    );
    expect(
      (await db.select(db.ledgerMembers).get()),
      isEmpty,
      reason: '成员镜像随账本清除',
    );
    expect(
      (await db.select(db.sharedLedgerCategories).get()),
      isEmpty,
      reason: '共享分类镜像随账本清除',
    );
    expect(
      (await db.select(db.ledgerMembers).get()),
      isEmpty,
      reason: '成员（含占位成员）随账本清除',
    );
    expect(
      (await db.select(db.recurringTransactions).get()),
      isEmpty,
      reason: '周期交易随账本清除',
    );

    // 本地账本完好：行还在、交易还在。
    final kept = await repo.getLedgerById(localC);
    expect(kept, isNotNull, reason: '本地账本必须原样保留');
    expect(kept!.storageMode, 'local');
    final keptTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(localC))).get();
    expect(keptTxs, hasLength(1), reason: '本地账本交易不受 purge 影响');
  });

  test('purge 幂等：无云端账本时调用成功且无副作用', () async {
    final localC = await seedLocalLedger('本地C');
    await repo.purgeAllCloudLedgers(); // 第一次：无云端账本
    await repo.purgeAllCloudLedgers(); // 第二次：仍无
    expect(await repo.getLedgerById(localC), isNotNull);
    expect(await db.select(db.ledgers).get(), hasLength(1));
  });

  test('purge 不误伤共享镜像外挂的本地账本', () async {
    // 本地账本即使挂了成员镜像（异常残留）也不该被删：选区只看 storage_mode。
    final localC = await seedLocalLedger('本地C');
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: const Uuid().v4(),
            ledgerId: localC,
            displayName: '残留成员',
            memberType: 'REGISTERED',
            linkedAccountId: d.Value('user-editor-1'),
            role: d.Value('editor'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await repo.purgeAllCloudLedgers();
    expect(
      await repo.getLedgerById(localC),
      isNotNull,
      reason: '本地账本及其镜像残留都不得被 purge',
    );
    expect(await db.select(db.ledgerMembers).get(), hasLength(1));
  });

  // ==================== 单账本 purge（退出/删除共享账本） ====================

  test('purgeLedger：只清目标账本全套关联数据，其他账本不动', () async {
    final cloudA = await seedCloudLedger('云端A');
    final cloudB = await seedCloudLedger('云端B');
    final cloudATx = (await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(cloudA))).get()).single.id;

    await repo.purgeLedger(cloudA);

    expect(await repo.getLedgerById(cloudA), isNull, reason: '目标账本行删除');
    expect(
      (await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(cloudA))).get()),
      isEmpty,
      reason: '目标账本交易级联清除',
    );
    expect(
      (await (db.select(
        db.recordEditHistories,
      )..where((h) => h.recordId.equals(cloudATx))).get()),
      isEmpty,
      reason: '目标账本编辑历史随交易清除',
    );
    expect(
      (await (db.select(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(cloudA))).get()),
      isEmpty,
      reason: '目标账本待推送变更清除',
    );
    expect(
      (await (db.select(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.equals(cloudA))).get()),
      isEmpty,
      reason: '目标账本成员镜像清除',
    );
    expect(
      (await (db.select(
        db.sharedLedgerCategories,
      )..where((s) => s.ledgerId.equals(cloudA))).get()),
      isEmpty,
      reason: '目标账本共享分类镜像清除',
    );

    // 另一本账本（含全套关联数据）原样保留。
    expect(await repo.getLedgerById(cloudB), isNotNull);
    expect(
      (await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(cloudB))).get()),
      hasLength(1),
      reason: '其他账本交易不受影响',
    );
    expect(
      (await (db.select(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.equals(cloudB))).get()),
      isNotEmpty,
      reason: '其他账本成员镜像不受影响',
    );
  });

  test('purgeLedger 幂等：账本不存在/重复调用零副作用', () async {
    final cloudA = await seedCloudLedger('云端A');

    await repo.purgeLedger('no-such-ledger'); // 不存在：不抛错
    await repo.purgeLedger(cloudA);
    await repo.purgeLedger(cloudA); // 重复：不抛错

    expect(await repo.getLedgerById(cloudA), isNull);
  });
}
