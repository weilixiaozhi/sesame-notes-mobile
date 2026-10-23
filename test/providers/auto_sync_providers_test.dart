import 'dart:async';

import 'package:drift/drift.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 独立的待推内容可与回执等表通知区分，测试使用固定编辑时钟。
AutoSyncPendingMutation _mutation(String id) =>
    (mutationId: id, payload: '{}', updatedAt: DateTime.utc(2026));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<Set<TableUpdate>> controller;
  late List<int> syncCalls;
  late Set<AutoSyncPendingMutation> pending;

  setUp(() {
    controller = StreamController<Set<TableUpdate>>();
    syncCalls = [];
    pending = {_mutation('pending')};
  });

  tearDown(() => controller.close());

  /// 构造只管理上传的调度器，执行次数和待推快照均由当前用例控制。
  AutoSyncCoordinator buildCoordinator({
    bool loggedIn = true,
    Duration debounce = const Duration(seconds: 2),
  }) {
    return AutoSyncCoordinator(
      changes: controller.stream.map((s) => s),
      isLoggedIn: () => loggedIn,
      pendingMutations: () async => pending,
      sync: () async {
        syncCalls.add(syncCalls.length + 1);
        return const SyncRunResult();
      },
      debounce: debounce,
    );
  }

  test('变更登记后防抖触发一次同步（登录态）', () {
    fakeAsync((async) {
      final coordinator = buildCoordinator();
      coordinator.start();
      try {
        controller.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        expect(syncCalls, isEmpty, reason: '防抖窗口内不得立即同步');
        async.elapse(const Duration(milliseconds: 100));
        expect(syncCalls, isEmpty);
        async.elapse(const Duration(milliseconds: 1900));
        expect(syncCalls, hasLength(1), reason: '防抖窗口结束触发一次同步');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('登录态启动时主动调度一轮同步，已有 pending 无需等待下一次编辑', () {
    fakeAsync((async) {
      final coordinator = buildCoordinator(
        debounce: const Duration(milliseconds: 10),
      );
      coordinator.start(syncOnStart: true);
      try {
        async.elapse(const Duration(milliseconds: 10));
        expect(syncCalls, hasLength(1), reason: '冷启动或重新登录后必须主动消费已有队列');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('防抖合并：窗口内多次变更只触发一次', () {
    fakeAsync((async) {
      final coordinator = buildCoordinator();
      coordinator.start();
      try {
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(milliseconds: 500));
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(milliseconds: 500));
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(seconds: 2));

        expect(syncCalls, hasLength(1), reason: '2s 窗口内 3 次变更合并为一次同步');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('未登录不触发同步', () {
    fakeAsync((async) {
      final coordinator = buildCoordinator(loggedIn: false);
      coordinator.start();
      try {
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(seconds: 3));
        expect(syncCalls, isEmpty, reason: '未登录时变更只入队不推送');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('同步执行期间的新变更在完成后重新排队（仍有待推 mutation）', () {
    fakeAsync((async) {
      // 慢同步：首次执行挂起，期间新变更应被防抖重新调度。
      final gate = Completer<void>();
      var calls = 0;
      var current = {_mutation('first')};
      final coordinator = AutoSyncCoordinator(
        changes: controller.stream.map((s) => s),
        isLoggedIn: () => true,
        sync: () async {
          calls++;
          if (calls == 1) await gate.future; // 第一次挂起
          return const SyncRunResult();
        },
        // 默认语义：执行期变更视为仍有待推 mutation，必须补跑一轮。
        pendingMutations: () async => current,
        debounce: const Duration(seconds: 2),
      );
      coordinator.start();
      try {
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1, reason: '首次同步已启动');
        // 执行期间新变更 → 防抖调度；完成后触发第二次。
        current = {...current, _mutation('second')};
        controller.add({TableUpdate('sync_changes')});
        // 先派发异步变更流，确保新变更在首轮同步挂起期间到达。
        async.flushMicrotasks();
        gate.complete();
        async.elapse(const Duration(seconds: 2));
        expect(calls, greaterThanOrEqualTo(2), reason: '执行期变更在完成后重新触发');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('同步执行期间仅产生 pushedAt 标记（无待推 mutation）时不重排尾随空转轮', () {
    fakeAsync((async) {
      // 场景：push 仅标记 pushedAt（无待推 mutation）同样发射 sync_changes 表变化，
      // 该变化不应再排一轮空转同步（push/pull 均为 0）拉长串行链。
      final gate = Completer<void>();
      var calls = 0;
      var current = {_mutation('first')};
      final coordinator = AutoSyncCoordinator(
        changes: controller.stream.map((s) => s),
        isLoggedIn: () => true,
        sync: () async {
          calls++;
          if (calls == 1) await gate.future; // 第一次挂起
          return const SyncRunResult();
        },
        // 执行期变更已被本轮 push 消费：无待推 mutation，无需补跑。
        pendingMutations: () async => current,
        debounce: const Duration(seconds: 2),
      );
      coordinator.start();
      try {
        controller.add({TableUpdate('sync_changes')});
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1, reason: '首次同步已启动');
        current = {};
        controller.add({TableUpdate('sync_changes')});
        async.flushMicrotasks();
        gate.complete();
        async.elapse(const Duration(seconds: 3));
        expect(calls, 1, reason: '无待推 mutation 时不得重排尾随空转轮');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('只有持久full任务也会触发同步，首轮未补齐后按退避重试并在成功后停止', () {
    fakeAsync((async) {
      var pending = true;
      var calls = 0;
      late final AutoSyncCoordinator coordinator;
      coordinator = AutoSyncCoordinator(
        changes: controller.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => const {},
        hasPendingDownloads: () async => pending,
        sync: () async {
          calls++;
          // 网络错误由统一同步入口转为结果，首轮留下的任务仍需后台补齐。
          if (calls == 2) {
            pending = false;
            coordinator.pendingDownloadsChanged({});
          }
          return const SyncRunResult();
        },
      );
      coordinator.start();
      try {
        coordinator.pendingDownloadsChanged({'ledger'});
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        async.elapse(const Duration(milliseconds: 4999));
        expect(calls, 1);
        async.elapse(const Duration(milliseconds: 1));
        expect(calls, 2);
        async.elapse(const Duration(hours: 1));
        expect(calls, 2, reason: '任务已清除后不能继续定时同步');
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  test('full重试指数退避至上限，重复pending通知不改成快速循环且五次后停止', () {
    fakeAsync((async) {
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: controller.stream,
        isLoggedIn: () => true,
        pendingMutations: () async => const {},
        hasPendingDownloads: () async => true,
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
        maxRetryDelay: const Duration(seconds: 20),
      );
      coordinator.start();
      try {
        coordinator.pendingDownloadsChanged({'ledger'});
        async.elapse(const Duration(seconds: 2));
        expect(calls, 1);
        coordinator.pendingDownloadsChanged({'ledger'});
        async.elapse(const Duration(seconds: 5));
        expect(calls, 2);
        coordinator.pendingDownloadsChanged({'ledger'});
        async.elapse(const Duration(seconds: 9));
        expect(calls, 2);
        async.elapse(const Duration(seconds: 1));
        expect(calls, 3);
        async.elapse(const Duration(seconds: 20));
        expect(calls, 4);
        async.elapse(const Duration(seconds: 20));
        expect(calls, 5, reason: '达到上限后仍使用固定上限，不回退到防抖间隔');
        async.elapse(const Duration(seconds: 20));
        expect(calls, 6);
        coordinator.pendingDownloadsChanged({'ledger'});
        async.elapse(const Duration(days: 1));
        expect(calls, 6, reason: '同一下载集合不能重置五次自动重试预算');
        expect(async.nonPeriodicTimerCount, 0);
      } finally {
        coordinator.dispose();
        async.flushMicrotasks();
      }
    });
  });

  for (final oldRetryable in [false, true]) {
    test('已有${oldRetryable ? '退避任务' : '失效任务'}时新增下载ID仍在防抖后唤醒', () {
      fakeAsync((async) {
        var retryable = oldRetryable;
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: controller.stream,
          isLoggedIn: () => true,
          pendingMutations: () async => const {},
          hasPendingDownloads: () async => retryable,
          sync: () async {
            calls++;
            return const SyncRunResult();
          },
        );
        coordinator.start();
        try {
          coordinator.pendingDownloadsChanged({'old'});
          async.elapse(const Duration(seconds: 2));
          expect(calls, 1);
          retryable = true;
          coordinator.pendingDownloadsChanged({'old', 'new'});
          async.elapse(const Duration(milliseconds: 1999));
          expect(calls, 1);
          async.elapse(const Duration(milliseconds: 1));
          expect(calls, 2);
        } finally {
          coordinator.dispose();
          async.flushMicrotasks();
        }
      });
    });
  }

  for (final reason in ['离线', '恢复闸门']) {
    test('$reason期间不忙循环，条件恢复后继续；暂停期间任务清除则停止', () {
      fakeAsync((async) {
        var available = false;
        var pending = true;
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: controller.stream,
          isLoggedIn: () => true,
          canSync: () => available,
          pendingMutations: () async => const {},
          hasPendingDownloads: () async => pending,
          sync: () async {
            calls++;
            return const SyncRunResult();
          },
        );
        coordinator.start(syncOnStart: true);
        try {
          coordinator.pendingDownloadsChanged({'ledger'});
          async.elapse(const Duration(hours: 1));
          expect(calls, 0);
          expect(async.nonPeriodicTimerCount, 0);
          available = true;
          coordinator.availabilityChanged();
          async.elapse(const Duration(seconds: 2));
          expect(calls, 1);
          available = false;
          coordinator.availabilityChanged();
          async.elapse(const Duration(hours: 1));
          expect(calls, 1);
          expect(async.nonPeriodicTimerCount, 0);
          pending = false;
          coordinator.pendingDownloadsChanged({});
          available = true;
          coordinator.availabilityChanged();
          async.elapse(const Duration(hours: 1));
          expect(calls, 1);
        } finally {
          coordinator.dispose();
          async.flushMicrotasks();
        }
      });
    });
  }

  test('登出和销毁取消full退避计时器，不触发迟到同步', () {
    fakeAsync((async) {
      var loggedIn = true;
      var calls = 0;
      final coordinator = AutoSyncCoordinator(
        changes: controller.stream,
        isLoggedIn: () => loggedIn,
        pendingMutations: () async => const {},
        hasPendingDownloads: () async => true,
        sync: () async {
          calls++;
          return const SyncRunResult();
        },
      );
      coordinator.start();
      coordinator.pendingDownloadsChanged({'ledger'});
      async.elapse(const Duration(seconds: 2));
      expect(calls, 1);
      loggedIn = false;
      coordinator.availabilityChanged();
      async.elapse(const Duration(hours: 1));
      expect(calls, 1);
      coordinator.dispose();
      loggedIn = true;
      coordinator.availabilityChanged();
      async.elapse(const Duration(hours: 1));
      expect(calls, 1);
      async.flushMicrotasks();
    });
  });

  for (final dispose in [false, true]) {
    test('查询待下载任务期间${dispose ? '销毁' : '清除标记'}，迟到结果不能重新创建重试', () {
      fakeAsync((async) {
        final response = Completer<bool>();
        var calls = 0;
        final coordinator = AutoSyncCoordinator(
          changes: controller.stream,
          isLoggedIn: () => true,
          pendingMutations: () async => const {},
          hasPendingDownloads: () => response.future,
          sync: () async {
            calls++;
            return const SyncRunResult();
          },
        );
        coordinator.start();
        try {
          coordinator.pendingDownloadsChanged({'ledger'});
          async.elapse(const Duration(seconds: 2));
          expect(calls, 1);
          if (dispose) {
            coordinator.dispose();
          } else {
            coordinator.pendingDownloadsChanged({});
          }
          response.complete(true);
          async.flushMicrotasks();
          async.elapse(const Duration(hours: 1));
          expect(calls, 1);
        } finally {
          coordinator.dispose();
          async.flushMicrotasks();
        }
      });
    });
  }
}
