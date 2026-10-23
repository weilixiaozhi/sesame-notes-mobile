import 'package:sesame_notes/core/logging/logger_service.dart';
import '../contracts/fitness_space_repositories.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/domain/fitness/fitness_recovery_branch.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import '../../db.dart';
import '../../models/private_book.dart';
import '../support/change_recorder.dart';
import 'private_book_lifecycle.dart';

FitnessSpace fitnessSpaceFromRow(FitnessSpaceRow row, {int count = 0}) =>
    FitnessSpace(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      storageMode: row.storageMode,
      scopeAccountId: row.scopeAccountId,
      syncId: row.syncId,
      fullCursor: row.fullCursor,
      serverRevision: row.serverRevision,
      deletedAt: row.deletedAt,
      isStale: row.isStale,
      isHidden: row.isHidden,
      pendingLocalDelete: row.pendingLocalDelete,
      sourceAccountId: row.sourceAccountId,
      sourceFitnessSpaceId: row.sourceFitnessSpaceId,
      sourceOperationId: row.sourceOperationId,
      entityCount: count,
    );

class FitnessSpaceRepository
    implements
        FitnessSpaceQueryRepository,
        FitnessSpaceBookRepository,
        FitnessSpaceAccountRepository {
  /// 在现有数据库连接中完成用例的原子读写，失败保留异常堆栈。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    try {
      return await db.transaction(action);
    } catch (error, stackTrace) {
      logger.error(
        'FitnessSpaceRepository',
        '本地事务未完成，已回滚',
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
  FitnessSpaceRepository(
    this.db, {
    this.changeRecorder,
    String? Function()? accountIdGetter,
    int Function()? generationGetter,
  }) : accountIdGetter = accountIdGetter ?? (() => null),
       generationGetter = generationGetter ?? (() => 0);
  d.Selectable<FitnessSpace> _books(String? account, {String? id}) => db
      .customSelect(
        "SELECT b.*,count(e.id) AS entity_count FROM fitness_spaces b LEFT JOIN fitness_entities e ON e.fitness_space_id=b.id AND e.deleted_at IS NULL WHERE b.deleted_at IS NULL AND b.is_hidden=0 AND b.pending_local_delete=0 AND (b.storage_mode='local' OR b.scope_account_id=?)${id == null ? '' : ' AND b.id=?'} GROUP BY b.id ORDER BY b.storage_mode ASC,b.updated_at DESC,b.id ASC",
        variables: [d.Variable(account ?? ''), if (id != null) d.Variable(id)],
        readsFrom: {db.fitnessSpaces, db.fitnessEntities},
      )
      .map(
        (row) => fitnessSpaceFromRow(
          db.fitnessSpaces.map(row.data),
          count: row.read<int>('entity_count'),
        ),
      );
  @override
  Future<List<FitnessSpace>> getBooks({String? accountId}) =>
      _books(accountId).get();
  @override
  Stream<List<FitnessSpace>> watchBooks({String? accountId}) =>
      _books(accountId).watch();
  @override
  Future<FitnessSpace?> getBook(String id, {String? accountId}) =>
      _books(accountId, id: id).getSingleOrNull();
  late final lifecycle = PrivateBookLifecycle<FitnessSpace>(
    db: db,
    table: db.fitnessSpaces,
    errorPrefix: 'FITNESS',
    parentIdColumn: 'fitness_space_id',
    sourceParentColumn: 'source_fitness_space_id',
    accountIdGetter: accountIdGetter,
    generationGetter: generationGetter,
    read: (id, account) => getBook(id, accountId: account),
    record: record,
  );
  @override
  Future<PrivateBookTarget> target(String id) => lifecycle.target(id);
  @override
  Future<FitnessSpace> requireTarget(PrivateBookTarget target) =>
      lifecycle.requireTarget(target);
  @override
  Future<FitnessSpace> createBook({
    required String id,
    required String name,
    String storageMode = 'local',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => lifecycle.create(
    id: id,
    name: name,
    storageMode: storageMode,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  @override
  Future<void> renameBook(PrivateBookTarget target, String name) =>
      lifecycle.rename(target, name);
  Future<void> record(
    FitnessSpace book,
    String action,
    Map<String, Object?> payload,
    DateTime now,
    int revision,
  ) async {
    if (!book.isCloud) return;
    if (changeRecorder == null) throw StateError('FITNESS_SYNC_UNAVAILABLE');
    await changeRecorder!.recordFitnessChange(
      entityType: 'fitness_space',
      entityId: book.id,
      fitnessSpaceId: book.id,
      accountId: book.scopeAccountId!,
      action: action,
      payload: jsonEncode(payload),
      updatedAt: now,
      baseRevision: revision,
    );
  }

  Future<void> moveToCloud(PrivateBookTarget target) =>
      lifecycle.promote(target, (cloud) async {
        final entities = await (db.select(
          db.fitnessEntities,
        )..where((e) => e.fitnessSpaceId.equals(cloud.id))).get();
        for (final entity in entities) {
          await (db.update(
            db.fitnessEntities,
          )..where((e) => e.id.equals(entity.id))).write(
            FitnessEntitiesCompanion(
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(cloud.scopeAccountId),
              syncId: const d.Value(null),
              serverRevision: const d.Value(0),
            ),
          );
          await changeRecorder!.recordFitnessChange(
            entityType: entity.entityType,
            entityId: entity.id,
            fitnessSpaceId: cloud.id,
            accountId: cloud.scopeAccountId!,
            action: 'upsert',
            payload: entity.payload,
            updatedAt: entity.updatedAt,
            baseRevision: 0,
          );
        }
      });
  Future<String> restoreSnapshot({
    required FitnessSpace book,
    required List<FitnessTransferRecord> records,
    List<Map<String, Object?>> receipts = const [],
    List<FitnessRecoveryBranch> branches = const [],
    bool forceCopy = false,
    bool cloud = false,
  }) => lifecycle.write(accountIdGetter(), generationGetter(), () async {
    final target = await lifecycle.prepareRestore(
      book,
      forceCopy: forceCopy,
      cloud: cloud,
      clearContents: (id) => FitnessDataTransfer.clearSpaceContents(db, id),
    );
    await FitnessDataTransfer.importDocument(
      db: db,
      document: FitnessTransferDocument(
        const Uuid().v4(),
        DateTime.now().toUtc(),
        records,
        space: book,
      ),
      fitnessSpaceId: target.id,
      accountId: accountIdGetter(),
      changeRecorder: changeRecorder,
      preserveIds: !target.copy,
      receipts: receipts,
      branches: branches,
    );
    return target.id;
  });

  @override
  Future<String> copyToLocalForAccountExit(String id, String operationId) =>
      lifecycle.write(accountIdGetter(), generationGetter(), () async {
        final source = await (db.select(
          db.fitnessSpaces,
        )..where((b) => b.id.equals(id))).getSingle();
        if (source.scopeAccountId != accountIdGetter()) {
          throw StateError('FITNESS_SCOPE_CHANGED');
        }
        final previous =
            await (db.select(db.fitnessSpaces)..where(
                  (b) =>
                      b.sourceFitnessSpaceId.equals(id) &
                      b.sourceOperationId.equals(operationId),
                ))
                .getSingleOrNull();
        if (previous != null) return previous.id;
        final records = await FitnessDataTransfer.snapshot(
          db,
          fitnessSpaceId: id,
          accountId: source.scopeAccountId,
          requireComplete: false,
        );
        final receipts = await (db.select(
          db.fitnessImportReceipts,
        )..where((r) => r.fitnessSpaceId.equals(id))).get();
        final copy = await restoreSnapshot(
          book: fitnessSpaceFromRow(source),
          records: records,
          forceCopy: true,
          branches: await FitnessDataTransfer.captureBranches(db, records),
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
        );
        await (db.update(
          db.fitnessSpaces,
        )..where((b) => b.id.equals(copy))).write(
          FitnessSpacesCompanion(
            sourceOperationId: d.Value(operationId),
            isStale: d.Value(
              source.isStale ||
                  (source.syncId != null && source.fullCursor == null),
            ),
          ),
        );
        return copy;
      });

  Future<void> deleteBook(
    PrivateBookTarget target, {
    required int expectedCount,
    String? expectedFullCursor,
  }) => lifecycle.delete(
    target,
    expectedFullCursor: expectedFullCursor,
    validatePreview: (book) async {
      if (book.entityCount != expectedCount) {
        throw StateError('FITNESS_DELETE_PREVIEW_CHANGED');
      }
    },
  );
}
