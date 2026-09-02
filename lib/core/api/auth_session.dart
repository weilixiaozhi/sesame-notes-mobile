import 'package:sesame_notes/core/api/cloud_profile_cache.dart';

/// 只在内存中保存短期 Access Token 的认证会话。
class AuthSession {
  final String accessToken;
  final String userId;
  final String deviceId;

  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.deviceId,
  });
}

/// 候选会话：登录/注册接口只返回候选值，由协调器在账号域切换完成后提交。
class CandidateSession {
  final AuthSession session;
  final String refreshToken;
  final CloudProfile profile;

  const CandidateSession({
    required this.session,
    required this.refreshToken,
    required this.profile,
  });
}
