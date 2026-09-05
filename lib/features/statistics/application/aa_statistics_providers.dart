/// AA 分摊 Provider 层。
///
/// 设计意图:
/// - 新增 AA 分摊统计查询、虚拟用户 CRUD 状态入口。
/// - 全部写操作走 [LocalRepository](保证 sync 登记统一,禁止绕过)。
/// - 读操作直接走子仓查询,UI 通过 ref.watch 自动响应数据变化。
///
/// Provider 职责:
/// - [aaEnabledProvider]:账本 AA 开关(读写)。
/// - [ledgerVirtualUsersProvider]:账本虚拟用户列表(Stream)。
/// - 虚拟用户 CRUD 动作函数(createVirtualUser/renameVirtualUser/deleteVirtualUser)。
/// - [aaStatisticsProvider]:账本 AA 分摊汇总(纯计算,依赖交易+成员+虚拟用户)。
library;

import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' show Ledger, LedgerMember;
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/user_display_name_resolver.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/features/statistics/application/aa_member_detail_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';

/// 本地账本自我参与人的展示名:固定本地身份「单机芝麻仔」,
/// 与云昵称无关(本地身份与云身份独立,I-04)。
/// 仅返回纯名字,「(我)」后缀由 UI 层基于 isSelf 标记用共享
/// meSuffixSpan/MeSuffix 统一渲染,不在数据层拼接。
String _localSelfName(AppLocalizations l10n) => l10n.mineLocalName;

/// 当前操作者成员 id：优先账本 self_member_id；本地账本未设置时
/// 按 uuidV5(ledgerId, localSelfId) 派生并确保成员行存在。
///
/// 供分摊编辑页默认支出人展示/锁定使用;与落库层 operatorMemberId 的身份
/// 解析口径一致。身份与登录账号解耦：登录/退出只改绑定，不改成员 id。
Future<String> authorMemberIdForLedger(WidgetRef ref, String ledgerId) async {
  final repo = ref.read(repositoryProvider);
  final ledger = await repo.getLedgerById(ledgerId);
  final selfMemberId = ledger?.selfMemberId;
  if (selfMemberId != null && selfMemberId.isNotEmpty) {
    return selfMemberId;
  }
  final localSelfId = await ref.read(localSelfIdProvider.future);
  if (ledger != null && ledger.storageMode == 'local') {
    try {
      final member = await repo.ensureLocalSelfMember(
        ledgerId: ledgerId,
        localSelfId: localSelfId,
        // 本地身份展示名固定为「单机芝麻仔」纯名。
        displayName: _localSelfName(
          lookupAppLocalizations(
            ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
          ),
        ),
      );
      return member.id;
    } catch (e, st) {
      // 普通记账已落库时，作者补记失败不能把整个保存流程变成失败。
      logger.warning('AaStatistics', 'self 成员创建失败，降级设备身份', '$e\n$st');
    }
    // 成员行创建失败时仍返回确定性派生成员 id(uuidV5),展示层可解析为
    // 本人固定身份,绝不裸写设备 localSelfId(否则展示为「未知」)。
    return localSelfMemberId(ledgerId, localSelfId);
  }
  // 非导入记账路径保留既有兜底；导入会在写入前单独校验成员身份。
  return localSelfId;
}

/// 解析账本 self member id：优先 ledger.self_member_id（登录绑定后写入）；
/// 本地账本未设置时按 uuidV5(ledgerId, localSelfId) 派生并确保成员行存在。
Future<String> _selfMemberIdFor(
  Ref ref,
  Ledger? ledger,
  String ledgerId,
) async {
  final selfMemberId = ledger?.selfMemberId;
  if (selfMemberId != null && selfMemberId.isNotEmpty) {
    return selfMemberId;
  }
  final repo = ref.read(repositoryProvider);
  final localSelfId = await ref.read(localSelfIdProvider.future);
  if (ledger != null && ledger.storageMode == 'local') {
    final member = await repo.ensureLocalSelfMember(
      ledgerId: ledgerId,
      localSelfId: localSelfId,
      displayName: _localSelfName(
        lookupAppLocalizations(
          ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
        ),
      ),
    );
    return member.id;
  }
  return localSelfId;
}

/// 账本成员镜像表查询(key = 账本 UUID)。
///
/// 管理与新建交易只展示 ACTIVE 成员；LEFT/REMOVED 由历史汇总单独读取。
final ledgerMembersProvider = FutureProvider.autoDispose
    .family<List<LedgerMember>, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);
      final repo = ref.watch(repositoryProvider);
      try {
        final members = await repo.getMembersByLedger(ledgerId);
        return members.where((member) => member.status == 'ACTIVE').toList();
      } catch (e, st) {
        logger.error('AaStatistics', '读取账本成员失败 ledgerId=$ledgerId', e, st);
        rethrow;
      }
    });

/// 页面使用的活动成员展示列表；底层 Row 仅留在 application 内部。
final ledgerMemberDisplaysProvider = FutureProvider.autoDispose
    .family<List<LedgerMemberDisplay>, String>((ref, ledgerId) async {
      final members = await ref.watch(ledgerMembersProvider(ledgerId).future);
      return members.map((member) => member.toDisplay()).toList();
    });

/// 账本成员展示映射(全量非 tombstone,含 LEFT/REMOVED;key = member id)。
///
/// 供首页交易列表、详情 sheet、编辑器作者位等展示路径解析创建者/编辑者/
/// 支出人昵称:历史交易仍引用已离开成员,必须保留其展示名。
final ledgerMemberDisplayMapProvider = FutureProvider.autoDispose
    .family<Map<String, LedgerMemberDisplay>, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);
      final repo = ref.watch(repositoryProvider);
      try {
        final members = await repo.getMembersByLedger(ledgerId);
        return {for (final m in members) m.id: m.toDisplay()};
      } catch (e, st) {
        logger.error('AaStatistics', '读取账本成员展示映射失败 ledgerId=$ledgerId', e, st);
        rethrow;
      }
    });

/// 成员写入后同时刷新 Row 查询缓存与页面展示缓存。
void invalidateLedgerMemberDisplays(WidgetRef ref, String ledgerId) {
  ref.invalidate(ledgerMembersProvider(ledgerId));
  ref.invalidate(ledgerMemberDisplaysProvider(ledgerId));
  ref.invalidate(ledgerMemberDisplayMapProvider(ledgerId));
}

/// 当前账本的 AA 分摊开关(Stream,自动响应 ledger.aaEnabled 变更)。
///
/// UI(账本设置页开关)watch 此 provider 即可实时反映开关状态;
/// 写入走 [setAaEnabled] 动作函数。
final aaEnabledProvider = StreamProvider<bool>((ref) {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  final repo = ref.watch(repositoryProvider);
  return repo.watchLedger(ledgerId).map((l) => l?.aaEnabled ?? false);
});

/// 切换账本 AA 分摊开关(动作函数)。
///
/// 走 [LocalRepository.updateLedger] 保证 changeTracker 登记 sync
/// (aaEnabled 必须跨设备同步)。
Future<void> setAaEnabled(WidgetRef ref, String ledgerId, bool enabled) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.updateLedger(id: ledgerId, aaEnabled: enabled);
    // 失效账本流,确保 UI 立即刷新。
    ref.invalidate(currentLedgerProvider);
  } catch (e, st) {
    logger.error(
      'AaStatistics',
      'setAaEnabled 失败 ledger=$ledgerId enabled=$enabled',
      e,
      st,
    );
    rethrow;
  }
}

/// 账本虚拟用户列表(Stream,自动响应增删改)。
///
/// family by ledgerId,UI(分摊设置/编辑页)watch 此 provider 渲染参与人选项。
/// 账本占位成员列表（原虚拟用户，memberType=PLACEHOLDER）。
/// 保留 provider 名以兼容既有 UI 引用；类型统一为 LedgerMember。
final ledgerVirtualUsersProvider = StreamProvider.autoDispose
    .family<List<LedgerMember>, String>((ref, ledgerId) {
      final repo = ref.watch(repositoryProvider);
      return repo
          .watchMembersByLedger(ledgerId)
          .map(
            (members) => members
                .where(
                  (member) =>
                      member.memberType == 'PLACEHOLDER' &&
                      member.status == 'ACTIVE',
                )
                .toList(),
          );
    });

/// 页面使用的活动占位成员展示列表。
final ledgerVirtualUserDisplaysProvider = Provider.autoDispose
    .family<AsyncValue<List<LedgerMemberDisplay>>, String>((ref, ledgerId) {
      return ref
          .watch(ledgerVirtualUsersProvider(ledgerId))
          .whenData(
            (members) => members
                .map((member) => member.toDisplay())
                .toList(growable: false),
          );
    });

/// 新建虚拟用户(动作函数)。
///
/// 走 [LocalRepository.createVirtualUser] 委托层,保证 changeTracker 登记 sync
/// (虚拟用户是 ledger-scoped 同步实体,change log 走 create)。
/// 失败时抛错由调用方(UI)展示友好提示。
Future<String> createVirtualUser(
  WidgetRef ref, {
  required String ledgerId,
  required String name,
}) async {
  try {
    final repo = ref.read(repositoryProvider);
    return await repo.createPlaceholderMember(ledgerId: ledgerId, name: name);
  } catch (e, st) {
    logger.error('AaStatistics', '新建虚拟用户失败 ledger=$ledgerId name=$name', e, st);
    rethrow;
  }
}

/// 重命名虚拟用户(动作函数)。
Future<void> renameVirtualUser(
  WidgetRef ref, {
  required String id,
  required String name,
}) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.renameMember(id: id, name: name);
  } catch (e, st) {
    logger.error('AaStatistics', '重命名虚拟用户失败 id=$id name=$name', e, st);
    rethrow;
  }
}

/// 删除虚拟用户(动作函数,硬删)。
///
/// 名下有账(被交易 aaParticipants 引用)不可删,
/// 子仓抛 [StateError],调用方(UI)catch 后展示友好提示。
Future<void> deleteVirtualUser(WidgetRef ref, String id) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.deleteMember(id);
  } on StateError {
    // 名下有账不可删,向上透传让 UI 展示。
    rethrow;
  } catch (e, st) {
    logger.error('AaStatistics', '删除虚拟用户失败 id=$id', e, st);
    rethrow;
  }
}

/// 按账本归属解析当前操作者 member id。
///
/// 供分摊编辑页默认支出人展示/锁定使用,与落库层 operatorMemberId 的身份
/// 解析口径一致,避免页面直接依赖 TxAuthorService。
Future<String?> currentOperatorIdForLedger(WidgetRef ref, String ledgerId) =>
    authorMemberIdForLedger(ref, ledgerId);

/// 账本 AA 参与人选项列表(真实成员 + 虚拟用户)。
///
/// 供编辑器 AA 区块、AaEditPage、交易详情页统一取参与人名册,
/// 标识口径与 [aaStatisticsProvider] 一致(真实成员 userId、虚拟用户 id)。
/// watch [dataChangeSignalProvider] 让成员变更后自动重取。
///
/// 单人/本地账本(成员数 = 1)无成员表,此处会把 owner 自动纳入参与人
/// 名册,避免参与人选择器在单人账本场景下出现空列表、用户无从下手。
final aaParticipantOptionsProvider = FutureProvider.autoDispose
    .family<List<AaParticipantOption>, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final options = <AaParticipantOption>[];

      final ledger = await repo.getLedgerById(ledgerId);
      final isSharedLedger = (ledger?.memberCount ?? 0) > 1;
      final isCloudLedger = ledger?.storageMode == 'cloud';
      // 云/共享账本才注入云账号身份;本地账本本人恒显固定本地身份。
      final account = isCloudLedger ? ref.read(accountStateProvider) : null;
      final locale =
          ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale;
      final l10n = lookupAppLocalizations(locale);

      if (isSharedLedger) {
        // 共享账本:从 ledgerMembersProvider 取真实成员(userId 为参与人标识)。
        try {
          final members = await ref.read(
            ledgerMembersProvider(ledgerId).future,
          );
          // 本人判定 = 该账本 self member（登录后由绑定服务写入）。
          final selfMemberId = await _selfMemberIdFor(ref, ledger, ledgerId);
          // 本人云昵称:仅云/共享账本使用当前云 Profile。
          final selfCloudName = isCloudLedger
              ? account?.profile?.displayName?.trim() ?? ''
              : '';
          for (final m in members.where(
            (member) => member.memberType != 'PLACEHOLDER',
          )) {
            final dn = m.displayName;
            final name = m.id == selfMemberId && selfCloudName.isNotEmpty
                ? selfCloudName
                : dn;
            options.add(
              AaParticipantOption(
                id: m.id,
                // 昵称恒非空(注册即分配);空昵称的防御兜底用「未知」。
                name: name.isNotEmpty ? name : l10n.aaUnknownUser,
                isVirtual: m.memberType == 'PLACEHOLDER',
                // 本人标记:UI 据此统一渲染「(我)」后缀,与成员管理模块一致。
                isSelf: m.id == selfMemberId,
              ),
            );
          }
        } catch (e, st) {
          logger.warning(
            'AaStatistics',
            '读取账本成员失败 ledger=$ledgerId,成员选项降级为空',
            '$e\n$st',
          );
        }
      } else {
        // 单人/本地账本:把 self member 纳入参与人名册,
        // 保证参与人选择器至少有一个可选项。
        // 展示名按账本归属:本地账本固定「单机芝麻仔」,单人云账本显云昵称
        // (「(我)」后缀由 UI 层统一渲染)。
        final selfMemberId = await _selfMemberIdFor(ref, ledger, ledgerId);
        final cloudName = isCloudLedger
            ? account?.profile?.displayName?.trim() ?? ''
            : '';
        options.add(
          AaParticipantOption(
            id: selfMemberId,
            name: cloudName.isNotEmpty ? cloudName : _localSelfName(l10n),
            isVirtual: false,
            isSelf: true,
          ),
        );
      }

      // 占位成员(原虚拟用户):UUID 作为参与人标识(与统计口径一致)。
      final placeholderMembers = await repo.getMembersByLedger(ledgerId);
      for (final vu in placeholderMembers.where(
        (member) =>
            member.memberType == 'PLACEHOLDER' && member.status == 'ACTIVE',
      )) {
        options.add(
          AaParticipantOption(id: vu.id, name: vu.displayName, isVirtual: true),
        );
      }
      return options;
    });

/// 账本成员支出统计项(按 paidByUserId 聚合)。
///
/// 设计意图:成员支出模块需要包含虚拟用户的支出,而云端 memberStats 仅含
/// 真实成员。按交易 paidByUserId 本地聚合(支出人 = paidByUserId),
/// 关联参与人名册(真实成员 + 虚拟用户)拿展示名,与 AA 分摊统计口径一致。
class MemberExpenseStatItem {
  const MemberExpenseStatItem({
    required this.participantId,
    required this.displayName,
    required this.expenseTotal,
    required this.txCount,
    this.isSelf = false,
    this.isVirtual = false,
    this.avatarUrl,
    this.avatarVersion = 0,
  });

  /// 参与人标识(userId 或虚拟用户 id)。
  final String participantId;

  /// 展示名(真实成员 displayName/account、虚拟用户 name)。
  ///
  /// 本人时已剥离「(我)」后缀(仅保留纯名字),「(我)」标记由 UI 层
  /// 统一渲染,保证与成员管理模块的字号/颜色/空格一致。
  final String displayName;

  /// 该成员作为支出人的支出金额合计(单位:元;源为 Decimal 字符串,直接解析)。
  final double expenseTotal;

  /// 该成员作为支出人的支出笔数。
  final int txCount;

  /// 是否本人(当前用户);UI 据此追加「(我)」后缀,与成员管理模块一致。
  final bool isSelf;

  /// 是否虚拟用户(PLACEHOLDER);UI 据此回退 person 占位头像。
  final bool isVirtual;

  /// 服务端头像相对/绝对 URL(真实成员);虚拟用户为 null。
  final String? avatarUrl;

  /// 服务端头像版本号(真实成员);用于本地缓存键,虚拟用户为 0。
  /// 当前 schema 无版本列,恒为 0,保留字段仅为 UI 缓存键兼容。
  final int avatarVersion;
}

/// 账本成员支出统计(按 paidByUserId 聚合,含虚拟用户)。
///
/// 数据源:账本全部支出交易(txType='expense'),按 paidByUserId 分组聚合
/// 金额与笔数;展示名取参与人名册(真实成员 + 虚拟用户),与 AA 分摊统计
/// 口径一致。paidByUserId 为空的交易不计入(支出人未知,无法归属)。
final memberExpenseStatsProvider = FutureProvider.autoDispose
    .family<List<MemberExpenseStatItem>, String>((ref, ledgerId) async {
      // 监听统一数据变更信号:任何交易/成员/虚拟用户写入都会自动重算。
      // 头像版本参与 MemberAvatar 缓存键,换头像后自动重载,无需额外刷新信号。
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(ledgerId);
      if (ledger == null) return const [];

      // 账本全部支出交易(只统计支出,与首页/统计口径一致)。
      final allTx = await repo.getTransactionsByLedger(ledgerId);
      final expenseTx = allTx.where((t) => t.txType == 'expense').toList();

      // 按 paidByUserId 聚合:金额合计 + 笔数。paidByUserId 为空跳过(无法归属)。
      // 金额统一按「折本位币」(nativeAmount) 累加,与 AA 分摊统计口径一致,
      // 多币种账本下不把原币金额直接相加;历史未折算数据回退原金额。
      // 金额为规范化 Decimal 字符串(单位:元),用 Decimal 累加避免浮点误差,
      // 输出时直接 toDouble,无需再 /100。
      final amountMap = <String, Decimal>{};
      final countMap = <String, int>{};
      for (final t in expenseTx) {
        final pid = t.payerMemberId;
        if (pid == null || pid.isEmpty) continue;
        final amt =
            Decimal.tryParse(
              t.nativeAmount.isNotEmpty ? t.nativeAmount : t.amount,
            ) ??
            Decimal.zero;
        amountMap[pid] = (amountMap[pid] ?? Decimal.zero) + amt;
        countMap[pid] = (countMap[pid] ?? 0) + 1;
      }

      // 参与人名册 → 展示名映射(真实成员 + 虚拟用户),与 aaParticipantOptionsProvider 口径一致。
      final displayNameMap = <String, String>{};
      // 本人标记:单人/本地账本的 owner、共享账本中 userId == localSelfId 的
      // 成员均为「我」,由 UI 层统一渲染「(我)」后缀,与成员管理模块样式一致。
      final selfMap = <String, bool>{};
      // 真实成员的头像 URL(userId → server avatarUrl)
      final avatarUrlMap = <String, String?>{};
      // 占位成员(原虚拟用户):UUID 作为参与人标识。
      final allMembers = await repo.getMembersByLedger(ledgerId);
      final virtualUsers = allMembers.where(
        (m) => m.memberType == 'PLACEHOLDER',
      );
      for (final vu in virtualUsers) {
        displayNameMap[vu.id] = vu.displayName;
      }
      // 展示名统一走 UserDisplayNameResolver 口径:本地账本 self member
      // 固定「单机芝麻仔」,云账本本人显云昵称,解析不到映射「未知」。
      final selfMemberId = await _selfMemberIdFor(ref, ledger, ledgerId);
      final isCloudLedger = ledger.storageMode == 'cloud';
      final account = isCloudLedger ? ref.read(accountStateProvider) : null;
      final l10n = lookupAppLocalizations(
        ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
      );
      final resolver = UserDisplayNameResolver(
        memberDisplayMap: const {},
        selfMemberId: selfMemberId,
        localSelfDisplayName: l10n.mineLocalName,
        cloudSelfUserId: account?.profile?.userId,
        cloudSelfDisplayName: account?.profile?.displayName,
        virtualNames: {for (final vu in virtualUsers) vu.id: vu.displayName},
        l10n: l10n,
      );
      // 本人展示名:本地账本固定「单机芝麻仔」;云账本取当前云 Profile 昵称,
      // 资料缓存未就绪时回退成员行昵称,再回退「未知」。
      String selfDisplayName(String? rowName) {
        if (!isCloudLedger) return l10n.mineLocalName;
        final cloud = account?.profile?.displayName?.trim() ?? '';
        if (cloud.isNotEmpty) return cloud;
        if (rowName != null && rowName.isNotEmpty) return rowName;
        return l10n.aaUnknownUser;
      }

      // 历史支出需要保留 LEFT/REMOVED 成员的名称与头像；repository 已排除
      // tombstone，避免已删除成员重新进入任何业务读模型。
      if (ledger.memberCount > 1) {
        for (final member in allMembers) {
          final displayName = member.displayName;
          displayNameMap[member.id] = member.id == selfMemberId
              ? selfDisplayName(displayName)
              : (displayName.isNotEmpty ? displayName : l10n.aaUnknownUser);
          selfMap[member.id] = member.id == selfMemberId;
          avatarUrlMap[member.id] = member.avatarUrl;
        }
      } else {
        // 单人/本地账本:self member 即本人。
        LedgerMember? selfRow;
        for (final m in allMembers) {
          if (m.id == selfMemberId) {
            selfRow = m;
            break;
          }
        }
        displayNameMap[selfMemberId] = selfDisplayName(selfRow?.displayName);
        selfMap[selfMemberId] = true;
      }

      // 组装结果:仅保留有支出的参与人(amountMap 的 key),按金额降序。
      final items = <MemberExpenseStatItem>[];
      amountMap.forEach((pid, total) {
        final isSelf = selfMap[pid] ?? resolver.isSelf(pid);
        final name = displayNameMap[pid] ?? resolver.resolve(pid);
        items.add(
          MemberExpenseStatItem(
            participantId: pid,
            // 解析不到统一「未知」,不渲染空名也不裸显 id。
            displayName: name.isNotEmpty ? name : l10n.aaUnknownUser,
            expenseTotal: total.toDouble(),
            txCount: countMap[pid] ?? 0,
            isSelf: isSelf,
            isVirtual: virtualUsers.any((vu) => vu.id == pid),
            avatarUrl: avatarUrlMap[pid],
          ),
        );
      });
      items.sort((a, b) => b.expenseTotal.compareTo(a.expenseTotal));
      return items;
    });

/// 账本 AA 分摊汇总(纯计算,依赖交易+成员+虚拟用户)。
///
/// watch [dataChangeSignalProvider] 让任意写库(含云同步 pull)后自动重算。
final aaStatisticsProvider = FutureProvider.autoDispose
    .family<AaLedgerStatistics, String>((ref, ledgerId) async {
      // 依赖统一数据变更信号，交易、分摊或成员变化时自动重算。
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(ledgerId);
      if (ledger == null) {
        return AaLedgerStatistics(participants: const [], transfers: const []);
      }

      // 账本未开启 AA:返回空汇总(入口隐藏、历史数据不展示)。
      if (!ledger.aaEnabled) {
        return AaLedgerStatistics(participants: const [], transfers: const []);
      }

      // 1) 取账本全部 AA 交易(aaMode != 1,已过滤"不分摊")
      final aaTxs = await repo.getAaTransactionsByLedger(ledgerId);

      // 2) 取账本全部参与人:全部成员行(REGISTERED + PLACEHOLDER)
      final allMembers = await repo.getMembersByLedger(ledgerId);
      final virtualUsers = allMembers.where(
        (m) => m.memberType == 'PLACEHOLDER',
      );
      final participantIds = <String>[];
      final displayNameMap = <String, String>{};
      // 本人标记:成员 id == self member id,单人/本地账本 self member 恒为本人。
      final selfMap = <String, bool>{};
      final selfMemberId = await _selfMemberIdFor(ref, ledger, ledgerId);

      // 占位成员(原虚拟用户):UUID 作为参与人标识
      for (final vu in virtualUsers) {
        participantIds.add(vu.id);
        displayNameMap[vu.id] = vu.displayName;
      }

      // 历史汇总保留 LEFT/REMOVED 真实成员，避免成员退出后旧账金额消失；
      // repository 已统一排除 tombstone。
      // 本人展示名口径与成员支出一致:本地固定「单机芝麻仔」,云账本显云昵称。
      final isCloudLedger = ledger.storageMode == 'cloud';
      final account = isCloudLedger ? ref.read(accountStateProvider) : null;
      final l10n = lookupAppLocalizations(
        ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
      );
      String selfDisplayName(String? rowName) {
        if (!isCloudLedger) return l10n.mineLocalName;
        final cloud = account?.profile?.displayName?.trim() ?? '';
        if (cloud.isNotEmpty) return cloud;
        if (rowName != null && rowName.isNotEmpty) return rowName;
        return l10n.aaUnknownUser;
      }

      if (ledger.memberCount > 1) {
        for (final member in allMembers.where(
          (member) => member.memberType != 'PLACEHOLDER',
        )) {
          participantIds.add(member.id);
          final displayName = member.displayName;
          displayNameMap[member.id] = member.id == selfMemberId
              ? selfDisplayName(displayName)
              : (displayName.isNotEmpty ? displayName : l10n.aaUnknownUser);
          selfMap[member.id] = member.id == selfMemberId;
        }
      } else {
        // 单人/本地账本:无成员表,self member 即本人。
        participantIds.add(selfMemberId);
        LedgerMember? selfRow;
        for (final m in allMembers) {
          if (m.id == selfMemberId) {
            selfRow = m;
            break;
          }
        }
        displayNameMap[selfMemberId] = selfDisplayName(selfRow?.displayName);
        selfMap[selfMemberId] = true;
      }

      // 3) 预取指定分摊关系表行,供纯计算服务使用(人均/不分摊不落行)。
      final aaByTxId =
          <
            String,
            ({List<String>? participantIds, Map<String, String>? splits})
          >{};
      for (final tx in aaTxs) {
        aaByTxId[tx.id] = aaRowsToEditModel(
          (await repo.getTransactionSplits(
            tx.id,
          )).map((row) => row.toDisplay()).toList(growable: false),
        );
      }

      // 4) 调用纯计算服务
      return AaStatisticsService.computeLedger(
        transactions: aaTxs,
        allParticipants: participantIds,
        displayNameMap: displayNameMap,
        selfMap: selfMap,
        aaByTxId: aaByTxId,
      );
    });

/// 成员账单详情(按支出人维度汇总)。
///
/// 分摊详情表点击成员进入本详情页:只展示「该成员作为支出人」的 AA 账单
/// (aaMode != 1),并复用 [aaStatisticsProvider] 的参与人名册 / 本人标记 /
/// 汇总口径,保证详情页与分摊详情表的实付 / 应摊 / 差额完全一致。
///
/// 单笔账单的分摊明细由 [AaStatisticsService.computeTx] 重算(与账本级
/// 统计同一条计算路径),避免维护第二套分摊算法。
final aaMemberDetailProvider = FutureProvider.autoDispose
    .family<AaMemberDetailData?, ({String ledgerId, String participantId})>((
      ref,
      args,
    ) async {
      // 依赖账本级统计:成员/交易变化时详情页自动重算,且直接复用其结果中的
      // 参与人名册与本人标记,避免在 Provider 层再复制一份身份组装逻辑。
      final stats = await ref.watch(aaStatisticsProvider(args.ledgerId).future);
      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(args.ledgerId);
      if (ledger == null || !ledger.aaEnabled) return null;

      // 从统计结果中定位成员:统计结果包含全部参与人(含虚拟用户与兜底参与人),
      // 找不到说明该参与人已不在当前账本,直接返回 null 走空态兜底。
      AaParticipantSummary? member;
      for (final p in stats.participants) {
        if (p.participantId == args.participantId) {
          member = p;
          break;
        }
      }
      if (member == null) return null;

      // 参与人名册 / 显示名 / 本人标记均以统计结果为唯一来源,与分摊详情表一致。
      final participantIds = <String>[
        for (final p in stats.participants) p.participantId,
      ];
      final nameOf = <String, String>{
        for (final p in stats.participants) p.participantId: p.displayName,
      };
      final selfOf = <String, bool>{
        for (final p in stats.participants) p.participantId: p.isSelf,
      };

      // 取账本全部交易(带分类);watch 变体返回流,取首帧快照即可。
      // 成员详情本质是「首页支出列表按支出人筛选」:全部支出(含不分摊)
      // 都要展示,仅收入交易与未知支出人不归属任何成员。
      final all = await repo
          .watchTransactionsWithCategoryAll(ledgerId: args.ledgerId)
          .first;
      // 解析不到的展示名统一「未知」,绝不裸显 member id。
      final l10n = lookupAppLocalizations(
        ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
      );
      String nameOrUnknown(String? id) {
        if (id == null) return l10n.aaUnknownUser;
        final name = nameOf[id];
        return (name != null && name.isNotEmpty) ? name : l10n.aaUnknownUser;
      }

      final bills = <AaMemberBill>[];
      for (final it in all) {
        final tx = it.t;
        if (tx.txType != 'expense') continue; // 支出明细不含收入交易。
        final paidBy = tx.payerMemberId;
        if (paidBy == null || paidBy.isEmpty) continue; // 支出人未知,无法归属。
        if (paidBy != args.participantId) continue; // 只保留本人垫付的账单。

        final mode = AaMode.fromDb(tx.aaMode);
        // 不分摊(aaMode=1)不参与 AA 计算:整笔支出归本人,无分摊明细;
        // 指定分摊数据异常(如 aaSplits 为空)同样降级为整笔归本人。
        final result = mode == AaMode.noSplit
            ? null
            : AaStatisticsService.computeTx(
                tx: tx,
                allParticipants: participantIds,
                aaModel: aaRowsToEditModel(
                  (await repo.getTransactionSplits(
                    tx.id,
                  )).map((row) => row.toDisplay()).toList(growable: false),
                ),
              );
        if (result == null) {
          // 金额为 Decimal 字符串(单位:元),直接解析;解析失败兜底 0。
          final txTotal =
              Decimal.tryParse(
                tx.nativeAmount.isNotEmpty ? tx.nativeAmount : tx.amount,
              )?.toDouble() ??
              0;
          bills.add(
            AaMemberBill(
              tx: tx.toDisplay(),
              category: it.category?.toDisplay(),
              mode: mode,
              // 成员详情按账本本位币口径展示,与分摊详情表/汇总卡一致。
              totalAmount: txTotal,
              myShare: txTotal,
              payerName: nameOrUnknown(paidBy),
              splits: const [],
            ),
          );
          continue;
        }

        final shares = result.shares;
        bills.add(
          AaMemberBill(
            tx: tx.toDisplay(),
            category: it.category?.toDisplay(),
            mode: result.mode,
            totalAmount: result.paidAmount,
            // 本人应摊:人均模式全员在册;指定金额未填本人时兜底 0。
            myShare: shares[args.participantId] ?? 0,
            payerName: nameOrUnknown(result.paidBy),
            splits: [
              for (final e in shares.entries)
                AaMemberSplit(
                  participantId: e.key,
                  displayName: nameOrUnknown(e.key),
                  amount: e.value,
                  isSelf: selfOf[e.key] ?? false,
                ),
            ],
          ),
        );
      }
      // 按发生时间倒序,列表按日期分组时自然保持最新在前。
      bills.sort((a, b) => b.tx.happenedAt.compareTo(a.tx.happenedAt));

      return AaMemberDetailData(
        ledgerName: ledger.name,
        member: member,
        bills: bills,
      );
    });

/// 参与人头像上下文:参与人标识(userId) → 账本成员(含头像 URL)。
///
/// 供转账方案行渲染"昵称前头像"使用:真实成员取 avatarUrl,
/// 虚拟用户/未配置头像的成员无 URL,UI 层据此回退 person 占位图标。
/// 本地/单人账本无成员表,返回空映射,全部参与人走占位头像。
class AaParticipantAvatarContext {
  const AaParticipantAvatarContext({this.members = const {}});

  /// 参与人标识(userId) → 账本成员(共享账本才可能有数据)。
  final Map<String, LedgerMemberDisplay> members;
}

/// 账本参与人头像上下文(共享账本成员)。
///
/// watch [dataChangeSignalProvider] 让成员变更后自动刷新，
/// 与 [aaStatisticsProvider] 同源数据、口径一致。
final aaParticipantAvatarContextProvider = FutureProvider.autoDispose
    .family<AaParticipantAvatarContext, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(ledgerId);
      // 本地/单人账本(成员数 = 1)无成员表:返回空上下文,UI 统一走占位头像。
      if ((ledger?.memberCount ?? 0) <= 1) {
        return const AaParticipantAvatarContext();
      }
      try {
        // 头像上下文用于历史 AA 明细，保留 LEFT/REMOVED，repository 会隐藏 tombstone。
        final members = await repo.getMembersByLedger(ledgerId);
        return AaParticipantAvatarContext(
          members: {for (final m in members) m.id: m.toDisplay()},
        );
      } catch (e, st) {
        logger.warning(
          'AaStatistics',
          '读取账本成员头像失败 ledger=$ledgerId,头像上下文降级为空',
          '$e\n$st',
        );
        return const AaParticipantAvatarContext();
      }
    });
