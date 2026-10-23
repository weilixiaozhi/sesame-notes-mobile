import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('防抖：窗口内连续通知只触发一轮同步，且窗口结束后才执行', () {
    fakeAsync((async) {
      var runs = 0;
      final trigger = RealtimeSyncTrigger(
        sync: () async => runs++,
        debounce: const Duration(seconds: 2),
      );

      trigger.notify();
      trigger.notify();
      trigger.notify();
      async.elapse(const Duration(milliseconds: 1900));
      expect(runs, 0, reason: '窗口未结束前不得提前触发同步');

      async.elapse(const Duration(milliseconds: 200));
      expect(runs, 1, reason: '窗口结束后必须恰好触发一轮同步');

      async.elapse(const Duration(seconds: 4));
      expect(runs, 1, reason: '无新通知时不得再触发额外轮次');
    });
  });

  test('防抖：窗口内新通知重置计时，风暴持续期间只保留最后一次计时', () {
    fakeAsync((async) {
      var runs = 0;
      final trigger = RealtimeSyncTrigger(
        sync: () async => runs++,
        debounce: const Duration(seconds: 2),
      );

      trigger.notify();
      for (var i = 0; i < 5; i++) {
        async.elapse(const Duration(milliseconds: 500));
        trigger.notify(); // 每次都在窗口内，重置计时
      }
      async.elapse(const Duration(milliseconds: 1900));
      expect(runs, 0, reason: '风暴未停时不得触发');

      async.elapse(const Duration(milliseconds: 200));
      expect(runs, 1, reason: '风暴结束后合并为一轮');
    });
  });

  test('防抖：执行中的通知合并为单次尾随，完成后不再等待防抖窗口', () {
    fakeAsync((async) {
      var runs = 0;
      // late final：sync 闭包内需要引用 trigger 自身（首轮执行期间注入新通知）。
      late final RealtimeSyncTrigger trigger;
      trigger = RealtimeSyncTrigger(
        sync: () async {
          runs++;
          // 第一轮同步执行期间来了新通知
          if (runs == 1) {
            trigger.notify();
            trigger.notify();
            trigger.notify();
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        debounce: const Duration(seconds: 2),
      );

      trigger.notify();
      async.elapse(const Duration(seconds: 2));

      expect(runs, 1, reason: '执行中的通知必须合并，不能创建无界的并发同步');
      async.elapse(const Duration(milliseconds: 50));
      expect(runs, 2, reason: '首轮结束立即处理尾随通知，不能额外等待两秒防抖');

      async.elapse(const Duration(seconds: 3));
      expect(runs, 2, reason: '合并后无新增通知不得再触发额外轮次');
    });
  });

  test('防抖：dispose 取消未执行的定时器', () {
    fakeAsync((async) {
      var runs = 0;
      final trigger = RealtimeSyncTrigger(
        sync: () async => runs++,
        debounce: const Duration(seconds: 2),
      );

      trigger.notify();
      trigger.dispose();
      trigger.notify();
      async.elapse(const Duration(seconds: 3));
      expect(runs, 0, reason: 'dispose 后不得再触发同步');
    });
  });

  test('同步抛错与异步拒绝均有限退避，预算用尽后不变成常态轮询', () {
    fakeAsync((async) {
      var runs = 0;
      final delays = <Duration>[];
      final trigger = RealtimeSyncTrigger(
        sync: () {
          runs++;
          if (runs.isOdd) throw StateError('同步调用失败');
          return Future<void>.error(StateError('异步调用失败'));
        },
        debounce: const Duration(milliseconds: 100),
        initialRetryDelay: const Duration(seconds: 1),
        maxRetryDelay: const Duration(seconds: 2),
        maxRetryAttempts: 3,
        scheduleTimer: (delay, action) {
          delays.add(delay);
          return Timer(delay, action);
        },
      );
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      expect(runs, 1);
      async.elapse(const Duration(seconds: 1));
      expect(runs, 2);
      async.elapse(const Duration(seconds: 2));
      expect(runs, 3);
      async.elapse(const Duration(seconds: 2));
      expect(runs, 4);
      expect(delays, [
        const Duration(milliseconds: 100),
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 2),
      ]);
      async.elapse(const Duration(minutes: 10));
      expect(runs, 4, reason: '一次通知的恢复预算用尽后不得持续发HTTP请求');
      final failures = logger.logs.where(
        (entry) => entry.tag == 'RealtimeSync' && entry.level == LogLevel.error,
      );
      expect(failures, isNotEmpty);
      expect(failures.last.stackTrace, isNotNull, reason: '延迟和尾随同步的错误必须保留堆栈');
      trigger.dispose();
    });
  });

  test('退避中的通知共用原计时，成功结束恢复并重置后续通知的预算', () {
    fakeAsync((async) {
      var runs = 0;
      final delays = <Duration>[];
      final trigger = RealtimeSyncTrigger(
        sync: () async {
          runs++;
          if (runs <= 2 || runs == 4) throw StateError('暂时失败');
        },
        debounce: const Duration(milliseconds: 100),
        initialRetryDelay: const Duration(seconds: 1),
        maxRetryDelay: const Duration(seconds: 2),
        scheduleTimer: (delay, action) {
          delays.add(delay);
          return Timer(delay, action);
        },
      );
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      for (var index = 0; index < 20; index++) {
        trigger.notify();
      }
      expect(delays, [
        const Duration(milliseconds: 100),
        const Duration(seconds: 1),
      ], reason: '新通知不能不断推迟或提前已安排的失败重试');
      async.elapse(const Duration(seconds: 3));
      expect(runs, 3);
      async.elapse(const Duration(minutes: 5));
      expect(runs, 3, reason: '成功后无待办不得继续同步');
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      expect(runs, 4);
      expect(delays.last, const Duration(seconds: 1));
      trigger.dispose();
    });
  });

  test('运行中出现异常时只安排一个重试，期间通知不会建立并发调用', () {
    fakeAsync((async) {
      var runs = 0;
      final first = Completer<void>();
      final trigger = RealtimeSyncTrigger(
        sync: () {
          runs++;
          return runs == 1 ? first.future : Future<void>.value();
        },
        debounce: const Duration(milliseconds: 100),
        initialRetryDelay: const Duration(seconds: 1),
      );
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      for (var index = 0; index < 20; index++) {
        trigger.notify();
      }
      expect(runs, 1);
      first.completeError(StateError('在途失败'));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      expect(runs, 2, reason: '失败尾随通知和原待办由同一个恢复轮处理');
      async.elapse(const Duration(seconds: 10));
      expect(runs, 2);
      trigger.dispose();
    });
  });

  test('dispose取消已排队的重试，后续通知不能重新唤醒', () {
    fakeAsync((async) {
      var runs = 0;
      final trigger = RealtimeSyncTrigger(
        sync: () async {
          runs++;
          throw StateError('暂时失败');
        },
        debounce: const Duration(milliseconds: 100),
      );
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      trigger.dispose();
      trigger.notify();
      async.elapse(const Duration(minutes: 10));
      expect(runs, 1);
    });
  });

  test('换号取消旧待办后，旧失败不能清理新轮次或重建旧重试', () {
    fakeAsync((async) {
      var runs = 0;
      final oldRun = Completer<void>();
      final newRun = Completer<void>();
      final trigger = RealtimeSyncTrigger(
        sync: () {
          runs++;
          return switch (runs) {
            1 => oldRun.future,
            2 => newRun.future,
            _ => Future<void>.value(),
          };
        },
        debounce: const Duration(milliseconds: 100),
      );
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      trigger.cancelPending();
      trigger.notify();
      async.elapse(const Duration(milliseconds: 100));
      expect(runs, 2);
      oldRun.completeError(StateError('旧身份迟到失败'));
      async.flushMicrotasks();
      trigger.notify();
      expect(runs, 2, reason: '旧结果不能把仍在执行的新身份轮次标成空闲');
      newRun.complete();
      async.flushMicrotasks();
      expect(runs, 3);
      async.elapse(const Duration(minutes: 10));
      expect(runs, 3, reason: '旧身份失败不能生成独立重试');
      trigger.dispose();
    });
  });

  for (final fails in [false, true]) {
    test('dispose后在途${fails ? '失败' : '成功'}结果不会重建尾随或重试', () {
      fakeAsync((async) {
        var runs = 0;
        final pending = Completer<void>();
        final trigger = RealtimeSyncTrigger(
          sync: () {
            runs++;
            return pending.future;
          },
          debounce: const Duration(milliseconds: 100),
        );
        trigger.notify();
        async.elapse(const Duration(milliseconds: 100));
        trigger.notify();
        trigger.dispose();
        if (fails) {
          pending.completeError(StateError('迟到失败'));
        } else {
          pending.complete();
        }
        async.flushMicrotasks();
        trigger.notify();
        async.elapse(const Duration(minutes: 10));
        expect(runs, 1);
      });
    });
  }
}
