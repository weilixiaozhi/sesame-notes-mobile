/// 成员展示快照刷新仓储测试。
///
/// 锁定行为:
/// - refreshDisplayByAccount:本人更新云 Profile 后,同 linked_account_id 的
///   REGISTERED 成员行昵称/头像被刷新;LOCAL/PLACEHOLDER 与已删除行不受影响;
///   不产生 sync_changes(纯镜像刷新)。
/// - applyDirectorySnapshot:服务端成员列表快照覆盖展示字段;昵称为空的
///   快照保留本地已有昵称;远端缺失本地已有的行保留。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';

import '../../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalLedgerMemberRepository repo;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalLedgerMemberRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedLedger(String id, String storageMode) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: id,
            storageMode: d.Value(storageMode),
            updatedAt: DateTime.utc(2026, 8, 24),
          ),
        );
  }

  Future<void> seedMember({
    required String id,
    required String ledgerId,
    required String memberType,
    String? linkedAccountId,
    String displayName = '旧昵称',
    DateTime? deletedAt,
  }) async {
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName: displayName,
            memberType: memberType,
            linkedAccountId: d.Value(linkedAccountId),
            updatedAt: DateTime.utc(2026, 8, 24),
            deletedAt: d.Value(deletedAt),
          ),
        );
  }

  test('refreshDisplayByAccount:同账号 REGISTERED 成员昵称/头像刷新,其余不受影响', () async {
    await seedLedger('ledger-1', 'cloud');
    await seedLedger('ledger-2', 'cloud');
    await seedMember(
      id: 'self-1',
      ledgerId: 'ledger-1',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-1',
    );
    await seedMember(
      id: 'self-2',
      ledgerId: 'ledger-2',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-1',
    );
    await seedMember(
      id: 'other-1',
      ledgerId: 'ledger-1',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-2',
    );
    await seedMember(
      id: 'local-1',
      ledgerId: 'ledger-1',
      memberType: 'LOCAL',
      linkedAccountId: 'user-1',
    );

    final n = await repo.refreshDisplayByAccount(
      userId: 'user-1',
      displayName: '新云昵称',
      avatarUrl: 'https://example.com/a.png',
      avatarVersion: 3,
    );

    expect(n, 2, reason: '仅两个绑定 user-1 的 REGISTERED 成员行被刷新');
    final self1 = (await repo.getById('self-1'))!;
    expect(self1.displayName, '新云昵称');
    expect(self1.avatarUrl, 'https://example.com/a.png');
    expect(self1.avatarVersion, 3);
    final other = (await repo.getById('other-1'))!;
    expect(other.displayName, '旧昵称');
    final local = (await repo.getById('local-1'))!;
    expect(local.displayName, '旧昵称', reason: 'LOCAL 成员不受云资料刷新影响');
    // 不产生 sync_changes
    final changes = await db.select(db.syncChanges).get();
    expect(changes, isEmpty, reason: '资料快照刷新不得登记同步变更');
  });

  test('refreshDisplayByAccount:昵称为空防御性跳过,不覆盖已有昵称', () async {
    await seedLedger('ledger-1', 'cloud');
    await seedMember(
      id: 'self-1',
      ledgerId: 'ledger-1',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-1',
    );

    await repo.refreshDisplayByAccount(
      userId: 'user-1',
      displayName: '  ',
      avatarUrl: null,
      avatarVersion: 0,
    );

    final row = (await repo.getById('self-1'))!;
    expect(row.displayName, '旧昵称', reason: '空昵称不得覆盖已有昵称');
    expect(row.avatarVersion, 0);
  });

  test('applyDirectorySnapshot:快照覆盖展示字段,空昵称保留本地,缺失行不删除', () async {
    await seedLedger('ledger-1', 'cloud');
    await seedMember(
      id: 'self-1',
      ledgerId: 'ledger-1',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-1',
    );
    await seedMember(
      id: 'left-1',
      ledgerId: 'ledger-1',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-3',
      displayName: '已离开成员',
    );

    await repo.applyDirectorySnapshot(
      ledgerId: 'ledger-1',
      members: [
        LedgerDirectoryMember(
          memberId: 'self-1',
          displayName: '服务端昵称',
          linkedAccountId: 'user-1',
          role: 'owner',
          status: 'ACTIVE',
          avatarUrl: 'https://example.com/a.png',
          avatarVersion: 2,
          joinedAt: _j,
        ),
        // 昵称为空:远端快照按原样落库(服务端保证恒非空,客户端不臆造)
        LedgerDirectoryMember(
          memberId: 'self-2',
          displayName: '',
          linkedAccountId: 'user-2',
          role: 'editor',
          status: 'ACTIVE',
          avatarVersion: 0,
          joinedAt: _j,
        ),
      ],
    );

    final self1 = (await repo.getById('self-1'))!;
    expect(self1.displayName, '服务端昵称');
    expect(self1.role, 'owner');
    expect(self1.avatarVersion, 2);
    final self2 = (await repo.getById('self-2'))!;
    expect(self2.displayName, '', reason: '远端快照昵称为空时按服务端值落库');
    final left = (await repo.getById('left-1'))!;
    expect(left.displayName, '已离开成员', reason: '快照缺失的本地行保留,生命周期以同步为准');
    final changes = await db.select(db.syncChanges).get();
    expect(changes, isEmpty, reason: '目录快照不得登记同步变更');
  });
}

final DateTime _j = DateTime.utc(2026, 1, 1);
