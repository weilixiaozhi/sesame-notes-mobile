/// 导入分类路径测试。
///
/// 需求锚点：分类必须按完整父子路径解析；路径不存在时整笔交易失败，
/// 不能静默创建同名一级分类或写成未分类。
library;

import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    service = DataImportService();
    await db.customStatement(
      "INSERT INTO ledgers (id, name, currency, storage_mode, updated_at) "
      "VALUES ('ledger-1', 'L', 'CNY', 'local', strftime('%s','now'))",
    );
  });

  tearDown(() async => db.close());

  test('分类路径未命中时交易失败，不兜底创建同名一级分类', () async {
    final result = await service.importTransactions(repo, 'ledger-1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('10'),
        categoryName: '早餐',
        categoryKind: 'expense',
        happenedAt: DateTime(2026, 8, 1),
      ),
    ], categoryCache: {});

    expect(result.inserted, 0);
    expect(result.failed, 1);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.categories).get(), isEmpty);
  });

  test('餐饮 > 早餐按完整路径落到二级分类，不生成一级早餐', () async {
    final result = await service.importData(
      repo,
      'ledger-1',
      ImportData(
        categories: const [
          ImportCategory(name: '餐饮', kind: 'expense'),
          ImportCategory(
            name: '早餐',
            kind: 'expense',
            level: 2,
            parentName: '餐饮',
          ),
        ],
        transactions: [
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('18'),
            categoryName: '早餐',
            categoryParentName: '餐饮',
            categoryKind: 'expense',
            happenedAt: DateTime(2026, 8, 2),
          ),
        ],
      ),
    );

    expect(result.inserted, 1);
    expect(result.failed, 0);
    final categories = await db.select(db.categories).get();
    final parent = categories.singleWhere((c) => c.name == '餐饮');
    final breakfast = categories.singleWhere((c) => c.name == '早餐');
    expect(breakfast.parentId, parent.id);
    expect(
      categories.where((c) => c.name == '早餐' && c.parentId == null),
      isEmpty,
    );
    expect(
      (await db.select(db.transactions).get()).single.categoryId,
      breakfast.id,
    );
  });

  test('跨父同名及分隔符分类按各自完整路径解析', () async {
    final result = await service.importData(
      repo,
      'ledger-1',
      ImportData(
        categories: const [
          ImportCategory(name: '购物', kind: 'expense'),
          ImportCategory(name: '服|装', kind: 'expense'),
          ImportCategory(
            name: '鞋:子',
            kind: 'expense',
            level: 2,
            parentName: '购物',
          ),
          ImportCategory(
            name: '鞋:子',
            kind: 'expense',
            level: 2,
            parentName: '服|装',
          ),
        ],
        transactions: [
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('20'),
            categoryName: '鞋:子',
            categoryParentName: '购物',
            categoryKind: 'expense',
            happenedAt: DateTime(2026, 8, 3),
            note: '购物鞋',
          ),
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('30'),
            categoryName: '鞋:子',
            categoryParentName: '服|装',
            categoryKind: 'expense',
            happenedAt: DateTime(2026, 8, 4),
            note: '服装鞋',
          ),
        ],
      ),
    );

    expect(result.inserted, 2);
    expect(result.failed, 0);
    final categories = await db.select(db.categories).get();
    final parents = {
      for (final c in categories.where((c) => c.level == 1)) c.name: c,
    };
    final shoesByParent = {
      for (final c in categories.where((c) => c.name == '鞋:子'))
        c.parentId: c.id,
    };
    final transactions = await db.select(db.transactions).get();
    final categoryByNote = {
      for (final tx in transactions) tx.note: tx.categoryId,
    };
    expect(categoryByNote['购物鞋'], shoesByParent[parents['购物']!.id]);
    expect(categoryByNote['服装鞋'], shoesByParent[parents['服|装']!.id]);
  });

  test('共享账本分类白名单拒绝私有 UUID，仅写入 Owner 镜像 UUID', () async {
    final result = await service.importTransactions(
      repo,
      'ledger-1',
      [
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('10'),
          categoryId: 'private-category',
          happenedAt: DateTime(2026, 8, 5),
          note: '私有',
        ),
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('20'),
          categoryId: 'owner-category',
          happenedAt: DateTime(2026, 8, 6),
          note: 'Owner',
        ),
      ],
      categoryCache: {},
      allowedCategoryIds: {'owner-category'},
    );

    expect(result.inserted, 1);
    expect(result.failed, 1);
    final transactions = await db.select(db.transactions).get();
    expect(transactions.single.categoryId, 'owner-category');
  });
}
