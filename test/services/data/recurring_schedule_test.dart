import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';

RecurringTransactionSnapshot rule({
  String frequency = 'daily',
  int interval = 1,
  DateTime? start,
  DateTime? after,
  DateTime? end,
  int? day,
  int? weekday,
  int? month,
}) => RecurringTransactionSnapshot(
  id: 'rule',
  ledgerId: 'ledger',
  txType: 'expense',
  amount: '1',
  currencyCode: 'CNY',
  frequency: frequency,
  interval: interval,
  startDate: start ?? DateTime.utc(2024, 1, 31),
  lastGeneratedDate: after,
  endDate: end,
  dayOfMonth: day,
  dayOfWeek: weekday,
  monthOfYear: month,
  enabled: true,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

void main() {
  final future = DateTime.utc(2030);
  test('SHA256发生UUID与服务端黄金向量完全相同', () {
    expect(
      recurringOccurrenceId(
        '11111111-1111-4111-8111-111111111111',
        '22222222-2222-4222-8222-222222222222',
        '2024-02-29',
      ),
      '8567ad8c-6340-4f61-b255-ad8e2317d077',
    );
  });
  test('weekly以start锚点和指定星期排班，编辑星期不跳过下一有效发生', () {
    expect(
      nextRecurringDate(
        rule(frequency: 'weekly', interval: 2, weekday: 1),
        future,
      ),
      DateTime.utc(2024, 2, 5),
    );
    expect(
      nextRecurringDate(
        rule(
          frequency: 'weekly',
          interval: 2,
          weekday: 1,
          after: DateTime.utc(2024, 2, 5),
        ),
        future,
      ),
      DateTime.utc(2024, 2, 19),
    );
    expect(
      nextRecurringDate(
        rule(frequency: 'weekly', weekday: 5, after: DateTime.utc(2024, 2, 5)),
        future,
      ),
      DateTime.utc(2024, 2, 9),
    );
  });
  test('monthly短月夹取但三月恢复31，interval保持原始月锚点', () {
    expect(
      nextRecurringDate(
        rule(frequency: 'monthly', after: DateTime.utc(2024, 1, 31)),
        future,
      ),
      DateTime.utc(2024, 2, 29),
    );
    expect(
      nextRecurringDate(
        rule(frequency: 'monthly', after: DateTime.utc(2024, 2, 29)),
        future,
      ),
      DateTime.utc(2024, 3, 31),
    );
    expect(
      nextRecurringDate(
        rule(
          frequency: 'monthly',
          interval: 2,
          after: DateTime.utc(2024, 2, 28),
        ),
        future,
      ),
      DateTime.utc(2024, 3, 31),
    );
  });
  test('yearly闰日不会永久退化为28号', () {
    final start = DateTime.utc(2024, 2, 29);
    expect(
      nextRecurringDate(
        rule(frequency: 'yearly', start: start, after: start),
        future,
      ),
      DateTime.utc(2025, 2, 28),
    );
    expect(
      nextRecurringDate(
        rule(
          frequency: 'yearly',
          start: start,
          after: DateTime.utc(2027, 2, 28),
        ),
        future,
      ),
      DateTime.utc(2028, 2, 29),
    );
  });
  test('daily按起始日取严格晚于cursor的周期，结束日包含', () {
    final start = DateTime.utc(2024, 1, 1);
    expect(
      nextRecurringDate(
        rule(start: start, interval: 3, after: DateTime.utc(2024, 1, 5)),
        future,
      ),
      DateTime.utc(2024, 1, 7),
    );
    expect(nextRecurringDate(rule(start: start, end: start), future), start);
    expect(
      nextRecurringDate(rule(start: start, end: start, after: start), future),
      isNull,
    );
  });
  test('规则时区今天与设备时区无关', () {
    final instant = DateTime.utc(2024, 3, 10, 1);
    expect(
      recurringToday('America/New_York', instant),
      DateTime.utc(2024, 3, 9),
    );
    expect(recurringToday('Asia/Shanghai', instant), DateTime.utc(2024, 3, 10));
  });
  test('纽约夏令时前后日界、圣保罗跳过零点与Apia跳日一致', () {
    expect(
      recurringOccurrenceInstant(DateTime.utc(2024, 3, 10), 'America/New_York'),
      DateTime.utc(2024, 3, 10, 5),
    );
    expect(
      recurringOccurrenceInstant(DateTime.utc(2024, 3, 11), 'America/New_York'),
      DateTime.utc(2024, 3, 11, 4),
    );
    expect(
      recurringOccurrenceInstant(
        DateTime.utc(2018, 11, 4),
        'America/Sao_Paulo',
      ),
      DateTime.utc(2018, 11, 4, 3),
    );
    expect(
      recurringOccurrenceInstant(DateTime.utc(2011, 12, 30), 'Pacific/Apia'),
      DateTime.utc(2011, 12, 30, 10),
    );
  });
  test('未知时区拒绝而非悄悄按UTC生成', () {
    expect(() => recurringLocation('GMT+08:00'), throwsFormatException);
  });
  test('UUID大小写不改变发生身份，IANA历史链接能解析', () {
    expect(
      recurringOccurrenceId(
        'abcdefab-1111-4111-8111-111111111111',
        'bbbbbbbb-2222-4222-8222-222222222222',
        '2024-02-29',
      ),
      recurringOccurrenceId(
        'ABCDEFAB-1111-4111-8111-111111111111',
        'BBBBBBBB-2222-4222-8222-222222222222',
        '2024-02-29',
      ),
    );
    for (final zone in [
      'UTC',
      'Etc/UTC',
      'Asia/Kolkata',
      'Asia/Calcutta',
      'Europe/Kyiv',
      'Europe/Kiev',
    ]) {
      expect(() => recurringLocation(zone), returnsNormally);
    }
  });
  test('Unix epoch以前的日界二分正常收敛', () {
    expect(
      recurringOccurrenceInstant(DateTime.utc(1900, 1, 1), 'UTC'),
      DateTime.utc(1900, 1, 1),
    );
    expect(
      recurringOccurrenceInstant(DateTime.utc(1970, 1, 1), 'Asia/Shanghai'),
      DateTime.utc(1969, 12, 31, 16),
    );
  });
  test('四位年份最小边界有效，超出协议年份拒绝', () {
    expect(
      nextRecurringDate(rule(start: DateTime.utc(1000)), future),
      DateTime.utc(1000),
    );
    expect(
      () => nextRecurringDate(rule(start: DateTime.utc(999)), future),
      throwsFormatException,
    );
    expect(
      () => validateRecurringDateRange(DateTime.utc(2024), DateTime.utc(10000)),
      throwsFormatException,
    );
    expect(
      () => validateRecurringDateRange(DateTime.utc(2024), DateTime.utc(2023)),
      throwsFormatException,
    );
  });
}
