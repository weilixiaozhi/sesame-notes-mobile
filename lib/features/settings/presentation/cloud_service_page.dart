import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/shadows.dart';

/// 第三方云备份页：展示各后端的配置、激活状态与最近成功备份。
class CloudServicePage extends ConsumerStatefulWidget {
  const CloudServicePage({super.key});

  @override
  ConsumerState<CloudServicePage> createState() => _CloudServicePageState();
}

class _CloudServicePageState extends ConsumerState<CloudServicePage> {
  /// 配置页返回后重新读取状态，使新激活的后端立即显示。
  Future<void> _openBackupConfig(CloudBackupBackendDisplay backend) async {
    try {
      await context.pushNamed(Routes.cloudBackupConfig, extra: backend);
      if (mounted) {
        ref.invalidate(cloudBackupBackendsProvider);
      }
    } catch (error, stackTrace) {
      logger.error('CloudServicePage', '打开第三方备份配置失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final backends = ref.watch(cloudBackupBackendsProvider);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.mineCloudService, showBack: true),
          Expanded(
            child: backends.when(
              data: (items) {
                return ListView(
                  padding: const EdgeInsets.all(AppDimens.p12),
                  children: [
                    _sectionCard(
                      context,
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) AppTokens.cardDivider(context),
                          _backupEntry(
                            context,
                            items[i],
                            _statusSubtitle(l10n, items[i]),
                            isActive: items[i].isActive,
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
              loading: () => Center(child: Text(l10n.mineCloudServiceLoading)),
              error: (_, _) => Center(child: Text(l10n.mineSyncError)),
            ),
          ),
        ],
      ),
    );
  }

  /// 按配置与激活状态生成单个后端的用户可见状态。
  String _statusSubtitle(
    AppLocalizations l10n,
    CloudBackupBackendDisplay backend,
  ) {
    if (!backend.isActive) {
      return backend.isConfigured
          ? l10n.cloudBackupConfiguredInactive
          : l10n.cloudBackupNotConfigured;
    }
    if (backend.lastSuccessAt == null) {
      return l10n.cloudBackupActiveNoSuccess;
    }
    final time = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(backend.lastSuccessAt!.toLocal());
    return l10n.cloudBackupActiveLastSuccess(time);
  }

  /// 区块卡片容器（统一视觉）。
  Widget _sectionCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface(context),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        boxShadow: AppTokens.isDark(context) ? null : AppShadows.card,
      ),
      child: Column(children: children),
    );
  }

  /// 第三方备份入口：展示状态并打开对应后端的配置页。
  Widget _backupEntry(
    BuildContext context,
    CloudBackupBackendDisplay backend,
    String status, {
    required bool isActive,
  }) {
    return AppListTile(
      leading: _iconForBackend(backend.id),
      title: backend.displayName,
      subtitle: status,
      trailing: Icon(
        isActive ? AppIcons.check : AppIcons.chevronRight,
        color: isActive
            ? AppTokens.primary(context)
            : AppTokens.iconTertiary(context),
        size: AppDimens.icon20,
      ),
      onTap: () => _openBackupConfig(backend),
    );
  }

  /// 后端图标：未登记的新后端回退通用云图标。
  IconData _iconForBackend(String backendId) => switch (backendId) {
    'supabase' => AppIcons.storage,
    'webdav' => AppIcons.folder,
    's3' => AppIcons.storage,
    _ => AppIcons.cloudQueue,
  };
}
