import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/repositories/support/ledger_kind.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'published_ledger_queries.dart';
import 'database_providers.dart';
import 'database_signals.dart';
import 'account_state_provider.dart';
import 'cloud_ledger_download_providers.dart';
import 'refresh_ticks.dart';
import 'simple_state_notifier.dart';

// 记住当前账本：启动时从持久化值恢复并校验有效性，失效则回退到本地第一个账本。
//
// 默认值 '' 为「未选中」哨兵：UUID 主键恒非空，'' 永远不可能是真实账本 id。
final currentLedgerIdProvider =
    NotifierProvider<SimpleStateNotifier<String>, String>(
      () => SimpleStateNotifier((ref) => ''),
    );

// 获取当前账本的详细信息。
final currentLedgerProvider = StreamProvider<Ledger?>((ref) async* {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  final account = ref.watch(currentAccountIdProvider);
  final repo = ref.watch(repositoryProvider);
  // 只观察当前账本是否发布，其他账本的首次下载不能让当前首页重新进入加载态。
  final hidden = ref.watch(
    unpublishedCloudLedgersProvider.select(
      (value) => value.value?.contains(ledgerId),
    ),
  );
  final unpublished =
      hidden ??
      (await ref.read(
        unpublishedCloudLedgersProvider.future,
      )).contains(ledgerId);
  if (!ref.mounted) return;
  yield* repo
      .watchLedger(ledgerId)
      .map(
        (ledger) =>
            ledger != null &&
                ledger.archivedAt == null &&
                ledger.isPublishedTo(
                  account,
                  unpublished ? {ledgerId} : const {},
                )
            ? ledger
            : null,
      );
});

/// 当前账本的 UI 展示模型；Drift Row 在 Provider 边界内完成转换。
final currentLedgerDisplayProvider = Provider<AsyncValue<LedgerDisplayItem?>>((
  ref,
) {
  final ledger = ref.watch(currentLedgerProvider);
  return ledger.whenData((row) => row?.toDisplayItem());
});

/// 当前账本的每月起始日(1-31);未加载完成时按 1(自然月)兜底。
final currentMonthStartDayProvider = Provider<int>((ref) {
  final ledger = ref.watch(currentLedgerProvider).value;
  return (ledger?.monthStartDay ?? 1).clamp(1, 31);
});

/// 手动选本先核对当前可见事实，完整内容尚未发布时保持原选择。
Future<void> selectPublishedLedger(
  T Function<T>(ProviderListenable<T>) read,
  String id,
) async {
  try {
    final target = await readPublishedLedger(read, id, includeArchived: false);
    if (target == null) throw StateError('账本暂不可用，请稍后重试');
    read(currentLedgerIdProvider.notifier).set(target.id);
  } catch (error, stackTrace) {
    logger.error(
      'LedgerSelection',
      '选择账本失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}

/// 选中本地第一个账本并把 id 写回 prefs（仅当前选中无效时才生效，幂等）。
Future<void> selectFirstLedger(
  T Function<T>(ProviderListenable<T>) read,
) async {
  try {
    final account = read(currentAccountIdProvider);
    final generation = read(authIdentityGenerationProvider);
    // 当前已选中且账本真实存在 → 尊重现状不覆盖。
    final current = read(currentLedgerIdProvider);
    final currentLedger = await readPublishedLedger(
      read,
      current,
      includeArchived: false,
    );
    if (currentLedger != null) return;
    final ledgers = await readPublishedLedgers(read);
    // 查询期间的手动选择优先，不能被迟到的自动回退覆盖。
    if (read(currentLedgerIdProvider) != current ||
        read(currentAccountIdProvider) != account ||
        read(authIdentityGenerationProvider) != generation) {
      return;
    }
    if (ledgers.isEmpty) {
      if (read(currentLedgerIdProvider).isNotEmpty) {
        read(currentLedgerIdProvider.notifier).set('');
      }
      return;
    }

    final first = ledgers.first.id;
    if (read(currentLedgerIdProvider) != first) {
      read(currentLedgerIdProvider.notifier).set(first);
    }
    final prefs = await read(sharedPreferencesProvider.future);
    if (read(currentLedgerIdProvider) == first &&
        read(currentAccountIdProvider) == account &&
        read(authIdentityGenerationProvider) == generation) {
      await prefs.setString('current_ledger_id', first);
    }
  } catch (error, stackTrace) {
    logger.error(
      'LedgerSelection',
      '恢复可用账本失败',
      safeErrorSummary(error),
      stackTrace,
    );
  }
}

/// 记住当前账本：启动时恢复并校验，切换时持久化。
final currentLedgerPersistProvider = FutureProvider<void>((ref) async {
  var restoring = true;
  final initialSelection = ref.read(currentLedgerIdProvider);
  // 先注册持久化 / 自愈监听。
  ref.listen<String>(currentLedgerIdProvider, (prev, next) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (ref.mounted && ref.read(currentLedgerIdProvider) == next) {
        await prefs.setString('current_ledger_id', next);
      }
    } catch (_) {}
  });

  // 运行时自愈：当前账本失效时自动回退第一个。
  ref.listen<AsyncValue<Ledger?>>(currentLedgerProvider, (prev, next) {
    // 只处理真正的 AsyncData：AsyncLoading(copyWithPrevious)
    // 会带 hasValue=true 但 value=null，穿透数值守卫导致启动窗口期误触发，
    // 把用户保存的非首个账本覆盖成第一个。
    if (next is! AsyncData) return;
    // 跳过注册时的初始触发（prev==null 表示无旧值）。
    if (prev == null) return;
    if (next.value != null) return;
    final triggerId = ref.read(currentLedgerIdProvider);
    // 哨兵空串不触发自愈（启动解析 / 兜底监听负责空态引导）。
    if (triggerId.isEmpty) return;
    Future(() async {
      try {
        if (!ref.mounted) return;
        final account = ref.read(currentAccountIdProvider);
        final generation = ref.read(authIdentityGenerationProvider);
        // 只保留仍可发布的当前本；缓存行存在但已撤权或尚未发布时也需回退。
        final db = ref.read(databaseProvider);
        final raw = await (db.select(
          db.ledgers,
        )..where((l) => l.id.equals(triggerId))).getSingleOrNull();
        final unpublished = await ref.read(
          unpublishedCloudLedgersProvider.future,
        );
        if (!ref.mounted ||
            account != ref.read(currentAccountIdProvider) ||
            generation != ref.read(authIdentityGenerationProvider) ||
            ref.read(currentLedgerIdProvider) != triggerId) {
          return;
        }
        if (raw != null &&
            raw.archivedAt == null &&
            raw.isPublishedTo(account, unpublished)) {
          return;
        }
        await selectFirstLedger(ref.read);
      } catch (e, stackTrace) {
        logger.error('CurrentLedgerSelfHeal', '自愈回退账本失败: $e', e, stackTrace);
      }
    });
  });

  /// 后台提交和首次任务完成后，空选择自动落到已发布账本。
  void selectWhenEmpty() {
    if (restoring ||
        !ref.mounted ||
        ref.read(currentLedgerIdProvider).isNotEmpty) {
      return;
    }
    Future(() async {
      try {
        if (!ref.mounted || ref.read(currentLedgerIdProvider).isNotEmpty) {
          return;
        }
        await selectFirstLedger(ref.read);
      } catch (e, stackTrace) {
        logger.error('CurrentLedgerSelfHeal', '刷新兜底选账本失败: $e', e, stackTrace);
      }
    });
  }

  ref.listen<int>(ledgerListRefreshProvider, (_, _) => selectWhenEmpty());
  ref.listen(accountingDataChangeSignalProvider, (_, next) {
    if (next is AsyncData) selectWhenEmpty();
  });
  ref.listen(unpublishedCloudLedgersProvider, (_, next) {
    if (next is AsyncData) selectWhenEmpty();
  });

  // 启动解析：恢复持久化账本，失效 / 缺失则回退本地第一个账本。
  try {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final saved = prefs.getString('current_ledger_id');

    final savedLedger = saved == null
        ? null
        : await readPublishedLedger(ref.read, saved, includeArchived: false);
    if (!ref.mounted || ref.read(currentLedgerIdProvider) != initialSelection) {
      return;
    }
    if (savedLedger != null) {
      final st = ref.read(currentLedgerIdProvider);
      if (st != saved) {
        ref.read(currentLedgerIdProvider.notifier).set(savedLedger.id);
      }
    } else {
      await selectFirstLedger(ref.read);
    }
  } catch (error, stackTrace) {
    logger.error(
      'LedgerSelection',
      '读取当前账本偏好失败',
      safeErrorSummary(error),
      stackTrace,
    );
  } finally {
    restoring = false;
    selectWhenEmpty();
  }
});

// 确保监听器被激活
final appInitProvider = FutureProvider<void>((ref) async {
  // 等待启动解析收敛（恢复持久化账本 id 或回退首个账本），
  // 保证随后读取 currentLedgerIdProvider 的预加载基于正确的当前账本。
  await ref.read(currentLedgerPersistProvider.future);
});

/// 按 id 缓存的账本查询（UUID）。
final ledgerByIdProvider = FutureProvider.autoDispose.family<Ledger?, String>((
  ref,
  ledgerId,
) {
  ref.watch(accountingDataChangeSignalProvider);
  final account = ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  final unpublished = ref.watch(unpublishedCloudLedgersProvider.future);
  final repo = ref.watch(repositoryProvider);
  return unpublished.then((hidden) async {
    final ledger = await repo.getLedgerById(ledgerId);
    return ledger?.isPublishedTo(account, hidden) == true ? ledger : null;
  });
});

/// 固定账本页面使用按标识查询的展示模型，不随首页当前本选择变化。
/// 归档状态保留在模型中，由编辑入口按原规则阻止写入。
final ledgerDisplayByIdProvider = Provider.autoDispose
    .family<AsyncValue<LedgerDisplayItem?>, String>((ref, ledgerId) {
      return ref
          .watch(ledgerByIdProvider(ledgerId))
          .whenData((ledger) => ledger?.toDisplayItem());
    });
