library;

import 'backup_snapshot_processor.dart';

/// 本地备份服务：备份文件 = 明文分帧 .snbak（无加密）。
///
/// - .snbak = [u32 manifest 长度][u32 sqlite 长度][manifest JSON][SQLite 体]，
///   任何设备可直接打开恢复；
/// - 命名由微秒时间戳与独立快照身份组成；
/// - 保留最近 N 份（默认 30，可配置）；
/// - 独占创建文件，完整写盘后移除提交标记，恢复列表只展示已提交快照；
/// - 恢复流程读取隔离快照，并按用户选择导入业务数据。

import 'dart:io';
import 'package:flutter/foundation.dart' show compute;
import 'backup_file_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
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

  /// 正式备份命名中记录的创建顺序时间。
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

/// 本地备份服务：把数据库以 .snbak Envelope 快照形式备份到本地磁盘。
enum BackupTrigger { manual, automatic }

/// 一次确认只适用于私有隔离快照文件；确认期间不把整库常驻内存。
class PreparedBackup {
  final BackupManifest manifest;

  /// 准备快照时固定的唯一名称；确认等待和后续上传共用这一份身份。
  final String fileName;
  final File _sqlite;
  final String? _accountId;
  final int? _generation;
  final BackupTrigger trigger;
  final SesameDatabase _db;

  /// 确认回调只能读取快照清单与发布身份，文件生命周期由 createBackup 统一拥有。
  PreparedBackup._(
    this.manifest,
    this.fileName,
    this._sqlite,
    this._accountId,
    this._generation,
    this.trigger,
    this._db,
  );
}

class LocalBackupService {
  static final _activeBackupReaders = <String, int>{};

  /// 读取租约使用规范绝对路径，Windows 路径大小写差异不应分裂同一个快照身份。
  static String _backupReadKey(File file) => Platform.isWindows
      ? p.normalize(file.absolute.path).toLowerCase()
      : p.normalize(file.absolute.path);

  /// 在云端初始化及文件传输期间持有读取租约，保留清理暂时跳过这份不可变快照。
  static Future<T> withBackupFileRead<T>(
    File file,
    Future<T> Function() read,
  ) async {
    final key = _backupReadKey(file);
    _activeBackupReaders.update(key, (count) => count + 1, ifAbsent: () => 1);
    try {
      return await read();
    } finally {
      final remaining = _activeBackupReaders[key]! - 1;
      if (remaining == 0) {
        _activeBackupReaders.remove(key);
      } else {
        _activeBackupReaders[key] = remaining;
      }
    }
  }

  /// 统一释放本次创建的隔离目录，清理失败不覆盖原来的备份结果。
  static Future<void> _releaseSnapshot(File file) async {
    try {
      if (await file.parent.exists()) await file.parent.delete(recursive: true);
    } catch (error, stack) {
      logger.warning('LocalBackup', '清理隔离快照失败: ${error.runtimeType}', stack);
    }
  }

  /// 新一轮单飞备份开始前清理崩溃留下的隔离目录，不触碰其他目录。
  static Future<void> _pruneAbandonedSnapshots(Directory parent) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 1));
    await for (final entry in parent.list(followLinks: false)) {
      if (entry is! Directory ||
          !p.basename(entry.path).startsWith('backup-snapshot-')) {
        continue;
      }
      if ((await entry.stat()).modified.isBefore(cutoff)) {
        await _releaseSnapshot(File(p.join(entry.path, 'snapshot.sqlite')));
      }
    }
  }

  /// 注入备份目录、数据库路径与时钟，正式与隔离测试共用同一发布和保留逻辑。
  LocalBackupService({
    Directory? backupDir,
    File? databaseFile,
    this.maxBackups = defaultMaxBackups,
    this.accountIdGetter,
    this.sessionGenerationGetter,
    DateTime Function()? clock,
  }) : _backupDirOverride = backupDir,
       _dbFileOverride = databaseFile,
       _clock = clock ?? DateTime.now;

  final Directory? _backupDirOverride;
  final File? _dbFileOverride;
  final DateTime Function() _clock;

  /// 备份发布前复核当前会话，拒绝账号切换后迟到的快照。
  final String? Function()? accountIdGetter;
  final int Function()? sessionGenerationGetter;

  /// 正式备份保留份数（默认 30，可配置）。
  final int maxBackups;

  /// 默认保留最近 30 份正式备份，自动备份与手动备份共用此上限。
  static const int defaultMaxBackups = 30;

  /// 正式备份文件名前缀。
  static const String backupPrefix = 'sesame_notes_';

  /// 备份文件扩展名（冻结协议）。
  static const String backupExtension = '.snbak';

  /// SharedPreferences key：自动备份开关（默认 true，零干预兜底）
  static const String prefsKeyAutoBackup = 'auto_backup';

  /// SharedPreferences key：自动备份时同步上传到第三方云端（默认 true）
  static const String prefsKeyAutoSync = 'auto_sync';

  // 备份防重入锁：自动触发与手动点击并发时，后到者直接失败返回，
  // 避免两个复制任务交叉写同一目录。
  static bool _backupInProgress = false;

  /// 文件名的日期与秒级时间部分（YYYYMMDD_HHMMSS）。
  static String formatTimestamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }

  /// 单飞创建依据磁盘已提交快照恢复排序基线，UUID 保证独立身份且不覆盖已有文件。
  Future<String> _allocateBackupFileName() async {
    final files = await _listBackupFiles();
    final previous = files.isEmpty
        ? null
        : backupTimestamp(p.basename(files.first.path))!;
    final now = _clock();
    final createdAt = previous != null && !now.isAfter(previous)
        ? previous.add(const Duration(microseconds: 1))
        : now;
    final fraction = (createdAt.millisecond * 1000 + createdAt.microsecond)
        .toString()
        .padLeft(6, '0');
    return '$backupPrefix${formatTimestamp(createdAt)}_${fraction}_${const Uuid().v4()}$backupExtension';
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
    final dir =
        _backupDirOverride ??
        Directory(
          p.join((await getApplicationDocumentsDirectory()).path, 'backups'),
        );
    final type = await FileSystemEntity.type(dir.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return [];
    if (type != FileSystemEntityType.directory) {
      throw FileSystemException('备份读取路径不是目录', dir.path);
    }
    return [dir];
  }

  /// 列出应用正式命名的已提交快照，其他文件不参与展示或清理。
  Future<List<File>> _listBackupFiles() async {
    final dirs = await _candidateReadDirs();
    if (dirs.isEmpty) return [];
    final files = <File>[];
    await for (final entry in dirs.single.list(followLinks: false)) {
      if (entry is! File || backupTimestamp(p.basename(entry.path)) == null) {
        continue;
      } // 提交标记覆盖整个写盘窗口，进程中断遗留的半文件也不能进入恢复列表或保留清理。
      if (!await File('${entry.path}.pending').exists()) files.add(entry);
    }
    // 日期与时间定长，同秒内含微秒及快照身份的名称排在秒级名称之前。
    files.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return files;
  }

  /// 解析数据库主文件路径（与 db.dart 的 _openConnection 同一路径公式）。
  Future<File> databaseFile() async {
    if (_dbFileOverride != null) return _dbFileOverride;
    final docs = await getApplicationDocumentsDirectory();
    return File(p.join(docs.path, 'sesame_notes.sqlite'));
  }

  /// 执行一次备份：在线隔离快照 → 过滤与压缩 → 同源 Manifest →
  /// 明文分帧（无加密）→ 原子落盘 .snbak → prune 超量旧备份。
  ///
  /// 返回生成的备份文件。并发调用时后到者抛 [StateError]。
  Future<File> createBackup({
    required SesameDatabase db,
    String? deviceId,
    Map<String, String>? accountNames,

    /// 当前登录账号 id（null = 未登录）：导出快照只含本地域与当前账号域
    String? currentAccountId,
    BackupTrigger trigger = BackupTrigger.manual,
    Future<bool> Function(PreparedBackup)? confirm,
  }) async {
    if (_backupInProgress) {
      throw StateError('backup already in progress');
    }
    _backupInProgress = true;
    try {
      final prepared = await _prepareBackup(
        db: db,
        trigger: trigger,
        currentAccountId: currentAccountId,
        deviceId: deviceId,
        accountNames: accountNames,
      );
      try {
        return await _finalizeBackup(prepared, confirm: confirm);
      } finally {
        await _releaseSnapshot(prepared._sqlite);
      }
    } catch (error, stackTrace) {
      logger.error(
        'LocalBackup',
        '备份未完成，请重试',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    } finally {
      _backupInProgress = false;
    }
  }

  /// 准备独立快照，并在任何异步确认之前固定该快照的发布身份。
  Future<PreparedBackup> _prepareBackup({
    required SesameDatabase db,
    required BackupTrigger trigger,
    String? currentAccountId,
    String? deviceId,
    Map<String, String>? accountNames,
  }) async {
    final fileName = await _allocateBackupFileName();
    final generation = sessionGenerationGetter?.call();
    final account = accountIdGetter == null
        ? currentAccountId
        : accountIdGetter!();
    if (currentAccountId != null && currentAccountId != account) {
      throw StateError('BACKUP_SESSION_CHANGED');
    }
    _requireBackupSession(account, generation);
    await db.customSelect('SELECT 1').get();
    final (manifest, bytes) = await _accountScopedSnapshot(
      dbFile: await databaseFile(),
      currentAccountId: account,
      deviceId: deviceId,
      accountNames: accountNames,
    );
    try {
      _requireBackupSession(account, generation);
    } catch (_) {
      await _releaseSnapshot(bytes);
      rethrow;
    }
    return PreparedBackup._(
      manifest,
      fileName,
      bytes,
      account,
      generation,
      trigger,
      db,
    );
  }

  /// 核验快照仍由有效会话持有，并检查备忘录可见域没有变化。
  Future<void> _validatePrepared(PreparedBackup prepared) async {
    _requireBackupSession(prepared._accountId, prepared._generation);
    for (final source in prepared.manifest.memoBooks) {
      final row = await (prepared._db.select(
        prepared._db.memoBooks,
      )..where((b) => b.id.equals(source.id))).getSingleOrNull();
      if (row == null ||
          row.deletedAt != null ||
          row.isHidden != source.isHidden ||
          row.pendingLocalDelete != source.pendingLocalDelete ||
          (row.storageMode == 'cloud' &&
              row.scopeAccountId != prepared._accountId)) {
        throw StateError('MEMO_BACKUP_SCOPE_CHANGED');
      }
    }
    _requireBackupSession(prepared._accountId, prepared._generation);
  }

  /// 确认隔离快照并以正式备份命名发布，写入前后复核原会话。
  Future<File> _finalizeBackup(
    PreparedBackup prepared, {
    Future<bool> Function(PreparedBackup)? confirm,
  }) async {
    await _validatePrepared(prepared);
    if (prepared.trigger == BackupTrigger.manual &&
        prepared.manifest.memoCardCount > 0) {
      if (confirm == null || !await confirm(prepared)) {
        throw StateError('BACKUP_CANCELLED');
      }
      await _validatePrepared(prepared);
    }
    final payload = backupFileChunks(
      BackupManifestCodec.encodeJson(prepared.manifest),
      prepared._sqlite,
    );
    final dir = await backupDirectory();
    final target = File(p.join(dir.path, prepared.fileName));
    await _writeAtomic(
      target,
      payload,
      beforeCommit: () => _validatePrepared(prepared),
    );
    await pruneBackups();
    return target;
  }

  /// 会话 generation 也参与校验，同账号重新登录不能承接上一会话备份。
  void _requireBackupSession(String? accountId, int? generation) {
    if ((accountIdGetter != null && accountIdGetter!() != accountId) ||
        (sessionGenerationGetter != null &&
            sessionGenerationGetter!() != generation)) {
      throw StateError('账号已变化，请重新备份');
    }
  }

  /// 在线复制等待整个 stream 完成，WAL 中的已提交记录参与一致快照。
  Future<void> copyDatabaseSnapshot(File source, File destination) => compute(
    BackupSnapshotProcessor.copySnapshotFile,
    (source.path, destination.path),
  );

  /// 清单、统计和文件体共用已过滤及压缩的隔离快照；不修改实时数据库。
  Future<(BackupManifest, File)> _accountScopedSnapshot({
    required File dbFile,
    required String? currentAccountId,
    String? deviceId,
    Map<String, String>? accountNames,
  }) async {
    await _pruneAbandonedSnapshots(dbFile.parent);
    final tempDir = await dbFile.parent.createTemp('backup-snapshot-');
    final tmp = File(p.join(tempDir.path, 'snapshot.sqlite'));
    try {
      await copyDatabaseSnapshot(dbFile, tmp);
      final manifest =
          await compute(BackupSnapshotProcessor.finishSnapshotFile, (
            path: tmp.path,
            account: currentAccountId,
            deviceId: deviceId,
            accountNames: accountNames,
          ));
      return (manifest, tmp);
    } catch (_) {
      await _releaseSnapshot(tmp);
      rethrow;
    }
  }

  /// 枚举当前格式的已提交快照；读取失败向调用方明确传播。
  Future<List<LocalBackupFile>> listBackups() async {
    try {
      final files = await _listBackupFiles();
      return [
        for (final f in files)
          LocalBackupFile(
            file: f,
            createdAt: backupTimestamp(p.basename(f.path))!,
            sizeBytes: await f.length(),
          ),
      ];
    } catch (e, st) {
      logger.error('LocalBackup', '枚举备份列表失败', safeErrorSummary(e), st);
      rethrow;
    }
  }

  /// 清理超过保留上限的已提交快照，读取中的文件暂时保留。
  Future<void> pruneBackups() => _pruneFiles();

  /// 独占写入不可变快照，删除提交标记时才允许列表和保留策略看见文件。
  ///
  /// File.rename 会替换已有目标，不能承担备份的拒绝覆盖协议。
  /// 两个文件都使用 exclusive 创建，发生名称冲突时只清理本次确实持有的文件。
  Future<void> _writeAtomic(
    File target,
    Stream<List<int>> bytes, {
    required Future<void> Function() beforeCommit,
  }) async {
    final pending = File('${target.path}.pending');
    var ownsPending = false;
    var ownsTarget = false;
    try {
      await pending.create(exclusive: true);
      ownsPending = true;
      await target.create(exclusive: true);
      ownsTarget = true;
      final output = await target.open(mode: FileMode.writeOnly);
      try {
        await for (final chunk in bytes) {
          await output.writeFrom(chunk);
        }
        await output.flush();
      } finally {
        await output.close();
      }
      // 文件写盘与最终会话校验共同构成发布事务，校验通过前保持对列表和上传不可见。
      await beforeCommit();
      await pending.delete();
    } catch (_) {
      final targetRemoved =
          !ownsTarget || await _deleteOwnedPublicationFile(target);
      // 半文件若无法删除，保留提交标记隔离它，不能让清理错误把半文件变成可恢复快照。
      if (ownsPending && targetRemoved) {
        await _deleteOwnedPublicationFile(pending);
      }
      rethrow;
    }
  }

  /// 清理本次独占创建的文件，清理故障只记录日志并保留原始业务错误。
  Future<bool> _deleteOwnedPublicationFile(File file) async {
    try {
      if (await file.exists()) await file.delete();
      return true;
    } catch (error, stackTrace) {
      logger.warning(
        'LocalBackup',
        '清理未完成的备份失败: ${safeErrorSummary(error)}',
        stackTrace,
      );
      return false;
    }
  }

  /// 保留目录中最新的 maxBackups 份，清理故障不使已生成快照变为失败。
  Future<void> _pruneFiles() async {
    try {
      final files = await _listBackupFiles();
      if (files.length <= maxBackups) return;
      final retained = files.take(maxBackups).map(_backupReadKey).toSet();
      for (final old in files) {
        final key = _backupReadKey(old);
        // 在途读取可以暂时超过保留上限，租约释放后的下一次清理再收敛。
        if (retained.contains(key) || _activeBackupReaders.containsKey(key)) {
          continue;
        }
        try {
          await old.delete();
          logger.info('LocalBackup', '已清理旧备份: ${old.path}');
        } catch (e) {
          logger.warning(
            'LocalBackup',
            '删除旧备份失败: ${old.path}: ${safeErrorSummary(e)}',
          );
        }
      }
    } catch (e, st) {
      // 清理失败不阻断主流程（最坏结果是多占一点磁盘）
      logger.warning('LocalBackup', 'prune 备份失败: ${safeErrorSummary(e)}', st);
    }
  }

  /// 识别应用的秒级与微秒快照名称，其他文件不视为应用管理的备份。
  static DateTime? backupTimestamp(String fileName) {
    final match = RegExp(
      r'^sesame_notes_(\d{8})_(\d{6})(?:_(\d{6})_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})?\.snbak$',
    ).firstMatch(fileName);
    if (match == null) return null;
    final d = match.group(1)!;
    final t = match.group(2)!;
    // 秒级名称没有小数部分，创建时间精确到秒。
    final fractionText = match.group(3);
    final fraction = fractionText == null ? 0 : int.parse(fractionText);
    final timestamp = DateTime(
      int.parse(d.substring(0, 4)),
      int.parse(d.substring(4, 6)),
      int.parse(d.substring(6, 8)),
      int.parse(t.substring(0, 2)),
      int.parse(t.substring(2, 4)),
      int.parse(t.substring(4, 6)),
      fraction ~/ 1000,
      fraction % 1000,
    );
    // DateTime 会归一化越界日期与时间，边界解析不能把非法文件误认成应用快照。
    return formatTimestamp(timestamp) == '${d}_$t' ? timestamp : null;
  }
}
