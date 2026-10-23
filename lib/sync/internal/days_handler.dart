import 'dart:convert';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/data/models/private_book.dart' as private_books;
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/models/day_event.dart' as days;
import 'package:sesame_notes/data/models/day_book.dart' as day_books;
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 日子本与记录的拉取、推送、保护和冲突处理。
class DaySyncHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  DaySyncHandler(this._runtime, this._ports, {required this.dayRepository});
  final SyncRuntime _runtime;
  final DaySyncHandlerPorts _ports;
  final DayRepository? dayRepository;

  /// 完整目录建立日子域屏障，不用单本快照提升全局水位。
  Future<void> discoverDayBooks() =>
      _ports.pullDiscoverBookDirectory(SyncDomain.days);

  /// 局部恢复只更新指定本及其完整快照边界。
  Future<void> fullDayBook({
    required String dayBookId,
    bool refreshPendingDelete = false,
  }) async {
    final accountId = dayAccount();
    try {
      final snapshot = await downloadDayBook(dayBookId, accountId);
      await _runtime.inAccountTransaction(accountId, () async {
        final book = await (_runtime.db.select(
          _runtime.db.dayBooks,
        )..where((b) => b.id.equals(dayBookId))).getSingleOrNull();
        final temporarilyUnfreeze =
            refreshPendingDelete && book?.pendingLocalDelete == true;
        if (temporarilyUnfreeze) {
          await (_runtime.db.update(
            _runtime.db.dayBooks,
          )..where((b) => b.id.equals(dayBookId))).write(
            const DayBooksCompanion(pendingLocalDelete: d.Value(false)),
          );
        }
        await applyDayFull(snapshot, accountId);
        if (temporarilyUnfreeze) {
          await (_runtime.db.update(
            _runtime.db.dayBooks,
          )..where((b) => b.id.equals(dayBookId))).write(
            const DayBooksCompanion(pendingLocalDelete: d.Value(true)),
          );
        }
      });
    } on DioException catch (error, stackTrace) {
      if (error.response?.statusCode == 412) {
        await _runtime.inAccountTransaction(
          accountId,
          () => protectDayBook(dayBookId, accountId, stale: true),
        );
      }
      logger.error(
        'SyncService',
        '日子本快照下载失败: $dayBookId',
        error.runtimeType,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 日子云操作必须同时拥有会话和日期校验仓储。
  String dayAccount() {
    final accountId = _runtime.currentAccountIdForCloudOperation('同步日子');
    if (dayRepository == null) {
      throw StateError('日子同步暂不可用，请重新登录后重试');
    }
    return accountId;
  }

  /// 下载前后的同本身份必须一致；本地已知绑定优先于目录元数据。
  Future<GetSyncDayBooksFull200Response> downloadDayBook(
    String id,
    String accountId, {
    String? knownSyncId,
  }) async {
    final local = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    // 本机模式的日子本不能被云端快照接管：绑定、归属与本机/云端模式必须同时成立。
    if (local != null &&
        (local.scopeAccountId != accountId ||
            local.storageMode != 'cloud' ||
            local.isStale)) {
      throw StateError('日子本绑定不可用');
    }
    final expected = local?.syncId ?? knownSyncId;
    final result = (await _runtime.api.getSyncDayBooksFull(
      dayBookId: id,
      syncId: expected,
    )).data!;
    _runtime.requireAccount(accountId);
    if (result.dayBook.id != id ||
        (expected != null && result.dayBook.syncId != expected)) {
      throw StateError('日子本快照绑定不匹配');
    }
    final current = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (current?.syncId != local?.syncId ||
        current?.scopeAccountId != local?.scopeAccountId ||
        current?.isStale == true) {
      throw StateError('日子本在下载期间发生变化，请重试');
    }
    return result;
  }

  /// 单本快照及边界同事务应用，集合外未确认分支仍然保留。
  Future<void> applyDayFull(
    GetSyncDayBooksFull200Response snapshot,
    String accountId,
  ) async {
    final id = snapshot.dayBook.id;
    final before = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (before != null &&
        (before.scopeAccountId != accountId ||
            before.isStale ||
            (before.syncId != null &&
                before.syncId != snapshot.dayBook.syncId))) {
      throw StateError('日子本绑定已变化');
    }
    await applyDayBookPayload(
      id,
      _runtime.modelMap(snapshot.dayBook, DayBook.serializer),
      accountId,
    );
    final ids = <String>{};
    for (final event in snapshot.dayEvents) {
      if (event.dayBookId != id ||
          event.syncId != snapshot.dayBook.syncId ||
          !ids.add(event.id)) {
        throw const FormatException('日子快照父子关系无效');
      }
      await applyDayEventPayload(
        event.id,
        _runtime.modelMap(event, DayEvent.serializer),
        accountId,
      );
    }
    final current = await (_runtime.db.select(
      _runtime.db.dayEvents,
    )..where((e) => e.dayBookId.equals(id) & e.deletedAt.isNull())).get();
    for (final row in current) {
      if (!ids.contains(row.id) &&
          !await hasDayRisk('day_event', row.id, accountId)) {
        await (_runtime.db.update(
          _runtime.db.dayEvents,
        )..where((e) => e.id.equals(row.id))).write(
          DayEventsCompanion(deletedAt: d.Value(DateTime.now().toUtc())),
        );
      }
    }
    final previous = before?.fullCursor;
    final cursor =
        previous != null &&
            BigInt.parse(previous) > BigInt.parse(snapshot.serverCursor)
        ? previous
        : snapshot.serverCursor;
    await (_runtime.db.update(_runtime.db.dayBooks)
          ..where((b) => b.id.equals(id)))
        .write(DayBooksCompanion(fullCursor: d.Value(cursor)));
  }

  /// 多条队列和 OPEN 事实使用存在性查询，不能要求唯一队列行。
  Future<bool> hasDayRisk(String type, String id, String accountId) async {
    if (await _runtime.pendingChange(type, id, accountId) != null) return true;
    return await (_runtime.db.select(_runtime.db.syncConflicts)
              ..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.entityType.equals(type) &
                    c.entityId.equals(id) &
                    c.status.equals('OPEN'),
              )
              ..limit(1))
            .getSingleOrNull() !=
        null;
  }

  /// 本元数据采用 revision 比较，未确认本地分支与远端分支分别保留。
  Future<void> applyDayBookPayload(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  ) async {
    final local = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (local != null &&
        (local.scopeAccountId != accountId || local.storageMode != 'cloud')) {
      throw StateError('日子本身份不可接管');
    }
    if (local?.isStale == true) return;
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      await protectDayBook(id, accountId, deleted: true);
      return;
    }
    final remote = _runtime.deser(jsonEncode(payload), DayBook.serializer);
    if (remote.id != id || remote.revision < 1) {
      throw const FormatException('日子本快照无效');
    }
    if (local?.syncId != null && local!.syncId != remote.syncId) {
      await protectDayBook(id, accountId, stale: true);
      return;
    }
    if (local != null && remote.revision <= (local.serverRevision ?? 0)) return;
    final pending = await _runtime.pendingChange('day_book', id, accountId);
    if (pending != null) {
      if (pending.frozenRequest == null ||
          await refreshOpenDayConflict(
            'day_book',
            id,
            accountId,
            payload,
            remote.revision,
          )) {
        await upsertDayConflict(
          head: pending,
          remotePayload: jsonEncode(payload),
          remoteRevision: remote.revision,
        );
      }
      // 冻结请求与本地名称保留；完整快照确认的绑定必须先建立才能持久化本级水位。
      if (local?.syncId == null) {
        await (_runtime.db.update(
          _runtime.db.dayBooks,
        )..where((b) => b.id.equals(id))).write(
          DayBooksCompanion(
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
          ),
        );
      }
      return;
    }
    if (await refreshOpenDayConflict(
      'day_book',
      id,
      accountId,
      payload,
      remote.revision,
    )) {
      return;
    }
    await _runtime.db
        .into(_runtime.db.dayBooks)
        .insertOnConflictUpdate(
          DayBooksCompanion.insert(
            id: id,
            name: day_books.normalizeDayName(remote.name),
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountId),
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
            createdAt: remote.createdAt,
            updatedAt: remote.updatedAt,
          ),
        );
  }

  /// 记录权威定义只在同账号同绑定父本下应用，不走时间戳 LWW。
  Future<void> applyDayEventPayload(
    String id,
    Map<String, dynamic> payload,
    String accountId,
  ) async {
    final local = await (_runtime.db.select(
      _runtime.db.dayEvents,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    final bookId = payload['day_book_id'] as String? ?? local?.dayBookId;
    if (bookId == null) throw const FormatException('日子缺少父本');
    final book = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(bookId))).getSingleOrNull();
    if (book == null ||
        book.scopeAccountId != accountId ||
        (local != null && local.dayBookId != bookId)) {
      throw StateError('日子父本不可访问');
    }
    if (book.isStale || book.deletedAt != null || book.pendingLocalDelete) {
      return;
    }
    if (payload['sync_id'] != null && payload['sync_id'] != book.syncId) {
      throw StateError('日子记录绑定不匹配');
    }
    final revision = payload['revision'] as int;
    // 零版本墓碑是云端明确不存在的事实，不能按历史修订水位忽略用户的远端决策。
    final remoteMissing = revision == 0 && payload['deleted'] == true;
    if (local != null &&
        !remoteMissing &&
        revision <= (local.serverRevision ?? 0)) {
      return;
    }
    final pending = await _runtime.pendingChange('day_event', id, accountId);
    if (pending != null) {
      if (pending.frozenRequest == null ||
          await refreshOpenDayConflict(
            'day_event',
            id,
            accountId,
            payload,
            revision,
          )) {
        await upsertDayConflict(
          head: pending,
          remotePayload: jsonEncode(payload),
          remoteRevision: revision,
        );
      }
      return;
    }
    if (await refreshOpenDayConflict(
      'day_event',
      id,
      accountId,
      payload,
      revision,
    )) {
      return;
    }
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      if (local != null) {
        await (_runtime.db.update(
          _runtime.db.dayEvents,
        )..where((e) => e.id.equals(id))).write(
          DayEventsCompanion(
            serverRevision: d.Value(revision),
            deletedAt: d.Value(DateTime.now().toUtc()),
          ),
        );
      }
      return;
    }
    final remote = _runtime.deser(jsonEncode(payload), DayEvent.serializer);
    if (remote.id != id) throw const FormatException('日子记录身份不匹配');
    final definition = days.DayEventDefinition(
      name: remote.name,
      category: remote.category.name,
      countdownMode: switch (remote.countdownMode?.name) {
        'fixedDate' => 'fixed_date',
        'intervalDays' => 'interval_days',
        final value => value,
      },
      intervalDays: remote.intervalDays,
      repeatType: remote.repeatType.name == 'intervalDays'
          ? 'interval_days'
          : remote.repeatType.name,
      statisticType: remote.statisticType.name,
      event: original(remote.event),
      start: original(remote.start),
      end: original(remote.end),
    );
    await _runtime.db
        .into(_runtime.db.dayEvents)
        .insertOnConflictUpdate(
          dayEventToCompanion(
            days.DayEvent(
              id: id,
              dayBookId: bookId,
              definition: dayRepository!.validateAndProject(definition),
              createdAt: remote.createdAt,
              updatedAt: remote.updatedAt,
              serverRevision: revision,
              sourceEventId: local?.sourceEventId,
            ),
          ),
        );
  }

  /// 日期 DTO 映射留在 sync，业务对象不暴露生成类型。
  days.OriginalDate? original(
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? value,
  ) => value == null
      ? null
      : days.OriginalDate(
          calendarType: value.calendarType.name,
          originalYear: value.originalYear,
          originalMonth: value.originalMonth,
          originalDay: value.originalDay,
          isLeapMonth: value.isLeapMonth,
          solarDate: days.DateOnly.parse(value.solarDate),
        );

  /// 队列已经确认但仍有 OPEN 决策时只更新远端事实，不能覆盖展示中的本地分支。
  Future<bool> refreshOpenDayConflict(
    String type,
    String id,
    String accountId,
    Map<String, dynamic> payload,
    int revision,
  ) async {
    final conflict =
        await (_runtime.db.select(_runtime.db.syncConflicts)..where(
              (c) =>
                  c.accountId.equals(accountId) &
                  c.entityType.equals(type) &
                  c.entityId.equals(id) &
                  c.status.equals('OPEN'),
            ))
            .getSingleOrNull();
    if (conflict == null) return false;
    if (revision > conflict.remoteRevision) {
      await (_runtime.db.update(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(conflict.id))).write(
        SyncConflictsCompanion(
          remotePayload: d.Value(jsonEncode(payload)),
          remoteRevision: d.Value(revision),
        ),
      );
    }
    return true;
  }

  /// 远端整本删除或失配先保护未确认的完整本地分支，再隔离原本。
  Future<void> protectDayBook(
    String id,
    String accountId, {
    bool stale = false,
    bool deleted = false,
  }) async {
    final book = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (book == null) return;
    if (book.scopeAccountId != accountId) throw StateError('不能处理其他账号的数据');
    await _ports.operationsQuarantinePrivateBook(
      SyncTarget('day_book', id),
      accountId,
      stale: stale,
      deleted: deleted,
      book: dayBookFromRow(book),
      table: _runtime.db.dayBooks,
      contents: _runtime.db.dayEvents,
      parentColumn: 'day_book_id',
      protect: (branch) async {
        await requiredDayRepository.copyToLocal(
          id,
          accountId: accountId,
          operationId: 'scope-protection:$id:$branch',
        );
      },
    );
  }

  /// 保存 D 域水位不改动 A 域水位。
  Future<void> saveDayCursor(String cursor) =>
      _runtime.saveDomainCursor(SyncDomain.days, cursor, dayAccount());

  /// 已被同绑定单本快照覆盖的事件无需重放，自己的确认回显不制造冲突。
  Future<void> applyDayChange(
    GetSyncPull200ResponseChangesInner change,
    String accountId,
  ) async {
    final id = change.dayBookId!;
    final book = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    final payload = <String, dynamic>{
      for (final entry in change.payload.entries) entry.key: entry.value?.value,
    };
    if (book != null && book.scopeAccountId != accountId) {
      throw StateError('日子本账号不匹配');
    }
    if (book?.isStale == true) return;
    if (book != null &&
        book.syncId == payload['sync_id'] &&
        book.fullCursor != null &&
        BigInt.parse(change.changeId) <= BigInt.parse(book.fullCursor!)) {
      return;
    }
    final own =
        await (_runtime.db.select(_runtime.db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(accountId) &
                  c.mutationId.equals(change.mutationId),
            ))
            .getSingleOrNull();
    if (own != null) {
      await applyDayPushOutcome(
        own,
        PostSyncPush200ResponseOutcomesInner(
          (b) => b
            ..mutationId = own.mutationId
            ..entityId = own.entityId
            ..status = PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
            ..changeId = change.changeId
            ..revision = payload['revision'] as int?
            ..syncId = payload['sync_id'] as String?,
        ),
        accountId,
      );
      return;
    }
    if (change.entityType.name == 'dayBook') {
      await applyDayBookPayload(change.entityId, payload, accountId);
    } else {
      await applyDayEventPayload(change.entityId, payload, accountId);
    }
  }

  /// 冲突决策固定账号和父本；远端墓碑的本地分支通过新身份保存。
  Future<void> resolveDayConflict(
    SyncConflict conflict,
    String? accountId, {
    required bool keepLocal,
  }) async {
    if (accountId == null ||
        conflict.accountId != accountId ||
        conflict.dayBookId == null) {
      throw StateError('冲突不属于当前账号');
    }
    try {
      await _runtime.inAccountTransaction(accountId, () async {
        final current =
            await (_runtime.db.select(_runtime.db.syncConflicts)..where(
                  (c) =>
                      c.id.equals(conflict.id) & c.accountId.equals(accountId),
                ))
                .getSingleOrNull();
        if (current == null || current.status != 'OPEN') return;
        conflict = current;
        final remote =
            jsonDecode(conflict.remotePayload) as Map<String, dynamic>;
        final remoteDeleted =
            remote['deleted'] == true || remote['deleted_at'] != null;
        // OPEN 期间仍可继续编辑；决策必须使用事务内最新队尾，不能回放旧预览内容。
        final tail = await _runtime.pendingChange(
          conflict.entityType,
          conflict.entityId,
          accountId,
          tail: true,
        );
        final localPayload = tail == null
            ? conflict.localPayload
            : tail.action == 'delete'
            ? jsonEncode({
                'deleted': true,
                ...jsonDecode(tail.payload) as Map<String, dynamic>,
              })
            : tail.payload;
        final book =
            await (_runtime.db.select(_runtime.db.dayBooks)..where(
                  (b) =>
                      b.id.equals(conflict.dayBookId!) &
                      b.scopeAccountId.equals(accountId),
                ))
                .getSingle();
        if (book.isStale ||
            book.deletedAt != null ||
            (conflict.entityType == 'day_book' && remoteDeleted)) {
          if (keepLocal) {
            await protectDayBook(
              book.id,
              accountId,
              stale: book.isStale,
              deleted: remoteDeleted || book.deletedAt != null,
            );
          } else if (remoteDeleted || book.deletedAt != null) {
            final deletedAt = DateTime.now().toUtc();
            await (_runtime.db.update(
              _runtime.db.dayBooks,
            )..where((b) => b.id.equals(book.id))).write(
              DayBooksCompanion(
                deletedAt: d.Value(deletedAt),
                pendingLocalDelete: const d.Value(false),
              ),
            );
            await (_runtime.db.update(_runtime.db.dayEvents)
                  ..where((e) => e.dayBookId.equals(book.id)))
                .write(DayEventsCompanion(deletedAt: d.Value(deletedAt)));
          }
          await (_runtime.db.delete(_runtime.db.syncChanges)..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.dayBookId.equals(book.id) &
                    c.pushedAt.isNull(),
              ))
              .go();
          await (_runtime.db.update(_runtime.db.syncConflicts)..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.dayBookId.equals(book.id) &
                    c.status.equals('OPEN'),
              ))
              .write(
                SyncConflictsCompanion(
                  status: d.Value(
                    keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE',
                  ),
                  resolvedAt: d.Value(DateTime.now().toUtc()),
                ),
              );
          return;
        }
        await (_runtime.db.delete(_runtime.db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(accountId) &
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
            localPayload: d.Value(localPayload),
            resolvedAt: d.Value(DateTime.now().toUtc()),
          ),
        );
        if (!keepLocal) {
          final payload = {...remote, 'revision': conflict.remoteRevision};
          if (conflict.entityType == 'day_book') {
            // 采用存活远端版本同时撤销本地删除意图，恢复本的正常写入入口。
            await (_runtime.db.update(
              _runtime.db.dayBooks,
            )..where((b) => b.id.equals(book.id))).write(
              const DayBooksCompanion(pendingLocalDelete: d.Value(false)),
            );
            await applyDayBookPayload(conflict.entityId, payload, accountId);
          } else {
            await applyDayEventPayload(conflict.entityId, payload, accountId);
          }
          return;
        }
        final local = jsonDecode(localPayload) as Map<String, dynamic>;
        final localDeleted = local.remove('deleted') == true;
        if (remoteDeleted && conflict.entityType == 'day_event') {
          final old =
              await (_runtime.db.select(_runtime.db.dayEvents)..where(
                    (e) =>
                        e.id.equals(conflict.entityId) &
                        e.dayBookId.equals(book.id),
                  ))
                  .getSingle();
          await (_runtime.db.update(
            _runtime.db.dayEvents,
          )..where((e) => e.id.equals(old.id))).write(
            DayEventsCompanion(
              deletedAt: d.Value(DateTime.now().toUtc()),
              serverRevision: d.Value(conflict.remoteRevision),
            ),
          );
          if (!localDeleted) {
            final original = dayEventFromRow(old);
            await requiredDayRepository.saveEvent(
              days.DayEvent(
                id: const Uuid().v4(),
                dayBookId: book.id,
                definition: original.definition,
                createdAt: original.createdAt,
                updatedAt: DateTime.now().toUtc(),
                sourceEventId: original.id,
              ),
              accountId: accountId,
              expectedSyncId: book.syncId,
            );
          }
          return;
        }
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: conflict.entityType,
                entityId: conflict.entityId,
                dayBookId: d.Value(book.id),
                accountId: d.Value(accountId),
                action: localDeleted ? 'delete' : 'upsert',
                // 条件删除保留完整快照前置条件，不能因冲突决策绕过云端并发保护。
                payload: jsonEncode(local),
                updatedAt: DateTime.now().toUtc(),
                mutationId: const Uuid().v4(),
                baseRevision: d.Value(conflict.remoteRevision),
              ),
            );
      });
    } catch (error) {
      // 中间层只保留冲突处理上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error('SyncService', '处理日子冲突失败，已保留本地分支', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 日子保护与转换必须通过注入的静态写边界。
  DayRepository get requiredDayRepository =>
      dayRepository ?? (throw StateError('日子数据服务尚未就绪'));

  /// 执行copyDayBookToLocal对应的同步步骤，沿用所属域的身份与事务规则。
  Future<day_books.DayBook> copyDayBookToLocal({
    required String dayBookId,
  }) async {
    final id = await _ports.transfersTransferToLocal(
      SyncTarget('day_book', dayBookId),
      move: false,
    );
    return dayBookFromRow(
      await (_runtime.db.select(
        _runtime.db.dayBooks,
      )..where((b) => b.id.equals(id))).getSingle(),
    );
  }

  /// 执行moveDayBookToLocal对应的同步步骤，沿用所属域的身份与事务规则。
  Future<day_books.DayBook> moveDayBookToLocal({
    required String dayBookId,
  }) async {
    final id = await _ports.transfersTransferToLocal(
      SyncTarget('day_book', dayBookId),
      move: true,
    );
    return dayBookFromRow(
      await (_runtime.db.select(
        _runtime.db.dayBooks,
      )..where((b) => b.id.equals(id))).getSingle(),
    );
  }

  /// 快照变化后重建同一隐藏副本，现有源记录映射继续沿用，去重事实一并重映射。
  Future<void> refreshDayMoveCopy(String sourceId, String copyId) async {
    final source = await (_runtime.db.select(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(sourceId))).getSingle();
    final originals = await (_runtime.db.select(
      _runtime.db.dayEvents,
    )..where((e) => e.dayBookId.equals(sourceId) & e.deletedAt.isNull())).get();
    final copied = await (_runtime.db.select(
      _runtime.db.dayEvents,
    )..where((e) => e.dayBookId.equals(copyId))).get();
    final mapping = {
      for (final row in copied)
        if (row.sourceEventId != null) row.sourceEventId!: row.id,
    };
    final keep = <String>{};
    for (final row in originals) {
      final event = dayEventFromRow(row);
      final id = mapping.putIfAbsent(event.id, () => const Uuid().v4());
      keep.add(id);
      await _runtime.db
          .into(_runtime.db.dayEvents)
          .insertOnConflictUpdate(
            dayEventToCompanion(
              days.DayEvent(
                id: id,
                dayBookId: copyId,
                definition: requiredDayRepository.validateAndProject(
                  event.definition,
                ),
                createdAt: event.createdAt,
                updatedAt: event.updatedAt,
                sourceEventId: event.id,
              ),
            ),
          );
    }
    await (_runtime.db.delete(_runtime.db.dayEvents)..where(
          (e) =>
              e.dayBookId.equals(copyId) &
              (keep.isEmpty ? const d.Constant(true) : e.id.isNotIn(keep)),
        ))
        .go();
    await (_runtime.db.update(
      _runtime.db.dayBooks,
    )..where((b) => b.id.equals(copyId))).write(
      DayBooksCompanion(
        name: d.Value(source.name),
        createdAt: d.Value(source.createdAt),
      ),
    );
    await (_runtime.db.delete(
      _runtime.db.dayImportReceipts,
    )..where((r) => r.targetDayBookId.equals(copyId))).go();
    final receipts = await (_runtime.db.select(
      _runtime.db.dayImportReceipts,
    )..where((r) => r.targetDayBookId.equals(sourceId))).get();
    for (final receipt in receipts) {
      await _runtime.db
          .into(_runtime.db.dayImportReceipts)
          .insert(
            DayImportReceiptsCompanion.insert(
              targetDayBookId: copyId,
              exportId: receipt.exportId,
              sourceEntryId: receipt.sourceEntryId,
              importedAt: receipt.importedAt,
              localEventId: d.Value(mapping[receipt.localEventId]),
            ),
          );
    }
  }

  /// 只处理当前账号及显式目标本；每轮重新读取确认后的版本和暂停事实。
  /// 在首次 HTTP 前冻结完整 envelope；任何重试都从已保存请求重建生成 DTO。
  Future<SyncChange> freezeDayChange(
    SyncChange source,
    String accountId,
  ) async {
    late SyncChange frozen;
    await _runtime.inAccountTransaction(accountId, () async {
      final row =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) => c.id.equals(source.id) & c.accountId.equals(accountId),
              ))
              .getSingle();
      final book =
          await (_runtime.db.select(_runtime.db.dayBooks)..where(
                (b) =>
                    b.id.equals(row.dayBookId!) &
                    b.scopeAccountId.equals(accountId),
              ))
              .getSingle();
      if (book.storageMode != 'cloud' ||
          row.ledgerId != null ||
          (row.entityType == 'day_book' && row.entityId != book.id)) {
        throw StateError('日子本归属已变化，请刷新后重试');
      }
      if (row.frozenRequest == null) {
        final wire = jsonEncode({
          'mutation_id': row.mutationId,
          'entity_type': row.entityType,
          'entity_id': row.entityId,
          'ledger_id': null,
          'day_book_id': book.id,
          'sync_id': ?book.syncId,
          'base_revision': row.baseRevision ?? 0,
          'action': row.action,
          'updated_at': wireTimestamp(row.updatedAt),
          'payload': jsonDecode(row.payload),
        });
        // 序列化验证必须先于提交冻结，非法载荷不会成为已经发出的请求。
        _runtime.changeCodec.dayChangeFromFrozen(wire);
        await (_runtime.db.update(_runtime.db.syncChanges)
              ..where((c) => c.id.equals(row.id)))
            .write(SyncChangesCompanion(frozenRequest: d.Value(wire)));
      }
      frozen = await (_runtime.db.select(
        _runtime.db.syncChanges,
      )..where((c) => c.id.equals(row.id))).getSingle();
    });
    return frozen;
  }

  /// 成功只确认对应队列并校准后继版本，不覆盖用户在途编辑后的最新定义。
  Future<void> applyDayPushOutcome(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String accountId,
  ) async {
    final book =
        await (_runtime.db.select(_runtime.db.dayBooks)..where(
              (b) =>
                  b.id.equals(change.dayBookId!) &
                  b.scopeAccountId.equals(accountId),
            ))
            .getSingle();
    switch (outcome.status) {
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
          PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
        final revision = outcome.revision;
        if (change.entityType == 'day_book') {
          // 与其他私有本共用同一条确认规则：建立绑定、补齐快照水位并退休同本未发送意图。
          await _runtime.ackPrivateBook(
            change,
            outcome,
            accountId,
            book: dayBookFromRow(book),
            table: _runtime.db.dayBooks,
            contents: _runtime.db.dayEvents,
            parentColumn: 'day_book_id',
          );
        } else {
          if (revision == null || revision < 1) {
            throw const FormatException('日子同步确认版本或绑定无效');
          }
          final event =
              await (_runtime.db.select(_runtime.db.dayEvents)..where(
                    (e) =>
                        e.id.equals(change.entityId) &
                        e.dayBookId.equals(book.id),
                  ))
                  .getSingle();
          if (revision > (event.serverRevision ?? 0)) {
            await (_runtime.db.update(_runtime.db.dayEvents)
                  ..where((e) => e.id.equals(event.id)))
                .write(DayEventsCompanion(serverRevision: d.Value(revision)));
          }
        }
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
        final payload = _runtime.privateBookConflictPayload(outcome);
        await upsertDayConflict(
          head: change,
          remotePayload: jsonEncode(payload),
          remoteRevision: payload['revision'] as int,
        );
      default:
        throw const FormatException('日子同步确认状态无效');
    }
  }

  /// 保存同账号实体的最终本地分支及远端版本，父本冲突会暂停整本依赖。
  Future<void> upsertDayConflict({
    required SyncChange head,
    required String remotePayload,
    required int remoteRevision,
  }) async {
    final accountId = head.accountId;
    if (accountId == null || head.dayBookId == null) {
      throw StateError('日子冲突缺少账号或父本');
    }
    final tail =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.entityType.equals(head.entityType) &
                    c.entityId.equals(head.entityId) &
                    c.pushedAt.isNull(),
              )
              ..orderBy([(c) => d.OrderingTerm.desc(c.id)])
              ..limit(1))
            .getSingle();
    await _runtime.upsertConflict(
      dayBookId: head.dayBookId,
      entityType: head.entityType,
      entityId: head.entityId,
      localPayload: tail.action == 'delete'
          ? jsonEncode({
              'deleted': true,
              ...jsonDecode(tail.payload) as Map<String, dynamic>,
            })
          : tail.payload,
      remotePayload: remotePayload,
      baseRevision: head.baseRevision,
      remoteRevision: remoteRevision,
      localMutationId: head.mutationId,
    );
  }
}

/// 日子本与记录的拉取、推送、保护和冲突处理所需的外部协作端口。
class DaySyncHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const DaySyncHandlerPorts({
    required this.operationsQuarantinePrivateBook,
    required this.pullDiscoverBookDirectory,
    required this.transfersTransferToLocal,
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

  /// 委托transfers域执行transferToLocal。
  final Future<String> Function(
    SyncTarget target, {
    required bool move,
    String? expectedFullCursor,
  })
  transfersTransferToLocal;
}
