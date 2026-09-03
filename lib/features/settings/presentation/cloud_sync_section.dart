/// 备份同步操作区块（嵌入在选中第三方后端卡片正下方）。
///
/// 与 Spitout cloud_sync_section.dart 同职责：上传 / 下载 / 登录登出 /
/// 自动同步开关 / 状态，但按本仓库的备份语义适配：
/// - 本仓库第三方备份是「.snbak 整包快照」模型（非逐条增量同步）：
///   上传 = 生成本地快照并版本化上传；下载 = 拉取云端最新快照并进入
///   4 步恢复页（RestoreBackupPage）；
/// - 登录登出仅 Supabase 需要（其余后端用配置内凭据认证）；
/// - 「自动同步」开关控制自动备份时是否随之上传云端。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sesame_notes/core/api/cloud_backup_facade.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_security_store.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// Supabase 认证服务（仅 supabase 激活时非 null）。
final cloudBackupAuthProvider = FutureProvider.autoDispose<CloudAuthService?>((
  ref,
) async {
  final overview = await ref.watch(cloudBackupOverviewProvider.future);
  if (overview.active.backendId != 'supabase') return null;
  final services = await createCloudServices(overview.active);
  // 区块卸载时释放 provider 资源（socket/缓存）。
  ref.onDispose(() {
    services.provider?.dispose();
  });
  return services.auth;
});

/// 备份同步操作区块（上传 / 下载 / 登录登出 / 自动同步开关 / 状态）。
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
        return Center(child: Text(l10n.commonOperationFailed));
      },
      data: (overview) {
        final isLocal = overview.active.isLocal;
        final backendName = _backendNameOf(context, overview);

        // 状态行图标与文案：与入口 tile 同一套映射。
        final statusIcon = switch (cloudBackupStatusOf(overview)) {
          CloudBackupStatusKind.localOnly => AppIcons.localStorage,
          CloudBackupStatusKind.configuredInactive => AppIcons.cloudOff,
          CloudBackupStatusKind.activeNoSuccess => AppIcons.cloudQueue,
          CloudBackupStatusKind.success => AppIcons.verified,
          CloudBackupStatusKind.failed => AppIcons.error,
        };
        final statusText = _statusText(context, overview, backendName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
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
                    enabled:
                        !isLocal &&
                        !_uploadBusy &&
                        !_downloadBusy,
                    trailing: _uploadBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: _uploadBusy || _downloadBusy ? null : _uploadNow,
                  ),
                  AppTokens.cardDivider(context),
                  // 从云端恢复：下载云端最新快照并进入 4 步恢复页。
                  AppListTile(
                    leading: AppIcons.cloudDownload,
                    title: l10n.cloudBackupRestoreFromCloud,
                    subtitle: _downloadBusy
                        ? l10n.cloudBackupDownloading
                        : (isLocal ? l10n.cloudBackupNotConfigured : null),
                    enabled:
                        !isLocal &&
                        !_uploadBusy &&
                        !_downloadBusy,
                    trailing: _downloadBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap:
                        _uploadBusy || _downloadBusy ? null : _downloadRestore,
                  ),
                  // 登录/登出（仅 Supabase 需要，其他后端用配置内凭据认证）。
                  if (!isLocal && overview.active.backendId == 'supabase')
                    Column(
                      children: [
                        AppTokens.cardDivider(context),
                        _SupabaseAuthTile(),
                      ],
                    ),
                  // 自动备份到云端开关（本地模式无云端概念，隐藏）。
                  if (!isLocal)
                    Consumer(
                      builder: (ctx, r, _) {
                        final autoSync = r.watch(autoSyncValueProvider);
                        final setter = r.read(autoSyncSetterProvider);
                        final value = autoSync.asData?.value ?? true;
                        return Column(
                          children: [
                            AppTokens.cardDivider(context),
                            SwitchListTile(
                              title: Text(l10n.cloudBackupAutoSyncTitle),
                              subtitle: Text(l10n.cloudBackupAutoSyncSubtitle),
                              value: value,
                              onChanged: (v) async {
                                await setter.set(v);
                              },
                            ),
                          ],
                        );
                      },
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
  String _statusText(
    BuildContext context,
    CloudBackupOverview overview,
    String backendName,
  ) {
    final l10n = AppLocalizations.of(context);
    if (overview.isDirty) return l10n.cloudBackupEntryFailed;
    if (overview.active.isLocal) {
      return overview.isLocalOnly
          ? l10n.cloudBackupEntryLocalOnly
          : l10n.cloudBackupConfiguredInactive;
    }
    if (overview.lastSuccessAt != null) {
      return l10n.cloudBackupActiveLastSuccess(
        DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(overview.lastSuccessAt!.toLocal()),
      );
    }
    return l10n.cloudBackupActiveNoSuccess;
  }

  /// 状态详情弹窗：成功时间 / 提供方 / 失败时间。
  Future<void> _showStatusDetail(
    BuildContext context,
    CloudBackupOverview overview,
  ) async {
    final l10n = AppLocalizations.of(context);
    final lines = <String>[
      _statusText(context, overview, _backendNameOf(context, overview)),
    ];
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
      // 云端备份必须受密码派生密钥保护：未配置备份密码时给前置引导。
      if (!await BackupSecurityStore().hasPassword()) {
        if (mounted) showToast(context, l10n.cloudBackupNeedPassword);
        return;
      }
      await performManualBackup(read: ref.read);
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
        message: l10n.commonOperationFailed,
      );
    } finally {
      if (mounted) setState(() => _uploadBusy = false);
    }
  }

  /// 从云端恢复：下载最新 .snbak → 以外部备份进入 4 步恢复页。
  Future<void> _downloadRestore() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _downloadBusy = true);
    try {
      final file = await downloadLatestCloudBackup(read: ref.read);
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
      if (mounted) setState(() => _downloadBusy = false);
    }
  }

  /// 后端展示名：注册表描述符 + 本页自定义名映射。
  String _backendNameOf(BuildContext context, CloudBackupOverview overview) {
    if (overview.active.isLocal) {
      return AppLocalizations.of(context).cloudLocalStorageTitle;
    }
    for (final b in overview.backends) {
      if (b.id == overview.active.backendId) return b.displayName;
    }
    return overview.active.backendId;
  }
}

/// Supabase 登录/登出行（本区块专属，随激活后端显隐）。
///
/// 登录/登出会改变认证会话，动作完成后 setState 重读 currentUser，
/// 使行文案立即切换（登录中/已登录）。
class _SupabaseAuthTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SupabaseAuthTile> createState() => _SupabaseAuthTileState();
}

class _SupabaseAuthTileState extends ConsumerState<_SupabaseAuthTile> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authAsync = ref.watch(cloudBackupAuthProvider);

    return authAsync.when(
      loading: () => AppListTile(
        leading: AppIcons.login,
        title: l10n.cloudBackupLogin,
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        enabled: false,
      ),
      error: (e, st) {
        logger.error('CloudSyncSection', '加载 Supabase 认证失败', e, st);
        return AppListTile(
          leading: AppIcons.login,
          title: l10n.cloudBackupLogin,
          enabled: false,
        );
      },
      data: (auth) => FutureBuilder<CloudUser?>(
        future: auth?.currentUser,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return AppListTile(
              leading: AppIcons.login,
              title: l10n.cloudBackupLogin,
              trailing: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              enabled: false,
            );
          }
          final user = snap.data;
          return AppListTile(
            leading: user == null
                ? AppIcons.login
                : AppIcons.verifiedUser,
            title: user == null
                ? l10n.cloudBackupLogin
                : user.account ?? l10n.cloudBackupLoginSuccess,
            onTap: () async {
              if (auth == null) return;
              if (user == null) {
                await _showLoginSheet(context, auth);
              } else {
                await _confirmLogout(context, auth);
              }
              // 登录/登出后重读当前用户，刷新行文案。
              if (mounted) setState(() {});
            },
          );
        },
      ),
    );
  }

  /// 登录弹窗：账号 + 密码（凭据仅用于本次登录，不落配置存储）。
  Future<void> _showLoginSheet(BuildContext context, CloudAuthService auth) async {
    final l10n = AppLocalizations.of(context);
    final accountController = TextEditingController();
    final passwordController = TextEditingController();
    try {
      final result = await showAppSheetTop<dynamic>(
        context: context,
        child: AppSheet(
          title: l10n.cloudBackupLogin,
          showGrabHandle: false,
          // ignore: sort_child_properties_last
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.p16),
                  child: TextField(
                    controller: accountController,
                    decoration: InputDecoration(
                      labelText: l10n.cloudBackupAccountLabel,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.cloudBackupPasswordLabel,
                  ),
                  obscureText: true,
                  onSubmitted: (_) => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
          footer: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.cloudBackupLogin),
                ),
              ),
            ],
          ),
        ),
      );
      if (result != true || !context.mounted) return;
      try {
        await auth.signInWithAccount(
          account: accountController.text.trim(),
          password: passwordController.text,
        );
        if (context.mounted) showToast(context, l10n.cloudBackupLoginSuccess);
      } catch (e, st) {
        logger.warning('CloudSyncSection', 'Supabase 登录失败: $e', st);
        if (context.mounted) {
          await AppDialog.error(
            context,
            title: l10n.cloudBackupLoginFailed,
            message: l10n.commonOperationFailed,
          );
        }
      }
    } finally {
      accountController.dispose();
      passwordController.dispose();
    }
  }

  /// 退出登录：二次确认 → signOut → 刷新认证状态。
  Future<void> _confirmLogout(BuildContext context, CloudAuthService auth) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.mineLogoutConfirmTitle,
      message: l10n.mineLogoutConfirmMessage,
      okLabel: l10n.mineLogoutButton,
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await auth.signOut();
      if (context.mounted) showToast(context, l10n.cloudClearConfigDone);
    } catch (e, st) {
      logger.error('CloudSyncSection', 'Supabase 登出失败', e, st);
      if (context.mounted) {
        await AppDialog.error(
          context,
          title: l10n.commonFailed,
          message: l10n.commonOperationFailed,
        );
      }
    }
  }
}
