import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/profile_service.dart';
import 'package:sesame_notes/core/storage/member_avatar_storage.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';


/// 成员头像缓存请求键：userId + 服务端版本号 + 是否有头像 URL。
typedef MemberAvatarKey = ({String userId, int version, bool hasAvatar});

/// 成员头像本地路径 provider（按 userId + 版本键控）。
///
/// 命中本地缓存（版本一致）直接返回；未命中且成员有头像时经
/// `downloadMyAvatar` 拉取并落盘；无头像/下载失败返回 null，UI 显示占位。
/// 版本号参与 key，服务端头像更新后自动重下，无需额外失效事件。
final memberAvatarPathProvider =
    FutureProvider.family<String?, MemberAvatarKey>((ref, key) async {
      final cached = await memberAvatarStorage.getPath(
        userId: key.userId,
        version: key.version,
      );
      if (cached != null) return cached;

      if (!key.hasAvatar) {
        // 服务端已无头像：顺手清掉本地残留缓存，避免下次又被旧文件命中。
        await memberAvatarStorage.remove(key.userId);
        return null;
      }

      try {
        // 仅登录态下载：云头像接口要求鉴权（Bearer 由拦截器自动携带）
        if (ref.read(authSessionProvider) == null) return null;
        final bytes = await ProfileService(
          ref.read(apiClientProvider),
        ).downloadAvatar(key.userId);
        if (bytes == null || bytes.isEmpty) return null;
        return await memberAvatarStorage.save(
          userId: key.userId,
          version: key.version,
          bytes: Uint8List.fromList(bytes),
        );
      } catch (e, st) {
        logger.warning('AvatarCache', '成员头像下载失败 userId=${key.userId}: $e', st);
        return null;
      }
    });

