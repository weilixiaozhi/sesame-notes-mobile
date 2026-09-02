/// 认证、资料与头像用例编排。
library;

export 'package:sesame_notes/core/api/api_error_mapper.dart'
    show ApiErrorKind, mapApiError;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/member_avatar_storage.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 页面可提交的认证与资料用例。
class AuthActions {
  AuthActions(this.ref);

  final Ref ref;

  /// 登录并通过账号切换协调器原子提交新会话。
  Future<bool> login({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    try {
      final candidate = await ref
          .read(authServiceProvider)
          .login(countryCode: countryCode, phone: phone, password: password);
      return ref
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(
            candidate: candidate,
            onReconnect: () => ref.read(syncCoordinatorProvider).reconnect(),
          );
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
      final candidate = await ref
          .read(authServiceProvider)
          .register(countryCode: countryCode, phone: phone, password: password);
      return ref
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(
            candidate: candidate,
            onReconnect: () => ref.read(syncCoordinatorProvider).reconnect(),
          );
    } catch (error, stackTrace) {
      logger.error('AuthActions', '注册失败', error, stackTrace);
      rethrow;
    }
  }

  /// 拉取本人最新资料，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> refreshProfile() async {
    try {
      final refreshed = await ref.read(profileServiceProvider).getMe();
      await _commitProfile(refreshed);
      return refreshed;
    } catch (error, stackTrace) {
      logger.error('AuthActions', '刷新个人资料失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新昵称，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> updateDisplayName(String name) async {
    try {
      final updated = await ref
          .read(profileServiceProvider)
          .updateDisplayName(name);
      await _commitProfile(updated);
      return updated;
    } catch (error, stackTrace) {
      logger.error('AuthActions', '更新昵称失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新性别，并同步内存账号状态与离线资料缓存。
  Future<CloudProfile> updateGender(String gender) async {
    try {
      final updated = await ref
          .read(profileServiceProvider)
          .updateGender(gender);
      await _commitProfile(updated);
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

  /// 上传头像，并把服务端返回的头像版本写回账号资料缓存。
  Future<void> uploadAvatar({
    required String contentType,
    required List<int> bytes,
  }) async {
    try {
      final result = await ref
          .read(profileServiceProvider)
          .uploadAvatar(contentType: contentType, bytes: bytes);
      final profile = ref.read(accountStateProvider).profile;
      if (profile == null) return;
      await _commitProfile(
        profile.copyWith(avatarUrl: result.url, avatarVersion: result.version),
      );
    } catch (error, stackTrace) {
      logger.error('AuthActions', '上传头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 服务端恢复默认头像后，清理账号资料与本地成员头像缓存。
  Future<void> restoreDefaultAvatar() async {
    try {
      await ref.read(profileServiceProvider).deleteAvatar();
      final profile = ref.read(accountStateProvider).profile;
      if (profile == null) return;
      await _commitProfile(profile.copyWith(avatarUrl: null, avatarVersion: 0));
      await memberAvatarStorage.remove(profile.userId);
    } catch (error, stackTrace) {
      logger.error('AuthActions', '恢复默认头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 原子更新页面即时状态与断网启动所需的账号资料缓存。
  Future<void> _commitProfile(CloudProfile profile) async {
    ref.read(accountStateProvider.notifier).updateProfile(profile);
    await ref.read(cloudProfileCacheProvider).write(profile);
  }
}

/// 认证与资料用例入口。
final authActionsProvider = Provider<AuthActions>(AuthActions.new);
