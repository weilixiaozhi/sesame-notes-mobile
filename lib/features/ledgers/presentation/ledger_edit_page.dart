/// 账本编辑二级页面
///
/// 承载新建 / 编辑（本地+共享）两种模式。
/// 布局：页头、三个设置页签与底部保存按钮。
library;

import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';

import 'package:sesame_notes/utils/text_validation.dart';

import 'package:sesame_notes/data/models/sync_issue.dart';

import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/features/transactions/presentation/recurring_transaction_section.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
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
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 账本编辑二级页面
///
/// [ledger] 为 null 时表示新建模式；非 null 时为编辑模式。
class LedgerEditPage extends ConsumerStatefulWidget {
  final LedgerDisplayItem? ledger;

  const LedgerEditPage({super.key, this.ledger});

  @override
  ConsumerState<LedgerEditPage> createState() => _LedgerEditPageState();
}

/// 保留离屏页的表单校验、成员输入和邀请状态。
class _LedgerSettingsTab extends StatefulWidget {
  const _LedgerSettingsTab({required this.child});

  final Widget child;

  @override
  State<_LedgerSettingsTab> createState() => _LedgerSettingsTabState();
}

class _LedgerSettingsTabState extends State<_LedgerSettingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 将当前页交给 Flutter 的原生保活机制，供其他页触发统一保存。
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _LedgerEditPageState extends ConsumerState<LedgerEditPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late final TextEditingController _nameController;
  String _currency = '';
  int _monthStartDay = 1;
  bool _saving = false;
  String? _saveError;
  bool _initialized = false;
  // 编辑数据加载失败：进入错误态并禁止保存，避免用默认值覆盖真实配置。
  bool _loadFailed = false;

  /// AA 分摊开关(新建/编辑态,随「保存」落库;跨设备同步)。
  ///
  /// 开关内容(虚拟用户列表 / 分摊统计入口)跟随开关立即显示/隐藏,
  /// 不依赖保存按钮——开关本身是纯 UI 状态,无需保存即可配置。
  bool _aaEnabled = false;

  /// 新本使用当前服务与同步策略推导的归属，已有本子保持原绑定。
  String get _effectiveStorageMode => ref.read(newBookStorageModeProvider);

  /// 新建态下内存暂存的虚拟用户列表。
  ///
  /// 新建态账本尚未落库、没有 ledgerId,虚拟用户无法直接写库,因此先暂存在
  /// 内存;保存账本拿到新 ledgerId 后,由 [_saveNewLedger] 批量落库。
  /// 编辑态虚拟用户直接走数据库 CRUD,不经过此列表。
  final List<PendingVirtualUser> _pendingVirtualUsers = [];
  List<RecurringTransactionDisplay> _pendingRecurring = [];

  bool get _isEditing => widget.ledger != null;
  bool get _isCreating => widget.ledger == null;

  /// 归档后关闭当前设置入口，并阻止已排队的操作回调。
  bool _isArchived = false;

  /// 共享账本协作者只读；归档后的页面在退出前也禁止修改元信息。
  bool get _isReadOnly =>
      _isArchived ||
      (_isEditing &&
          widget.ledger!.isShared &&
          widget.ledger!.myRole != 'owner');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabChanged);
    // 注意：initState 中不能用 translateLedgerName(context, ...)，
    // 它依赖 AppLocalizations.of(context)（InheritedWidget），
    // 在 initState 完成前访问会抛 dependOnInheritedWidgetOfExactType 异常。
    // 名称输入框初始值用原始账本名，翻译仅用于标题展示（在 build 中调用）。
    _nameController = TextEditingController(
      text: widget.ledger != null ? widget.ledger!.name : '',
    );
    if (widget.ledger != null) {
      _updateArchiveState(widget.ledger!.isArchived);
      _currency = widget.ledger!.currency;
      _monthStartDay = 1; // 真实值在 _loadLedgerData 中异步加载
      _loadLedgerData();
      // 其他设备归档账本时，关闭当前设置页及其尚未提交的弹层。
      ref.listenManual(ledgerByIdProvider(widget.ledger!.id), (previous, next) {
        final ledger = next.value;
        if (ledger != null) _updateArchiveState(ledger.archivedAt != null);
      }, fireImmediately: true);
    } else {
      _initDefaultCurrency();
    }
  }

  /// 归档后返回进入设置前的页面，弹层与设置页一起关闭。
  void _updateArchiveState(bool archived) {
    if (!mounted || archived == _isArchived) return;
    setState(() => _isArchived = archived);
    if (!archived) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isArchived) return;
      try {
        final route = ModalRoute.of(context);
        final navigator = Navigator.of(context);
        // 关闭动画期间页面仍挂载，已退出导航栈的页面不能再次触发返回。
        if (route == null || !route.isActive) return;
        navigator.popUntil(
          (candidate) => candidate == route || candidate.isFirst,
        );
        if (route.isCurrent && navigator.canPop()) navigator.pop();
      } catch (error, stackTrace) {
        logger.error('LedgerEditPage', '关闭归档账本设置失败', error, stackTrace);
        if (mounted) {
          showToast(
            context,
            AppLocalizations.of(context).commonOperationFailed,
          );
        }
      }
    });
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
        _updateArchiveState(data.isArchived);
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
    _tabController.dispose();
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
            actions: _isEditing && !_isArchived
                ? [_buildMoreMenu(context, l10n)]
                : null,
          ),
          Expanded(
            child: _loadFailed
                ? AppLoadError(
                    message: l10n.categoryDetailLoadFailed,
                    onRetry: _retryLoad,
                  )
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

  /// 点击和滑动切换页签时结束当前输入，让行内编辑提交并收起键盘。
  void _handleTabChanged() {
    FocusScope.of(context).unfocus();
  }

  /// 页签共用现有保存入口，已访问的页保持挂载以保留表单校验与编辑状态。
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Material(
          color: AppTokens.surface(context),
          child: TabBar(
            controller: _tabController,
            labelStyle: AppTextTokens.body(context),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: AppTokens.textSecondary(context),
            indicatorColor: Theme.of(context).colorScheme.primary,
            dividerColor: AppTokens.divider(context),
            tabs: [
              Tab(text: l10n.ledgerBasicSettings),
              Tab(text: l10n.sharedMembersPageTitle),
              Tab(text: l10n.sharedMembersStatsTitle),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicSettings(context, l10n),
              ListView(
                key: const PageStorageKey('ledger-members'),
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [_buildMemberSection()],
              ),
              ListView(
                key: const PageStorageKey('ledger-member-expenses'),
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [MemberStatsSection(ledgerId: widget.ledger?.id)],
              ),
            ].map((page) => _LedgerSettingsTab(child: page)).toList(),
          ),
        ),
      ],
    );
  }

  /// 三个设置项分别使用统一区块标题与卡片，输入字号和尺寸保持一致。
  Widget _buildBasicSettings(BuildContext context, AppLocalizations l10n) {
    final valueStyle = AppTextTokens.input(context).copyWith(
      color: _isReadOnly
          ? Theme.of(context).disabledColor
          : AppTokens.textPrimary(context),
    );
    return Form(
      key: _formKey,
      child: ListView(
        key: const PageStorageKey('ledger-basic-settings'),
        padding: const EdgeInsets.all(AppDimens.p16),
        children: [
          const SizedBox(height: AppDimens.p16),
          AppFormSection(
            title: l10n.ledgerNameLabel,
            disabled: _isReadOnly,
            child: _isReadOnly
                ? InputDecorator(
                    decoration: _settingDecoration(),
                    child: Text(_nameController.text, style: valueStyle),
                  )
                : TextFormField(
                    key: const ValueKey('ledger-name-input'),
                    controller: _nameController,
                    style: valueStyle,
                    decoration: _settingDecoration().copyWith(
                      hintText: l10n.ledgerNameHint,
                    ),
                    validator: (value) {
                      if (!isValidName(value ?? '')) {
                        return l10n.ledgerNameLabel;
                      }
                      return null;
                    },
                  ),
          ),
          AppFormSection(
            title: l10n.ledgerBaseCurrencyLabel,
            disabled: _isReadOnly,
            child: _buildSettingPicker(
              key: const ValueKey('ledger-currency-input'),
              child: currencyFlagLabel(_currency, textStyle: valueStyle),
              onTap: !_isReadOnly
                  ? () async {
                      await prepareForOverlay();
                      if (!context.mounted) return;
                      final picked = await showCurrencyPickerSheet(
                        context,
                        selected: _currency.toUpperCase(),
                        title: l10n.ledgerBaseCurrencyLabel,
                        showRateAsBaseLabel: true,
                        visibleCurrencies: ref.read(visibleCurrenciesProvider),
                      );
                      if (picked != null && mounted) {
                        setState(() => _currency = picked);
                      }
                    }
                  : null,
            ),
          ),
          AppFormSection(
            title: l10n.ledgersMonthStartDay,
            disabled: _isReadOnly,
            child: _buildSettingPicker(
              key: const ValueKey('ledger-month-input'),
              child: Text(
                _monthStartDay <= 1
                    ? l10n.ledgersMonthStartDayNatural
                    : l10n.ledgersMonthStartDayValue(_monthStartDay),
                style: valueStyle,
              ),
              onTap: !_isReadOnly
                  ? () async {
                      final picked = await _showMonthStartDayPicker(
                        context,
                        initial: _monthStartDay,
                      );
                      if (picked != null && mounted) {
                        setState(() => _monthStartDay = picked);
                      }
                    }
                  : null,
            ),
          ),
          const SizedBox(height: AppDimens.p4),
          RecurringTransactionSection(
            ledgerId: widget.ledger?.id,
            readOnly: _isArchived || _saving || !_initialized,
            drafts: _pendingRecurring,
            draftCurrency: _currency,
            onDraftsChanged: (items) =>
                setState(() => _pendingRecurring = items),
          ),
        ],
      ),
    );
  }

  /// 输入框与选择入口使用同一填充容器，校验提示出现时允许自然增高。
  InputDecoration _settingDecoration() {
    return InputDecoration(
      enabled: !_isReadOnly,
      isDense: true,
      constraints: const BoxConstraints(
        minHeight: AppDimens.actionButtonMinHeight,
      ),
    );
  }

  /// 选择器沿用现有点击回调，只读时没有箭头和点击响应。
  Widget _buildSettingPicker({
    required Key key,
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return AppSelectionField(
      key: key,
      enabled: !_isReadOnly,
      onTap: onTap,
      child: child,
    );
  }

  /// 成员页沿用账本归属、只读权限和新建态虚拟成员暂存逻辑。
  Widget _buildMemberSection() {
    // 新建态 ledger 为 null：账本名称取输入框当前值；编辑态取账本名。
    final ledger = widget.ledger;
    final ledgerName = ledger?.name ?? _nameController.text.trim();

    return MemberManagementSection(
      // 云端/共享账本按账本 UUID 走成员镜像表(含进入页面的目录刷新);
      // 本地账本/新建态置空,展示固定「所有者」行。
      // 归属判定走统一谓词:共享账本即使 storageMode 未回填也按云口径。
      ledgerExternalId: ledger?.isCloudLedger == true ? ledger?.id : null,
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
      showInviteEntry:
          !_isArchived && (_isCreating || (ledger?.isCloudLedger ?? false)),
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
  /// 失败回滚由 [DataLifecycleActions] 的单事务保证（移动/复制失败时账本原样
  /// 不动），这里只需把异常摊给用户。
  ///
  /// [popAfter] 控制成功后是否返回列表：移动到云端/本地会改变账本归属，
  /// 编辑页持有的快照会过期，必须 pop 回列表；复制到本地不改变云端原件，
  /// 快照仍有效，故不 pop。
  Future<void> _confirmStorageMove({
    required String title,
    required String message,
    required String successText,
    required Future<void> Function() action,
    bool popAfter = true,
  }) async {
    if (!_isReadOnly && !_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    final confirmed = await AppDialog.confirmAsync(
      context,
      title: title,
      message: message,
      onConfirm: () async {
        if (!_isReadOnly) {
          final saved = await _saveExistingLedger(_nameController.text.trim());
          if (!saved) throw StateError('账本保存未完成');
        }
        await action();
      },
      errorMessage: (error) => cloudOperationErrorMessage(error),
    );
    if (!confirmed || !mounted) return;
    ref.read(ledgerListRefreshProvider.notifier).tick();
    ref.invalidate(currentLedgerProvider);
    showToast(context, successText);
    if (popAfter) Navigator.of(context).pop();
  }

  /// 右上角菜单集中放置复制留档与账本敏感操作。
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
    final loggedIn = ref.watch(currentLedgerAccountIdProvider) != null;
    return AppPopupMenu(
      items: [
        if (_initialized && !_loadFailed)
          AppMenuItem.action(value: 'archive', label: l10n.ledgersArchive),
        if (!isShared)
          loggedIn && _initialized && !_loadFailed
              ? AppMenuItem.action(
                  value: ledger.isCloudLedger
                      ? 'move_to_local'
                      : 'move_to_cloud',
                  label: ledger.isCloudLedger
                      ? l10n.ledgersActionMoveToLocal
                      : l10n.ledgersActionMoveToCloud,
                )
              : AppMenuItem.tip(
                  label: ledger.isCloudLedger
                      ? l10n.ledgersActionMoveToLocal
                      : l10n.ledgersActionMoveToCloud,
                ),
        if (ledger.isCloudLedger)
          loggedIn && _initialized && !_loadFailed
              ? AppMenuItem.action(
                  value: 'copy_to_local',
                  label: l10n.ledgersActionCopyToLocal,
                )
              : AppMenuItem.tip(label: l10n.ledgersActionCopyToLocal),
        if (isOwner)
          // 清空操作使用警示色，删除与退出使用危险操作样式。
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
        if (!mounted) return;
        if (_isArchived) {
          showToast(context, l10n.ledgersArchivedRestoreRequired);
          return;
        }
        switch (value) {
          case 'archive':
            _archiveLedger();
          case 'move_to_cloud':
            _confirmStorageMove(
              title: l10n.ledgersActionMoveToCloud,
              message: l10n.ledgersMoveToCloudMessage(
                _editedNameForConfirm(ledger),
              ),
              successText: l10n.ledgersMoveToCloudSuccess,
              action: () => ref
                  .read(dataLifecycleProvider)
                  .moveToCloud(SyncTarget('ledger', ledger.id)),
            );
          case 'move_to_local':
            _confirmStorageMove(
              title: l10n.ledgersActionMoveToLocal,
              message: l10n.ledgersMoveToLocalMessage(
                _editedNameForConfirm(ledger),
              ),
              successText: l10n.ledgersMoveToLocalSuccess,
              action: () => ref
                  .read(dataLifecycleProvider)
                  .moveToLocal(SyncTarget('ledger', ledger.id)),
            );
          case 'copy_to_local':
            _confirmStorageMove(
              title: l10n.ledgersActionCopyToLocal,
              message: l10n.ledgersCopyToLocalMessage(
                _editedNameForConfirm(ledger),
              ),
              successText: l10n.ledgersCopyToLocalSuccess,
              popAfter: false,
              action: () => ref
                  .read(dataLifecycleProvider)
                  .copyToLocal(SyncTarget('ledger', ledger.id)),
            );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_saveError != null) ...[
            Text(
              _saveError!,
              style: AppTextTokens.body(
                context,
              ).copyWith(color: AppTokens.error(context)),
            ),
            const SizedBox(height: AppDimens.p8),
          ],
          AppPrimaryButton(
            onPressed: !_initialized ? null : _handleSave,
            busy: _saving,
            label: _isCreating ? l10n.ledgersCreate : l10n.commonSave,
          ),
        ],
      ),
    );
  }

  /// 保存（新建或编辑）
  ///
  /// 编辑保存返回 false（数据缺失/加载失败）时不关闭页面，避免
  /// 「什么都没保存却退出」的误导；失败统一弹友好错误并保留现场。
  Future<void> _handleSave() async {
    if (_saving || _loadFailed || _isArchived) return;
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });
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
        setState(
          () =>
              _saveError = cloudOperationErrorMessage(e, fallback: '保存失败，未保存'),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 个人归档状态独立落库；成功返回列表，失败保留页面并显示可重试原因。
  Future<void> _archiveLedger() async {
    if (_saving || !_initialized || _loadFailed) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref
          .read(ledgerActionsProvider)
          .setArchived(widget.ledger!.id, true);
      if (!mounted) return;
      showToast(context, l10n.ledgersArchiveSuccess);
      _updateArchiveState(true);
    } catch (error, stackTrace) {
      logger.error(
        'LedgerEditPage',
        '归档账本失败 ledger=${widget.ledger!.id}',
        error,
        stackTrace,
      );
      if (mounted) {
        final message = cloudOperationErrorMessage(
          error,
          fallback: l10n.commonOperationFailed,
        );
        setState(() => _saveError = message);
        if (_isReadOnly && !_isArchived) showToast(context, message);
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
  Future<void> _saveNewLedger(String name) async {
    // 必须在任何 await 之前捕获：此刻由按钮回调同步进入，context 必然有效。
    final container = ProviderScope.containerOf(context, listen: false);
    final actions = ref.read(ledgerActionsProvider);

    // 登录身份决定新本归属；先落本机数据库，云端创建由后台队列完成。
    // AA 开关与起始日随 createLedger 一同落库，避免「先建后改」的中间态。
    final newLedgerId = await actions.create(
      name: name,
      currency: _currency,
      storageMode: _effectiveStorageMode,
      aaEnabled: _aaEnabled,
      monthStartDay: _monthStartDay,
      placeholderNames: [
        for (final member in _pendingVirtualUsers) member.name,
      ],
      recurring: _pendingRecurring,
    );
    // 落库完成后清空内存暂存,避免重复创建虚拟用户。
    _pendingVirtualUsers.clear();
    _pendingRecurring = [];

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
    if (!mounted) return;
    showToast(context, AppLocalizations.of(context).ledgersCreateSuccess);
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
    if (ledgerData.isArchived) {
      _updateArchiveState(true);
      return false;
    }

    // 币种变更：确认弹窗 + updateLedger + 拉汇率 + 全量重算 + 刷新 + 同步
    final currencyChanged =
        _currency.toUpperCase() != ledgerData.currency.toUpperCase();
    if (currencyChanged) {
      final applied = await applyLedgerCurrencyChange(
        context,
        ledgerId: ledger.id,
        newCurrency: _currency,
        name: name,
        monthStartDay: _monthStartDay,
        aaEnabled: _aaEnabled,
      );
      // 用户取消 → 整体中止
      return applied;
    }

    // 名称/起始日/AA 开关变更：无变更时视为保存成功但不落任何字段。
    final result = await ref
        .read(ledgerActionsProvider)
        .saveEdits(
          id: ledger.id,
          name: name,
          monthStartDay: _monthStartDay,
          aaEnabled: _aaEnabled,
        );
    if (!result.saved) return false;
    if (!result.changed) return true;

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
    final confirmed = await AppDialog.confirmAsync(
      context,
      title: l10n.ledgersClearTitle,
      message: l10n.ledgersClearMessage(
        translateLedgerName(context, ledger.name),
      ),
      onConfirm: () =>
          ref.read(ledgerActionsProvider).clearTransactions(ledger.id),
      errorMessage: (error) => cloudOperationErrorMessage(error),
    );
    if (!confirmed || !mounted) return;
    ref.read(ledgerListRefreshProvider.notifier).tick();
    showToast(context, l10n.ledgersClearSuccess);
  }

  /// 删除个人账本（本地删行 + 清残留偏好）。
  Future<void> _handleDeleteLocalLedger() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;

    final confirmed = await AppDialog.confirmAsync(
      context,
      title: l10n.ledgersDeleteConfirm,
      message: l10n.ledgersDeleteMessage,
      onConfirm: () => ref.read(ledgerActionsProvider).delete(ledger.id),
      errorMessage: (error) => cloudOperationErrorMessage(error),
    );
    if (!confirmed || !mounted) return;
    await selectFirstLedger(ref.read);
    if (!mounted) return;
    ref.invalidate(currentLedgerProvider);
    ref.read(ledgerListRefreshProvider.notifier).tick();
    showToast(context, l10n.ledgersDeleted);
    Navigator.of(context).pop();
  }

  /// 协作者「退出并删除」共享账本：cloud-first 退出（成员置 LEFT）→
  /// 清本地数据。服务端 404（已退出/已被移除）幂等放行。
  Future<void> _handleLeaveAndDeleteSharedLedger() async {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledger!;

    final confirmed = await AppDialog.confirmAsync(
      context,
      title: l10n.ledgersLeaveAndDeleteConfirm,
      message: l10n.ledgersLeaveAndDeleteMessage(
        translateLedgerName(context, ledger.name),
      ),
      onConfirm: () =>
          ref.read(ledgerActionsProvider).leaveSharedLedger(ledger.id),
      errorMessage: (error) => cloudOperationErrorMessage(
        error,
        fallback: l10n.commonOperationFailed,
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await selectFirstLedger(ref.read);
      if (!mounted) return;
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

    final confirmed = await AppDialog.confirmAsync(
      context,
      title: l10n.ledgersDeleteSharedConfirm,
      message: l10n.ledgersDeleteSharedMessage(
        translateLedgerName(context, ledger.name),
      ),
      onConfirm: () =>
          ref.read(ledgerActionsProvider).deleteSharedAsOwner(ledger.id),
      errorMessage: (error) => cloudOperationErrorMessage(
        error,
        fallback: l10n.commonOperationFailed,
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await selectFirstLedger(ref.read);
      if (!mounted) return;
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

  /// 选择 1–31 日作为每月周期起点，底部留白避开系统手势区域。
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
        contentPadding: const EdgeInsets.fromLTRB(
          AppDimens.p16,
          AppDimens.p12,
          AppDimens.p16,
          AppDimens.p20,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: AppDimens.p8,
              runSpacing: AppDimens.p8,
              children: List.generate(31, (index) {
                final day = index + 1;
                final isSelected = initial == day;
                return SizedBox.square(
                  dimension: AppDimens.p40,
                  child: ChoiceChip(
                    label: Text('$day'),
                    selected: isSelected,
                    showCheckmark: false,
                    labelPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: primary.withValues(alpha: 0.12),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: isSelected ? primary : AppTokens.divider(context),
                    ),
                    labelStyle: AppTextTokens.body(context).copyWith(
                      color: isSelected
                          ? primary
                          : AppTokens.textPrimary(context),
                    ),
                    onSelected: (_) => Navigator.pop(context, day),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
