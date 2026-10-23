import 'package:sesame_notes/core/logging/logger_service.dart';
import '../../models/memo_import_preview.dart';
export '../../models/memo_import_preview.dart';
import '../contracts/memo_repositories.dart';
import 'private_book_lifecycle.dart';
import '../../models/private_book.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import '../../db.dart';
import '../../models/memo.dart';
import '../../models/memo_order.dart';
import '../../models/memo_json.dart';
import '../../mappers/memo_mapper.dart';
import '../support/change_recorder.dart';
import '../support/database_fingerprint.dart';
part 'memo_exchange.dart';

/// 备忘录唯一业务写边界：固定身份、父子事务及 outbox 一起提交。
class MemoRepository
    implements
        MemoQueryRepository,
        MemoEntryRepository,
        MemoBookRepository,
        MemoTransferRepository,
        MemoAccountRepository {
  /// 在现有数据库连接中完成用例的原子读写，失败保留异常堆栈。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    try {
      return await db.transaction(action);
    } catch (error, stackTrace) {
      logger.error(
        'MemoRepository',
        '本地事务未完成，已回滚',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 交换格式沿用同一个仓储实例，完整快照与 outbox 的事务不拆开。
  @override
  Future<MemoJsonDocument> exportJson(String id) =>
      _exchange('导出笔记', () => MemoExchange(this).exportJson(id));

  /// 捕获固定目标的导入预览版本。
  @override
  Future<MemoImportPreview> previewImport(
    MemoJsonDocument input,
    PrivateBookTarget fixed,
  ) =>
      _exchange('预览笔记导入', () => MemoExchange(this).previewImport(input, fixed));

  /// 同一实例提交预览所对应的标准文档。
  @override
  Future<({int imported, int skipped, bool pendingSync})> importJson(
    MemoImportPreview preview, {
    void Function(int, int)? onProgress,
  }) => _exchange(
    '导入笔记',
    () => MemoExchange(this).importJson(preview, onProgress: onProgress),
  );

  /// 退出账号时复用副本的幂等身份和原子事务。
  @override
  Future<String> copyToLocalForAccountExit(String id, String operationId) =>
      _exchange(
        '保护退出账号的笔记',
        () => MemoExchange(this).copyToLocalForAccountExit(id, operationId),
      );

  /// 记录交换操作的上下文和原始堆栈，保留领域错误供应用层转换提示。
  Future<T> _exchange<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      logger.error(
        'MemoRepository',
        '$operation失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  final SesameDatabase db;
  final ChangeRecorder? changeRecorder;
  @override
  final String? Function() accountIdGetter;
  @override
  final int Function() generationGetter;
  MemoRepository(
    this.db, {
    this.changeRecorder,
    String? Function()? accountIdGetter,
    int Function()? generationGetter,
  }) : accountIdGetter = accountIdGetter ?? (() => null),
       generationGetter = generationGetter ?? (() => 0);
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
  static const _visible =
      "b.deleted_at IS NULL AND b.is_hidden=0 AND b.pending_local_delete=0 AND (b.storage_mode='local' OR b.scope_account_id=?)";
  void _check(String? accountId, int generation) {
    if (accountIdGetter() != accountId || generationGetter() != generation) {
      throw StateError('MEMO_SESSION_CHANGED');
    }
  }

  void _id(String id) {
    if (!_uuid.hasMatch(id)) throw const FormatException('MEMO_ID');
  }

  d.Selectable<MemoBook> _books(String? accountId, {String? id}) => db
      .customSelect(
        'SELECT b.*, count(m.id) AS entry_count FROM memo_books b LEFT JOIN memo_entries m ON m.memo_book_id=b.id AND m.deleted_at IS NULL WHERE $_visible${id == null ? '' : ' AND b.id=?'} GROUP BY b.id ORDER BY b.storage_mode ASC,b.updated_at DESC,b.id ASC',
        variables: [
          d.Variable(accountId ?? ''),
          if (id != null) d.Variable(id),
        ],
        readsFrom: {db.memoBooks, db.memoEntries},
      )
      .map(
        (r) => memoBookFromRow(
          db.memoBooks.map(r.data),
          count: r.read<int>('entry_count'),
        ),
      );
  @override
  Future<List<MemoBook>> getBooks({String? accountId}) =>
      _books(accountId).get();
  @override
  Stream<List<MemoBook>> watchBooks({String? accountId}) =>
      _books(accountId).watch();
  @override
  Future<MemoBook?> getBook(String id, {String? accountId}) =>
      _books(accountId, id: id).getSingleOrNull();

  late final lifecycle = PrivateBookLifecycle<MemoBook>(
    db: db,
    table: db.memoBooks,
    errorPrefix: 'MEMO',
    parentIdColumn: 'memo_book_id',
    sourceParentColumn: 'source_memo_book_id',
    accountIdGetter: accountIdGetter,
    generationGetter: generationGetter,
    read: (id, account) => getBook(id, accountId: account),
    record: (book, action, payload, now, revision) =>
        _record(book, 'memo_book', book.id, action, payload, now, revision),
  );
  @override
  Future<PrivateBookTarget> target(String id) => lifecycle.target(id);
  @override
  Future<MemoBook> requireTarget(PrivateBookTarget target) =>
      lifecycle.requireTarget(target);

  /// 查询固定本子，摘要列表和完整正文共用权限、日期与数量限制。
  d.Selectable<MemoEntry> _entries(
    String bookId,
    String? accountId, {
    bool includeBody = true,
    DateTime? start,
    DateTime? end,
    int? limit,
  }) => _entryQuery(
    accountId: accountId,
    scope: 'm.memo_book_id=?',
    scopeValue: bookId,
    includeBody: includeBody,
    start: start,
    end: end,
    limit: limit,
  );

  /// 账号密码卡片按所属本查询：列表页只展示当前选中的账号密码本。
  ///
  /// [search] 非空时按全部字段的名称与取值过滤（卡片名称只用于显示），
  /// 空串保持原有全量口径。
  @override
  Stream<List<MemoEntry>> watchCredentialEntries({
    required String bookId,
    String? accountId,
    int? limit = 100,
    String search = '',
    CredentialSort sort = CredentialSort.manual,
  }) => _entryQuery(
    accountId: accountId,
    scope: "b.type='$memoBookTypeCredentials' AND b.id=?",
    scopeValue: bookId,
    includeBody: false,
    limit: limit,
    search: search,
    credentialSort: sort,
  ).watch();

  /// 单本列表与账号密码全集共用同一套列投影、预览与排序。
  d.Selectable<MemoEntry> _entryQuery({
    required String? accountId,
    required String scope,
    required String scopeValue,
    bool includeBody = true,
    DateTime? start,
    DateTime? end,
    int? limit,
    String search = '',
    CredentialSort? credentialSort,
  }) {
    final columns = db.memoEntries.$columns
        .map((column) {
          final name = column.$name;
          if (!includeBody) {
            if (name == 'body') return 'NULL AS "$name"';
            if (name == 'title') {
              if (credentialSort != null) return 'm."$name"';
              return 'substr(CAST(m."$name" AS BLOB),1,2048) AS "$name"';
            }
          }
          return 'm."$name"';
        })
        .join(',');
    // 列表只读取纯文字预览：普通笔记取正文文字，账号密码卡片取前两个字段。
    final preview = includeBody
        ? 'NULL'
        : "CASE WHEN b.type='credentials' "
              "THEN substr(CAST((SELECT group_concat(json_extract(f.value, '\$.label') || '：' || json_extract(f.value, '\$.value'), char(10)) FROM (SELECT value FROM json_each(m.body, '\$.fields') LIMIT 2) f) AS BLOB),1,2048) "
              "ELSE substr(CAST((SELECT group_concat(json_extract(value, '\$.insert'), '') FROM json_each(m.body, '\$.ops')) AS BLOB),1,2048) END";
    final variables = <d.Variable>[
      d.Variable(scopeValue),
      d.Variable(accountId ?? ''),
    ];
    var range = '';
    if (start != null && end != null) {
      range = ' AND m.updated_at >= ? AND m.updated_at < ?';
      variables.addAll([
        d.Variable(start.millisecondsSinceEpoch),
        d.Variable(end.millisecondsSinceEpoch),
      ]);
    }
    // 关键词过滤在 SQL 内完成：按卡片字段名称与取值匹配（卡片名称只用于显示），
    // 字段遍历与摘要读取共用同一份 json_each 展开口径，列表仍只读摘要、不解析正文。
    final keyword = search.trim();
    final searchClause = keyword.isEmpty
        ? ''
        : " AND b.type='credentials' AND EXISTS (SELECT 1 FROM json_each(CASE WHEN json_valid(m.body) THEN m.body ELSE '{}' END, '\$.fields') AS s WHERE json_extract(s.value, '\$.label') LIKE ? ESCAPE '\\' OR json_extract(s.value, '\$.value') LIKE ? ESCAPE '\\')";
    // 名称排序在完整摘要集合上由系统中文排序器完成，不能先截断分页。
    final ordering = switch (credentialSort) {
      CredentialSort.updated => 'm.updated_at DESC,m.id ASC',
      CredentialSort.manual ||
      CredentialSort.title => 'm.order_key ASC,m.id ASC',
      null when start != null => 'm.updated_at DESC,m.id ASC',
      null =>
        "CASE WHEN b.type='credentials' THEN m.order_key END ASC,"
            "CASE WHEN b.type='normal' THEN m.updated_at END DESC,m.id ASC",
    };
    return db
        .customSelect(
          'SELECT $columns, $preview AS preview_text FROM memo_entries m JOIN memo_books b ON b.id=m.memo_book_id WHERE $scope AND $_visible AND m.deleted_at IS NULL$range$searchClause ORDER BY $ordering${limit == null ? '' : ' LIMIT ?'}',
          variables: [
            ...variables,
            if (keyword.isNotEmpty) ...[
              d.Variable(_likePattern(keyword)),
              d.Variable(_likePattern(keyword)),
            ],
            if (limit != null) d.Variable(limit),
          ],
          readsFrom: {db.memoEntries, db.memoBooks},
        )
        .map((row) {
          final data = Map<String, dynamic>.from(row.data);
          if (!includeBody && credentialSort == null) {
            data['title'] = _preview(data['title']) ?? '';
          }
          return memoEntryFromRow(
            db.memoEntries.map(data),
            previewText: _preview(data['preview_text']),
            summary: !includeBody,
          );
        });
  }

  // 先按最多 2048 字节读取，再按 Unicode 标量截取；保留 NUL 且不拆开表情。
  String? _preview(Object? value) {
    if (value == null) return null;
    final text = value is List<int>
        ? utf8.decode(value, allowMalformed: true)
        : value as String;
    return String.fromCharCodes(text.runes.take(512));
  }

  /// 关键词转 LIKE 模式：转义通配符后两端加 %，让用户输入的 % 与 _ 按字面匹配。
  String _likePattern(String keyword) =>
      '%${keyword.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';

  @override
  Future<List<MemoEntry>> getEntries(String id, {String? accountId}) =>
      _entries(id, accountId).get();
  @override
  Stream<List<MemoEntry>> watchEntries(
    String id, {
    String? accountId,
    DateTime? date,
    int? limit = 100,
  }) {
    final start = date == null
        ? null
        : DateTime(date.year, date.month, date.day).toUtc();
    final end = date == null
        ? null
        : DateTime(date.year, date.month, date.day + 1).toUtc();
    return _entries(
      id,
      accountId,
      includeBody: false,
      start: start,
      end: end,
      limit: limit,
    ).watch();
  }

  @override
  Future<MemoEntry?> getEntry(String id, PrivateBookTarget target) async {
    await requireTarget(target);
    final row =
        await (db.select(db.memoEntries)..where(
              (e) =>
                  e.id.equals(id) &
                  e.memoBookId.equals(target.bookId) &
                  e.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    await requireTarget(target);
    return row == null ? null : memoEntryFromRow(row);
  }

  /// 月历统计仅查询更新时间，普通笔记和账号密码沿用同一权限与本地日期边界。
  @override
  Stream<Map<DateTime, int>> watchCalendarCounts(
    String bookId, {
    required DateTime start,
    required DateTime until,
    String? accountId,
  }) => db
      .customSelect(
        'SELECT m.updated_at FROM memo_entries m JOIN memo_books b ON b.id=m.memo_book_id WHERE m.memo_book_id=? AND $_visible AND m.deleted_at IS NULL AND m.updated_at>=? AND m.updated_at<?',
        variables: [
          d.Variable(bookId),
          d.Variable(accountId ?? ''),
          d.Variable(start.millisecondsSinceEpoch),
          d.Variable(until.millisecondsSinceEpoch),
        ],
        readsFrom: {db.memoEntries, db.memoBooks},
      )
      .watch()
      .map((rows) {
        final counts = <DateTime, int>{};
        for (final row in rows) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('updated_at'),
          );
          final day = DateTime(date.year, date.month, date.day);
          counts.update(day, (count) => count + 1, ifAbsent: () => 1);
        }
        return counts;
      });

  Future<T> _write<T>(
    String? accountId,
    int generation,
    Future<T> Function() work,
  ) async {
    try {
      return await db.transaction(() async {
        _check(accountId, generation);
        final result = await work();
        _check(accountId, generation);
        return result;
      });
    } on FormatException {
      rethrow;
    } on StateError {
      rethrow;
    } catch (_) {
      // SQLite 错误可能携带绑定参数；不得把正文或密码穿透至日志与 UI。
      throw StateError('MEMO_WRITE_FAILED');
    }
  }

  Future<void> _record(
    MemoBook book,
    String type,
    String id,
    String action,
    Map<String, Object?> payload,
    DateTime now,
    int revision,
  ) async {
    if (!book.isCloud) return;
    if (changeRecorder == null) throw StateError('MEMO_SYNC_UNAVAILABLE');
    await changeRecorder!.recordMemoChange(
      entityType: type,
      entityId: id,
      memoBookId: book.id,
      accountId: book.scopeAccountId!,
      action: action,
      payload: jsonEncode(payload),
      updatedAt: now,
      baseRevision: revision,
    );
  }

  @override
  Future<MemoBook> createBook({
    required String id,
    required String name,
    required String type,
    String storageMode = 'local',
    String? accountId,
    int? generation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    validateMemoBookDefinition(name, type);
    return lifecycle.create(
      id: id,
      name: name,
      extra: {'type': type},
      storageMode: storageMode,
      accountId: accountId,
      generation: generation,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> renameBook(PrivateBookTarget target, String name) =>
      lifecycle.rename(target, name);
  Future<void> _touch(String id, DateTime now) => db
      .customUpdate(
        'UPDATE memo_books SET updated_at=max(updated_at,?) WHERE id=?',
        variables: [d.Variable(now.millisecondsSinceEpoch), d.Variable(id)],
        updates: {db.memoBooks},
      )
      .then((_) {});
  @override
  Future<void> saveEntry(
    MemoEntry value,
    PrivateBookTarget target, {
    bool preserveTimes = false,
  }) => _write(target.accountId, target.generation, () async {
    _id(value.id);
    final book = await requireTarget(target);
    if (value.memoBookId != book.id || value.bookType != book.type) {
      throw StateError('MEMO_PARENT_CHANGED');
    }
    value.validate();
    final old = await (db.select(
      db.memoEntries,
    )..where((e) => e.id.equals(value.id))).getSingleOrNull();
    if (old != null && (old.memoBookId != book.id || old.deletedAt != null)) {
      throw StateError('MEMO_ENTRY_CHANGED');
    }
    int? order = old?.orderKey;
    if (value.isCard && old == null) {
      final max = db.memoEntries.orderKey.max();
      final row =
          await (db.selectOnly(db.memoEntries)
                ..addColumns([max])
                ..where(
                  db.memoEntries.memoBookId.equals(book.id) &
                      db.memoEntries.deletedAt.isNull(),
                ))
              .getSingle();
      final last = row.read(max) ?? -1;
      if (preserveTimes && value.orderKey != null) {
        order = value.orderKey;
      } else {
        // 仅活动卡片决定追加位置；先检查上限，避免整数加法溢出为负值。
        if (last == 9223372036854775807) {
          throw StateError('MEMO_ORDER_CAPACITY');
        }
        order = last + 1;
      }
    }
    final now = preserveTimes ? value.updatedAt : DateTime.now().toUtc();
    final saved = MemoEntry(
      id: value.id,
      memoBookId: book.id,
      bookType: book.type,
      title: value.title,
      bodyJson: value.bodyJson,
      orderKey: order,
      createdAt: old?.createdAt ?? (preserveTimes ? value.createdAt : now),
      updatedAt: now,
      serverRevision: book.isCloud ? old?.serverRevision ?? 0 : null,
      sourceEntryId: old?.sourceEntryId ?? value.sourceEntryId,
      sourceConflictId: old?.sourceConflictId ?? value.sourceConflictId,
    );
    await db
        .into(db.memoEntries)
        .insertOnConflictUpdate(memoEntryToCompanion(saved));
    await _touch(book.id, now);
    await _record(
      book,
      'memo_entry',
      saved.id,
      'upsert',
      saved.payload,
      now,
      saved.serverRevision ?? 0,
    );
  });

  /// 重排只修改顺序和编辑时间，卡片正文取事务内最新值，避免覆盖并发编辑。
  @override
  Future<void> reorderCredentials(
    PrivateBookTarget target,
    List<MemoEntry> visibleEntries,
    List<String> reorderedIds,
  ) => _write(target.accountId, target.generation, () async {
    final book = await requireTarget(target);
    if (book.type != memoBookTypeCredentials) {
      throw StateError('MEMO_BOOK_TYPE_CHANGED');
    }
    final entries = await getEntries(book.id, accountId: target.accountId);
    if (entries.any((entry) => entry.orderKey == null || entry.orderKey! < 0)) {
      throw StateError('MEMO_ORDER_CHANGED');
    }
    entries.sort(compareCredentialOrder);
    final byId = {for (final entry in entries) entry.id: entry};
    // 使用展示时的版本检查拖动目标，过期列表不能把旧顺序覆盖到新内容上。
    for (final visible in visibleEntries) {
      final current = byId[visible.id];
      if (visible.memoBookId != book.id ||
          !visible.isCard ||
          current == null ||
          current.serverRevision != visible.serverRevision ||
          current.updatedAt != visible.updatedAt ||
          current.orderKey != visible.orderKey ||
          current.title != visible.title) {
        throw StateError('MEMO_ORDER_CHANGED');
      }
    }
    final ids = mergeCredentialOrder(
      entries,
      visibleEntries.map((entry) => entry.id).toList(),
      reorderedIds,
    );
    final now = DateTime.now().toUtc();
    var changed = false;
    for (var index = 0; index < ids.length; index++) {
      final entry = byId[ids[index]]!;
      if (entry.orderKey == index) continue;
      final saved = MemoEntry(
        id: entry.id,
        memoBookId: entry.memoBookId,
        bookType: entry.bookType,
        title: entry.title,
        bodyJson: entry.bodyJson,
        orderKey: index,
        createdAt: entry.createdAt,
        updatedAt: now,
        serverRevision: entry.serverRevision,
        sourceEntryId: entry.sourceEntryId,
        sourceConflictId: entry.sourceConflictId,
      );
      await (db.update(
        db.memoEntries,
      )..where((row) => row.id.equals(entry.id))).write(
        MemoEntriesCompanion(orderKey: d.Value(index), updatedAt: d.Value(now)),
      );
      await _record(
        book,
        'memo_entry',
        entry.id,
        'upsert',
        saved.payload,
        now,
        entry.serverRevision ?? 0,
      );
      changed = true;
    }
    if (changed) await _touch(book.id, now);
  });

  Future<void> deleteEntry(String id, PrivateBookTarget target) => _write(
    target.accountId,
    target.generation,
    () async {
      final book = await requireTarget(target);
      final entry = await getEntry(id, target);
      if (entry == null) return;
      final now = DateTime.now().toUtc();
      // 本机保留墓碑，导入去重和同步删除共用原有卡片身份。
      await (db.update(db.memoEntries)..where((e) => e.id.equals(id))).write(
        MemoEntriesCompanion(deletedAt: d.Value(now), updatedAt: d.Value(now)),
      );
      await _touch(book.id, now);
      await _record(
        book,
        'memo_entry',
        id,
        'delete',
        {},
        now,
        entry.serverRevision ?? 0,
      );
    },
  );
  Future<void> deleteBook(
    PrivateBookTarget target, {
    required int expectedCount,
    String? expectedFullCursor,
  }) => lifecycle.delete(
    target,
    expectedFullCursor: expectedFullCursor,
    validatePreview: (book) async {
      if (book.entryCount != expectedCount) {
        throw StateError('MEMO_DELETE_PREVIEW_CHANGED');
      }
    },
  );

  /// 冲突副本使用新身份与唯一来源，保留原始内容时间，卡片追加在同本末尾。
  Future<String?> preserveEntry(MemoEntryRow source, String conflictId) async {
    final existing = await (db.select(
      db.memoEntries,
    )..where((e) => e.sourceConflictId.equals(conflictId))).getSingleOrNull();
    if (existing != null) return existing.id;
    if (source.deletedAt != null) return null;
    final original = memoEntryFromRow(source);
    final parent = await (db.select(
      db.memoBooks,
    )..where((b) => b.id.equals(source.memoBookId))).getSingle();
    if (parent.pendingLocalDelete ||
        parent.isStale ||
        parent.isHidden ||
        parent.deletedAt != null) {
      final copy = await preserveBook(parent.id, conflictId);
      return (await (db.select(db.memoEntries)..where(
                (e) =>
                    e.memoBookId.equals(copy.id) &
                    e.sourceEntryId.equals(source.id),
              ))
              .getSingleOrNull())
          ?.id;
    }
    final target = await this.target(source.memoBookId);
    final id = const Uuid().v4();
    await saveEntry(
      MemoEntry(
        id: id,
        memoBookId: source.memoBookId,
        bookType: source.bookType,
        title: original.title,
        bodyJson: original.bodyJson,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        sourceEntryId: source.id,
        sourceConflictId: conflictId,
      ),
      target,
      preserveTimes: true,
    );
    return id;
  }

  /// 远端父本不可用时仍按原账号保护完整分支，不降为所有账号可见的本机本。
  Future<MemoBook> preserveBook(String sourceId, String operationId) =>
      _write(accountIdGetter(), generationGetter(), () async {
        final source = await (db.select(
          db.memoBooks,
        )..where((b) => b.id.equals(sourceId))).getSingle();
        if (source.scopeAccountId == null ||
            source.scopeAccountId != accountIdGetter()) {
          throw StateError('MEMO_SCOPE');
        }
        final existing =
            await (db.select(db.memoBooks)..where(
                  (b) =>
                      b.sourceMemoBookId.equals(sourceId) &
                      b.sourceOperationId.equals(operationId),
                ))
                .getSingleOrNull();
        if (existing != null) return memoBookFromRow(existing);
        final id = const Uuid().v4();
        final book = await createBook(
          id: id,
          name: source.name,
          type: source.type,
          storageMode: 'cloud',
          accountId: source.scopeAccountId,
          createdAt: source.createdAt,
          updatedAt: source.updatedAt,
        );
        await (db.update(db.memoBooks)..where((b) => b.id.equals(id))).write(
          MemoBooksCompanion(
            sourceAccountId: d.Value(source.scopeAccountId),
            sourceMemoBookId: d.Value(sourceId),
            sourceOperationId: d.Value(operationId),
          ),
        );
        final target = await this.target(id);
        final entries =
            await (db.select(db.memoEntries)..where(
                  (e) => e.memoBookId.equals(sourceId) & e.deletedAt.isNull(),
                ))
                .get();
        final mapping = <String, String>{};
        for (final row in entries) {
          final value = memoEntryFromRow(row);
          final copyId = const Uuid().v4();
          mapping[row.id] = copyId;
          await saveEntry(
            MemoEntry(
              id: copyId,
              memoBookId: id,
              bookType: value.bookType,
              title: value.title,
              bodyJson: value.bodyJson,
              orderKey: value.orderKey,
              createdAt: value.createdAt,
              updatedAt: value.updatedAt,
              sourceEntryId: value.id,
            ),
            target,
            preserveTimes: true,
          );
        }
        final receipts = await (db.select(
          db.memoImportReceipts,
        )..where((r) => r.targetMemoBookId.equals(sourceId))).get();
        for (final receipt in receipts) {
          await db
              .into(db.memoImportReceipts)
              .insert(
                MemoImportReceiptsCompanion.insert(
                  targetMemoBookId: id,
                  exportId: receipt.exportId,
                  sourceBookId: receipt.sourceBookId,
                  sourceEntryId: receipt.sourceEntryId,
                  fingerprint: receipt.fingerprint,
                  localEntryId: d.Value(mapping[receipt.localEntryId]),
                  importedAt: receipt.importedAt,
                ),
              );
        }
        return book;
      });
}
