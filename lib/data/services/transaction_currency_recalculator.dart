import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/contracts/currency_rate_repository.dart';
import 'package:sesame_notes/data/repositories/contracts/currency_transaction_repository.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 原币、本位币与分摊金额的持久化一致性，变更登记和重算共用一个事务。
class TransactionCurrencyRecalculator {
  /// 只注入交易存储和三个汇率读取能力，不依赖组合仓储实现。
  TransactionCurrencyRecalculator(this.db, this._transactions, this._rates);
  final SesameDatabase db;
  final CurrencyTransactionRepository _transactions;
  final CurrencyRateRepository _rates;

  /// 以 [base] 为本位币合成有效汇率（手动 > 最新自动）。
  Future<Map<String, EffectiveRate>> _effectiveRatesFor(String base) async {
    final autos = await _rates.getLatestAutoRates(base);
    final overrides = await _rates.getOverrides(base);
    return mergeEffectiveRates(
      autoRates: [
        for (final r in autos)
          (quote: r.quoteCurrency, rate: r.rate, rateDate: r.rateDate),
      ],
      overrides: [
        for (final o in overrides) (quote: o.quoteCurrency, rate: o.rate),
      ],
    );
  }

  /// 兜底解析 (currencyCode, nativeAmount)：币种默认账本本位币；
  /// 外币按有效汇率折算，取不到则 native=amount（未折算检测可捞回）。
  Future<(String, String)> resolveCurrency({
    required String ledgerId,
    required String amount,
    String? currencyCode,
    String? nativeAmount,
    bool requireRate = false,
  }) async {
    if (currencyCode != null &&
        currencyCode.isNotEmpty &&
        nativeAmount != null &&
        nativeAmount.isNotEmpty) {
      return (currencyCode.toUpperCase(), nativeAmount);
    }
    final base = await _rates.ledgerBaseCurrency(ledgerId);
    var cc = currencyCode?.toUpperCase();
    if (cc == null || cc.isEmpty) {
      cc = base;
    }
    var na = nativeAmount;
    if (na == null || na.isEmpty) {
      if (cc == base) {
        na = amount;
      } else {
        final rates = await _effectiveRatesFor(base);
        na = computeNativeAmountDecimal(
          amount: amount,
          txCurrency: cc,
          ledgerBase: base,
          rates: rates,
        );
        if (na == null && requireRate) {
          throw StateError('缺少 $cc 到 $base 的有效汇率，周期账单未生成，请更新汇率后重试。');
        }
        na ??= amount;
      }
    }
    return (cc, na);
  }

  /// 重算核心：遍历该账本交易按 [base] 重算 nativeAmount（Decimal 字符串版）。
  ///
  /// [recordChanges] 默认 true：云端账本在同一个写事务内登记 transaction
  /// upsert 同步变更（含 AA 分摊行折算后的完整 payload）；恢复导入等回填
  /// 路径传 false，禁止历史快照反向推云。
  Future<int> recalculate(
    String ledgerId,
    String base, {
    required bool onlyUnconverted,
    String? previousBase,
    bool recordChanges = true,
  }) => db.transaction(
    () => _recalcNativeAmountsInner(
      ledgerId,
      base,
      onlyUnconverted: onlyUnconverted,
      previousBase: previousBase,
      recordChanges: recordChanges,
    ),
  );

  /// 在同一数据上下文中计算并保存金额变化。
  Future<int> _recalcNativeAmountsInner(
    String ledgerId,
    String base, {
    required bool onlyUnconverted,
    required String? previousBase,
    bool recordChanges = true,
  }) async {
    final baseUp = base.toUpperCase();
    final previousBaseUp = previousBase?.trim().toUpperCase();
    final rates = await _effectiveRatesFor(baseUp);
    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())).get();
    // 单次重算共用同一时刻：交易 updatedAt 与同步变更登记时间一致，云端
    // LWW 按该时间裁决，避免「本地已改、云端仍旧」的半同步态。
    final now = DateTime.now().toUtc();
    final changedIds = <String>[];
    for (final t in txs) {
      final shouldBackfillCurrency =
          !onlyUnconverted &&
          previousBaseUp != null &&
          (t.currencyCode.isEmpty || t.currencyCode.trim().isEmpty);
      final cc =
          (shouldBackfillCurrency
                  ? previousBaseUp
                  : t.currencyCode.isEmpty
                  ? baseUp
                  : t.currencyCode)
              .toUpperCase();
      if (cc == baseUp) {
        // 本位币交易：全量重算时对齐 native=amount。
        if (onlyUnconverted ||
            (!shouldBackfillCurrency && t.nativeAmount == t.amount)) {
          continue;
        }
        await (db.update(
          db.transactions,
        )..where((x) => x.id.equals(t.id))).write(
          TransactionsCompanion(
            currencyCode: shouldBackfillCurrency
                ? d.Value(cc)
                : const d.Value.absent(),
            nativeAmount: d.Value(t.amount),
            updatedAt: d.Value(now),
          ),
        );
        // 本位币口径同样要求 sum(splits)==amount，历史错快照同步补齐。
        await _scaleAaSplitsForRecalc(t, newNative: t.amount);
        changedIds.add(t.id);
      } else {
        if (onlyUnconverted && t.nativeAmount != t.amount) {
          continue; // 已折算过，不动。
        }
        var na = computeNativeAmountDecimal(
          amount: t.amount,
          txCurrency: cc,
          ledgerBase: baseUp,
          rates: rates,
        );
        if (na == null) {
          if (onlyUnconverted) continue;
          na = t.amount;
        }
        if (t.nativeAmount == na) continue;
        await (db.update(
          db.transactions,
        )..where((x) => x.id.equals(t.id))).write(
          TransactionsCompanion(
            currencyCode: shouldBackfillCurrency
                ? d.Value(cc)
                : const d.Value.absent(),
            nativeAmount: d.Value(na),
            updatedAt: d.Value(now),
          ),
        );
        // AA 指定分摊：本位币切换后同步换算分账金额，保持服务端
        // sum(splits)==native_amount 契约成立，否则推送会被整体拒绝。
        await _scaleAaSplitsForRecalc(t, newNative: na);
        changedIds.add(t.id);
      }
    }
    if (changedIds.isNotEmpty) {
      if (recordChanges) {
        // 变更登记与数据更新同一事务：登记失败整体回滚。
        // 现有实现只对 storageMode == 'cloud' 的账本实际写入。
        await _transactions.recordBatchTxChanges(changedIds);
      }
      logger.info(
        'LocalRepository',
        '多币种重算完成 ledger=$ledgerId base=$baseUp onlyUnconverted=$onlyUnconverted 改动 ${changedIds.length} 笔',
      );
    }
    return changedIds.length;
  }

  /// AA 指定分摊（aaMode=2 且有分摊行）随本位币切换同步换算。
  ///
  /// 按「新 native / 旧 native」比例缩放每行金额，四舍五入后的尾差归支出人
  /// （不在分摊列表时归最后一位参与人），保证换算后
  /// sum(splits) == 新 nativeAmount 精确成立。
  ///
  Future<void> _scaleAaSplitsForRecalc(
    TransactionSnapshot t, {
    required String newNative,
  }) async {
    final rows = await _transactions.getTransactionSplits(t.id);
    if (rows.isEmpty) return;
    final oldNativeD = Decimal.tryParse(t.nativeAmount);
    final newNativeD = Decimal.tryParse(newNative);
    if (oldNativeD == null || newNativeD == null) {
      throw const FormatException('交易金额非法');
    }
    final values = <Decimal>[];
    for (final r in rows) {
      final v = Decimal.tryParse(r.amount);
      if (v == null || v <= Decimal.zero) {
        throw const FormatException('AA 分摊金额非法');
      }
      values.add(v);
    }
    final payerIdx = t.payerMemberId == null
        ? -1
        : rows.indexWhere((r) => r.memberId == t.payerMemberId);
    final balanced = convertSplits(
      splits: values,
      fromTotal: oldNativeD,
      toTotal: newNativeD,
      remainderIndex: payerIdx,
    );
    for (var i = 0; i < rows.length; i++) {
      await (db.update(
        db.transactionSplits,
      )..where((s) => s.id.equals(rows[i].id))).write(
        TransactionSplitsCompanion(
          amount: d.Value(normalizeDecimal(balanced[i])),
        ),
      );
    }
  }

  /// 编辑写入口只接受交易原币分摊，落库前显式转为账本本位币。
  List<TransactionSplitInput>? convertSplitsForWrite(
    List<TransactionSplitInput>? splits,
    String amount,
    String nativeAmount,
    String? payerMemberId,
  ) {
    if (splits == null || splits.isEmpty) return splits;
    final amountD = Decimal.tryParse(amount);
    final nativeD = Decimal.tryParse(nativeAmount);
    if (amountD == null || nativeD == null) {
      throw const FormatException('交易金额非法');
    }
    final values = <Decimal>[];
    for (final s in splits) {
      final v = Decimal.tryParse(s.amount);
      if (v == null || v <= Decimal.zero) {
        throw const FormatException('AA 分摊金额非法');
      }
      values.add(v);
    }
    final payerIdx = payerMemberId == null
        ? -1
        : splits.indexWhere((s) => s.memberId == payerMemberId);
    final normalized = convertSplits(
      splits: values,
      fromTotal: amountD,
      toTotal: nativeD,
      remainderIndex: payerIdx,
    );
    return [
      for (var i = 0; i < splits.length; i++)
        TransactionSplitInput(
          memberId: splits[i].memberId,
          amount: normalizeDecimal(normalized[i]),
        ),
    ];
  }

  /// 移动交易时以目标账本的本位币重新计算快照。
  Future<void> moveTransaction({
    required String id,
    required String ledgerId,
  }) async {
    final tx = await _transactions.getTransactionById(id);
    if (tx == null) {
      throw StateError('交易不存在，无法移动: $id');
    }
    // 目标账本必须存在且带本位币，否则按 CNY 猜测基准会写错折算快照。
    final base = await _rates.ledgerBaseCurrency(ledgerId);
    final cc = tx.currencyCode.isEmpty ? base : tx.currencyCode.toUpperCase();
    String na;
    if (cc == base) {
      na = tx.amount;
    } else {
      final rates = await _effectiveRatesFor(base);
      na =
          computeNativeAmountDecimal(
            amount: tx.amount,
            txCurrency: cc,
            ledgerBase: base,
            rates: rates,
          ) ??
          tx.amount;
    }
    await _transactions.updateTransactionLedger(
      id: id,
      ledgerId: ledgerId,
      currencyCode: cc,
      nativeAmount: na,
    );
  }
}
