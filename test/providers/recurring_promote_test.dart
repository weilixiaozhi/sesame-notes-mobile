import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../helpers/test_isolation.dart';

/// 测试凭证只驻留内存，转云编排不连接网络或系统安全存储。
class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;

  @override
  Future<void> delete() async => value = null;
}

const _account = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late LocalCategoryRepository localCategories;
  late ProviderContainer container;
  late DataLifecycleActions actions;
  final day = DateTime.utc(2024, 1, 1);

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => _account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => _account),
    );
    localCategories = LocalCategoryRepository(db, categoryScopeId: '');
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
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
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'fixture-token',
            userId: _account,
            deviceId: 'fixture-device',
          ),
        );
    actions = container.read(dataLifecycleProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 使用正常本地创建入口生成LOCAL本人及账本，不提前登记云端变更。
  Future<String> localLedger() => repo.createLedger(
    name: '本地周期历史验收',
    storageMode: 'local',
    localSelfId: 'fixture-local-self',
  );

  /// 新规则使用真实仓储校验，初始发生日期固定在过去。
  Future<RecurringTransaction> rule(
    String ledgerId, {
    DateTime? start,
    String? category,
  }) async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: start ?? day,
      categoryId: category,
      timeZone: 'UTC',
    );
    return (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  /// 事务失败前后比较所有可被归属转换修改的表，避免只检查storageMode而漏掉队列或身份。
  Future<Map<String, Object?>> state() async => {
    'ledgers': (await db.select(db.ledgers).get())
        .map((row) => row.toJson())
        .toList(),
    'members': (await db.select(db.ledgerMembers).get())
        .map((row) => row.toJson())
        .toList(),
    'transactions': (await db.select(db.transactions).get())
        .map((row) => row.toJson())
        .toList(),
    'rules': (await db.select(db.recurringTransactions).get())
        .map((row) => row.toJson())
        .toList(),
    'splits': (await db.select(db.transactionSplits).get())
        .map((row) => row.toJson())
        .toList(),
    'histories': (await db.select(db.recordEditHistories).get())
        .map((row) => row.toJson())
        .toList(),
    'categories': (await db.select(db.categories).get())
        .map((row) => row.toJson())
        .toList(),
    'queue': (await db.select(db.syncChanges).get())
        .map((row) => row.toJson())
        .toList(),
  };

  /// 覆盖已暂停/已删除规则、人工修改发生、发生墓碑和AA成员引用。
  Future<
    ({
      String ledger,
      String pausedRule,
      String deletedRule,
      String edited,
      String tombstone,
      String deletedRuleOccurrence,
      String ordinary,
      String placeholder,
    })
  >
  history() async {
    final ledger = await localLedger();
    final self = (await repo.getLedgerById(ledger))!.selfMemberId!;
    final placeholder = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '同行成员',
    );
    final paused = await rule(ledger);
    final edited = await repo.generateRecurringTransaction(
      recurring: paused,
      happenedAt: day,
    );
    await repo.updateTransaction(
      id: edited,
      type: 'expense',
      amount: '99',
      note: '人工修改后保留',
      operatorMemberId: self,
    );
    await (db.update(
      db.transactions,
    )..where((row) => row.id.equals(edited))).write(
      TransactionsCompanion(
        aaMode: const d.Value(2),
        payerMemberId: d.Value(self),
      ),
    );
    await repo.replaceTransactionSplits(edited, [
      TransactionSplitInput(memberId: self, amount: '60'),
      TransactionSplitInput(memberId: placeholder, amount: '39'),
    ]);
    final current = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(paused.id))).getSingle();
    final tombstone = await repo.generateRecurringTransaction(
      recurring: current,
      happenedAt: day.add(const Duration(days: 1)),
    );
    await repo.deleteTransaction(tombstone);
    await repo.toggleRecurringTransaction(paused.id, false);
    final removed = await rule(ledger);
    final removedOccurrence = await repo.generateRecurringTransaction(
      recurring: removed,
      happenedAt: day,
    );
    await repo.deleteRecurringTransaction(removed.id);
    final ordinary = await repo.addTransaction(
      ledgerId: ledger,
      type: 'expense',
      amount: '7',
      happenedAt: day,
      operatorMemberId: self,
    );
    return (
      ledger: ledger,
      pausedRule: paused.id,
      deletedRule: removed.id,
      edited: edited,
      tombstone: tombstone,
      deletedRuleOccurrence: removedOccurrence,
      ordinary: ordinary,
      placeholder: placeholder,
    );
  }

  test('转云初始包完整保留人工修改、暂停规则、已删规则和发生墓碑，并重映射AA本人', () async {
    final seeded = await history();
    expect(await db.select(db.syncChanges).get(), isEmpty);
    final deletedBefore = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(seeded.deletedRule))).getSingle();
    final tombstoneBefore = await (db.select(
      db.transactions,
    )..where((row) => row.id.equals(seeded.tombstone))).getSingle();
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    final registered = registeredMemberId(seeded.ledger, _account);
    final ledger = (await repo.getLedgerById(seeded.ledger))!;
    expect(ledger.storageMode, 'cloud');
    expect(ledger.scopeAccountId, _account);
    expect(ledger.selfMemberId, registered);
    final queue = await db.select(db.syncChanges).get();
    expect(queue, hasLength(7));
    expect(
      queue.every((row) => row.accountId == _account && row.action == 'upsert'),
      isTrue,
    );
    final rules = {
      for (final change in queue.where(
        (row) => row.entityType == 'recurring_transaction',
      ))
        change.entityId: jsonDecode(change.payload) as Map<String, dynamic>,
    };
    expect(
      rules.keys,
      unorderedEquals([seeded.pausedRule, seeded.deletedRule]),
    );
    expect(rules[seeded.pausedRule]!['enabled'], isFalse);
    final initial =
        rules[seeded.pausedRule]!['initial_state'] as Map<String, dynamic>;
    expect(initial['last_generated_date'], '2024-01-02T00:00:00.000Z');
    expect(initial['deleted_at'], isNull);
    final occurrences = (initial['occurrences'] as List)
        .cast<Map<String, dynamic>>();
    expect(
      occurrences.map((row) => row['id']),
      unorderedEquals([seeded.edited, seeded.tombstone]),
    );
    final edited =
        occurrences.singleWhere((row) => row['id'] == seeded.edited)['payload']
            as Map<String, dynamic>;
    expect(edited['amount'], '99');
    expect(edited['note'], '人工修改后保留');
    expect(edited['recurring_id'], seeded.pausedRule);
    expect(edited['occurrence_date'], '2024-01-01');
    expect(edited['payer_member_id'], registered);
    expect(
      edited['created_by_member_id'],
      isNull,
      reason: '自动发生保留原始空创建人，不伪造作者',
    );
    expect(edited['last_edited_by_member_id'], registered);
    final ordinaryPayload =
        jsonDecode(
              queue
                  .singleWhere((row) => row.entityId == seeded.ordinary)
                  .payload,
            )
            as Map<String, dynamic>;
    expect(ordinaryPayload['created_by_member_id'], registered);
    expect(edited['aa_mode'], '2');
    expect(
      edited['splits'],
      unorderedEquals([
        {'member_id': registered, 'amount': '60'},
        {'member_id': seeded.placeholder, 'amount': '39'},
      ]),
    );
    expect(
      occurrences.singleWhere(
        (row) => row['id'] == seeded.tombstone,
      )['deleted_at'],
      tombstoneBefore.deletedAt!.toUtc().toIso8601String(),
    );
    final removedInitial =
        rules[seeded.deletedRule]!['initial_state'] as Map<String, dynamic>;
    expect(
      removedInitial['deleted_at'],
      deletedBefore.deletedAt!.toUtc().toIso8601String(),
    );
    expect(
      (removedInitial['occurrences'] as List).single['id'],
      seeded.deletedRuleOccurrence,
    );
    expect(
      queue
          .where((row) => row.entityType == 'transaction')
          .map((row) => row.entityId),
      unorderedEquals([
        seeded.edited,
        seeded.deletedRuleOccurrence,
        seeded.ordinary,
      ]),
    );
    expect(
      (await db.select(db.transactions).get())
          .singleWhere((row) => row.id == seeded.tombstone)
          .deletedAt,
      isNotNull,
    );
  });

  for (final invalid in ['无效协议格式', '无发生证据的游标', '缺发生日期', '错误确定身份', '未来发生日期']) {
    test('$invalid拒绝转云且本人、原记录和队列完全不变', () async {
      final ledger = await localLedger();
      final recurring = await rule(ledger);
      if (invalid == '无效协议格式') {
        await (db.update(
          db.recurringTransactions,
        )..where((row) => row.id.equals(recurring.id))).write(
          const RecurringTransactionsCompanion(protocolVersion: d.Value(2)),
        );
      } else if (invalid == '无发生证据的游标') {
        await (db.update(
          db.recurringTransactions,
        )..where((row) => row.id.equals(recurring.id))).write(
          RecurringTransactionsCompanion(lastGeneratedDate: d.Value(day)),
        );
      } else {
        final generated = await repo.generateRecurringTransaction(
          recurring: recurring,
          happenedAt: day,
        );
        final future = recurringCalendarDate(
          DateTime.now().toUtc(),
        ).add(const Duration(days: 2));
        await (db.update(
          db.transactions,
        )..where((row) => row.id.equals(generated))).write(
          invalid == '缺发生日期'
              ? const TransactionsCompanion(occurrenceDate: d.Value(null))
              : invalid == '错误确定身份'
              ? const TransactionsCompanion(
                  id: d.Value('a963c781-7051-46aa-9baa-d72ba3f4fe44'),
                )
              : TransactionsCompanion(
                  id: d.Value(
                    recurringOccurrenceId(
                      ledger,
                      recurring.id,
                      recurringDateKey(future),
                    ),
                  ),
                  occurrenceDate: d.Value(recurringDateKey(future)),
                ),
        );
      }
      final before = await state();
      await expectLater(
        actions.promoteLocal(SyncTarget('ledger', ledger)),
        throwsStateError,
      );
      expect(await state(), before);
    });
  }

  test('超过10000个发生先拒绝，不翻云或截断历史', () async {
    final ledger = await localLedger();
    final start = DateTime.utc(1990, 1, 1);
    final recurring = await rule(ledger, start: start);
    final before = (await repo.getLedgerById(ledger))!;
    final membersBefore = await db.select(db.ledgerMembers).get();
    await db.batch(
      (batch) => batch.insertAll(db.transactions, [
        for (var index = 0; index < 10001; index++)
          TransactionsCompanion.insert(
            id: recurringOccurrenceId(
              ledger,
              recurring.id,
              recurringDateKey(start.add(Duration(days: index))),
            ),
            ledgerId: ledger,
            txType: 'expense',
            amount: '1',
            nativeAmount: '1',
            currencyCode: 'CNY',
            happenedAt: start.add(Duration(days: index)),
            createdAt: start,
            updatedAt: start,
            recurringId: d.Value(recurring.id),
            occurrenceDate: d.Value(
              recurringDateKey(start.add(Duration(days: index))),
            ),
          ),
      ]),
    );
    await expectLater(
      actions.promoteLocal(SyncTarget('ledger', ledger)),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '原因',
          contains('10000'),
        ),
      ),
    );
    expect(await repo.getLedgerById(ledger), before);
    expect(await db.select(db.ledgerMembers).get(), membersBefore);
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      (await db
              .customSelect('SELECT COUNT(*) AS count FROM transactions')
              .getSingle())
          .read<int>('count'),
      10001,
    );
  });

  test('两条规则各5001个发生允许整体转云，每条初始状态独立完整', () async {
    final ledger = await localLedger();
    final start = DateTime.utc(1990, 1, 1);
    final first = await rule(ledger, start: start);
    final second = await rule(ledger, start: start);
    final last = start.add(const Duration(days: 5000));
    await db.batch((batch) {
      batch.insertAll(db.transactions, [
        for (final recurring in [first, second])
          for (var index = 0; index < 5001; index++)
            TransactionsCompanion.insert(
              id: recurringOccurrenceId(
                ledger,
                recurring.id,
                recurringDateKey(start.add(Duration(days: index))),
              ),
              ledgerId: ledger,
              txType: 'expense',
              amount: '1',
              nativeAmount: '1',
              currencyCode: 'CNY',
              happenedAt: start.add(Duration(days: index)),
              createdAt: start,
              updatedAt: start,
              recurringId: d.Value(recurring.id),
              occurrenceDate: d.Value(
                recurringDateKey(start.add(Duration(days: index))),
              ),
            ),
      ]);
    });
    await (db.update(
      db.recurringTransactions,
    )..where((row) => row.ledgerId.equals(ledger))).write(
      RecurringTransactionsCompanion(lastGeneratedDate: d.Value(last)),
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
    final queue = await db.select(db.syncChanges).get();
    expect(queue, hasLength(10005));
    final initialStates = queue
        .where((row) => row.entityType == 'recurring_transaction')
        .map(
          (row) =>
              (jsonDecode(row.payload) as Map<String, dynamic>)['initial_state']
                  as Map<String, dynamic>,
        )
        .toList();
    expect(initialStates, hasLength(2));
    for (final initial in initialStates) {
      expect(initial['last_generated_date'], last.toIso8601String());
      final occurrences = initial['occurrences'] as List;
      expect(occurrences, hasLength(5001));
      expect(occurrences.map((row) => row['id']).toSet(), hasLength(5001));
    }
    expect(
      queue.where((row) => row.entityType == 'transaction'),
      hasLength(10002),
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('仅历史墓碑引用的分类转云克隆并登记，规则更换分类不丢失原引用', () async {
    final seeded = await history();
    final historical = await localCategories.createCategory(
      name: '仅发生墓碑引用的分类',
      kind: 'expense',
      recordChanges: false,
    );
    final current = await localCategories.createCategory(
      name: '规则当前分类',
      kind: 'expense',
      recordChanges: false,
    );
    await (db.update(db.transactions)
          ..where((row) => row.id.equals(seeded.tombstone)))
        .write(TransactionsCompanion(categoryId: d.Value(historical)));
    await (db.update(db.recurringTransactions)
          ..where((row) => row.id.equals(seeded.pausedRule)))
        .write(RecurringTransactionsCompanion(categoryId: d.Value(current)));
    expect(await db.select(db.syncChanges).get(), isEmpty);
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    final categories =
        await (db.select(db.categories)..where(
              (row) =>
                  row.id.isIn([historical, current]) &
                  categoryScopePredicate(row, _account),
            ))
            .get();
    expect(categories, hasLength(2));
    expect(categories.every((row) => row.scopeAccountId == _account), isTrue);
    expect(
      (await localCategories.getAllCategories()).map((c) => c.id),
      containsAll([historical, current]),
    );
    final queue = await db.select(db.syncChanges).get();
    expect(
      queue
          .where((row) => row.entityType == 'category')
          .map((row) => row.entityId),
      unorderedEquals([historical, current]),
    );
    final payload =
        jsonDecode(
              queue
                  .singleWhere((row) => row.entityId == seeded.pausedRule)
                  .payload,
            )
            as Map<String, dynamic>;
    expect(payload['category_id'], current);
    final occurrences =
        (payload['initial_state'] as Map<String, dynamic>)['occurrences']
            as List;
    final tombstone = occurrences.cast<Map<String, dynamic>>().singleWhere(
      (row) => row['id'] == seeded.tombstone,
    );
    expect(tombstone['deleted_at'], isNotNull);
    expect(
      (tombstone['payload'] as Map<String, dynamic>)['category_id'],
      historical,
    );
  });
  for (final missing in ['分类', '成员']) {
    test('历史墓碑的$missing被异常硬删时转云拒绝且整本原状保留', () async {
      final ledger = await localLedger();
      final recurring = await rule(ledger);
      final tx = await repo.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: day,
      );
      final dependency = missing == '分类'
          ? await localCategories.createCategory(
              name: '历史弱引用',
              kind: 'expense',
              recordChanges: false,
            )
          : await repo.createPlaceholderMember(ledgerId: ledger, name: '历史成员');
      await repo.updateTransaction(
        id: tx,
        type: 'expense',
        amount: '12',
        categoryId: missing == '分类' ? dependency : null,
        payerMemberId: missing == '成员' ? dependency : null,
      );
      await repo.deleteTransaction(tx);
      // 故意绕开正常删除保护，模拟导入损坏或旧数据中的悬空弱引用。
      if (missing == '分类') {
        await (db.delete(
          db.categories,
        )..where((row) => row.id.equals(dependency))).go();
      } else {
        await (db.delete(
          db.ledgerMembers,
        )..where((row) => row.id.equals(dependency))).go();
      }
      final before = await state();
      await expectLater(
        actions.promoteLocal(SyncTarget('ledger', ledger)),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            '原因',
            contains(missing),
          ),
        ),
      );
      expect(await state(), before);
      expect((await repo.getLedgerById(ledger))!.storageMode, 'local');
      expect(await db.select(db.syncChanges).get(), isEmpty);
    });
  }

  for (final batch in [false, true]) {
    test('正常${batch ? '批量' : '单个'}删除分类后仍可转云，周期墓碑金额来源和删除状态完整', () async {
      final ledger = await localLedger();
      final recurring = await rule(ledger);
      final category = await localCategories.createCategory(
        name: '历史分类',
        kind: 'expense',
        recordChanges: false,
      );
      final tx = await repo.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: day,
      );
      await repo.updateTransaction(
        id: tx,
        type: 'expense',
        amount: '12',
        categoryId: category,
      );
      await repo.deleteTransaction(tx);
      final before = await (db.select(
        db.transactions,
      )..where((row) => row.id.equals(tx))).getSingle();
      if (batch) {
        await localCategories.deleteCategoriesByIds([category]);
      } else {
        await localCategories.deleteCategory(category);
      }
      final after = await (db.select(
        db.transactions,
      )..where((row) => row.id.equals(tx))).getSingle();
      expect(after.toJson(), {...before.toJson(), 'categoryId': null});
      await actions.promoteLocal(SyncTarget('ledger', ledger));
      expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
      final change = await (db.select(
        db.syncChanges,
      )..where((row) => row.entityId.equals(recurring.id))).getSingle();
      final payload = jsonDecode(change.payload) as Map<String, dynamic>;
      final occurrence =
          ((payload['initial_state'] as Map)['occurrences'] as List).single
              as Map;
      expect(occurrence['id'], tx);
      expect(
        occurrence['deleted_at'],
        before.deletedAt!.toUtc().toIso8601String(),
      );
      final transaction = occurrence['payload'] as Map;
      expect(transaction['category_id'], isNull);
      expect(transaction['amount'], '12');
      expect(transaction['native_amount'], '12');
      expect(transaction['recurring_id'], recurring.id);
      expect(transaction['occurrence_date'], '2024-01-01');
    });
  }

  test('仅被周期墓碑引用的成员不能删除，保留成员后转云完整保留付款关系', () async {
    final ledger = await localLedger();
    final recurring = await rule(ledger);
    final member = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '历史付款人',
    );
    final tx = await repo.generateRecurringTransaction(
      recurring: recurring,
      happenedAt: day,
    );
    await repo.updateTransaction(
      id: tx,
      type: 'expense',
      amount: '12',
      payerMemberId: member,
    );
    await repo.deleteTransaction(tx);
    final before = await state();
    await expectLater(repo.deleteMember(member), throwsStateError);
    expect(await state(), before);
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
    final queue = await db.select(db.syncChanges).get();
    expect(
      queue
          .where((row) => row.entityType == 'member')
          .map((row) => row.entityId),
      contains(member),
    );
    final payload =
        jsonDecode(
              queue.singleWhere((row) => row.entityId == recurring.id).payload,
            )
            as Map<String, dynamic>;
    final occurrence =
        ((payload['initial_state'] as Map)['occurrences'] as List).single
            as Map;
    expect(occurrence['deleted_at'], isNotNull);
    expect((occurrence['payload'] as Map)['payer_member_id'], member);
    expect((occurrence['payload'] as Map)['amount'], '12');
  });
  test('未确认初始化仍引用分类时阻止删除，未知和被拒绝请求保持原文，确认后解除保护', () async {
    final seeded = await history();
    final category = await localCategories.createCategory(
      name: '初始化引用分类',
      kind: 'expense',
      recordChanges: false,
    );
    await (db.update(db.transactions)
          ..where((row) => row.id.equals(seeded.tombstone)))
        .write(TransactionsCompanion(categoryId: d.Value(category)));
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    final bootstrap = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(seeded.pausedRule))).getSingle();
    final frozen = jsonEncode({
      'mutation_id': bootstrap.mutationId,
      'payload': jsonDecode(bootstrap.payload),
    });
    for (final status in ['未发送', '结果未知', '明确拒绝']) {
      await (db.update(
        db.syncChanges,
      )..where((row) => row.id.equals(bootstrap.id))).write(
        SyncChangesCompanion(
          frozenRequest: d.Value(status == '未发送' ? null : frozen),
          rejectionReason: d.Value(
            status == '明确拒绝' ? 'FIXTURE_REJECTED' : null,
          ),
        ),
      );
      final before = await state();
      await expectLater(
        repo.deleteCategory(category),
        throwsStateError,
        reason: status,
      );
      expect(await state(), before, reason: '$status时不能修改历史或冻结队列');
    }
    final original = await (db.select(
      db.transactions,
    )..where((row) => row.id.equals(seeded.tombstone))).getSingle();
    await (db.update(db.syncChanges)
          ..where((row) => row.id.equals(bootstrap.id)))
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())));
    await repo.deleteCategory(category);
    final categoryTombstone =
        await (db.select(db.categories)..where(
              (row) =>
                  row.id.equals(category) &
                  categoryScopePredicate(row, _account),
            ))
            .getSingle();
    expect(categoryTombstone.deletedAt, isNotNull);
    expect(await repo.categoryStore.getCategoryById(category), isNull);
    final detached = await (db.select(
      db.transactions,
    )..where((row) => row.id.equals(seeded.tombstone))).getSingle();
    expect(detached.toJson(), {...original.toJson(), 'categoryId': null});
    expect(detached.deletedAt, isNotNull);
  });
  test('本地删分类清除活动和已删规则引用后可转云，规则墓碑与进度保持', () async {
    final ledger = await localLedger();
    final category = await localCategories.createCategory(
      name: '规则当前分类',
      kind: 'expense',
      recordChanges: false,
    );
    final active = await rule(ledger, category: category);
    final deleted = await rule(ledger, category: category);
    await repo.deleteRecurringTransaction(deleted.id);
    final deletedBefore = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(deleted.id))).getSingle();
    await localCategories.deleteCategoriesByIds([category]);
    final rules = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.ledgerId.equals(ledger))).get();
    expect(rules, hasLength(2));
    expect(rules.every((row) => row.categoryId == null), isTrue);
    expect(rules.singleWhere((row) => row.id == active.id).deletedAt, isNull);
    expect(rules.singleWhere((row) => row.id == deleted.id).toJson(), {
      ...deletedBefore.toJson(),
      'categoryId': null,
    });
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
    final changes = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityType.equals('recurring_transaction'))).get();
    expect(changes, hasLength(2));
    for (final change in changes) {
      final payload = jsonDecode(change.payload) as Map;
      expect(payload['category_id'], isNull);
      final initial = payload['initial_state'] as Map;
      expect(initial['occurrences'], isEmpty);
      expect(initial['last_generated_date'], isNull);
      expect(
        initial['deleted_at'],
        change.entityId == deleted.id
            ? deletedBefore.deletedAt!.toUtc().toIso8601String()
            : null,
      );
    }
  });

  test('已确认云端规则删除分类时仅活动规则登记清引用，已删规则不复活', () async {
    final ledger = await localLedger();
    final category = await localCategories.createCategory(
      name: '云端规则分类',
      kind: 'expense',
      recordChanges: false,
    );
    final active = await rule(ledger, category: category);
    final deleted = await rule(ledger, category: category);
    await repo.deleteRecurringTransaction(deleted.id);
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    await db
        .update(db.syncChanges)
        .write(
          SyncChangesCompanion(
            pushedAt: d.Value(DateTime.now().toUtc()),
            payload: const d.Value('{}'),
            frozenRequest: const d.Value(null),
          ),
        );
    final deletedBefore = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(deleted.id))).getSingle();
    await repo.deleteCategory(category);
    final rules = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.ledgerId.equals(ledger))).get();
    expect(rules.every((row) => row.categoryId == null), isTrue);
    expect(rules.singleWhere((row) => row.id == active.id).deletedAt, isNull);
    expect(rules.singleWhere((row) => row.id == deleted.id).toJson(), {
      ...deletedBefore.toJson(),
      'categoryId': null,
    });
    final pendingRules =
        await (db.select(db.syncChanges)..where(
              (row) =>
                  row.entityType.equals('recurring_transaction') &
                  row.pushedAt.isNull(),
            ))
            .get();
    expect(pendingRules, hasLength(1));
    expect(pendingRules.single.entityId, active.id);
    expect(pendingRules.single.action, 'upsert');
    final payload = jsonDecode(pendingRules.single.payload) as Map;
    expect(payload['category_id'], isNull);
    expect(payload['enabled'], isTrue);
    expect(payload.containsKey('initial_state'), isFalse);
  });

  test('尚未生成发生的规则初始化仍引用分类时禁止删除且队列不变', () async {
    final ledger = await localLedger();
    final category = await localCategories.createCategory(
      name: '未发生规则分类',
      kind: 'expense',
      recordChanges: false,
    );
    final recurring = await rule(ledger, category: category);
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect(await db.select(db.transactions).get(), isEmpty);
    final pending = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(recurring.id))).getSingle();
    final payload = jsonDecode(pending.payload) as Map;
    expect(payload['category_id'], category);
    expect((payload['initial_state'] as Map)['occurrences'], isEmpty);
    final before = await state();
    await expectLater(repo.deleteCategory(category), throwsStateError);
    expect(await state(), before);
  });

  test('冻结初始化原分类A仍受保护，即使本地规则已正常改为B', () async {
    final ledger = await localLedger();
    final originalCategory = await localCategories.createCategory(
      name: '初始分类A',
      kind: 'expense',
      recordChanges: false,
    );
    final recurring = await rule(ledger, category: originalCategory);
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    final nextCategory = await repo.createCategory(
      name: '后继分类B',
      kind: 'expense',
      recordChanges: false,
    );
    final bootstrap = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(recurring.id))).getSingle();
    final frozen = jsonEncode({
      'mutation_id': bootstrap.mutationId,
      'entity_type': bootstrap.entityType,
      'entity_id': bootstrap.entityId,
      'ledger_id': ledger,
      'action': bootstrap.action,
      'updated_at': bootstrap.updatedAt.toUtc().toIso8601String(),
      'payload': jsonDecode(bootstrap.payload),
    });
    await (db.update(db.syncChanges)
          ..where((row) => row.id.equals(bootstrap.id)))
        .write(SyncChangesCompanion(frozenRequest: d.Value(frozen)));
    await repo.updateRecurringTransaction(
      id: recurring.id,
      ledgerId: ledger,
      type: 'expense',
      amount: '10',
      categoryId: nextCategory,
      frequency: 'daily',
      interval: 1,
      startDate: day,
      timeZone: 'UTC',
    );
    final current = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(recurring.id))).getSingle();
    expect(current.categoryId, nextCategory);
    expect(await db.select(db.transactions).get(), isEmpty);
    final before = await state();
    await expectLater(
      repo.deleteCategoriesByIds([originalCategory]),
      throwsStateError,
    );
    expect(await state(), before);
    final preserved = await (db.select(
      db.syncChanges,
    )..where((row) => row.id.equals(bootstrap.id))).getSingle();
    expect(preserved.payload, bootstrap.payload);
    expect(preserved.frozenRequest, frozen);
    expect(
      (jsonDecode(preserved.payload) as Map)['category_id'],
      originalCategory,
    );
    final successors =
        await (db.select(db.syncChanges)..where(
              (row) =>
                  row.entityId.equals(recurring.id) &
                  row.id.isNotValue(bootstrap.id),
            ))
            .get();
    expect(successors, hasLength(1));
    expect(
      (jsonDecode(successors.single.payload) as Map)['category_id'],
      nextCategory,
    );
  });
  test('超出请求容量的本地旧数据拒绝转云，保留原内容供修复', () async {
    final ledger = await localLedger();
    final recurring = await rule(ledger);
    final id = await repo.generateRecurringTransaction(
      recurring: recurring,
      happenedAt: day,
    );
    final before = (await repo.getLedgerById(ledger))!;
    // 模拟超大历史存储，不走正常输入长度校验；必须在本人转换之前拒绝。
    const bytes = 64 * 1024 * 1024;
    await (db.update(db.transactions)..where((row) => row.id.equals(id))).write(
      TransactionsCompanion(note: d.Value(''.padRight(bytes, 'x'))),
    );
    await expectLater(
      actions.promoteLocal(SyncTarget('ledger', ledger)),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '原因',
          contains('64 MiB'),
        ),
      ),
    );
    expect(await repo.getLedgerById(ledger), before);
    expect(
      (await db.select(db.ledgerMembers).get()).single.memberType,
      'LOCAL',
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      (await db
              .customSelect('SELECT length(note) AS size FROM transactions')
              .getSingle())
          .read<int>('size'),
      bytes,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('最后一条outbox登记失败回滚整本，重试仅登记一组且再次调用幂等', () async {
    final seeded = await history();
    final before = await state();
    // 仅当前内存库注入最后一条队列写入失败，覆盖已完成本人映射后的事务回滚。
    await db.customStatement('''
      CREATE TRIGGER reject_final_promote BEFORE INSERT ON sync_changes
      WHEN NEW.ledger_id = '${seeded.ledger}' AND
        (SELECT COUNT(*) FROM sync_changes WHERE ledger_id = '${seeded.ledger}') = 6
      BEGIN SELECT RAISE(ABORT, 'injected final outbox failure'); END
    ''');
    await expectLater(
      actions.promoteLocal(SyncTarget('ledger', seeded.ledger)),
      throwsA(anything),
    );
    expect(await state(), before);
    await db.customStatement('DROP TRIGGER reject_final_promote');
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    final first = await state();
    final queue = await db.select(db.syncChanges).get();
    expect(queue, hasLength(7));
    expect(queue.map((row) => row.mutationId).toSet(), hasLength(7));
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    expect(await state(), first);
  });

  for (final rejected in [false, true]) {
    for (final remove in [false, true]) {
      test(
        '${rejected ? '已拒绝' : '未发送'}初始化${remove ? '删除' : '修正'}只保留一个完整初始包',
        () async {
          final seeded = await history();
          await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
          final bootstrap =
              await (db.select(db.syncChanges)..where(
                    (row) =>
                        row.entityType.equals('recurring_transaction') &
                        row.entityId.equals(seeded.pausedRule),
                  ))
                  .getSingle();
          final initial =
              (jsonDecode(bootstrap.payload)
                      as Map<String, dynamic>)['initial_state']
                  as Map<String, dynamic>;
          if (rejected) {
            await (db.update(
              db.syncChanges,
            )..where((row) => row.id.equals(bootstrap.id))).write(
              SyncChangesCompanion(
                frozenRequest: d.Value(
                  jsonEncode({
                    'mutation_id': bootstrap.mutationId,
                    'payload': jsonDecode(bootstrap.payload),
                  }),
                ),
                rejectionReason: const d.Value(
                  'INITIAL_STATE_FIXTURE_REJECTED',
                ),
              ),
            );
          }
          if (remove) {
            await repo.deleteRecurringTransaction(seeded.pausedRule);
          } else {
            await repo.updateRecurringTransaction(
              id: seeded.pausedRule,
              ledgerId: seeded.ledger,
              type: 'expense',
              amount: '12',
              note: '修正规则元数据后继续上传',
              frequency: 'daily',
              interval: 1,
              startDate: day,
              timeZone: 'UTC',
            );
          }
          final pending =
              await (db.select(db.syncChanges)..where(
                    (row) =>
                        row.entityType.equals('recurring_transaction') &
                        row.entityId.equals(seeded.pausedRule) &
                        row.pushedAt.isNull(),
                  ))
                  .get();
          // 初始状态仅可在云端实体尚不存在时应用，不能追加第二个 bootstrap。
          expect(pending, hasLength(1));
          final change = pending.single;
          expect(change.action, 'upsert');
          expect(change.rejectionReason, isNull);
          expect(change.frozenRequest, isNull);
          if (rejected) expect(change.mutationId, isNot(bootstrap.mutationId));
          final payload = jsonDecode(change.payload) as Map<String, dynamic>;
          final retained = payload['initial_state'] as Map<String, dynamic>;
          expect(retained['occurrences'], initial['occurrences']);
          expect(
            retained['last_generated_date'],
            initial['last_generated_date'],
          );
          if (remove) {
            final deletedRule = await (db.select(
              db.recurringTransactions,
            )..where((row) => row.id.equals(seeded.pausedRule))).getSingle();
            expect(deletedRule.deletedAt, isNotNull);
            expect(retained['deleted_at'], payload['updated_at']);
            // 持久化墓碑与初始化载荷必须属于同一次删除发生的秒区间。
            expect(
              DateTime.parse(
                    retained['deleted_at'] as String,
                  ).millisecondsSinceEpoch ~/
                  1000,
              deletedRule.deletedAt!.millisecondsSinceEpoch ~/ 1000,
            );
          } else {
            expect(retained, initial);
            expect(payload['amount'], '12');
            expect(payload['note'], '修正规则元数据后继续上传');
          }
        },
      );
    }
  }

  test('结果未知的冻结初始化原文保持不变，后继修正不携带第二个初始化包', () async {
    final seeded = await history();
    await actions.promoteLocal(SyncTarget('ledger', seeded.ledger));
    final bootstrap =
        await (db.select(db.syncChanges)..where(
              (row) =>
                  row.entityType.equals('recurring_transaction') &
                  row.entityId.equals(seeded.pausedRule),
            ))
            .getSingle();
    final frozen = jsonEncode({
      'mutation_id': bootstrap.mutationId,
      'payload': jsonDecode(bootstrap.payload),
    });
    await (db.update(db.syncChanges)
          ..where((row) => row.id.equals(bootstrap.id)))
        .write(SyncChangesCompanion(frozenRequest: d.Value(frozen)));
    await repo.toggleRecurringTransaction(seeded.pausedRule, true);
    final pending =
        await (db.select(db.syncChanges)..where(
              (row) =>
                  row.entityType.equals('recurring_transaction') &
                  row.entityId.equals(seeded.pausedRule) &
                  row.pushedAt.isNull(),
            ))
            .get();
    expect(pending, hasLength(2));
    final original = pending.singleWhere((row) => row.id == bootstrap.id);
    expect(original.payload, bootstrap.payload);
    expect(original.mutationId, bootstrap.mutationId);
    expect(original.frozenRequest, frozen);
    final next = pending.singleWhere((row) => row.id != bootstrap.id);
    final payload = jsonDecode(next.payload) as Map<String, dynamic>;
    expect(next.action, 'upsert');
    expect(next.mutationId, isNot(bootstrap.mutationId));
    expect(next.frozenRequest, isNull);
    expect(payload['enabled'], isTrue);
    expect(payload.containsKey('initial_state'), isFalse);
  });
  test('转云声明本人Owner并复制本地分类父链，另一账号同UUID及另一本地引用原样保留', () async {
    final ledger = await localLedger();
    final localBook = await localLedger();
    final parent = await localCategories.createCategory(
      name: '本地餐饮',
      kind: 'expense',
      recordChanges: false,
    );
    final child = await localCategories.createCategory(
      name: '早餐',
      kind: 'expense',
      level: 2,
      parentId: parent,
      recordChanges: false,
    );
    final recurring = await rule(ledger, category: child);
    final otherRule = await rule(localBook, category: child);
    const foreign = '10000000-0000-4000-8000-000000000999';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: parent,
            name: '另一账号内容',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value(foreign),
            updatedAt: day,
            cloudRegistered: const d.Value(true),
          ),
        );
    final localBefore = await localCategories.getAllCategories();
    final foreignBefore = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, foreign))).get();
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    final book = (await repo.getLedgerById(ledger))!;
    expect(
      (book.storageMode, book.scopeAccountId, book.ownerAccountId),
      ('cloud', _account, _account),
    );
    expect(await localCategories.getAllCategories(), localBefore);
    expect(
      await (db.select(
        db.categories,
      )..where((c) => categoryScopePredicate(c, foreign))).get(),
      foreignBefore,
    );
    final own = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, _account))).get();
    expect(own.map((c) => c.id).toSet(), {parent, child});
    expect(own.every((c) => !c.cloudRegistered), isTrue);
    final beforeQueue = await db.select(db.syncChanges).get();
    expect(
      beforeQueue
          .where((c) => c.entityType == 'category')
          .map((c) => c.entityId),
      [parent, child],
    );
    expect(
      (await db.select(db.recurringTransactions).get())
          .singleWhere((r) => r.id == recurring.id)
          .categoryId,
      child,
    );
    expect(
      (await db.select(db.recurringTransactions).get())
          .singleWhere((r) => r.id == otherRule.id)
          .categoryId,
      child,
    );
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect(await db.select(db.syncChanges).get(), beforeQueue);
    expect((await repo.getLedgerById(localBook))!.storageMode, 'local');
  });

  test('转云同级同名不同UUID分别保留，原分类和账单身份不变', () async {
    final ledger = await localLedger();
    final localCategory = await localCategories.createCategory(
      name: '餐饮',
      kind: 'expense',
      recordChanges: false,
    );
    final existingOwnCategory = await repo.createCategory(
      name: '餐饮',
      kind: 'expense',
      recordChanges: false,
    );
    final transactionId = await repo.addTransaction(
      ledgerId: ledger,
      type: 'expense',
      amount: '10',
      happenedAt: day,
      categoryId: localCategory,
    );
    final localBefore = await localCategories.getAllCategories();
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect(await localCategories.getAllCategories(), localBefore);
    final own = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, _account))).get();
    expect(own.where((c) => c.name == '餐饮').map((c) => c.id).toSet(), {
      localCategory,
      existingOwnCategory,
    });
    final transaction = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(transactionId))).getSingle();
    expect(transaction.categoryId, localCategory);
    expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
  });

  test('转云历史分类前置校验不能用另一账号同UUID替代缺失本地来源', () async {
    final ledger = await localLedger();
    final recurring = await rule(ledger);
    const missing = '20000000-0000-4000-8000-000000000999';
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: missing,
            name: '他人分类',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value(
              '10000000-0000-4000-8000-000000000999',
            ),
            updatedAt: day,
          ),
        );
    await (db.update(
      db.recurringTransactions,
    )..where((r) => r.id.equals(recurring.id))).write(
      const RecurringTransactionsCompanion(categoryId: d.Value(missing)),
    );
    final before = await state();
    await expectLater(
      actions.promoteLocal(SyncTarget('ledger', ledger)),
      throwsStateError,
    );
    expect(await state(), before);
  });

  test('另一本子的普通离线记录不受无效规则阻塞，可独立转云', () async {
    final blocked = await localLedger();
    final old = await rule(blocked);
    await (db.update(
      db.recurringTransactions,
    )..where((row) => row.id.equals(old.id))).write(
      const RecurringTransactionsCompanion(protocolVersion: d.Value(2)),
    );
    await expectLater(
      actions.promoteLocal(SyncTarget('ledger', blocked)),
      throwsStateError,
    );
    final ordinary = await localLedger();
    final tx = await repo.addTransaction(
      ledgerId: ordinary,
      type: 'expense',
      amount: '5',
      happenedAt: day,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    await actions.promoteLocal(SyncTarget('ledger', ordinary));
    expect((await repo.getLedgerById(blocked))!.storageMode, 'local');
    expect((await repo.getLedgerById(ordinary))!.storageMode, 'cloud');
    expect((await repo.getTransactionById(tx))!.recurringId, isNull);
    final queue = await db.select(db.syncChanges).get();
    expect(queue, hasLength(2));
    expect(queue.every((row) => row.ledgerId == ordinary), isTrue);
  });
}
