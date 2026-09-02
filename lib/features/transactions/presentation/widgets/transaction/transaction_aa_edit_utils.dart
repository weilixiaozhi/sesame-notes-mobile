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
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';

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
  /// 换算失败（脏数据/金额非法）时按原值回填，由编辑页校验层拦截。
  static Future<({List<String>? participantIds, Map<String, String>? splits})>
  _editSplitsArgs(WidgetRef ref, TransactionDisplay transaction) async {
    final rows = await ref
        .read(transactionActionsProvider)
        .getSplits(transaction.id);
    final model = aaRowsToEditModel(rows);
    final splits = model.splits;
    if (splits == null || splits.isEmpty) return model;
    final amountD = Decimal.tryParse(transaction.amount);
    final nativeD = Decimal.tryParse(transaction.nativeAmount);
    if (amountD == null || nativeD == null) return model;
    final values = <Decimal>[];
    for (final e in splits.entries) {
      final v = Decimal.tryParse(e.value);
      if (v == null) return model;
      values.add(v);
    }
    final payerIdx = transaction.payerMemberId == null
        ? -1
        : splits.keys.toList().indexOf(transaction.payerMemberId!);
    final normalized = normalizeSplitsToOriginal(
      splits: values,
      amount: amountD,
      nativeAmount: nativeD,
      remainderIndex: payerIdx,
    );
    final keys = splits.keys.toList();
    return (
      participantIds: model.participantIds,
      splits: {
        for (var i = 0; i < keys.length; i++)
          keys[i]: normalizeDecimal(normalized[i]),
      },
    );
  }

  /// 打开分摊编辑页并落库结果。取消则不落库、不弹错误。
  static Future<void> editTransactionAa(
    BuildContext context,
    WidgetRef ref,
    TransactionDisplay transaction,
    CategoryDisplay? category,
  ) async {
    final ledgerId = ref.read(currentLedgerIdProvider);
    final ledger = ref.read(currentLedgerDisplayProvider).asData?.value;
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
    if (!context.mounted) return;

    // 落库:仅更新 AA 字段,其他字段(amount/category/note 等)保持原值。
    // updateTransaction 的 aa* 参数 null = 不更新,故切换「指定 → 不分摊」时
    // 需显式传空串清空旧 aaParticipants/aaSplits。
    // 支出人(paidByUserId)属全局交易语义(非 AA 专属):未手选回传 null 不更新
    // 保持原值,手选后恒写手选值,不受分摊方式切换影响。
    final actions = ref.read(transactionActionsProvider);
    // 成员列表与操作者成员 id（self member）并行解析；操作者必须在写库前
    // 拿到，作者字段随交易同一事务落定，不再写完再回填。
    final membersFuture = actions.getMembers(ledgerId);
    final operatorMemberId = await authorMemberIdForLedger(ref, ledgerId);
    final newVersion = await actions.update(
      id: transaction.id,
      type: transaction.txType,
      amount: transaction.amount,
      // 分类 UUID 直连（本地与云端同一 id），无需 synthetic override。
      categoryId: transaction.categoryId,
      note: transaction.note,
      happenedAt: transaction.happenedAt,
      excludeFromStats: transaction.excludeFromStats,
      currencyCode: transaction.currencyCode,
      nativeAmount: transaction.nativeAmount,
      payerMemberId: result.paidByUserId,
      aaMode: result.aaMode,
      // 指定分摊整批写入关系表（参与人标识即成员 id）。
      splits: aaEditModelToSplitInputs(
        aaMode: result.aaMode,
        splits: result.aaSplits,
        virtualUserIds: (await membersFuture)
            .where((m) => m.memberType == 'PLACEHOLDER')
            .map((v) => v.id)
            .toSet(),
      ),
      operatorMemberId: operatorMemberId,
    );

    // 编辑历史闭环:追加一条同版本号快照,详情页编辑记录区块可见。
    // 跨异步间隙后使用 l10n,需取 context.mounted 兜底;这里已通过前面校验,
    // 但严格满足 lint:在 await 后用 l10n 提取前重新读 mounted。
    final l10n = context.mounted ? AppLocalizations.of(context) : null;
    final summary =
        '${category?.name ?? l10n?.homeDetailCategory ?? ''}'
        ' · ${double.parse(transaction.amount).toStringAsFixed(2)} · '
        '${transaction.happenedAt.year}-${transaction.happenedAt.month.toString().padLeft(2, '0')}-'
        '${transaction.happenedAt.day.toString().padLeft(2, '0')} '
        '${transaction.happenedAt.hour.toString().padLeft(2, '0')}:'
        '${transaction.happenedAt.minute.toString().padLeft(2, '0')}';
    await actions.appendHistory(
      recordId: transaction.id,
      version: newVersion,
      operatorMemberId: operatorMemberId,
      summary: summary,
    );
    ref.invalidate(recordEditHistoryProvider(transaction.id));

    // 统计依赖数据库监听自动更新，此处只失效显式的笔数缓存。
    ref.invalidate(countsForLedgerProvider(ledgerId));

    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).commonSave);
    }
  }
}
