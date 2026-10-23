import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/data/models/day_book.dart';

void main() {
  test('普通名称共用可见性、首尾空白和 Unicode 码点上限', () {
    expect(normalizeName('\u0085 \uFEFF家庭 🏠\u3000'), '家庭 🏠');
    expect(normalizeDayName('  家庭  '), '家庭');
    expect(normalizeName('🏠' * maxNameLength), '🏠' * maxNameLength);
    for (final name in [
      '',
      ' \u0085',
      '\u200B',
      '\uFE0F',
      '\uD800',
      'a\u0000b',
      '🏠' * (maxNameLength + 1),
    ]) {
      expect(isValidName(name), isFalse, reason: name);
      expect(fitnessValidName(name), isFalse, reason: name);
      expect(() => normalizeDayName(name), throwsException);
    }
    // 正文和密码只检查编码，不套用名称的修剪、长度与控制字符规则。
    expect(isWellFormedText(' a\n b '), isTrue);
  });
  test('协议时间固定 UTC 毫秒，保留瞬间并截断微秒', () {
    final value = DateTime.utc(2026, 9, 14, 3, 2, 1, 123, 456);
    expect(wireTimestamp(value), '2026-09-14T03:02:01.123Z');
    expect(wireTimestamp(value.toLocal()), wireTimestamp(value));
    expect(
      wireTimestamp(DateTime.fromMicrosecondsSinceEpoch(-1, isUtc: true)),
      DateTime.fromMillisecondsSinceEpoch(
        DateTime.fromMicrosecondsSinceEpoch(-1).millisecondsSinceEpoch,
        isUtc: true,
      ).toIso8601String(),
    );
  });
}
