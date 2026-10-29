import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

/// 故障只注入目录读取，分类写入仍由真实事务验证回滚。
class _FailingQueries extends Mock implements CategoryQueryRepository {}

/// 分类阶段整批失败必须报告失败数，并且不遗留未被账单引用的部分写入。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late DataImportService service;
  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    service = DataImportService();
    await db.customStatement(
      "INSERT INTO ledgers (id,name,currency,storage_mode,updated_at) VALUES ('ledger','测试','CNY','local',0)",
    );
  });
  tearDown(() => db.close());

  test('父分类无效时整批回滚，成功草稿也不能遗留', () async {
    final result = await service.importCategories(
      repo,
      const [
        ImportCategory(
          id: '00000000-0000-4000-8000-000000000401',
          name: '好分类',
          kind: 'expense',
        ),
        ImportCategory(
          id: '00000000-0000-4000-8000-000000000402',
          name: '子分类',
          kind: 'expense',
          level: 2,
          parentName: '无效父',
          parentId: '00000000-0000-4000-8000-000000000499',
        ),
      ],
      categoryQueries: repo.categoryStore,
      ledgerId: 'ledger',
    );
    expect(result.failed, 2);
    expect(result.cache, isEmpty);
    expect(await db.select(db.categories).get(), isEmpty);
  });

  test('创建后的目录校验失败也回滚分类并报告真实失败', () async {
    final queries = _FailingQueries();
    when(
      () => queries.getAllCategoriesIncludingShared(ledgerId: 'ledger'),
    ).thenThrow(StateError('读取失败'));
    final result = await service.importCategories(
      repo,
      const [ImportCategory(name: '分类', kind: 'expense')],
      categoryQueries: queries,
      ledgerId: 'ledger',
    );
    expect(result.failed, 1);
    expect(result.cache, isEmpty);
    expect(await db.select(db.categories).get(), isEmpty);
  });

  test('分类创建失败和引用失败分别计入结果，不把交易挂到同名项', () async {
    final result = await service.importData(
      repo,
      'ledger',
      ImportData(
        categories: const [
          ImportCategory(
            name: '坏分类',
            kind: 'expense',
            level: 2,
            parentName: '缺失父',
          ),
        ],
        transactions: [
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('10'),
            categoryName: '坏分类',
            categoryParentName: '缺失父',
            categoryKind: 'expense',
            happenedAt: DateTime.utc(2026),
          ),
        ],
      ),
      categoryQueries: repo.categoryStore,
    );
    expect(result.inserted, 0);
    expect(result.failed, 2);
    expect(await db.select(db.categories).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
