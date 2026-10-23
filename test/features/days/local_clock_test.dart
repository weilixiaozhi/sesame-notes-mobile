import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('午夜刷新后，前台时钟变化立即重读日期', () {
    fakeAsync((async) {
      var now = DateTime(2026, 9, 7, 23, 59, 59);
      final events = StreamController<void>();
      final container = ProviderContainer(
        overrides: [
          localClockNowProvider.overrideWithValue(() => now),
          clockChangeEventsProvider.overrideWithValue(events.stream),
        ],
      );
      final subscription = container.listen(localTodayProvider, (_, _) {});
      expect(subscription.read(), DateTime(2026, 9, 7));
      now = DateTime(2026, 9, 8);
      async.elapse(const Duration(seconds: 1));
      expect(subscription.read(), DateTime(2026, 9, 8));
      now = DateTime(2026, 9, 6, 20);
      events.add(null);
      async.flushMicrotasks();
      expect(subscription.read(), DateTime(2026, 9, 6));
      container
          .read(localTodayProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.paused);
      now = DateTime(2026, 9, 10, 6);
      async.elapse(const Duration(days: 2));
      expect(subscription.read(), DateTime(2026, 9, 6));
      container
          .read(localTodayProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(subscription.read(), DateTime(2026, 9, 10));
      subscription.close();
      container.dispose();
      unawaited(events.close());
      async.flushMicrotasks();
      expect(async.pendingTimers, isEmpty);
    });
  });
}
