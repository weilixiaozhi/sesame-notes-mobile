import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';

import '../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

class _MockRepo extends Mock implements LocalRepository {}

/// 分类查询独立注入，导入导出不能依赖组合仓储的查询转发。
class _CategoryQueries extends Mock implements CategoryQueryRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late _MockRepo repo;
  late _CategoryQueries categoryQueries;
  late DataImportService service;

  setUp(() {
    repo = _MockRepo();
    categoryQueries = _CategoryQueries();
    service = DataImportService();
  });

  test('importCategories: 创建失败计入 failed，成功分类仍返回缓存', () async {
    when(
      () => categoryQueries.getTopLevelCategories('expense'),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => categoryQueries.getSubCategories(any()),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.createCategory(
        name: '好分类',
        kind: 'expense',
        icon: any(named: 'icon'),
        sortOrder: any(named: 'sortOrder'),
      ),
    ).thenAnswer((_) async => 'cat-ok');
    when(
      () => repo.createCategory(
        name: '坏分类',
        kind: 'expense',
        icon: any(named: 'icon'),
        sortOrder: any(named: 'sortOrder'),
      ),
    ).thenThrow(Exception('db down'));

    final result = await service.importCategories(repo, const [
      ImportCategory(name: '好分类', kind: 'expense'),
      ImportCategory(name: '坏分类', kind: 'expense'),
    ], categoryQueries: categoryQueries);

    expect(result.failed, 1, reason: '坏分类创建失败必须计入 failed');
    expect(result.cache.values, contains('cat-ok'));
  });

  // 读现有分类属于基础设施读取，不是"某条分类创建失败"：把它降级成 failed=0
  // 会让导入报告宣称分类阶段正常，真实故障被改写成后续交易的"分类路径未命中"。
  test('importCategories: 读取现有分类失败时上抛，不伪装成零失败', () async {
    when(
      () => categoryQueries.getTopLevelCategories('expense'),
    ).thenThrow(Exception('db down'));

    await expectLater(
      service.importCategories(repo, const [
        ImportCategory(name: '好分类', kind: 'expense'),
      ], categoryQueries: categoryQueries),
      throwsA(isA<Exception>()),
    );
  });

  test('importData: 分类创建失败计入 ImportResult.failed', () async {
    when(() => repo.getLedgerById('1')).thenAnswer(
      (_) async => Ledger(
        id: '1',
        name: 'L',
        currency: 'CNY',
        role: 'owner',
        memberCount: 1,
        monthStartDay: 1,
        storageMode: 'local',
        aaEnabled: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    when(
      () => categoryQueries.getAllCategoriesIncludingShared(ledgerId: '1'),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.createCategory(
        name: any(named: 'name'),
        kind: any(named: 'kind'),
        icon: any(named: 'icon'),
        sortOrder: any(named: 'sortOrder'),
        ledgerId: '1',
      ),
    ).thenThrow(Exception('db down'));
    when(
      () => repo.getTransactionsByLedger(any()),
    ).thenAnswer((_) async => <Transaction>[]);
    when(
      () => repo.getLatestAutoRates(any()),
    ).thenAnswer((_) async => <ExchangeRate>[]);
    when(
      () => repo.getOverrides(any()),
    ).thenAnswer((_) async => <ExchangeRateOverride>[]);
    when(
      () => repo.importTransactions(
        transactions: any(named: 'transactions'),
        recordChanges: any(named: 'recordChanges'),
      ),
    ).thenAnswer((invocation) async {
      final txs =
          invocation.namedArguments[#transactions]
              as List<TransactionsCompanion>;
      return [for (final t in txs) t.id.value];
    });

    final result = await service.importData(
      repo,
      '1',
      ImportData(
        categories: const [ImportCategory(name: '坏分类', kind: 'expense')],
        transactions: [
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('10'),
            categoryName: '好分类',
            categoryKind: 'expense',
            happenedAt: DateTime(2026, 7, 1),
          ),
        ],
      ),
      categoryQueries: categoryQueries,
    );

    // 分类创建失败 1 + 交易引用未命中失败 1 = 2；成功 0。
    expect(result.inserted, 0);
    expect(result.failed, 2);
  });
}
