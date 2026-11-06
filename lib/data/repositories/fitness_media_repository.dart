import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/logger_service.dart';
import 'support/fitness_media_cache.dart';

/// 官方 GIF 的同源持久缓存，文件名只由受控 URL 的摘要产生。
class FitnessMediaRepository {
  /// 缓存目录可注入，测试不读取应用真实文件。
  FitnessMediaRepository({
    required this.dio,
    Future<Directory> Function()? directory,
    AssetBundle? assetBundle,
    this.cacheLimitBytes = 256 * 1024 * 1024,
    this.requestTimeout = const Duration(seconds: 20),
    this.maxConcurrentLoads = 4,
  }) : directory = directory ?? getApplicationSupportDirectory,
       assetBundle = assetBundle ?? rootBundle {
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(requestTimeout, 'requestTimeout');
    }
    if (maxConcurrentLoads <= 0) {
      throw ArgumentError.value(maxConcurrentLoads, 'maxConcurrentLoads');
    }
  }
  final Dio dio;
  final Future<Directory> Function() directory;
  final AssetBundle assetBundle;
  final Duration requestTimeout;
  final int cacheLimitBytes;
  final int maxConcurrentLoads;
  late final _cache = FitnessMediaCache(
    directory: _cacheDirectory,
    reclaimableKeys: _reclaimableKeys,
    verifyReclaimable: _matchesBundledMedia,
    maxBytes: cacheLimitBytes,
  );
  Future<Map<String, String>>? _builtinAssets;
  final Map<String, _MediaLoad> _inFlight = {};
  final _waiting = Queue<_MediaLoad>();
  final _cancellations = <CancelToken>{};
  var _activeLoads = 0;
  var _disposed = false;
  static final _path = RegExp(
    r'^/api/v1/fitness/media/(builtin-[0-9]{4}|[0-9a-f]{64})$',
  );
  static const _maxBytes = 20 * 1024 * 1024;

  /// 应用支持目录中的媒体子目录由缓存服务统一串行管理。
  Future<Directory> _cacheDirectory() async {
    final root = await directory();
    return Directory('${root.path}${Platform.pathSeparator}fitness-media');
  }

  /// 缓存身份保留服务器边界，不同环境不能读取彼此的同名媒体。
  String _cacheKey(String path) =>
      sha256.convert(utf8.encode('${dio.options.baseUrl}|$path')).toString();

  /// 只用当前随包目录和实际资源清单证明副本可替代，不依赖在线目录或当前账号的可见训练。
  Future<Set<String>> _reclaimableKeys() async =>
      (await (_builtinAssets ??= _loadBuiltinAssets())).keys.toSet();

  /// 上传媒体和旧版本未知身份没有可靠离线替身，无法证明时一律不自动回收。
  Future<Map<String, String>> _loadBuiltinAssets() async {
    try {
      final catalog = jsonDecode(
        await assetBundle.loadString('assets/fitness/exercises.json'),
      );
      final assets = (await AssetManifest.loadFromAssetBundle(
        assetBundle,
      )).listAssets().toSet();
      if (catalog is! Map || catalog['exercises'] is! List) return {};
      final assetsByKey = <String, String>{};
      final pattern = RegExp(
        r'^assets/fitness/videos/([0-9]{4})-[A-Za-z0-9_-]+\.gif$',
      );
      for (final row in catalog['exercises'] as List) {
        if (row is! Map || row['gif_asset'] is! String) continue;
        final asset = row['gif_asset'] as String;
        final match = pattern.firstMatch(asset);
        if (match != null &&
            row['id'] == match.group(1) &&
            assets.contains(asset)) {
          assetsByKey[_cacheKey('/api/v1/fitness/media/builtin-${row['id']}')] =
              asset;
        }
      }
      return assetsByKey;
    } catch (error, stack) {
      logger.error(
        'FitnessMediaCache',
        '无法确认随包图片清单，已保留全部离线图片',
        safeErrorSummary(error),
        stack,
      );
      return {};
    }
  }

  /// 淘汰前读取真实随包资源并比对摘要，只有字节完全相同的副本才可由离线素材替代。
  Future<bool> _matchesBundledMedia(String key, File file) async {
    final asset = (await (_builtinAssets ??= _loadBuiltinAssets()))[key];
    if (asset == null) return false;
    final data = await assetBundle.load(asset);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    if (bytes.length < 6 || bytes.length > _maxBytes) return false;
    final signature = ascii.decode(bytes.sublist(0, 6), allowInvalid: true);
    if (signature != 'GIF87a' && signature != 'GIF89a') return false;
    return await sha256.bind(file.openRead()).first == sha256.convert(bytes);
  }

  /// 相同媒体共用结果，不同媒体按容量排队，完整图片字节只由有限个读取任务持有。
  Future<Uint8List?> load(String path) {
    // 无内容服务器时立即交给图片组件读取内置素材，不访问网络或缓存目录。
    if (_disposed || dio.options.baseUrl.isEmpty || !_path.hasMatch(path)) {
      return Future.value(null);
    }
    final existing = _inFlight[path];
    if (existing != null) return existing.result.future;
    final request = _MediaLoad(path);
    _inFlight[path] = request;
    _waiting.add(request);
    _drain();
    return request.result.future;
  }

  /// 网络、校验与串行落盘共用并发额度，避免已下载的大图片堆在磁盘写入队列中。
  void _drain() {
    while (!_disposed &&
        _activeLoads < maxConcurrentLoads &&
        _waiting.isNotEmpty) {
      final request = _waiting.removeFirst();
      _activeLoads++;
      unawaited(_run(request));
    }
  }

  /// 每项任务无论成功、失败或取消都归还额度；已释放的所有者不再派发后续请求。
  Future<void> _run(_MediaLoad request) async {
    try {
      final bytes = await _load(request.path);
      if (!request.result.isCompleted) {
        request.result.complete(_disposed ? null : bytes);
      }
    } catch (error, stackTrace) {
      logger.error(
        'FitnessMedia',
        '动作图片读取失败，继续使用内置素材',
        safeErrorSummary(error),
        stackTrace,
      );
      if (!request.result.isCompleted) request.result.complete(null);
    } finally {
      _inFlight.remove(request.path);
      _activeLoads--;
      _drain();
    }
  }

  /// 仅取消本仓储的媒体传输，其他业务仍可使用共享网络客户端。
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final request in _inFlight.values) {
      if (!request.result.isCompleted) request.result.complete(null);
    }
    _inFlight.clear();
    _waiting.clear();
    for (final cancellation in _cancellations.toList()) {
      try {
        cancellation.cancel('动作图片读取已结束');
      } catch (error, stackTrace) {
        logger.error(
          'FitnessMedia',
          '释放动作图片请求失败',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    }
    _cancellations.clear();
  }

  /// GIF 头、大小与上传内容摘要同时校验，缓存损坏时重新获取。
  bool _valid(Uint8List bytes, String path) {
    if (bytes.length < 6 || bytes.length > _maxBytes) return false;
    final signature = ascii.decode(bytes.sublist(0, 6), allowInvalid: true);
    if (signature != 'GIF87a' && signature != 'GIF89a') return false;
    final id = path.split('/').last;
    return id.startsWith('builtin-') || sha256.convert(bytes).toString() == id;
  }

  /// 禁止重定向和外部源；完整校验后原子写入，离线优先读取已有 GIF。
  Future<Uint8List?> _load(String path) async {
    CancelToken? cancel;
    try {
      if (_disposed) return null;
      final key = _cacheKey(path);
      final cached = await _cache.read(
        key,
        maxFileBytes: _maxBytes,
        valid: (bytes) => _valid(bytes, path),
      );
      if (_disposed) return null;
      if (cached != null) return cached;
      cancel = CancelToken();
      _cancellations.add(cancel);
      final cancellation = cancel;
      final response = await dio
          .get<List<int>>(
            path,
            cancelToken: cancellation,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status == 200,
            ),
            onReceiveProgress: (count, total) {
              if (count > _maxBytes || total > _maxBytes) {
                cancellation.cancel('动作媒体超过大小限制');
              }
            },
          )
          .timeout(
            requestTimeout,
            onTimeout: () {
              cancellation.cancel('动作媒体请求超时');
              throw TimeoutException(
                'FITNESS_MEDIA_REQUEST_TIMEOUT',
                requestTimeout,
              );
            },
          );
      if (_disposed) return null;
      final data = response.data;
      final bytes = data is Uint8List
          ? data
          : Uint8List.fromList(data ?? const []);
      if (!_valid(bytes, path)) {
        throw const FormatException('FITNESS_MEDIA_INVALID');
      }
      // 容量不足或落盘失败不丢弃已经校验的网络图片，也不删除已有唯一离线副本。
      await _cache.write(key, bytes);
      return bytes;
    } catch (error, stackTrace) {
      // 所有者主动结束属于资源回收，交由界面继续使用已有图片或内置素材。
      if (_disposed && error is DioException && CancelToken.isCancel(error)) {
        return null;
      }
      logger.error(
        'FitnessMedia',
        '官方动作图片暂不可用，继续使用内置素材',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    } finally {
      if (cancel != null) _cancellations.remove(cancel);
    }
  }
}

/// 排队项只保留受控路径与结果出口，尚未启动时不分配媒体字节或网络资源。
class _MediaLoad {
  /// 每个媒体身份在排队和执行期间共用一个结果。
  _MediaLoad(this.path);
  final String path;
  final result = Completer<Uint8List?>();
}
