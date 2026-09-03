/// 本机备份页（本地存储）：自动本地备份开关 + 手动备份 + 备份快照列表。
///
/// 按 Spitout LocalBackupPage 恢复（结合本仓库实际）：
/// - 本仓库备份文件是 .snbak 加密快照（非 .sqlite），保存在应用私有目录；
/// - 恢复不再做整库文件级覆盖，而是进入 4 步恢复页 RestoreBackupPage
///   （按账本选择策略，Step 1–3 零写入），列表点击 / 从文件恢复均跳转过去；
/// - 「找回旧版本备份」授权弹窗不适用（本仓库不写公共 Download 目录，
///   外部备份经「从文件恢复」兜底）；
/// - 自动备份开关（autoBackupValueProvider）控制冷启动/回前台的自动快照。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_security_store.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/presentation/file_picker_helper.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
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
      await future;
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
      await performManualBackup(read: ref.read);
      if (!mounted) return;
      showToast(context, l10n.localBackupSuccess);
      _reloadBackups();
    } catch (e, st) {
      logger.error('LocalBackup', '手动备份失败', e, st);
      if (!mounted) return;
      showToast(context, l10n.localBackupFailed);
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  /// 点击快照 → 进入 4 步恢复页（该文件预选，输入密码即可打开）。
  Future<void> _restoreFile(LocalBackupFile file) async {
    await context.pushNamed(Routes.backupRestore, extra: file.file.path);
  }

  /// 打开备份密码管理弹层：未设置走设置流程，已设置提供修改/清除。
  Future<void> _openPasswordSheet({required bool configured}) async {
    final l10n = AppLocalizations.of(context);
    if (!configured) {
      await _setPassword();
      return;
    }
    final action = await showAppSheetTop<String>(
      context: context,
      child: AppSheet(
        title: l10n.backupPasswordTitle,
        showGrabHandle: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.settings, size: AppDimens.icon20),
              title: Text(l10n.backupPasswordChange),
              trailing: const Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon20,
              ),
              onTap: () => Navigator.of(context).pop('change'),
            ),
            ListTile(
              leading: const Icon(AppIcons.delete, size: AppDimens.icon20),
              title: Text(l10n.backupPasswordClear),
              trailing: const Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon20,
              ),
              onTap: () => Navigator.of(context).pop('clear'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'change') {
      await _changePassword();
    } else if (action == 'clear') {
      await _clearPassword();
    }
  }

  /// 设置备份密码：新密码 + 确认 → 生成恢复词（仅展示一次）。
  Future<void> _setPassword() async {
    final l10n = AppLocalizations.of(context);
    final fields = await _showPasswordFields(title: l10n.backupPasswordSetAction);
    if (fields == null) return;
    final (_, password, confirm) = fields;
    if (password.length < 8) {
      if (mounted) showToast(context, l10n.backupPasswordTooShort);
      return;
    }
    if (password != confirm) {
      if (mounted) showToast(context, l10n.backupPasswordMismatch);
      return;
    }
    try {
      final words = await BackupSecurityStore().setPassword(password: password);
      ref.invalidate(backupPasswordConfiguredProvider);
      if (!mounted) return;
      showToast(context, l10n.backupPasswordSetSuccess);
      await _showRecoveryWords(words);
    } catch (e, st) {
      logger.error('LocalBackup', '设置备份密码失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    }
  }

  /// 修改备份密码：校验当前密码 → 新密码 + 确认 → 生成新恢复词。
  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    final store = BackupSecurityStore();
    final fields = await _showPasswordFields(
      title: l10n.backupPasswordChange,
      withOld: true,
    );
    if (fields == null) return;
    final (oldPassword, password, confirm) = fields;
    try {
      if (!await store.verifyPassword(oldPassword)) {
        if (mounted) showToast(context, l10n.backupPasswordWrong);
        return;
      }
      if (password.length < 8) {
        if (mounted) showToast(context, l10n.backupPasswordTooShort);
        return;
      }
      if (password != confirm) {
        if (mounted) showToast(context, l10n.backupPasswordMismatch);
        return;
      }
      final words = await store.setPassword(password: password);
      ref.invalidate(backupPasswordConfiguredProvider);
      if (!mounted) return;
      showToast(context, l10n.backupPasswordSetSuccess);
      await _showRecoveryWords(words);
    } catch (e, st) {
      logger.error('LocalBackup', '修改备份密码失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    }
  }

  /// 清除备份密码：二次确认后清除（云端不再上传，历史备份可用恢复词打开）。
  Future<void> _clearPassword() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm<bool>(
      context,
      title: l10n.backupPasswordClear,
      message: l10n.backupPasswordClearConfirm,
    );
    if (confirmed != true || !mounted) return;
    try {
      await BackupSecurityStore().clearPassword();
      ref.invalidate(backupPasswordConfiguredProvider);
      if (mounted) showToast(context, l10n.backupPasswordCleared);
    } catch (e, st) {
      logger.error('LocalBackup', '清除备份密码失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    }
  }

  /// 密码输入弹层：返回 (当前密码, 新密码, 确认密码)；取消返回 null。
  Future<(String, String, String)?> _showPasswordFields({
    required String title,
    bool withOld = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    try {
      final result = await showAppSheetTop<bool>(
        context: context,
        child: AppSheet(
          title: title,
          showGrabHandle: false,
          // ignore: sort_child_properties_last
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (withOld)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.p16),
                    child: TextField(
                      controller: oldCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.backupPasswordOldLabel,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.p16),
                  child: TextField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.backupPasswordNewLabel,
                    ),
                  ),
                ),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.backupPasswordConfirmLabel,
                  ),
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
                  child: Text(l10n.commonConfirm),
                ),
              ),
            ],
          ),
        ),
      );
      if (result != true || !mounted) return null;
      return (
        oldCtrl.text.trim(),
        newCtrl.text,
        confirmCtrl.text,
      );
    } finally {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
    }
  }

  /// 恢复词一次性展示弹窗：请用户抄写保存。
  Future<void> _showRecoveryWords(List<String> words) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await AppDialog.info(
      context,
      title: l10n.backupPasswordRecoveryTitle,
      message:
          '${l10n.backupPasswordRecoveryBody}\n\n${words.join('  ')}',
    );
  }

  /// 从文件恢复：从系统文件选择器挑一个 .snbak 备份，同样进入 4 步恢复页。
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
      if (result == null || result.files.isEmpty) return;
      final path = result.files.first.path;
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
    final isDark = AppTokens.isDark(context);
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
                  // ===== 自动本地备份开关 =====
                  // 背景色由 Material 承载：若用带背景色的 Container 包裹
                  // SwitchListTile，其 ink 波纹会画在 DecoratedBox 之下而被
                  // 遮挡，触发 Flutter 的 ListTile 背景调试断言。
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: Material(
                      color: AppTokens.surface(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                        side: isDark
                            ? BorderSide(color: AppTokens.border(context))
                            : BorderSide.none,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        title: Text(
                          l10n.localBackupAutoTitle,
                          style: AppTextTokens.title(context).copyWith(
                            color: AppTokens.textPrimary(context),
                          ),
                        ),
                        subtitle: Text(
                          l10n.localBackupAutoSubtitle,
                          style: AppTextTokens.caption(context).copyWith(
                            color: AppTokens.textSecondary(context),
                          ),
                        ),
                        // 默认 true（零干预兜底）；加载期间也按 true 展示避免闪烁
                        value: autoBackup.value ?? true,
                        onChanged: (v) =>
                            ref.read(autoBackupSetterProvider).set(v),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p12),
                  // ===== 备份密码 =====
                  // 云端上传的前置条件：未设置时自动备份只做本机快照。
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: Material(
                      color: AppTokens.surface(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                        side: isDark
                            ? BorderSide(color: AppTokens.border(context))
                            : BorderSide.none,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Consumer(
                        builder: (ctx, r, _) {
                          final async = r.watch(backupPasswordConfiguredProvider);
                          final configured = async.asData?.value;
                          return ListTile(
                            leading: Icon(
                              AppIcons.lock,
                              size: AppDimens.icon20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              l10n.backupPasswordTitle,
                              style: AppTextTokens.title(context).copyWith(
                                color: AppTokens.textPrimary(context),
                              ),
                            ),
                            subtitle: Text(
                              configured == null
                                  ? l10n.backupPasswordSubtitle
                                  : (configured
                                        ? '${l10n.backupPasswordSet} · '
                                              '${l10n.backupPasswordSubtitle}'
                                        : '${l10n.backupPasswordNotSet} · '
                                              '${l10n.backupPasswordSubtitle}'),
                              style: AppTextTokens.caption(context).copyWith(
                                color: AppTokens.textSecondary(context),
                              ),
                            ),
                            trailing: Icon(
                              AppIcons.chevronRight,
                              size: AppDimens.icon20,
                              color: AppTokens.iconTertiary(context),
                            ),
                            onTap: () => _openPasswordSheet(
                              configured: configured == true,
                            ),
                          );
                        },
                      ),
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
                      style: AppTextTokens.body(context).copyWith(
                        color: AppTokens.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    child: Text(
                      l10n.localBackupRestoreHint,
                      style: AppTextTokens.caption(context).copyWith(
                        color: AppTokens.textTertiary(context),
                      ),
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
                      if (backups.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppDimens.p32),
                          child: Center(
                            child: Text(
                              l10n.localBackupListEmpty,
                              style: TextStyle(
                                color: AppTokens.textTertiary(context),
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final backup in backups)
                            _buildBackupTile(context, backup, isDark),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.p16),
                  // 从文件恢复入口：卸载重装/换机后历史备份可能不在恢复列表中，
                  // 此处常驻一个手动指定文件的兜底通道，避免「备份还在却恢复不了」。
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                      onTap: _backingUp ? null : _importAndRestore,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.p12,
                          vertical: AppDimens.p8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.fileUpload,
                              size: AppDimens.icon16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimens.p4),
                            Text(
                              l10n.localBackupImportFromFile,
                              style: AppTextTokens.body(context).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
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
  Widget _buildBackupTile(
    BuildContext context,
    LocalBackupFile backup,
    bool isDark,
  ) {
    // 背景色交给 Material 承载（原因同自动备份开关卡片）。
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p4,
      ),
      child: Material(
        color: AppTokens.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          side: isDark
              ? BorderSide(color: AppTokens.border(context))
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(
            backup.fileName,
            style: AppTextTokens.title(context).copyWith(
              color: AppTokens.textPrimary(context),
            ),
          ),
          subtitle: Text(
            backup.sizeLabel,
            style: AppTextTokens.label(context).copyWith(
              color: AppTokens.textSecondary(context),
            ),
          ),
          onTap: () => _restoreFile(backup),
        ),
      ),
    );
  }
}
