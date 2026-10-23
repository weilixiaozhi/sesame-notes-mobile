import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/transactions/domain/recurring_transaction_rules.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  TransactionActions actions() => container.read(transactionActionsProvider);

  // 本组编辑测试模拟已有同步快照，不能通过生产入口凭空推进生成游标。
  Future<void> seedHistoricalCursor(String id, DateTime date) async {
    await (db.update(db.recurringTransactions)
          ..where((row) => row.id.equals(id)))
        .write(RecurringTransactionsCompanion(lastGeneratedDate: Value(date)));
  }

  test('新建保存：按开始日期推导每月几号，参数原样落库', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final startDate = DateTime.utc(2026, 7, 20, 9, 30);

    final id = await actions().addRecurring(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.25',
      categoryId: categoryId,
      note: null,
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: defaultRecurringDayOfMonth(startDate),
      dayOfWeek: null,
      monthOfYear: null,
      startDate: startDate,
      endDate: null,
    );

    final row = (await repo.getAllRecurringTransactions()).single;
    expect(row.id, id);
    expect(row.ledgerId, ledgerId);
    expect(row.txType, 'expense');
    expect(row.amount, '50.25');
    expect(row.categoryId, categoryId);
    expect(row.note, isNull);
    expect(row.frequency, 'monthly');
    expect(row.interval, 1);
    expect(row.dayOfMonth, 20, reason: '月频「每月几号」由开始日期推导');
    expect(row.dayOfWeek, isNull);
    expect(row.monthOfYear, isNull);
    expect(row.startDate.toUtc(), recurringDateOnly(startDate));
    expect(row.endDate, isNull);
    expect(row.enabled, isTrue);
    expect(row.currencyCode, 'CNY', reason: '未指定币种时固化账本本位币');
  });

  test('分类选择：允许挂二级分类（topLevelOnly=false）', () async {
    // 会话与镜像账本均具有明确的查看者身份，分类归属由所有者决定。
    container.dispose();
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(
          LocalRepository(db, accountIdGetter: () => 'viewer-account'),
        ),
      ],
    );
    // 共享账本 Editor 视角：可选分类来自共享镜像，是本参数唯一可观测的场景。
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-shared',
            name: '共享账本',
            updatedAt: DateTime.utc(2026, 8, 8),
            memberCount: const Value(2),
            role: const Value('editor'),
            storageMode: const Value('cloud'),
            scopeAccountId: const Value('viewer-account'),
            ownerAccountId: const Value('owner-account'),
          ),
        );
    for (final row in [
      SharedLedgerCategoriesCompanion.insert(
        ledgerId: 'led-shared',
        categoryId: 'c1',
        name: '餐饮',
        kind: 'expense',
        updatedAt: DateTime.utc(2026, 8, 8),
      ),
      SharedLedgerCategoriesCompanion.insert(
        ledgerId: 'led-shared',
        categoryId: 'c2',
        name: '外卖',
        kind: 'expense',
        level: const Value(2),
        parentId: const Value('c1'),
        updatedAt: DateTime.utc(2026, 8, 8),
      ),
    ]) {
      await db.into(db.sharedLedgerCategories).insert(row);
    }

    final categories = container.read(categoryActionsProvider);
    final picked = await categories.filterForRecurringPicker(
      ledgerId: 'led-shared',
    );
    expect(picked.map((category) => category.id).toSet(), {
      'c1',
      'c2',
    }, reason: '周期账单必须能挂到二级分类');

    // 只取一级分类的查询会丢掉二级分类，证明该参数就是这条规则的开关。
    final topLevelOnly = await categories.filterForPicker(
      ledgerId: 'led-shared',
      kind: 'expense',
    );
    expect(topLevelOnly.map((category) => category.id), ['c1']);
  });

  test('编辑保存：保留外币与金额精度、写入关闭状态、不重置生成锚点', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      currencyCode: 'USD',
      note: '房租',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
    );
    // 锚点早于开始日期：普通编辑（关掉开关）也必须原样保留。
    await seedHistoricalCursor(id, DateTime.utc(2025, 12, 1));

    final startDate = DateTime.utc(2026, 1, 1);

    await actions().updateRecurring(
      id: id,
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      currencyCode: 'USD',
      categoryId: null,
      note: '房租',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      dayOfWeek: null,
      monthOfYear: null,
      startDate: startDate,
      endDate: null,
      enabled: false,
      clearLastGeneratedDate: false,
    );

    final row = (await repo.getAllRecurringTransactions()).single;
    expect(row.currencyCode, 'USD', reason: '编辑不得把外币改成本位币');
    expect(row.amount, '50.00', reason: '金额精度原样保留');
    expect(row.enabled, isFalse, reason: '关闭状态必须落库');
    expect(
      row.lastGeneratedDate?.toUtc(),
      DateTime.utc(2025, 12, 1),
      reason: '普通编辑不得重置生成锚点，否则会重复补生成',
    );
  });

  test('编辑保存：开始日期早于最后生成日期也保留协议1锚点', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
    );
    await seedHistoricalCursor(id, DateTime.utc(2026, 3, 1));

    final startDate = DateTime.utc(2026, 1, 1);

    await actions().updateRecurring(
      id: id,
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      dayOfWeek: null,
      monthOfYear: null,
      startDate: startDate,
      endDate: null,
      enabled: true,
      clearLastGeneratedDate: false,
    );

    final row = (await repo.getAllRecurringTransactions()).single;
    expect(
      row.lastGeneratedDate?.toUtc(),
      DateTime.utc(2026, 3, 1),
      reason: '协议1必须保留已生成锚点',
    );
  });

  test('删除：确认后列表隐藏模板，数据库保留墓碑', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
    );

    await actions().deleteRecurring(id);

    expect(await repo.getAllRecurringTransactions(), isEmpty);
    final tombstone = (await db.select(db.recurringTransactions).get()).single;
    expect(tombstone.id, id);
    expect(tombstone.deletedAt, isNotNull);
  });

  test('删除失败：模板保留在库，重试后可再次删除', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
    );
    // 注入删除失败：事务回滚，删除入口必须把异常上抛给确认弹窗。
    await db.customStatement(
      "CREATE TRIGGER fail_recurring_delete BEFORE UPDATE OF deleted_at ON recurring_transactions "
      "BEGIN SELECT RAISE(ABORT, 'injected delete failure'); END;",
    );

    await expectLater(actions().deleteRecurring(id), throwsA(isA<Exception>()));
    final kept = await repo.getAllRecurringTransactions();
    expect(kept, hasLength(1), reason: '删除失败必须保留模板，确认态可重试');
    expect(kept.single.id, id);
    expect(kept.single.deletedAt, isNull);

    await db.customStatement('DROP TRIGGER fail_recurring_delete');
    await actions().deleteRecurring(id);
    expect(
      await repo.getAllRecurringTransactions(),
      isEmpty,
      reason: '重试成功后落库删除',
    );
    expect(
      (await db.select(db.recurringTransactions).get()).single.deletedAt,
      isNotNull,
    );
  });

  test('未落库账本：草稿以空 ledgerId 返回，写入与删除入口都不落库', () async {
    final ledgerId = await repo.createLedger(
      name: '周期账本',
      storageMode: 'local',
    );
    final existingId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
    );

    final draft = buildRecurringDraft(
      id: '',
      amount: '99',
      currencyCode: 'USD',
      categoryId: 'cat-1',
      note: null,
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
      endDate: null,
      enabled: true,
    );
    expect(draft.ledgerId, isEmpty);

    // 草稿没有归属账本：写入入口必须拒绝，不能凭空落一条无账本模板。
    await expectLater(
      actions().addRecurring(
        ledgerId: draft.ledgerId,
        type: draft.txType,
        amount: draft.amount,
        currencyCode: draft.currencyCode,
        categoryId: draft.categoryId,
        note: draft.note,
        frequency: draft.frequency,
        interval: draft.interval,
        dayOfMonth: draft.dayOfMonth,
        startDate: draft.startDate,
        endDate: draft.endDate,
      ),
      throwsA(isA<StateError>()),
    );
    final rows = await repo.getAllRecurringTransactions();
    expect(rows, hasLength(1), reason: '草稿不得落库');
    expect(rows.single.id, existingId);

    // 草稿的删除分支（id 为空）也不得动到任何已落库模板。
    await actions().deleteRecurring(draft.id);
    expect(await repo.getAllRecurringTransactions(), hasLength(1));
  });

  test('列表页只读：读取展示流不改启停、不产生写操作', () async {
    final ledgerId = await repo.createLedger(name: '云账本', storageMode: 'cloud');
    final enabledId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '50.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 15,
      startDate: DateTime.utc(2026, 1, 1),
      enabled: true,
    );
    final disabledId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '80.00',
      frequency: 'monthly',
      interval: 2,
      dayOfMonth: 1,
      startDate: DateTime.utc(2026, 1, 1),
      enabled: false,
    );
    final changesBefore = await db.select(db.syncChanges).get();

    final subscription = container.listen(
      recurringTransactionDisplaysProvider,
      (_, _) {},
    );
    final items = await container.read(
      recurringTransactionDisplaysProvider.future,
    );

    expect(items, hasLength(2));
    expect(items.singleWhere((item) => item.id == enabledId).enabled, isTrue);
    expect(
      items.singleWhere((item) => item.id == disabledId).enabled,
      isFalse,
      reason: '列表页只读，渲染不得改写启停状态',
    );

    final rows = await repo.getAllRecurringTransactions();
    expect(rows.singleWhere((row) => row.id == enabledId).enabled, isTrue);
    expect(rows.singleWhere((row) => row.id == disabledId).enabled, isFalse);
    expect(
      await db.select(db.syncChanges).get(),
      hasLength(changesBefore.length),
      reason: '渲染周期账单列表不得产生任何写操作',
    );
    subscription.close();
  });
  test('跨端规则参数穿过操作和仓储端口，保留时区星期月份；已发生后拒绝改区', () async {
    final ledgerId = await repo.createLedger(
      name: '跨端周期',
      storageMode: 'local',
      currency: 'USD',
    );
    final id = await actions().addRecurring(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '0.0000000001',
      currencyCode: 'USD',
      frequency: 'yearly',
      interval: 18,
      dayOfMonth: 29,
      dayOfWeek: 5,
      monthOfYear: 2,
      timeZone: 'America/New_York',
      startDate: DateTime.utc(2026, 1, 1),
    );
    var row = (await repo.getAllRecurringTransactions()).single;
    expect(row.timeZone, 'America/New_York');
    expect(row.protocolVersion, 1);
    expect(row.dayOfWeek, 5);
    expect(row.monthOfYear, 2);
    expect(row.interval, 18);
    expect(row.amount, '0.0000000001');
    await actions().updateRecurring(
      id: id,
      ledgerId: ledgerId,
      type: 'expense',
      amount: '0.0000000001',
      frequency: 'yearly',
      interval: 18,
      dayOfMonth: 29,
      dayOfWeek: 5,
      monthOfYear: 2,
      timeZone: 'Asia/Tokyo',
      startDate: DateTime.utc(2026, 1, 1),
    );
    row = (await repo.getAllRecurringTransactions()).single;
    expect(row.timeZone, 'Asia/Tokyo');
    await repo.generateRecurringTransaction(
      recurring: row,
      happenedAt: DateTime.utc(2026, 2, 28),
    );
    await expectLater(
      actions().updateRecurring(
        id: id,
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10',
        frequency: 'yearly',
        interval: 1,
        dayOfMonth: 29,
        monthOfYear: 2,
        timeZone: 'UTC',
        startDate: DateTime.utc(2026, 1, 1),
      ),
      throwsA(isA<StateError>()),
    );
    row = (await repo.getAllRecurringTransactions()).single;
    expect(row.timeZone, 'Asia/Tokyo');
    expect(row.amount, '0.0000000001');
    expect(row.lastGeneratedDate?.toUtc(), DateTime.utc(2026, 2, 28));
  });
}
