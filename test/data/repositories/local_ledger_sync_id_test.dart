// 账本同步身份生命周期（客户端 repository 层）。
//
// - LOCAL_ONLY 账本没有 active sync_id；
// - sync_id 只标识云同步时间线；Detach 清除 binding，不生成伪本地 sync_id。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<Ledger?> ledgerRow(String id) async {
    final rows = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(id))).get();
    return rows.isEmpty ? null : rows.single;
  }

  test('新建本地账本 sync_id 恒为 NULL（无同步身份）', () async {
    final id = await repo.createLedger(name: '纯本地账本', storageMode: 'local');
    final row = await ledgerRow(id);
    expect(row?.storageMode, 'local');
    expect(row?.syncId, isNull);
  });

  test('新建云端账本 sync_id 为 NULL（首次上云尚未建立绑定，由服务端生成后返回）', () async {
    final id = await repo.createLedger(name: '待上云账本', storageMode: 'cloud');
    final row = await ledgerRow(id);
    expect(row?.storageMode, 'cloud');
    expect(row?.syncId, isNull);
  });

  test('createBoundLedger 携带服务端 sync_id：绑定行落库', () async {
    await repo.createBoundLedger(
      id: 'led-bound',
      name: '已绑定账本',
      syncId: 'S100',
    );
    final row = await ledgerRow('led-bound');
    expect(row?.storageMode, 'cloud');
    expect(row?.syncId, 'S100');
  });

  test('updateLedgerSyncId：同步身份更新（绑定确认路径）', () async {
    final id = await repo.createLedger(name: '云端账本', storageMode: 'cloud');
    await repo.updateLedgerSyncId(id: id, syncId: 'S200');
    final row = await ledgerRow(id);
    expect(row?.syncId, 'S200');
  });

  test('detachFromCloud 清除 binding（sync_id=NULL），不生成伪本地 sync_id', () async {
    final id = await repo.createLedger(name: '云端账本', storageMode: 'cloud');
    await repo.updateLedgerSyncId(id: id, syncId: 'S300');
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    // 断联前存在待推送变更
    expect(await db.select(db.syncChanges).get(), isNotEmpty);

    await repo.detachFromCloud(id);

    final row = await ledgerRow(id);
    expect(row?.storageMode, 'local');
    expect(row?.syncId, isNull);
    // 待推送变更随断联清除
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
}
