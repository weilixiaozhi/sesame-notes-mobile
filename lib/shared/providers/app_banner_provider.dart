import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/logger_service.dart';
import '../../data/models/app_banner.dart';
import '../../data/repositories/app_banner_repository.dart';
import '../../infrastructure/api/api_client_provider.dart';

/// 同时出现的入口共享刷新节流，前台恢复不产生重复网络请求。
class AppBannerRefreshGate {
  DateTime? _lastRefresh;

  /// 页面实际开始取配置时记录时间，不读取或清除任何图片缓存。
  void mark(DateTime now) => _lastRefresh = now;

  /// 只有距上次配置请求至少三十秒时允许可见页面主动刷新。
  bool claim(DateTime now) {
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < const Duration(seconds: 30)) {
      return false;
    }
    mark(now);
    return true;
  }
}

/// 服务地址变化时独立建立刷新节流，不沿用另一个环境的时间状态。
final appBannerRefreshGateProvider = Provider<AppBannerRefreshGate>((ref) {
  ref.watch(apiConfigProvider);
  return AppBannerRefreshGate();
});

/// 横幅使用独立匿名连接，不携带登录凭据，不影响账号连接状态。
final appBannerRepositoryProvider = Provider.autoDispose<AppBannerRepository>((
  ref,
) {
  final config = ref.watch(apiConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );
  ref.onDispose(() {
    try {
      dio.close(force: true);
    } catch (error, stackTrace) {
      logger.error(
        'AppBanner',
        '横幅连接释放失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  });
  return AppBannerRepository(dio: dio);
});

/// 当前服务地址的图片和目标只保存在内存，页面重新进入时刷新；加载期间直接显示内置入口。
final appBannersProvider =
    FutureProvider.autoDispose<Map<AppBannerSlot, List<ResolvedAppBanner>>>((
      ref,
    ) async {
      try {
        if (!ref.watch(apiConfigProvider).isConfigured) return const {};
        ref.read(appBannerRefreshGateProvider).mark(DateTime.now());
        return await ref.watch(appBannerRepositoryProvider).load();
      } catch (error, stackTrace) {
        logger.error(
          'AppBanner',
          '横幅加载失败，继续使用内置入口',
          safeErrorSummary(error),
          stackTrace,
        );
        return const {};
      }
    });
