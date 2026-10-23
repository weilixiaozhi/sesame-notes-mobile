import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';

void main() {
  const rules = DayDateRules();
  final today = DateOnly(2026, 9, 7);

  /// 天数匹配错误由展示层翻译输入提示，范围错误翻译支持范围提示。
  Matcher invalidInterval() => isA<DayDateException>().having(
    (error) => error.code,
    'code',
    'invalid_interval',
  );
  Matcher outOfRange() => isA<DayDateException>().having(
    (error) => error.code,
    'code',
    'date_out_of_range',
  );

  test('完整整数天数按自然日推算前后日期并保留输入快照', () {
    final result = rules.offsetDatesFromText(today, '5');
    expect(result.before.iso8601, '2026-09-02');
    expect(result.after.iso8601, '2026-09-12');
    expect(result.count, 5);

    // 零天合法：前后都落在同一天。
    final zero = rules.offsetDatesFromText(today, '0');
    expect(zero.before, today);
    expect(zero.after, today);
    expect(zero.count, 0);
  });

  test('非法天数文本拒绝计算，不变成另一个有效天数', () {
    for (final text in ['-1', '1.5', '', ' ', 'abc', '36501']) {
      expect(
        () => rules.offsetDatesFromText(today, text),
        throwsA(invalidInterval()),
        reason: text,
      );
    }
  });

  test('结果越出支持范围报范围错误，不返回半份结果', () {
    for (final start in [DateOnly.minimum, DateOnly.maximum]) {
      expect(
        () => rules.offsetDatesFromText(start, '1'),
        throwsA(outOfRange()),
        reason: start.iso8601,
      );
    }
  });
}
