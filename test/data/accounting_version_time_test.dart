import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// 财务实体和墓碑使用同一毫秒单位，关闭重开后仍可作为后继编辑的版本基线。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('当前结构财务实体和墓碑往返保留毫秒及金额精度', () async {
    final raw = sql.sqlite3.openInMemory();
    final updated = DateTime.utc(2026, 10, 19, 12, 0, 0, 947);
    final deleted = updated.add(const Duration(milliseconds: 21));
    final db = SesameDatabase.withExecutor(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    try {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'ledger',
              name: '账本',
              updatedAt: updated,
              deletedAt: d.Value(deleted),
            ),
          );
      await db.customStatement(
        'INSERT INTO recurring_transactions(id,ledger_id,tx_type,amount,currency_code,'
        'frequency,start_date,updated_at,deleted_at) VALUES(?,?,?,?,?,?,?,?,?)',
        [
          'rule',
          'ledger',
          'expense',
          '12.34',
          'USD',
          'monthly',
          0,
          updated.millisecondsSinceEpoch,
          deleted.millisecondsSinceEpoch,
        ],
      );
      await db.customStatement(
        'INSERT INTO exchange_rate_overrides(id,base_currency,quote_currency,rate,'
        'updated_at,deleted_at) VALUES(?,?,?,?,?,?)',
        [
          'rate',
          'USD',
          'CNY',
          '7.123456789123456789',
          updated.millisecondsSinceEpoch,
          deleted.millisecondsSinceEpoch,
        ],
      );
      for (final table in [
        'ledgers',
        'recurring_transactions',
        'exchange_rate_overrides',
      ]) {
        final row = raw
            .select('SELECT updated_at,deleted_at FROM $table')
            .single;
        expect(row['updated_at'], updated.millisecondsSinceEpoch);
        expect(row['deleted_at'], deleted.millisecondsSinceEpoch);
      }
    } finally {
      await db.close();
    }
    final reopened = SesameDatabase.withExecutor(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    try {
      final ledger = await reopened.select(reopened.ledgers).getSingle();
      final rule = await reopened
          .select(reopened.recurringTransactions)
          .getSingle();
      final rate = await reopened
          .select(reopened.exchangeRateOverrides)
          .getSingle();
      expect([
        ledger.updatedAt,
        rule.updatedAt,
        rate.updatedAt,
      ], everyElement(updated));
      expect([
        ledger.deletedAt,
        rule.deletedAt,
        rate.deletedAt,
      ], everyElement(deleted));
      expect(rate.rate, '7.123456789123456789');
      expect(
        raw.select('PRAGMA user_version').single.values.single,
        currentSchemaVersion,
      );
    } finally {
      await reopened.close();
      raw.close();
    }
  });

  test('当前结构记账水位区分未知和合法零值，关闭重开后保持原状态', () async {
    final raw = sql.sqlite3.openInMemory();
    final db = SesameDatabase.withExecutor(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    try {
      await db.customStatement(
        "INSERT INTO sync_state(account_id,device_id) VALUES('account','unknown')",
      );
      await db.customStatement(
        "INSERT INTO sync_state(account_id,device_id,server_cursor) VALUES('account','completed-zero','0')",
      );
      final column = raw
          .select('PRAGMA table_info(sync_state)')
          .singleWhere((row) => row['name'] == 'server_cursor');
      expect(column['notnull'], 0);
      expect(column['dflt_value'], isNull, reason: '未知状态不能由默认零值伪装成已完成快照');
    } finally {
      await db.close();
    }
    final reopened = SesameDatabase.withExecutor(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    try {
      final rows = await reopened.select(reopened.syncState).get();
      expect(
        rows.singleWhere((row) => row.deviceId == 'unknown').serverCursor,
        isNull,
      );
      expect(
        rows
            .singleWhere((row) => row.deviceId == 'completed-zero')
            .serverCursor,
        '0',
      );
      expect(
        raw.select('PRAGMA user_version').single.values.single,
        currentSchemaVersion,
      );
    } finally {
      await reopened.close();
      raw.close();
    }
  });
}
