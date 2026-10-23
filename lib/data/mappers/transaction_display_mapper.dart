import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';

/// 将数据库交易行转换为页面只读展示模型。
extension TransactionDisplayMapper on TransactionSnapshot {
  TransactionDisplay toDisplay() => TransactionDisplay(
    id: id,
    ledgerId: ledgerId,
    txType: txType,
    amount: amount,
    happenedAt: happenedAt,
    note: note,
    categoryId: categoryId,
    currencyCode: currencyCode,
    nativeAmount: nativeAmount,
    recurringId: recurringId,
    createdByMemberId: createdByMemberId,
    lastEditedByMemberId: lastEditedByMemberId,
    payerMemberId: payerMemberId,
    aaMode: aaMode,
    version: version,
    serverRevision: serverRevision,
    lastEditedAt: lastEditedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
