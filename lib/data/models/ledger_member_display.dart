/// 账本成员展示模型。
class LedgerMemberDisplay {
  const LedgerMemberDisplay({
    required this.id,
    required this.ledgerId,
    required this.displayName,
    required this.memberType,
    this.linkedAccountId,
    this.originMemberId,
    this.originAccountId,
    required this.role,
    this.avatarUrl,
    required this.avatarVersion,
    required this.status,
    required this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String ledgerId;
  final String displayName;
  final String memberType;
  final String? linkedAccountId;
  final String? originMemberId;
  final String? originAccountId;
  final String role;
  final String? avatarUrl;
  final int avatarVersion;
  final String status;
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
