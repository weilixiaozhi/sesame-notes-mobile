import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../helpers/ledger_sync_fixture.dart';
import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('成员连续编辑与生成请求完整保留毫秒版本', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final fixture = LedgerSyncFixture(
      db,
      'account',
      localSelfId: () async => 'self',
    );
    addTearDown(() async {
      fixture.client.dio.close(force: true);
      await db.close();
    });
    final repo = LocalRepository(
      db,
      accountIdGetter: () => 'account',
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
    );
    final ledger = await repo.createLedger(name: '成员精度', storageMode: 'cloud');
    final member = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '初始成员',
    );
    final started = DateTime.now().toUtc();
    for (var index = 0; index < 100; index++) {
      await repo.renameMember(id: member, name: '快速编辑$index');
    }
    await repo.deleteMember(member);
    await fixture.service.push();
    final changes = fixture.requests
        .where((row) => row['entity_id'] == member)
        .toList();
    expect(changes, hasLength(102));
    final times = changes
        .map(
          (row) => DateTime.parse(
            row['updated_at'] as String,
          ).millisecondsSinceEpoch,
        )
        .toList();
    for (var index = 1; index < times.length; index++) {
      expect(
        times[index],
        greaterThan(times[index - 1]),
        reason: '同设备后继必须有不同服务端毫秒',
      );
    }
    expect(
      times.last,
      lessThan(started.add(const Duration(seconds: 5)).millisecondsSinceEpoch),
      reason: '不得按整秒累计时钟触发服务器 5 秒裁剪',
    );
    expect(changes.last['action'], 'delete');
  });

  test('成员远端毫秒基线在落盘和已确认队列压缩后仍约束后续编辑', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final fixture = LedgerSyncFixture(
      db,
      'account',
      localSelfId: () async => 'self',
    );
    addTearDown(() async {
      fixture.client.dio.close(force: true);
      await db.close();
    });
    final repo = LocalRepository(
      db,
      accountIdGetter: () => 'account',
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
    );
    final ledger = await repo.createLedger(
      name: '成员版本基线',
      storageMode: 'cloud',
    );
    final member = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '远端成员',
    );
    await (db.update(db.ledgers)..where((row) => row.id.equals(ledger))).write(
      const LedgersCompanion(syncId: d.Value('test-binding')),
    );
    // 模拟已观察的未来容差内云端版本，后续时间必须由实体基线而非墙上时钟保证。
    final observed = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000 + 2947,
      isUtc: true,
    );
    await (db.update(db.ledgerMembers)..where((row) => row.id.equals(member)))
        .write(LedgerMembersCompanion(updatedAt: d.Value(observed)));
    await db.delete(db.syncChanges).go();
    var previous = observed;
    expect((await repo.getMemberById(member))!.updatedAt, observed);
    for (var index = 0; index < 3; index++) {
      await repo.renameMember(id: member, name: '后继编辑$index');
      final pending = await db.select(db.syncChanges).getSingle();
      final stored = (await repo.getMemberById(member))!.updatedAt;
      expect(stored, pending.updatedAt);
      expect(stored.isAfter(previous), isTrue);
      await fixture.service.push();
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
      expect(
        DateTime.parse(fixture.requests.last['updated_at'] as String),
        stored,
      );
      // 已确认历史不是版本事实来源；实体行仍须精确保留上一次毫秒时间。
      await db.delete(db.syncChanges).go();
      previous = stored;
    }
  });
}
