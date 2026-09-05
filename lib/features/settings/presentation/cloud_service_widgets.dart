/// 云服务页（备份与云同步）共用展示组件。
///
/// 与 Spitout cloud_service_widgets.dart 同职责：状态头部 / 分组标题 /
/// 服务选择卡片；按本仓库注册表驱动的后端模型适配（不枚举具体后端）。
library;

import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';

/// 头部「当前类型 / 脱敏端点 / 连接状态」信息块。
///
/// 设计要点：
/// - 「测试连接」入口内联为文字链，紧贴状态徽标左侧，不用头部 icon 按钮（避免重复）。
/// - 测试结果（状态/时间/详情）全部内联展示，不弹窗。
/// - 本地后端没有可连接的远程服务，自测无意义，故不展示测试链与状态徽标。
Widget buildCloudServiceStatusHeader({
  required BuildContext context,
  required String currentName,
  required bool isLocal,
  required bool canTest,
  required String endpointSummary,
  required bool? testResult,
  required DateTime? testTime,
  required String? testMessage,
  required bool testingConnection,
  required VoidCallback onTest,
}) {
  final l10n = AppLocalizations.of(context);
  final Color statusColor;
  final String statusText;

  if (testResult == null) {
    // 未测试
    statusColor = AppTokens.warning(context);
    statusText = l10n.cloudStatusNotTested;
  } else if (testResult) {
    // 测试成功
    statusColor = AppTokens.success(context);
    statusText = l10n.cloudStatusNormal;
  } else {
    // 测试失败
    statusColor = AppTokens.error(context);
    statusText = l10n.cloudStatusFailed;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // 长类型名在窄空间下省略号截断，防止与状态徽标挤压导致横向溢出。
          Expanded(
            child: Text(
              '${l10n.commonCurrent}: $currentName',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // 本地存储没有「连接」概念，不展示状态徽标与测试链。
          if (!isLocal) ...[
            const SizedBox(width: AppDimens.p12),
            _buildTestConnectionLink(
              context: context,
              canTest: canTest,
              testingConnection: testingConnection,
              onTest: onTest,
            ),
            const SizedBox(width: AppDimens.p8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.p4),
                  Text(
                    statusText,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppDimens.p4),
      Text(
        endpointSummary,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTokens.textSecondary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // 上次测试时间：仅当存在历史测试记录（点过测试连接）时展示
      if (testTime != null) ...[
        const SizedBox(height: AppDimens.p4),
        Text(
          l10n.cloudLastTestTime(formatCloudTestTime(testTime)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      // 测试结果详情文案（成功绿 / 失败红），纯内联展示，不弹窗
      if (testMessage != null) ...[
        const SizedBox(height: AppDimens.p4),
        Text(
          testMessage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: testResult == true
                ? AppTokens.success(context)
                : AppTokens.error(context),
          ),
        ),
      ],
    ],
  );
}

/// 「测试连接」文字链：紧贴状态徽标左侧。
///
/// 仅在配置有效时可点击；测试进行中显示转圈，不弹窗。
Widget _buildTestConnectionLink({
  required BuildContext context,
  required bool canTest,
  required bool testingConnection,
  required VoidCallback onTest,
}) {
  return TextButton(
    onPressed: (canTest && !testingConnection) ? onTest : null,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: testingConnection
        ? const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            AppLocalizations.of(context).cloudTestConnection,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: canTest
                  ? Theme.of(context).colorScheme.primary
                  : AppTokens.textTertiary(context),
            ),
          ),
  );
}

/// 列表分组主标题，仅作视觉分组，无交互。
/// 左侧色条用于清晰区分不同分组（离线模式 / 备份同步）。
Widget buildCloudServiceSectionHeader(
  BuildContext context,
  String title, {
  String? subtitle,
}) {
  final Widget titleRow = Row(
    children: [
      // 左侧色条：用主题主色区分分组边界
      Container(
        width: 3,
        height: 15,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(AppDimens.radius4),
        ),
      ),
      const SizedBox(width: AppDimens.p8),
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppTokens.textPrimary(context),
        ),
      ),
    ],
  );

  // 未传入副标题时，复用单行标题布局。
  if (subtitle == null) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.p4, bottom: AppDimens.p8),
      child: titleRow,
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: AppDimens.p4, bottom: AppDimens.p8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow,
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.p4),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTokens.textSecondary(context),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 云服务选择卡片（本地 / 各第三方后端通用）。
///
/// 选中态 = 主题色 1px 边框 + 右上角勾选角标（与恢复卡片同款，遵循设计规范），
/// 「配置」按钮浮于卡片右下角，卡片高度固定保证整列等高。本仓库不设教程
/// 按钮（官方云端协同不在本页管理，教程入口整体省略）。
Widget buildCloudServiceCard({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required bool isSelected,
  bool isConfigured = true,
  bool isDisabled = false,
  required VoidCallback onTap,
  VoidCallback? onConfigure,
}) {
  return Opacity(
    opacity: isDisabled ? 0.5 : 1.0,
    child: Container(
      decoration: BoxDecoration(
        // 选中态 = 主题色 1px 边框（与恢复卡片同款）；未选中透明 1px 占位，
        // 确保固定高度下所有卡片高度完全一致。
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Stack(
        children: [
          SectionCard(
            margin: EdgeInsets.zero,
            // 将 SectionCard 默认内边距收窄为 p4。
            padding: const EdgeInsets.all(AppDimens.p4),
            // 整卡可点击选中；高度由内容撑起（标题/副标题均单行，
            // 各卡结构一致自然等高）。
            child: InkWell(
              onTap: isDisabled ? null : onTap,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p12,
                  vertical: AppDimens.p8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图标
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: AppDimens.icon16,
                      ),
                    ),
                    const SizedBox(width: AppDimens.p8),

                    // 文字信息。副标题为单行省略（兼顾固定卡片高度与长端点不横向溢出）。
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (isDisabled)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.p8,
                                    vertical: AppDimens.p4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.textTertiary(
                                      context,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radius8,
                                    ),
                                  ),
                                  child: Text(
                                    '不可用',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppTokens.textTertiary(
                                            context,
                                          ),
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTokens.textSecondary(context),
                                      ),
                                ),
                              ),
                              // 「配置」文字链内联在副标题行右侧，
                              // 与副标题垂直对齐；点按不触发卡片选中。
                              if (!isDisabled &&
                                  isConfigured &&
                                  onConfigure != null)
                                TextButton.icon(
                                  onPressed: onConfigure,
                                  icon: const Icon(
                                    AppIcons.settings,
                                    size: AppDimens.icon16,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).commonConfigure,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.p8,
                                      vertical: 0,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 右上角勾选标签：与恢复卡片同款——覆盖在边框之上。
          // 外移量 = 边框宽度 1px，顶边/右边与卡片外沿精确齐平；
          // 右上圆角（r12）圆心与卡片外角圆弧圆心重合，只露一条弧线。
          if (isSelected && !isDisabled)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppDimens.radius12),
                    bottomLeft: Radius.circular(AppDimens.radius12),
                  ),
                ),
                child: Icon(
                  AppIcons.check,
                  size: AppDimens.icon12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// 将时间格式化为固定的 YYYY-MM-DD HH:MM:SS（手动格式化，避免 locale 改变日期顺序）。
String formatCloudTestTime(DateTime dt) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${p(dt.month)}-${p(dt.day)} '
      '${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}';
}

/// 从后端配置提取脱敏端点摘要（纯函数，测试锚点）。
///
/// 按后端声明的连接字段取值（webdav/supabase 取 url，s3 取 endpoint），
/// 对嵌入 URL 的账号密码段做掩码；取不到时回退 [fallback]。
String cloudEndpointObfuscated(
  String backendId,
  Map<String, dynamic> settings,
  String fallback,
) {
  final raw = switch (backendId) {
    'webdav' || 'supabase' => settings['url'],
    's3' => settings['endpoint'],
    _ => null,
  };
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty) return fallback;
  return _obfuscateEndpoint(text);
}

/// 掩码 URL 中的 userinfo 段（scheme://user:pass@host → scheme://***@host）。
String _obfuscateEndpoint(String text) {
  final schemeIndex = text.indexOf('://');
  if (schemeIndex < 0) return text;
  final atIndex = text.indexOf('@', schemeIndex + 3);
  if (atIndex < 0) return text;
  return '${text.substring(0, schemeIndex + 3)}***'
      '${text.substring(atIndex)}';
}
