/// 账本编辑二级页面
///
/// 承载新建 / 编辑（本地+共享）两种模式。
/// 布局：PrimaryHeader + Card 模块列表 + 底部保存按钮。
library;

import 'package:flutter/material.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_storage_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_currency_change.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/member_management_section.dart';
import 'package:sesame_notes/features/statistics/presentation/widgets/member_stats_section.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/currency_picker_sheet.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/presentation/format_utils.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 账本编辑二级页面
///
/// [ledger] 为 null 时表示新建模式；非 null 时为编辑模式。
class LedgerEditPage extends ConsumerStatefulWidget {
  final LedgerDisplayItem? ledger;

  const LedgerEditPage({super.key, this.ledger});

  @override
  ConsumerState<LedgerEditPage> createState() => _LedgerEditPageState();
}

class _LedgerEditPageState extends ConsumerState<LedgerEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _currency = '';
  int _monthStartDay = 1;
  bool _saving = false;
  bool _initialized = false;
  // 编辑数据加载失败：进入错误态并禁止保存，避免用默认值覆盖真实配置。
  bool _loadFailed = false;

  /// AA 分摊开关(新建/编辑态,随「保存」落库;跨设备同步)。
  ///
  /// 开关内容(虚拟用户列表 / 分摊统计入口)跟随开关立即显示/隐藏,
  /// 不依赖保存按钮——开关本身是纯 UI 状态,无需保存即可配置。
  bool _aaEnabled = false;

  /// 新建态归属选择：null = 未手动选择（按登录态取默认值）。
  /// 已登录默认云端（用户既然接了云服务，新账本默认参与同步符合预期）；
  /// 未登录只能是本地。编辑态不可改归属，恒为 null。
  String? _storageMode;

  /// 未登录时无论 UI 状态如何都只能建本地账本（二次夹紧）：
  /// 否则会造出「标了 cloud 却没有云端同步能力」的孤儿账本。
  bool get _loggedIn => ref.read(currentLedgerAccountIdProvider) != null;

  /// 生效的归属：手动选择优先，未选时按登录态取默认值；未登录强制 local。
  String get _effectiveStorageMode =>
      _loggedIn ? (_storageMode ?? 'cloud') : 'local';

  /// 新建态下内存暂存的虚拟用户列表。
  ///
  /// 新建态账本尚未落库、没有 ledgerId,虚拟用户无法直接写库,因此先暂存在
  /// 内存;保存账本拿到新 ledgerId 后,由 [_saveNewLedger] 批量落库。
  /// 编辑态虚拟用户直接走数据库 CRUD,不经过此列表。
  final List<PendingVirtualUser> _pendingVirtualUsers = [];

  bool get _isEditing => widget.ledger != null;
  bool get _isCreating => widget.ledger == null;

  /// 协作者只读判断：仅当「编辑已有账本」且「当前账本为共享账本」且「自己非拥有者」时为 true。
  /// 此时账本元信息（名称 / 币种 / 起始日）不可编辑。
  /// 依赖前置条件：_isEditing 为真时 widget.ledger 必然非空，故此处使用 ! 非空断言是安全的。
  bool get _isReadOnly =>
      _isEditing && widget.ledger!.isShared && widget.ledger!.myRole != 'owner';

  @override
  void initState() {
    super.initState();
    // 注意：initState 中不能用 translateLedgerName(context, ...)，
    // 它依赖 AppLocalizations.of(context)（InheritedWidget），
    // 在 initState 完成前访问会抛 dependOnInheritedWidgetOfExactType 异常。
    // 名称输入框初始值用原始账本名，翻译仅用于标题展示（在 build 中调用）。
    _nameController = TextEditingController(
      text: widget.ledger != null ? widget.ledger!.name : '',
    );
    if (widget.ledger != null) {
      _currency = widget.ledger!.currency;
      _monthStartDay = 1; // 真实值在 _loadLedgerData 中异步加载
      _loadLedgerData();
    } else {
      _initDefaultCurrency();
    }
  }

  /// 编辑模式：从 DB 加载完整的账本数据（monthStartDay 等）。
  ///
  /// 加载失败或账本不存在时进入错误态（_loadFailed），不允许用默认值继续
  /// 编辑后覆盖真实配置；用户可点击重试。
  Future<void> _loadLedgerData() async {
    try {
      final data = await ref
          .read(ledgerActionsProvider)
          .getById(widget.ledger!.id);
      if (!mounted) return;
      if (data != null) {
        setState(() {
          _currency = data.currency;
          _monthStartDay = data.monthStartDay;
          _aaEnabled = data.aaEnabled;
          _loadFailed = false;
          _initialized = true;
        });
      } else {
        setState(() {
          _loadFailed = true;
          _initialized = true;
        });
      }
    } catch (e, st) {
      logger.error('LedgerEditPage', '加载账本数据失败', e, st);
      if (mounted) {
        setState(() {
          _loadFailed = true;
          _initialized = true;
        });
      }
    }
  }

  /// 重试加载账本数据：先回到加载态，再重新发起加载。
  void _retryLoad() {
    setState(() {
      _loadFailed = false;
      _initialized = false;
    });
    _loadLedgerData();
  }

  /// 新建模式：默认币种链 — 当前账本本位币 → welcome 选币 → CNY
  Future<void> _initDefaultCurrency() async {
    String currency =
        ref.read(currentLedgerDisplayProvider).value?.currency ?? '';
    if (currency.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        currency = prefs.getString('selected_currency') ?? 'CNY';
      } catch (e) {
        logger.warning('LedgerEditPage', '读取默认币种失败: $e');
        currency = 'CNY';
      }
    }
    if (mounted) {
      setState(() {
        _currency = currency;
        _monthStartDay = 1;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 页面标题：编辑模式用账本名称，新建模式用「新建账本」
    final title = _isCreating
        ? l10n.ledgersNew
        : translateLedgerName(context, widget.ledger!.name);

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: title,
            showBack: true,
            // 仅编辑模式展示右上角「更多」菜单，收纳账本敏感操作；
            // 新建模式没有清空/删除等危险入口，无需菜单。
            actions: _isEditing ? [_buildMoreMenu(context, l10n)] : null,
          ),
          Expanded(
            child: _loadFailed
                ? _buildLoadError(context, l10n)
                : (_initialized
                      ? _buildBody(context, l10n)
                      : const Center(child: CircularProgressIndicator())),
          ),
          // 底部保存按钮（新建和编辑模式显示）
          // 协作者只读时不渲染保存按钮，从源头杜绝推送账本元信息变更
          // 加载失败时不渲染，避免在默认值基础上误保存。
          if (!_isReadOnly && !_loadFailed) _buildSaveButton(context, l10n),
        ],
      ),
    );
  }

  /// 模块标题 — 页面统一采用「标题在外 + 内容卡片」的版块结构。
  ///
  /// 左侧 3px 主题色条 + 加粗标题,与「备份与云同步配置」等页面的模块标题
  /// 风格一致,让编辑页各模块(账本名称 / 币种 / 每月起始日 / 成员管理 /
  /// 成员收支 / 存储位置)在长列表中区分更明显;水平内缩与 Card 默认
  /// margin(all: 4) 对齐;[disabled] 时色条与文字整行置灰,与只读内容的
  /// 禁用色保持一致。
  Widget _buildSectionTitle(
    BuildContext context,
    String text, {
    bool disabled = false,
  }) {
    final color = disabled
        ? Theme.of(context).disabledColor
        : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 15,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimens.radius4),
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 编辑数据加载失败态：友好提示 + 重试按钮。
  Widget _buildLoadError(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.categoryDetailLoadFailed,
              style: TextStyle(color: AppTokens.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.p12),
            TextButton.icon(
              onPressed: _retryLoad,
              icon: const Icon(AppIcons.refresh, size: AppDimens.icon16),
              label: Text(l10n.analyticsRetry),
            ),
          ],
        ),
      ),
    );
  }

  /// 新建账本时的归属选择（本地账本 / 云端账本）。
  ///
  /// 设计意图：这本账会不会上云必须在创建时就让用户看清，而不是靠登录态隐式
  /// 决定——后者会让用户在不知情的情况下把私密账本传上云。未登录时云端选项
  /// 直接禁用并给出登录引导，不留误点的机会。
  Widget _buildStorageModeSelector(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        // 与上游一致：标题内嵌卡片顶部，四周用 LTRB(16,12,16,12) 收紧。
        padding: const EdgeInsets.fromLTRB(
          AppDimens.p16,
          AppDimens.p12,
          AppDimens.p16,
          AppDimens.p12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledgersStorageLocation,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimens.p8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'local',
                  icon: const Icon(
                    AppIcons.localStorage,
                    size: AppDimens.icon16,
                  ),
                  label: Text(l10n.ledgersSectionLocal),
                ),
                ButtonSegment(
                  value: 'cloud',
                  icon: const Icon(AppIcons.cloudQueue, size: AppDimens.icon16),
                  label: Text(l10n.ledgersSectionCloud),
                  enabled: _loggedIn,
                ),
              ],
              selected: {_effectiveStorageMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _storageMode = s.first),
            ),
            const SizedBox(height: AppDimens.p8),
            Text(
              !_loggedIn
                  ? l10n.ledgersSectionCloudSignInHint
                  : (_effectiveStorageMode == 'cloud'
                        ? l10n.ledgersStorageCloudHint
                        : l10n.ledgersStorageLocalHint),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTokens.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.p16),
        children: [
          // ── 1. 账本名称 ──
          // 不设置 elevation，与编辑分类等其他模块保持一致的扁平卡片风格。
          _buildSectionTitle(
            context,
            l10n.ledgerNameLabel,
            disabled: _isReadOnly,
          ),
          const SizedBox(height: AppDimens.p8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.p16),
              // 协作者只读：不渲染带边框的输入框，仅展示账本名称文本，
              // 避免「看起来还能编辑」的误导；文字同步置灰。
              child: _isReadOnly
                  ? Text(
                      _nameController.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    )
                  : TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.ledgerNameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.ledgerNameLabel;
                        }
                        return null;
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppDimens.p16),

          // ── 1.5 存储位置（仅新建：归属在创建时决定，之后不可改）──
          // 标题内嵌在卡片里（与上游一致），此处不再重复渲染分区标题。
          if (_isCreating) ...[
            _buildStorageModeSelector(context, l10n),
            const SizedBox(height: AppDimens.p16),
          ],

          // ── 2. 主币种 ──
          _buildSectionTitle(
            context,
            l10n.ledgerBaseCurrencyLabel,
            disabled: _isReadOnly,
          ),
          const SizedBox(height: AppDimens.p8),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
                vertical: AppDimens.p4,
              ),
              title: currencyFlagLabel(
                context,
                _currency,
                // 可编辑：与账本名称编辑框同用全局 bodyLarge（14px / 主色），
                // 避免可编辑值显示为灰色误导"不可编辑"；
                // 只读：对齐账本名称的只读样式（bodyLarge + disabledColor 置灰），
                // 与 ListTile 的 enabled=false 灰化保持一致。
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _isReadOnly ? Theme.of(context).disabledColor : null,
                ),
              ),
              // 协作者只读时整行置灰（enabled=false 灰化文字与图标），且不显示右箭头，
              // 避免「看起来还能点击」的误导
              trailing: !_isReadOnly
                  ? Icon(
                      AppIcons.chevronRight,
                      size: AppDimens.icon16,
                      color: AppTokens.iconTertiary(context),
                    )
                  : null,
              enabled: !_isReadOnly,
              onTap: !_isReadOnly
                  ? () async {
                      // 在首个 await 之前先捕获主题色：Theme.of(context) 跨 await 间隙使用会被
                      // use_build_context_synchronously 告警，提前取出引用后 await 之后仅复用局部变量。
                      final primaryColor = Theme.of(
                        context,
                      ).colorScheme.primary;
                      // 键盘守卫：与记账页/分类页一致，避免面板关闭后键盘重弹。
                      await prepareForOverlay();
                      // 闭包内 context 为 build 参数，用 context.mounted 与同源，方能被分析器识别为有效守卫。
                      if (!context.mounted) return;
                      final picked = await showCurrencyPickerSheet(
                        context,
                        selected: _currency.toUpperCase(),
                        primaryColor: primaryColor,
                        title: l10n.ledgerBaseCurrencyLabel,
                        showRateAsBaseLabel: true,
                        visibleCurrencies: ref.read(visibleCurrenciesProvider),
                      );
                      if (picked != null) {
                        setState(() => _currency = picked);
                      }
                    }
                  : null,
            ),
          ),
          const SizedBox(height: AppDimens.p16),

          // ── 3. 每月起始日 ──
          _buildSectionTitle(
            context,
            l10n.ledgersMonthStartDay,
            disabled: _isReadOnly,
          ),
          const SizedBox(height: AppDimens.p8),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
                vertical: AppDimens.p4,
              ),
              title: Text(
                _monthStartDay <= 1
                    ? l10n.ledgersMonthStartDayNatural
                    : l10n.ledgersMonthStartDayValue(_monthStartDay),
                // 可编辑：与账本名称编辑框同用全局 bodyLarge（14px / 主色），
                // 避免可编辑值显示为灰色误导"不可编辑"；
                // 只读：对齐账本名称的只读样式（bodyLarge + disabledColor 置灰），
                // 与 ListTile 的 enabled=false 灰化保持一致。
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _isReadOnly ? Theme.of(context).disabledColor : null,
                ),
              ),
              // 协作者只读时整行置灰且不显示右箭头
              trailing: !_isReadOnly
                  ? Icon(
                      AppIcons.chevronRight,
                      size: AppDimens.icon16,
                      color: AppTokens.iconTertiary(context),
                    )
                  : null,
              enabled: !_isReadOnly,
              onTap: !_isReadOnly
                  ? () async {
                      final picked = await _showMonthStartDayPicker(
                        context,
                        initial: _monthStartDay,
                      );
                      if (picked != null) {
                        setState(() => _monthStartDay = picked);
                      }
                    }
                  : null,
            ),
          ),

          // ── 4. 成员管理 + 成员支出(常驻显示) ──
          //
          // 成员管理 / 成员支出在新建、编辑、本地、云端模式下均常驻显示:
          // - 新建态成员中必有当前用户(所有者),必定有数据;
          // - AA 分摊开关已并入成员管理模块内部,不单独占一个模块;
          // - 成员支出在新建态数据默认归 0,无需跟随云端。
          _buildMemberSections(context, l10n),
          // ── 5. 存储归属操作（仅编辑：已有本地账本的迁云入口）──
          if (_isEditing) _buildStorageActions(context, l10n),
        ],
      ),
    );
  }

  /// 成员协作区（成员管理 / 成员收支）
  ///
  /// 间距内化：隐藏时返回零高度 [SizedBox.shrink]（不带任何 Padding），
  /// 展示时由本方法自带 `Padding(top: 16)`。这样上层 [_buildBody] 无需为
  /// 本区预留独立间隔 —— 否则本区隐藏时那段间隔会变成"孤儿间隙"。
  Widget _buildMemberSections(BuildContext context, AppLocalizations l10n) {
    // 新建态 ledger 为 null：账本名称取输入框当前值；编辑态取账本名。
    final ledger = widget.ledger;
    final ledgerName = ledger?.name ?? _nameController.text.trim();

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成员管理模块自带标题行（色条 + "成员管理"），AA 开启时
          // 标题右侧显示"添加虚拟用户"文字链，无需外部再渲染标题。
          MemberManagementSection(
            // 新 schema 无 syncId：成员协作数据源标识置空（本地账本语义）。
            ledgerExternalId: null,
            ledgerName: ledgerName,
            ledgerId: ledger?.id,
            aaEnabled: _aaEnabled,
            onAaChanged: (v) => setState(() => _aaEnabled = v),
            isReadOnly: _isReadOnly,
            pendingVirtualUsers: _pendingVirtualUsers,
            onPendingVirtualUsersChanged: (list) => setState(
              // final 列表不允许整体替换,原地清空后填充即可
              () => _pendingVirtualUsers
                ..clear()
                ..addAll(list),
            ),
            // 邀请入口展示判断:
            // - 新建态:展示;
            // - 云端账本(isCloudLedger):展示;
            // - 本地账本(已存在、storageMode=local):不展示。
            showInviteEntry: _isCreating || (ledger?.isCloudLedger ?? false),
          ),
          // 成员支出常驻显示：新建态 / 本地账本时数据归 0 空态。模块自带标题。
          const SizedBox(height: AppDimens.p16),
          MemberStatsSection(ledgerId: ledger?.id),
        ],
      ),
    );
  }

  /// 账本归属操作区：编辑态按归属动态生成操作项。
  ///
  /// 设计意图：归属在创建时选择之后并非永远不变——
  ///   - 本地 + 非共享 → 移动到云端（参与同步）；
  ///   - 云端 + 非共享 → 移动到本地 + 复制到本地；
  ///   - 云端 + 共享   → 复制到本地（共享账本归属他人云端资源，只能留档）。
  /// 登录是硬门槛（移动动作需与服务端交互），未登录时全部禁用并给出登录引导。
  Widget _buildStorageActions(BuildContext context, AppLocalizations l10n) {
    final ledger = widget.ledger!;
    final loggedIn = ref.watch(currentLedgerAccountIdProvider) != null;

    final canMoveToCloud = !ledger.isCloudLedger && !ledger.isShared;
    final canMoveToLocal = ledger.isCloudLedger && !ledger.isShared;
    final canCopyToLocal = ledger.isCloudLedger;

    if (!canMoveToCloud && !canMoveToLocal && !canCopyToLocal) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, l10n.ledgersStorageLocation),
          const SizedBox(height: AppDimens.p8),
          Card(
            child: Column(
              children: [
                if (canMoveToCloud)
                  ListTile(
                    leading: const Icon(AppIcons.cloudUpload),
                    title: Text(l10n.ledgersActionMoveToCloud),
                    enabled: loggedIn,
                    onTap: loggedIn
                        ? () => _confirmStorageMove(
                            ledger,
                            title: l10n.ledgersActionMoveToCloud,
                            message: l10n.ledgersMoveToCloudMessage(
                              _editedNameForConfirm(ledger),
                            ),
                            successText: l10n.ledgersMoveToCloudSuccess,
                            action: () => ref
                                .read(ledgerStorageActionsProvider)
                                .moveToCloud(ledger.id),
                          )
                        : null,
                  ),
                if (canMoveToLocal) ...[
                  if (canMoveToCloud) const Divider(height: 1),
                  ListTile(
                    leading: const Icon(AppIcons.cloudDownload),
                    title: Text(l10n.ledgersActionMoveToLocal),
                    enabled: loggedIn,
                    onTap: loggedIn
                        ? () => _confirmStorageMove(
                            ledger,
                            title: l10n.ledgersActionMoveToLocal,
                            message: l10n.ledgersMoveToLocalMessage(
                              _editedNameForConfirm(ledger),
                            ),
                            successText: l10n.ledgersMoveToLocalSuccess,
                            action: () => ref
                                .read(ledgerStorageActionsProvider)
                                .moveToLocal(ledger.id),
                          )
                        : null,
                  ),
                ],
                if (canCopyToLocal) ...[
                  if (canMoveToCloud || canMoveToLocal)
                    const Divider(height: 1),
                  ListTile(
                    leading: const Icon(AppIcons.copy),
                    title: Text(l10n.ledgersActionCopyToLocal),
                    enabled: loggedIn,
                    onTap: loggedIn
                        ? () => _confirmStorageMove(
                            ledger,
                            title: l10n.ledgersActionCopyToLocal,
                            message: l10n.ledgersCopyToLocalMessage(
                              _editedNameForConfirm(ledger),
                            ),
                            successText: l10n.ledgersCopyToLocalSuccess,
                            // 复制只是云端留一份本地副本，云端原件归属不变，
                            // 编辑页快照仍然有效，无需 pop 回列表。
                            popAfter: false,
                            action: () => ref
                                .read(ledgerStorageActionsProvider)
                                .copyToLocal(ledger.id),
                          )
                        : null,
                  ),
                ],
                if (!loggedIn)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.p16,
                      0,
                      AppDimens.p16,
                      AppDimens.p12,
                    ),
                    child: Text(
                      l10n.ledgersSectionCloudSignInHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.textSecondary(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 确认文案用的账本名：以表单中正在编辑的名称为准（用户可能已改名未保存）。
  String _editedNameForConfirm(LedgerDisplayItem ledger) {
    final edited = _nameController.text.trim();
    return edited.isEmpty ? translateLedgerName(context, ledger.name) : edited;
  }

  /// 归属操作统一执行壳：二次确认 → 落盘未保存表单 → 执行 → 刷新 / 失败弹窗。
  ///
  /// 移动/复制都基于数据库当前值生成结果，必须先落盘表单里尚未保存的
  /// 元数据（尤其是名称 / AA 开关），否则会出现「界面上已开启、结果是关闭」
  /// 的假状态；保存被用户取消（如币种变更确认）时中止归属操作。
  /// 失败回滚由 [LedgerStorageActions] 的单事务保证（移动/复制失败时账本原样
  /// 不动），这里只需把异常摊给用户。
  ///
  /// [popAfter] 控制成功后是否返回列表：移动到云端/本地会改变账本归属，
  /// 编辑页持有的快照会过期，必须 pop 回列表；复制到本地不改变云端原件，
  /// 快照仍有效，故不 pop。
  Future<void> _confirmStorageMove(
    LedgerDisplayItem ledger, {
    required String title,
    required String message,
    required String successText,
    required Future<void> Function() action,
    bool popAfter = true,
  }) async {
    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: title,
      message: message,
    );
    if (confirmed != true || !mounted) return;

    // 状态副作用与页面挂载解耦：用户操作后可能立即退出，ref 会随之失效。
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      // 协作者只读态（共享账本复制留档）无表单可保存，跳过落盘步骤。
      if (!_isReadOnly) {
        if (!_formKey.currentState!.validate()) return;
        final name = _nameController.text.trim();
        if (name.isEmpty) return;
        final saved = await _saveExistingLedger(name);
        if (!saved || !mounted) return;
      }

      // 移动含网络交互（推送/删除/确认），执行期间显示不可关闭 loading。
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await action();
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;

      container.read(ledgerListRefreshProvider.notifier).tick();
      container.invalidate(currentLedgerProvider);
      showToast(context, successText);
      if (popAfter) Navigator.of(context).pop();
    } catch (e, st) {
      logger.error('LedgerEditPage', '账本归属操作失败(${ledger.id})', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: AppLocalizations.of(context).commonFailed,
        message: AppLocalizations.of(context).commonOperationFailed,
      );
    }
  }

  /// 右上角「更多」菜单：收纳账本敏感操作（清空 / 删除 / 退出并删除）。
  ///
  /// 菜单项按角色动态生成，点击后调用对应的处理函数：
  /// - 所有者：清空账本
  /// - 共享账本 Owner：删除共享账本（云端 tombstone 级联踢人 + 广播）
  /// - 共享账本协作者：退出并删除（云端退出 + 清本地）
  /// - 个人账本：删除账本（本地删行 + 清残留偏好）
  Widget _buildMoreMenu(BuildContext context, AppLocalizations l10n) {
    final ledger = widget.ledger!;
    final isOwner = ledger.myRole == 'owner';
    final isShared = ledger.isShared;
    return AppPopupMenu(
      items: [
        if (isOwner)
          // 清空是可逆的警示级操作，用黄色与红色破坏级操作（删除/退出）区分
          AppMenuItem.action(
            value: 'clear',
            label: l10n.ledgersClear,
            color: AppTokens.warning(context),
          ),
        if (isShared && isOwner)
          AppMenuItem.action(
            value: 'delete_shared',
            label: l10n.ledgersDeleteShared,
            isDanger: true,
          ),
        if (isShared && !isOwner)
          AppMenuItem.action(
            value: 'leave_and_delete',
            label: l10n.ledgersLeaveAndDelete,
            isDanger: true,
          ),
        if (!isShared)
          AppMenuItem.action(
            value: 'delete',
            label: l10n.ledgersDelete,
            isDanger: true,
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'clear':
            _handleClearLedger();
          case 'delete_shared':
            _handleDeleteSharedLedgerAsOwner();
          case 'leave_and_delete':
            _handleLeaveAndDeleteSharedLedger();
          case 'delete':
            _handleDeleteLocalLedger();
        }
      },
    );
  }

  /// 底部保存按钮
  Widget _buildSaveButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: FilledButton(
        onPressed: _saving ? null : _handleSave,
        child: _saving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTokens.textOnPrimary(context),
                ),
              )
            : Text(_isCreating ? l10n.ledgersCreate : l10n.commonSave),
      ),
    );
  }

  /// 保存（新建或编辑）
  ///
  /// 编辑保存返回 false（数据缺失/加载失败）时不关闭页面，避免
  /// 「什么都没保存却退出」的误导；失败统一弹友好错误并保留现场。
  Future<void> _handleSave() async {
    if (_loadFailed) return;
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      if (_isCreating) {
        await _saveNewLedger(name);
      } else {
        final saved = await _saveExistingLedger(name);
        if (!saved) return;
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      logger.error('LedgerEditPage', '保存账本失败', e, st);
      if (mounted) {
        await AppDialog.error(
          context,
          title: AppLocalizations.of(context).commonFailed,
          message: AppLocalizations.of(context).commonOperationFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 新建账本
  ///
  /// 关键设计：本方法内所有「状态类副作用」（首快照、当前账本切换、列表刷新）
  /// 一律通过方法入口捕获的根 [ProviderContainer] 执行，与页面挂载状态解耦。
  /// 原因：用户新建后可能极快退出，此时 mounted 变 false，若用 ref 执行会被
  /// `if (!mounted) return` 整段跳过 —— 表现为「首快照没发 + 首本账本没被选中
  /// + 账本列表不刷新」。mounted 守卫只保留给真正需要 BuildContext 的 UI 反馈。
  Future<String?> _saveNewLedger(String name) async {
    // 必须在任何 await 之前捕获：此刻由按钮回调同步进入，context 必然有效。
    final container = ProviderScope.containerOf(context, listen: false);
    final actions = ref.read(ledgerActionsProvider);

    // 归属按用户选择落库（云端账本 = storage_mode='cloud'，由 push 建立服务端
    // 记录）；未登录时二次夹紧强制 local，杜绝「标了 cloud 却无同步能力」的孤儿账本。
    // AA 开关与起始日随 createLedger 一同落库，避免「先建后改」的中间态。
    final newLedgerId = await actions.create(
      name: name,
      currency: _currency,
      storageMode: _effectiveStorageMode,
      aaEnabled: _aaEnabled,
      monthStartDay: _monthStartDay,
    );

    // 新建态内存暂存的虚拟用户:拿到 ledgerId 后批量落库。
    // 用户新建时开启 AA 即可直接添加虚拟用户(无需先保存再回来配置),
    // 此处在账本创建成功时一并写入,保证开关与虚拟用户同事务生效。
    // 仓库暂无批量接口，用 Future.wait 并行写入，避免逐条串行拖慢保存。
    await Future.wait([
      for (final vu in _pendingVirtualUsers)
        actions.createPlaceholderMember(ledgerId: newLedgerId, name: vu.name),
    ]);
    // 落库完成后清空内存暂存,避免重复创建虚拟用户。
    _pendingVirtualUsers.clear();

    // 空账本场景切换到新账本：同样走 container，避免快速退出后「建了第一本
    // 账本却仍处于无当前账本」的状态。
    // Riverpod 3 下 container.read(StreamProvider.future) 会因临时监听器关闭而挂起，
    // 必须保持监听直到首值到达（见 readProviderFuture 说明）。
    final currentLedger = await readProviderFutureFromContainer(
      container,
      currentLedgerProvider.future,
    );
    if (currentLedger == null) {
      container.read(currentLedgerIdProvider.notifier).set(newLedgerId);
      container.invalidate(currentLedgerProvider);
    }
    // 列表刷新信号同理：账本列表页在本页 pop 后仍存活，必须收到
    container.read(ledgerListRefreshProvider.notifier).tick();

    // 仅 UI 反馈需要 mounted
    if (!mounted) return newLedgerId;
    showToast(context, AppLocalizations.of(context).ledgersCreateSuccess);
    return newLedgerId;
  }

  /// 编辑账本
  ///
  /// 与 [_saveNewLedger] 同理：写库完成后的「刷新信号 + 同步触发」是纯状态
  /// 副作用，必须走方法入口捕获的根 container。否则用户保存后极快退出时，
  /// ref 已随页面销毁失效，`ref.read` 抛错会被 _handleSave 静默吞掉 ——
  /// 表现为「改名已落库但列表不刷新 + 云端不同步」。
  ///
  /// 返回 false 表示未完成保存（数据缺失 / 用户取消），调用方不应关闭页面。
  Future<bool> _saveExistingLedger(String name) async {
    final ledger = widget.ledger!;
    // 协作者只读防御（第二道防线）：即使 UI 层被绕过（如直接调用保存），
    // 也不允许推送账本元信息变更。与隐藏保存按钮形成双重保险。
    if (ledger.isShared && ledger.myRole != 'owner') return false;
    // 必须在任何 await 之前捕获：此刻 context 必然有效。
    final container = ProviderScope.containerOf(context, listen: false);
    final ledgerData = await ref.read(ledgerActionsProvider).getById(ledger.id);
    // 数据缺失（如编辑页已过期）时不落任何字段，交由调用方保留页面。
    if (ledgerData == null || !mounted) return false;

    // 币种变更：确认弹窗 + updateLedger + 拉汇率 + 全量重算 + 刷新 + 同步
    final currencyChanged =
        _currency.toUpperCase() != ledgerData.currency.toUpperCase();
    if (currencyChanged) {
      final applied = await applyLedgerCurrencyChange(
        context,
        ref,
        ledgerId: ledger.id,
        newCurrency: _currency,
      );
      // 用户取消 → 整体中止
      if (!applied || !mounted) return false;
    }

    // 名称/起始日/AA 开关变更
    final nameChanged = name != ledgerData.name;
    final startDayChanged = _monthStartDay != ledgerData.monthStartDay;
    final aaChanged = _aaEnabled != ledgerData.aaEnabled;
    if (!nameChanged && !startDayChanged && !currencyChanged && !aaChanged) {
      // 无任何变更：视为保存成功，允许关闭页面。
      return true;
    }

    if (nameChanged || startDayChanged || aaChanged) {
      await ref
          .read(ledgerActionsProvider)
          .update(
            id: ledger.id,
            name: name,
            monthStartDay: _monthStartDay,
            // 未变更时传 null = 不更新(updateLedger 语义)
            aaEnabled: aaChanged ? _aaEnabled : null,
          );
    }

    // 刷新信号在 sync 之前发；走 container 与页面生命周期解耦，
    // 保证快速退出后列表页/统计页仍能收到信号。
    container.read(ledgerListRefreshProvider.notifier).tick();
    container.invalidate(currentLedgerProvider);
    // 汇总/统计刷新由统一数据变更信号自动驱动（写库即触发）。

    return true;
  }

  /// 清空账本
  Future<void> _handleClearLedger() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;
    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.ledgersClearTitle,
      message: l10n.ledgersClearMessage(
        translateLedgerName(context, ledger.name),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(ledgerActionsProvider).clearTransactions(ledger.id);

      if (!mounted) return;
      ref.read(cachedTransactionsProvider.notifier).set(null);
      if (!mounted) return;
      ref.read(ledgerListRefreshProvider.notifier).tick();
      showToast(context, l10n.ledgersClearSuccess);
    } catch (e, st) {
      logger.error('LedgerEditPage', '清空账本失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.commonFailed,
        message: l10n.commonOperationFailed,
      );
    }
  }

  /// 删除个人账本（本地删行 + 清残留偏好）。
  Future<void> _handleDeleteLocalLedger() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;

    final allLedgers = await ref.read(ledgerActionsProvider).getAll();
    if (!mounted) return;

    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.ledgersDeleteConfirm,
      message: l10n.ledgersDeleteMessage,
    );
    if (confirmed != true || !mounted) return;

    try {
      final current = ref.read(currentLedgerIdProvider);
      final deletedLedgerId = ledger.id;

      if (current == deletedLedgerId) {
        final remain = allLedgers
            .where((l) => l.id != deletedLedgerId)
            .toList();
        if (remain.isNotEmpty) {
          ref.read(currentLedgerIdProvider.notifier).set(remain.first.id);
        }
      }

      // 新 schema 无云端通道：本地直接删行，残留偏好一并清理。
      await ref.read(ledgerActionsProvider).delete(deletedLedgerId);
      await _removeLedgerLocalPrefs(deletedLedgerId);

      if (!mounted) return;
      ref.invalidate(currentLedgerProvider);
      ref.read(ledgerListRefreshProvider.notifier).tick();

      showToast(context, l10n.ledgersDeleted);
      // 删除成功后返回上一页
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      logger.error('LedgerEditPage', '删除个人账本失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.ledgersDeleteFailed,
        message: l10n.commonOperationFailed,
      );
    }
  }

  /// 协作者「退出并删除」共享账本：cloud-first 退出（成员置 LEFT）→
  /// 清本地数据。服务端 404（已退出/已被移除）幂等放行。
  Future<void> _handleLeaveAndDeleteSharedLedger() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;
    final allLedgers = await ref.read(ledgerActionsProvider).getAll();
    if (!mounted) return;

    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.ledgersLeaveAndDeleteConfirm,
      message: l10n.ledgersLeaveAndDeleteMessage(
        translateLedgerName(context, ledger.name),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(ledgerActionsProvider).leaveSharedLedger(ledger.id);
      if (!mounted) return;

      // 若删的是当前账本，切换走，避免 UI 指向已删账本。
      if (ref.read(currentLedgerIdProvider) == ledger.id) {
        final remain = allLedgers.where((l) => l.id != ledger.id).toList();
        if (remain.isNotEmpty) {
          ref.read(currentLedgerIdProvider.notifier).set(remain.first.id);
        }
      }
      ref.invalidate(currentLedgerProvider);

      showToast(context, l10n.ledgersLeaveAndDeleteSuccess);
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      logger.error('LedgerEditPage', '退出并删除共享账本失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.commonFailed,
        message: l10n.commonOperationFailed,
      );
    }
  }

  /// Owner「全局删除」共享账本：cloud-first 删除（服务端 tombstone 账本、
  /// 级联撤销邀请并广播 delete change）→ 清本地数据。
  Future<void> _handleDeleteSharedLedgerAsOwner() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;
    final allLedgers = await ref.read(ledgerActionsProvider).getAll();
    if (!mounted) return;

    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.ledgersDeleteSharedConfirm,
      message: l10n.ledgersDeleteSharedMessage(
        translateLedgerName(context, ledger.name),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(ledgerActionsProvider).deleteSharedAsOwner(ledger.id);
      if (!mounted) return;

      // 若删的是当前账本，切换走，避免 UI 指向已删账本。
      if (ref.read(currentLedgerIdProvider) == ledger.id) {
        final remain = allLedgers.where((l) => l.id != ledger.id).toList();
        if (remain.isNotEmpty) {
          ref.read(currentLedgerIdProvider.notifier).set(remain.first.id);
        }
      }
      ref.invalidate(currentLedgerProvider);

      showToast(context, l10n.ledgersDeleteSharedSuccess);
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      logger.error('LedgerEditPage', '删除共享账本失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.commonFailed,
        message: l10n.commonOperationFailed,
      );
    }
  }

  /// 清理被删账本的本地残留
  Future<void> _removeLedgerLocalPrefs(String ledgerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 与 currency_providers 的可见币种 key 格式保持一致（UUID 账本 id）。
      await prefs.remove('visibleCurrencies.$ledgerId');
    } catch (e) {
      logger.warning('LedgerEditPage', '清理可见币种 prefs 失败(非阻断): $e');
    }
  }

  /// 28 宫格月起始日选择器
  Future<int?> _showMonthStartDayPicker(
    BuildContext context, {
    required int initial,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    return showAppSheet<int>(
      context: context,
      child: AppSheet(
        title: l10n.ledgersMonthStartDay,
        subtitle: l10n.ledgersMonthStartDayHint,
        contentPadding: const EdgeInsets.only(top: AppDimens.p12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(28, (index) {
            final day = index + 1;
            final isSelected = initial == day;
            return InkWell(
              onTap: () => Navigator.pop(context, day),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  color: isSelected
                      ? primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primary : AppTokens.divider(context),
                  ),
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? primary
                        : AppTokens.textPrimary(context),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
