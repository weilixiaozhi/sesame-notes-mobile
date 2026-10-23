import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/shared_preferences_provider.dart';
import '../domain/analytics/product_analytics_context.dart';
import '../domain/analytics/product_analytics_ports.dart';
import '../features/auth/application/security_providers.dart';
import '../features/fitness/application/fitness_analytics.dart';
import '../infrastructure/analytics/product_analytics_service.dart';
import '../infrastructure/analytics/preferences_analytics_flow_store.dart';
import '../infrastructure/api/api_client_provider.dart';
import '../shared/application/product_analytics_controller.dart';
import '../shared/presentation/analytics/product_analytics_page_state.dart';
import '../shared/providers/account_state_provider.dart';
import '../shared/providers/ui_state_providers.dart';

/// 前后台由全局生命周期桥接更新，初始化保持可见的普通界面默认状态。
class ProductAnalyticsVisibility {
  bool foreground = true;
}

/// 可注入时钟保持应用采集与测试使用同一个时间来源。
final productAnalyticsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// 生命周期状态独立于业务状态，不在组件构建期间写入响应式业务提供者。
final productAnalyticsVisibilityProvider = Provider(
  (ref) => ProductAnalyticsVisibility(),
);

/// 通用页面登记只持有界面状态，装配层负责释放。
final productAnalyticsPageStateProvider = Provider<ProductAnalyticsPageState>((
  ref,
) {
  final state = ProductAnalyticsPageState();
  ref.onDispose(state.dispose);
  return state;
});

/// 应用认证信息仅在装配层读取，领域及基础设施使用注入的身份值。
ProductAnalyticsIdentity _identity(Ref ref) {
  final account = ref.read(accountStateProvider);
  return ProductAnalyticsIdentity(
    account.isAuthenticated ? account.userId : null,
    ref.read(authIdentityGenerationProvider),
  );
}

/// 真实重试入口重建已失败的装配，进行中的初始化保持单飞。
Future<T> _retryFailed<T>(Ref ref, FutureProvider<T> provider) {
  final state = ref.read(provider);
  if (state.hasError && !state.isLoading) {
    final preferences = ref.read(sharedPreferencesProvider);
    if (preferences.hasError && !preferences.isLoading) {
      ref.invalidate(sharedPreferencesProvider);
    }
    ref.invalidate(provider);
  }
  return ref.read(provider.future);
}

/// 唯一事件写入实现装配入口，界面和用例只依赖领域端口。
final productAnalyticsWriterProvider =
    FutureProvider<ProductAnalyticsEventWriter>((ref) async {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final service = ProductAnalyticsService(
        dio: ref.watch(apiClientProvider).dio,
        preferences: preferences,
        accountId: () => _identity(ref).account,
        accessToken: () => ref.read(authSessionProvider)?.accessToken,
        identityGeneration: () => _identity(ref).generation,
        clock: ref.read(productAnalyticsClockProvider),
      );
      ref.onDispose(service.dispose);
      return service;
    });

/// 关联存储与事件上传分别装配，不让训练记录索引进入上传实现。
final productAnalyticsFlowStoreProvider =
    FutureProvider<ProductAnalyticsFlowStore>((ref) async {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final store = PreferencesAnalyticsFlowStore(
        preferences: preferences,
        environment: ref.watch(apiConfigProvider).baseUrl,
        currentIdentity: () => _identity(ref),
        clock: ref.read(productAnalyticsClockProvider),
      );
      ref.onDispose(store.dispose);
      return store;
    });

/// 采集用例只接收端口和运行态，认证、启动与隐私状态在此完成装配。
final productAnalyticsControllerProvider = Provider<ProductAnalyticsController>(
  (ref) {
    ref.watch(apiConfigProvider);
    final controller = ProductAnalyticsController(
      writer: () => _retryFailed(ref, productAnalyticsWriterProvider),
      clock: ref.read(productAnalyticsClockProvider),
      runtime: () => ProductAnalyticsRuntime(
        identity: _identity(ref),
        enabled:
            ref.read(appInitStateProvider) == AppInitState.ready &&
            !ref.read(shouldShowWelcomeProvider) &&
            !ref.read(isAppLockedProvider) &&
            !ref.read(showPrivacyScreenProvider) &&
            ref.read(productAnalyticsVisibilityProvider).foreground,
      ),
    );
    ref.listen(
      authIdentityGenerationProvider,
      (_, _) => controller.identityChanged(),
    );
    ref.listen(accountStateProvider, (before, after) {
      if (before?.userId != after.userId ||
          before?.isAuthenticated != after.isAuthenticated) {
        controller.identityChanged();
      }
    });
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// 训练场景在自身应用用例中管理关联，不暴露通用存储实现给业务组件。
final fitnessAnalyticsProvider = Provider<FitnessAnalytics>(
  (ref) => FitnessAnalytics(
    controller: ref.watch(productAnalyticsControllerProvider),
    store: () => _retryFailed(ref, productAnalyticsFlowStoreProvider),
  ),
);
