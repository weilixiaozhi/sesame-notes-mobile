import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/fitness_library.dart';
import '../../../shared/providers/fitness_library_provider.dart';

/// 官方内容查询随仓储身份重建，网络刷新与快照失效由应用层统一拥有。
final fitnessLibraryQueriesProvider = Provider<FitnessLibraryQueries>((ref) {
  final repository = ref.watch(fitnessLibraryRepositoryProvider.future);
  return FitnessLibraryQueries(
    load: () => ref.read(fitnessLibraryProvider.future),
    refresh: () async {
      final source = await repository;
      final changed = await source.refresh();
      if (!ref.mounted) throw StateError('FITNESS_LIBRARY_QUERY_CHANGED');
      if (changed) ref.invalidate(fitnessLibraryProvider);
      return ref.read(fitnessLibraryProvider.future);
    },
    isCurrent: () => ref.mounted,
  );
});

/// 横幅和其他官方入口按稳定身份补齐目标，不向页面暴露仓储或网络句柄。
class FitnessLibraryQueries {
  /// 注入当前快照、刷新和归属检查，查询可在无平台环境下独立验证。
  const FitnessLibraryQueries({
    required this.load,
    required this.refresh,
    required this.isCurrent,
  });

  final Future<FitnessLibrary> Function() load;
  final Future<FitnessLibrary> Function() refresh;
  final bool Function() isCurrent;

  /// 目标已缓存时立即返回；缺失时最多刷新一次，未知目标交由页面友好回退。
  Future<FitnessLibrary> ensureOfficialContent({
    required String id,
    required bool plan,
  }) async {
    try {
      var library = await load();
      if (!isCurrent()) throw StateError('FITNESS_LIBRARY_QUERY_CHANGED');
      final exists = plan
          ? library.plans.any((value) => value.id == id)
          : library.templates.any((value) => value.id == id);
      if (!exists) library = await refresh();
      if (!isCurrent()) throw StateError('FITNESS_LIBRARY_QUERY_CHANGED');
      return library;
    } catch (error, stack) {
      logger.error(
        'FitnessLibraryQueries',
        '官方训练内容暂时无法读取，请稍后重试',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }
}
