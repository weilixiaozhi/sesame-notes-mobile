import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fitness_library.dart';

/// 官方训练内容库的本地快照读取与在线刷新。
///
/// 页面先读本地快照立即渲染，在线内容由后台刷新补齐，网络耗时不再阻塞首屏。
class FitnessLibraryRepository {
  static const _assetPath = 'assets/fitness/library.json';

  /// 每次在线请求的最长等待，超时同时停止传输并保留本地内容。
  static const _requestTimeout = Duration(seconds: 8);

  final Dio dio;
  final SharedPreferences preferences;
  final AssetBundle assetBundle;
  final String _baseUrl;
  final bool Function() _isCurrent;
  Future<bool>? _refreshInFlight;

  /// 固定来源地址与生命周期检查，旧来源的迟到响应不能提交到新来源缓存。
  FitnessLibraryRepository({
    required this.dio,
    required this.preferences,
    AssetBundle? assetBundle,
    bool Function()? isCurrent,
  }) : assetBundle = assetBundle ?? rootBundle,
       _baseUrl = dio.options.baseUrl,
       _isCurrent = isCurrent ?? _alwaysCurrent;

  /// 独立仓储默认由调用方管理生命周期，应用装配会注入Provider所属代次。
  static bool _alwaysCurrent() => true;

  /// 正文和ETag使用同一来源摘要，未知来源的旧全局缓存保持原样且不自动迁入。
  String get _cacheKey =>
      'fitness_library_cache_v1_${sha256.convert(utf8.encode(_baseUrl))}';

  /// 验证令牌只对创建它的服务来源和正文有效。
  String get _etagKey =>
      'fitness_library_etag_v1_${sha256.convert(utf8.encode(_baseUrl))}';

  /// 同时确认拥有者与HTTP配置，外部复用Dio并修改地址时也不能串写来源。
  bool get _current => _isCurrent() && dio.options.baseUrl == _baseUrl;

  /// 本地快照：缓存优先（内容只由服务端写入），其次内置资源；不发起网络请求。
  Future<FitnessLibrary> loadLocal() async {
    final cached = _loadCached();
    if (cached != null) return cached;
    return _loadBuiltin();
  }

  /// 在线刷新当前 v1 内容：内容变化并写入缓存时返回 true，未变化或刷新失败返回 false。
  Future<bool> refresh() {
    return _refreshInFlight ??= _refresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  /// 同一仓储的并发刷新共享请求，页面查询和后台更新不会互相覆盖缓存。
  Future<bool> _refresh() async {
    try {
      // 公共内容可匿名更新；缺少服务器配置时直接保留缓存或内置内容。
      if (_baseUrl.isEmpty || !_current) return false;
      final cached = _loadCached();
      final etag = cached == null ? null : preferences.getString(_etagKey);
      var response = await _request(etag: etag);
      if (!_current) return false;
      // 本地已有可用内容时，304 直接沿用缓存，不需要正文。
      if (response.statusCode == 304 && cached != null) return false;
      if (response.statusCode == 304) {
        response = await _request(allowNotModified: false);
        if (!_current) return false;
      }
      final json = response.data;
      if (json is! Map) throw const FormatException('FITNESS_LIBRARY_RESPONSE');
      final content = Map<String, dynamic>.from(json);
      // 先解析校验，再落缓存：结构不符的内容不会污染本地快照。
      FitnessLibrary.fromJson(content);
      final changed = preferences.getString(_cacheKey) != jsonEncode(content);
      final saved = await _saveCache(content, response.headers.value('etag'));
      // 内容变化但写入失败时不通知上层重建，避免反复刷新同一份内容。
      return _current && changed && saved;
    } catch (error, stackTrace) {
      logger.error(
        'FitnessLibrary',
        '在线训练内容刷新失败，继续使用本地内容',
        safeErrorSummary(error),
        stackTrace,
      );
      return false;
    }
  }

  /// 条件读取和无缓存重取共用取消边界，局部超时不能遗留传输后再接受新一轮刷新。
  Future<Response<Object?>> _request({
    String? etag,
    bool allowNotModified = true,
  }) async {
    final cancel = CancelToken();
    try {
      return await dio
          .get<Object?>(
            '/api/v1/fitness/library',
            cancelToken: cancel,
            options: Options(
              headers: {'if-none-match': ?etag},
              validateStatus: (status) =>
                  status == 200 || (allowNotModified && status == 304),
            ),
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              cancel.cancel('训练内容请求超时');
              throw TimeoutException(
                'FITNESS_LIBRARY_REQUEST_TIMEOUT',
                _requestTimeout,
              );
            },
          );
    } catch (error, stack) {
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// 内置快照是离线可用性的最后防线，损坏时记录完整诊断并停止继续使用。
  Future<FitnessLibrary> _loadBuiltin() async {
    try {
      final content = await assetBundle.loadString(_assetPath);
      final json = jsonDecode(content);
      if (json is! Map) throw const FormatException('FITNESS_LIBRARY_ASSET');
      return FitnessLibrary.fromJson(Map<String, dynamic>.from(json));
    } catch (error, stackTrace) {
      logger.error('FitnessLibrary', '内置训练内容读取失败', error, stackTrace);
      throw StateError('FITNESS_LIBRARY_BUILTIN_INVALID');
    }
  }

  /// 缓存损坏只影响在线更新结果，不阻断内置快照。
  FitnessLibrary? _loadCached() {
    try {
      final content = preferences.getString(_cacheKey);
      if (content == null) return null;
      final json = jsonDecode(content);
      if (json is! Map) throw const FormatException('FITNESS_LIBRARY_CACHE');
      return FitnessLibrary.fromJson(Map<String, dynamic>.from(json));
    } catch (error, stackTrace) {
      logger.error(
        'FitnessLibrary',
        '训练内容缓存无效，将使用内置快照',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    }
  }

  /// 正文写入成功后更新或清除对应 ETag，返回正文是否保存成功。
  Future<bool> _saveCache(Map<String, dynamic> json, String? etag) async {
    var saved = false;
    try {
      if (!_current) return false;
      saved = await preferences.setString(_cacheKey, jsonEncode(json));
      if (!saved) throw StateError('FITNESS_LIBRARY_CACHE_WRITE');
      if (!_current) return false;
      if (etag != null) {
        final etagSaved = await preferences.setString(_etagKey, etag);
        if (!etagSaved) throw StateError('FITNESS_LIBRARY_ETAG_WRITE');
      } else {
        final removed = await preferences.remove(_etagKey);
        if (!removed) throw StateError('FITNESS_LIBRARY_ETAG_REMOVE');
      }
    } catch (error, stackTrace) {
      logger.error(
        'FitnessLibrary',
        '训练内容缓存保存失败，继续使用已有内容',
        safeErrorSummary(error),
        stackTrace,
      );
    }
    return saved;
  }
}
