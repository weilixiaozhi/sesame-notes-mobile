import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';

import 'local_accounting_context.dart';

/// currency 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalCurrencyOperations on LocalAccountingContext {
  /// 新增交易（金额为规范化 Decimal 字符串）。
  ///
  /// 币种折算兜底：未传 currencyCode/nativeAmount 时按账本本位币补齐
  /// （外币取有效汇率折算，取不到时 native=amount 交由未折算检测捞回）。
  @override
  Future<String> addTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? categoryId,
    required DateTime happenedAt,
    String? note,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    final (cc, na) = await currencyService.resolveCurrency(
      ledgerId: ledgerId,
      amount: amount,
      currencyCode: currencyCode,
      nativeAmount: nativeAmount,
    );
    return transactionStore.addTransaction(
      ledgerId: ledgerId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      happenedAt: happenedAt,
      note: note,
      currencyCode: cc,
      nativeAmount: na,
      payerMemberId: payerMemberId,
      aaMode: aaMode,
      splits: currencyService.convertSplitsForWrite(
        splits,
        amount,
        na,
        payerMemberId,
      ),
      operatorMemberId: operatorMemberId,
    );
  }

  /// 更新交易；返回编辑后版本号（UI 写编辑历史用）。
  @override
  Future<int> updateTransaction({
    required String id,
    required String type,
    required String amount,
    String? categoryId,
    String? note,
    DateTime? happenedAt,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    final old = await transactionStore.getTransactionById(id);
    if (old == null) {
      throw StateError('交易不存在，无法更新: $id');
    }
    // 联动兜底：调用方不传两字段时，按隐含汇率缩放或沿用旧值。
    var effCurrency = currencyCode;
    var effNative = nativeAmount;
    // 两字段都缺省时，仅当交易币种就是账本本位币才带入旧币种走下方缩放：
    // 本位币交易 nativeAmount 恒等于 amount，金额变化后快照必须跟随新值，
    // 否则汇总永远停留在旧金额；外币交易则保持快照列不动——本地层不得发明
    // 调用方未请求的汇率换算（编辑器、AA 工具等真实调用方总是显式传两字段）。
    if (effCurrency == null && effNative == null) {
      final base = await ledgerBaseCurrency(old.ledgerId);
      if (old.currencyCode.toUpperCase() == base) {
        effCurrency = old.currencyCode;
      }
    }
    if (effCurrency != null && effNative == null) {
      final oldNative = old.nativeAmount;
      if (oldNative.isNotEmpty &&
          old.currencyCode.toUpperCase() == effCurrency.toUpperCase() &&
          old.amount == amount) {
        effNative = oldNative;
      } else if (oldNative.isNotEmpty && amount != old.amount) {
        // 按隐含汇率缩放：native_new = native_old × amount_new / amount_old
        final oldA = Decimal.tryParse(old.amount);
        final newA = Decimal.tryParse(amount);
        final oldN = Decimal.tryParse(oldNative);
        if (oldA != null &&
            newA != null &&
            oldN != null &&
            oldA != Decimal.zero) {
          // 隐含汇率可能是循环小数，先保留十八位中间精度再按金额规则舍入。
          effNative = normalizeDecimal(
            (oldN * newA / oldA).toDecimal(scaleOnInfinitePrecision: 18),
            scale: 10,
          );
        } else {
          effNative = amount;
        }
      } else {
        effNative = amount;
      }
    } else if (effCurrency == null && effNative != null) {
      effCurrency = old.currencyCode;
    }
    return transactionStore.updateTransaction(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      note: note,
      happenedAt: happenedAt,
      currencyCode: effCurrency,
      nativeAmount: effNative,
      payerMemberId: payerMemberId,
      aaMode: aaMode,
      splits: currencyService.convertSplitsForWrite(
        splits,
        amount,
        effNative ?? old.nativeAmount,
        payerMemberId,
      ),
      operatorMemberId: operatorMemberId,
    );
  }

  /// 账本本位币切换后重算所有交易快照。
  ///
  /// [recordChanges] 默认 true；恢复导入传 false（数据回填不反向推云）。
  @override
  Future<int> recalcNativeAmountsForLedger(
    String ledgerId,
    String newBase, {
    required String previousBase,
    bool recordChanges = true,
  }) => currencyService.recalculate(
    ledgerId,
    newBase,
    onlyUnconverted: false,
    previousBase: previousBase,
    recordChanges: recordChanges,
  );

  /// 提供 recomputeForeignTxForLedger 对应的持久化能力。
  @override
  Future<int> recomputeForeignTxForLedger(String ledgerId) async {
    final base = await ledgerBaseCurrency(ledgerId);
    return currencyService.recalculate(ledgerId, base, onlyUnconverted: true);
  }

  /// 跨账本移动沿用统一的币种转换与分摊保存规则。
  Future<void> updateTransactionLedger({
    required String id,
    required String ledgerId,
  }) => guard(
    'updateTransactionLedger transaction=$id ledger=$ledgerId',
    () => currencyService.moveTransaction(id: id, ledgerId: ledgerId),
  );

  /// 提供 upsertAutoRates 对应的持久化能力。
  @override
  Future<void> upsertAutoRates({
    required String base,
    required String rateDate,
    required Map<String, String> rates,
    required String source,
    required DateTime fetchedAt,
  }) => exchangeRateStore.upsertAutoRates(
    base: base,
    rateDate: rateDate,
    rates: rates,
    source: source,
    fetchedAt: fetchedAt,
  );

  /// 提供 getLatestAutoRates 对应的持久化能力。
  @override
  Future<List<ExchangeRate>> getLatestAutoRates(String base) =>
      exchangeRateStore.getLatestAutoRates(base);

  /// 提供 getLastFetchedAt 对应的持久化能力。
  @override
  Future<DateTime?> getLastFetchedAt(String base) =>
      exchangeRateStore.getLastFetchedAt(base);

  /// 提供 getOverrides 对应的持久化能力。
  @override
  Future<List<ExchangeRateOverride>> getOverrides(String base) =>
      exchangeRateStore.getOverrides(base);

  /// 提供 setOverride 对应的持久化能力。
  @override
  Future<void> setOverride({
    required String base,
    required String quote,
    required String rate,
  }) => exchangeRateStore.setOverride(base: base, quote: quote, rate: rate);

  /// 提供 removeOverride 对应的持久化能力。
  @override
  Future<void> removeOverride({required String base, required String quote}) =>
      exchangeRateStore.removeOverride(base: base, quote: quote);
}
