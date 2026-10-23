import 'package:flutter/foundation.dart' show kDebugMode;

/// 需要账号服务时报告缺少服务器配置，与网络故障和凭据错误分别处理。
class ServerNotConfiguredException implements Exception {
  const ServerNotConfiguredException();

  /// 日志仅保留配置缺失事实，不包含账号资料或请求内容。
  @override
  String toString() => 'SERVER_NOT_CONFIGURED: 未配置账号服务器';
}

/// 服务地址可由构建配置注入；空地址允许直接使用本地功能。
abstract final class AppEnvironment {
  static const name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: kDebugMode ? 'test' : 'prod',
  );
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const updateManifestUrl = String.fromEnvironment(
    'UPDATE_MANIFEST_URL',
  );

  /// 账号设备列表沿用应用显示规则，只有测试环境附带 test 标识。
  static String get deviceName => displayName('Sesame Notes Mobile');

  /// 使用本地化品牌名生成系统任务标题，只有测试环境附带 test 标识。
  static String displayName(String brand) =>
      name == 'test' ? '$brand test' : brand;

  /// 在打开本地数据前校验编译配置；参数入口供测试覆盖独立配置组合。
  static void validate({
    String environment = name,
    String apiUrl = apiBaseUrl,
    String updateUrl = updateManifestUrl,
  }) {
    if (environment != 'test' && environment != 'prod') {
      throw StateError('APP_ENV 必须为 test 或 prod。');
    }
    if (apiUrl.isNotEmpty) {
      final uri = Uri.tryParse(apiUrl);
      if (uri == null ||
          apiUrl.trim() != apiUrl ||
          apiUrl.contains('\\') ||
          !uri.hasAuthority ||
          uri.host.isEmpty ||
          uri.port <= 0 ||
          uri.port > 65535 ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw StateError('API_BASE_URL 必须为空或无凭据、查询参数或片段的 HTTP(S) 地址。');
      }
      // 正式包只校验面向客户端的公网入口，反向代理之后可以继续使用 HTTP。
      if (environment == 'prod' && uri.scheme != 'https') {
        throw StateError('正式环境的 API_BASE_URL 必须使用 HTTPS。');
      }
    }
    if (updateUrl.isEmpty) return;
    if (environment == 'test') {
      throw StateError('测试环境的 UPDATE_MANIFEST_URL 必须为空。');
    }
    final updateUri = Uri.tryParse(updateUrl);
    if (updateUri == null ||
        updateUrl.trim() != updateUrl ||
        updateUrl.contains('\\') ||
        updateUri.scheme != 'https' ||
        updateUri.host.isEmpty ||
        updateUri.port <= 0 ||
        updateUri.port > 65535 ||
        updateUri.userInfo.isNotEmpty ||
        updateUri.hasQuery ||
        updateUri.hasFragment) {
      throw StateError('UPDATE_MANIFEST_URL 必须为空或无凭据、查询参数或片段的 HTTPS 地址。');
    }
  }
}
