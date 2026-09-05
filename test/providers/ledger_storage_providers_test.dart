/// 账本归属移动（P0-2 移动到云端 / P0-3 移动到本地）行为测试。
///
/// 需求锚点：
/// - 移动到云端：本地账本翻 storage_mode='cloud'，且该账本全部实体
///   （账本/交易/虚拟用户/周期交易）登记 upsert 变更（backfill）——
///   本地历史数据从未登记过变更，不补登记云端将只有空账本；
/// - 移动到本地：先登记账本 delete（tombstone 删云端）并推送成功
///   （fail-closed：删云端失败则本地保持云端态），成功后本地断联
///   （置 local + 清除该账本全部待推送变更）；推送失败不得残留 delete
///   变更（否则下次推送会误删云端）。
library;

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/secure_account_store.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_storage_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../helpers/test_isolation.dart';

class _MockSyncService extends Mock implements SyncService {}

class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

/// 测试账号（与跨端 golden 测试同 ownerId）。
const testUserId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSyncService sync;
  late ProviderContainer container;
  late LedgerStorageActions actions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => testUserId),
    );
    sync = _MockSyncService();
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            _MemorySecureStore(),
            pendingStore: _MemorySecureStore(),
            logoutMarkerStore: _MemorySecureStore(),
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
      ],
    );
    // 登录测试账号（moveToCloud/moveToLocal 的前置条件）
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'test-token',
            userId: testUserId,
            deviceId: 'device-1',
          ),
        );
    actions = container.read(ledgerStorageActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 构造本地账本：账本 + 2 交易 + 1 虚拟用户 + 1 周期交易。
  /// 传入 [localSelfId] 让 createLedger 同时创建 LOCAL self 成员；
  /// 交易按真实 UI 路径回填作者（createdBy 指向 LOCAL 本人）。
  Future<String> seedLocalLedger(
    String name, {
    String? localSelfId = 'device-self',
  }) async {
    final id = await repo.createLedger(
      name: name,
      storageMode: 'local',
      localSelfId: localSelfId,
    );
    final selfMemberId = localSelfMemberId(id, localSelfId!);
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
      operatorMemberId: selfMemberId,
    );
    await repo.addTransaction(
      ledgerId: id,
      type: 'income',
      amount: '20.00',
      happenedAt: DateTime(2026, 7, 6),
      operatorMemberId: selfMemberId,
    );
    await repo.createPlaceholderMember(ledgerId: id, name: '小明');
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'rec-$id',
            ledgerId: id,
            txType: 'expense',
            amount: '5.00',
            currencyCode: 'CNY',
            frequency: 'monthly',
            startDate: DateTime(2026, 8, 1),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  test('moveToCloud：本人身份原子映射 + 归属翻云 + backfill 归属当前账号', () async {
    final id = await seedLocalLedger('本地账本');

    // 转换前：LOCAL self 存在，交易创建人指向 LOCAL 本人
    final before = await repo.getLedgerById(id);
    final localSelfId = before!.selfMemberId!;
    final localSelf = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.id.equals(localSelfId))).getSingle();
    expect(localSelf.memberType, 'LOCAL');
    final beforeTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(
      beforeTxs.every((t) => t.createdByMemberId == localSelfId),
      isTrue,
      reason: '转换前交易创建人全部指向 LOCAL 本人',
    );

    await actions.moveToCloud(id);

    // 归属与账号域
    final ledger = await repo.getLedgerById(id);
    expect(ledger!.storageMode, 'cloud', reason: '归属必须翻为云端');
    expect(ledger.scopeAccountId, testUserId, reason: '转换后账本必须归属当前账号');
    // self_member_id 指向 REGISTERED 本人（uuidV5 派生，跨端黄金向量同源）
    final mRegistered = registeredMemberId(id, testUserId);
    expect(ledger.selfMemberId, mRegistered);
    final registered = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.id.equals(mRegistered))).getSingle();
    expect(registered.memberType, 'REGISTERED');
    expect(registered.linkedAccountId, testUserId);
    expect(
      registered.originMemberId,
      localSelfId,
      reason: 'origin_member_id 必须永久保留来源成员链',
    );
    // 全部本人引用重写
    final afterTx = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(
      afterTx.every((t) => t.createdByMemberId == mRegistered),
      isTrue,
      reason: '创建人引用必须全部重写为 REGISTERED 本人',
    );
    // 已无引用的 LOCAL 成员清理
    expect(
      await (db.select(
        db.ledgerMembers,
      )..where((m) => m.id.equals(localSelfId))).getSingleOrNull(),
      isNull,
      reason: '清理已无引用的 LOCAL 本人',
    );

    // backfill：账本+2交易+1虚拟用户+1周期交易共 5 条变更，全部归属当前账号
    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(5));
    expect(
      changes.every((c) => c.accountId == testUserId),
      isTrue,
      reason: 'backfill mutation 必须写当前账号域（B 推不到 A）',
    );
    final byType = <String, int>{};
    for (final c in changes) {
      byType[c.entityType] = (byType[c.entityType] ?? 0) + 1;
      expect(c.action, 'upsert');
      expect(c.ledgerId, id);
    }
    expect(byType['ledger'], 1);
    expect(byType['transaction'], 2);
    expect(byType['member'], 1);
    expect(byType['recurring_transaction'], 1);
    final txChange = changes.firstWhere((c) => c.entityType == 'transaction');
    expect(txChange.payload, contains('"tx_type"'));
    expect(
      txChange.payload,
      contains(mRegistered),
      reason: '交易 payload 的本人引用必须是重映射后的 REGISTERED 成员',
    );
  });

  test('moveToCloud 未登录：拒绝转换且账本零改动', () async {
    container.read(authSessionProvider.notifier).signOut();
    final id = await seedLocalLedger('本地账本');
    await expectLater(actions.moveToCloud(id), throwsStateError);
    final ledger = await repo.getLedgerById(id);
    expect(ledger!.storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('moveToCloud：AA 分摊两个本人行合并金额，分摊总额保持完全相等', () async {
    final id = await seedLocalLedger('分摊账本');
    final localSelfId = (await repo.getLedgerById(id))!.selfMemberId!;
    // 构造同一交易两个本人行：M_local 与 M_registered 各一行
    final mRegistered = registeredMemberId(id, testUserId);
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: mRegistered,
            ledgerId: id,
            displayName: '云本人',
            memberType: 'REGISTERED',
            linkedAccountId: d.Value(testUserId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '30.00',
      happenedAt: DateTime(2026, 7, 7),
    );
    await repo.replaceTransactionSplits(txId, [
      TransactionSplitInput(memberId: localSelfId, amount: '10.00'),
    ]);
    await db
        .into(db.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: txId,
            memberId: mRegistered,
            amount: '20.00',
          ),
        );

    await actions.moveToCloud(id);

    // 合并后只剩一行 REGISTERED 本人，金额 = 10 + 20（Decimal 语义比较）
    final splits = await repo.getTransactionSplits(txId);
    expect(splits, hasLength(1));
    expect(splits.single.memberId, mRegistered);
    expect(
      Decimal.parse(splits.single.amount),
      Decimal.parse('30.00'),
      reason: '分摊总额必须保持完全相等',
    );
  });

  test('moveToCloud：本地域分类克隆到账号 scope，交易引用重写且其他本地账本不受影响', () async {
    final id = await seedLocalLedger('分类账本');
    // 建一个本地域分类并让本账本交易引用它
    final categoryId = 'local-cat-1';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '15.00',
      happenedAt: DateTime(2026, 7, 8),
      categoryId: categoryId,
    );
    // 另一个本地账本也引用同一分类
    final otherId = await seedLocalLedger('另一本地账本', localSelfId: 'other-self');
    await repo.addTransaction(
      ledgerId: otherId,
      type: 'expense',
      amount: '5.00',
      happenedAt: DateTime(2026, 7, 9),
      categoryId: categoryId,
    );

    await actions.moveToCloud(id);

    // 原分类保留在本地域（其他账本继续引用），新分类克隆到账号 scope
    final original = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    expect(original, isNotNull, reason: '其他本地账本仍在引用，原分类不得改动');
    expect(original!.scopeAccountId, isNull);
    final clones = await (db.select(
      db.categories,
    )..where((c) => c.scopeAccountId.equals(testUserId))).get();
    expect(clones, hasLength(1));
    expect(clones.single.id, isNot(categoryId), reason: '克隆必须使用新 UUID');
    expect(clones.single.name, '餐饮');
    // 本账本交易引用指向克隆
    final txRows = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(
      txRows.any((t) => t.categoryId == clones.single.id),
      isTrue,
      reason: '转换账本交易必须引用账号域克隆分类',
    );
    // 其他本地账本交易仍引用原分类
    final otherTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(otherId))).get();
    expect(otherTxs.any((t) => t.categoryId == categoryId), isTrue);
    // 克隆分类必须登记 user-global upsert（服务端按序应用，交易分类必须已存在）
    final categoryChanges = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('category'))).get();
    expect(categoryChanges, hasLength(1));
    expect(categoryChanges.single.entityId, clones.single.id);
    expect(categoryChanges.single.accountId, testUserId);
  });

  test('moveToCloud：backfill 交易 payload 的 category_id 必须是克隆后的账号域 id', () async {
    final id = await seedLocalLedger('payload账本');
    const categoryId = 'local-cat-payload';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '交通',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '8.00',
      happenedAt: DateTime(2026, 7, 10),
      categoryId: categoryId,
    );

    await actions.moveToCloud(id);

    final clone = await (db.select(
      db.categories,
    )..where((c) => c.scopeAccountId.equals(testUserId))).getSingle();
    final txChanges = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('transaction'))).get();
    expect(txChanges, hasLength(3));
    for (final c in txChanges) {
      expect(
        c.payload,
        isNot(contains(categoryId)),
        reason: 'payload 不得携带重写前的本地域分类 id（云端不存在该分类）',
      );
    }
    expect(
      txChanges.map((c) => c.payload).join(),
      contains(clone.id),
      reason: '带分类的交易 payload 必须引用账号域克隆分类 id',
    );
  });

  test(
    'moveToCloud：backfill 交易 payload 的 aa_mode 为契约 wire 字符串且保留 recurring_id',
    () async {
      final id = await seedLocalLedger('aa账本');
      final localSelfId = (await repo.getLedgerById(id))!.selfMemberId!;
      final txId = await repo.addTransaction(
        ledgerId: id,
        type: 'expense',
        amount: '30.00',
        happenedAt: DateTime(2026, 7, 11),
      );
      await repo.replaceTransactionSplits(txId, [
        TransactionSplitInput(memberId: localSelfId, amount: '30.00'),
      ]);
      // 指定分摊（aa_mode=2）+ 由周期模板生成（recurring_id 指向种子周期交易）
      await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(
          aaMode: const d.Value(2),
          recurringId: d.Value('rec-$id'),
        ),
      );

      await actions.moveToCloud(id);

      final change =
          await (db.select(db.syncChanges)..where(
                (c) =>
                    c.entityType.equals('transaction') &
                    c.entityId.equals(txId),
              ))
              .getSingle();
      expect(
        change.payload,
        contains('"aa_mode":"2"'),
        reason: 'aa_mode 必须是契约 wire 字符串，裸数字会被服务端拒绝',
      );
      expect(
        change.payload,
        contains('"recurring_id":"rec-$id"'),
        reason: '周期模板生成的交易必须保留模板关联',
      );
    },
  );

  test('moveToCloud：两个本地账本共享同一本地分类，先后迁云账号域只保留一个克隆', () async {
    final first = await seedLocalLedger('第一本');
    final second = await seedLocalLedger('第二本', localSelfId: 'second-self');
    const categoryId = 'shared-cat';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '共享分类',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    for (final ledgerId in [first, second]) {
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '1.00',
        happenedAt: DateTime(2026, 7, 12),
        categoryId: categoryId,
      );
    }

    await actions.moveToCloud(first);
    await actions.moveToCloud(second);

    final clones = await (db.select(
      db.categories,
    )..where((c) => c.scopeAccountId.equals(testUserId))).get();
    expect(clones, hasLength(1), reason: '同一分类在账号域只应存在一个克隆，重复克隆会产生重复分类');
    final secondTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(second))).get();
    expect(
      secondTxs.every(
        (t) => t.categoryId == null || t.categoryId == clones.single.id,
      ),
      isTrue,
      reason: '第二本账本的交易必须复用首个克隆',
    );
  });

  test('moveToCloud：本地域 v5 确定性种子分类复用原 id 上云，不克隆新实体', () async {
    final id = await seedLocalLedger('种子分类账本');
    // v5 确定性种子 id：任何设备/账号域中同一 key 生成同一 id，即同一实体
    final seedCatId = SeedService.deterministicCategorySyncId(
      kind: 'expense',
      level: 1,
      key: 'dining',
    );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: seedCatId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '15.00',
      happenedAt: DateTime(2026, 7, 8),
      categoryId: seedCatId,
    );

    await actions.moveToCloud(id);

    // 分类表不变：确定性 id 在账号域就是同一个实体，克隆新 id 只会制造云端重复
    final cats = await db.select(db.categories).get();
    expect(cats, hasLength(1), reason: 'v5 种子分类必须复用原 id，不得克隆新实体');
    expect(cats.single.id, seedCatId);
    // 本账本交易继续引用原 id
    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(
      txs.any((t) => t.categoryId == seedCatId),
      isTrue,
      reason: '交易引用必须保持种子分类原 id',
    );
    // 登记的 category 变更携带原 id：服务端按 id 幂等收敛
    final catChange = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('category'))).getSingle();
    expect(catChange.entityId, seedCatId);
    expect(catChange.accountId, testUserId);
  });

  test('moveToCloud 幂等：已是云端账本时零副作用', () async {
    final id = 'cloud-1';
    await repo.createBoundLedger(id: id, name: '云端账本');
    await actions.moveToCloud(id);
    expect(
      await db.select(db.syncChanges).get(),
      isEmpty,
      reason: '已是云端账本不应重复登记变更',
    );
  });

  test('moveToCloud：账本不存在抛错', () async {
    expect(() => actions.moveToCloud('no-such-id'), throwsStateError);
  });

  /// 构造已绑定云端账本（scope 归测试账号），含 REGISTERED self 与共享成员。
  Future<String> seedCloudLedger(String name) async {
    final id = 'cloud-$name';
    await repo.createBoundLedger(id: id, name: name, syncId: 'sync-$name');
    await (db.update(db.ledgers)..where((l) => l.id.equals(id))).write(
      LedgersCompanion(scopeAccountId: d.Value(testUserId)),
    );
    // REGISTERED self + 其他 REGISTERED 成员 + PLACEHOLDER
    final selfId = registeredMemberId(id, testUserId);
    final otherId = 'member-other-$name';
    final placeholderId = 'placeholder-$name';
    await db.batch((b) {
      b.insertAll(db.ledgerMembers, [
        LedgerMembersCompanion.insert(
          id: selfId,
          ledgerId: id,
          displayName: '云本人',
          memberType: 'REGISTERED',
          linkedAccountId: d.Value(testUserId),
          role: const d.Value('owner'),
          updatedAt: DateTime.now().toUtc(),
        ),
        LedgerMembersCompanion.insert(
          id: otherId,
          ledgerId: id,
          displayName: '小王',
          memberType: 'REGISTERED',
          linkedAccountId: d.Value('other-user-id'),
          role: const d.Value('editor'),
          updatedAt: DateTime.now().toUtc(),
        ),
        LedgerMembersCompanion.insert(
          id: placeholderId,
          ledgerId: id,
          displayName: '小张',
          memberType: 'PLACEHOLDER',
          updatedAt: DateTime.now().toUtc(),
        ),
      ]);
    });
    await (db.update(db.ledgers)..where((l) => l.id.equals(id))).write(
      LedgersCompanion(selfMemberId: d.Value(selfId)),
    );
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    // 交易创建人/分摊引用 self，用于验证成员映射重写
    await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
      TransactionsCompanion(createdByMemberId: d.Value(selfId)),
    );
    await repo.replaceTransactionSplits(txId, [
      TransactionSplitInput(memberId: selfId, amount: '6.00'),
      TransactionSplitInput(memberId: placeholderId, amount: '4.00'),
    ]);
    return id;
  }

  test(
    'moveToLocal：隐藏 Fork → accepted → 发布新本地账本（新 ledger id + 成员本地化）',
    () async {
      final id = await seedCloudLedger('A');
      when(
        () => sync.pushLedgerDelete(ledgerId: id),
      ).thenAnswer((_) async => 'accepted');

      await actions.moveToLocal(id);

      // 源云端行已清除（级联子表），新本地账本发布
      expect(await repo.getLedgerById(id), isNull, reason: '旧云缓存必须整本清除');
      final ledgers = await repo.getAllLedgers();
      expect(ledgers, hasLength(1));
      final fork = ledgers.single;
      expect(fork.id, isNot(id), reason: '云转本地必须生成新 ledger id');
      expect(fork.storageMode, 'local');
      expect(fork.bindingStatus, isNull, reason: '发布后隐藏 intent 必须置空');
      expect(fork.originLedgerId, id, reason: 'origin_ledger_id 保留来源链');

      // 成员本地化：self 是 LOCAL；其他 REGISTERED 与 PLACEHOLDER 分别映射、不合并
      final members = await (db.select(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.equals(fork.id))).get();
      expect(members, hasLength(3), reason: '三人各自独立，不能合并');
      final self = members.where((m) => m.memberType == 'LOCAL').toList();
      expect(self, hasLength(1));
      final placeholders = members
          .where((m) => m.memberType == 'PLACEHOLDER')
          .toList();
      expect(
        placeholders,
        hasLength(2),
        reason: '其他 REGISTERED 与 PLACEHOLDER 各自映射为独立占位',
      );
      expect(placeholders.map((m) => m.displayName).toSet(), {
        '小王',
        '小张',
      }, reason: '成员展示快照保留');
      // 交易引用重写：创建人/分摊指向本地化后的成员
      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(fork.id))).getSingle();
      expect(tx.createdByMemberId, self.single.id);
      final splits = await repo.getTransactionSplits(tx.id);
      expect(splits, hasLength(2));
      final allMemberIds = members.map((m) => m.id).toSet();
      expect(
        splits.every((s) => allMemberIds.contains(s.memberId)),
        isTrue,
        reason: '分摊参与人必须是本地化后的成员',
      );
      expect(
        splits.map((s) => s.memberId).contains(self.single.id),
        isTrue,
        reason: '本人分摊行保留',
      );
      // 源 delete 变更已随推送消费，无残留
      expect(await db.select(db.syncChanges).get(), isEmpty);
    },
  );

  test(
    'moveToLocal：云端删除 invalid/conflict → 隐藏 Fork 保留、源行不动、delete 变更移除',
    () async {
      final id = await seedCloudLedger('B');
      when(
        () => sync.pushLedgerDelete(ledgerId: id),
      ).thenAnswer((_) async => 'conflict');

      await expectLater(actions.moveToLocal(id), throwsStateError);

      // 源云账本原样保留（归属/数据不动）
      final ledger = await repo.getLedgerById(id);
      expect(ledger!.storageMode, 'cloud');
      // 隐藏 Fork 存在且保持 pending_local_move（持久 intent，可重试/取消）
      final forks = await repo.getPendingLocalMoveForks();
      expect(forks, hasLength(1));
      expect(forks.single.originLedgerId, id);
      // delete 变更移除，防止下次 push 误删云端（账本级待推送交易变更仍保留）
      final remaining = await db.select(db.syncChanges).get();
      expect(
        remaining.where((c) => c.action == 'delete' && c.ledgerId == id),
        isEmpty,
      );
      // 隐藏副本不出现在正常账本列表（恢复完成前不展示重复账本）
      expect(await repo.getAllLedgers(), hasLength(1));
    },
  );

  test('moveToLocal：云端删除 ignored 但权威查询证明已删 → 继续发布', () async {
    final id = await seedCloudLedger('C');
    when(
      () => sync.pushLedgerDelete(ledgerId: id),
    ).thenAnswer((_) async => 'ignored');
    when(
      () => sync.fetchLedgerRemoteStatus(id),
    ).thenAnswer((_) async => (deleted: true));

    await actions.moveToLocal(id);
    verify(() => sync.fetchLedgerRemoteStatus(id)).called(1);
    expect(await repo.getLedgerById(id), isNull);
    expect(await repo.getAllLedgers(), hasLength(1));
  });

  test('moveToLocal：ignored 但权威查询证明源仍存活 → 拒绝发布', () async {
    final id = await seedCloudLedger('D');
    when(
      () => sync.pushLedgerDelete(ledgerId: id),
    ).thenAnswer((_) async => 'ignored');
    when(
      () => sync.fetchLedgerRemoteStatus(id),
    ).thenAnswer((_) async => (deleted: false));

    await expectLater(actions.moveToLocal(id), throwsStateError);
    expect(await repo.getLedgerById(id), isNotNull);
    expect((await repo.getPendingLocalMoveForks()).single.originLedgerId, id);
  });

  test('moveToLocal 幂等：已是本地账本时零副作用', () async {
    final id = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await actions.moveToLocal(id);
    verifyNever(() => sync.push());
    expect(await repo.getLedgerById(id), isNotNull);
  });

  test('copyToLocal：云端账本复制本地副本，云端原件保留', () async {
    final id = 'cloud-copy';
    await repo.createBoundLedger(id: id, name: '云端账本', aaEnabled: true);
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    await repo.createPlaceholderMember(ledgerId: id, name: '小明');
    await repo.replaceTransactionSplits(txId, [
      TransactionSplitInput(memberId: 'vu-1', amount: '10.00'),
    ]);

    final newId = await actions.copyToLocal(id);

    // 新账本为本地归属，数据完整复制。
    final copy = await repo.getLedgerById(newId);
    expect(copy, isNotNull);
    expect(copy!.storageMode, 'local', reason: '副本必须为纯本地归属');
    expect(copy.name, '云端账本');
    expect(copy.aaEnabled, isTrue);
    final copyTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(newId))).get();
    expect(copyTxs, hasLength(1), reason: '交易必须复制到副本');
    expect(copyTxs.single.id, isNot(txId), reason: '副本交易必须使用新 UUID');
    final copySplits = await repo.getTransactionSplits(copyTxs.single.id);
    expect(copySplits, hasLength(1), reason: 'AA 指定分摊行必须随交易复制');
    final copyVus =
        await (db.select(db.ledgerMembers)..where(
              (v) =>
                  v.ledgerId.equals(newId) & v.memberType.equals('PLACEHOLDER'),
            ))
            .get();
    expect(copyVus, hasLength(1), reason: '占位成员（原虚拟用户）必须复制到副本');

    // 云端原件原样保留（归属/交易/分摊均不变）。
    final src = await repo.getLedgerById(id);
    expect(src!.storageMode, 'cloud');
    final srcTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(srcTxs, hasLength(1));
    expect(srcTxs.single.id, txId);
    expect(await repo.getTransactionSplits(txId), hasLength(1));
  });

  test('copyToLocal：源不存在抛错；本地账本不能复制', () async {
    await expectLater(actions.copyToLocal('no-such-id'), throwsStateError);
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await expectLater(
      actions.copyToLocal(localId),
      throwsStateError,
      reason: '复制到本地是「云端→本地」单向动作，本地账本无意义',
    );
  });
}
