import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
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
    TransactionDisplay transaction, {
    String? analyticsSourcePageId,
    ProductAnalyticsContext? analyticsContext,
  }) async {
    if (!context.mounted) return;
    // 页面与身份在读取分摊数据之前固定，异步完成时不借用后续页面或账号。
    final sourcePage =
        analyticsSourcePageId ??
        productAnalyticsEntryPage(
          context,
          ref.read,
          fallbackPageId: 'accounting',
        );
    final entryContext =
        analyticsContext ??
        ref.read(productAnalyticsControllerProvider).beginFlow();
    // 分类 UUID 直连（本地与云端同一 id），编辑器按 UUID 反查回显"已选"。
    final String? initialCategoryId = transaction.categoryId;

    // 全局仅支出模式,交易 type 恒为 'expense',所有交易都使用同一编辑器。
    // AA 分摊回显:指定分摊从关系表读取(人均/不分摊不落行,回显 null = 全部成员)。
    try {
      final aaModel = aaRowsToEditModel(
        await ref.read(transactionActionsProvider).getSplits(transaction.id),
      );
      if (!context.mounted) return;

      final originalSplits = aaModel.splits == null
          ? null
          : originalSplitAmounts(
              aaModel.splits!,
              amount: transaction.amount,
              nativeAmount: transaction.nativeAmount,
              payerMemberId: transaction.payerMemberId,
            );
      await showTransactionEditorSheet(
        context,
        analyticsSourcePageId: sourcePage,
        analyticsContext: entryContext,
        editingTransactionId: transaction.id,
        ledgerId: transaction.ledgerId,
        initialCategoryId: initialCategoryId,
        initialAmount: transaction.amount,
        initialDate: transaction.happenedAt,
        initialNote: transaction.note,
        // 多币种:编辑外币交易时汇率行按隐含汇率回显
        initialCurrencyCode: transaction.currencyCode,
        initialNativeAmount: transaction.nativeAmount,
        initialAaMode: transaction.aaMode,
        initialAaParticipants: aaModel.participantIds,
        initialAaSplits: originalSplits,
        initialPaidByUserId: transaction.payerMemberId,
      );
    } catch (error, stackTrace) {
      logger.error(
        'TransactionEdit',
        '读取交易编辑内容失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonError);
      }
    }
  }
}
