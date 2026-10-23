import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';

/// AA 参与人头像：本人和真实成员复用磁盘缓存，虚拟或未知参与人使用默认头像。
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
