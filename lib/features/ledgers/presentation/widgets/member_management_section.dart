import 'ledger_invite_sheet.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/utils/text_validation.dart';
// 成员管理按 AA 设置、账本成员与虚拟成员分组。
// 邀请使用底部面板，虚拟成员名称直接在列表内编辑。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/features/ledgers/domain/member_mirror.dart';
import 'package:sesame_notes/features/ledgers/domain/pending_virtual_users.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/skeleton.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

// 账本编辑页通过统一出口使用待提交虚拟成员模型。
export 'package:sesame_notes/features/ledgers/domain/pending_virtual_users.dart'
    show PendingVirtualUser;

/// 成员管理模块
///
/// AA 开关独立设置，账本成员与虚拟成员分别展示。
/// 本地账本显示本人，云端账本按现有权限展示邀请和移除入口。
///
/// 卡片边缘与父页面内容区对齐，内部统一使用列表间距。
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
  });

  /// 账本 UUID(用于查询成员镜像表);null/空 = 新建态或本地账本。
  ///
  /// 为空时本模块展示所有者作为唯一成员。
  final String? ledgerExternalId;

  /// 账本名称，用于生成邀请分享文案。
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

  /// 是否展示"邀请新成员"入口。
  final bool showInviteEntry;

  @override
  ConsumerState<MemberManagementSection> createState() =>
      _MemberManagementSectionState();
}

class _MemberManagementSectionState
    extends ConsumerState<MemberManagementSection> {
  /// 新建态/本地账本下推导的当前设备身份(异步加载,用于派生所有者成员 id)。
  String _ownerSelfId = '';

  late final LedgerInviteController _inviteController;

  bool _addingVirtualUser = false;
  String? _addVirtualUserError;

  @override
  void initState() {
    super.initState();
    _inviteController = LedgerInviteController(
      ledgerId: widget.ledgerExternalId,
      ledgerName: widget.ledgerName,
      isReadOnly: widget.isReadOnly,
      createInvite: (ledgerId, expiresInHours) => ref
          .read(ledgerActionsProvider)
          .createInvite(ledgerId: ledgerId, expiresInHours: expiresInHours),
    );
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

  /// 父页面变化后同步邀请账本和权限，通知发生在本轮布局完成后。
  @override
  void didUpdateWidget(covariant MemberManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ledgerExternalId != widget.ledgerExternalId ||
        oldWidget.ledgerName != widget.ledgerName ||
        oldWidget.isReadOnly != widget.isReadOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _inviteController.updateLedger(
          ledgerId: widget.ledgerExternalId,
          ledgerName: widget.ledgerName,
          isReadOnly: widget.isReadOnly,
        );
      });
    }
  }

  /// 邀请状态随成员页面结束，晚到响应不会再通知面板。
  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
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

  /// 使用默认名称直接添加虚拟用户。
  ///
  /// 编辑态(有 ledgerId):直接写库,Stream 自动刷新列表。
  /// 新建态(无 ledgerId):在父组件内存暂存列表追加,保存时批量落库。
  Future<void> _addVirtualUser() async {
    if (_addingVirtualUser) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _addingVirtualUser = true;
      _addVirtualUserError = null;
    });
    try {
      if (_isCreatingMode) {
        // 新建态只暂存成员，已有账本直接提交本地事务及同步队列。
        widget.onPendingVirtualUsersChanged(
          addPendingVirtualUser(
            widget.pendingVirtualUsers,
            l10n.aaVirtualUserDefaultName,
          ),
        );
      } else {
        // 默认名编号:取现有虚拟用户数 + 1,避免重名。
        final existingCount =
            (ref
                        .read(
                          ledgerVirtualUserDisplaysProvider(widget.ledgerId!),
                        )
                        .value ??
                    const <LedgerMemberDisplay>[])
                .length;
        await createVirtualUser(
          ref.read(applicationReaderProvider),
          ledgerId: widget.ledgerId!,
          name: l10n.aaVirtualUserDefaultName(
            nextVirtualUserIndex(existingCount),
          ),
        );
      }
    } catch (error, stackTrace) {
      logger.error(
        'MemberManagementSection',
        '添加虚拟成员失败 ledger=${widget.ledgerId}',
        error,
        stackTrace,
      );
      if (mounted) setState(() => _addVirtualUserError = '添加失败，未保存');
    } finally {
      if (mounted) setState(() => _addingVirtualUser = false);
    }
  }

  /// 重命名虚拟用户(编辑态直接写库,新建态改内存列表)。
  Future<void> _renameVirtualUser({
    String? existingId,
    required int pendingIndex,
    required String newName,
  }) async {
    final name = normalizeName(newName);
    if (existingId != null) {
      await renameVirtualUser(
        ref.read(applicationReaderProvider),
        id: existingId,
        name: name,
      );
    } else {
      // 新建态:改内存暂存列表(空白名与越界下标不产生变化,不通知父组件)。
      final updated = renamePendingVirtualUser(
        widget.pendingVirtualUsers,
        pendingIndex,
        name,
      );
      if (!identical(updated, widget.pendingVirtualUsers)) {
        widget.onPendingVirtualUsersChanged(updated);
      }
    }
  }

  /// 删除虚拟用户(编辑态直接写库,新建态从内存列表移除)。
  ///
  /// 编辑态名下有账(被交易 aaParticipants 引用)不可删,
  /// 子仓抛 [StateError]，错误留在确认弹窗中供用户处理。
  Future<void> _deleteVirtualUser({
    String? existingId,
    required int pendingIndex,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (existingId != null) {
      await AppDialog.confirmAsync(
        context,
        title: l10n.commonDelete,
        message: l10n.aaVirtualUserDeleteConfirm(''),
        onConfirm: () =>
            deleteVirtualUser(ref.read(applicationReaderProvider), existingId),
        errorMessage: (error) =>
            error is StateError ? l10n.aaVirtualUserInUse : '删除失败，未保存',
      );
    } else {
      // 新建态:从内存暂存列表移除(越界下标不产生变化,不通知父组件)。
      final updated = removePendingVirtualUserAt(
        widget.pendingVirtualUsers,
        pendingIndex,
      );
      if (!identical(updated, widget.pendingVirtualUsers)) {
        widget.onPendingVirtualUsersChanged(updated);
      }
    }
  }

  /// 构建独立的 AA 设置和成员分组。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final virtualCount = !widget.aaEnabled
        ? 0
        : widget.pendingVirtualUsers.length +
              (_isCreatingMode
                  ? 0
                  : (ref
                                .watch(
                                  ledgerVirtualUserDisplaysProvider(
                                    widget.ledgerId!,
                                  ),
                                )
                                .value ??
                            const <LedgerMemberDisplay>[])
                        .length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.split,
                          size: AppDimens.icon20,
                          color: AppTokens.primary(context),
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Flexible(
                          child: Text(
                            l10n.ledgerAaLabel,
                            style: AppTextTokens.strongTitle(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      l10n.ledgerAaDescription,
                      style: AppTextTokens.label(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.p12),
              Semantics(
                label: l10n.ledgerAaLabel,
                child: Switch(
                  value: widget.aaEnabled,
                  onChanged: widget.isReadOnly ? null : widget.onAaChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.p20),
        _buildCardContent(context, l10n),
        if (widget.aaEnabled) ...[
          const SizedBox(height: AppDimens.p20),
          _buildGroupHeader(
            context,
            l10n.ledgerVirtualMembersTitle,
            count: virtualCount,
            trailing: widget.isReadOnly
                ? null
                : TextButton.icon(
                    onPressed: _addingVirtualUser ? null : _addVirtualUser,
                    icon: const Icon(AppIcons.add, size: AppDimens.icon16),
                    label: Text(l10n.commonAdd),
                    style: TextButton.styleFrom(
                      textStyle: AppTextTokens.label(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p8,
                      ),
                    ),
                  ),
          ),
          if (_addVirtualUserError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.p4),
              child: Text(
                _addVirtualUserError!,
                style: AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.error(context)),
              ),
            ),
          if (virtualCount > 0) ...[
            const SizedBox(height: AppDimens.p4),
            SectionCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Column(children: _buildVirtualUserRows()),
            ),
          ],
        ],
      ],
    );
  }

  /// 面板独立订阅邀请状态，重复打开时保留当前有效期和邀请码。
  Future<void> _showInviteSheet() async {
    if (widget.isReadOnly) return;
    final l10n = AppLocalizations.of(context);
    try {
      await showAppSheet<void>(
        context: context,
        child: LedgerInviteSheet(controller: _inviteController),
      );
    } catch (error, stackTrace) {
      logger.error('MemberManagementSection', '打开邀请面板失败', error, stackTrace);
      if (mounted) showToast(context, l10n.commonFailed);
    }
  }

  /// 分组人数紧邻统一标题左对齐，操作入口保持在行尾。
  Widget _buildGroupHeader(
    BuildContext context,
    String title, {
    int? count,
    Widget? trailing,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimens.p40),
      child: SectionTitle(
        title: title,
        padding: EdgeInsets.zero,
        titleTrailing: count == null
            ? null
            : Text(
                AppLocalizations.of(context).ledgerMemberCount(count),
                style: AppTextTokens.label(context),
              ),
        trailing: trailing,
      ),
    );
  }

  /// 成员卡片内容:无成员镜像模式展示所有者;有镜像模式查成员表。
  Widget _buildCardContent(BuildContext context, AppLocalizations l10n) {
    // 本地账本保持单机身份；云账本仅展示注册成员，虚拟成员独立分组。
    final membersAsync = _isNoSyncIdMode
        ? AsyncData(_buildOwnerAsMember())
        : ref.watch(ledgerMemberDisplaysProvider(widget.ledgerExternalId!));
    // 有成员镜像(云账本)时只展示 REGISTERED 成员，无镜像时展示合成的所有者行。
    final members = membersAsync.value == null
        ? null
        : visibleMemberDisplays(
            membersAsync.value!,
            hasMirror: !_isNoSyncIdMode,
          );
    return Column(
      children: [
        _buildGroupHeader(
          context,
          l10n.ledgerMembersTitle,
          count: members?.length,
          trailing:
              widget.showInviteEntry && !widget.isReadOnly && !_isCreatingMode
              ? TextButton.icon(
                  onPressed: _showInviteSheet,
                  icon: const Icon(AppIcons.personAdd, size: AppDimens.icon16),
                  label: Text(l10n.ledgerInviteMembers),
                  style: TextButton.styleFrom(
                    textStyle: AppTextTokens.label(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p8,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppDimens.p4),
        membersAsync.when(
          loading: () => _buildLoadingMemberCard(context),
          error: (_, _) => _buildErrorCard(l10n),
          data: (_) => _buildContent(context, members!, l10n),
        ),
      ],
    );
  }

  /// 加载态展示成员头像和名称骨架。
  Widget _buildLoadingMemberCard(BuildContext context) {
    final placeholderColor = AppTokens.surfaceSecondary(context);
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(radius: 16, backgroundColor: placeholderColor),
        title: const SkeletonBar(
          width: AppDimens.skeletonTitleWidth,
          height: AppDimens.p12,
        ),
      ),
    );
  }

  /// 真实错误态:展示错误文案 + 重试按钮,点击重试 invalidate provider 重拉。
  Widget _buildErrorCard(AppLocalizations l10n) {
    return SectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: AppStatusBanner(
        inset: true,
        icon: AppIcons.error,
        message: l10n.sharedMembersLoadFailed,
        action: TextButton(
          onPressed: () => ref.invalidate(
            ledgerMemberDisplaysProvider(widget.ledgerExternalId!),
          ),
          child: Text(l10n.sharedMembersRetry),
        ),
      ),
    );
  }

  /// 二次确认后移除协作者：服务端 REMOVED + 本地镜像同步，权限由服务端校验。
  Future<void> _confirmRemoveMember(
    LedgerMemberDisplay member,
    AppLocalizations l10n,
  ) async {
    final accountId = member.linkedAccountId;
    if (accountId == null || accountId.isEmpty) return;
    final removed = await AppDialog.confirmAsync(
      context,
      title: l10n.sharedMembersRemoveTitle,
      message: l10n.sharedMembersRemoveConfirm(member.displayName),
      confirmLabel: l10n.sharedMembersRemoveCta,
      onConfirm: () async {
        try {
          await ref
              .read(ledgerActionsProvider)
              .removeMember(
                ledgerId: widget.ledgerExternalId!,
                memberId: member.id,
                accountId: accountId,
              );
        } catch (error, stackTrace) {
          logger.error(
            'MemberManagementSection',
            '移除成员失败 member=${member.id}',
            error,
            stackTrace,
          );
          rethrow;
        }
      },
      errorMessage: (error) => cloudOperationErrorMessage(
        error,
        fallback: l10n.sharedMembersRemoveFailed,
      ),
    );
    if (!removed || !mounted) return;
    ref.read(refreshLedgerMemberDisplaysProvider)(widget.ledgerExternalId!);
    showToast(context, l10n.sharedMembersRemoved);
  }

  /// 账本成员列表按当前身份权限展示真实成员和直接移除入口。
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
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // —— 真实成员行 ——
          for (final m in members) ...[
            _MemberTile(
              ledgerId: widget.ledgerId,
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
            if (m != members.last)
              AppTokens.cardDivider(
                context,
                indent: 0,
                verticalGap: 0,
                height: 1,
              ),
          ],
        ],
      ),
    );
  }

  /// 新建态/本地账本:构造所有者行作为唯一成员。
  ///
  /// 新建态的新账本归属由登录身份决定：已登录建的
  /// 是云端本,所有者即当前云账号本人,展示云昵称;未登录新建与既有本地账本
  /// 保持固定本地身份「单机芝麻仔」。
  List<LedgerMemberDisplay> _buildOwnerAsMember() {
    final l10n = AppLocalizations.of(context);
    final ledgerId = widget.ledgerExternalId ?? '';
    final now = DateTime.now().toUtc();
    final account = ref.watch(accountStateProvider);
    // 归属判定与账本落库共用同一入口,避免展示口径与写入口径不一致。
    final cloudUserId = ref.watch(currentLedgerAccountIdProvider);
    final isCloudSelf =
        _isCreatingMode && cloudUserId != null && cloudUserId.isNotEmpty;
    if (isCloudSelf) {
      // 云账号本人:成员 id 与服务端为同一账号分配的成员 id 同源;
      // 昵称取本地资料缓存,未就绪时由成员行统一兜底「未知」。
      return [
        LedgerMemberDisplay(
          id: registeredMemberId(ledgerId, cloudUserId),
          ledgerId: ledgerId,
          displayName: account.profile?.displayName?.trim() ?? '',
          memberType: 'REGISTERED',
          linkedAccountId: cloudUserId,
          role: 'owner',
          avatarVersion: 0,
          status: 'ACTIVE',
          joinedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    }
    // 本地账本/新建态的 self member：id 按 uuidV5(ledgerId, localSelfId)
    // 派生（同账本稳定），与登录/退出无关。
    final memberId = localSelfMemberId(ledgerId, _ownerSelfId);
    return [
      LedgerMemberDisplay(
        id: memberId,
        ledgerId: ledgerId,
        displayName: l10n.mineLocalName,
        memberType: 'LOCAL',
        role: 'owner',
        avatarVersion: 0,
        status: 'ACTIVE',
        joinedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// 虚拟成员分组列表在 AA 开启时展示。
  ///
  /// 编辑态从成员展示 Provider 拉取;新建态从父组件内存暂存列表拉取。
  /// 每行：统一默认头像 + 可编辑名称 + 移除按钮。
  List<Widget> _buildVirtualUserRows() {
    final rows = <Widget>[];

    // 编辑态:从 Stream 拉取已落库虚拟用户。
    final List<LedgerMemberDisplay> existingUsers = !_isCreatingMode
        ? (ref
                  .watch(ledgerVirtualUserDisplaysProvider(widget.ledgerId!))
                  .value ??
              const <LedgerMemberDisplay>[])
        : const <LedgerMemberDisplay>[];

    // —— 已落库虚拟用户行(编辑态) ——
    for (var i = 0; i < existingUsers.length; i++) {
      if (rows.isNotEmpty) {
        rows.add(
          AppTokens.cardDivider(context, indent: 0, verticalGap: 0, height: 1),
        );
      }
      rows.add(
        _VirtualUserTile(
          key: ValueKey(existingUsers[i].id),
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
      if (rows.isNotEmpty) {
        rows.add(
          AppTokens.cardDivider(context, indent: 0, verticalGap: 0, height: 1),
        );
      }
      rows.add(
        _VirtualUserTile(
          key: ObjectKey(pending[i]),
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

/// 单个真实成员行展示头像、昵称、权限说明与角色标签。
class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.ledgerId,
    required this.member,
    this.onRemove,
  });

  /// 所属账本 id(供统一身份解析);null = 新建态。
  final String? ledgerId;

  final LedgerMemberDisplay member;

  /// 非空时显示移除按钮（Owner 视角下的协作者行）。
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isOwner = member.role == 'owner';
    // 昵称与本人判定统一走账本身份上下文,与成员支出/AA 分摊同一套解析链。
    // 本地身份行(LOCAL 成员,含新建态/本地账本的合成所有者)恒显固定本地
    // 身份并标记本人——其 id 与身份上下文的 self 成员派生命名空间不同,
    // 不能交给上下文解析,否则会落成「未知」;新建态(无账本 id)不查上下文。
    final identity = (ledgerId != null && ledgerId!.isNotEmpty)
        ? ref.watch(ledgerIdentityProvider(ledgerId!)).value
        : null;
    final sessionUserId = ref.watch(currentLedgerAccountIdProvider) ?? '';
    final isSelf =
        member.memberType == 'LOCAL' ||
        (identity?.isSelfOf(member.id) ??
            (member.linkedAccountId != null &&
                member.linkedAccountId!.isNotEmpty &&
                member.linkedAccountId == sessionUserId));
    final displayName = member.memberType == 'LOCAL'
        ? l10n.mineLocalName
        : (identity?.displayNameOf(member.id) ??
              (member.displayName.isNotEmpty
                  ? member.displayName
                  : l10n.aaUnknownUser));
    return Padding(
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Row(
        children: [
          isSelf
              ? const SelfAvatar(size: AppDimens.icon40)
              : MemberAvatar(
                  userId: member.linkedAccountId,
                  version: member.avatarVersion,
                  hasAvatar:
                      member.linkedAccountId != null &&
                      member.linkedAccountId!.isNotEmpty &&
                      member.avatarUrl != null &&
                      member.avatarUrl!.trim().isNotEmpty,
                  size: AppDimens.icon40,
                ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTokens.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppDimens.p4),
                Text(
                  isOwner
                      ? l10n.ledgerOwnerDescription
                      : l10n.ledgerEditorDescription,
                  style: AppTextTokens.label(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          if (isOwner)
            DetailListTag(
              label: l10n.sharedRoleOwner,
              foregroundColor: AppTokens.primary(context),
              backgroundColor: AppTokens.surfaceSelected(context),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: AppDimens.p4,
              ),
            )
          else
            Text(l10n.sharedRoleEditor, style: AppTextTokens.label(context)),
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

/// 虚拟成员行使用输入框编辑名称，并提供直接删除入口。
class _VirtualUserTile extends StatefulWidget {
  const _VirtualUserTile({
    super.key,
    required this.name,
    required this.isReadOnly,
    required this.onRename,
    required this.onDelete,
  });

  /// 当前虚拟用户名称。
  final String name;

  /// 协作者只读时禁用名称编辑和删除。
  final bool isReadOnly;

  /// 行内编辑完成后提交有效名称。
  final Future<void> Function(String) onRename;

  /// 删除回调。
  final VoidCallback onDelete;

  @override
  State<_VirtualUserTile> createState() => _VirtualUserTileState();
}

class _VirtualUserTileState extends State<_VirtualUserTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _dirty = false;
  bool _saving = false;
  String? _error;

  /// 输入状态随成员行保留，失焦统一提交，覆盖点击页签和左右滑动。
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  /// 同步成员流更新，保留用户正在输入但尚未提交的内容。
  @override
  void didUpdateWidget(covariant _VirtualUserTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name && !_dirty) {
      _controller.text = widget.name;
      _dirty = false;
    }
  }

  /// 释放输入与焦点状态，移除成员时不额外触发改名。
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 名称去空格后提交；空名称恢复当前名称，避免每次按键写库。
  Future<void> _handleFocusChange() async {
    if (_focusNode.hasFocus || !_dirty || widget.isReadOnly || _saving) return;
    final raw = _controller.text;
    if (raw.trim().isNotEmpty && !isValidName(raw)) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        ).commonNameInvalid(maxNameLength),
      );
      return;
    }
    final name = raw.trim().isEmpty ? '' : normalizeName(raw);
    _controller.text = name.isEmpty ? widget.name : name;
    if (name.isEmpty || name == widget.name) {
      setState(() {
        _dirty = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // 等待本地保存结果，失败时保留输入及待提交标记，重新失焦即可重试。
      await widget.onRename(name);
      _dirty = false;
    } catch (error, stackTrace) {
      logger.error('MemberManagementSection', '保存虚拟成员名称失败', error, stackTrace);
      if (mounted) setState(() => _error = '保存失败，未保存');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 构建与账本名称一致的输入色块，保留成员头像与删除按钮。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p12,
      ),
      child: Row(
        children: [
          const MemberAvatar(userId: null, size: AppDimens.icon40),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: widget.isReadOnly || _saving,
              textInputAction: TextInputAction.done,
              style: AppTextTokens.input(context).copyWith(
                color: widget.isReadOnly
                    ? Theme.of(context).disabledColor
                    : AppTokens.textPrimary(context),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.aaVirtualUserNameHint,
                errorText: _error,
                errorMaxLines: 2,
                constraints: const BoxConstraints(
                  minHeight: AppDimens.actionButtonMinHeight,
                ),
              ),
              onChanged: (_) => _dirty = true,
              onTapOutside: (_) => _focusNode.unfocus(),
              onSubmitted: (_) => _focusNode.unfocus(),
            ),
          ),
          const SizedBox(width: AppDimens.p8),
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
