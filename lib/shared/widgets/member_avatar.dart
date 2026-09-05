import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/avatar_providers.dart'
    show memberAvatarPathProvider;

/// 全局默认头像资产(随客户端包分发的静态图片)。
///
/// 所有无头像场景(虚拟用户 / 未上传头像 / 缓存加载中或失败)统一回退此图,
/// 不再使用 person 图标占位,保证全项目默认头像视觉一致。
const String kDefaultAvatarAsset = 'assets/Default avatar.png';

/// 全局默认头像:ClipOval + assets 图片,按 [size] 方形裁切。
class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.size});

  /// 圆形直径。
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        kDefaultAvatarAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// 成员头像 —— 全项目唯一头像渲染入口。
///
/// - [userId] 为空(虚拟用户/占位)→ 全局默认头像资产;
/// - [userId] 非空 → 按 userId + 版本走本地磁盘缓存(断网可用);
///   未命中且服务端无头像/下载失败 → 全局默认头像资产。
class MemberAvatar extends ConsumerWidget {
  const MemberAvatar({
    super.key,
    required this.userId,
    this.version = 0,
    this.hasAvatar = false,
    required this.size,
  });

  /// 云端 userId(linkedAccountId / profile.userId);为空 = 虚拟用户/无身份。
  final String? userId;

  /// 服务端头像版本号(0 = 未知,仍按 URL 存在尝试下载)。
  final int version;

  /// 服务端是否返回了头像 URL。
  final bool hasAvatar;

  /// 圆形直径。
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      return _DefaultAvatar(size: size);
    }

    final path = ref
        .watch(
          memberAvatarPathProvider((
            userId: uid,
            version: version,
            hasAvatar: hasAvatar,
          )),
        )
        .value;
    if (path == null || path.isEmpty) {
      return _DefaultAvatar(size: size);
    }

    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        // 缓存文件损坏:与未上传头像一致回退全局默认头像。
        errorBuilder: (_, _, _) => _DefaultAvatar(size: size),
      ),
    );
  }
}

/// 本人头像 —— 云已登录且有资料时走成员磁盘缓存(上传后即时生效、离线可用),
/// 否则统一回退全局默认头像资产。
class SelfAvatar extends ConsumerWidget {
  const SelfAvatar({super.key, required this.size});

  /// 圆形直径。
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountStateProvider);
    final profile = account.isAuthenticated ? account.profile : null;
    if (profile == null) {
      return _DefaultAvatar(size: size);
    }
    return MemberAvatar(
      userId: profile.userId,
      version: profile.avatarVersion,
      hasAvatar:
          profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty,
      size: size,
    );
  }
}
