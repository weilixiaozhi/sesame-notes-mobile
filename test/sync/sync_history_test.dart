import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/sync_history.dart';

void main() {
  late SesameDatabase db;
  final time = DateTime.utc(2026, 9, 13);
  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
  });
  tearDown(() => db.close());
  Future<void> seed() async {
    await db.batch(
      (b) => b.insertAll(db.syncChanges, [
        for (var i = 0; i < 105; i++)
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx',
            accountId: const d.Value('a'),
            action: 'upsert',
            payload: '{"content":"version-$i"}',
            updatedAt: time,
            mutationId: 'ack-$i',
            pushedAt: d.Value(time),
            frozenRequest: d.Value('frozen-$i'),
          ),
        for (final name in ['unknown', 'rejected', 'other'])
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: name,
            accountId: d.Value(name == 'other' ? 'b' : 'a'),
            action: 'upsert',
            payload: '{"content":"$name"}',
            updatedAt: time,
            mutationId: name,
            pushedAt: d.Value(name == 'other' ? time : null),
            frozenRequest: d.Value('frozen-$name'),
            rejectionReason: d.Value(name == 'rejected' ? 'invalid' : null),
          ),
      ]),
    );
    await db.batch(
      (b) => b.insertAll(db.syncConflicts, [
        for (var i = 0; i < 105; i++)
          SyncConflictsCompanion.insert(
            id: 'resolved-$i',
            accountId: d.Value('a'),
            entityType: 'transaction',
            entityId: 'e-$i',
            localPayload: '{"content":"local"}',
            remotePayload: '{"content":"remote"}',
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'm-$i',
            status: const d.Value('RESOLVED_REMOTE'),
            resolvedAt: d.Value(time),
          ),
        SyncConflictsCompanion.insert(
          id: 'open',
          accountId: d.Value('a'),
          entityType: 'transaction',
          entityId: 'open',
          localPayload: '{"content":"local"}',
          remotePayload: '{"content":"remote"}',
          baseRevision: 1,
          remoteRevision: 2,
          localMutationId: 'open',
        ),
        SyncConflictsCompanion.insert(
          id: 'recovery',
          accountId: d.Value('a'),
          entityType: 'fitness_workout',
          entityId: 'recovery',
          localPayload: '{"content":"local"}',
          remotePayload: '{"content":"remote"}',
          baseRevision: 1,
          remoteRevision: 2,
          localMutationId: 'fitness-recovery:pending',
          status: const d.Value('RESOLVED_REMOTE'),
        ),
      ]),
    );
  }

  test('只压缩本账号已确认历史，未知请求/拒绝/冲突/待决定恢复分支完整保留', () async {
    await seed();
    await compactSyncHistory(db, accountId: 'a');
    final all = await db.select(db.syncChanges).get();
    final acknowledged = all
        .where((r) => r.accountId == 'a' && r.pushedAt != null)
        .toList();
    expect(acknowledged, hasLength(100));
    expect(
      acknowledged.every((r) => r.payload == '{}' && r.frozenRequest == null),
      isTrue,
    );
    for (final name in ['unknown', 'rejected', 'other']) {
      final row = all.singleWhere((r) => r.mutationId == name);
      expect(row.payload, '{"content":"$name"}');
      expect(row.frozenRequest, 'frozen-$name');
    }
    final conflicts = await db.select(db.syncConflicts).get();
    expect(conflicts.where((c) => c.resolvedAt != null), hasLength(100));
    expect(
      conflicts
          .where((c) => c.resolvedAt != null)
          .every((c) => c.localPayload == '{}' && c.remotePayload == '{}'),
      isTrue,
    );
    for (final id in ['open', 'recovery']) {
      expect(
        conflicts.singleWhere((c) => c.id == id).remotePayload,
        '{"content":"remote"}',
      );
    }
  });
  test('外层事务失败时完整回滚，不把未知分支当垃圾清理', () async {
    await seed();
    final before = await db.select(db.syncChanges).get();
    await expectLater(
      db.transaction(() async {
        await compactSyncHistory(db, accountId: 'a');
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await db.select(db.syncChanges).get(), before);
  });
  test('没有待清理内容时不发布变化，避免自动同步空转', () async {
    await seed();
    await compactSyncHistory(db, accountId: 'a');
    var changes = 0;
    final sub = db
        .tableUpdates(
          d.TableUpdateQuery.onAllTables([db.syncChanges, db.syncConflicts]),
        )
        .listen((_) => changes++);
    await compactSyncHistory(db, accountId: 'a');
    await Future<void>.delayed(Duration.zero);
    expect(changes, 0);
    await sub.cancel();
  });
}
