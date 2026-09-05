import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sesame_notes/data/models/app_update_info.dart';
import 'package:sesame_notes/features/ledgers/presentation/cloud_service_entry_tile.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/services/app_update_service.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 展示记账设置、通用设置与检查更新等低频功能入口。
///
/// 分组结构（分组标题不展示，仅用卡片分隔）：
/// - 记账设置：分类管理 / 汇率管理 / 周期账单 / 支出颜色；
/// - 通用设置：应用语言 / 深色模式 / 通知设置 / 应用上锁 /
///   数据导入导出 / 配置导入导出 / 备份与云同步；
/// - 检查更新：单独成组，位于页面末尾。
class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  /// 构建 Mine 页面。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context), // ⭐ 使用 Token
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 个人资料区并入滚动列表，与下方分组整体滚动，不常驻置顶。
          PrimaryHeader(
            showBack: false,
            title: l10n.mineTitle,
            showTitleSection: false,
            content: const MinePageHeader(),
          ),
          // 分组之间留 12px 呼吸距；组内行间距由 cardDivider 呼吸距
          // 与 AppListTile 行内边距统一为约 16px，首末行与中间行视觉一致。
          SizedBox(height: AppDimens.p12),
          // 记账设置分组：与记账行为直接相关的低频设置，避免挤占高频入口。
          SectionCard(
            margin: EdgeInsets.fromLTRB(AppDimens.p12, 0, AppDimens.p12, 0),
            child: Column(
              children: [
                // 分类管理
                AppListTile(
                  leading: AppIcons.category,
                  title: l10n.mineCategoryManagement,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  // 按路由名跳转分类管理页，由 go_router 统一解析
                  onTap: () => context.pushNamed(Routes.categoryManage),
                ),
                AppTokens.cardDivider(context),
                // 汇率管理
                AppListTile(
                  leading: AppIcons.currencyExchange,
                  title: l10n.exchangeRatePageTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.exchangeRate),
                ),
                AppTokens.cardDivider(context),
                // 周期账单
                AppListTile(
                  leading: AppIcons.repeat,
                  title: l10n.mineRecurringTransactions,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.recurringTransaction),
                ),
                AppTokens.cardDivider(context),
                // 支出颜色（影响列表 / 搜索 / 详情等支出金额的着色）
                AppListTile(
                  leading: AppIcons.theme,
                  title: l10n.appearanceExpenseColorScheme,
                  // 圆点放进与右侧箭头同高的图标槽位，
                  // 保证圆点中心与各行右箭头中心对齐。
                  trailing: SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              ref.watch(expenseColorSchemeProvider) == 'green'
                              ? AppTokens.success(context)
                              : AppTokens.error(context),
                        ),
                      ),
                    ),
                  ),
                  onTap: () =>
                      _showExpenseColorSchemeDialog(context, ref, l10n),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.p12),
          // 通用设置分组：语言、主题、通知、应用锁、数据迁移与云同步等通用能力。
          SectionCard(
            margin: EdgeInsets.fromLTRB(AppDimens.p12, 0, AppDimens.p12, 0),
            child: Column(
              children: [
                // 应用语言
                AppListTile(
                  leading: AppIcons.language,
                  title: l10n.mineLanguageSettings,
                  onTap: () => context.pushNamed(Routes.languageSettings),
                ),
                AppTokens.cardDivider(context),
                // 深色模式
                AppListTile(
                  leading: AppIcons.themeAuto,
                  title: l10n.appearanceThemeMode,
                  onTap: () => _showThemeModeDialog(context, ref, l10n),
                ),
                AppTokens.cardDivider(context),
                // 通知设置
                AppListTile(
                  leading: AppIcons.notifications,
                  title: l10n.mineReminderSettings,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.reminderSettings),
                ),
                AppTokens.cardDivider(context),
                // 应用上锁 —— 直接进入应用锁设置页配置。
                AppListTile(
                  leading: AppIcons.lock,
                  title: l10n.appLockTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.appLockSettings),
                ),
                AppTokens.cardDivider(context),
                // 数据导入导出统一进入数据迁移页面。
                AppListTile(
                  leading: AppIcons.currencyExchange,
                  title: l10n.detailImportExportTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.detailImportExport),
                ),
                AppTokens.cardDivider(context),
                // 配置导入导出
                AppListTile(
                  leading: AppIcons.backupRestore,
                  title: l10n.configImportExportTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.configImportExport),
                ),
                AppTokens.cardDivider(context),
                // 备份与云同步 —— 统一入口：图标按备份状态切换，
                // 点击统一进入 CloudServicePage（不按后端类型路由分叉）。
                CloudServiceEntryTile(onTap: () => _openCloudService(context)),
              ],
            ),
          ),
          SizedBox(height: AppDimens.p12),
          // 检查更新分组：单独成组，放在页面最后。
          SectionCard(
            margin: EdgeInsets.fromLTRB(AppDimens.p12, 0, AppDimens.p12, 0),
            child: Column(
              children: [
                // 应用内检查更新。
                AppListTile(
                  leading: AppIcons.download,
                  title: l10n.mineCheckUpdate,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => _checkUpdate(context),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.p16),
        ],
      ),
    );
  }

  /// 检查更新：调服务对比版本，按三态弹窗引导；失败不硬报错（unknown 态）。
  Future<void> _checkUpdate(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final info = await AppUpdateService.check();
    if (!context.mounted) return;
    final content = switch (info.status) {
      UpdateStatus.hasUpdate => Text(
        l10n.updateFound(info.latestVersion ?? info.currentVersion),
      ),
      UpdateStatus.latest => Text(l10n.updateLatest),
      UpdateStatus.unknown => Text(l10n.updateUnknown),
    };
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateDialogTitle),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.updateOk),
          ),
          if (info.status != UpdateStatus.latest)
            TextButton(
              onPressed: () async {
                final url = info.releaseUrl ?? AppUpdateInfo.releasePageBase;
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(l10n.updateGoRelease),
            ),
        ],
      ),
    );
  }

  /// 打开云服务页（备份与云同步）。
  Future<void> _openCloudService(BuildContext context) async {
    await context.pushNamed(Routes.cloudService);
  }

  /// 显示主题模式选择对话框
  void _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final currentMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTokens.surfaceElevated(context),
        title: Text(
          l10n.appearanceThemeMode,
          style: TextStyle(color: AppTokens.textPrimary(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeOption(
              context,
              ref,
              title: l10n.appearanceThemeModeSystem,
              value: ThemeMode.system,
              currentValue: currentMode,
              icon: AppIcons.settingsSuggest,
            ),
            _buildModeOption(
              context,
              ref,
              title: l10n.appearanceThemeModeLight,
              value: ThemeMode.light,
              currentValue: currentMode,
              icon: AppIcons.lightMode,
            ),
            _buildModeOption(
              context,
              ref,
              title: l10n.appearanceThemeModeDark,
              value: ThemeMode.dark,
              currentValue: currentMode,
              icon: AppIcons.darkMode,
            ),
          ],
        ),
      ),
    );
  }

  /// 主题模式单选行：选中态主题色高亮，点击即写 provider 并关闭弹窗。
  Widget _buildModeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required ThemeMode value,
    required ThemeMode currentValue,
    required IconData icon,
  }) {
    final isSelected = value == currentValue;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? primaryColor : AppTokens.iconSecondary(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primaryColor : AppTokens.textPrimary(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(AppIcons.check, color: primaryColor) : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).set(value);
        Navigator.pop(context);
      },
    );
  }

  /// 显示支出颜色方案选择对话框。选项直接展示「-100」示例数字（红/绿），
  /// 让用户在切换前就能预览支出金额的着色效果。点击"保存"才写
  /// expenseColorSchemeProvider（其 listener 会落盘并同步到云端）;
  /// "取消"或弹窗外关闭则保持原值不变（本地副本自动丢弃，无需回退处理）。
  ///
  /// 保存后：颜色已在本地即时换好，关闭本弹窗后，居中展示 1s 弱化
  /// loading（无遮罩、细线条、浅颜色），结束弹 toast「已更换」。不跳转首页。
  void _showExpenseColorSchemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final pageContext = context; // 我的页 context,用于在其上展示 loading 与 toast
    // 本地副本记录对话框内当前选择,与 provider 分离;只有点"保存"才提交。
    var selected = ref.read(expenseColorSchemeProvider);
    final initialSelected = selected;
    var saving = false;
    final primaryColor = Theme.of(pageContext).colorScheme.primary;
    showDialog(
      context: pageContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppTokens.surfaceElevated(dialogCtx),
          title: Text(
            l10n.appearanceExpenseColorScheme,
            style: TextStyle(color: AppTokens.textPrimary(dialogCtx)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExpenseColorSchemeOption(
                context: dialogCtx,
                title: l10n.appearanceExpenseColorRed,
                value: 'red',
                selected: selected,
                exampleColor: AppTokens.error(dialogCtx),
                primaryColor: primaryColor,
                onTap: () {
                  // 只更新本地副本,不写 provider。
                  selected = 'red';
                  setDialogState(() {});
                },
              ),
              _buildExpenseColorSchemeOption(
                context: dialogCtx,
                title: l10n.appearanceExpenseColorGreen,
                value: 'green',
                selected: selected,
                exampleColor: AppTokens.success(dialogCtx),
                primaryColor: primaryColor,
                onTap: () {
                  selected = 'green';
                  setDialogState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      // 显示 loading,避免重复点击;落盘 + 云同步由
                      // expenseColorSchemeProvider 的 listener 在后台完成。
                      setDialogState(() => saving = true);
                      // 真正提交:有变更才落盘 + 同步云端,避免无谓写入。
                      if (selected != initialSelected) {
                        ref
                            .read(expenseColorSchemeProvider.notifier)
                            .set(selected);
                      }
                      if (!pageContext.mounted) return;
                      // 仅关闭颜色选择弹窗,停留在我的页(不跳转首页)。
                      Navigator.of(dialogCtx).pop();
                      // 弱化 loading：无遮罩，仅居中展示细线条、浅颜色的
                      // CircularProgressIndicator，1s 过渡反馈后弹 toast「已更换」。
                      final overlayEntry = OverlayEntry(
                        builder: (context) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTokens.iconTertiary(context),
                            ),
                          ),
                        ),
                      );
                      Overlay.of(pageContext).insert(overlayEntry);
                      try {
                        await Future.delayed(
                          const Duration(milliseconds: 1000),
                        );
                        if (pageContext.mounted) {
                          showToast(
                            pageContext,
                            l10n.appearanceExpenseColorApplied,
                          );
                        }
                      } finally {
                        // 页面在等待期间被退出也要移除 overlay,
                        // 避免根 Overlay 上残留全屏转圈指示器。
                        if (overlayEntry.mounted) {
                          overlayEntry.remove();
                        }
                      }
                    },
              child: saving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTokens.textOnPrimary(context),
                        ),
                      ),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }

  /// 支出颜色方案单个选项：左侧选中圆圈 + 标题 + 右侧「-100」示例数字。
  Widget _buildExpenseColorSchemeOption({
    required BuildContext context,
    required String title,
    required String value,
    required String selected,
    required Color exampleColor,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selected;
    return ListTile(
      leading: Icon(
        isSelected ? AppIcons.radioChecked : AppIcons.radioUnchecked,
        color: isSelected ? primaryColor : AppTokens.iconSecondary(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primaryColor : AppTokens.textPrimary(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      // 示例数字用方案对应颜色渲染,直观预览支出着色。
      trailing: Text(
        '-100',
        style: TextStyle(color: exampleColor, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
