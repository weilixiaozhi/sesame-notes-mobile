import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sesame_notes/data/models/app_update_info.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/services/update/app_update_service.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 展示个人设置、第三方云备份与数据维护入口。
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
                // 功能管理集中放置低频设置，避免挤占底部导航的高频入口。
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
                        subtitle: AppLocalizations.of(
                          context,
                        ).mineCategoryManagementSubtitle,
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
                        subtitle: AppLocalizations.of(
                          context,
                        ).exchangeRateEntrySubtitle,
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
                        subtitle: AppLocalizations.of(
                          context,
                        ).mineRecurringTransactionsSubtitle,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.recurringTransaction),
                      ),
                      AppTokens.cardDivider(context),
                      // 记账提醒
                      AppListTile(
                        leading: AppIcons.notifications,
                        title: AppLocalizations.of(
                          context,
                        ).mineReminderSettings,
                        subtitle: AppLocalizations.of(
                          context,
                        ).mineReminderSettingsSubtitle,
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
                        subtitle: AppLocalizations.of(
                          context,
                        ).appearanceSettingsDesc,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.appearanceSettings),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimens.p8),
                // 一级分组：第三方备份与数据维护。
                SectionCard(
                  margin: EdgeInsets.fromLTRB(
                    AppDimens.p12,
                    0,
                    AppDimens.p12,
                    0,
                  ),
                  child: Column(
                    children: [
                      _buildCloudBackupEntry(context),
                      AppTokens.cardDivider(context),
                      // 明细导入导出统一进入数据迁移页面。
                      AppListTile(
                        leading: AppIcons.currencyExchange,
                        title: AppLocalizations.of(
                          context,
                        ).detailImportExportTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        ).detailImportExportSubtitle,
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
                        subtitle: AppLocalizations.of(
                          context,
                        ).configImportExportSubtitle,
                        trailing: Icon(
                          AppIcons.chevronRight,
                          color: AppTokens.iconTertiary(context),
                          size: AppDimens.icon20,
                        ),
                        onTap: () =>
                            context.pushNamed(Routes.configImportExport),
                      ),
                      AppTokens.cardDivider(context),
                      // 应用内检查更新。
                      AppListTile(
                        leading: AppIcons.download,
                        title: AppLocalizations.of(context).mineCheckUpdate,
                        subtitle: AppLocalizations.of(
                          context,
                        ).mineCheckUpdateSubtitle,
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

  /// 第三方云备份入口：官方账号登录与退出由个人资料区域承载。
  Widget _buildCloudBackupEntry(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppListTile(
      leading: AppIcons.cloudQueue,
      title: l10n.mineCloudService,
      subtitle: l10n.cloudBackupEntrySubtitle,
      trailing: Icon(
        AppIcons.chevronRight,
        color: AppTokens.iconTertiary(context),
        size: AppDimens.icon20,
      ),
      onTap: () => _openCloudService(context),
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

  /// 打开云服务页（账户与同步 + 第三方云备份两个区块）。
  Future<void> _openCloudService(BuildContext context) async {
    await context.pushNamed(Routes.cloudService);
  }
}
