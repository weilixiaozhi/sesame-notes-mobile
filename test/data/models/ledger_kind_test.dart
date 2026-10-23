import 'package:sesame_notes/data/repositories/support/ledger_kind.dart';
import '../../helpers/ledger_kind_filter.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/ledger_kind.dart';

void main() {
  // 每种归属只维护一份预期，同时约束内存判定、持久化行和 SQL 筛选。
  for (final (mode, shared, cloud, local, storedLocal)
      in <(String?, bool, bool, bool, bool)>[
        ('cloud', false, true, false, false),
        ('cloud', true, true, false, false),
        ('local', false, false, true, true),
        ('local', true, true, false, false),
        // 未知归属不能取反判成本地；未提供数据库列时则使用 local 默认值。
        (null, false, false, false, true),
        (null, true, true, false, false),
      ]) {
    test('账本归属：storageMode=$mode，shared=$shared', () async {
      expect(isCloudLedgerOf(mode, isShared: shared), cloud);
      expect(isLocalLedgerOf(mode, isShared: shared), local);

      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'ledger',
              name: '测试账本',
              updatedAt: DateTime.utc(2026, 1, 1),
              storageMode: mode == null ? const Value.absent() : Value(mode),
              memberCount: Value(shared ? 2 : 1),
              scopeAccountId: const Value('account-a'),
            ),
          );

      final ledger = await db.select(db.ledgers).getSingle();
      expect(ledger.isCloudLedger, cloud);
      expect(ledger.isLocalLedger, storedLocal);
      expect(ledger.isAccessibleTo('account-a'), storedLocal || cloud);
      expect(ledger.isAccessibleTo('account-b'), storedLocal);
      expect(ledger.isAccessibleTo(null), storedLocal);
      final cloudRows = await (db.select(
        db.ledgers,
      )..where(cloudLedgerFilter)).get();
      expect(cloudRows.map((row) => row.id), cloud ? ['ledger'] : isEmpty);
    });
  }
}
