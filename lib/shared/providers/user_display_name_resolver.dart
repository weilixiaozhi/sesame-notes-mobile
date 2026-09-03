import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 用户展示名统一解析器。
///
/// 解析优先级:
/// 1. 共享账本成员表(成员目录缓存,昵称恒非空——账号注册即分配昵称)
/// 2. 本人(selfMemberId,按账本归属分口径:
///    本地账本恒显固定本地身份「单机芝麻仔」;云账本显当前云 Profile 昵称)
/// 3. 虚拟用户名(由调用方传入)
/// 4. 无法解析返回空串,由 UI 统一映射「未知」——绝不裸显 member id / user id。
///
/// 「我」的判定以 self member id 为权威:登录/退出只改成员绑定不改 id,
/// 因此同一账本的本人恒为同一个成员,展示判定不随账号切换漂移。
class UserDisplayNameResolver {
  final Map<String, LedgerMemberDisplay> memberDisplayMap;

  /// 当前账本的本人成员 id(ledger.selfMemberId 权威;未设置时由调用方
  /// 按 uuidV5(ledgerId, localSelfId) 确定性派生传入)。
  final String selfMemberId;

  /// 本地账本本人的固定展示名(l10n.mineLocalName 纯名,
  /// 「(我)」后缀由 UI 层统一渲染)。
  final String localSelfDisplayName;

  /// 当前登录云账号 userId;仅云/共享账本场景由调用方传入。
  final String? cloudSelfUserId;

  /// 当前云账号昵称(恒非空;未登录或资料缓存未就绪时为 null)。
  /// 仅云/共享账本场景由调用方传入,本地账本必须传 null 以保持
  /// 本地身份与云身份独立(I-04)。
  final String? cloudSelfDisplayName;

  final Map<String, String> virtualNames;
  final AppLocalizations l10n;

  UserDisplayNameResolver({
    required this.memberDisplayMap,
    required this.selfMemberId,
    required this.localSelfDisplayName,
    this.cloudSelfUserId,
    this.cloudSelfDisplayName,
    required this.virtualNames,
    required this.l10n,
  });

  /// 解析 member id 为展示名。返回空串表示「无法解析」,
  /// 调用方按既有口径映射为「未知」(aaUnknownUser)。
  String resolve(String? memberId) {
    if (memberId == null || memberId.isEmpty) return '';

    // 1. 共享账本成员表:成员目录缓存的公开 Profile 昵称。
    final member = memberDisplayMap[memberId];
    if (member != null) {
      // 本人按账本归属分口径:本地账本 LOCAL 成员恒显固定本地身份,
      // 云账本 REGISTERED 本人(绑定当前登录账号)显当前云 Profile 昵称。
      if (memberId == selfMemberId) {
        if (member.memberType == 'LOCAL') return localSelfDisplayName;
        final bound =
            cloudSelfUserId != null &&
            member.linkedAccountId == cloudSelfUserId;
        if (bound) {
          final cloudName = cloudSelfDisplayName?.trim() ?? '';
          if (cloudName.isNotEmpty) return cloudName;
        }
      }
      final dn = member.displayName.trim();
      if (dn.isNotEmpty) return dn;
      // 昵称为空的防御兜底(正常不会发生:账号注册即分配昵称)。
      return l10n.aaUnknownUser;
    }

    // 2. 本人但成员行缺失(历史脏数据):云账本用云昵称兜底,否则固定本地身份。
    if (memberId == selfMemberId) {
      final cloudName = cloudSelfDisplayName?.trim() ?? '';
      if (cloudName.isNotEmpty) return cloudName;
      return localSelfDisplayName;
    }

    // 3. 虚拟用户(PLACEHOLDER 成员/原虚拟用户名)。
    final virtualName = virtualNames[memberId];
    if (virtualName != null && virtualName.isNotEmpty) return virtualName;

    // 4. 无法解析:返回空串,由 UI 映射「未知」,禁止裸显原始 id。
    return '';
  }

  /// 判断 member id 是否为当前账本本人(self member id)。
  bool isSelf(String? memberId) {
    if (memberId == null || memberId.isEmpty) return false;
    return memberId == selfMemberId;
  }
}
