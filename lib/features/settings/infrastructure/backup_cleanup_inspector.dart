import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:crypto/crypto.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../domain/backup_cleanup.dart';
import '../domain/backup_manifest.dart';
import 'backup_file_io.dart';
import 'backup_import_service.dart';
import 'local_backup_service.dart';

/// 识别结果绑定原始文件摘要；云端解码只用于检查，不改变待删除的原始 key。
class BackupCleanupInspection {
  const BackupCleanupInspection(
    this.status,
    this.sha256,
    this.createdAt, {
    this.diagnostic,
    this.diagnosticStack,
  });
  final BackupCleanupStatus status;
  final String? sha256;
  final DateTime? createdAt;
  final String? diagnostic, diagnosticStack;
}

/// 管理页仅识别明确的应用格式，当前格式仍复用正式只读恢复校验。
class BackupCleanupInspector {
  BackupCleanupInspector({
    Future<void> Function(File file)? validateCurrent,
    DateTime Function()? clock,
  }) : _validateCurrent = validateCurrent ?? _validateCurrentBackup,
       _clock = clock ?? DateTime.now,
       _background = validateCurrent == null;

  final Future<void> Function(File file) _validateCurrent;
  final DateTime Function() _clock;
  final bool _background;
  static final _emergency = RegExp(
    r'^sesame_notes_emergency_(\d{8})_(\d{6})\.snbak$',
  );
  static final _rawEmergency = RegExp(
    r'^\.emergency_([1-9]\d{12,17})\.sqlite$',
  );

  /// 普通和紧急快照均校验日期，名称只提供排序线索，不代替内容校验。
  static DateTime? namedTime(String name) {
    final ordinary = LocalBackupService.backupTimestamp(name);
    if (ordinary != null) return ordinary;
    final emergency = _emergency.firstMatch(name);
    if (emergency != null) {
      return LocalBackupService.backupTimestamp(
        'sesame_notes_${emergency[1]}_${emergency[2]}.snbak',
      );
    }
    return null;
  }

  /// 历史写盘中间文件只接受已有应用快照名加精确后缀，不匹配任意 tmp/old。
  static bool isTemporaryArtifact(String name) =>
      (name.endsWith('.tmp') || name.endsWith('.old')) &&
      namedTime(name.substring(0, name.length - 4)) != null;

  /// 至少静置一天且有可信修改时间，才允许检查历史写盘残留的删除资格。
  bool temporaryReady(String name, DateTime? modified) =>
      !isTemporaryArtifact(name) ||
      modified != null &&
          !modified.isAfter(_clock().subtract(const Duration(days: 1)));

  /// 原始二进制与 Base64 文本都先有限读取头部，再按需流式处理完整文件。
  Future<BackupCleanupInspection> inspect(
    File raw, {
    required String fileName,
    required bool isLocal,
    required DateTime? modified,
  }) async {
    final result = _background
        ? await compute(_inspectWorker, (
            path: raw.path,
            name: fileName,
            local: isLocal,
            modified: modified,
            now: _clock(),
          ))
        : await _inspectFile(
            raw,
            fileName: fileName,
            isLocal: isLocal,
            modified: modified,
          );
    if (result.diagnostic != null) {
      // 文件工作器只返回安全诊断，持久日志留在有平台消息通道的主 isolate。
      logger.warning(
        'BackupCleanup',
        '文件内容无法识别，保留原件：${result.diagnostic}',
        result.diagnosticStack == null
            ? null
            : StackTrace.fromString(result.diagnosticStack!),
      );
    }
    return result;
  }

  /// 文件工作器只接收路径和标量，旧结构检查和当前只读验收都不阻塞界面。
  static Future<BackupCleanupInspection> _inspectWorker(
    ({String path, String name, bool local, DateTime? modified, DateTime now})
    input,
  ) =>
      BackupCleanupInspector(
        validateCurrent: _validateCurrentBackup,
        clock: () => input.now,
      )._inspectFile(
        File(input.path),
        fileName: input.name,
        isLocal: input.local,
        modified: input.modified,
      );

  /// 检查只操作调用方隔离副本，原始字节摘要与内容资格来自同一次读取。
  Future<BackupCleanupInspection> _inspectFile(
    File raw, {
    required String fileName,
    required bool isLocal,
    required DateTime? modified,
  }) async {
    Directory? decodedDirectory;
    try {
      if (!temporaryReady(fileName, modified)) {
        return const BackupCleanupInspection(
          BackupCleanupStatus.pending,
          null,
          null,
        );
      }
      if (await _isSidecar(raw, fileName)) {
        return BackupCleanupInspection(
          BackupCleanupStatus.auxiliary,
          await digest(raw),
          null,
        );
      }
      if (isLocal &&
          _rawEmergency.hasMatch(fileName) &&
          await _sqliteVersion(raw, 0) != null) {
        final version = (await _sqliteVersion(raw, 0))!;
        if (version < 1 || version >= currentSchemaVersion) {
          throw const FormatException('原始辅助副本版本不在已识别历史范围');
        }
        _validateApplicationSqlite(raw);
        return BackupCleanupInspection(
          BackupCleanupStatus.auxiliary,
          await digest(raw),
          null,
        );
      }
      var body = raw;
      final head = await _head(raw, 96);
      if (_looksBase64(head)) {
        decodedDirectory = await raw.parent.createTemp('cleanup-decode-');
        final decoded = File('${decodedDirectory.path}/decoded');
        await decoded.create(exclusive: true);
        final output = await decoded.open(mode: FileMode.writeOnly);
        try {
          await for (final chunk
              in raw
                  .openRead()
                  .transform(utf8.decoder)
                  .map((text) => text.replaceAll(RegExp(r'[\r\n\t ]'), ''))
                  .transform(base64.decoder)) {
            await output.writeFrom(chunk);
          }
          await output.flush();
        } finally {
          await output.close();
        }
        body = decoded;
      }
      final frame = await readBackupFileFrame(body);
      final json = jsonDecode(utf8.decode(frame.manifestJson));
      if (json is! Map ||
          json['format_version'] != backupFormatVersion ||
          json['db_schema_version'] is! int ||
          (json['db_schema_version'] as int) <= 0 ||
          json['device_id'] is! String ||
          json['ledgers'] is! List ||
          json['accounts'] is! List ||
          json['created_at'] is! String) {
        throw const FormatException('备份来源清单无法确认');
      }
      final created = DateTime.tryParse(json['created_at'] as String);
      final schema = json['db_schema_version'] as int;
      if (created == null ||
          schema > currentSchemaVersion ||
          frame.sqliteLength < 100 ||
          await _sqliteVersion(body, frame.sqliteOffset) != schema) {
        throw const FormatException('备份结构版本无法确认');
      }
      if (schema == currentSchemaVersion) {
        await _validateCurrent(body);
      } else {
        await _validateHistoricalSqlite(body, frame);
      }
      return BackupCleanupInspection(
        isLocal && isTemporaryArtifact(fileName)
            ? BackupCleanupStatus.auxiliary
            : schema == currentSchemaVersion
            ? BackupCleanupStatus.current
            : BackupCleanupStatus.unsupported,
        await digest(raw),
        created,
      );
    } catch (error, stack) {
      // 名称、后缀和静置时间均不能代替完整内容证明，识别失败一律保留原件。
      return BackupCleanupInspection(
        BackupCleanupStatus.unknown,
        null,
        null,
        diagnostic: safeErrorSummary(error),
        diagnosticStack: stack.toString(),
      );
    } finally {
      if (decodedDirectory != null) {
        await decodedDirectory.delete(recursive: true);
      }
    }
  }

  /// 摘要始终针对存储中的原始字节，文件大小不影响常驻内存。
  static Future<String> digest(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  /// 仅读取指定头部，不把大备份整体读入内存。
  static Future<Uint8List> _head(File file, int length) async {
    final input = await file.open();
    try {
      return await input.read(length);
    } finally {
      await input.close();
    }
  }

  /// SQLite 头部版本与清单一致才确认为应用备份，不执行任何数据库迁移。
  static Future<int?> _sqliteVersion(File file, int offset) async {
    final input = await file.open();
    try {
      await input.setPosition(offset);
      final header = await input.read(100);
      if (header.length != 100 ||
          latin1.decode(header.sublist(0, 16)) != 'SQLite format 3\x00') {
        return null;
      }
      return ByteData.sublistView(header).getUint32(60);
    } finally {
      await input.close();
    }
  }

  /// Base64 只作为存储载体识别，解码后的实际备份版本决定恢复资格。
  static bool _looksBase64(List<int> bytes) =>
      bytes.length >= 16 &&
      bytes.every(
        (byte) =>
            byte >= 65 && byte <= 90 ||
            byte >= 97 && byte <= 122 ||
            byte >= 48 && byte <= 57 ||
            const [43, 47, 61, 13, 10, 9, 32].contains(byte),
      );

  /// WebDAV 辅助文件必须同时匹配快照基名、应用元数据和合法写入时间。
  static Future<bool> _isSidecar(File file, String name) async {
    const suffix = '.metadata.json';
    if (!name.endsWith(suffix) ||
        namedTime(name.substring(0, name.length - suffix.length)) == null ||
        await file.length() > 64 * 1024) {
      return false;
    }
    try {
      final value = jsonDecode(await file.readAsString());
      return value is Map &&
          value['metadata'] is Map &&
          value['metadata']['app'] == 'sesame_notes' &&
          value['metadata']['format'] == 'snbak' &&
          value['metadata']['encoding'] == 'base64' &&
          value['updatedAt'] is String &&
          DateTime.tryParse(value['updatedAt'] as String) != null;
    } catch (_) {
      return false;
    }
  }

  /// 与正式恢复共用只读验收，关闭时清理提取副本，不接触活动数据库。
  static Future<void> _validateCurrentBackup(File file) async {
    final directory = await file.parent.createTemp('cleanup-current-');
    try {
      final session = await BackupImportService(
        tempDirOverride: directory,
      ).openBackup(backupFile: file);
      try {
        // 打开成功已经完成当前结构、清单和业务定义的校验。
      } finally {
        await session.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  }

  /// 历史内容只核实独立 SQLite 副本的完整性与应用表，不执行升级或恢复。
  static Future<void> _validateHistoricalSqlite(
    File source,
    BackupFileFrame frame,
  ) async {
    final directory = await source.parent.createTemp('cleanup-sqlite-');
    final extracted = File('${directory.path}/snapshot.sqlite');
    try {
      await extractBackupSqlite(source, extracted, frame);
      _validateApplicationSqlite(extracted);
    } finally {
      await directory.delete(recursive: true);
    }
  }

  /// 只读核实应用核心表和 SQLite 完整性，任意其他数据库都不能因文件名获得删除资格。
  static void _validateApplicationSqlite(File file) {
    final database = sqlite.sqlite3.open(
      file.path,
      mode: sqlite.OpenMode.readOnly,
    );
    try {
      final tables = database
          .select("SELECT name FROM sqlite_master WHERE type='table'")
          .map((row) => row['name'])
          .toSet();
      final check = database.select('PRAGMA quick_check');
      if (!tables.containsAll({'ledgers', 'transactions', 'categories'}) ||
          check.length != 1 ||
          check.single.values.single != 'ok') {
        throw const FormatException('历史文件内容无法确认为完整应用备份');
      }
    } finally {
      database.close();
    }
  }
}
