import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 统一处理本地与远端版本的冲突选择。
class SyncConflictHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  SyncConflictHandler(this._runtime, this._ports);
  final SyncRuntime _runtime;
  final SyncConflictHandlerPorts _ports;

  /// 执行resolveConflict对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> resolveConflict(String id, {required bool keepLocal}) async {
    final account = _runtime.currentAccountIdForCloudOperation('处理同步冲突');
    await _runtime.inAccountTransaction(account, () async {
      final conflict = await (_runtime.db.select(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(id))).getSingleOrNull();
      if (conflict == null) throw StateError('冲突不存在');
      if (conflict.accountId != account) throw StateError('冲突不属于当前账号');
      if (conflict.entityType == 'category') {
        throw StateError('分类冲突必须比较云端版本后单独确认，不能创建分类副本');
      }
      if (conflict.status != 'OPEN') return;
      final remote = Map<String, dynamic>.from(
        jsonDecode(conflict.remotePayload) as Map,
      );
      final deleted = remote['deleted'] == true || remote['deleted_at'] != null;
      if (keepLocal && deleted) {
        final tail = await _runtime.pendingChange(
          conflict.entityType,
          conflict.entityId,
          account,
          tail: true,
        );
        final locallyDeleted =
            tail?.action == 'delete' ||
            tail == null &&
                (jsonDecode(conflict.localPayload) as Map)['deleted'] == true;
        if (!locallyDeleted) {
          final target = conflict.ledgerId != null
              ? SyncTarget('ledger', conflict.ledgerId!)
              : conflict.dayBookId != null
              ? SyncTarget('day_book', conflict.dayBookId!)
              : conflict.memoBookId != null
              ? SyncTarget('memo_book', conflict.memoBookId!)
              : conflict.fitnessSpaceId != null
              ? SyncTarget('fitness_space', conflict.fitnessSpaceId!)
              : SyncTarget(conflict.entityType, conflict.entityId);
          await _ports.operationsProtectTargetToLocal(target);
        }
      }
      // 原身份已经删除时只保留独立本机分支，然后采用墓碑，绝不排入复活请求。
      final rebase = keepLocal && !deleted;
      if (['memo_book', 'fitness_space'].contains(conflict.entityType)) {
        await resolvePrivateParentConflict(
          conflict,
          account,
          keepLocal: rebase,
        );
      } else if (conflict.entityType == 'ledger') {
        await _ports.operationsResolveLedgerConflict(conflict, account);
      } else if (conflict.dayBookId != null) {
        await _ports.daysResolveDayConflict(
          conflict,
          account,
          keepLocal: rebase,
        );
      } else if (conflict.memoBookId != null) {
        await _ports.memosResolveMemoConflict(
          conflict,
          account,
          keepLocal: rebase,
        );
      } else if (fitnessSyncTypes.contains(conflict.entityType)) {
        await _ports.fitnessResolveFitnessConflict(
          conflict,
          account,
          keepLocal: rebase,
        );
      } else if (conflict.entityType == 'transaction') {
        await resolveTransactionProjection(
          conflict,
          account,
          keepLocal: rebase,
        );
      } else {
        throw StateError('此冲突需要重新同步后处理');
      }
      await (_runtime.db.update(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(id))).write(
        SyncConflictsCompanion(
          status: d.Value(keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE'),
          resolvedAt: d.Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  /// 执行resolveTransactionProjection对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> resolveTransactionProjection(
    SyncConflict conflict,
    String? account, {
    required bool keepLocal,
  }) async {
    final current = await (_runtime.db.select(
      _runtime.db.transactions,
    )..where((t) => t.id.equals(conflict.entityId))).getSingleOrNull();
    final ledgerId = current?.ledgerId ?? conflict.ledgerId;
    if (ledgerId == null || ledgerId != conflict.ledgerId) {
      throw StateError('冲突的所属本已变化');
    }
    if (account != null) {
      final ledger = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((b) => b.id.equals(ledgerId))).getSingleOrNull();
      if (ledger == null ||
          ledger.scopeAccountId != account ||
          ledger.storageMode != 'cloud') {
        throw StateError('冲突不属于当前账号');
      }
    }

    await (_runtime.db.delete(_runtime.db.syncChanges)..where(
          (c) =>
              c.entityType.equals('transaction') &
              c.entityId.equals(conflict.entityId) &
              c.pushedAt.isNull() &
              (account == null
                  ? c.accountId.isNull()
                  : c.accountId.equals(account)),
        ))
        .go();
    if (keepLocal) {
      final tx = await (_runtime.db.select(
        _runtime.db.transactions,
      )..where((t) => t.id.equals(conflict.entityId))).getSingle();
      await _runtime.db
          .into(_runtime.db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: tx.id,
              ledgerId: d.Value(conflict.ledgerId),
              accountId: d.Value(account),
              action: tx.deletedAt == null ? 'upsert' : 'delete',
              payload: tx.deletedAt == null
                  ? await _ports.payloadLocalTxPayload(tx)
                  : '{}',
              updatedAt: DateTime.now().toUtc(),
              mutationId: const Uuid().v4(),
              baseRevision: d.Value(conflict.remoteRevision),
            ),
          );
    } else {
      final remote = Map<String, dynamic>.from(
        jsonDecode(conflict.remotePayload) as Map,
      );
      final deleted = remote['deleted'] == true || remote['deleted_at'] != null;
      if (!deleted &&
          (remote['id'] != conflict.entityId ||
              remote['ledger_id'] != ledgerId)) {
        throw StateError('冲突远端内容不属于此记录');
      }
      await _ports.projectionApplyTransaction(
        conflict.entityId,
        deleted ? 'delete' : 'upsert',
        {...remote, 'revision': conflict.remoteRevision},
      );
    }
  }

  /// 执行resolvePrivateParentConflict对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> resolvePrivateParentConflict(
    SyncConflict conflict,
    String account, {
    required bool keepLocal,
  }) async {
    final fitness = conflict.entityType == 'fitness_space';
    final d.TableInfo table = fitness
        ? _runtime.db.fitnessSpaces
        : _runtime.db.memoBooks;
    final book = await _runtime.db
        .customSelect(
          'SELECT * FROM ${table.actualTableName} WHERE id=?',
          variables: [d.Variable(conflict.entityId)],
        )
        .getSingle();
    if (book.readNullable<String>('scope_account_id') != account ||
        book.read<bool>('is_stale')) {
      throw StateError('本同步身份已失效，请保留副本后重新下载');
    }
    final remote = Map<String, dynamic>.from(
      jsonDecode(conflict.remotePayload) as Map,
    );
    final tail = await _runtime.pendingChange(
      conflict.entityType,
      conflict.entityId,
      account,
      tail: true,
    );
    await (_runtime.db.delete(_runtime.db.syncChanges)..where(
          (c) =>
              c.accountId.equals(account) &
              c.entityType.equals(conflict.entityType) &
              c.entityId.equals(conflict.entityId) &
              c.pushedAt.isNull(),
        ))
        .go();
    await (_runtime.db.update(
      _runtime.db.syncConflicts,
    )..where((c) => c.id.equals(conflict.id))).write(
      SyncConflictsCompanion(
        status: d.Value(keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE'),
        resolvedAt: d.Value(DateTime.now().toUtc()),
      ),
    );
    await _runtime.db.customUpdate(
      'UPDATE ${table.actualTableName} SET pending_local_delete=0 WHERE id=?',
      variables: [d.Variable(conflict.entityId)],
      updates: {table},
    );
    if (keepLocal) {
      final payload = tail?.payload ?? conflict.localPayload;
      await _runtime.db
          .into(_runtime.db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: conflict.entityType,
              entityId: conflict.entityId,
              fitnessSpaceId: d.Value(fitness ? conflict.entityId : null),
              memoBookId: d.Value(fitness ? null : conflict.entityId),
              accountId: d.Value(account),
              action:
                  tail?.action ??
                  ((jsonDecode(payload) as Map)['deleted'] == true
                      ? 'delete'
                      : 'upsert'),
              payload: payload,
              updatedAt: DateTime.now().toUtc(),
              mutationId: const Uuid().v4(),
              baseRevision: d.Value(conflict.remoteRevision),
            ),
          );
    } else {
      final payload = {...remote, 'revision': conflict.remoteRevision};
      if (fitness) {
        await _ports.fitnessApplyFitnessSpacePayload(
          conflict.entityId,
          payload,
          account,
        );
      } else {
        await _ports.memosApplyMemoBookPayload(
          conflict.entityId,
          payload,
          account,
        );
      }
    }
  }
}

/// 统一处理本地与远端版本的冲突选择所需的外部协作端口。
class SyncConflictHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const SyncConflictHandlerPorts({
    required this.daysResolveDayConflict,
    required this.fitnessApplyFitnessSpacePayload,
    required this.fitnessResolveFitnessConflict,
    required this.memosApplyMemoBookPayload,
    required this.memosResolveMemoConflict,
    required this.operationsProtectTargetToLocal,
    required this.operationsResolveLedgerConflict,
    required this.payloadLocalTxPayload,
    required this.projectionApplyTransaction,
  });

  /// 委托days域执行resolveDayConflict。
  final Future<void> Function(
    SyncConflict conflict,
    String? accountId, {
    required bool keepLocal,
  })
  daysResolveDayConflict;

  /// 委托fitness域执行applyFitnessSpacePayload。
  final Future<void> Function(
    String id,
    Map<String, dynamic> payload,
    String account,
  )
  fitnessApplyFitnessSpacePayload;

  /// 委托fitness域执行resolveFitnessConflict。
  final Future<void> Function(
    SyncConflict conflict,
    String? account, {
    required bool keepLocal,
  })
  fitnessResolveFitnessConflict;

  /// 委托memos域执行applyMemoBookPayload。
  final Future<void> Function(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  )
  memosApplyMemoBookPayload;

  /// 委托memos域执行resolveMemoConflict。
  final Future<void> Function(
    SyncConflict conflict,
    String? account, {
    required bool keepLocal,
  })
  memosResolveMemoConflict;

  /// 委托operations域执行protectTargetToLocal。
  final Future<String> Function(SyncTarget target)
  operationsProtectTargetToLocal;

  /// 委托operations域执行resolveLedgerConflict。
  final Future<void> Function(SyncConflict conflict, String? account)
  operationsResolveLedgerConflict;

  /// 委托payload域执行localTxPayload。
  final Future<String> Function(dynamic tx) payloadLocalTxPayload;

  /// 委托projection域执行applyTransaction。
  final Future<void> Function(String id, String action, Map<String, dynamic> p)
  projectionApplyTransaction;
}
