library;

import '../../../data/repositories/local/fitness_space_repository.dart';

/// 打开备份并建立只读预览会话，再按用户选择恢复账本、日子本、备忘录本和健身空间。
///
/// 预览阶段不写主库，提交前核对目标指纹和账号身份。各域仓储处理本机恢复、
/// 独立副本与云绑定，所有选中内容在同一事务中应用；任一步失败整体回滚。
/// 账本、日子本和备忘录本的恢复动作记录到本机审计表。

import 'backup_file_io.dart';
import 'backup_schema.dart';
import '../../../data/repositories/support/database_fingerprint.dart';

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_recovery_repository.dart';

/// 每个账本的恢复决策（勾选即恢复；无隐式 Merge）。
enum RecoveryDecision {
  /// 恢复为本地账本（原 identity；同 ID 的本地账本覆盖，同 ID 的云端账本 Fork）
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
  /// 组合备份身份与只读统计，供预览和实际恢复策略使用。
  const RecoveryItem({
    required this.ledgerBackupId,
    required this.name,
    required this.storageOrigin,
    required this.accountReference,
    required this.syncId,
    required this.currency,
    required this.expenseTotal,
    required this.memberCount,
    required this.transactionCount,
    required this.pendingCount,
    required this.conflictCount,
    this.archivedAt,
  });

  /// 源账本 id（备份内原始 ledger id，恢复读取与冲突判断均以此为准）。
  final String ledgerBackupId;

  /// 账本名（仅展示）。
  final String name;

  /// 备份中的个人归档时间，仅用于恢复预览标识。
  final DateTime? archivedAt;

  /// 备份时存储归属。
  final LedgerStorageOrigin storageOrigin;

  /// 归属账号引用（无凭据；LOCAL 为 null）。
  final ManifestAccount? accountReference;

  /// 备份时同步身份（仅展示/审计，绝不激活）。
  final String? syncId;

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
  const BackupApplyReport({
    required this.entries,
    this.dayBookResults = const {},
    this.memoBookResults = const {},
    this.fitnessSpaceResults = const {},
  });

  final List<BackupApplyEntry> entries;
  final Map<String, String> dayBookResults;
  final Map<String, String> memoBookResults;
  final Map<String, String> fitnessSpaceResults;
}

/// 生成的财务 SQL 只作映射；物理只读连接与禁止迁移双重保护源文件。
class _ReadOnlyBackupDatabase extends SesameDatabase {
  bool _closed = false;
  _ReadOnlyBackupDatabase(File file)
    : super.withExecutor(_connection(file.path));

  static d.QueryExecutor _connection(String path) => d.LazyDatabase(() async {
    final worker = await DriftIsolate.spawn(
      () => NativeDatabase.opened(
        sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly),
        enableMigrations: false,
      ),
    );
    try {
      return await worker.connect(singleClientMode: true);
    } catch (_) {
      await worker.shutdownAll();
      rethrow;
    }
  });

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await super.close();
  }

  /// 合法旧备份不经过主库初始化，也绝不补齐当前日子表。
  @override
  d.MigrationStrategy get migration => d.MigrationStrategy(
    onCreate: (_) async => throw StateError('备份不允许初始化'),
    onUpgrade: (_, _, _) async => throw StateError('备份不允许迁移'),
    beforeOpen: (_) async {},
  );
}

/// RecoverySession：内存态恢复隔离区。
///
/// 备份 SQLite 提取到独立临时文件，
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

  /// 已验证的 Manifest。
  final BackupManifest manifest;

  /// 提取后的 SQLite 备份体（临时文件，位于应用临时目录）。
  final File extractedSqliteFile;

  /// 备份体 drift 句柄（复制阶段读取源；schema 已校验一致，打开不迁移）。
  final SesameDatabase sourceDb;

  /// 只读预览仓库（零写入）。
  final BackupRecoveryRepository recoveryRepository;

  /// 每个账本的恢复决策（ledgerBackupId → 决策；未决策 = skip）。
  final Map<String, RecoveryDecision> decisions = {};

  /// 日子按本独立决策，与财务选择集合互不影响。
  final Map<String, RecoveryDecision> dayBookDecisions = {};

  /// 打开预览时的目标行快照；提交前变化必须重新展示覆盖决策。
  final Map<String, String> dayTargetSnapshots = {};
  final Map<String, RecoveryDecision> memoBookDecisions = {};
  final Map<String, String> memoTargetSnapshots = {};
  final Map<String, RecoveryDecision> fitnessSpaceDecisions = {};
  final Map<String, String> fitnessTargetSnapshots = {};
  Future<void>? _closing;

  /// 关闭会话：释放连接并清理临时文件。
  Future<void> close() => _closing ??= _close();

  /// 页面退出与容器释放共用同一次关闭，避免两个删除动作交错。
  Future<void> _close() async {
    try {
      await sourceDb.close();
    } catch (e) {
      logger.warning('Recovery', '关闭恢复源库异常: ${safeErrorSummary(e)}');
    }
    recoveryRepository.close();
    try {
      if (await extractedSqliteFile.exists()) {
        await extractedSqliteFile.delete();
      }
    } catch (e) {
      logger.warning('Recovery', '清理恢复临时文件失败: ${safeErrorSummary(e)}');
    }
  }
}

/// 备份导入服务：Inspector + Copier 两层职责的组合。
class BackupImportService {
  BackupImportService({Directory? tempDirOverride})
    : _tempDirOverride = tempDirOverride; // ignore: prefer_initializing_formals

  final Directory? _tempDirOverride;

  Future<Map<String, String>> captureMemoTargets(
    SesameDatabase db,
    Iterable<String> ids, {
    Future<void>? cancelled,
  }) => MemoExchange.fingerprintTargets(db, ids, cancelled: cancelled);

  /// 缺失本保留明确标记，其余内容仅保存一致读事务的摘要。
  Future<Map<String, String>> captureDayTargets(
    SesameDatabase db,
    Iterable<String> ids, {
    Future<void>? cancelled,
  }) {
    final selected = ids.toList(growable: false);
    return fingerprintGroups(
      db,
      {
        for (final id in selected)
          id: [
            FingerprintTable('day_books', 'id', id),
            FingerprintTable('day_events', 'day_book_id', id),
            FingerprintTable('day_import_receipts', 'target_day_book_id', id),
          ],
      },
      absentIfMissing: selected.toSet(),
      cancelled: cancelled,
    );
  }

  /// 打开备份：解析 .snbak 明文分帧，校验 Manifest 与当前 schema，
  /// 再把 SQLite 提取到临时隔离区构建只读 RecoverySession。
  ///
  /// 备份无加密，任何设备可直接打开；结构版本取当前应用的统一声明。
  Future<RecoverySession> openBackup({required File backupFile}) async {
    try {
      final framed = await readBackupFileFrame(backupFile);
      final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
      // 2) Manifest 格式版本校验（与 .snbak 协议一致）
      if (manifest.formatVersion != backupFormatVersion) {
        throw const BackupFormatException(
          BackupOpenError.invalidManifest,
          'Manifest 的 format_version 不受支持',
        );
      }
      // 版本边界先于提取，未知结构保留原文件并明确拒绝打开。
      if (!supportsBackupSchema(manifest.dbSchemaVersion)) {
        throw const BackupFormatException(
          BackupOpenError.unsupportedSchema,
          '备份结构版本不受支持，原文件未修改',
        );
      }

      // 提取 SQLite 到应用临时目录，预览和复制都不触碰 live 库文件。
      final tempDir = _tempDirOverride ?? await getTemporaryDirectory();
      final extracted = File(
        p.join(tempDir.path, 'recovery_${const Uuid().v4()}.sqlite'),
      );
      await extractBackupSqlite(backupFile, extracted, framed);

      BackupRecoveryRepository? recoveryRepository;
      try {
        // 只读校验业务类型后才建立恢复会话，外部文件必须符合当前数据规则。
        recoveryRepository = await BackupRecoveryRepository.openAndValidate(
          extracted.path,
          manifest,
        );
        var effectiveManifest = manifest;
        if (manifest.dbSchemaVersion != currentSchemaVersion) {
          // 来源清单与 SQLite 已核对；先关闭只读句柄，再仅升级本次提取副本。
          recoveryRepository.close();
          recoveryRepository = null;
          await upgradeExtractedBackupSchema(extracted);
          effectiveManifest = currentBackupManifest(manifest);
          recoveryRepository = await BackupRecoveryRepository.openAndValidate(
            extracted.path,
            effectiveManifest,
          );
        }
        final sourceDb = _ReadOnlyBackupDatabase(extracted);
        return RecoverySession(
          backupFile: backupFile,
          manifest: effectiveManifest,
          extractedSqliteFile: extracted,
          sourceDb: sourceDb,
          recoveryRepository: recoveryRepository,
        );
      } catch (error, stackTrace) {
        recoveryRepository?.close();
        try {
          await extracted.delete();
        } catch (cleanupError, cleanupStack) {
          logger.error(
            'BackupImport',
            '清理无效备份临时文件失败',
            safeErrorSummary(cleanupError),
            cleanupStack,
          );
        }
        if (error is FormatException) {
          logger.error(
            'BackupImport',
            '备份数据校验失败',
            safeErrorSummary(error),
            stackTrace,
          );
          throw BackupFormatException(BackupOpenError.corrupt, error.message);
        }
        rethrow;
      }
    } on BackupFormatException {
      rethrow;
    } catch (e, st) {
      logger.error('BackupImport', '打开备份失败', safeErrorSummary(e), st);
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
            archivedAt: row.archivedAt,
            storageOrigin: byId[row.id]!.storageOrigin,
            accountReference: accounts[byId[row.id]!.originalAccountId],
            syncId: row.syncId,
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
    void Function()? validateContext,
  }) async {
    final repo = LocalLedgerRepository(liveDb);
    final items = await listRecoveryItems(session);
    final backupName = p.basename(session.backupFile.path);
    final entries = <BackupApplyEntry>[];
    final dayBookResults = <String, String>{};
    final memoBookResults = <String, String>{};
    final fitnessSpaceResults = <String, String>{};

    try {
      await liveDb.transaction(() async {
        validateContext?.call();
        session.recoveryRepository.validateFitnessManifest(session.manifest);
        final fitnessRepo = FitnessSpaceRepository(
          liveDb,
          accountIdGetter: () => currentAccountId,
          changeRecorder: ChangeRecorderImpl(
            liveDb,
            accountIdGetter: () => currentAccountId,
          ),
        );
        for (final space in session.manifest.fitnessSpaces) {
          final decision =
              session.fitnessSpaceDecisions[space.id] ?? RecoveryDecision.skip;
          if (decision == RecoveryDecision.skip) continue;
          if (session.fitnessTargetSnapshots[space.id] !=
              await FitnessDataTransfer.fingerprint(liveDb, space.id)) {
            throw StateError('FITNESS_RESTORE_PREVIEW_CHANGED');
          }
          final id = await fitnessRepo.restoreSnapshot(
            book: session.recoveryRepository.fitnessSpace(space.id),
            records: session.recoveryRepository.listFitnessRecords(space.id),
            receipts: session.recoveryRepository.listFitnessReceipts(space.id),
            branches: session.recoveryRepository.listFitnessBranches(space.id),
            forceCopy: decision == RecoveryDecision.forkCloudToLocal,
            cloud: decision == RecoveryDecision.reconnect,
          );
          fitnessSpaceResults[space.id] = id;
          if (!space.fullyDownloaded) {
            await (liveDb.update(liveDb.fitnessSpaces)
                  ..where((b) => b.id.equals(id)))
                .write(const FitnessSpacesCompanion(isStale: d.Value(true)));
          }
        }
        final memoRepo = MemoRepository(
          liveDb,
          accountIdGetter: () => currentAccountId,
          changeRecorder: ChangeRecorderImpl(
            liveDb,
            accountIdGetter: () => currentAccountId,
          ),
        );
        for (final choice in session.memoBookDecisions.entries.where(
          (e) => e.value != RecoveryDecision.skip,
        )) {
          final preview = session.memoTargetSnapshots[choice.key];
          if (preview == null ||
              preview != await memoRepo.bookFingerprint(choice.key)) {
            throw StateError('MEMO_RESTORE_PREVIEW_CHANGED');
          }
        }
        final selectedDayIds = session.dayBookDecisions.entries
            .where((entry) => entry.value != RecoveryDecision.skip)
            .map((entry) => entry.key);
        final latestTargets = await captureDayTargets(liveDb, selectedDayIds);
        for (final entry in latestTargets.entries) {
          final preview = session.dayTargetSnapshots[entry.key];
          if (preview != null && preview != entry.value) {
            throw StateError('目标日子本在预览后已变化，请重新打开备份');
          }
        }
        for (final item in items) {
          final decision =
              session.decisions[item.ledgerBackupId] ?? RecoveryDecision.skip;
          switch (decision) {
            case RecoveryDecision.restoreLocal:
              // ID 冲突策略（按 ledger ID，不按名字）：
              // - live 库无该 ID → 原 identity 恢复；
              // - live 库已有该 ID 的本地账本 → 覆盖：备份快照替换现有
              //   数据（现有数据再新也以备份为准）；
              // - live 库已有该 ID 的云端账本 → Fork 兜底：云端时间线在
              //   服务器，覆盖会与同步身份脱节，生成独立本地副本。
              final exists =
                  await (liveDb.select(liveDb.ledgers)
                        ..where((l) => l.id.equals(item.ledgerBackupId)))
                      .getSingleOrNull();
              final overwrite = exists != null && exists.storageMode == 'local';
              final targetId = exists == null || overwrite
                  ? item.ledgerBackupId
                  : const Uuid().v4();
              await repo.restoreLocalLedger(
                sourceLedgerId: item.ledgerBackupId,
                targetLedgerId: targetId,
                localSelfId: localSelfId,
                originBackupId: backupName,
                sourceDb: session.sourceDb,
                currentAccountId: currentAccountId,
                overwrite: overwrite,
              );
              final conflictDetail = exists == null
                  ? ''
                  : (overwrite ? ' overwrite' : ' conflict_fork');
              await _writeLog(
                liveDb,
                sourceBackupName: backupName,
                targetLedgerId: targetId,
                action: 'restore_local',
                result: 'success',
                detail: 'source=${item.ledgerBackupId}$conflictDetail',
              );
              entries.add(
                BackupApplyEntry(
                  ledgerBackupId: item.ledgerBackupId,
                  name: item.name,
                  decision: decision,
                  targetLedgerId: targetId,
                  success: true,
                  detail: overwrite
                      ? 'overwrite'
                      : (exists != null ? 'conflict_fork' : null),
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
        final dayRepo = DayRepository(
          liveDb,
          validateAndProject: validateAndProject,
        );
        final dayBooks = session.recoveryRepository.listDayBooks();
        for (final book in dayBooks) {
          final decision =
              session.dayBookDecisions[book.id] ?? RecoveryDecision.skip;
          if (decision == RecoveryDecision.skip) continue;
          validateContext?.call();
          final sourceEvents = session.recoveryRepository.listDayEvents(
            book.id,
          );
          final sourceReceipts = session.recoveryRepository.listDayReceipts(
            book.id,
          );
          final current = await (liveDb.select(
            liveDb.dayBooks,
          )..where((row) => row.id.equals(book.id))).getSingleOrNull();
          if (decision == RecoveryDecision.reconnect) {
            if (!book.isCloud ||
                currentAccountId == null ||
                currentAccountId != book.scopeAccountId ||
                book.syncId == null) {
              throw StateError('云端来源账号或绑定无效，请重新预览');
            }
            if (current != null &&
                (current.storageMode != 'cloud' ||
                    current.scopeAccountId != currentAccountId ||
                    current.syncId != book.syncId ||
                    current.deletedAt != null ||
                    current.isStale)) {
              throw StateError('原日子本绑定已变化，请重新预览');
            }
            final info = session.manifest.dayBooks.singleWhere(
              (item) => item.dayBookId == book.id,
            );
            // 备份未确认分支先成为完整本机保护本，远端 full 才能以云端为准。
            if (info.pendingCount > 0 ||
                info.rejectedCount > 0 ||
                info.openConflictCount > 0 ||
                book.isHidden) {
              dayBookResults[book.id] = await dayRepo.restoreFromBackup(
                book: book,
                events: sourceEvents,
                receipts: sourceReceipts,
                forceCopy: true,
              );
            }
            if (current == null) {
              // 只建立经预览确认的原绑定占位，不注入备份记录、队列或消费游标。
              await liveDb
                  .into(liveDb.dayBooks)
                  .insert(
                    DayBooksCompanion.insert(
                      id: book.id,
                      name: book.name,
                      storageMode: const d.Value('cloud'),
                      scopeAccountId: d.Value(currentAccountId),
                      syncId: d.Value(book.syncId),
                      serverRevision: d.Value(book.serverRevision),
                      createdAt: book.createdAt,
                      updatedAt: book.updatedAt,
                    ),
                  );
            }
          } else {
            dayBookResults[book.id] = await dayRepo.restoreFromBackup(
              book: book,
              events: sourceEvents,
              receipts: sourceReceipts,
              // 运行中的隐藏副本由转换流程持有，备份内容使用独立身份保留。
              forceCopy:
                  decision == RecoveryDecision.forkCloudToLocal ||
                  current?.isHidden == true,
              // 备份中的操作中间态转为可检查的本机内容，不恢复旧云删除操作。
              hidden: false,
            );
          }
          await _writeLog(
            liveDb,
            sourceBackupName: backupName,
            targetLedgerId: null,
            action: 'restore_day_book',
            result: 'success',
            detail: 'source=${book.id};decision=${decision.name}',
          );
        }
        for (final book in session.recoveryRepository.listMemoBooks()) {
          final decision =
              session.memoBookDecisions[book.id] ?? RecoveryDecision.skip;
          if (decision == RecoveryDecision.skip) continue;
          validateContext?.call();
          memoBookResults[book.id] = await memoRepo.restoreSnapshot(
            book: book,
            entries: session.recoveryRepository.listMemoEntries(
              book.id,
              includeDeleted: true,
            ),
            receipts: session.recoveryRepository.listMemoReceipts(book.id),
            forceCopy: decision == RecoveryDecision.forkCloudToLocal,
            cloud: decision == RecoveryDecision.reconnect,
          );
          await _writeLog(
            liveDb,
            sourceBackupName: backupName,
            targetLedgerId: null,
            action: 'restore_memo_book',
            result: 'success',
            detail: 'source=${book.id};decision=${decision.name}',
          );
        }
        validateContext?.call();
      });
    } catch (e, st) {
      // 失败尝试在回滚后单独事务落盘（成功日志随主事务回滚消失）
      logger.error(
        'BackupImport',
        '应用恢复失败（已回滚），记录失败尝试',
        safeErrorSummary(e),
        st,
      );
      await recordFailedAttempt(
        liveDb: liveDb,
        sourceBackupName: backupName,
        detail: safeErrorSummary(e),
      );
      rethrow;
    }
    return BackupApplyReport(
      entries: entries,
      dayBookResults: dayBookResults,
      memoBookResults: memoBookResults,
      fitnessSpaceResults: fitnessSpaceResults,
    );
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
      logger.warning(
        'BackupImport',
        '失败尝试日志写入失败（不影响主流程）: ${safeErrorSummary(e)}',
        st,
      );
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
