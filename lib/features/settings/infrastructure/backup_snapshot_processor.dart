import '../../../data/repositories/local/fitness_space_repository.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode, Database;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/data/mappers/memo_mapper.dart';
import 'package:sesame_notes/data/models/day_event.dart' show DayCategory;
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_recovery_repository.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';

/// 只处理已隔离的数据库文件，不持有实时连接、会话或备份互斥状态。
class BackupSnapshotProcessor {
  /// 所有处理输入均显式传入，可以独立运行于后台隔离进程。
  const BackupSnapshotProcessor();

  /// 在隔离工作进程中处理备份快照，失败向调用方保留原异常。
  static Future<void> copySnapshotFile((String, String) paths) async {
    Database? from;
    Database? to;
    try {
      from = sqlite3.open(paths.$1, mode: OpenMode.readOnly);
      to = sqlite3.open(paths.$2);
      await from.backup(to, nPage: 256).drain<void>();
    } catch (error) {
      logger.error('LocalBackup', '创建数据库在线快照失败', safeErrorSummary(error));
      rethrow;
    } finally {
      to?.close();
      from?.close();
    }
  }

  /// 在隔离工作进程中处理备份快照，失败向调用方保留原异常。
  static Future<BackupManifest> finishSnapshotFile(
    ({
      String path,
      String? account,
      String? deviceId,
      Map<String, String>? accountNames,
    })
    input,
  ) async {
    final tmp = File(input.path), currentAccountId = input.account;
    final deviceId = input.deviceId, accountNames = input.accountNames;
    final snapshot = sqlite3.open(tmp.path);
    try {
      snapshot.execute('PRAGMA foreign_keys = ON');
      snapshot.execute('BEGIN');
      try {
        const BackupSnapshotProcessor()._filterSnapshotAccount(
          snapshot,
          currentAccountId,
        );
        snapshot.execute('COMMIT');
      } catch (_) {
        snapshot.execute('ROLLBACK');
        rethrow;
      }
    } finally {
      snapshot.close();
    }
    final isolated = SesameDatabase.withExecutor(NativeDatabase(tmp));
    late BackupManifest manifest;
    try {
      manifest = await const BackupSnapshotProcessor()._buildManifest(
        isolated,
        deviceId: deviceId,
        accountNames: accountNames,
        currentAccountId: currentAccountId,
      );
    } finally {
      await isolated.close();
    }
    final compact = sqlite3.open(tmp.path);
    try {
      // 全部物化后只压缩一次，清除被排除账号与历史正文的残留页。
      compact.execute('VACUUM');
      compact.execute('PRAGMA wal_checkpoint(TRUNCATE)');
      compact.execute('PRAGMA journal_mode = DELETE');
      if (compact.select('PRAGMA integrity_check').single.values.single !=
              'ok' ||
          compact.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw StateError('备份数据完整性校验失败');
      }
    } finally {
      compact.close();
    }
    final recovery = BackupRecoveryRepository.open(tmp.path);
    try {
      recovery.validateDayManifest(manifest);
      recovery.validateMemoManifest(manifest);
      recovery.validateFitnessManifest(manifest);
    } finally {
      recovery.close();
    }
    return manifest;
  }

  /// 父本决定业务范围，先清除独立同步事实，再级联删除其他账号父子数据。
  void _filterSnapshotAccount(Database snapshot, String? accountId) {
    final hasAccount = accountId != null && accountId.isNotEmpty;
    final accountFilter = hasAccount
        ? 'IS NOT NULL AND account_id != ?'
        : 'IS NOT NULL';
    final scopeFilter = hasAccount
        ? 'IS NOT NULL AND scope_account_id != ?'
        : 'IS NOT NULL';
    final args = <Object?>[if (hasAccount) accountId];
    for (final table in [
      'sync_changes',
      'sync_conflicts',
      'sync_pull_errors',
    ]) {
      snapshot.execute(
        'DELETE FROM $table WHERE account_id $accountFilter',
        args,
      );
      for (final (column, parent) in [
        ('ledger_id', 'ledgers'),
        ('day_book_id', 'day_books'),
        ('memo_book_id', 'memo_books'),
        ('fitness_space_id', 'fitness_spaces'),
      ]) {
        snapshot.execute(
          'DELETE FROM $table WHERE $column IN '
          '(SELECT id FROM $parent WHERE scope_account_id $scopeFilter)',
          args,
        );
      }
    }
    snapshot.execute(
      'DELETE FROM sync_state WHERE account_id $accountFilter',
      args,
    );
    for (final table in [
      'day_books',
      'memo_books',
      'ledgers',
      'exchange_rate_overrides',
      'fitness_spaces',
    ]) {
      snapshot.execute(
        'DELETE FROM $table WHERE scope_account_id $scopeFilter',
        args,
      );
    }
    // 分类 SQL 本地域采用空字符串，账号过滤保留本地目录和当前账号的独立身份。
    snapshot.execute(
      hasAccount
          ? "DELETE FROM categories WHERE scope_account_id != '' AND scope_account_id != ?"
          : "DELETE FROM categories WHERE scope_account_id != ''",
      args,
    );
    // 镜像依附实际保留的账本，独立缓存表没有级联外键，孤立或已排除账号的镜像一并清理。
    snapshot.execute(
      'DELETE FROM shared_ledger_categories WHERE ledger_id NOT IN (SELECT id FROM ledgers)',
    );
  }

  /// 从最终隔离数据库构建 Manifest（账本分域 + 同步状态统计）。
  ///
  /// 统计口径（仅展示与审计）：pending = 未推送 sync_changes 数；
  /// open_conflict = status=OPEN 冲突数；last_sync_at = 账本内最近一次业务更新时间。
  /// 不设 last_server_revision（账本无天然的'最后服务端修订号'）。
  Future<void> _materializeMemoBranches(SesameDatabase db) => db.transaction(
    () async {
      final candidates = <({String bookId, String entityId, String payload})>[];
      for (final change in await (db.select(
        db.syncChanges,
      )..where((c) => c.memoBookId.isNotNull() & c.pushedAt.isNull())).get()) {
        if (change.entityType == 'memo_entry' && change.action == 'upsert') {
          candidates.add((
            bookId: change.memoBookId!,
            entityId: change.entityId,
            payload: change.payload,
          ));
          if (change.frozenRequest != null) {
            final frozen =
                jsonDecode(change.frozenRequest!) as Map<String, dynamic>;
            candidates.add((
              bookId: change.memoBookId!,
              entityId: change.entityId,
              payload: jsonEncode(frozen['payload']),
            ));
          }
        }
      }
      for (final conflict
          in await (db.select(db.syncConflicts)..where(
                (c) => c.memoBookId.isNotNull() & c.status.equals('OPEN'),
              ))
              .get()) {
        if (conflict.entityType == 'memo_entry') {
          candidates.add((
            bookId: conflict.memoBookId!,
            entityId: conflict.entityId,
            payload: conflict.localPayload,
          ));
        }
      }
      final seen = <String>{};
      for (final c in candidates) {
        final parent = await (db.select(
          db.memoBooks,
        )..where((b) => b.id.equals(c.bookId))).getSingleOrNull();
        if (parent == null || parent.deletedAt != null) {
          throw StateError('MEMO_BACKUP_BRANCH_UNAVAILABLE');
        }
        final payload = jsonDecode(c.payload) as Map<String, dynamic>;
        if (payload.isEmpty) continue;
        final hash = memoFingerprint(payload);
        if (!seen.add('${c.entityId}:$hash')) continue;
        final existing = await (db.select(
          db.memoEntries,
        )..where((e) => e.id.equals(c.entityId))).getSingleOrNull();
        if (existing != null &&
            existing.deletedAt == null &&
            memoFingerprint(memoEntryFromRow(existing).payload) == hash) {
          continue;
        }
        final document = MemoJsonDocument.decode(
          utf8.encode(
            jsonEncode({
              'format': 'sesame-memos',
              'schema_version': 2,
              'export_id': const Uuid().v4(),
              'exported_at': memoBookFromRow(parent).payload['updated_at'],
              'books': [
                {
                  'source_book_id': parent.id,
                  ...memoBookFromRow(parent).payload,
                  'entries': [
                    {
                      'source_entry_id': c.entityId,
                      'source_book_id': parent.id,
                      ...payload,
                    },
                  ],
                },
              ],
            }),
          ),
        );
        final value = document.books.single.entries.single;
        final row = memoEntryToCompanion(value);
        await db
            .into(db.memoEntries)
            .insert(
              row.copyWith(
                id: d.Value(const Uuid().v4()),
                serverRevision: const d.Value(null),
                sourceEntryId: d.Value(c.entityId),
              ),
            );
      }
      // 恢复只读取物化后的内容；活跃请求和诊断原文都不进入可交付备份。
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.memoBookId.isNotNull())).go();
      await (db.delete(
        db.syncConflicts,
      )..where((c) => c.memoBookId.isNotNull())).go();
      await (db.delete(
        db.syncPullErrors,
      )..where((c) => c.memoBookId.isNotNull())).go();
    },
  );

  /// 在隔离工作进程中处理备份快照，失败向调用方保留原异常。
  Future<BackupManifest> _buildManifest(
    SesameDatabase db, {
    String? deviceId,
    Map<String, String>? accountNames,
    String? currentAccountId,
  }) async {
    final now = DateTime.now().toUtc();
    await _materializeMemoBranches(db);
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
      // 当前账号兜底收录：owner 成员缺绑定账号时 original_account_id
      // 会回退到当前账号，账号引用表必须包含它，否则恢复侧查无此人。
      if (currentAccountId != null && currentAccountId.isNotEmpty) {
        accountIds.add(currentAccountId);
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
          // owner 成员缺绑定账号时兜底当前账号：快照经账号域过滤只含当前
          // 账号域的云账本，兜底语义正确（避免恢复页显示「未知账号」）。
          originalAccountId: isCloud
              ? (ownerMember?.linkedAccountId ?? currentAccountId)
              : null,
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
    final dayEntries = <ManifestDayBook>[];
    final books = await (db.select(
      db.dayBooks,
    )..where((b) => b.deletedAt.isNull())).get();
    for (final book in books) {
      final events =
          await (db.select(db.dayEvents)..where(
                (e) => e.dayBookId.equals(book.id) & e.deletedAt.isNull(),
              ))
              .get();
      final pending = await (db.select(
        db.syncChanges,
      )..where((c) => c.dayBookId.equals(book.id) & c.pushedAt.isNull())).get();
      final conflicts =
          await (db.select(db.syncConflicts)..where(
                (c) => c.dayBookId.equals(book.id) & c.status.equals('OPEN'),
              ))
              .get();
      final isCloud = book.storageMode == 'cloud';
      final sourceAccount = isCloud
          ? book.scopeAccountId
          : book.sourceAccountId;
      if (sourceAccount != null) accountIds.add(sourceAccount);
      dayEntries.add(
        ManifestDayBook(
          dayBookId: book.id,
          name: book.name,
          storageOrigin: isCloud
              ? LedgerStorageOrigin.cloud
              : LedgerStorageOrigin.local,
          sourceAccountId: sourceAccount,
          sourceDayBookId: book.sourceDayBookId ?? book.id,
          syncId: book.syncId,
          eventCount: events.length,
          categoryCounts: {
            for (final category in DayCategory.values)
              category: events
                  .where((event) => event.category == category)
                  .length,
          },
          pendingCount: pending.length,
          rejectedCount: pending
              .where((change) => change.rejectionReason != null)
              .length,
          openConflictCount: conflicts.length,
          fullyDownloaded:
              !isCloud || (book.fullCursor != null && !book.isStale),
          isHidden: book.isHidden,
        ),
      );
    }
    final memoEntries = <ManifestMemoBook>[];
    for (final book in await (db.select(
      db.memoBooks,
    )..where((b) => b.deletedAt.isNull())).get()) {
      if (book.storageMode == 'cloud' &&
          (book.isStale || (book.syncId != null && book.fullCursor == null))) {
        throw StateError('MEMO_DOWNLOAD_REQUIRED');
      }
      final count = await db
          .customSelect(
            'SELECT count(*) AS n FROM memo_entries WHERE memo_book_id=? AND deleted_at IS NULL',
            variables: [d.Variable(book.id)],
          )
          .getSingle();
      final source = book.scopeAccountId ?? book.sourceAccountId;
      if (source != null) accountIds.add(source);
      memoEntries.add(
        ManifestMemoBook(
          id: book.id,
          name: book.name,
          type: book.type,
          storageOrigin: book.storageMode == 'cloud'
              ? LedgerStorageOrigin.cloud
              : LedgerStorageOrigin.local,
          sourceAccountId: source,
          entryCount: count.read<int>('n'),
          createdAt: book.createdAt,
          updatedAt: book.updatedAt,
          isHidden: book.isHidden,
          pendingLocalDelete: book.pendingLocalDelete,
        ),
      );
    }
    final fitnessManifest = <ManifestFitnessSpace>[];
    for (final row in await (db.select(
      db.fitnessSpaces,
    )..where((b) => b.deletedAt.isNull())).get()) {
      final book = fitnessSpaceFromRow(row);
      final records = await FitnessDataTransfer.snapshot(
        db,
        fitnessSpaceId: book.id,
        accountId: currentAccountId,
        requireComplete: false,
      );
      final branches = await FitnessDataTransfer.captureBranches(db, records);
      if (book.scopeAccountId ?? book.sourceAccountId case final account?) {
        accountIds.add(account);
      }
      fitnessManifest.add(
        ManifestFitnessSpace(
          book: book,
          entityCounts: {
            for (final type in [
              'fitness_template',
              'fitness_plan',
              'fitness_workout',
              'fitness_preferences',
            ])
              type: records.where((r) => r.entityType == type).length,
          },
          fullyDownloaded: book.isComplete && !book.isStale,
          runningCount: records
              .where(
                (r) =>
                    r.entityType == 'fitness_workout' &&
                    r.deletedAt == null &&
                    r.payload['status'] == 'in_progress',
              )
              .length,
          recoveryBranchCount: branches.length,
        ),
      );
    }
    return BackupManifest(
      formatVersion: backupFormatVersion,
      dbSchemaVersion: db.schemaVersion,
      createdAt: now,
      deviceId: deviceId ?? '',
      ledgers: entries,
      dayBooks: dayEntries,
      memoBooks: memoEntries,
      fitnessSpaces: fitnessManifest,
      accounts: [
        for (final id in accountIds)
          ManifestAccount(accountId: id, accountName: accountNames?[id] ?? ''),
      ],
    );
  }
}
