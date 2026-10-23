import '../../data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/contracts/fitness_repositories.dart';
import 'fitness_space_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

final fitnessRepositoryProvider = Provider<FitnessRepository>((ref) {
  final db = ref.watch(databaseProvider);
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  return FitnessRepository(
    db,
    spaceId: ref.watch(currentFitnessSpaceIdProvider).value ?? '',
    syncId: ref.watch(
      currentFitnessSpaceProvider.select((value) => value.value?.syncId),
    ),
    syncIdGetter: () => ref.read(currentFitnessSpaceProvider).value?.syncId,
    spaceIdGetter: () => ref.read(currentFitnessSpaceIdProvider).value ?? '',
    accountIdGetter: () => ref.read(currentAccountIdProvider),
    generationGetter: () =>
        ref.read(authSessionProvider.notifier).identityGeneration,
    changeRecorder: ChangeRecorderImpl(
      db,
      accountIdGetter: () => ref.read(currentAccountIdProvider),
    ),
  );
});

/// 仅向用例公开 FitnessQueryRepository，复用同一事务与账号上下文。
final fitnessQueryRepositoryProvider = Provider<FitnessQueryRepository>(
  (ref) => ref.watch(fitnessRepositoryProvider),
);

/// 仅向用例公开 FitnessWorkoutRepository，复用同一事务与账号上下文。
final fitnessWorkoutRepositoryProvider = Provider<FitnessWorkoutRepository>(
  (ref) => ref.watch(fitnessRepositoryProvider),
);

/// 仅向用例公开 FitnessLibraryWriteRepository，复用同一事务与账号上下文。
final fitnessLibraryWriteRepositoryProvider =
    Provider<FitnessLibraryWriteRepository>(
      (ref) => ref.watch(fitnessRepositoryProvider),
    );

/// 仅向用例公开 FitnessPreferencesRepository，复用同一事务与账号上下文。
final fitnessPreferencesRepositoryProvider =
    Provider<FitnessPreferencesRepository>(
      (ref) => ref.watch(fitnessRepositoryProvider),
    );

/// 文件交换固定目标的只读实例，与首页当前空间选择相互独立。
final fitnessTargetQueryRepositoryProvider =
    Provider.family<FitnessQueryRepository, PrivateBookTarget>(
      (ref, target) => FitnessRepository(
        ref.watch(databaseProvider),
        spaceId: target.bookId,
        syncId: target.syncId,
        accountIdGetter: () => ref.read(currentAccountIdProvider),
        generationGetter: () => ref.read(authIdentityGenerationProvider),
      ),
    );
