/// Mine 页「备份与云同步配置」统一入口。
///
/// 与 Spitout 的 CloudServiceEntryTile 同职责：图标与副标题按备份状态动态切换，
/// 点击统一进入 CloudServicePage（不按后端类型路由分叉）。本仓库的官方云同步
/// 由个人资料区承载，故状态数据源为第三方备份总览 [CloudBackupOverview]
/// （激活配置 + 最近成功/失败标记），非官方同步引擎的 SyncDiff。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// Mine 页「备份与云同步配置」统一入口。
///
/// 点击入口回调由 page 层注入导航逻辑（进入云服务页），widget 不感知具体页面。
class CloudServiceEntryTile extends ConsumerWidget {
  /// 点击入口回调，由 page 层注入导航逻辑（通常进入云服务配置页）。
  final VoidCallback onTap;

  const CloudServiceEntryTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overviewAsync = ref.watch(cloudBackupOverviewProvider);

    // 首屏加载中：图标占位 + spinner。
    if (overviewAsync.isLoading) {
      return AppListTile(
        leading: AppIcons.cloudQueue,
        title: l10n.mineCloudService,
        subtitle: l10n.mineCloudServiceLoading,
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onTap: onTap,
      );
    }

    final overview = overviewAsync.value;
    if (overview == null) {
      // 状态读取失败：入口仍可点，用错误态提示。
      return AppListTile(
        leading: AppIcons.error,
        title: l10n.mineCloudService,
        subtitle: l10n.mineSyncError,
        onTap: onTap,
      );
    }

    final status = cloudBackupStatusOf(overview);
    final icon = switch (status) {
      CloudBackupStatusKind.localOnly => AppIcons.localStorage,
      CloudBackupStatusKind.configuredInactive => AppIcons.cloudOff,
      CloudBackupStatusKind.activeNoSuccess => AppIcons.cloudQueue,
      CloudBackupStatusKind.success => AppIcons.verified,
      CloudBackupStatusKind.failed => AppIcons.error,
    };
    final subtitle = switch (status) {
      CloudBackupStatusKind.localOnly => l10n.cloudBackupEntryLocalOnly,
      CloudBackupStatusKind.configuredInactive =>
        l10n.cloudBackupConfiguredInactive,
      CloudBackupStatusKind.activeNoSuccess => l10n.cloudBackupActiveNoSuccess,
      CloudBackupStatusKind.success => l10n.cloudBackupActiveLastSuccess(
        _formatTime(overview.lastSuccessAt!.toLocal()),
      ),
      CloudBackupStatusKind.failed => l10n.cloudBackupEntryFailed,
    };

    return AppListTile(
      leading: icon,
      title: l10n.mineCloudService,
      subtitle: subtitle,
      trailing: Icon(
        AppIcons.chevronRight,
        color: AppTokens.iconTertiary(context),
        size: AppDimens.icon20,
      ),
      onTap: onTap,
    );
  }

  /// 最近成功时间格式：yyyy-MM-dd HH:mm。
  static String _formatTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}
