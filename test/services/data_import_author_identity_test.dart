// 导入作者身份落库测试。
//
// 需求锚点：导入的数据以当前账本 self member 身份导入；
// 创建者/编辑者一并回填，避免详情页「空，没有信息」；云同步拉取路径不传身份时保持原行为。

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
    db = SesameDatabase.forTesting(NativeDatabase.memory());
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

  ImportTransaction tx() => ImportTransaction(
    type: 'expense',
    amount: Decimal.parse('10'),
    happenedAt: DateTime(2026, 7, 1),
  );

  test('importTransactions：传入 authorMemberId 时三个人员字段都落当前成员', () async {
    await seed();

    final result = await service.importTransactions(
      repo,
      '1',
      [tx()],
      categoryCache: {},
      authorMemberId: 'current-member',
    );
    expect(result.inserted, 1);

    final t = (await allTx()).single;
    expect(t.payerMemberId, 'current-member');
    expect(t.createdByMemberId, 'current-member');
    expect(t.lastEditedByMemberId, 'current-member');
  });

  test('importData：传入 authorMemberId 时同样落当前成员', () async {
    await seed();

    final result = await service.importData(
      repo,
      '1',
      ImportData(transactions: [tx()]),
      authorMemberId: 'current-member',
    );
    expect(result.inserted, 1);

    final t = (await allTx()).single;
    expect(t.payerMemberId, 'current-member');
    expect(t.createdByMemberId, 'current-member');
    expect(t.lastEditedByMemberId, 'current-member');
  });

  test('不传 authorMemberId：保持恢复语义（payer 按备份值/空串，作者字段为空）', () async {
    await seed();

    final result = await service.importTransactions(repo, '1', [
      tx(),
    ], categoryCache: {});
    expect(result.inserted, 1);

    final t = (await allTx()).single;
    expect(t.payerMemberId, '');
    expect(t.createdByMemberId, isNull);
    expect(t.lastEditedByMemberId, isNull);
  });
}
