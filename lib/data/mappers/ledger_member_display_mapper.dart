import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';

/// 把 Drift 成员行转换为稳定的页面展示模型。
extension LedgerMemberDisplayMapper on LedgerMemberSnapshot {
  /// 复制页面所需字段，阻断 schema Row 向 presentation 扩散。
  LedgerMemberDisplay toDisplay() => LedgerMemberDisplay(
    id: id,
    ledgerId: ledgerId,
    displayName: displayName,
    memberType: memberType,
    linkedAccountId: linkedAccountId,
    originMemberId: originMemberId,
    originAccountId: originAccountId,
    role: role,
    avatarUrl: avatarUrl,
    avatarVersion: avatarVersion,
    status: status,
    joinedAt: joinedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
