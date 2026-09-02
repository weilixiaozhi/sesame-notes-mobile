/// 交易级多币种 — Repository 层契约:
///   - addTransaction 带折算兜底:同币种=amount;外币先查有效汇率,
///     取不到才 =amount
///   - updateTransaction 快照规则:两字段缺省时沿用旧快照(外币不做隐含
///     汇率缩放);显式传 nativeAmount 以传入为准,不联动;改备注不动快照
///   - recompute/recalc/count:补折算/全量重算/检测
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 创建账本并返回 UUID
  Future<String> seedLedger({String currency = 'CNY'}) async {
    return repo.createLedger(
      name: 'L',
      currency: currency,
      storageMode: 'cloud',
    );
  }

  Future<void> seedUsdRates() => repo.upsertAutoRates(
    base: 'CNY',
    rateDate: '2026-07-10',
    rates: {'USD': '7.2'},
    source: 'test',
    fetchedAt: DateTime.utc(2026, 7, 10),
  );

  group('addTransaction 带折算兜底', () {
    test('不传两字段+本位币 → currencyCode=本位币, nativeAmount=amount', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '100.00',

        happenedAt: DateTime(2026, 7, 12),
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.currencyCode, 'CNY');
      expect(tx.nativeAmount, '100.00');
    });

    test('不传 nativeAmount+外币+有汇率 → nativeAmount=折算值', () async {
      final lid = await seedLedger();

      await seedUsdRates();
      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        currencyCode: 'USD',
        happenedAt: DateTime(2026, 7, 12),
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.currencyCode, 'USD');
      expect(tx.nativeAmount, '86.4');
    });

    test('不传 nativeAmount+外币+无汇率 → nativeAmount=amount(命中补折算检测)', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        currencyCode: 'USD',
        happenedAt: DateTime(2026, 7, 12),
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.currencyCode, 'USD');
      expect(tx.nativeAmount, '12.00');
      expect(await repo.countUnconvertedForeignTx(lid), 1);
    });

    test('显式传外币两字段 → 原样写入(UI 手改汇率快照)', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',

        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '87.00', // 用户手改的汇率快照
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.nativeAmount, '87.00');
    });

    test('无账户交易显式传币种 → 写入所选;不传 → 本位币', () async {
      final lid = await seedLedger();
      await seedUsdRates();
      final id1 = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      expect((await repo.getTransactionById(id1))!.currencyCode, 'USD');

      final id2 = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '5.00',
        happenedAt: DateTime(2026, 7, 12),
      );
      final tx2 = await repo.getTransactionById(id2);
      expect(tx2!.currencyCode, 'CNY');
      expect(tx2.nativeAmount, '5.00');
    });
  });

  group('updateTransaction 联动兜底(App 侧镜像)', () {
    test('不传币种字段只改金额 → 沿用旧快照', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',

        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      // 只改金额、不传 currencyCode/nativeAmount → 快照保持原值
      await repo.updateTransaction(id: id, type: 'expense', amount: '24.00');
      final tx = await repo.getTransactionById(id);
      expect(tx!.amount, '24.00');
      expect(tx.nativeAmount, '86.4');
    });

    test('金额未变(改备注)→ 快照不动', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',

        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '12.00',
        note: '改备注',
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.note, '改备注');
      expect(tx.nativeAmount, '86.4');
    });

    test('显式传 nativeAmount → 以传入为准(不联动)', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',

        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '24.00',
        currencyCode: 'USD',
        nativeAmount: '170.00',
      );
      expect((await repo.getTransactionById(id))!.nativeAmount, '170.00');
    });
  });

  group('补折算 / 全量重算 / 检测', () {
    test('recompute 只补「未折算外币」;已折算/本位币不动;返回条数', () async {
      final lid = await seedLedger();

      await seedUsdRates();
      // 未折算外币(native==amount,模拟迁移回填态)
      final unconverted = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 7, 1),
        currencyCode: 'USD',
        nativeAmount: '10.00',
      );
      // 已折算外币(不许覆盖)
      final converted = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        happenedAt: DateTime(2026, 7, 2),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      // 本位币(不动)
      final cny = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 3),
      );

      final n = await repo.recomputeForeignTxForLedger(lid);
      expect(n, 1);
      expect(
        (await repo.getTransactionById(unconverted))!.nativeAmount,
        '72',
      ); // 10 × 7.2
      expect((await repo.getTransactionById(converted))!.nativeAmount, '86.4');
      expect((await repo.getTransactionById(cny))!.nativeAmount, '50.00');
      expect(await repo.countUnconvertedForeignTx(lid), 0); // 横幅消失
    });

    test('纯本位币账本 recompute 返回 0、无改动', () async {
      final lid = await seedLedger();
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 3),
      );
      expect(await repo.recomputeForeignTxForLedger(lid), 0);
    });

    test('recalc 全量按新本位币重算', () async {
      final lid = await seedLedger(); // 本位币 CNY

      // 改本位币为 USD 后:CNY 交易要折 USD、USD 交易对齐 =amount
      await repo.upsertAutoRates(
        base: 'USD',
        rateDate: '2026-07-10',
        rates: {'CNY': '0.14'},
        source: 'test',
        fetchedAt: DateTime.utc(2026, 7, 10),
      );
      final usdTx = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        happenedAt: DateTime(2026, 7, 1),
        currencyCode: 'USD',
        nativeAmount: '86.4', // 旧本位币 CNY 的快照
      );
      final cnyTx = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 7, 2),
        currencyCode: 'CNY',
        nativeAmount: '100.00',
      );

      final n = await repo.recalcNativeAmountsForLedger(
        lid,
        'USD',
        previousBase: 'CNY',
      );
      expect(n, 2);
      expect(
        (await repo.getTransactionById(usdTx))!.nativeAmount,
        '12.00',
      ); // 对齐原币
      expect(
        (await repo.getTransactionById(cnyTx))!.nativeAmount,
        '14',
      ); // 100 × 0.14
    });
  });
}
