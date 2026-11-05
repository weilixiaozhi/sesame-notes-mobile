import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 云服务配置、同步选择和内存会话共同决定可用能力。
class CloudCapability {
  /// 三项事实分别由装配层传入，不读取账号展示或具体业务状态。
  const CloudCapability({
    required this.serverConfigured,
    required this.syncEnabled,
    required this.hasSession,
  });

  final bool serverConfigured;
  final bool syncEnabled;
  final bool hasSession;

  /// 登录、注册及会话恢复需要服务配置，不受同步开关限制。
  bool get canAuthenticate => serverConfigured;

  /// 缓存身份可以离线建云本，关闭同步后新本归本机。
  bool get canUseCloudBooks => serverConfigured && syncEnabled;

  /// 数据传输及实时通知还需要有效内存会话。
  bool get canSync => canUseCloudBooks && hasSession;
}

/// 账号增量同步策略独立于第三方备份上传开关。
final accountSyncEnabledProvider = NotifierProvider<AccountSyncEnabled, bool>(
  AccountSyncEnabled.new,
);

/// 当前进程的同步选择不改动已有本子归属或缓存身份。
class AccountSyncEnabled extends Notifier<bool> {
  /// 账号增量同步默认启用。
  @override
  bool build() => true;

  /// 调度器订阅策略变化，统一停止或恢复工作。
  void setEnabled(bool enabled) => state = enabled;
}
