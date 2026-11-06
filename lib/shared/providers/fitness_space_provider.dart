import 'package:sesame_notes/data/repositories/contracts/fitness_space_repositories.dart';
import 'sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/models/private_book.dart';
import '../../data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'current_private_book_provider.dart';
import 'read_provider_future.dart';

final fitnessSpaceRepositoryProvider = Provider(
  (ref) => FitnessSpaceRepository(
    ref.watch(databaseProvider),
    accountIdGetter: () => ref.read(currentAccountIdProvider),
    generationGetter: () => ref.read(authIdentityGenerationProvider),
    changeRecorder: ChangeRecorderImpl(
      ref.watch(databaseProvider),
      accountIdGetter: () => ref.read(currentAccountIdProvider),
    ),
  ),
);
final fitnessSpacesProvider = StreamProvider<List<FitnessSpace>>(
  (ref) => ref
      .watch(fitnessSpaceRepositoryProvider)
      .watchBooks(accountId: ref.watch(currentAccountIdProvider)),
);
final currentFitnessSpaceIdProvider =
    AsyncNotifierProvider<CurrentFitnessSpaceNotifier, String?>(
      CurrentFitnessSpaceNotifier.new,
    );

class CurrentFitnessSpaceNotifier extends CurrentPrivateBookNotifier {
  @override
  String get preferencePrefix => 'current_fitness_space_id';

  /// 依赖身份和空间选择均读取同步观察到的最新目录。
  @override
  List<FitnessSpace> watchDirectory() {
    ref.watch(
      fitnessSpacesProvider.select((value) => privateBookIds(value.value)),
    );
    return ref.read(fitnessSpacesProvider).requireValue;
  }

  /// 选空间复用目录流，避免再次聚合全部训练实体数量。
  @override
  Future<void> waitForDirectory() async {
    await readProviderFutureFromRef(ref, fitnessSpacesProvider.future);
  }

  @override
  Future<PrivateBookTarget> target(String id) =>
      ref.read(fitnessSpaceRepositoryProvider).target(id);
  @override
  Future<FitnessSpace> requireTarget(PrivateBookTarget target) =>
      ref.read(fitnessSpaceRepositoryProvider).requireTarget(target);
}

final currentFitnessSpaceProvider = Provider<AsyncValue<FitnessSpace?>>(
  (ref) => selectedPrivateBook(
    privateBooksForDisplay(
      ref.watch(fitnessSpacesProvider),
      ref.watch(currentAccountIdProvider),
      ref.watch(fitnessDirectoryStatusProvider),
    ),
    ref.watch(currentFitnessSpaceIdProvider),
  ),
);

/// 仅向用例公开 FitnessSpaceQueryRepository，复用同一事务与账号上下文。
final fitnessSpaceQueryRepositoryProvider =
    Provider<FitnessSpaceQueryRepository>(
      (ref) => ref.watch(fitnessSpaceRepositoryProvider),
    );

/// 仅向用例公开 FitnessSpaceBookRepository，复用同一事务与账号上下文。
final fitnessSpaceBookRepositoryProvider = Provider<FitnessSpaceBookRepository>(
  (ref) => ref.watch(fitnessSpaceRepositoryProvider),
);

/// 仅向用例公开 FitnessSpaceAccountRepository，复用同一事务与账号上下文。
final fitnessSpaceAccountRepositoryProvider =
    Provider<FitnessSpaceAccountRepository>(
      (ref) => ref.watch(fitnessSpaceRepositoryProvider),
    );
