import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import '../helpers/ledger_sync_fixture.dart';
import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  final now = DateTime.utc(2026, 9, 13);
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('全局查询包含四类内容和隐藏操作，排除其他账号，普通上传只汇总', () async {
    const account = 'account-a';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger',
            name: '账本',
            scopeAccountId: const d.Value(account),
            storageMode: const d.Value('cloud'),
            bindingStatus: const d.Value('stale'),
            updatedAt: now,
          ),
        );
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: 'day',
            name: '隐藏的日子删除',
            scopeAccountId: const d.Value(account),
            storageMode: const d.Value('cloud'),
            serverRevision: const d.Value(1),
            syncId: const d.Value('binding'),
            pendingLocalDelete: const d.Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: 'memo',
            name: '记事本',
            type: 'normal',
            scopeAccountId: const d.Value(account),
            storageMode: const d.Value('cloud'),
            serverRevision: const d.Value(1),
            syncId: const d.Value('binding'),
            isStale: const d.Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: 'copy',
            name: '隐藏的移动副本',
            isHidden: const d.Value(true),
            sourceAccountId: const d.Value(account),
            sourceDayBookId: const d.Value('day'),
            sourceOperationId: const d.Value(
              'local-move:account-a:day_book:day:binding',
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final (type, parent) in [
      ('transaction', 'ledger'),
      ('day_event', 'day'),
      ('memo_entry', 'memo'),
      ('fitness_workout', ''),
    ]) {
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: type,
              entityType: type,
              entityId: '$type-id',
              accountId: d.Value(account),
              ledgerId: d.Value(type == 'transaction' ? parent : null),
              dayBookId: d.Value(type == 'day_event' ? parent : null),
              memoBookId: d.Value(type == 'memo_entry' ? parent : null),
              localPayload: jsonEncode({'name': type}),
              remotePayload: '{}',
              baseRevision: 1,
              remoteRevision: 2,
              localMutationId: type,
            ),
          );
    }
    for (final actor in [account, 'account-b']) {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'day_book',
              entityId: 'day',
              dayBookId: const d.Value('day'),
              accountId: d.Value(actor),
              action: 'delete',
              payload: '{}',
              updatedAt: now,
              mutationId: actor,
              rejectionReason: d.Value('$actor-only'),
            ),
          );
    }
    for (var i = 0; i < 3; i++) {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: 'category-$i',
              accountId: const d.Value(account),
              action: 'upsert',
              payload: '{}',
              updatedAt: now,
              mutationId: 'category-$i',
            ),
          );
    }
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'other-account-history',
            accountId: d.Value('other-account'),
            entityType: 'transaction',
            entityId: 'private-id',
            ledgerId: const d.Value('not-local'),
            localPayload: '{"title":"other-account"}',
            remotePayload: '{}',
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'old-account-request',
          ),
        );
    final issues = await readSyncIssues(
      db,
      account: account,
      includeFitnessCompleteness: false,
    );
    expect(issues.where((i) => i.kind == SyncIssueKind.conflict), hasLength(4));
    expect(
      issues
          .where((i) => i.kind == SyncIssueKind.conflict)
          .map((i) => i.target.type)
          .toSet(),
      {'transaction', 'day_event', 'memo_entry', 'fitness_workout'},
    );
    expect(
      issues.any(
        (i) => i.kind == SyncIssueKind.pendingMove && i.target.id == 'day',
      ),
      isTrue,
    );
    expect(
      issues.singleWhere((i) => i.kind == SyncIssueKind.rejected).reason,
      'account-a-only',
    );
    expect(
      issues.singleWhere((i) => i.kind == SyncIssueKind.pendingUpload).count,
      3,
    );
    expect(
      issues
          .where((i) => i.kind == SyncIssueKind.stale)
          .map((i) => i.target.type)
          .toSet(),
      {'ledger', 'memo_book'},
    );
    expect(issues.any((i) => i.reason == 'account-b-only'), isFalse);
  });

  test('删除重试固定快照：预览不写入，确认时拒绝变化，重新预览后正确完成', () async {
    const account = 'account-a';
    final repo = LocalRepository(
      db,
      accountIdGetter: () => account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    final id = await repo.createLedger(name: '删除预览', storageMode: 'cloud');
    await (db.update(db.ledgers)..where((b) => b.id.equals(id))).write(
      const LedgersCompanion(syncId: d.Value('binding')),
    );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '19',
      happenedAt: now,
    );
    await repo.deleteLedger(id);
    final fixture = LedgerSyncFixture(
      db,
      account,
      localSelfId: () async => 'self',
    );
    addTearDown(() => fixture.client.dio.close(force: true));
    fixture.deleteStatus = 'invalid';
    await fixture.service.push();
    final target = SyncTarget('ledger', id);
    final queued = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).getSingle();
    expect(queued.rejectionReason, isNotNull);
    await expectLater(
      fixture.service.retryRejectedChange(queued.id.toString()),
      throwsStateError,
    );
    final preview = await fixture.service.prepareScopeDelete(target);
    expect(preview.count, 1);
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).getSingle(),
      queued,
    );
    await (db.update(
      db.syncChanges,
    )..where((c) => c.id.equals(queued.id))).write(
      const SyncChangesCompanion(payload: d.Value('{"changed":true}')),
    );
    await expectLater(
      fixture.service.confirmScopeDelete(preview),
      throwsStateError,
    );
    expect(fixture.deleteCalls, 1);
    final fresh = await fixture.service.prepareScopeDelete(target);
    await fixture.service.confirmScopeDelete(fresh);
    final retried = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).getSingle();
    expect(retried.mutationId, isNot(queued.mutationId));
    expect(jsonDecode(retried.payload)['expected_full_cursor'], fresh.cursor);
    // 正式删除确认路径把精确 UTC 时间持久化在正文，冻结前不借用秒级列补时间。
    final deletionTime = jsonDecode(retried.payload)['updated_at'] as String;
    expect(DateTime.parse(deletionTime).isUtc, isTrue);
    expect(deletionTime, endsWith('Z'));
    fixture.deleteStatus = 'accepted';
    await fixture.service.push();
    expect(
      (await (db.select(
        db.ledgers,
      )..where((b) => b.id.equals(id))).getSingle()).deletedAt,
      isNotNull,
    );
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
    );
  });
  test('记账转换的离线删除意图不能提前发布隐藏副本，拒绝后必须重新确认', () async {
    const account = 'account-a';
    final repo = LocalRepository(
      db,
      accountIdGetter: () => account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    final id = await repo.createLedger(name: '隐藏转换', storageMode: 'cloud');
    await (db.update(db.ledgers)..where((b) => b.id.equals(id))).write(
      const LedgersCompanion(syncId: d.Value('binding')),
    );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '35',
      happenedAt: now,
    );
    final fixture = LedgerSyncFixture(
      db,
      account,
      localSelfId: () async => 'self',
    );
    addTearDown(() => fixture.client.dio.close(force: true));
    fixture.deleteStatus = 'invalid';
    final target = SyncTarget('ledger', id);
    await expectLater(
      fixture.service.transferToLocal(target, move: true),
      throwsStateError,
    );
    final hidden = await (db.select(
      db.ledgers,
    )..where((b) => b.bindingStatus.equals('pending_local_move'))).getSingle();
    await expectLater(
      fixture.service.transferToLocal(target, move: true),
      throwsStateError,
    );
    expect(
      (await (db.select(
        db.ledgers,
      )..where((b) => b.id.equals(hidden.id))).getSingle()).bindingStatus,
      'pending_local_move',
    );
    final preview = await fixture.service.prepareScopeDelete(target);
    expect(preview.moving, isTrue);
    expect(preview.count, 1);
    fixture.deleteStatus = 'accepted';
    await fixture.service.confirmScopeDelete(preview);
    expect(
      (await (db.select(
        db.ledgers,
      )..where((b) => b.id.equals(hidden.id))).getSingle()).bindingStatus,
      isNull,
    );
    expect(
      (await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(hidden.id))).getSingle()).amount,
      '35',
    );
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
    );
  });
}
