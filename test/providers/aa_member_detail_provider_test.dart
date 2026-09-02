/// 成员账单详情 Provider 单测（按支出人维度聚合）。
///
/// 需求锚点：
/// - 详情页展示「该成员作为支出人」的全部支出明细（含不分摊 aaMode=1，
///   收入交易不计入支出明细）；
/// - 人均 / 指定金额的分摊明细、本人应摊与账本级统计口径一致；
/// - 不分摊账单无分摊明细，整笔金额即本人支出；
/// - 虚拟用户、owner、协作者均可作为支出人进入查看；
/// - 无垫付账单的成员返回空账单列表而非报错。
library;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart'
    show TransactionSplitInput;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/features/statistics/domain/aa_member_detail_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';

/// 插库交易 id 自增序列（主键为 UUID 字符串，需保证同文件内唯一）。
var _txSeq = 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late ProviderContainer container;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    // createLedger 返回 UUID，捕获后作为 family 参数。
    ledgerId = await repo.createLedger(
      name: '测试账本',
      storageMode: 'local',
      aaEnabled: true,
    );

    // 固定参与人名册与本人标记（与分摊详情表同源），
    // 让本测试只聚焦「按支出人聚合」这一新增逻辑。
    final stats = AaLedgerStatistics(
      participants: [
        AaParticipantSummary(
          participantId: 'u1',
          displayName: '张三',
          totalPaid: 0,
          totalShouldPay: 0,
          isSelf: true,
        ),
        AaParticipantSummary(
          participantId: 'u2',
          displayName: '李四',
          totalPaid: 0,
          totalShouldPay: 0,
          isSelf: false,
        ),
        AaParticipantSummary(
          participantId: 'vu1',
          displayName: '室友A',
          totalPaid: 0,
          totalShouldPay: 0,
          isSelf: false,
        ),
      ],
      transfers: const [],
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        aaStatisticsProvider.overrideWith((ref, ledgerId) async => stats),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  /// 直接写库插入一笔交易（绕过 sync 登记，仅作数据源）。
  Future<String> seedTx({
    required String amount,
    String? nativeAmount,
    String? currencyCode,
    String type = 'expense',
    String? payerMemberId,
    int? aaMode,
    DateTime? happenedAt,
    List<TransactionSplitInput>? splits,
  }) async {
    // 库表 CHECK:币种与折算金额必须成对出现;
    // 传了折算金额但没传币种时默认按 USD 构造，否则按账本本位币 CNY 补齐。
    final effectiveCurrency =
        currencyCode ?? (nativeAmount == null ? 'CNY' : 'USD');
    final at = happenedAt ?? DateTime(2026, 8, 3, 12, 0);
    final txId = 'tx-${_txSeq++}';
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: txId,
            ledgerId: ledgerId,
            txType: type,
            amount: amount,
            nativeAmount: nativeAmount ?? amount,
            currencyCode: effectiveCurrency,
            happenedAt: at,
            payerMemberId: payerMemberId == null
                ? const Value.absent()
                : Value(payerMemberId),
            aaMode: aaMode == null ? const Value.absent() : Value(aaMode),
            createdAt: at,
            updatedAt: at,
          ),
        );
    // 指定分摊写入关系表(先删后插,与仓储语义一致)。
    if (splits != null) {
      await (db.delete(
        db.transactionSplits,
      )..where((s) => s.transactionId.equals(txId))).go();
      if (splits.isNotEmpty) {
        await db.batch((b) {
          b.insertAll(db.transactionSplits, [
            for (final s in splits)
              TransactionSplitsCompanion.insert(
                transactionId: txId,
                memberId: s.memberId,
                amount: s.amount,
              ),
          ]);
        });
      }
    }
    return txId;
  }

  Future<AaMemberDetailData?> readDetail(String participantId) {
    return container.read(
      aaMemberDetailProvider((
        ledgerId: ledgerId,
        participantId: participantId,
      )).future,
    );
  }

  test('按支出人维度聚合：返回该成员全部支出明细（含不分摊，排除收入）', () async {
    // 张三垫付的人均账单：10.00 / 3 人，floor 后余数归支出人 → 3.34/3.33/3.33。
    await seedTx(
      amount: '10',
      payerMemberId: 'u1',
      aaMode: 0,
      happenedAt: DateTime(2026, 8, 3, 19, 15),
    );
    // 李四垫付的账单：不应出现在张三详情中。
    await seedTx(
      amount: '5',
      payerMemberId: 'u2',
      aaMode: 0,
      happenedAt: DateTime(2026, 8, 2, 12, 0),
    );
    // 不分摊：虽不进入 AA 统计，但属于该成员垫付的支出，必须纳入。
    await seedTx(
      amount: '7',
      payerMemberId: 'u1',
      aaMode: 1,
      happenedAt: DateTime(2026, 8, 1, 8, 0),
    );
    // 支出人未知：无法归属，不应出现。
    await seedTx(amount: '9', happenedAt: DateTime(2026, 7, 31, 8, 0));
    // 收入交易：不属于支出明细，不应出现。
    await seedTx(
      amount: '50',
      type: 'income',
      payerMemberId: 'u1',
      happenedAt: DateTime(2026, 7, 28, 10, 0),
    );
    // 张三垫付的指定金额账单：8.00 = 张三 4.00 + 李四 4.00。
    await seedTx(
      amount: '8',
      payerMemberId: 'u1',
      aaMode: 2,
      happenedAt: DateTime(2026, 7, 30, 20, 0),
      splits: [
        TransactionSplitInput(memberId: 'u1', amount: '4.00'),
        TransactionSplitInput(memberId: 'u2', amount: '4.00'),
      ],
    );

    final data = await readDetail('u1');
    expect(data, isNotNull);
    expect(data!.ledgerName, '测试账本');
    expect(data.member.isSelf, isTrue);
    expect(data.bills, hasLength(3), reason: '张三垫付的两笔 AA 账单 + 一笔不分摊支出，收入不计入');

    // 最新在前：人均账单 → 不分摊账单 → 指定金额账单。
    final perPersonBill = data.bills[0];
    expect(perPersonBill.mode, AaMode.perPerson);
    expect(perPersonBill.totalAmount, 10.0);
    expect(
      perPersonBill.myShare,
      closeTo(3.34, 0.001),
      reason: '人均 floor 后余数归支出人',
    );
    expect(perPersonBill.payerName, '张三');
    expect(perPersonBill.splits, hasLength(3));
    expect(perPersonBill.splits[0].participantId, 'u1');
    expect(perPersonBill.splits[0].isSelf, isTrue);
    expect(perPersonBill.splits[1].displayName, '李四');
    expect(perPersonBill.splits[2].displayName, '室友A');
    expect(
      perPersonBill.splits.fold<double>(0, (s, it) => s + it.amount),
      closeTo(10.0, 0.001),
      reason: '分摊明细合计恒等于账单实付',
    );

    // 不分摊账单：无分摊明细，整笔金额即本人支出。
    final noSplitBill = data.bills[1];
    expect(noSplitBill.mode, AaMode.noSplit);
    expect(noSplitBill.totalAmount, 7.0);
    expect(noSplitBill.myShare, closeTo(7.0, 0.001));
    expect(noSplitBill.splits, isEmpty);
    expect(noSplitBill.payerName, '张三');

    final customBill = data.bills[2];
    expect(customBill.mode, AaMode.custom);
    expect(customBill.totalAmount, 8.0);
    expect(customBill.myShare, closeTo(4.0, 0.001));
    expect(customBill.splits, hasLength(2));
  });

  test('虚拟用户作为支出人可查看其账单详情', () async {
    await seedTx(amount: '3', payerMemberId: 'vu1', aaMode: 0);

    final data = await readDetail('vu1');
    expect(data, isNotNull);
    expect(data!.bills, hasLength(1));
    expect(data.bills.single.payerName, '室友A');
    expect(data.bills.single.myShare, closeTo(1.0, 0.001));
    expect(data.bills.single.splits, hasLength(3));
  });

  test('无垫付账单的成员返回空账单列表而非报错', () async {
    await seedTx(amount: '5', payerMemberId: 'u1', aaMode: 0);

    final data = await readDetail('u2');
    expect(data, isNotNull);
    expect(data!.member.displayName, '李四');
    expect(data.bills, isEmpty);
  });

  test('多币种:单笔账单与汇总均按账本本位币(nativeAmount)口径', () async {
    // 外币账单:原币 $10.00,折本位币 ¥72.50。
    await seedTx(
      amount: '10',
      nativeAmount: '72.50',
      payerMemberId: 'u1',
      aaMode: 0,
      happenedAt: DateTime(2026, 8, 3, 12, 0),
    );

    final data = await readDetail('u1');
    expect(data, isNotNull);
    final bill = data!.bills.single;
    // 实付/本人应摊均为本位币,而不是原币 $10 / $5。
    // v1 契约人均 = 全部成员(3 人)展开:本人应摊 = 72.50 / 3。
    expect(bill.totalAmount, closeTo(72.50, 0.001));
    expect(bill.myShare, closeTo(24.18, 0.001));
    // 分摊明细同样为本位币。
    expect(
      bill.splits.fold<double>(0, (s, it) => s + it.amount),
      closeTo(72.50, 0.001),
    );
  });
}
