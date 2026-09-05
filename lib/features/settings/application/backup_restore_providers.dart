/// 备份恢复流程状态（集中编排：打开 → 预览 → 勾选策略 → 立即恢复）。
///
/// 设计意图：恢复流程的状态（加载中/错误/会话/预览条目/决策/结果）集中在
/// 本 Notifier，页面只做渲染；服务经构造注入（测试 overrideWith 注入假实现，
/// 生产由默认装配）。打开与勾选全程零写入，「立即恢复」单事务应用。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

/// 恢复流程错误分类（UI 据此映射本地化文案）。
enum RestoreFlowError {
  /// 无错误
  none,

  /// 文件损坏 / 非备份文件 / 解析失败
  openFailed,

  /// 备份 schema 旧于当前
  schemaTooOld,

  /// 备份 schema 新于当前
  schemaTooNew,

  /// 应用恢复失败（单事务已整体回滚）
  applyFailed,
}

/// 单个账本的恢复预览展示项。
class RestoreLedgerItem {
  const RestoreLedgerItem({
    required this.ledgerBackupId,
    required this.name,
    required this.storageOrigin,
    this.accountId,
    required this.currency,
    required this.expenseTotal,
    required this.memberCount,
    required this.transactionCount,
    required this.conflictCount,
  });

  final String ledgerBackupId;
  final String name;
  final LedgerStorageOrigin storageOrigin;

  /// 备份记录的归属账号 id（云端账本；本地账本为 null）。
  final String? accountId;

  /// 账本本位币（ISO 大写），与账本管理页卡片同口径展示。
  final String currency;

  /// 账本累计支出总额（备份时快照），与账本管理页卡片同口径。
  final double expenseTotal;

  final int memberCount;
  final int transactionCount;
  final int conflictCount;
}

/// 页面可选的恢复决策。
enum RestoreDecision { restoreLocal, forkCloudToLocal, reconnect, skip }

/// 判定云端账本是否归入「云端账本」分区（其余账本一律归「本地账本」分区）。
///
/// 规则：已登录且备份记录的归属账号 == 当前账号。未登录 / 账号不符 /
/// 备份缺账号信息的云端账本归入本地分区，选中时恢复为本地副本。
bool cloudSectionOf({
  required RestoreLedgerItem item,
  required String? currentAccountId,
}) {
  if (item.storageOrigin != LedgerStorageOrigin.cloud) return false;
  if (currentAccountId == null || currentAccountId.isEmpty) return false;
  if (item.accountId == null || item.accountId!.isEmpty) return false;
  return item.accountId == currentAccountId;
}

/// 账本的默认决策（默认全选：勾选时按此决策恢复，取消勾选 = skip）。
RestoreDecision defaultDecisionFor({
  required RestoreLedgerItem item,
  required String? currentAccountId,
}) {
  if (item.storageOrigin == LedgerStorageOrigin.local) {
    return RestoreDecision.restoreLocal;
  }
  if (cloudSectionOf(item: item, currentAccountId: currentAccountId)) {
    return RestoreDecision.reconnect;
  }
  return RestoreDecision.forkCloudToLocal;
}

/// 应用恢复后是否需要触发 Reconnect v1（纯函数，测试锚点）。
///
/// 仅当存在「reconnect 决策已应用且原账号 == 当前账号」的账本时为 true；
/// 未登录/账号不符时不得触发（备份内容不复制，云端最新由登录后的
/// Reconnect v1 下载）。
bool shouldReconnectAfterApply({
  required List<RestoreLedgerItem> items,
  required Map<String, RestoreDecision> decisions,
  required String? currentAccountId,
}) {
  if (currentAccountId == null || currentAccountId.isEmpty) return false;
  return items.any(
    (item) =>
        decisions[item.ledgerBackupId] == RestoreDecision.reconnect &&
        item.accountId == currentAccountId,
  );
}

/// 恢复流程状态（不可变快照）。
class BackupRestoreFlowState {
  const BackupRestoreFlowState({
    this.loading = false,
    this.error = RestoreFlowError.none,
    this.session,
    this.items = const [],
    this.decisions = const {},
  });

  /// 是否忙（打开备份/应用恢复中）。
  final bool loading;

  /// 错误分类（打开失败/应用失败，均不触碰 live DB）。
  final RestoreFlowError error;

  /// 打开的只读恢复会话（打开备份的产物，退出页面时关闭释放临时文件）。
  final RecoverySession? session;

  /// 备份内容预览条目。
  final List<RestoreLedgerItem> items;

  /// 每账本恢复决策（默认全选预填；未决策 = skip）。
  final Map<String, RestoreDecision> decisions;

  /// 不可变快照复制：[clearSession] 为 true 时显式清空会话（nullable 字段
  /// 无法用 null 区分「不修改」与「置空」）。
  BackupRestoreFlowState copyWith({
    bool? loading,
    RestoreFlowError? error,
    RecoverySession? session,
    bool clearSession = false,
    List<RestoreLedgerItem>? items,
    Map<String, RestoreDecision>? decisions,
  }) {
    return BackupRestoreFlowState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      session: clearSession ? null : (session ?? this.session),
      items: items ?? this.items,
      decisions: decisions ?? this.decisions,
    );
  }
}

/// 恢复流程 Notifier：编排打开 → 预览 → 勾选 → 立即恢复。
class BackupRestoreFlowNotifier extends Notifier<BackupRestoreFlowState> {
  BackupRestoreFlowNotifier({BackupImportService? importService})
    : _importService = importService; // ignore: prefer_initializing_formals

  final BackupImportService? _importService;

  BackupImportService get _import => _importService ?? BackupImportService();

  /// 当前打开的会话引用（onDispose 兜底关闭时不能访问 state，用普通字段）。
  RecoverySession? _session;

  @override
  BackupRestoreFlowState build() {
    // 容器销毁兜底关闭会话：页面中途退出/异常路径也会释放解压临时文件
    ref.onDispose(() {
      final session = _session;
      if (session != null) unawaited(session.close());
    });
    return const BackupRestoreFlowState();
  }

  /// 打开备份（明文解帧 + Manifest 校验 + 只读预览），零写入。
  ///
  /// 备份无加密，任何设备可直接打开；打开失败即文件损坏或非备份文件。
  /// 成功后按「默认全选」预填每账本决策（本地→恢复为本地账本，
  /// 云端匹配账号→恢复为云账本，其余云端→恢复为本地副本）。
  Future<void> openBackup({required File file}) async {
    state = state.copyWith(
      loading: true,
      error: RestoreFlowError.none,
      clearSession: true,
    );
    try {
      final db = ref.read(databaseProvider);
      final session = await _import.openBackup(
        backupFile: file,
        currentSchemaVersion: db.schemaVersion,
      );
      final items = (await _import.listRecoveryItems(session))
          .map(
            (item) => RestoreLedgerItem(
              ledgerBackupId: item.ledgerBackupId,
              name: item.name,
              storageOrigin: item.storageOrigin,
              accountId: item.accountReference?.accountId,
              currency: item.currency,
              expenseTotal: item.expenseTotal,
              memberCount: item.memberCount,
              transactionCount: item.transactionCount,
              conflictCount: item.conflictCount,
            ),
          )
          .toList(growable: false);
      final currentAccountId = ref.read(authSessionProvider)?.userId;
      _session = session;
      state = state.copyWith(
        loading: false,
        session: session,
        items: items,
        decisions: {
          for (final item in items)
            item.ledgerBackupId: defaultDecisionFor(
              item: item,
              currentAccountId: currentAccountId,
            ),
        },
      );
    } on BackupFormatException catch (e) {
      logger.warning('RestoreFlow', '打开备份失败: ${e.reason.name} ${e.message}');
      final error = switch (e.reason) {
        BackupOpenError.schemaTooOld => RestoreFlowError.schemaTooOld,
        BackupOpenError.schemaTooNew => RestoreFlowError.schemaTooNew,
        _ => RestoreFlowError.openFailed,
      };
      state = state.copyWith(loading: false, error: error);
    } catch (e, st) {
      logger.error('RestoreFlow', '打开备份异常', e, st);
      state = state.copyWith(
        loading: false,
        error: RestoreFlowError.openFailed,
      );
    }
  }

  /// 勾选/取消勾选单个账本：选中 = 默认决策恢复，未选中 = skip（暂不处理）。
  void setDecision(String ledgerBackupId, RestoreDecision decision) {
    final decisions = Map<String, RestoreDecision>.from(state.decisions);
    decisions[ledgerBackupId] = decision;
    state = state.copyWith(decisions: decisions);
  }

  /// 应用恢复：单事务写入 live DB，任一步失败整体回滚。
  ///
  /// 返回是否成功。成功后页面立即 toast 并退出，会话由页面 dispose 的
  /// [closeSession] 统一释放；失败保留会话，用户可直接重试。
  /// 结果提示由页面按返回值弹 toast。
  Future<bool> apply() async {
    final session = state.session;
    if (session == null) return false;
    state = state.copyWith(loading: true, error: RestoreFlowError.none);
    try {
      // 决策的唯一来源是流程状态；应用前同步进会话（apply 只读 session.decisions）
      session.decisions
        ..clear()
        ..addAll(
          state.decisions.map(
            (id, decision) => MapEntry(id, _toInfrastructureDecision(decision)),
          ),
        );
      final db = ref.read(databaseProvider);
      final localSelfId = await ref.read(localSelfIdProvider.future);
      // 当前认证账号（账号匹配时 self 指向原 REGISTERED 成员）
      final currentAccountId = ref.read(authSessionProvider)?.userId;
      await _import.apply(
        session: session,
        liveDb: db,
        localSelfId: localSelfId,
        currentAccountId: currentAccountId,
      );
      // 存在「恢复为云账本」且账号匹配的决策：触发 Reconnect v1 从服务器
      // 下载云端最新（备份内容不复制，实际数据由同步引擎收敛）。
      if (shouldReconnectAfterApply(
        items: state.items,
        decisions: state.decisions,
        currentAccountId: currentAccountId,
      )) {
        unawaited(_reconnectAfterApply());
      }
      // 会话保留到页面退出再关闭：成功后页面立即 toast 退出，
      // 临时文件由页面 dispose 的 closeSession 统一释放。
      state = state.copyWith(loading: false);
      return true;
    } catch (e, st) {
      logger.error('RestoreFlow', '应用恢复失败（已回滚）', e, st);
      state = state.copyWith(
        loading: false,
        error: RestoreFlowError.applyFailed,
      );
      return false;
    }
  }

  /// 关闭恢复会话并清理临时文件（页面退出/应用完成后调用；幂等）。
  ///
  /// 页面 dispose 时容器可能已先行销毁：状态写入前判 ref.mounted，
  /// 临时文件清理不依赖状态照常执行。
  Future<void> closeSession() async {
    final session = _session;
    if (session == null) return;
    _session = null;
    if (ref.mounted) {
      state = state.copyWith(clearSession: true);
    }
    await session.close();
  }

  /// 把页面决策转换为恢复引擎决策。
  RecoveryDecision _toInfrastructureDecision(RestoreDecision decision) =>
      switch (decision) {
        RestoreDecision.restoreLocal => RecoveryDecision.restoreLocal,
        RestoreDecision.forkCloudToLocal => RecoveryDecision.forkCloudToLocal,
        RestoreDecision.reconnect => RecoveryDecision.reconnect,
        RestoreDecision.skip => RecoveryDecision.skip,
      };

  /// 应用恢复后触发 Reconnect v1：收敛云端账本并刷新账本列表。
  ///
  /// 失败仅记日志不打断恢复流程（恢复本身已完成，云端收敛可重试）。
  Future<void> _reconnectAfterApply() async {
    try {
      await ref.read(syncCoordinatorProvider).reconnect();
      ref.read(ledgerListRefreshProvider.notifier).tick();
    } catch (e, st) {
      logger.error('RestoreFlow', '恢复后 Reconnect 失败', e, st);
    }
  }
}

/// 恢复流程 provider（生产装配；测试 overrideWith 注入假服务）。
final backupRestoreFlowProvider =
    NotifierProvider<BackupRestoreFlowNotifier, BackupRestoreFlowState>(
      BackupRestoreFlowNotifier.new,
    );
