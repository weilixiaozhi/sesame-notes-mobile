import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

/// 首值读取临时保持来源活跃，完成、失败和调用方销毁均应释放。
void main() {
  for (final fails in [false, true]) {
    test('无人监听的调用方${fails ? '收到错误' : '取得首值'}后释放来源', () async {
      var canceled = 0;
      final events = StreamController<int>(onCancel: () => canceled++);
      final source = StreamProvider.autoDispose<int>((ref) => events.stream);
      final owner = Provider<Future<int>>(
        (ref) => readProviderFutureFromRef(ref, source.future),
      );
      final container = ProviderContainer();
      try {
        final value = container.read(owner);
        await container.pump();
        expect(events.hasListener, isTrue);
        if (fails) {
          final error = StateError('来源不可读');
          final assertion = expectLater(value, throwsA(same(error)));
          events.addError(error);
          await assertion;
        } else {
          events.add(7);
          expect(await value, 7);
        }
        await container.pump();
        expect(canceled, 1);
        expect(events.hasListener, isFalse);
      } catch (error, stackTrace) {
        logger.error(
          'ProviderFutureLifecycleTest',
          '首值读取释放验证失败',
          error,
          stackTrace,
        );
        rethrow;
      } finally {
        container.dispose();
        await events.close();
      }
    });
  }

  test('调用方销毁后停止等待常驻来源并释放临时监听', () async {
    var pauses = 0;
    final events = StreamController<int>(onPause: () => pauses++);
    // 常驻来源不会因无人监听而销毁，取消必须由读取者主动完成。
    final source = StreamProvider<int>((ref) => events.stream);
    final owner = Provider.autoDispose<Future<int>>(
      (ref) => readProviderFutureFromRef(ref, source.future),
    );
    final container = ProviderContainer();
    final listener = container.listen(owner, (_, _) {});
    try {
      final value = listener.read();
      final assertion = expectLater(value, throwsStateError);
      await container.pump();
      listener.close();
      await container.pump();
      await assertion.timeout(const Duration(seconds: 3));
      expect(pauses, 1, reason: '常驻流应回到暂停状态，临时监听不能继续持有资源');
    } catch (error, stackTrace) {
      logger.error(
        'ProviderFutureLifecycleTest',
        '调用方销毁取消验证失败',
        error,
        stackTrace,
      );
      rethrow;
    } finally {
      listener.close();
      container.dispose();
      await events.close();
    }
  });
}
