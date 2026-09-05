import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/aa/aa_decimal_util.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/widgets/aa_mode_toggle.dart';
import 'package:sesame_notes/shared/widgets/aa_participant_avatar.dart';
import 'package:sesame_notes/shared/widgets/me_suffix.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/aa_payer_picker_sheet.dart';

/// AA 分摊编辑页(纯选择器,不写库)。
///
/// 职责:
/// - 只读展示主体信息(金额 / 分类 / 日期 / 货币,不可改);
/// - 分摊方式独立区块标题 + 三态切换按钮(人均 / 不分摊 / 指定,与记账编辑器一致);
/// - 切换为人均/指定后在下方展示分摊配置:支出人(bottom sheet)+ 参与人(页内直接勾选);
///   人均:勾选项决定均摊人数,金额实时重算、输入框置灰不可改;
///   指定:每人金额可填,合计必须与交易金额精确相等;
/// - pop 返回 [AaEditResult](null = 取消),由调用方落库。
class AaEditPage extends ConsumerStatefulWidget {
  final AaEditPageArgs args;

  const AaEditPage({super.key, required this.args});

  @override
  ConsumerState<AaEditPage> createState() => _AaEditPageState();
}

class _AaEditPageState extends ConsumerState<AaEditPage> {
  /// 分摊方式(人均 / 指定 / 不分摊)。
  late AaMode _mode = widget.args.mode;

  /// 支出人标识;null = 未手动选择(新建默认创建人,编辑保持原值)。
  ///
  /// 未手选时由 [_resolveDefaultPayerId] 异步解析操作者 id 填充为「我」,
  /// 使参与人行置灰锁定、防反选与顶部展示三处口径一致;
  /// [_paidByManuallySet] 仍为 false,确认回传 null 由落库层回填操作者。
  String? _paidById;

  /// 是否已手动选择/回填支出人。
  ///
  /// 区分「手选值」与「默认创建人」:未手选时确认回传 null,由落库层
  /// 以操作者兜底支出人(新建)或保持原值(编辑);手选后恒写手选值。
  bool _paidByManuallySet = false;

  /// 参与人勾选集合;null = 全部成员(运行时展开为 options 全集)。
  ///
  /// 需求:支出人必是参与人且置顶置灰、不可反选;
  /// 取消勾选某人 → 不计入分摊(人均时实时重算,指定时金额栏置灰)。
  Set<String>? _participantIds;

  /// 指定金额输入控制器(key=参与人标识),随参与人变化同步增删。
  final Map<String, TextEditingController> _amountCtrls = {};

  /// 参与人选项异步加载完成后只初始化一次,避免用户输入被流刷新覆盖。
  bool _initialized = false;

  @override
  void dispose() {
    for (final c in _amountCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 参与人选项到达后的首次初始化:支出人兜底、参与人回填、指定金额回填。
  ///
  /// 指定分摊新建默认不预填任何金额(金额由用户按需填写),仅在编辑模式
  /// 回填既有指定金额;不分摊/人均模式不涉及输入框金额。
  void _initOnce(List<AaParticipantOption> options) {
    if (_initialized || options.isEmpty) return;
    _initialized = true;
    // 支出人初值:编辑回填视为已设定(编辑不覆盖);新建 null 保持未手选,
    // 由落库层回填操作者(默认支出人 = 创建人)。
    _paidById = widget.args.paidByUserId;
    _paidByManuallySet = widget.args.paidByUserId != null;
    _participantIds = widget.args.participantIds?.toSet();
    _syncAmountControllers(options);
    // 未手选时解析操作者 id 作为默认支出人(展示/锁定用,回传仍 null),
    // 使「我」所在行置灰锁定,与 _toggleParticipant 防反选口径一致。
    if (!_paidByManuallySet) {
      _resolveDefaultPayerId(options);
    }
    if (_mode == AaMode.noSplit) return;
    final hasSplits =
        widget.args.splits != null && widget.args.splits!.isNotEmpty;
    if (hasSplits) {
      // 编辑模式回填既有指定金额。
      widget.args.splits?.forEach((id, amount) {
        _amountCtrls[id]?.text = amount;
      });
    }
  }

  /// 未手选时解析操作者 id 作为默认支出人(仅用于展示与参与人锁定)。
  ///
  /// 设计意图:支出人必是参与人,未手选时落库层以操作者(operatorMemberId)
  /// 兜底支出人。若页内不解析操作者 id,参与人行的 isPayer 判断(_paidById)
  /// 与防反选锁定(锁定操作者「我」)会口径不一致。
  /// 此处提前把操作者 id 填充到 [_paidById],使「我」所在行置灰锁定、
  /// 防反选也锁定「我」;[_paidByManuallySet] 保持 false,确认回传仍 null
  /// 由落库层回填,不改变落库口径。
  ///
  /// 操作者 id 不在名册(options)时放弃填充,_paidById 保持 null,
  /// 无「我」所在行,不锁定任何参与人行(顶部展示回退「我」兜底)。
  Future<void> _resolveDefaultPayerId(List<AaParticipantOption> options) async {
    try {
      // 操作者 id 与落库层口径一致:本地账本 localSelfId,云端账本云 userId。
      final operatorId = await currentOperatorIdForLedger(
        ref,
        widget.args.ledgerId,
      );
      if (operatorId == null || operatorId.isEmpty || !mounted) return;
      // 操作者不在名册中时放弃,避免锁定一个不存在的行。
      if (!options.any((o) => o.id == operatorId)) return;
      setState(() => _paidById = operatorId);
    } catch (e, st) {
      logger.warning('AaEditPage', '解析默认支出人失败,回退参与人首个兜底', '$e\n$st');
    }
  }

  /// 按当前参与人集合同步金额输入控制器:新增补空控制器,移除释放。
  void _syncAmountControllers(List<AaParticipantOption> options) {
    final ids = options.map((o) => o.id).toSet();
    for (final id in ids) {
      _amountCtrls.putIfAbsent(id, () => TextEditingController());
    }
    final stale = _amountCtrls.keys.where((k) => !ids.contains(k)).toList();
    for (final k in stale) {
      _amountCtrls.remove(k)?.dispose();
    }
  }

  /// 当前生效的参与人集合(已勾选);未选(null) = 全部成员。
  List<String> _effectiveParticipants(List<AaParticipantOption> options) {
    final all = options.map((o) => o.id).toList();
    final selected = _participantIds;
    if (selected == null) return all;
    // 保持 options 顺序,且仅返回已勾选的;支出人必在内(锁定)。
    return all.where((id) => selected.contains(id)).toList();
  }

  String _optionName(List<AaParticipantOption> options, String id) {
    for (final o in options) {
      if (o.id == id) return o.name;
    }
    return AppLocalizations.of(context).aaUnknownUser;
  }

  /// 未手选支出人(默认 = 创建人 = 本人)的展示名:按账本归属分口径。
  ///
  /// 本地账本恒显固定本地身份「单机芝麻仔」;云账本显当前云 Profile 昵称
  /// (正常恒非空,注册即分配),缓存未就绪时防御性回退固定本地身份。
  String _selfDisplayName(AppLocalizations l10n) {
    // 展示名统一走账本身份上下文:本地账本固定「单机芝麻仔」,
    // 云/共享账本显云昵称(缓存未就绪时回退成员行昵称/本地身份)。
    final identity = ref
        .watch(ledgerIdentityProvider(widget.args.ledgerId))
        .value;
    if (identity != null && identity.selfMemberId.isNotEmpty) {
      return identity.displayNameOf(identity.selfMemberId);
    }
    return l10n.mineLocalName;
  }

  /// 切换某参与人勾选态;支出人锁定不可反选。
  void _toggleParticipant(String id) {
    // 支出人锁定:直接按 _paidById 判断,与参与人行 isPayer 置灰口径一致。
    // 未手选时 [_resolveDefaultPayerId] 已把操作者 id 填充进 _paidById,
    // 锁定的就是「我」;操作者不在名册(解析放弃)时 _paidById 为 null,
    // 无「我」所在行,不锁定任何参与人行(顶部展示也走「我」兜底)。
    if (id == _paidById) return;
    setState(() {
      // 首次点击时 _participantIds 为 null(全选态),必须以全部成员为基线,
      // 点击才表示「取消该行」;若用空集兜底会把初始全选误变成「仅该行」。
      final selected = _participantIds ?? _lastOptions.map((o) => o.id).toSet();
      if (!selected.remove(id)) {
        selected.add(id);
      }
      // 选中集合覆盖全部 options → 视为「全部成员」(落 null);
      // 否则保留具体名单。
      _participantIds = selected.length == _currentOptionsLength
          ? null
          : selected;
    });
  }

  /// 当前 options 快照(供 _toggleParticipant 内部判断全覆盖用)。
  List<AaParticipantOption> _lastOptions = const [];

  int get _currentOptionsLength => _lastOptions.length;

  /// 单点循环切换分摊方式:人均 → 不分摊 → 指定 → 人均。
  ///
  /// 与记账编辑器保持一致的循环顺序与切换语义。
  void _cycleAaMode() {
    setState(() {
      _mode = switch (_mode) {
        AaMode.perPerson => AaMode.noSplit,
        AaMode.noSplit => AaMode.custom,
        AaMode.custom => AaMode.perPerson,
      };
      _syncAmountControllers(_lastOptions);
    });
  }

  /// 已填指定金额合计(Decimal 精确累加,避免浮点尾差)。
  ///
  /// 仅统计当前已勾选参与人的金额:取消勾选的参与人不计入,
  /// 保证参与人总额/差额展示与勾选状态一致。
  Decimal _filledSum(List<AaParticipantOption> options) {
    var sum = Decimal.zero;
    for (final id in _effectiveParticipants(options)) {
      final value = Decimal.tryParse(_amountCtrls[id]?.text.trim() ?? '');
      if (value != null) sum += value;
    }
    return sum;
  }

  /// 完成:校验并 pop [AaEditResult]。
  ///
  /// 不分摊:直接 pop(aaMode=1,无参与人/支出人/指定金额)。
  /// 指定分摊校验:每人金额必填;合计 ≠ 交易金额时偏差按支出人
  /// 兜底修正(支出人应摊 += 差额),修正后为负则阻断。
  void _onConfirm(List<AaParticipantOption> options) {
    final l10n = AppLocalizations.of(context);

    if (_mode == AaMode.noSplit) {
      Navigator.of(context).pop(
        const AaEditResult(
          paidByUserId: null,
          aaMode: 1,
          aaParticipants: null,
          aaSplits: null,
        ),
      );
      return;
    }

    final participants = _effectiveParticipants(options);
    if (participants.isEmpty) {
      showToast(context, l10n.aaNoParticipants);
      return;
    }
    // 回传时按 _paidByManuallySet 区分手选与否——未手选回传 null,
    // 由落库层回填操作者(新建)或保持原值(编辑)。
    final resultPaidBy = _paidByManuallySet ? _paidById : null;

    if (_mode == AaMode.perPerson) {
      Navigator.of(context).pop(
        AaEditResult(
          paidByUserId: resultPaidBy,
          aaMode: 0,
          // 全选(null)落 null,运行时展开;部分选落具体名单。
          aaParticipants: _participantIds == null ? null : participants,
          aaSplits: null,
        ),
      );
      return;
    }

    // 指定分摊:逐人读取金额,空值阻断
    final splits = <String, Decimal>{};
    for (final id in participants) {
      final value = Decimal.tryParse(_amountCtrls[id]?.text.trim() ?? '');
      if (value == null || value < Decimal.zero) {
        showToast(context, l10n.aaSplitAmountIncomplete);
        return;
      }
      splits[id] = value;
    }

    // 指定分摊是金额写入边界，必须精确相等，不能静默改写支出人金额。
    final total = Decimal.tryParse(widget.args.amount);
    if (total == null ||
        !validateSplitsTotal(total: total, splits: splits.values.toList())) {
      showToast(context, l10n.aaSplitAmountIncomplete);
      return;
    }

    Navigator.of(context).pop(
      AaEditResult(
        paidByUserId: resultPaidBy,
        aaMode: 2,
        aaParticipants: participants,
        aaSplits: {
          for (final e in splits.entries) e.key: e.value.toStringAsFixed(2),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final optionsAsync = ref.watch(
      aaParticipantOptionsProvider(widget.args.ledgerId),
    );
    final options = optionsAsync.value ?? const <AaParticipantOption>[];
    _lastOptions = options;
    // 金额输入控制器必须在渲染参与人行前就位(TextField 依赖 controller),
    // 此处仅做控制器增删,不改变业务状态,可安全在 build 中执行。
    _syncAmountControllers(options);
    // 业务初始化(_initOnce 改写 _paidById/_participantIds 等状态字段)延迟到
    // 帧结束执行,避免在 build 中直接改 state,为后续可能的 setState 留出安全余量。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current =
          ref.read(aaParticipantOptionsProvider(widget.args.ledgerId)).value ??
          const <AaParticipantOption>[];
      final before = _initialized;
      _initOnce(current);
      if (before != _initialized && mounted) {
        setState(() {});
      }
    });

    final participants = _effectiveParticipants(options);
    // 交易币种缺省时回退账本本位币展示。
    final currencyCode =
        widget.args.currencyCode ??
        ref.watch(currentLedgerDisplayProvider).value?.currency;

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l10n.aaEditTitle, showBack: true),
          Expanded(
            child: optionsAsync.isLoading && options.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(AppDimens.p16),
                    children: [
                      _buildSubjectCard(context, l10n, currencyCode),
                      const SizedBox(height: AppDimens.p16),
                      // 分摊方式:独立区块标题(与账单详情的 _SectionLabel 对齐),
                      // 标题下方紧跟三态切换按钮,与主体卡分离。
                      _buildSplitModeSection(context, l10n),
                      if (_mode != AaMode.noSplit) ...[
                        const SizedBox(height: AppDimens.p16),
                        _buildSplitCard(
                          context,
                          l10n,
                          options,
                          participants,
                          currencyCode,
                        ),
                      ],
                    ],
                  ),
          ),
          _buildConfirmBar(context, l10n, options),
        ],
      ),
    );
  }

  /// 主体信息只读卡:icon + 类目 / 日期 / 金额 / 货币。
  ///
  /// 排版完全照搬账单详情头部模块(字号/间距/字体颜色),不硬编码:
  /// - 顶部:36x36 icon 容器(圆角12) + 类目(16px/w600/textPrimary);
  /// - 12px 间距后接分隔线,再接日期/金额/货币信息行(14px,与详情 _InfoRow 一致)。
  /// 分摊方式使用独立区块标题(见 [_buildSplitModeSection]),不归属此卡。
  Widget _buildSubjectCard(
    BuildContext context,
    AppLocalizations l10n,
    String? currencyCode,
  ) {
    final d = widget.args.date.toLocal();
    final dateText =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final primary = Theme.of(context).colorScheme.primary;
    final iconData = resolveCategoryIcon(widget.args.categoryIconName);

    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部:icon + 类目(只读),与账单详情头部 Row 完全一致
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTokens.surfaceSecondary(context),
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Icon(iconData, size: AppDimens.icon20, color: primary),
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: Text(
                  CategoryUtils.getDisplayName(
                    widget.args.categoryName,
                    context,
                  ),
                  style: AppTextTokens.strongTitle(
                    context,
                  ).copyWith(color: AppTokens.textPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // 与账单详情一致:icon 行后 12px 间距再接分隔线,避免 icon 压着分割线
          const SizedBox(height: AppDimens.p12),
          _cardDivider(context),
          // 日期(只读)
          _infoRow(context, l10n.homeDetailDate, dateText),
          // 金额(只读)
          _infoRow(
            context,
            l10n.homeDetailAmount,
            '',
            valueWidget: AmountText(
              value: double.tryParse(widget.args.amount) ?? 0,
              signed: false,
              // 主体卡金额带币种符号:与合计行/只读金额统一口径。
              showCurrency: true,
              currencyCode: currencyCode,
              style: AppTextTokens.body(
                context,
              ).copyWith(color: AppTokens.textPrimary(context)),
            ),
          ),
          // 货币(只读)
          if (widget.args.currencyCode != null &&
              widget.args.currencyCode!.isNotEmpty)
            _infoRow(
              context,
              l10n.homeDetailCurrency,
              widget.args.currencyCode!,
            ),
        ],
      ),
    );
  }

  /// 分摊方式独立区块:标题 + 三态切换按钮同行展示。
  ///
  /// 设计意图:分摊方式在账单详情中是独立区块标题(_SectionLabel:13px/w600/
  /// textSecondary),编辑分摊页面对齐该结构——标题独立成块、不归属主体卡。
  /// 标题与切换按钮放置在同一行(标题左、按钮右)并垂直居中对齐,避免上下
  /// 堆叠造成的视觉错位。
  Widget _buildSplitModeSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
      child: Row(
        children: [
          // 独立区块标题:与账单详情 _SectionLabel 完全一致(13px/w600/textSecondary)
          Text(
            l10n.aaSplitMode,
            style: AppTextTokens.label(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokens.textSecondary(context),
            ),
          ),
          const Spacer(),
          // 三态切换按钮:标题已表达语义,不重复左侧文案
          // 右缩 24px = 页面 16px 内边距 + 金额文本右边界 8px 基准,
          // 使按钮右边界与账单详情值/合计/参与人金额同一条直线
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: AaModeToggle(
              modeText: _aaModeToggleText(l10n),
              onTap: _cycleAaMode,
              toggleKey: const ValueKey('aa_mode_toggle'),
            ),
          ),
        ],
      ),
    );
  }

  /// 当前分摊方式文案（与记账编辑器头部共用的 [AaModeToggle] 展示）。
  String _aaModeToggleText(AppLocalizations l10n) {
    return switch (_mode) {
      AaMode.perPerson => l10n.aaModePerPerson,
      AaMode.noSplit => l10n.aaModeNoSplit,
      AaMode.custom => l10n.aaModeCustom,
    };
  }

  /// 分摊配置卡:支出人 + 合计 + 参与人列表(页内直接勾选 + 金额输入框)。
  ///
  /// 人均分摊:参与人勾选决定均摊人数,金额输入框置灰、实时重算展示;
  /// 指定分摊:每人金额可填,合计必须与交易金额精确相等。
  /// 支出人置顶置灰(锁定勾选、icon/名称置灰,金额输入框若未勾选则置灰不可操作)。
  Widget _buildSplitCard(
    BuildContext context,
    AppLocalizations l10n,
    List<AaParticipantOption> options,
    List<String> participants,
    String? currencyCode,
  ) {
    final total = Decimal.tryParse(widget.args.amount) ?? Decimal.zero;
    final sum = _filledSum(options);
    final balanced = total == sum;

    // 合计行的合计值:人均分摊按勾选人数均摊(展示总额);
    // 指定分摊按已填金额累加(未填行计 0)。
    // 人均模式下金额为只读实时重算,指定模式下 _filledSum 按当前已勾选
    // 参与人的已填金额累加,切换勾选/模式时同步更新。
    final displaySum = toDouble(_mode == AaMode.perPerson ? total : sum);
    final displayTotal = toDouble(total);

    return SectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p4,
      ),
      child: Column(
        children: [
          // 支出人(bottom sheet 选择)
          _buildPayerRow(context, l10n, options),
          _cardDivider(context),
          // 参与人标题行:文案「参与人」(原「合计」),不加粗,
          // 与支出人 label 同字号同色(textSecondary),作为参与人列表的标题行。
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
            child: Row(
              children: [
                Text(
                  l10n.aaParticipants,
                  style: AppTextTokens.body(
                    context,
                  ).copyWith(color: AppTokens.textSecondary(context)),
                ),
                // 合计值右对齐占满剩余宽度:右缩 10px 对齐参与人金额列中
                // 金额文本的右边界(可编辑输入框 contentPadding 右侧 10px,
                // 只读金额同缩 10px)。设计意图:支出人 chevron / 参与人总额 /
                // 每行只读态 / 编辑态四类元素统一以金额文本右边界为基准。
                // FittedBox 保证金额超大时不溢出/换行,而是等比缩小完整显示。
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppDimens.p8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${formatMoneyWithCurrency(displaySum, currencyCode: currencyCode)}'
                          ' / ${formatMoneyWithCurrency(displayTotal, currencyCode: currencyCode)}',
                          style: AppTextTokens.body(context).copyWith(
                            color: _mode == AaMode.perPerson || balanced
                                ? AppTokens.success(context)
                                : AppTokens.warning(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 参与人列表:支出人置顶置灰,其余按 options 顺序。
          // 逐行:方框勾选 + 名称 + 右对齐金额输入框。
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) _cardDivider(context),
            _buildParticipantRow(context, options, options[i], currencyCode),
          ],
        ],
      ),
    );
  }

  /// 支出人导航行:点击弹 bottom sheet 选择。
  ///
  /// 字段值(支出人名)右对齐,与日期/金额/货币等信息行口径一致。
  Widget _buildPayerRow(
    BuildContext context,
    AppLocalizations l10n,
    List<AaParticipantOption> options,
  ) {
    // 展示名:未手选时 [_resolveDefaultPayerId] 已把操作者 id 填入 _paidById,
    // 此处反查名册即「我」(与参与人锁定行同名,三处口径一致)。
    // 未手选 = 默认支出人 = 创建人(本人):按账本归属展示——
    // 本地账本固定「单机芝麻仔」,云账本显当前云 Profile 昵称。
    // 未手选(_paidById 为 null)时操作者即「我」,恒为本人;手选后按名册
    // option.isSelf 判定,与参与人锁定行 / picker 行的本人口径一致。
    final payerIsSelf = _paidById == null
        ? true
        : options.where((o) => o.id == _paidById).firstOrNull?.isSelf ?? false;
    // 纯名展示(不拼接「(我)」,后缀交给 UI 层共享 meSuffixSpan 统一渲染);
    // 手选反查名册名。
    final payerName = _paidById == null
        ? _selfDisplayName(l10n)
        : _optionName(options, _paidById!);
    return InkWell(
      onTap: () async {
        final picked = await showAaPayerPickerSheet(
          context,
          ledgerId: widget.args.ledgerId,
          options: options,
          selectedId: _paidById,
        );
        // 选择器打开期间页面可能已销毁,或用户取消选择,均不更新状态。
        if (picked == null || !mounted) return;
        if (picked != _paidById) {
          setState(() {
            _paidById = picked;
            // 手选后标记手动选择:确认回传手选值(而非 null)。
            // 未手选(新建)回传 null,由落库层回填操作者 = 默认支出人创建人。
            _paidByManuallySet = true;
            // 支出人必是参与人:新支出人若不在已选名单内,自动补入。
            if (_participantIds != null && !_participantIds!.contains(picked)) {
              _participantIds = {..._participantIds!, picked};
              _syncAmountControllers(options);
            }
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
        child: Row(
          children: [
            Text(
              l10n.aaPayer,
              style: AppTextTokens.body(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
            const Spacer(),
            // 支出人名右对齐,与其他信息行(日期/金额/货币)口径一致。
            // 必须用 Expanded(tight) 而非 Flexible(loose):loose 下 Text 只占
            // 内容宽并靠左,右侧留白使 chevron 无法贴行尾;tight 强制占满槽位,
            // 配合 textAlign.right 使文本右对齐,chevron 贴到金额文本右边界。
            Expanded(
              // 本人支出人:名称后追加共享「(我)」后缀,与成员管理/交易详情
              // 口径一致;非本人用纯名 Text。
              child: payerIsSelf
                  ? Text.rich(
                      TextSpan(
                        text: payerName,
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(color: AppTokens.textPrimary(context)),
                        children: [meSuffixSpan(context, l10n)],
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      payerName,
                      textAlign: TextAlign.right,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            const SizedBox(width: AppDimens.p4),
            // 右缩进 10px,使 chevron 右边界与参与人金额列中金额文本右边界对齐
            // (可编辑金额输入框 contentPadding 右侧 10px),避免选项按钮悬出金额列。
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.p8),
              child: Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon16,
                color: AppTokens.iconTertiary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 单个参与人行:方框勾选 + 名称 + 右对齐金额输入框。
  ///
  /// 只读态统一:人均分摊金额、指定分摊未勾选/支出人
  /// 锁定的金额,均以纯文字展示(无边框/无色块),可用态用 textPrimary,
  /// 置灰态用 disabledColor,避免同页面出现两套只读色。
  /// 复选按钮:支出人锁定时做置灰只读态(边框/勾用 disabledColor),而非
  /// 仅禁用点击。
  Widget _buildParticipantRow(
    BuildContext context,
    List<AaParticipantOption> options,
    AaParticipantOption option,
    String? currencyCode,
  ) {
    final isPayer = option.id == _paidById;
    final selected = _participantIds == null
        ? true
        : _participantIds!.contains(option.id);
    final disabledColor = Theme.of(context).disabledColor;

    // 人均分摊:按勾选人数实时均摊,已勾选行只读展示人均值。
    final perPersonAmount = _mode == AaMode.perPerson
        ? _computePerPerson(options, option.id)
        : null;

    // 名称颜色:支出人/未勾选 → 置灰(disabledColor);已勾选 → 一级色。
    final nameColor = (isPayer || !selected)
        ? disabledColor
        : AppTokens.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
      child: Row(
        children: [
          // 方框勾选:支出人锁定时置灰只读态(disabledColor),而非仅禁用点击;
          // key 供测试定位该参与人的勾选框。
          _buildCheckbox(
            context,
            key: ValueKey('aa-checkbox-${option.id}'),
            checked: selected,
            locked: isPayer,
            onTap: isPayer ? null : () => _toggleParticipant(option.id),
          ),
          const SizedBox(width: AppDimens.p8),
          // 参与人头像:统一走 AaParticipantAvatar(全局默认头像资产/云头像缓存),
          // 支出人/未勾选用透明度置灰,与名称置灰口径一致。
          Opacity(
            opacity: (isPayer || !selected) ? 0.4 : 1,
            child: AaParticipantAvatar(
              ledgerId: widget.args.ledgerId,
              participantId: option.id,
              isSelf: option.isSelf,
              size: AppDimens.icon16,
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          Expanded(
            // 本人参与人:名称后追加共享「(我)」后缀,与支出人行 / 成员管理
            // 口径一致;非本人用纯名 Text。
            child: option.isSelf
                ? Text.rich(
                    TextSpan(
                      text: option.name,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: nameColor),
                      children: [
                        meSuffixSpan(context, AppLocalizations.of(context)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    option.name,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: nameColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: AppDimens.p12),
          // 金额列:
          // - 高度固定 40(与输入框 contentPadding+边框高度一致),行高不随
          //   勾选状态收缩,取消勾选后整行不会上下移动;
          // - 仅已勾选参与人渲染金额:指定分摊用可编辑输入框(含支出人,金额
          //   可调),人均分摊用只读人均值(每人均摊同一值);
          // - 取消勾选的参与人(两种模式一致)金额栏留白,金额不计入总额。
          SizedBox(
            width: 120,
            height: 40,
            child: !selected
                ? const SizedBox.shrink()
                : _mode == AaMode.custom
                ? TextField(
                    controller: _amountCtrls[option.id],
                    enabled: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    textAlign: TextAlign.right,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: AppTokens.textPrimary(context)),
                    decoration: InputDecoration(
                      isDense: true,
                      // 输入框前缀币种符号:输入时即可确认分摊金额币种,
                      // 与展示金额带符号的视觉口径一致。
                      prefixText: currencyCode == null
                          ? null
                          : '${getCurrencySymbol(currencyCode)} ',
                      hintText: '0.00',
                      hintStyle: TextStyle(color: disabledColor),
                      // 已填金额时在右侧显示圆形 x 清空按钮(空框不占位),
                      // 点击后一键清空便于重新填写;有内容才可清空,避免
                      // 空输入框上出现误导性的可点图标。
                      suffixIcon:
                          (_amountCtrls[option.id]?.text.trim().isNotEmpty ??
                              false)
                          ? _buildClearAmountButton(context, option.id)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p8,
                        vertical: AppDimens.p8,
                      ),
                      filled: true,
                      fillColor: AppTokens.surfaceInput(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : _readOnlyAmountText(
                    context,
                    perPersonAmount ?? 0,
                    dimmed: true,
                    currencyCode: currencyCode,
                  ),
          ),
        ],
      ),
    );
  }

  /// 方框勾选组件:未选空方框,选中实心带勾。
  ///
  /// 锁定态(支出人):做置灰只读态——底色用 disabledColor、勾 icon 用白色,
  /// 且无外边框(支出人必是参与人,checked 恒为 true,灰底+白勾已足够表达
  /// 「不可操作」);可勾选态保留边框,视觉上提示可点击。
  Widget _buildCheckbox(
    BuildContext context, {
    Key? key,
    required bool checked,
    bool locked = false,
    VoidCallback? onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final disabledColor = Theme.of(context).disabledColor;
    // 锁定态用 disabledColor,可用态用 primary
    final activeColor = locked ? disabledColor : primary;
    final borderColor = checked
        ? activeColor
        : AppTokens.textTertiary(context).withValues(alpha: 0.5);
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius4),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: checked ? activeColor : Colors.transparent,
          // 锁定态(支出人)去边框:仅灰底+白勾;可勾选态保留边框。
          border: locked
              ? Border.all(color: Colors.transparent, width: 1.5)
              : Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppDimens.radius4),
        ),
        child: checked
            ? Icon(
                AppIcons.check,
                size: AppDimens.icon12,
                color: AppTokens.textOnPrimary(context),
              )
            : null,
      ),
    );
  }

  /// 金额输入框的清空按钮:已填金额时显示圆形 x,点击一键清空。
  ///
  /// 设计意图:指定分摊金额需精确调整,一键清空便于重新填写。按钮仅在有内容
  /// 时出现,空框不占位。程序清空不触发 onChanged,故点击后需手动 setState
  /// 刷新合计与按钮显隐。
  Widget _buildClearAmountButton(BuildContext context, String id) {
    return GestureDetector(
      onTap: () {
        _amountCtrls[id]?.clear();
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p4),
        child: Icon(
          AppIcons.cancel,
          size: AppDimens.icon16,
          color: AppTokens.iconSecondary(context),
        ),
      ),
    );
  }

  /// 只读金额展示(纯文字,无边框无色块),人均分摊已勾选行展示人均值用。
  ///
  /// 右对齐基准:可编辑金额的 TextField 有 10px 水平 contentPadding,金额文本
  /// 右边界比输入框(色块)右边界内缩 10px。只读态同样右缩 10px,保证两种状态
  /// 的金额文本右边界对齐,而不是对齐到色块右边缘。
  /// FittedBox 在金额超大时不换行/不省略,等比缩小字号完整显示(与结算页
  /// 分摊详情表的处理方式一致,保证用户能看清每人的分摊金额)。
  Widget _readOnlyAmountText(
    BuildContext context,
    double value, {
    required bool dimmed,
    required String? currencyCode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.p8),
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            // 只读金额带币种符号,与可输入金额的前缀符号口径一致。
            formatMoneyWithCurrency(value, currencyCode: currencyCode),
            style: AppTextTokens.body(context).copyWith(
              color: dimmed
                  ? Theme.of(context).disabledColor
                  : AppTokens.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }

  /// 按当前勾选人与支出人计算该行金额，分位余数固定归支出人。
  double _computePerPerson(
    List<AaParticipantOption> options,
    String participantId,
  ) {
    final participants = _effectiveParticipants(options);
    if (participants.isEmpty) return 0;
    final total = Decimal.tryParse(widget.args.amount) ?? Decimal.zero;
    final splits = splitEvenly(
      total: total,
      participantCount: participants.length,
      payerIndex: participants.indexOf(_paidById ?? participants.first),
    );
    final index = participants.indexOf(participantId);
    return index < 0 ? 0 : toDouble(splits[index]);
  }

  /// 主体卡信息行(只读):左标签 + 右值。
  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
          Flexible(
            // 右缩 10px:与分摊配置卡金额文本右边界(输入框 contentPadding
            // 右侧 10px)对齐,使全页右侧内容落在同一条直线上
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimens.p8),
              child:
                  valueWidget ??
                  Text(
                    value,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: AppTokens.textPrimary(context)),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部完成按钮(返回 result;取消走系统返回/pop null)。
  Widget _buildConfirmBar(
    BuildContext context,
    AppLocalizations l10n,
    List<AaParticipantOption> options,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: FilledButton(
        onPressed: () => _onConfirm(options),
        child: Text(l10n.commonFinish),
      ),
    );
  }

  Widget _cardDivider(BuildContext context) =>
      Divider(height: 1, thickness: 0.5, color: AppTokens.divider(context));
}
