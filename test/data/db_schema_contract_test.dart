// 数据库 schema v1 契约测试。
//
// 锚点：按冻结契约锁定的列名与硬约束。
// 锁定的内容：
//   1. 每张表的**运行时 schema**（生成的 $columns）暴露的列名必须与契约一致——
//      同步 payload、CSV/YAML 导出都依赖这些列名，改名即破坏跨层契约；
//   2. 数据库层面的硬约束（CHECK / 外键 / 复合主键）行为按契约断言；
//   3. 基类 DSL 列 getter（db.dart 中的表定义）是生成期专用代码：运行时
//      调用必须抛 UnsupportedError。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';

import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    // 触发惰性连接，先建好全部表再跑断言。
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() async {
    await db.close();
  });

  group('运行时 schema 列名与 v1 契约一致', () {
    // 无自增 id 的表 drift 会附加 rowid 伪列，断言时剔除。
    List<String> columnNames(d.TableInfo table) =>
        table.$columns.map((c) => c.name).where((n) => n != 'rowid').toList();

    test('ledgers（UUID 主键；4.4 起含 origin 溯源七列，无 type/is_shared）', () {
      expect(columnNames(db.ledgers), [
        'id',
        'name',
        'currency',
        'month_start_day',
        'aa_enabled',
        'role',
        'member_count',
        'storage_mode',
        'scope_account_id',
        'sync_id',
        'binding_status',
        'self_member_id',
        'origin_type',
        'origin_ledger_id',
        'origin_sync_id',
        'origin_account_id',
        'origin_backup_id',
        'origin_last_revision',
        'detached_at',
        'created_at',
        'updated_at',
        'deleted_at',
      ]);
    });

    test('exchange_rates（复合主键表，不进同步）', () {
      expect(columnNames(db.exchangeRates), [
        'base_currency',
        'quote_currency',
        'rate_date',
        'rate',
        'source',
        'fetched_at',
      ]);
    });

    test('exchange_rate_overrides（UUID 主键，无 sync_id）', () {
      expect(columnNames(db.exchangeRateOverrides), [
        'id',
        'base_currency',
        'quote_currency',
        'rate',
        'updated_at',
        'deleted_at',
        'scope_account_id',
      ]);
    });

    test('categories（UUID 主键，无 sync_id）', () {
      expect(columnNames(db.categories), [
        'id',
        'name',
        'kind',
        'level',
        'sort_order',
        'icon',
        'parent_id',
        'scope_account_id',
        'updated_at',
        'deleted_at',
      ]);
    });

    test('transactions（UUID 主键，tx_type，金额为 TEXT；AA 分摊收敛为关系表）', () {
      expect(columnNames(db.transactions), [
        'id',
        'ledger_id',
        'tx_type',
        'amount',
        'happened_at',
        'note',
        'category_id',
        'exclude_from_stats',
        'currency_code',
        'native_amount',
        'recurring_id',
        'created_by_member_id',
        'last_edited_by_member_id',
        'payer_member_id',
        'aa_mode',
        'version',
        'server_revision',
        'last_edited_at',
        'created_at',
        'updated_at',
        'deleted_at',
      ]);
    });

    test('transaction_splits（AA 指定分摊关系表，参与人单轨成员 id）', () {
      expect(columnNames(db.transactionSplits), [
        'id',
        'transaction_id',
        'member_id',
        'amount',
      ]);
    });

    test('record_edit_histories（本地只读历史）', () {
      expect(columnNames(db.recordEditHistories), [
        'id',
        'record_id',
        'version',
        'operator_member_id',
        'summary',
        'created_at',
      ]);
    });

    test('recurring_transactions（UUID 主键，tx_type）', () {
      expect(columnNames(db.recurringTransactions), [
        'id',
        'ledger_id',
        'tx_type',
        'amount',
        'currency_code',
        'category_id',
        'note',
        'frequency',
        'interval',
        'day_of_month',
        'day_of_week',
        'month_of_year',
        'start_date',
        'end_date',
        'last_generated_date',
        'enabled',
        'created_at',
        'updated_at',
        'deleted_at',
      ]);
    });

    test('sync_changes（契约 Push change 形状，含 mutation_id 幂等键）', () {
      expect(columnNames(db.syncChanges), [
        'id',
        'entity_type',
        'entity_id',
        'ledger_id',
        'account_id',
        'action',
        'payload',
        'updated_at',
        'pushed_at',
        'mutation_id',
        'base_revision',
      ]);
    });

    test('sync_state（无 provider_type，server_cursor 为 TEXT）', () {
      expect(columnNames(db.syncState), [
        'device_id',
        'server_cursor',
        'last_push_at',
        'last_pull_at',
      ]);
    });

    test('sync_pull_errors（change_id 为 TEXT 十进制字符串）', () {
      expect(columnNames(db.syncPullErrors), [
        'id',
        'change_id',
        'ledger_id',
        'entity_type',
        'entity_id',
        'action',
        'raw_change_json',
        'error_class',
        'error_message',
        'stack_trace',
        'first_seen_at',
        'last_attempt_at',
        'attempt_count',
        'user_action',
        'resolved_at',
      ]);
    });

    test('backup_state（自动备份脏状态，id 为单例哨兵列）', () {
      expect(columnNames(db.backupState), [
        'dirty_since',
        'last_success_at',
        'current_provider',
        'id',
      ]);
    });

    test('ledger_members（UUID 主键，成员单轨）', () {
      expect(columnNames(db.ledgerMembers), [
        'id',
        'ledger_id',
        'display_name',
        'member_type',
        'linked_account_id',
        'origin_member_id',
        'origin_account_id',
        'role',
        'avatar_url',
        'avatar_version',
        'status',
        'joined_at',
        'created_at',
        'updated_at',
        'deleted_at',
      ]);
    });

    test('recovery_logs（恢复审计日志，本地自增主键）', () {
      expect(columnNames(db.recoveryLogs), [
        'id',
        'created_at',
        'source_backup_name',
        'target_ledger_id',
        'action',
        'result',
        'detail',
      ]);
    });

    test('shared_ledger_categories（(ledger_id,category_id) 复合主键）', () {
      expect(columnNames(db.sharedLedgerCategories), [
        'ledger_id',
        'category_id',
        'name',
        'kind',
        'icon',
        'sort_order',
        'level',
        'parent_id',
        'updated_at',
      ]);
    });
  });

  group('关键列默认值与必填性', () {
    test('ledgers 默认本位币 CNY / 归属 local / 月首日 1 / role owner', () {
      final cols = {for (final c in db.ledgers.$columns) c.name: c};
      expect(cols['currency']!.defaultValue, const d.Constant('CNY'));
      expect(cols['storage_mode']!.defaultValue, const d.Constant('local'));
      expect(cols['month_start_day']!.defaultValue, const d.Constant(1));
      expect(cols['role']!.defaultValue, const d.Constant('owner'));
      // 契约同步字段：updated_at 必填（LWW 依据）。
      expect(cols['updated_at']!.requiredDuringInsert, isTrue);
    });

    test('transactions 编辑版本默认 1、排除统计默认 false、LWW 字段必填', () {
      final cols = {for (final c in db.transactions.$columns) c.name: c};
      expect(cols['version']!.defaultValue, const d.Constant(1));
      expect(cols['exclude_from_stats']!.defaultValue, const d.Constant(false));
      // 契约必填：id/ledger_id/tx_type/amount/happened_at/currency_code/
      // native_amount/created_at/updated_at。
      for (final name in [
        'id',
        'ledger_id',
        'tx_type',
        'amount',
        'happened_at',
        'currency_code',
        'native_amount',
        'created_at',
        'updated_at',
      ]) {
        expect(
          cols[name]!.requiredDuringInsert,
          isTrue,
          reason: 'transactions.$name 必须随插入写入',
        );
      }
    });

    test('sync_changes 必填列符合同步契约', () {
      final cols = {for (final c in db.syncChanges.$columns) c.name: c};
      for (final name in [
        'entity_type',
        'entity_id',
        'action',
        'payload',
        'updated_at',
        'mutation_id',
      ]) {
        expect(
          cols[name]!.requiredDuringInsert,
          isTrue,
          reason: 'sync_changes.$name 必须随插入写入',
        );
      }
      // ledger_id 对 user-global 实体可为 null（非插入必填）。
      expect(cols['ledger_id']!.requiredDuringInsert, isFalse);
    });

    test('sync_state 无 provider_type（仅 Sesame Notes Cloud 一个同步协议）', () {
      final cols = {for (final c in db.syncState.$columns) c.name: c};
      expect(cols.containsKey('provider_type'), isFalse);
      expect(cols['device_id']!.requiredDuringInsert, isTrue);
    });
  });

  group('基类 DSL getter 仅限生成期使用', () {
    test('ledgers 全部列 getter', () {
      final t = Ledgers();
      expect(() => t.id, throwsUnsupportedError);
      expect(() => t.name, throwsUnsupportedError);
      expect(() => t.currency, throwsUnsupportedError);
      expect(() => t.monthStartDay, throwsUnsupportedError);
      expect(() => t.aaEnabled, throwsUnsupportedError);
      expect(() => t.role, throwsUnsupportedError);
      expect(() => t.memberCount, throwsUnsupportedError);
      expect(() => t.storageMode, throwsUnsupportedError);
      expect(() => t.selfMemberId, throwsUnsupportedError);
      expect(() => t.createdAt, throwsUnsupportedError);
      expect(() => t.updatedAt, throwsUnsupportedError);
      expect(() => t.deletedAt, throwsUnsupportedError);
    });

    test('transactions 全部列 getter', () {
      final t = Transactions();
      expect(() => t.id, throwsUnsupportedError);
      expect(() => t.ledgerId, throwsUnsupportedError);
      expect(() => t.txType, throwsUnsupportedError);
      expect(() => t.amount, throwsUnsupportedError);
      expect(() => t.categoryId, throwsUnsupportedError);
      expect(() => t.happenedAt, throwsUnsupportedError);
      expect(() => t.note, throwsUnsupportedError);
      expect(() => t.recurringId, throwsUnsupportedError);
      expect(() => t.excludeFromStats, throwsUnsupportedError);
      expect(() => t.currencyCode, throwsUnsupportedError);
      expect(() => t.nativeAmount, throwsUnsupportedError);
      expect(() => t.version, throwsUnsupportedError);
      expect(() => t.createdAt, throwsUnsupportedError);
      expect(() => t.updatedAt, throwsUnsupportedError);
      expect(() => t.deletedAt, throwsUnsupportedError);
    });

    test('sync_changes 全部列 getter', () {
      final t = SyncChanges();
      expect(() => t.id, throwsUnsupportedError);
      expect(() => t.entityType, throwsUnsupportedError);
      expect(() => t.entityId, throwsUnsupportedError);
      expect(() => t.ledgerId, throwsUnsupportedError);
      expect(() => t.action, throwsUnsupportedError);
      expect(() => t.payload, throwsUnsupportedError);
      expect(() => t.updatedAt, throwsUnsupportedError);
      expect(() => t.pushedAt, throwsUnsupportedError);
    });

    test('ledger_members 全部列 getter（含 primaryKey 引用）', () {
      final t = LedgerMembers();
      expect(() => t.id, throwsUnsupportedError);
      expect(() => t.ledgerId, throwsUnsupportedError);
      expect(() => t.displayName, throwsUnsupportedError);
      expect(() => t.memberType, throwsUnsupportedError);
      expect(() => t.linkedAccountId, throwsUnsupportedError);
      expect(() => t.role, throwsUnsupportedError);
      expect(() => t.avatarVersion, throwsUnsupportedError);
      expect(() => t.status, throwsUnsupportedError);
      expect(() => t.joinedAt, throwsUnsupportedError);
      expect(() => t.createdAt, throwsUnsupportedError);
      expect(() => t.updatedAt, throwsUnsupportedError);
      expect(() => t.primaryKey, throwsUnsupportedError);
    });

    test('shared_ledger_categories 全部列 getter（含 primaryKey 引用）', () {
      final t = SharedLedgerCategories();
      expect(() => t.ledgerId, throwsUnsupportedError);
      expect(() => t.categoryId, throwsUnsupportedError);
      expect(() => t.name, throwsUnsupportedError);
      expect(() => t.kind, throwsUnsupportedError);
      expect(() => t.level, throwsUnsupportedError);
      expect(() => t.parentId, throwsUnsupportedError);
      expect(() => t.updatedAt, throwsUnsupportedError);
      expect(() => t.primaryKey, throwsUnsupportedError);
    });
  });

  group('CHECK 约束在数据库层兜底', () {
    test('month_start_day 越界(0/29)直接拒绝', () {
      expect(
        () => db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: 'l-bad-0',
                name: 'bad',
                monthStartDay: d.Value(0),
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: 'l-bad-29',
                name: 'bad',
                monthStartDay: d.Value(29),
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('categories.level 只允许 1/2', () {
      expect(
        () => db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'c-bad-level',
                name: 'bad',
                kind: 'expense',
                level: 3,
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('transactions.aa_mode 只允许 null/0/1/2', () async {
      final ledgerId = 'l-aa';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'aa',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      expect(
        () => db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 't-bad-aa',
                ledgerId: ledgerId,
                txType: 'expense',
                amount: '100',
                happenedAt: DateTime.utc(2026, 8, 8),
                currencyCode: 'CNY',
                nativeAmount: '100',
                createdAt: DateTime.utc(2026, 8, 8),
                updatedAt: DateTime.utc(2026, 8, 8),
                aaMode: d.Value(9),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('外键行为', () {
    test('删除账本级联删除交易', () async {
      final ledgerId = 'l-cascade';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'cascade',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final txId = 't-cascade';
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: txId,
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '100',
              happenedAt: DateTime.utc(2026, 8, 8),
              currencyCode: 'CNY',
              nativeAmount: '100',
              createdAt: DateTime.utc(2026, 8, 8),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );

      await (db.delete(db.ledgers)..where((l) => l.id.equals(ledgerId))).go();

      final left = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).get();
      expect(left, isEmpty);
    });

    test('分类弱引用允许共享镜像 UUID，删除个人分类也保留交易引用', () async {
      final ledgerId = 'l-catfk';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'cat-fk',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final catId = 'c-food';
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: catId,
              name: '餐饮',
              kind: 'expense',
              level: 1,
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final txId = 't-catfk';
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: txId,
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '100',
              happenedAt: DateTime.utc(2026, 8, 8),
              categoryId: d.Value(catId),
              currencyCode: 'CNY',
              nativeAmount: '100',
              createdAt: DateTime.utc(2026, 8, 8),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );

      // 共享 Editor 的 Owner 分类仅存在于 shared_ledger_categories，
      // transactions.category_id 必须允许保存该 UUID。
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't-shared-category',
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '88',
              happenedAt: DateTime.utc(2026, 8, 8),
              categoryId: const d.Value('owner-category-not-in-categories'),
              currencyCode: 'CNY',
              nativeAmount: '88',
              createdAt: DateTime.utc(2026, 8, 8),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );

      await (db.delete(db.categories)..where((c) => c.id.equals(catId))).go();

      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.categoryId, catId);
      final sharedTx = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals('t-shared-category'))).getSingle();
      expect(sharedTx.categoryId, 'owner-category-not-in-categories');
    });

    test('删除交易级联删除编辑历史', () async {
      final ledgerId = 'l-histfk';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'history-fk',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final txId = 't-histfk';
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: txId,
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '100',
              happenedAt: DateTime.utc(2026, 8, 8),
              currencyCode: 'CNY',
              nativeAmount: '100',
              createdAt: DateTime.utc(2026, 8, 8),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      await db
          .into(db.recordEditHistories)
          .insert(
            RecordEditHistoriesCompanion.insert(
              recordId: txId,
              version: 2,
              summary: '改金额',
            ),
          );

      await (db.delete(db.transactions)..where((t) => t.id.equals(txId))).go();

      final left = await (db.select(
        db.recordEditHistories,
      )..where((h) => h.recordId.equals(txId))).get();
      expect(left, isEmpty);
    });
  });

  group('复合主键 / 唯一约束', () {
    test('exchange_rates 同 (base,quote,date) 重复插入被拒绝', () async {
      final row = ExchangeRatesCompanion.insert(
        baseCurrency: 'CNY',
        quoteCurrency: 'USD',
        rateDate: '2026-08-08',
        rate: '7.2',
        source: 'server',
        fetchedAt: DateTime(2026, 8, 8),
      );
      await db.into(db.exchangeRates).insert(row);
      expect(
        () => db.into(db.exchangeRates).insert(row),
        throwsA(isA<SqliteException>()),
      );
    });

    test('exchange_rate_overrides 同 (base,quote) 唯一（业务唯一键）', () async {
      final row = ExchangeRateOverridesCompanion.insert(
        id: 'ov-1',
        baseCurrency: 'CNY',
        quoteCurrency: 'USD',
        rate: '7.25',
        updatedAt: DateTime.utc(2026, 8, 8),
      );
      await db.into(db.exchangeRateOverrides).insert(row);
      expect(
        () => db
            .into(db.exchangeRateOverrides)
            .insert(
              ExchangeRateOverridesCompanion.insert(
                id: 'ov-2',
                baseCurrency: 'CNY',
                quoteCurrency: 'USD',
                rate: '7.30',
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('ledger_members 同 id（主键）重复插入被拒绝', () async {
      // FK：成员必须挂在真实账本下。
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'l1',
              name: 'm-ledger',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final row = LedgerMembersCompanion.insert(
        id: 'm1',
        ledgerId: 'l1',
        displayName: '成员A',
        memberType: 'REGISTERED',
        linkedAccountId: d.Value('u1'),
        role: const d.Value('editor'),
        joinedAt: d.Value(DateTime(2026, 8, 8)),
        updatedAt: DateTime(2026, 8, 8),
      );
      await db.into(db.ledgerMembers).insert(row);
      await expectLater(
        db.into(db.ledgerMembers).insert(row),
        throwsA(isA<SqliteException>()),
      );
    });

    test('ledger_members 非法 role 被数据库 CHECK 拒绝', () async {
      await expectLater(
        db
            .into(db.ledgerMembers)
            .insert(
              LedgerMembersCompanion.insert(
                id: 'm2',
                ledgerId: 'l1',
                displayName: '成员B',
                memberType: 'REGISTERED',
                role: const d.Value('admin'),
                updatedAt: DateTime(2026, 8, 8),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'shared_ledger_categories 同 (ledger_id,category_id) 重复插入被拒绝',
      () async {
        final row = SharedLedgerCategoriesCompanion.insert(
          ledgerId: 'l1',
          categoryId: 'cat1',
          name: '餐饮',
          kind: 'expense',
          level: d.Value(1),
          updatedAt: DateTime(2026, 8, 8),
        );
        await db.into(db.sharedLedgerCategories).insert(row);
        expect(
          () => db.into(db.sharedLedgerCategories).insert(row),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test('backup_state 只允许 id=0 的单例记录', () async {
      expect(
        () => db
            .into(db.backupState)
            .insert(BackupStateCompanion.insert(id: const d.Value(1))),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('低频表读写通路（生成查询方法）', () {
    test('sync_state / sync_changes / sync_pull_errors 插入与回读', () async {
      await db
          .into(db.syncState)
          .insert(
            SyncStateCompanion.insert(
              deviceId: 'dev-1',
              serverCursor: d.Value('42'),
            ),
          );
      final syncState = await db.select(db.syncState).getSingle();
      expect(syncState.serverCursor, '42');

      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: 't-1',
              action: 'upsert',
              payload: '{}',
              updatedAt: DateTime.utc(2026, 8, 8),
              mutationId: 'm-1',
            ),
          );
      final change = await db.select(db.syncChanges).getSingle();
      expect(change.action, 'upsert');
      expect(change.pushedAt, isNull);
      expect(change.mutationId, 'm-1', reason: '幂等键必须随变更持久化');

      final now = DateTime.utc(2026, 8, 8);
      await db
          .into(db.syncPullErrors)
          .insert(
            SyncPullErrorsCompanion.insert(
              changeId: '7',
              entityType: 'transaction',
              entityId: 't-1',
              action: 'upsert',
              rawChangeJson: '{}',
              firstSeenAt: now,
              lastAttemptAt: now,
            ),
          );
      final err = await db.select(db.syncPullErrors).getSingle();
      expect(err.changeId, '7');
      expect(err.attemptCount, 1);
    });

    test('exchange_rate_overrides / ledger_members 读写', () async {
      await db
          .into(db.exchangeRateOverrides)
          .insert(
            ExchangeRateOverridesCompanion.insert(
              id: 'ov-1',
              baseCurrency: 'CNY',
              quoteCurrency: 'USD',
              rate: '7.25',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final ov = await db.select(db.exchangeRateOverrides).getSingle();
      expect(ov.rate, '7.25');

      // FK：虚拟用户必须挂在真实账本下。
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'l1',
              name: 'v-ledger',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      // FK：占位成员（原虚拟用户）必须挂在真实账本下。
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: 'vu-1',
              ledgerId: 'l1',
              displayName: '张三',
              memberType: 'PLACEHOLDER',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final vu = await db.select(db.ledgerMembers).getSingle();
      expect(vu.displayName, '张三');
      expect(vu.memberType, 'PLACEHOLDER');
      // drift 读出为本地时区，转 UTC 后与契约值比较。
      expect(vu.updatedAt.toUtc(), DateTime.utc(2026, 8, 8));
    });

    test('recurring_transactions 复合规则字段回读', () async {
      // 外键约束：周期模板必须挂在真实账本下。
      final ledgerId = 'l-recurring';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'recurring',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      await db
          .into(db.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              id: 'rt-1',
              ledgerId: ledgerId,
              txType: 'expense',
              amount: '50.00',
              currencyCode: 'CNY',
              frequency: 'monthly',
              interval: d.Value(2),
              dayOfMonth: d.Value(15),
              startDate: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final rt = await db.select(db.recurringTransactions).getSingle();
      expect(rt.frequency, 'monthly');
      expect(rt.interval, 2);
      expect(rt.dayOfMonth, 15);
      expect(rt.enabled, isTrue);
    });

    test('tombstone 列可空且默认空（契约删除走 deleted_at）', () async {
      final ledgerId = 'l-tomb';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: 'tomb',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      final l = await db.select(db.ledgers).getSingle();
      expect(l.deletedAt, isNull);
    });
  });

  group('账号域索引（10.5）', () {
    Future<Set<String>> indexNames() async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
          )
          .get();
      return rows.map((r) => r.read<String>('name')).toSet();
    }

    test('四个账号域索引建库即就绪，旧全局唯一汇率索引已移除', () async {
      final names = await indexNames();
      expect(names, contains('idx_ledgers_scope_mode'));
      expect(names, contains('idx_sync_changes_account_pushed'));
      expect(names, contains('idx_categories_scope_parent'));
      expect(names, contains('idx_rate_overrides_local_pair'));
      expect(names, contains('idx_rate_overrides_account_pair'));
      // 全局唯一汇率索引（base+quote 全库唯一）与账号域隔离冲突，必须不存在
      expect(names, isNot(contains('idx_rate_override_pair')));
    });

    test('汇率分域 partial unique：本地域一份、每账号域各一份', () async {
      // 本地域（null scope）同币对只能一行
      await db
          .into(db.exchangeRateOverrides)
          .insert(
            ExchangeRateOverridesCompanion.insert(
              id: 'local-1',
              baseCurrency: 'CNY',
              quoteCurrency: 'USD',
              rate: '7.5',
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      await expectLater(
        db
            .into(db.exchangeRateOverrides)
            .insert(
              ExchangeRateOverridesCompanion.insert(
                id: 'local-2',
                baseCurrency: 'CNY',
                quoteCurrency: 'USD',
                rate: '7.6',
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(anything),
        reason: '本地域同币对第二行必须被 partial unique 拒绝',
      );

      // 账号 A 与账号 B 同币对各自一行（互不冲突）
      await db
          .into(db.exchangeRateOverrides)
          .insert(
            ExchangeRateOverridesCompanion.insert(
              id: 'acc-a-1',
              baseCurrency: 'CNY',
              quoteCurrency: 'USD',
              rate: '7.5',
              scopeAccountId: const d.Value('account-a'),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      await db
          .into(db.exchangeRateOverrides)
          .insert(
            ExchangeRateOverridesCompanion.insert(
              id: 'acc-b-1',
              baseCurrency: 'CNY',
              quoteCurrency: 'USD',
              rate: '7.4',
              scopeAccountId: const d.Value('account-b'),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
      // 同一账号同币对第二行被拒绝
      await expectLater(
        db
            .into(db.exchangeRateOverrides)
            .insert(
              ExchangeRateOverridesCompanion.insert(
                id: 'acc-a-2',
                baseCurrency: 'CNY',
                quoteCurrency: 'USD',
                rate: '7.7',
                scopeAccountId: const d.Value('account-a'),
                updatedAt: DateTime.utc(2026, 8, 8),
              ),
            ),
        throwsA(anything),
        reason: '同账号同币对第二行必须被 partial unique 拒绝',
      );
      // 本地域 + 账号域同币对共存：总数 3 行
      final count = await db
          .customSelect('SELECT COUNT(*) AS n FROM exchange_rate_overrides')
          .getSingle();
      expect(count.read<int>('n'), 3);
    });
  });
}
