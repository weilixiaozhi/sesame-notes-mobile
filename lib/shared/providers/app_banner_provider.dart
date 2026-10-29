import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/logger_service.dart';
import '../../data/models/app_banner.dart';
import '../../data/repositories/app_banner_repository.dart';
import '../../infrastructure/api/api_client_provider.dart';

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
    FutureProvider.autoDispose<Map<AppBannerSlot, ResolvedAppBanner>>((
      ref,
    ) async {
      try {
        if (!ref.watch(apiConfigProvider).isConfigured) return const {};
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
