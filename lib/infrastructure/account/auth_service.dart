import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:dio/dio.dart';
import 'package:built_value/json_object.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/device_identity.dart';
import 'package:sesame_notes/infrastructure/account/device_metadata.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/core/network/request_deadline.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 撤销已完成，或服务端确认该刷新凭证已失效；其余结果均需保留待办。
enum SessionRevocationResult { revoked, credentialInvalid }

/// 负责注册、登录、刷新和登出的认证服务。
///
/// - Access Token 只放内存（短期 JWT）；
/// - Refresh Token 与账号/设备指针组成原子凭证束，由协调器统一提交；
/// - 登录/注册只返回候选会话，绝不自行覆盖现有凭证；
/// - 刷新按凭证束轮换并返回新凭证束，由协调器在数据域校验后提交。
class AuthService {
  final SesameApiClient client;
  final DeviceIdentity identity;

  /// 装配方校验服务实例仍属于当前配置，独立撤销请求也使用同一边界。
  final bool Function()? isCurrent;
  final DeviceMetadataReader metadataReader;

  /// 设备资料读取独立于稳定安装身份，可注入读取器验证登录与刷新正文。
  AuthService({
    required this.client,
    required this.identity,
    this.isCurrent,
    DeviceMetadataReader? metadataReader,
  }) : metadataReader = metadataReader ?? DeviceMetadataReader();

  /// 登录：返回候选会话 + 刷新令牌 + 云资料，不写安全存储。
  Future<CandidateSession> login({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    ensureServerConfigured();
    final device = await _registrationDevice();
    ensureServerConfigured();
    final resp = await AuthApi(client.dio, client.serializers).postAuthLogin(
      postAuthLoginRequest: PostAuthLoginRequest(
        (b) => b
          ..countryCode = countryCode
          ..phone = phone
          ..password = password
          ..device = device.toBuilder(),
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
    ensureServerConfigured();
    final device = await _registrationDevice();
    ensureServerConfigured();
    final resp = await AuthApi(client.dio, client.serializers).postAuthRegister(
      postAuthRegisterRequest: PostAuthRegisterRequest(
        (b) => b
          ..countryCode = countryCode
          ..phone = phone
          ..password = password
          ..device = device.toBuilder(),
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

  /// 账号服务器缺失时立即结束认证，不读取设备资料或发出网络请求。
  void ensureServerConfigured() {
    try {
      final uri = Uri.tryParse(client.dio.options.baseUrl);
      if (uri == null ||
          !uri.hasAuthority ||
          uri.host.isEmpty ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw const ServerNotConfiguredException();
      }
      if (isCurrent?.call() == false) {
        throw StateError('服务配置已变化，请重试');
      }
    } catch (error, stackTrace) {
      logger.error(
        'Auth',
        '账号服务未配置或已变更，请检查服务配置',
        error.runtimeType,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 稳定安装身份沿用安全存储，设备资料每次读取当前系统和应用的实际信息。
  Future<PostAuthRegisterRequestDevice> _registrationDevice() async {
    try {
      final installation = await identity.load();
      final metadata = await metadataReader.read();
      return PostAuthRegisterRequestDevice(
        (device) => device
          ..installationId = installation
          ..name = AppEnvironment.deviceName
          ..platform = metadata.platform
          ..appVersion = metadata.appVersion
          ..osVersion = metadata.osVersion
          ..deviceModel = metadata.deviceModel,
      );
    } catch (error, stackTrace) {
      logger.error(
        'AuthDevice',
        '设备身份暂时无法准备，请稍后重试登录',
        error.runtimeType,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 用现有凭证束刷新会话：返回新会话、新刷新令牌与最新云资料，不写安全存储。
  ///
  /// 设计意图：轮换结果先由协调器完成数据域校验再原子提交，
  /// 避免「新 Token + 旧账号/设备指针」的撕裂状态；返回资料供启动恢复/拦截器
  /// 同步刷新缓存，避免刷新后仍展示旧昵称头像。
  Future<({AuthSession session, String refreshToken, CloudProfile profile})>
  refresh({required ActiveCredential credential}) async {
    ensureServerConfigured();
    final metadata = await metadataReader.read();
    ensureServerConfigured();
    final resp = await AuthApi(client.dio, client.serializers).postAuthRefresh(
      postAuthRefreshRequest: PostAuthRefreshRequest(
        (b) => b
          ..refreshToken = credential.refreshToken
          ..device = JsonObject(metadata.toJson()),
      ),
    );
    final data = resp.data;
    if (data == null) throw const FormatException('刷新响应为空');
    if (data.user.userId != credential.userId ||
        data.deviceId != credential.deviceId) {
      throw const FormatException('刷新会话身份不匹配');
    }
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
        gender: data.user.gender.name,
      ),
    );
  }

  /// 用待撤销凭证恢复临时认证，轮换材料落安全存储后再撤销服务端会话。
  /// 临时客户端没有当前账号的认证或刷新拦截器，避免退出旧账号影响新账号。
  Future<SessionRevocationResult> revokeServerSession(
    ActiveCredential credential, {
    required Future<void> Function(ActiveCredential) persistRotatedCredential,
  }) async {
    ensureServerConfigured();
    final dio = Dio(client.dio.options.copyWith(headers: {}));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            ensureServerConfigured();
            handler.next(options);
          } catch (error, stackTrace) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
                stackTrace: stackTrace,
              ),
            );
          }
        },
      ),
    );
    // 复用传输配置但不共享认证状态；此处不能关闭属于应用客户端的适配器。
    dio.httpClientAdapter = client.dio.httpClientAdapter;
    // 独立撤销同样受完整请求期限约束，持续收包不能一直占用认证队列。
    final requestDeadline = client.dio.interceptors
        .whereType<RequestDeadlineInterceptor>()
        .firstOrNull;
    dio.interceptors.add(
      RequestDeadlineInterceptor(
        timeout: requestDeadline?.timeout ?? const Duration(seconds: 30),
      ),
    );
    final api = AuthApi(dio, client.serializers);
    ActiveCredential? unsavedCredential;
    try {
      // 安全槽不可用时不开始服务端轮换，保留仍有效的原始撤销材料。
      await persistRotatedCredential(credential);
      final refreshed = await api.postAuthRefresh(
        postAuthRefreshRequest: PostAuthRefreshRequest(
          (b) => b..refreshToken = credential.refreshToken,
        ),
      );
      final session = refreshed.data;
      if (session == null ||
          session.user.userId != credential.userId ||
          session.deviceId != credential.deviceId) {
        throw const FormatException('待撤销会话身份校验失败');
      }
      final rotated = ActiveCredential(
        userId: credential.userId,
        deviceId: credential.deviceId,
        refreshToken: session.refreshToken,
      );
      try {
        await persistRotatedCredential(rotated);
      } catch (error, stackTrace) {
        unsavedCredential = rotated;
        // 轮换已经发生：落盘失败时立即尝试撤销新令牌，避免只剩失效的旧材料。
        logger.error(
          'AuthLogout',
          '撤销材料保存失败，立即撤销临时会话',
          error.runtimeType,
          stackTrace,
        );
      }
      final revoked = await api.postAuthLogout(
        postAuthLogoutRequest: PostAuthLogoutRequest(
          (b) => b..refreshToken = rotated.refreshToken,
        ),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      if (revoked.statusCode != 204) {
        throw const FormatException('服务端未确认会话撤销完成');
      }
      unsavedCredential = null;
      return SessionRevocationResult.revoked;
    } on DioException catch (error, stackTrace) {
      final body = error.response?.data;
      // 仅刷新接口的明确业务结果代表材料失效；普通 401 或撤销 401 继续重试。
      if (error.requestOptions.path == '/api/v1/auth/refresh' &&
          error.response?.statusCode == 401 &&
          body is Map &&
          body['code'] == 'INVALID_REFRESH_TOKEN') {
        return SessionRevocationResult.credentialInvalid;
      }
      logger.error(
        'AuthLogout',
        '服务端会话撤销未完成',
        'type=${error.type.name}, status=${error.response?.statusCode}',
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      logger.error('AuthLogout', '服务端会话撤销未完成', error.runtimeType, stackTrace);
      rethrow;
    } finally {
      if (unsavedCredential != null) {
        try {
          // 即时撤销也未完成时再保存一次，覆盖平台写入的瞬时故障。
          await persistRotatedCredential(unsavedCredential);
        } catch (storageError, storageStackTrace) {
          logger.error(
            'AuthLogout',
            '新撤销材料仍无法保存，服务端撤销未确认',
            storageError.runtimeType,
            storageStackTrace,
          );
        }
      }
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
        gender: user.gender.name,
      ),
    );
  }
}
