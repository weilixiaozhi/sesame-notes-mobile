/// 账本身份上下文 —— 昵称 / 本人判定 / 头像上下文的统一解析出口。
///
/// 设计意图:
/// - 所有展示昵称与头像的页面(AA 分摊、成员支出、成员管理、交易详情、
///   AA 编辑)都从 [ledgerIdentityProvider] 取身份,禁止各自拼装解析逻辑;
/// - 账本归属判定走 [Ledger] 上的统一谓词 isCloudLedger
///   (storageMode == 'cloud' || memberCount > 1),共享账本即使 storageMode
///   未回填 'cloud' 也按云账本口径解析;
/// - self member 解析链:self_member_id(权威)→ 绑定当前云账号的 REGISTERED
///   成员 → 本地账本确定性派生的 LOCAL 成员 → 设备身份兜底;
/// - 云昵称读本地资料缓存(离线可用),资料缓存未就绪时回退成员行昵称,
///   最后兜底「未知」,绝不裸显 member id / user id;
/// - 本地账本不注入云身份(I-04):本人恒显固定本地身份「单机芝麻仔」。
library;

import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart'
    show authSessionProvider;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_kind.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/user_display_name_resolver.dart';
import 'package:sesame_notes/utils/member_id.dart';

/// 账本身份上下文(纯数据模型,展示名解析委托 [UserDisplayNameResolver])。
class LedgerIdentity {
  const LedgerIdentity({
    required this.selfMemberId,
    required this.localSelfName,
    required this.unknownName,
    this.isShared = false,
    this.cloudSelfUserId,
    this.cloudSelfName = '',
    this.memberMap = const {},
  });

  /// 账本是否共享(memberCount > 1);共享账本才渲染协作头像。
  final bool isShared;

  /// 本人成员 id(解析链见文件头注释);空串 = 未解析到本人。
  final String selfMemberId;

  /// 当前登录云账号 userId;仅云/共享账本注入,本地账本为 null(I-04)。
  final String? cloudSelfUserId;

  /// 当前云账号昵称(本地资料缓存,离线可用);空串 = 未就绪。
  final String cloudSelfName;

  /// 本地身份固定展示名(l10n.mineLocalName 纯名)。
  final String localSelfName;

  /// 无法解析展示名时的统一兜底文案(l10n.aaUnknownUser)。
  final String unknownName;

  /// 账本全部非 tombstone 成员(含 LEFT/REMOVED 与虚拟用户)。
  final Map<String, LedgerMemberDisplay> memberMap;

  /// 展示名解析器(每次构建;解析链唯一,禁止调用方另写一套)。
  UserDisplayNameResolver get _resolver => UserDisplayNameResolver(
    memberDisplayMap: memberMap,
    selfMemberId: selfMemberId,
    localSelfDisplayName: localSelfName,
    cloudSelfUserId: cloudSelfUserId,
    cloudSelfDisplayName: cloudSelfName.isEmpty ? null : cloudSelfName,
    virtualNames: virtualNames,
  );

  /// 虚拟用户名映射(PLACEHOLDER 成员 id → 名称)。
  Map<String, String> get virtualNames => {
    for (final e in memberMap.entries)
      if (e.value.memberType == 'PLACEHOLDER') e.key: e.value.displayName,
  };

  /// 解析 member id 为展示名(纯名,不含「(我)」后缀);
  /// 无法解析统一返回 [unknownName],绝不裸显原始 id。
  String displayNameOf(String? memberId) {
    final name = _resolver.resolve(memberId);
    return name.isEmpty ? unknownName : name;
  }

  /// 判定 member id 是否为本人:
  /// self member id 权威 / LOCAL 成员恒为本人 / 绑定当前云账号的成员。
  bool isSelfOf(String? memberId) => _resolver.isSelf(memberId);
}

/// 账本身份上下文 provider(family by 账本 UUID)。
///
/// watch [accountStateProvider] 与 [authSessionProvider]:登录 / 资料刷新 /
/// 头像更新都会重算身份,派生统计与 UI 随之自动重建——修复旧实现
/// ref.read 一次后缓存「未知」不再刷新的问题。
///
/// 不用 autoDispose:动作函数(authorMemberIdForLedger 等)以 ref.read(...future)
/// 单次读取,临时订阅关闭后 autoDispose 会销毁仍在加载的元素,触发
/// UnmountedRefException / disposed-during-loading;身份上下文体积小,
/// 常驻缓存可接受。
final ledgerIdentityProvider = FutureProvider.family<LedgerIdentity, String>((
  ref,
  ledgerId,
) async {
  // 成员行/账本行写入(含成员目录刷新落库)后重算身份。
  ref.watch(dataChangeSignalProvider);
  ref.watch(accountStateProvider);
  ref.watch(authSessionProvider);
  final repo = ref.watch(repositoryProvider);
  final l10n = lookupAppLocalizations(
    ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
  );
  final account = ref.read(accountStateProvider);
  final session = ref.read(authSessionProvider);
  // 当前云账号:会话优先(断网恢复时会话可能为空,回退资料缓存 userId)。
  final cloudUserId =
      session?.userId ??
      (account.isAuthenticated ? account.profile?.userId : null);
  final cloudName = account.isAuthenticated
      ? (account.profile?.displayName?.trim() ?? '')
      : '';

  final ledger = await repo.getLedgerById(ledgerId);
  if (ledger == null) {
    return LedgerIdentity(
      selfMemberId: '',
      localSelfName: l10n.mineLocalName,
      unknownName: l10n.aaUnknownUser,
    );
  }
  final isCloud = ledger.isCloudLedger;

  final members = await repo.getMembersByLedger(ledgerId);
  final memberMap = <String, LedgerMemberDisplay>{
    for (final m in members) m.id: m.toDisplay(),
  };

  // ---- self member 解析链 ----
  var selfMemberId = ledger.selfMemberId;
  if ((selfMemberId == null || selfMemberId.isEmpty) &&
      !ledger.isLocalLedger &&
      cloudUserId != null &&
      cloudUserId.isNotEmpty) {
    // 绑定当前云账号的 REGISTERED 成员:登录绑定后 self_member_id 应已回写,
    // 此兜底覆盖回写缺失/历史脏数据,避免本人解析成「未知」。
    for (final m in members) {
      if (m.memberType == 'REGISTERED' && m.linkedAccountId == cloudUserId) {
        selfMemberId = m.id;
        break;
      }
    }
  }
  if (selfMemberId == null || selfMemberId.isEmpty) {
    if (ledger.isLocalLedger) {
      // 本地账本:确保确定性派生的 LOCAL self 成员存在(幂等)。
      final localSelfId = await ref.read(localSelfIdProvider.future);
      try {
        final member = await repo.ensureLocalSelfMember(
          ledgerId: ledgerId,
          localSelfId: localSelfId,
          displayName: l10n.mineLocalName,
        );
        selfMemberId = member.id;
        memberMap.putIfAbsent(member.id, () => member.toDisplay());
      } catch (e, st) {
        // 成员行创建失败时降级确定性派生 id,展示层仍可解析为固定本地身份。
        logger.warning('LedgerIdentity', 'self 成员行创建失败,降级派生 id', '$e\n$st');
        selfMemberId = localSelfMemberId(ledgerId, localSelfId);
      }
    } else {
      // 云端账本无任何绑定信息:回退设备身份(仅用于「我」兜底判定)。
      selfMemberId = await ref.read(localSelfIdProvider.future);
    }
  }

  return LedgerIdentity(
    isShared: ledger.memberCount > 1,
    selfMemberId: selfMemberId ?? '',
    // 本地账本不注入云身份(I-04):本人恒显固定本地身份。
    cloudSelfUserId: isCloud ? cloudUserId : null,
    cloudSelfName: isCloud ? cloudName : '',
    localSelfName: l10n.mineLocalName,
    unknownName: l10n.aaUnknownUser,
    memberMap: memberMap,
  );
});
