import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/policy/cloud_capability.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/shared/domain/book_storage_choice.dart';

export 'package:sesame_notes/core/policy/cloud_capability.dart'
    show AccountSyncEnabled, CloudCapability, accountSyncEnabledProvider;
export 'package:sesame_notes/infrastructure/api/api_client_provider.dart'
    show cloudCapabilityProvider;

/// 新本默认归属不修改已有云本；有效缓存账号在本地模式仍可访问已下载内容。
final newBookStorageModeProvider = Provider<String>((ref) {
  return newLedgerStorageMode(
    accountId: ref.watch(currentAccountIdProvider),
    cloudAvailable: ref.watch(cloudCapabilityProvider).canUseCloudBooks,
  );
});

/// 配置或同步策略变化使旧数据操作失效，即使地址随后恢复也不能复活旧结果。
final cloudOperationGenerationProvider =
    NotifierProvider<CloudOperationGeneration, int>(
      CloudOperationGeneration.new,
    );

/// 与账号代次分开累计的服务工作代次。
class CloudOperationGeneration extends Notifier<int> {
  int _generation = 0;

  /// 同步选择和配置每次重建都开启独立操作范围。
  @override
  int build() {
    ref.watch(apiConfigProvider);
    ref.watch(authIdentityGenerationProvider);
    ref.watch(accountSyncEnabledProvider);
    return ++_generation;
  }
}
