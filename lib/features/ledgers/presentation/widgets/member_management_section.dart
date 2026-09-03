// 成员管理模块 — 列出账本成员(真实成员 + 虚拟用户),
// 并内嵌 AA 分摊开关与添加虚拟用户文字链。
//
// 设计意图:
// - 无论新建/编辑、本地/云端,本模块常驻显示。
//   新建态或本地账本(无成员镜像)时,成员列表展示"所有者(我)"。
// - AA 分摊开关作为本模块内部一个 SwitchListTile,跟随开关立即显示内容
//   (虚拟用户列表 + 添加入口),不依赖保存按钮。
// - 虚拟用户并入成员列表:编辑态直接写库,新建态在父组件内存暂存
//   (保存账本拿到 ledgerId 后批量落库),避免"保存→返回→重新进入→配置"的长路径。
// - 成员数据源:共享账本(成员数 > 1)查本地 LedgerMembers 镜像表,
//   单人/本地账本无成员表,展示"所有者(我)"。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/text_state_switch.dart';
import 'package:sesame_notes/shared/widgets/me_suffix.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/widgets/person_avatar.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';

/// 新建态下内存暂存的虚拟用户(保存账本拿到 ledgerId 后批量落库)。
///
/// 仅有 [name] 字段:新建态没有 ledgerId,无法直接写库,故在 UI 层暂存;
/// 用户点击保存后,父组件遍历此列表调用 [createVirtualUser] 批量创建。
class PendingVirtualUser {
  PendingVirtualUser({required this.name});

  /// 虚拟用户昵称。
  String name;
}

/// 成员管理模块
///
/// 作为内容版块内嵌在编辑账本页中:
/// - 标题行(色条 + "成员管理",AA 开启时右侧显示"添加虚拟用户"文字链)
/// - 成员卡片(真实成员 + 虚拟用户列表 + AA 开关)
///
/// 卡片外边距与页面内 Material Card 默认 margin(all: 4) 对齐。
class MemberManagementSection extends ConsumerStatefulWidget {
  const MemberManagementSection({
    super.key,
    required this.ledgerExternalId,
    required this.ledgerName,
    required this.ledgerId,
    required this.aaEnabled,
    required this.onAaChanged,
    required this.isReadOnly,
    required this.pendingVirtualUsers,
    required this.onPendingVirtualUsersChanged,
    required this.showInviteEntry,
    this.onInviteWithoutSyncId,
  });

  /// 账本 UUID(用于查询成员镜像表);null/空 = 新建态或本地账本。
  ///
  /// 为空时本模块展示"所有者(我)"作为唯一成员。
  final String? ledgerExternalId;

  /// 账本名称,保留用于兼容父组件传参(协作邀请已下线,暂无展示用途)。
  final String ledgerName;

  /// 本地账本 id(UUID);null = 新建态。
  ///
  /// 编辑态直接用此 id 拉取/写库虚拟用户;新建态虚拟用户在父组件内存暂存。
  final String? ledgerId;

  /// AA 分摊开关当前状态(父组件持有,跨页面一致)。
  final bool aaEnabled;

  /// AA 分摊开关变化回调(父组件更新状态,保存时一并落库)。
  final ValueChanged<bool> onAaChanged;

  /// 协作者只读判断:只读时禁用所有写操作(开关、虚拟用户增删改)。
  final bool isReadOnly;

  /// 新建态下内存暂存的虚拟用户列表(仅 ledgerId 为 null 时使用)。
  final List<PendingVirtualUser> pendingVirtualUsers;

  /// 新建态虚拟用户列表变化回调(增删改时通知父组件同步内存状态)。
  final ValueChanged<List<PendingVirtualUser>> onPendingVirtualUsersChanged;

  /// 是否展示"邀请新成员"入口(云协作邀请已下线,保留参数兼容父组件)。
  final bool showInviteEntry;

  /// 无成员镜像时点击"邀请新成员"的回调(云协作邀请已下线,保留参数兼容父组件)。
  final Future<void> Function()? onInviteWithoutSyncId;

  @override
  ConsumerState<MemberManagementSection> createState() =>
      _MemberManagementSectionState();
}

class _MemberManagementSectionState
    extends ConsumerState<MemberManagementSection> {
  /// 新建态/本地账本下推导的当前设备身份(异步加载,用于派生所有者成员 id)。
  String _ownerSelfId = '';

  /// 邀请码有效期选项:1 天 / 3 天 / 7 天。
  static const _expiryOptions = <int>[24, 72, 168];

  /// 邀请模块本地状态 — 有效期 / 已生成的邀请 / 生成中 / 错误信息 / 展开态。
  int _expiresInHours = 24;
  LedgerInvite? _generated;
  bool _inviteBusy = false;
  String? _inviteError;
  bool _inviteExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.ledgerExternalId == null || widget.ledgerExternalId!.isEmpty) {
      // 仅在无成员镜像(新建态/本地账本)时加载当前用户信息作为所有者展示。
      _loadCurrentUserInfo();
    } else {
      // 进入成员管理(成员身份页面)时按需刷新成员公开资料(幂等 + 防抖)。
      final container = ProviderScope.containerOf(context, listen: false);
      unawaited(
        refreshLedgerMemberDirectory(container, widget.ledgerExternalId!),
      );
    }
  }

  /// 加载本地设备身份,作为新建态/本地账本的所有者展示。
  ///
  /// 新建态没有成员镜像表,但账本创建者必然是当前用户,故从 localSelfId
  /// 推导本人成员 id;展示名按本地身份固定文案「单机芝麻仔」渲染。
  Future<void> _loadCurrentUserInfo() async {
    try {
      final selfId = await ref.read(localSelfIdProvider.future);
      if (!mounted) return;
      setState(() {
        _ownerSelfId = selfId;
      });
    } catch (_) {
      // 推导失败不影响 UI,所有者行仍会以固定本地身份展示。
    }
  }

  /// 是否为无成员镜像模式(新建态/本地账本)。
  bool get _isNoSyncIdMode =>
      widget.ledgerExternalId == null || widget.ledgerExternalId!.isEmpty;

  /// 是否为新建态(无 ledgerId,虚拟用户在内存暂存)。
  bool get _isCreatingMode => widget.ledgerId == null;

  /// 添加虚拟用户:自动分配默认名"虚拟用户1/虚拟用户2/..."。
  ///
  /// 编辑态(有 ledgerId):直接写库,Stream 自动刷新列表。
  /// 新建态(无 ledgerId):在父组件内存暂存列表追加,保存时批量落库。
  Future<void> _addVirtualUser() async {
    final l10n = AppLocalizations.of(context);
    // 默认名编号:取现有虚拟用户数 + 1,避免重名。
    final existingCount = _isCreatingMode
        ? widget.pendingVirtualUsers.length
        : (ref
                      .read(ledgerVirtualUserDisplaysProvider(widget.ledgerId!))
                      .value ??
                  const <LedgerMemberDisplay>[])
              .length;
    final defaultName = l10n.aaVirtualUserDefaultName(existingCount + 1);

    if (_isCreatingMode) {
      // 新建态:内存暂存,保存时批量落库。
      final updated = [
        ...widget.pendingVirtualUsers,
        PendingVirtualUser(name: defaultName),
      ];
      widget.onPendingVirtualUsersChanged(updated);
    } else {
      // 编辑态:直接写库。
      try {
        await createVirtualUser(
          ref,
          ledgerId: widget.ledgerId!,
          name: defaultName,
        );
      } catch (e) {
        if (mounted) showToast(context, '${l10n.commonFailed}: $e');
      }
    }
  }

  /// 重命名虚拟用户(编辑态直接写库,新建态改内存列表)。
  Future<void> _renameVirtualUser({
    String? existingId,
    required int pendingIndex,
    required String newName,
  }) async {
    final l10n = AppLocalizations.of(context);
    final name = newName.trim();
    if (name.isEmpty) return;
    if (existingId != null) {
      try {
        await renameVirtualUser(ref, id: existingId, name: name);
      } catch (e) {
        if (mounted) showToast(context, '${l10n.commonFailed}: $e');
      }
    } else {
      // 新建态:改内存暂存列表。
      final updated = [...widget.pendingVirtualUsers];
      if (pendingIndex >= 0 && pendingIndex < updated.length) {
        updated[pendingIndex] = PendingVirtualUser(name: name);
        widget.onPendingVirtualUsersChanged(updated);
      }
    }
  }

  /// 删除虚拟用户(编辑态直接写库,新建态从内存列表移除)。
  ///
  /// 编辑态名下有账(被交易 aaParticipants 引用)不可删,
  /// 子仓抛 [StateError],此处 catch 后 toast 提示。
  Future<void> _deleteVirtualUser({
    String? existingId,
    required int pendingIndex,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (existingId != null) {
      final confirmed = await AppDialog.confirm<bool>(
        context,
        title: l10n.commonDelete,
        message: l10n.aaVirtualUserDeleteConfirm(''),
      );
      if (confirmed != true || !mounted) return;
      try {
        await deleteVirtualUser(ref, existingId);
      } on StateError {
        if (mounted) showToast(context, l10n.aaVirtualUserInUse);
      } catch (e) {
        if (mounted) showToast(context, '${l10n.commonFailed}: $e');
      }
    } else {
      // 新建态:从内存暂存列表移除。
      final updated = [...widget.pendingVirtualUsers];
      if (pendingIndex >= 0 && pendingIndex < updated.length) {
        updated.removeAt(pendingIndex);
        widget.onPendingVirtualUsersChanged(updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行(色条 + "成员管理" + AA 分摊开关 + "添加虚拟用户"文字链)
        _buildHeader(context, l10n),
        const SizedBox(height: AppDimens.p8),
        // 云端账本的 Owner 可展开邀请新成员(邀请即编辑,无只读档)
        if (widget.showInviteEntry &&
            !widget.isReadOnly &&
            !_isCreatingMode) ...[
          _buildInviteSection(context, l10n),
          const SizedBox(height: AppDimens.p8),
        ],
        _buildCardContent(context, l10n),
      ],
    );
  }

  /// 内嵌邀请模块 — 默认收起只显示标题(personAdd + 「邀请新成员」),
  /// 点击标题展开内容,未生成时展示表单,已生成时展示邀请码分享视图。
  Widget _buildInviteSection(BuildContext context, AppLocalizations l10n) {
    final primary = Theme.of(context).colorScheme.primary;
    return Theme(
      // 不显示 ExpansionTile 默认的上下分割线,贴合 SectionCard 风格
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: _inviteExpanded,
        onExpansionChanged: (v) => setState(() => _inviteExpanded = v),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(
          top: AppDimens.p16,
          bottom: AppDimens.p4,
          left: AppDimens.p16,
          right: AppDimens.p16,
        ),
        leading: Icon(
          AppIcons.personAdd,
          size: AppDimens.icon16,
          color: primary,
        ),
        title: Text(
          l10n.sharedMembersInviteCta,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        // 收起朝右、展开朝下,指向明确
        trailing: Icon(
          _inviteExpanded ? AppIcons.chevronDown : AppIcons.chevronRight,
          size: AppDimens.icon16,
          color: AppTokens.iconTertiary(context),
        ),
        children: [
          if (_generated == null)
            _buildInviteForm(l10n)
          else
            _buildShareView(_generated!, l10n),
        ],
      ),
    );
  }

  /// 邀请表单 — 角色(固定编辑者,邀请即编辑)+ 有效期选择 + 生成按钮。
  Widget _buildInviteForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sharedInviteFormRole,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDimens.p8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.sharedRoleEditor),
              selected: true,
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p16),
        Text(
          l10n.sharedInviteFormExpiry,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDimens.p8),
        Wrap(
          spacing: 8,
          children: [
            for (final h in _expiryOptions)
              ChoiceChip(
                label: Text(_expiryLabel(h, l10n)),
                selected: _expiresInHours == h,
                onSelected: _inviteBusy
                    ? null
                    : (sel) {
                        if (sel) setState(() => _expiresInHours = h);
                      },
              ),
          ],
        ),
        const SizedBox(height: AppDimens.p20),
        FilledButton.icon(
          onPressed: _inviteBusy ? null : _generate,
          icon: const Icon(AppIcons.qrCode),
          label: _inviteBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.sharedInviteGenerate),
        ),
        if (_inviteError != null) ...[
          const SizedBox(height: AppDimens.p12),
          Text(
            _inviteError!,
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
        ],
        const SizedBox(height: AppDimens.p16),
        Text(
          l10n.sharedInviteWarning,
          style: AppTextTokens.label(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
      ],
    );
  }

  /// 邀请码分享视图 — 大号邀请码 + 有效期 + 复制 / 分享操作。
  Widget _buildShareView(LedgerInvite invite, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SelectableText(
            invite.code,
            style: AppTextTokens.display3(context).copyWith(letterSpacing: 6),
          ),
        ),
        // 生成响应必带 expires_at,展示失效时间。
        const SizedBox(height: AppDimens.p8),
        Center(
          child: Text(
            l10n.sharedInviteExpiresAt(
              invite.expiresAt.toLocal().toString().split('.').first,
            ),
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.textTertiary(context)),
          ),
        ),
        const SizedBox(height: AppDimens.p20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(AppIcons.copy),
                label: Text(l10n.sharedInviteCopyCode),
                onPressed: () => _copyInviteCode(invite, l10n),
              ),
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(AppIcons.share),
                label: Text(l10n.sharedInviteShareCode),
                onPressed: () => _share(invite, l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p20),
        Text(
          l10n.sharedInviteInstruction,
          style: TextStyle(color: AppTokens.textSecondary(context)),
        ),
        const SizedBox(height: AppDimens.p16),
        TextButton(
          onPressed: () {
            setState(() {
              _generated = null;
              _inviteError = null;
            });
          },
          child: Text(l10n.sharedInviteGenerateAnother),
        ),
      ],
    );
  }

  /// 生成邀请:按所选有效期调服务端,成功记录展示分享视图,失败提示重试。
  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context);
    final ledgerId = widget.ledgerExternalId;
    if (ledgerId == null || ledgerId.isEmpty) {
      if (mounted) showToast(context, l10n.sharedMembersSaveFirst);
      return;
    }
    setState(() {
      _inviteBusy = true;
      _inviteError = null;
    });
    try {
      final invite = await ref
          .read(ledgerActionsProvider)
          .createInvite(ledgerId: ledgerId, expiresInHours: _expiresInHours);
      if (!mounted) return;
      setState(() => _generated = invite);
    } catch (e) {
      if (!mounted) return;
      setState(() => _inviteError = l10n.commonFailed);
    } finally {
      if (mounted) setState(() => _inviteBusy = false);
    }
  }

  /// 复制邀请码到剪贴板。
  void _copyInviteCode(LedgerInvite invite, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: invite.code));
    showToast(context, l10n.commonCopied);
  }

  /// 调起系统分享,携带账本名与邀请码。
  Future<void> _share(LedgerInvite invite, AppLocalizations l10n) async {
    try {
      final message = l10n.sharedInviteShareText(
        widget.ledgerName,
        invite.code,
      );
      await SharePlus.instance.share(ShareParams(text: message));
    } catch (e) {
      if (mounted) showToast(context, l10n.commonFailed);
    }
  }

  /// 有效期标签:24 小时 → 1 天,其余按小时/天展示。
  String _expiryLabel(int hours, AppLocalizations l10n) {
    if (hours < 24) return l10n.sharedInviteExpiryHours(hours);
    return l10n.sharedInviteExpiryDays(hours ~/ 24);
  }

  /// 模块标题行:左侧色条 + "成员管理",右侧 AA 分摊开关(内部带状态文案),
  /// AA 开启后追加"添加虚拟用户"文字链。
  ///
  /// 标题行使用固定高度 44:开关(25)、色条与按钮高度各不相同,
  /// 固定高度 + 垂直居中可以保证标题行不随内容变化上下跳动;
  /// 开关状态在父组件持有,跟随开关立即显示/隐藏虚拟用户列表与
  /// "添加虚拟用户"入口。
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final primary = Theme.of(context).colorScheme.primary;
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: primary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: SizedBox(
        // 固定标题行高度:让开关/色条/按钮垂直居中,防止模块上下移动
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 3,
              height: 15,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(AppDimens.radius4),
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Text(l10n.sharedMembersPageTitle, style: titleStyle),
            const SizedBox(width: AppDimens.p12),
            // AA 分摊开关:状态文案内嵌在开关内部(开启/关闭文案不同),
            // 尺寸 100x30,宽度可容纳状态文案,高度与标题行紧凑对齐
            TextStateSwitch(
              width: 100,
              height: 30,
              value: widget.aaEnabled,
              // 协作者只读:禁用开关(onChanged=null 灰化)
              onChanged: widget.isReadOnly
                  ? null
                  : (v) => widget.onAaChanged(v),
              onLabel: l10n.aaSwitchOnLabel,
              offLabel: l10n.aaSwitchOffLabel,
            ),
            const Spacer(),
            if (widget.aaEnabled && !widget.isReadOnly)
              TextButton.icon(
                onPressed: _addVirtualUser,
                icon: const Icon(AppIcons.personAdd, size: AppDimens.icon12),
                label: Text(
                  l10n.aaAddVirtualUser,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.p8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 成员卡片内容:无成员镜像模式展示"所有者(我)";有镜像模式查成员表。
  Widget _buildCardContent(BuildContext context, AppLocalizations l10n) {
    // 无成员镜像模式:成员列表只展示"所有者(我)",不走成员表。
    if (_isNoSyncIdMode) {
      return _buildContent(context, _buildOwnerAsMember(), l10n);
    }

    // 有成员镜像模式:从本地 LedgerMembers 镜像表拉取成员列表。
    // 真实成员行只渲染 REGISTERED:PLACEHOLDER 由虚拟用户区块渲染;
    // 云账本成员列表只含 REGISTERED,不渲染 LOCAL 行,
    // 避免本人同时出现「单机芝麻仔」与云昵称两行。
    final membersAsync = ref.watch(
      ledgerMemberDisplaysProvider(widget.ledgerExternalId!),
    );

    return membersAsync.when(
      loading: () => _buildLoadingMemberCard(context, l10n),
      error: (_, _) => _buildErrorCard(context, l10n),
      data: (members) => _buildContent(
        context,
        members.where((m) => m.memberType == 'REGISTERED').toList(),
        l10n,
      ),
    );
  }

  /// 加载态:展示骨架行(头像 + 文本占位条)+ AA 开关区域占位。
  Widget _buildLoadingMemberCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;
    return SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: AppDimens.p8,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: Text(
                    l10n.sharedMembersLoadingHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 骨架行:头像占位 + 标题占位条
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: placeholderColor,
            ),
            title: _SkeletonBar(
              width: 120,
              height: 12,
              color: placeholderColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 真实错误态:展示错误文案 + 重试按钮,点击重试 invalidate provider 重拉。
  Widget _buildErrorCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.error,
              size: AppDimens.icon16,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: AppDimens.p8),
            Expanded(
              child: Text(
                l10n.sharedMembersLoadFailed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(
                ledgerMemberDisplaysProvider(widget.ledgerExternalId!),
              ),
              child: Text(l10n.sharedMembersRetry),
            ),
          ],
        ),
      ),
    );
  }

  /// 二次确认后移除协作者：服务端 REMOVED + 本地镜像同步，权限由服务端校验。
  Future<void> _confirmRemoveMember(
    LedgerMemberDisplay member,
    AppLocalizations l10n,
  ) async {
    final context = this.context;
    final ok = await AppDialog.confirm<bool>(
      context,
      title: l10n.sharedMembersRemoveTitle,
      message: l10n.sharedMembersRemoveConfirm(member.displayName),
      okLabel: l10n.sharedMembersRemoveCta,
    );
    if (ok != true || !mounted) return;
    final accountId = member.linkedAccountId;
    if (accountId == null || accountId.isEmpty) return;
    try {
      await ref
          .read(ledgerActionsProvider)
          .removeMember(
            ledgerId: widget.ledgerExternalId!,
            memberId: member.id,
            accountId: accountId,
          );
      if (!mounted) return;
      invalidateLedgerMemberDisplays(ref, widget.ledgerExternalId!);
      showToast(this.context, l10n.sharedMembersRemoved);
    } catch (_) {
      if (mounted) showToast(this.context, l10n.sharedMembersRemoveFailed);
    }
  }

  /// 成员列表 + 虚拟用户列表。
  ///
  /// 布局:SectionCard 内按顺序排列——
  /// 1. 真实成员行(所有者 / 协作者)
  /// 2. 虚拟用户行(可改名 / 可删除,AA 开启时显示)
  Widget _buildContent(
    BuildContext context,
    List<LedgerMemberDisplay> members,
    AppLocalizations l10n,
  ) {
    // 移除协作者仅 Owner 可操作：当前用户是否为 Owner 由成员镜像中
    // 的 owner 行 + 绑定账号判定（服务端权限仍是最终防线）。
    final sessionUserId = ref.watch(currentLedgerAccountIdProvider) ?? '';
    final isCurrentOwner = members.any(
      (m) => m.role == 'owner' && m.linkedAccountId == sessionUserId,
    );
    return SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
      child: Column(
        children: [
          // —— 真实成员行 ——
          for (final m in members) ...[
            _MemberTile(
              member: m,
              onRemove:
                  isCurrentOwner &&
                      !widget.isReadOnly &&
                      m.memberType != 'LOCAL' &&
                      m.role != 'owner' &&
                      m.linkedAccountId != sessionUserId
                  ? () => _confirmRemoveMember(m, l10n)
                  : null,
            ),
            if (m != members.last) const Divider(height: 1),
          ],

          // —— 虚拟用户行(AA 开启时显示) ——
          if (widget.aaEnabled)
            ..._buildVirtualUserRows(context, l10n, members),
        ],
      ),
    );
  }

  /// 新建态/本地账本:构造"所有者(我)"行作为唯一成员。
  ///
  /// 本地身份展示名固定为「单机芝麻仔」(纯名,「(我)」后缀由 _MemberTile
  /// 统一渲染),与云昵称无关。
  List<LedgerMemberDisplay> _buildOwnerAsMember() {
    final selfId = _ownerSelfId;
    // 本地账本/新建态的 self member：id 按 uuidV5(ledgerId, localSelfId)
    // 派生（同账本稳定），与登录/退出无关。
    final memberId = localSelfMemberId(widget.ledgerExternalId ?? '', selfId);
    return [
      LedgerMemberDisplay(
        id: memberId,
        ledgerId: widget.ledgerExternalId ?? '',
        displayName: AppLocalizations.of(context).mineLocalName,
        memberType: 'LOCAL',
        role: 'owner',
        avatarVersion: 0,
        status: 'ACTIVE',
        joinedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    ];
  }

  /// 虚拟用户行列表(AA 开启时在真实成员行下方展示)。
  ///
  /// 编辑态从成员展示 Provider 拉取;新建态从父组件内存暂存列表拉取。
  /// 每行:头像(person 图标)+ 可编辑名称 + 移除 icon。
  List<Widget> _buildVirtualUserRows(
    BuildContext context,
    AppLocalizations l10n,
    List<LedgerMemberDisplay> realMembers,
  ) {
    final rows = <Widget>[];

    // 编辑态:从 Stream 拉取已落库虚拟用户。
    final List<LedgerMemberDisplay> existingUsers = !_isCreatingMode
        ? (ref
                  .watch(ledgerVirtualUserDisplaysProvider(widget.ledgerId!))
                  .value ??
              const <LedgerMemberDisplay>[])
        : const <LedgerMemberDisplay>[];

    // 首个虚拟用户行前加分隔线(与真实成员行分隔)。
    bool needsLeadingDivider = realMembers.isNotEmpty;

    // —— 已落库虚拟用户行(编辑态) ——
    for (var i = 0; i < existingUsers.length; i++) {
      if (needsLeadingDivider || i > 0) {
        rows.add(const Divider(height: 1));
      }
      needsLeadingDivider = false;
      rows.add(
        _VirtualUserTile(
          name: existingUsers[i].displayName,
          isReadOnly: widget.isReadOnly,
          onRename: (newName) => _renameVirtualUser(
            existingId: existingUsers[i].id,
            pendingIndex: -1,
            newName: newName,
          ),
          onDelete: () => _deleteVirtualUser(
            existingId: existingUsers[i].id,
            pendingIndex: -1,
          ),
        ),
      );
    }

    // —— 内存暂存虚拟用户行(新建态) ——
    final pending = widget.pendingVirtualUsers;
    for (var i = 0; i < pending.length; i++) {
      if (needsLeadingDivider || i > 0) {
        rows.add(const Divider(height: 1));
      }
      needsLeadingDivider = false;
      rows.add(
        _VirtualUserTile(
          name: pending[i].name,
          isReadOnly: widget.isReadOnly,
          onRename: (newName) => _renameVirtualUser(
            existingId: null,
            pendingIndex: i,
            newName: newName,
          ),
          onDelete: () => _deleteVirtualUser(existingId: null, pendingIndex: i),
        ),
      );
    }

    return rows;
  }
}

/// 单个真实成员行:头像 + 名称 + (自己) + 角色标签。
///
/// 只展示一行标题(昵称优先、无昵称回退账号),不展示账号副标题,
/// 避免与昵称重复占用行高。
class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.member, this.onRemove});

  final LedgerMemberDisplay member;

  /// 非空时显示移除按钮（Owner 视角下的协作者行）。
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isOwner = member.role == 'owner';
    // 本人判定:本地账本 LOCAL 成员恒为本人;共享账本成员绑定当前账号
    // （linked_account_id == 当前登录 userId）即本人。
    final sessionUserId = ref.watch(currentLedgerAccountIdProvider) ?? '';
    final isSelf =
        member.memberType == 'LOCAL' ||
        (member.linkedAccountId != null &&
            member.linkedAccountId!.isNotEmpty &&
            member.linkedAccountId == sessionUserId);
    // 标题按身份口径解析:本人优先当前云 Profile 昵称/固定本地身份,
    // 即使成员行快照为空也不落「未知」;他人用成员目录昵称(注册即分配,
    // 恒非空),空昵称的防御兜底才用「未知」。
    final hasDisplayName = member.displayName.isNotEmpty;
    String displayName;
    if (isSelf && member.memberType == 'REGISTERED') {
      // 云昵称优先,资料缓存未就绪时回退成员行快照(正常恒非空)。
      final cloudName =
          ref.watch(accountStateProvider).profile?.displayName?.trim() ?? '';
      displayName = cloudName.isNotEmpty
          ? cloudName
          : (hasDisplayName ? member.displayName : l10n.aaUnknownUser);
    } else if (isSelf && member.memberType == 'LOCAL') {
      displayName = l10n.mineLocalName;
    } else {
      displayName = hasDisplayName ? member.displayName : l10n.aaUnknownUser;
    }
    return ListTile(
      dense: true,
      leading: _MemberAvatar(member: member),
      title: Row(
        children: [
          Flexible(child: Text(displayName, overflow: TextOverflow.ellipsis)),
          // 本人「(我)」后缀统一走共享 MeSuffix,保证各模块样式一致。
          if (isSelf) const MeSuffix(),
        ],
      ),
      // 角色标签贴最右；Owner 视角的协作者行追加移除按钮
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(isOwner ? l10n.sharedRoleOwner : l10n.sharedRoleEditor),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(AppIcons.personRemove, size: AppDimens.icon20),
              tooltip: l10n.sharedMembersRemoveCta,
              onPressed: onRemove,
              style: IconButton.styleFrom(
                foregroundColor: AppTokens.error(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// 加载骨架占位条 — 用于 [_buildLoadingMemberCard] 中成员行的标题占位。
/// 简单的灰色圆角条,不引入 shimmer 依赖,避免过度设计。
class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
    );
  }
}

/// 成员头像 — 本人优先用本地头像文件，其他成员走磁盘缓存；
/// 都没有或加载失败才回退 person 图标。
class _MemberAvatar extends ConsumerWidget {
  const _MemberAvatar({required this.member});

  final LedgerMemberDisplay member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 本人判定:本地账本 LOCAL 成员恒为本人;共享账本成员绑定当前账号即本人。
    final sessionUserId = ref.watch(currentLedgerAccountIdProvider) ?? '';
    final isSelf =
        member.memberType == 'LOCAL' ||
        (member.linkedAccountId != null &&
            member.linkedAccountId!.isNotEmpty &&
            member.linkedAccountId == sessionUserId);
    // 本人头像：云已登录且有云头像走成员缓存（上传后即时生效、离线可用）；
    // 本地本人/云无头像统一回退正式默认头像。
    if (isSelf) {
      final account = ref.read(accountStateProvider);
      final profile = account.profile;
      if (account.isAuthenticated && profile != null) {
        return MemberAvatar(
          userId: profile.userId,
          version: profile.avatarVersion,
          hasAvatar: profile.avatarUrl != null,
          size: AppDimens.icon40,
          iconSize: AppDimens.icon16,
        );
      }
      return const ClipOval(
        child: Image(
          image: AssetImage(kDefaultAvatarAsset),
          width: AppDimens.icon40,
          height: AppDimens.icon40,
          fit: BoxFit.cover,
        ),
      );
    }

    // 非本人真实成员:统一走磁盘缓存(断网可用),未配置头像/加载失败回退正式默认头像。
    return MemberAvatar(
      userId: member.linkedAccountId,
      // schema v1 无头像版本列,恒为 0,仅作本地缓存键兼容。
      version: 0,
      hasAvatar:
          member.linkedAccountId != null &&
          member.avatarUrl != null &&
          member.avatarUrl!.trim().isNotEmpty,
      size: AppDimens.icon40,
      iconSize: AppDimens.icon16,
    );
  }
}

/// 单个虚拟用户行:头像(person 图标)+ 可编辑名称 + 移除 icon。
///
/// 名称行内编辑,不弹窗。
class _VirtualUserTile extends StatefulWidget {
  const _VirtualUserTile({
    required this.name,
    required this.isReadOnly,
    required this.onRename,
    required this.onDelete,
  });

  /// 当前虚拟用户名称。
  final String name;

  /// 协作者只读:禁用名称编辑和删除。
  final bool isReadOnly;

  /// 重命名回调(行内编辑完成时触发)。
  final ValueChanged<String> onRename;

  /// 删除回调。
  final VoidCallback onDelete;

  @override
  State<_VirtualUserTile> createState() => _VirtualUserTileState();
}

class _VirtualUserTileState extends State<_VirtualUserTile> {
  /// 行内编辑控制器：由 State 持有并在 dispose 释放。
  ///
  /// 在 build 中每次新建 controller 会在父组件重建时丢失未失焦输入且无法释放；
  /// 由 State 持有后，滚动 / 刷新 / 无关重建都不会打断输入，也不会累积未释放的 controller。
  late final TextEditingController _controller;

  /// 是否已触发重命名回调（防止失焦 + 提交重复触发）；文本再次变化后复位。
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    if (_committed) return;
    _committed = true;
    final newText = _controller.text.trim();
    if (newText.isNotEmpty && newText != widget.name) {
      widget.onRename(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 自行布局而非用 ListTile:TextField 需限定宽度到「虚拟用户1」左右,
    // ListTile 的 title 会 Expanded 铺满,色块过宽与全局编辑框视觉不一致。
    // 左内边距取 12 与全局 ListTileTheme contentPadding 一致,
    // 保证真实成员行(ListTile)与虚拟用户行(自定义 Row)的头像左缘对齐。
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p12,
        AppDimens.p8,
        AppDimens.p12,
        AppDimens.p8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTokens.surfaceSecondary(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.person,
              size: AppDimens.icon16,
              color: AppTokens.iconSecondary(context),
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          // 固定宽度,仅容纳短昵称(如「虚拟用户1」),避免色块过宽。
          SizedBox(
            width: 140,
            child: TextField(
              controller: _controller,
              readOnly: widget.isReadOnly,
              // 文本变化后允许再次提交（否则首次提交后 _committed 恒为 true）。
              onChanged: (_) => _committed = false,
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.aaVirtualUserNameHint,
                hintStyle: TextStyle(color: AppTokens.textTertiary(context)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p12,
                  vertical: AppDimens.p8,
                ),
                // 与全局编辑框一致的色块样式(filled 背景 + 无描边圆角)
                filled: true,
                fillColor: AppTokens.surfaceInput(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextTokens.title(
                context,
              ).copyWith(color: AppTokens.textPrimary(context)),
              // 失焦时提交重命名(避免每次按键都写库)。
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                _commit();
              },
              onSubmitted: (_) => _commit(),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(AppIcons.personRemove, size: AppDimens.icon20),
            tooltip: l10n.commonDelete,
            onPressed: widget.isReadOnly ? null : widget.onDelete,
            style: IconButton.styleFrom(
              foregroundColor: AppTokens.error(context),
            ),
          ),
        ],
      ),
    );
  }
}
