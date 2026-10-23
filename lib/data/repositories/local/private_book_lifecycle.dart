import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import '../../db.dart';
import '../../models/private_book.dart';

/// 现有私有本实际共用的父容器写边界，内容序列化由业务回调负责。
class PrivateBookLifecycle<B extends PrivateBook> {
  final SesameDatabase db;
  final d.TableInfo table;
  final String errorPrefix;
  final String parentIdColumn, sourceParentColumn;
  final String? Function() accountIdGetter;
  final int Function() generationGetter;
  final Future<B?> Function(String, String?) read;
  final Future<void> Function(B, String, Map<String, Object?>, DateTime, int)
  record;
  PrivateBookLifecycle({
    required this.db,
    required this.table,
    required this.errorPrefix,
    required this.parentIdColumn,
    required this.sourceParentColumn,
    required this.accountIdGetter,
    required this.generationGetter,
    required this.read,
    required this.record,
  });

  void check(String? account, int generation) {
    if (accountIdGetter() != account || generationGetter() != generation) {
      throw StateError('${errorPrefix}_SESSION_CHANGED');
    }
  }

  Future<T> write<T>(
    String? account,
    int generation,
    Future<T> Function() work,
  ) async {
    try {
      return await db.transaction(() async {
        check(account, generation);
        final result = await work();
        check(account, generation);
        return result;
      });
    } on FormatException {
      rethrow;
    } on StateError {
      rethrow;
    } catch (error, stackTrace) {
      // 对外只暴露稳定失败码，根因写入日志供定位，避免把 SQLite 绑定参数带出。
      logger.error(
        'PrivateBookLifecycle',
        '${errorPrefix}_WRITE_FAILED',
        safeErrorSummary(error),
        stackTrace,
      );
      throw StateError('${errorPrefix}_WRITE_FAILED');
    }
  }

  Future<PrivateBookTarget> target(String id) async {
    final account = accountIdGetter(), generation = generationGetter();
    final book = await read(id, account);
    check(account, generation);
    if (book == null || book.isStale || !book.isComplete) {
      throw StateError('${errorPrefix}_BOOK_UNAVAILABLE');
    }
    return (
      bookId: id,
      accountId: account,
      syncId: book.syncId,
      generation: generation,
    );
  }

  Future<B> requireTarget(PrivateBookTarget target) async {
    check(target.accountId, target.generation);
    final book = await read(target.bookId, target.accountId);
    if (book == null ||
        book.isStale ||
        !book.isComplete ||
        !matchesPrivateBookTarget(target, (
          bookId: book.id,
          accountId: accountIdGetter(),
          generation: generationGetter(),
          syncId: book.syncId,
        ))) {
      throw StateError('${errorPrefix}_TARGET_CHANGED');
    }
    check(target.accountId, target.generation);
    return book;
  }

  Future<B> create({
    required String id,
    required String name,
    Map<String, Object?> extra = const {},
    String storageMode = 'local',
    String? accountId,
    int? generation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    name = normalizeName(name);
    final account = accountId ?? accountIdGetter(),
        currentGeneration = generation ?? generationGetter();
    return write(account, currentGeneration, () async {
      if (!Uuid.isValidUUID(fromString: id) ||
          !hasVisibleText(name) ||
          !['local', 'cloud'].contains(storageMode) ||
          (storageMode == 'cloud' && account == null)) {
        throw FormatException('${errorPrefix}_BOOK_FIELDS');
      }
      final old = await db
          .customSelect(
            'SELECT id FROM ${table.actualTableName} WHERE id=?',
            variables: [d.Variable(id)],
          )
          .get();
      if (old.isNotEmpty) {
        final visible = await read(id, account);
        if (visible != null &&
            visible.name == name &&
            visible.storageMode == storageMode &&
            extra.entries.every(
              (entry) => visible.payload[entry.key] == entry.value,
            )) {
          return visible;
        }
        throw StateError('${errorPrefix}_ID_EXISTS');
      }
      final now = DateTime.now().toUtc();
      final values = <String, Object?>{
        'id': id,
        'name': name,
        ...extra,
        'storage_mode': storageMode,
        'scope_account_id': storageMode == 'cloud' ? account : null,
        'server_revision': storageMode == 'cloud' ? 0 : null,
        'created_at': (createdAt ?? now).millisecondsSinceEpoch,
        'updated_at': (updatedAt ?? createdAt ?? now).millisecondsSinceEpoch,
      };
      await db.customInsert(
        'INSERT INTO ${table.actualTableName} (${values.keys.join(',')}) VALUES (${List.filled(values.length, '?').join(',')})',
        variables: [for (final value in values.values) d.Variable(value)],
        updates: {table},
      );
      final book = (await read(id, account))!;
      await record(book, 'upsert', book.payload, now, 0);
      return book;
    });
  }

  Future<void> rename(PrivateBookTarget target, String name) =>
      write(target.accountId, target.generation, () async {
        final book = await requireTarget(target);
        name = normalizeName(name);
        if (book.name == name) return;
        final now = DateTime.now().toUtc();
        await db.customUpdate(
          'UPDATE ${table.actualTableName} SET name=?,updated_at=? WHERE id=?',
          variables: [
            d.Variable(name),
            d.Variable(now.millisecondsSinceEpoch),
            d.Variable(book.id),
          ],
          updates: {table},
        );
        await record(
          book,
          'upsert',
          {...book.payload, 'name': name, 'updated_at': wireTimestamp(now)},
          now,
          book.serverRevision ?? 0,
        );
      });
  Future<void> promote(
    PrivateBookTarget target,
    Future<void> Function(B) enqueueContents,
  ) => write(target.accountId, target.generation, () async {
    final book = await requireTarget(target);
    if (target.accountId == null) throw StateError('${errorPrefix}_SCOPE');
    if (book.isCloud) return;
    await db.customUpdate(
      "UPDATE ${table.actualTableName} SET storage_mode='cloud',scope_account_id=?,sync_id=NULL,full_cursor=NULL,server_revision=0 WHERE id=?",
      variables: [d.Variable(target.accountId!), d.Variable(book.id)],
      updates: {table},
    );
    for (final queue in <d.TableInfo>[db.syncConflicts, db.syncPullErrors]) {
      await db.customUpdate(
        'UPDATE ${queue.actualTableName} SET account_id=? WHERE $parentIdColumn=? AND account_id IS NULL',
        variables: [d.Variable(target.accountId!), d.Variable(book.id)],
        updates: {queue},
      );
    }
    final cloud = (await read(book.id, target.accountId))!;
    await record(cloud, 'upsert', cloud.payload, DateTime.now().toUtc(), 0);
    await enqueueContents(cloud);
  });

  /// 整本恢复的目标判定、同步历史清理和父恢复意图共用，内容仅在回调中替换。
  Future<({String id, bool copy})> prepareRestore(
    B source, {
    bool forceCopy = false,
    bool cloud = false,
    Map<String, Object?> extra = const {},
    required Future<void> Function(String) clearContents,
  }) => write(accountIdGetter(), generationGetter(), () async {
    final current = await db
        .customSelect(
          'SELECT * FROM ${table.actualTableName} WHERE id=?',
          variables: [d.Variable(source.id)],
        )
        .getSingleOrNull();
    if (cloud &&
        (!source.isCloud ||
            source.scopeAccountId != accountIdGetter() ||
            current == null ||
            current.readNullable<String>('scope_account_id') !=
                accountIdGetter() ||
            current.read<String>('storage_mode') != 'cloud' ||
            current.read<bool>('is_hidden') ||
            current.read<bool>('is_stale') ||
            current.readNullable<int>('deleted_at') != null ||
            current.read<bool>('pending_local_delete') ||
            current.readNullable<String>('sync_id') == null ||
            current.readNullable<String>('full_cursor') == null ||
            extra.entries.any(
              (entry) => current.data[entry.key] != entry.value,
            ))) {
      throw StateError('${errorPrefix}_RESTORE_FULL_REQUIRED');
    }
    final copy =
        !cloud &&
        (forceCopy ||
            source.isCloud ||
            current?.read<String>('storage_mode') == 'cloud' ||
            current?.read<bool>('is_hidden') == true);
    final id = copy ? const Uuid().v4() : source.id;
    if (cloud &&
        (await db
                .customSelect(
                  'SELECT id FROM sync_changes WHERE $parentIdColumn=? AND pushed_at IS NULL LIMIT 1',
                  variables: [d.Variable(id)],
                )
                .get())
            .isNotEmpty) {
      throw StateError('${errorPrefix}_RESTORE_PENDING');
    }
    final active = cloud ? (await read(id, accountIdGetter()))! : null;
    if (!copy && current != null) {
      await clearContents(id);
      for (final queue in <d.TableInfo>[
        db.syncChanges,
        db.syncConflicts,
        db.syncPullErrors,
      ]) {
        await db.customUpdate(
          'DELETE FROM ${queue.actualTableName} WHERE $parentIdColumn=?',
          variables: [d.Variable(id)],
          updates: {queue},
        );
      }
      if (!cloud) {
        await db.customUpdate(
          'DELETE FROM ${table.actualTableName} WHERE id=?',
          variables: [d.Variable(id)],
          updates: {table},
        );
      }
    }
    if (cloud) {
      await db.customUpdate(
        'UPDATE ${table.actualTableName} SET name=?,created_at=?,updated_at=? WHERE id=?',
        variables: [
          d.Variable(normalizeName(source.name)),
          d.Variable(source.createdAt.millisecondsSinceEpoch),
          d.Variable(source.updatedAt.millisecondsSinceEpoch),
          d.Variable(id),
        ],
        updates: {table},
      );
      await record(
        active!,
        'upsert',
        {
          ...source.payload,
          'name': normalizeName(source.name),
          'restore': true,
          'expected_full_cursor': active.fullCursor,
        },
        DateTime.now().toUtc(),
        active.serverRevision!,
      );
    } else {
      await create(
        id: id,
        name: source.name,
        extra: extra,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
      );
      await db.customUpdate(
        'UPDATE ${table.actualTableName} SET source_account_id=?,$sourceParentColumn=? WHERE id=?',
        variables: [
          d.Variable(source.scopeAccountId ?? source.sourceAccountId),
          d.Variable(source.id),
          d.Variable(id),
        ],
        updates: {table},
      );
    }
    return (id: id, copy: copy);
  });

  Future<void> delete(
    PrivateBookTarget target, {
    required Future<void> Function(B) validatePreview,
    String? expectedFullCursor,
  }) => write(target.accountId, target.generation, () async {
    final book = await requireTarget(target);
    await validatePreview(book);
    final now = DateTime.now().toUtc();
    if (book.isCloud) {
      if (book.syncId == null) {
        final frozen = await db
            .customSelect(
              'SELECT id FROM sync_changes WHERE $parentIdColumn=? AND frozen_request IS NOT NULL LIMIT 1',
              variables: [d.Variable(book.id)],
            )
            .get();
        if (frozen.isEmpty) {
          await db.customUpdate(
            'DELETE FROM sync_changes WHERE $parentIdColumn=? AND account_id=?',
            variables: [d.Variable(book.id), d.Variable(target.accountId!)],
            updates: {db.syncChanges},
          );
          await db.customUpdate(
            'DELETE FROM ${table.actualTableName} WHERE id=?',
            variables: [d.Variable(book.id)],
            updates: {table},
          );
          return;
        }
      }
      if (book.syncId != null && book.fullCursor == null) {
        throw StateError('${errorPrefix}_DOWNLOAD_REQUIRED');
      }
      await db.customUpdate(
        'UPDATE ${table.actualTableName} SET pending_local_delete=1 WHERE id=?',
        variables: [d.Variable(book.id)],
        updates: {table},
      );
      await record(
        book,
        'delete',
        {'expected_full_cursor': expectedFullCursor ?? book.fullCursor},
        now,
        book.serverRevision ?? 0,
      );
    } else {
      await db.customUpdate(
        'DELETE FROM ${table.actualTableName} WHERE id=?',
        variables: [d.Variable(book.id)],
        updates: {table},
      );
    }
  });
}
