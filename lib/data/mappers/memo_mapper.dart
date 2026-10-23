import 'package:drift/drift.dart' as d;
import '../db.dart';
import '../models/memo.dart';

MemoBook memoBookFromRow(MemoBookRow row, {int count = 0}) => MemoBook(
  id: row.id,
  name: row.name,
  type: row.type,
  storageMode: row.storageMode,
  scopeAccountId: row.scopeAccountId,
  syncId: row.syncId,
  serverRevision: row.serverRevision,
  fullCursor: row.fullCursor,
  createdAt: row.createdAt.toUtc(),
  updatedAt: row.updatedAt.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
  pendingLocalDelete: row.pendingLocalDelete,
  isStale: row.isStale,
  isHidden: row.isHidden,
  sourceAccountId: row.sourceAccountId,
  sourceMemoBookId: row.sourceMemoBookId,
  sourceOperationId: row.sourceOperationId,
  entryCount: count,
);

MemoEntry memoEntryFromRow(
  MemoEntryRow row, {
  String? previewText,
  bool summary = false,
}) => MemoEntry(
  previewText: previewText,
  isSummary: summary,
  id: row.id,
  memoBookId: row.memoBookId,
  bookType: row.bookType,
  title: row.title,
  bodyJson: row.body,
  orderKey: row.orderKey,
  serverRevision: row.serverRevision,
  createdAt: row.createdAt.toUtc(),
  updatedAt: row.updatedAt.toUtc(),
  deletedAt: row.deletedAt?.toUtc(),
  sourceEntryId: row.sourceEntryId,
  sourceConflictId: row.sourceConflictId,
);

MemoEntriesCompanion memoEntryToCompanion(MemoEntry entry) =>
    MemoEntriesCompanion.insert(
      id: entry.id,
      memoBookId: entry.memoBookId,
      bookType: entry.bookType,
      title: entry.title,
      bodyFormat: d.Value(entry.isCard ? 'fields_v1' : 'delta_v1'),
      body: d.Value(entry.bodyJson),
      orderKey: d.Value(entry.orderKey),
      serverRevision: d.Value(entry.serverRevision),
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      deletedAt: d.Value(entry.deletedAt),
      sourceEntryId: d.Value(entry.sourceEntryId),
      sourceConflictId: d.Value(entry.sourceConflictId),
    );
