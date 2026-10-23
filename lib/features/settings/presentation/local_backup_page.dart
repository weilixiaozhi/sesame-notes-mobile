/// 本机备份页（本地存储）：自动本地备份开关 + 手动备份 + 备份快照列表。
///
/// - 备份文件是 .snbak 明文分帧快照，保存在应用私有目录；
/// - 恢复进入单步恢复页 RestoreBackupPage（打开即预览、勾选账本、立即恢复），
///   列表点击 / 从文件恢复均跳转过去；
/// - 备份文件不写公共 Download 目录，外部备份经「从文件恢复」兜底；
/// - 自动备份开关（autoBackupValueProvider）控制冷启动/回前台的自动快照。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/presentation/file_picker_helper.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 本机备份页：自动备份开关 + 立即备份 + 快照列表恢复入口。
class LocalBackupPage extends ConsumerStatefulWidget {
  const LocalBackupPage({super.key});

  @override
  ConsumerState<LocalBackupPage> createState() => _LocalBackupPageState();
}

class _LocalBackupPageState extends ConsumerState<LocalBackupPage>
    with WidgetsBindingObserver {
  bool _backingUp = false;

  /// 备份列表 Future：initState 创建，下拉刷新 / resume / 备份成功后重建。
  late Future<List<LocalBackupFile>> _backupsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _backupsFuture = _loadBackups();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 从系统设置页（如文件访问授权）返回后重读目录，让新出现的备份立即显示。
    if (state == AppLifecycleState.resumed) {
      _reloadBackups();
    }
  }

  Future<List<LocalBackupFile>> _loadBackups() =>
      ref.read(localBackupServiceProvider).listBackups();

  /// 重建列表 Future 并刷新 UI（内部有 mounted 守卫，可安全在异步回调中调用）。
  void _reloadBackups() {
    if (!mounted) return;
    setState(() {
      _backupsFuture = _loadBackups();
    });
  }

  /// 下拉刷新：等待新 Future 完成，让 RefreshIndicator 的转圈正确收尾。
  Future<void> _refreshBackups() async {
    final future = _loadBackups();
    setState(() {
      _backupsFuture = future;
    });
    try {
      // 最小展示 1 秒：备份列表为本地瞬时查询，凑满时长让指示器完整收起。
      await ensureMinimumRefreshDuration(() => future);
    } catch (e, st) {
      logger.error('LocalBackup', '下拉刷新备份列表失败', e, st);
    }
  }

  /// 手动立即备份：与自动备份同一装配（本地快照 + 云端上传 + 成功记录），
  /// 不受按天去重限制；成功后写入当天日期避免再被自动触发重复备份。
  Future<void> _backupNow() async {
    if (_backingUp) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _backingUp = true);
    try {
      if (!await performManualBackup(
        read: ref.read,
        confirm: (_) async => mounted,
      )) {
        return;
      }
      if (!mounted) return;
      showToast(context, l10n.localBackupSuccess);
      _reloadBackups();
    } catch (e, st) {
      logger.error('LocalBackup', '手动备份失败', e, st);
      if (!mounted) return;
      showToast(
        context,
        e is BackupUploadFailedException
            ? l10n.memoBackupLocalOnly
            : l10n.localBackupFailed,
      );
      _reloadBackups();
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  /// 点击快照 → 进入恢复页（该文件直接打开预览）。
  Future<void> _restoreFile(LocalBackupFile file) async {
    await context.pushNamed(Routes.backupRestore, extra: file.file.path);
  }

  /// 从文件恢复：从系统文件选择器挑一个 .snbak 备份，同样进入恢复页。
  ///
  /// 设计意图：卸载重装/换机后，历史备份可能不在恢复列表（保存在外部目录），
  /// 给用户一个手动指定文件的兜底入口，避免「备份明明还在却恢复不了」。
  Future<void> _importAndRestore() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePickerHelper.pickFileWithExtensions(
        allowedExtensions: ['snbak'],
      );
      // 用户取消选择：静默返回，不打扰
      if (result == null) return;
      final path = result.path;
      if (path == null) {
        // 极端设备只给流不给路径：无法走文件级恢复，按无效文件处理。
        if (!mounted) return;
        showToast(context, l10n.localBackupImportInvalidFile);
        return;
      }
      if (!mounted) return;
      await context.pushNamed(Routes.backupRestore, extra: path);
    } on FileExtensionException {
      // 设备不支持扩展名过滤时用户可能误选其他类型文件，给出明确引导。
      if (!mounted) return;
      showToast(context, l10n.localBackupImportInvalidFile);
    } catch (e, st) {
      logger.error('LocalBackup', '导入备份文件失败', e, st);
      if (!mounted) return;
      showToast(context, l10n.localBackupImportInvalidFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final autoBackup = ref.watch(autoBackupValueProvider);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.localBackupPageTitle,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.fileDownload,
                tooltip: l10n.localBackupNowTooltip,
                spinning: _backingUp,
                onPressed: _backingUp ? null : _backupNow,
              ),
            ],
          ),
          Expanded(
            // 下拉刷新：内容不足一屏时也允许下拉，保证刷新手势始终可用
            child: RefreshIndicator(
              onRefresh: _refreshBackups,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: AppDimens.p16),
                  SectionCard(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: AppSwitchTile(
                      title: l10n.localBackupAutoTitle,
                      subtitle: l10n.localBackupAutoSubtitle,
                      value: autoBackup.value ?? true,
                      onChanged: (value) =>
                          ref.read(autoBackupSetterProvider).set(value),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p20),
                  // ===== 恢复列表 =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: Text(
                      l10n.localBackupListHint,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: Text(
                      l10n.localBackupRestoreHint,
                      style: AppTextTokens.caption(
                        context,
                      ).copyWith(color: AppTokens.textTertiary(context)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  FutureBuilder<List<LocalBackupFile>>(
                    future: _backupsFuture,
                    builder: (context, snapshot) {
                      final backups = snapshot.data ?? [];
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(AppDimens.p32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return AppLoadError(
                          message: l10n.localBackupFailed,
                          onRetry: _reloadBackups,
                        );
                      }
                      if (backups.isEmpty) {
                        return AppEmpty(text: l10n.localBackupListEmpty);
                      }
                      return Column(
                        children: [
                          for (final backup in backups)
                            _buildBackupTile(context, backup),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.p16),
                  // 从文件恢复入口：卸载重装/换机后历史备份可能不在恢复列表中，
                  // 此处常驻一个手动指定文件的兜底通道，避免「备份还在却恢复不了」。
                  Center(
                    child: TextButton.icon(
                      onPressed: _backingUp ? null : _importAndRestore,
                      icon: const Icon(
                        AppIcons.fileUpload,
                        size: AppDimens.icon16,
                      ),
                      label: Text(l10n.localBackupImportFromFile),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 单个备份快照列表项：文件名（主）+ 大小（副），点击进入恢复流程。
  Widget _buildBackupTile(BuildContext context, LocalBackupFile backup) =>
      SectionCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p8,
        ),
        onTap: () => _restoreFile(backup),
        child: AppListTile(
          title: backup.fileName,
          subtitle: backup.sizeLabel,
          titleMaxLines: null,
          subtitleMaxLines: null,
        ),
      );
}
