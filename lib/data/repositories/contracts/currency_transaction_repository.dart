import 'package:sesame_notes/data/models/accounting_records.dart';

/// 币种重算需要的交易存储能力，避免服务依赖具体本地仓储。
abstract interface class CurrencyTransactionRepository {
  /// 读取未删除的交易快照。
  Future<TransactionSnapshot?> getTransactionById(String id);

  /// 按稳定顺序读取交易分摊快照。
  Future<List<TransactionSplitSnapshot>> getTransactionSplits(
    String transactionId,
  );

  /// 在当前事务中登记已修改交易的同步变更。
  Future<void> recordBatchTxChanges(Iterable<String> ids);

  /// 原子更新目标账本、币种与折算金额。
  Future<void> updateTransactionLedger({
    required String id,
    required String ledgerId,
    required String currencyCode,
    required String nativeAmount,
  });
}
