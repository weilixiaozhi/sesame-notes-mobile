import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet.dart';

/// 打开全高记账弹层，分类独立滚动，备注与自定义计算键盘固定在底部。
/// 备注系统键盘展开时输入区整体避让，金额键盘与所有草稿保持挂载。
/// 当前账本复用首页分类订阅，记录编辑按所属账本准备本机数据后再呈现完整首帧。
///
/// 传入 [editingTransactionId] 即为编辑模式,会按初始值回显。
///
/// AA 分摊初值(initialAaMode/initialAaParticipants/initialAaSplits)仅编辑
/// 模式回填,新建交易传 null 即默认人均分摊 / 全部成员。
/// 支出人(initialPaidByUserId)仅编辑模式回填:编辑器本身不提供支出人编辑,
/// 该值仅作分摊编辑页(AaEditPage)的支出人回显初值;新建传 null,由落库层
/// 回填操作者(默认支出人 = 创建人)。
Future<void> showTransactionEditorSheet(
  BuildContext context, {
  String? analyticsSourcePageId,
  ProductAnalyticsContext? analyticsContext,
  String? editingTransactionId,
  String? ledgerId,
  String? initialCategoryId,
  String? initialAmount,
  DateTime? initialDate,
  String? initialNote,
  String? initialCurrencyCode,
  String? initialNativeAmount,
  int? initialAaMode,
  List<String>? initialAaParticipants,
  Map<String, String>? initialAaSplits,
  String? initialPaidByUserId,
}) async {
  try {
    final l10n = AppLocalizations.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final entryContext =
        analyticsContext ??
        container.read(productAnalyticsControllerProvider).beginFlow();
    container
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId:
              analyticsSourcePageId ??
              productAnalyticsEntryPage(
                context,
                container.read,
                fallbackPageId: 'accounting',
              ),
          action: editingTransactionId == null
              ? ProductAction.accountingTransactionCreateClick
              : ProductAction.accountingTransactionEditClick,
          context: entryContext,
        );
    final accountId = container.read(currentAccountIdProvider);
    final generation = container.read(authIdentityGenerationProvider);
    var display = ledgerId == null
        ? container.read(currentLedgerDisplayProvider)
        : container.read(ledgerDisplayByIdProvider(ledgerId));
    // 没有任何账本时，由首条数据顺带创建默认账本承接；已有账本只是当前未选中
    // 时保持既有入口，由用户在账本页选择。
    if (editingTransactionId == null &&
        ledgerId == null &&
        display is AsyncData &&
        display.value == null) {
      final created = await container
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.bookkeeping, l10n);
      if (created == null) {
        if (context.mounted) await context.pushNamed(Routes.ledgerEdit);
        return;
      }
      // 等待新建账本进入流查询，避免刚创建就被判定为"账本信息正在加载"。
      await container.read(currentLedgerProvider.future);
      display = container.read(currentLedgerDisplayProvider);
    }
    // 普通新增必须先确定当前本，记录编辑可以在本机准备其所属账本。
    if (!context.mounted) return;
    if (ledgerId == null && (display is! AsyncData || display.value == null)) {
      showToast(
        context,
        '账本信息正在加载，请稍后重试',
        duration: const Duration(seconds: 3),
      );
      return;
    }
    final targetLedgerId = ledgerId ?? display.value!.id;
    // 预加载和弹层订阅同一个账本实例，准备到弹层退出期间保持订阅，避免空窗期销毁缓存。
    final ledgerSubscription = container.listen(
      ledgerDisplayByIdProvider(targetLedgerId),
      (_, _) {},
    );
    final categoriesProvider = categoryPickerTreeForLedgerProvider((
      ledgerId: targetLedgerId,
      type: 'expense',
    ));
    final categorySubscription = container.listen(
      categoriesProvider,
      (_, _) {},
    );
    try {
      final categories = categorySubscription.read();
      // 已预加载的新增入口同步命中缓存；冷账本只在呈现前等待本机首值，弹层不承担加载过程。
      if (categories is! AsyncData ||
          categories.isLoading ||
          categories.hasError) {
        await container.read(categoriesProvider.future);
      }
      if (!context.mounted) return;
      final target = ledgerSubscription.read();
      final sameContext =
          container.read(currentAccountIdProvider) == accountId &&
          container.read(authIdentityGenerationProvider) == generation &&
          (ledgerId != null ||
              container.read(currentLedgerIdProvider) == targetLedgerId);
      if (!sameContext ||
          target.hasError ||
          target.value == null ||
          target.value!.isArchived) {
        logger.warning('TransactionEditor', '记账准备期间账本或账号上下文失效');
        showToast(
          context,
          target.value?.isArchived == true
              ? l10n.ledgersArchivedRestoreRequired
              : l10n.txEditorContextUnavailable,
        );
        return;
      }
      await showAppSheet<void>(
        context: context,
        heightFactor: 1,
        entryShape: true,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius16),
        ),
        // 备注键盘的避让由编辑器负责，金额输入使用内置计算键盘。
        avoidKeyboard: false,
        child: productAnalyticsPresentation(
          context: context,
          read: container.read,
          pageId: 'accounting.transaction.editor',
          analyticsContext: entryContext,
          child: TransactionEditorSheet(
            analyticsContext: entryContext,
            editingTransactionId: editingTransactionId,
            ledgerId: targetLedgerId,
            initialCategoryId: initialCategoryId,
            initialAmount: initialAmount,
            initialDate: initialDate,
            initialNote: initialNote,
            initialCurrencyCode: initialCurrencyCode,
            initialNativeAmount: initialNativeAmount,
            initialAaMode: initialAaMode,
            initialAaParticipants: initialAaParticipants,
            initialAaSplits: initialAaSplits,
            initialPaidByUserId: initialPaidByUserId,
          ),
        ),
      );
    } finally {
      categorySubscription.close();
      ledgerSubscription.close();
    }
  } catch (error, stackTrace) {
    logger.error('TransactionEditor', '打开记账编辑器失败', error, stackTrace);
    if (context.mounted) {
      showToast(
        context,
        '暂时无法打开记账，请稍后重试',
        duration: const Duration(seconds: 3),
      );
    }
  }
}
