import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

const _viewer = '10000000-0000-4000-8000-000000000001';
const _sharedOwner = '10000000-0000-4000-8000-000000000002';
const _ledger = '20000000-0000-4000-8000-000000000001';
const _category = '30000000-0000-4000-8000-000000000001';
const _transaction = '40000000-0000-4000-8000-000000000001';
final _stamp = DateTime.utc(2026, 10, 11, 1, 2, 3);

/// 权威删除事件可补齐旧缓存未知Owner，保护分支仍必须从该Owner的正确目录复制。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncService service;
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient();
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'delete-owner-device',
      repo: LocalLedgerRepository(db),
      currentAccountIdGetter: () => _viewer,
      localSelfIdLoader: () async => 'local-self',
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledger,
            name: '旧缓存云账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_viewer),
            role: const d.Value('owner'),
            syncId: const d.Value('50000000-0000-4000-8000-000000000001'),
            updatedAt: _stamp,
          ),
        );
    for (final (account, name) in [
      (_viewer, '本人分类'),
      (_sharedOwner, '他人私有缓存'),
    ]) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: _category,
              name: name,
              kind: 'expense',
              level: 1,
              scopeAccountId: d.Value(account),
              cloudRegistered: const d.Value(true),
              updatedAt: _stamp,
            ),
          );
    }
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: _transaction,
            ledgerId: _ledger,
            txType: 'expense',
            amount: '10',
            nativeAmount: '10',
            currencyCode: 'CNY',
            categoryId: const d.Value(_category),
            note: const d.Value('未上传修改'),
            happenedAt: _stamp,
            createdAt: _stamp,
            updatedAt: _stamp,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: _transaction,
            ledgerId: const d.Value(_ledger),
            action: 'upsert',
            payload: jsonEncode({'note': '未上传修改', 'category_id': _category}),
            accountId: const d.Value(_viewer),
            mutationId: '60000000-0000-4000-8000-000000000001',
            updatedAt: _stamp,
          ),
        );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 远端墓碑沿真实生成协议解析，不请求已经删除账本的GET补证。
  api.GetSyncPull200ResponseChangesInner event(
    String? owner, {
    bool detached = false,
  }) => api.standardSerializers.deserializeWith(
    api.GetSyncPull200ResponseChangesInner.serializer,
    {
      'change_id': '101',
      'entity_type': 'ledger',
      'entity_id': _ledger,
      'ledger_id': detached ? null : _ledger,
      'action': 'delete',
      'mutation_id': '70000000-0000-4000-8000-000000000001',
      'updated_at': _stamp.add(const Duration(seconds: 1)).toIso8601String(),
      'device_id': 'remote-device',
      'payload': {
        'owner_id': ?owner,
        'deleted_at': _stamp.add(const Duration(seconds: 1)).toIso8601String(),
      },
    },
  )!;

  /// 采用实际pull相同的账号事务，保护失败不能留下部分账本或类别写入。
  Future<void> apply(String? owner, {bool detached = false}) =>
      service.runtime.inAccountTransaction(
        _viewer,
        () => service.projectionHandler.applyChange(
          event(owner, detached: detached),
        ),
      );

  for (final (owner, detached) in [
    (_viewer, false),
    (_sharedOwner, false),
    (_sharedOwner, true),
  ]) {
    test(
      '${detached ? '账号注销解除事件外键' : '账本删除'}：权威${owner == _viewer ? '本人' : '共享'}归属保护未上传正文和原类别身份',
      () async {
        if (owner == _sharedOwner) {
          await db
              .into(db.sharedLedgerCategories)
              .insert(
                SharedLedgerCategoriesCompanion.insert(
                  ledgerId: _ledger,
                  categoryId: _category,
                  name: '共享账本真实分类',
                  kind: 'expense',
                  updatedAt: _stamp,
                ),
              );
        }
        final privateBefore = await db.select(db.categories).get();
        await apply(owner, detached: detached);
        final source = await (db.select(
          db.ledgers,
        )..where((l) => l.id.equals(_ledger))).getSingle();
        expect(source.ownerAccountId, owner);
        expect(source.role, owner == _viewer ? 'owner' : 'editor');
        expect(
          source.deletedAt?.toUtc(),
          _stamp.add(const Duration(seconds: 1)),
        );
        final copy = await (db.select(
          db.ledgers,
        )..where((l) => l.storageMode.equals('local'))).getSingle();
        expect(copy.originType, 'DR_PROTECT');
        final transaction = await (db.select(
          db.transactions,
        )..where((t) => t.ledgerId.equals(copy.id))).getSingle();
        expect(
          (transaction.note, transaction.categoryId),
          ('未上传修改', _category),
        );
        final local = await (db.select(
          db.categories,
        )..where((c) => categoryScopePredicate(c, null))).getSingle();
        expect(local.name, owner == _viewer ? '本人分类' : '共享账本真实分类');
        expect(local.cloudRegistered, isFalse);
        final privateAfter = await (db.select(
          db.categories,
        )..where((c) => c.scopeAccountId.isNotValue(''))).get();
        expect(privateAfter, privateBefore);
      },
    );
  }

  test('无Owner的删除保持未知来源和本机修改，不用旧roleowner或私有同UUID猜测分类', () async {
    final ledgerBefore = await db.select(db.ledgers).get();
    final categoriesBefore = await db.select(db.categories).get();
    final transactionsBefore = await db.select(db.transactions).get();
    final queueBefore = await db.select(db.syncChanges).get();
    await expectLater(
      apply(null),
      throwsA(
        isA<SyncOperationFailure>().having(
          (error) => error.code,
          '归属原因',
          'CLOUD_OWNERSHIP_MISSING',
        ),
      ),
    );
    expect(await db.select(db.ledgers).get(), ledgerBefore);
    expect(await db.select(db.categories).get(), categoriesBefore);
    expect(await db.select(db.transactions).get(), transactionsBefore);
    expect(await db.select(db.syncChanges).get(), queueBefore);
  });
}
