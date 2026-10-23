/// 备份同步操作区块（嵌入在选中第三方后端卡片正下方）。
///
/// 按本仓库的备份语义适配：
/// - 第三方备份是「.snbak 整包快照」模型（非逐条增量同步）：
///   上传 = 生成本地快照并版本化上传；下载 = 拉取云端最新快照并进入
///   恢复页（RestoreBackupPage）；
/// - 各后端凭据随配置保存（Supabase 账号密码在配置内，创建服务时自动登录），
///   区块不设独立登录入口；
/// - 「自动同步」开关控制自动备份时是否随之上传云端。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';

/// 备份同步操作区块（上传 / 下载 / 自动同步开关 / 状态）。
///
/// 无 Scaffold / PrimaryHeader / RefreshIndicator 外壳，由 CloudServicePage
/// 嵌入在当前选中的第三方后端卡片正下方（仅激活第三方后端时显示）。
class CloudSyncSection extends ConsumerStatefulWidget {
  const CloudSyncSection({super.key});

  @override
  ConsumerState<CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends ConsumerState<CloudSyncSection> {
  bool _uploadBusy = false;
  bool _downloadBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewAsync = ref.watch(cloudBackupOverviewProvider);

    return overviewAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) {
        logger.error('CloudSyncSection', '加载备份状态失败', e, st);
        return AppEmpty(text: l10n.commonOperationFailed, icon: AppIcons.error);
      },
      data: (overview) {
        final isLocal = overview.active.isLocal;

        // 状态行图标与文案：与入口 tile 同一套映射。
        final statusIcon = switch (cloudBackupStatusOf(overview)) {
          CloudBackupStatusKind.localOnly => AppIcons.localStorage,
          CloudBackupStatusKind.configuredInactive => AppIcons.cloudOff,
          CloudBackupStatusKind.activeNoSuccess => AppIcons.cloudQueue,
          CloudBackupStatusKind.success => AppIcons.verified,
          CloudBackupStatusKind.failed => AppIcons.error,
        };
        final statusText = _statusText(context, overview);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  // 自动备份到云端开关：置于区块最顶部
                  // （本地模式无云端概念，隐藏）。
                  if (!isLocal)
                    Consumer(
                      builder: (ctx, r, _) {
                        final autoSync = r.watch(autoSyncValueProvider);
                        final setter = r.read(autoSyncSetterProvider);
                        final value = autoSync.asData?.value ?? true;
                        return Column(
                          children: [
                            AppSwitchTile(
                              key: const ValueKey('autoSyncRow'),
                              title: l10n.cloudBackupAutoSyncTitle,
                              subtitle: l10n.cloudBackupAutoSyncSubtitle,
                              value: value,
                              onChanged: autoSync.hasValue ? setter.set : null,
                            ),
                            AppTokens.cardDivider(context),
                          ],
                        );
                      },
                    ),
                  // 备份状态：点击查看详情（成功时间/提供方/失败时间）。
                  AppListTile(
                    leading: statusIcon,
                    title: l10n.cloudBackupStatusTitle,
                    subtitle: statusText,
                    onTap: () => _showStatusDetail(context, overview),
                  ),
                  AppTokens.cardDivider(context),
                  // 立即上传：生成本地快照并版本化上传到云端。
                  AppListTile(
                    leading: AppIcons.cloudUpload,
                    title: l10n.cloudBackupUploadNow,
                    subtitle: _uploadBusy ? l10n.cloudBackupUploading : null,
                    enabled: !isLocal && !_uploadBusy && !_downloadBusy,
                    trailing: _uploadBusy
                        ? const SizedBox(
                            width: AppDimens.icon20,
                            height: AppDimens.icon20,
                            child: CircularProgressIndicator(
                              strokeWidth: AppDimens.progressStrokeWidth,
                            ),
                          )
                        : null,
                    onTap: _uploadBusy || _downloadBusy ? null : _uploadNow,
                  ),
                  AppTokens.cardDivider(context),
                  // 从云端恢复：下载云端最新快照并进入恢复页。
                  AppListTile(
                    leading: AppIcons.cloudDownload,
                    title: l10n.cloudBackupRestoreFromCloud,
                    subtitle: _downloadBusy
                        ? l10n.cloudBackupDownloading
                        : (isLocal ? l10n.cloudBackupNotConfigured : null),
                    enabled: !isLocal && !_uploadBusy && !_downloadBusy,
                    trailing: _downloadBusy
                        ? const SizedBox(
                            width: AppDimens.icon20,
                            height: AppDimens.icon20,
                            child: CircularProgressIndicator(
                              strokeWidth: AppDimens.progressStrokeWidth,
                            ),
                          )
                        : null,
                    onTap: _uploadBusy || _downloadBusy
                        ? null
                        : _downloadRestore,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 状态行文案。
  String _statusText(BuildContext context, CloudBackupOverview overview) {
    final l10n = AppLocalizations.of(context);
    return switch (cloudBackupStatusOf(overview)) {
      CloudBackupStatusKind.failed => l10n.cloudBackupEntryFailed,
      CloudBackupStatusKind.localOnly => l10n.cloudBackupEntryLocalOnly,
      CloudBackupStatusKind.configuredInactive =>
        l10n.cloudBackupConfiguredInactive,
      CloudBackupStatusKind.activeNoSuccess => l10n.cloudBackupActiveNoSuccess,
      CloudBackupStatusKind.success => l10n.cloudBackupActiveLastSuccess(
        DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(overview.lastSuccessAt!.toLocal()),
      ),
    };
  }

  /// 状态详情弹窗：成功时间 / 提供方 / 失败时间。
  Future<void> _showStatusDetail(
    BuildContext context,
    CloudBackupOverview overview,
  ) async {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[_statusText(context, overview)];
    if (overview.lastSuccessAt != null) {
      lines.add(
        '${l10n.cloudBackupStatusTitle}: '
        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(overview.lastSuccessAt!.toLocal())}',
      );
    }
    if (overview.lastSuccessProvider != null) {
      lines.add('${l10n.commonCurrent}: ${overview.lastSuccessProvider}');
    }
    if (overview.dirtySince != null) {
      lines.add(
        '${l10n.cloudBackupEntryFailed} '
        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(overview.dirtySince!.toLocal())}',
      );
    }
    await AppDialog.info(
      context,
      title: l10n.cloudBackupStatusTitle,
      message: lines.join('\n'),
    );
  }

  /// 立即上传：手动动作绕过按天去重与 auto_sync 开关。
  Future<void> _uploadNow() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _uploadBusy = true);
    try {
      if (!await performManualBackup(
        read: ref.read,
        confirm: (_) async => mounted,
      )) {
        return;
      }
      if (!mounted) return;
      showToast(context, l10n.cloudBackupUploadSuccess);
      ref.invalidate(cloudBackupOverviewProvider);
      ref.invalidate(cloudBackupBackendsProvider);
    } catch (e, st) {
      logger.error('CloudSyncSection', '立即上传失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.commonFailed,
        message: e is BackupUploadFailedException
            ? l10n.memoBackupLocalOnly
            : l10n.commonOperationFailed,
      );
    } finally {
      if (mounted) setState(() => _uploadBusy = false);
    }
  }

  /// 从云端恢复：下载最新 .snbak → 以外部备份进入恢复页。
  Future<void> _downloadRestore() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _downloadBusy = true);
    File? downloaded;
    try {
      final file = downloaded = await downloadLatestCloudBackup();
      if (!mounted) return;
      if (file == null) {
        await AppDialog.info(
          context,
          title: l10n.cloudBackupRestoreFromCloud,
          message: l10n.cloudBackupNoRemote,
        );
        return;
      }
      showToast(context, l10n.cloudBackupDownloadSuccess);
      await context.pushNamed(Routes.backupRestore, extra: file.path);
    } catch (e, st) {
      logger.error('CloudSyncSection', '云端下载失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.cloudBackupRestoreFromCloud,
        message: l10n.cloudBackupDownloadFailed,
      );
    } finally {
      if (downloaded != null) await releaseDownloadedCloudBackup(downloaded);
      if (mounted) setState(() => _downloadBusy = false);
    }
  }
}
