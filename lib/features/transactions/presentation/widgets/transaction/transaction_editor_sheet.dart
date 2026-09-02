import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/wheel_date_picker.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/amount_input_panel.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_section.dart';
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';
import 'package:sesame_notes/shared/widgets/note_input_row.dart';
import 'package:sesame_notes/shared/widgets/collaborator_avatar.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/aa_mode_toggle.dart';

/// 记账编辑 BottomSheet（单页：分类 + 金额 + 备注 + 键盘同页）。
///
/// 布局（自上而下）：
/// 1. 拖拽条
/// 2. Header：返回按钮 + 「记一笔」标题 + 作者头像
/// 3. 分类网格区（独立滚动、无可见滚动条；固定 100px 保底）
/// 4. 键盘容器（Expanded 撑满剩余空间）：备注行 + 金额栏行 + 4×4 键盘
///
/// 计算器状态机：waiting / operating / calculated
/// - waiting：初始或清空后，金额区显示实际金额（空值显示 0），主按钮显示 Enter
/// - operating：用户点了运算符，金额区显示「累加值 运算符 当前输入 = 预览」，主按钮显示 =
/// - calculated：用户点了 = 后，金额区仅显示最终结果，主按钮显示 Enter
///
/// 系统键盘拉起时（备注聚焦）：整页（分类区 + 自定义键盘）保持可见并整体上移，
/// 仅把备注行 / 币种行顶到系统键盘之上，不收起分类区。
/// 点击非备注区域优先收起系统键盘；返回键仅收起键盘、保留记账页。
class TransactionEditorSheet extends ConsumerStatefulWidget {
  /// 值固定为 'expense'（全局仅支出模式）
  final String initialKind;

  /// 编辑模式交易 ID（UUID）；null = 新建
  final String? editingTransactionId;

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
    required this.initialKind,
    this.editingTransactionId,
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
  late final String _ledgerId;

  // —— AA 分摊(仅账本开启 AA 时展示并落库) ——
  late AaMode _aaMode; // 分摊方式;默认人均(不分摊不在编辑器提供入口)
  List<String>? _aaParticipantIds; // null = 全部成员(运行时展开)
  Map<String, String>? _aaSplits; // 指定分摊金额(编辑模式回填/AaEditPage 回传)

  @override
  void initState() {
    super.initState();
    _ledgerId = ref.read(currentLedgerIdProvider);
    _date = widget.initialDate ?? DateTime.now();
    _noteCtrl.text = widget.initialNote ?? '';

    // AA 初值回填:编辑器支持人均/不分摊/指定三态循环切换,
    // 不分摊交易原样回显为「不分摊」。
    _aaMode = AaMode.fromDb(widget.initialAaMode);
    _aaParticipantIds = widget.initialAaParticipants;
    _aaSplits = widget.initialAaSplits;

    _noteFocusNode.addListener(() {
      // 备注聚焦变化时触发重建，让分类区/键盘区在系统键盘拉起时正确让位
      // （MediaQuery.viewInsets.bottom 也会触发重建，此处保留以确保即时响应）
      setState(() {});
    });

    // 解析初始分类（编辑模式 / 预选）：分类 UUID 直连主表反查。
    _resolveInitialCategory();
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  /// 解析初始分类 ID（UUID）对应的 Category，设置 _selectedCategory
  /// 以便提交时直接拿到分类。
  Future<void> _resolveInitialCategory() async {
    if (widget.initialCategoryId == null) return;
    final id = widget.initialCategoryId!;
    // 分类 UUID 直连（本地与云端同一 id），无需 synthetic override。
    final c = await ref.read(categoryActionsProvider).getById(id);
    if (c != null && mounted) {
      setState(() => _selectedCategory = c);
    }
  }

  // —— 日期 ——

  /// 5 列滚轮同屏（年/月/日/时/分），始终显示完整时间。
  void _pickDate() async {
    // 收起键盘并等待动画结束，避免选择日期后键盘重新弹出（统一走 OverlayKeyboardGuard）。
    await prepareForOverlay();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final res = await showWheelDatePicker(
      context,
      initial: _date,
      mode: WheelDatePickerMode.datetime,
      // 组件默认边界 2000~2100，已可选任意未来时间，无需再显式传 maxDate。
      useRootNavigator: false,
      barrierColor: Colors.transparent,
      title: l10n.txSelectDateTimeTitle,
      subtitle: l10n.txSelectDateTimeHint,
      confirmLabel: l10n.commonFinish,
    );
    if (res != null) setState(() => _date = res);
  }

  // —— AA 分摊 ——

  /// 单点循环切换分摊方式:人均 → 不分摊 → 指定 → 人均。
  ///
  /// 设计意图:人均分摊是最高频场景,作为循环起点;不分摊次之;
  /// 指定分摊最重(需逐人填金额),故放最后。切换仅改本地状态,
  /// 落库(含指定分摊跳 [AaEditPage] 确认金额)统一在提交时处理。
  void _cycleAaMode() {
    setState(() {
      _aaMode = switch (_aaMode) {
        AaMode.perPerson => AaMode.noSplit,
        AaMode.noSplit => AaMode.custom,
        AaMode.custom => AaMode.perPerson,
      };
    });
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
  Future<
    ({
      int? aaMode,
      List<String>? aaParticipants,
      Map<String, String>? aaSplits,
      String? paidByUserId,
    })?
  >
  _resolveAaFields(String total, String txCurrency, CategoryDisplay c) async {
    final aaEnabled =
        ref.read(currentLedgerDisplayProvider).value?.aaEnabled ?? false;
    // 未开启 AA 的账本:aa* 与 paidByUserId 恒 null。update 语义下 null =
    // 不更新,开关关闭后编辑历史交易不会清掉旧分摊/支出人数据,重开仍在。
    if (!aaEnabled) {
      return (
        aaMode: null,
        aaParticipants: null,
        aaSplits: null,
        paidByUserId: null,
      );
    }

    // 人均/指定分摊:提交时统一跳 AaEditPage 配置——人均可改参与人/支出人,
    // 指定再逐人填金额;跳页前不落库,AaEditPage 是纯选择器,pop 返回 result。
    if (_aaMode == AaMode.perPerson || _aaMode == AaMode.custom) {
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
      _aaMode = result.aaMode == 2 ? AaMode.custom : AaMode.perPerson;
      _aaParticipantIds = result.aaParticipants;
      _aaSplits = result.aaSplits;
      return (
        aaMode: result.aaMode,
        // 参与人与金额以原始 UI 模型透传;落库前由 aaEditModelToSplitInputs
        // 转换为关系表行(整批替换,非指定模式即清空)。
        aaParticipants: result.aaParticipants,
        aaSplits: result.aaSplits,
        // 支出人透传分摊编辑页结果:未手选回传 null,新建由落库层回填
        // 操作者(默认支出人 = 创建人),编辑不更新保持原值。
        paidByUserId: result.paidByUserId,
      );
    }

    // 不分摊:不参与分摊算法,列入「不计入清单」;无参与人/指定金额,
    // 编辑模式显式清空旧分摊数据。支出人字段不写入(update 语义下 null =
    // 不更新),不分摊交易的支出人由创建时落库层回填操作者决定。
    return (
      aaMode: 1,
      aaParticipants: null,
      aaSplits: null,
      paidByUserId: null,
    );
  }

  // —— 提交逻辑 ——

  /// 提交回调：金额总额（可能含未按 = 的运算）、交易币种、本笔汇率（可为 null）。
  Future<void> _onSubmit(String amount, String txCurrency, String? rate) async {
    final c = _selectedCategory;
    if (c == null) {
      // 未选分类：提示并阻断（分类由用户主动选择，不预先选定）
      showToast(context, AppLocalizations.of(context).categoryEmpty);
      return;
    }
    // 防重复点击
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final total = parseDecimal(amount)?.abs();
      if (total == null) {
        showToast(context, AppLocalizations.of(context).commonError);
        return;
      }
      // 落库维持两位金额字符串，业务计算全程不经过 double。
      final amountStr = roundHalfEven(total, scale: 2).toStringAsFixed(2);

      // 折本位币快照(Decimal 字符串)。外币且汇率无效 → 阻断。
      final ledgerBase = ref.read(currentLedgerCurrencyProvider);
      String? nativeAmount;
      if (txCurrency == ledgerBase) {
        nativeAmount = amountStr;
      } else {
        final converted = rate == null
            ? null
            : multiplyDecimalStrings(amountStr, rate, scale: 2);
        if (converted == null) {
          showToast(context, AppLocalizations.of(context).txRateMissingHint);
          return;
        }
        nativeAmount = Decimal.parse(converted).toStringAsFixed(2);
      }

      // AA 分流:指定分摊先跳 AaEditPage 取 result 后一次性落库;
      // 取消则中止提交,编辑器保持开启、内容保留。
      final aa = await _resolveAaFields(amountStr, txCurrency, c);
      if (aa == null) return;

      HapticFeedback.lightImpact();

      final actions = ref.read(transactionActionsProvider);
      // 指定分摊整批写入关系表;参与人标识即成员 id。
      final aaSplitsInput = aaEditModelToSplitInputs(
        aaMode: aa.aaMode,
        splits: aa.aaSplits,
        virtualUserIds: (await actions.getMembers(
          _ledgerId,
        )).where((m) => m.memberType == 'PLACEHOLDER').map((v) => v.id).toSet(),
      );
      // 操作者成员 id（self member）解析与落库并行发起。
      final authorIdFuture = authorMemberIdForLedger(ref, _ledgerId);
      // 分类 UUID 直连（本地与云端同一 id），无需 synthetic override。
      final categoryIdForWrite = c.id;

      // 作者必须在写库前解析：随交易同一事务落定，不再写完再回填
      // （回填会让云端账本产生第二条同步 mutation）。
      final operatorMemberId = await authorIdFuture;

      String transactionId;
      if (widget.editingTransactionId != null) {
        // 编辑模式：更新交易
        // 无旗标功能：excludeFromStats 恒为 false
        final newVersion = await actions.update(
          id: widget.editingTransactionId!,
          type: widget.initialKind,
          amount: amountStr,
          categoryId: categoryIdForWrite,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          happenedAt: _date,
          excludeFromStats: false,
          currencyCode: txCurrency,
          nativeAmount: nativeAmount,
          payerMemberId: aa.paidByUserId,
          aaMode: aa.aaMode,
          splits: aaSplitsInput,
          operatorMemberId: operatorMemberId,
        );
        transactionId = widget.editingTransactionId!;

        // 闭环：在编辑历史表追加一条同版本号快照，让详情页"编辑记录"区块
        // 有内容可展示。updateTransaction 已将 transactions.version +1，
        // 此处用同版本号写历史，使 transactions.version 与
        // record_edit_histories.version 一一对应，详情页"vN"标签才能
        // 正确指代本次编辑。
        // summary 作为不本地化的快照文本（与 note 字段同理），直接用
        // 分类名 + 金额 + 交易发生日期拼接。
        final summary =
            '${c.name} · $amountStr · '
            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-'
            '${_date.day.toString().padLeft(2, '0')} '
            '${_date.hour.toString().padLeft(2, '0')}:'
            '${_date.minute.toString().padLeft(2, '0')}';
        await actions.appendHistory(
          recordId: transactionId,
          version: newVersion,
          operatorMemberId: operatorMemberId,
          summary: summary,
        );
        // 主动失效编辑历史缓存：若详情 sheet 仍在 widget tree 上，
        // 下次读取会重查，立即看到刚写入的历史行。
        ref.invalidate(recordEditHistoryProvider(transactionId));
      } else {
        // 创建人 + 编辑人（同一个成员）随交易落库；
        // payerMemberId 为空时以操作者兜底,已显式写入的值(指定分摊)不覆盖。
        transactionId = await actions.add(
          ledgerId: _ledgerId,
          type: widget.initialKind,
          amount: amountStr,
          categoryId: categoryIdForWrite,
          happenedAt: _date,
          note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          excludeFromStats: false,
          currencyCode: txCurrency,
          nativeAmount: nativeAmount,
          payerMemberId: aa.paidByUserId,
          aaMode: aa.aaMode,
          splits: aaSplitsInput,
          operatorMemberId: operatorMemberId,
        );
      }

      // 账本笔数缓存失效；汇总/统计由统一数据变更信号自动刷新。
      ref.invalidate(countsForLedgerProvider(_ledgerId));

      // 提交成功后关闭编辑器 sheet。
      // 若本次提交跳转过 AaEditPage,AA 页退场固定为下滑动画(见
      // aaSlidePageRoute),与 sheet 下滑收起同向同速、同步进行,视觉上
      // 两层"一起收起来",无需等待 AA 页退场完成,也无需瞬隐 sheet。
      // 未跳转 AA 页时走标准 pop,sheet 下滑动画体验保持不变。
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      // 提交失败：保持 sheet 开启（内容不丢），复位提交中状态并提示，
      // 避免 updateTransaction 成功但 appendEditHistory 失败时界面永久卡死。
      logger.error('TransactionEditorSheet', '提交交易失败', e, st);
      if (mounted) {
        showToast(context, '${AppLocalizations.of(context).commonError}: $e');
      }
    } finally {
      // 无论成功 / 失败 / 取消都必须复位，防止提交状态永久卡死、后续无法再次提交。
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onCategorySelected(CategoryDisplay c) {
    setState(() => _selectedCategory = c);
  }

  void _onNotePicked(String note) {
    setState(() {
      _noteCtrl.text = note;
      _noteCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: note.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    // —— 高度自适应 ——
    final bottomInset = mq.viewPadding.bottom; // 底部安全区（刘海/Home Indicator）
    // 系统键盘拉起时底部安全区已被键盘覆盖，不额外留白
    final effectiveBottomInset = keyboardOpen ? 0.0 : bottomInset;
    final keyboardH = mq.viewInsets.bottom; // 系统键盘
    // 背景高度上限 = 全屏 − 系统键盘；实际受 route 约束（SafeArea 已扣顶部
    // 状态栏）限制，顶部正好顶到状态栏下面、底部铺到屏幕底。
    final available = mq.size.height - keyboardH;
    // sheet 背景高度上限 = available（全屏 − 键盘），铺满屏顶且不被键盘遮挡；
    // 真实高度由内容决定，仅作为 Container 上限封顶。
    final sheetMaxH = available;
    // —— 键盘区占比 ——
    // 目标高度按「无键盘的全屏可用高度」40% 计算（200px 下限 / 360px 上限），
    // 而不是按扣掉系统键盘后的剩余高度重算——否则备注聚焦、系统键盘拉起时
    // 自定义键盘会整体缩到 200px 下限，行高/字号随之大幅压缩。
    // 键盘拉起时键盘区保持目标尺寸整体上移，收缩主要由分类区（Expanded）
    // 承担；极端紧凑时键盘区让位（保底 160px），同时给分类区留出最低可见高度。
    final fullUsableH = mq.size.height - mq.padding.top - bottomInset;
    final keypadTarget = math.min(
      (fullUsableH * 0.40).clamp(200.0, 360.0),
      math.max(0.0, fullUsableH - 50),
    );
    final usableH = available - mq.padding.top - effectiveBottomInset;
    final keypadAreaH = math
        .min(keypadTarget, math.max(160.0, usableH - 50 - 56))
        .clamp(0.0, math.max(0.0, usableH - 50))
        .toDouble();

    // AA 区块仅账本开启 AA 时展示(功能隔离)
    final aaEnabled =
        ref.watch(currentLedgerDisplayProvider).value?.aaEnabled ?? false;

    // 编辑模式 + 共享账本 → 展示作者头像（创建者/最后编辑者）
    final editingTxId = widget.editingTransactionId;

    return PopScope(
      // 系统键盘拉起时，Android 返回键只收起键盘、保留记账页，
      // 不直接关闭整个 BottomSheet（否则 sheet 缩成极小时点击空白会误关）。
      canPop: !keyboardOpen,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && keyboardOpen) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Padding(
        // 系统键盘拉起时把整个 sheet 上推，确保备注 / 金额栏不被遮挡，
        // 同时整页（含分类区 / 自定义键盘）保持可见，不收起。
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: sheetMaxH),
          decoration: BoxDecoration(
            color: AppTokens.surfaceSheet(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radius16),
            ),
          ),
          child: Padding(
            // sheet 背景已由 SafeArea 顶到状态栏下面，顶部无需再内缩；
            // 仅底部内缩 Home Indicator 高度，最底排按键不被手势条压住；
            // 系统键盘拉起时键盘已覆盖手势条区域，不再留白。
            padding: EdgeInsets.only(bottom: effectiveBottomInset),
            child: Column(
              // 始终填满可用高度：分类区用 Expanded 占据剩余空间并独立滚动。
              // sheetMaxH = available（全屏 − 键盘）。键盘拉起时整页上移且不收起内容，
              // 满足「保留整个记账页、系统键盘不遮挡备注行与币种行」的需求。
              mainAxisSize: MainAxisSize.max,
              children: [
                // —— 拖拽条 ——
                const SheetGrabHandle(),
                // —— Header：返回 + 记一笔 + 分摊方式(弱化) + 作者头像 ——
                _buildHeader(context, l10n, editingTxId, aaEnabled),
                // —— 分类区（始终显示，含系统键盘拉起时） ——
                // 键盘拉起时分类区保持可见，整页上移保留。
                // 弱分隔线
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppTokens.cardInnerDividerColor(context),
                ),
                // 分类区（独立滚动、无可见滚动条）：Expanded 吃键盘区之外的
                // 剩余空间，剩余空间不足时自动压缩（可滚动）。
                Expanded(
                  child: CategoryGridSection(
                    kind: widget.initialKind,
                    initialSelectedId: widget.initialCategoryId,
                    onCategorySelected: _onCategorySelected,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppTokens.cardInnerDividerColor(context),
                ),
                // —— 键盘容器：备注行 + 金额栏行 + 键盘，高度按屏占比自适应 ——
                // 备注行必须始终在树中，否则键盘拉起→NoteInputRow 移除→
                // TextField 销毁→焦点丢失→键盘收起，形成死循环导致备注无法输入。
                // 键盘容器背景为浅灰（亮色 #DEE0E7），无阴影；
                // 内边距上 10 / 左 10 / 右 10 / 下 40（底部留白 40）。
                SizedBox(
                  height: keypadAreaH,
                  child: Container(
                    color: AppTokens.keypadBackground(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.p8,
                        AppDimens.p8,
                        AppDimens.p8,
                        AppDimens.p40,
                      ),
                      child: LayoutBuilder(
                        builder: (ctx, c) {
                          // 6 行均分：备注行永远比其余 5 行矮 [KeypadLayout.noteRowDelta]px，
                          // 其余 5 行（金额栏 + 3 行数字 + 底部行）等高，
                          // 相邻行纵向间距全局 [KeypadLayout.rowGap]px。
                          final h = KeypadLayout.rowHeight(c.maxHeight);
                          final noteH = math.max(
                            0.0,
                            h - KeypadLayout.noteRowDelta,
                          );
                          return Column(
                            children: [
                              // 备注输入行（备注行在金额栏行上方）
                              SizedBox(
                                height: noteH,
                                child: NoteInputRow(
                                  noteController: _noteCtrl,
                                  noteFocusNode: _noteFocusNode,
                                  onNotePicked: _onNotePicked,
                                ),
                              ),
                              const SizedBox(height: KeypadLayout.rowGap),
                              // 金额输入面板（金额/运算/币种/汇率状态全部在内部，
                              // 按键只重建本面板，不带动 Header/分类网格/备注行）
                              SizedBox(
                                height: 5 * h + 4 * KeypadLayout.rowGap,
                                child: AmountInputPanel(
                                  initialAmount: widget.initialAmount,
                                  initialCurrencyCode:
                                      widget.initialCurrencyCode,
                                  initialNativeAmount:
                                      widget.initialNativeAmount,
                                  date: _date,
                                  categorySelected: _selectedCategory != null,
                                  onPickDate: _pickDate,
                                  onSubmit: _onSubmit,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建 Header：返回按钮 + 「记一笔」标题 + 分摊方式(弱化) + 作者头像。
  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String? editingTxId,
    bool aaEnabled,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p12,
        0,
        AppDimens.p12,
        AppDimens.p4,
      ),
      child: Row(
        children: [
          // 返回按钮：关闭整个 sheet
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.p4),
              child: Icon(
                AppIcons.chevronLeft,
                size: AppDimens.icon16,
                color: AppTokens.iconTertiary(context),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          // 标题 + 分摊方式:作为左对齐整体,分摊方式紧贴标题约 10px(「隔壁」),
          // 而非被 Expanded 推到行尾;标题超宽时省略号截断,保证 toggle 不被挤出。
          if (aaEnabled) ...[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.txAddEntryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.strongTitle(
                        context,
                      ).copyWith(color: AppTokens.textPrimary(context)),
                    ),
                  ),
                  const SizedBox(width: AppDimens.p8),
                  AaModeToggle(
                    modeText: _aaModeToggleText(l10n),
                    onTap: _cycleAaMode,
                    toggleKey: const ValueKey('editor_aa_mode_toggle'),
                  ),
                ],
              ),
            ),
            // 作者头像:Spacer 推至行尾,避免挤占「标题+分摊方式」组
            if (editingTxId != null) ...[
              const Spacer(),
              _TxAuthorAvatars(editingTransactionId: editingTxId),
            ],
          ] else ...[
            // 无 AA 账本:标题直接顶满剩余空间
            Expanded(
              child: Text(
                l10n.txAddEntryTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.strongTitle(
                  context,
                ).copyWith(color: AppTokens.textPrimary(context)),
              ),
            ),
            if (editingTxId != null)
              _TxAuthorAvatars(editingTransactionId: editingTxId),
          ],
        ],
      ),
    );
  }

  /// 当前分摊方式文案（与编辑分摊页共用的 [AaModeToggle] 展示）。
  String _aaModeToggleText(AppLocalizations l10n) {
    return switch (_aaMode) {
      AaMode.perPerson => l10n.aaModePerPerson,
      AaMode.noSplit => l10n.aaModeNoSplit,
      AaMode.custom => l10n.aaModeCustom,
    };
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
        // 从成员列表中查找创作者/编辑者信息
        final membersAsync = ref.watch(
          ledgerMemberDisplaysProvider(ctx.ledgerId),
        );
        return membersAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (members) {
            final byId = <String, LedgerMemberDisplay>{
              for (final m in members) m.id: m,
            };
            final creator = ctx.creatorUserId != null
                ? byId[ctx.creatorUserId]
                : null;
            final editor = ctx.lastEditedByUserId != null
                ? byId[ctx.lastEditedByUserId]
                : null;
            // 判断当前用户(self member id)是否就是这笔交易的创建者/编辑者
            final selfMemberId =
                ref
                    .watch(currentLedgerDisplayProvider)
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
            // 且图片加载失败时回退首字母（修复"只有圆形占位、没有首字母"）。
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
