import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sesame_notes/data/models/app_update_info.dart';
import 'package:sesame_notes/features/ledgers/presentation/cloud_service_entry_tile.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/services/app_update_service.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 展示记账设置、通用设置与检查更新等低频功能入口。
///
/// 分组结构（分组标题不展示，仅用卡片分隔）：
/// - 记账设置：分类管理 / 汇率管理 / 周期账单；
/// - 通用设置：通知设置 / 偏好调节 / 备份与云同步 /
///   数据导入导出 / 配置导入导出 / 应用上锁；
/// - 检查更新：单独成组，位于页面末尾。
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  /// 构建 Mine 页面。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context), // ⭐ 使用 Token
      body: Column(
        children: [
          PrimaryHeader(
            showBack: false,
            title: AppLocalizations.of(context).mineTitle,
            showTitleSection: false,
            content: const MinePageHeader(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: AppDimens.p8),
                // 记账设置分组：与记账行为直接相关的低频设置，避免挤占高频入口。
                SectionCard(
                  margin: EdgeInsets.fromLTRB(
                    AppDimens.p12,
                    0,
                    AppDimens.p12,
                    0,
                  ),
                  child: Column(
                    children: [
                      // 分类管理
                      AppListTile(
                        leading: AppIcons.category,
                        title: AppLocalizations.of(
                          context,
                        ).mineCategoryManagement,
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
                        title: AppLocalizations.of(
                          context,
                        ).exchangeRatePageTitle,
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
                        title: AppLocalizations.of(
                          context,
                        ).mineRecurringTransactions,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.recurringTransaction),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimens.p8),
                // 通用设置分组：通知、偏好、备份与云同步、数据迁移、应用锁等通用能力。
                SectionCard(
                  margin: EdgeInsets.fromLTRB(
                    AppDimens.p12,
                    0,
                    AppDimens.p12,
                    0,
                  ),
                  child: Column(
                    children: [
                      // 通知设置
                      AppListTile(
                        leading: AppIcons.notifications,
                        title: AppLocalizations.of(
                          context,
                        ).mineReminderSettings,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () => context.pushNamed(Routes.reminderSettings),
                      ),
                      AppTokens.cardDivider(context),
                      // 偏好调节
                      AppListTile(
                        leading: AppIcons.theme,
                        title: AppLocalizations.of(context).appearanceSettings,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.appearanceSettings),
                      ),
                      AppTokens.cardDivider(context),
                      // 备份与云同步 —— 统一入口：图标按备份状态切换，
                      // 点击统一进入 CloudServicePage（不按后端类型路由分叉）。
                      CloudServiceEntryTile(
                        onTap: () => _openCloudService(context),
                      ),
                      AppTokens.cardDivider(context),
                      // 数据导入导出统一进入数据迁移页面。
                      AppListTile(
                        leading: AppIcons.currencyExchange,
                        title: AppLocalizations.of(
                          context,
                        ).detailImportExportTitle,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.detailImportExport),
                      ),
                      AppTokens.cardDivider(context),
                      // 配置导入导出
                      AppListTile(
                        leading: AppIcons.backupRestore,
                        title: AppLocalizations.of(
                          context,
                        ).configImportExportTitle,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.configImportExport),
                      ),
                      AppTokens.cardDivider(context),
                      // 应用上锁 —— 直接进入应用锁设置页配置。
                      AppListTile(
                        leading: AppIcons.lock,
                        title: AppLocalizations.of(context).appLockTitle,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () => context.pushNamed(Routes.appLockSettings),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimens.p8),
                // 检查更新分组：单独成组，放在页面最后。
                SectionCard(
                  margin: EdgeInsets.fromLTRB(
                    AppDimens.p12,
                    0,
                    AppDimens.p12,
                    0,
                  ),
                  child: Column(
                    children: [
                      // 应用内检查更新。
                      AppListTile(
                        leading: AppIcons.download,
                        title: AppLocalizations.of(context).mineCheckUpdate,
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
          ),
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
}
