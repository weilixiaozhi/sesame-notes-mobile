/// 成员目录 REST 快照条目：服务端成员列表接口公开资料的最小形状。
class LedgerDirectoryMember {
  /// 创建成员公开资料快照，保留服务端成员身份与生命周期字段。
  const LedgerDirectoryMember({
    required this.memberId,
    required this.displayName,
    this.linkedAccountId,
    required this.role,
    required this.status,
    this.avatarUrl,
    required this.avatarVersion,
    required this.joinedAt,
  });

  /// 服务端权威 member id(账本内 canonical 成员标识)。
  final String memberId;

  /// 公开昵称(恒非空:账号注册即分配)。
  final String displayName;

  /// 绑定账号 userId(仅 REGISTERED 成员有)。
  final String? linkedAccountId;

  /// 账本内角色:owner/editor。
  final String role;

  /// 成员生命周期:ACTIVE/LEFT/REMOVED。
  final String status;

  /// 头像 URL(服务端相对路径由服务层归一化为绝对地址)。
  final String? avatarUrl;

  /// 头像版本号(本地缓存键)。
  final int avatarVersion;

  /// 加入时间。
  final DateTime joinedAt;
}
