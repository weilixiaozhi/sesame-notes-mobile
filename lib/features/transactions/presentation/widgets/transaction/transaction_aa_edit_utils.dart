import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/application/ledger_identity_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';

/// 从详情页直接编辑分摊的工具(绕过编辑记账器)。
///
/// 设计意图:开启分摊的账本,详情页常驻「编辑分摊」按钮,
/// 用户无需进入编辑记账器即可调整分摊方式/参与人/金额。
/// 流程:
/// 1. 用交易当前分摊态构造 [AaEditPageArgs],push [Routes.aaEdit];
/// 2. 拿到 [AaEditResult] 后,仅更新 AA 相关字段(amount 等保持原值);
/// 3. 触发同步、失效相关缓存。
///
/// 不分摊的交易也允许进入,默认选中不分摊,在 [AaEditPage] 内可切到其他方式。
class TransactionAaEditUtils {
  /// 构造分摊编辑参数：读取关系表并换算为原币口径。
  ///
  /// 非法持久值阻止编辑，由外层错误提示保留现场。
  static Future<({List<String>? participantIds, Map<String, String>? splits})>
  _editSplitsArgs(WidgetRef ref, TransactionDisplay transaction) async {
    final rows = await ref
        .read(transactionActionsProvider)
        .getSplits(transaction.id);
    final model = aaRowsToEditModel(rows);
    return (
      participantIds: model.participantIds,
      splits: model.splits == null
          ? null
          : originalSplitAmounts(
              model.splits!,
              amount: transaction.amount,
              nativeAmount: transaction.nativeAmount,
              payerMemberId: transaction.payerMemberId,
            ),
    );
  }

  /// 打开分摊编辑页并落库结果。取消则不落库、不弹错误。
  static Future<void> editTransactionAa(
    BuildContext context,
    WidgetRef ref,
    TransactionDisplay transaction,
    CategoryDisplay? category,
  ) async {
    try {
      final ledgerId = transaction.ledgerId;
      final account = ref.read(currentAccountIdProvider);
      final generation = ref.read(authIdentityGenerationProvider);

      /// 编辑全程绑定打开时的账号与交易所属本，首页切本不会改变分摊名册。
      void requireCurrent() {
        if (!context.mounted ||
            ref.read(currentAccountIdProvider) != account ||
            ref.read(authIdentityGenerationProvider) != generation) {
          throw StateError('账号已变化，请重新打开交易');
        }
      }

      final ledger = await ref.read(ledgerByIdProvider(ledgerId).future);
      if (!context.mounted) return;
      requireCurrent();
      if (ledger == null) {
        logger.warning('TransactionAaEditUtils', '账本未就绪,无法编辑分摊', null);
        return;
      }

      // 分类显示名(供 AaEditPage 主体卡只读展示)。
      // 共享账本 synthetic category 名字直接用 c.name,本地账本用 displayName。
      final categoryName = category != null
          ? CategoryUtils.getDisplayName(category.name, context)
          : AppLocalizations.of(context).homeDetailCategory;

      // 当前分摊态作为初值;不分摊也允许进入(默认选中不分摊,可切换)。
      final mode = AaMode.fromDb(transaction.aaMode);

      // 指定分摊从关系表读取(人均/不分摊不落行,回显 null = 全部成员)。
      // 关系表金额为账本本位币口径(服务端契约),编辑页按原币显示与
      // 校验(合计 == amount),回填前逆换算,保证用户看到的仍是当时输入值。
      final aaModel = await _editSplitsArgs(ref, transaction);
      if (!context.mounted) return;
      requireCurrent();

      final result = await context.pushNamed<AaEditResult>(
        Routes.aaEdit,
        extra: AaEditPageArgs(
          ledgerId: ledgerId,
          amount: transaction.amount,
          currencyCode: transaction.currencyCode,
          categoryName: categoryName,
          categoryIconName: category?.icon,
          date: transaction.happenedAt,
          mode: mode,
          paidByUserId: transaction.payerMemberId,
          participantIds: aaModel.participantIds,
          splits: aaModel.splits,
        ),
      );

      if (result == null) return; // 用户取消
      requireCurrent();

      // 落库:仅更新 AA 字段,其他字段(amount/category/note 等)保持原值。
      // updateTransaction 的 aa* 参数 null = 不更新,故切换「指定 → 不分摊」时
      // 需显式传空串清空旧 aaParticipants/aaSplits。
      // 支出人(paidByUserId)属全局交易语义(非 AA 专属):未手选回传 null 不更新
      // 保持原值,手选后恒写手选值,不受分摊方式切换影响。
      final actions = ref.read(transactionActionsProvider);
      // 先解析操作者身份，再将交易及历史一次提交。
      final operatorMemberId = await authorMemberIdForLedger(
        ref.read(applicationReaderProvider),
        ledgerId,
      );
      requireCurrent();
      final l10n = context.mounted ? AppLocalizations.of(context) : null;
      final summary =
          '${category?.name ?? l10n?.homeDetailCategory ?? ''}'
          ' · ${double.parse(transaction.amount).toStringAsFixed(2)} · '
          '${transaction.happenedAt.year}-${transaction.happenedAt.month.toString().padLeft(2, '0')}-'
          '${transaction.happenedAt.day.toString().padLeft(2, '0')} '
          '${transaction.happenedAt.hour.toString().padLeft(2, '0')}:'
          '${transaction.happenedAt.minute.toString().padLeft(2, '0')}';
      await actions.edit(
        id: transaction.id,
        type: transaction.txType,
        amount: transaction.amount,
        // 分类 UUID 直连（本地与云端同一 id），无需 synthetic override。
        categoryId: transaction.categoryId,
        note: transaction.note,
        happenedAt: transaction.happenedAt,
        currencyCode: transaction.currencyCode,
        nativeAmount: transaction.nativeAmount,
        payerMemberId: result.paidByUserId,
        aaMode: result.aaMode,
        // 指定分摊整批写入关系表（参与人标识即成员 id）。
        splits: aaEditModelToSplitInputs(
          aaMode: result.aaMode,
          splits: result.aaSplits,
        ),
        operatorMemberId: operatorMemberId,
        historySummary: summary,
      );
      if (!context.mounted) return;
      ref.invalidate(recordEditHistoryProvider(transaction.id));

      // 统计依赖数据库监听自动更新，此处只失效显式的笔数缓存。
      ref.invalidate(countsForLedgerProvider(ledgerId));

      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonSave);
      }
    } catch (error, stackTrace) {
      logger.error(
        'TransactionAaEditUtils',
        '编辑分摊失败: ${transaction.id}',
        error,
        stackTrace,
      );
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonError);
      }
    }
  }
}
