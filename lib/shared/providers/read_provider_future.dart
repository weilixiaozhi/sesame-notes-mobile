import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// [Ref] 载体的首值读取；等待期间的监听不随调用方暂停而停收流事件。
Future<T> readProviderFutureFromRef<T>(
  Ref ref,
  ProviderListenable<Future<T>> listenable,
) async {
  // 容器级临时监听保持数据库首帧活跃，调用方失效时仍立即释放订阅。
  final sub = ref.container.listen(listenable, (_, _) {});
  final cancelled = Completer<T>();
  final removeDisposeListener = ref.onDispose(() {
    sub.close();
    if (!cancelled.isCompleted) {
      cancelled.completeError(StateError('Provider首值读取已取消'));
    }
  });
  try {
    // 常驻来源暂停后可能永远没有首帧，调用方销毁必须同时结束旧等待。
    return await Future.any([sub.read(), cancelled.future]);
  } finally {
    removeDisposeListener();
    sub.close();
  }
}

/// 后台服务与测试等待首值时保持真实监听，完成或失败后关闭。
Future<T> readProviderFutureFromContainer<T>(
  ProviderContainer container,
  ProviderListenable<Future<T>> listenable,
) async {
  final sub = container.listen(listenable, (_, _) {});
  try {
    return await sub.read();
  } finally {
    sub.close();
  }
}
