import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 按业务域协调目录发现、分页拉取和游标推进。
class SyncPullCoordinator {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  SyncPullCoordinator(
    this._runtime,
    this._ports, {
    required this.dayRepository,
    required this.downloadStore,
    required this.fitnessEnabled,
    required this.memoRepository,
    required this.repo,
  });
  final SyncRuntime _runtime;
  final SyncPullCoordinatorPorts _ports;
  final DayRepository? dayRepository;
  final CloudLedgerDownloadStore? downloadStore;
  final bool fitnessEnabled;
  final MemoRepository? memoRepository;
  final LocalLedgerRepository? repo;

  /// 执行discoverBookDirectory对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> discoverBookDirectory(SyncDomain domain) async {
    final account = _runtime.currentAccountIdForCloudOperation('同步本目录');
    final accounting = domain == SyncDomain.accounting;
    final d.TableInfo table = switch (domain) {
      SyncDomain.accounting => _runtime.db.ledgers,
      SyncDomain.days => _runtime.db.dayBooks,
      SyncDomain.memos => _runtime.db.memoBooks,
      SyncDomain.fitness => _runtime.db.fitnessSpaces,
    };
    GetSyncAccountingFull200Response? accountingSnapshot;
    final ledgerSnapshots = <String, GetSyncFull200Response>{};
    final completedLedgerIds = <String>{};
    Future<({List<Map<String, dynamic>> books, String cursor})>
    directory() async {
      final Map<String, dynamic> response;
      final String key;
      switch (domain) {
        case SyncDomain.accounting:
          final response = await _runtime.api.getSyncAccountingFull();
          final body = response.data!;
          accountingSnapshot = body;
          final books = <Map<String, dynamic>>[];
          for (final block in body.ledgerSnapshots) {
            books.add(
              _runtime.modelMap(
                block.ledger,
                GetSyncFull200ResponseLedger.serializer,
              ),
            );
            ledgerSnapshots[block.ledger.id] = GetSyncFull200Response(
              (b) => b
                ..ledger = block.ledger.toBuilder()
                ..members = block.members.toBuilder()
                ..transactions = block.transactions.toBuilder()
                ..categories = block.categories.toBuilder()
                ..categoryTombstones = block.categoryTombstones.toBuilder()
                ..recurringTransactions = block.recurringTransactions
                    .toBuilder()
                ..exchangeRateOverrides = block.exchangeRateOverrides
                    .toBuilder()
                ..serverCursor = body.serverCursor,
            );
          }
          _runtime.requireAccount(account);
          return (books: books, cursor: body.serverCursor);
        case SyncDomain.days:
          response = _runtime.modelMap(
            (await _runtime.api.getSyncDayBooks()).data!,
            GetSyncDayBooks200Response.serializer,
          );
          key = 'day_books';
        case SyncDomain.memos:
          response = _runtime.modelMap(
            (await _runtime.api.getSyncMemoBooks()).data!,
            GetSyncMemoBooks200Response.serializer,
          );
          key = 'memo_books';
        case SyncDomain.fitness:
          response = _runtime.modelMap(
            (await _runtime.api.getSyncFitnessSpaces()).data!,
            GetSyncFitnessSpaces200Response.serializer,
          );
          key = 'fitness_spaces';
      }
      _runtime.requireAccount(account);
      return (
        books: (response[key] as List)
            .map((b) => Map<String, dynamic>.from(b as Map))
            .toList(),
        cursor: response['server_cursor'] as String,
      );
    }

    Future<void> protect(
      String id, {
      bool stale = false,
      bool deleted = false,
    }) => switch (domain) {
      SyncDomain.accounting => _ports.operationsQuarantineLedger(
        id,
        account,
        stale: stale,
        deleted: deleted,
      ),
      SyncDomain.days => _ports.daysProtectDayBook(
        id,
        account,
        stale: stale,
        deleted: deleted,
      ),
      SyncDomain.memos => _ports.memosProtectMemoBook(
        id,
        account,
        stale: stale,
        deleted: deleted,
      ),
      SyncDomain.fitness => _ports.fitnessProtectFitnessSpace(
        id,
        account,
        stale: stale,
        deleted: deleted,
      ),
    };
    bool stale(d.QueryRow row) => accounting
        ? row.readNullable<String>('binding_status') == 'stale'
        : row.read<bool>('is_stale');
    final list = await directory();
    Future<void> reconcile() async {
      final ids = <String>{};
      for (final meta in list.books) {
        final id = meta['id'] as String;
        if (!ids.add(id)) throw const FormatException('DUPLICATE_BOOK');
        final local = await _runtime.db
            .customSelect(
              'SELECT * FROM ${table.actualTableName} WHERE id=?',
              variables: [d.Variable(id)],
            )
            .getSingleOrNull();
        if (local != null && stale(local)) continue;
        if (accounting && local != null) {
          if (local.read<String>('storage_mode') != 'cloud') continue;
          final binding = local.readNullable<String>('sync_id');
          if (binding != null && binding != meta['sync_id']) {
            await protect(id, stale: true);
            continue;
          }
        }
        if (domain == SyncDomain.memos || domain == SyncDomain.fitness) {
          await _runtime.inAccountTransaction(
            account,
            () => domain == SyncDomain.memos
                ? _ports.memosApplyMemoBookPayload(id, meta, account)
                : _ports.fitnessApplyFitnessSpacePayload(id, meta, account),
          );
        }
        try {
          switch (domain) {
            case SyncDomain.accounting:
              await _ports.accountingApplyFullSnapshot(
                id,
                ledgerSnapshots[id]!,
                accountId: account,
              );
              completedLedgerIds.add(id);
            case SyncDomain.days:
              final full = await _ports.daysDownloadDayBook(
                id,
                account,
                knownSyncId: meta['sync_id'] as String,
              );
              if (BigInt.parse(full.serverCursor) < BigInt.parse(list.cursor)) {
                throw StateError('STALE_FULL');
              }
              await _runtime.inAccountTransaction(
                account,
                () => _ports.daysApplyDayFull(full, account),
              );
            case SyncDomain.memos:
              final full = await _ports.memosDownloadMemoBook(
                id,
                account,
                knownSyncId: meta['sync_id'] as String,
              );
              if (BigInt.parse(full.serverCursor) < BigInt.parse(list.cursor)) {
                throw StateError('STALE_FULL');
              }
              await _runtime.inAccountTransaction(
                account,
                () => _ports.memosApplyMemoFull(full, account),
              );
            case SyncDomain.fitness:
              await _ports.fitnessFullFitness(
                spaceId: id,
                minimumCursor: list.cursor,
              );
          }
        } on DioException catch (error) {
          if (error.response?.statusCode == 412) {
            await _runtime.inAccountTransaction(
              account,
              () => protect(id, stale: true),
            );
          } else if (error.response?.statusCode == 404) {
            final latest = await directory();
            if (BigInt.parse(latest.cursor) < BigInt.parse(list.cursor) ||
                latest.books.any((b) => b['id'] == id)) {
              rethrow;
            }
            await _runtime.inAccountTransaction(
              account,
              () => protect(id, deleted: true),
            );
          } else {
            rethrow;
          }
        }
      }
      await _runtime.inAccountTransaction(account, () async {
        final cached = await _runtime.db
            .customSelect(
              "SELECT * FROM ${table.actualTableName} WHERE storage_mode='cloud' AND scope_account_id=?",
              variables: [d.Variable(account)],
            )
            .get();
        for (final book in cached) {
          final id = book.read<String>('id');
          if (!ids.contains(id) &&
              book.readNullable<String>('sync_id') != null &&
              !stale(book) &&
              book.readNullable<int>('deleted_at') == null) {
            await protect(id, deleted: true);
          }
        }
        switch (domain) {
          case SyncDomain.accounting:
            await _ports.accountingApplyDirectoryGlobals(
              accountingSnapshot!,
              account,
            );
            await _runtime.saveServerCursor(list.cursor);
          case SyncDomain.days:
            await _ports.daysSaveDayCursor(list.cursor);
          case SyncDomain.memos:
            await _ports.memosSaveMemoCursor(list.cursor);
          case SyncDomain.fitness:
            await _ports.fitnessSaveFitnessCursor(list.cursor, account);
        }
      });
    }

    // 记账的账号快照包含共享分类、汇率与所有账本，保留既有整批原子提交。
    if (accounting) {
      await _runtime.inAccountTransaction(account, reconcile);
      // 账号快照全部提交后才解除实际已下载账本的标记，跳过的分支仍待处理。
      for (final id in completedLedgerIds) {
        _runtime.requireAccount(account);
        await downloadStore?.markReady(account, id);
      }
    } else {
      await reconcile();
    }
  }

  /// 执行changeDomain对应的同步步骤，沿用所属域的身份与事务规则。
  SyncDomain changeDomain(GetSyncPull200ResponseChangesInner change) =>
      switch (change.entityType.name) {
        'dayBook' || 'dayEvent' => SyncDomain.days,
        'memoBook' || 'memoEntry' => SyncDomain.memos,
        'fitnessSpace' ||
        'fitnessTemplate' ||
        'fitnessPlan' ||
        'fitnessWorkout' ||
        'fitnessPreferences' => SyncDomain.fitness,
        _ => SyncDomain.accounting,
      };

  /// 四域共享扫描流，各自事务提交与推进；完整轮次只在已完成初始化的域推送。
  Future<int> pullDomains({
    Future<void> Function(Set<SyncDomain> readyDomains)? pushReadyDomains,
  }) async {
    final accountId = _runtime.currentAccountIdForCloudOperation('拉取云端变更');
    final enabled = {
      SyncDomain.accounting,
      if (dayRepository != null) SyncDomain.days,
      if (memoRepository != null) SyncDomain.memos,
      if (fitnessEnabled) SyncDomain.fitness,
    };
    final failures = <SyncDomain, (Object, StackTrace)>{};
    final ready = <SyncDomain>{};
    final cursors = <SyncDomain, BigInt>{};
    Future<void> readState() async {
      final state = await _runtime.domainState();
      cursors.addAll({
        SyncDomain.accounting: BigInt.parse(state?.serverCursor ?? '0'),
        SyncDomain.days: BigInt.parse(state?.dayEventsCursor ?? '0'),
        SyncDomain.memos: BigInt.parse(state?.memosCursor ?? '0'),
        SyncDomain.fitness: BigInt.parse(state?.fitnessCursor ?? '0'),
      });
    }

    Future<void> recover(SyncDomain domain) async {
      try {
        switch (domain) {
          case SyncDomain.accounting:
            await _ports.facadeAccountingFull();
          case SyncDomain.days:
            await _ports.facadeDiscoverDayBooks();
          case SyncDomain.memos:
            await _ports.facadeDiscoverMemoBooks();
          case SyncDomain.fitness:
            await _ports.facadeDiscoverFitnessSpaces();
        }
        ready.add(domain);
        failures.remove(domain);
      } catch (error, stack) {
        failures[domain] = (error, stack);
        ready.remove(domain);
      }
    }

    final initial = await _runtime.domainState();
    for (final domain in enabled) {
      final initialized = switch (domain) {
        SyncDomain.accounting => initial?.serverCursor != null || repo == null,
        SyncDomain.days => initial?.dayEventsCursor != null,
        SyncDomain.memos => initial?.memosCursor != null,
        SyncDomain.fitness => initial?.fitnessCursor != null,
      };
      if (initialized) {
        ready.add(domain);
      } else {
        await recover(domain);
      }
    }
    await readState();
    // 完整快照先建立各域基线，失败域不发送本机旧版本；成功域继续推送及增量消费。
    // 普通 pull 不传回调，仍只拉取；完整轮次复用同一次初始化和扫描，不重复联网。
    if (pushReadyDomains != null && ready.isNotEmpty) {
      _runtime.requireAccount(accountId);
      await pushReadyDomains(Set.unmodifiable(ready));
    }
    BigInt minimum() =>
        ready.map((d) => cursors[d]!).reduce((a, b) => a < b ? a : b);
    var scan = ready.isEmpty ? BigInt.zero : minimum();
    var recovered = false;
    var count = 0;
    final fullLedgerIds = downloadStore != null
        ? await downloadStore!.pending(accountId)
        : <String>{};
    while (ready.isNotEmpty) {
      _runtime.requireAccount(accountId);
      GetSyncPull200Response body;
      try {
        body = (await _runtime.api.getSyncPull(since: scan.toString())).data!;
      } on DioException catch (error) {
        if (error.response?.statusCode != 410 || recovered) rethrow;
        recovered = true;
        ready.clear();
        for (final domain in enabled) {
          await recover(domain);
        }
        await readState();
        // 完整恢复已更新持久下载状态，本轮补拉必须使用恢复后的集合。
        final pending = downloadStore != null
            ? await downloadStore!.pending(accountId)
            : <String>{};
        _runtime.requireAccount(accountId);
        fullLedgerIds
          ..clear()
          ..addAll(pending);
        if (ready.isNotEmpty) scan = minimum();
        continue;
      }
      final next = BigInt.parse(body.serverCursor);
      if (next < scan || (body.hasMore && next == scan)) {
        throw StateError('同步游标没有前进，请重试');
      }
      for (final domain in ready.toList()) {
        final changes = body.changes
            .where(
              (c) =>
                  changeDomain(c) == domain &&
                  BigInt.parse(c.changeId) > cursors[domain]!,
            )
            .toList();
        final cursor = next > cursors[domain]! ? next : cursors[domain]!;
        try {
          switch (domain) {
            case SyncDomain.accounting:
              await pullAccountingPage(
                changes,
                accountId,
                cursor.toString(),
                fullLedgerIds,
              );
            case SyncDomain.days:
              await pullDayPage(changes, accountId, cursor.toString());
            case SyncDomain.memos:
              await pullMemoPage(changes, accountId, cursor.toString());
            case SyncDomain.fitness:
              await _ports.fitnessPullFitnessPage(
                changes,
                accountId,
                cursor.toString(),
              );
          }
          cursors[domain] = cursor;
          count += changes.length;
        } catch (error, stack) {
          _runtime.requireAccount(accountId);
          ready.remove(domain);
          failures[domain] = (error, stack);
          logger.error(
            'SyncService',
            '${domain.name}增量本页未提交',
            error.runtimeType,
            stack,
          );
          if (changes.isNotEmpty &&
              !(domain == SyncDomain.accounting &&
                  _isTemporaryLedgerDownloadFailure(error))) {
            await _runtime.rememberDomainFailure(
              changes.first,
              accountId,
              error,
              stack,
            );
          }
        }
      }
      scan = next;
      if (!body.hasMore) break;
    }
    if (failures.isNotEmpty) {
      final failure = failures.values.first;
      Error.throwWithStackTrace(failure.$1, failure.$2);
    }
    return count;
  }

  /// 账本快照的短暂传输失败保留后台任务，不登记成需要人工处理的数据错误。
  bool _isTemporaryLedgerDownloadFailure(Object error) {
    if (error is! DioException) return false;
    final status = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        status == 408 ||
        status == 429 ||
        status != null && status >= 500;
  }

  /// 执行pullAccountingPage对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> pullAccountingPage(
    List<GetSyncPull200ResponseChangesInner> changes,
    String accountId,
    String cursor,
    Set<String> fullIds,
  ) async {
    final prepared = await _ports.accountingPrepareDownloads(
      fullIds,
      changes,
      accountId,
    );
    await _runtime.inAccountTransaction(accountId, () async {
      final blocked = {
        ...await _ports.accountingBlockedLedgerIds(
          changes.map(
            (change) => change.entityType.name == 'ledger'
                ? change.entityId
                : change.ledgerId,
          ),
        ),
        ...prepared.$2,
      };
      for (final change in changes) {
        // 用户域的账本发现事件没有 ledger_id，仍按实体账本身份执行隔离。
        final ledgerId = change.entityType.name == 'ledger'
            ? change.entityId
            : change.ledgerId;
        if (!blocked.contains(ledgerId)) {
          await _ports.projectionApplyChange(change);
        }
      }
      for (final entry in prepared.$1.entries) {
        await _ports.accountingApplyFullSnapshot(
          entry.key,
          entry.value,
          accountId: accountId,
        );
      }
      await _runtime.saveServerCursor(cursor);
    });
    for (final id in prepared.$1.keys) {
      _runtime.requireAccount(accountId);
      await downloadStore?.markReady(accountId, id);
      fullIds.remove(id);
    }
  }

  /// 执行pullDayPage对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> pullDayPage(
    List<GetSyncPull200ResponseChangesInner> changes,
    String accountId,
    String cursor,
  ) async {
    final snapshots = <GetSyncDayBooksFull200Response>[];
    final gone = <String>{};
    final download = <String>{};
    for (final change in changes) {
      final id = change.dayBookId;
      if (id == null) throw const FormatException('日子事件缺少父本');
      final book = await (_runtime.db.select(
        _runtime.db.dayBooks,
      )..where((b) => b.id.equals(id))).getSingleOrNull();
      if (book == null && change.action.name != 'delete') download.add(id);
    }
    for (final id in download) {
      try {
        snapshots.add(await _ports.daysDownloadDayBook(id, accountId));
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) rethrow;
        final directory = (await _runtime.api.getSyncDayBooks()).data!;
        _runtime.requireAccount(accountId);
        if (BigInt.parse(directory.serverCursor) < BigInt.parse(cursor) ||
            directory.dayBooks.any((b) => b.id == id)) {
          rethrow;
        }
        gone.add(id);
      }
    }
    await _runtime.inAccountTransaction(accountId, () async {
      for (final full in snapshots) {
        await _ports.daysApplyDayFull(full, accountId);
      }
      for (final id in gone) {
        await _ports.daysProtectDayBook(id, accountId, deleted: true);
      }
      for (final change in changes) {
        if (!gone.contains(change.dayBookId)) {
          await _ports.daysApplyDayChange(change, accountId);
        }
      }
      await _ports.daysSaveDayCursor(cursor);
    });
  }

  /// 执行pullMemoPage对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> pullMemoPage(
    List<GetSyncPull200ResponseChangesInner> changes,
    String accountId,
    String cursor,
  ) async {
    final snapshots = <GetSyncMemoBooksFull200Response>[];
    final gone = <String>{};
    final download = <String>{};
    for (final change in changes) {
      final id = change.memoBookId;
      if (id == null) throw const FormatException('MEMO_CHANGE_SCOPE');
      final book = await _ports.memosMemoBook(id);
      if ((book == null || book.fullCursor == null) &&
          change.action.name != 'delete') {
        download.add(id);
      }
    }
    for (final id in download) {
      try {
        snapshots.add(await _ports.memosDownloadMemoBook(id, accountId));
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) rethrow;
        final directory = (await _runtime.api.getSyncMemoBooks()).data!;
        _runtime.requireAccount(accountId);
        if (BigInt.parse(directory.serverCursor) < BigInt.parse(cursor) ||
            directory.memoBooks.any((b) => b.id == id)) {
          rethrow;
        }
        gone.add(id);
      }
    }
    await _runtime.inAccountTransaction(accountId, () async {
      for (final full in snapshots) {
        await _ports.memosApplyMemoFull(full, accountId);
      }
      for (final id in gone) {
        await _ports.memosProtectMemoBook(id, accountId, deleted: true);
      }
      for (final change in changes) {
        if (!gone.contains(change.memoBookId)) {
          await _ports.memosApplyMemoChange(change, accountId);
        }
      }
      await _ports.memosSaveMemoCursor(cursor);
    });
  }
}

/// 按业务域协调目录发现、分页拉取和游标推进所需的外部协作端口。
class SyncPullCoordinatorPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const SyncPullCoordinatorPorts({
    required this.accountingApplyFullSnapshot,
    required this.accountingBlockedLedgerIds,
    required this.accountingApplyDirectoryGlobals,
    required this.daysApplyDayChange,
    required this.daysApplyDayFull,
    required this.daysDownloadDayBook,
    required this.accountingPrepareDownloads,
    required this.daysProtectDayBook,
    required this.daysSaveDayCursor,
    required this.facadeAccountingFull,
    required this.facadeDiscoverDayBooks,
    required this.facadeDiscoverFitnessSpaces,
    required this.facadeDiscoverMemoBooks,
    required this.fitnessApplyFitnessSpacePayload,
    required this.fitnessFullFitness,
    required this.fitnessProtectFitnessSpace,
    required this.fitnessPullFitnessPage,
    required this.fitnessSaveFitnessCursor,
    required this.memosApplyMemoBookPayload,
    required this.memosApplyMemoChange,
    required this.memosApplyMemoFull,
    required this.memosDownloadMemoBook,
    required this.memosMemoBook,
    required this.memosProtectMemoBook,
    required this.memosSaveMemoCursor,
    required this.operationsQuarantineLedger,
    required this.projectionApplyChange,
  });

  /// 委托accounting域执行applyFullSnapshot。
  final Future<void> Function(
    String ledgerId,
    GetSyncFull200Response data, {
    required String accountId,
  })
  accountingApplyFullSnapshot;

  /// 委托accounting域执行blockedLedgerIds。
  final Future<Set<String>> Function(Iterable<String?> candidateIds)
  accountingBlockedLedgerIds;

  /// 委托accounting域执行applyAccountingDirectoryGlobals。
  final Future<void> Function(
    GetSyncAccountingFull200Response body,
    String accountId,
  )
  accountingApplyDirectoryGlobals;

  /// 委托days域执行applyDayChange。
  final Future<void> Function(
    GetSyncPull200ResponseChangesInner change,
    String accountId,
  )
  daysApplyDayChange;

  /// 委托days域执行applyDayFull。
  final Future<void> Function(
    GetSyncDayBooksFull200Response snapshot,
    String accountId,
  )
  daysApplyDayFull;

  /// 委托days域执行downloadDayBook。
  final Future<GetSyncDayBooksFull200Response> Function(
    String id,
    String accountId, {
    String? knownSyncId,
  })
  daysDownloadDayBook;

  /// 委托accounting域执行prepareAccountingDownloads。
  final Future<(Map<String, GetSyncFull200Response>, Set<String>)> Function(
    Set<String> ids,
    List<GetSyncPull200ResponseChangesInner> changes,
    String accountId,
  )
  accountingPrepareDownloads;

  /// 委托days域执行protectDayBook。
  final Future<void> Function(
    String id,
    String accountId, {
    bool stale,
    bool deleted,
  })
  daysProtectDayBook;

  /// 委托days域执行saveDayCursor。
  final Future<void> Function(String cursor) daysSaveDayCursor;

  /// 委托facade域执行accountingFull。
  final Future<void> Function() facadeAccountingFull;

  /// 委托facade域执行discoverDayBooks。
  final Future<void> Function() facadeDiscoverDayBooks;

  /// 委托facade域执行discoverFitnessSpaces。
  final Future<void> Function() facadeDiscoverFitnessSpaces;

  /// 委托facade域执行discoverMemoBooks。
  final Future<void> Function() facadeDiscoverMemoBooks;

  /// 委托fitness域执行applyFitnessSpacePayload。
  final Future<void> Function(
    String id,
    Map<String, dynamic> payload,
    String account,
  )
  fitnessApplyFitnessSpacePayload;

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

  /// 委托fitness域执行pullFitnessPage。
  final Future<void> Function(
    List<GetSyncPull200ResponseChangesInner> changes,
    String account,
    String cursor,
  )
  fitnessPullFitnessPage;

  /// 委托fitness域执行saveFitnessCursor。
  final Future<void> Function(String cursor, String account)
  fitnessSaveFitnessCursor;

  /// 委托memos域执行applyMemoBookPayload。
  final Future<void> Function(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  )
  memosApplyMemoBookPayload;

  /// 委托memos域执行applyMemoChange。
  final Future<void> Function(
    GetSyncPull200ResponseChangesInner change,
    String accountId,
  )
  memosApplyMemoChange;

  /// 委托memos域执行applyMemoFull。
  final Future<void> Function(
    GetSyncMemoBooksFull200Response full,
    String accountId,
  )
  memosApplyMemoFull;

  /// 委托memos域执行downloadMemoBook。
  final Future<GetSyncMemoBooksFull200Response> Function(
    String id,
    String accountId, {
    String? knownSyncId,
  })
  memosDownloadMemoBook;

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

  /// 委托memos域执行saveMemoCursor。
  final Future<void> Function(String cursor) memosSaveMemoCursor;

  /// 委托operations域执行quarantineLedger。
  final Future<void> Function(
    String id,
    String? account, {
    bool stale,
    bool deleted,
    DateTime? remoteDeletedAt,
  })
  operationsQuarantineLedger;

  /// 委托projection域执行applyChange。
  final Future<void> Function(GetSyncPull200ResponseChangesInner change)
  projectionApplyChange;
}
