/// 云服务页（备份与云同步）。
///
/// - 头部：当前激活配置状态行 + 内联「测试连接」（结果/时间持久化到 SharedPreferences）；
/// - 离线模式分组：本地存储卡片 → 配置入口进入本机备份页（LocalBackupPage）；
/// - 备份同步分组：注册表内全部第三方后端卡片（WebDAV / S3 / Supabase），
///   选中哪张就在卡片正下方嵌入 CloudSyncSection（上传/从云端恢复/
///   自动同步开关/状态）；配置经弹窗承载；
/// - 同步中心入口用于查看并处理官方云端协同的问题。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_backend_config_dialog.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_service_widgets.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_sync_section.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';

/// 备份与云同步页。
class CloudServicePage extends ConsumerStatefulWidget {
  const CloudServicePage({super.key});

  @override
  ConsumerState<CloudServicePage> createState() => _CloudServicePageState();
}

class _CloudServicePageState extends ConsumerState<CloudServicePage> {
  bool _testingConnection = false;

  /// 各后端测试结果（bool）/ 时间 / 详情文案，内联展示不弹窗。
  final Map<String, bool> _connectionTestResults = {};
  final Map<String, DateTime> _connectionTestTimes = {};
  final Map<String, String> _connectionTestMessages = {};

  @override
  void initState() {
    super.initState();
    // 进入页面即恢复上次测试结果，避免每次进页面都回到「未测试」。
    _loadPersistedTestResults();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewAsync = ref.watch(cloudBackupOverviewProvider);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          overviewAsync.when(
            loading: () =>
                PrimaryHeader(title: l10n.mineCloudService, showBack: true),
            error: (e, _) =>
                PrimaryHeader(title: l10n.mineCloudService, showBack: true),
            data: (overview) {
              final active = overview.active;
              final isLocal = active.isLocal;
              // 本地模式展示「本地存储」，第三方模式展示激活后端名。
              final currentName = isLocal
                  ? l10n.cloudLocalStorageTitle
                  : _backendNameOf(overview, active.backendId);
              final endpointSummary = isLocal
                  ? l10n.cloudLocalStorageSubtitle
                  : cloudEndpointObfuscated(
                      active.backendId,
                      active.settings,
                      currentName,
                    );
              return PrimaryHeader(
                title: l10n.mineCloudService,
                showBack: true,
                // 头部在激活态下保持一致：配置信息行始终展示
                // （本地展示「本地存储」状态）。
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    AppDimens.p8,
                    0,
                    AppDimens.p4,
                  ),
                  child: buildCloudServiceStatusHeader(
                    context: context,
                    currentName: currentName,
                    isLocal: isLocal,
                    canTest: !isLocal && active.isValid,
                    endpointSummary: endpointSummary,
                    testResult: _connectionTestResults[active.backendId],
                    testTime: _connectionTestTimes[active.backendId],
                    testMessage: _connectionTestMessages[active.backendId],
                    testingConnection: _testingConnection,
                    onTest: () => _testConnection(active),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: overviewAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmpty(
                text: l10n.commonOperationFailed,
                icon: AppIcons.error,
              ),
              data: (overview) {
                // 单列表展示：按 离线模式 / 备份同步 分组，主标题下依次平铺
                // 该分组内的服务卡片。选中卡片正下方嵌入备份同步操作区块。
                return RefreshIndicator(
                  // 最小展示 1 秒：概览重查为瞬时操作，凑满时长让指示器完整收起。
                  onRefresh: () => ensureMinimumRefreshDuration(() async {
                    ref.invalidate(cloudBackupOverviewProvider);
                    await ref.read(cloudBackupOverviewProvider.future);
                  }),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.p16,
                      AppDimens.p16,
                      AppDimens.p16,
                      AppDimens.p16,
                    ),
                    // 内容不足一屏时也允许下拉手势触发刷新
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // ===== 离线模式 =====
                      buildCloudServiceSectionHeader(l10n.cloudTabOffline),
                      buildCloudServiceCard(
                        context: context,
                        icon: AppIcons.localStorage,
                        iconColor: AppTokens.brandLocal,
                        title: l10n.cloudLocalStorageTitle,
                        subtitle: l10n.cloudLocalStorageSubtitle,
                        isSelected: overview.active.isLocal,
                        onTap: () => _switchToLocal(),
                        // 齿轮「配置」入口：进入本机备份页
                        // （自动备份开关 / 快照列表 / 恢复流程入口）。
                        onConfigure: () =>
                            context.pushNamed(Routes.localBackup),
                      ),

                      const SizedBox(height: AppDimens.p16),
                      // 同步问题处理独立成组，入口与备份配置保持同一模块样式。
                      buildCloudServiceSectionHeader(l10n.syncCenterTitle),
                      SectionCard(
                        margin: EdgeInsets.zero,
                        child: AppListTile(
                          leading: AppIcons.cloudSync,
                          title: l10n.syncCenterTitle,
                          subtitle: l10n.syncCenterSubtitle,
                          trailing: const SizedBox.shrink(),
                          subtitleMaxLines: 2,
                          onTap: () => context.pushNamed(Routes.syncCenter),
                        ),
                      ),
                      const SizedBox(height: AppDimens.p16),
                      // ===== 备份同步 =====
                      buildCloudServiceSectionHeader(l10n.cloudTabBackup),
                      for (final backend in overview.backends) ...[
                        _buildBackendCard(context, backend),
                        if (backend.isActive) ...[
                          const SizedBox(height: AppDimens.p8),
                          // 备份同步操作区块：仅当前选中的后端卡片正下方显示。
                          const CloudSyncSection(),
                        ],
                        const SizedBox(height: AppDimens.p12),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 单个第三方后端卡片。
  Widget _buildBackendCard(
    BuildContext context,
    CloudBackupBackendDisplay backend,
  ) {
    final (icon, color) = _backendVisualOf(backend.id);
    final title = _backendTitleOf(context, backend);
    // 已配置展示脱敏端点，未配置展示引导文案。
    final subtitle = backend.hasLoadError
        ? AppLocalizations.of(context).commonOperationFailed
        : backend.isConfigured
        ? cloudEndpointObfuscated(
            backend.id,
            backend.settings,
            _backendSubtitleOf(context, backend.id),
          )
        : _backendSubtitleOf(context, backend.id);
    return buildCloudServiceCard(
      context: context,
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      isSelected: backend.isActive,
      isConfigured: backend.isConfigured,
      onTap: () => backend.isConfigured && !backend.hasLoadError
          ? _switchService(backend)
          : _configureBackend(backend),
      onConfigure: () => _configureBackend(backend),
    );
  }

  /// 切回本地存储（带二次确认）。
  Future<void> _switchToLocal() async {
    final l10n = AppLocalizations.of(context);
    final overview = ref.read(cloudBackupOverviewProvider).value;
    if (overview == null || overview.active.isLocal) return;
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.cloudSwitchConfirmTitle,
      message: l10n.cloudSwitchConfirmMessage,
    );
    if (confirmed != true || !mounted) return;
    try {
      final ok = await ref
          .read(cloudBackupActionsProvider)
          .activate(CloudBackupSelection.localBackendId);
      if (!ok) return;
      _refreshBackupProviders();
      if (mounted) {
        showToast(context, l10n.cloudSwitchedTo(l10n.cloudLocalStorageTitle));
      }
    } catch (e, st) {
      logger.error('CloudServicePage', '切回本地存储失败', e, st);
      if (mounted) {
        await AppDialog.error(
          context,
          title: l10n.cloudSwitchFailedTitle,
          message: l10n.commonOperationFailed,
        );
      }
    }
  }

  /// 切换到指定第三方后端（带二次确认）。
  Future<void> _switchService(CloudBackupBackendDisplay backend) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.cloudSwitchConfirmTitle,
      message: l10n.cloudSwitchConfirmMessage,
    );
    if (confirmed != true || !mounted) return;
    // 用户已确认，直接激活。
    await _activateBackend(backend);
  }

  /// 激活指定第三方后端（无确认；供切换确认后与「保存并切换」共用）。
  Future<void> _activateBackend(CloudBackupBackendDisplay backend) async {
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await ref
          .read(cloudBackupActionsProvider)
          .activate(backend.id);
      if (!ok) {
        if (mounted) {
          await AppDialog.error(
            context,
            title: l10n.cloudSwitchFailedTitle,
            message: l10n.cloudSwitchFailedConfigMissing,
          );
        }
        return;
      }
      _refreshBackupProviders();
      if (mounted) {
        showToast(context, l10n.cloudSwitchedTo(backend.displayName));
      }
    } catch (e, st) {
      logger.error('CloudServicePage', '切换云服务失败', e, st);
      if (mounted) {
        await AppDialog.error(
          context,
          title: l10n.cloudSwitchFailedTitle,
          message: l10n.commonOperationFailed,
        );
      }
    }
  }

  /// 打开配置弹窗：新建 / 编辑 / 清除共用一个弹窗流程。
  Future<void> _configureBackend(CloudBackupBackendDisplay backend) async {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(cloudBackupActionsProvider);
    Map<String, dynamic>? existing;
    try {
      existing = await actions.loadSettings(backend.id);
    } catch (e, st) {
      // 无法回填时先明确提示，用户仍可重新填写或清除原配置。
      logger.warning('CloudServicePage', '读取已有配置失败: ${backend.id}', st);
      if (mounted) showToast(context, l10n.commonOperationFailed);
    }
    if (!mounted) return;

    final result = await showAppSheetTop<dynamic>(
      context: context,
      child: CloudBackendConfigDialog(
        backend: backend,
        initialSettings: existing,
        canDelete: existing != null || backend.isConfigured,
      ),
    );
    if (!mounted) return;

    // 删除哨兵：用户在弹窗标题栏点击清除图标。
    if (result == cloudConfigDeleteSentinel) {
      await _deleteConfig(backend);
      return;
    }
    if (result is! Map) return;

    final settings = Map<String, dynamic>.from(result);
    // 弹窗已做必填/数字内联校验，此处再做后端完整校验兜底。
    if (!actions.isValid(backend.id, settings)) {
      showToast(context, l10n.cloudConfigInvalidMessage);
      return;
    }
    try {
      await actions.saveOnly(backend.id, settings);
      _refreshBackupProviders();
      if (!mounted) return;
      // 保存成功后统一引导用户是否立即切换（新建与编辑均弹出）。
      final wantSwitch = await _confirmSaveSwitch();
      if (wantSwitch && mounted) {
        // 用户已在引导弹窗确认，直接激活。
        await _activateBackend(backend);
      }
    } catch (e, st) {
      logger.error('CloudServicePage', '保存云服务配置失败', e, st);
      if (mounted) {
        await AppDialog.error(
          context,
          title: l10n.cloudSaveFailed,
          message: l10n.commonOperationFailed,
        );
      }
    }
  }

  /// 配置保存成功后询问是否立即切换；返回 true 表示「保存并切换」。
  Future<bool> _confirmSaveSwitch() async {
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    final result = await AppDialog.confirm(
      context,
      title: l10n.cloudFirstSaveSwitchTitle,
      message: l10n.cloudFirstSaveSwitchMessage,
      cancelLabel: l10n.cloudSaveOnlyNoSwitch,
      okLabel: l10n.cloudSaveAndSwitch,
    );
    return result == true;
  }

  /// 清除指定后端配置（回到未配置状态；云端数据不删除）。
  Future<void> _deleteConfig(CloudBackupBackendDisplay backend) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.cloudClearConfigConfirmTitle,
      message: l10n.cloudClearConfigConfirmMessage,
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(cloudBackupActionsProvider).clearConfig(backend.id);
      _refreshBackupProviders();
      if (mounted) showToast(context, l10n.cloudClearConfigDone);
    } catch (e, st) {
      logger.error('CloudServicePage', '清除云端配置失败', e, st);
      if (mounted) {
        await AppDialog.error(
          context,
          title: l10n.commonFailed,
          message: l10n.commonOperationFailed,
        );
      }
    }
  }

  /// 刷新总览与后端列表（激活/配置状态变更后统一重建）。
  void _refreshBackupProviders() {
    ref.invalidate(cloudBackupOverviewProvider);
    ref.invalidate(cloudBackupBackendsProvider);
  }

  /// 测试当前激活配置的连接性；结果内联展示并持久化。
  Future<void> _testConnection(CloudBackupSelection config) async {
    if (config.isLocal) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _testingConnection = true);
    try {
      await ref
          .read(cloudBackupActionsProvider)
          .testSavedConnection(config.backendId);
      await _setTestResult(
        config.backendId,
        true,
        l10n.cloudTestSuccessMessage,
      );
    } catch (e, st) {
      // 异常兜底：同样内联展示失败状态，不弹窗。
      logger.warning('CloudServicePage', '测试连接异常: ${config.backendId}', st);
      await _setTestResult(
        config.backendId,
        false,
        l10n.cloudTestFailedMessage,
      );
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  /// 写入「测试连接」结果到内存并持久化到 SharedPreferences。
  Future<void> _setTestResult(String id, bool success, String message) async {
    final now = DateTime.now();
    _connectionTestResults[id] = success;
    _connectionTestTimes[id] = now;
    _connectionTestMessages[id] = message;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cloud_test_result_$id', success);
      await prefs.setInt('cloud_test_time_$id', now.millisecondsSinceEpoch);
      await prefs.setString('cloud_test_message_$id', message);
    } catch (e, st) {
      logger.error('CloudServicePage', '持久化测试连接结果失败: $e', st);
    }
    if (mounted) setState(() {});
  }

  /// 进入页面时从 SharedPreferences 恢复各后端的测试结果。
  Future<void> _loadPersistedTestResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final id in ref.read(cloudBackupActionsProvider).backendIds) {
        final result = prefs.getBool('cloud_test_result_$id');
        final time = prefs.getInt('cloud_test_time_$id');
        final message = prefs.getString('cloud_test_message_$id');
        if (result != null) _connectionTestResults[id] = result;
        if (time != null) {
          _connectionTestTimes[id] = DateTime.fromMillisecondsSinceEpoch(time);
        }
        if (message != null) _connectionTestMessages[id] = message;
      }
      if (mounted) setState(() {});
    } catch (e, st) {
      logger.error('CloudServicePage', '加载测试连接历史结果失败: $e', st);
    }
  }

  /// 后端展示名：已登记的后端映射既有文案，未登记回退注册表展示名。
  String _backendTitleOf(BuildContext context, CloudBackupBackendDisplay b) {
    final l10n = AppLocalizations.of(context);
    return switch (b.id) {
      'supabase' => l10n.cloudCustomSupabaseTitle,
      'webdav' => l10n.cloudCustomWebdavTitle,
      's3' => l10n.cloudCustomS3Title,
      _ => b.displayName,
    };
  }

  /// 后端引导副文案（未配置时展示）。
  String _backendSubtitleOf(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);
    return switch (id) {
      'supabase' => l10n.cloudCustomSupabaseSubtitle,
      'webdav' => l10n.cloudCustomWebdavSubtitle,
      's3' => l10n.cloudCustomS3Subtitle,
      _ => '',
    };
  }

  /// 后端图标与品牌色。
  (IconData, Color) _backendVisualOf(String id) => switch (id) {
    'supabase' => (AppIcons.storage, AppTokens.brandSupabase),
    'webdav' => (AppIcons.folderShared, AppTokens.brandWebdav),
    's3' => (AppIcons.storage, AppTokens.brandS3),
    _ => (AppIcons.cloudQueue, AppTokens.brandCloud),
  };

  /// 后端名（按 id 在总览中查找）。
  String _backendNameOf(CloudBackupOverview overview, String backendId) {
    for (final b in overview.backends) {
      if (b.id == backendId) return b.displayName;
    }
    return backendId;
  }
}
