// debug 验收数据填充器（AcceptanceDataSeeder）契约测试。
//
// 锁定验收数据生成的硬性口径：
//  - 一键填充覆盖近 12 个月、多币种、支出人归属成员、部分账单带人均 AA；
//  - AA 账单三种分摊模式齐备，指定分摊金额精确合计（sum(splits) == amount）；
//  - 虚拟用户为 PLACEHOLDER 成员；本地账本带 AA 开关与 self 成员；
//  - 云账本未登录跳过不落库，已登录落库并登记同步变更。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/services/acceptance_data_seeder.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;

  /// 未登录仓储：无变更登记、无账号域。
  late LocalRepository anonRepo;

  /// 已登录仓储：模拟 user-1 账号域 + 同步变更登记（对齐 repositoryProvider 装配）。
  late LocalRepository authedRepo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    anonRepo = LocalRepository(db);
    authedRepo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'user-1'),
      accountIdGetter: () => 'user-1',
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// 建一本开启 AA 的本地账本：分类 + LOCAL self + 两个虚拟用户。
  Future<({String ledgerId, List<String> memberIds})> buildLedger(
    LocalRepository repo,
  ) async {
    await repo.upsertCategory(name: '餐饮', kind: 'expense');
    await repo.upsertCategory(name: '交通', kind: 'expense');
    final ledgerId = await repo.createLedger(
      name: '测试账本',
      storageMode: 'local',
      aaEnabled: true,
      localSelfId: 'self-1',
    );
    final ledger = await repo.getLedgerById(ledgerId);
    final memberIds = <String>[ledger!.selfMemberId!];
    memberIds.add(
      await repo.createPlaceholderMember(ledgerId: ledgerId, name: '小美'),
    );
    memberIds.add(
      await repo.createPlaceholderMember(ledgerId: ledgerId, name: '阿强'),
    );
    return (ledgerId: ledgerId, memberIds: memberIds);
  }

  group('fillBills 一键填充账单', () {
    test('覆盖近 12 个月、多币种、支出人归属成员、含人均 AA 账单', () async {
      final data = await buildLedger(anonRepo);
      final seeder = AcceptanceDataSeeder(anonRepo);

      final count = await seeder.fillBills(
        ledgerId: data.ledgerId,
        operatorMemberId: data.memberIds.first,
      );

      // 12 个月 × 每月最少 6 笔
      expect(count, greaterThanOrEqualTo(72));
      final txs = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(data.ledgerId))).get();
      expect(txs.length, count);

      // 覆盖近 12 个月：最早一笔落在 11 个月之前（含当月共 12 个自然月）
      final now = DateTime.now();
      final earliest = txs
          .map((t) => t.happenedAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      expect(earliest.isBefore(DateTime(now.year, now.month - 10, 1)), isTrue);

      // 多币种轮换：至少出现两种币种（含本位币）
      final codes = txs.map((t) => t.currencyCode).toSet();
      expect(codes.length, greaterThanOrEqualTo(2));

      // 金额均为规范化 decimal 字符串
      for (final t in txs) {
        expect(double.tryParse(t.amount), isNotNull);
      }

      // 支出人统一归属账本成员（含虚拟用户），避免「支出人未知」失真
      for (final t in txs) {
        expect(t.payerMemberId, isNotNull);
        expect(data.memberIds, contains(t.payerMemberId));
      }

      // 每 4 笔固定 1 笔人均 AA：72 笔至少 18 笔
      expect(txs.where((t) => t.aaMode == 0).length, greaterThanOrEqualTo(18));
    });

    test('分类为空时自建兜底分类，填充不失败', () async {
      final ledgerId = await anonRepo.createLedger(
        name: '空分类账本',
        storageMode: 'local',
        aaEnabled: true,
        localSelfId: 'self-2',
      );
      final seeder = AcceptanceDataSeeder(anonRepo);

      final count = await seeder.fillBills(ledgerId: ledgerId);

      expect(count, greaterThanOrEqualTo(72));
      final cats = await anonRepo.getUsableCategories('expense');
      expect(cats, isNotEmpty);
    });
  });

  group('createAaBills 新建 AA 分摊账单', () {
    test('三种分摊模式齐备，指定分摊金额精确合计', () async {
      final data = await buildLedger(anonRepo);
      final seeder = AcceptanceDataSeeder(anonRepo);

      final ids = await seeder.createAaBills(
        ledgerId: data.ledgerId,
        baseCurrency: 'CNY',
        operatorMemberId: data.memberIds.first,
      );

      expect(ids.length, 3);
      final txs =
          await (db.select(db.transactions)
                ..where((t) => t.ledgerId.equals(data.ledgerId))
                ..where((t) => t.id.isIn(ids)))
              .get();
      // 人均(0) / 不分摊(1) / 指定金额(2) 各一笔
      expect(txs.map((t) => t.aaMode).toSet(), {0, 1, 2});

      // 指定分摊：关系行金额精确合计等于账单金额（本位币口径）
      final custom = txs.firstWhere((t) => t.aaMode == 2);
      final splits = await (db.select(
        db.transactionSplits,
      )..where((s) => s.transactionId.equals(custom.id))).get();
      final sum = splits.fold<num>(0, (acc, s) => acc + num.parse(s.amount));
      expect(sum, closeTo(num.parse(custom.amount), 0.001));
    });

    test('成员不足两人时自动补建虚拟用户', () async {
      // 只建 LOCAL self，不建虚拟用户
      final ledgerId = await anonRepo.createLedger(
        name: '单人账本',
        storageMode: 'local',
        aaEnabled: true,
        localSelfId: 'self-3',
      );
      final seeder = AcceptanceDataSeeder(anonRepo);

      final ids = await seeder.createAaBills(
        ledgerId: ledgerId,
        baseCurrency: 'CNY',
      );

      expect(ids.length, 3);
      final members = await anonRepo.getMembersByLedger(ledgerId);
      // 补建契约：总参与人数 >= 2（LOCAL self + 补建的虚拟用户），
      // 且确实发生了虚拟用户补建。
      expect(members.length, greaterThanOrEqualTo(2));
      expect(
        members.where((m) => m.memberType == 'PLACEHOLDER').length,
        greaterThanOrEqualTo(1),
      );
    });
  });

  group('createVirtualUsers 新建虚拟用户', () {
    test('创建 N 个 PLACEHOLDER 活跃成员', () async {
      final data = await buildLedger(anonRepo);
      final seeder = AcceptanceDataSeeder(anonRepo);

      final ids = await seeder.createVirtualUsers(
        ledgerId: data.ledgerId,
        count: 3,
      );

      expect(ids.length, 3);
      for (final id in ids) {
        final member = await anonRepo.getMemberById(id);
        expect(member, isNotNull);
        expect(member!.memberType, 'PLACEHOLDER');
        expect(member.status, 'ACTIVE');
      }
    });
  });

  group('createLocalLedger 新建本地账本', () {
    test('本地归属 + AA 开关 + self 成员 + 3 个虚拟用户', () async {
      final seeder = AcceptanceDataSeeder(anonRepo);

      final id = await seeder.createLocalLedger(
        localSelfId: 'self-9',
        name: '验收本地账本',
      );

      final ledger = await anonRepo.getLedgerById(id);
      expect(ledger, isNotNull);
      expect(ledger!.storageMode, 'local');
      expect(ledger.aaEnabled, isTrue);
      expect(ledger.selfMemberId, isNotNull);
      final members = await anonRepo.getMembersByLedger(id);
      expect(members.where((m) => m.memberType == 'LOCAL').length, 1);
      expect(members.where((m) => m.memberType == 'PLACEHOLDER').length, 3);
    });
  });

  group('createCloudLedgerIfLoggedIn 新建云账本', () {
    test('未登录跳过且不落库', () async {
      final seeder = AcceptanceDataSeeder(anonRepo);

      final id = await seeder.createCloudLedgerIfLoggedIn(
        accountId: null,
        name: '验收云账本',
      );

      expect(id, isNull);
      expect(await anonRepo.getAllLedgers(), isEmpty);
    });

    test('已登录创建云端账本并登记同步变更', () async {
      final seeder = AcceptanceDataSeeder(authedRepo);

      final id = await seeder.createCloudLedgerIfLoggedIn(
        accountId: 'user-1',
        name: '验收云账本',
      );

      expect(id, isNotNull);
      final ledger = await authedRepo.getLedgerById(id!);
      expect(ledger!.storageMode, 'cloud');
      expect(ledger.scopeAccountId, 'user-1');
      expect(ledger.aaEnabled, isTrue);
      final changes = await (db.select(
        db.syncChanges,
      )..where((c) => c.entityId.equals(id))).get();
      expect(
        changes.any((c) => c.entityType == 'ledger' && c.action == 'upsert'),
        isTrue,
      );
    });
  });
}
