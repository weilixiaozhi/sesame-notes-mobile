import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/mappers/recurring_transaction_display_mapper.dart';
import 'package:sesame_notes/features/transactions/domain/recurring_transaction_rules.dart';

void main() {
  group('精确周期金额', () {
    test('输入中间态与10位小数合法，不用double舍入', () {
      for (final value in [
        '',
        '0',
        '12.',
        '12.3',
        '12.3456789012',
        '9999999999999999999999999999.9999999999',
      ]) {
        expect(isValidRecurringAmountInput(value), isTrue, reason: value);
      }
      expect(
        normalizeRecurringAmount('9007199254740993.1234567890'),
        '9007199254740993.123456789',
      );
      expect(normalizeRecurringAmount('0.0000000001'), '0.0000000001');
      expect(normalizeRecurringAmount('050.00'), '50');
    });
    test('超出契约、科学计数法、负数和错误小数拒绝', () {
      for (final value in [
        '1.12345678901',
        '99999999999999999999999999999',
        '1e3',
        '-5',
        'abc',
        '1.2.3',
      ]) {
        expect(isValidRecurringAmountInput(value), isFalse, reason: value);
        expect(normalizeRecurringAmount(value), isNull, reason: value);
      }
      for (final value in ['', '   ', '12.', '.', '0', '0.00000']) {
        expect(normalizeRecurringAmount(value), isNull, reason: value);
      }
    });
  });

  test('日期只携带年月日，保存为UTC零点，不转换日历日期', () {
    expect(
      recurringDateOnly(DateTime(2026, 9, 30, 23, 55)),
      DateTime.utc(2026, 9, 30),
    );
    expect(
      recurringDateOnly(DateTime.utc(2026, 10, 1, 0, 15)),
      DateTime.utc(2026, 10, 1),
    );
  });

  test('展示映射保留Web规则的星期、月份、时区及全部精度', () {
    final value = RecurringTransactionSnapshot(
      id: 'rule',
      ledgerId: 'ledger',
      txType: 'expense',
      amount: '9007199254740993.1234567890',
      currencyCode: 'USD',
      frequency: 'yearly',
      interval: 2,
      dayOfMonth: 29,
      dayOfWeek: 5,
      monthOfYear: 2,
      timeZone: 'America/New_York',
      protocolVersion: 1,
      startDate: DateTime.utc(2026, 1, 1).toLocal(),
      endDate: DateTime.utc(2030, 12, 31).toLocal(),
      lastGeneratedDate: DateTime.utc(2026, 2, 28).toLocal(),
      enabled: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final display = value.toDisplay();
    expect(display.amount, value.amount);
    expect(display.dayOfWeek, 5);
    expect(display.monthOfYear, 2);
    expect(display.dayOfMonth, 29);
    expect(display.timeZone, 'America/New_York');
    expect(display.startDate, DateTime.utc(2026, 1, 1));
    expect(display.startDate.isUtc, isTrue);
    expect(display.endDate, DateTime.utc(2030, 12, 31));
    expect(display.endDate!.isUtc, isTrue);
    expect(display.lastGeneratedDate, DateTime.utc(2026, 2, 28));
    expect(display.lastGeneratedDate!.isUtc, isTrue);
  });

  test('新账本草稿保留完整规则、使用日历日期，不伪造账本身份', () {
    final draft = buildRecurringDraft(
      id: 'rule',
      amount: '0.0000000001',
      currencyCode: 'USD',
      categoryId: 'category',
      note: '周期草稿',
      frequency: 'yearly',
      interval: 2,
      dayOfMonth: 29,
      dayOfWeek: 5,
      monthOfYear: 2,
      timeZone: 'Asia/Shanghai',
      startDate: DateTime(2026, 1, 1, 23),
      endDate: DateTime(2030, 12, 31, 18),
      enabled: false,
    );
    expect(draft.ledgerId, isEmpty);
    expect(draft.id, 'rule');
    expect(draft.amount, '0.0000000001');
    expect(draft.dayOfWeek, 5);
    expect(draft.monthOfYear, 2);
    expect(draft.timeZone, 'Asia/Shanghai');
    expect(draft.startDate, DateTime.utc(2026, 1, 1));
    expect(draft.endDate, DateTime.utc(2030, 12, 31));
    expect(draft.enabled, isFalse);
    expect(draft.lastGeneratedDate, isNull);
  });
  test(
    '月内日默认来自开始日期',
    () => expect(defaultRecurringDayOfMonth(DateTime.utc(2026, 1, 31)), 31),
  );
}
