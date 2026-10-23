import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _ledger = '20000000-0000-4000-8000-000000000001';
const _entity = '30000000-0000-4000-8000-000000000001';
final _stamp = DateTime.utc(2026, 10, 11, 1, 2, 3, 980);

/// 真实 Dio 请求和生成 SDK 经过生产期限边界，断网不写分类归属或变更冻结身份。
class _NetworkAdapter implements HttpClientAdapter {
  _NetworkAdapter({this.offline = false});
  final bool offline;
  final List<RequestOptions> calls = [];
  int cancelled = 0;

  /// 断网立即失败；慢传输只有收到取消后才结束，不使用测试侧 Future.timeout 代替取消。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline fixture',
      );
    }
    final waiting = Completer<ResponseBody>();
    unawaited(
      cancelFuture?.then((_) {
        cancelled++;
        if (!waiting.isCompleted) {
          waiting.complete(ResponseBody.fromString('{}', 200));
        }
      }),
    );
    return waiting.future;
  }

  /// 请求期限已经接管未完成资源，本夹具没有其他外部连接。
  @override
  void close({bool force = false}) {}
}

/// 验证首次未知归属有限等待及结果未知请求原样保留，不通过错误恢复重建 UUID。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late SyncService service;
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'http://deadline.test'),
        ),
        apiRequestDeadlineProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    service = SyncService(
      client: container.read(apiClientProvider),
      db: db,
      deviceId: 'network-device',
      currentAccountIdGetter: () => _account,
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledger,
            name: '已绑定旧账本',
            updatedAt: _stamp,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            syncId: const d.Value('40000000-0000-4000-8000-000000000001'),
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: _entity,
            ledgerId: const d.Value(_ledger),
            action: 'upsert',
            payload: jsonEncode({
              'tx_type': 'expense',
              'amount': '10',
              'native_amount': '10',
              'currency_code': 'CNY',
              'happened_at': _stamp.toIso8601String(),
              'updated_at': _stamp.toIso8601String(),
              'category_id': null,
              'note': '保留正文',
              'splits': null,
            }),
            accountId: const d.Value(_account),
            mutationId: '50000000-0000-4000-8000-000000000001',
            updatedAt: _stamp,
            baseRevision: const d.Value(7),
          ),
        );
  });
  tearDown(() async {
    service.client.dio.close(force: true);
    container.dispose();
    await db.close();
  });

  for (final offline in [true, false]) {
    test('首次未知Owner在${offline ? '断网' : '慢请求'}时结束本轮，不写归属或自动循环请求', () async {
      final adapter = _NetworkAdapter(offline: offline);
      service.client.dio.httpClientAdapter = adapter;
      final ledgerBefore = await db.select(db.ledgers).getSingle();
      final queueBefore = await db.select(db.syncChanges).getSingle();
      await expectLater(
        service.push(),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            '网络原因',
            offline
                ? DioExceptionType.connectionError
                : DioExceptionType.receiveTimeout,
          ),
        ),
      );
      expect(adapter.calls, hasLength(1));
      expect(adapter.calls.single.path, endsWith('/ledgers/$_ledger'));
      expect(adapter.cancelled, offline ? 0 : 1);
      expect(await db.select(db.ledgers).getSingle(), ledgerBefore);
      expect(await db.select(db.syncChanges).getSingle(), queueBefore);
      expect(await db.select(db.categories).get(), isEmpty);
    });
  }

  test('已经发出的冻结请求超时后原entity、mutation、正文和幂等字节保持不变', () async {
    await (db.update(db.ledgers)..where((l) => l.id.equals(_ledger))).write(
      const LedgersCompanion(ownerAccountId: d.Value(_account)),
    );
    final original = await db.select(db.syncChanges).getSingle();
    final frozen = (await service.pushCoordinator.freezePending(
      original,
      _account,
    ))!;
    final adapter = _NetworkAdapter();
    service.client.dio.httpClientAdapter = adapter;
    await expectLater(
      service.push(),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          '网络原因',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
    expect(adapter.calls, hasLength(1));
    expect(adapter.calls.single.path, endsWith('/sync/push'));
    expect(adapter.cancelled, 1);
    expect(await db.select(db.syncChanges).getSingle(), frozen);
    expect(frozen.entityId, _entity);
    expect(frozen.mutationId, original.mutationId);
    expect(frozen.payload, original.payload);
    expect(frozen.frozenRequest, isNotNull);
  });

  for (final offline in [true, false]) {
    test('多个账本${offline ? '断网' : '慢网络'}时仅等待一次连接期限，所有原请求保留', () async {
      try {
        const secondLedger = '20000000-0000-4000-8000-000000000002';
        await (db.update(db.ledgers)..where((row) => row.id.equals(_ledger)))
            .write(const LedgersCompanion(ownerAccountId: d.Value(_account)));
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: secondLedger,
                name: '第二账本',
                updatedAt: _stamp,
                storageMode: const d.Value('cloud'),
                scopeAccountId: const d.Value(_account),
                ownerAccountId: const d.Value(_account),
                syncId: const d.Value('40000000-0000-4000-8000-000000000002'),
              ),
            );
        final original = await db.select(db.syncChanges).getSingle();
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'transaction',
                entityId: '30000000-0000-4000-8000-000000000002',
                ledgerId: const d.Value(secondLedger),
                action: 'upsert',
                payload: original.payload,
                accountId: const d.Value(_account),
                updatedAt: _stamp,
                mutationId: '50000000-0000-4000-8000-000000000002',
                baseRevision: const d.Value(9),
              ),
            );
        for (final change in await db.select(db.syncChanges).get()) {
          await service.pushCoordinator.freezePending(change, _account);
        }
        final before = await db.select(db.syncChanges).get();
        final adapter = _NetworkAdapter(offline: offline);
        service.client.dio.httpClientAdapter = adapter;
        await expectLater(service.push(), throwsA(isA<DioException>()));
        expect(adapter.calls, hasLength(1), reason: '连接不可用后其他账本不能重复等待同一网络期限');
        expect(adapter.calls.single.path, endsWith('/sync/push'));
        expect(adapter.cancelled, offline ? 0 : 1);
        expect(await db.select(db.syncChanges).get(), before);
        expect(await db.select(db.categories).get(), isEmpty);
      } catch (error) {
        // 原始异常由测试框架输出，资源在统一 tearDown 中释放。
        rethrow;
      }
    });
  }
}
