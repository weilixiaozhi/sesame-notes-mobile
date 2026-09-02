/// 交易级多币种 — 币种切换不变性测试:
///
/// 核心验证点(对应 bug 修复):
///   1. 账本主币种变更后,recalcNativeAmountsForLedger 只重算 nativeAmount,
///      绝不修改交易的 currencyCode(交易原币种是用户记账时选的,不随主币种变更)
///   2. currencyCode 为空串的历史数据:先恢复旧本位币，再按新本位币折算
///   3. 显式 currencyCode='CNY' 的交易:主币种改为 USD 后仍为 'CNY'
///   4. nativeAmount 按新主币种重算(有汇率)或退化=amount(无汇率)
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

  // UUID 主键表 insert 要求调用方提供 id，用自增序号生成确定性的测试 id。
  var rawSeq = 0;

  /// 创建账本并返回 UUID
  Future<String> seedLedger({String currency = 'CNY'}) async {
    return repo.createLedger(
      name: 'L',
      currency: currency,
      storageMode: 'cloud',
    );
  }

  /// 插入汇率(1 quote = rate base)
  Future<void> seedRates({
    required String base,
    required Map<String, String> rates,
  }) async {
    await repo.upsertAutoRates(
      base: base,
      rateDate: '2026-07-20',
      rates: rates,
      source: 'test',
      fetchedAt: DateTime.utc(2026, 7, 20),
    );
  }

  /// 直接用 SQL 插入交易(绕过 _resolveTxCurrency 兜底),
  /// 用于精确模拟历史数据(currencyCode 为空串)。
  /// v1 schema 下 currency_code/native_amount 均为 NOT NULL,
  /// "缺失"状态用空串表示(repo 重算逻辑按 isEmpty 识别)。
  Future<String> seedTxRaw({
    required String ledgerId,
    required String amount,
    String? currencyCode,
    String? nativeAmount,
  }) async {
    final now = DateTime.now().toUtc();
    final id = 'raw-${rawSeq++}';
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: amount,
            happenedAt: DateTime(2026, 7, 15),
            currencyCode: currencyCode ?? '',
            nativeAmount: nativeAmount ?? '',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  group('recalcNativeAmountsForLedger 币种不变性', () {
    test('显式 currencyCode 的交易:主币种变更后 currencyCode 不变', () async {
      final lid = await seedLedger(currency: 'CNY');

      // 插入汇率:改主币种为 USD 后需要 CNY→USD 的汇率
      await seedRates(base: 'USD', rates: {'CNY': '0.14'});

      // 创建一笔 CNY 交易(主币种为 CNY 时, nativeAmount = amount)
      final txId = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 7, 15),
        currencyCode: 'CNY',
        nativeAmount: '100.00',
      );

      // 修改账本主币种为 USD 并全量重算
      await repo.updateLedger(id: lid, currency: 'USD');
      await repo.recalcNativeAmountsForLedger(lid, 'USD', previousBase: 'CNY');

      final tx = await repo.getTransactionById(txId);
      // 核心断言:currencyCode 不变,仍是 CNY
      expect(tx!.currencyCode, 'CNY', reason: '交易原币种不应随账本主币种变更而改变');
      // nativeAmount 按新主币种 USD 重算:100 × 0.14 = 14
      expect(tx.nativeAmount, '14', reason: 'nativeAmount 应按新主币种重算');
    });

    test('currencyCode 为空串的历史数据:按旧本位币恢复并折算', () async {
      final lid = await seedLedger(currency: 'CNY');

      await seedRates(base: 'USD', rates: {'CNY': '0.14'});

      // 用 SQL 直接插入 currencyCode 为空串的历史数据
      final txId = await seedTxRaw(
        ledgerId: lid,
        amount: '50.00',
        currencyCode: null,
        nativeAmount: null,
      );

      // 修改账本主币种为 USD 并全量重算
      await repo.updateLedger(id: lid, currency: 'USD');
      await repo.recalcNativeAmountsForLedger(lid, 'USD', previousBase: 'CNY');

      final tx = await repo.getTransactionById(txId);
      // 历史空币种金额属于换币前的 CNY；重算必须先恢复原币种，再折算为 USD。
      expect(tx!.currencyCode, 'CNY', reason: '历史空币种交易应恢复为换币前的账本币种');
      expect(tx.nativeAmount, '7', reason: '50 CNY 应按 0.14 汇率折算为 7 USD');
    });

    test('多笔交易混合币种:主币种变更后各自 currencyCode 均不变', () async {
      final lid = await seedLedger(currency: 'CNY');

      await seedRates(base: 'USD', rates: {'CNY': '0.14', 'EUR': '1.08'});

      // CNY 交易(原主币种)
      final cnyTx = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 7, 1),
        currencyCode: 'CNY',
        nativeAmount: '100.00',
      );
      // USD 交易(外币)
      final usdTx = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime(2026, 7, 2),
        currencyCode: 'USD',
        nativeAmount: '144.00', // 20 × 7.2(旧汇率)
      );
      // EUR 交易(外币)
      final eurTx = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '30.00',
        happenedAt: DateTime(2026, 7, 3),
        currencyCode: 'EUR',
        nativeAmount: '216.00', // 30 × 7.2(旧汇率)
      );

      // 修改账本主币种为 USD 并全量重算
      await repo.updateLedger(id: lid, currency: 'USD');
      await repo.recalcNativeAmountsForLedger(lid, 'USD', previousBase: 'CNY');

      // 全部 currencyCode 不变
      expect((await repo.getTransactionById(cnyTx))!.currencyCode, 'CNY');
      expect((await repo.getTransactionById(usdTx))!.currencyCode, 'USD');
      expect((await repo.getTransactionById(eurTx))!.currencyCode, 'EUR');

      // nativeAmount 按新主币种 USD 重算
      expect(
        (await repo.getTransactionById(cnyTx))!.nativeAmount,
        '14',
      ); // 100 × 0.14
      expect(
        (await repo.getTransactionById(usdTx))!.nativeAmount,
        '20.00',
      ); // 同币种 = amount
      expect(
        (await repo.getTransactionById(eurTx))!.nativeAmount,
        '32.4',
      ); // 30 × 1.08
    });

    test('无汇率时:currencyCode 不变,nativeAmount 退化=amount', () async {
      final lid = await seedLedger(currency: 'CNY');

      // 不插入任何汇率
      final txId = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 7, 1),
        currencyCode: 'CNY',
        nativeAmount: '100.00',
      );

      // 修改账本主币种为 USD 并全量重算(无 CNY→USD 汇率)
      await repo.updateLedger(id: lid, currency: 'USD');
      await repo.recalcNativeAmountsForLedger(lid, 'USD', previousBase: 'CNY');

      final tx = await repo.getTransactionById(txId);
      expect(tx!.currencyCode, 'CNY', reason: '无汇率时 currencyCode 也不变');
      expect(
        tx.nativeAmount,
        '100.00',
        reason: '无汇率时 nativeAmount 退化=amount,由补折算横幅兜底',
      );
    });
  });

  group('recomputeForeignTxForLedger 币种不变性', () {
    test('补折算模式:currencyCode 不变,只补 nativeAmount', () async {
      final lid = await seedLedger(currency: 'CNY');

      await seedRates(base: 'CNY', rates: {'USD': '7.2'});

      // 未折算外币(native==amount,模拟迁移回填态)
      final txId = await seedTxRaw(
        ledgerId: lid,
        amount: '10.00',
        currencyCode: 'USD',
        nativeAmount: '10.00', // == amount → 未折算
      );

      final n = await repo.recomputeForeignTxForLedger(lid);
      expect(n, 1);

      final tx = await repo.getTransactionById(txId);
      expect(tx!.currencyCode, 'USD', reason: '补折算不改 currencyCode');
      expect(tx.nativeAmount, '72'); // 10 × 7.2
    });
  });

  group('updateTransactionLedger 跨账本移动后币种不变性', () {
    test('跨账本移动:currencyCode 不变,nativeAmount 按新账本重算', () async {
      // 账本1: CNY
      final lid1 = await seedLedger(currency: 'CNY');
      // 账本2: USD
      final lid2 = await seedLedger(currency: 'USD');

      await seedRates(base: 'USD', rates: {'CNY': '0.14'});

      // 在账本1(CNY)下创建一笔 CNY 交易
      final txId = await repo.addTransaction(
        ledgerId: lid1,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 7, 1),
        currencyCode: 'CNY',
        nativeAmount: '100.00',
      );

      // 移动到账本2(USD)
      await repo.updateTransactionLedger(id: txId, ledgerId: lid2);

      final tx = await repo.getTransactionById(txId);
      expect(tx!.ledgerId, lid2);
      expect(tx.currencyCode, 'CNY', reason: '跨账本移动不改 currencyCode');
      expect(tx.nativeAmount, '14', reason: 'nativeAmount 按新账本本位币 USD 重算');
    });
  });

  group('add/update 交易折算兜底', () {
    test('add 不传两字段+本位币 → currencyCode=本位币, nativeAmount=amount', () async {
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

    test('add 不传 nativeAmount+外币+有汇率 → nativeAmount=折算值', () async {
      final lid = await seedLedger();

      await seedRates(base: 'CNY', rates: {'USD': '7.2'});
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

    test('update 不传币种字段只改金额 → 沿用旧快照, currencyCode 不变', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      // 只改金额、不传 currencyCode/nativeAmount → 快照与币种保持原值
      await repo.updateTransaction(id: id, type: 'expense', amount: '24.00');
      final tx = await repo.getTransactionById(id);
      expect(tx!.amount, '24.00');
      expect(tx.currencyCode, 'USD', reason: '更新不改 currencyCode');
      expect(tx.nativeAmount, '86.4', reason: '未传币种字段时沿用旧快照,不做隐含汇率缩放');
    });

    test('update 改备注不改金额 → 快照不动, currencyCode 不变', () async {
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
      expect(tx.currencyCode, 'USD');
      expect(tx.nativeAmount, '86.4');
    });

    test('update 显式传 currencyCode+nativeAmount → 以传入为准', () async {
      final lid = await seedLedger();

      final id = await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '12.00',
        happenedAt: DateTime(2026, 7, 12),
        currencyCode: 'USD',
        nativeAmount: '86.4',
      );
      // 编辑:改币种为 EUR,金额改为 30,折算快照 32.4
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '30.00',
        currencyCode: 'EUR',
        nativeAmount: '32.4',
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.currencyCode, 'EUR');
      expect(tx.amount, '30.00');
      expect(tx.nativeAmount, '32.4');
    });
  });

  group('countUnconvertedForeignTx / countForeignCurrencyTx', () {
    test('空账本:两者均返回 0', () async {
      final lid = await seedLedger();
      expect(await repo.countUnconvertedForeignTx(lid), 0);
      expect(await repo.countForeignCurrencyTx(lid), 0);
    });

    test('仅本位币交易:两者均返回 0', () async {
      final lid = await seedLedger();
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 1),
      );
      expect(await repo.countUnconvertedForeignTx(lid), 0);
      expect(await repo.countForeignCurrencyTx(lid), 0);
    });

    test('未折算外币:unconverted=1, foreignTotal=1', () async {
      final lid = await seedLedger();
      await seedTxRaw(
        ledgerId: lid,
        amount: '10.00',
        currencyCode: 'USD',
        nativeAmount: '10.00',
      );
      expect(await repo.countUnconvertedForeignTx(lid), 1);
      expect(await repo.countForeignCurrencyTx(lid), 1);
    });

    test('已折算外币:unconverted=0, foreignTotal=1', () async {
      final lid = await seedLedger();
      await seedTxRaw(
        ledgerId: lid,
        amount: '10.00',
        currencyCode: 'USD',
        nativeAmount: '72.00',
      );
      expect(await repo.countUnconvertedForeignTx(lid), 0);
      expect(await repo.countForeignCurrencyTx(lid), 1);
    });

    test('混合:未折算+已折算+本位币', () async {
      final lid = await seedLedger();
      await seedTxRaw(
        ledgerId: lid,
        amount: '10.00',
        currencyCode: 'USD',
        nativeAmount: '10.00',
      );
      await seedTxRaw(
        ledgerId: lid,
        amount: '20.00',
        currencyCode: 'EUR',
        nativeAmount: '144.00',
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 1),
      );
      expect(await repo.countUnconvertedForeignTx(lid), 1); // 仅 USD
      expect(await repo.countForeignCurrencyTx(lid), 2); // USD + EUR
    });
  });

  group('getLedgerForeignCurrencies / getUsedCurrencies', () {
    test('空账本:返回空集合', () async {
      final lid = await seedLedger();
      expect(await repo.getLedgerForeignCurrencies(lid), isEmpty);
      expect(await repo.getUsedCurrencies(), isEmpty);
    });

    test('仅本位币:foreignCurrencies 为空, usedCurrencies 包含本位币', () async {
      final lid = await seedLedger();
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 1),
      );
      expect(await repo.getLedgerForeignCurrencies(lid), isEmpty);
      expect(await repo.getUsedCurrencies(), {'CNY'});
    });

    test('混合币种:foreignCurrencies 排除本位币, usedCurrencies 全部', () async {
      final lid = await seedLedger();
      await seedTxRaw(
        ledgerId: lid,
        amount: '10.00',
        currencyCode: 'USD',
        nativeAmount: '72.00',
      );
      await seedTxRaw(
        ledgerId: lid,
        amount: '20.00',
        currencyCode: 'EUR',
        nativeAmount: '144.00',
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime(2026, 7, 1),
      );
      expect(await repo.getLedgerForeignCurrencies(lid), {'USD', 'EUR'});
      expect(await repo.getUsedCurrencies(), {'CNY', 'USD', 'EUR'});
    });
  });
}
