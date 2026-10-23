import 'package:sesame_notes/data/repositories/contracts/memo_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MemoRepository(
    db,
    accountIdGetter: () => ref.read(currentAccountIdProvider),
    generationGetter: () =>
        ref.read(authSessionProvider.notifier).identityGeneration,
    changeRecorder: ChangeRecorderImpl(
      db,
      accountIdGetter: () => ref.read(currentAccountIdProvider),
    ),
  );
});

/// 仅向用例公开 MemoQueryRepository，复用同一事务与账号上下文。
final memoQueryRepositoryProvider = Provider<MemoQueryRepository>(
  (ref) => ref.watch(memoRepositoryProvider),
);

/// 仅向用例公开 MemoEntryRepository，复用同一事务与账号上下文。
final memoEntryRepositoryProvider = Provider<MemoEntryRepository>(
  (ref) => ref.watch(memoRepositoryProvider),
);

/// 仅向用例公开 MemoBookRepository，复用同一事务与账号上下文。
final memoBookRepositoryProvider = Provider<MemoBookRepository>(
  (ref) => ref.watch(memoRepositoryProvider),
);

/// 仅向用例公开 MemoTransferRepository，复用同一事务与账号上下文。
final memoTransferRepositoryProvider = Provider<MemoTransferRepository>(
  (ref) => ref.watch(memoRepositoryProvider),
);

/// 仅向用例公开 MemoAccountRepository，复用同一事务与账号上下文。
final memoAccountRepositoryProvider = Provider<MemoAccountRepository>(
  (ref) => ref.watch(memoRepositoryProvider),
);
