import 'dart:async';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/features/settings/application/app_update_controller.dart';
import 'package:sesame_notes/features/settings/infrastructure/app_update_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';

/// 更新对话框：状态机在 [AppUpdateController]，本组件只负责订阅与渲染。
///
/// 点击更新后持续展示进度，用户可主动关闭，安装由全局前台监听器接管。
class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({super.key, this.serviceFactory});
  final AppUpdateService Function()? serviceFactory;

  /// 每次打开窗口创建独立订阅，系统下载任务在窗口之间共享。
  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog>
    with WidgetsBindingObserver {
  late final AppUpdateController _controller;

  /// 打开窗口后检查版本并恢复已有下载进度。
  @override
  void initState() {
    super.initState();
    _controller = AppUpdateController(service: widget.serviceFactory?.call());
    WidgetsBinding.instance.addObserver(this);
    _controller.check();
  }

  /// 释放页面监听，已登记的系统任务继续运行。
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// 返回应用时立即刷新下载状态。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.refreshDownload());
    }
  }

  /// 使用现有对话框和间距 token 展示更新状态及用户操作。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // 窗口关闭仅停止自身订阅，系统下载不受路由动画影响。
        if (didPop) _controller.close();
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final update = _controller.update;
          final error = switch (_controller.errorCode) {
            'UPDATE_NOT_CONFIGURED' => l10n.appUpdateNotConfigured,
            'UPDATE_UNSUPPORTED' => l10n.appUpdateUnsupported,
            'UPDATE_PERMISSION' => l10n.appUpdatePermission,
            null => null,
            _ => l10n.appUpdateFailed,
          };
          return AppContentDialog(
            title: l10n.appUpdateTitle,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.installedVersion != null) ...[
                  Text(
                    '${l10n.appUpdateCurrentVersion}: ${_controller.installedVersion}',
                  ),
                  const SizedBox(height: AppDimens.p12),
                ],
                if (update != null) ...[
                  Text(
                    '${update.version} (${update.buildNumber}) · '
                    '${(update.size / 1024 / 1024).toStringAsFixed(1)} MB',
                  ),
                  if (update.notes.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.p12),
                    Text(update.notes),
                  ],
                ],
                if (_controller.busy) ...[
                  const SizedBox(height: AppDimens.p16),
                  LinearProgressIndicator(value: _controller.progress),
                  const SizedBox(height: AppDimens.p8),
                  Text(
                    _controller.progress == null
                        ? l10n.appUpdateWorking
                        : '${l10n.appUpdateDownloading} ${(_controller.progress! * 100).floor()}%',
                  ),
                ] else if (error == null && update == null)
                  Text(l10n.appUpdateLatest),
                if (_controller.waitingForPermission)
                  Text(l10n.appUpdatePermission),
                if (_controller.downloading)
                  Text(
                    _controller.downloadState?.status == 'paused'
                        ? l10n.appUpdatePaused
                        : l10n.appUpdateBackground,
                  ),
                if (_controller.readyToInstall) Text(l10n.appUpdateReady),
                if (error != null) ...[
                  const SizedBox(height: AppDimens.p12),
                  Text(
                    error,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.appUpdateClose),
              ),
              if (_controller.downloading)
                TextButton(
                  onPressed: _controller.cancelDownload,
                  child: Text(l10n.appUpdateCancelDownload),
                ),
              if (!_controller.busy &&
                  !_controller.waitingForPermission &&
                  (update != null ||
                      (_controller.errorCode != null &&
                          _controller.errorCode != 'UPDATE_UNSUPPORTED' &&
                          _controller.errorCode != 'UPDATE_NOT_CONFIGURED')))
                AppPrimaryButton(
                  fullWidth: false,
                  label: update == null
                      ? l10n.commonRetry
                      : _controller.readyToInstall
                      ? l10n.appUpdateInstall
                      : l10n.appUpdateDownload,
                  onPressed: update == null
                      ? _controller.check
                      : _controller.startUpdate,
                ),
            ],
          );
        },
      ),
    );
  }
}
