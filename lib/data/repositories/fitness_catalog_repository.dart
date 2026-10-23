import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/logger_service.dart';
import '../models/fitness_catalog.dart';
import '../models/fitness_catalog_snapshot.dart';
import '../models/fitness_official_reference.dart';

/// 官方动作目录的环境隔离缓存；后台更新可覆盖资料，下架动作仍保留历史引用。
class FitnessCatalogRepository {
  /// 沿用统一 API 传输与资源包，可在测试中替换两者。
  FitnessCatalogRepository({
    required this.dio,
    required this.preferences,
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;
  final Dio dio;
  final SharedPreferences preferences;
  final AssetBundle bundle;

  /// 不同测试、生产地址分别缓存，避免本地切换环境串用官方目录。
  String get _cacheKey =>
      'fitness_catalog_v1_${sha256.convert(utf8.encode(dio.options.baseUrl))}';

  /// 校验完整目录与唯一引用，损坏的远端响应不能替换离线快照。
  FitnessCatalogSnapshot _parse(Object? content) {
    if (content is! Map || content['exercises'] is! List) {
      throw const FormatException('FITNESS_CATALOG_RESPONSE');
    }
    final seen = <String>{};
    final rows = (content['exercises'] as List)
        .map((row) {
          final definition = FitnessExerciseDefinition.fromJson(
            Map<String, dynamic>.from(row as Map),
          );
          if (!fitnessOfficialReference(definition.id) ||
              !seen.add(definition.id)) {
            throw const FormatException('FITNESS_CATALOG_ID');
          }
          return definition;
        })
        .toList(growable: false);
    return FitnessCatalogSnapshot(
      exercises: rows,
      taxonomies: content.containsKey('taxonomies')
          ? FitnessTaxonomies.fromJson(content['taxonomies'])
          : null,
    );
  }

  /// 缓存不可读时退回随包目录，不阻断动作库或历史训练页面。
  Future<List<FitnessExerciseDefinition>> loadLocal() async {
    return (await loadSnapshot()).exercises;
  }

  /// 动作与动态分类一起读取，旧缓存缺少分类时保留内置分类回退语义。
  Future<FitnessCatalogSnapshot> loadSnapshot() async {
    try {
      final cached = preferences.getString(_cacheKey);
      if (cached != null) return _parse(jsonDecode(cached));
    } catch (error, stackTrace) {
      logger.error('FitnessCatalog', '动作目录缓存不可用，使用内置内容', error, stackTrace);
    }
    try {
      return _parse(
        jsonDecode(await bundle.loadString('assets/fitness/exercises.json')),
      );
    } catch (error, stackTrace) {
      logger.error('FitnessCatalog', '内置动作目录读取失败', error, stackTrace);
      throw StateError('动作资料暂时无法读取，请稍后重试');
    }
  }

  /// 条件请求减少目录流量，先校验再持久化，内容变化才通知上层更新。
  Future<bool> refresh() async {
    try {
      // 未配置内容服务器时，内置目录就是可用来源，不创建失败请求。
      if (dio.options.baseUrl.isEmpty) return false;
      final cached = preferences.getString(_cacheKey);
      String? etag;
      if (cached != null) {
        try {
          _parse(jsonDecode(cached));
          etag = preferences.getString('${_cacheKey}_etag');
        } catch (_) {
          /* 损坏缓存必须获取完整正文。 */
        }
      }
      final response = await dio
          .get<Object?>(
            '/api/v1/fitness/catalog',
            options: Options(
              headers: {'if-none-match': ?etag},
              validateStatus: (status) => status == 200 || status == 304,
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 304) return false;
      _parse(response.data);
      final content = jsonEncode(response.data);
      if (!await preferences.setString(_cacheKey, content)) {
        throw StateError('动作目录缓存保存失败');
      }
      final nextEtag = response.headers.value('etag');
      if (nextEtag != null) {
        await preferences.setString('${_cacheKey}_etag', nextEtag);
      } else {
        await preferences.remove('${_cacheKey}_etag');
      }
      return cached != content;
    } catch (error, stackTrace) {
      logger.error('FitnessCatalog', '在线动作目录刷新失败，继续使用离线内容', error, stackTrace);
      return false;
    }
  }
}
