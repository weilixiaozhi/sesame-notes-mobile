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
  @override
  void watchDirectory() {
    ref.watch(
      fitnessSpacesProvider.select((value) => privateBookIds(value.value)),
    );
  }

  @override
  Future<List<FitnessSpace>> loadBooks(String? account) =>
      ref.watch(fitnessSpaceRepositoryProvider).getBooks(accountId: account);
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
