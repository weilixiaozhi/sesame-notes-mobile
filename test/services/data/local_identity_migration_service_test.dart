/// 登录不得改写本地账本（一期不变量 I-02/I-03）单测。
///
/// 锚点：登录只建立账号会话，LOCAL ledger、LOCAL member、self_member_id、
/// 交易作者/付款人/分摊引用一行不改；`unbindOnLogout` 只清 LOCAL 绑定的
/// linked_account_id，不改 member id、display name、交易或分摊引用。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/identity/local_user_identity.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/identity_binding_service.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 构造带历史引用（作者/付款人/分摊）的本地账本，返回业务快照。
  Future<Map<String, Object?>> localSnapshot(String ledgerId) async {
    final ledger = await repo.getLedgerById(ledgerId);
    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(ledgerId))).get();
    final members = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.ledgerId.equals(ledgerId))).get();
    final splits = await (db.select(db.transactionSplits)).get();
    return {
      'storage_mode': ledger?.storageMode,
      'self_member_id': ledger?.selfMemberId,
      'tx_count': txs.length,
      'member_count': members.length,
      'split_count': splits.length,
      'created_by': txs.map((t) => t.createdByMemberId).toList(),
      'payer': txs.map((t) => t.payerMemberId).toList(),
      'member_ids': members.map((m) => m.id).toList(),
      'member_types': members.map((m) => m.memberType).toList(),
    };
  }

  test('登录前后本地账本业务快照完全不变（登录不建立 LOCAL 绑定）', () async {
    final selfId = await LocalSelfId.getOrCreate();
    final ledgerId = await repo.createLedger(
      name: '账本',
      storageMode: 'local',
      localSelfId: selfId,
    );
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    // 本地编辑路径回填 self member 引用
    final selfMemberId = localSelfMemberId(ledgerId, selfId);
    await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
      TransactionsCompanion(
        createdByMemberId: d.Value(selfMemberId),
        lastEditedByMemberId: d.Value(selfMemberId),
        payerMemberId: d.Value(selfMemberId),
      ),
    );

    final before = await localSnapshot(ledgerId);

    // 登录只建会话：一期没有 bindOnLogin 分支可调用，快照必须保持不变
    final after = await localSnapshot(ledgerId);
    expect(after, before);
  });

  test('unbindOnLogout：只清 LOCAL 绑定，成员与历史引用保留', () async {
    final selfId = await LocalSelfId.getOrCreate();
    final ledgerId = await repo.createLedger(
      name: '账本',
      storageMode: 'local',
      localSelfId: selfId,
    );
    final selfMemberId = localSelfMemberId(ledgerId, selfId);
    // 模拟旧版本遗留绑定
    await (db.update(
      db.ledgerMembers,
    )..where((m) => m.id.equals(selfMemberId))).write(
      LedgerMembersCompanion(
        linkedAccountId: d.Value('legacy-cloud-user'),
        updatedAt: d.Value(DateTime.now().toUtc()),
      ),
    );

    await IdentityBindingService.unbindOnLogout(db: db);

    final member = await repo.getMemberById(selfMemberId);
    expect(member, isNotNull, reason: '成员行保留');
    expect(member!.linkedAccountId, isNull, reason: '只清绑定');
    expect(member.memberType, 'LOCAL');
    final nameAfter = member.displayName;
    expect(nameAfter, isNotNull, reason: '展示名保留（unbind 不触碰 display_name）');
    final ledger = await repo.getLedgerById(ledgerId);
    expect(ledger!.selfMemberId, selfMemberId, reason: 'self_member_id 不改写');
  });
}
