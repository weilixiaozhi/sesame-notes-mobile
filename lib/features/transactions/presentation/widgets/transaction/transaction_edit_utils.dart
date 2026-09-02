import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet_entry.dart';

/// 交易编辑辅助（打开记账编辑 BottomSheet）。
///
/// 职责：拉起编辑器 sheet，属 UI 编排，位于 widgets/ 层；utils 层只保留
/// 纯函数工具。
class TransactionEditUtils {
  /// 打开交易编辑器（编辑模式）。
  static Future<void> editTransaction(
    BuildContext context,
    WidgetRef ref,
    TransactionDisplay transaction,
    CategoryDisplay? category,
  ) async {
    // 分类 UUID 直连（本地与云端同一 id），编辑器按 UUID 反查回显"已选"。
    final String? initialCategoryId = transaction.categoryId;

    if (!context.mounted) return;

    // 全局仅支出模式,交易 type 恒为 'expense',所有交易都使用同一编辑器。
    // AA 分摊回显:指定分摊从关系表读取(人均/不分摊不落行,回显 null = 全部成员)。
    final aaModel = aaRowsToEditModel(
      await ref.read(transactionActionsProvider).getSplits(transaction.id),
    );
    if (!context.mounted) return;

    await showTransactionEditorSheet(
      context,
      initialKind: transaction.txType, // 全局仅支出模式，值固定为 'expense'
      editingTransactionId: transaction.id,
      initialCategoryId: initialCategoryId,
      initialAmount: transaction.amount,
      initialDate: transaction.happenedAt,
      initialNote: transaction.note,
      // 多币种:编辑外币交易时汇率行按隐含汇率回显
      initialCurrencyCode: transaction.currencyCode,
      initialNativeAmount: transaction.nativeAmount,
      initialAaMode: transaction.aaMode,
      initialAaParticipants: aaModel.participantIds,
      initialAaSplits: aaModel.splits,
      initialPaidByUserId: transaction.payerMemberId,
    );
  }
}
