/// 认证、资料与头像用例编排。
library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

export 'package:sesame_notes/infrastructure/api/api_error_mapper.dart'
    show ApiErrorKind, mapApiError;

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/member_avatar_storage.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 页面可提交的认证与资料用例。
class AuthActions {
  AuthActions(this.ref);

  final Ref ref;

  /// 固定资料操作所属的账号与身份代次，令牌轮换不会改变该身份。
  ({String userId, int generation, ApiConfig config}) _identity() {
    final state = ref.read(accountStateProvider);
    final id = ref.read(authSessionProvider)?.userId ?? state.userId;
    if (!state.isAuthenticated || id == null) throw StateError('请先登录');
    return (
      userId: id,
      generation: ref.read(authIdentityGenerationProvider),
      config: ref.read(apiConfigProvider),
    );
  }

  /// 每次异步提交前复核身份，拒绝退出、换号和同账号重新登录后的旧响应。
  void _requireIdentity(
    ({String userId, int generation, ApiConfig config}) identity,
  ) {
    if (!ref.mounted || _identity() != identity) {
      throw StateError('账号已变化，请重新操作');
    }
  }

  /// 登录并通过账号切换协调器原子提交新会话。
  Future<bool> login({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    try {
      final service = ref.read(authServiceProvider);
      service.ensureServerConfigured();
      return await runAccountAuthentication(ref, () async {
        final candidate = await service.login(
          countryCode: countryCode,
          phone: phone,
          password: password,
        );
        service.ensureServerConfigured();
        return ref
            .read(accountSwitchCoordinatorProvider)
            .commitLogin(
              candidate: candidate,
              onReconnect: () => ref.read(syncCoordinatorProvider).reconnect(),
            );
      });
    } catch (error, stackTrace) {
      logger.error('AuthActions', '登录失败', error, stackTrace);
      rethrow;
    }
  }

  /// 注册并通过账号切换协调器原子提交新会话。
  Future<bool> register({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    try {
      final service = ref.read(authServiceProvider);
      service.ensureServerConfigured();
      return await runAccountAuthentication(ref, () async {
        final candidate = await service.register(
          countryCode: countryCode,
          phone: phone,
          password: password,
        );
        service.ensureServerConfigured();
        return ref
            .read(accountSwitchCoordinatorProvider)
            .commitLogin(
              candidate: candidate,
              initializeNewAccount: true,
              onReconnect: () => ref.read(syncCoordinatorProvider).reconnect(),
            );
      });
    } catch (error, stackTrace) {
      logger.error('AuthActions', '注册失败', error, stackTrace);
      rethrow;
    }
  }

  /// 拉取本人最新资料，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> refreshProfile() async {
    try {
      final identity = _identity();
      final refreshed = await ref.read(profileServiceProvider).getMe();
      await _commitProfile(refreshed, identity);
      return refreshed;
    } catch (error, stackTrace) {
      logger.error('AuthActions', '刷新个人资料失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新昵称，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> updateDisplayName(String name) async {
    try {
      final identity = _identity();
      final updated = await ref
          .read(profileServiceProvider)
          .updateDisplayName(name);
      await _commitProfile(updated, identity);
      return updated;
    } catch (error, stackTrace) {
      logger.error('AuthActions', '更新昵称失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新性别，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> updateGender(String gender) async {
    try {
      final identity = _identity();
      final updated = await ref
          .read(profileServiceProvider)
          .updateGender(gender);
      await _commitProfile(updated, identity);
      return updated;
    } catch (error, stackTrace) {
      logger.error('AuthActions', '更新性别失败', error, stackTrace);
      rethrow;
    }
  }

  /// 修改当前账号密码。
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ref
          .read(profileServiceProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
    } catch (error, stackTrace) {
      logger.error('AuthActions', '修改密码失败', error, stackTrace);
      rethrow;
    }
  }

  /// 上传头像，并把服务端返回的头像版本写回账号资料缓存；
  /// 上传字节同步写成员头像磁盘缓存，账本/成员页面即时显示新头像。
  Future<void> uploadAvatar({
    required String contentType,
    required List<int> bytes,
  }) async {
    try {
      final identity = _identity();
      final result = await ref
          .read(profileServiceProvider)
          .uploadAvatar(contentType: contentType, bytes: bytes);
      _requireIdentity(identity);
      final profile = ref.read(accountStateProvider).profile;
      if (profile == null) return;
      await _commitProfile(
        profile.copyWith(avatarUrl: result.url, avatarVersion: result.version),
        identity,
      );
      _requireIdentity(identity);
      await memberAvatarStorage.save(
        userId: profile.userId,
        version: result.version,
        bytes: Uint8List.fromList(bytes),
      );
    } catch (error, stackTrace) {
      logger.error('AuthActions', '上传头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 服务端恢复默认头像后，清理账号资料与本地成员头像缓存。
  Future<void> restoreDefaultAvatar() async {
    try {
      final identity = _identity();
      await ref.read(profileServiceProvider).deleteAvatar();
      _requireIdentity(identity);
      final profile = ref.read(accountStateProvider).profile;
      if (profile == null) return;
      await _commitProfile(
        profile.copyWith(avatarUrl: null, avatarVersion: 0),
        identity,
      );
      _requireIdentity(identity);
      await memberAvatarStorage.remove(profile.userId);
    } catch (error, stackTrace) {
      logger.error('AuthActions', '恢复默认头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 原子更新页面即时状态与断网启动所需的账号资料缓存。
  ///
  /// 资料落定后批量刷新本地云账本中绑定该账号的 REGISTERED
  /// 成员展示快照,保证成员管理/交易详情等身份页面即时显示新昵称/头像;
  /// 快照刷新失败只记日志,不阻断资料本身已保存成功的结果。
  Future<void> _commitProfile(
    CloudProfile profile,
    ({String userId, int generation, ApiConfig config}) identity,
  ) async {
    _requireIdentity(identity);
    if (profile.userId != identity.userId) throw StateError('资料不属于当前账号');
    ref.read(accountStateProvider.notifier).updateProfile(profile);
    await ref
        .read(cloudProfileCacheProvider)
        .write(
          profile,
          isCurrent: () {
            try {
              _requireIdentity(identity);
              return true;
            } catch (_) {
              return false;
            }
          },
        );
    _requireIdentity(identity);
    try {
      await ref
          .read(accountDataAccessProvider)
          .refreshMemberDisplayByAccount(
            userId: profile.userId,
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
            avatarVersion: profile.avatarVersion,
          );
    } catch (error, stackTrace) {
      logger.warning(
        'AuthActions',
        '成员展示快照刷新失败 userId=${profile.userId}',
        '$error\n$stackTrace',
      );
    }
  }
}

/// 认证与资料用例入口。
final authActionsProvider = Provider<AuthActions>(AuthActions.new);

/// 资料页进入时的服务端资料刷新入口。
///
/// 同一容器内重复读取复用同一次请求，避免页面重建重复拉取；
/// 页面离开后释放，重新进入时会再拉取一次最新资料。
final profileRefreshProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    await ref.read(authActionsProvider).refreshProfile();
  } catch (_) {
    // AuthActions 已记录错误，后台刷新失败不打断资料页使用。
  }
});
