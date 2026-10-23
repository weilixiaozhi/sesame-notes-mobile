import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'fitness_providers.dart';

/// 合并静态目录与当前健身空间的自定义动作。
final fitnessCatalogProvider = FutureProvider<List<FitnessExerciseDefinition>>((
  ref,
) async {
  final builtin = await ref.watch(fitnessBuiltinCatalogProvider.future);
  final preferences = await ref.watch(fitnessPreferencesProvider.future);
  return List.unmodifiable([
    ...builtin,
    ...preferences.customExercises.map((e) => e.definition),
  ]);
});
