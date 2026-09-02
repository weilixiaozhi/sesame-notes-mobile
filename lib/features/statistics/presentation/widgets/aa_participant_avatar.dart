import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/avatar_providers.dart'
    show avatarPathProvider;
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/widgets/person_avatar.dart';

/// AA 参与人头像（本人本地头像 → 成员头像磁盘缓存 → person 占位图标）。
///
/// 分摊统计页成员行、成员账单详情页头部与分摊明细共用，保证同一参与人在
/// 各处的头像样式完全一致（含加载中 / 加载失败回退），不散落各自的头像
/// 拼接逻辑。
class AaParticipantAvatar extends ConsumerWidget {
  /// 所属账本 id（UUID；用于查询参与人成员头像上下文）。
  final String ledgerId;

  /// 参与人标识（userId 或虚拟用户 id）。
  final String participantId;

  /// 是否本人；本人优先展示本地头像，其他参与人只走成员头像。
  final bool isSelf;

  /// 圆形直径。
  final double size;

  const AaParticipantAvatar({
    super.key,
    required this.ledgerId,
    required this.participantId,
    this.isSelf = false,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 本人本地头像（离线可用、上传后即时生效）；非本人不读取本地路径。
    final localPath = isSelf ? ref.watch(avatarPathProvider).value : null;
    if (localPath != null && localPath.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(localPath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => PersonAvatar(size: size),
        ),
      );
    }

    // 真实成员头像：从参与人头像上下文取成员，走磁盘缓存（断网可用）。
    final ctx = ref.watch(aaParticipantAvatarContextProvider(ledgerId)).value;
    final member = ctx?.members[participantId];
    if (member != null) {
      return MemberAvatar(
        userId: member.id,
        // schema v1 无头像版本列,恒为 0,仅作本地缓存键兼容。
        version: 0,
        hasAvatar:
            member.avatarUrl != null && member.avatarUrl!.trim().isNotEmpty,
        size: size,
        iconSize: size * 0.45,
      );
    }

    // 虚拟用户 / 未配置头像：与全项目无头像占位样式一致。
    return PersonAvatar(size: size, iconSize: size * 0.45);
  }
}
