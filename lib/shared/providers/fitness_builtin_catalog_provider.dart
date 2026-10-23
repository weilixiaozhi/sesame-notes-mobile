import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import '../../core/storage/shared_preferences_provider.dart';
import '../../data/repositories/fitness_catalog_repository.dart';
import '../../infrastructure/api/api_client_provider.dart';

/// 官方目录先读已缓存快照或随包资源，后台刷新与个人自定义动作互不覆盖。
final fitnessCatalogSnapshotProvider = FutureProvider<FitnessCatalogSnapshot>((
  ref,
) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  final repository = FitnessCatalogRepository(
    dio: ref.watch(apiClientProvider).dio,
    preferences: preferences,
  );
  final local = await repository.loadSnapshot();
  unawaited(
    repository.refresh().then((changed) {
      if (changed && ref.mounted) ref.invalidateSelf();
    }),
  );
  return local;
});

/// 既有动作消费者继续读取列表，动作和分类都由同一快照驱动刷新。
final fitnessBuiltinCatalogProvider =
    FutureProvider<List<FitnessExerciseDefinition>>(
      (ref) async =>
          (await ref.watch(fitnessCatalogSnapshotProvider.future)).exercises,
    );

/// 加载期间或旧目录未提供分类时回退内置名称，已缓存目录可立即展示动态名称。
final fitnessTaxonomiesProvider = Provider<FitnessTaxonomies?>(
  (ref) => ref.watch(fitnessCatalogSnapshotProvider).value?.taxonomies,
);
