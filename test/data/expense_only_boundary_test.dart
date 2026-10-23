import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  final now = DateTime.utc(2026, 9, 6);

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(name: '支出账本', storageMode: 'local');
  });
  tearDown(() async => db.close());

  for (final type in ['income', 'transfer', 'invalid', '']) {
    test('数据库四类实体拒绝非法类型 "$type"', () async {
      final writes = <String, Future<int> Function()>{
        '分类': () => db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'category',
                name: '分类',
                kind: type,
                level: 1,
                updatedAt: now,
              ),
            ),
        '共享分类': () => db
            .into(db.sharedLedgerCategories)
            .insert(
              SharedLedgerCategoriesCompanion.insert(
                ledgerId: ledgerId,
                categoryId: 'shared',
                name: '共享分类',
                kind: type,
                updatedAt: now,
              ),
            ),
        '交易': () => db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'transaction',
                ledgerId: ledgerId,
                txType: type,
                amount: '1',
                happenedAt: now,
                currencyCode: 'CNY',
                nativeAmount: '1',
                createdAt: now,
                updatedAt: now,
              ),
            ),
        '周期账单': () => db
            .into(db.recurringTransactions)
            .insert(
              RecurringTransactionsCompanion.insert(
                id: 'recurring',
                ledgerId: ledgerId,
                txType: type,
                amount: '1',
                currencyCode: 'CNY',
                frequency: 'monthly',
                startDate: now,
                updatedAt: now,
              ),
            ),
      };
      for (final entry in writes.entries) {
        await expectLater(
          entry.value(),
          throwsA(isA<SqliteException>()),
          reason: '${entry.key}只能保存支出',
        );
      }
    });

    test('仓储写入拒绝非法类型 "$type" 并返回友好错误', () async {
      final parent = await repo.createCategory(name: '餐饮', kind: 'expense');
      final writes = <Future<Object?> Function()>[
        () => repo.createCategory(name: '非法分类', kind: type),
        () =>
            repo.createSubCategory(parentId: parent, name: '非法子分类', kind: type),
        () => repo.upsertCategory(name: '非法分类', kind: type),
        () => repo.addTransaction(
          ledgerId: ledgerId,
          type: type,
          amount: '1',
          happenedAt: now,
        ),
        () => repo.addRecurringTransaction(
          ledgerId: ledgerId,
          type: type,
          amount: '1',
          frequency: 'monthly',
          interval: 1,
          startDate: now,
        ),
        () => repo.batchInsertCategories([
          CategoriesCompanion.insert(
            id: 'batch',
            name: '批量分类',
            kind: type,
            level: 1,
            updatedAt: now,
          ),
        ]),
        () => repo.insertTransactionsBatch([
          TransactionsCompanion.insert(
            id: 'batch',
            ledgerId: ledgerId,
            txType: type,
            amount: '1',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '1',
            createdAt: now,
            updatedAt: now,
          ),
        ]),
      ];
      for (final write in writes) {
        await expectLater(
          write(),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('仅支持支出'),
            ),
          ),
        );
      }
      expect(await repo.categoryStore.getAllCategories(), hasLength(1));
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await db.select(db.recurringTransactions).get(), isEmpty);
    });

    test('直接分类导入对非法类型 "$type" 返回失败计数', () async {
      final result = await DataImportService().importCategories(repo, [
        ImportCategory(name: '非法分类', kind: type, level: 1),
      ], categoryQueries: repo.categoryStore);
      expect(result.failed, 1);
      expect(result.cache, isEmpty);
      expect(await repo.categoryStore.getAllCategories(), isEmpty);
    });

    test('支出交易引用非法分类类型 "$type" 时导入失败', () async {
      final categoryId = await repo.createCategory(name: '分类', kind: 'expense');
      final result = await DataImportService()
          .importTransactions(repo, ledgerId, [
            ImportTransaction(
              type: 'expense',
              amount: Decimal.one,
              happenedAt: now,
              categoryId: categoryId,
              categoryName: '分类',
              categoryKind: type,
            ),
          ], categoryCache: {});
      expect(result.failed, 1);
      expect(result.inserted, 0);
      expect(await db.select(db.transactions).get(), isEmpty);
    });
  }

  test('非法类型编辑保留现有支出记录', () async {
    final id = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '1',
      happenedAt: now,
    );
    await expectLater(
      repo.updateTransaction(id: id, type: 'income', amount: '2'),
      throwsA(isA<FormatException>()),
    );
    final row = await repo.getTransactionById(id);
    expect(row!.txType, 'expense');
    expect(row.amount, '1');
    expect(row.version, 1);
  });
}
