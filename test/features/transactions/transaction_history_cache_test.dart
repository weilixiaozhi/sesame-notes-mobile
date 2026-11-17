import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/policy/cloud_capability.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/features/statistics/application/cloud_record_history.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

import '../../helpers/test_isolation.dart';

const _account = 'history-account';
const _generation = 7;

/// 云账本交易使用可预测的修订号，静默补拉直接按该版本判断缓存是否落后。
Future<({LocalRepository repo, String ledgerId, String transactionId})>
_createCloudTransaction(SesameDatabase db, {int revision = 3}) async {
  final repo = LocalRepository(db, accountIdGetter: () => _account);
  final ledgerId = await repo.createLedger(name: '云端账本', storageMode: 'cloud');
  await repo.updateLedgerSyncId(id: ledgerId, syncId: 'sync-binding');
  final transactionId = await repo.addTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '12.34',
    happenedAt: DateTime.utc(2026, 11, 3, 10),
  );
  await (db.update(
    db.transactions,
  )..where((row) => row.id.equals(transactionId))).write(
    TransactionsCompanion(
      version: d.Value(revision),
      serverRevision: d.Value(revision),
    ),
  );
  return (repo: repo, ledgerId: ledgerId, transactionId: transactionId);
}

/// 所有测试共享同一条真实内存库和同一组身份/网络替身。
ProviderContainer _container({
  required SesameDatabase db,
  required LocalRepository repo,
  required String ledgerId,
  CloudRecordHistoryLoader? loader,
}) {
  return ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(repo),
      databaseProvider.overrideWithValue(db),
      currentAccountIdProvider.overrideWithValue(_account),
      authIdentityGenerationProvider.overrideWithValue(_generation),
      cloudCapabilityProvider.overrideWithValue(
        const CloudCapability(
          serverConfigured: true,
          syncEnabled: true,
          hasSession: true,
        ),
      ),
      ledgerByIdProvider(
        ledgerId,
      ).overrideWith((ref) async => await repo.getLedgerById(ledgerId)),
      if (loader != null)
        cloudRecordHistoryLoaderProvider.overrideWithValue(loader),
    ],
  );
}

CloudRecordHistoryEntry _entry(
  int version, {
  required String recordId,
  String? note,
}) => CloudRecordHistoryEntry(
  id: 'cloud-$recordId-$version',
  recordId: recordId,
  version: version,
  createdAt: DateTime.utc(2026, 11, 3, 10, version),
  operatorMemberId: 'member',
  operatorDisplayName: '远端成员',
  changes: {'note': note ?? '远端备注$version'},
);

CloudRecordEditHistorySnapshot _cached(
  String recordId,
  int version, {
  String? id,
}) => CloudRecordEditHistorySnapshot(
  id: id ?? 'cloud-$recordId-$version',
  recordId: recordId,
  version: version,
  operatorMemberId: 'member',
  operatorDisplayName: '远端成员',
  changesJson: '{"note":"缓存$version"}',
  // 晚于本机写入时间，确保合并断言可以验证“云端在前”的排序语义。
  createdAt: DateTime.now().toUtc().add(Duration(minutes: 1 + version)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('云端缓存与本机历史一起读取，删除交易时两处历史同时清理', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db);
    final repo = fixture.repo;
    final recordId = fixture.transactionId;

    await repo.appendEditHistory(
      recordId: recordId,
      version: 2,
      operatorMemberId: 'member',
      summary: '本地摘要',
    );
    await repo.upsertCloudEditHistories([_cached(recordId, 2)]);

    final rows = await repo.watchEditHistories(recordId).first;
    expect(rows.local.single.summary, '本地摘要');
    expect(rows.cloud.single.operatorDisplayName, '远端成员');
    expect(await repo.cloudEditHistoryCacheStates([recordId]), {
      recordId: (maxVersion: 2, count: 1),
    });

    await deleteTransactionsWithEditHistories(db, [recordId]);
    expect(await repo.getEditHistories(recordId), isEmpty);
    expect(await db.select(db.cloudRecordEditHistories).get(), isEmpty);
  });

  test('云端未完整时保留两类历史，并在云端写入后自动更新且不访问网络', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db);
    final repo = fixture.repo;
    final recordId = fixture.transactionId;
    final container = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
    );
    addTearDown(container.dispose);

    await repo.appendEditHistory(
      recordId: recordId,
      version: 2,
      operatorMemberId: 'member',
      summary: '本地摘要',
    );
    final values = <List<RecordEditHistoryDisplayShim>>[];
    final subscription = container.listen(recordEditHistoryProvider(recordId), (
      previous,
      next,
    ) {
      final list = next.value;
      if (list == null) return;
      values.add([
        for (final item in list)
          RecordEditHistoryDisplayShim(
            version: item.version,
            isCloud: item.isCloud,
          ),
      ]);
    }, fireImmediately: true);
    addTearDown(subscription.close);
    await pumpEventQueue();
    expect(values.last.single.isCloud, isFalse);

    await repo.upsertCloudEditHistories([_cached(recordId, 3)]);
    await pumpEventQueue();
    expect(values.last.map((item) => item.isCloud), [isTrue, isFalse]);
  });

  test('云端完整后隐藏同一编辑的本机副本，只保留云端行', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db, revision: 3);
    final repo = fixture.repo;
    final recordId = fixture.transactionId;
    await repo.appendEditHistory(
      recordId: recordId,
      version: 2,
      operatorMemberId: 'member',
      summary: '本地摘要2',
    );
    await repo.appendEditHistory(
      recordId: recordId,
      version: 3,
      operatorMemberId: 'member',
      summary: '本地摘要3',
    );
    await repo.upsertCloudEditHistories([
      _cached(recordId, 2),
      _cached(recordId, 3),
    ]);
    final container = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
    );
    addTearDown(container.dispose);

    final values = <List<RecordEditHistoryDisplayShim>>[];
    final subscription = container.listen(recordEditHistoryProvider(recordId), (
      previous,
      next,
    ) {
      final list = next.value;
      if (list == null) return;
      values.add([
        for (final item in list)
          RecordEditHistoryDisplayShim(
            version: item.version,
            isCloud: item.isCloud,
          ),
      ]);
    }, fireImmediately: true);
    addTearDown(subscription.close);
    await pumpEventQueue();

    expect(values.last.map((item) => item.isCloud), [isTrue, isTrue]);
    expect(values.last.map((item) => item.version), [3, 2]);
  });

  test('云端完整后仍显示未上传的本机版本，同版本云端优先', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db, revision: 4);
    final repo = fixture.repo;
    final recordId = fixture.transactionId;
    // 版本 3 两端都有，只保留云端；版本 5 只有本机，属于待同步。
    await repo.appendEditHistory(
      recordId: recordId,
      version: 3,
      operatorMemberId: 'member',
      summary: '本地摘要3',
    );
    await repo.appendEditHistory(
      recordId: recordId,
      version: 5,
      operatorMemberId: 'member',
      summary: '本地待同步5',
    );
    await repo.upsertCloudEditHistories([
      _cached(recordId, 2),
      _cached(recordId, 3),
      _cached(recordId, 4),
    ]);
    final container = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
    );
    addTearDown(container.dispose);

    final values = <List<RecordEditHistoryDisplayShim>>[];
    final subscription = container.listen(recordEditHistoryProvider(recordId), (
      previous,
      next,
    ) {
      final list = next.value;
      if (list == null) return;
      values.add([
        for (final item in list)
          RecordEditHistoryDisplayShim(
            version: item.version,
            isCloud: item.isCloud,
          ),
      ]);
    }, fireImmediately: true);
    addTearDown(subscription.close);
    await pumpEventQueue();

    // 云端已覆盖 revision 4，隐藏本机版本 3；版本 5 尚未上传，仍需展示。
    expect(values.last.map((item) => item.isCloud), [
      isTrue,
      isTrue,
      isTrue,
      isFalse,
    ]);
    expect(values.last.map((item) => item.version), [4, 3, 2, 5]);
  });

  test('批量分页逐页写入缓存，缓存完整后不再请求', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db, revision: 3);
    final repo = fixture.repo;
    final transaction = (await repo.getTransactionById(
      fixture.transactionId,
    ))!.toDisplay();
    final loaderCalls = <String?>[];
    final container = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
      loader:
          ({
            required ledgerId,
            required transactionIds,
            cursor,
            required cancelToken,
          }) async {
            loaderCalls.add(cursor);
            expect(transactionIds, [fixture.transactionId]);
            return cursor == null
                ? CloudRecordHistoryPage([
                    _entry(3, recordId: fixture.transactionId),
                    _entry(2, recordId: fixture.transactionId),
                  ], 'next')
                : CloudRecordHistoryPage([
                    _entry(1, recordId: fixture.transactionId),
                  ], null);
          },
    );
    addTearDown(container.dispose);

    await refreshCloudRecordEditHistories(container, fixture.ledgerId, [
      transaction,
    ]);
    expect(loaderCalls, [null, 'next']);
    final cached = await repo.watchEditHistories(fixture.transactionId).first;
    expect(cached.cloud.map((row) => row.version), [3, 2, 1]);
    expect(await repo.cloudEditHistoryCacheStates([fixture.transactionId]), {
      fixture.transactionId: (maxVersion: 3, count: 3),
    });

    await refreshCloudRecordEditHistories(container, fixture.ledgerId, [
      transaction,
    ]);
    expect(loaderCalls, [null, 'next']);
  });

  test('仅有最高版本的部分缓存仍会补拉，失败不抛错也不覆盖已有缓存', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = await _createCloudTransaction(db, revision: 3);
    final repo = fixture.repo;
    final recordId = fixture.transactionId;
    final transaction = (await repo.getTransactionById(recordId))!.toDisplay();
    // 上次中断只写入最新版本，最高版本虽已追上，但行数不足，仍需补拉。
    await repo.upsertCloudEditHistories([_cached(recordId, 3)]);
    var loaderCalls = 0;
    final failing = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
      loader:
          ({
            required ledgerId,
            required transactionIds,
            cursor,
            required cancelToken,
          }) async {
            loaderCalls++;
            throw StateError('网络不可用');
          },
    );
    addTearDown(failing.dispose);

    await expectLater(
      refreshCloudRecordEditHistories(failing, fixture.ledgerId, [transaction]),
      completes,
    );
    expect(loaderCalls, 1);
    expect(
      (await repo.watchEditHistories(recordId).first).cloud.map(
        (row) => row.version,
      ),
      [3],
    );

    // 新会话没有失败冷却，验证补齐缺失版本后缓存标记为完整。
    final recovered = _container(
      db: db,
      repo: repo,
      ledgerId: fixture.ledgerId,
      loader:
          ({
            required ledgerId,
            required transactionIds,
            cursor,
            required cancelToken,
          }) async {
            loaderCalls++;
            return CloudRecordHistoryPage([
              _entry(3, recordId: recordId),
              _entry(2, recordId: recordId),
            ], null);
          },
    );
    addTearDown(recovered.dispose);
    await refreshCloudRecordEditHistories(recovered, fixture.ledgerId, [
      transaction,
    ]);
    expect(loaderCalls, 2);
    expect(
      (await repo.watchEditHistories(recordId).first).cloud.map(
        (row) => row.version,
      ),
      [3, 2],
    );
    expect(await repo.cloudEditHistoryCacheStates([recordId]), {
      recordId: (maxVersion: 3, count: 2),
    });
  });
}

/// 只保留测试断言需要的展示字段，避免依赖完整的本地化上下文。
class RecordEditHistoryDisplayShim {
  const RecordEditHistoryDisplayShim({
    required this.version,
    required this.isCloud,
  });
  final int version;
  final bool isCloud;
}
