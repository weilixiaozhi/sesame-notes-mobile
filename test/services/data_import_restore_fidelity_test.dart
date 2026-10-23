import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:decimal/decimal.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late DataImportService service;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    service = DataImportService();
  });

  tearDown(() async => db.close());

  Future<void> seed() async {
    await db.customStatement(
      "INSERT INTO ledgers (id, name, currency, updated_at) "
      "VALUES (1, 'L', 'CNY', strftime('%s','now'))",
    );
  }

  Future<List<Transaction>> allTx() => (db.select(
    db.transactions,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  test('nativeAmount 快照优先:不随本地汇率重算而失真', () async {
    await seed();
    // 本地有 JPY 汇率 0.0488 —— 若走重算会得到 48.8,
    // 但快照值 35.5 是源端真实所见,必须优先采用。
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-07-10',
      rates: {'JPY': '0.0488'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 7, 10),
    );

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('1000'),
        currencyCode: 'JPY',
        nativeAmount: Decimal.parse('35.5'),
        happenedAt: DateTime(2026, 7, 1),
      ),
    ], categoryCache: {});
    expect(result.inserted, 1);

    final txs = await allTx();
    expect(txs[0].currencyCode, 'JPY');
    expect(txs[0].nativeAmount, '35.5', reason: '源端快照优先,不得被本地汇率重算覆盖为 48.8');
  });

  test('nativeAmount 缺键(null) → 走既有重算路径', () async {
    await seed();
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-07-10',
      rates: {'JPY': '0.0488'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 7, 10),
    );

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('1000'),
        currencyCode: 'JPY',
        // nativeAmount 缺键 → 重算
        happenedAt: DateTime(2026, 7, 1),
      ),
    ], categoryCache: {});
    expect(result.inserted, 1);

    final txs = await allTx();
    expect(txs[0].nativeAmount, '48.8');
  });
}
