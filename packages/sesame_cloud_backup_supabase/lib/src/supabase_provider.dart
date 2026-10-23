library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'supabase_storage_service.dart';
import 'supabase_secure_storage.dart';

/// Supabase 云备份提供方，账号密码只用于当前实例的存储会话。
///
/// 配置包含项目 `url`、`anonKey` 和可选的 `bucket`、`pathPrefix`。
/// 备份注册入口还会传入 `account` 与 `password`，在本客户端内完成登录。
///
/// 每个适配器独立持有客户端，备份、恢复和连接测试互不共享认证状态。
/// 调用方使用完毕后必须等待 dispose，释放连接、订阅与 JSON 工作 isolate。
class SupabaseProvider implements CloudProvider {
  final CloudSyncLogger? _logger;

  /// 注入宿主日志回调，并传给当前后端创建的存储服务。
  SupabaseProvider({CloudSyncLogger? logger}) : _logger = logger;

  supabase.SupabaseClient? _client;
  SupabaseStorageService? _storageService;
  Future<void> _lifecycle = Future.value();

  @override
  CloudStorageService get storage {
    if (_storageService == null) {
      throw CloudConfigurationException(
          'Provider not initialized. Call initialize() first.');
    }
    return _storageService!;
  }

  /// 当前实例独占的 SDK 客户端，供后端内部与生命周期验证使用。
  supabase.SupabaseClient? get client => _client;

  /// 同一实例的初始化和释放串行执行，避免在途初始化重新挂回已释放的资源。
  Future<void> _serialize(Future<void> Function() action) {
    final operation = _lifecycle.then((_) => action());
    // 本次失败仍由 operation 返回给调用方，后续生命周期操作可以继续排队。
    _lifecycle = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return operation;
  }

  /// 为当前操作创建独立客户端，使用配置凭据登录且会话仅保留在内存。
  @override
  Future<void> initialize(Map<String, dynamic> config) => _serialize(() async {
        if (!validateConfig(config)) {
          throw CloudConfigurationException(
              'Invalid configuration. Required keys: url, anonKey');
        }

        final url = config['url'] as String;
        final anonKey = config['anonKey'] as String;
        try {
          await _releaseClient();
          _client = supabase.SupabaseClient(
            url,
            anonKey,
            authOptions: supabase.AuthClientOptions(
              authFlowType: supabase.AuthFlowType.pkce,
              pkceAsyncStorage: SecureSupabaseGotrueAsyncStorage(),
            ),
          );
          _storageService = SupabaseStorageService(
            _client!,
            config['bucket'] as String? ?? 'storage',
            config['pathPrefix'] as String?,
            _logger,
          );
        } catch (error, stackTrace) {
          _logger?.error('Supabase 初始化失败：${error.runtimeType}\n$stackTrace');
          await _releaseFailedClient();
          throw CloudConfigurationException('备份服务初始化失败，请检查配置后重试', error);
        }

        try {
          await _signInWithConfig(config);
        } catch (error, stackTrace) {
          // 配置登录保留认证错误类型与结构化错误码，清理故障不能替代原始失败。
          _logger?.error('Supabase 备份登录失败：${error.runtimeType}\n$stackTrace');
          await _releaseFailedClient();
          rethrow;
        }
      });

  /// 凭据只用于当前客户端，未配置账号的直接实例由调用方管理其 SDK 会话。
  Future<void> _signInWithConfig(Map<String, dynamic> config) async {
    try {
      final account = (config['account'] as String?)?.trim();
      if (account == null || account.isEmpty) return;
      final password = (config['password'] as String?) ?? '';
      final response = await _client!.auth.signInWithPassword(
        email: account,
        password: password,
      );
      if (response.user == null) {
        throw CloudAuthException('登录成功但未返回用户会话，请检查验证状态或稍后重试');
      }
    } on supabase.AuthApiException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        CloudAuthException(error.message, error, error.code),
        stackTrace,
      );
    }
  }

  @override
  bool validateConfig(Map<String, dynamic> config) {
    if (!config.containsKey('url') || config['url'] is! String) {
      return false;
    }
    if (!config.containsKey('anonKey') || config['anonKey'] is! String) {
      return false;
    }
    // bucket is optional
    if (config.containsKey('bucket') && config['bucket'] is! String) {
      return false;
    }
    return true;
  }

  /// 释放当前实例的全部 SDK 资源，不撤销其他备份操作的登录会话。
  @override
  Future<void> dispose() => _serialize(_releaseClient);

  /// 先摘除公开引用，再等待底层关闭；重复释放不产生额外操作。
  Future<void> _releaseClient() async {
    final client = _client;
    _storageService = null;
    _client = null;
    try {
      await client?.dispose();
    } catch (error, stackTrace) {
      _logger?.error('Supabase 资源释放失败：${error.runtimeType}\n$stackTrace');
      throw CloudConfigurationException('备份连接关闭失败，请稍后重试', error);
    }
  }

  /// 初始化或登录已有失败时尽力释放资源，清理诊断不改变首个错误的分类。
  Future<void> _releaseFailedClient() async {
    try {
      await _releaseClient();
    } catch (error, stackTrace) {
      _logger?.error('Supabase 失败连接清理异常：${error.runtimeType}\n$stackTrace');
    }
  }
}
