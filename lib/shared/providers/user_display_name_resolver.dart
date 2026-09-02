import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 用户展示名统一解析器。
///
/// 解析优先级:
/// 1. 共享账本成员表(displayName)
/// 2. 本人(selfMemberId → 本地昵称 → 「未设置昵称」)
/// 3. 虚拟用户名(由调用方传入)
/// 4. 原始 id(未知 id 不套用本地昵称,避免张冠李戴)
///
/// 「我」的判定以 self member id 为权威:登录/退出只改成员绑定不改 id,
/// 因此同一账本的本人恒为同一个成员,展示判定不随账号切换漂移。
class UserDisplayNameResolver {
  final Map<String, LedgerMemberDisplay> memberDisplayMap;
  final String? localOwnerDisplayName;

  /// 当前账本的本人成员 id(ledger.selfMemberId 权威;未设置时由调用方
  /// 按 uuidV5(ledgerId, localSelfId) 确定性派生传入)。
  final String selfMemberId;
  final Map<String, String> virtualNames;
  final AppLocalizations l10n;

  UserDisplayNameResolver({
    required this.memberDisplayMap,
    required this.localOwnerDisplayName,
    required this.selfMemberId,
    required this.virtualNames,
    required this.l10n,
  });

  /// 解析 member id 为展示名。返回空串表示「无此人信息」。
  String resolve(String? memberId) {
    if (memberId == null || memberId.isEmpty) return '';

    // 1. 共享账本成员表:displayName 必填非空列,空值视为无昵称。
    final member = memberDisplayMap[memberId];
    if (member != null) {
      final dn = member.displayName.trim();
      if (dn.isNotEmpty) return dn;
    }

    // 2. 本人(selfMemberId):本地昵称 → 「未设置昵称」。
    if (memberId == selfMemberId) {
      final localName = localOwnerDisplayName?.trim() ?? '';
      if (localName.isNotEmpty) return localName;
      return l10n.mineSlogan;
    }

    // 3. 虚拟用户
    final virtualName = virtualNames[memberId];
    if (virtualName != null && virtualName.isNotEmpty) return virtualName;

    // 4. 兜底原始 id。
    return memberId;
  }

  /// 判断 member id 是否为当前账本本人(self member id)。
  bool isSelf(String? memberId) {
    if (memberId == null || memberId.isEmpty) return false;
    return memberId == selfMemberId;
  }
}
