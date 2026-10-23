import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(name: 'test');
  });

  tearDown(() => db.close());

  Future<String> createTx({String? payerMemberId, String? operatorMemberId}) =>
      repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime(2026, 1, 1),
        payerMemberId: payerMemberId,
        operatorMemberId: operatorMemberId,
      );

  group('新建', () {
    test('操作者就绪 → 支出人、创建人与最近编辑人统一写操作者', () async {
      final id = await createTx(operatorMemberId: 'u-alice');
      final tx = (await repo.getTransactionById(id))!;
      expect(tx.payerMemberId, 'u-alice');
      expect(tx.createdByMemberId, 'u-alice');
      expect(tx.lastEditedByMemberId, 'u-alice');
    });

    test('已显式指定支出人 → 支出人保留显式值，作者字段照常写', () async {
      final id = await createTx(
        payerMemberId: 'explicit-payer',
        operatorMemberId: 'u-alice',
      );
      final tx = (await repo.getTransactionById(id))!;
      expect(tx.payerMemberId, 'explicit-payer');
      expect(tx.createdByMemberId, 'u-alice');
      expect(tx.lastEditedByMemberId, 'u-alice');
    });

    test('操作者未就绪（空串） → 作者与支出人均不写', () async {
      final id = await createTx(operatorMemberId: '');
      final tx = (await repo.getTransactionById(id))!;
      expect(tx.payerMemberId, isNull);
      expect(tx.createdByMemberId, isNull);
      expect(tx.lastEditedByMemberId, isNull);
    });
  });

  group('编辑', () {
    test('原支出人为空 → 回填操作者并写 lastEditedBy', () async {
      final id = await createTx();
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '120.00',
        operatorMemberId: 'u-bob',
      );
      final tx = (await repo.getTransactionById(id))!;
      expect(tx.payerMemberId, 'u-bob');
      expect(tx.lastEditedByMemberId, 'u-bob');
      // 编辑路径不写创建人。
      expect(tx.createdByMemberId, isNull);
    });

    test('原支出人非空 → 保留原值，仅写 lastEditedBy', () async {
      final id = await createTx(operatorMemberId: 'u-alice');
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '120.00',
        operatorMemberId: 'u-bob',
      );
      final tx = (await repo.getTransactionById(id))!;
      // 创建人 first-write-wins，支出人不随编辑人变化。
      expect(tx.createdByMemberId, 'u-alice');
      expect(tx.payerMemberId, 'u-alice');
      expect(tx.lastEditedByMemberId, 'u-bob');
    });

    test('显式传入支出人 → 覆盖原值', () async {
      final id = await createTx(operatorMemberId: 'u-alice');
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '120.00',
        payerMemberId: 'hand-picked',
        operatorMemberId: 'u-bob',
      );
      final tx = (await repo.getTransactionById(id))!;
      expect(tx.payerMemberId, 'hand-picked');
      expect(tx.lastEditedByMemberId, 'u-bob');
    });
  });
}
