// 分类创建失败计数测试。
//
// 需求锚点：分类创建失败必须计入 ImportResult.failed（不能只写日志让用户
// 误以为全部成功）；单条失败不阻断其余分类导入。

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:decimal/decimal.dart';

import '../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late _MockRepo repo;
  late DataImportService service;

  setUp(() {
    repo = _MockRepo();
    service = DataImportService();
  });

  test('importCategories: 创建失败计入 failed，成功分类仍返回缓存', () async {
    when(
      () => repo.getTopLevelCategories('expense'),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.getSubCategories(any()),
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
    ]);

    expect(result.failed, 1, reason: '坏分类创建失败必须计入 failed');
    expect(result.cache.values, contains('cat-ok'));
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
      () => repo.getTopLevelCategories('expense'),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.getSubCategories(any()),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.createCategory(
        name: any(named: 'name'),
        kind: any(named: 'kind'),
        icon: any(named: 'icon'),
        sortOrder: any(named: 'sortOrder'),
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
      () => repo.insertTransactionsBatchWithRelations(
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
    );

    // 分类创建失败 1 + 交易引用未命中失败 1 = 2；成功 0。
    expect(result.inserted, 0);
    expect(result.failed, 2);
  });
}
