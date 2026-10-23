import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import '../infrastructure/app_update_service.dart';

/// 界面订阅系统任务状态，关闭只释放订阅，显式取消才撤销下载。
class AppUpdateController extends ChangeNotifier {
  /// 全局监听器提供实时门控，异步查询完成后仍需满足前台和解锁条件。
  AppUpdateController({AppUpdateService? service, this._canInstallNow})
    : _service = service ?? AppUpdateService();
  final AppUpdateService _service;
  final bool Function()? _canInstallNow;
  CancelToken _cancel = CancelToken();
  Timer? _poll;
  AppUpdate? _update;
  UpdateDownload? _download;
  bool _working = false, _refreshing = false, _closed = false;
  bool _waitingForPermission = false;
  String? _errorCode;

  String? get installedVersion => _service.installedVersion;
  AppUpdate? get update => _update;
  UpdateDownload? get downloadState => _download;
  bool get downloading => _download?.active ?? false;
  bool get readyToInstall => _download?.ready ?? false;
  bool get busy => _working || downloading;
  bool get waitingForPermission => _waitingForPermission;
  double? get progress => downloading ? _download?.progress : null;
  String? get errorCode => _errorCode;

  /// 每次读取当前门控，避免使用异步操作开始时保存的前台状态。
  bool get _installAllowed => !_closed && (_canInstallNow?.call() ?? true);

  /// 关闭元数据请求和进度订阅，独立的系统下载继续运行。
  void close() {
    if (_closed) return;
    _closed = true;
    _poll?.cancel();
    _cancel.cancel();
    _service.dispose();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  /// 检查更新时恢复已有任务，进度仅在用户打开检查窗口时展示。
  Future<void> check() async {
    if (_working || _closed) return;
    _set(() {
      _working = true;
      _errorCode = null;
    });
    _cancel = CancelToken();
    try {
      final update = await _service.check(_cancel);
      if (_closed) return;
      _set(() => _update = update);
      await refreshDownload();
      _watchDownload();
    } catch (error, stack) {
      _report(error, stack);
    } finally {
      _set(() => _working = false);
    }
  }

  /// 更新按钮登记系统任务并保留窗口，已完成的任务重新登记一次安装意图。
  Future<void> startUpdate() async {
    final update = _update;
    if (_closed || busy || update == null) return;
    _set(() {
      _working = true;
      _errorCode = null;
    });
    try {
      final task = await _service.startDownload(update);
      // 入队期间用户关闭窗口时，系统仍持有下载任务，页面只丢弃晚到的结果。
      if (_closed) return;
      _set(() {
        _download = task;
        _update = task.update;
        if (task.status == 'failed') _errorCode = 'UPDATE_DOWNLOAD_FAILED';
      });
      _watchDownload();
    } catch (error, stack) {
      _report(error, stack);
    } finally {
      _set(() => _working = false);
    }
  }

  /// 窗口展示系统下载进度，自动安装统一由应用根部监听器领取，避免重复弹出。
  void _watchDownload() {
    _poll?.cancel();
    if (_closed || !downloading) return;
    _poll = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(refreshDownload()),
    );
  }

  /// 前台全局监听器可领取一次安装意图，普通进度窗口不会自动安装。
  Future<void> refreshDownload({bool allowInstall = false}) async {
    if (_closed || _refreshing) return;
    _refreshing = true;
    try {
      final task = await _service.currentDownload();
      if (_closed) return;
      if (task == null) {
        _set(() => _download = null);
      } else if (allowInstall ||
          _update == null ||
          _update!.sha256Digest == task.update.sha256Digest) {
        _set(() {
          _download = task;
          _update = task.update;
          if (task.status == 'failed') _errorCode = 'UPDATE_DOWNLOAD_FAILED';
          if (task.status != 'failed' &&
              _errorCode == 'UPDATE_DOWNLOAD_FAILED') {
            _errorCode = null;
          }
        });
      }
      if (!downloading) _poll?.cancel();
      if (allowInstall &&
          task != null &&
          task.ready &&
          task.installPending &&
          !_waitingForPermission &&
          !_working &&
          _installAllowed) {
        if (!await _service.consumeInstall(task)) return;
        // 领取任务本身也跨平台异步执行；门控关闭时把意图交还原生持久任务。
        if (!_installAllowed) {
          await _deferInstall(task);
          return;
        }
        await install();
      }
    } catch (error, stack) {
      _report(error, stack);
    } finally {
      _refreshing = false;
    }
  }

  /// 用户明确取消时移除系统任务，保留版本信息供再次下载。
  Future<void> cancelDownload() async {
    if (_closed || _working) return;
    _set(() => _working = true);
    try {
      await _service.cancelDownload();
      _poll?.cancel();
      _set(() {
        _download = null;
        _errorCode = null;
      });
    } catch (error, stack) {
      _report(error, stack);
    } finally {
      _set(() => _working = false);
    }
  }

  /// 用户从安装授权设置返回时继续一次安装，拒绝授权不会循环打开设置。
  Future<void> handleAppResumed() async {
    if (!_installAllowed || !_waitingForPermission) return;
    _waitingForPermission = false;
    await install(afterSettings: true);
  }

  /// 只有完整包才进入安装权限与系统确认流程，原生层再次复核文件身份。
  Future<void> install({bool afterSettings = false}) async {
    if (!_installAllowed || _working || !readyToInstall || _update == null) {
      return;
    }
    final task = _download!;
    _set(() {
      _working = true;
      _errorCode = null;
    });
    try {
      final allowed = await _service.canInstall();
      // 权限查询返回前可能退到后台或进入锁屏，授权设置和安装器均须延期。
      if (!_installAllowed) {
        await _deferInstall(task);
        return;
      }
      if (!allowed) {
        if (afterSettings) {
          _set(() => _errorCode = 'UPDATE_PERMISSION');
        } else {
          _set(() => _waitingForPermission = true);
          await _service.openInstallSettings();
        }
        return;
      }
      await _service.install(task.update);
    } catch (error, stack) {
      _waitingForPermission = false;
      _report(error, stack);
    } finally {
      _set(() => _working = false);
    }
  }

  /// 窗口关闭、退后台或锁屏时归还同一任务的安装意图，恢复后再领取。
  Future<void> _deferInstall(UpdateDownload task) async {
    await _service.restoreInstallIntent(task);
    _set(() {
      _waitingForPermission = false;
      _errorCode = null;
    });
  }

  /// 记录完整错误上下文，界面只接收可本地化的错误码。
  void _report(Object error, StackTrace stack) {
    if (error is PlatformException && error.code == 'UPDATE_WAIT_FOREGROUND') {
      logger.info('AppUpdate', '安装任务等待应用恢复前台');
      _set(() => _errorCode = null);
      return;
    }
    logger.error('AppUpdate', '更新任务操作失败', error, stack);
    _set(
      () => _errorCode = error is PlatformException
          ? error.code
          : 'UPDATE_FAILED',
    );
  }

  /// 已销毁的窗口不再接收晚到结果。
  void _set(VoidCallback change) {
    if (!_closed) {
      change();
      notifyListeners();
    }
  }
}
