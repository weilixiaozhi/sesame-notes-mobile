import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';

void main() {
  final base = LedgerDisplayItem(
    id: 'led-1',
    name: 'L',
    currency: 'CNY',
    lastUpdated: DateTime(2026, 1, 1),
    transactionCount: 3,
    expenseTotal: 100.0,
  );

  test('相等语义仅按 id', () {
    expect(
      base,
      LedgerDisplayItem(
        id: 'led-1',
        name: '改名',
        currency: 'USD',
        lastUpdated: DateTime(2026, 2, 2),
        transactionCount: 99,
        expenseTotal: 9.9,
      ),
      reason: '字段变化不影响身份判等',
    );
    expect(base.hashCode, 'led-1'.hashCode);

    final other = LedgerDisplayItem(
      id: 'led-2',
      name: 'L',
      currency: 'CNY',
      lastUpdated: DateTime(2026, 1, 1),
      transactionCount: 3,
      expenseTotal: 100.0,
    );
    expect(base == other, isFalse);
  });

  test('Drift Ledger Row 映射为完整展示模型', () {
    final updatedAt = DateTime(2026, 8, 31);
    final display = Ledger(
      id: 'led-shared',
      name: '共享账本',
      currency: 'USD',
      monthStartDay: 12,
      aaEnabled: true,
      role: 'editor',
      memberCount: 3,
      storageMode: 'cloud',
      selfMemberId: 'member-self',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: updatedAt,
    ).toDisplayItem();

    expect(display.id, 'led-shared');
    expect(display.name, '共享账本');
    expect(display.currency, 'USD');
    expect(display.monthStartDay, 12);
    expect(display.aaEnabled, isTrue);
    expect(display.myRole, 'editor');
    expect(display.memberCount, 3);
    expect(display.isShared, isTrue);
    expect(display.storageMode, 'cloud');
    expect(display.selfMemberId, 'member-self');
    expect(display.lastUpdated, updatedAt);
  });
}
