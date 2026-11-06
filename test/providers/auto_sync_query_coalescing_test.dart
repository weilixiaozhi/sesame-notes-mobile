import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 正文变化代表同一队列任务的新编辑，回执和冻结不改变此快照。
AutoSyncPendingMutation _mutation(String body) => (
  mutationId: 'mutation',
  payload: body,
  updatedAt: DateTime.utc(2026, 11, 6),
);

/// 验证减少队列读取的同时，仍能发现执行期间的新编辑并隔离已销毁会话。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('读取期间密集通知只补查最新快照，始终只有一个在途查询', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final firstRead = Completer<Set<AutoSyncPendingMutation>>();
      var reads = 0;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () {
          reads++;
          return reads == 1
              ? firstRead.future
              : Future.value({_mutation('最新正文')});
        },
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      )..start();
      try {
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        for (var i = 0; i < 500; i++) {
          changes.add({TableUpdate('sync_changes')});
        }
        async.flushMicrotasks();
        expect(reads, 1, reason: '已有读取未完成时不得并发查询');
        firstRead.complete({_mutation('旧正文')});
        async.flushMicrotasks();
        expect(reads, 2, reason: '所有在途变更只需补查一次最新快照');
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1, reason: '最新编辑仍会正常唤醒同步');
      } catch (error, stackTrace) {
        printOnFailure('队列查询合并回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('自动同步期间冻结通知不读取队列，结束后仍能补推新编辑', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final firstSync = Completer<SyncRunResult>();
      var pending = {_mutation('初始正文')};
      var reads = 0;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async {
          reads++;
          return pending;
        },
        sync: () {
          calls++;
          return calls == 1
              ? firstSync.future
              : Future.value(const SyncRunResult());
        },
      )..start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        expect(reads, 1);
        for (var i = 0; i < 500; i++) {
          changes.add({TableUpdate('sync_changes')});
          async.flushMicrotasks();
        }
        expect(reads, 1, reason: '逐条冻结和回执不重复搬运待推正文');
        pending = {_mutation('同步期间的新正文')};
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        firstSync.complete(const SyncRunResult());
        async.flushMicrotasks();
        expect(reads, 2, reason: '同步结束后统一核对最新待推快照');
        async.elapse(const Duration(seconds: 2));
        expect(calls, 2, reason: '执行期间新增的编辑不能被合并逻辑吞掉');
      } catch (error, stackTrace) {
        printOnFailure('同步期间查询回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('手动同步期间的通知也合并，结束后检查尚未发送的新编辑', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      var pending = <AutoSyncPendingMutation>{};
      var reads = 0;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async {
          reads++;
          return pending;
        },
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      )..start();
      try {
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        expect(reads, 1);
        coordinator.syncActivityChanged(true);
        for (var i = 0; i < 500; i++) {
          changes.add({TableUpdate('sync_changes')});
          async.flushMicrotasks();
        }
        pending = {_mutation('手动同步期间的新正文')};
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        expect(reads, 1);
        coordinator.syncActivityChanged(false);
        async.flushMicrotasks();
        expect(reads, 2);
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
      } catch (error, stackTrace) {
        printOnFailure('手动同步查询合并回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('同步收尾检查下载期间的新编辑仍会补推', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final downloads = Completer<bool>();
      var pending = <AutoSyncPendingMutation>{};
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => pending,
        hasPendingDownloads: () => downloads.future,
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      )..start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        pending = {_mutation('收尾期间的新正文')};
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        downloads.complete(false);
        async.elapse(const Duration(seconds: 2));
        expect(calls, 2, reason: '下载查询期间的新编辑不能遗漏');
      } catch (error, stackTrace) {
        printOnFailure('同步收尾编辑回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('收尾补读编辑期间加入的下载任务不会被旧快照覆盖', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final downloads = Completer<bool>();
      final pendingRead = Completer<Set<AutoSyncPendingMutation>>();
      var reads = 0;
      var downloadReads = 0;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () {
          reads++;
          return reads == 3 ? pendingRead.future : Future.value(const {});
        },
        hasPendingDownloads: () {
          downloadReads++;
          return downloadReads == 1 ? downloads.future : Future.value(true);
        },
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      )..start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        downloads.complete(false);
        async.flushMicrotasks();
        expect(reads, 3);
        coordinator.pendingDownloadsChanged({'new-download'});
        pendingRead.complete(const {});
        async.flushMicrotasks();
        expect(downloadReads, 2, reason: '新增下载不能被旧的无任务结果覆盖');
        async.elapse(const Duration(seconds: 2));
        expect(calls, 2, reason: '新下载必须在首轮结束后及时消费');
      } catch (error, stackTrace) {
        printOnFailure('收尾下载快照回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('销毁期间的迟到查询不补查且不建立同步计时器', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final response = Completer<Set<AutoSyncPendingMutation>>();
      var reads = 0;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () {
          reads++;
          return response.future;
        },
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      )..start();
      try {
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        changes.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        coordinator.dispose();
        response.complete({_mutation('迟到正文')});
        async.elapse(const Duration(minutes: 1));
        expect(reads, 1);
        expect(calls, 0);
        expect(async.nonPeriodicTimerCount, 0);
      } catch (error, stackTrace) {
        printOnFailure('同步销毁隔离回归失败：$error\n$stackTrace');
        rethrow;
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });
}
