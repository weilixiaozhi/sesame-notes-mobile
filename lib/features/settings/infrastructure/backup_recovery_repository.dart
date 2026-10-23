library;

import 'package:sesame_notes/utils/text_validation.dart';

import '../../../data/models/private_book.dart';

/// 备份恢复只读仓库（RecoverySession 隔离区预览层）。
///
/// 设计意图：恢复预览（账本清单/币种/支出/成员数/交易数）必须**零写入**——用
/// sqlite3 包以只读模式直接查询备份 sqlite，不经过 drift（drift 打开连接会
/// 执行 PRAGMA/迁移等写路径，违背只读隔离区语义）。

import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;

import 'package:decimal/decimal.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode, Database;
import 'package:sesame_notes/data/models/expense_type.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import '../domain/backup_manifest.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/domain/fitness/fitness_recovery_branch.dart';

/// 校验备份业务表的当前类型约束；外部 SQLite 不能依赖本机建表时的 CHECK。
void validateExpenseOnlyBackup(Database database) {
  for (final (table, column) in [
    ('categories', 'kind'),
    ('shared_ledger_categories', 'kind'),
    ('transactions', 'tx_type'),
    ('recurring_transactions', 'tx_type'),
  ]) {
    final invalid = database.select(
      'SELECT $column AS type FROM $table '
      "WHERE $column IS NULL OR $column != 'expense' LIMIT 1",
    );
    if (invalid.isNotEmpty) requireExpenseType(invalid.first['type']);
  }
}

/// 备份库中的账本行（预览用）。
class BackupRecoveryLedgerRow {
  const BackupRecoveryLedgerRow({
    required this.id,
    required this.name,
    required this.storageMode,
    required this.syncId,
    required this.currency,
    required this.scopeAccountId,
    this.archivedAt,
  });

  /// 账本 id（备份时的原始 id）。
  final String id;

  /// 账本名。
  final String name;

  /// 存储归属（local / cloud）。
  final String storageMode;

  /// 备份时的同步身份（仅展示/审计，绝不激活）。
  final String? syncId;

  /// 账本本位币（ISO 大写）。
  final String currency;

  /// 账号数据域（null = 本地域）；manifest 缺归属账号时用它兜底溯源。
  final String? scopeAccountId;

  /// 备份中的个人归档时间，仅用于恢复预览标识。
  final DateTime? archivedAt;
}

/// 只读访问层：所有查询均为 SELECT，任何路径都不写备份文件。
class BackupRecoveryRepository {
  BackupRecoveryRepository._(this._db);

  /// 以只读模式打开备份 sqlite（损坏文件在此抛异常，由调用方转 corrupt）。
  factory BackupRecoveryRepository.open(String path) {
    final database = sqlite3.open(path, mode: OpenMode.readOnly);
    try {
      validateExpenseOnlyBackup(database);
      return BackupRecoveryRepository._(database);
    } catch (_) {
      database.close();
      rethrow;
    }
  }

  /// 大量内容校验在工作 isolate 执行，主界面只持有之后的只读预览连接。
  static Future<BackupRecoveryRepository> openAndValidate(
    String path,
    BackupManifest manifest,
  ) async {
    await compute(_validateFile, (path, manifest));
    return BackupRecoveryRepository._(
      sqlite3.open(path, mode: OpenMode.readOnly),
    );
  }

  static void _validateFile((String, BackupManifest) input) {
    final source = BackupRecoveryRepository.open(input.$1);
    try {
      source.validateDayManifest(input.$2);
      source.validateMemoManifest(input.$2);
      source.validateFitnessManifest(input.$2);
    } finally {
      source.close();
    }
  }

  final Database _db;

  /// 回调同步消费游标，成功或校验异常都会关闭语句，避免整表正文常驻。
  T _withRows<T>(
    String sql,
    List<Object?> parameters,
    T Function(Iterable<Map<String, Object?>>) read,
  ) {
    final statement = _db.prepare(sql);
    try {
      final cursor = statement.selectCursor(parameters);
      Iterable<Map<String, Object?>> rows() sync* {
        while (cursor.moveNext()) {
          yield Map<String, Object?>.from(cursor.current);
        }
      }

      return read(rows());
    } finally {
      statement.close();
    }
  }

  static FitnessTransferRecord _fitnessRecord(Map<String, Object?> row) =>
      FitnessTransferRecord(
        id: row['id'] as String,
        entityType: row['entity_type'] as String,
        fitnessSpaceId: row['fitness_space_id'] as String,
        payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        deletedAt: row['deleted_at'] == null
            ? null
            : _memoTime(row['deleted_at']),
      );
  List<FitnessTransferRecord> listFitnessRecords([
    String? fitnessSpaceId,
  ]) => _db
      .select(
        "SELECT * FROM fitness_entities ${fitnessSpaceId == null ? '' : 'WHERE fitness_space_id=?'} ORDER BY id",
        fitnessSpaceId == null ? [] : [fitnessSpaceId],
      )
      .map(_fitnessRecord)
      .toList();

  List<Map<String, Object?>> listFitnessReceipts(String fitnessSpaceId) => [
    for (final r in _db.select(
      'SELECT * FROM fitness_import_receipts WHERE fitness_space_id=?',
      [fitnessSpaceId],
    ))
      Map<String, Object?>.from(r),
  ];

  List<FitnessRecoveryBranch> listFitnessBranches([String? fitnessSpaceId]) {
    final result = <FitnessRecoveryBranch>[];
    _visitFitnessBranches((branch) {
      if (fitnessSpaceId == null || branch.fitnessSpaceId == fitnessSpaceId) {
        result.add(branch);
      }
    });
    return result;
  }

  void _visitFitnessBranches(void Function(FitnessRecoveryBranch) visit) {
    const changes =
        "entity_type LIKE 'fitness_%' AND entity_type<>'fitness_space' AND pushed_at IS NULL";
    const conflicts =
        "entity_type LIKE 'fitness_%' AND entity_type<>'fitness_space' AND (status='OPEN' OR (resolved_at IS NULL AND (local_mutation_id LIKE 'fitness-superseded:%' OR local_mutation_id LIKE 'fitness-recovery:%')))";
    final keys = <String>{};
    final ids = _db.select(
      'SELECT entity_id FROM sync_changes WHERE $changes UNION SELECT entity_id FROM sync_conflicts WHERE $conflicts',
    );
    for (final identity in ids) {
      final id = identity['entity_id'];
      final canonical = _db
          .select('SELECT * FROM fitness_entities WHERE id=?', [id])
          .map(_fitnessRecord)
          .toList();
      void emit(
        List<Map<String, Object?>> changeRows,
        List<Map<String, Object?>> conflictRows,
      ) {
        for (final branch in FitnessRecoveryBranch.fromRows(
          records: canonical,
          changes: changeRows,
          conflicts: conflictRows,
        )) {
          if (!keys.add(
            '${branch.fitnessSpaceId}:${branch.canonicalId}:${branch.operationId}',
          )) {
            throw const FormatException('duplicate fitness branch');
          }
          visit(branch);
        }
      }

      _withRows(
        'SELECT * FROM sync_changes WHERE entity_id=? AND $changes ORDER BY id',
        [id],
        (rows) {
          for (final row in rows) {
            emit([row], []);
          }
        },
      );
      _withRows(
        'SELECT * FROM sync_conflicts WHERE entity_id=? AND $conflicts ORDER BY id',
        [id],
        (rows) {
          for (final row in rows) {
            emit([], [row]);
          }
        },
      );
    }
  }

  /// 同一隔离快照生成数量与完整性标记；备份允许保存不完整缓存，但必须明示。
  FitnessSpace fitnessSpace(String id) {
    final row = _db.select('SELECT * FROM fitness_spaces WHERE id=?', [
      id,
    ]).single;
    return FitnessSpace(
      id: id,
      name: row['name'] as String,
      storageMode: row['storage_mode'] as String,
      scopeAccountId: row['scope_account_id'] as String?,
      sourceAccountId: row['source_account_id'] as String?,
      syncId: row['sync_id'] as String?,
      fullCursor: row['full_cursor'] as String?,
      serverRevision: row['server_revision'] as int?,
      createdAt: _memoTime(row['created_at']),
      updatedAt: _memoTime(row['updated_at']),
      deletedAt: row['deleted_at'] == null
          ? null
          : _memoTime(row['deleted_at']),
      isHidden: row['is_hidden'] == 1,
      isStale: row['is_stale'] == 1,
      pendingLocalDelete: row['pending_local_delete'] == 1,
    );
  }

  List<ManifestFitnessSpace> fitnessManifest() {
    final counts = <String, Map<String, int>>{},
        running = <String, int>{},
        branches = <String, int>{};
    for (final row in _db.select(
      'SELECT fitness_space_id,entity_type,count(*) AS n FROM fitness_entities GROUP BY fitness_space_id,entity_type',
    )) {
      (counts[row['fitness_space_id'] as String] ??=
              <String, int>{})[row['entity_type'] as String] =
          row['n'] as int;
    }
    for (final row in _db.select(
      "SELECT fitness_space_id,count(*) AS n FROM fitness_entities WHERE entity_type='fitness_workout' AND deleted_at IS NULL AND json_extract(payload,'\$.status')='in_progress' GROUP BY fitness_space_id",
    )) {
      running[row['fitness_space_id'] as String] = row['n'] as int;
    }
    _visitFitnessBranches(
      (branch) => branches.update(
        branch.fitnessSpaceId,
        (n) => n + 1,
        ifAbsent: () => 1,
      ),
    );
    return [
      for (final row in _db.select(
        'SELECT id FROM fitness_spaces WHERE deleted_at IS NULL ORDER BY id',
      ))
        () {
          final book = fitnessSpace(row['id'] as String);
          return ManifestFitnessSpace(
            book: book,
            entityCounts: {
              for (final type in FitnessTransferFormat.types)
                type: counts[book.id]?[type] ?? 0,
            },
            fullyDownloaded: book.isComplete && !book.isStale,
            runningCount: running[book.id] ?? 0,
            recoveryBranchCount: branches[book.id] ?? 0,
          );
        }(),
    ];
  }

  /// 外部 SQLite 的 CHECK 不能被信任：所有行、墓碑、归属、回执及清单一起校验。
  void validateFitnessManifest(BackupManifest manifest) {
    try {
      for (final (table, required) in [
        (
          'fitness_entities',
          [
            'id',
            'entity_type',
            'fitness_space_id',
            'scope_account_id',
            'storage_mode',
            'sync_id',
            'server_revision',
            'payload',
            'is_stale',
            'created_at',
            'updated_at',
            'deleted_at',
          ],
        ),
        (
          'fitness_spaces',
          [
            'id',
            'name',
            'storage_mode',
            'scope_account_id',
            'sync_id',
            'server_revision',
            'full_cursor',
            'is_stale',
            'created_at',
            'updated_at',
            'deleted_at',
            'is_hidden',
            'pending_local_delete',
          ],
        ),
        (
          'fitness_import_receipts',
          [
            'fitness_space_id',
            'export_id',
            'entity_type',
            'source_id',
            'target_id',
            'imported_at',
          ],
        ),
      ]) {
        final columns = _db
            .select('PRAGMA table_info($table)')
            .map((r) => r['name'])
            .toSet();
        if (!required.every(columns.contains)) {
          throw const FormatException('fitness columns');
        }
      }
      _withRows(
        'SELECT * FROM fitness_entities',
        [],
        (rows) =>
            FitnessTransferFormat.validateRecords(rows.map(_fitnessRecord)),
      );
      final records = _db
          .select(
            'SELECT id,fitness_space_id,entity_type FROM fitness_entities',
          )
          .map(
            (r) => (
              id: r['id'] as String,
              fitnessSpaceId: r['fitness_space_id'] as String,
              entityType: r['entity_type'] as String,
            ),
          )
          .toList();
      _withRows('SELECT * FROM fitness_entities', [], (rows) {
        for (final r in rows) {
          final local = r['storage_mode'] == 'local';
          final parent = fitnessSpace(r['fitness_space_id'] as String);
          if (r['storage_mode'] != parent.storageMode ||
              r['scope_account_id'] != parent.scopeAccountId ||
              (r['sync_id'] != null && r['sync_id'] != parent.syncId)) {
            throw const FormatException('fitness parent scope');
          }
          final payload =
              jsonDecode(r['payload'] as String) as Map<String, dynamic>;
          if ((local &&
                  (r['scope_account_id'] != null ||
                      r['sync_id'] != null ||
                      r['server_revision'] != null)) ||
              (!local &&
                  (r['storage_mode'] != 'cloud' ||
                      r['scope_account_id'] == null ||
                      r['server_revision'] is! int ||
                      (r['server_revision'] as int) < 0)) ||
              (r['sync_id'] != null &&
                  !FitnessTransferFormat.uuid.hasMatch(
                    r['sync_id'] as String,
                  )) ||
              (r['is_stale'] != 0 && r['is_stale'] != 1) ||
              DateTime.parse(
                    payload['created_at'] as String,
                  ).millisecondsSinceEpoch !=
                  r['created_at'] ||
              (r['deleted_at'] == null &&
                  DateTime.parse(
                        payload['updated_at'] as String,
                      ).millisecondsSinceEpoch !=
                      r['updated_at'])) {
            throw const FormatException('fitness row');
          }
        }
      });
      final byId = {for (final r in records) r.id: r};
      final receiptKeys = <String>{};
      for (final r in _db.select('SELECT * FROM fitness_import_receipts')) {
        final target = byId[r['target_id']];
        if (target == null ||
            target.fitnessSpaceId != r['fitness_space_id'] ||
            target.entityType != r['entity_type'] ||
            !FitnessTransferFormat.uuid.hasMatch(r['export_id'] as String) ||
            !FitnessTransferFormat.uuid.hasMatch(r['source_id'] as String) ||
            r['imported_at'] is! int ||
            !receiptKeys.add(
              jsonEncode([
                r['fitness_space_id'],
                r['export_id'],
                r['entity_type'],
                r['source_id'],
              ]),
            )) {
          throw const FormatException('fitness receipt');
        }
      }
      final spaceIds = <String>{};
      for (final row in _db.select('SELECT * FROM fitness_spaces')) {
        final book = fitnessSpace(row['id'] as String);
        if (!FitnessTransferFormat.uuid.hasMatch(book.id) ||
            !isValidName(book.name) ||
            !spaceIds.add(book.id) ||
            !['local', 'cloud'].contains(book.storageMode) ||
            (book.isCloud && book.scopeAccountId == null) ||
            (!book.isCloud &&
                (book.scopeAccountId != null || book.syncId != null))) {
          throw const FormatException('fitness space');
        }
      }
      for (final record in records) {
        if (!spaceIds.contains(record.fitnessSpaceId)) {
          throw const FormatException('fitness parent missing');
        }
      }
      final actual = fitnessManifest();
      final expected = {for (final s in manifest.fitnessSpaces) s.id: s};
      if (actual.length != expected.length) {
        throw const FormatException('fitness manifest scope');
      }
      for (final s in actual) {
        final e = expected[s.id];
        if (e == null ||
            e.runningCount != s.runningCount ||
            e.recoveryBranchCount != s.recoveryBranchCount ||
            e.fullyDownloaded != s.fullyDownloaded ||
            e.entityCounts.length != s.entityCounts.length ||
            s.entityCounts.entries.any(
              (v) => e.entityCounts[v.key] != v.value,
            )) {
          throw const FormatException('fitness manifest mismatch');
        }
      }
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.corrupt,
        '健身备份结构或内容校验失败',
      );
    }
  }

  void validateMemoManifest(BackupManifest manifest) {
    try {
      final tables = _db
          .select("SELECT name FROM sqlite_master WHERE type='table'")
          .map((r) => r['name'])
          .toSet();
      final names = ['memo_books', 'memo_entries', 'memo_import_receipts'];
      if (!names.every(tables.contains) ||
          _db.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const FormatException('memo tables');
      }
      final books = listMemoBooks(includeDeleted: true);
      final sourceIds = <String>{};
      for (final book in books) {
        _withRows(
          'SELECT * FROM memo_entries WHERE memo_book_id=? ORDER BY id',
          [book.id],
          (rows) {
            MemoJsonDocument.validateSnapshotBook(
              book,
              rows.map((row) {
                final entry = _memoEntry(row);
                if (entry.serverRevision != null && entry.serverRevision! < 0) {
                  throw const FormatException('memo identity');
                }
                return entry;
              }),
              seenIds: sourceIds,
            );
          },
        );
        if (!['local', 'cloud'].contains(book.storageMode) ||
            (book.isCloud &&
                (book.scopeAccountId == null ||
                    !book.isComplete ||
                    book.isStale)) ||
            (!book.isCloud &&
                (book.scopeAccountId != null || book.syncId != null)) ||
            (book.serverRevision != null && book.serverRevision! < 0)) {
          throw const FormatException('memo scope');
        }
      }
      final active = books.where((b) => b.deletedAt == null).toList();
      if (active.length != manifest.memoBooks.length) {
        throw const FormatException('memo count');
      }
      for (final book in active) {
        final item = manifest.memoBooks.singleWhere((b) => b.id == book.id);
        if (item.name != book.name ||
            item.type != book.type ||
            item.entryCount !=
                _count(
                  'SELECT count(*) AS c FROM memo_entries WHERE memo_book_id=? AND deleted_at IS NULL',
                  book.id,
                ) ||
            item.storageOrigin !=
                (book.isCloud
                    ? LedgerStorageOrigin.cloud
                    : LedgerStorageOrigin.local) ||
            item.sourceAccountId !=
                (book.scopeAccountId ?? book.sourceAccountId) ||
            item.createdAt != book.createdAt ||
            item.updatedAt != book.updatedAt ||
            item.isHidden != book.isHidden ||
            item.pendingLocalDelete != book.pendingLocalDelete) {
          throw const FormatException('memo manifest mismatch');
        }
      }
      final bookIds = books.map((b) => b.id).toSet();
      for (final row in _db.select(
        'SELECT memo_book_id,book_type,body_format FROM memo_entries',
      )) {
        if (!bookIds.contains(row['memo_book_id'])) {
          throw const FormatException('memo orphan');
        }
        // 正文格式与所属本类型一一对应：账号密码是字段列表，普通笔记是 delta。
        final expectedFormat = row['book_type'] == 'credentials'
            ? 'fields_v1'
            : 'delta_v1';
        if (row['body_format'] != expectedFormat) {
          throw const FormatException('memo body format');
        }
      }
      final receipts = <String>{};
      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      for (final row in _db.select('SELECT * FROM memo_import_receipts')) {
        if (!bookIds.contains(row['target_memo_book_id']) ||
            !uuid.hasMatch(row['export_id'] as String) ||
            !uuid.hasMatch(row['source_book_id'] as String) ||
            ((row['source_entry_id'] as String).isNotEmpty &&
                !uuid.hasMatch(row['source_entry_id'] as String)) ||
            !RegExp(r'^[a-f0-9]{64}$').hasMatch(row['fingerprint'] as String) ||
            row['imported_at'] is! int ||
            !receipts.add(
              jsonEncode([
                row['target_memo_book_id'],
                row['export_id'],
                row['source_book_id'],
                row['source_entry_id'],
              ]),
            )) {
          throw const FormatException('memo receipt');
        }
        final local = row['local_entry_id'];
        if (local != null) {
          final target = _db.select(
            'SELECT memo_book_id FROM memo_entries WHERE id=?',
            [local],
          );
          if (target.isEmpty ||
              target.single['memo_book_id'] != row['target_memo_book_id']) {
            throw const FormatException('memo receipt target');
          }
        }
      }
    } catch (_) {
      throw const BackupFormatException(BackupOpenError.corrupt, '备忘录备份内容校验失败');
    }
  }

  List<MemoBook> listMemoBooks({bool includeDeleted = false}) => [
    for (final r in _db.select(
      'SELECT * FROM memo_books ${includeDeleted ? '' : 'WHERE deleted_at IS NULL'} ORDER BY updated_at DESC,id',
    ))
      MemoBook(
        id: r['id'] as String,
        name: r['name'] as String,
        type: r['type'] as String,
        storageMode: r['storage_mode'] as String,
        scopeAccountId: r['scope_account_id'] as String?,
        syncId: r['sync_id'] as String?,
        fullCursor: r['full_cursor'] as String?,
        serverRevision: r['server_revision'] as int?,
        createdAt: _memoTime(r['created_at']),
        updatedAt: _memoTime(r['updated_at']),
        deletedAt: r['deleted_at'] == null ? null : _memoTime(r['deleted_at']),
        isStale: _memoBool(r['is_stale']),
        isHidden: _memoBool(r['is_hidden']),
        pendingLocalDelete: _memoBool(r['pending_local_delete']),
        sourceAccountId: r['source_account_id'] as String?,
        sourceMemoBookId: r['source_memo_book_id'] as String?,
        sourceOperationId: r['source_operation_id'] as String?,
      ),
  ];

  List<MemoEntry> listMemoEntries(String id, {bool includeDeleted = false}) => [
    for (final r in _db.select(
      'SELECT * FROM memo_entries WHERE memo_book_id=? ${includeDeleted ? '' : 'AND deleted_at IS NULL'} ORDER BY order_key,id',
      [id],
    ))
      _memoEntry(r),
  ];
  static MemoEntry _memoEntry(Map<String, Object?> r) => MemoEntry(
    id: r['id'] as String,
    memoBookId: r['memo_book_id'] as String,
    bookType: r['book_type'] as String,
    title: r['title'] as String,
    bodyJson: r['body'] as String?,
    orderKey: r['order_key'] as int?,
    serverRevision: r['server_revision'] as int?,
    createdAt: _memoTime(r['created_at']),
    updatedAt: _memoTime(r['updated_at']),
    deletedAt: r['deleted_at'] == null ? null : _memoTime(r['deleted_at']),
    sourceEntryId: r['source_entry_id'] as String?,
    sourceConflictId: r['source_conflict_id'] as String?,
  );
  List<Map<String, Object?>> listMemoReceipts(String id) => [
    for (final r in _db.select(
      'SELECT * FROM memo_import_receipts WHERE target_memo_book_id=?',
      [id],
    ))
      Map<String, Object?>.from(r),
  ];
  static DateTime _memoTime(Object? v) =>
      DateTime.fromMillisecondsSinceEpoch(v as int, isUtc: true);
  static bool _memoBool(Object? v) {
    if (v != 0 && v != 1) throw const FormatException('memo boolean');
    return v == 1;
  }

  /// 日子声明、关系、统计和日期定义必须全部一致才能进入预览。
  void validateDayManifest(BackupManifest manifest) {
    try {
      if (_db.select('PRAGMA integrity_check').single.values.single != 'ok' ||
          _db.select('PRAGMA user_version').single.values.single !=
              manifest.dbSchemaVersion) {
        throw const FormatException('sqlite');
      }
      final tables = _db
          .select("SELECT name FROM sqlite_master WHERE type='table'")
          .map((row) => row['name'])
          .toSet();
      final present = [
        'day_books',
        'day_events',
        'day_import_receipts',
      ].where(tables.contains).toList();
      if (present.length != 3) {
        throw const FormatException('missing day tables');
      }
      final bookFields = [
        'id',
        'name',
        'storage_mode',
        'scope_account_id',
        'sync_id',
        'server_revision',
        'full_cursor',
        'pending_local_delete',
        'is_stale',
        'is_hidden',
        'source_account_id',
        'source_day_book_id',
        'source_operation_id',
        'created_at',
        'updated_at',
        'deleted_at',
      ];
      final eventFields = [
        'id',
        'day_book_id',
        'category',
        'name',
        'countdown_mode',
        'interval_days',
        'repeat_type',
        'statistic_type',
        'server_revision',
        'created_at',
        'updated_at',
        'deleted_at',
        'source_event_id',
        for (final prefix in ['event', 'start', 'end'])
          for (final suffix in [
            'calendar_type',
            'original_year',
            'original_month',
            'original_day',
            'is_leap_month',
            'solar_date',
          ])
            '${prefix}_$suffix',
      ];
      for (final pair in [
        ('day_books', bookFields),
        ('day_events', eventFields),
        (
          'day_import_receipts',
          [
            'target_day_book_id',
            'export_id',
            'source_entry_id',
            'local_event_id',
            'imported_at',
          ],
        ),
      ]) {
        final columns = _db
            .select('PRAGMA table_info(${pair.$1})')
            .map((row) => row['name'])
            .toSet();
        if (!pair.$2.every(columns.contains)) {
          throw const FormatException('missing day columns');
        }
      }
      if (_db
              .select(
                'SELECT e.id FROM day_events e LEFT JOIN day_books b ON b.id=e.day_book_id WHERE b.id IS NULL LIMIT 1',
              )
              .isNotEmpty ||
          _db
              .select(
                'SELECT r.source_entry_id FROM day_import_receipts r LEFT JOIN day_books b ON b.id=r.target_day_book_id WHERE b.id IS NULL LIMIT 1',
              )
              .isNotEmpty ||
          _db
              .select(
                'SELECT r.source_entry_id FROM day_import_receipts r JOIN day_events e ON e.id=r.local_event_id WHERE e.day_book_id<>r.target_day_book_id LIMIT 1',
              )
              .isNotEmpty) {
        throw const FormatException('day relationships');
      }
      // 所有记录包括墓碑都通过同一日期规则校验，损坏内容不能藏在未勾选或删除记录中。
      _withRows('SELECT * FROM day_events', [], (rows) {
        for (final row in rows) {
          validateAndProject(_dayEvent(row).definition);
        }
      });
      final books = listDayBooks();
      final manifestById = {
        for (final item in manifest.dayBooks) item.dayBookId: item,
      };
      if (books.length != manifestById.length) {
        throw const FormatException('day book count');
      }
      for (final book in books) {
        final item = manifestById[book.id];
        final totals = {
          for (final row in _db.select(
            'SELECT category,count(*) AS n FROM day_events WHERE day_book_id=? AND deleted_at IS NULL GROUP BY category',
            [book.id],
          ))
            row['category'] as String: row['n'] as int,
        };
        final counts = {
          for (final type in DayCategory.values) type: totals[type] ?? 0,
        };
        if (item == null ||
            item.name != book.name ||
            item.storageOrigin.name != book.storageMode ||
            item.syncId != book.syncId ||
            item.sourceAccountId !=
                (book.isCloud ? book.scopeAccountId : book.sourceAccountId) ||
            item.sourceDayBookId != (book.sourceDayBookId ?? book.id) ||
            item.isHidden != book.isHidden ||
            item.eventCount !=
                counts.values.fold<int>(0, (total, count) => total + count) ||
            counts.entries.any(
              (entry) => item.categoryCounts[entry.key] != entry.value,
            ) ||
            item.fullyDownloaded !=
                (!book.isCloud || (book.fullCursor != null && !book.isStale)) ||
            item.pendingCount !=
                _count(
                  'SELECT COUNT(*) AS c FROM sync_changes WHERE day_book_id=? AND pushed_at IS NULL',
                  book.id,
                ) ||
            item.rejectedCount !=
                _count(
                  'SELECT COUNT(*) AS c FROM sync_changes WHERE day_book_id=? AND pushed_at IS NULL AND rejection_reason IS NOT NULL',
                  book.id,
                ) ||
            item.openConflictCount !=
                _count(
                  "SELECT COUNT(*) AS c FROM sync_conflicts WHERE day_book_id=? AND status='OPEN'",
                  book.id,
                )) {
          throw const FormatException('day manifest mismatch');
        }
      }
    } catch (error, stackTrace) {
      logger.error(
        'BackupRecovery',
        '日子备份结构或定义校验失败',
        safeErrorSummary(error),
        stackTrace,
      );
      throw const BackupFormatException(
        BackupOpenError.corrupt,
        '日子备份结构或清单不一致',
      );
    }
  }

  /// 不容忍 SQLite 中非法布尔值。
  bool _bool(Object? value) {
    if (value != 0 && value != 1) throw const FormatException('boolean');
    return value == 1;
  }

  /// 列出非墓碑父本，隐藏本保留独立保护身份。
  List<DayBook> listDayBooks() => [
    for (final row in _db.select(
      'SELECT * FROM day_books WHERE deleted_at IS NULL ORDER BY created_at,id',
    ))
      DayBook(
        id: row['id'] as String,
        name: normalizeDayName(row['name'] as String),
        storageMode: row['storage_mode'] as String,
        scopeAccountId: row['scope_account_id'] as String?,
        syncId: row['sync_id'] as String?,
        serverRevision: row['server_revision'] as int?,
        fullCursor: row['full_cursor'] as String?,
        createdAt: _memoTime(row['created_at']),
        updatedAt: _memoTime(row['updated_at']),
        pendingLocalDelete: _bool(row['pending_local_delete']),
        isStale: _bool(row['is_stale']),
        isHidden: _bool(row['is_hidden']),
        sourceAccountId: row['source_account_id'] as String?,
        sourceDayBookId: row['source_day_book_id'] as String?,
        sourceOperationId: row['source_operation_id'] as String?,
      ),
  ];

  /// 读取完整本内集合，墓碑在恢复时被排除但收据仍可保留。
  List<DayEvent> listDayEvents(String bookId) => [
    for (final row in _db.select(
      'SELECT * FROM day_events WHERE day_book_id=? ORDER BY created_at,id',
      [bookId],
    ))
      _dayEvent(row),
  ];

  /// 只映射当前本的导入事实，不把队列或游标作为活跃状态恢复。
  List<DayBackupReceipt> listDayReceipts(String bookId) => [
    for (final row in _db.select(
      'SELECT * FROM day_import_receipts WHERE target_day_book_id=?',
      [bookId],
    ))
      (
        exportId: row['export_id'] as String,
        sourceEntryId: row['source_entry_id'] as String,
        localEventId: row['local_event_id'] as String?,
        importedAt: _memoTime(row['imported_at']),
      ),
  ];

  /// 日期组必须全部为空或全部存在，不允许丢弃半组脏字段。
  OriginalDate? _date(Map<String, Object?> row, String prefix) {
    final values = [
      for (final suffix in [
        'calendar_type',
        'original_year',
        'original_month',
        'original_day',
        'is_leap_month',
        'solar_date',
      ])
        row['${prefix}_$suffix'],
    ];
    if (values.every((value) => value == null)) return null;
    if (values.any((value) => value == null)) {
      throw const FormatException('incomplete date');
    }
    return OriginalDate(
      calendarType: values[0] as String,
      originalYear: values[1] as int,
      originalMonth: values[2] as int,
      originalDay: values[3] as int,
      isLeapMonth: _bool(values[4]),
      solarDate: DateOnly.parse(values[5] as String),
    );
  }

  /// 外部行经严格定义映射后交给共享日期校验器。
  DayEvent _dayEvent(Map<String, Object?> row) => DayEvent(
    id: row['id'] as String,
    dayBookId: row['day_book_id'] as String,
    definition: DayEventDefinition(
      category: row['category'] as String,
      name: row['name'] as String,
      repeatType: row['repeat_type'] as String,
      statisticType: row['statistic_type'] as String,
      countdownMode: row['countdown_mode'] as String?,
      intervalDays: row['interval_days'] as int?,
      event: _date(row, 'event'),
      start: _date(row, 'start'),
      end: _date(row, 'end'),
    ),
    createdAt: _memoTime(row['created_at']),
    updatedAt: _memoTime(row['updated_at']),
    deletedAt: row['deleted_at'] == null ? null : _memoTime(row['deleted_at']),
    sourceEventId: row['source_event_id'] as String?,
  );

  /// 列出备份中的未删除账本（按名称排序，预览稳定）。
  List<BackupRecoveryLedgerRow> listLedgers() {
    try {
      final rows = _db.select(
        'SELECT id, name, storage_mode, sync_id, currency, scope_account_id, archived_at '
        'FROM ledgers WHERE deleted_at IS NULL ORDER BY name',
      );
      return [
        for (final row in rows)
          BackupRecoveryLedgerRow(
            id: row['id'] as String,
            name: row['name'] as String,
            storageMode: row['storage_mode'] as String,
            syncId: row['sync_id'] as String?,
            currency: row['currency'] as String? ?? 'CNY',
            scopeAccountId: row['scope_account_id'] as String?,
            archivedAt: row['archived_at'] == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    (row['archived_at'] as int) * 1000,
                    isUtc: true,
                  ),
          ),
      ];
    } catch (e) {
      throw StateError('备份账本列表读取失败: $e');
    }
  }

  /// 账本成员数（含生命周期状态成员——历史身份保留）。
  int countMembers(String ledgerId) {
    return _count(
      'SELECT COUNT(*) AS c FROM ledger_members WHERE ledger_id = ?1 AND deleted_at IS NULL',
      ledgerId,
    );
  }

  /// 账本交易数（未删除）。
  int countTransactions(String ledgerId) {
    return _count(
      'SELECT COUNT(*) AS c FROM transactions WHERE ledger_id = ?1 AND deleted_at IS NULL',
      ledgerId,
    );
  }

  /// 账本累计支出总额：Dart 层 Decimal 累加（金额为规范化 decimal 字符串，
  /// SQL SUM 对 TEXT 列失效），口径与账本管理页卡片一致。
  double sumLedgerExpense(String ledgerId) {
    try {
      final rows = _db.select(
        'SELECT native_amount, amount FROM transactions '
        'WHERE ledger_id = ?1 AND deleted_at IS NULL',
        [ledgerId],
      );
      var total = Decimal.zero;
      for (final row in rows) {
        final raw = (row['native_amount'] ?? row['amount']) as String?;
        final value = raw == null ? null : Decimal.tryParse(raw);
        if (value != null) total += value;
      }
      return total.toDouble();
    } catch (e) {
      throw StateError('备份支出统计读取失败: $e');
    }
  }

  /// 关闭只读连接（幂等）。
  void close() {
    try {
      _db.close();
    } catch (_) {
      // 已关闭/半关闭状态容错
    }
  }

  /// 执行 COUNT 聚合查询并返回计数值（查询失败抛 StateError）。
  int _count(String sql, String ledgerId) {
    try {
      final rows = _db.select(sql, [ledgerId]);
      final value = rows.first['c'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    } catch (e) {
      throw StateError('备份统计读取失败: $e');
    }
  }
}
