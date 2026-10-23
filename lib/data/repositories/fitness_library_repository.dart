import 'dart:convert';

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
  static const _cacheKey = 'fitness_library_cache_v1';
  static const _etagKey = 'fitness_library_etag_v1';

  /// 单次在线刷新的最长等待：连接或解析悬挂时放弃本次刷新并保留本地内容。
  static const _requestTimeout = Duration(seconds: 8);

  final Dio dio;
  final SharedPreferences preferences;
  final AssetBundle assetBundle;

  FitnessLibraryRepository({
    required this.dio,
    required this.preferences,
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  /// 本地快照：缓存优先（内容只由服务端写入），其次内置资源；不发起网络请求。
  Future<FitnessLibrary> loadLocal() async {
    final cached = _loadCached();
    if (cached != null) return cached;
    return _loadBuiltin();
  }

  /// 在线刷新当前 v1 内容：内容变化并写入缓存时返回 true，未变化或刷新失败返回 false。
  Future<bool> refresh() async {
    try {
      // 公共内容可匿名更新；缺少服务器配置时直接保留缓存或内置内容。
      if (dio.options.baseUrl.isEmpty) return false;
      final cached = _loadCached();
      final etag = cached == null ? null : preferences.getString(_etagKey);
      var response = await dio
          .get<Object?>(
            '/api/v1/fitness/library',
            options: Options(
              headers: {'if-none-match': ?etag},
              validateStatus: (status) => status == 200 || status == 304,
            ),
          )
          .timeout(_requestTimeout);
      // 本地已有可用内容时，304 直接沿用缓存，不需要正文。
      if (response.statusCode == 304 && cached != null) return false;
      if (response.statusCode == 304) {
        response = await dio
            .get<Object?>(
              '/api/v1/fitness/library',
              options: Options(validateStatus: (status) => status == 200),
            )
            .timeout(_requestTimeout);
      }
      final json = response.data;
      if (json is! Map) throw const FormatException('FITNESS_LIBRARY_RESPONSE');
      final content = Map<String, dynamic>.from(json);
      // 先解析校验，再落缓存：结构不符的内容不会污染本地快照。
      FitnessLibrary.fromJson(content);
      final changed = preferences.getString(_cacheKey) != jsonEncode(content);
      final saved = await _saveCache(content, response.headers.value('etag'));
      // 内容变化但写入失败时不通知上层重建，避免反复刷新同一份内容。
      return changed && saved;
    } catch (error, stackTrace) {
      logger.warning(
        'FitnessLibrary',
        '在线训练内容刷新失败，继续使用本地内容：$error\n$stackTrace',
      );
      return false;
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
    final content = preferences.getString(_cacheKey);
    if (content == null) return null;
    try {
      final json = jsonDecode(content);
      if (json is! Map) throw const FormatException('FITNESS_LIBRARY_CACHE');
      return FitnessLibrary.fromJson(Map<String, dynamic>.from(json));
    } catch (error, stackTrace) {
      logger.warning('FitnessLibrary', '训练内容缓存无效，将使用内置快照：$error\n$stackTrace');
      return null;
    }
  }

  /// 正文写入成功后更新或清除对应 ETag，返回正文是否保存成功。
  Future<bool> _saveCache(Map<String, dynamic> json, String? etag) async {
    var saved = false;
    try {
      saved = await preferences.setString(_cacheKey, jsonEncode(json));
      if (!saved) throw StateError('FITNESS_LIBRARY_CACHE_WRITE');
      if (etag != null) {
        final etagSaved = await preferences.setString(_etagKey, etag);
        if (!etagSaved) throw StateError('FITNESS_LIBRARY_ETAG_WRITE');
      } else {
        final removed = await preferences.remove(_etagKey);
        if (!removed) throw StateError('FITNESS_LIBRARY_ETAG_REMOVE');
      }
    } catch (error, stackTrace) {
      logger.warning('FitnessLibrary', '训练内容缓存保存失败：$error\n$stackTrace');
    }
    return saved;
  }
}
