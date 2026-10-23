import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 同一 mutation 的正文与编辑时间共同表示待推内容，冻结等簿记不构成新写入。
AutoSyncPendingMutation _mutation(String id, {String payload = '正文'}) =>
    (mutationId: id, payload: payload, updatedAt: DateTime.utc(2026, 10, 19));

/// 可恢复原因使用正式同步入口的稳定失败事实。
SyncRunResult _failure(String code) => SyncRunResult(
  failure: SyncOperationFailure(code: code, message: '数据已保存在本机'),
);

/// 精确推进生产调度器的重试期限，所有用例均不等待真实时钟。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('首次读取下载集合沿用冷启动计时器，不推迟已有同步期限', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => const {},
        hasPendingDownloads: () async => true,
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 1));
        coordinator.pendingDownloadsChanged({'initial-full'});
        async.elapse(const Duration(seconds: 1));
        expect(calls, 1, reason: '首次下载集合和启动同步共用原两秒期限');
        async.elapse(const Duration(seconds: 4));
        expect(calls, 1);
        async.elapse(const Duration(seconds: 1));
        expect(calls, 2, reason: '首轮未完成的下载按五秒退避补跑');
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('网络轮次开始前读出的下载集合由本轮消费，不作为执行中新任务快速补跑', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final baseline = Completer<Set<AutoSyncPendingMutation>>();
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () => baseline.future,
        hasPendingDownloads: () async => true,
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 2));
        coordinator.pendingDownloadsChanged({'initial-full'});
        baseline.complete({});
        async.flushMicrotasks();
        expect(calls, 1);
        async.elapse(const Duration(seconds: 4));
        expect(calls, 1);
        async.elapse(const Duration(seconds: 1));
        expect(calls, 2);
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  for (final code in ['NETWORK_UNAVAILABLE', 'CLOUD_SERVICE_UNAVAILABLE']) {
    test('$code无新操作也按5/10/20/40/60秒自动重试且耗尽后停止', () {
      fakeAsync((async) {
        final changes = StreamController<Set<TableUpdate>>();
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: changes.stream,
          isLoggedIn: () => true,
          pendingMutations: () async => {_mutation('same-mutation')},
          sync: () async {
            calls++;
            return _failure(code);
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          async.elapse(const Duration(seconds: 2));
          expect(calls, 1);
          for (final seconds in [5, 10, 20, 40, 60]) {
            changes.add({TableUpdate('sync_changes')});
            async.flushMicrotasks();
            async.elapse(Duration(milliseconds: seconds * 1000 - 1));
            expect(calls, lessThan(7));
            final before = calls;
            async.elapse(const Duration(milliseconds: 1));
            expect(calls, before + 1);
          }
          expect(calls, 6, reason: '初次同步加最多五次自动重试');
          changes.add({TableUpdate('sync_changes')});
          async.elapse(const Duration(days: 1));
          expect(calls, 6, reason: '同一队列的簿记通知不得重新获得重试预算');
          expect(async.nonPeriodicTimerCount, 0);
        } finally {
          coordinator.dispose();
          unawaited(changes.close());
          async.flushMicrotasks();
        }
      });
    });
  }

  for (final code in [
    'AUTH_REQUIRED',
    'PERMISSION_DENIED',
    'SYNC_REJECTED',
    'SYNC_REQUIRES_ATTENTION',
    'SYNC_PENDING_UPLOAD',
    'SYNC_OPERATION_CANCELLED',
    'SYNC_DATA_UNREADABLE',
    'SYNC_OPERATION_FAILED',
  ]) {
    test('$code保留待推内容和full任务但不自动重复尝试', () {
      fakeAsync((async) {
        final changes = StreamController<Set<TableUpdate>>();
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: changes.stream,
          isLoggedIn: () => true,
          pendingMutations: () async => {_mutation('pending')},
          hasPendingDownloads: () async => true,
          sync: () async {
            calls++;
            changes.add({TableUpdate('sync_changes')});
            return _failure(code);
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          coordinator.pendingDownloadsChanged({'full-ledger'});
          async.elapse(const Duration(days: 1));
          expect(calls, 1);
          expect(async.nonPeriodicTimerCount, 0);
        } finally {
          coordinator.dispose();
          unawaited(changes.close());
          async.flushMicrotasks();
        }
      });
    });
  }

  for (final newId in [false, true]) {
    test('预算耗尽后${newId ? '新增mutation' : '合并编辑同一mutation'}唤醒并获得新预算', () {
      fakeAsync((async) {
        final changes = StreamController<Set<TableUpdate>>();
        var pending = {_mutation('old')};
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: changes.stream,
          isLoggedIn: () => true,
          pendingMutations: () async => pending,
          sync: () async {
            calls++;
            return _failure('NETWORK_UNAVAILABLE');
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          async.elapse(const Duration(days: 1));
          expect(calls, 6);
          pending = newId
              ? {...pending, _mutation('new')}
              : {_mutation('old', payload: '编辑后的正文')};
          changes.add({TableUpdate('sync_changes')});
          async.elapse(const Duration(seconds: 2));
          expect(calls, 7);
          async.elapse(const Duration(seconds: 5));
          expect(calls, 8);
        } finally {
          coordinator.dispose();
          unawaited(changes.close());
          async.flushMicrotasks();
        }
      });
    });
  }

  test('预算耗尽后网络恢复会唤醒，明确离线和闸门期间无计时空转', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      var available = true;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        canSync: () => available,
        pendingMutations: () async => {_mutation('pending')},
        sync: () async {
          calls++;
          return _failure('NETWORK_UNAVAILABLE');
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(days: 1));
        expect(calls, 6);
        available = false;
        coordinator.availabilityChanged();
        async.elapse(const Duration(days: 1));
        expect(calls, 6);
        expect(async.nonPeriodicTimerCount, 0);
        available = true;
        coordinator.availabilityChanged();
        async.elapse(const Duration(seconds: 2));
        expect(calls, 7);
        async.elapse(const Duration(seconds: 5));
        expect(calls, 8);
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('重试成功后清除计时器，后续簿记通知不安排空同步', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      var pending = {_mutation('pending')};
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => pending,
        sync: () async {
          calls++;
          if (calls == 1) return _failure('NETWORK_UNAVAILABLE');
          pending = {};
          changes.add({TableUpdate('sync_changes')});
          return const SyncRunResult();
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 7));
        expect(calls, 2);
        changes.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(days: 1));
        expect(calls, 2);
        expect(async.nonPeriodicTimerCount, 0);
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('其他同步入口已完成同一队列后，回执通知取消原自动退避', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      var pending = {_mutation('pending')};
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => pending,
        sync: () async {
          calls++;
          return _failure('NETWORK_UNAVAILABLE');
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        pending = {};
        changes.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(days: 1));
        expect(calls, 1);
        expect(async.nonPeriodicTimerCount, 0);
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  test('退避触发后仍是单飞，在途新编辑仅合并一轮尾随同步', () {
    fakeAsync((async) {
      final changes = StreamController<Set<TableUpdate>>();
      final response = Completer<SyncRunResult>();
      var pending = {_mutation('first')};
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: changes.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => pending,
        sync: () async {
          calls++;
          if (calls == 1) return _failure('NETWORK_UNAVAILABLE');
          if (calls == 2) return response.future;
          pending = {};
          return const SyncRunResult();
        },
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(seconds: 7));
        expect(calls, 2);
        for (var index = 0; index < 3; index++) {
          pending = {...pending, _mutation('new-$index')};
          changes.add({TableUpdate('sync_changes')});
          async.elapse(const Duration(seconds: 2));
        }
        expect(calls, 2, reason: '在途请求不能因新写入发生重入');
        response.complete(_failure('NETWORK_UNAVAILABLE'));
        async.elapse(const Duration(seconds: 2));
        expect(calls, 3);
        async.elapse(const Duration(days: 1));
        expect(calls, 3);
        expect(async.nonPeriodicTimerCount, 0);
      } finally {
        coordinator.dispose();
        unawaited(changes.close());
        async.flushMicrotasks();
      }
    });
  });

  for (final pauseDuringRequest in [false, true]) {
    test('${pauseDuringRequest ? '在途失败' : '退避等待'}遇阻断时暂停，恢复后继续原待推任务', () {
      fakeAsync((async) {
        final changes = StreamController<Set<TableUpdate>>();
        final response = Completer<SyncRunResult>();
        var available = true;
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: changes.stream,
          isLoggedIn: () => true,
          canSync: () => available,
          pendingMutations: () async => {_mutation('pending')},
          sync: () async {
            calls++;
            if (pauseDuringRequest && calls == 1) return response.future;
            return _failure('NETWORK_UNAVAILABLE');
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          async.elapse(const Duration(seconds: 2));
          expect(calls, 1);
          available = false;
          coordinator.availabilityChanged();
          if (pauseDuringRequest) {
            response.complete(_failure('NETWORK_UNAVAILABLE'));
          }
          async.elapse(const Duration(days: 1));
          expect(calls, 1);
          expect(async.nonPeriodicTimerCount, 0);
          available = true;
          coordinator.availabilityChanged();
          async.elapse(const Duration(seconds: 2));
          expect(calls, 2);
          async.elapse(const Duration(seconds: 5));
          expect(calls, 3);
        } finally {
          coordinator.dispose();
          unawaited(changes.close());
          async.flushMicrotasks();
        }
      });
    });
  }

  for (final dispose in [false, true]) {
    test('读取待推快照期间${dispose ? '销毁' : '账号失效'}，迟到结果不得执行同步', () {
      fakeAsync((async) {
        final changes = StreamController<Set<TableUpdate>>();
        final pending = Completer<Set<AutoSyncPendingMutation>>();
        var loggedIn = true;
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: changes.stream,
          isLoggedIn: () => loggedIn,
          pendingMutations: () => pending.future,
          sync: () async {
            calls++;
            return _failure('NETWORK_UNAVAILABLE');
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          async.elapse(const Duration(seconds: 2));
          if (dispose) {
            coordinator.dispose();
          } else {
            loggedIn = false;
            coordinator.availabilityChanged();
          }
          pending.complete({_mutation('old-account')});
          async.elapse(const Duration(days: 1));
          expect(calls, 0);
          expect(async.nonPeriodicTimerCount, 0);
        } finally {
          coordinator.dispose();
          unawaited(changes.close());
          async.flushMicrotasks();
        }
      });
    });
  }
}
