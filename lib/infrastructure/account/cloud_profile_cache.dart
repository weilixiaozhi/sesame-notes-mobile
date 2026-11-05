import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';

/// 可空资料字段的未指定标记，显式 null 表示清空当前值。
const _unsetCloudProfile = Object();

/// 云账号个人资料缓存（按 user_id 键控，仅本人可见字段）。
///
/// 设计意图：断网时仍能展示已登录身份；手机号与性别虽不是凭证，
/// 仍属于「仅本人可见」的私有资料，缓存必须按账号键控，且只有当前
/// authenticated 账号域可读取。不保存密码或 Access Token。
class CloudProfile {
  final String userId;
  final String? sesameNumber;
  final String? displayName;
  final String? avatarUrl;
  final int avatarVersion;
  final String? phone;
  final String gender;

  const CloudProfile({
    required this.userId,
    this.sesameNumber,
    this.displayName,
    this.avatarUrl,
    this.avatarVersion = 0,
    this.phone,
    this.gender = 'UNSPECIFIED',
  });

  /// 未指定的资料沿用当前值，可空字段支持显式清空。
  CloudProfile copyWith({
    Object? sesameNumber = _unsetCloudProfile,
    Object? displayName = _unsetCloudProfile,
    Object? avatarUrl = _unsetCloudProfile,
    int? avatarVersion,
    Object? phone = _unsetCloudProfile,
    String? gender,
  }) => CloudProfile(
    userId: userId,
    sesameNumber: identical(sesameNumber, _unsetCloudProfile)
        ? this.sesameNumber
        : sesameNumber as String?,
    displayName: identical(displayName, _unsetCloudProfile)
        ? this.displayName
        : displayName as String?,
    avatarUrl: identical(avatarUrl, _unsetCloudProfile)
        ? this.avatarUrl
        : avatarUrl as String?,
    avatarVersion: avatarVersion ?? this.avatarVersion,
    phone: identical(phone, _unsetCloudProfile) ? this.phone : phone as String?,
    gender: gender ?? this.gender,
  );

  Map<String, Object?> toJson() => {
    'user_id': userId,
    'sesame_number': sesameNumber,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'avatar_version': avatarVersion,
    'phone': phone,
    'gender': gender,
  };

  /// 解析失败返回 null；损坏缓存按缺失处理。
  static CloudProfile? fromJson(Map<String, dynamic> json) {
    try {
      final userId = json['user_id'] as String?;
      if (userId == null || userId.isEmpty) return null;
      return CloudProfile(
        userId: userId,
        sesameNumber: json['sesame_number'] as String?,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        avatarVersion: (json['avatar_version'] as num?)?.toInt() ?? 0,
        phone: json['phone'] as String?,
        gender: json['gender'] as String? ?? 'UNSPECIFIED',
      );
    } catch (error, stackTrace) {
      logger.error(
        'CloudProfileCache',
        '云资料缓存结构无效，本次按缺失处理',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    }
  }
}

/// 云资料缓存门面：按 user_id 保存/读取个人资料。
class CloudProfileCache {
  static const _keyPrefix = 'sesame_notes_cloud_profile_';

  final SharedPreferences _prefs;

  /// 写入完成回调（装配时注入）；供上层把磁盘缓存变更同步进内存展示状态。
  final void Function(CloudProfile profile)? onWrite;

  CloudProfileCache(this._prefs, {this.onWrite});

  /// 读取指定账号的缓存资料；未缓存或损坏返回 null。
  CloudProfile? read(String userId) {
    try {
      final raw = _prefs.getString(_keyPrefix + userId);
      if (raw == null || raw.isEmpty) return null;
      return CloudProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error, stackTrace) {
      logger.error(
        'CloudProfileCache',
        '读取云资料缓存失败，本次按缺失处理',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    }
  }

  /// 保存账号资料缓存。
  Future<void> write(CloudProfile profile, {bool Function()? isCurrent}) async {
    try {
      if (isCurrent != null && !isCurrent()) return;
      final key = _keyPrefix + profile.userId;
      final value = jsonEncode(profile.toJson());
      if (!await _prefs.setString(key, value)) {
        throw StateError('云资料缓存写入未被系统确认');
      }
      // 退出可能与平台写入交错；只撤回本次仍占据的缓存值，不覆盖后来的资料。
      if (isCurrent != null && !isCurrent()) {
        if (_prefs.getString(key) == value) await _prefs.remove(key);
        return;
      }
      // 只有平台确认写入后才发布缓存变更，避免失败写入触发资料刷新。
      onWrite?.call(profile);
    } catch (error, stackTrace) {
      // 可选缓存失败保持降级；诊断只包含操作、类型和堆栈，不记录资料正文。
      logger.error(
        'CloudProfileCache',
        '保存云资料缓存失败，本次继续使用已有身份',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 清除指定账号的缓存（登出/凭证失效时调用）。
  Future<void> clear(String userId) async {
    try {
      if (!await _prefs.remove(_keyPrefix + userId)) {
        throw StateError('云资料缓存清除未被系统确认');
      }
    } catch (error, stackTrace) {
      // 登出后残留旧账号资料会破坏账号隔离：降级放行但必须留痕。
      logger.error(
        'CloudProfileCache',
        '清除云资料缓存失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }
}

/// 云资料缓存装配：经统一 SharedPreferences 出口读取（测试可整体替换注入）。
final cloudProfileCacheProvider = Provider<CloudProfileCache>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw StateError('SharedPreferences 未就绪，云资料缓存不可用');
  }
  return CloudProfileCache(
    prefs,
    // 每次缓存写入 bump 一次版本号：上层（账号状态桥）监听该信号，
    // 把 token 刷新等"只写磁盘"路径的最新资料同步进内存展示状态。
    onWrite: (_) => ref.read(profileCacheTickProvider.notifier).bump(),
  );
});

/// 云资料缓存写入信号：每次成功写入递增一次版本号。
class ProfileCacheTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final profileCacheTickProvider =
    NotifierProvider<ProfileCacheTickNotifier, int>(
      ProfileCacheTickNotifier.new,
    );
