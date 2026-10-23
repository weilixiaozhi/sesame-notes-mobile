import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/repositories/fitness_media_repository.dart';
import '../../../infrastructure/api/api_client_provider.dart';

/// 官方媒体查询随当前 API 实例更新，仓储和持久缓存仅由应用层持有。
final fitnessMediaQueriesProvider = Provider<FitnessMediaQueries>(
  (ref) => FitnessMediaQueries(
    FitnessMediaRepository(dio: ref.watch(apiClientProvider).dio),
  ),
);

/// 向展示层提供可解码的媒体字节，隐藏网络和磁盘缓存实现。
class FitnessMediaQueries {
  /// 复用同一仓储实例的下载合并与持久缓存。
  const FitnessMediaQueries(this._repository);

  final FitnessMediaRepository _repository;

  /// 不可用的媒体返回空结果，由图片组件选择随包资源或重试占位。
  Future<Uint8List?> load(String mediaUrl) async {
    try {
      return await _repository.load(mediaUrl);
    } catch (error, stackTrace) {
      logger.error(
        'FitnessMediaQueries',
        '官方动作图片暂不可用，继续使用内置素材',
        error,
        stackTrace,
      );
      return null;
    }
  }
}
