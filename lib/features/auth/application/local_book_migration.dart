import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/application/support/action_error_boundary.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 弹窗展示时固定账号、身份代次与本子范围，重试不吸收之后创建的本子。
class LocalBookMigrationPlan {
  /// 固定一次用户确认对应的账号和本子名单。
  const LocalBookMigrationPlan({
    required this.accountId,
    required this.generation,
    required this.targets,
  });
  final String accountId;
  final int generation;
  final List<SyncTarget> targets;

  /// 本次询问涵盖的本子总数。
  int get count => targets.length;
}

/// 登录后的可选本机迁移；只有显式确认会改写归属与同步队列。
class LocalBookMigration {
  /// 复用当前容器中的数据仓储与账号串行边界。
  LocalBookMigration(this.ref);
  final Ref ref;
  ({String account, int generation})? _promptedIdentity;

  /// 注册页经登录页返回时可能同时结束两个路由，同一次登录只展示一次询问。
  Future<LocalBookMigrationPlan?> previewForPrompt() async {
    final account = ref.read(currentAccountIdProvider);
    if (account == null) return null;
    final identity = (
      account: account,
      generation: ref.read(authIdentityGenerationProvider),
    );
    if (_promptedIdentity == identity) return null;
    _promptedIdentity = identity;
    try {
      return await preview();
    } catch (_) {
      if (_promptedIdentity == identity) _promptedIdentity = null;
      rethrow;
    }
  }

  /// 只读取所有业务域的可见本机本，归档账本也参与选择，隐藏副本不参与。
  Future<LocalBookMigrationPlan> preview() =>
      runApplicationAction('LocalBookMigration', '读取本机本子', () async {
        final account = ref.read(currentAccountIdProvider);
        if (account == null) throw StateError('请先登录');
        final generation = ref.read(authIdentityGenerationProvider);
        final targets = await _localTargets();
        final plan = LocalBookMigrationPlan(
          accountId: account,
          generation: generation,
          targets: List.unmodifiable(targets),
        );
        _requireIdentity(plan);
        return plan;
      });

  /// 各域复用同一归属条件，空本也保留在确认名单中。
  Future<List<SyncTarget>> _localTargets() async {
    final ledgers = await ref.read(accountDataAccessProvider).getAllLedgers();
    final days = await ref.read(dayQueryRepositoryProvider).getBooks();
    final memos = await ref.read(memoQueryRepositoryProvider).getBooks();
    final fitness = await ref
        .read(fitnessSpaceQueryRepositoryProvider)
        .getBooks();
    return [
      for (final b in ledgers)
        if (b.storageMode == 'local' && b.scopeAccountId == null)
          SyncTarget('ledger', b.id),
      for (final b in days)
        if (!b.isCloud && b.scopeAccountId == null)
          SyncTarget('day_book', b.id),
      for (final b in memos)
        if (!b.isCloud && b.scopeAccountId == null)
          SyncTarget('memo_book', b.id),
      for (final b in fitness)
        if (!b.isCloud && b.scopeAccountId == null)
          SyncTarget('fitness_space', b.id),
    ];
  }

  /// 确认操作与账号切换共用串行边界，沿用已有迁移实现，任一域失败整批回滚。
  Future<void> migrate(LocalBookMigrationPlan plan) =>
      runApplicationAction('LocalBookMigration', '迁移本机本子', () async {
        _requireIdentity(plan);
        // 记账迁移需要缓存的账号展示资料，提交前显式等待偏好存储就绪。
        await ref.read(sharedPreferencesProvider.future);
        _requireIdentity(plan);
        await ref.read(syncCoordinatorProvider).runAccountTransition(() async {
          _requireIdentity(plan);
          await ref.read(databaseProvider).transaction(() async {
            final available = (await _localTargets()).toSet();
            for (final target in plan.targets) {
              // 已删除或已迁移的本子无需再次处理，确认后新增的本子保持本机归属。
              if (!available.contains(target)) continue;
              await ref.read(dataLifecycleProvider).promoteLocal(target);
            }
            _requireIdentity(plan);
          });
        });
      });

  /// 拒绝退出、换号及同账号重新登录后的旧确认。
  void _requireIdentity(LocalBookMigrationPlan plan) {
    if (!ref.mounted ||
        ref.read(currentAccountIdProvider) != plan.accountId ||
        ref.read(authIdentityGenerationProvider) != plan.generation) {
      throw StateError('账号已变化，请重新操作');
    }
  }
}

/// 注册与登录共用的本机本子迁移入口。
final localBookMigrationProvider = Provider(LocalBookMigration.new);
