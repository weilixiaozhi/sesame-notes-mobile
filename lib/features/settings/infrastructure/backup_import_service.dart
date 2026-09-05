/// BackupImportService（Backup Inspector + Ledger Copier）与 RecoverySession。
///
/// - **Inspector**：openBackup → validate → readManifest → listRecoveryItems，
///   全程零写入（打开与勾选阶段不触碰 live DB）；
/// - **Copier**：用户决策后按策略复制账本——importLocalLedger（本地：ID 冲突
///   Fork / 无冲突原 identity）、forkCloudLedgerToLocal（永远
///   Fork）、reconnect（登录原账号下载云端最新，不复制数据）、
///   skip（无隐式 Merge）；
/// - **应用**：单事务写入，任一步失败整体回滚，live DB 不变；
/// - 每次恢复写入 recovery_log（审计，不依赖云端）。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_recovery_repository.dart';

/// 每个账本的恢复决策（勾选即恢复；无隐式 Merge）。
enum RecoveryDecision {
  /// 恢复为本地账本（原 identity；ID 冲突时 Fork 新 ID）
  restoreLocal,

  /// 云端账本转本地独立副本（永远 Fork）
  forkCloudToLocal,

  /// 登录原账号获取云端最新（Reconnect v1，不复制备份数据）
  reconnect,

  /// 暂不处理（跳过，零写入）
  skip,
}

/// 恢复预览条目（listRecoveryItems 产出）。
class RecoveryItem {
  const RecoveryItem({
    required this.ledgerBackupId,
    required this.name,
    required this.storageOrigin,
    required this.accountReference,
    required this.syncId,
    required this.ownerType,
    required this.currency,
    required this.expenseTotal,
    required this.memberCount,
    required this.transactionCount,
    required this.pendingCount,
    required this.conflictCount,
  });

  /// 源账本 id（备份内原始 ledger id，恢复读取与冲突判断均以此为准）。
  final String ledgerBackupId;

  /// 账本名（仅展示）。
  final String name;

  /// 备份时存储归属。
  final LedgerStorageOrigin storageOrigin;

  /// 归属账号引用（无凭据；LOCAL 为 null）。
  final ManifestAccount? accountReference;

  /// 备份时同步身份（仅展示/审计，绝不激活）。
  final String? syncId;

  /// 归属类型（OWNER / MEMBER）。
  final String ownerType;

  /// 账本本位币（ISO 大写），与账本管理页卡片同口径展示。
  final String currency;

  /// 账本累计支出总额（备份时快照），与账本管理页卡片同口径。
  final double expenseTotal;

  /// 备份时成员数。
  final int memberCount;

  /// 备份时交易数。
  final int transactionCount;

  /// 备份时未推送 mutation 数（Manifest 统计，仅审计）。
  final int pendingCount;

  /// 备份时 OPEN 冲突数（仅警告展示）。
  final int conflictCount;
}

/// 单条恢复结果（含审计字段）。
class BackupApplyEntry {
  const BackupApplyEntry({
    required this.ledgerBackupId,
    required this.name,
    required this.decision,
    required this.targetLedgerId,
    required this.success,
    this.detail,
  });

  final String ledgerBackupId;
  final String name;
  final RecoveryDecision decision;

  /// 目标账本 id（skip/reconnect 为 null）。
  final String? targetLedgerId;
  final bool success;
  final String? detail;
}

/// 恢复应用结果报告（完成态展示）。
class BackupApplyReport {
  const BackupApplyReport({required this.entries});

  final List<BackupApplyEntry> entries;
}

/// RecoverySession：内存态恢复隔离区。
///
/// 设计意图：恢复不直接操作当前 DB——备份 sqlite 解密后落到临时文件，
/// 预览经只读仓库（零写入），复制阶段读取临时文件的 drift 句柄；
/// 用户点击"应用"后才由 BackupImportService.apply 在单事务内写 live DB。
class RecoverySession {
  RecoverySession({
    required this.backupFile,
    required this.manifest,
    required this.extractedSqliteFile,
    required this.sourceDb,
    required this.recoveryRepository,
  });

  /// 原始 .snbak 文件。
  final File backupFile;

  /// 解密后的 Manifest。
  final BackupManifest manifest;

  /// 解密后的 SQLite 备份体（临时文件，位于应用临时目录）。
  final File extractedSqliteFile;

  /// 备份体 drift 句柄（复制阶段读取源；schema 已校验一致，打开不迁移）。
  final SesameDatabase sourceDb;

  /// 只读预览仓库（零写入）。
  final BackupRecoveryRepository recoveryRepository;

  /// 每个账本的恢复决策（ledgerBackupId → 决策；未决策 = skip）。
  final Map<String, RecoveryDecision> decisions = {};

  /// 关闭会话：释放连接并清理临时文件。
  Future<void> close() async {
    try {
      await sourceDb.close();
    } catch (e) {
      logger.warning('Recovery', '关闭恢复源库异常: $e');
    }
    recoveryRepository.close();
    try {
      if (await extractedSqliteFile.exists()) {
        await extractedSqliteFile.delete();
      }
    } catch (e) {
      logger.warning('Recovery', '清理恢复临时文件失败: $e');
    }
  }
}

/// 备份导入服务：Inspector + Copier 两层职责的组合。
class BackupImportService {
  BackupImportService({Directory? tempDirOverride})
    : _tempDirOverride = tempDirOverride; // ignore: prefer_initializing_formals

  final Directory? _tempDirOverride;

  /// 打开备份：解析 .snbak 明文分帧，校验 Manifest 与当前 schema，
  /// 再把 SQLite 提取到临时隔离区构建只读 RecoverySession。
  ///
  /// 备份无加密，任何设备可直接打开；[currentSchemaVersion] 为当前应用
  /// db schema 版本。
  Future<RecoverySession> openBackup({
    required File backupFile,
    required int currentSchemaVersion,
  }) async {
    try {
      final bytes = await backupFile.readAsBytes();
      // 1) 明文分帧还原 Manifest + SQLite 体
      final framed = BackupPayloadCodec.decode(bytes);
      final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
      // 2) Manifest 格式版本校验（与 .snbak 协议一致）
      if (manifest.formatVersion != backupFormatVersion) {
        throw const BackupFormatException(
          BackupOpenError.invalidManifest,
          'Manifest 的 format_version 不受支持',
        );
      }
      // 3) schema 版本校验：版本不一致直接拒绝，避免未验证的迁移分支。
      if (manifest.dbSchemaVersion > currentSchemaVersion) {
        throw const BackupFormatException(
          BackupOpenError.schemaTooNew,
          '备份由更新版本应用创建，请先升级应用',
        );
      }
      if (manifest.dbSchemaVersion < currentSchemaVersion) {
        throw const BackupFormatException(
          BackupOpenError.schemaTooOld,
          '备份数据库版本过旧，请使用当前版本重新备份',
        );
      }

      // 提取 SQLite 到应用临时目录，预览和复制都不触碰 live 库文件。
      final tempDir = _tempDirOverride ?? await getTemporaryDirectory();
      final extracted = File(
        p.join(tempDir.path, 'recovery_${const Uuid().v4()}.sqlite'),
      );
      await extracted.writeAsBytes(framed.sqliteBytes, flush: true);

      // schema 已精确匹配，打开源句柄不会触发升级写入。
      final recoveryRepository = BackupRecoveryRepository.open(extracted.path);
      final sourceDb = SesameDatabase.forTesting(NativeDatabase(extracted));
      return RecoverySession(
        backupFile: backupFile,
        manifest: manifest,
        extractedSqliteFile: extracted,
        sourceDb: sourceDb,
        recoveryRepository: recoveryRepository,
      );
    } on BackupFormatException {
      rethrow;
    } catch (e, st) {
      logger.error('BackupImport', '打开备份失败', e, st);
      throw const BackupFormatException(BackupOpenError.corrupt, '备份文件无法解析');
    }
  }

  /// 产出恢复预览条目：Manifest 账本清单 + 只读仓库的成员/交易/支出统计。
  ///
  /// 全程零写入。统计字段仅展示与警告。
  Future<List<RecoveryItem>> listRecoveryItems(RecoverySession session) async {
    final accounts = {
      for (final a in session.manifest.accounts) a.accountId: a,
    };
    final rows = session.recoveryRepository.listLedgers();
    final byId = {
      for (final l in session.manifest.ledgers) l.ledgerBackupId: l,
    };
    return [
      for (final row in rows)
        if (byId.containsKey(row.id))
          RecoveryItem(
            ledgerBackupId: row.id,
            name: row.name,
            storageOrigin: byId[row.id]!.storageOrigin,
            // 归属账号溯源：manifest 优先；旧备份 manifest 缺 original_account_id
            // 时回退读账本行的 scope_account_id（快照经账号域过滤，兜底可信）。
            accountReference: byId[row.id]!.originalAccountId == null
                ? (row.scopeAccountId == null
                      ? null
                      : accounts[row.scopeAccountId])
                : accounts[byId[row.id]!.originalAccountId],
            syncId: row.syncId,
            ownerType: byId[row.id]!.ownerType,
            currency: row.currency,
            expenseTotal: session.recoveryRepository.sumLedgerExpense(row.id),
            memberCount: session.recoveryRepository.countMembers(row.id),
            transactionCount: session.recoveryRepository.countTransactions(
              row.id,
            ),
            pendingCount: byId[row.id]!.pendingMutationCount,
            conflictCount: byId[row.id]!.openConflictCount,
          ),
    ];
  }

  /// 应用恢复：按每账本决策在**单个事务**内写入 live DB；
  /// 任一步失败 → 整体回滚，live DB 不变。
  ///
  /// 每次恢复写入 recovery_log（时间/来源备份/目标账本/动作/结果，审计）。
  Future<BackupApplyReport> apply({
    required RecoverySession session,
    required SesameDatabase liveDb,
    required String localSelfId,
    String? currentAccountId,
  }) async {
    final repo = LocalLedgerRepository(liveDb);
    final items = await listRecoveryItems(session);
    final backupName = p.basename(session.backupFile.path);
    final entries = <BackupApplyEntry>[];

    try {
      await liveDb.transaction(() async {
        for (final item in items) {
          final decision =
              session.decisions[item.ledgerBackupId] ?? RecoveryDecision.skip;
          switch (decision) {
            case RecoveryDecision.restoreLocal:
              // ID 冲突策略（按 ledger ID，不按名字）：
              // live 库已存在该 ID → Fork 新 ID；不存在 → 原 identity 恢复
              final exists =
                  await (liveDb.select(liveDb.ledgers)
                        ..where((l) => l.id.equals(item.ledgerBackupId)))
                      .getSingleOrNull();
              final targetId = exists != null
                  ? const Uuid().v4()
                  : item.ledgerBackupId;
              await repo.restoreLocalLedger(
                sourceLedgerId: item.ledgerBackupId,
                targetLedgerId: targetId,
                localSelfId: localSelfId,
                originBackupId: backupName,
                sourceDb: session.sourceDb,
                currentAccountId: currentAccountId,
              );
              await _writeLog(
                liveDb,
                sourceBackupName: backupName,
                targetLedgerId: targetId,
                action: 'restore_local',
                result: 'success',
                detail:
                    'source=${item.ledgerBackupId}${exists != null ? ' conflict_fork' : ''}',
              );
              entries.add(
                BackupApplyEntry(
                  ledgerBackupId: item.ledgerBackupId,
                  name: item.name,
                  decision: decision,
                  targetLedgerId: targetId,
                  success: true,
                  detail: exists != null ? 'conflict_fork' : null,
                ),
              );
            case RecoveryDecision.forkCloudToLocal:
              // 云端账本永远 Fork：新 ledger_id + 同步身份全清 +
              // origin 溯源，同步状态不恢复。
              final newId = const Uuid().v4();
              await repo.forkCloudLedgerToLocal(
                sourceLedgerId: item.ledgerBackupId,
                newLedgerId: newId,
                localSelfId: localSelfId,
                originBackupId: backupName,
                originAccountId: item.accountReference?.accountId,
                originSyncId: item.syncId,
                sourceDb: session.sourceDb,
                currentAccountId: currentAccountId,
              );
              await _writeLog(
                liveDb,
                sourceBackupName: backupName,
                targetLedgerId: newId,
                action: 'fork_cloud_to_local',
                result: 'success',
                detail: 'source=${item.ledgerBackupId}',
              );
              entries.add(
                BackupApplyEntry(
                  ledgerBackupId: item.ledgerBackupId,
                  name: item.name,
                  decision: decision,
                  targetLedgerId: newId,
                  success: true,
                ),
              );
            case RecoveryDecision.reconnect:
              // Reconnect v1：登录原账号 → 下载云端最新；备份内容不复制。
              // 审计记录动作；数据恢复由同步引擎完成。
              await _writeLog(
                liveDb,
                sourceBackupName: backupName,
                targetLedgerId: null,
                action: 'reconnect',
                result: 'success',
                detail: 'account=${item.accountReference?.accountId ?? ''}',
              );
              entries.add(
                BackupApplyEntry(
                  ledgerBackupId: item.ledgerBackupId,
                  name: item.name,
                  decision: decision,
                  targetLedgerId: null,
                  success: true,
                ),
              );
            case RecoveryDecision.skip:
              await _writeLog(
                liveDb,
                sourceBackupName: backupName,
                targetLedgerId: null,
                action: 'skip',
                result: 'success',
                detail: null,
              );
              entries.add(
                BackupApplyEntry(
                  ledgerBackupId: item.ledgerBackupId,
                  name: item.name,
                  decision: decision,
                  targetLedgerId: null,
                  success: true,
                ),
              );
          }
        }
      });
    } catch (e, st) {
      // 失败尝试在回滚后单独事务落盘（成功日志随主事务回滚消失）
      logger.error('BackupImport', '应用恢复失败（已回滚），记录失败尝试', e, st);
      await recordFailedAttempt(
        liveDb: liveDb,
        sourceBackupName: backupName,
        detail: e.toString(),
      );
      rethrow;
    }
    return BackupApplyReport(entries: entries);
  }

  /// 记录一次失败的恢复尝试（主事务回滚后单独事务写入）。
  ///
  /// 设计意图：成功记录写在应用事务内（回滚即一并消失，不产生虚假成功）；
  /// 失败记录必须在回滚**之后**用独立事务落盘，否则失败也无从审计。
  Future<void> recordFailedAttempt({
    required SesameDatabase liveDb,
    required String sourceBackupName,
    required String detail,
  }) async {
    try {
      await liveDb
          .into(liveDb.recoveryLogs)
          .insert(
            RecoveryLogsCompanion.insert(
              sourceBackupName: sourceBackupName,
              action: 'apply_failed',
              result: 'failed',
              detail: d.Value(detail),
            ),
          );
    } catch (e, st) {
      logger.warning('BackupImport', '失败尝试日志写入失败（不影响主流程）: $e', st);
    }
  }

  /// 写恢复审计日志（在应用事务内，回滚时日志一并回滚——不产生虚假记录）。
  Future<void> _writeLog(
    SesameDatabase db, {
    required String sourceBackupName,
    required String? targetLedgerId,
    required String action,
    required String result,
    String? detail,
  }) async {
    await db
        .into(db.recoveryLogs)
        .insert(
          RecoveryLogsCompanion.insert(
            sourceBackupName: sourceBackupName,
            targetLedgerId: d.Value(targetLedgerId),
            action: action,
            result: result,
            detail: d.Value(detail),
          ),
        );
  }
}
