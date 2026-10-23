import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/diagnostics/data/acceptance_data_seeder.dart';

import '../helpers/test_isolation.dart';

/// 调试填充与真实记账共用账本分类域，登录身份不能改变本地账本的类别来源。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('登录时填充本地账本只引用本地域分类', () async {
    resetGlobalTestState();
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      final repository = LocalRepository(db, accountIdGetter: () => 'account');
      final ledger = await repository.createLedger(
        name: '本地验收',
        storageMode: 'local',
      );
      await repository.createCategory(name: '云端分类', kind: 'expense');
      final localCategory = await repository.createCategory(
        name: '本地分类',
        kind: 'expense',
        ledgerId: ledger,
      );

      await AcceptanceDataSeeder(
        repository,
      ).createAaBills(ledgerId: ledger, baseCurrency: 'CNY');

      final rows = await repository.getTransactionsByLedger(ledger);
      expect(rows, hasLength(3));
      expect(rows.map((row) => row.categoryId).toSet(), {localCategory});
    } finally {
      await db.close();
    }
  });
}
