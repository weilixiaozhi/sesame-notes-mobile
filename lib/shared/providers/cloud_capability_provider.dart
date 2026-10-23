import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/features/ledgers/domain/ledger_storage_choice.dart';

/// 账号服务能力与本机身份分开：认证不依赖同步选择，离线数据不依赖网络会话。
class CloudCapability {
  /// 三项事实分别来自服务配置、账号同步策略与内存会话。
  const CloudCapability({
    required this.serverConfigured,
    required this.syncEnabled,
    required this.hasSession,
  });

  final bool serverConfigured;
  final bool syncEnabled;
  final bool hasSession;

  /// 登录、注册及会话恢复必须先有服务，但不受同步开关限制。
  bool get canAuthenticate => serverConfigured;

  /// 缓存身份可以离线建云本；关闭同步或移除服务后新本明确归本机。
  bool get canUseCloudBooks => serverConfigured && syncEnabled;

  /// 数据传输及实时通知还需要有效内存会话，服务地址不决定账号归属。
  bool get canSync => canUseCloudBooks && hasSession;
}

/// 账号增量同步策略独立于第三方备份上传开关，默认启用。
final accountSyncEnabledProvider = NotifierProvider<AccountSyncEnabled, bool>(
  AccountSyncEnabled.new,
);

/// 当前应用生命周期中的同步策略；不改动本子归属或缓存身份。
class AccountSyncEnabled extends Notifier<bool> {
  /// 账号同步沿用默认启用语义。
  @override
  bool build() => true;

  /// 调整传输策略后由各调度器订阅停止或恢复工作。
  void setEnabled(bool enabled) => state = enabled;
}

/// 所有云功能共享同一份能力判定，缓存身份仅用于数据访问和新本归属。
final cloudCapabilityProvider = Provider<CloudCapability>((ref) {
  final config = ref.watch(apiConfigProvider);
  final session = ref.watch(authSessionProvider);
  return CloudCapability(
    serverConfigured: config.isConfigured,
    syncEnabled: ref.watch(accountSyncEnabledProvider),
    hasSession: session != null,
  );
});

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
