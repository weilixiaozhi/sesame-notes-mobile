/// 本地备份服务：备份文件 = BackupEnvelope（.snbak）。
///
/// - 备份文件为冻结格式 .snbak：Envelope 头部明文，Manifest + SQLite 体同密
///   （无备份密码时用设备密钥加密，属"本机自动备份"场景，非唯一保护）；
/// - 命名 sesame_notes_ 加时间戳加 .snbak，时间戳字典序即时间序；
/// - 保留最近 N 份（默认 7，可配置）+ 紧急备份 3 份；
/// - 一切写盘走"临时文件 + rename"原子落盘；
/// - restoreFromBackup 是**整库覆盖原语**，输入为解密后的原始 .sqlite
///   （.snbak 解密由紧急通道/恢复流程负责，本类不感知密钥）。
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode, Database;

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/domain/backup_envelope.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

/// 单个本地备份文件信息（供恢复列表展示）。
class LocalBackupFile {
  const LocalBackupFile({
    required this.file,
    required this.createdAt,
    required this.sizeBytes,
  });

  /// 备份文件本体
  final File file;

  /// 备份创建时间（优先解析自文件名时间戳，失败回退文件修改时间）
  final DateTime createdAt;

  /// 文件大小（字节）
  final int sizeBytes;

  /// 文件名（含扩展名）
  String get fileName => p.basename(file.path);

  /// 人类可读大小（KB/MB），供列表副标题展示
  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  }
}

/// 恢复执行结果状态。
///
/// 设计意图：恢复是覆盖性不可逆操作，每种失败都对应独立的用户文案与善后策略
/// （紧急备份失败/文件损坏/版本过高均不触碰当前库），故用枚举而非 bool 返回。
enum RestoreStatus {
  /// 覆盖成功，调用方负责 invalidate databaseProvider 热重建
  success,

  /// 恢复前的紧急备份（回滚点）创建失败，已中止，当前库未动
  emergencyFailed,

  /// 备份文件损坏或不是合法 sqlite，已中止，当前库未动
  integrityFailed,

  /// 备份由更新版本应用创建（user_version 更高），已中止，当前库未动
  versionTooNew,

  /// 覆盖复制阶段失败（tmp 未 rename，原库完整）
  copyFailed,
}

/// 恢复执行结果。
class RestoreResult {
  const RestoreResult(this.status, {this.error});

  /// 结果状态
  final RestoreStatus status;

  /// 底层异常（仅记日志用，不向用户展示原始错误）
  final Object? error;

  /// 是否成功
  bool get success => status == RestoreStatus.success;
}

/// 本地备份服务：把数据库以 .snbak Envelope 快照形式备份到本地磁盘。
class LocalBackupService {
  LocalBackupService({
    Directory? backupDir,
    File? databaseFile,
    this.maxBackups = defaultMaxBackups,
  }) : _backupDirOverride = backupDir,
       _dbFileOverride = databaseFile;

  final Directory? _backupDirOverride;
  final File? _dbFileOverride;

  /// 正式备份保留份数（冻结默认 7，可配置）。
  final int maxBackups;

  /// 默认正式备份保留份数（协议冻结）。
  static const int defaultMaxBackups = 7;

  /// 紧急备份保留数量（恢复前的回滚点，独立保留、不进恢复列表）。
  static const int maxEmergencyBackups = 3;

  /// 正式备份文件名前缀（时间戳后接扩展名）。
  static const String backupPrefix = 'sesame_notes_';

  /// 紧急备份文件名前缀。
  static const String emergencyPrefix = 'sesame_notes_emergency_';

  /// 备份文件扩展名（冻结协议）。
  static const String backupExtension = '.snbak';

  /// SharedPreferences key：自动备份开关（默认 true，零干预兜底）
  static const String prefsKeyAutoBackup = 'auto_backup';

  /// SharedPreferences key：自动备份时同步上传到第三方云端（默认 true）
  static const String prefsKeyAutoSync = 'auto_sync';

  /// SharedPreferences key：上次备份日期（本地时区 YYYY-MM-DD，按天去重）
  static const String prefsKeyLastBackupDate = 'last_backup_date';

  // 防重入锁：备份/恢复各自单飞。自动触发与手动点击并发时，后到者直接失败返回，
  // 避免两个复制任务交叉写同一目录。
  static bool _backupInProgress = false;
  static bool _restoreInProgress = false;

  /// 今天日期串（本地时区 YYYY-MM-DD），按天去重的比较基准
  static String todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 文件名时间戳（YYYYMMDD_HHMMSS），字典序即时间序，天然支持排序与 prune
  static String formatTimestamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }

  /// 解析备份写入目录（应用文档目录/backups）。
  Future<Directory> backupDirectory() async {
    if (_backupDirOverride != null) {
      if (!await _backupDirOverride.exists()) {
        await _backupDirOverride.create(recursive: true);
      }
      return _backupDirOverride;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 返回当前应用的备份读取目录；目录不存在时返回空列表。
  Future<List<Directory>> _candidateReadDirs() async {
    if (_backupDirOverride != null) {
      return await _backupDirOverride.exists() ? [_backupDirOverride] : [];
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'backups'));
    return await dir.exists() ? [dir] : [];
  }

  /// 列出备份目录中匹配 [prefix] 的 .snbak 文件（按文件名时间戳倒序）。
  ///
  /// 设计意图：正式前缀 sesame_notes_ 是紧急前缀 sesame_notes_emergency_ 的前缀，
  /// 列举正式备份时必须显式排除紧急备份，否则恢复列表会混入系统回滚点。
  Future<List<File>> _listBackupFiles(String prefix) async {
    final dirs = await _candidateReadDirs();
    if (dirs.isEmpty) return [];
    final isEmergency = prefix == emergencyPrefix;
    final files = await dirs.single
        .list()
        .where(
          (entry) =>
              entry is File &&
              p.basename(entry.path).startsWith(prefix) &&
              (isEmergency ||
                  !p.basename(entry.path).startsWith(emergencyPrefix)) &&
              entry.path.endsWith(backupExtension),
        )
        .cast<File>()
        .toList();
    // 文件名时间戳字典序即时间序，倒序取最新在前
    files.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return files;
  }

  /// 解析数据库主文件路径（与 db.dart 的 _openConnection 同一路径公式）。
  Future<File> databaseFile() async {
    if (_dbFileOverride != null) return _dbFileOverride;
    final docs = await getApplicationDocumentsDirectory();
    return File(p.join(docs.path, 'sesame_notes.sqlite'));
  }

  /// 执行一次备份：checkpoint 合并 WAL → 构建 Manifest（实时统计）→
  /// 分帧加密成 Envelope → 原子落盘 .snbak → prune 超量旧备份。
  ///
  /// [filePrefix] 默认正式备份前缀；恢复流程传 [emergencyPrefix] 生成回滚点。
  /// [secrets] 为凭据集合（Multi-Key-Slot）：密码/恢复词/设备密钥任一
  /// 提供即可；自动备份路径由调用方装配（恢复词 + 设备密钥）。
  /// 返回生成的备份文件。并发调用时后到者抛 [StateError]。
  Future<File> createBackup({
    required SesameDatabase db,
    String filePrefix = backupPrefix,
    BackupSecrets? secrets,
    String? deviceId,
    String? appVersion,
    Map<String, String>? accountNames,

    /// 当前登录账号 id（null = 未登录）：导出快照只含本地域与当前账号域
    String? currentAccountId,
  }) async {
    if (_backupInProgress) {
      throw StateError('backup already in progress');
    }
    _backupInProgress = true;
    try {
      final creds = secrets ?? const BackupSecrets();
      if (!creds.hasAny) {
        throw ArgumentError('需要至少一个备份凭据（密码/恢复词/设备密钥）');
      }
      final dbFile = await databaseFile();
      final dir = await backupDirectory();

      // 把 WAL 合并进主库，使单文件复制即为完整数据。
      // 失败仅降级（快照略旧）不阻断——复制出的主库仍是合法库。
      try {
        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      } catch (e, st) {
        logger.warning('LocalBackup', 'wal_checkpoint 失败，继续复制（数据可能略旧）: $e', st);
      }

      // 构建 Manifest：账本分域 + 同步状态统计（仅展示与审计）。
      final manifest = await _buildManifest(
        db,
        deviceId: deviceId,
        appVersion: appVersion,
        accountNames: accountNames,
      );
      // 导出快照按账号域过滤：只含本地域（null scope）与当前账号域；
      // 其他账号数据在切换时已清理，这里对崩溃残留做防御性兜底
      final sqliteBytes = await _accountScopedSnapshotBytes(
        dbFile: dbFile,
        currentAccountId: currentAccountId,
      );
      final payload = BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(manifest),
        sqliteBytes,
      );
      final envelope = await BackupCrypto.createEnvelope(
        plaintextPayload: payload,
        password: creds.password,
        recoveryKey: creds.recoveryKey,
        deviceKey: creds.deviceKey,
      );

      final name =
          filePrefix + formatTimestamp(DateTime.now()) + backupExtension;
      final target = File(p.join(dir.path, name));
      await _writeAtomic(target, BackupEnvelopeCodec.encode(envelope));

      logger.info('LocalBackup', '备份完成: ${target.path}');
      await pruneBackups();
      return target;
    } finally {
      _backupInProgress = false;
    }
  }

  /// 生成账号域过滤后的备份快照字节：只含本地域（null scope）与当前账号域。
  ///
  /// 设计意图：.snbak 不携带其他账号数据（切换时已清理，此处是崩溃残留的
  /// 防御性兜底）。实现为「复制主库 → 在快照上删除非当前账号域的行 →
  /// 读取字节」，绝不触碰实时数据库；快照连接显式开启外键，级联子表一并清除。
  Future<Uint8List> _accountScopedSnapshotBytes({
    required File dbFile,
    required String? currentAccountId,
  }) async {
    final tmp = File('${dbFile.path}.account-scope.tmp');
    await dbFile.copy(tmp.path);
    try {
      final snapshot = sqlite3.open(tmp.path);
      try {
        // 快照连接默认外键关闭：显式开启才能级联清除交易/成员等子表
        snapshot.execute('PRAGMA foreign_keys = ON');
        final keepCurrent =
            currentAccountId != null && currentAccountId.isNotEmpty;
        if (keepCurrent) {
          // 冲突/拉取错误按账本级外键清理（先于账本删除执行）
          snapshot.execute(
            'DELETE FROM sync_conflicts WHERE ledger_id IN '
            '(SELECT id FROM ledgers WHERE scope_account_id IS NOT NULL AND scope_account_id != ?)',
            [currentAccountId],
          );
          snapshot.execute(
            'DELETE FROM sync_pull_errors WHERE ledger_id IN '
            '(SELECT id FROM ledgers WHERE scope_account_id IS NOT NULL AND scope_account_id != ?)',
            [currentAccountId],
          );
          snapshot.execute(
            'DELETE FROM sync_changes WHERE account_id IS NOT NULL AND account_id != ?',
            [currentAccountId],
          );
          snapshot.execute(
            'DELETE FROM ledgers WHERE scope_account_id IS NOT NULL AND scope_account_id != ?',
            [currentAccountId],
          );
          snapshot.execute(
            'DELETE FROM categories WHERE scope_account_id IS NOT NULL AND scope_account_id != ?',
            [currentAccountId],
          );
          snapshot.execute(
            'DELETE FROM exchange_rate_overrides WHERE scope_account_id IS NOT NULL AND scope_account_id != ?',
            [currentAccountId],
          );
        } else {
          // 未登录：只保留本地域数据
          snapshot.execute(
            'DELETE FROM sync_conflicts WHERE ledger_id IN '
            '(SELECT id FROM ledgers WHERE scope_account_id IS NOT NULL)',
          );
          snapshot.execute(
            'DELETE FROM sync_pull_errors WHERE ledger_id IN '
            '(SELECT id FROM ledgers WHERE scope_account_id IS NOT NULL)',
          );
          snapshot.execute(
            'DELETE FROM sync_changes WHERE account_id IS NOT NULL',
          );
          snapshot.execute(
            'DELETE FROM ledgers WHERE scope_account_id IS NOT NULL',
          );
          snapshot.execute(
            'DELETE FROM categories WHERE scope_account_id IS NOT NULL',
          );
          snapshot.execute(
            'DELETE FROM exchange_rate_overrides WHERE scope_account_id IS NOT NULL',
          );
        }
        return await tmp.readAsBytes();
      } finally {
        snapshot.close();
      }
    } finally {
      try {
        await tmp.delete();
      } catch (_) {
        // 临时快照清理失败不影响备份结果
      }
    }
  }

  /// 从实时数据库构建 Manifest（账本分域 + 同步状态统计）。
  ///
  /// 统计口径（仅展示与审计）：pending = 未推送 sync_changes 数；
  /// open_conflict = status=OPEN 冲突数；last_sync_at = 账本内最近一次业务更新时间。
  /// 不设 last_server_revision（账本无天然的'最后服务端修订号'）。
  Future<BackupManifest> _buildManifest(
    SesameDatabase db, {
    String? deviceId,
    String? appVersion,
    Map<String, String>? accountNames,
  }) async {
    final now = DateTime.now().toUtc();
    final ledgers = await (db.select(
      db.ledgers,
    )..where((l) => l.deletedAt.isNull())).get();
    final members = await (db.select(db.ledgerMembers)).get();

    final entries = <ManifestLedger>[];
    final accountIds = <String>{};
    for (final ledger in ledgers) {
      // 归属账号：云端账本取 owner 成员（role=owner 的 REGISTERED）的绑定账号
      final ledgerMembers = members
          .where((m) => m.ledgerId == ledger.id)
          .toList();
      final ownerMember = ledgerMembers
          .where(
            (m) =>
                m.role == 'owner' &&
                m.memberType == 'REGISTERED' &&
                m.linkedAccountId != null,
          )
          .firstOrNull;
      for (final m in ledgerMembers) {
        if (m.memberType == 'REGISTERED' && m.linkedAccountId != null) {
          accountIds.add(m.linkedAccountId!);
        }
      }
      final pendingCount =
          await (db.select(db.syncChanges)..where(
                (c) => c.ledgerId.equals(ledger.id) & c.pushedAt.isNull(),
              ))
              .get()
              .then((rows) => rows.length);
      final conflictCount =
          await (db.select(db.syncConflicts)..where(
                (c) => c.ledgerId.equals(ledger.id) & c.status.equals('OPEN'),
              ))
              .get()
              .then((rows) => rows.length);
      final isCloud = ledger.storageMode == 'cloud';
      entries.add(
        ManifestLedger(
          ledgerBackupId: ledger.id,
          name: ledger.name,
          storageOrigin: isCloud
              ? LedgerStorageOrigin.cloud
              : LedgerStorageOrigin.local,
          originalLocalLedgerId: isCloud ? null : ledger.id,
          cloudProvider: isCloud ? 'sesame_notes' : null,
          originalCloudLedgerId: isCloud ? ledger.id : null,
          originalAccountId: isCloud ? ownerMember?.linkedAccountId : null,
          ownerType:
              ledger.selfMemberId != null &&
                  ledgerMembers.any(
                    (m) => m.id == ledger.selfMemberId && m.role == 'owner',
                  )
              ? 'OWNER'
              : 'MEMBER',
          pendingMutationCount: pendingCount,
          openConflictCount: conflictCount,
          lastSyncAt: ledger.updatedAt,
        ),
      );
    }
    return BackupManifest(
      formatVersion: BackupEnvelopeConstants.formatVersion,
      dbSchemaVersion: db.schemaVersion,
      createdAt: now,
      deviceId: deviceId ?? '',
      appVersion: appVersion ?? '',
      ledgers: entries,
      accounts: [
        for (final id in accountIds)
          ManifestAccount(accountId: id, accountName: accountNames?[id] ?? ''),
      ],
    );
  }

  /// 枚举恢复列表：仅正式备份（[backupPrefix]），按时间戳倒序。
  ///
  /// 紧急备份（回滚点）刻意不展示——它是系统内部安全网，混进列表会让用户
  /// 分不清"我的快照"与"恢复前自动存的现场"。目录不可读时返回空列表。
  Future<List<LocalBackupFile>> listBackups() async {
    try {
      final files = await _listBackupFiles(backupPrefix);
      return [
        for (final f in files)
          LocalBackupFile(
            file: f,
            createdAt:
                _parseTimestamp(p.basename(f.path)) ?? await f.lastModified(),
            sizeBytes: await f.length(),
          ),
      ];
    } catch (e, st) {
      logger.error('LocalBackup', '枚举备份列表失败', e, st);
      return [];
    }
  }

  /// 清理超量旧备份：正式备份保留 [maxBackups] 个，紧急备份保留 [maxEmergencyBackups] 个。
  Future<void> pruneBackups() async {
    await _pruneByPrefix(backupPrefix, maxBackups);
    await _pruneByPrefix(emergencyPrefix, maxEmergencyBackups);
  }

  /// 从备份恢复（整库覆盖原语）：校验 → 紧急备份当前库 → 关闭连接 →
  /// 原子覆盖 → 清理 WAL 残留。
  ///
  /// 输入 [backupFile] 必须是**解密后的原始 .sqlite**（.snbak 的解密由
  /// 紧急通道/恢复流程负责，本原语不感知密钥）。
  /// 成功返回 [RestoreStatus.success] 后，**调用方负责 ref.invalidate(databaseProvider)**
  /// 触发级联热重建。所有失败路径都不破坏当前库。
  Future<RestoreResult> restoreFromBackup({
    required SesameDatabase db,
    required File backupFile,
    String? localSelfId,
  }) async {
    if (_restoreInProgress) {
      return const RestoreResult(
        RestoreStatus.copyFailed,
        error: 'restore already in progress',
      );
    }
    _restoreInProgress = true;
    try {
      // 1. 完整性 + 版本校验（独立于当前连接，失败零成本）
      final check = await validateBackup(backupFile, db.schemaVersion);
      if (check != null) return RestoreResult(check);

      // 2. 紧急备份当前库（回滚点）：恢复不可逆，先留"恢复前状态"才能在误操作时救回。
      //    失败则中止恢复——没有回滚点的覆盖操作对记账 App 不可接受。
      try {
        // 紧急备份（回滚点）：设备密钥兜底（本机可解）
        if (localSelfId == null || localSelfId.isEmpty) {
          throw StateError('紧急备份需要 localSelfId');
        }
        await createBackup(
          db: db,
          filePrefix: emergencyPrefix,
          secrets: BackupSecrets(
            deviceKey: BackupCrypto.deviceKeyFromLocalSelfId(localSelfId),
          ),
        );
      } catch (e, st) {
        logger.error('LocalBackup', '恢复前紧急备份失败，已中止恢复', e, st);
        return RestoreResult(RestoreStatus.emergencyFailed, error: e);
      }

      // 3. 关闭当前 Drift 连接释放文件锁（不关闭则覆盖会被系统拒绝）。
      try {
        await db.close();
      } catch (e, st) {
        logger.warning('LocalBackup', '关闭数据库连接异常（继续覆盖）: $e', st);
      }

      // 4. 原子覆盖主库 + 清理 WAL/SHM 残留。
      //    残留旧 WAL 会在下次打开时被错误拼回新库，造成数据错乱，必须删除。
      try {
        final dbFile = await databaseFile();
        await _copyAtomic(backupFile, dbFile);
        for (final suffix in ['-wal', '-shm']) {
          final f = File(dbFile.path + suffix);
          if (await f.exists()) await f.delete();
        }
      } catch (e, st) {
        logger.error('LocalBackup', '覆盖数据库文件失败', e, st);
        return RestoreResult(RestoreStatus.copyFailed, error: e);
      }

      logger.info('LocalBackup', '恢复完成: ${backupFile.path}');
      return const RestoreResult(RestoreStatus.success);
    } finally {
      _restoreInProgress = false;
    }
  }

  /// 紧急整库回滚通道（restoreWholeDatabaseForEmergency，**不进正常 UI**）。
  ///
  /// 仅开发/运维使用：解密 .snbak → 校验 → 整库覆盖原语 → 强制进入
  /// "未同步状态"：所有云端账本 sync_id 失效并标记
  /// STALE_BINDING，清除待推送队列/冲突/游标——绝不保留备份中的同步状态。
  ///
  /// [secrets] 为凭据集合（密码/恢复词/设备密钥任一即可解对应 key slot）。
  /// 成功返回 [RestoreStatus.success] 后，调用方负责 invalidate(databaseProvider)。
  Future<RestoreResult> restoreWholeDatabaseForEmergency({
    required SesameDatabase db,
    required File backupFile,
    required BackupSecrets secrets,
    required String localSelfId,
  }) async {
    // 1) 解密 .snbak 并提取 SQLite 备份体
    Uint8List sqliteBytes;
    try {
      final envelope = BackupEnvelopeCodec.decode(
        await backupFile.readAsBytes(),
      );
      final payload = await BackupCrypto.decryptEnvelopePayload(
        envelope: envelope,
        password: secrets.password,
        recoveryKey: secrets.recoveryKey,
        deviceKey: secrets.deviceKey,
      );
      sqliteBytes = BackupPayloadCodec.decode(payload).sqliteBytes;
    } on BackupFormatException catch (e, st) {
      logger.error('LocalBackup', '紧急恢复：备份解密失败', e, st);
      return RestoreResult(RestoreStatus.integrityFailed, error: e);
    } catch (e, st) {
      logger.error('LocalBackup', '紧急恢复：备份读取失败', e, st);
      return RestoreResult(RestoreStatus.integrityFailed, error: e);
    }

    // 2) 落到临时文件做完整性校验，再走整库覆盖原语
    final dir = await backupDirectory();
    final tmpSqlite = File(
      p.join(
        dir.path,
        '.emergency_${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    try {
      await tmpSqlite.writeAsBytes(sqliteBytes, flush: true);
      final check = await validateBackup(tmpSqlite, db.schemaVersion);
      if (check != null) return RestoreResult(check);
      final result = await restoreFromBackup(
        db: db,
        backupFile: tmpSqlite,
        localSelfId: localSelfId,
      );
      if (!result.success) return result;
      // 3) 覆盖成功：强制未同步状态（云端账本 sync_id 失效 + STALE_BINDING，
      //    清除 pending/conflict/cursor——备份里的同步状态绝不复活）
      try {
        await _neutralizeSyncStateAfterEmergencyRestore();
      } catch (e, st) {
        logger.error('LocalBackup', '紧急恢复后同步状态中和失败', e, st);
        return RestoreResult(RestoreStatus.emergencyFailed, error: e);
      }
      return result;
    } finally {
      if (await tmpSqlite.exists()) await tmpSqlite.delete();
    }
  }

  /// 紧急恢复后的同步状态中和：恢复会关闭原连接，这里重开连接后
  /// 把云端账本全部置为 STALE_BINDING（sync_id 清空），并清空同步基础设施。
  Future<void> _neutralizeSyncStateAfterEmergencyRestore() async {
    final dbFile = await databaseFile();
    final reopened = SesameDatabase.forTesting(NativeDatabase(dbFile));
    try {
      await reopened.transaction(() async {
        await (reopened.update(
          reopened.ledgers,
        )..where((l) => l.storageMode.equals('cloud'))).write(
          LedgersCompanion(
            syncId: const d.Value(null),
            bindingStatus: const d.Value('stale'),
          ),
        );
        await reopened.delete(reopened.syncChanges).go();
        await reopened.delete(reopened.syncConflicts).go();
        await reopened.delete(reopened.syncState).go();
      });
    } finally {
      await reopened.close();
    }
  }

  /// 校验原始 .sqlite 备份文件可用性：sqlite 完整性 + schema 版本不高于当前应用。
  ///
  /// 通过返回 null；失败返回对应 [RestoreStatus]。
  /// 用 sqlite3 包以**只读模式**直接执行 PRAGMA——避免在备份目录产生
  /// -wal/-shm 副作用文件，也绕开 drift 裸 executor 需内部接口才能打开的坑。
  Future<RestoreStatus?> validateBackup(
    File backupFile,
    int currentSchemaVersion,
  ) async {
    if (!await backupFile.exists()) return RestoreStatus.integrityFailed;
    Database? database;
    try {
      database = sqlite3.open(backupFile.path, mode: OpenMode.readOnly);
      // integrity_check 单行为 'ok' 才是完好库；损坏文件此处直接抛异常进 catch
      final rows = database.select('PRAGMA integrity_check');
      final ok =
          rows.length == 1 && rows.first.values.first?.toString() == 'ok';
      if (!ok) return RestoreStatus.integrityFailed;

      // 版本守卫：备份来自更新版本应用时 Drift 打开即炸（无向下迁移路径），提前拦截
      final versionRows = database.select('PRAGMA user_version');
      final version = (versionRows.first.values.first as int?) ?? 0;
      if (version > currentSchemaVersion) return RestoreStatus.versionTooNew;
      return null;
    } catch (e, st) {
      logger.error('LocalBackup', '备份文件校验失败', e, st);
      return RestoreStatus.integrityFailed;
    } finally {
      database?.close();
    }
  }

  /// 原子写入：先写同目录临时文件再 rename 落位（目标存在时旧文件先改名退避）。
  Future<void> _writeAtomic(File target, List<int> bytes) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (!await target.exists()) {
      await tmp.rename(target.path);
      return;
    }
    final backup = File('${target.path}.old');
    if (await backup.exists()) await backup.delete();
    await target.rename(backup.path);
    try {
      await tmp.rename(target.path);
    } catch (_) {
      // 新文件落位失败：把旧文件换回，绝不留下目标缺失窗口。
      await backup.rename(target.path);
      rethrow;
    }
    await backup.delete();
  }

  /// 原子复制：先写同目录临时文件，再通过「旧文件先改名退避」的方式落位。
  Future<void> _copyAtomic(File source, File target) async {
    final tmp = File('${target.path}.tmp');
    await source.copy(tmp.path);
    if (!await target.exists()) {
      await tmp.rename(target.path);
      return;
    }
    final backup = File('${target.path}.old');
    if (await backup.exists()) await backup.delete();
    await target.rename(backup.path);
    try {
      await tmp.rename(target.path);
    } catch (_) {
      await backup.rename(target.path);
      rethrow;
    }
    await backup.delete();
  }

  /// 按前缀清理超量备份文件（跨全部候选目录聚合后，全局保留最近 keep 个）
  Future<void> _pruneByPrefix(String prefix, int keep) async {
    try {
      final files = await _listBackupFiles(prefix);
      if (files.length <= keep) return;
      for (final old in files.skip(keep)) {
        try {
          await old.delete();
          logger.info('LocalBackup', '已清理旧备份: ${old.path}');
        } catch (e) {
          logger.warning('LocalBackup', '删除旧备份失败: ${old.path}: $e');
        }
      }
    } catch (e, st) {
      // 清理失败不阻断主流程（最坏结果是多占一点磁盘）
      logger.warning('LocalBackup', 'prune 备份失败: $e', st);
    }
  }

  /// 从文件名解析时间戳（sesame_notes_YYYYMMDD_HHMMSS.snbak），失败返回 null
  DateTime? _parseTimestamp(String fileName) {
    final match = RegExp(r'_(\d{8})_(\d{6})\.snbak$').firstMatch(fileName);
    if (match == null) return null;
    final d = match.group(1)!;
    final t = match.group(2)!;
    return DateTime(
      int.parse(d.substring(0, 4)),
      int.parse(d.substring(4, 6)),
      int.parse(d.substring(6, 8)),
      int.parse(t.substring(0, 2)),
      int.parse(t.substring(2, 4)),
      int.parse(t.substring(4, 6)),
    );
  }
}
