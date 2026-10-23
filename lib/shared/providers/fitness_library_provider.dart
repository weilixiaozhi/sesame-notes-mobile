import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../core/logging/logger_service.dart';
import '../../core/storage/shared_preferences_provider.dart';
import '../../data/models/fitness_library.dart';
import '../../data/repositories/fitness_library_repository.dart';

/// 页面共用的训练内容库：先返回本地快照，再在后台刷新一次。
final fitnessLibraryProvider = FutureProvider<FitnessLibrary>((ref) async {
  try {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    final repository = FitnessLibraryRepository(
      dio: ref.watch(apiClientProvider).dio,
      preferences: preferences,
    );
    final local = await repository.loadLocal();
    unawaited(_refreshInBackground(ref, repository));
    return local;
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(error, stackTrace);
  }
});

/// 后台刷新：只在服务端内容变化时重建一次；重建后缓存已与本次响应一致，不会循环刷新。
Future<void> _refreshInBackground(
  Ref ref,
  FitnessLibraryRepository repository,
) async {
  try {
    if (await repository.refresh() && ref.mounted) ref.invalidateSelf();
  } catch (error, stackTrace) {
    logger.warning('FitnessLibrary', '训练内容后台刷新失败：$error\n$stackTrace');
  }
}
