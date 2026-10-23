import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';

/// 发布元数据同时约束下载内容和目标应用，安装由原生层再次校验。
class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.buildNumber,
    required this.url,
    required this.size,
    required this.sha256Digest,
    required this.notes,
  });

  /// 校验服务器和本机持久任务中的同一份发布协议。
  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    final build = json['buildNumber'];
    final url = Uri.tryParse(
      json['url'] is String ? json['url'] as String : '',
    );
    final size = json['size'];
    final digest = json['sha256'];
    final notes = json['notes'];
    if (version is! String ||
        !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version) ||
        build is! int ||
        build <= 0 ||
        url == null ||
        url.scheme != 'https' ||
        url.host.isEmpty ||
        url.userInfo.isNotEmpty ||
        size is! int ||
        size <= 0 ||
        digest is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(digest) ||
        json['packageName'] != 'com.sesame.notes' ||
        json['abi'] != 'arm64-v8a' ||
        notes is! String) {
      throw const FormatException('Invalid update manifest');
    }
    return AppUpdate(
      version: version,
      buildNumber: build,
      url: url,
      size: size,
      sha256Digest: digest.toLowerCase(),
      notes: notes,
    );
  }

  final String version;
  final int buildNumber;
  final Uri url;
  final int size;
  final String sha256Digest;
  final String notes;

  /// 构建号决定能否覆盖安装，同版本重构建仍可发布。
  bool isNewerThan(int installedBuild) => buildNumber > installedBuild;

  /// 原生系统任务持久保存公开元数据，不携带业务凭据。
  Map<String, Object> toJson() => {
    'version': version,
    'buildNumber': buildNumber,
    'url': url.toString(),
    'size': size,
    'sha256': sha256Digest,
    'notes': notes,
    'packageName': 'com.sesame.notes',
    'abi': 'arm64-v8a',
  };
}

/// 系统任务快照独立于任何页面，重新打开应用可恢复同一编号。
class UpdateDownload {
  const UpdateDownload({
    required this.id,
    required this.status,
    required this.received,
    required this.update,
    this.installPending = false,
    this.reason,
  });
  final int id;
  final String status;
  final int received;
  final AppUpdate update;
  final bool installPending;
  final String? reason;

  /// 平台通道输入必须具备合法任务状态和发布元数据。
  factory UpdateDownload.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final id = json['id'];
    final received = json['received'];
    if (id is! int ||
        received is! int ||
        received < 0 ||
        !{'pending', 'running', 'paused', 'ready', 'failed'}.contains(status) ||
        json['manifest'] is! Map) {
      throw const FormatException('Invalid download state');
    }
    return UpdateDownload(
      id: id,
      status: status as String,
      received: received,
      update: AppUpdate.fromJson(
        Map<String, dynamic>.from(json['manifest'] as Map),
      ),
      installPending: json['installPending'] == true,
      reason: json['reason'] as String?,
    );
  }

  /// 系统等待网络、排队和实际传输均属于可继续的后台任务。
  bool get active =>
      status == 'pending' || status == 'running' || status == 'paused';
  bool get ready => status == 'ready';
  double get progress => (received / update.size).clamp(0, 1);
}

/// HTTP 客户端仅检查公开元数据，APK 下载与文件校验由 Android 系统任务承担。
class AppUpdateService {
  AppUpdateService({Dio? dio, this.source = manifestUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
  static const manifestUrl = AppEnvironment.updateManifestUrl;
  static const _channel = MethodChannel('com.sesame_notes.update');
  final Dio _dio;
  final String source;
  String? installedVersion;
  bool _disposed = false;

  /// 只在原生支持的正式包中运行安装流程。
  Future<bool> supported() async =>
      await _channel.invokeMethod<bool>('isSupported') ?? false;

  /// 活跃或已就绪任务优先恢复，网络检查失败也保留已有可重试任务。
  Future<AppUpdate?> check(CancelToken cancelToken) async {
    final info = await PackageInfo.fromPlatform();
    installedVersion = '${info.version} (${info.buildNumber})';
    final uri = Uri.tryParse(source);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw PlatformException(code: 'UPDATE_NOT_CONFIGURED');
    }
    if (info.packageName != 'com.sesame.notes' || !await supported()) {
      throw PlatformException(code: 'UPDATE_UNSUPPORTED');
    }
    final installed = int.parse(info.buildNumber);
    var saved = await currentDownload();
    if (saved != null && !saved.update.isNewerThan(installed)) {
      await cancelDownload();
      saved = null;
    }
    if (saved != null && (saved.active || saved.ready)) return saved.update;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        uri.toString(),
        cancelToken: cancelToken,
        options: Options(headers: {'Cache-Control': 'no-cache'}),
      );
      final update = AppUpdate.fromJson(response.data ?? {});
      return update.isNewerThan(installed) ? update : null;
    } on DioException {
      if (!cancelToken.isCancelled && saved != null) return saved.update;
      rethrow;
    }
  }

  /// 系统任务编号由原生层持久保存，重复点击复用同一包的现有任务。
  Future<UpdateDownload> startDownload(AppUpdate update) async =>
      UpdateDownload.fromJson(
        (await _channel.invokeMapMethod<String, dynamic>(
          'enqueueDownload',
          update.toJson(),
        ))!,
      );

  /// 读取系统进度；ready 表示原生层已经校验完整安装包。
  Future<UpdateDownload?> currentDownload() async {
    final value = await _channel.invokeMapMethod<String, dynamic>(
      'downloadStatus',
    );
    return value == null ? null : UpdateDownload.fromJson(value);
  }

  /// 用户明确取消时才撤销后台任务。
  Future<void> cancelDownload() =>
      _channel.invokeMethod<void>('cancelDownload');

  /// 前台监听器以系统任务编号领取一次安装意图。
  Future<bool> consumeInstall(UpdateDownload task) async =>
      await _channel.invokeMethod<bool>('consumeInstall', {'id': task.id}) ??
      false;

  /// 门控关闭时归还同一编号的安装意图，已取消或已替换的任务不会被恢复。
  Future<void> restoreInstallIntent(UpdateDownload task) =>
      _channel.invokeMethod<void>('restoreInstallIntent', {'id': task.id});

  /// 安装权限由 Android 决定。
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;
  Future<void> openInstallSettings() =>
      _channel.invokeMethod<void>('openInstallSettings');

  /// 原生层复核任务、摘要、包名、版本和签名后才打开系统安装确认。
  Future<void> install(AppUpdate update) async {
    if (_disposed) return;
    await _channel.invokeMethod<void>('install', {
      'buildNumber': update.buildNumber,
      'sha256': update.sha256Digest,
    });
  }

  /// 释放元数据连接不影响独立的系统下载任务。
  void dispose() {
    _disposed = true;
    _dio.close(force: true);
  }
}
