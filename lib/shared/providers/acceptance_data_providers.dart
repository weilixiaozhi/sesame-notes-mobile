/// debug 包验收数据一键生成的动作门面。
///
/// UI（首页 debug 入口）只调用本文件的动作函数，不直接触碰服务层。
/// 与 [acceptanceDataSeederProvider] 的职责边界：
/// - 本层负责登录态判定、当前账本解析、生成后的状态收敛（切当前账本 / 列表刷新）；
/// - 服务层（AcceptanceDataSeeder）只负责纯数据生成。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/services/acceptance_data_seeder.dart';

/// 验收数据填充器（仅 debug 入口使用）。
final acceptanceDataSeederProvider = Provider<AcceptanceDataSeeder>(
  (ref) => AcceptanceDataSeeder(ref.watch(repositoryProvider)),
);

/// 一键填充当前账本账单（近 12 个月），返回填充笔数。
Future<int> seedAcceptanceBills(WidgetRef ref) async {
  try {
    final ledger = await _requireCurrentLedger(ref);
    final operator = await _resolveOperatorMemberId(ref, ledger);
    final seeder = ref.read(acceptanceDataSeederProvider);
    return seeder.fillBills(ledgerId: ledger.id, operatorMemberId: operator);
  } catch (e, st) {
    logger.error('AcceptanceSeed', '填充账单失败', e, st);
    rethrow;
  }
}

/// 新建本地账本（AA 开启 + 3 个虚拟用户），返回账本名。
Future<String> seedAcceptanceLocalLedger(WidgetRef ref) async {
  try {
    final localSelfId = await readProviderFutureFromWidgetRef(
      ref,
      localSelfIdProvider.future,
    );
    final seeder = ref.read(acceptanceDataSeederProvider);
    final name = '验收本地账本 ${AcceptanceDataSeeder.suffix()}';
    final id = await seeder.createLocalLedger(
      localSelfId: localSelfId,
      name: name,
    );
    await _switchCurrentIfEmpty(ref, id);
    ref.read(ledgerListRefreshProvider.notifier).tick();
    return name;
  } catch (e, st) {
    logger.error('AcceptanceSeed', '新建本地账本失败', e, st);
    rethrow;
  }
}

/// 新建云账本；未登录时返回 null（调用方提示「已跳过」），成功返回账本名。
///
/// 登录判定与账本编辑页同源：authSessionProvider 的 userId 非空即已登录。
Future<String?> seedAcceptanceCloudLedger(WidgetRef ref) async {
  try {
    final accountId = ref.read(authSessionProvider)?.userId;
    if (accountId == null) return null;
    final seeder = ref.read(acceptanceDataSeederProvider);
    final name = '验收云账本 ${AcceptanceDataSeeder.suffix()}';
    final id = await seeder.createCloudLedgerIfLoggedIn(
      accountId: accountId,
      name: name,
    );
    if (id == null) return null;
    await _switchCurrentIfEmpty(ref, id);
    ref.read(ledgerListRefreshProvider.notifier).tick();
    return name;
  } catch (e, st) {
    logger.error('AcceptanceSeed', '新建云账本失败', e, st);
    rethrow;
  }
}

/// 新建 AA 分摊账单（人均/指定/不分摊各一笔），返回笔数。
/// 账本未开启 AA 时自动先开启开关，保证验收一次点击即成功。
Future<int> seedAcceptanceAaBills(WidgetRef ref) async {
  try {
    final ledger = await _requireCurrentLedger(ref);
    if (!ledger.aaEnabled) {
      await ref
          .read(repositoryProvider)
          .updateLedger(id: ledger.id, aaEnabled: true);
    }
    final operator = await _resolveOperatorMemberId(ref, ledger);
    final seeder = ref.read(acceptanceDataSeederProvider);
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
Future<int> seedAcceptanceVirtualUsers(WidgetRef ref) async {
  try {
    final ledger = await _requireCurrentLedger(ref);
    final seeder = ref.read(acceptanceDataSeederProvider);
    final ids = await seeder.createVirtualUsers(ledgerId: ledger.id);
    return ids.length;
  } catch (e, st) {
    logger.error('AcceptanceSeed', '新建虚拟用户失败', e, st);
    rethrow;
  }
}

/// 读取当前账本；无账本或账本已删除时抛错（由 UI 统一 toast）。
Future<Ledger> _requireCurrentLedger(WidgetRef ref) async {
  final ledgerId = ref.read(currentLedgerIdProvider);
  if (ledgerId.isEmpty) {
    throw StateError('当前无账本，请先创建账本');
  }
  final ledger = await readProviderFutureFromWidgetRef(
    ref,
    currentLedgerProvider.future,
  );
  if (ledger == null) {
    throw StateError('当前账本不存在或已被删除');
  }
  return ledger;
}

/// 解析当前操作者成员 id：优先账本 self_member_id；本地账本缺失时按
/// 确定性派生 id 确保 LOCAL 成员行存在（与 AA 统计同一口径）。
Future<String?> _resolveOperatorMemberId(WidgetRef ref, Ledger ledger) async {
  final self = ledger.selfMemberId;
  if (self != null && self.isNotEmpty) return self;
  if (ledger.storageMode != 'local') return null;
  final repo = ref.read(repositoryProvider);
  final localSelfId = await readProviderFutureFromWidgetRef(
    ref,
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
Future<void> _switchCurrentIfEmpty(WidgetRef ref, String ledgerId) async {
  final current = await readProviderFutureFromWidgetRef(
    ref,
    currentLedgerProvider.future,
  );
  if (current == null) {
    ref.read(currentLedgerIdProvider.notifier).set(ledgerId);
    ref.invalidate(currentLedgerProvider);
  }
}
