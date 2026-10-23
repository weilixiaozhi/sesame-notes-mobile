part of 'memo_repository.dart';

extension MemoExchange on MemoRepository {
  /// 上云保留本与内容身份，归属和完整父子队列在同一事务提交。
  Future<void> moveToCloud(PrivateBookTarget target) =>
      lifecycle.promote(target, (cloud) async {
        final entries = await getEntries(cloud.id, accountId: target.accountId);
        final now = DateTime.now().toUtc();
        for (final entry in entries) {
          await (db.update(db.memoEntries)..where((e) => e.id.equals(entry.id)))
              .write(const MemoEntriesCompanion(serverRevision: d.Value(0)));
          await _record(
            cloud,
            'memo_entry',
            entry.id,
            'upsert',
            entry.payload,
            now,
            0,
          );
        }
      });

  Future<String> copyToLocalForAccountExit(String id, String operationId) =>
      _write(accountIdGetter(), generationGetter(), () async {
        final source = await (db.select(
          db.memoBooks,
        )..where((b) => b.id.equals(id))).getSingle();
        if (source.scopeAccountId != accountIdGetter()) {
          throw StateError('MEMO_SCOPE');
        }
        final previous =
            await (db.select(db.memoBooks)..where(
                  (b) =>
                      b.sourceMemoBookId.equals(id) &
                      b.sourceOperationId.equals(operationId),
                ))
                .getSingleOrNull();
        if (previous != null) return previous.id;
        if (source.syncId != null && source.fullCursor == null) {
          throw StateError('MEMO_DOWNLOAD_REQUIRED');
        }
        final entries = await (db.select(
          db.memoEntries,
        )..where((e) => e.memoBookId.equals(id))).get();
        final receipts = await (db.select(
          db.memoImportReceipts,
        )..where((r) => r.targetMemoBookId.equals(id))).get();
        final copy = await restoreSnapshot(
          book: memoBookFromRow(source),
          entries: entries.map(memoEntryFromRow).toList(),
          forceCopy: true,
          receipts: [
            for (final r in receipts)
              {
                'export_id': r.exportId,
                'source_book_id': r.sourceBookId,
                'source_entry_id': r.sourceEntryId,
                'fingerprint': r.fingerprint,
                'local_entry_id': r.localEntryId,
                'imported_at': r.importedAt.millisecondsSinceEpoch ~/ 1000,
              },
          ],
        );
        await (db.update(db.memoBooks)..where((b) => b.id.equals(copy))).write(
          MemoBooksCompanion(sourceOperationId: d.Value(operationId)),
        );
        return copy;
      });

  /// 恢复整本：本机同身份替换，独立副本重映射；云端使用全量水位建立新一代父子意图。
  Future<String> restoreSnapshot({
    required MemoBook book,
    required List<MemoEntry> entries,
    required List<Map<String, Object?>> receipts,
    bool forceCopy = false,
    bool cloud = false,
  }) => _write(accountIdGetter(), generationGetter(), () async {
    final prepared = await lifecycle.prepareRestore(
      book,
      forceCopy: forceCopy,
      cloud: cloud,
      extra: {'type': book.type},
      clearContents: (id) async {
        await (db.delete(
          db.memoImportReceipts,
        )..where((r) => r.targetMemoBookId.equals(id))).go();
        await (db.delete(
          db.memoEntries,
        )..where((e) => e.memoBookId.equals(id))).go();
      },
    );
    final id = prepared.id, copy = prepared.copy;
    final activeBook = (await getBook(id, accountId: accountIdGetter()))!;
    final mapping = <String, String>{};
    final sorted = entries.toList()
      ..sort((a, b) {
        final order = (a.orderKey ?? 0).compareTo(b.orderKey ?? 0);
        return order == 0 ? a.id.compareTo(b.id) : order;
      });
    for (var index = 0; index < sorted.length; index++) {
      final e = sorted[index];
      final collision = await (db.select(
        db.memoEntries,
      )..where((row) => row.id.equals(e.id))).getSingleOrNull();
      final entryId = copy || collision != null ? const Uuid().v4() : e.id;
      mapping[e.id] = entryId;
      final saved = MemoEntry(
        id: entryId,
        memoBookId: id,
        bookType: book.type,
        title: e.title,
        bodyJson: e.bodyJson,
        orderKey: copy && e.isCard ? index : e.orderKey,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        deletedAt: e.deletedAt,
        serverRevision: cloud ? 0 : null,
        sourceEntryId: copy ? e.id : e.sourceEntryId,
      );
      saved.validate();
      await db.into(db.memoEntries).insert(memoEntryToCompanion(saved));
      if (cloud && saved.deletedAt == null) {
        await _record(
          activeBook,
          'memo_entry',
          entryId,
          'upsert',
          saved.payload,
          DateTime.now().toUtc(),
          0,
        );
      }
    }
    for (final r in receipts) {
      await db
          .into(db.memoImportReceipts)
          .insert(
            MemoImportReceiptsCompanion.insert(
              targetMemoBookId: id,
              exportId: r['export_id'] as String,
              sourceBookId: r['source_book_id'] as String,
              sourceEntryId: r['source_entry_id'] as String,
              fingerprint: r['fingerprint'] as String,
              localEntryId: d.Value(mapping[r['local_entry_id']]),
              importedAt: DateTime.fromMillisecondsSinceEpoch(
                (r['imported_at'] as int) * 1000,
                isUtc: true,
              ),
            ),
          );
    }
    return id;
  });

  /// 全部表和收据参与预览版本，避免同名、子项编辑或删除后错误覆盖。
  Future<String> bookFingerprint(String id) async =>
      (await fingerprintTargets(db, [id]))[id]!;

  static Future<Map<String, String>> fingerprintTargets(
    SesameDatabase db,
    Iterable<String> ids, {
    Future<void>? cancelled,
  }) => fingerprintGroups(db, {
    for (final id in ids)
      id: [
        FingerprintTable('memo_books', 'id', id),
        FingerprintTable('memo_entries', 'memo_book_id', id),
        FingerprintTable('memo_import_receipts', 'target_memo_book_id', id),
      ],
  }, cancelled: cancelled);

  Future<MemoJsonDocument> exportJson(String id) {
    final account = accountIdGetter(), generation = generationGetter();
    return _write(account, generation, () async {
      final fixed = await target(id);
      final book = await requireTarget(fixed);
      final document = MemoJsonDocument(
        const Uuid().v4(),
        DateTime.now().toUtc(),
        [MemoJsonBook(book, await getEntries(id, accountId: account))],
      );
      return MemoJsonDocument.decode(document.encode());
    });
  }

  Future<MemoImportPreview> previewImport(
    MemoJsonDocument input,
    PrivateBookTarget fixed,
  ) => _write(fixed.accountId, fixed.generation, () async {
    final document = MemoJsonDocument.decode(input.encode());
    final book = await requireTarget(fixed);
    if (book.type != document.books.single.book.type) {
      throw StateError('MEMO_IMPORT_TYPE');
    }
    return MemoImportPreview(document, fixed, await bookFingerprint(book.id));
  });

  Future<({int imported, int skipped, bool pendingSync})> importJson(
    MemoImportPreview preview, {
    void Function(int, int)? onProgress,
  }) => _write(preview.target.accountId, preview.target.generation, () async {
    final fixed = preview.target;
    final book = await requireTarget(fixed);
    if (await bookFingerprint(book.id) != preview.fingerprint) {
      throw StateError('MEMO_IMPORT_PREVIEW_CHANGED');
    }
    final source = MemoJsonDocument.decode(
      preview.document.encode(),
    ).books.single;
    if (book.type != source.book.type) throw StateError('MEMO_IMPORT_TYPE');
    var imported = 0, skipped = 0;
    final pendingSync = book.isCloud;
    final receipts =
        await (db.select(db.memoImportReceipts)..where(
              (r) =>
                  r.targetMemoBookId.equals(book.id) &
                  r.exportId.equals(preview.document.exportId) &
                  r.sourceBookId.equals(source.book.id),
            ))
            .get();
    final bySource = {for (final r in receipts) r.sourceEntryId: r};
    final bookHash = memoFingerprint(source.json);
    Future<void> receipt(String sourceId, String hash, String? localId) => db
        .into(db.memoImportReceipts)
        .insert(
          MemoImportReceiptsCompanion.insert(
            targetMemoBookId: book.id,
            exportId: preview.document.exportId,
            sourceBookId: source.book.id,
            sourceEntryId: sourceId,
            fingerprint: hash,
            localEntryId: d.Value(localId),
            importedAt: DateTime.now().toUtc(),
          ),
        )
        .then((_) {});
    for (final e in source.entries) {
      final hash = memoFingerprint(e.payload);
      if (bySource[e.id] != null) {
        if (bySource[e.id]!.fingerprint != hash) {
          throw StateError('MEMO_IMPORT_IDENTITY_CONFLICT');
        }
        skipped++;
        onProgress?.call(imported + skipped, source.entries.length);
        continue;
      }
      final id = const Uuid().v4();
      // 不传入源 orderKey，整批按已排序的源顺序追加；内容时间仍原样保留。
      await saveEntry(
        MemoEntry(
          id: id,
          memoBookId: book.id,
          bookType: book.type,
          title: e.title,
          bodyJson: e.bodyJson,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          sourceEntryId: e.id,
        ),
        fixed,
        preserveTimes: true,
      );
      await receipt(e.id, hash, id);
      imported++;
      onProgress?.call(imported + skipped, source.entries.length);
    }
    if (bySource[''] == null) await receipt('', bookHash, null);
    return (imported: imported, skipped: skipped, pendingSync: pendingSync);
  });
}
