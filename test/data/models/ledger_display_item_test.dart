// LedgerDisplayItem 纯模型测试。
//
// 需求锚点：
//   1. fromLocal 以 createdAt 作为最后更新时间；
//   2. 相等语义仅按 id（身份相等），字段变化不影响判等；
//   3. isCloudLedger 口径：storageMode==cloud 或 isShared 即为云账本；
//   4. toString 可读。

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';

void main() {
  final base = LedgerDisplayItem.fromLocal(
    id: 'led-1',
    name: 'L',
    currency: 'CNY',
    createdAt: DateTime(2026, 1, 1),
    transactionCount: 3,
    expenseTotal: 100.0,
  );

  test('fromLocal 以 createdAt 为 lastUpdated', () {
    expect(base.lastUpdated, DateTime(2026, 1, 1));
    expect(base.transactionCount, 3);
    expect(base.expenseTotal, 100.0);
    expect(base.isShared, isFalse);
  });

  test('相等语义仅按 id', () {
    expect(
      base,
      LedgerDisplayItem.fromLocal(
        id: 'led-1',
        name: '改名',
        currency: 'USD',
        createdAt: DateTime(2026, 2, 2),
        transactionCount: 99,
        expenseTotal: 9.9,
      ),
      reason: '字段变化不影响身份判等',
    );
    expect(base.hashCode, 'led-1'.hashCode);

    final other = LedgerDisplayItem.fromLocal(
      id: 'led-2',
      name: 'L',
      currency: 'CNY',
      createdAt: DateTime(2026, 1, 1),
      transactionCount: 3,
      expenseTotal: 100.0,
    );
    expect(base == other, isFalse);
  });

  test('isCloudLedger：cloud 或 shared 判定', () {
    final cloud = LedgerDisplayItem(
      id: 'led-2',
      name: 'C',
      currency: 'CNY',
      transactionCount: 0,
      expenseTotal: 0,
      lastUpdated: DateTime(2026, 1, 1),
      storageMode: 'cloud',
    );
    expect(cloud.isCloudLedger, isTrue);

    final shared = LedgerDisplayItem(
      id: 'led-3',
      name: 'S',
      currency: 'CNY',
      transactionCount: 0,
      expenseTotal: 0,
      lastUpdated: DateTime(2026, 1, 1),
      isShared: true,
      storageMode: 'local',
    );
    expect(shared.isCloudLedger, isTrue, reason: '共享账本 storageMode 缺失也按云账本');

    expect(base.isCloudLedger, isFalse);
  });

  test('toString 包含 id 与名称', () {
    expect(base.toString(), contains('id: led-1'));
    expect(base.toString(), contains('L'));
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
