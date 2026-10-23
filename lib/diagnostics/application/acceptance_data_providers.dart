/// debug 包验收数据一键生成的动作门面。
///
/// UI（首页 debug 入口）只调用本文件装配的动作对象，不直接触碰服务层。
/// 与 [acceptanceDataSeederProvider] 的职责边界：
/// - 本层负责登录态判定、当前账本解析、生成后的状态收敛（切当前账本 / 列表刷新）；
/// - 服务层（AcceptanceDataSeeder）只负责纯数据生成。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/diagnostics/data/acceptance_data_seeder.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_repository_provider.dart';
import 'package:sesame_notes/diagnostics/data/acceptance_fitness_seeder.dart';

/// 验收数据填充器（仅 debug 入口使用）。
final acceptanceDataSeederProvider = Provider<AcceptanceDataSeeder>(
  (ref) => AcceptanceDataSeeder(ref.watch(repositoryProvider)),
);

/// 应用容器拥有诊断用例，页面只传入验收选项。
final acceptanceDataActionsProvider = Provider<AcceptanceDataActions>(
  AcceptanceDataActions.new,
);

/// 固定应用依赖和首值订阅能力，不保存界面引用。
class AcceptanceDataActions {
  /// 将动作生命周期绑定到应用容器，页面关闭不取消已开始的数据写入。
  AcceptanceDataActions(this._ref);
  final Ref _ref;

  /// 填充健身场景，是否暂停由调用方显式指定。
  Future<void> seedAcceptanceFitness({bool paused = false}) =>
      fillAcceptanceFitness(
        _ref.read(fitnessRepositoryProvider),
        paused: paused,
      );

  /// 纪念日本创建与填充独立；未登录的云端创建不产生本地数据。
  Future<String?> seedAcceptanceDayBook({required bool cloud}) async {
    final accountId = _ref.read(currentAccountIdProvider);
    if (cloud && accountId == null) return null;
    final repository = _ref.read(dayRepositoryProvider);
    final name =
        '验收${cloud ? '云端' : '本地'}纪念日本 ${AcceptanceDataSeeder.suffix()}';
    final book = await repository.createBook(
      id: const Uuid().v4(),
      name: name,
      storageMode: cloud ? 'cloud' : 'local',
      accountId: accountId,
    );
    if (!_ref.mounted) return name;
    if (await _ref.read(currentDayBookIdProvider.future) == null) {
      await _ref.read(currentDayBookIdProvider.notifier).select(book.id);
    }
    return name;
  }

  /// 创建普通的空示例本；已有选择时保持当前本。
  Future<int?> seedAcceptanceMemoBooks({required bool cloud}) async {
    if (cloud && _ref.read(currentAccountIdProvider) == null) return null;
    final currentId = await _ref.read(currentMemoBookIdProvider.future);
    final books = await AcceptanceDataSeeder.createMemoBooks(
      _ref.read(memoRepositoryProvider),
      storageMode: cloud ? 'cloud' : 'local',
    );
    if (_ref.mounted && currentId == null) {
      await _ref
          .read(currentMemoBookIdProvider.notifier)
          .select(books.first.id);
    }
    return books.length;
  }

  /// 填充当前普通本与当前账号密码本，云端沿用仓储的同步登记。
  Future<int> seedAcceptanceMemos() async {
    final currentId = await _ref.read(currentMemoBookIdProvider.future);
    final repository = _ref.read(memoRepositoryProvider);
    final book = currentId == null
        ? null
        : await repository.requireTarget(await repository.target(currentId));
    final books = await AcceptanceDataSeeder.fillMemos(repository, book: book);
    if (_ref.mounted && currentId == null) {
      await _ref
          .read(currentMemoBookIdProvider.notifier)
          .select(books.first.id);
    }
    return books.length * 12;
  }

  /// 固定点击时的当前本与账号，真实仓储负责权限校验及云变更登记。
  Future<int> seedAcceptanceDays() async {
    final repository = _ref.read(dayRepositoryProvider);
    final accountId = _ref.read(currentAccountIdProvider);
    final today = _ref.read(dayTodayProvider);
    final currentId = await _ref.read(currentDayBookIdProvider.future);
    var book = currentId == null
        ? null
        : await repository.getBook(currentId, accountId: accountId);
    // 没有本子也能直接验收，建本与填充在同一事务内完成。
    final count = await repository.db.transaction(() async {
      book ??= await repository.createBook(
        id: const Uuid().v4(),
        name: '示例纪念日 ${AcceptanceDataSeeder.suffix()}',
      );
      return AcceptanceDataSeeder.fillDays(
        repository,
        book: book!,
        today: today,
        accountId: accountId,
      );
    });
    await _ref.read(currentDayBookIdProvider.notifier).select(book!.id);
    return count;
  }

  /// 一键填充近 12 个月账单；没有有效账本时先创建本地示例账本。
  Future<int> seedAcceptanceBills() async {
    try {
      final current = await readProviderFutureFromRef(
        _ref,
        currentLedgerProvider.future,
      );
      final seeder = _ref.read(acceptanceDataSeederProvider);
      final localSelfId = current == null
          ? await readProviderFutureFromRef(_ref, localSelfIdProvider.future)
          : null;
      // 建本、成员和账单一起提交，填充失败时不能留下空本或半批账单。
      final result = await seeder.repo.runInTransaction(() async {
        var ledger = current;
        if (ledger == null) {
          final ledgerId = await seeder.createLocalLedger(
            localSelfId: localSelfId!,
            name: '验收本地账本 ${AcceptanceDataSeeder.suffix()}',
          );
          ledger = await seeder.repo.getLedgerById(ledgerId);
          if (ledger == null) throw StateError('示例账本创建失败，请重试');
        }
        final operator = await _resolveOperatorMemberId(ledger);
        final count = await seeder.fillBills(
          ledgerId: ledger.id,
          operatorMemberId: operator,
        );
        return (ledgerId: ledger.id, count: count);
      });
      if (current == null && _ref.mounted) {
        // 数据提交后再选中示例本；填充期间已有新选择时保留用户选择。
        await _switchCurrentIfEmpty(result.ledgerId);
        _ref.read(ledgerListRefreshProvider.notifier).tick();
      }
      return result.count;
    } catch (e, st) {
      logger.error('AcceptanceSeed', '填充账单失败', e, st);
      rethrow;
    }
  }

  /// 新建本地账本（AA 开启 + 3 个虚拟用户），返回账本名。
  Future<String> seedAcceptanceLocalLedger() async {
    try {
      final localSelfId = await readProviderFutureFromRef(
        _ref,
        localSelfIdProvider.future,
      );
      final seeder = _ref.read(acceptanceDataSeederProvider);
      final name = '验收本地账本 ${AcceptanceDataSeeder.suffix()}';
      final id = await seeder.createLocalLedger(
        localSelfId: localSelfId,
        name: name,
      );
      await _switchCurrentIfEmpty(id);
      _ref.read(ledgerListRefreshProvider.notifier).tick();
      return name;
    } catch (e, st) {
      logger.error('AcceptanceSeed', '新建本地账本失败', e, st);
      rethrow;
    }
  }

  /// 新建云账本；未登录时返回 null（调用方提示「已跳过」），成功返回账本名。
  ///
  /// 登录判定与账本编辑页同源：authSessionProvider 的 userId 非空即已登录。
  Future<String?> seedAcceptanceCloudLedger() async {
    try {
      final accountId = _ref.read(authSessionProvider)?.userId;
      if (accountId == null) return null;
      final seeder = _ref.read(acceptanceDataSeederProvider);
      final name = '验收云账本 ${AcceptanceDataSeeder.suffix()}';
      final id = await seeder.createCloudLedgerIfLoggedIn(
        accountId: accountId,
        name: name,
      );
      if (id == null) return null;
      await _switchCurrentIfEmpty(id);
      _ref.read(ledgerListRefreshProvider.notifier).tick();
      return name;
    } catch (e, st) {
      logger.error('AcceptanceSeed', '新建云账本失败', e, st);
      rethrow;
    }
  }

  /// 新建 AA 分摊账单（人均/指定/不分摊各一笔），返回笔数。
  /// 账本未开启 AA 时自动先开启开关，保证验收一次点击即成功。
  Future<int> seedAcceptanceAaBills() async {
    try {
      final ledger = await _requireCurrentLedger();
      if (!ledger.aaEnabled) {
        await _ref
            .read(repositoryProvider)
            .updateLedger(id: ledger.id, aaEnabled: true);
      }
      final operator = await _resolveOperatorMemberId(ledger);
      final seeder = _ref.read(acceptanceDataSeederProvider);
      final ids = await seeder.createAaBills(
        ledgerId: ledger.id,
        baseCurrency: ledger.currency.toUpperCase(),
        operatorMemberId: operator,
      );
      return ids.length;
    } catch (e, st) {
      logger.error('AcceptanceSeed', '新建 AA 分摊账单失败', e, st);
      rethrow;
    }
  }

  /// 新建 3 个虚拟用户，返回创建数量。
  Future<int> seedAcceptanceVirtualUsers() async {
    try {
      final ledger = await _requireCurrentLedger();
      final seeder = _ref.read(acceptanceDataSeederProvider);
      final ids = await seeder.createVirtualUsers(ledgerId: ledger.id);
      return ids.length;
    } catch (e, st) {
      logger.error('AcceptanceSeed', '新建虚拟用户失败', e, st);
      rethrow;
    }
  }

  /// 读取当前账本；无账本或账本已删除时抛错（由 UI 统一 toast）。
  Future<Ledger> _requireCurrentLedger() async {
    final ledgerId = _ref.read(currentLedgerIdProvider);
    if (ledgerId.isEmpty) {
      throw StateError('当前无账本，请先创建账本');
    }
    final ledger = await readProviderFutureFromRef(
      _ref,
      currentLedgerProvider.future,
    );
    if (ledger == null) {
      throw StateError('当前账本不存在或已被删除');
    }
    return ledger;
  }

  /// 解析当前操作者成员 id：优先账本 self_member_id；本地账本缺失时按
  /// 确定性派生 id 确保 LOCAL 成员行存在（与 AA 统计同一口径）。
  Future<String?> _resolveOperatorMemberId(Ledger ledger) async {
    final self = ledger.selfMemberId;
    if (self != null && self.isNotEmpty) return self;
    if (ledger.storageMode != 'local') return null;
    final repo = _ref.read(repositoryProvider);
    final localSelfId = await readProviderFutureFromRef(
      _ref,
      localSelfIdProvider.future,
    );
    final member = await repo.ensureLocalSelfMember(
      ledgerId: ledger.id,
      localSelfId: localSelfId,
      displayName: '',
    );
    return member.id;
  }

  /// 空账本场景切换到新账本（对齐账本编辑页新建后的切换逻辑）。
  Future<void> _switchCurrentIfEmpty(String ledgerId) async {
    final current = await readProviderFutureFromRef(
      _ref,
      currentLedgerProvider.future,
    );
    if (current == null) {
      _ref.read(currentLedgerIdProvider.notifier).set(ledgerId);
      _ref.invalidate(currentLedgerProvider);
    }
  }
}
