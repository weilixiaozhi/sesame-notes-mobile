/// AA 分摊计算服务单测。
///
/// 覆盖:
/// - 人均分摊:3 人 10.00 → 3.33/3.33/3.34,支出人实付差归支出人,总和恒等。
/// - 不分摊:跳过,不进入统计。
/// - 指定分摊:aaSplits 即最终应摊。
/// - 账本汇总:实付/应摊/净额 + 转账方案。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';
import 'package:sesame_notes/shared/aa/aa_decimal_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  group('aa_decimal_util', () {
    test('toDecimal2 规范 2 位小数', () {
      // Decimal.parse 会规范化尾随零('10.00' → '10'),用 toDouble 比较值。
      expect(toDouble(toDecimal2('10.0')), 10.0);
      expect(toDouble(toDecimal2('0.3')), 0.3);
    });

    test('splitEvenly: 3 人 10.00 余数归支出人,总和恒等', () {
      final total = toDecimal2('10.0');
      final splits = splitEvenly(
        total: total,
        participantCount: 3,
        payerIndex: 0, // 支出人 = 第 0 个
      );
      expect(splits, hasLength(3));
      // floor(1000/3) = 333 分 = 3.33;余数 1 分归支出人 → 3.34
      expect(toDouble(splits[0]).toStringAsFixed(2), '3.34');
      expect(toDouble(splits[1]).toStringAsFixed(2), '3.33');
      expect(toDouble(splits[2]).toStringAsFixed(2), '3.33');
      // 总和恒等
      final sum = toDouble(splits.fold(toDecimal2('0.0'), (acc, v) => acc + v));
      expect(sum.toStringAsFixed(2), '10.00');
    });

    test('splitEvenly: 整除场景无余数', () {
      final total = toDecimal2('9.0');
      final splits = splitEvenly(
        total: total,
        participantCount: 3,
        payerIndex: 1,
      );
      // 9.00 / 3 = 3.00 整除,无余数
      for (final s in splits) {
        expect(toDouble(s).toStringAsFixed(2), '3.00');
      }
    });

    test('validateSplitsTotal: 合计校验', () {
      final total = toDecimal2('10.0');
      // 合计 10.00,校验通过
      final ok = [toDecimal2('3.34'), toDecimal2('3.33'), toDecimal2('3.33')];
      expect(validateSplitsTotal(total: total, splits: ok), isTrue);
      // 合计 9.00,校验失败(超 0.01 容差)
      final bad = [toDecimal2('3.0'), toDecimal2('3.0'), toDecimal2('3.0')];
      expect(validateSplitsTotal(total: total, splits: bad), isFalse);
      // 金额边界必须精确相等，差 1 分也不能由统计层静默接受。
      final shortByOneCent = [toDecimal2('6.0'), toDecimal2('3.99')];
      expect(
        validateSplitsTotal(total: total, splits: shortByOneCent),
        isFalse,
      );
    });
  });

  group('AaStatisticsService.computeTx', () {
    late SesameDatabase db;

    setUp(() {
      db = SesameDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async => db.close());

    /// 构造一条交易行(不写库,仅用 data class)。
    Transaction makeTx({
      required String id,
      String amount = '10.00',
      String? nativeAmount,
      String? payerMemberId = 'u1',
      int? aaMode,
      ({List<String>? participantIds, Map<String, String>? splits})? aaModel,
    }) {
      return Transaction(
        id: id,
        ledgerId: 'led-1',
        txType: 'expense',
        amount: amount,
        categoryId: null,
        happenedAt: DateTime(2026, 7, 1),
        note: null,
        recurringId: null,
        createdByMemberId: null,
        lastEditedByMemberId: null,
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: nativeAmount ?? '',
        version: 1,
        lastEditedAt: null,
        payerMemberId: payerMemberId,
        aaMode: aaMode,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );
    }

    test('人均: 3 人 10.00,支出人 u1 实付差归 u1', () {
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        payerMemberId: 'u1',
        aaMode: 0, // 人均
        aaModel: (participantIds: ['u1', 'u2', 'u3'], splits: null),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2', 'u3'],
        aaModel: (participantIds: ['u1', 'u2', 'u3'], splits: null),
      )!;
      expect(result.mode, AaMode.perPerson);
      expect(result.paidBy, 'u1');
      // u1 取余数 → 3.34;u2/u3 → 3.33
      expect(result.shares['u1']!.toStringAsFixed(2), '3.34');
      expect(result.shares['u2']!.toStringAsFixed(2), '3.33');
      expect(result.shares['u3']!.toStringAsFixed(2), '3.33');
      // 总和 == 实付
      final sum = result.shares.values.fold(0.0, (a, b) => a + b);
      expect(sum.toStringAsFixed(2), '10.00');
    });

    test('人均: aaParticipants 空 → 展开为账本全部成员', () {
      final tx = makeTx(
        id: 'tx-1',
        amount: '9.00',
        payerMemberId: 'u2',
        aaMode: null, // null 视为人均
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2', 'u3'],
        aaModel: (participantIds: null, splits: null),
      )!;
      // 9.00 / 3 = 3.00 整除
      expect(result.shares['u1']!.toStringAsFixed(2), '3.00');
      expect(result.shares['u2']!.toStringAsFixed(2), '3.00');
      expect(result.shares['u3']!.toStringAsFixed(2), '3.00');
    });

    test('不分摊(aaMode=1): 返回 null,不进入 AA 统计', () {
      final tx = makeTx(id: 'tx-1', aaMode: 1);
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (participantIds: null, splits: null),
      );
      expect(result, isNull);
    });

    test('指定分摊: aaSplits 即最终应摊', () {
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        payerMemberId: 'u1',
        aaMode: 2, // 指定
        aaModel: (
          participantIds: ['u1', 'u2'],
          splits: {'u1': '6.00', 'u2': '4.00'},
        ),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (
          participantIds: ['u1', 'u2'],
          splits: {'u1': '6.00', 'u2': '4.00'},
        ),
      )!;
      expect(result.mode, AaMode.custom);
      expect(result.shares['u1']!.toStringAsFixed(2), '6.00');
      expect(result.shares['u2']!.toStringAsFixed(2), '4.00');
    });

    test('指定分摊: 合计与交易金额不一致时拒绝统计', () {
      final tx = makeTx(
        id: 'tx-invalid-custom-total',
        amount: '10.00',
        payerMemberId: 'u1',
        aaMode: 2,
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (
          participantIds: ['u1', 'u2'],
          splits: {'u1': '6.00', 'u2': '3.99'},
        ),
      );
      expect(result, isNull);
    });

    test('指定分摊: aaSplits 为空 → 返回 null', () {
      final tx = makeTx(id: 'tx-1', aaMode: 2);
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (participantIds: null, splits: null),
      );
      expect(result, isNull);
    });

    test('payerMemberId 为空(支出人未知) → 返回 null,跳过分摊', () {
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        payerMemberId: null,
        aaMode: 0,
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      );
      // 支出人未知:实付无法归属,跳过该交易,不得误归给参与人首个。
      expect(result, isNull);
    });

    test('payerMemberId 为空串 → 同样跳过分摊', () {
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        payerMemberId: '',
        aaMode: 0,
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      );
      expect(result, isNull);
    });

    test('外币交易:人均分摊按 nativeAmount(本位币)计算', () {
      // 原币 1000 分($10),折本位币 7250 分(¥72.50,隐含汇率 7.25)。
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        nativeAmount: '72.50',
        payerMemberId: 'u1',
        aaMode: 0,
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (participantIds: ['u1', 'u2'], splits: null),
      )!;
      // 实付按本位币输出,而不是原币 $10。
      expect(result.paidAmount.toStringAsFixed(2), '72.50');
      // 72.50 / 2 = 36.25 整除,无余数。
      expect(result.shares['u1']!.toStringAsFixed(2), '36.25');
      expect(result.shares['u2']!.toStringAsFixed(2), '36.25');
    });

    test('外币指定分摊:原币金额按隐含汇率折到本位币', () {
      // $10,隐含汇率 7.25 → ¥72.50;原币分摊 u1=6 / u2=4。
      final tx = makeTx(
        id: 'tx-1',
        amount: '10.00',
        nativeAmount: '72.50',
        payerMemberId: 'u1',
        aaMode: 2,
        aaModel: (
          participantIds: ['u1', 'u2'],
          splits: {'u1': '6.00', 'u2': '4.00'},
        ),
      );
      final result = AaStatisticsService.computeTx(
        tx: tx,
        allParticipants: ['u1', 'u2'],
        aaModel: (
          participantIds: ['u1', 'u2'],
          splits: {'u1': '6.00', 'u2': '4.00'},
        ),
      )!;
      // 6.00 × 7.25 = 43.50;4.00 × 7.25 = 29.00。
      expect(result.shares['u1']!.toStringAsFixed(2), '43.50');
      expect(result.shares['u2']!.toStringAsFixed(2), '29.00');
    });
  });

  group('AaStatisticsService.computeLedger', () {
    Transaction makeTx({
      required String id,
      required String amount,
      String? nativeAmount,
      required String payerMemberId,
      int? aaMode,
    }) {
      return Transaction(
        id: id,
        ledgerId: 'led-1',
        txType: 'expense',
        amount: amount,
        categoryId: null,
        happenedAt: DateTime(2026, 7, 1),
        note: null,
        recurringId: null,
        createdByMemberId: null,
        lastEditedByMemberId: null,
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: nativeAmount ?? '',
        version: 1,
        lastEditedAt: null,
        payerMemberId: payerMemberId,
        aaMode: aaMode,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );
    }

    test('汇总: 人均交易均按账本全部成员展开(v1 契约语义),净额正确', () {
      final txs = [
        makeTx(id: 'tx-1', amount: '10.00', payerMemberId: 'u1', aaMode: 0),
        makeTx(id: 'tx-2', amount: '6.00', payerMemberId: 'u2', aaMode: 0),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', 'u2', 'u3'],
        displayNameMap: {'u1': 'Alice', 'u2': 'Bob', 'u3': 'Carol'},
      );

      // v1 契约人均(aa_mode=0) = 全部成员运行时展开:
      // u1: 实付 10.00,应摊 = 3.34(tx1) + 2.00(tx2) = 5.34,净额 = 4.66
      final u1 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u1',
      );
      expect(u1.totalPaid.toStringAsFixed(2), '10.00');
      expect(u1.totalShouldPay.toStringAsFixed(2), '5.34');
      expect(u1.net.toStringAsFixed(2), '4.66');

      // u2: 实付 6.00,应摊 = 3.33 + 2.00 = 5.33,净额 = 0.67
      final u2 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u2',
      );
      expect(u2.totalPaid.toStringAsFixed(2), '6.00');
      expect(u2.totalShouldPay.toStringAsFixed(2), '5.33');
      expect(u2.net.toStringAsFixed(2), '0.67');

      // u3: 实付 0,应摊 = 3.33 + 2.00 = 5.33,净额 = -5.33
      final u3 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u3',
      );
      expect(u3.totalPaid.toStringAsFixed(2), '0.00');
      expect(u3.totalShouldPay.toStringAsFixed(2), '5.33');
      expect(u3.net.toStringAsFixed(2), '-5.33');
    });

    test('转账方案: 净额>0 与 <0 配对,贪心最小化笔数', () {
      final txs = [
        makeTx(id: 'tx-1', amount: '30.00', payerMemberId: 'u1', aaMode: 0),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', 'u2', 'u3'],
        displayNameMap: {'u1': 'Alice', 'u2': 'Bob', 'u3': 'Carol'},
      );

      // u1 实付 30,应摊 10,净额 +20
      // u2/u3 各应摊 10,净额 -10
      // 转账方案: u2→u1 10, u3→u1 10(2 笔)
      expect(settlement.transfers, hasLength(2));
      for (final t in settlement.transfers) {
        expect(t.to, 'u1', reason: '所有转账指向净额>0 的 u1');
        expect(t.amount.toStringAsFixed(2), '10.00');
      }
      final fromIds = settlement.transfers.map((t) => t.from).toSet();
      expect(fromIds, {'u2', 'u3'});
    });

    test('空支出人交易被跳过,不误归给参与人首个', () {
      final txs = [
        makeTx(
          id: 'tx-1',
          amount: '30.00',
          payerMemberId: '', // 支出人未知(如历史/导入数据缺字段)
          aaMode: 0,
        ),
        makeTx(id: 'tx-2', amount: '6.00', payerMemberId: 'u1', aaMode: 0),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', 'u2', 'u3'],
        displayNameMap: {'u1': 'Alice', 'u2': 'Bob', 'u3': 'Carol'},
      );

      // tx1(30 元,支出人未知)整体跳过:参与人实付/应摊均不受影响。
      // 仅 tx2:人均按全部成员 3 人,u1 实付 6,应摊 2,净额 +4;u2/u3 各应摊 2,净额 -2。
      final u1 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u1',
      );
      expect(u1.totalPaid.toStringAsFixed(2), '6.00');
      expect(u1.net.toStringAsFixed(2), '4.00');
      final u2 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u2',
      );
      expect(u2.totalPaid.toStringAsFixed(2), '0.00');
      expect(u2.net.toStringAsFixed(2), '-2.00');
      final u3 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u3',
      );
      expect(u3.totalPaid.toStringAsFixed(2), '0.00');
      expect(u3.totalShouldPay.toStringAsFixed(2), '2.00');
    });

    test('虚拟用户参与: 虚拟用户 id 作为参与人标识', () {
      final vuId = 'vu-uuid-1';
      final txs = [
        makeTx(id: 'tx-1', amount: '10.00', payerMemberId: 'u1', aaMode: 0),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', vuId],
        displayNameMap: {'u1': 'Alice', vuId: '室友'},
      );

      // u1 实付 10,应摊 5,净额 +5
      final u1 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u1',
      );
      expect(u1.net.toStringAsFixed(2), '5.00');
      // 虚拟用户应摊 5,净额 -5
      final vu = settlement.participants.firstWhere(
        (p) => p.participantId == vuId,
      );
      expect(vu.displayName, '室友');
      expect(vu.net.toStringAsFixed(2), '-5.00');
      // 转账: vu → u1 5.00
      expect(settlement.transfers, hasLength(1));
      expect(settlement.transfers.single.from, vuId);
      expect(settlement.transfers.single.to, 'u1');
    });

    test('selfMap 贯通: 参与人 isSelf 与转账方案本人标记正确', () {
      final txs = [
        makeTx(id: 'tx-1', amount: '30.00', payerMemberId: 'u1', aaMode: 0),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', 'u2', 'u3'],
        displayNameMap: {'u1': 'Alice', 'u2': 'Bob', 'u3': 'Carol'},
        // 仅 u2 标记为本人(如本地账本 owner 恒为本人)。
        selfMap: {'u2': true},
      );

      // 参与人 isSelf:默认 false,selfMap 命中者 true。
      final u1 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u1',
      );
      final u2 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u2',
      );
      final u3 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u3',
      );
      expect(u1.isSelf, isFalse);
      expect(u2.isSelf, isTrue);
      expect(u3.isSelf, isFalse);

      // u1 应收(净额 +20),u2/u3 各应付 10:转账 u2→u1、u3→u1。
      // 收款方 u1 非本人;u2 为付款方本人,其 fromIsSelf 应为 true。
      final fromU2 = settlement.transfers.firstWhere(
        (t) => t.from == 'u2' && t.to == 'u1',
      );
      final fromU3 = settlement.transfers.firstWhere(
        (t) => t.from == 'u3' && t.to == 'u1',
      );
      expect(fromU2.fromIsSelf, isTrue);
      expect(fromU3.fromIsSelf, isFalse);
      expect(fromU2.toIsSelf, isFalse);
    });

    test('多币种账本:汇总按 nativeAmount 跨币种求和,不直接相加原币', () {
      final txs = [
        // u1 垫付 ¥100(人民币)。
        makeTx(
          id: 'tx-1',
          amount: '100.00',
          nativeAmount: '100.00',
          payerMemberId: 'u1',
          aaMode: 0,
        ),
        // u2 垫付 $50,折本位币 ¥362.50(隐含汇率 7.25)。
        makeTx(
          id: 'tx-2',
          amount: '50.00',
          nativeAmount: '362.50',
          payerMemberId: 'u2',
          aaMode: 0,
        ),
      ];
      final settlement = AaStatisticsService.computeLedger(
        transactions: txs,
        allParticipants: ['u1', 'u2'],
        displayNameMap: {'u1': 'Alice', 'u2': 'Bob'},
      );

      // u1:实付 ¥100.00,应摊 50 + 181.25 = 231.25,净额 -131.25。
      final u1 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u1',
      );
      expect(u1.totalPaid.toStringAsFixed(2), '100.00');
      expect(u1.totalShouldPay.toStringAsFixed(2), '231.25');
      expect(u1.net.toStringAsFixed(2), '-131.25');
      // u2:实付 ¥362.50,应摊 50 + 181.25 = 231.25,净额 +131.25。
      final u2 = settlement.participants.firstWhere(
        (p) => p.participantId == 'u2',
      );
      expect(u2.totalPaid.toStringAsFixed(2), '362.50');
      expect(u2.net.toStringAsFixed(2), '131.25');
    });
  });
}
