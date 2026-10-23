import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:sesame_notes/shared/services/notification/notification_util.dart';

void main() {
  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
  });
  tearDown(() => tz.setLocalLocation(tz.UTC));

  test('UTC 单次提醒转换保留原时间点和毫秒', () {
    final instant = DateTime.utc(2026, 9, 7, 10, 30, 0, 123);

    final converted = convertToTZDateTime(instant);

    expect(converted.millisecondsSinceEpoch, instant.millisecondsSinceEpoch);
    expect(converted.hour, 18);
  });

  test('进入夏令时的明天仍在本地 21 点提醒', () {
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    final next = calculateNextReminderTime(
      21,
      0,
      now: tz.TZDateTime(tz.local, 2026, 3, 7, 22),
    );

    expect(next.toUtc(), DateTime.utc(2026, 3, 9, 1));
  });

  test('结束夏令时的明天仍在本地 21 点提醒', () {
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    final next = calculateNextReminderTime(
      21,
      0,
      now: tz.TZDateTime(tz.local, 2026, 10, 31, 22),
    );

    expect(next.toUtc(), DateTime.utc(2026, 11, 2, 2));
  });
}
