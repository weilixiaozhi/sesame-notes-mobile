import 'dart:convert';

import 'package:sesame_notes/data/models/transaction_split_input.dart';
import '../helpers/ledger_sync_fixture.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../helpers/test_isolation.dart';
import '../helpers/bound_ledger_seed.dart';

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

/// 验证账本归属转换及同步队列在已配置云服务下的行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late LedgerSyncFixture sync;
  late ProviderContainer container;
  late DataLifecycleActions actions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => testUserId,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => testUserId),
    );
    sync = LedgerSyncFixture(
      db,
      testUserId,
      localSelfId: () => container.read(localSelfIdProvider.future),
    );
    // 归属转换的后台同步在此只模拟传输完成，保留待推送队列供业务断言检查。
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        // 服务能力与账本同步夹具使用同一个模拟地址。
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://sync.test'),
        ),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync.service),
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
    actions = container.read(dataLifecycleProvider);
  });

  tearDown(() async {
    // 转云动作提交后会启动后台同步，销毁测试作用域前先等待现有串行队列排空。
    await container
        .read(syncCoordinatorProvider)
        .runAccountTransition(() async {});
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
      type: 'expense',
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
            protocolVersion: const d.Value(1),
            timeZone: const d.Value('UTC'),
            startDate: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  test('转云历史意图仅属于首次 FIFO，后续编辑不改写未发或冻结请求', () async {
    final ledgerId = await seedLocalLedger('历史初始化队列');
    final members = await repo.getMembersByLedger(ledgerId);
    final member = members.singleWhere(
      (row) => row.memberType == 'PLACEHOLDER',
    );
    await (db.update(db.ledgerMembers)
          ..where((row) => row.id.equals(member.id)))
        .write(const LedgerMembersCompanion(status: d.Value('LEFT')));
    await actions.promoteLocal(SyncTarget('ledger', ledgerId));
    final tx = (await (db.select(
      db.transactions,
    )..where((row) => row.ledgerId.equals(ledgerId))).get()).first;
    Future<List<SyncChange>> queue(String id) =>
        (db.select(db.syncChanges)
              ..where((row) => row.entityId.equals(id))
              ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
            .get();
    final initialTx = (await queue(tx.id)).single;
    final initialMember = (await queue(member.id)).single;
    expect(jsonDecode(initialTx.payload)['initial_history'], isTrue);
    expect(jsonDecode(initialMember.payload)['initial_status'], 'LEFT');

    Future<void> edit(String suffix) async {
      await repo.updateTransaction(
        id: tx.id,
        type: 'expense',
        amount: '12',
        note: suffix,
      );
      await repo.renameMember(id: member.id, name: suffix);
    }

    await edit('首次发送前');
    expect((await queue(tx.id)).first, initialTx);
    expect((await queue(member.id)).first, initialMember);
    expect(
      jsonDecode(
        (await queue(tx.id)).last.payload,
      ).containsKey('initial_history'),
      isFalse,
    );
    expect(
      jsonDecode(
        (await queue(member.id)).last.payload,
      ).containsKey('initial_status'),
      isFalse,
    );
    expect((await queue(tx.id)).last.baseRevision, 1);

    String frozenBody(SyncChange first) => jsonEncode({
      'payload': jsonDecode(first.payload),
      'updated_at': first.updatedAt.toUtc().toIso8601String(),
    });
    // 模拟首条已交给传输层但尚无回执；登记器必须保留冻结字节和 mutation。
    for (final first in [initialTx, initialMember]) {
      await (db.update(
        db.syncChanges,
      )..where((row) => row.id.equals(first.id))).write(
        SyncChangesCompanion(frozenRequest: d.Value(frozenBody(first))),
      );
    }
    await edit('回执未知时');
    for (final first in [initialTx, initialMember]) {
      final rows = await queue(first.entityId);
      expect(rows, hasLength(3));
      expect(rows.first.mutationId, first.mutationId);
      expect(rows.first.frozenRequest, frozenBody(first));
      expect(rows.first.payload, first.payload);
      expect(
        jsonDecode(rows.last.payload).containsKey('initial_history'),
        isFalse,
      );
      expect(
        jsonDecode(rows.last.payload).containsKey('initial_status'),
        isFalse,
      );
    }
    expect((await queue(tx.id)).last.baseRevision, 2);

    // 已确认后再编辑是既有实体更新，不可再次取得首次历史导入标记。
    await (db.update(db.syncChanges)
          ..where((row) => row.ledgerId.equals(ledgerId)))
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())));
    await (db.update(db.transactions)..where((row) => row.id.equals(tx.id)))
        .write(const TransactionsCompanion(serverRevision: d.Value(3)));
    await edit('确认后');
    expect((await queue(tx.id)).last.baseRevision, 3);
    expect(
      jsonDecode(
        (await queue(tx.id)).last.payload,
      ).containsKey('initial_history'),
      isFalse,
    );
    expect(
      jsonDecode(
        (await queue(member.id)).last.payload,
      ).containsKey('initial_status'),
      isFalse,
    );
  });

  test('首次历史明确拒收后修正保留原意图，普通失败不取得初始化标记', () async {
    final ledger = await seedLocalLedger('拒收恢复');
    final member = (await repo.getMembersByLedger(
      ledger,
    )).singleWhere((row) => row.memberType == 'PLACEHOLDER');
    await (db.update(db.ledgerMembers)
          ..where((row) => row.id.equals(member.id)))
        .write(const LedgerMembersCompanion(status: d.Value('LEFT')));
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    final tx = (await (db.select(
      db.transactions,
    )..where((row) => row.ledgerId.equals(ledger))).get()).first;
    Future<SyncChange> pending(String id) =>
        (db.select(db.syncChanges)
              ..where((row) => row.entityId.equals(id) & row.pushedAt.isNull()))
            .getSingle();
    Future<int> reject(String id) =>
        (db.update(db.syncChanges)
              ..where((row) => row.entityId.equals(id) & row.pushedAt.isNull()))
            .write(
              const SyncChangesCompanion(rejectionReason: d.Value('明确拒收')),
            );
    final firstTx = await pending(tx.id);
    final firstMember = await pending(member.id);
    await reject(tx.id);
    await reject(member.id);
    await repo.updateTransaction(
      id: tx.id,
      type: 'expense',
      amount: '15',
      note: '修正历史',
    );
    await repo.renameMember(id: member.id, name: '修正历史成员');
    final fixedTx = await pending(tx.id);
    final fixedMember = await pending(member.id);
    expect(fixedTx.mutationId, isNot(firstTx.mutationId));
    expect(fixedMember.mutationId, isNot(firstMember.mutationId));
    expect(jsonDecode(fixedTx.payload)['initial_history'], isTrue);
    expect(jsonDecode(fixedMember.payload)['initial_status'], 'LEFT');
    expect(jsonDecode(fixedMember.payload)['display_name'], '修正历史成员');

    // 云端已有同 UUID 但尚无本地确认时，再次纠错仍须携带原 marker 让服务端拒绝。
    await reject(member.id);
    await repo.renameMember(id: member.id, name: '已有身份不能降级普通写');
    expect(
      jsonDecode((await pending(member.id)).payload)['initial_status'],
      'LEFT',
    );

    final ordinary = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '普通创建',
    );
    await reject(ordinary);
    await repo.renameMember(id: ordinary, name: '普通修正');
    expect(
      jsonDecode(
        (await pending(ordinary)).payload,
      ).containsKey('initial_status'),
      isFalse,
    );
    await (db.update(
      db.syncChanges,
    )..where((row) => row.entityId.equals(member.id))).write(
      SyncChangesCompanion(
        pushedAt: d.Value(DateTime.now().toUtc()),
        rejectionReason: const d.Value(null),
      ),
    );
    await repo.renameMember(id: member.id, name: '已确认后普通修改');
    await reject(member.id);
    await repo.renameMember(id: member.id, name: '已确认后纠错');
    expect(
      jsonDecode(
        (await pending(member.id)).payload,
      ).containsKey('initial_status'),
      isFalse,
    );
  });

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

    await actions.moveToCloud(SyncTarget('ledger', id));

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
    await expectLater(
      actions.moveToCloud(SyncTarget('ledger', id)),
      throwsStateError,
    );
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

    await actions.moveToCloud(SyncTarget('ledger', id));

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

  test('moveToCloud：原ID复制到账号目录，本地原分类及其他账本引用保留', () async {
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

    await actions.moveToCloud(SyncTarget('ledger', id));

    // 本地目录和账号目录使用同 UUID 的独立身份，各自引用按账本所属域解析。
    final cats = await db.select(db.categories).get();
    expect(cats, hasLength(2), reason: '本地原行必须保留，账号目录各保存一份原身份');
    expect(cats.map((c) => c.id).toSet(), {categoryId});
    expect(cats.map((c) => c.scopeAccountId).toSet(), {null, testUserId});
    // 两个账本保持原 UUID，分别解析本地与当前账号自己的目录。
    final txRows = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get();
    expect(
      txRows.any((t) => t.categoryId == categoryId),
      isTrue,
      reason: '转换账本交易引用不变',
    );
    final otherTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(otherId))).get();
    expect(otherTxs.any((t) => t.categoryId == categoryId), isTrue);
    // 迁域分类必须登记 user-global upsert（服务端按 id 幂等收敛）
    final categoryChanges = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('category'))).get();
    expect(categoryChanges, hasLength(1));
    expect(categoryChanges.single.entityId, categoryId);
    expect(categoryChanges.single.accountId, testUserId);
  });

  test('moveToCloud：backfill 交易 payload 的 category_id 保持原分类 id', () async {
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

    await actions.moveToCloud(SyncTarget('ledger', id));

    // 分类迁域不改 id：账号域行与交易引用仍是原 id
    final cat = await (db.select(
      db.categories,
    )..where((c) => c.scopeAccountId.equals(testUserId))).getSingle();
    expect(cat.id, categoryId, reason: '迁域不得克隆新 id');
    final txChanges = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('transaction'))).get();
    expect(txChanges, hasLength(3));
    // 带分类的交易 payload 必须携带同一分类原 id（云端按 id 幂等收敛）
    final withCategory =
        await (db.select(db.transactions)..where(
              (t) => t.ledgerId.equals(id) & t.categoryId.equals(categoryId),
            ))
            .getSingle();
    final change = txChanges.singleWhere((c) => c.entityId == withCategory.id);
    expect(
      change.payload,
      contains(categoryId),
      reason: '交易 payload 必须携带同一分类原 id（云端按 id 幂等收敛）',
    );
  });

  test(
    'moveToCloud：backfill 交易 payload 的 aa_mode 为契约 wire 字符串且保留 recurring_id',
    () async {
      final id = await seedLocalLedger('aa账本');
      final localSelfId = (await repo.getLedgerById(id))!.selfMemberId!;
      final recurringId = const Uuid().v4();
      // 该用例通过真实生成入口建立协议 1 的来源和确定日期，再设置指定分摊。
      await (db.update(
        db.recurringTransactions,
      )..where((row) => row.id.equals('rec-$id'))).write(
        RecurringTransactionsCompanion(
          id: d.Value(recurringId),
          amount: const d.Value('30'),
        ),
      );
      final rule = await (db.select(
        db.recurringTransactions,
      )..where((row) => row.id.equals(recurringId))).getSingle();
      final txId = await repo.generateRecurringTransaction(
        recurring: rule,
        happenedAt: DateTime.utc(2026, 8, 1),
      );
      expect(txId, recurringOccurrenceId(id, recurringId, '2026-08-01'));
      await repo.replaceTransactionSplits(txId, [
        TransactionSplitInput(memberId: localSelfId, amount: '30'),
      ]);
      await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
        const TransactionsCompanion(aaMode: d.Value(2)),
      );

      await actions.moveToCloud(SyncTarget('ledger', id));

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
        contains('"recurring_id":"$recurringId"'),
        reason: '周期模板生成的交易必须保留模板关联',
      );
      final payload = jsonDecode(change.payload) as Map<String, dynamic>;
      expect(payload['occurrence_date'], '2026-08-01');
      expect(payload['splits'], [
        {'member_id': registeredMemberId(id, testUserId), 'amount': '30'},
      ], reason: '转云后保留指定分摊金额，并将本人引用映射到当前账号');
    },
  );

  test('moveToCloud：两本先后迁云复用一份账号类别，另保留独立本地原行', () async {
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

    await actions.moveToCloud(SyncTarget('ledger', first));
    await actions.moveToCloud(SyncTarget('ledger', second));

    // 重复迁云复用同一个账号实体，不能在该账号中新增第二个类别。
    final cats = await db.select(db.categories).get();
    expect(cats, hasLength(2));
    expect(cats.map((c) => c.id).toSet(), {categoryId});
    expect(cats.where((c) => c.scopeAccountId == testUserId), hasLength(1));
    expect(cats.where((c) => c.scopeAccountId == null), hasLength(1));
    final secondTxs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(second))).get();
    expect(
      secondTxs.every(
        (t) => t.categoryId == null || t.categoryId == categoryId,
      ),
      isTrue,
      reason: '第二本账本的交易仍引用同一行',
    );
  });

  test('moveToCloud：确定性默认UUID按本地与账号分域，复用原ID与原时间', () async {
    final id = await seedLocalLedger('种子分类账本');
    final categoryTime = DateTime.utc(2024, 1, 1);
    // 默认 UUID 稳定；不同账号或本地域各自持有独立分类身份。
    final seedCatId = SeedService.deterministicCategorySyncId(
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
            updatedAt: categoryTime,
          ),
        );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '15.00',
      happenedAt: DateTime(2026, 7, 8),
      categoryId: seedCatId,
    );

    await actions.moveToCloud(SyncTarget('ledger', id));

    // 本地原分类保留，账号独立目录使用原 UUID，不生成额外默认身份。
    final cats = await db.select(db.categories).get();
    expect(cats, hasLength(2));
    expect(cats.map((c) => c.id).toSet(), {seedCatId});
    expect(cats.map((c) => c.scopeAccountId).toSet(), {null, testUserId});
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
    expect(catChange.updatedAt.toUtc(), categoryTime);
    expect(
      DateTime.parse(
        jsonDecode(catChange.payload)['updated_at'] as String,
      ).toUtc(),
      categoryTime,
    );
    expect(cats.every((c) => c.updatedAt.toUtc() == categoryTime), isTrue);
  });

  test('moveToCloud 幂等：已是云端账本时零副作用', () async {
    final id = 'cloud-1';
    await seedBoundLedger(
      db,
      accountId: testUserId,
      id: id,
      name: '云端账本',
      ownerAccountId: testUserId,
    );
    await actions.moveToCloud(SyncTarget('ledger', id));
    expect(
      await db.select(db.syncChanges).get(),
      isEmpty,
      reason: '已是云端账本不应重复登记变更',
    );
  });

  test('moveToCloud：账本不存在抛错', () async {
    expect(
      () => actions.moveToCloud(SyncTarget('ledger', 'no-such-id')),
      throwsStateError,
    );
  });

  /// 构造已绑定云端账本（scope 归测试账号），含 REGISTERED self 与共享成员。
  Future<String> seedCloudLedger(String name) async {
    final id = 'cloud-$name';
    await seedBoundLedger(
      db,
      accountId: testUserId,
      id: id,
      name: name,
      syncId: 'sync-$name',
      ownerAccountId: testUserId,
    );
    // REGISTERED self + 其他 REGISTERED 成员 + PLACEHOLDER
    final selfId = registeredMemberId(id, testUserId);
    final otherId = 'member-other-$name';
    final placeholderId = const Uuid().v4();
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
      sync.deleteStatus = 'accepted';

      await actions.moveToLocal(SyncTarget('ledger', id));

      // 源云端账本保留已确认墓碑，新本地账本发布。
      expect(
        (await (db.select(
          db.ledgers,
        )..where((b) => b.id.equals(id))).getSingle()).deletedAt,
        isNotNull,
        reason: '源本必须保留确认后的墓碑',
      );
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
      expect(
        await (db.select(
          db.syncChanges,
        )..where((c) => c.pushedAt.isNull())).get(),
        isEmpty,
      );
    },
  );

  test(
    'moveToLocal：云端删除 invalid/conflict → 隐藏 Fork 保留、源行不动、delete 变更保留待处理',
    () async {
      final id = await seedCloudLedger('B');
      sync.deleteStatus = 'conflict';

      await expectLater(
        actions.moveToLocal(SyncTarget('ledger', id)),
        throwsStateError,
      );

      // 源云账本原样保留（归属/数据不动）
      final ledger = await repo.getLedgerById(id);
      expect(ledger!.storageMode, 'cloud');
      // 隐藏 Fork 存在且保持 pending_local_move（持久 intent，可重试/取消）
      final forks = await repo.getPendingLocalMoveForks();
      expect(forks, hasLength(1));
      expect(forks.single.originLedgerId, id);
      // 冲突对应的冻结删除仍持久保存，供全局决策处理，不能当作未知请求直接抹去。
      final remaining = await db.select(db.syncChanges).get();
      expect(
        remaining.where(
          (c) => c.action == 'delete' && c.ledgerId == id && c.pushedAt == null,
        ),
        hasLength(1),
      );
      expect(
        remaining.singleWhere((c) => c.action == 'delete').frozenRequest,
        isNotNull,
      );
      expect((await db.select(db.syncConflicts).get()).single.status, 'OPEN');
      // 隐藏副本不出现在正常账本列表（恢复完成前不展示重复账本）
      expect(await repo.getAllLedgers(), hasLength(1));
    },
  );

  test('moveToLocal：云端删除 ignored 但权威查询证明已删 → 继续发布', () async {
    final id = await seedCloudLedger('C');
    sync.deleteStatus = 'ignored';
    sync.remoteDeleted = true;

    await actions.moveToLocal(SyncTarget('ledger', id));
    expect(sync.deleteCalls, 1);
    expect(sync.fullCalls, 2);
    expect(
      (await (db.select(
        db.ledgers,
      )..where((b) => b.id.equals(id))).getSingle()).deletedAt,
      isNotNull,
    );
    expect(await repo.getAllLedgers(), hasLength(1));
  });

  test('moveToLocal：ignored 但权威查询证明源仍存活 → 拒绝发布', () async {
    final id = await seedCloudLedger('D');
    sync.deleteStatus = 'ignored';
    sync.remoteDeleted = false;

    await expectLater(
      actions.moveToLocal(SyncTarget('ledger', id)),
      throwsStateError,
    );
    expect(await repo.getLedgerById(id), isNotNull);
    expect((await repo.getPendingLocalMoveForks()).single.originLedgerId, id);
  });

  test('moveToLocal 幂等：已是本地账本时零副作用', () async {
    final id = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await actions.moveToLocal(SyncTarget('ledger', id));
    expect(sync.requests, isEmpty);
    expect(await repo.getLedgerById(id), isNotNull);
  });

  test('copyToLocal：云端账本复制本地副本，云端原件保留', () async {
    final id = 'cloud-copy';
    await seedBoundLedger(
      db,
      accountId: testUserId,
      id: id,
      name: '云端账本',
      aaEnabled: true,
      ownerAccountId: testUserId,
    );
    await (db.update(db.ledgers)..where((row) => row.id.equals(id))).write(
      const LedgersCompanion(syncId: d.Value('S-BOUND')),
    );
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    final memberId = await repo.createPlaceholderMember(
      ledgerId: id,
      name: '小明',
    );
    await repo.replaceTransactionSplits(txId, [
      TransactionSplitInput(memberId: memberId, amount: '10.00'),
    ]);

    final newId = await actions.copyToLocal(SyncTarget('ledger', id));

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

  test('copyToLocal：离线新云本的周期模板和本人身份完整本地化', () async {
    final id = await seedLocalLedger('完整复制');
    await actions.promoteLocal(SyncTarget('ledger', id));
    final copy = await actions.copyToLocal(SyncTarget('ledger', id));
    final ledger = (await repo.getLedgerById(copy))!;
    expect(ledger.storageMode, 'local');
    expect(ledger.scopeAccountId, isNull);
    expect(
      (await repo.getMemberById(ledger.selfMemberId!))!.memberType,
      'LOCAL',
    );
    final recurring = await (db.select(
      db.recurringTransactions,
    )..where((r) => r.ledgerId.equals(copy))).get();
    expect(recurring, hasLength(1));
    expect(recurring.single.amount, '5.00');
    expect(recurring.single.protocolVersion, 1);
    expect(recurring.single.timeZone, 'UTC');
    expect(recurring.single.startDate.toUtc(), DateTime.utc(2026, 8, 1));
    expect(recurring.single.id, isNot('rec-$id'));
    expect(await repo.getTransactionsByLedger(copy), hasLength(2));
    expect((await repo.getLedgerById(id))!.storageMode, 'cloud');
  });

  test('copyToLocal：源不存在抛错；本地账本不能复制', () async {
    await expectLater(
      actions.copyToLocal(SyncTarget('ledger', 'no-such-id')),
      throwsStateError,
    );
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await expectLater(
      actions.copyToLocal(SyncTarget('ledger', localId)),
      throwsStateError,
      reason: '复制到本地是「云端→本地」单向动作，本地账本无意义',
    );
  });
}
