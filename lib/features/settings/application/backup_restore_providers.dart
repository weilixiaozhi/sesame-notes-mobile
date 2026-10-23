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
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';

/// 恢复流程错误分类（UI 据此映射本地化文案）。
enum RestoreFlowError {
  /// 无错误
  none,

  /// 文件损坏 / 非备份文件 / 解析失败
  openFailed,

  /// 备份 schema 与当前不一致
  unsupportedSchema,

  /// 应用恢复失败（单事务已整体回滚）
  applyFailed,
}

/// 单个账本的恢复预览展示项。
class RestoreLedgerItem {
  /// 保存恢复列表实际展示的账本来源、统计与归档状态。
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
    this.archivedAt,
  });

  final String ledgerBackupId;
  final String name;

  /// 备份中的个人归档时间，仅用于恢复预览标识。
  final DateTime? archivedAt;
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

/// 每个日子本独立预览；即使为空也保留可选卡片。
class RestoreDayBookItem {
  final ManifestDayBook book;

  /// 保留日子本的备份定义与分类数量。
  const RestoreDayBookItem({required this.book});
}

/// 备忘录本与健身空间复用来源信息和已核验的重连资格。
class RestorePrivateBookItem<B extends ManifestPrivateBook> {
  final B book;
  final bool canReconnect;

  /// 默认不能重连，只有预览读取实际云绑定后才允许恢复为云本。
  const RestorePrivateBookItem(this.book, {this.canReconnect = false});
}

typedef RestoreMemoBookItem = RestorePrivateBookItem<ManifestMemoBook>;
typedef RestoreFitnessSpaceItem = RestorePrivateBookItem<ManifestFitnessSpace>;
RestoreDecision defaultPrivateBookDecision(RestorePrivateBookItem item) =>
    item.book.storageOrigin == LedgerStorageOrigin.local
    ? RestoreDecision.restoreLocal
    : item.canReconnect
    ? RestoreDecision.reconnect
    : RestoreDecision.forkCloudToLocal;
RestoreDecision defaultMemoBookDecision(RestoreMemoBookItem item) =>
    defaultPrivateBookDecision(item);

/// 来源账号匹配时恢复原云绑定，其余云本产生独立本机副本。
RestoreDecision defaultDayBookDecision(
  RestoreDayBookItem item,
  String? accountId,
) {
  if (item.book.storageOrigin == LedgerStorageOrigin.local) {
    return RestoreDecision.restoreLocal;
  }
  return accountId != null &&
          item.book.syncId != null &&
          item.book.sourceAccountId == accountId &&
          !item.book.isHidden
      ? RestoreDecision.reconnect
      : RestoreDecision.forkCloudToLocal;
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

/// 恢复流程状态（不可变快照）。
class BackupRestoreFlowState {
  const BackupRestoreFlowState({
    this.loading = false,
    this.error = RestoreFlowError.none,
    this.session,
    this.items = const [],
    this.decisions = const {},
    this.dayBookItems = const [],
    this.dayBookDecisions = const {},
    this.memoBookItems = const [],
    this.memoBookDecisions = const {},
    this.fitnessSpaceItems = const [],
    this.fitnessSpaceDecisions = const {},
    this.cloudRestorePending = false,
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
  final List<RestoreDayBookItem> dayBookItems;
  final Map<String, RestoreDecision> dayBookDecisions;
  final List<RestoreMemoBookItem> memoBookItems;
  final Map<String, RestoreDecision> memoBookDecisions;
  final List<RestoreFitnessSpaceItem> fitnessSpaceItems;
  final Map<String, RestoreDecision> fitnessSpaceDecisions;
  final bool cloudRestorePending;

  /// 不可变快照复制：[clearSession] 为 true 时显式清空会话（nullable 字段
  /// 无法用 null 区分「不修改」与「置空」）。
  BackupRestoreFlowState copyWith({
    bool? loading,
    RestoreFlowError? error,
    RecoverySession? session,
    bool clearSession = false,
    List<RestoreLedgerItem>? items,
    Map<String, RestoreDecision>? decisions,
    List<RestoreDayBookItem>? dayBookItems,
    Map<String, RestoreDecision>? dayBookDecisions,
    List<RestoreMemoBookItem>? memoBookItems,
    Map<String, RestoreDecision>? memoBookDecisions,
    bool? cloudRestorePending,
    List<RestoreFitnessSpaceItem>? fitnessSpaceItems,
    Map<String, RestoreDecision>? fitnessSpaceDecisions,
  }) {
    return BackupRestoreFlowState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      session: clearSession ? null : (session ?? this.session),
      items: items ?? this.items,
      decisions: decisions ?? this.decisions,
      dayBookItems: dayBookItems ?? this.dayBookItems,
      dayBookDecisions: dayBookDecisions ?? this.dayBookDecisions,
      memoBookItems: memoBookItems ?? this.memoBookItems,
      memoBookDecisions: memoBookDecisions ?? this.memoBookDecisions,
      fitnessSpaceItems: fitnessSpaceItems ?? this.fitnessSpaceItems,
      fitnessSpaceDecisions:
          fitnessSpaceDecisions ?? this.fitnessSpaceDecisions,
      cloudRestorePending: cloudRestorePending ?? this.cloudRestorePending,
    );
  }
}

/// 一次恢复持有独立的预览与身份，后续页面选择不能改变已确认的任务。
class _RestoreApplySnapshot {
  /// 复制四类条目与决策，保留本次操作使用的源会话和身份代次。
  _RestoreApplySnapshot({
    required BackupRestoreFlowState preview,
    required this.session,
    required this.request,
    required this.accountId,
    required this.generation,
  }) : preview = preview.copyWith(
         items: List.unmodifiable(preview.items),
         decisions: Map.unmodifiable(preview.decisions),
         dayBookItems: List.unmodifiable(preview.dayBookItems),
         dayBookDecisions: Map.unmodifiable(preview.dayBookDecisions),
         memoBookItems: List.unmodifiable(preview.memoBookItems),
         memoBookDecisions: Map.unmodifiable(preview.memoBookDecisions),
         fitnessSpaceItems: List.unmodifiable(preview.fitnessSpaceItems),
         fitnessSpaceDecisions: Map.unmodifiable(preview.fitnessSpaceDecisions),
       );

  final BackupRestoreFlowState preview;
  final RecoverySession session;
  final int request;
  final String? accountId;
  final int? generation;
}

/// 恢复流程 Notifier：编排打开 → 预览 → 勾选 → 立即恢复。
class BackupRestoreFlowNotifier extends Notifier<BackupRestoreFlowState> {
  BackupRestoreFlowNotifier({BackupImportService? importService})
    : _importService = importService; // ignore: prefer_initializing_formals

  final BackupImportService? _importService;

  BackupImportService get _import => _importService ?? BackupImportService();

  /// 当前打开的会话引用（onDispose 兜底关闭时不能访问 state，用普通字段）。
  RecoverySession? _session;
  String? _openingAccountId;
  int? _openingGeneration;
  Future<void>? _closingSession;
  ({RecoverySession session, Future<bool> result})? _applying;
  int _openingRequest = 0;
  Completer<void>? _openingCancellation;
  void _cancelOpening() {
    final pending = _openingCancellation;
    _openingCancellation = null;
    if (pending != null && !pending.isCompleted) pending.complete();
  }

  /// 同账号重新登录也会改变 generation，迟到的预览不能写入新会话。
  void _validateContext() {
    if (!ref.mounted ||
        ref.read(authSessionProvider)?.userId != _openingAccountId ||
        ref.read(authSessionProvider.notifier).identityGeneration !=
            _openingGeneration) {
      throw StateError('账号已变化，请重新打开备份');
    }
  }

  @override
  BackupRestoreFlowState build() {
    // 容器销毁兜底关闭会话：页面中途退出/异常路径也会释放解压临时文件
    ref.onDispose(() {
      unawaited(closeSession());
    });
    return const BackupRestoreFlowState();
  }

  /// 打开备份（明文解帧 + Manifest 校验 + 只读预览），零写入。
  ///
  /// 备份无加密，任何设备可直接打开；打开失败即文件损坏或非备份文件。
  /// 成功后按「默认全选」预填每账本决策（本地→恢复为本地账本，
  /// 云端匹配账号→恢复为云账本，其余云端→恢复为本地副本）。
  Future<void> openBackup({required File file}) async {
    _cancelOpening();
    final cancellation = Completer<void>();
    _openingCancellation = cancellation;
    final request = ++_openingRequest;
    await _closeCurrentSession();
    if (!ref.mounted || request != _openingRequest) return;
    _openingAccountId = ref.read(authSessionProvider)?.userId;
    _openingGeneration = ref
        .read(authSessionProvider.notifier)
        .identityGeneration;
    state = state.copyWith(
      loading: true,
      error: RestoreFlowError.none,
      clearSession: true,
    );
    void checkOpening() {
      if (request != _openingRequest) throw StateError('备份打开已取消');
      _validateContext();
    }

    RecoverySession? opened;
    var published = false;
    try {
      final db = ref.read(databaseProvider);
      final session = await _import.openBackup(backupFile: file);
      opened = session;
      if (!ref.mounted || request != _openingRequest) return;
      _session = session;
      _validateContext();
      final rawItems = await _import.listRecoveryItems(session);
      checkOpening();

      final items = rawItems
          .map(
            (item) => RestoreLedgerItem(
              ledgerBackupId: item.ledgerBackupId,
              name: item.name,
              archivedAt: item.archivedAt,
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
      final dayBookItems = <RestoreDayBookItem>[];
      for (final book in session.manifest.dayBooks) {
        checkOpening();
        dayBookItems.add(RestoreDayBookItem(book: book));
      }
      session.dayTargetSnapshots.addAll(
        await _import.captureDayTargets(
          db,
          dayBookItems.map((item) => item.book.dayBookId),
          cancelled: cancellation.future,
        ),
      );
      final memoItems = <RestoreMemoBookItem>[];
      for (final book in session.manifest.memoBooks) {
        checkOpening();
        final existing = await (db.select(
          db.memoBooks,
        )..where((b) => b.id.equals(book.id))).getSingleOrNull();
        memoItems.add(
          RestoreMemoBookItem(
            book,
            canReconnect:
                book.storageOrigin == LedgerStorageOrigin.cloud &&
                currentAccountId != null &&
                book.sourceAccountId == currentAccountId &&
                existing?.scopeAccountId == currentAccountId &&
                existing?.isHidden == false &&
                existing?.isStale == false &&
                existing?.deletedAt == null &&
                existing?.syncId != null &&
                existing?.fullCursor != null,
          ),
        );
      }
      session.memoTargetSnapshots.addAll(
        await _import.captureMemoTargets(
          db,
          memoItems.map((i) => i.book.id),
          cancelled: cancellation.future,
        ),
      );
      final fitnessItems = <RestoreFitnessSpaceItem>[];
      for (final space in session.manifest.fitnessSpaces) {
        checkOpening();
        final existing = await (db.select(
          db.fitnessSpaces,
        )..where((b) => b.id.equals(space.id))).getSingleOrNull();
        fitnessItems.add(
          RestoreFitnessSpaceItem(
            space,
            canReconnect:
                space.storageOrigin == LedgerStorageOrigin.cloud &&
                currentAccountId != null &&
                space.sourceAccountId == currentAccountId &&
                existing?.scopeAccountId == currentAccountId &&
                existing?.isHidden == false &&
                existing?.isStale == false &&
                existing?.deletedAt == null &&
                existing?.syncId != null &&
                existing?.fullCursor != null,
          ),
        );
      }
      session.fitnessTargetSnapshots.addAll(
        await FitnessDataTransfer.fingerprints(
          db,
          fitnessItems.map((i) => i.book.id),
          cancelled: cancellation.future,
        ),
      );
      _validateContext();
      if (!ref.mounted || request != _openingRequest) return;
      state = state.copyWith(
        loading: false,
        session: session,
        items: items,
        dayBookItems: dayBookItems,
        memoBookItems: memoItems,
        fitnessSpaceItems: fitnessItems,
        fitnessSpaceDecisions: {
          for (final item in fitnessItems)
            item.book.id: defaultPrivateBookDecision(item),
        },
        memoBookDecisions: {
          for (final item in memoItems)
            item.book.id: defaultMemoBookDecision(item),
        },
        dayBookDecisions: {
          for (final item in dayBookItems)
            item.book.dayBookId: defaultDayBookDecision(item, currentAccountId),
        },
        decisions: {
          for (final item in items)
            item.ledgerBackupId: defaultDecisionFor(
              item: item,
              currentAccountId: currentAccountId,
            ),
        },
      );
      published = true;
    } on BackupFormatException catch (e) {
      logger.warning('RestoreFlow', '打开备份失败: ${e.reason.name} ${e.message}');
      final error = switch (e.reason) {
        BackupOpenError.unsupportedSchema => RestoreFlowError.unsupportedSchema,
        _ => RestoreFlowError.openFailed,
      };
      if (ref.mounted && request == _openingRequest) {
        state = state.copyWith(loading: false, error: error);
      }
    } catch (e, st) {
      logger.error('RestoreFlow', '打开备份异常', safeErrorSummary(e), st);
      if (ref.mounted && request == _openingRequest) {
        state = state.copyWith(
          loading: false,
          error: RestoreFlowError.openFailed,
        );
      }
    } finally {
      if (!cancellation.isCompleted) cancellation.complete();
      if (identical(_openingCancellation, cancellation)) {
        _openingCancellation = null;
      }
      if (!published && opened != null) {
        if (identical(_session, opened)) _session = null;
        await opened.close();
      }
    }
  }

  /// 勾选/取消勾选单个账本：选中 = 默认决策恢复，未选中 = skip（暂不处理）。
  void setDecision(String ledgerBackupId, RestoreDecision decision) {
    final decisions = Map<String, RestoreDecision>.from(state.decisions);
    decisions[ledgerBackupId] = decision;
    state = state.copyWith(decisions: decisions);
  }

  /// 日子选择不改动记账决策集合。
  void setDayBookDecision(String id, RestoreDecision decision) => state = state
      .copyWith(dayBookDecisions: {...state.dayBookDecisions, id: decision});
  void setMemoBookDecision(String id, RestoreDecision decision) => state = state
      .copyWith(memoBookDecisions: {...state.memoBookDecisions, id: decision});

  void setFitnessSpaceDecision(String id, RestoreDecision decision) =>
      state = state.copyWith(
        fitnessSpaceDecisions: {...state.fitnessSpaceDecisions, id: decision},
      );

  /// 固定本次恢复选择，重复确认共用同一个任务；页面退出不关闭在用源库。
  Future<bool> apply() {
    if (!ref.mounted) return Future.value(false);
    final session = state.session;
    if (session == null) return Future.value(false);
    final active = _applying;
    if (active != null) return active.result;
    final snapshot = _RestoreApplySnapshot(
      preview: state,
      session: session,
      request: _openingRequest,
      accountId: _openingAccountId,
      generation: _openingGeneration,
    );
    late final Future<bool> result;
    // 先登记任务再开始异步工作，关闭页面时始终能找到需要等待的源库使用者。
    result = Future<bool>.microtask(() => _applySnapshot(snapshot))
        .whenComplete(() {
          if (identical(_applying?.result, result)) _applying = null;
        });
    _applying = (session: session, result: result);
    state = state.copyWith(loading: true, error: RestoreFlowError.none);
    return result;
  }

  /// 身份校验只比较任务捕获值，关闭预览或打开其他备份不会改写预期账号。
  bool _matchesApplyIdentity(_RestoreApplySnapshot snapshot) =>
      ref.mounted &&
      ref.read(authSessionProvider)?.userId == snapshot.accountId &&
      ref.read(authSessionProvider.notifier).identityGeneration ==
          snapshot.generation;

  /// 事务提交前身份必须仍然有效；同账号重新登录也使旧任务失效。
  void _validateApplyIdentity(_RestoreApplySnapshot snapshot) {
    if (!_matchesApplyIdentity(snapshot)) {
      throw StateError('账号已变化，请重新打开备份');
    }
  }

  /// 只有仍绑定本次会话的页面才能接收加载状态和恢复结果。
  bool _ownsApplySnapshot(_RestoreApplySnapshot snapshot) =>
      ref.mounted &&
      snapshot.request == _openingRequest &&
      identical(_session, snapshot.session) &&
      identical(state.session, snapshot.session);

  /// 使用固定预览执行事务，提交成功后的刷新失败独立处理。
  Future<bool> _applySnapshot(_RestoreApplySnapshot snapshot) async {
    final session = snapshot.session;
    final preview = snapshot.preview;
    final fitnessCloudIds = {
      for (final entry in preview.fitnessSpaceDecisions.entries)
        if (entry.value == RestoreDecision.reconnect) entry.key,
    };
    final memoCloudIds = {
      for (final entry in preview.memoBookDecisions.entries)
        if (entry.value == RestoreDecision.reconnect) entry.key,
    };
    final ledgerIds = {
      for (final item in preview.items)
        if (preview.decisions[item.ledgerBackupId] ==
                RestoreDecision.reconnect &&
            item.accountId == snapshot.accountId)
          item.ledgerBackupId,
    };
    final dayBookIds = {
      for (final item in preview.dayBookItems)
        if (preview.dayBookDecisions[item.book.dayBookId] ==
                RestoreDecision.reconnect &&
            item.book.sourceAccountId == snapshot.accountId)
          item.book.dayBookId,
    };
    final pending =
        ledgerIds.isNotEmpty ||
        dayBookIds.isNotEmpty ||
        memoCloudIds.isNotEmpty ||
        fitnessCloudIds.isNotEmpty;
    try {
      _validateApplyIdentity(snapshot);
      // 引擎只读取本次冻结的选择，界面随后产生的选择不参与当前事务。
      session.fitnessSpaceDecisions
        ..clear()
        ..addAll(
          preview.fitnessSpaceDecisions.map(
            (id, decision) => MapEntry(id, _toInfrastructureDecision(decision)),
          ),
        );
      session.decisions
        ..clear()
        ..addAll(
          preview.decisions.map(
            (id, decision) => MapEntry(id, _toInfrastructureDecision(decision)),
          ),
        );
      session.dayBookDecisions
        ..clear()
        ..addAll(
          preview.dayBookDecisions.map(
            (id, decision) => MapEntry(id, _toInfrastructureDecision(decision)),
          ),
        );
      session.memoBookDecisions
        ..clear()
        ..addAll(
          preview.memoBookDecisions.map(
            (id, decision) => MapEntry(id, _toInfrastructureDecision(decision)),
          ),
        );
      if (memoCloudIds.isNotEmpty || fitnessCloudIds.isNotEmpty) {
        // 云端覆盖先 full；若下载改变任何目标指纹，事务会要求重新预览。
        final refreshed = await ref
            .read(syncCoordinatorProvider)
            .reconnect(
              ledgerIds: {},
              dayBookIds: {},
              memoBookIds: memoCloudIds,
              fitnessSpaceIds: fitnessCloudIds,
            );
        if (![
          ...memoCloudIds,
          ...fitnessCloudIds,
        ].every(refreshed.refreshed.contains)) {
          throw StateError('MEMO_RESTORE_FULL_REQUIRED');
        }
        _validateApplyIdentity(snapshot);
      }
      final db = ref.read(databaseProvider);
      final localSelfId = await ref.read(localSelfIdProvider.future);
      _validateApplyIdentity(snapshot);
      await _import.apply(
        session: session,
        liveDb: db,
        localSelfId: localSelfId,
        currentAccountId: snapshot.accountId,
        validateContext: () => _validateApplyIdentity(snapshot),
      );
    } catch (e, st) {
      logger.error('RestoreFlow', '应用备份未完成', safeErrorSummary(e), st);
      if (_ownsApplySnapshot(snapshot)) {
        state = state.copyWith(
          loading: false,
          error: RestoreFlowError.applyFailed,
        );
      }
      return false;
    }
    // 引擎返回即已提交；身份变化只能停止后续同步，不能把已提交内容误报为回滚。
    if (pending && _matchesApplyIdentity(snapshot)) {
      unawaited(
        _reconnectAfterApply(
          snapshot,
          ledgerIds: ledgerIds,
          dayBookIds: dayBookIds,
          syncAfter: memoCloudIds.isNotEmpty || fitnessCloudIds.isNotEmpty,
        ),
      );
    }
    if (_ownsApplySnapshot(snapshot)) {
      state = state.copyWith(loading: false, cloudRestorePending: pending);
    }
    return true;
  }

  /// 关闭恢复会话并清理临时文件（页面退出/应用完成后调用；幂等）。
  ///
  /// 页面 dispose 时容器可能已先行销毁：状态写入前判 ref.mounted，
  /// 退出立即解绑预览，源库等已确认的恢复结束后释放。
  Future<void> closeSession() {
    _openingRequest++;
    _cancelOpening();
    return _closeCurrentSession();
  }

  /// 解绑当前预览并复用关闭任务，后续打开必须等待源会话使用者结束。
  Future<void> _closeCurrentSession() async {
    final session = _session;
    if (session == null) {
      await _closingSession;
      return;
    }
    _session = null;
    final active = _applying;
    final applying = identical(active?.session, session)
        ? active?.result
        : null;
    if (ref.mounted) {
      state = const BackupRestoreFlowState();
    }
    _closingSession = _releaseSession(session, applying);
    await _closingSession;
  }

  /// 源库在事务结束后关闭；销毁回调也可安全等待，清理失败只记录脱敏日志。
  Future<void> _releaseSession(
    RecoverySession session,
    Future<bool>? applying,
  ) async {
    try {
      await applying;
    } catch (error, stackTrace) {
      logger.error(
        'RestoreFlow',
        '等待恢复任务结束失败',
        safeErrorSummary(error),
        stackTrace,
      );
    } finally {
      try {
        await session.close();
      } catch (error, stackTrace) {
        logger.error(
          'RestoreFlow',
          '关闭恢复会话失败',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    }
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
  Future<void> _reconnectAfterApply(
    _RestoreApplySnapshot snapshot, {
    required Set<String> ledgerIds,
    required Set<String> dayBookIds,
    required bool syncAfter,
  }) async {
    try {
      _validateApplyIdentity(snapshot);
      final coordinator = ref.read(syncCoordinatorProvider);
      if (ledgerIds.isNotEmpty || dayBookIds.isNotEmpty) {
        await coordinator.reconnect(
          ledgerIds: ledgerIds,
          dayBookIds: dayBookIds,
        );
        _validateApplyIdentity(snapshot);
        ref.read(ledgerListRefreshProvider.notifier).tick();
      }
      if (syncAfter) await coordinator.run();
    } catch (e, st) {
      logger.error('RestoreFlow', '恢复后 Reconnect 失败', safeErrorSummary(e), st);
    }
  }
}

/// 恢复流程 provider（生产装配；测试 overrideWith 注入假服务）。
final backupRestoreFlowProvider =
    NotifierProvider<BackupRestoreFlowNotifier, BackupRestoreFlowState>(
      BackupRestoreFlowNotifier.new,
    );
