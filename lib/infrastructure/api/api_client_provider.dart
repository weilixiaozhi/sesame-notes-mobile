import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_interceptors.dart';
import 'package:sesame_notes/infrastructure/account/auth_service.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/device_identity.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/network/request_deadline.dart';
import 'api_serializers.dart';
import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';

/// 服务端地址，HTTP 与 WebSocket 连接统一由该地址派生。
class ApiConfig {
  final String baseUrl;

  /// HTTP 与 WebSocket 共用构建地址，空地址表示账号服务未配置。
  const ApiConfig({this.baseUrl = AppEnvironment.apiBaseUrl});

  /// 仅完整 HTTP(S) 服务地址可以承载请求，空地址不能退化为相对路径。
  bool get isConfigured {
    final uri = Uri.tryParse(baseUrl);
    return uri != null &&
        uri.hasAuthority &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
  }
}

/// 构建带请求追踪、Bearer 认证和单飞刷新的全局 API 客户端。
///
/// 刷新由会话 Notifier 统一协调，启动、下拉与 HTTP 401 共用一轮凭证轮换。
final apiClientProvider = Provider<SesameApiClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final requestDeadline = ref.watch(apiRequestDeadlineProvider);
  var active = true;
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      sendTimeout: requestDeadline,
    ),
  );
  ref.onDispose(() {
    active = false;
    try {
      // 所有者结束后拒绝新请求，已发出的业务请求仍可完成并取得响应。
      dio.close(force: false);
    } catch (error, stackTrace) {
      logger.error('ApiClient', '网络连接释放失败', error, stackTrace);
    }
  });
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          if (!active ||
              !ref.mounted ||
              !identical(ref.read(apiConfigProvider), config)) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
                error: StateError('服务配置已变化，请重试'),
              ),
            );
            return;
          }
          if (!config.isConfigured) {
            throw const ServerNotConfiguredException();
          }
          if (options.uri.origin != Uri.parse(config.baseUrl).origin) {
            throw StateError('请求地址与当前服务器不一致');
          }
          // 认证和账号管理独立于同步策略，数据传输和实时取票统一受同步能力约束。
          if ((options.path.startsWith('/api/v1/sync/') ||
                  options.path == '/api/v1/ws/ticket') &&
              !ref.read(cloudCapabilityProvider).canSync) {
            throw StateError('云同步已暂停，本机数据仍可使用');
          }
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
  dio.interceptors.add(RequestIdInterceptor());
  dio.interceptors.add(
    AuthRefreshInterceptor(
      dio: dio,
      refresh: () => active && ref.mounted
          ? ref.read(authSessionProvider.notifier).refresh()
          : Future.value(''),
      identityGeneration: () => active && ref.mounted
          ? ref.read(authSessionProvider.notifier).identityGeneration
          : -1,
    ),
  );
  dio.interceptors.add(
    CloudConnectionInterceptor(
      connection: ref.read(cloudConnectionProvider.notifier),
      isActive: () => active && ref.mounted,
    ),
  );
  // 不传空拦截器列表，让生成客户端安装 BearerAuthInterceptor 等认证能力。
  final client = SesameApiClient(dio: dio, serializers: apiSerializers);
  final session = ref.read(authSessionProvider);
  if (session != null) {
    client.setBearerAuth('bearerAuth', session.accessToken);
  }
  // 期限转换位于错误链末端，已取消的内部令牌不会覆盖最终展示的网络超时原因。
  dio.interceptors.add(RequestDeadlineInterceptor(timeout: requestDeadline));
  return client;
});

final apiConfigProvider = Provider<ApiConfig>((ref) => const ApiConfig());

/// 单个云请求完整期限可独立注入，认证刷新及重放不延长原请求的等待预算。
final apiRequestDeadlineProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 30),
);

/// 凭证束存储装配（core API 层：刷新拦截器与协调器共用同一实例）。
final secureAccountStoreProvider = Provider<SecureAccountStore>((ref) {
  return SecureAccountStore(
    const KeyedSecureFlutterStore('sesame_notes_active_credential'),
  );
});

/// 当前登录会话（null = 未登录）。
final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);

/// 会话更新后读取身份代次，令订阅者只在身份变化时重新装配。
final authIdentityGenerationProvider = Provider<int>((ref) {
  ref.watch(authSessionProvider);
  return ref.read(authSessionProvider.notifier).identityGeneration;
});

class AuthSessionNotifier extends Notifier<AuthSession?> {
  Future<String>? _refreshInFlight;
  ApiConfig? _refreshConfig;
  int _generation = 0;
  int _identityGeneration = 0;
  Completer<void>? _refreshPause;

  /// 登录身份代次在退出或更换账号设备时递增，令牌刷新保持不变。
  int get identityGeneration => _identityGeneration;

  /// 初始化为未登录状态，Access Token 不做持久化恢复。
  @override
  AuthSession? build() {
    ref.onDispose(() {
      _refreshPause?.complete();
      _refreshPause = null;
    });
    return null;
  }

  /// 无内存会话的缓存登录态也必须收到明确登出通知，交由账号层清理云端数据。
  @override
  bool updateShouldNotify(AuthSession? previous, AuthSession? next) => true;

  /// 账号域清理期间暂停新刷新，在途结果等待退出或换号最终完成后再校验归属。
  void setRefreshBlocked(bool blocked) {
    if (blocked) {
      _refreshPause ??= Completer<void>();
    } else {
      _refreshPause?.complete();
      _refreshPause = null;
    }
  }

  /// 启动恢复、手动下拉与 HTTP 401 共用的单飞入口，等待凭证与资料提交完成。
  Future<String> refresh() {
    if (_refreshPause != null || !ref.read(apiConfigProvider).isConfigured) {
      return Future.value('');
    }
    final active = _refreshInFlight;
    final config = ref.read(apiConfigProvider);
    if (active != null) {
      return identical(_refreshConfig, config)
          ? active
          : _refreshAfterConfiguration(active, config);
    }
    _refreshConfig = config;
    late final Future<String> current;
    current = _refreshOnce(_generation).whenComplete(() {
      if (identical(_refreshInFlight, current)) _refreshInFlight = null;
    });
    _refreshInFlight = current;
    return current;
  }

  /// 服务恢复等待原轮换真实结束，再用已保存的新凭证恢复，避免并发消费同一刷新令牌。
  Future<String> _refreshAfterConfiguration(
    Future<String> previous,
    ApiConfig config,
  ) async {
    final identity = _identityGeneration;
    try {
      await previous;
    } catch (error, stackTrace) {
      logger.error(
        'AuthRefresh',
        '原服务请求已结束，按当前配置恢复',
        safeErrorSummary(error),
        stackTrace,
      );
    }
    if (!ref.mounted ||
        identity != _identityGeneration ||
        !identical(ref.read(apiConfigProvider), config)) {
      return '';
    }
    return refresh();
  }

  /// 同步检查账号代次，避免在异步等待与提交之间使用已经过期的检查结果。
  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  /// 刷新与提交前校验凭证归属；仅服务端明确返回 401 时删除当前凭证。
  Future<String> _refreshOnce(int generation) async {
    final config = ref.read(apiConfigProvider);
    final store = ref.read(secureAccountStoreProvider);
    ActiveCredential? credential;
    ActiveCredential? rotated;
    try {
      credential = await store.load();
      if (!_isCurrent(generation) ||
          _refreshPause != null ||
          !identical(ref.read(apiConfigProvider), config)) {
        return '';
      }
      if (credential == null) {
        if (store.lastError != null) {
          Error.throwWithStackTrace(store.lastError!.$1, store.lastError!.$2);
        }
        signOut();
        return '';
      }
      final refreshed = await ref
          .read(authServiceProvider)
          .refresh(credential: credential);
      rotated = ActiveCredential(
        userId: refreshed.session.userId,
        deviceId: refreshed.session.deviceId,
        refreshToken: refreshed.refreshToken,
      );
      if (!_isCurrent(generation)) return '';
      final current = await store.load();
      // 退出预检可能取消；等待最终结果后再决定是否提交服务器已经轮换的凭证。
      while (ref.mounted && _refreshPause != null) {
        await _refreshPause!.future;
      }
      if (!_isCurrent(generation) || current?.encode() != credential.encode()) {
        return '';
      }
      // 持久化先于内存会话生效，资料桥在会话建立时补齐缓存登录态的资料。
      await store.save(rotated);
      // 在途轮换必须保全新材料；配置变化只禁止迟到结果激活，不能误登记为登出待办。
      if (!_isCurrent(generation)) return '';
      if (!identical(ref.read(apiConfigProvider), config)) {
        rotated = null;
        return '';
      }
      while (ref.mounted && _refreshPause != null) {
        await _refreshPause!.future;
      }
      if (!_isCurrent(generation)) return '';
      if (!identical(ref.read(apiConfigProvider), config)) {
        rotated = null;
        return '';
      }
      await ref.read(cloudProfileCacheProvider).write(refreshed.profile);
      while (ref.mounted && _refreshPause != null) {
        await _refreshPause!.future;
      }
      if (!_isCurrent(generation)) return '';
      if (!identical(ref.read(apiConfigProvider), config)) {
        rotated = null;
        return '';
      }
      signIn(refreshed.session, preserveIdentity: true);
      rotated = null;
      return refreshed.session.accessToken;
    } on DioException catch (error, stackTrace) {
      if (!ref.mounted || !identical(ref.read(apiConfigProvider), config)) {
        return '';
      }
      if (error.response?.statusCode == 401 && credential != null) {
        if (!_isCurrent(generation)) return '';
        final current = await store.load();
        while (ref.mounted && _refreshPause != null) {
          await _refreshPause!.future;
        }
        if (!_isCurrent(generation) ||
            !identical(ref.read(apiConfigProvider), config) ||
            current?.encode() != credential.encode()) {
          return '';
        }
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
          while (ref.mounted && _refreshPause != null) {
            await _refreshPause!.future;
          }
          if (_isCurrent(generation) &&
              identical(ref.read(apiConfigProvider), config)) {
            signOut();
          }
        }
        logger.error('AuthRefresh', '认证失效，请重新登录', error, stackTrace);
      } else {
        logger.warning(
          'AuthRefresh',
          '刷新暂不可用，保留凭证与会话待重试',
          safeErrorSummary(error),
        );
      }
      rethrow;
    } catch (error, stackTrace) {
      logger.error(
        'AuthRefresh',
        '刷新未完成，保留本地登录信息',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    } finally {
      if (rotated != null) {
        try {
          // 已轮换但未提交的凭证只用于撤销；即使退出已清除旧标记也须接住新材料。
          await store.replaceLogoutMarker(credential!, rotated);
        } catch (error, stackTrace) {
          logger.error(
            'AuthRefresh',
            '轮换后的会话撤销材料保存失败',
            error.runtimeType,
            stackTrace,
          );
          rethrow;
        }
      }
    }
  }

  /// 登录成功后注入：写内存会话 + 挂 Bearer token。
  void signIn(AuthSession session, {bool preserveIdentity = false}) {
    if (!preserveIdentity ||
        (state != null &&
            (state?.userId != session.userId ||
                state?.deviceId != session.deviceId))) {
      _identityGeneration++;
    }
    if (state?.userId != session.userId ||
        state?.deviceId != session.deviceId) {
      ref.read(cloudConnectionProvider.notifier).resetForAccountChange();
    }
    _generation++;
    _refreshInFlight = null;
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
    _identityGeneration++;
    ref.read(cloudConnectionProvider.notifier).resetForAccountChange();
    _generation++;
    _refreshInFlight = null;
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
  final config = ref.watch(apiConfigProvider);
  return AuthService(
    client: client,
    identity: identity,
    isCurrent: () =>
        ref.mounted && identical(ref.read(apiConfigProvider), config),
  );
});
