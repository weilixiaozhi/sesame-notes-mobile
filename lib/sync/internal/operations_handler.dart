import 'dart:convert';
import 'package:sesame_notes/data/models/private_book.dart' as private_books;
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/sync/models/ledger_sync_state.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 删除、恢复和本地保护等同步数据操作。
class SyncDataOperations {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  SyncDataOperations(
    this._runtime,
    this._ports, {
    required this.downloadStore,
    required this.localSelfIdLoader,
    required this.memoRepository,
    required this.repo,
  });
  final SyncRuntime _runtime;
  final SyncDataOperationsPorts _ports;
  final CloudLedgerDownloadStore? downloadStore;
  final Future<String> Function()? localSelfIdLoader;
  final MemoRepository? memoRepository;
  final LocalLedgerRepository? repo;

  /// 执行prepareScopeDelete对应的同步步骤，沿用所属域的身份与事务规则。
  Future<SyncDeletePreview> prepareScopeDelete(SyncTarget target) async {
    final account = _runtime.currentAccountIdForCloudOperation('读取删除预览');
    final source = await _ports.transfersTransferSource(target, account);
    if (source.stale) throw StateError('请先处理同步绑定');
    final branch = await scopeBranchKey(target, account);
    final operation =
        'local-move:$account:${target.type}:${target.id}:${source.syncId}';
    final moving =
        (await _ports.transfersTransferCopy(
          target,
          account,
          operation,
        ))?.hidden ==
        true;
    Map<String, dynamic> parent = {};
    var snapshotJson = '';
    String? cursor;
    var count = 0, gone = false;
    try {
      switch (target.type) {
        case 'ledger':
          final full = (await _runtime.api.getSyncFull(
            ledgerId: target.id,
            syncId: source.syncId,
          )).data!;
          snapshotJson = jsonEncode(
            _runtime.modelMap(full, GetSyncFull200Response.serializer),
          );
          parent = Map<String, dynamic>.from(
            _runtime.modelMap(full, GetSyncFull200Response.serializer)['ledger']
                as Map,
          );
          cursor = full.serverCursor;
          count = full.transactions.length;
        case 'day_book':
          final full = (await _runtime.api.getSyncDayBooksFull(
            dayBookId: target.id,
            syncId: source.syncId,
          )).data!;
          snapshotJson = jsonEncode(
            _runtime.modelMap(full, GetSyncDayBooksFull200Response.serializer),
          );
          parent = _runtime.modelMap(full.dayBook, DayBook.serializer);
          cursor = full.serverCursor;
          count = full.dayEvents.length;
        case 'memo_book':
          final full = (await _runtime.api.getSyncMemoBooksFull(
            memoBookId: target.id,
            syncId: source.syncId,
          )).data!;
          snapshotJson = jsonEncode(
            _runtime.modelMap(full, GetSyncMemoBooksFull200Response.serializer),
          );
          parent = _runtime.modelMap(full.memoBook, MemoBook.serializer);
          cursor = full.serverCursor;
          count = full.memoEntries.length;
        case 'fitness_space':
          final full = (await _runtime.api.getSyncFitnessSpacesFull(
            fitnessSpaceId: target.id,
            syncId: source.syncId,
          )).data!;
          final wire = _runtime.modelMap(
            full,
            GetSyncFitnessSpacesFull200Response.serializer,
          );
          snapshotJson = jsonEncode(wire);
          parent = Map<String, dynamic>.from(wire['fitness_space'] as Map);
          cursor = full.serverCursor;
          count = [
            for (final field in [
              'fitness_templates',
              'fitness_plans',
              'fitness_workouts',
              'fitness_preferences',
            ])
              ...wire[field] as List,
          ].where((row) => (row as Map)['deleted_at'] == null).length;
      }
      if (parent['id'] != target.id ||
          source.syncId != null && parent['sync_id'] != source.syncId) {
        throw const FormatException('删除预览身份不匹配');
      }
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
      gone = true;
    }
    _runtime.requireAccount(account);
    if (await scopeBranchKey(target, account) != branch) {
      throw StateError('本机内容已变化，请重新预览');
    }
    final table = switch (target.type) {
      'ledger' => 'ledgers',
      'day_book' => 'day_books',
      'memo_book' => 'memo_books',
      'fitness_space' => 'fitness_spaces',
      _ => throw StateError('无效的本子'),
    };
    final name =
        parent['name'] as String? ??
        (await _runtime.db
                .customSelect(
                  'SELECT name FROM $table WHERE id=?',
                  variables: [d.Variable(target.id)],
                )
                .getSingle())
            .read<String>('name');
    return SyncDeletePreview(
      target: target,
      accountId: account,
      generation: _runtime.sessionGenerationGetter?.call(),
      branchKey: branch,
      syncId: source.syncId,
      cursor: cursor,
      name: name,
      count: count,
      gone: gone,
      moving: moving,
      snapshotJson: snapshotJson,
    );
  }

  /// 执行confirmScopeDelete对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> confirmScopeDelete(SyncDeletePreview preview) async {
    final account = _runtime.currentAccountIdForCloudOperation('确认删除');
    if (account != preview.accountId ||
        _runtime.sessionGenerationGetter?.call() != preview.generation) {
      throw StateError('账号已变化');
    }
    final target = preview.target;
    await _runtime.inAccountTransaction(account, () async {
      final current = await _ports.transfersTransferSource(
        target,
        preview.accountId,
      );
      if (current.syncId != preview.syncId ||
          current.stale ||
          await scopeBranchKey(target, account) != preview.branchKey) {
        throw StateError('删除预览已变化');
      }
      final pending =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) =>
                    c.accountId.equals(preview.accountId) &
                    c.entityType.equals(target.type) &
                    c.entityId.equals(target.id) &
                    c.pushedAt.isNull(),
              ))
              .get();
      final conflict =
          await (_runtime.db.select(_runtime.db.syncConflicts)
                ..where(
                  (c) =>
                      c.accountId.equals(preview.accountId) &
                      c.entityType.equals(target.type) &
                      c.entityId.equals(target.id) &
                      c.status.equals('OPEN'),
                )
                ..limit(1))
              .getSingleOrNull();
      if (conflict == null &&
          pending.any(
            (c) => c.frozenRequest != null && c.rejectionReason == null,
          )) {
        throw StateError('仍有结果未知的请求，请先同步确认');
      }
      if (preview.gone) {
        switch (target.type) {
          case 'ledger':
            await quarantineLedger(target.id, account, deleted: true);
          case 'day_book':
            await _ports.daysProtectDayBook(
              target.id,
              preview.accountId,
              deleted: true,
            );
          case 'memo_book':
            await _ports.memosProtectMemoBook(
              target.id,
              preview.accountId,
              deleted: true,
            );
          case 'fitness_space':
            await _ports.fitnessProtectFitnessSpace(
              target.id,
              preview.accountId,
              deleted: true,
            );
        }
        return;
      }
      await (_runtime.db.delete(
        _runtime.db.syncChanges,
      )..where((c) => c.id.isIn(pending.map((c) => c.id)))).go();
      await (_runtime.db.update(_runtime.db.syncConflicts)..where(
            (c) =>
                c.accountId.equals(preview.accountId) &
                c.entityType.equals(target.type) &
                c.entityId.equals(target.id) &
                c.status.equals('OPEN'),
          ))
          .write(
            SyncConflictsCompanion(
              status: const d.Value('RESOLVED_LOCAL'),
              resolvedAt: d.Value(DateTime.now().toUtc()),
            ),
          );
      switch (target.type) {
        case 'ledger':
          await _ports.accountingApplyFullSnapshot(
            target.id,
            _runtime.deser(
              preview.snapshotJson,
              GetSyncFull200Response.serializer,
            ),
            accountId: account,
          );
        case 'day_book':
          await (_runtime.db.update(
            _runtime.db.dayBooks,
          )..where((b) => b.id.equals(target.id))).write(
            const DayBooksCompanion(pendingLocalDelete: d.Value(false)),
          );
          await _ports.daysApplyDayFull(
            _runtime.deser(
              preview.snapshotJson,
              GetSyncDayBooksFull200Response.serializer,
            ),
            preview.accountId,
          );
        case 'memo_book':
          await (_runtime.db.update(
            _runtime.db.memoBooks,
          )..where((b) => b.id.equals(target.id))).write(
            const MemoBooksCompanion(pendingLocalDelete: d.Value(false)),
          );
          await _ports.memosApplyMemoFull(
            _runtime.deser(
              preview.snapshotJson,
              GetSyncMemoBooksFull200Response.serializer,
            ),
            preview.accountId,
          );
        case 'fitness_space':
          await (_runtime.db.update(
            _runtime.db.fitnessSpaces,
          )..where((b) => b.id.equals(target.id))).write(
            const FitnessSpacesCompanion(pendingLocalDelete: d.Value(false)),
          );
          await _ports.fitnessFullFitness(
            spaceId: target.id,
            downloaded: _runtime.deser(
              preview.snapshotJson,
              GetSyncFitnessSpacesFull200Response.serializer,
            ),
          );
      }
      if (!preview.moving) {
        await _ports.transfersQueueScopeDelete(
          target,
          preview.accountId,
          expectedFullCursor: preview.cursor,
        );
        if (target.type == 'ledger') {
          await (_runtime.db.update(
            _runtime.db.ledgers,
          )..where((b) => b.id.equals(target.id))).write(
            LedgersCompanion(deletedAt: d.Value(DateTime.now().toUtc())),
          );
        }
      }
    });
    if (preview.moving && !preview.gone) {
      await _ports.transfersTransferToLocal(
        target,
        move: true,
        expectedFullCursor: preview.cursor,
      );
    }
  }

  /// 幂等删除可能来自较早时间线；发布副本前以同一绑定确认原件确实不可用。
  Future<bool> scopeDeleted(SyncTarget target, String? syncId) async {
    try {
      switch (target.type) {
        case 'ledger':
          final full = (await _runtime.api.getSyncFull(
            ledgerId: target.id,
            syncId: syncId,
          )).data!;
          return (_runtime.modelMap(
                    full,
                    GetSyncFull200Response.serializer,
                  )['ledger']
                  as Map)['deleted_at'] !=
              null;
        case 'day_book':
          final full = (await _runtime.api.getSyncDayBooksFull(
            dayBookId: target.id,
            syncId: syncId,
          )).data!;
          return full.dayBook.deletedAt != null;
        case 'memo_book':
          final full = (await _runtime.api.getSyncMemoBooksFull(
            memoBookId: target.id,
            syncId: syncId,
          )).data!;
          return full.memoBook.deletedAt != null;
        case 'fitness_space':
          final full = (await _runtime.api.getSyncFitnessSpacesFull(
            fitnessSpaceId: target.id,
            syncId: syncId,
          )).data!;
          return full.fitnessSpace.deletedAt != null;
        default:
          throw StateError('此操作需要完整本子');
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return true;
      if (error.response?.statusCode == 412) return false;
      rethrow;
    }
  }

  /// 执行scopeBranchKey对应的同步步骤，沿用所属域的身份与事务规则。
  Future<String?> scopeBranchKey(SyncTarget target, String? account) async {
    final pending =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (c) =>
                    _runtime.scopeChanges(c, target) &
                    c.pushedAt.isNull() &
                    (account == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(account)),
              )
              ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
            .get();
    final conflicts =
        await (_runtime.db.select(_runtime.db.syncConflicts)
              ..where(
                (c) =>
                    _runtime.scopeConflicts(c, target) &
                    c.status.equals('OPEN') &
                    (account == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(account)),
              )
              ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
            .get();
    if (pending.isEmpty && conflicts.isEmpty) return null;
    return const Uuid().v5(
      Namespace.url.value,
      jsonEncode([
        pending.map((c) => c.toJson()).toList(),
        conflicts.map((c) => c.toJson()).toList(),
      ]),
    );
  }

  /// 失效绑定只暂停；权威整本删除在保护本机分支后退休无效队列，规则全局一致。
  Future<void> quarantineScope(
    SyncTarget target,
    String? account, {
    required bool stale,
    required bool deleted,
    required Future<void> Function(String branch) protect,
    required Future<void> Function() mark,
  }) async {
    final branch = await scopeBranchKey(target, account);
    final localDelete =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (c) =>
                    _runtime.scopeChanges(c, target) &
                    c.entityType.equals(target.type) &
                    c.entityId.equals(target.id) &
                    c.pushedAt.isNull() &
                    (account == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(account)),
              )
              ..orderBy([(c) => d.OrderingTerm.desc(c.id)])
              ..limit(1))
            .getSingleOrNull();
    if (branch != null && (!deleted || localDelete?.action != 'delete')) {
      try {
        await protect(branch);
      } catch (error, stack) {
        if (!stale || deleted) rethrow;
        // 保护失败仍冻结失效绑定，原内容和未知请求保持原样，供全局入口重试。
        logger.error(
          'SyncService',
          '保护副本未完成，原内容仍保留',
          safeErrorSummary(error),
          stack,
        );
      }
    }
    if (deleted) await clearTargetPending(target, account, retire: true);
    await mark();
    if (deleted &&
        account != null &&
        [
          'ledger',
          'day_book',
          'memo_book',
          'fitness_space',
        ].contains(target.type)) {
      final source = await _ports.transfersTransferSource(target, account);
      final copy = await _ports.transfersTransferCopy(
        target,
        account,
        'local-move:$account:${target.type}:${target.id}:${source.syncId}',
      );
      if (copy != null && copy.hidden) {
        await _ports.transfersPublishTransferCopy(target, copy.id, account);
      }
    }
  }

  /// 私有本父本共用隔离：保护未确认分支，再写失效/墓碑并级联子内容。
  Future<void> quarantinePrivateBook(
    SyncTarget target,
    String account, {
    required bool stale,
    required bool deleted,
    required private_books.PrivateBook book,
    required d.TableInfo table,
    required d.TableInfo contents,
    required String parentColumn,
    required Future<void> Function(String branch) protect,
  }) => quarantineScope(
    target,
    account,
    stale: stale,
    deleted: deleted,
    protect: protect,
    mark: () async {
      final now = DateTime.now().toUtc();
      final values = <String, Object?>{
        'is_stale': !deleted && (stale || book.isStale),
        if (deleted) 'deleted_at': now.millisecondsSinceEpoch,
        if (deleted) 'pending_local_delete': 0,
      };
      await _runtime.db.customUpdate(
        'UPDATE ${table.actualTableName} SET ${values.keys.map((key) => '$key=?').join(',')} WHERE id=?',
        variables: [
          for (final value in values.values) d.Variable(value),
          d.Variable(book.id),
        ],
        updates: {table},
      );
      if (!deleted) return;
      await _runtime.db.customUpdate(
        'UPDATE ${contents.actualTableName} SET deleted_at=? WHERE $parentColumn=?',
        variables: [
          d.Variable(now.millisecondsSinceEpoch),
          d.Variable(book.id),
        ],
        updates: {contents},
      );
    },
  );

  /// 执行quarantineLedger对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> quarantineLedger(
    String id,
    String? account, {
    bool stale = false,
    bool deleted = false,
    DateTime? remoteDeletedAt,
  }) async {
    final source = await (_runtime.db.select(
      _runtime.db.ledgers,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (source == null) return;
    if (account != null && source.scopeAccountId != account) {
      throw StateError('数据不属于当前账号');
    }
    await quarantineScope(
      SyncTarget('ledger', id),
      account,
      stale: stale,
      deleted: deleted,
      protect: (_) async {
        if (await _ports.accountingProtectLocalStateAsFork(id) ==
            LocalStateProtection.failed) {
          throw StateError('保护副本未完成');
        }
      },
      mark: () async {
        await (_runtime.db.update(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(id))).write(
          LedgersCompanion(
            bindingStatus: deleted
                ? const d.Value(null)
                : stale
                ? const d.Value('stale')
                : const d.Value.absent(),
            deletedAt: deleted
                ? d.Value(remoteDeletedAt ?? DateTime.now().toUtc())
                : const d.Value.absent(),
          ),
        );
      },
    );
  }

  /// 采纳整本云端墓碑并清理原身份的待推意图，本机副本由统一冲突入口保存。
  Future<void> resolveLedgerConflict(
    SyncConflict conflict,
    String? account,
  ) async {
    if (account == null || conflict.accountId != account) {
      throw StateError('冲突不属于当前账号');
    }
    await _runtime.inAccountTransaction(account, () async {
      final current = await (_runtime.db.select(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(conflict.id))).getSingle();
      if (current.status != 'OPEN') return;
      final remote = Map<String, dynamic>.from(
        jsonDecode(current.remotePayload) as Map,
      );
      if (remote['deleted'] != true && remote['deleted_at'] == null) {
        throw StateError('请重新同步此本再处理');
      }
      final target = SyncTarget('ledger', current.entityId);
      final source = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((b) => b.id.equals(target.id))).getSingle();
      if (source.scopeAccountId != account) throw StateError('数据不属于当前账号');
      await clearTargetPending(target, account);
      await _ports.projectionApplyLedger(
        target.id,
        'delete',
        remote,
        DateTime.now().toUtc(),
      );
      await (_runtime.db.update(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(current.id))).write(
        SyncConflictsCompanion(
          status: const d.Value('RESOLVED_REMOTE'),
          resolvedAt: d.Value(DateTime.now().toUtc()),
        ),
      );
    });
  }

  /// 用户重试与自动依赖恢复共用明确拒收的重新登记规则。
  Future<void> retryRejectedChange(String id) async {
    final account = _runtime.currentAccountIdForCloudOperation('重试未上传记录');
    if (!await _runtime.rejectionRecovery.retryRejectedChange(
      int.parse(id),
      account,
    )) {
      final rejected =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) =>
                    c.id.equals(int.parse(id)) &
                    c.accountId.equals(account) &
                    c.pushedAt.isNull(),
              ))
              .getSingleOrNull();
      if (rejected?.rejectionReason != null) {
        throw StateError('仍有结果未知的请求，请先同步确认');
      }
    }
  }

  /// 完整本地保护不要求失效绑定重新联网；每个源范围使用稳定操作身份避免重复副本。
  Future<String> protectTargetToLocal(SyncTarget target) async {
    final account = _runtime.currentAccountIdForCloudOperation('保留本机副本');
    final branchKey =
        await scopeBranchKey(target, account) ?? const Uuid().v4();
    final operation =
        'local-protection:$account:${target.type}:${target.id}:$branchKey';
    return inAccountResult(account, () async {
      switch (target.type) {
        case 'ledger':
          final source = await (_runtime.db.select(
            _runtime.db.ledgers,
          )..where((b) => b.id.equals(target.id))).getSingle();
          if (source.scopeAccountId != account ||
              source.storageMode != 'cloud') {
            throw StateError('数据不属于当前账号');
          }
          final key = await _ports.accountingLocalStateProtectionKey(source.id);
          if (key != null) {
            if (await _ports.accountingProtectLocalStateAsFork(source.id) !=
                LocalStateProtection.protected) {
              throw StateError('修改仍保留，副本创建失败，请重试');
            }
            final copy =
                await (_runtime.db.select(_runtime.db.ledgers)
                      ..where(
                        (b) =>
                            b.originLedgerId.equals(source.id) &
                            b.originBackupId.equals(key) &
                            b.originType.equals('DR_PROTECT') &
                            b.storageMode.equals('local') &
                            b.syncId.isNull() &
                            b.bindingStatus.isNull() &
                            b.deletedAt.isNull(),
                      )
                      ..limit(1))
                    .getSingle();
            return copy.id;
          }
          final id = const Uuid().v4();
          if (repo == null || localSelfIdLoader == null) {
            throw StateError('本机数据服务尚未就绪');
          }
          return repo!.protectCloudLedgerToLocalFork(
            sourceLedgerId: source.id,
            targetLedgerId: id,
            localSelfId: await localSelfIdLoader!(),
            currentAccountId: account,
          );
        case 'day_book':
          final source = await (_runtime.db.select(
            _runtime.db.dayBooks,
          )..where((b) => b.id.equals(target.id))).getSingle();
          return (await _ports.daysRequiredDayRepository().copyToLocal(
            source.id,
            accountId: account,
            operationId: '$operation:${source.syncId}',
          )).id;
        case 'memo_book':
          final source = await _ports.memosMemoBook(target.id);
          if (source == null || memoRepository == null) {
            throw StateError('数据不存在');
          }
          return memoRepository!.copyToLocalForAccountExit(
            source.id,
            '$operation:${source.syncId}',
          );
        case 'fitness_space':
          final source = await _ports.fitnessFitnessSpace(target.id);
          if (source == null || source.scopeAccountId != account) {
            throw StateError('数据不属于当前账号');
          }
          return _ports
              .fitnessFitnessSpaceRepository()
              .copyToLocalForAccountExit(
                source.id,
                '$operation:${source.syncId}',
              );
        default:
          if (fitnessSyncTypes.contains(target.type)) {
            final source = await _ports.fitnessFitnessEntity(target.id);
            if (source == null || source.scopeAccountId != account) {
              throw StateError('数据不属于当前账号');
            }
            return _ports
                .fitnessFitnessSpaceRepository()
                .copyToLocalForAccountExit(source.fitnessSpaceId, operation);
          }
          throw StateError('此记录应从所属本保护');
      }
    });
  }

  /// 执行inAccountResult对应的同步步骤，沿用所属域的身份与事务规则。
  Future<T> inAccountResult<T>(
    String account,
    Future<T> Function() work,
  ) async {
    late T result;
    await _runtime.inAccountTransaction(account, () async {
      result = await work();
    });
    return result;
  }

  /// 网络读取在事务外；保护、退休旧请求和应用新快照在同一事务，失败不能放开旧绑定。
  Future<void> replaceProtected<T>(
    SyncTarget target,
    String account, {
    required Future<T> Function() download,
    required Future<void> Function(T) apply,
    required Future<void> Function() validate,
  }) async {
    final snapshot = await download();
    await _runtime.inAccountTransaction(account, () async {
      await validate();
      String? previousCopy;
      if ([
        'ledger',
        'day_book',
        'memo_book',
        'fitness_space',
      ].contains(target.type)) {
        final source = await _ports.transfersTransferSource(target, account);
        final operation =
            'local-move:$account:${target.type}:${target.id}:${source.syncId}';
        final copy = await _ports.transfersTransferCopy(
          target,
          account,
          operation,
        );
        if (copy?.hidden == true) {
          previousCopy = await _ports.transfersWriteTransferCopy(
            target,
            account,
            operation,
            hidden: true,
          );
        }
      }
      if (previousCopy == null &&
          await scopeBranchKey(target, account) != null) {
        await protectTargetToLocal(target);
      }
      await clearTargetPending(target, account);
      await apply(snapshot);
      // 新时间线不继承旧的删除意图；旧隐藏副本成为可用的保护副本。
      if (previousCopy != null) {
        await _ports.transfersPublishCopyOnly(target, previousCopy);
      }
    });
  }

  /// 执行refreshTarget对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> refreshTarget(SyncTarget target) async {
    final account = _runtime.currentAccountIdForCloudOperation('重新下载数据');
    switch (target.type) {
      case 'ledger':
        final source = await (_runtime.db.select(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(target.id))).getSingleOrNull();
        if (source == null) {
          await _ports.facadeFull(ledgerId: target.id);
          return;
        }
        if (source.scopeAccountId != account) throw StateError('数据不属于当前账号');
        if (source.bindingStatus != 'stale') {
          await _ports.facadeFull(ledgerId: target.id);
          return;
        }
        await replaceProtected(
          target,
          account,
          download: () async {
            final reply = (await _runtime.api.getSyncFull(
              ledgerId: target.id,
            )).data!;
            if (reply.ledger.id != target.id) {
              throw const FormatException('快照身份不匹配');
            }
            return reply;
          },
          validate: () => _ports.accountingRequireStaleBinding(target.id),
          apply: (reply) async {
            await _ports.accountingApplyFullSnapshot(
              target.id,
              reply,
              accountId: account,
            );
            await (_runtime.db.update(
              _runtime.db.ledgers,
            )..where((b) => b.id.equals(target.id))).write(
              LedgersCompanion(
                syncId: d.Value(reply.ledger.syncId),
                bindingStatus: const d.Value(null),
              ),
            );
          },
        );
        _runtime.requireAccount(account);
        await downloadStore?.markReady(account, target.id);
      case 'day_book':
        final source = await (_runtime.db.select(
          _runtime.db.dayBooks,
        )..where((b) => b.id.equals(target.id))).getSingle();
        if (source.scopeAccountId != account) throw StateError('数据不属于当前账号');
        if (!source.isStale) {
          await _ports.facadeFullDayBook(dayBookId: target.id);
          return;
        }
        await replaceProtected(
          target,
          account,
          download: () async {
            final directory = (await _runtime.api.getSyncDayBooks()).data!;
            _runtime.requireAccount(account);
            final meta = directory.dayBooks
                .where((b) => b.id == target.id)
                .firstOrNull;
            if (meta == null) throw StateError('云端数据已不存在，请保留本机副本');
            final reply = (await _runtime.api.getSyncDayBooksFull(
              dayBookId: target.id,
              syncId: meta.syncId,
            )).data!;
            if (reply.dayBook.id != target.id ||
                reply.dayBook.syncId != meta.syncId) {
              throw const FormatException('快照身份不匹配');
            }
            return reply;
          },
          validate: () async {
            final fresh = await (_runtime.db.select(
              _runtime.db.dayBooks,
            )..where((b) => b.id.equals(target.id))).getSingle();
            if (fresh.syncId != source.syncId ||
                !fresh.isStale ||
                fresh.scopeAccountId != account) {
              throw StateError('绑定已变化，请重新操作');
            }
          },
          apply: (reply) async {
            await (_runtime.db.update(
              _runtime.db.dayBooks,
            )..where((b) => b.id.equals(target.id))).write(
              DayBooksCompanion(
                // 在同一事务内先进入合法的未绑定状态，再由完整快照建立新版本。
                syncId: const d.Value(null),
                serverRevision: const d.Value(0),
                fullCursor: const d.Value(null),
                isStale: const d.Value(false),
                pendingLocalDelete: const d.Value(false),
                deletedAt: const d.Value(null),
              ),
            );
            await (_runtime.db.update(_runtime.db.dayEvents)
                  ..where((e) => e.dayBookId.equals(target.id)))
                .write(const DayEventsCompanion(serverRevision: d.Value(0)));
            await _ports.daysApplyDayFull(reply, account);
          },
        );
      case 'memo_book':
        final source = await _ports.memosMemoBook(target.id);
        if (source == null || source.scopeAccountId != account) {
          throw StateError('数据不属于当前账号');
        }
        if (!source.isStale) {
          await _ports.facadeFullMemoBook(memoBookId: target.id);
          return;
        }
        await replaceProtected(
          target,
          account,
          download: () async {
            final directory = (await _runtime.api.getSyncMemoBooks()).data!;
            _runtime.requireAccount(account);
            final meta = directory.memoBooks
                .where((b) => b.id == target.id)
                .firstOrNull;
            if (meta == null || meta.type.name != source.type) {
              throw StateError('云端数据已不存在，请保留本机副本');
            }
            final reply = (await _runtime.api.getSyncMemoBooksFull(
              memoBookId: target.id,
              syncId: meta.syncId,
            )).data!;
            if (reply.memoBook.id != target.id ||
                reply.memoBook.syncId != meta.syncId) {
              throw const FormatException('快照身份不匹配');
            }
            return reply;
          },
          validate: () async {
            final fresh = await _ports.memosMemoBook(target.id);
            if (fresh == null ||
                fresh.syncId != source.syncId ||
                !fresh.isStale ||
                fresh.scopeAccountId != account) {
              throw StateError('绑定已变化，请重新操作');
            }
          },
          apply: (reply) async {
            await (_runtime.db.update(
              _runtime.db.memoBooks,
            )..where((b) => b.id.equals(target.id))).write(
              MemoBooksCompanion(
                // 零修订只属于未绑定状态，完整快照会同时写入新绑定与权威修订。
                syncId: const d.Value(null),
                serverRevision: const d.Value(0),
                fullCursor: const d.Value(null),
                isStale: const d.Value(false),
                pendingLocalDelete: const d.Value(false),
                deletedAt: const d.Value(null),
              ),
            );
            await (_runtime.db.update(_runtime.db.memoEntries)
                  ..where((e) => e.memoBookId.equals(target.id)))
                .write(const MemoEntriesCompanion(serverRevision: d.Value(0)));
            await _ports.memosApplyMemoFull(reply, account);
          },
        );
      case 'fitness_space':
        final source = await _ports.fitnessFitnessSpace(target.id);
        if (source == null || source.scopeAccountId != account) {
          throw StateError('数据不属于当前账号');
        }
        if (!source.isStale) {
          await _ports.facadeFullFitnessSpace(target.id);
          return;
        }
        await replaceProtected(
          target,
          account,
          download: () async {
            final reply = (await _runtime.api.getSyncFitnessSpacesFull(
              fitnessSpaceId: target.id,
            )).data!;
            _runtime.requireAccount(account);
            if (reply.fitnessSpace.id != target.id) {
              throw const FormatException('快照身份不匹配');
            }
            return reply;
          },
          validate: () async {
            final fresh = await _ports.fitnessFitnessSpace(target.id);
            if (fresh == null ||
                fresh.syncId != source.syncId ||
                !fresh.isStale ||
                fresh.scopeAccountId != account) {
              throw StateError('绑定已变化');
            }
          },
          apply: (reply) async {
            await (_runtime.db.update(
              _runtime.db.fitnessSpaces,
            )..where((b) => b.id.equals(target.id))).write(
              const FitnessSpacesCompanion(
                syncId: d.Value(null),
                serverRevision: d.Value(0),
                fullCursor: d.Value(null),
                isStale: d.Value(false),
                pendingLocalDelete: d.Value(false),
                deletedAt: d.Value(null),
              ),
            );
            await (_runtime.db.delete(
              _runtime.db.fitnessEntities,
            )..where((e) => e.fitnessSpaceId.equals(target.id))).go();
            await _ports.fitnessFullFitness(
              spaceId: target.id,
              downloaded: reply,
            );
          },
        );
      default:
        throw StateError('此记录应从所属本重新下载');
    }
  }

  /// 执行clearTargetPending对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> clearTargetPending(
    SyncTarget target,
    String? account, {
    bool retire = false,
  }) async {
    d.Expression<bool> pending(SyncChanges c) =>
        _runtime.scopeChanges(c, target) &
        c.pushedAt.isNull() &
        (account == null ? c.accountId.isNull() : c.accountId.equals(account));
    if (retire) {
      await (_runtime.db.update(_runtime.db.syncChanges)..where(pending)).write(
        SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())),
      );
    } else {
      await (_runtime.db.delete(_runtime.db.syncChanges)..where(pending)).go();
    }
    await (_runtime.db.update(_runtime.db.syncConflicts)..where(
          (c) =>
              _runtime.scopeConflicts(c, target) &
              c.status.equals('OPEN') &
              (account == null
                  ? c.accountId.isNull()
                  : c.accountId.equals(account)),
        ))
        .write(
          SyncConflictsCompanion(
            status: const d.Value('RESOLVED_REMOTE'),
            resolvedAt: d.Value(DateTime.now().toUtc()),
          ),
        );
  }
}

/// 删除、恢复和本地保护等同步数据操作所需的外部协作端口。
class SyncDataOperationsPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const SyncDataOperationsPorts({
    required this.accountingApplyFullSnapshot,
    required this.accountingLocalStateProtectionKey,
    required this.accountingProtectLocalStateAsFork,
    required this.accountingRequireStaleBinding,
    required this.daysApplyDayFull,
    required this.daysProtectDayBook,
    required this.daysRequiredDayRepository,
    required this.facadeFull,
    required this.facadeFullDayBook,
    required this.facadeFullFitnessSpace,
    required this.facadeFullMemoBook,
    required this.fitnessFitnessEntity,
    required this.fitnessFitnessSpace,
    required this.fitnessFitnessSpaceRepository,
    required this.fitnessFullFitness,
    required this.fitnessProtectFitnessSpace,
    required this.memosApplyMemoFull,
    required this.memosMemoBook,
    required this.memosProtectMemoBook,
    required this.projectionApplyLedger,
    required this.transfersPublishCopyOnly,
    required this.transfersPublishTransferCopy,
    required this.transfersQueueScopeDelete,
    required this.transfersTransferCopy,
    required this.transfersTransferSource,
    required this.transfersTransferToLocal,
    required this.transfersWriteTransferCopy,
  });

  /// 委托accounting域执行applyFullSnapshot。
  final Future<void> Function(
    String ledgerId,
    GetSyncFull200Response data, {
    required String accountId,
  })
  accountingApplyFullSnapshot;

  /// 委托accounting域执行localStateProtectionKey。
  final Future<String?> Function(String ledgerId)
  accountingLocalStateProtectionKey;

  /// 委托accounting域执行protectLocalStateAsFork。
  final Future<LocalStateProtection> Function(String ledgerId)
  accountingProtectLocalStateAsFork;

  /// 委托accounting域执行requireStaleBinding。
  final Future<void> Function(String ledgerId) accountingRequireStaleBinding;

  /// 委托days域执行applyDayFull。
  final Future<void> Function(
    GetSyncDayBooksFull200Response snapshot,
    String accountId,
  )
  daysApplyDayFull;

  /// 委托days域执行protectDayBook。
  final Future<void> Function(
    String id,
    String accountId, {
    bool stale,
    bool deleted,
  })
  daysProtectDayBook;

  /// 委托days域执行requiredDayRepository。
  final DayRepository Function() daysRequiredDayRepository;

  /// 委托facade域执行full。
  final Future<void> Function({required String ledgerId}) facadeFull;

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

  /// 委托fitness域执行fitnessEntity。
  final Future<FitnessEntityRow?> Function(String id) fitnessFitnessEntity;

  /// 委托fitness域执行fitnessSpace。
  final Future<FitnessSpaceRow?> Function(String id) fitnessFitnessSpace;

  /// 委托fitness域执行fitnessSpaceRepository。
  final FitnessSpaceRepository Function() fitnessFitnessSpaceRepository;

  /// 委托fitness域执行fullFitness。
  final Future<void> Function({
    required String spaceId,
    String? minimumCursor,
    GetSyncFitnessSpacesFull200Response? downloaded,
  })
  fitnessFullFitness;

  /// 委托fitness域执行protectFitnessSpace。
  final Future<void> Function(
    String id,
    String account, {
    bool stale,
    bool deleted,
  })
  fitnessProtectFitnessSpace;

  /// 委托memos域执行applyMemoFull。
  final Future<void> Function(
    GetSyncMemoBooksFull200Response full,
    String accountId,
  )
  memosApplyMemoFull;

  /// 委托memos域执行memoBook。
  final Future<MemoBookRow?> Function(String id) memosMemoBook;

  /// 委托memos域执行protectMemoBook。
  final Future<void> Function(
    String id,
    String accountId, {
    bool stale,
    bool deleted,
  })
  memosProtectMemoBook;

  /// 委托projection域执行applyLedger。
  final Future<void> Function(
    String id,
    String action,
    Map<String, dynamic> p,
    DateTime eventUpdatedAt,
  )
  projectionApplyLedger;

  /// 委托transfers域执行publishCopyOnly。
  final Future<void> Function(SyncTarget target, String id)
  transfersPublishCopyOnly;

  /// 委托transfers域执行publishTransferCopy。
  final Future<void> Function(SyncTarget target, String id, String account)
  transfersPublishTransferCopy;

  /// 委托transfers域执行queueScopeDelete。
  final Future<void> Function(
    SyncTarget target,
    String account, {
    String? expectedFullCursor,
  })
  transfersQueueScopeDelete;

  /// 委托transfers域执行transferCopy。
  final Future<({String id, bool hidden})?> Function(
    SyncTarget target,
    String account,
    String operation,
  )
  transfersTransferCopy;

  /// 委托transfers域执行transferSource。
  final Future<({String? syncId, bool deleted, bool stale})> Function(
    SyncTarget target,
    String account,
  )
  transfersTransferSource;

  /// 委托transfers域执行transferToLocal。
  final Future<String> Function(
    SyncTarget target, {
    required bool move,
    String? expectedFullCursor,
  })
  transfersTransferToLocal;

  /// 委托transfers域执行writeTransferCopy。
  final Future<String> Function(
    SyncTarget target,
    String account,
    String operation, {
    required bool hidden,
  })
  transfersWriteTransferCopy;
}
