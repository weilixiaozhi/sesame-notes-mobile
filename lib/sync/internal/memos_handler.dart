import 'dart:convert';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/data/models/private_book.dart' as private_books;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/models/memo.dart' as memos;
import 'package:sesame_notes/data/mappers/memo_mapper.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 笔记本与条目的拉取、推送、保护和冲突处理。
class MemoSyncHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  MemoSyncHandler(this._runtime, this._ports, {required this.memoRepository});
  final SyncRuntime _runtime;
  final MemoSyncHandlerPorts _ports;
  final MemoRepository? memoRepository;

  /// 执行memoAccount对应的同步步骤，沿用所属域的身份与事务规则。
  String memoAccount() {
    final account = _runtime.currentAccountIdForCloudOperation('同步备忘录');
    if (memoRepository == null) {
      throw StateError('MEMO_SYNC_UNAVAILABLE');
    }
    return account;
  }

  /// 执行memoBook对应的同步步骤，沿用所属域的身份与事务规则。
  Future<MemoBookRow?> memoBook(String id) => (_runtime.db.select(
    _runtime.db.memoBooks,
  )..where((b) => b.id.equals(id))).getSingleOrNull();

  /// 先登记未完整下载状态；仅全部本成功处理后才建立域级屏障。
  Future<void> discoverMemoBooks() =>
      _ports.pullDiscoverBookDirectory(SyncDomain.memos);

  /// 执行downloadMemoBook对应的同步步骤，沿用所属域的身份与事务规则。
  Future<GetSyncMemoBooksFull200Response> downloadMemoBook(
    String id,
    String accountId, {
    String? knownSyncId,
  }) async {
    final local = await memoBook(id);
    if (local != null &&
        (local.scopeAccountId != accountId ||
            local.storageMode != 'cloud' ||
            local.isStale)) {
      throw StateError('MEMO_SCOPE');
    }
    final expected = local?.syncId ?? knownSyncId;
    final response = (await _runtime.api.getSyncMemoBooksFull(
      memoBookId: id,
      syncId: expected,
    )).data!;
    _runtime.requireAccount(accountId);
    if (response.memoBook.id != id ||
        (expected != null && response.memoBook.syncId != expected)) {
      throw StateError('MEMO_FULL_IDENTITY');
    }
    final current = await memoBook(id);
    if (current?.scopeAccountId != local?.scopeAccountId ||
        current?.syncId != local?.syncId ||
        current?.isStale == true) {
      throw StateError('MEMO_TARGET_CHANGED');
    }
    return response;
  }

  /// 执行fullMemoBook对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> fullMemoBook(String id) async {
    final accountId = memoAccount();
    final pendingParent = await _runtime.pendingChange(
      'memo_book',
      id,
      accountId,
    );
    if (pendingParent?.frozenRequest != null &&
        (jsonDecode(pendingParent!.payload)
                as Map<String, dynamic>)['restore'] ==
            true) {
      await _ports.pushPushPending(accountId);
      if (await _runtime.pendingChange('memo_book', id, accountId) != null) {
        throw StateError('MEMO_RESTORE_PENDING');
      }
    }
    try {
      final full = await downloadMemoBook(id, accountId);
      await _runtime.inAccountTransaction(
        accountId,
        () => applyMemoFull(full, accountId),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 412) {
        await _runtime.inAccountTransaction(
          accountId,
          () => protectMemoBook(id, accountId, stale: true),
        );
      }
      rethrow;
    }
  }

  /// 全量父子校验后在一个事务应用；单本 full 不改变全域消费水位。
  Future<void> applyMemoFull(
    GetSyncMemoBooksFull200Response full,
    String accountId,
  ) async {
    final id = full.memoBook.id;
    final before = await memoBook(id);
    if (before != null &&
        (before.scopeAccountId != accountId ||
            before.isStale ||
            (before.syncId != null && before.syncId != full.memoBook.syncId))) {
      throw StateError('MEMO_FULL_SCOPE');
    }
    final ids = <String>{};
    for (final entry in full.memoEntries) {
      if (!ids.add(entry.id) ||
          entry.memoBookId != id ||
          entry.syncId != full.memoBook.syncId ||
          entry.bookType.name != full.memoBook.type.name ||
          entry.deletedAt != null) {
        throw const FormatException('MEMO_FULL_RELATION');
      }
      memoEntryModel(entry).validate();
    }
    await applyMemoBookPayload(
      id,
      _runtime.modelMap(full.memoBook, MemoBook.serializer),
      accountId,
    );
    for (final entry in full.memoEntries) {
      await applyMemoEntryPayload(
        entry.id,
        _runtime.modelMap(entry, MemoEntry.serializer),
        accountId,
      );
    }
    final local = await (_runtime.db.select(
      _runtime.db.memoEntries,
    )..where((e) => e.memoBookId.equals(id) & e.deletedAt.isNull())).get();
    for (final entry in local) {
      if (ids.contains(entry.id)) continue;
      final pending = await _runtime.pendingChange(
        'memo_entry',
        entry.id,
        accountId,
      );
      if (pending != null && (entry.serverRevision ?? 0) == 0) continue;
      final tombstone = {
        'memo_book_id': id,
        'sync_id': full.memoBook.syncId,
        'deleted': true,
        'revision': (entry.serverRevision ?? 0) + 1,
      };
      if (pending != null) {
        // 未知结果仍先保留冻结请求，下一轮重放得到权威确认或冲突。
        if (pending.frozenRequest == null) {
          await _runtime.privateBookConflict(pending, tombstone, accountId);
        }
      } else {
        await applyMemoEntryPayload(entry.id, tombstone, accountId);
      }
    }
    final cursor = before?.fullCursor;
    await (_runtime.db.update(
      _runtime.db.memoBooks,
    )..where((b) => b.id.equals(id))).write(
      MemoBooksCompanion(
        fullCursor: d.Value(
          cursor != null &&
                  BigInt.parse(cursor) > BigInt.parse(full.serverCursor)
              ? cursor
              : full.serverCursor,
        ),
      ),
    );
  }

  /// 执行memoEntryModel对应的同步步骤，沿用所属域的身份与事务规则。
  memos.MemoEntry memoEntryModel(
    MemoEntry entry, {
    String? sourceId,
    String? conflictId,
  }) => memos.MemoEntry(
    id: entry.id,
    memoBookId: entry.memoBookId,
    bookType: entry.bookType.name,
    title: entry.title,
    // 正文是自由 JSON 对象；JsonObject 必须解包 value 才能重新序列化。
    bodyJson: entry.body == null
        ? null
        : jsonEncode({
            for (final item in entry.body!.entries) item.key: item.value?.value,
          }),
    orderKey: entry.orderKey == null ? null : int.parse(entry.orderKey!),
    createdAt: entry.createdAt,
    updatedAt: entry.updatedAt,
    deletedAt: entry.deletedAt,
    serverRevision: entry.revision,
    sourceEntryId: sourceId,
    sourceConflictId: conflictId,
  );

  /// 执行applyMemoBookPayload对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyMemoBookPayload(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  ) async {
    final local = await memoBook(id);
    if (local != null &&
        (local.scopeAccountId != accountId || local.storageMode != 'cloud')) {
      throw StateError('MEMO_SCOPE');
    }
    if (local?.isStale == true) return;
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      await protectMemoBook(id, accountId, deleted: true);
      return;
    }
    final remote = _runtime.deser(jsonEncode(payload), MemoBook.serializer);
    if (remote.id != id || remote.revision < 1 || !isValidName(remote.name)) {
      throw const FormatException('MEMO_BOOK_PAYLOAD');
    }
    if (local != null && local.type != remote.type.name) {
      throw const FormatException('MEMO_TYPE');
    }
    if (local?.syncId != null && local!.syncId != remote.syncId) {
      await protectMemoBook(id, accountId, stale: true);
      return;
    }
    if (local != null && remote.revision <= (local.serverRevision ?? 0)) {
      await touchMemoBook(id, remote.updatedAt);
      return;
    }
    final head = await _runtime.pendingChange('memo_book', id, accountId);
    if (head != null) {
      if (head.frozenRequest == null) {
        await _runtime.privateBookConflict(head, payload, accountId);
      }
      if (local?.syncId == null) {
        await (_runtime.db.update(
          _runtime.db.memoBooks,
        )..where((b) => b.id.equals(id))).write(
          MemoBooksCompanion(
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
          ),
        );
      }
      return;
    }
    await _runtime.db
        .into(_runtime.db.memoBooks)
        .insertOnConflictUpdate(
          MemoBooksCompanion.insert(
            id: id,
            name: normalizeName(remote.name),
            type: remote.type.name,
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountId),
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
            createdAt: remote.createdAt,
            updatedAt:
                local != null && local.updatedAt.isAfter(remote.updatedAt)
                ? local.updatedAt
                : remote.updatedAt,
          ),
        );
  }

  /// 执行touchMemoBook对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> touchMemoBook(String id, DateTime updatedAt) async {
    await _runtime.db.customUpdate(
      'UPDATE memo_books SET updated_at=max(updated_at,?) WHERE id=?',
      variables: [d.Variable(updatedAt.millisecondsSinceEpoch), d.Variable(id)],
      updates: {_runtime.db.memoBooks},
    );
  }

  /// 执行applyMemoEntryPayload对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyMemoEntryPayload(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  ) async {
    final local = await (_runtime.db.select(
      _runtime.db.memoEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    final bookId = payload['memo_book_id'] as String? ?? local?.memoBookId;
    if (bookId == null) throw const FormatException('MEMO_PARENT');
    final book = await memoBook(bookId);
    if (book == null ||
        book.scopeAccountId != accountId ||
        (local != null && local.memoBookId != bookId)) {
      throw StateError('MEMO_SCOPE');
    }
    if (book.isStale || book.deletedAt != null) return;
    if (payload['sync_id'] != null && payload['sync_id'] != book.syncId) {
      throw StateError('MEMO_SYNC_ID');
    }
    final revision = payload['revision'] as int;
    if (payload['book_updated_at'] case final String timestamp) {
      await touchMemoBook(bookId, DateTime.parse(timestamp));
    }
    // 零版本墓碑是云端明确不存在的事实，不能按历史修订水位忽略用户的远端决策。
    final remoteMissing = revision == 0 && payload['deleted'] == true;
    if (local != null &&
        !remoteMissing &&
        revision <= (local.serverRevision ?? 0)) {
      return;
    }
    final head = await _runtime.pendingChange('memo_entry', id, accountId);
    if (head != null) {
      if (head.frozenRequest == null) {
        await _runtime.privateBookConflict(head, payload, accountId);
      }
      return;
    }
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      if (local != null) {
        await (_runtime.db.update(
          _runtime.db.memoEntries,
        )..where((e) => e.id.equals(id))).write(
          MemoEntriesCompanion(
            serverRevision: d.Value(revision),
            deletedAt: d.Value(DateTime.now().toUtc()),
          ),
        );
      }
      return;
    }
    final remote = _runtime.deser(jsonEncode(payload), MemoEntry.serializer);
    if (remote.id != id ||
        remote.bookType.name != book.type ||
        remote.revision < 1) {
      throw const FormatException('MEMO_ENTRY_PAYLOAD');
    }
    final entry = memoEntryModel(
      remote,
      sourceId: local?.sourceEntryId,
      conflictId: local?.sourceConflictId,
    );
    entry.validate();
    await _runtime.db
        .into(_runtime.db.memoEntries)
        .insertOnConflictUpdate(memoEntryToCompanion(entry));
  }

  /// 执行protectMemoBook对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> protectMemoBook(
    String id,
    String accountId, {
    bool stale = false,
    bool deleted = false,
  }) async {
    final book = await memoBook(id);
    if (book == null) return;
    if (book.scopeAccountId != accountId) throw StateError('数据不属于当前账号');
    await _ports.operationsQuarantinePrivateBook(
      SyncTarget('memo_book', id),
      accountId,
      stale: stale,
      deleted: deleted,
      book: memoBookFromRow(book),
      table: _runtime.db.memoBooks,
      contents: _runtime.db.memoEntries,
      parentColumn: 'memo_book_id',
      protect: (branch) async {
        await memoRepository!.preserveBook(id, 'scope-protection:$id:$branch');
      },
    );
  }

  /// 执行saveMemoCursor对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> saveMemoCursor(String cursor) async {
    await _runtime.saveDomainCursor(SyncDomain.memos, cursor, memoAccount());
    // 完整本消费完增量后也是完整快照，不能一直用首次 full 的旧水位删本。
    // 未确认分支可能阻止远端应用，因此这些本仍保留原水位与并发保护。
    final account = memoAccount();
    final pending =
        (await (_runtime.db.select(_runtime.db.syncChanges)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.memoBookId.isNotNull() &
                      c.pushedAt.isNull(),
                ))
                .get())
            .map((c) => c.memoBookId)
            .toSet();
    final books =
        await (_runtime.db.select(_runtime.db.memoBooks)..where(
              (b) =>
                  b.scopeAccountId.equals(account) &
                  b.fullCursor.isNotNull() &
                  b.isStale.equals(false) &
                  b.isHidden.equals(false) &
                  b.pendingLocalDelete.equals(false) &
                  b.deletedAt.isNull(),
            ))
            .get();
    for (final book in books) {
      if (!pending.contains(book.id) &&
          BigInt.parse(cursor) > BigInt.parse(book.fullCursor!)) {
        await (_runtime.db.update(_runtime.db.memoBooks)
              ..where((b) => b.id.equals(book.id)))
            .write(MemoBooksCompanion(fullCursor: d.Value(cursor)));
      }
    }
  }

  /// 执行applyMemoChange对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyMemoChange(
    GetSyncPull200ResponseChangesInner change,
    String accountId,
  ) async {
    final id = change.memoBookId;
    if (id == null || change.dayBookId != null || change.ledgerId != null) {
      throw const FormatException('MEMO_CHANGE_SCOPE');
    }
    final payload = <String, dynamic>{
      for (final item in change.payload.entries) item.key: item.value?.value,
    };
    final book = await memoBook(id);
    if (book != null && book.scopeAccountId != accountId) {
      throw StateError('MEMO_SCOPE');
    }
    if (book?.isStale == true) return;
    final own =
        await (_runtime.db.select(_runtime.db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(accountId) &
                  c.mutationId.equals(change.mutationId),
            ))
            .getSingleOrNull();
    if (own != null && own.pushedAt == null) {
      await applyMemoPushOutcome(
        own,
        PostSyncPush200ResponseOutcomesInner(
          (b) => b
            ..mutationId = own.mutationId
            ..entityId = own.entityId
            ..status = PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
            ..changeId = change.changeId
            ..revision = (payload['revision'] as int?)
            ..syncId = (payload['sync_id'] as String?),
        ),
        accountId,
      );
      return;
    }
    if (book?.fullCursor != null &&
        book?.syncId == payload['sync_id'] &&
        BigInt.parse(change.changeId) <= BigInt.parse(book!.fullCursor!)) {
      return;
    }
    if (change.entityType.name == 'memoBook') {
      await applyMemoBookPayload(change.entityId, payload, accountId);
    } else {
      await applyMemoEntryPayload(change.entityId, payload, accountId);
    }
  }

  /// 执行freezeMemoChange对应的同步步骤，沿用所属域的身份与事务规则。
  Future<SyncChange?> freezeMemoChange(
    SyncChange source,
    String accountId,
  ) async {
    SyncChange? result;
    await _runtime.inAccountTransaction(accountId, () async {
      final row =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) => c.id.equals(source.id) & c.accountId.equals(accountId),
              ))
              .getSingleOrNull();
      if (row == null || row.pushedAt != null) return;
      final book = await (_runtime.db.select(
        _runtime.db.memoBooks,
      )..where((b) => b.id.equals(row.memoBookId!))).getSingle();
      if (book.scopeAccountId != accountId ||
          book.storageMode != 'cloud' ||
          row.dayBookId != null ||
          row.ledgerId != null) {
        throw StateError('MEMO_SCOPE');
      }
      if (row.frozenRequest == null) {
        final wire = jsonEncode({
          'mutation_id': row.mutationId,
          'entity_type': row.entityType,
          'entity_id': row.entityId,
          'ledger_id': null,
          'day_book_id': null,
          'memo_book_id': book.id,
          'sync_id': ?book.syncId,
          'base_revision': row.baseRevision ?? 0,
          'action': row.action,
          'updated_at': wireTimestamp(row.updatedAt),
          'payload': jsonDecode(row.payload),
        });
        if (utf8.encode(wire).length > 768 * 1024) {
          await (_runtime.db.update(
            _runtime.db.syncChanges,
          )..where((c) => c.id.equals(row.id))).write(
            const SyncChangesCompanion(rejectionReason: d.Value('SYNC_BUDGET')),
          );
          return;
        }
        _runtime.changeCodec.memoChangeFromFrozen(wire);
        await (_runtime.db.update(_runtime.db.syncChanges)
              ..where((c) => c.id.equals(row.id)))
            .write(SyncChangesCompanion(frozenRequest: d.Value(wire)));
      }
      result = await (_runtime.db.select(
        _runtime.db.syncChanges,
      )..where((c) => c.id.equals(row.id))).getSingle();
    });
    return result;
  }

  /// 执行applyMemoPushOutcome对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyMemoPushOutcome(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String accountId,
  ) async {
    final book = await (_runtime.db.select(
      _runtime.db.memoBooks,
    )..where((b) => b.id.equals(change.memoBookId!))).getSingle();
    if (book.scopeAccountId != accountId) throw StateError('MEMO_SCOPE');
    switch (outcome.status) {
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
          PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
        final revision = outcome.revision;
        final syncId = outcome.syncId;
        final restoring =
            change.entityType == 'memo_book' &&
            change.action == 'upsert' &&
            (jsonDecode(change.payload) as Map<String, dynamic>)['restore'] ==
                true;
        if (revision == null ||
            revision < 1 ||
            syncId == null ||
            (!restoring && book.syncId != null && book.syncId != syncId)) {
          throw const FormatException('MEMO_OUTCOME_VERSION');
        }
        if (change.entityType == 'memo_book') {
          await _runtime.ackPrivateBook(
            change,
            outcome,
            accountId,
            book: memoBookFromRow(book),
            table: _runtime.db.memoBooks,
            contents: _runtime.db.memoEntries,
            parentColumn: 'memo_book_id',
          );
        } else {
          final local = await (_runtime.db.select(
            _runtime.db.memoEntries,
          )..where((e) => e.id.equals(change.entityId))).getSingle();
          if (local.memoBookId != book.id) throw StateError('MEMO_PARENT');
          if (revision > (local.serverRevision ?? 0)) {
            await (_runtime.db.update(_runtime.db.memoEntries)
                  ..where((e) => e.id.equals(local.id)))
                .write(MemoEntriesCompanion(serverRevision: d.Value(revision)));
          }
        }
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
        final payload = _runtime.privateBookConflictPayload(outcome);
        await _runtime.privateBookConflict(change, payload, accountId);
      default:
        throw const FormatException('MEMO_OUTCOME_STATUS');
    }
  }

  /// 执行resolveMemoConflict对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> resolveMemoConflict(
    SyncConflict conflict,
    String? account, {
    required bool keepLocal,
  }) async {
    if (account == null ||
        conflict.accountId != account ||
        conflict.memoBookId == null) {
      throw StateError('冲突不属于当前账号');
    }
    await _runtime.inAccountTransaction(account, () async {
      final current = await (_runtime.db.select(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(conflict.id))).getSingle();
      if (current.status != 'OPEN') return;
      final book = await memoBook(current.memoBookId!);
      if (book == null || book.scopeAccountId != account) {
        throw StateError('MEMO_SCOPE');
      }
      final remote = Map<String, dynamic>.from(
        jsonDecode(current.remotePayload) as Map,
      );
      final deleted = remote['deleted'] == true || remote['deleted_at'] != null;
      final whole =
          book.isStale ||
          book.deletedAt != null ||
          current.entityType == 'memo_book' && deleted;
      final tail = await _runtime.pendingChange(
        current.entityType,
        current.entityId,
        account,
        tail: true,
      );
      if (keepLocal && (deleted || whole)) {
        if (whole) {
          await memoRepository!.preserveBook(book.id, current.id);
        } else {
          final entry = await (_runtime.db.select(
            _runtime.db.memoEntries,
          )..where((e) => e.id.equals(current.entityId))).getSingle();
          await memoRepository!.preserveEntry(entry, current.id);
        }
      }
      await (_runtime.db.delete(_runtime.db.syncChanges)..where(
            (c) =>
                c.accountId.equals(account) &
                c.pushedAt.isNull() &
                (whole
                    ? c.memoBookId.equals(book.id)
                    : c.entityType.equals(current.entityType) &
                          c.entityId.equals(current.entityId)),
          ))
          .go();
      await (_runtime.db.update(_runtime.db.syncConflicts)..where(
            (c) =>
                c.accountId.equals(account) &
                c.status.equals('OPEN') &
                (whole
                    ? c.memoBookId.equals(book.id)
                    : c.id.equals(current.id)),
          ))
          .write(
            SyncConflictsCompanion(
              status: d.Value(keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE'),
              resolvedAt: d.Value(DateTime.now().toUtc()),
            ),
          );
      if (current.entityType == 'memo_book') {
        await (_runtime.db.update(
          _runtime.db.memoBooks,
        )..where((b) => b.id.equals(book.id))).write(
          const MemoBooksCompanion(pendingLocalDelete: d.Value(false)),
        );
      }
      if (keepLocal && !deleted && !whole) {
        final payload = tail?.payload ?? current.localPayload;
        final action =
            tail?.action ??
            ((jsonDecode(payload) as Map)['deleted'] == true
                ? 'delete'
                : 'upsert');
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: current.entityType,
                entityId: current.entityId,
                memoBookId: d.Value(book.id),
                accountId: d.Value(account),
                action: action,
                payload: payload,
                updatedAt: DateTime.now().toUtc(),
                mutationId: const Uuid().v4(),
                baseRevision: d.Value(current.remoteRevision),
              ),
            );
      } else if (current.entityType == 'memo_book') {
        await applyMemoBookPayload(current.entityId, {
          ...remote,
          'revision': current.remoteRevision,
        }, account);
      } else {
        await applyMemoEntryPayload(current.entityId, {
          ...remote,
          'memo_book_id': book.id,
          'revision': current.remoteRevision,
        }, account);
      }
    });
  }
}

/// 笔记本与条目的拉取、推送、保护和冲突处理所需的外部协作端口。
class MemoSyncHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const MemoSyncHandlerPorts({
    required this.operationsQuarantinePrivateBook,
    required this.pullDiscoverBookDirectory,
    required this.pushPushPending,
  });

  /// 委托operations域执行quarantinePrivateBook。
  final Future<void> Function(
    SyncTarget target,
    String account, {
    required bool stale,
    required bool deleted,
    required private_books.PrivateBook book,
    required d.TableInfo table,
    required d.TableInfo contents,
    required String parentColumn,
    required Future<void> Function(String branch) protect,
  })
  operationsQuarantinePrivateBook;

  /// 委托pull域执行discoverBookDirectory。
  final Future<void> Function(SyncDomain domain) pullDiscoverBookDirectory;

  /// 委托push域执行pushPending。
  final Future<void> Function(String account, {SyncTarget? target})
  pushPushPending;
}
