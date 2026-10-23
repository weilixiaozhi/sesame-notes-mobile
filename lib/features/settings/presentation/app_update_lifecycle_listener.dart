import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import '../application/app_update_controller.dart';
import '../infrastructure/app_update_service.dart';

/// 常驻应用根部，只有前台、解锁且初始化完成时才领取安装意图。
class AppUpdateLifecycleListener extends StatefulWidget {
  const AppUpdateLifecycleListener({
    super.key,
    required this.enabled,
    required this.navigatorKey,
  });
  final bool enabled;
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<AppUpdateLifecycleListener> createState() =>
      _AppUpdateLifecycleListenerState();
}

class _AppUpdateLifecycleListenerState extends State<AppUpdateLifecycleListener>
    with WidgetsBindingObserver {
  final _service = AppUpdateService();
  late final _controller = AppUpdateController(
    service: _service,
    canInstallNow: () => mounted && widget.enabled && _foreground,
  );
  Timer? _timer;
  bool _foreground = true, _busy = false;
  bool _resumePending = false;
  bool? _supported;
  String? _shownError;

  /// 前台轮询只查询本机系统任务，不发起网络下载或检查更新。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => unawaited(_tick()),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_tick()));
    }
  }

  /// 后台不打开界面，恢复前台后立即重新查询系统任务。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) unawaited(_tick(resumed: true));
  }

  /// 初始化或解锁完成后恢复此前等待的安装权限流程。
  @override
  void didUpdateWidget(AppUpdateLifecycleListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_tick(resumed: true)),
      );
    }
  }

  /// 锁屏和欢迎页退出后由下一次查询消费持久化安装意图。
  Future<void> _tick({bool resumed = false}) async {
    if (resumed) _resumePending = true;
    if (!mounted ||
        !widget.enabled ||
        !_foreground ||
        _busy ||
        defaultTargetPlatform != TargetPlatform.android ||
        kIsWeb) {
      return;
    }
    _busy = true;
    try {
      _supported ??= await _service.supported();
      if (_supported == false) _timer?.cancel();
      if (_supported != true || !mounted || !widget.enabled || !_foreground) {
        return;
      }
      if (_resumePending) {
        _resumePending = false;
        await _controller.handleAppResumed();
      }
      if (!mounted || !widget.enabled || !_foreground) return;
      await _controller.refreshDownload(allowInstall: true);
      if (mounted &&
          widget.enabled &&
          _foreground &&
          _controller.errorCode != null &&
          _shownError != _controller.errorCode) {
        _shownError = _controller.errorCode;
        final l = AppLocalizations.of(context);
        final overlay = widget.navigatorKey.currentState?.overlay;
        if (overlay != null && overlay.mounted) {
          showToastOnOverlay(
            overlay,
            _shownError == 'UPDATE_PERMISSION'
                ? l.appUpdatePermission
                : l.appUpdateFailed,
          );
        }
      }
      if (_controller.errorCode == null) _shownError = null;
    } catch (error, stack) {
      if (error is MissingPluginException) {
        _supported = false;
        _timer?.cancel();
      }
      logger.error('AppUpdateLifecycle', '恢复系统更新任务失败', error, stack);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
