import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';

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
  final String? phoneMasked;
  final String gender;

  const CloudProfile({
    required this.userId,
    this.sesameNumber,
    this.displayName,
    this.avatarUrl,
    this.avatarVersion = 0,
    this.phone,
    this.phoneMasked,
    this.gender = 'UNSPECIFIED',
  });

  CloudProfile copyWith({
    String? sesameNumber,
    String? displayName,
    String? avatarUrl,
    int? avatarVersion,
    String? phone,
    String? phoneMasked,
    String? gender,
  }) => CloudProfile(
    userId: userId,
    sesameNumber: sesameNumber ?? this.sesameNumber,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    avatarVersion: avatarVersion ?? this.avatarVersion,
    phone: phone ?? this.phone,
    phoneMasked: phoneMasked ?? this.phoneMasked,
    gender: gender ?? this.gender,
  );

  Map<String, Object?> toJson() => {
    'user_id': userId,
    'sesame_number': sesameNumber,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'avatar_version': avatarVersion,
    'phone': phone,
    'phone_masked': phoneMasked,
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
        phoneMasked: json['phone_masked'] as String?,
        gender: json['gender'] as String? ?? 'UNSPECIFIED',
      );
    } catch (_) {
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
    } catch (_) {
      return null;
    }
  }

  /// 保存账号资料缓存。
  Future<void> write(CloudProfile profile) async {
    try {
      await _prefs.setString(
        _keyPrefix + profile.userId,
        jsonEncode(profile.toJson()),
      );
      // 写入成功才发信号：写失败（异常被吞）不触发内存同步，避免误报新值
      onWrite?.call(profile);
    } catch (_) {
      // 缓存写入失败不影响主流程；下次在线刷新会重写
    }
  }

  /// 清除指定账号的缓存（登出/凭证失效时调用）。
  Future<void> clear(String userId) async {
    try {
      await _prefs.remove(_keyPrefix + userId);
    } catch (_) {}
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
