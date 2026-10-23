import 'package:sesame_notes/data/repositories/contracts/day_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

/// 纯日期实现由顶层装配注入，共享 Provider 不引用业务 feature。
final dayDefinitionValidatorProvider =
    Provider<DayEventDefinition Function(DayEventDefinition)>((ref) {
      throw StateError('日子日期校验尚未装配');
    });

/// 日子仓储与记账共用数据库和账号事实，保持各自业务数据边界。
final dayRepositoryProvider = Provider<DayRepository>((ref) {
  final db = ref.watch(databaseProvider);
  // 会话身份与代次必须在这里注入：显式带 accountId 的云本写入要用它校验
  // 会话未变化，换号时也要让订阅者重新装配，避免旧账号上下文继续写库。
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  return DayRepository(
    db,
    validateAndProject: (definition) =>
        ref.read(dayDefinitionValidatorProvider)(definition),
    accountIdGetter: () => ref.read(currentAccountIdProvider),
    generationGetter: () =>
        ref.read(authSessionProvider.notifier).identityGeneration,
    changeRecorder: ChangeRecorderImpl(
      db,
      accountIdGetter: () => ref.read(currentAccountIdProvider),
    ),
  );
});

/// 仅向用例公开 DayQueryRepository，复用同一事务与账号上下文。
final dayQueryRepositoryProvider = Provider<DayQueryRepository>(
  (ref) => ref.watch(dayRepositoryProvider),
);

/// 仅向用例公开 DayEntryRepository，复用同一事务与账号上下文。
final dayEntryRepositoryProvider = Provider<DayEntryRepository>(
  (ref) => ref.watch(dayRepositoryProvider),
);

/// 仅向用例公开 DayBookRepository，复用同一事务与账号上下文。
final dayBookRepositoryProvider = Provider<DayBookRepository>(
  (ref) => ref.watch(dayRepositoryProvider),
);

/// 仅向用例公开 DayTransferRepository，复用同一事务与账号上下文。
final dayTransferRepositoryProvider = Provider<DayTransferRepository>(
  (ref) => ref.watch(dayRepositoryProvider),
);

/// 仅向用例公开 DayAccountRepository，复用同一事务与账号上下文。
final dayAccountRepositoryProvider = Provider<DayAccountRepository>(
  (ref) => ref.watch(dayRepositoryProvider),
);
