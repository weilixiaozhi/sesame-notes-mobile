import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 默认本子懒创建入口：欢迎流程只落分类模板，本子由首条数据顺带创建。
///
/// 仅当该业务域一本都没有时创建默认本子（登录时归账号域，未登录为本地本子），
/// 已存在任何本子时保持既有选择与新建入口不变——否则新装应用登录已有账号时
/// 会建出一本与云端同名的默认本子，用户以为数据没恢复。
class DefaultBookProvisioner implements DefaultBookActions {
  /// 通过应用容器取得各业务用例和当前账号状态。
  DefaultBookProvisioner(this.ref);

  final Ref ref;

  static const _uuid = Uuid();

  /// 返回该业务域可承载首条数据的本子 id；已有本子时返回 null（调用方走既有入口）。
  @override
  Future<String?> ensureDefault(AppMode mode, AppLocalizations l10n) async {
    try {
      switch (mode) {
        case AppMode.bookkeeping:
          return await _ensureLedger(l10n);
        case AppMode.days:
          return await _ensureDayBook(l10n);
        case AppMode.memos:
          return await _ensureMemoBook(l10n);
        case AppMode.fitness:
          return await _ensureFitnessSpace(l10n);
      }
    } catch (error, stackTrace) {
      logger.error(
        'DefaultBook',
        '默认本子创建失败 mode=${mode.name}',
        error,
        stackTrace,
      );
      return null;
    }
  }

  /// 私有本的目录判定与创建在同一写事务中完成，等待期间换号则全部回滚。
  Future<T> _withPrivateBookCreation<T>(
    Future<T> Function(String? account, int generation, String storageMode)
    action,
  ) {
    final storageMode = ref.read(newBookStorageModeProvider);
    final config = ref.read(apiConfigProvider);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final db = ref.read(databaseProvider);

    /// 身份固定为发起时的账号与代次，不能将迟到创建提交到新会话。
    void verify() {
      if (!ref.mounted ||
          ref.read(currentAccountIdProvider) != account ||
          ref.read(authIdentityGenerationProvider) != generation ||
          ref.read(newBookStorageModeProvider) != storageMode ||
          !identical(ref.read(apiConfigProvider), config)) {
        throw StateError('账号已变更，请重新操作');
      }
    }

    return ref
        .read(syncCoordinatorProvider)
        .runDataMutation(
          () => db.transaction(() async {
            verify();
            final result = await action(account, generation, storageMode);
            verify();
            return result;
          }),
        );
  }

  /// 已登录的空目录须先完成云端发现，未确认的目录不能触发隐式默认建本。
  bool _directoryAllowsDefault(String? account, AppMode mode) {
    if (account == null ||
        !ref.read(cloudCapabilityProvider).canUseCloudBooks) {
      return true;
    }
    final directory = switch (mode) {
      AppMode.days => dayDirectoryStatusProvider,
      AppMode.memos => memoDirectoryStatusProvider,
      AppMode.fitness => fitnessDirectoryStatusProvider,
      AppMode.bookkeeping => throw StateError('记账目录使用独立发布状态'),
    };
    return ref.read(directory) == BookDirectoryStatus.ready;
  }

  /// 默认建本的查询、创建和选中共用发起时的身份，云端待发布事实也参与判定。
  Future<String?> _ensureLedger(AppLocalizations l10n) async {
    final storageMode = ref.read(newBookStorageModeProvider);
    final config = ref.read(apiConfigProvider);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);

    /// 任一次等待期间身份变化都中止本次默认创建。
    void verify() {
      if (!ref.mounted ||
          ref.read(currentAccountIdProvider) != account ||
          ref.read(authIdentityGenerationProvider) != generation ||
          ref.read(newBookStorageModeProvider) != storageMode ||
          !identical(ref.read(apiConfigProvider), config)) {
        throw StateError('账号已变更，请重新操作');
      }
    }

    final repo = ref.read(repositoryProvider);
    if ((await repo.getAllLedgers()).isNotEmpty) return null;
    verify();
    // 已知云端账本正在后台建立完整内容时，不另建同名默认本。
    if (storageMode == 'cloud' &&
        (await ref.read(
          pendingCloudLedgerDownloadsProvider.future,
        )).isNotEmpty) {
      return null;
    }
    verify();
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final localSelfId = storageMode == 'local'
        ? await ref.read(localSelfIdProvider.future)
        : null;
    verify();
    final id = await repo.runInTransaction(() async {
      verify();
      // 等待期间已落地或已登记的远端本优先，避免与后台发布并发重复创建。
      if ((await repo.getAllLedgers()).isNotEmpty ||
          (storageMode == 'cloud' &&
              (await ref.read(
                pendingCloudLedgerDownloadsProvider.future,
              )).isNotEmpty)) {
        return null;
      }
      verify();
      final created = await ref
          .read(ledgerActionsProvider)
          .create(
            name: l10n.ledgerDefaultName,
            currency: prefs.getString('selected_currency') ?? 'CNY',
            storageMode: storageMode,
            localSelfId: localSelfId,
          );
      verify();
      return created;
    });
    if (id == null) return null;
    verify();
    await selectPublishedLedger(ref.read, id);
    logger.info('DefaultBook', '首条数据懒创建默认账本 id=$id');
    return id;
  }

  /// 查询与创建共用固定账号和事务，已有目录时交还原有新增入口。
  Future<String?> _ensureDayBook(AppLocalizations l10n) async {
    final repo = ref.read(dayRepositoryProvider);
    final book = await _withPrivateBookCreation((
      account,
      generation,
      storageMode,
    ) async {
      if ((await repo.getBooks(accountId: account)).isNotEmpty) return null;
      if (!_directoryAllowsDefault(account, AppMode.days)) return null;
      return repo.createBook(
        id: _uuid.v4(),
        name: l10n.dayDefaultBookName,
        storageMode: storageMode,
        accountId: account,
        generation: generation,
      );
    });
    if (book == null) return null;
    await ref.read(currentDayBookIdProvider.notifier).select(book.id);
    logger.info('DefaultBook', '首条数据懒创建默认日子本 id=${book.id}');
    return book.id;
  }

  /// 普通本与账号密码本分别判定，云目录与本机目录都属于当前账号可见范围。
  Future<String?> _ensureMemoBook(AppLocalizations l10n) async {
    final repo = ref.read(memoRepositoryProvider);
    final book = await _withPrivateBookCreation((
      account,
      generation,
      storageMode,
    ) async {
      final books = await repo.getBooks(accountId: account);
      if (books.any((book) => book.type != memoBookTypeCredentials)) {
        return null;
      }
      if (!_directoryAllowsDefault(account, AppMode.memos)) return null;
      return repo.createBook(
        id: _uuid.v4(),
        name: l10n.memoDefaultBookName,
        type: 'normal',
        storageMode: storageMode,
        accountId: account,
        generation: generation,
      );
    });
    if (book == null) return null;
    await ref.read(currentMemoBookIdProvider.notifier).select(book.id);
    logger.info('DefaultBook', '首条数据懒创建默认备忘录本 id=${book.id}');
    return book.id;
  }

  /// 新增卡片复用已有账号密码本，目录确认该类型为空时才创建并选中默认本。
  @override
  Future<String?> ensureCredentialBook(AppLocalizations l10n) async {
    try {
      final storageMode = ref.read(newBookStorageModeProvider);
      final config = ref.read(apiConfigProvider);
      final account = ref.read(currentAccountIdProvider);
      final generation = ref.read(authIdentityGenerationProvider);
      final repo = ref.read(memoRepositoryProvider);
      final selection = ref.read(currentCredentialBookIdProvider.notifier);
      final current = await selection.currentSelection();
      if (!ref.mounted ||
          ref.read(currentAccountIdProvider) != account ||
          ref.read(authIdentityGenerationProvider) != generation ||
          ref.read(newBookStorageModeProvider) != storageMode ||
          !identical(ref.read(apiConfigProvider), config)) {
        throw StateError('账号已变更，请重新操作');
      }
      final book = await _withPrivateBookCreation((
        account,
        generation,
        storageMode,
      ) async {
        final books = (await repo.getBooks(
          accountId: account,
        )).where((book) => book.type == memoBookTypeCredentials).toList();
        final existing =
            books.where((book) => book.id == current).firstOrNull ??
            books.firstOrNull;
        if (existing != null) return existing;
        if (!_directoryAllowsDefault(account, AppMode.memos)) return null;
        return repo.createBook(
          id: _uuid.v4(),
          name: l10n.memoCredentials,
          type: memoBookTypeCredentials,
          storageMode: storageMode,
          accountId: account,
          generation: generation,
        );
      });
      if (book == null) return null;
      await selection.select(book.id);
      logger.info('DefaultBook', '懒创建账号密码本 id=${book.id}');
      return book.id;
    } catch (error, stackTrace) {
      logger.error('DefaultBook', '账号密码本创建失败', error, stackTrace);
      return null;
    }
  }

  /// 健身空间按当前账号查询，目录检查与创建共享写入边界。
  Future<String?> _ensureFitnessSpace(AppLocalizations l10n) async {
    final repo = ref.read(fitnessSpaceRepositoryProvider);
    final book = await _withPrivateBookCreation((
      account,
      generation,
      storageMode,
    ) async {
      if ((await repo.getBooks(accountId: account)).isNotEmpty) return null;
      if (!_directoryAllowsDefault(account, AppMode.fitness)) return null;
      return repo.createBook(
        id: _uuid.v4(),
        name: l10n.fitnessDefaultSpaceName,
        storageMode: storageMode,
      );
    });
    if (book == null) return null;
    await ref.read(currentFitnessSpaceIdProvider.notifier).select(book.id);
    logger.info('DefaultBook', '首条数据懒创建默认健身空间 id=${book.id}');
    return book.id;
  }
}
