import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 负责注册、登录、刷新和登出的认证服务。
///
/// - Access Token 只放内存（短期 JWT）；
/// - Refresh Token 与账号/设备指针组成原子凭证束，由协调器统一提交；
/// - 登录/注册只返回候选会话，绝不自行覆盖现有凭证；
/// - 刷新按凭证束轮换并返回新凭证束，由协调器在数据域校验后提交。
class AuthService {
  final SesameApiClient client;
  final DeviceIdentity identity;

  AuthService({required this.client, required this.identity});

  /// 登录：返回候选会话 + 刷新令牌 + 云资料，不写安全存储。
  Future<CandidateSession> login({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    final installationId = await identity.load();
    final resp = await AuthApi(client.dio, client.serializers).postAuthLogin(
      postAuthLoginRequest: PostAuthLoginRequest(
        (b) => b
          ..countryCode = countryCode
          ..phone = phone
          ..password = password
          ..device = PostAuthRegisterRequestDevice(
            (d) => d
              ..installationId = installationId
              ..name = 'Sesame Notes Mobile'
              ..platform = 'flutter',
          ).toBuilder(),
      ),
    );
    final data = resp.data;
    if (data == null) throw const FormatException('登录响应为空');
    return _candidateFrom(
      data.accessToken,
      data.refreshToken,
      data.deviceId,
      data.user,
    );
  }

  /// 注册（注册即登录）；返回候选会话，不写安全存储。
  Future<CandidateSession> register({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    final installationId = await identity.load();
    final resp = await AuthApi(client.dio, client.serializers).postAuthRegister(
      postAuthRegisterRequest: PostAuthRegisterRequest(
        (b) => b
          ..countryCode = countryCode
          ..phone = phone
          ..password = password
          ..device = PostAuthRegisterRequestDevice(
            (d) => d
              ..installationId = installationId
              ..name = 'Sesame Notes Mobile'
              ..platform = 'flutter',
          ).toBuilder(),
      ),
    );
    final data = resp.data;
    if (data == null) throw const FormatException('注册响应为空');
    return _candidateFrom(
      data.accessToken,
      data.refreshToken,
      data.deviceId,
      data.user,
    );
  }

  /// 用现有凭证束刷新会话：返回新会话、新刷新令牌与最新云资料，不写安全存储。
  ///
  /// 设计意图：轮换结果先由协调器完成数据域校验再原子提交，
  /// 避免「新 Token + 旧账号/设备指针」的撕裂状态；返回资料供启动恢复/拦截器
  /// 同步刷新缓存，避免刷新后仍展示旧昵称头像。
  Future<({AuthSession session, String refreshToken, CloudProfile profile})>
  refresh({required ActiveCredential credential}) async {
    final resp = await AuthApi(client.dio, client.serializers).postAuthRefresh(
      postAuthRefreshRequest: PostAuthRefreshRequest(
        (b) => b..refreshToken = credential.refreshToken,
      ),
    );
    final data = resp.data;
    if (data == null) throw const FormatException('刷新响应为空');
    return (
      session: AuthSession(
        accessToken: data.accessToken,
        userId: data.user.userId,
        deviceId: data.deviceId,
      ),
      refreshToken: data.refreshToken,
      profile: CloudProfile(
        userId: data.user.userId,
        sesameNumber: data.user.sesameNumber,
        displayName: data.user.displayName,
        avatarUrl: data.user.avatarUrl,
        avatarVersion: data.user.avatarVersion,
        phone: data.user.phone,
        phoneMasked: data.user.phoneMasked,
        gender: data.user.gender.name,
      ),
    );
  }

  /// 只撤销服务端会话（两阶段切换/登出专用）：不清除本地凭证束，
  /// 由协调器在完成账号域清理后统一清除。
  Future<void> revokeServerSession(ActiveCredential credential) async {
    try {
      await AuthApi(client.dio, client.serializers).postAuthLogout(
        postAuthRefreshRequest: PostAuthRefreshRequest(
          (b) => b..refreshToken = credential.refreshToken,
        ),
      );
    } catch (error, stackTrace) {
      logger.error('AuthLogout', '服务端会话撤销失败', error, stackTrace);
      rethrow;
    }
  }

  /// 把会话响应组装为候选会话（含云资料模型）。
  CandidateSession _candidateFrom(
    String accessToken,
    String refreshToken,
    String deviceId,
    PostAuthRegister201ResponseUser user,
  ) {
    return CandidateSession(
      session: AuthSession(
        accessToken: accessToken,
        userId: user.userId,
        deviceId: deviceId,
      ),
      refreshToken: refreshToken,
      profile: CloudProfile(
        userId: user.userId,
        sesameNumber: user.sesameNumber,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        avatarVersion: user.avatarVersion,
        phone: user.phone,
        phoneMasked: user.phoneMasked,
        gender: user.gender.name,
      ),
    );
  }
}
