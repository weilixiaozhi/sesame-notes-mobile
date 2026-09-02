// AA 分摊:虚拟用户 Repository CRUD + 删除约束测试。
//
// 本测试验证 [LocalLedgerMemberRepository] 的:
//   1. CRUD 基本操作(create/getByLedger/getById/rename/delete)
//   2. watchByLedger stream 正常
//   3. 删除约束:被交易的 aaParticipants 引用时不允许删除
//   4. 未被引用时正常硬删

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalLedgerMemberRepository repo;

  /// 创建账本行（UUID 主键 + updated_at 必填），返回账本 id。
  Future<String> seedLedger(SesameDatabase db, String id) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: 'L',
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  /// 插入一笔引用指定 AA 参与人的交易（v1 下指定分摊存 transaction_splits 关系表）。
  Future<void> insertTxWithParticipants(
    String ledgerId,
    List<String> participants,
  ) async {
    final now = DateTime.now().toUtc();
    final txId = 'tx-${now.microsecondsSinceEpoch}';
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: txId,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '30.00',
            happenedAt: DateTime.now(),
            aaMode: const d.Value(2),
            currencyCode: 'CNY',
            nativeAmount: '30.00',
            createdAt: now,
            updatedAt: now,
          ),
        );
    // 指定分摊写入关系表:参与者即成员 id（单轨模型）。
    await db.batch((b) {
      b.insertAll(db.transactionSplits, [
        for (final p in participants)
          TransactionSplitsCompanion.insert(
            transactionId: txId,
            memberId: p,
            amount: '30.00',
          ),
      ]);
    });
  }

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalLedgerMemberRepository(db);
    // 外键约束:虚拟用户与交易引用的账本先存在。
    await seedLedger(db, 'l-1');
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD', () {
    test('create: 新建虚拟用户,自动填 UUID 主键', () async {
      final id = await repo.createPlaceholder(ledgerId: 'l-1', name: '室友A');
      final user = await (db.select(
        db.ledgerMembers,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(user.displayName, '室友A');
      expect(user.ledgerId, 'l-1');
      expect(user.id, isNotEmpty);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('create: 显式传 id 时用传入值', () async {
      final id = await repo.createPlaceholder(
        ledgerId: 'l-1',
        name: '室友B',
        id: 'custom-uuid-123',
      );
      final user = await (db.select(
        db.ledgerMembers,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(user.id, 'custom-uuid-123');
    });

    test('getByLedger: 只返回指定账本的虚拟用户', () async {
      await repo.createPlaceholder(ledgerId: 'l-1', name: '用户1');
      await repo.createPlaceholder(ledgerId: 'l-1', name: '用户2');
      await seedLedger(db, 'l-2');
      await repo.createPlaceholder(ledgerId: 'l-2', name: '用户3');

      final ledger1Users = await repo.getByLedger('l-1');
      final ledger2Users = await repo.getByLedger('l-2');

      expect(ledger1Users.length, 2);
      expect(ledger2Users.length, 1);
      expect(ledger2Users.first.displayName, '用户3');
    });

    test('getById: 按 UUID 精确匹配', () async {
      await repo.createPlaceholder(ledgerId: 'l-1', name: '用户', id: 'sync-abc');
      final user = await repo.getById('sync-abc');
      expect(user, isNotNull);
      expect(user!.displayName, '用户');

      final notFound = await repo.getById('non-existent');
      expect(notFound, isNull);
    });

    test('rename: 更新名称并写入 updatedAt', () async {
      final id = await repo.createPlaceholder(ledgerId: 'l-1', name: '旧名');
      await repo.rename(id: id, name: '新名');
      final user = await (db.select(
        db.ledgerMembers,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(user.displayName, '新名');
      expect(user.updatedAt, isNotNull);
    });

    test('delete: 未被引用时正常硬删', () async {
      final id = await repo.createPlaceholder(ledgerId: 'l-1', name: '待删');
      final deleted = await repo.delete(id);
      expect(deleted, isTrue);
      final remaining = await repo.getByLedger('l-1');
      expect(remaining, isEmpty);
    });

    test('delete: 不存在的 id 返回 false', () async {
      final deleted = await repo.delete('no-such-uuid');
      expect(deleted, isFalse);
    });
  });

  group('watchByLedger', () {
    test('监听指定账本的虚拟用户列表,数据变化时自动 emit', () async {
      final stream = repo.watchByLedger('l-1');
      final emitted = <List<LedgerMember>>[];
      final sub = stream.listen(emitted.add);

      // 等待初始 emit
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted, isNotEmpty);
      expect(emitted.last, isEmpty);

      // 插入一条
      await repo.createPlaceholder(ledgerId: 'l-1', name: '用户1');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted.last.length, 1);
      expect(emitted.last.first.displayName, '用户1');

      // 插入第二条
      await repo.createPlaceholder(ledgerId: 'l-1', name: '用户2');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted.last.length, 2);

      // 删除一条
      await repo.delete(emitted.last.first.id);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted.last.length, 1);

      await sub.cancel();
    });

    test('只监听指定账本,其他账本变化不触发', () async {
      await seedLedger(db, 'l-2');
      await repo.createPlaceholder(ledgerId: 'l-2', name: '其他账本用户');

      final stream = repo.watchByLedger('l-1');
      final emitted = <List<LedgerMember>>[];
      final sub = stream.listen(emitted.add);

      await Future.delayed(const Duration(milliseconds: 50));
      // 账本 1 没有用户
      expect(emitted.last, isEmpty);

      // 在账本 2 插入,不应触发账本 1 的 stream
      await repo.createPlaceholder(ledgerId: 'l-2', name: '又一个');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emitted.last, isEmpty);

      await sub.cancel();
    });
  });

  group('删除约束:名下有账不可删', () {
    test('被交易的 aaParticipants 引用时抛 StateError', () async {
      final vUserId = await repo.createPlaceholder(
        ledgerId: 'l-1',
        name: '被引用用户',
      );
      // 插入一笔交易,aaParticipants 包含该虚拟用户 UUID
      await insertTxWithParticipants('l-1', ['user-alice', vUserId]);

      // 校验引用检测
      final referenced = await repo.isReferencedByAnyTransaction(vUserId);
      expect(referenced, isTrue, reason: '被 aaParticipants 引用时应返回 true');

      // 尝试删除应抛错
      expect(
        () => repo.delete(vUserId),
        throwsA(isA<StateError>()),
        reason: '名下有账不可删',
      );

      // 验证行仍在
      final stillExists = await (db.select(
        db.ledgerMembers,
      )..where((t) => t.id.equals(vUserId))).getSingleOrNull();
      expect(stillExists, isNotNull);
    });

    test('未被引用时正常删除', () async {
      final vUserId = await repo.createPlaceholder(
        ledgerId: 'l-1',
        name: '未引用用户',
      );
      // 插入一笔不含该虚拟用户 UUID 的交易
      await insertTxWithParticipants('l-1', ['user-alice']);

      final referenced = await repo.isReferencedByAnyTransaction(vUserId);
      expect(referenced, isFalse);

      final deleted = await repo.delete(vUserId);
      expect(deleted, isTrue);
    });

    test('无交易引用该虚拟用户时不算被引用', () async {
      // 直接插入一个从未被任何交易引用的虚拟用户
      final id = await repo.createPlaceholder(ledgerId: 'l-1', name: '无引用用户');
      final referenced = await repo.isReferencedByAnyTransaction(id);
      expect(referenced, isFalse, reason: '未被交易 aaParticipants 引用的虚拟用户不算被引用');
    });
  });
}
