/// 备份恢复 4 步流程状态。
///
/// 设计意图：恢复流程的状态（当前步/备份列表/会话/决策/结果）集中在本
/// Notifier，页面只做渲染；服务经构造注入（测试 overrideWith 注入假实现，
/// 生产由默认装配）。Step 1–3 零写入，Step 4 单事务应用。
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

/// 恢复流程错误分类（UI 据此映射本地化文案）。
enum RestoreFlowError {
  /// 无错误
  none,

  /// 密码错误 / 文件损坏 / 解析失败
  openFailed,

  /// 备份 schema 旧于当前
  schemaTooOld,

  /// 备份 schema 新于当前
  schemaTooNew,
}

/// 恢复列表中的本地备份展示项。
class RestoreBackupFile {
  const RestoreBackupFile._({
    required this._source,
    required this.createdAt,
    required this.sizeLabel,
    required this.pathKey,
  });

  /// 外部 .snbak 文件（「从文件恢复」/「从云端恢复」兜底通道）构造入口。
  factory RestoreBackupFile.external(LocalBackupFile file) =>
      RestoreBackupFile._(
        source: file,
        createdAt: file.createdAt,
        sizeLabel: file.sizeLabel,
        pathKey: file.file.path,
      );

  final LocalBackupFile _source;
  final DateTime createdAt;
  final String sizeLabel;
  final String pathKey;
}

/// 单个账本的恢复预览展示项。
class RestoreLedgerItem {
  const RestoreLedgerItem({
    required this.ledgerBackupId,
    required this.name,
    required this.storageOrigin,
    this.accountId,
    this.accountName,
    required this.memberCount,
    required this.transactionCount,
    required this.pendingCount,
    required this.conflictCount,
  });

  final String ledgerBackupId;
  final String name;
  final LedgerStorageOrigin storageOrigin;
  final String? accountId;
  final String? accountName;
  final int memberCount;
  final int transactionCount;
  final int pendingCount;
  final int conflictCount;
}

/// 页面可选的恢复决策。
enum RestoreDecision { restoreLocal, forkCloudToLocal, reconnect, skip }

/// 单个账本的恢复结果展示项。
class RestoreApplyEntry {
  const RestoreApplyEntry({
    required this.name,
    required this.decision,
    required this.success,
    this.detail,
  });

  final String name;
  final RestoreDecision decision;
  final bool success;
  final String? detail;
}

/// 恢复结果展示报告。
class RestoreApplyReport {
  const RestoreApplyReport(this.entries);

  final List<RestoreApplyEntry> entries;
}

/// 恢复流程状态（不可变快照）。
class BackupRestoreFlowState {
  const BackupRestoreFlowState({
    this.step = 1,
    this.loading = false,
    this.error = RestoreFlowError.none,
    this.backups = const [],
    this.selected,
    this.session,
    this.items = const [],
    this.decisions = const {},
    this.report,
  });

  /// 当前步骤（1 选择备份 / 2 查看内容 / 3 选择策略 / 4 确认应用）。
  final int step;

  /// 是否忙（打开备份/应用恢复中）。
  final bool loading;

  /// 错误分类（Step 1–3 失败不影响 live DB）。
  final RestoreFlowError error;

  /// 本地备份列表。
  final List<RestoreBackupFile> backups;

  /// 当前选中的备份文件。
  final RestoreBackupFile? selected;

  /// 打开的只读恢复会话（Step 1 产物）。
  final RecoverySession? session;

  /// 备份内容预览条目（Step 2 产物）。
  final List<RestoreLedgerItem> items;

  /// 每账本恢复决策（Step 3；未决策 = skip）。
  final Map<String, RestoreDecision> decisions;

  /// Step 4 应用结果。
  final RestoreApplyReport? report;

  BackupRestoreFlowState copyWith({
    int? step,
    bool? loading,
    RestoreFlowError? error,
    List<RestoreBackupFile>? backups,
    RestoreBackupFile? selected,
    RecoverySession? session,
    List<RestoreLedgerItem>? items,
    Map<String, RestoreDecision>? decisions,
    RestoreApplyReport? report,
  }) {
    return BackupRestoreFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      backups: backups ?? this.backups,
      selected: selected ?? this.selected,
      session: session ?? this.session,
      items: items ?? this.items,
      decisions: decisions ?? this.decisions,
      report: report ?? this.report,
    );
  }
}

/// 恢复流程 Notifier：编排 4 步状态机。
class BackupRestoreFlowNotifier extends Notifier<BackupRestoreFlowState> {
  BackupRestoreFlowNotifier({
    LocalBackupService? backupService,
    BackupImportService? importService,
  }) : _backupService = backupService, // ignore: prefer_initializing_formals
       _importService = importService; // ignore: prefer_initializing_formals

  final LocalBackupService? _backupService;
  final BackupImportService? _importService;

  LocalBackupService get _backup => _backupService ?? LocalBackupService();
  BackupImportService get _import => _importService ?? BackupImportService();

  @override
  BackupRestoreFlowState build() => const BackupRestoreFlowState();

  /// Step 1：加载本地备份列表（只读）。
  ///
  /// [externalPath] 为备份目录之外的外部 .snbak 文件（「从文件恢复」选择的文件、
  /// 云端下载的最新备份），存在时插入列表头部并预选——用户只需输入密码即可打开。
  Future<void> loadBackups({String? externalPath}) async {
    state = state.copyWith(loading: true, error: RestoreFlowError.none);
    try {
      final backups = (await _backup.listBackups())
          .map(
            (file) => RestoreBackupFile._(
              source: file,
              createdAt: file.createdAt,
              sizeLabel: file.sizeLabel,
              pathKey: file.file.path,
            ),
          )
          .toList();
      RestoreBackupFile? preselected;
      if (externalPath != null) {
        final external = File(externalPath);
        if (await external.exists()) {
          final item = RestoreBackupFile.external(
            LocalBackupFile(
              file: external,
              createdAt: await external.lastModified(),
              sizeBytes: await external.length(),
            ),
          );
          backups.insert(0, item);
          preselected = item;
        }
      }
      state = state.copyWith(
        loading: false,
        backups: backups,
        selected: preselected,
      );
    } catch (e, st) {
      logger.error('RestoreFlow', '读取备份列表失败', e, st);
      state = state.copyWith(
        loading: false,
        error: RestoreFlowError.openFailed,
      );
    }
  }

  /// Step 1：点选备份（仅选中，不打开；打开由页面「打开所选备份」按钮触发）。
  void selectBackup(RestoreBackupFile file) {
    state = state.copyWith(selected: file, error: RestoreFlowError.none);
  }

  /// Step 1→2：打开备份（明文解帧 + Manifest 校验 + 预览），零写入。
  ///
  /// 备份无加密，任何设备可直接打开；打开失败即文件损坏或非备份文件。
  Future<void> openBackup({required RestoreBackupFile file}) async {
    state = state.copyWith(loading: true, error: RestoreFlowError.none);
    try {
      final db = ref.read(databaseProvider);
      final session = await _import.openBackup(
        backupFile: file._source.file,
        currentSchemaVersion: db.schemaVersion,
      );
      final items = (await _import.listRecoveryItems(session))
          .map(
            (item) => RestoreLedgerItem(
              ledgerBackupId: item.ledgerBackupId,
              name: item.name,
              storageOrigin: item.storageOrigin,
              accountId: item.accountReference?.accountId,
              accountName: item.accountReference?.accountName,
              memberCount: item.memberCount,
              transactionCount: item.transactionCount,
              pendingCount: item.pendingCount,
              conflictCount: item.conflictCount,
            ),
          )
          .toList(growable: false);
      state = state.copyWith(
        loading: false,
        selected: file,
        session: session,
        items: items,
        step: 2,
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

  /// Step 2→3：进入策略选择（内容已只读预览，无写入）。
  void proceedToStrategy() {
    state = state.copyWith(step: 3);
  }

  /// Step 3：设置单个账本的恢复决策（未决策 = skip）。
  void setDecision(String ledgerBackupId, RestoreDecision decision) {
    final decisions = Map<String, RestoreDecision>.from(state.decisions);
    decisions[ledgerBackupId] = decision;
    state = state.copyWith(decisions: decisions);
  }

  /// Step 3→4：进入确认页（映射预览，零写入）。
  ///
  /// 设计意图：Step 3 界面展示的默认决策（本地恢复 / 云端 Fork）必须在此
  /// 物化进决策表——否则用户看到"已选中"但 apply 时全部走 skip（显式决策
  /// 与 UI 默认值保持一致）。
  void proceedToConfirm() {
    final decisions = Map<String, RestoreDecision>.from(state.decisions);
    for (final item in state.items) {
      decisions.putIfAbsent(
        item.ledgerBackupId,
        () => item.storageOrigin == LedgerStorageOrigin.cloud
            ? RestoreDecision.forkCloudToLocal
            : RestoreDecision.restoreLocal,
      );
    }
    state = state.copyWith(decisions: decisions, step: 4);
  }

  /// Step 4：单事务应用恢复；成功后停留在完成态展示结果。
  Future<void> apply() async {
    final session = state.session;
    if (session == null) return;
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
      final rawReport = await _import.apply(
        session: session,
        liveDb: db,
        localSelfId: localSelfId,
        currentAccountId: currentAccountId,
      );
      final report = RestoreApplyReport(
        rawReport.entries
            .map(
              (entry) => RestoreApplyEntry(
                name: entry.name,
                decision: _toDisplayDecision(entry.decision),
                success: entry.success,
                detail: entry.detail,
              ),
            )
            .toList(growable: false),
      );
      state = state.copyWith(loading: false, report: report, step: 4);
    } catch (e, st) {
      logger.error('RestoreFlow', '应用恢复失败（已回滚）', e, st);
      state = state.copyWith(
        loading: false,
        error: RestoreFlowError.openFailed,
      );
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

  /// 把恢复引擎结果转换为页面决策。
  RestoreDecision _toDisplayDecision(RecoveryDecision decision) =>
      switch (decision) {
        RecoveryDecision.restoreLocal => RestoreDecision.restoreLocal,
        RecoveryDecision.forkCloudToLocal => RestoreDecision.forkCloudToLocal,
        RecoveryDecision.reconnect => RestoreDecision.reconnect,
        RecoveryDecision.skip => RestoreDecision.skip,
      };

  /// 返回上一步（2→1 时关闭会话，释放临时文件）。
  Future<void> back() async {
    if (state.step == 2) {
      final session = state.session;
      state = state.copyWith(
        step: 1,
        session: null,
        items: const [],
        decisions: const {},
        report: null,
      );
      if (session != null) {
        await session.close();
      }
      return;
    }
    state = state.copyWith(step: state.step - 1);
  }
}

/// 恢复流程 provider（生产装配；测试 overrideWith 注入假服务）。
final backupRestoreFlowProvider =
    NotifierProvider<BackupRestoreFlowNotifier, BackupRestoreFlowState>(
      BackupRestoreFlowNotifier.new,
    );
