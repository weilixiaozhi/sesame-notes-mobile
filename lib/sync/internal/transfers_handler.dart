import 'dart:convert';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'sync_runtime.dart';

/// 跨本复制和搬迁的持久快照与发布步骤。
class BookTransferHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  BookTransferHandler(
    this._runtime,
    this._ports, {
    required this.localSelfIdLoader,
    required this.memoRepository,
    required this.repo,
  });
  final SyncRuntime _runtime;
  final BookTransferHandlerPorts _ports;
  final Future<String> Function()? localSelfIdLoader;
  final MemoRepository? memoRepository;
  final LocalLedgerRepository? repo;

  /// 执行transferSource对应的同步步骤，沿用所属域的身份与事务规则。
  Future<({String? syncId, bool deleted, bool stale})> transferSource(
    SyncTarget target,
    String account,
  ) async {
    switch (target.type) {
      case 'ledger':
        final b = await (_runtime.db.select(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(target.id))).getSingle();
        if (b.scopeAccountId != account || b.storageMode != 'cloud') {
          throw StateError('数据不属于当前账号');
        }
        return (
          syncId: b.syncId,
          deleted: b.deletedAt != null,
          stale: b.bindingStatus == 'stale',
        );
      case 'day_book':
        final b = await (_runtime.db.select(
          _runtime.db.dayBooks,
        )..where((b) => b.id.equals(target.id))).getSingle();
        if (b.scopeAccountId != account || b.storageMode != 'cloud') {
          throw StateError('数据不属于当前账号');
        }
        return (
          syncId: b.syncId,
          deleted: b.deletedAt != null,
          stale: b.isStale,
        );
      case 'memo_book':
        final b = await _ports.memosMemoBook(target.id);
        if (b == null ||
            b.scopeAccountId != account ||
            b.storageMode != 'cloud') {
          throw StateError('数据不属于当前账号');
        }
        return (
          syncId: b.syncId,
          deleted: b.deletedAt != null,
          stale: b.isStale,
        );
      case 'fitness_space':
        final b = await _ports.fitnessFitnessSpace(target.id);
        if (b == null ||
            b.scopeAccountId != account ||
            b.storageMode != 'cloud') {
          throw StateError('数据不属于当前账号');
        }
        return (
          syncId: b.syncId,
          deleted: b.deletedAt != null,
          stale: b.isStale,
        );
      default:
        throw StateError('此操作需要完整本子');
    }
  }

  /// 执行transferToLocal对应的同步步骤，沿用所属域的身份与事务规则。
  Future<String> transferToLocal(
    SyncTarget target, {
    required bool move,
    String? expectedFullCursor,
  }) async {
    final account = _runtime.currentAccountIdForCloudOperation('复制或移动数据');
    if (move) {
      final table = const {
        'ledger': 'ledgers',
        'day_book': 'day_books',
        'memo_book': 'memo_books',
        'fitness_space': 'fitness_spaces',
      }[target.type];
      if (table == null) throw StateError('此操作需要完整本子');
      if ((await _runtime.db
              .customSelect(
                'SELECT id FROM $table WHERE id=? AND storage_mode=\'local\' AND scope_account_id IS NULL',
                variables: [d.Variable(target.id)],
              )
              .get())
          .isNotEmpty) {
        return target.id;
      }
    }
    await transferSource(target, account);
    await _ports.pushPushPending(account, target: target);
    final source = await transferSource(target, account);
    var operation = move
        ? 'local-move:$account:${target.type}:${target.id}:${source.syncId}'
        : const Uuid().v4();
    var copy = move ? await transferCopy(target, account, operation) : null;
    if (copy != null && !copy.hidden) return copy.id;

    if (source.stale) throw StateError('绑定失效，请先保留本机副本');
    if (source.deleted && copy == null) throw StateError('数据已删除');
    // 仅推送本次操作范围，其他本失败不影响明确的单本转换。
    await _ports.pushPushPending(account, target: target);
    final afterPush = await transferSource(target, account);
    if (afterPush.deleted && copy != null) {
      // 记账以 deletedAt 保存离线删除意图，仍有请求或冲突时不能当成云端确认。
      await requireTransferSettled(target, account);
      await publishTransferCopy(target, copy.id, account);
      return copy.id;
    }
    final rejected =
        await (_runtime.db.select(_runtime.db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(account) &
                  _runtime.scopeChanges(c, target) &
                  c.entityType.equals(target.type) &
                  c.action.equals('delete') &
                  c.rejectionReason.isNotNull() &
                  c.pushedAt.isNull(),
            ))
            .getSingleOrNull();
    if (rejected != null && expectedFullCursor == null) {
      throw StateError('请重新预览并确认此本的转换');
    }
    await requireTransferSettled(target, account, ignored: rejected?.id);
    String? snapshotCursor;
    switch (target.type) {
      case 'ledger':
        snapshotCursor = await _ports.accountingFullLedger(ledgerId: target.id);
      case 'day_book':
        await _ports.facadeFullDayBook(
          dayBookId: target.id,
          refreshPendingDelete: rejected != null,
        );
      case 'memo_book':
        await _ports.facadeFullMemoBook(memoBookId: target.id);
      case 'fitness_space':
        await _ports.facadeFullFitnessSpace(target.id);
    }
    late String copyId;
    await _runtime.inAccountTransaction(account, () async {
      await requireTransferSettled(target, account, ignored: rejected?.id);
      final current = await transferSource(target, account);
      if (source.syncId != null && current.syncId != source.syncId ||
          current.deleted ||
          current.stale) {
        throw StateError('数据绑定已变化');
      }
      if (move && source.syncId == null) {
        operation =
            'local-move:$account:${target.type}:${target.id}:${current.syncId}';
      }
      if (rejected != null) {
        await (_runtime.db.delete(
          _runtime.db.syncChanges,
        )..where((c) => c.id.equals(rejected.id))).go();
      }
      copyId = await writeTransferCopy(
        target,
        account,
        operation,
        hidden: move,
      );
      if (move) {
        await queueScopeDelete(
          target,
          account,
          expectedFullCursor: expectedFullCursor ?? snapshotCursor,
        );
      }
    });
    if (!move) return copyId;
    await _ports.pushPushPending(account, target: target);
    final pending =
        await (_runtime.db.select(_runtime.db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(account) &
                  _runtime.scopeChanges(c, target) &
                  c.pushedAt.isNull(),
            ))
            .get();
    final deleted = (await transferSource(target, account)).deleted;
    if (pending.isNotEmpty || !deleted) {
      throw StateError('云端删除尚未确认，本机副本已保留，请从全局同步继续');
    }
    await publishTransferCopy(target, copyId, account);
    return copyId;
  }

  /// 执行requireTransferSettled对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> requireTransferSettled(
    SyncTarget target,
    String account, {
    int? ignored,
  }) async {
    final pending =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (c) =>
                    c.accountId.equals(account) &
                    _runtime.scopeChanges(c, target) &
                    c.pushedAt.isNull() &
                    (ignored == null
                        ? const d.Constant(true)
                        : c.id.equals(ignored).not()),
              )
              ..limit(1))
            .getSingleOrNull();
    final conflicts =
        await (_runtime.db.select(_runtime.db.syncConflicts)
              ..where(
                (c) =>
                    c.accountId.equals(account) &
                    c.status.equals('OPEN') &
                    _runtime.scopeConflicts(c, target),
              )
              ..limit(1))
            .getSingleOrNull();
    if (pending != null || conflicts != null) throw StateError('请先处理待同步内容或冲突');
  }

  /// 执行transferCopy对应的同步步骤，沿用所属域的身份与事务规则。
  Future<({String id, bool hidden})?> transferCopy(
    SyncTarget target,
    String account,
    String operation,
  ) async {
    switch (target.type) {
      case 'ledger':
        final id = const Uuid().v5(Namespace.url.value, operation);
        final b =
            await (_runtime.db.select(_runtime.db.ledgers)..where(
                  (b) =>
                      b.id.equals(id) &
                      b.storageMode.equals('local') &
                      b.originLedgerId.equals(target.id) &
                      b.originAccountId.equals(account),
                ))
                .getSingleOrNull();
        return b == null
            ? null
            : (id: b.id, hidden: b.bindingStatus == 'pending_local_move');
      case 'day_book':
        final b =
            await (_runtime.db.select(_runtime.db.dayBooks)..where(
                  (b) =>
                      b.sourceOperationId.equals(operation) &
                      b.sourceAccountId.equals(account) &
                      b.sourceDayBookId.equals(target.id) &
                      b.storageMode.equals('local'),
                ))
                .getSingleOrNull();
        return b == null ? null : (id: b.id, hidden: b.isHidden);
      case 'memo_book':
        final b =
            await (_runtime.db.select(_runtime.db.memoBooks)..where(
                  (b) =>
                      b.sourceOperationId.equals(operation) &
                      b.sourceAccountId.equals(account) &
                      b.sourceMemoBookId.equals(target.id) &
                      b.storageMode.equals('local'),
                ))
                .getSingleOrNull();
        return b == null ? null : (id: b.id, hidden: b.isHidden);
      case 'fitness_space':
        final b =
            await (_runtime.db.select(_runtime.db.fitnessSpaces)..where(
                  (b) =>
                      b.sourceOperationId.equals(operation) &
                      b.sourceAccountId.equals(account) &
                      b.sourceFitnessSpaceId.equals(target.id) &
                      b.storageMode.equals('local'),
                ))
                .getSingleOrNull();
        return b == null ? null : (id: b.id, hidden: b.isHidden);
      default:
        return null;
    }
  }

  /// 执行writeTransferCopy对应的同步步骤，沿用所属域的身份与事务规则。
  Future<String> writeTransferCopy(
    SyncTarget target,
    String account,
    String operation, {
    required bool hidden,
  }) async {
    switch (target.type) {
      case 'ledger':
        if (repo == null || localSelfIdLoader == null) {
          throw StateError('本机数据服务尚未就绪');
        }
        final source = await transferSource(target, account);
        final id = const Uuid().v5(Namespace.url.value, operation);
        final existing = await (_runtime.db.select(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(id))).getSingleOrNull();
        if (existing != null &&
            (existing.storageMode != 'local' ||
                existing.bindingStatus != 'pending_local_move' ||
                existing.originLedgerId != target.id ||
                existing.originAccountId != account)) {
          throw StateError('副本身份冲突，原数据保持不变');
        }
        return hidden
            ? repo!.forkCloudLedgerToLocalPendingMove(
                sourceLedgerId: target.id,
                newLedgerId: id,
                localSelfId: await localSelfIdLoader!(),
                currentAccountId: account,
                originSyncId: source.syncId,
                overwrite: true,
              )
            : repo!.copyCloudLedgerToLocal(
                sourceLedgerId: target.id,
                newLedgerId: id,
                localSelfId: await localSelfIdLoader!(),
                currentAccountId: account,
                originSyncId: source.syncId,
              );
      case 'day_book':
        final copy = await _ports.daysRequiredDayRepository().copyToLocal(
          target.id,
          accountId: account,
          operationId: operation,
          hidden: hidden,
        );
        if (hidden) await _ports.daysRefreshDayMoveCopy(target.id, copy.id);
        return copy.id;
      case 'memo_book':
        if (memoRepository == null) throw StateError('本机数据服务尚未就绪');
        final id = await memoRepository!.copyToLocalForAccountExit(
          target.id,
          operation,
        );
        if (hidden) await refreshMemoTransferCopy(target.id, id);
        await (_runtime.db.update(_runtime.db.memoBooks)
              ..where((b) => b.id.equals(id)))
            .write(MemoBooksCompanion(isHidden: d.Value(hidden)));
        return id;
      case 'fitness_space':
        final id = await _ports
            .fitnessFitnessSpaceRepository()
            .copyToLocalForAccountExit(target.id, operation);
        if (hidden) await refreshFitnessTransferCopy(target.id, id);
        await (_runtime.db.update(_runtime.db.fitnessSpaces)
              ..where((b) => b.id.equals(id)))
            .write(FitnessSpacesCompanion(isHidden: d.Value(hidden)));
        return id;
      default:
        throw StateError('此操作需要完整本子');
    }
  }

  /// 执行queueScopeDelete对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> queueScopeDelete(
    SyncTarget target,
    String account, {
    String? expectedFullCursor,
  }) async {
    switch (target.type) {
      case 'ledger':
        final source = await (_runtime.db.select(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(target.id))).getSingle();
        if (source.role != 'owner') throw StateError('只有所有者可以移动或删除云端原本');
        if (expectedFullCursor == null) throw StateError('请先完成整个本子的下载');
        // 队列时钟与正文记录同一次 UTC 删除意图，冻结包络使用队列毫秒时间。
        final updatedAt = DateTime.now().toUtc();
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'ledger',
                entityId: target.id,
                ledgerId: d.Value(target.id),
                accountId: d.Value(account),
                action: 'delete',
                payload: jsonEncode({
                  'expected_full_cursor': expectedFullCursor,
                  'updated_at': updatedAt.toIso8601String(),
                }),
                updatedAt: updatedAt,
                mutationId: const Uuid().v4(),
              ),
            );
      case 'day_book':
        final source = await (_runtime.db.select(
          _runtime.db.dayBooks,
        )..where((b) => b.id.equals(target.id))).getSingle();
        await (_runtime.db.update(_runtime.db.dayBooks)
              ..where((b) => b.id.equals(target.id)))
            .write(const DayBooksCompanion(pendingLocalDelete: d.Value(false)));
        await _ports.daysRequiredDayRepository().deleteBook(
          await _ports.daysRequiredDayRepository().target(target.id),
          expectedFullCursor: expectedFullCursor ?? source.fullCursor,
        );
      case 'memo_book':
        await (_runtime.db.update(
          _runtime.db.memoBooks,
        )..where((b) => b.id.equals(target.id))).write(
          const MemoBooksCompanion(pendingLocalDelete: d.Value(false)),
        );
        final fixed = await memoRepository!.target(target.id);
        final book = await memoRepository!.requireTarget(fixed);
        await memoRepository!.deleteBook(
          fixed,
          expectedCount: book.entryCount,
          expectedFullCursor: expectedFullCursor,
        );
      case 'fitness_space':
        await (_runtime.db.update(
          _runtime.db.fitnessSpaces,
        )..where((b) => b.id.equals(target.id))).write(
          const FitnessSpacesCompanion(pendingLocalDelete: d.Value(false)),
        );
        final fixed = await _ports.fitnessFitnessSpaceRepository().target(
          target.id,
        );
        final book = await _ports.fitnessFitnessSpaceRepository().requireTarget(
          fixed,
        );
        await _ports.fitnessFitnessSpaceRepository().deleteBook(
          fixed,
          expectedCount: book.entityCount,
          expectedFullCursor: expectedFullCursor,
        );
    }
  }

  /// 执行publishTransferCopy对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> publishTransferCopy(
    SyncTarget target,
    String id,
    String account,
  ) => _runtime.inAccountTransaction(account, () async {
    if (target.type == 'ledger') {
      await (_runtime.db.update(_runtime.db.ledgers)
            ..where((b) => b.id.equals(target.id)))
          .write(LedgersCompanion(deletedAt: d.Value(DateTime.now().toUtc())));
    }
    await publishCopyOnly(target, id);
  });

  /// 执行publishCopyOnly对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> publishCopyOnly(SyncTarget target, String id) async {
    switch (target.type) {
      case 'ledger':
        await (_runtime.db.update(_runtime.db.ledgers)
              ..where((b) => b.id.equals(id)))
            .write(const LedgersCompanion(bindingStatus: d.Value(null)));
      case 'day_book':
        await (_runtime.db.update(_runtime.db.dayBooks)
              ..where((b) => b.id.equals(id)))
            .write(const DayBooksCompanion(isHidden: d.Value(false)));
      case 'memo_book':
        await (_runtime.db.update(_runtime.db.memoBooks)
              ..where((b) => b.id.equals(id)))
            .write(const MemoBooksCompanion(isHidden: d.Value(false)));
      case 'fitness_space':
        await (_runtime.db.update(_runtime.db.fitnessSpaces)
              ..where((b) => b.id.equals(id)))
            .write(const FitnessSpacesCompanion(isHidden: d.Value(false)));
    }
  }

  /// 只更新尚未发布的副本，重试保持条目映射和导入去重事实。
  Future<void> refreshMemoTransferCopy(String sourceId, String copyId) async {
    final source = await _ports.memosMemoBook(sourceId);
    final originals = await (_runtime.db.select(
      _runtime.db.memoEntries,
    )..where((e) => e.memoBookId.equals(sourceId))).get();
    final copied = await (_runtime.db.select(
      _runtime.db.memoEntries,
    )..where((e) => e.memoBookId.equals(copyId))).get();
    final ids = {
      for (final e in copied)
        if (e.sourceEntryId != null) e.sourceEntryId!: e.id,
    };
    final keep = <String>{};
    for (final e in originals) {
      final id = ids.putIfAbsent(e.id, () => const Uuid().v4());
      keep.add(id);
      await _runtime.db
          .into(_runtime.db.memoEntries)
          .insertOnConflictUpdate(
            e
                .copyWith(
                  id: id,
                  memoBookId: copyId,
                  sourceEntryId: d.Value(e.id),
                  serverRevision: const d.Value(null),
                )
                .toCompanion(true),
          );
    }
    await (_runtime.db.delete(_runtime.db.memoEntries)..where(
          (e) =>
              e.memoBookId.equals(copyId) &
              (keep.isEmpty ? const d.Constant(true) : e.id.isNotIn(keep)),
        ))
        .go();
    await (_runtime.db.update(
      _runtime.db.memoBooks,
    )..where((b) => b.id.equals(copyId))).write(
      MemoBooksCompanion(
        name: d.Value(source!.name),
        updatedAt: d.Value(source.updatedAt),
      ),
    );
    await (_runtime.db.delete(
      _runtime.db.memoImportReceipts,
    )..where((r) => r.targetMemoBookId.equals(copyId))).go();
    final receipts = await (_runtime.db.select(
      _runtime.db.memoImportReceipts,
    )..where((r) => r.targetMemoBookId.equals(sourceId))).get();
    for (final r in receipts) {
      await _runtime.db
          .into(_runtime.db.memoImportReceipts)
          .insert(
            r
                .copyWith(
                  targetMemoBookId: copyId,
                  localEntryId: d.Value(
                    r.localEntryId == null ? null : ids[r.localEntryId],
                  ),
                )
                .toCompanion(true),
          );
    }
  }

  /// 执行refreshFitnessTransferCopy对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> refreshFitnessTransferCopy(
    String sourceId,
    String copyId,
  ) async {
    final source = (await _ports.fitnessFitnessSpace(sourceId))!;
    final records = await FitnessDataTransfer.snapshot(
      _runtime.db,
      fitnessSpaceId: sourceId,
      accountId: source.scopeAccountId,
    );
    await FitnessDataTransfer.clearSpaceContents(_runtime.db, copyId);
    await (_runtime.db.update(
      _runtime.db.fitnessSpaces,
    )..where((b) => b.id.equals(copyId))).write(
      FitnessSpacesCompanion(
        name: d.Value(source.name),
        createdAt: d.Value(source.createdAt),
        updatedAt: d.Value(source.updatedAt),
        isStale: const d.Value(false),
      ),
    );
    final receipts = await (_runtime.db.select(
      _runtime.db.fitnessImportReceipts,
    )..where((r) => r.fitnessSpaceId.equals(sourceId))).get();
    await FitnessDataTransfer.importDocument(
      db: _runtime.db,
      receipts: [
        for (final r in receipts)
          {
            'export_id': r.exportId,
            'entity_type': r.entityType,
            'source_id': r.sourceId,
            'target_id': r.targetId,
            'imported_at': r.importedAt.millisecondsSinceEpoch,
          },
      ],
      document: FitnessTransferDocument(
        const Uuid().v4(),
        DateTime.now().toUtc(),
        records,
        space: fitnessSpaceFromRow(source),
      ),
      fitnessSpaceId: copyId,
    );
  }
}

/// 跨本复制和搬迁的持久快照与发布步骤所需的外部协作端口。
class BookTransferHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const BookTransferHandlerPorts({
    required this.accountingFullLedger,
    required this.daysRefreshDayMoveCopy,
    required this.daysRequiredDayRepository,
    required this.facadeFullDayBook,
    required this.facadeFullFitnessSpace,
    required this.facadeFullMemoBook,
    required this.fitnessFitnessSpace,
    required this.fitnessFitnessSpaceRepository,
    required this.memosMemoBook,
    required this.pushPushPending,
  });

  /// 委托accounting域执行fullLedger。
  final Future<String> Function({required String ledgerId})
  accountingFullLedger;

  /// 委托days域执行refreshDayMoveCopy。
  final Future<void> Function(String sourceId, String copyId)
  daysRefreshDayMoveCopy;

  /// 委托days域执行requiredDayRepository。
  final DayRepository Function() daysRequiredDayRepository;

  /// 委托facade域执行fullDayBook。
  final Future<void> Function({
    required String dayBookId,
    bool refreshPendingDelete,
  })
  facadeFullDayBook;

  /// 委托facade域执行fullFitnessSpace。
  final Future<void> Function(String spaceId) facadeFullFitnessSpace;

  /// 委托facade域执行fullMemoBook。
  final Future<void> Function({required String memoBookId}) facadeFullMemoBook;

  /// 委托fitness域执行fitnessSpace。
  final Future<FitnessSpaceRow?> Function(String id) fitnessFitnessSpace;

  /// 委托fitness域执行fitnessSpaceRepository。
  final FitnessSpaceRepository Function() fitnessFitnessSpaceRepository;

  /// 委托memos域执行memoBook。
  final Future<MemoBookRow?> Function(String id) memosMemoBook;

  /// 委托push域执行pushPending。
  final Future<void> Function(String account, {SyncTarget? target})
  pushPushPending;
}
