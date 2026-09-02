import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/shared_preferences_provider.dart';
// 叶子模块：账本列表刷新 tick，供自愈兜底监听使用。
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';

// 数据库Provider
/// 统一业务数据变更信号：任何业务表发生写入（插入/更新/删除）都会发射一次。
///
/// 所有汇总/统计 provider 只依赖这一个信号，保证「无论从哪条路径写库都会
/// 自动刷新」。只订阅业务表，排除同步簿记表（sync_changes / sync_state /
/// sync_pull_errors / backup_state）与编辑历史表。
final dataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((ref) {
  // 手动刷新只重建这一个数据依赖源，所有派生 provider 会随之重算。
  final manualRefreshRevision = ref.watch(manualDataRefreshProvider);
  final db = ref.watch(databaseProvider);
  return _watchBusinessDataChanges(
    db,
    emitManualRefresh: manualRefreshRevision > 0,
  );
});

/// 监听所有会影响客户端展示的业务表。
///
/// 手动刷新时先发射空集合，让重建的流真正通知消费者；
/// 常规首次订阅不额外发射，避免页面初始化重查两次。
Stream<Set<TableUpdate>> _watchBusinessDataChanges(
  SesameDatabase db, {
  required bool emitManualRefresh,
}) async* {
  if (emitManualRefresh) yield <TableUpdate>{};
  try {
    yield* db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.ledgers,
        db.categories,
        db.transactions,
        db.transactionSplits,
        db.recurringTransactions,
        db.ledgerMembers,
        db.sharedLedgerCategories,
        db.exchangeRates,
        db.exchangeRateOverrides,
        // 同步冲突属于业务状态，解决或新增时需要刷新冲突 UI。
        db.syncConflicts,
      ]),
    );
  } catch (e, st) {
    logger.error('DataChangeSignal', '监听业务数据变更失败', e, st);
    rethrow;
  }
}

final databaseProvider = Provider<SesameDatabase>((ref) {
  final db = SesameDatabase();
  ref.onDispose(() async {
    // 本地备份恢复流程会在 invalidate 前手动 close 过连接，此处二次 close
    // Drift 会抛 StateError，故幂等容错。
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});

// 仓储Provider — LocalRepository(本地优先)。变更登记经 ChangeRecorder 端口
// 注入：写操作落 sync_changes 表，由 SyncService 消费推送。
final repositoryProvider = Provider<LocalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  // 变更登记带当前账号域：登录后编辑的 mutation 归属当前账号，未登录不归属
  return LocalRepository(
    db,
    changeTracker: ChangeRecorderImpl(
      db,
      accountIdGetter: () => ref.read(authSessionProvider)?.userId,
    ),
    // 汇率覆盖等确定性派生主键需要当前账号身份，与变更登记同源。
    accountIdGetter: () => ref.read(authSessionProvider)?.userId,
  );
});

// 记住当前账本：启动时从持久化值恢复并校验有效性，失效则回退到本地第一个账本。
//
// 默认值 '' 为「未选中」哨兵：UUID 主键恒非空，'' 永远不可能是真实账本 id。
final currentLedgerIdProvider =
    NotifierProvider<SimpleStateNotifier<String>, String>(
      () => SimpleStateNotifier((ref) => ''),
    );

// 获取当前账本的详细信息。
final currentLedgerProvider = StreamProvider<Ledger?>((ref) {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  final repo = ref.watch(repositoryProvider);
  return repo.watchLedger(ledgerId);
});

/// 当前账本的 UI 展示模型；Drift Row 在 Provider 边界内完成转换。
final currentLedgerDisplayProvider = Provider<AsyncValue<LedgerDisplayItem?>>((
  ref,
) {
  return ref
      .watch(currentLedgerProvider)
      .whenData((row) => row?.toDisplayItem());
});

/// 当前账本的每月起始日(1-28);未加载完成时按 1(自然月)兜底。
final currentMonthStartDayProvider = Provider<int>((ref) {
  final ledger = ref.watch(currentLedgerProvider).value;
  return (ledger?.monthStartDay ?? 1).clamp(1, 28);
});

/// 选中本地第一个账本并把 id 写回 prefs（仅当前选中无效时才生效，幂等）。
Future<void> selectFirstLedger(
  T Function<T>(ProviderListenable<T>) read,
) async {
  try {
    final repo = read(repositoryProvider);

    // 当前已选中且账本真实存在 → 尊重现状不覆盖。
    final current = read(currentLedgerIdProvider);
    if (current.isNotEmpty && await repo.getLedgerById(current) != null) return;

    final ledgers = await repo.getAllLedgers();
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
    await prefs.setString('current_ledger_id', first);
  } catch (_) {
    // 选中失败不阻断引导/启动流程。
  }
}

/// 记住当前账本：启动时恢复并校验，切换时持久化。
final currentLedgerPersistProvider = FutureProvider<void>((ref) async {
  // 先注册持久化 / 自愈监听。
  ref.listen<String>(currentLedgerIdProvider, (prev, next) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString('current_ledger_id', next);
    } catch (_) {}
  });

  // 运行时自愈：当前账本失效时自动回退第一个。
  ref.listen<AsyncValue<Ledger?>>(currentLedgerProvider, (prev, next) {
    // 只处理真正的 AsyncData：Riverpod 3.4 的 AsyncLoading(copyWithPrevious)
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
        final repo = ref.read(repositoryProvider);
        final ledgers = await repo.getAllLedgers();
        if (ref.read(currentLedgerIdProvider) != triggerId) return;
        if (ledgers.isEmpty) {
          if (triggerId.isNotEmpty) {
            ref.read(currentLedgerIdProvider.notifier).set('');
          }
          return;
        }
        final first = ledgers.first.id;
        if (triggerId == first) return;
        if (triggerId.isEmpty) return;
        ref.read(currentLedgerIdProvider.notifier).set(first);
      } catch (e, stackTrace) {
        logger.error('CurrentLedgerSelfHeal', '自愈回退账本失败: $e', e, stackTrace);
      }
    });
  });

  // 兜底：账本列表刷新后若仍停在哨兵但已有账本。
  ref.listen<int>(ledgerListRefreshProvider, (prev, next) {
    if (ref.read(currentLedgerIdProvider).isNotEmpty) return;
    Future(() async {
      try {
        final repo = ref.read(repositoryProvider);
        final ledgers = await repo.getAllLedgers();
        if (ledgers.isEmpty) return;
        if (ref.read(currentLedgerIdProvider).isNotEmpty) return;
        ref.read(currentLedgerIdProvider.notifier).set(ledgers.first.id);
      } catch (e, stackTrace) {
        logger.error('CurrentLedgerSelfHeal', '刷新兜底选账本失败: $e', e, stackTrace);
      }
    });
  });

  // 启动解析：恢复持久化账本，失效 / 缺失则回退本地第一个账本。
  try {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final repo = ref.read(repositoryProvider);
    final saved = prefs.getString('current_ledger_id');

    if (saved != null &&
        saved.isNotEmpty &&
        await repo.getLedgerById(saved) != null) {
      final st = ref.read(currentLedgerIdProvider);
      if (st != saved) {
        ref.read(currentLedgerIdProvider.notifier).set(saved);
      }
    } else {
      await selectFirstLedger(ref.read);
    }
  } catch (_) {
    // 读取或校验失败时保持现状。
  }
});

// 当账本切换时，顺便触发一次设置页状态刷新。
final ledgerChangeListenerProvider = Provider<void>((ref) {
  ref.read(currentLedgerPersistProvider);
  ref.listen<String>(currentLedgerIdProvider, (prev, next) {
    // 账本切换：汇总刷新由 dataChangeSignal 驱动，此处仅保持监听活跃。
  });
});

// 确保监听器被激活
final appInitProvider = FutureProvider<void>((ref) async {
  ref.read(ledgerChangeListenerProvider);
  // 等待启动解析收敛（恢复持久化账本 id 或回退首个账本），
  // 保证随后读取 currentLedgerIdProvider 的预加载基于正确的当前账本。
  await ref.read(currentLedgerPersistProvider.future);
});

// 分类Provider
final categoriesProvider = FutureProvider<List<CategoryDisplay>>((ref) async {
  ref.watch(dataChangeSignalProvider);
  final repo = ref.watch(repositoryProvider);
  return (await repo.getAllCategories())
      .map((row) => row.toDisplay())
      .toList(growable: false);
});

// 分类与交易笔数组合Provider（响应式版本）
final categoriesWithCountProvider =
    StreamProvider.autoDispose<
      List<({CategoryDisplay category, int transactionCount})>
    >((ref) {
      final repo = ref.watch(repositoryProvider);
      return repo.watchCategoriesWithCount().map(
        (rows) => rows
            .map(
              (row) => (
                category: row.category.toDisplay(),
                transactionCount: row.transactionCount,
              ),
            )
            .toList(growable: false),
      );
    });

/// 按 id 缓存的分类查询（UUID）。
final categoryByIdProvider = FutureProvider.autoDispose
    .family<CategoryDisplay?, String>((ref, categoryId) async {
      ref.watch(dataChangeSignalProvider);
      final repo = ref.watch(repositoryProvider);
      return (await repo.getCategoryById(categoryId))?.toDisplay();
    });

/// 按 id 缓存的账本查询（UUID）。
final ledgerByIdProvider = FutureProvider.autoDispose.family<Ledger?, String>((
  ref,
  ledgerId,
) {
  ref.watch(dataChangeSignalProvider);
  final repo = ref.watch(repositoryProvider);
  return repo.getLedgerById(ledgerId);
});
