import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';

/// AA 参与人头像 —— AA 页面统一的参与人头像解析组件。
///
/// - 本人 → [SelfAvatar](云头像走成员磁盘缓存,否则全局默认头像资产);
/// - 其他真实成员 → [MemberAvatar](按 linkedAccountId 走磁盘缓存,断网可用);
/// - 虚拟用户 / 未知参与人 → 全局默认头像资产。
///
/// 分摊统计页、成员账单详情页、成员支出模块、AA 编辑页与支出人选择器共用,
/// 同一参与人在各处头像完全一致,不散落各自的头像拼接逻辑。
class AaParticipantAvatar extends ConsumerWidget {
  const AaParticipantAvatar({
    super.key,
    required this.ledgerId,
    required this.participantId,
    this.isSelf = false,
    this.size = 32,
  });

  /// 所属账本 id(UUID;用于查询参与人成员头像上下文)。
  final String ledgerId;

  /// 参与人标识(member id 或虚拟用户 id)。
  final String participantId;

  /// 是否本人;本人优先展示本地头像,其他参与人只走成员头像。
  final bool isSelf;

  /// 圆形直径。
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelf) {
      return SelfAvatar(size: size);
    }

    final identity = ref.watch(ledgerIdentityProvider(ledgerId)).value;
    final member = identity?.memberMap[participantId];
    if (member != null && member.memberType != 'PLACEHOLDER') {
      final uid = member.linkedAccountId;
      return MemberAvatar(
        userId: uid,
        version: member.avatarVersion,
        hasAvatar:
            uid != null &&
            uid.isNotEmpty &&
            member.avatarUrl != null &&
            member.avatarUrl!.trim().isNotEmpty,
        size: size,
      );
    }

    // 虚拟用户/身份上下文未就绪:与全项目无头像场景一致回退默认头像资产。
    return MemberAvatar(userId: null, size: size);
  }
}
