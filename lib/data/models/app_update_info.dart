/// 应用更新检查相关纯数据模型（P2）。
///
/// 设计意图：UI 层只依赖本文件的纯数据类型，不直连 services 层实现；
/// 这些类型不持有 provider / http 客户端 / db 引用，依赖方向保持
/// `pages/widgets → services → data` 单向流动。
library;

/// 更新检查的状态枚举。
///
/// 设计意图：把「结果」与「异常」解耦——私有仓库匿名请求 401、限流 403、
/// 网络抖动都不应表现为硬错误，降级为 [unknown] 由 UI 统一引导去 GitHub。
enum UpdateStatus {
  /// 检测到新版本。
  hasUpdate,

  /// 已是最新版本。
  latest,

  /// 无法自动检测（私有仓库 / 网络异常等），引导用户手动前往发布页。
  unknown,
}

/// 「检查更新」的结果。
class AppUpdateInfo {
  /// 发布/下载页基础地址（无具体 release 时兜底）。
  ///
  /// 注意：新仓库的 GitHub owner/repo 尚未冻结，此处为占位值，
  /// 冻结后随 repoSlug 一并替换。
  static const String releasePageBase =
      'https://github.com/sesame-notes/sesame-notes-mobile/releases';

  /// 检查状态（三态），UI 据此切换弹窗样式与按钮。
  final UpdateStatus status;

  /// 是否存在比当前更新的版本（由 [status] 派生，杜绝矛盾组合）。
  bool get hasUpdate => status == UpdateStatus.hasUpdate;

  /// 远端最新版本号（去 "v" 后，如 "1.0.1"），无数据时为空。
  final String? latestVersion;

  /// 远端 release 的 HTML 地址；为空时 UI 以 [releasePageBase] 兜底。
  final String? releaseUrl;

  /// 当前安装版本号（如 "1.0.0"）。
  final String currentVersion;

  const AppUpdateInfo({
    required this.status,
    this.latestVersion,
    this.releaseUrl,
    required this.currentVersion,
  });
}
