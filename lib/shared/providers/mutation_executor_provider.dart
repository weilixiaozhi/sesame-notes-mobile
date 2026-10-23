import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/application/ports/mutation_executor.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 写用例只取得本机写入能力，与恢复和切号复用同一生命周期协调器。
final mutationExecutorProvider = Provider<MutationExecutor>(
  (ref) => ref.watch(syncCoordinatorProvider),
);
