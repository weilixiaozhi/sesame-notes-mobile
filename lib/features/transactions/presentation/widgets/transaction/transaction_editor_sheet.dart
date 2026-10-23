import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'dart:math' as math;

import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/application/ledger_identity_actions.dart';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart'
    show AppEditorHeader;
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/transaction_amount_rules.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/widgets/wheel_date_picker.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/amount_input_panel.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_section.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/note_input_row.dart';
import 'package:sesame_notes/shared/widgets/collaborator_avatar.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/shared/widgets/aa_mode_toggle.dart';

/// 记账编辑弹层：顶部分类选择、整行备注及底部自定义计算键盘。
/// 金额、汇率和保存校验沿用真实业务，当前账本在打开时确定。
class TransactionEditorSheet extends ConsumerStatefulWidget {
  /// 本次入口固定的操作流，其他记录和再次打开不会复用该实例。
  final ProductAnalyticsContext? analyticsContext;

  /// 编辑模式交易 ID（UUID）；null = 新建
  final String? editingTransactionId;
  final String? ledgerId;

  /// 初始选中分类 ID（UUID；编辑模式回显 / 预选）
  final String? initialCategoryId;

  final String? initialAmount;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialCurrencyCode;
  final String? initialNativeAmount;

  /// AA 分摊方式初值(数据库列值:null/0=人均,2=指定);仅编辑模式回填。
  final int? initialAaMode;

  /// AA 参与人初值;null = 全部成员(运行时展开)。
  final List<String>? initialAaParticipants;

  /// AA 指定分摊金额初值(key=参与人标识,value=金额字符串)。
  final Map<String, String>? initialAaSplits;

  /// 支出人初值;编辑模式回填,新建为 null。
  ///
  /// 设计意图:编辑器本身不提供支出人编辑,该值仅作为分摊编辑页
  /// (AaEditPage)的支出人回显初值,保证编辑分摊时已保存的支出人不被
  /// 误判为「默认创建人」。编辑器提交时支出人字段一律不直接写入。
  final String? initialPaidByUserId;

  const TransactionEditorSheet({
    super.key,
    this.analyticsContext,

    this.editingTransactionId,
    this.ledgerId,
    this.initialCategoryId,
    this.initialAmount,
    this.initialDate,
    this.initialNote,
    this.initialCurrencyCode,
    this.initialNativeAmount,
    this.initialAaMode,
    this.initialAaParticipants,
    this.initialAaSplits,
    this.initialPaidByUserId,
  });

  @override
  ConsumerState<TransactionEditorSheet> createState() =>
      _TransactionEditorSheetState();
}

class _TransactionEditorSheetState
    extends ConsumerState<TransactionEditorSheet> {
  // 日期 / 备注
  late DateTime _date;
  final TextEditingController _noteCtrl = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  // 分类 / 备注 / 提交
  CategoryDisplay? _selectedCategory;
  bool _isSubmitting = false;
  String? _submitError;
  late final String _ledgerId;
  late final LedgerDisplayItem? _openedLedger;
  late final String? _accountId;
  late final int _identityGeneration;

  // —— AA 分摊(仅账本开启 AA 时展示并落库) ——
  late AaMode _aaMode; // 分摊方式，默认人均。
  List<String>? _aaParticipantIds; // null = 全部成员(运行时展开)
  Map<String, String>? _aaSplits; // 指定分摊金额(编辑模式回填/AaEditPage 回传)

  /// 固定编辑上下文，分类与账本只读取入口已经准备好的快照。
  @override
  void initState() {
    super.initState();
    _ledgerId = widget.ledgerId ?? ref.read(currentLedgerIdProvider);
    _openedLedger = ref.read(ledgerDisplayByIdProvider(_ledgerId)).value;
    _accountId = ref.read(currentAccountIdProvider);
    _identityGeneration = ref.read(authIdentityGenerationProvider);
    // 编辑期间保留已经解析的身份，退出编辑器后随订阅释放，避免提交时重复预读。
    ref.listenManual(ledgerIdentityProvider(_ledgerId), (_, _) {});
    _date = (widget.initialDate ?? DateTime.now()).toLocal();
    _noteCtrl.text = widget.initialNote ?? '';

    // 入口已持有本机分类树，首帧直接回填选择，金额键盘无需等待分类回调再重建。
    final tree = ref
        .read(
          categoryPickerTreeForLedgerProvider((
            ledgerId: _ledgerId,
            type: 'expense',
          )),
        )
        .asData
        ?.value;
    if (tree != null) {
      final initialId = widget.initialCategoryId;
      _selectedCategory = initialId == null
          ? tree.topLevel.firstOrNull
          : [
              ...tree.topLevel,
              for (final parent in tree.topLevel)
                ...tree.children[parent.id] ?? const <CategoryDisplay>[],
            ].where((category) => category.id == initialId).firstOrNull;
    }

    // AA 初值回填，工具栏可直接选择人均、不分摊或指定。
    _aaMode = AaMode.fromDb(widget.initialAaMode);
    _aaParticipantIds = widget.initialAaParticipants;
    _aaSplits = widget.initialAaSplits;
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // —— 日期 ——

  /// 日期键一次选择年月日和时分，取消时保留完整草稿。
  Future<void> _pickDate() async {
    if (_isSubmitting) return;
    try {
      await prepareForOverlay();
      if (!mounted || _isSubmitting) return;
      final result = await showWheelDatePicker(
        context,
        initial: _date,
        mode: WheelDatePickerMode.datetime,
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        confirmLabel: AppLocalizations.of(context).commonDone,
      );
      if (result != null && mounted) {
        setState(() => _date = result);
      }
    } catch (error, stackTrace) {
      logger.error('TransactionEditorSheet', '选择记账日期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  // —— AA 分摊 ——

  /// 点选分摊方式只更新本地状态，金额确认和落库统一在提交时处理。
  void _selectAaMode(AaMode mode) {
    if (_isSubmitting) return;
    setState(() => _aaMode = mode);
  }

  /// 组装落库字段(AA 分摊 + 支出人)。
  ///
  /// 返回 null 表示用户取消(指定分摊跳 [AaEditPage] 后放弃)——
  /// 编辑器保持开启、内容保留、不落库。
  ///
  /// 支出人语义:编辑器不提供支出人编辑,paidByUserId 仅透传分摊编辑页
  /// 的结果——人均/指定分摊时由 [AaEditPage] 决定(未手选返回 null,新建
  /// 由落库层以操作者兜底,编辑仅在原值为空时兜底);未开启 AA
  /// 或不分摊时不写入(update 语义下 null = 不更新)。
  ///
  /// 清空语义:updateTransaction 的 aa* 参数 null = 不更新,故编辑模式下
  /// 「指定 → 人均」「部分参与人 → 全部成员」需显式传空串清空旧值。
  Future<({int? aaMode, Map<String, String>? aaSplits, String? paidByUserId})?>
  _resolveAaFields(
    String total,
    String txCurrency,
    CategoryDisplay c,
    bool aaEnabled,
  ) async {
    // 未开启 AA 的账本:aa* 与 paidByUserId 恒 null。update 语义下 null =
    // 不更新,开关关闭后编辑历史交易不会清掉旧分摊/支出人数据,重开仍在。
    if (!aaEnabled) {
      return (aaMode: null, aaSplits: null, paidByUserId: null);
    }

    // 人均/指定分摊:提交时统一跳 AaEditPage 配置——人均可改参与人/支出人,
    // 指定再逐人填金额;跳页前不落库,AaEditPage 是纯选择器,pop 返回 result。
    if (_aaMode == AaMode.perPerson || _aaMode == AaMode.custom) {
      await prepareForOverlay();
      if (!mounted) return null;
      final result = await context.pushNamed<AaEditResult>(
        Routes.aaEdit,
        extra: AaEditPageArgs(
          ledgerId: _ledgerId,
          amount: total,
          currencyCode: txCurrency,
          categoryName: CategoryUtils.getDisplayName(c.name, context),
          categoryIconName: c.icon,
          date: _date,
          mode: _aaMode,
          // 支出人初值仅作分摊编辑页回显(编辑模式回填已保存值);编辑器本身
          // 不维护支出人状态,最终是否写入由 AaEditPage 的结果决定。
          paidByUserId: widget.initialPaidByUserId,
          participantIds: _aaParticipantIds,
          splits: _aaSplits,
        ),
      );
      if (result == null || !mounted) return null; // 取消:不落库
      // 回传值同步到本地状态,编辑器再次打开时现场与已确认的分摊一致。
      _aaMode = AaMode.fromDb(result.aaMode);
      _aaParticipantIds = result.aaParticipants;
      _aaSplits = result.aaSplits;
      return (
        aaMode: result.aaMode,
        // 金额以原始 UI 模型透传，落库前转换为关系表行。
        aaSplits: result.aaSplits,
        // 支出人透传分摊编辑页结果:未手选回传 null,新建由落库层回填
        // 操作者(默认支出人 = 创建人),编辑不更新保持原值。
        paidByUserId: result.paidByUserId,
      );
    }

    // 不分摊:不参与分摊算法,列入「不计入清单」;无参与人/指定金额,
    // 编辑模式显式清空旧分摊数据。支出人字段不写入(update 语义下 null =
    // 不更新),不分摊交易的支出人由创建时落库层回填操作者决定。
    return (aaMode: 1, aaSplits: null, paidByUserId: null);
  }

  // —— 提交逻辑 ——

  /// 保存仅使用打开时的本和身份，异步选择返回后再次核对，避免跨本或跨账号写入。
  LedgerDisplayItem? _validateContext({String? expectedCurrency}) {
    if (!mounted) return null;
    final fixedLedger = ref.read(ledgerDisplayByIdProvider(_ledgerId));
    final ledger = fixedLedger.value;
    final sameIdentity =
        ref.read(currentAccountIdProvider) == _accountId &&
        ref.read(authIdentityGenerationProvider) == _identityGeneration;
    if (!sameIdentity ||
        fixedLedger.hasError ||
        ledger == null ||
        ledger.isArchived ||
        (expectedCurrency != null &&
            normalizeLedgerCurrency(ledger.currency) != expectedCurrency)) {
      logger.warning('TransactionEditorSheet', '记账上下文失效，保留输入并阻止保存');
      setState(
        () => _submitError = ledger?.isArchived == true
            ? AppLocalizations.of(context).ledgersArchivedRestoreRequired
            : AppLocalizations.of(context).txEditorContextUnavailable,
      );
      return null;
    }
    return ledger;
  }

  /// 提交前复核合法正金额、固定账本与汇率，保留原有AA与保存事务。
  Future<void> _onSubmit(String amount, String txCurrency, String? rate) async {
    if (_isSubmitting) return;
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: widget.analyticsContext);
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'accounting.transaction.editor',
          action: ProductAction.accountingTransactionSaveClick,
          context: analyticsContext,
        );
    final ledger = _validateContext();
    if (ledger == null) return;
    final c = _selectedCategory;
    if (c == null) {
      // 分类目录不可用或选中项已消失时阻断提交，并保留金额草稿。
      setState(() => _submitError = AppLocalizations.of(context).categoryEmpty);
      return;
    }
    // 防重复点击
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final total = TransactionAmountRules.positiveAmount(amount);
      if (total == null) {
        setState(
          () => _submitError = AppLocalizations.of(context).txAmountInvalid,
        );
        return;
      }
      // 落库维持两位金额字符串，业务计算全程不经过 double。
      final amountStr = roundHalfEven(total, scale: 2).toStringAsFixed(2);

      // 折本位币快照(Decimal 字符串)。外币且汇率无效 → 阻断。
      final ledgerBase = normalizeLedgerCurrency(ledger.currency);
      String? nativeAmount;
      if (txCurrency == ledgerBase) {
        nativeAmount = amountStr;
      } else {
        final converted = rate == null
            ? null
            : multiplyDecimalStrings(amountStr, rate, scale: 2);
        if (converted == null) {
          // 错误与保存区一起可见，分类滚动位置不影响发现缺失汇率。
          setState(
            () => _submitError = AppLocalizations.of(context).txRateMissingHint,
          );
          return;
        }
        nativeAmount = Decimal.parse(converted).toStringAsFixed(2);
      }

      // AA 分流:指定分摊先跳 AaEditPage 取 result 后一次性落库;
      // 取消则中止提交,编辑器保持开启、内容保留。
      final aa = await _resolveAaFields(
        amountStr,
        txCurrency,
        c,
        ledger.aaEnabled,
      );
      if (aa == null) return;
      if (_validateContext(expectedCurrency: ledgerBase) == null) return;

      HapticFeedback.lightImpact().catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        logger.error(
          'TransactionEditorSheet',
          '保存触觉反馈失败',
          safeErrorSummary(error),
          stackTrace,
        );
      });

      final actions = ref.read(transactionActionsProvider);
      // 指定分摊整批写入关系表;参与人标识即成员 id。
      final aaSplitsInput = aaEditModelToSplitInputs(
        aaMode: aa.aaMode,
        splits: aa.aaSplits,
      );
      // 作者随交易同一事务落定；回填会让云端账本产生第二条同步 mutation。
      final operatorMemberId = await authorMemberIdForLedger(
        ref.read(applicationReaderProvider),
        _ledgerId,
      );
      if (_validateContext(expectedCurrency: ledgerBase) == null) return;

      String transactionId;
      if (widget.editingTransactionId != null) {
        transactionId = widget.editingTransactionId!;
        // 分类名、金额与发生时间构成本地历史快照，与交易一次提交。
        final summary =
            '${c.name} · $amountStr · '
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-'
            '${_date.day.toString().padLeft(2, '0')} '
            '${_date.hour.toString().padLeft(2, '0')}:'
            '${_date.minute.toString().padLeft(2, '0')}';
        await actions.edit(
          id: widget.editingTransactionId!,
          type: 'expense',
          amount: amountStr,
          categoryId: c.id,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          happenedAt: _date,
          currencyCode: txCurrency,
          nativeAmount: nativeAmount,
          payerMemberId: aa.paidByUserId,
          aaMode: aa.aaMode,
          splits: aaSplitsInput,
          operatorMemberId: operatorMemberId,
          historySummary: summary,
        );
        // 主动失效编辑历史缓存：若详情 sheet 仍在 widget tree 上，
        // 下次读取会重查，立即看到刚写入的历史行。
        if (mounted) ref.invalidate(recordEditHistoryProvider(transactionId));
      } else {
        // 创建人 + 编辑人（同一个成员）随交易落库；
        // payerMemberId 为空时以操作者兜底,已显式写入的值(指定分摊)不覆盖。
        transactionId = await actions.add(
          ledgerId: _ledgerId,
          type: 'expense',
          amount: amountStr,
          categoryId: c.id,
          happenedAt: _date,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          currencyCode: txCurrency,
          nativeAmount: nativeAmount,
          payerMemberId: aa.paidByUserId,
          aaMode: aa.aaMode,
          splits: aaSplitsInput,
          operatorMemberId: operatorMemberId,
        );
      }

      // 本地事务已经完成，创建与编辑分别记录，正文和金额不进入统计。
      if (mounted) {
        ref
            .read(productAnalyticsControllerProvider)
            .trackAction(
              pageId: 'accounting.transaction.editor',
              action: widget.editingTransactionId == null
                  ? ProductAction.accountingTransactionCreated
                  : ProductAction.accountingTransactionUpdated,
              context: analyticsContext,
            );
      }
      // 提交成功后关闭编辑器，AA 页与编辑弹层共用下滑退场的方向和时长。
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      // 提交失败只更新保存区的安全提示，金额、分类、日期与备注均保留。
      logger.error('TransactionEditorSheet', '提交交易失败', e, st);
      if (mounted) {
        setState(
          () =>
              _submitError = AppLocalizations.of(context).commonOperationFailed,
        );
      }
    } finally {
      // 无论成功 / 失败 / 取消都必须复位，防止提交状态永久卡死、后续无法再次提交。
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 选中父分类或子分类后更新提交使用的分类。
  void _onCategorySelected(CategoryDisplay c) {
    if (_isSubmitting || identical(_selectedCategory, c)) return;
    setState(() => _selectedCategory = c);
  }

  /// 分类删除或账本目录失效时解除选择，保留其他输入并阻止保存。
  void _onCategoryUnavailable() {
    if (_selectedCategory == null) return;
    setState(() => _selectedCategory = null);
  }

  /// 更新备注并把光标移动到末尾。
  void _onNotePicked(String note) {
    if (_isSubmitting) return;
    setState(() {
      _noteCtrl.text = note;
      _noteCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: note.length),
      );
    });
  }

  /// 固定账本和身份只驱动业务状态，备注键盘的逐帧避让由独立布局外壳处理。
  @override
  Widget build(BuildContext context) {
    final fixedLedger = ref.watch(ledgerDisplayByIdProvider(_ledgerId));
    final ledger = fixedLedger.value ?? _openedLedger;
    final identityMatches =
        ref.watch(currentAccountIdProvider) == _accountId &&
        ref.watch(authIdentityGenerationProvider) == _identityGeneration;
    final contextReady =
        identityMatches &&
        fixedLedger.hasValue &&
        fixedLedger.value != null &&
        !fixedLedger.hasError &&
        fixedLedger.value?.isArchived != true;
    final contextError =
        !identityMatches ||
            fixedLedger.hasError ||
            (fixedLedger.hasValue && fixedLedger.value == null)
        ? AppLocalizations.of(context).txEditorContextUnavailable
        : fixedLedger.value?.isArchived == true
        ? AppLocalizations.of(context).ledgersArchivedRestoreRequired
        : null;
    return _TransactionEditorLayout(
      header: _buildHeader(context, ledger?.aaEnabled ?? false),
      categories: AbsorbPointer(
        absorbing: _isSubmitting,
        child: CategoryGridSection(
          ledgerId: _ledgerId,
          initialSelectedId: widget.initialCategoryId,
          onCategorySelected: _onCategorySelected,
          onSelectionUnavailable: _onCategoryUnavailable,
        ),
      ),
      note: NoteInputRow(
        noteController: _noteCtrl,
        noteFocusNode: _noteFocusNode,
        onNotePicked: _onNotePicked,
        readOnly: _isSubmitting,
      ),
      amount: AmountInputPanel(
        ledgerId: _ledgerId,
        baseCurrency: normalizeLedgerCurrency(ledger?.currency),
        initialAmount: widget.initialAmount,
        initialCurrencyCode: widget.initialCurrencyCode,
        initialNativeAmount: widget.initialNativeAmount,
        date: _date,
        onPickDate: _pickDate,
        categorySelected: _selectedCategory != null && contextReady,
        isSubmitting: _isSubmitting,
        onSubmit: _onSubmit,
        errorMessage: _submitError ?? contextError,
      ),
    );
  }

  /// 返回、标题、分摊方式和作者共用一行，提交入口由底部完成键提供。
  Widget _buildHeader(BuildContext context, bool aaEnabled) => AppEditorHeader(
    title: AppLocalizations.of(context).txAddEntryTitle,
    onBack: () {
      try {
        if (_noteFocusNode.hasFocus) {
          _noteFocusNode.unfocus();
        } else if (!_isSubmitting && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (error, stackTrace) {
        logger.error('TransactionEditorSheet', '退出记账编辑器失败', error, stackTrace);
        if (mounted) {
          showToast(
            context,
            AppLocalizations.of(context).commonOperationFailed,
          );
        }
      }
    },
    trailing: !aaEnabled && widget.editingTransactionId == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (aaEnabled)
                Flexible(
                  child: AaModeToggle(
                    mode: _aaMode,
                    onChanged: _selectAaMode,
                    enabled: !_isSubmitting,
                    toggleKey: const ValueKey('editor_aa_mode_toggle'),
                  ),
                ),
              if (widget.editingTransactionId != null) ...[
                const SizedBox(width: AppDimens.p8),
                _TxAuthorAvatars(
                  editingTransactionId: widget.editingTransactionId!,
                ),
              ],
            ],
          ),
  );
}

/// 分类独立滚动，底部输入保持固定；短屏和备注键盘只调整约束，不替换业务子树。
class _TransactionEditorLayout extends StatelessWidget {
  /// 所有输入资源由父编辑器和金额面板持有，布局变化不重新创建草稿。
  const _TransactionEditorLayout({
    required this.header,
    required this.categories,
    required this.note,
    required this.amount,
  });

  final Widget header, categories, note, amount;

  /// 系统返回优先收起备注键盘，横屏紧凑时底部输入区可滚动到全部按键。
  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final keyboardOpen = keyboard > 0;
    final keypadTarget = (size.height * 0.40).clamp(
      AppDimens.transactionKeypadMinHeight,
      AppDimens.transactionKeypadMaxHeight,
    );
    // 备注与其余五行按键保持原始比例；紧凑约束通过滚动消化，不压缩文字和触控区域。
    final rowHeight =
        (keypadTarget -
            AppDimens.p8 -
            AppDimens.p40 -
            5 * KeypadLayout.rowGap +
            AppDimens.p5) /
        6;
    final noteStyle = AppTextTokens.input(context);
    final noteTextHeight =
        MediaQuery.textScalerOf(
          context,
        ).scale(noteStyle.fontSize ?? AppDimens.p16) *
        (noteStyle.height ?? 1.4);
    final noteHeight = math.max(
      rowHeight - AppDimens.p5,
      noteTextHeight + 2 * AppDimens.p5,
    );
    final amountHeight = 5 * rowHeight + 4 * KeypadLayout.rowGap;
    return PopScope(
      canPop: !keyboardOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && keyboardOpen) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardOpen ? 0 : safeBottom),
          child: Column(
            children: [
              const SheetGrabHandle(),
              header,
              AppTokens.cardDivider(
                context,
                indent: 0,
                verticalGap: 0,
                height: 1,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 给分类保留一行可见空间，备注键盘拉起时仍能切换分类。
                    final categoryMinimum = math.min(
                      AppDimens.categoryPickerRowMinHeight,
                      constraints.maxHeight / 3,
                    );
                    final keypadHeight = math.min(
                      keypadTarget,
                      math.max(0.0, constraints.maxHeight - categoryMinimum),
                    );
                    return Column(
                      children: [
                        Expanded(child: categories),
                        AppTokens.cardDivider(
                          context,
                          indent: 0,
                          verticalGap: 0,
                          height: 1,
                        ),
                        SizedBox(
                          height: math.max(0.0, keypadHeight - 1),
                          child: ColoredBox(
                            color: AppTokens.keypadBackground(context),
                            child: SingleChildScrollView(
                              key: const ValueKey(
                                'transaction_keyboard_scroll',
                              ),
                              primary: false,
                              padding: const EdgeInsets.fromLTRB(
                                AppDimens.p8,
                                AppDimens.p8,
                                AppDimens.p8,
                                AppDimens.p40,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: noteHeight, child: note),
                                  const SizedBox(height: KeypadLayout.rowGap),
                                  SizedBox(height: amountHeight, child: amount),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =============================================================================
// 编辑模式下的共享账本作者头像展示
// =============================================================================

/// 从交易ID中解析出作者信息所需的上下文:
/// - 创建者userId / 最后编辑者userId
/// - 所属共享账本的 id(UUID,用于查成员列表)
class _TxAuthorContext {
  _TxAuthorContext({
    required this.creatorUserId,
    required this.lastEditedByUserId,
    required this.ledgerId,
  });
  final String? creatorUserId;
  final String? lastEditedByUserId;
  final String ledgerId;
}

/// 从本地数据库获取交易作者上下文。
/// 仅当交易属于共享账本时返回非null;非共享账本直接返回null不展示头像。
final _txAuthorContextProvider = FutureProvider.autoDispose
    .family<_TxAuthorContext?, String>((ref, txId) async {
      final tx = await ref.read(transactionActionsProvider).getById(txId);
      if (tx == null) return null;
      final ledger = await ref.read(ledgerActionsProvider).getById(tx.ledgerId);
      // 只有共享账本(成员数 > 1)才需要展示协作者头像
      if (ledger == null || ledger.memberCount <= 1) return null;
      return _TxAuthorContext(
        creatorUserId: tx.createdByMemberId,
        lastEditedByUserId: tx.lastEditedByMemberId,
        ledgerId: ledger.id,
      );
    });

/// 编辑模式下的共享账本作者头像组件。
///
/// UX规则:
///   - 创建人 == 编辑人 == 自己 → 不展示(看自己头像无意义)
///   - 创建人 == 编辑人 != 自己 → 展示1个头像 + Tooltip "X 创建并编辑"
///   - 创建人 != 编辑人 → 展示2个头像(左侧偏移3px叠放) + 分别Tooltip
class _TxAuthorAvatars extends ConsumerWidget {
  const _TxAuthorAvatars({required this.editingTransactionId});
  final String editingTransactionId;

  /// 作者身份与交易所属账本绑定，后台切换当前本不会改变“自己”的判断。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(
      _txAuthorContextProvider(editingTransactionId),
    );

    return contextAsync.when(
      // 加载中 / 出错 / 非共享账本 → 不展示
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (ctx) {
        if (ctx == null) return const SizedBox.shrink();
        // 从全量成员展示映射(含 LEFT/REMOVED)中查找创作者/编辑者信息。
        final membersAsync = ref.watch(
          ledgerMemberDisplayMapProvider(ctx.ledgerId),
        );
        return membersAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (byId) {
            final creator = ctx.creatorUserId != null
                ? byId[ctx.creatorUserId]
                : null;
            final editor = ctx.lastEditedByUserId != null
                ? byId[ctx.lastEditedByUserId]
                : null;
            // 判断当前用户(self member id)是否就是这笔交易的创建者/编辑者
            final selfMemberId =
                ref
                    .watch(ledgerDisplayByIdProvider(ctx.ledgerId))
                    .asData
                    ?.value
                    ?.selfMemberId ??
                '';
            final creatorIsSelf = ctx.creatorUserId == selfMemberId;
            final editorIsSelf = ctx.lastEditedByUserId == selfMemberId;
            final isSelf = creatorIsSelf && editorIsSelf;

            // 规则1:创建人==编辑人==自己 → 不展示
            if (isSelf) return const SizedBox.shrink();

            // 复用共享头像组：创建人==编辑人!=自己 → 1个头像；
            // 创建人!=编辑人 → 2个重叠头像。两者规则与首页列表一致，
            // 且图片加载失败时回退首字母。
            return CollaboratorAvatarGroup(
              creator: creator,
              editor: editor,
              creatorUserId: ctx.creatorUserId,
              editorUserId: ctx.lastEditedByUserId,
              radius: 11,
            );
          },
        );
      },
    );
  }
}
