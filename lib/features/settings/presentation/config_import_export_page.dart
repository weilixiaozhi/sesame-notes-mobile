import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/shared/presentation/file_picker_helper.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/features/settings/application/import_export_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 配置导入导出页面
class ConfigImportExportPage extends ConsumerStatefulWidget {
  const ConfigImportExportPage({super.key});

  @override
  ConsumerState<ConfigImportExportPage> createState() =>
      _ConfigImportExportPageState();
}

class _ConfigImportExportPageState
    extends ConsumerState<ConfigImportExportPage> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportConfig() async {
    // Step 1: 显示选择导出内容对话框
    final options = await showDialog<ExportOptions>(
      context: context,
      builder: (context) => const _ExportOptionsDialog(),
    );

    if (options == null || !mounted) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Step 2: 生成预览内容
      final yamlContent = await exportConfigToYaml(ref, options);

      if (!mounted) return;

      // Step 3: 显示预览并确认导出
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => _ExportPreviewDialog(yamlContent: yamlContent),
      );

      if (confirm != true || !mounted) {
        setState(() => _isExporting = false);
        return;
      }

      // Step 4: 写入临时文件并交给系统分享面板，由用户选择保存位置。
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'sesame_notes_config_$timestamp.yml';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(yamlContent);

      try {
        if (!mounted) return;
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: AppLocalizations.of(context).configExportShareSubject,
          ),
        );

        if (result.status == ShareResultStatus.success) {
          if (!mounted) return;
          showToast(context, AppLocalizations.of(context).configExportSuccess);
        }
      } finally {
        // 配置可能包含账户定位信息，分享完成后立即清理临时文件。
        try {
          if (file.existsSync()) await file.delete();
        } catch (e, st) {
          logger.warning('ConfigExport', '清理临时导出文件失败: $e', st);
        }
      }
    } catch (e, st) {
      logger.error('ConfigExport', '导出配置失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: AppLocalizations.of(context).configExportFailed,
        message: AppLocalizations.of(context).commonOperationFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importConfig() async {
    setState(() => _isImporting = true);

    try {
      // Step 1: 选择文件（使用 FilePickerHelper 处理部分设备不支持扩展名过滤的问题）
      final result = await FilePickerHelper.pickYamlFile();

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() => _isImporting = false);
        }
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context).configImportNoFilePath);
      }

      // Step 2: 读取文件并检测可用内容
      if (!mounted) return;
      final file = File(filePath);
      final yamlContent = await file.readAsString();

      // 检测文件中包含哪些配置项
      final contentInfo = detectConfigContent(yamlContent);

      // Step 3: 显示预览并选择导入内容的对话框
      if (!mounted) return;
      final options = await showDialog<ExportOptions>(
        context: context,
        builder: (context) => _ImportPreviewDialog(
          yamlContent: yamlContent,
          contentInfo: contentInfo,
        ),
      );

      if (options == null || !mounted) {
        setState(() => _isImporting = false);
        return;
      }

      // Step 4: 执行导入（页面已持有 yamlContent,直接走内存导入,避免重复读盘）
      // 注意：不传入 ledgerId，让导入逻辑使用 yml 中指定的账本名称
      // 这样预算等数据会导入到正确的账本，而不是当前账本
      await importConfigFromYaml(ref, yamlContent, options);

      // 导入后立即刷新相关的 Provider 状态
      if (options.appSettings) {
        await _refreshProvidersAfterImport();
      }

      if (!mounted) return;
      showToast(context, AppLocalizations.of(context).configImportSuccess);

      // 提示需要重启应用（部分设置可能仍需重启）
      if (!mounted) return;
      await AppDialog.info(
        context,
        title: AppLocalizations.of(context).configImportRestartTitle,
        message: AppLocalizations.of(context).configImportRestartMessage,
      );
    } catch (e, st) {
      logger.error('ConfigImport', '导入配置失败', e, st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: AppLocalizations.of(context).configImportFailed,
        message: AppLocalizations.of(context).commonOperationFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  /// 导入后刷新相关的 Provider 状态
  Future<void> _refreshProvidersAfterImport() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 刷新主题模式
      final themeMode = prefs.getString('themeMode');
      if (themeMode != null) {
        switch (themeMode) {
          case 'light':
            ref.read(themeModeProvider.notifier).set(ThemeMode.light);
            break;
          case 'dark':
            ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
            break;
          default:
            ref.read(themeModeProvider.notifier).set(ThemeMode.system);
        }
        logger.info('ConfigImport', '主题模式已刷新: $themeMode');
      }

      logger.info('ConfigImport', 'Provider 状态刷新完成');
    } catch (e) {
      logger.error('ConfigImport', '刷新 Provider 状态失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.configImportExportTitle,
            subtitle: l10n.configImportExportSubtitle,
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.p12,
                vertical: AppDimens.p8,
              ),
              children: [
                // 说明卡片
                SectionCard(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(AppDimens.p12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.info,
                              size: AppDimens.icon20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: AppDimens.p8),
                            Text(
                              l10n.configImportExportInfoTitle,
                              style: AppTextTokens.strongTitle(
                                context,
                              ).copyWith(color: AppTokens.textPrimary(context)),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimens.p8),
                        Text(
                          l10n.configImportExportInfoMessage,
                          style: AppTextTokens.body(context).copyWith(
                            color: AppTokens.textSecondary(context),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: AppDimens.p12),
                        // 包含的配置项列表（合并自原底部说明卡片，仅保留一个说明区域）
                        Text(
                          l10n.configImportExportIncludesTitle,
                          style: AppTextTokens.body(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTokens.textPrimary(context),
                          ),
                        ),
                        SizedBox(height: AppDimens.p8),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.book,
                          l10n.configIncludeLedgers,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.category,
                          l10n.configIncludeCategories,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.repeat,
                          l10n.configIncludeRecurringTransactions,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.cloud,
                          l10n.configIncludeSupabase,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.folder,
                          l10n.configIncludeWebdav,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.storage,
                          l10n.configIncludeS3,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.cloudSync,
                          l10n.configIncludeCloud,
                        ),
                        SizedBox(height: AppDimens.p4),
                        _buildConfigItem(
                          context,
                          ref,
                          AppIcons.settings,
                          l10n.configIncludeAppSettings,
                        ),
                        SizedBox(height: AppDimens.p12),
                        // 注意事项：用橙色背景区块突出敏感信息和覆盖风险
                        Container(
                          padding: EdgeInsets.all(AppDimens.p8),
                          decoration: BoxDecoration(
                            color: AppTokens.warning(
                              context,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radius8,
                            ),
                            border: Border.all(
                              color: AppTokens.warning(
                                context,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                AppIcons.warning,
                                size: AppDimens.icon16,
                                color: AppTokens.warning(context),
                              ),
                              SizedBox(width: AppDimens.p8),
                              Expanded(
                                child: Text(
                                  l10n.configImportExportWarning,
                                  style: AppTextTokens.label(context).copyWith(
                                    color: AppTokens.warning(context),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppDimens.p8),
                // 功能按钮
                SectionCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // 导出配置
                      AppListTile(
                        leading: AppIcons.fileUpload,
                        title: l10n.configExportTitle,
                        subtitle: l10n.configExportSubtitle,
                        trailing: _isExporting
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                        onTap: _isExporting ? null : _exportConfig,
                      ),
                      AppTokens.cardDivider(context),
                      // 导入配置
                      AppListTile(
                        leading: AppIcons.download,
                        title: l10n.configImportTitle,
                        subtitle: l10n.configImportSubtitle,
                        trailing: _isImporting
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                        onTap: _isImporting ? null : _importConfig,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimens.icon16,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: AppDimens.p8),
        Expanded(
          child: Text(
            text,
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.textPrimary(context)),
          ),
        ),
      ],
    );
  }
}

/// 导出选项选择对话框
class _ExportOptionsDialog extends StatefulWidget {
  const _ExportOptionsDialog();

  @override
  State<_ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<_ExportOptionsDialog> {
  // 默认全选
  bool _ledgers = true;
  bool _categories = true;
  bool _recurringTransactions = true;
  bool _appSettings = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p20,
        vertical: AppDimens.p40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      backgroundColor: AppTokens.surfaceElevated(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            decoration: BoxDecoration(
              color: AppTokens.surfaceElevated(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius12),
                topRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.checklist),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: Text(
                    l10n.configExportSelectTitle,
                    style: AppTextTokens.strongTitle(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 选项列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
            child: Column(
              children: [
                CheckboxListTile(
                  value: _ledgers,
                  onChanged: (v) => setState(() => _ledgers = v ?? true),
                  title: Text(l10n.configIncludeLedgers),
                  secondary: Icon(AppIcons.book, color: primary),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _categories,
                  onChanged: (v) => setState(() => _categories = v ?? true),
                  title: Text(l10n.configIncludeCategories),
                  secondary: Icon(AppIcons.category, color: primary),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _recurringTransactions,
                  onChanged: (v) =>
                      setState(() => _recurringTransactions = v ?? true),
                  title: Text(l10n.configIncludeRecurringTransactions),
                  secondary: Icon(AppIcons.repeat, color: primary),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: _appSettings,
                  onChanged: (v) => setState(() => _appSettings = v ?? true),
                  title: Text(l10n.configIncludeOtherSettings),
                  subtitle: Text(
                    l10n.configIncludeOtherSettingsSubtitle,
                    style: AppTextTokens.label(
                      context,
                    ).copyWith(color: AppTokens.textSecondary(context)),
                  ),
                  secondary: Icon(AppIcons.settings, color: primary),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.p8),
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: AppDimens.p12),
                FilledButton(
                  onPressed: () {
                    final options = ExportOptions(
                      ledgers: _ledgers,
                      categories: _categories,
                      recurringTransactions: _recurringTransactions,
                      appSettings: _appSettings,
                    );
                    Navigator.pop(context, options);
                  },
                  child: Text(l10n.commonNext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 导出预览对话框
class _ExportPreviewDialog extends StatelessWidget {
  final String yamlContent;

  const _ExportPreviewDialog({required this.yamlContent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p20,
        vertical: AppDimens.p40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      backgroundColor: AppTokens.surfaceElevated(context),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            decoration: BoxDecoration(
              color: AppTokens.surfaceElevated(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius12),
                topRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.preview),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: Text(
                    l10n.configExportPreviewTitle,
                    style: AppTextTokens.strongTitle(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context, false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.p12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.p12),
                    decoration: BoxDecoration(
                      color: AppTokens.surface(context),
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                      border: Border.all(color: AppTokens.border(context)),
                    ),
                    child: SelectableText(
                      yamlContent,
                      style: AppTextTokens.label(context).copyWith(
                        height: 1.5,
                        color: AppTokens.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: AppDimens.p12),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.configExportConfirmTitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 导入预览对话框（先预览内容，再选择导入项）
class _ImportPreviewDialog extends StatefulWidget {
  final String yamlContent;
  final ConfigContentInfo contentInfo;

  const _ImportPreviewDialog({
    required this.yamlContent,
    required this.contentInfo,
  });

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  // 默认全选（仅对文件中存在的项）
  late bool _ledgers;
  late bool _categories;
  late bool _recurringTransactions;
  late bool _appSettings;

  @override
  void initState() {
    super.initState();
    _ledgers = widget.contentInfo.hasLedgers;
    _categories = widget.contentInfo.hasCategories;
    _recurringTransactions = widget.contentInfo.hasRecurringTransactions;
    _appSettings = widget.contentInfo.hasAppSettings;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final info = widget.contentInfo;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p20,
        vertical: AppDimens.p40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      backgroundColor: AppTokens.surfaceElevated(context),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            decoration: BoxDecoration(
              color: AppTokens.surfaceElevated(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius12),
                topRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.preview),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: Text(
                    l10n.configImportPreviewTitle,
                    style: AppTextTokens.strongTitle(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // YAML 内容预览
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 警告提示
                  Container(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    decoration: BoxDecoration(
                      color: AppTokens.warning(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                      border: Border.all(
                        color: AppTokens.warning(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          AppIcons.warning,
                          color: AppTokens.warning(context),
                          size: AppDimens.icon20,
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Expanded(
                          child: Text(
                            l10n.configImportOverwriteWarning,
                            style: AppTextTokens.label(
                              context,
                            ).copyWith(color: AppTokens.warning(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  // YAML 内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.p12),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: AppTokens.surface(context),
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                      border: Border.all(color: AppTokens.border(context)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        widget.yamlContent,
                        style: AppTextTokens.label(context).copyWith(
                          height: 1.5,
                          color: AppTokens.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  // 选择导入内容标题
                  Text(
                    l10n.configImportSelectTitle,
                    style: AppTextTokens.body(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTokens.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  // 选项列表
                  if (info.hasLedgers)
                    CheckboxListTile(
                      value: _ledgers,
                      onChanged: (v) => setState(() => _ledgers = v ?? true),
                      title: Text(l10n.configIncludeLedgers),
                      secondary: Icon(AppIcons.book, color: primary),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  if (info.hasCategories)
                    CheckboxListTile(
                      value: _categories,
                      onChanged: (v) => setState(() => _categories = v ?? true),
                      title: Text(l10n.configIncludeCategories),
                      secondary: Icon(AppIcons.category, color: primary),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  if (info.hasRecurringTransactions)
                    CheckboxListTile(
                      value: _recurringTransactions,
                      onChanged: (v) =>
                          setState(() => _recurringTransactions = v ?? true),
                      title: Text(l10n.configIncludeRecurringTransactions),
                      secondary: Icon(AppIcons.repeat, color: primary),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  if (info.hasAppSettings)
                    CheckboxListTile(
                      value: _appSettings,
                      onChanged: (v) =>
                          setState(() => _appSettings = v ?? true),
                      title: Text(l10n.configIncludeOtherSettings),
                      subtitle: Text(
                        l10n.configIncludeOtherSettingsSubtitle,
                        style: AppTextTokens.label(
                          context,
                        ).copyWith(color: AppTokens.textSecondary(context)),
                      ),
                      secondary: Icon(AppIcons.settings, color: primary),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              ),
            ),
          ),
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(AppDimens.p16),
            decoration: BoxDecoration(
              color: AppTokens.surfaceElevated(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimens.radius12),
                bottomRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: AppDimens.p12),
                FilledButton(
                  onPressed: () {
                    final options = ExportOptions(
                      ledgers: _ledgers,
                      categories: _categories,
                      recurringTransactions: _recurringTransactions,
                      appSettings: _appSettings,
                    );
                    Navigator.pop(context, options);
                  },
                  child: Text(l10n.configImportConfirmTitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
