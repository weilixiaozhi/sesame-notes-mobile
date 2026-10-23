import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 原生通道只通知系统时钟改变，不携带业务数据。
final clockChangeEventsProvider = Provider<Stream<void>>(
  (ref) => const EventChannel(
    'com.sesame_notes.clock',
  ).receiveBroadcastStream().map((_) {}),
);

/// 系统时钟读取入口，测试可固定日期并发送独立的平台变化信号。
final localClockNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// 发布当地日期；前台只安排下一午夜的一次性计时器。
final localTodayProvider = NotifierProvider<LocalTodayNotifier, DateTime>(
  LocalTodayNotifier.new,
);

/// 前台时间、时区变化与恢复前台共用一个重新读取入口。
class LocalTodayNotifier extends Notifier<DateTime>
    with WidgetsBindingObserver {
  Timer? _midnight;
  bool _foreground = true;

  /// 对称注册平台信号、生命周期与计时器。
  @override
  DateTime build() {
    WidgetsBinding.instance.addObserver(this);
    final subscription = ref
        .watch(clockChangeEventsProvider)
        .listen(
          (_) => refresh(),
          onError: (Object error, StackTrace stackTrace) {
            logger.error('LocalClock', '系统时间通知暂不可用', error, stackTrace);
          },
        );
    ref.onDispose(() {
      _midnight?.cancel();
      WidgetsBinding.instance.removeObserver(this);
      unawaited(subscription.cancel());
    });
    final now = ref.read(localClockNowProvider)();
    _schedule(now);
    return DateTime(now.year, now.month, now.day);
  }

  /// 使用当地下一午夜，避免固定 24 小时在时区或夏令时切换时偏移。
  void _schedule(DateTime now) {
    _midnight?.cancel();
    if (!_foreground) return;
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), refresh);
  }

  /// 重读系统时间后同时更新日期和下一次唤醒时间。
  void refresh() {
    if (!ref.mounted) return;
    final now = ref.read(localClockNowProvider)();
    state = DateTime(now.year, now.month, now.day);
    _schedule(now);
  }

  /// 后台暂停计时；恢复前台立即核对本地日期。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      refresh();
    } else {
      _midnight?.cancel();
    }
  }
}
