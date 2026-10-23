import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

/// AA 分摊详情表的成员覆盖与成员账单详情的汇总口径。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  const ledgerId = 'ledger-1';
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    // 共享账本（storageMode=cloud + memberCount>1）：成员镜像即 AA 参与人名册。
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '共享AA账本',
            memberCount: const Value(3),
            role: const Value('owner'),
            aaEnabled: const Value(true),
            storageMode: const Value('cloud'),
            selfMemberId: const Value('u1'),
            updatedAt: DateTime.utc(2026, 8, 8),
          ),
        );
    for (final (id, name) in [
      ('u1', '张三'),
      ('u2', '李四'),
      ('u3', '王五'),
      ('u4', '赵六'),
    ]) {
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: id,
              ledgerId: ledgerId,
              displayName: name,
              memberType: 'REGISTERED',
              linkedAccountId: Value(id),
              role: const Value('editor'),
              updatedAt: DateTime.utc(2026, 8, 8),
            ),
          );
    }
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  /// 等待 Drift 流首次发射并驱动派生 provider 重算。
  Future<void> waitUntil(
    bool Function() predicate, {
    required String reason,
  }) async {
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (!predicate()) {
      if (DateTime.now().isAfter(deadline)) fail(reason);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  /// 张三与王五有分摊活动；李四只有不分摊支出；赵六没有任何支出。
  ///
  /// 分摊账单用指定分摊（人均会摊到全部参与人，造不出「零 AA 活动」成员）。
  Future<void> seedTransactions() async {
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '168',
      happenedAt: DateTime(2026, 8, 3, 19, 15),
      payerMemberId: 'u1',
      aaMode: 2,
      splits: [
        TransactionSplitInput(memberId: 'u1', amount: '84'),
        TransactionSplitInput(memberId: 'u3', amount: '84'),
      ],
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      happenedAt: DateTime(2026, 7, 30, 20),
      payerMemberId: 'u1',
      aaMode: 2,
      splits: [
        TransactionSplitInput(memberId: 'u1', amount: '4'),
        TransactionSplitInput(memberId: 'u3', amount: '4'),
      ],
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '7',
      happenedAt: DateTime(2026, 8, 1, 8),
      payerMemberId: 'u1',
      aaMode: 1,
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '5',
      happenedAt: DateTime(2026, 8, 2, 9),
      payerMemberId: 'u2',
      aaMode: 1,
    );
  }

  test('分摊详情表：仅有不分摊支出的成员也补入，无任何支出的成员不入表', () async {
    await seedTransactions();
    // 保持真实监听：Riverpod 3 下无人监听时流订阅会暂停，派生 provider 不会重算。
    container.listen(aaDetailParticipantsProvider(ledgerId), (_, _) {});
    await waitUntil(
      () => container.read(aaNoSplitTxProvider(ledgerId)).hasValue,
      reason: '不分摊交易流未发射',
    );

    final visible = container.read(aaDetailParticipantsProvider(ledgerId));

    expect(visible.map((p) => p.participantId).toSet(), {
      'u1',
      'u2',
      'u3',
    }, reason: '仅有不分摊支出的李四必须补入分摊详情表，无任何支出的赵六不入表');
    final li = visible.singleWhere((p) => p.participantId == 'u2');
    expect(li.displayName, '李四');
    expect(li.totalPaid, 0, reason: '不分摊支出不进 AA 统计，实付按真实统计值 0 展示');
    expect(li.totalShouldPay, 0);
  });

  test('成员账单详情：总付=全部账单合计（含不分摊），分摊实付不含不分摊', () async {
    await seedTransactions();

    final data = await readProviderFutureFromContainer(
      container,
      aaMemberDetailProvider((ledgerId: ledgerId, participantId: 'u1')).future,
    );

    expect(data, isNotNull);
    expect(data!.bills, hasLength(3), reason: '两笔指定分摊 + 一笔不分摊账单都归支出人张三');
    expect(
      data.totalBillAmount,
      closeTo(183, 0.001),
      reason: '总付 = 全部账单合计，必须含不分摊支出',
    );
    expect(
      data.member.totalPaid,
      closeTo(176, 0.001),
      reason: '分摊实付只算 AA 账单（168 + 8），不含不分摊支出',
    );
    expect(
      data.totalBillAmount - data.member.totalPaid,
      closeTo(7, 0.001),
      reason: '总付与分摊实付的差额恰为不分摊支出',
    );
    expect(
      data.bills.singleWhere((b) => b.mode == AaMode.noSplit).totalAmount,
      7.0,
    );
  });
}
