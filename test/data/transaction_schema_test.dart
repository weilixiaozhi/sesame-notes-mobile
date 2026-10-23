import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';

/// 当前数据库直接建表，记账新增与编辑只依赖当前交易结构。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('新数据库直接建立当前结构并可正常新增和编辑记账', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      await db.customStatement(
        "INSERT INTO ledgers(id,name,updated_at) VALUES('ledger','日常账本',1000)",
      );
      await db.customStatement(
        'INSERT INTO transactions(id,ledger_id,tx_type,amount,happened_at,currency_code,native_amount,created_at,updated_at,note) '
        "VALUES('tx','ledger','expense','12.34',1000,'CNY','12.34',1000,2000,'早餐')",
      );
      await db.customStatement(
        "UPDATE transactions SET amount='15.50',native_amount='15.50',note='午餐' WHERE id='tx'",
      );
      final transaction = await db.select(db.transactions).getSingle();
      expect(
        (transaction.amount, transaction.nativeAmount, transaction.note),
        ('15.50', '15.50', '午餐'),
      );
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        currentSchemaVersion,
      );
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    } catch (error, stackTrace) {
      logger.error('TransactionSchemaTest', '当前结构记账验证失败', error, stackTrace);
      rethrow;
    } finally {
      await db.close();
    }
  });
}
