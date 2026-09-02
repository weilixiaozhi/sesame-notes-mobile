// AA 分摊:LocalRepository(聚合层) AA 字段透传 + 虚拟用户 CRUD 测试。
//
// 本测试验证:
//   1. addTransaction: AA 字段(payerMemberId/aaMode/aaParticipants/aaSplits)
//      透传到子仓并落库
//   2. updateTransaction: AA 字段透传(null=不更新,非 null=写入)
//   3. getAaTransactionsByLedger: 按 aaMode 过滤(排除 aaMode=1)
//   4. updateLedger: aaEnabled 透传并写入,云端账本登记 ledger:upsert 变更
//   5. 虚拟用户 CRUD 经 LocalRepository 委托

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart'
    show TransactionSplitInput;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';

/// 测试用变更记录器，把仓储登记的变更直接写入同步队列以便断言。
class _TestChangeRecorder implements ChangeRecorder {
  _TestChangeRecorder(this.db);
  final SesameDatabase db;

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
  }

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            ledgerId: d.Value(ledgerId),
            action: action,
            payload: payload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
  }

  @override
  Future<void> recordLedgerChanges({
    required List<SyncChangeRecord> changes,
  }) async {
    await db.batch((b) {
      for (final ch in changes) {
        b.insert(
          db.syncChanges,
          SyncChangesCompanion.insert(
            entityType: ch.entityType,
            entityId: ch.entityId,
            ledgerId: d.Value(ch.ledgerId),
            action: ch.action,
            payload: ch.payload,
            updatedAt: ch.updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
      }
    });
  }

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) async {
    await db.batch((b) {
      for (final ch in changes) {
        b.insert(
          db.syncChanges,
          SyncChangesCompanion.insert(
            entityType: ch.entityType,
            entityId: ch.entityId,
            action: ch.action,
            payload: ch.payload,
            updatedAt: ch.updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
      }
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: _TestChangeRecorder(db));
    // createLedger 默认 storageMode='cloud',会登记 ledger:upsert 变更
    ledgerId = await repo.createLedger(name: 'test');
  });

  tearDown(() async {
    await db.close();
  });

  group('addTransaction AA 字段透传', () {
    test('AA 字段全部传入并落库', () async {
      final id = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime.now(),
        payerMemberId: 'user-alice',
        aaMode: 2,
        splits: [
          TransactionSplitInput(memberId: 'user-alice', amount: '60.00'),
          TransactionSplitInput(memberId: 'vuser-1', amount: '40.00'),
        ],
      );
      final tx = await repo.getTransactionById(id);
      expect(tx, isNotNull);
      expect(tx!.payerMemberId, 'user-alice');
      expect(tx.aaMode, 2);
      // 指定分摊写入关系表,按行读取回显。
      final rows = await repo.getTransactionSplits(id);
      expect(rows, hasLength(2));
      expect(rows[0].memberId, 'user-alice');
      expect(rows[0].amount, '60.00');
      expect(rows[1].memberId, 'vuser-1');
      expect(rows[1].amount, '40.00');
    });

    test('AA 字段不传时落 NULL', () async {
      final id = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime.now(),
      );
      final tx = await repo.getTransactionById(id);
      expect(tx, isNotNull);
      expect(tx!.payerMemberId, isNull);
      expect(tx.aaMode, isNull);
      expect(await repo.getTransactionSplits(id), isEmpty);
    });
  });

  group('updateTransaction AA 字段透传', () {
    test('AA 字段更新写入', () async {
      final id = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime.now(),
      );
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '100.00',
        payerMemberId: 'user-bob',
        aaMode: 2,
        splits: [TransactionSplitInput(memberId: 'user-bob', amount: '100.00')],
      );
      final tx = await repo.getTransactionById(id);
      expect(tx!.payerMemberId, 'user-bob');
      expect(tx.aaMode, 2);
      final rows = await repo.getTransactionSplits(id);
      expect(rows, hasLength(1));
      expect(rows[0].memberId, 'user-bob');
      expect(rows[0].amount, '100.00');
    });

    test('AA 字段不传时保持原值(absent)', () async {
      final id = await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '100.00',
        happenedAt: DateTime.now(),
        payerMemberId: 'user-alice',
        aaMode: 2,
        splits: [
          TransactionSplitInput(memberId: 'user-alice', amount: '100.00'),
        ],
      );
      // 只更新金额,不传 AA 字段 → AA 字段保持原值
      await repo.updateTransaction(id: id, type: 'expense', amount: '120.00');
      final tx = await repo.getTransactionById(id);
      expect(tx!.amount, '120.00');
      expect(tx.payerMemberId, 'user-alice', reason: '未传 payerMemberId 时应保持原值');
      expect(tx.aaMode, 2);
      final rows = await repo.getTransactionSplits(id);
      expect(rows, hasLength(1));
      expect(rows[0].memberId, 'user-alice');
    });
  });

  group('getAaTransactionsByLedger', () {
    test('排除 aaMode=1(不分摊),包含 null/0/2', () async {
      // 人均(null)
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '30.00',
        happenedAt: DateTime.now(),
        // aaMode 不传 → null
      );
      // 不分摊(aaMode=1)
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime.now(),
        aaMode: 1,
      );
      // 指定(aaMode=2)
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '50.00',
        happenedAt: DateTime.now(),
        aaMode: 2,
      );
      // 人均(aaMode=0)
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '40.00',
        happenedAt: DateTime.now(),
        aaMode: 0,
      );

      final aaTxs = await repo.getAaTransactionsByLedger(ledgerId);
      // 应包含 null/0/2 三笔,排除 aaMode=1 那笔
      expect(aaTxs.length, 3);
      final modes = aaTxs.map((t) => t.aaMode).toSet();
      expect(modes, containsAll([null, 0, 2]));
      expect(modes, isNot(contains(1)));
    });
  });

  group('updateLedger aaEnabled', () {
    test('aaEnabled 写入并登记 ledger:upsert 变更', () async {
      await repo.updateLedger(id: ledgerId, aaEnabled: true);
      final ledger = await repo.getLedgerById(ledgerId);
      expect(ledger!.aaEnabled, true);

      // 云端账本(createLedger 默认 cloud)更新会登记 ledger:upsert
      final changes = await db.select(db.syncChanges).get();
      final ledgerChanges = changes
          .where((c) => c.entityType == 'ledger' && c.action == 'upsert')
          .toList();
      expect(ledgerChanges, isNotEmpty);
    });

    test('aaEnabled 不传时保持原值', () async {
      // 先设为 true
      await repo.updateLedger(id: ledgerId, aaEnabled: true);
      // 再更新名称,不传 aaEnabled
      await repo.updateLedger(id: ledgerId, name: '新名称');
      final ledger = await repo.getLedgerById(ledgerId);
      expect(ledger!.aaEnabled, true, reason: '未传 aaEnabled 时应保持原值');
      expect(ledger.name, '新名称');
    });
  });

  group('虚拟用户 CRUD 经 LocalRepository 委托', () {
    test('create: 新建并返回 UUID', () async {
      final id = await repo.createPlaceholderMember(
        ledgerId: ledgerId,
        name: '室友A',
      );
      expect(id, isNotEmpty);
    });

    test('rename: 更新名称', () async {
      final id = await repo.createPlaceholderMember(
        ledgerId: ledgerId,
        name: '旧名',
      );
      await repo.renameMember(id: id, name: '新名');

      final user = await (db.select(
        db.ledgerMembers,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(user.displayName, '新名');
    });

    test('delete: 硬删', () async {
      final id = await repo.createPlaceholderMember(
        ledgerId: ledgerId,
        name: '待删',
      );
      final deleted = await repo.deleteMember(id);
      expect(deleted, isTrue);
    });

    test('delete: 名下有账不可删(抛错)', () async {
      final id = await repo.createPlaceholderMember(
        ledgerId: ledgerId,
        name: '被引用',
      );
      // 插入引用该虚拟用户的交易(指定分摊关系表存虚拟用户 UUID)
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '30.00',
        happenedAt: DateTime.now(),
        aaMode: 2,
        splits: [TransactionSplitInput(memberId: id, amount: '30.00')],
      );

      // 删除应抛错
      expect(() => repo.deleteMember(id), throwsA(isA<StateError>()));
    });
  });
}
