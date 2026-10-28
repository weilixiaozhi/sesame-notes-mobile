import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/services/notification/notification_navigation.dart';

/// 只处理应用允许的通知目标，拒绝外部地址。
void main() {
  tearDown(() => NotificationNavigation.pending.value = null);

  test('只接受应用定义的通知路径，忽略旧通知和外部地址', () {
    for (final payload in [null, '', 'https://example.com', '/auth/login']) {
      NotificationNavigation.receive(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: payload,
        ),
      );
      expect(NotificationNavigation.pending.value, isNull);
    }
  });
}
