import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/api/api_interceptors.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 编译期服务端地址覆盖；未通过 --dart-define=API_BASE_URL 注入时为空串。
const String kApiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

/// 服务端地址，HTTP 与 WebSocket 连接统一由该地址派生。
class ApiConfig {
  final String baseUrl;

  const ApiConfig({this.baseUrl = _effectiveBaseUrl});

  /// 编译期注入优先于线上默认地址（验收/联调本地后端用 dart-define 覆盖）。
  static const String _effectiveBaseUrl = kApiBaseUrlOverride == ''
      ? 'https://api.9100300.xyz'
      : kApiBaseUrlOverride;
}

/// 构建带请求追踪、Bearer 认证和单飞刷新的全局 API 客户端。
///
/// refresh 回调延迟 read [authServiceProvider]（避免 provider 构造期循环依赖）：
/// authServiceProvider 构造依赖本 provider，但回调在请求失败时执行，
/// 此时两个 provider 均已实例化。
final apiClientProvider = Provider<SesameApiClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  dio.interceptors.add(RequestIdInterceptor());
  dio.interceptors.add(
    AuthRefreshInterceptor(
      dio: dio,
      refresh: () async {
        final service = ref.read(authServiceProvider);
        final store = ref.read(secureAccountStoreProvider);
        final stored = await store.load();
        if (stored == null) {
          // 无凭证可刷新：明确认证 401 语义，直接回未登录
          ref.read(authSessionProvider.notifier).signOut();
          return '';
        }
        try {
          final refreshed = await service.refresh(credential: stored);
          // 轮换结果原子提交：凭证束、会话与资料同步覆盖
          await store.save(
            ActiveCredential(
              userId: refreshed.session.userId,
              deviceId: refreshed.session.deviceId,
              refreshToken: refreshed.refreshToken,
            ),
          );
          ref.read(authSessionProvider.notifier).signIn(refreshed.session);
          // 同步刷新资料缓存：断网重启后展示最新昵称/头像
          await ref.read(cloudProfileCacheProvider).write(refreshed.profile);
          return refreshed.session.accessToken;
        } on DioException catch (error, stackTrace) {
          final status = error.response?.statusCode;
          // 网络错误/5xx 保留凭证与缓存身份，等待恢复后重试
          if (status == null || status >= 500) {
            logger.warning(
              'AuthRefresh',
              '刷新失败（网络/服务端），保留本地会话待重试',
              '$error\n$stackTrace',
            );
            rethrow;
          }
          // 明确认证类 401：清除凭证回到未登录；账号域云端数据由账号状态
          // 会话失效监听统一执行 P0-1 purge（与显式退出登录同口径），
          // 重登后由 reconnect 全量快照拉回。
          try {
            await store.clear();
          } catch (clearError, clearStackTrace) {
            logger.error(
              'AuthRefresh',
              '认证失效后清理凭证失败',
              clearError,
              clearStackTrace,
            );
          } finally {
            ref.read(authSessionProvider.notifier).signOut();
          }
          logger.error('AuthRefresh', '认证失效，本地凭证已清除', '$error\n$stackTrace');
          rethrow;
        } catch (error, stackTrace) {
          // 解析/格式等异常按临时失败处理，保留凭证
          logger.warning(
            'AuthRefresh',
            '刷新响应解析失败，保留本地会话',
            '$error\n$stackTrace',
          );
          rethrow;
        }
      },
    ),
  );
  // 不传空拦截器列表，让生成客户端安装 BearerAuthInterceptor 等认证能力。
  return SesameApiClient(dio: dio);
});

final apiConfigProvider = Provider<ApiConfig>((ref) => const ApiConfig());

/// 凭证束存储装配（core API 层：刷新拦截器与协调器共用同一实例）。
final secureAccountStoreProvider = Provider<SecureAccountStore>((ref) {
  return SecureAccountStore(SecureFlutterStore());
});

/// 当前登录会话（null = 未登录）。
final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthSession?> {
  /// 初始化为未登录状态，Access Token 不做持久化恢复。
  @override
  AuthSession? build() => null;

  /// 登录成功后注入：写内存会话 + 挂 Bearer token。
  void signIn(AuthSession session) {
    state = session;
    ref
        .read(apiClientProvider)
        .setBearerAuth('bearerAuth', session.accessToken);
  }

  /// 轮换 Access Token，同时保留当前用户与设备身份。
  void updateToken(String accessToken) {
    final current = state;
    if (current == null) return;
    state = AuthSession(
      accessToken: accessToken,
      userId: current.userId,
      deviceId: current.deviceId,
    );
    ref.read(apiClientProvider).setBearerAuth('bearerAuth', accessToken);
  }

  /// 清除内存会话和生成客户端持有的 Bearer Token。
  void signOut() {
    state = null;
    ref.read(apiClientProvider).removeBearerAuth('bearerAuth');
  }
}

/// 提供注册和登录共用的持久化设备标识。
/// 首次生成后固定复用，保证同一设备每次登录绑定同一服务端设备记录。
final deviceIdentityProvider = Provider<DeviceIdentity>((ref) {
  return DeviceIdentity(SecureDeviceIdStore());
});

/// 同步等未登录场景的兜底设备 id（不持久化，登录后以会话 deviceId 为准）。
String get localDeviceId => const Uuid().v4();

/// Riverpod 装配：客户端 + 持久化设备身份（安全存储）。
final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  final identity = ref.watch(deviceIdentityProvider);
  return AuthService(client: client, identity: identity);
});
