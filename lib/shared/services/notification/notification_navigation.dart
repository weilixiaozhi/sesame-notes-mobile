import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 系统通知仅允许打开明确的业务入口，不接受任意外部路由。
enum NotificationDestination {
  bookkeeping('/bookkeeping'),
  days('/days'),
  fitness('/fitness/workout'),
  settings('/settings/reminder');

  const NotificationDestination(this.path);
  final String path;

  /// 校验系统携带的路径，仅识别业务白名单中的通知入口。
  static NotificationDestination? parse(String? payload) {
    for (final destination in values) {
      if (destination.path == payload) return destination;
    }
    return null;
  }
}

/// 点击先进入待处理队列，应用初始化和解锁完成后才消费。
class NotificationNavigation {
  static final pending = ValueNotifier<NotificationDestination?>(null);

  /// 所有渠道共用回调，重复初始化插件也不会覆盖成空处理器。
  static void receive(NotificationResponse response) {
    final destination = NotificationDestination.parse(response.payload);
    if (destination != null) pending.value = destination;
  }
}
