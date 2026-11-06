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
  bool _refreshPending = false;
  int _readFailures = 0;
  bool? _supported;
  String? _shownError;

  /// 启动时恢复一次系统任务，后续由任务变更和前台生命周期唤醒。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      AppUpdateService.downloadChanges.addListener(_downloadsChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_tick()));
    }
  }

  /// 只有前台、可操作且平台支持时才查询持久系统任务。
  bool get _canObserve =>
      mounted &&
      widget.enabled &&
      _foreground &&
      _supported != false &&
      defaultTargetPlatform == TargetPlatform.android &&
      !kIsWeb;

  /// 入队或取消任务后立即核对状态；在途查询结束时补读，避免遗漏新任务。
  void _downloadsChanged() {
    _readFailures = 0;
    _refreshPending = true;
    unawaited(_tick());
  }

  /// 活跃下载才需要周期检查，空闲、完成、锁屏和后台均释放定时器。
  void _syncPolling() {
    _timer?.cancel();
    _timer = null;
    if (!_canObserve) return;
    // 查询失败代表状态未知，最多补查三次；明确空闲时不保留周期工作。
    if (_readFailures > 3 || (_readFailures == 0 && !_controller.downloading)) {
      return;
    }
    final delay = _readFailures == 0
        ? const Duration(seconds: 3)
        : Duration(seconds: 3 * (1 << (_readFailures - 1)));
    _timer = Timer(delay, () => unawaited(_tick()));
  }

  /// 后台不打开界面，恢复前台后立即重新查询系统任务。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(_tick(resumed: true));
    } else {
      _syncPolling();
    }
  }

  /// 初始化或解锁完成后恢复此前等待的安装权限流程。
  @override
  void didUpdateWidget(AppUpdateLifecycleListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _syncPolling();
    if (!oldWidget.enabled && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_tick(resumed: true)),
      );
    }
  }

  /// 锁屏和欢迎页退出后由下一次查询消费持久化安装意图。
  Future<void> _tick({bool resumed = false}) async {
    if (resumed) {
      _readFailures = 0;
      _resumePending = true;
      _refreshPending = true;
    }
    if (!_canObserve || _busy) return;
    _timer?.cancel();
    _timer = null;
    _busy = true;
    try {
      do {
        _refreshPending = false;
        _supported ??= await _service.supported();
        if (_supported != true || !_canObserve) return;
        if (_resumePending) {
          _resumePending = false;
          await _controller.handleAppResumed();
        }
        if (!_canObserve) return;
        final readSucceeded = await _controller.refreshDownload(
          allowInstall: true,
        );
        _readFailures = readSucceeded ? 0 : _readFailures + 1;
        if (mounted &&
            _canObserve &&
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
      } while (_refreshPending && _canObserve);
    } catch (error, stack) {
      _readFailures++;
      if (error is MissingPluginException) {
        _supported = false;
        _timer?.cancel();
      }
      logger.error('AppUpdateLifecycle', '恢复系统更新任务失败', error, stack);
    } finally {
      _busy = false;
      _syncPolling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    AppUpdateService.downloadChanges.removeListener(_downloadsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
