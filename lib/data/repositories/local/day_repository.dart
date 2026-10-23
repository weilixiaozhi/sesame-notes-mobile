import '../contracts/day_repositories.dart';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import '../../models/private_book.dart';
import 'private_book_lifecycle.dart';

/// 日子父子数据的唯一写边界，与财务仓储共享数据库和变更登记端口。
class DayRepository
    implements
        DayQueryRepository,
        DayEntryRepository,
        DayBookRepository,
        DayTransferRepository,
        DayAccountRepository {
  /// 在现有数据库连接中完成用例的原子读写，失败保留异常堆栈。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    try {
      return await db.transaction(action);
    } catch (error, stackTrace) {
      logger.error(
        'DayRepository',
        '本地事务未完成，已回滚',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 仅查询当前本子的待办事实，文件交换用例不读取同步表结构。
  @override
  Future<bool> hasUnsettledChanges(String bookId) =>
      _guard('读取日子未完成同步状态', () async {
        final pending =
            await (db.select(db.syncChanges)
                  ..where(
                    (row) =>
                        row.dayBookId.equals(bookId) & row.pushedAt.isNull(),
                  )
                  ..limit(1))
                .get();
        if (pending.isNotEmpty) return true;
        final errors =
            await (db.select(db.syncPullErrors)
                  ..where(
                    (row) =>
                        row.dayBookId.equals(bookId) & row.resolvedAt.isNull(),
                  )
                  ..limit(1))
                .get();
        return errors.isNotEmpty;
      });

  final SesameDatabase db;
  final DayEventDefinition Function(DayEventDefinition) validateAndProject;
  final ChangeRecorder? changeRecorder;
  @override
  final String? Function() accountIdGetter;
  @override
  final int Function() generationGetter;
  static final _uuidV4 = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// 顶层装配注入纯日期校验，数据层不反向依赖 feature。
  DayRepository(
    this.db, {
    required this.validateAndProject,
    this.changeRecorder,
    String? Function()? accountIdGetter,
    int Function()? generationGetter,
  }) : accountIdGetter = accountIdGetter ?? (() => null),
       generationGetter = generationGetter ?? (() => 0);

  /// 私有本父本写规则与其他业务共用同一实现，日子只提供表、作用域与记录回调。
  late final lifecycle = PrivateBookLifecycle<DayBook>(
    db: db,
    table: db.dayBooks,
    errorPrefix: 'DAY',
    parentIdColumn: 'day_book_id',
    sourceParentColumn: 'source_day_book_id',
    accountIdGetter: accountIdGetter,
    generationGetter: generationGetter,
    read: (id, account) => getBook(id, accountId: account),
    record: (book, action, payload, now, revision) =>
        _record(book, 'day_book', book.id, action, payload, now, revision),
  );

  @override
  Future<PrivateBookTarget> target(String id) => lifecycle.target(id);
  @override
  Future<DayBook> requireTarget(PrivateBookTarget target) =>
      lifecycle.requireTarget(target);

  /// 所有普通本查询使用同一账号隔离和可见性条件。
  d.Expression<bool> _accessible(DayBooks b, String? accountId) =>
      b.deletedAt.isNull() &
      b.isHidden.equals(false) &
      b.pendingLocalDelete.equals(false) &
      (b.storageMode.equals('local') |
          (accountId == null
              ? const d.Constant(false)
              : b.scopeAccountId.equals(accountId)));

  /// 可访问本按照稳定创建顺序排列，同名本不合并。
  d.SimpleSelectStatement<DayBooks, DayBookRow> _books(String? accountId) =>
      db.select(db.dayBooks)
        ..where((b) => _accessible(b, accountId))
        ..orderBy([
          (b) => d.OrderingTerm.asc(b.storageMode),
          (b) => d.OrderingTerm.asc(b.createdAt),
          (b) => d.OrderingTerm.asc(b.id),
        ]);

  /// 读取可访问本，包括没有记录的空本。
  @override
  Future<List<DayBook>> getBooks({String? accountId}) => _guard(
    '读取日子本',
    () async => (await _books(accountId).get()).map(dayBookFromRow).toList(),
  );

  /// 监听父本集合，账号变化由上层重新建立流。
  @override
  Stream<List<DayBook>> watchBooks({String? accountId}) async* {
    try {
      yield* _books(
        accountId,
      ).watch().map((rows) => rows.map(dayBookFromRow).toList());
    } catch (error) {
      logger.error('DayRepository', '监听日子本失败', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 只返回当前上下文有权访问的本子。
  @override
  Future<DayBook?> getBook(String id, {String? accountId}) =>
      _guard('读取日子本', () async {
        final row = await (_books(
          accountId,
        )..where((b) => b.id.equals(id))).getSingleOrNull();
        return row == null ? null : dayBookFromRow(row);
      });

  /// 关联父本过滤记录，无法产生跨账号或隐藏本记录流。
  d.JoinedSelectStatement _events(String id, String? accountId) =>
      db.select(db.dayEvents).join([
          d.innerJoin(
            db.dayBooks,
            db.dayBooks.id.equalsExp(db.dayEvents.dayBookId),
          ),
        ])
        ..where(
          db.dayEvents.dayBookId.equals(id) &
              db.dayEvents.deletedAt.isNull() &
              _accessible(db.dayBooks, accountId),
        )
        ..orderBy([
          d.OrderingTerm.asc(db.dayEvents.createdAt),
          d.OrderingTerm.asc(db.dayEvents.id),
        ]);

  /// 返回显式父本的记录快照，不读取当前页面选择。
  @override
  Future<List<DayEvent>> getEvents(String id, {String? accountId}) => _guard(
    '读取日子',
    () async => (await _events(id, accountId).get())
        .map((row) => dayEventFromRow(row.readTable(db.dayEvents)))
        .toList(),
  );

  /// 监听固定本子；父本删除或权限变化会同步隐藏全部子记录。
  @override
  Stream<List<DayEvent>> watchEvents(String id, {String? accountId}) async* {
    try {
      yield* _events(id, accountId).watch().map(
        (rows) => rows
            .map(
              (row) => dayEventFromRow(
                row.readTable(db.dayEvents),
                forDisplay: true,
              ),
            )
            .toList(),
      );
    } catch (error) {
      logger.error('DayRepository', '监听日子失败: $id', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 事务内再次检查固定目标，绑定变更不得把输入写入其他本。
  @override
  Future<DayBook> requireWritable(
    String id, {
    String? accountId,
    String? expectedSyncId,
  }) async {
    final book = await getBook(id, accountId: accountId);
    if (book == null ||
        book.isStale ||
        (expectedSyncId != null && book.syncId != expectedSyncId)) {
      throw StateError('日子本状态已变化，请保留输入并刷新后重试');
    }
    return book;
  }

  /// 固定 UUID 创建使落库后响应丢失仍可重试，同名合法但不能接管已有身份。
  @override
  Future<DayBook> createBook({
    required String id,
    required String name,
    String storageMode = 'local',
    String? accountId,
    int? generation,
  }) => _guard(
    '创建日子本',
    () => lifecycle.create(
      id: id,
      name: normalizeDayName(name),
      storageMode: storageMode,
      accountId: accountId,
      generation: generation,
    ),
  );

  /// 改名只修改可写元数据，保留创建时间、父本身份和绑定。
  @override
  Future<void> renameBook(PrivateBookTarget target, String name) =>
      _guard('修改日子本', () => lifecycle.rename(target, normalizeDayName(name)));

  /// 本机删除是父子原子操作；未知云创建结果保留冻结请求直到确认真实身份。
  Future<void> deleteBook(
    PrivateBookTarget target, {
    String? expectedFullCursor,
  }) => _guard(
    '删除日子本',
    () => lifecycle.delete(
      target,
      expectedFullCursor: expectedFullCursor,
      validatePreview: (book) async {
        // 云本必须先通过可写校验，临时冻结删除意图在确认期间不得被重建。
        await requireWritable(
          book.id,
          accountId: target.accountId,
          expectedSyncId: target.syncId,
        );
      },
    ),
  );

  /// 每个写入入口统一校验定义和投影；创建时间在首次写入后不可改变。
  Future<void> saveEvent(
    DayEvent value, {
    String? accountId,
    String? expectedSyncId,
  }) => _saveEvent(value, accountId: accountId, expectedSyncId: expectedSyncId);

  /// 编辑器的固定目标与会话参与同一写事务，迟到保存不能跨会话提交。
  @override
  Future<void> saveEventAtTarget(DayEvent value, PrivateBookTarget target) =>
      lifecycle.write(target.accountId, target.generation, () async {
        if (value.dayBookId != target.bookId) {
          throw StateError('DAY_TARGET_CHANGED');
        }
        await requireTarget(target);
        await saveEvent(
          value,
          accountId: target.accountId,
          expectedSyncId: target.syncId,
        );
        await requireTarget(target);
      });

  /// 导入可以保留文件修改时间，普通新增和编辑使用本次保存时间。
  Future<void> _saveEvent(
    DayEvent value, {
    String? accountId,
    String? expectedSyncId,
    DateTime? importedUpdatedAt,
  }) => _guard(
    '保存日子',
    () => db.transaction(() async {
      _requireUuid(value.id);
      final book = await requireWritable(
        value.dayBookId,
        accountId: accountId,
        expectedSyncId: expectedSyncId,
      );
      final old = await (db.select(
        db.dayEvents,
      )..where((e) => e.id.equals(value.id))).getSingleOrNull();
      if (old != null &&
          (old.dayBookId != value.dayBookId || old.deletedAt != null)) {
        throw StateError('日子身份已变化，请重新创建');
      }
      final projected = DayEvent(
        id: value.id,
        dayBookId: value.dayBookId,
        definition: validateAndProject(value.definition),
        createdAt: old?.createdAt ?? value.createdAt,
        updatedAt: importedUpdatedAt ?? DateTime.now().toUtc(),
        serverRevision: book.isCloud ? old?.serverRevision ?? 0 : null,
        sourceEventId: old?.sourceEventId ?? value.sourceEventId,
      );
      await db
          .into(db.dayEvents)
          .insertOnConflictUpdate(dayEventToCompanion(projected));
      await _record(
        book,
        'day_event',
        value.id,
        'upsert',
        dayEventPayload(projected),
        projected.updatedAt,
        projected.serverRevision ?? 0,
      );
    }),
  );

  /// 删除记录保留空本；云记录以同一事务登记删除意图。
  Future<void> deleteEvent(
    String id,
    String dayBookId, {
    String? accountId,
  }) => _guard(
    '删除日子',
    () => db.transaction(() async {
      final book = await requireWritable(dayBookId, accountId: accountId);
      final row =
          await (db.select(db.dayEvents)..where(
                (e) =>
                    e.id.equals(id) &
                    e.dayBookId.equals(dayBookId) &
                    e.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (row == null) throw StateError('日子已不存在，请刷新后重试');
      final now = DateTime.now().toUtc();
      if (book.isCloud) {
        await (db.update(db.dayEvents)..where((e) => e.id.equals(id))).write(
          DayEventsCompanion(deletedAt: d.Value(now), updatedAt: d.Value(now)),
        );
        await _record(
          book,
          'day_event',
          id,
          'delete',
          const {},
          now,
          row.serverRevision ?? 0,
        );
      } else {
        await (db.delete(db.dayEvents)..where((e) => e.id.equals(id))).go();
      }
    }),
  );

  /// 确认删除的原始目标参与同一事务，会话或云绑定改变时删除与队列一起回滚。
  Future<void> deleteEventAtTarget(String id, PrivateBookTarget target) =>
      lifecycle.write(target.accountId, target.generation, () async {
        await requireTarget(target);
        await deleteEvent(id, target.bookId, accountId: target.accountId);
        await requireTarget(target);
      });

  /// 显式上云保留父子 ID，事务登记父本在前的依赖队列。
  Future<void> moveToCloud(PrivateBookTarget target) => _guard(
    '日子本上云',
    () => lifecycle.promote(target, (cloud) async {
      final events = await getEvents(cloud.id, accountId: cloud.scopeAccountId);
      final now = DateTime.now().toUtc();
      for (final event in events) {
        await (db.update(db.dayEvents)..where((e) => e.id.equals(event.id)))
            .write(const DayEventsCompanion(serverRevision: d.Value(0)));
        await _record(
          cloud,
          'day_event',
          event.id,
          'upsert',
          dayEventPayload(event),
          now,
          0,
        );
      }
    }),
  );

  /// 整本复制统一重映射父子身份，保护操作身份让失败重试不生成第二份。
  @override
  Future<DayBook> copyToLocal(
    String id, {
    String? accountId,
    String? operationId,
    bool hidden = false,
  }) => _guard(
    '保留本机副本',
    () => lifecycle.write(accountIdGetter(), generationGetter(), () async {
      final source = await (db.select(
        db.dayBooks,
      )..where((b) => b.id.equals(id))).getSingle();
      if (source.storageMode == 'cloud' && source.scopeAccountId != accountId) {
        throw StateError('日子本账号不匹配');
      }
      if (operationId != null) {
        final existing =
            await (db.select(db.dayBooks)..where(
                  (b) =>
                      b.sourceOperationId.equals(operationId) &
                      b.sourceDayBookId.equals(id),
                ))
                .getSingleOrNull();
        if (existing != null) return dayBookFromRow(existing);
      }
      final newId = const Uuid().v4();
      final now = DateTime.now().toUtc();
      await db
          .into(db.dayBooks)
          .insert(
            DayBooksCompanion.insert(
              id: newId,
              name: source.name,
              createdAt: source.createdAt,
              updatedAt: now,
              isHidden: d.Value(hidden),
              sourceAccountId: d.Value(source.scopeAccountId),
              sourceDayBookId: d.Value(source.id),
              sourceOperationId: d.Value(operationId),
            ),
          );
      final rows = await (db.select(
        db.dayEvents,
      )..where((e) => e.dayBookId.equals(id) & e.deletedAt.isNull())).get();
      final eventIds = <String, String>{};
      for (final row in rows) {
        final event = dayEventFromRow(row);
        final eventId = const Uuid().v4();
        eventIds[event.id] = eventId;
        await db
            .into(db.dayEvents)
            .insert(
              dayEventToCompanion(
                DayEvent(
                  id: eventId,
                  dayBookId: newId,
                  definition: validateAndProject(event.definition),
                  createdAt: event.createdAt,
                  updatedAt: event.updatedAt,
                  sourceEventId: event.id,
                ),
              ),
            );
      }
      final receipts = await (db.select(
        db.dayImportReceipts,
      )..where((r) => r.targetDayBookId.equals(id))).get();
      for (final receipt in receipts) {
        await db
            .into(db.dayImportReceipts)
            .insert(
              DayImportReceiptsCompanion.insert(
                targetDayBookId: newId,
                exportId: receipt.exportId,
                sourceEntryId: receipt.sourceEntryId,
                localEventId: d.Value(
                  receipt.localEventId == null
                      ? null
                      : eventIds[receipt.localEventId],
                ),
                importedAt: receipt.importedAt,
              ),
            );
      }
      return dayBookFromRow(
        await (db.select(
          db.dayBooks,
        )..where((b) => b.id.equals(newId))).getSingle(),
      );
    }),
  );

  /// 本机写入不产生队列；云端缺少登记器直接失败以保证原子性。
  Future<void> _record(
    DayBook book,
    String type,
    String id,
    String action,
    Map<String, Object?> payload,
    DateTime updatedAt,
    int revision,
  ) async {
    if (!book.isCloud) return;
    final recorder = changeRecorder;
    if (recorder == null) throw StateError('同步暂不可用，请稍后重试');
    await recorder.recordDayChange(
      entityType: type,
      entityId: id,
      dayBookId: book.id,
      accountId: book.scopeAccountId!,
      action: action,
      payload: jsonEncode(payload),
      updatedAt: updatedAt,
      baseRevision: revision,
    );
  }

  /// 离线生成的身份必须符合共同 UUID v4 约定。
  void _requireUuid(String id) {
    if (!_uuidV4.hasMatch(id)) throw StateError('日子身份无效，请重新创建');
  }

  /// 返回固定目标本已经导入的来源条目标识，删除记录后仍保留去重事实。
  @override
  Future<Set<String>> getImportReceipts(
    String targetDayBookId,
    String exportId, {
    String? accountId,
  }) => _guard('读取日子导入收据', () async {
    if (await getBook(targetDayBookId, accountId: accountId) == null) {
      throw StateError('日子本不可访问');
    }
    final rows =
        await (db.select(db.dayImportReceipts)..where(
              (receipt) =>
                  receipt.targetDayBookId.equals(targetDayBookId) &
                  receipt.exportId.equals(exportId),
            ))
            .get();
    return rows.map((receipt) => receipt.sourceEntryId).toSet();
  });

  /// 在同一事务写入全部新记录、目标本收据及必要上传队列。
  @override
  Future<({int imported, int skipped})> importIntoBook({
    required String targetDayBookId,
    required String exportId,
    required List<DayEvent> entries,
    String? accountId,
    String? expectedSyncId,
    DayBook? expectedBook,
    void Function()? validateContext,
    void Function(int, int)? onProgress,
  }) => _guard(
    '导入日子',
    () => db.transaction(() async {
      validateContext?.call();
      _requireUuid(exportId);
      final book = await requireWritable(
        targetDayBookId,
        accountId: accountId,
        expectedSyncId: expectedSyncId,
      );
      if (expectedBook != null &&
          (book.storageMode != expectedBook.storageMode ||
              book.scopeAccountId != expectedBook.scopeAccountId ||
              book.syncId != expectedBook.syncId)) {
        throw StateError('目标日子本绑定已改变，请重新选择');
      }
      final ids = <String>{};
      // 包括将被去重跳过的行也要先校验，坏文件不能借已有收据绕过写边界。
      for (final entry in entries) {
        _requireUuid(entry.id);
        if (!ids.add(entry.id) || entry.deletedAt != null) {
          throw StateError('日子文件包含重复或已删除条目');
        }
        validateAndProject(entry.definition);
      }
      final receipts = await getImportReceipts(
        targetDayBookId,
        exportId,
        accountId: accountId,
      );
      var imported = 0;
      var processed = 0;
      for (final entry in entries) {
        if (receipts.contains(entry.id)) {
          onProgress?.call(++processed, entries.length);
          continue;
        }
        validateContext?.call();
        final localId = const Uuid().v4();
        await _saveEvent(
          DayEvent(
            id: localId,
            dayBookId: targetDayBookId,
            definition: entry.definition,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
            sourceEventId: entry.id,
          ),
          accountId: accountId,
          expectedSyncId: expectedSyncId,
          importedUpdatedAt: entry.updatedAt,
        );
        await db
            .into(db.dayImportReceipts)
            .insert(
              DayImportReceiptsCompanion.insert(
                targetDayBookId: targetDayBookId,
                exportId: exportId,
                sourceEntryId: entry.id,
                localEventId: d.Value(localId),
                importedAt: DateTime.now().toUtc(),
              ),
            );
        imported++;
        onProgress?.call(++processed, entries.length);
      }
      validateContext?.call();
      return (imported: imported, skipped: entries.length - imported);
    }),
  );

  /// 整本恢复以备份集合为权威，调用方用外层事务组合多个业务本。
  Future<String> restoreFromBackup({
    required DayBook book,
    required List<DayEvent> events,
    required List<DayBackupReceipt> receipts,
    bool forceCopy = false,
    bool hidden = false,
  }) => _guard(
    '恢复日子本',
    () => lifecycle.write(accountIdGetter(), generationGetter(), () async {
      _requireUuid(book.id);
      if (book.deletedAt != null) throw StateError('已删除日子本不能恢复为可见数据');
      final name = normalizeDayName(book.name);
      final existing = await (db.select(
        db.dayBooks,
      )..where((row) => row.id.equals(book.id))).getSingleOrNull();
      final copy =
          forceCopy || book.isCloud || existing?.storageMode == 'cloud';
      final targetId = copy ? const Uuid().v4() : book.id;
      final mappings = <String, String>{};
      final projected = <DayEvent>[];
      for (final event in events) {
        _requireUuid(event.id);
        if (event.dayBookId != book.id || mappings.containsKey(event.id)) {
          throw StateError('备份日子父子关系无效');
        }
        final definition = validateAndProject(event.definition);
        mappings[event.id] = copy ? const Uuid().v4() : event.id;
        if (!copy) {
          final occupied = await (db.select(
            db.dayEvents,
          )..where((row) => row.id.equals(event.id))).getSingleOrNull();
          if (occupied != null && occupied.dayBookId != targetId) {
            throw StateError('备份日子身份已被其他本占用');
          }
        }
        if (event.deletedAt == null) {
          projected.add(
            DayEvent(
              id: mappings[event.id]!,
              dayBookId: targetId,
              definition: definition,
              createdAt: event.createdAt,
              updatedAt: event.updatedAt,
              sourceEventId: copy
                  ? (event.sourceEventId ?? event.id)
                  : event.sourceEventId,
            ),
          );
        }
      }
      final receiptKeys = <String>{};
      for (final receipt in receipts) {
        _requireUuid(receipt.exportId);
        _requireUuid(receipt.sourceEntryId);
        if (!receiptKeys.add('${receipt.exportId}/${receipt.sourceEntryId}')) {
          throw StateError('备份导入收据重复');
        }
        if (receipt.localEventId != null &&
            !mappings.containsKey(receipt.localEventId)) {
          // 已删除记录可不在可见集合中；只有指向别本的引用才是损坏。
          final other =
              await (db.select(db.dayEvents)
                    ..where((row) => row.id.equals(receipt.localEventId!)))
                  .getSingleOrNull();
          if (other != null && other.dayBookId != book.id) {
            throw StateError('备份收据引用其他日子本');
          }
        }
      }
      // 保留 ID 的整本恢复合并既有去重事实，记录集合仍由备份完整替换。
      final previousReceipts = !copy && existing != null
          ? await (db.select(
              db.dayImportReceipts,
            )..where((row) => row.targetDayBookId.equals(targetId))).get()
          : const <DayImportReceipt>[];
      if (!copy && existing != null) {
        await (db.delete(
          db.dayEvents,
        )..where((row) => row.dayBookId.equals(targetId))).go();
        await (db.delete(
          db.syncChanges,
        )..where((row) => row.dayBookId.equals(targetId))).go();
        await (db.delete(
          db.syncConflicts,
        )..where((row) => row.dayBookId.equals(targetId))).go();
        await (db.delete(
          db.syncPullErrors,
        )..where((row) => row.dayBookId.equals(targetId))).go();
        await (db.delete(
          db.dayBooks,
        )..where((row) => row.id.equals(targetId))).go();
      }
      await db
          .into(db.dayBooks)
          .insert(
            DayBooksCompanion.insert(
              id: targetId,
              name: name,
              createdAt: book.createdAt,
              updatedAt: book.updatedAt,
              isHidden: d.Value(hidden),
              sourceAccountId: d.Value(
                book.sourceAccountId ?? book.scopeAccountId,
              ),
              sourceDayBookId: d.Value(book.sourceDayBookId ?? book.id),
            ),
          );
      for (final event in projected) {
        await db.into(db.dayEvents).insert(dayEventToCompanion(event));
      }
      final activeIds = projected.map((event) => event.id).toSet();
      for (final receipt in [
        for (final old in previousReceipts)
          (
            exportId: old.exportId,
            sourceEntryId: old.sourceEntryId,
            localEventId: old.localEventId,
            importedAt: old.importedAt,
          ),
        ...receipts,
      ]) {
        final mapped = copy
            ? mappings[receipt.localEventId]
            : receipt.localEventId;
        await db
            .into(db.dayImportReceipts)
            .insert(
              DayImportReceiptsCompanion.insert(
                targetDayBookId: targetId,
                exportId: receipt.exportId,
                sourceEntryId: receipt.sourceEntryId,
                localEventId: d.Value(
                  activeIds.contains(mapped) ? mapped : null,
                ),
                importedAt: receipt.importedAt,
              ),
              mode: d.InsertMode.insertOrIgnore,
            );
      }
      return targetId;
    }),
  );

  /// 记录脱敏操作及堆栈后原样抛错，调用方保留输入并提供重试。
  Future<T> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return await body();
    } catch (error) {
      logger.error('DayRepository', '$operation失败', safeErrorSummary(error));
      rethrow;
    }
  }
}
