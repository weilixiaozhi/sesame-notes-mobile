import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/ledgers/domain/ledger_storage_choice.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';
import '../../helpers/bound_ledger_seed.dart';

/// 账本保存规则（新建原子性 / 编辑保存 / 危险区）的逻辑层用例。
///
/// 规则全部落在 application 层与真实内存库上，页面只负责交互与提示。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late LedgerActions actions;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(authSessionProvider)?.userId,
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(authSessionProvider)?.userId,
      ),
    );
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    actions = container.read(ledgerActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  void signIn() {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account',
            deviceId: 'device',
          ),
        );
  }

  /// 播种账本并返回其 id；默认纯本地归属，未登录也可读写。
  Future<String> seedLedger({
    required String name,
    String storageMode = 'local',
  }) => repo.createLedger(
    name: name,
    storageMode: storageMode,
    localSelfId: storageMode == 'local' ? 'device-self' : null,
  );

  Future<List<String>> ledgerIds() async =>
      (await db.select(db.ledgers).get()).map((row) => row.id).toList();

  group('新建账本原子性', () {
    final draft = RecurringTransactionDisplay(
      id: '',
      ledgerId: '',
      txType: 'expense',
      amount: '88.00',
      currencyCode: 'USD',
      frequency: 'monthly',
      interval: 2,
      dayOfMonth: 31,
      startDate: DateTime.utc(2026, 10, 1),
      endDate: DateTime.utc(2027, 10, 1),
      enabled: false,
    );

    test('周期模板写入失败：账本/模板/变更整体回滚，重试只创建一本', () async {
      signIn();
      await db.customStatement(
        'CREATE TRIGGER fail_recurring BEFORE INSERT ON recurring_transactions '
        "BEGIN SELECT RAISE(ABORT, 'disk write failed'); END",
      );

      await expectLater(
        actions.create(name: '周期账本', storageMode: 'cloud', recurring: [draft]),
        throwsA(anything),
      );

      expect(
        await db.select(db.ledgers).get(),
        isEmpty,
        reason: '账本必须随模板失败一并回滚',
      );
      expect(await repo.getAllRecurringTransactions(), isEmpty);
      expect(
        await db.select(db.syncChanges).get(),
        isEmpty,
        reason: '回滚不得留下半成品变更',
      );

      await db.customStatement('DROP TRIGGER fail_recurring');
      await actions.create(
        name: '周期账本',
        storageMode: 'cloud',
        recurring: [draft],
      );

      final ledgers = await repo.getAllLedgers();
      final items = await repo.getAllRecurringTransactions();
      expect(ledgers, hasLength(1), reason: '重试只允许创建一本账本');
      expect(items, hasLength(1));
      expect(
        items.single.ledgerId,
        ledgers.single.id,
        reason: '模板必须挂在重试后新建的账本上',
      );
      expect(items.single.currencyCode, 'USD');
      expect(items.single.amount, '88.00');
      expect(items.single.interval, 2);
      expect(items.single.dayOfMonth, 31);
      expect(items.single.startDate.toUtc(), draft.startDate);
      expect(items.single.endDate?.toUtc(), draft.endDate);
      expect(items.single.enabled, isFalse);
    });

    test('虚拟成员写入失败：账本与成员整体回滚，重试只创建一本', () async {
      signIn();
      await db.customStatement(
        'CREATE TRIGGER fail_placeholder BEFORE INSERT ON ledger_members '
        "WHEN NEW.member_type = 'PLACEHOLDER' "
        "BEGIN SELECT RAISE(ABORT, 'disk write failed'); END",
      );

      await expectLater(
        actions.create(
          name: '原子保存账本',
          storageMode: 'cloud',
          aaEnabled: true,
          placeholderNames: ['同行成员'],
        ),
        throwsA(anything),
      );

      expect(await db.select(db.ledgers).get(), isEmpty);
      expect(await db.select(db.ledgerMembers).get(), isEmpty);
      expect(await db.select(db.syncChanges).get(), isEmpty);

      await db.customStatement('DROP TRIGGER fail_placeholder');
      await actions.create(
        name: '原子保存账本',
        storageMode: 'cloud',
        aaEnabled: true,
        placeholderNames: ['同行成员'],
      );

      expect(
        await db.select(db.ledgers).get(),
        hasLength(1),
        reason: '重试只允许创建一本账本',
      );
      final vus = await (db.select(
        db.ledgerMembers,
      )..where((m) => m.memberType.equals('PLACEHOLDER'))).get();
      expect(vus, hasLength(1));
      expect(vus.single.displayName, '同行成员');
    });

    test('AA 开关、币种与月起始日随账本一次落库，31 日不被截断', () async {
      signIn();

      await actions.create(
        name: '页签中的账本',
        currency: 'USD',
        storageMode: 'cloud',
        aaEnabled: true,
        monthStartDay: 31,
      );

      final row = (await db.select(db.ledgers).get()).single;
      expect(row.name, '页签中的账本');
      expect(row.aaEnabled, isTrue);
      expect(row.currency, 'USD');
      expect(row.monthStartDay, 31, reason: '月起始日选到 31 必须原样落库');
    });

    test('名称为空或全为空白：拒绝保存且不落任何行', () async {
      signIn();

      for (final name in ['', '   ', '\u3000']) {
        await expectLater(
          actions.create(name: name, storageMode: 'cloud'),
          throwsFormatException,
          reason: '空白名称必须被拒绝',
        );
      }

      expect(await db.select(db.ledgers).get(), isEmpty);
      expect(await db.select(db.syncChanges).get(), isEmpty);
    });

    test('归属随登录态：未登录默认本地，落库 local 且不登记变更', () async {
      expect(newLedgerStorageMode(accountId: null), 'local');
      final mode = newLedgerStorageMode(
        accountId: container.read(currentLedgerAccountIdProvider),
      );
      expect(mode, 'local');

      await actions.create(name: '本地本', storageMode: mode);

      final row = (await db.select(db.ledgers).get()).single;
      expect(row.storageMode, 'local');
      expect(row.scopeAccountId, isNull, reason: '本地账本不归属任何账号');
      expect(
        await db.select(db.syncChanges).get(),
        isEmpty,
        reason: '本地账本不进同步通道',
      );
    });

    test('归属随登录态：已登录默认云端，落库 cloud 并登记 ledger upsert', () async {
      signIn();
      expect(
        newLedgerStorageMode(
          accountId: container.read(currentLedgerAccountIdProvider),
        ),
        'cloud',
      );

      await actions.create(
        name: '云端本',
        storageMode: newLedgerStorageMode(
          accountId: container.read(currentLedgerAccountIdProvider),
        ),
      );

      final row = (await db.select(db.ledgers).get()).single;
      expect(row.storageMode, 'cloud');
      expect(row.scopeAccountId, 'account', reason: '云端账本归属当前登录账号');
      final changes = await db.select(db.syncChanges).get();
      expect(changes, hasLength(1), reason: '云端建本必须登记变更供 push 建立服务端记录');
      expect(changes.single.entityType, 'ledger');
      expect(changes.single.action, 'upsert');
      expect(changes.single.entityId, row.id);
      expect(changes.single.ledgerId, row.id);
      expect(changes.single.accountId, 'account');
    });
  });

  group('编辑保存', () {
    test('换币后半段重算失败，名称、账期、AA 与交易快照一起回滚', () async {
      final id = await seedLedger(name: '原名称');
      final txId = await repo.addTransaction(
        ledgerId: id,
        type: 'expense',
        amount: '10',
        currencyCode: 'USD',
        nativeAmount: '70',
        happenedAt: DateTime.utc(2026, 7, 5),
      );
      await db.customStatement(
        'CREATE TRIGGER fail_currency_snapshot BEFORE UPDATE ON transactions '
        "BEGIN SELECT RAISE(ABORT, 'injected snapshot write failure'); END",
      );
      await expectLater(
        actions.changeCurrency(
          ledgerId: id,
          currency: 'USD',
          name: '新名称',
          monthStartDay: 15,
          aaEnabled: true,
        ),
        throwsA(anything),
      );
      final original = (await repo.getLedgerById(id))!;
      expect(original.name, '原名称');
      expect(original.currency, 'CNY');
      expect(original.monthStartDay, 1);
      expect(original.aaEnabled, isFalse);
      expect((await repo.getTransactionById(txId))!.nativeAmount, '70');
      await db.customStatement('DROP TRIGGER fail_currency_snapshot');
      await actions.changeCurrency(
        ledgerId: id,
        currency: 'USD',
        name: '新名称',
        monthStartDay: 15,
        aaEnabled: true,
      );
      final saved = (await repo.getLedgerById(id))!;
      expect(saved.name, '新名称');
      expect(saved.currency, 'USD');
      expect(saved.monthStartDay, 15);
      expect(saved.aaEnabled, isTrue);
      expect((await repo.getTransactionById(txId))!.nativeAmount, '10');
    });

    test('改名并开启 AA：两个字段一起落库', () async {
      final id = await seedLedger(name: '测试账本');

      final result = await actions.saveEdits(
        id: id,
        name: '改名后',
        monthStartDay: 1,
        aaEnabled: true,
      );

      expect(result.saved, isTrue);
      expect(result.changed, isTrue);
      final row = (await repo.getLedgerById(id))!;
      expect(row.name, '改名后');
      expect(row.aaEnabled, isTrue);
    });

    test('无任何变更保存：不改数据也不登记同步变更', () async {
      signIn();
      final id = await seedLedger(name: '测试账本', storageMode: 'cloud');
      // 播种时的新建变更与本用例无关，先清空以便观察保存是否产生写入。
      await db.delete(db.syncChanges).go();
      final before = (await db.select(db.ledgers).get()).single;

      final result = await actions.saveEdits(
        id: id,
        name: '测试账本',
        monthStartDay: 1,
        aaEnabled: false,
      );

      expect(result.saved, isTrue, reason: '无变更保存视为成功，允许关闭页面');
      expect(result.changed, isFalse);
      expect(
        (await db.select(db.ledgers).get()).single,
        before,
        reason: '无变更保存不得改动账本行（含 updatedAt）',
      );
      expect(
        await db.select(db.syncChanges).get(),
        isEmpty,
        reason: '无变更保存不得登记多余的同步变更',
      );
    });

    test('月起始日 15 / 31 原样落库', () async {
      final id = await seedLedger(name: '月末账本');

      for (final day in [15, 31]) {
        await actions.saveEdits(
          id: id,
          name: '月末账本',
          monthStartDay: day,
          aaEnabled: false,
        );
        expect((await repo.getLedgerById(id))!.monthStartDay, day);
      }
    });

    test('切换本位币：元数据与折算快照同事务落库', () async {
      final id = await seedLedger(name: '本位币账本');
      await repo.addTransaction(
        ledgerId: id,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 7, 5),
      );

      await actions.changeCurrency(ledgerId: id, currency: 'USD');

      expect((await repo.getLedgerById(id))!.currency, 'USD');
    });
  });

  group('危险区', () {
    test('清空账本：只清该账本交易，其他账本记录保持原样', () async {
      final a = await seedLedger(name: '账本A');
      final b = await seedLedger(name: '账本B');
      await repo.addTransaction(
        ledgerId: a,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 7, 5),
      );
      await repo.addTransaction(
        ledgerId: b,
        type: 'expense',
        amount: '20',
        happenedAt: DateTime(2026, 7, 6),
      );

      expect(await actions.clearTransactions(a), 1);

      expect(await repo.getTransactionsByLedger(a), isEmpty);
      final kept = await repo.getTransactionsByLedger(b);
      expect(kept, hasLength(1));
      expect(kept.single.amount, '20');
    });

    test('删除个人账本：本地删行并连带清除记录', () async {
      final a = await seedLedger(name: '待删账本');
      await repo.addTransaction(
        ledgerId: a,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 7, 5),
      );

      await actions.delete(a);

      expect(await repo.getLedgerById(a), isNull);
      expect(await repo.getTransactionsByLedger(a), isEmpty);
    });

    test('删除当前账本：切换目标为剩余可离线账本', () async {
      final a = await seedLedger(name: '账本A');
      final b = await seedLedger(name: '账本B');
      container.read(currentLedgerIdProvider.notifier).set(a);

      await actions.delete(a);
      await selectFirstLedger(container.read);

      expect(
        container.read(currentLedgerIdProvider),
        b,
        reason: '被删的是当前账本时必须切到剩余账本',
      );
      expect(await ledgerIds(), [b]);
    });

    test('删除非当前账本：不产生切换目标，当前选择保持', () async {
      final a = await seedLedger(name: '账本A');
      final b = await seedLedger(name: '账本B');
      container.read(currentLedgerIdProvider.notifier).set(b);

      await actions.delete(a);
      await selectFirstLedger(container.read);
      expect(container.read(currentLedgerIdProvider), b);
      expect(await ledgerIds(), [b]);
    });

    test('删除当前账本且无剩余可离线账本：切换目标为空串', () async {
      final a = await seedLedger(name: '账本A');
      container.read(currentLedgerIdProvider.notifier).set(a);

      await actions.delete(a);
      await selectFirstLedger(container.read);

      expect(
        container.read(currentLedgerIdProvider),
        isEmpty,
        reason: '已无剩余可用账本时必须清空当前选择',
      );
      expect(await db.select(db.ledgers).get(), isEmpty);
    });

    test('删除当前账本：未下载完整的云账本不作为切换目标', () async {
      signIn();
      final a = await seedLedger(name: '账本A');
      await seedBoundLedger(
        db,
        accountId: 'account',
        id: 'cloud-pending',
        name: '待下载云本',
      );
      await container
          .read(cloudLedgerDownloadStoreProvider)
          .markPending('account', 'cloud-pending');
      container.read(currentLedgerIdProvider.notifier).set(a);

      await actions.delete(a);
      await selectFirstLedger(container.read);

      expect(
        container.read(currentLedgerIdProvider),
        isEmpty,
        reason: '首次快照尚未发布的云账本不能作为切换目标',
      );
      expect(await ledgerIds(), ['cloud-pending']);
    });
  });
}
