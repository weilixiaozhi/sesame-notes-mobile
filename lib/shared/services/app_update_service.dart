/// 应用内「检查更新」服务（P2）。
///
/// 设计意图：本地 APK 分发没有应用商店的自动更新通道，自建轻量检测入口，
/// 通过 GitHub Releases 公开 API 获取最新发布版本与当前安装版本比较，
/// 引导用户前往发布页手动下载安装。所有失败路径（非 200 / 网络异常 /
/// 解析失败）统一降级为 [UpdateStatus.unknown]，不向上抛硬错误。
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sesame_notes/data/models/app_update_info.dart';

/// 应用内「检查更新」服务。
class AppUpdateService {
  /// GitHub 仓库标识（owner/repo）。
  ///
  /// 注意：GitHub owner/repo 尚未冻结，此处为占位值，
  /// 冻结后替换并同步 [AppUpdateInfo.releasePageBase]。
  static const String repoSlug = 'sesame-notes/sesame-notes-mobile';

  /// 检查是否有新版本。
  ///
  /// - 取当前安装的 [PackageInfo.version]（versionName，如 "1.0.0"）；
  /// - 请求 latest release，解析 tagName（如 "v1.0.1"）去 "v" 后比较；
  /// - 非 200（私有仓库匿名 401 / 限流 403）、网络抖动、解析失败都降级为
  ///   [UpdateStatus.unknown]，由调用方引导用户前往发布页；
  /// - [AppUpdateInfo.releaseUrl] 始终兜底到 [releasePageBase]，
  ///   保证「前往发布页」按钮在任何状态下都可用。
  ///
  /// [client] 仅用于单元测试桩接网络；生产传 null 使用默认 [http.Client]。
  /// [currentVersion] 仅测试注入（生产走 PackageInfo 平台实现）。
  static Future<AppUpdateInfo> check({
    http.Client? client,
    String? currentVersion,
  }) async {
    final httpClient = client ?? http.Client();
    // 测试注入版本号时跳过平台实现（PackageInfo 无 binding 会抛错）；
    // 生产走 PackageInfo.fromPlatform 读取安装版本。
    final String current;
    if (currentVersion != null) {
      current = currentVersion;
    } else {
      final pkg = await PackageInfo.fromPlatform();
      current = pkg.version;
    }

    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$repoSlug/releases/latest',
      );
      final resp = await httpClient
          .get(uri, headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        return AppUpdateInfo(
          status: UpdateStatus.unknown,
          currentVersion: current,
          releaseUrl: AppUpdateInfo.releasePageBase,
        );
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String? ?? '').replaceAll(
        RegExp(r'^v'),
        '',
      );
      final htmlUrl =
          data['html_url'] as String? ?? AppUpdateInfo.releasePageBase;

      final hasUpdate = tag.isNotEmpty && _isNewer(tag, current);
      return AppUpdateInfo(
        status: hasUpdate ? UpdateStatus.hasUpdate : UpdateStatus.latest,
        latestVersion: tag.isNotEmpty ? tag : null,
        releaseUrl: htmlUrl,
        currentVersion: current,
      );
    } catch (_) {
      return AppUpdateInfo(
        status: UpdateStatus.unknown,
        currentVersion: current,
        releaseUrl: AppUpdateInfo.releasePageBase,
      );
    }
  }

  /// 语义化版本比较：返回 [latest] 是否严格大于 [current]。
  ///
  /// 按点号分段数值比较（主.次.修订），补零对齐位数避免 "1.9" 大于 "1.10"。
  /// 段数不一致（如 "1.0" vs "1.0.1"）按短侧补 0 处理。
  static bool _isNewer(String latest, String current) {
    final l = _parts(latest);
    final c = _parts(current);
    final n = l.length > c.length ? l.length : c.length;
    for (var i = 0; i < n; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv != cv) return lv > cv;
    }
    return false;
  }

  static List<int> _parts(String v) =>
      v.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}
