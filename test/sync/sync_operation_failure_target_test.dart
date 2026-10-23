import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _category = '20000000-0000-4000-8000-000000000001';
const _mutation = '30000000-0000-4000-8000-000000000001';

/// 记录真实传输边界，准备失败不能误报为服务器已拒收。
class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;

  /// 请求不连接外部网络；测试只允许在准备成功后到达传输边界。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString('{}', 200);
  }

  /// 夹具没有外部连接或定时器。
  @override
  void close({bool force = false}) {}
}

/// 同一待同步记录的时间或冻结协议异常携带原身份，界面可定位而不改写原请求。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncService service;
  late _CountingAdapter adapter;
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient(basePathOverride: 'http://wire.test');
    adapter = _CountingAdapter();
    client.dio.httpClientAdapter = adapter;
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'wire-device',
      currentAccountIdGetter: () => _account,
    );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 固定完整原请求，使用实际发送协调器检验不可改写身份和范围的边界。
  Future<SyncChange> frozenChange(
    Map<String, dynamic> overrides, {
    String? ledgerId,
  }) async {
    final timestamp = DateTime.utc(2026, 10, 12, 6, 17, 0, 947);
    final type = ledgerId == null ? 'category' : 'transaction';
    final payload = ledgerId == null
        ? <String, dynamic>{
            'name': '订阅服务',
            'kind': 'expense',
            'level': '1',
            'sort_order': 0,
            'parent_id': null,
            'icon': null,
          }
        : <String, dynamic>{
            'tx_type': 'expense',
            'amount': '88',
            'native_amount': '88',
            'currency_code': 'CNY',
            'happened_at': timestamp.toIso8601String(),
            'category_id': null,
          };
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: type,
            entityId: _category,
            ledgerId: d.Value(ledgerId),
            accountId: const d.Value(_account),
            action: 'upsert',
            payload: jsonEncode(payload),
            updatedAt: timestamp,
            mutationId: _mutation,
            frozenRequest: d.Value(
              jsonEncode({
                'mutation_id': _mutation,
                'entity_type': type,
                'entity_id': _category,
                'action': 'upsert',
                'ledger_id': ledgerId,
                'updated_at': timestamp.toIso8601String(),
                'payload': payload,
                ...overrides,
              }),
            ),
          ),
        );
    return db.select(db.syncChanges).getSingle();
  }

  for (final parentKey in [
    'ledger_id',
    'day_book_id',
    'memo_book_id',
    'fitness_space_id',
  ]) {
    test('未知冻结请求携带异域 $parentKey 时零HTTP且原请求不被重新绑定', () async {
      try {
        final before = await frozenChange({
          parentKey: '40000000-0000-4000-8000-000000000001',
        });
        await expectLater(
          service.push(),
          throwsA(
            isA<SyncOperationFailure>()
                .having(
                  (error) => error.code,
                  '原因',
                  'SYNC_FROZEN_REQUEST_INVALID',
                )
                .having(
                  (error) => error.target,
                  '原实体',
                  const SyncTarget('category', _category),
                ),
          ),
        );
        expect(adapter.calls, 0);
        expect(await db.select(db.syncChanges).getSingle(), before);
      } catch (error, stack) {
        logger.error(
          'SyncFailureTargetTest',
          '冻结请求异域父范围校验失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });
  }

  test('冻结请求不能从原账本A悄然发送到同账号账本B', () async {
    try {
      const ledger = '40000000-0000-4000-8000-000000000001';
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledger,
              name: '原账本A',
              updatedAt: DateTime.utc(2026, 10, 12),
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value(_account),
              ownerAccountId: const d.Value(_account),
              syncId: const d.Value('50000000-0000-4000-8000-000000000001'),
            ),
          );
      final before = await frozenChange({
        'ledger_id': '40000000-0000-4000-8000-000000000002',
      }, ledgerId: ledger);
      await expectLater(
        service.push(),
        throwsA(
          isA<SyncOperationFailure>()
              .having(
                (error) => error.code,
                '原因',
                'SYNC_FROZEN_REQUEST_INVALID',
              )
              .having(
                (error) => error.target,
                '原记录及账本',
                const SyncTarget('transaction', _category, parentId: ledger),
              ),
        ),
      );
      expect(adapter.calls, 0);
      expect(await db.select(db.syncChanges).getSingle(), before);
    } catch (error, stack) {
      logger.error(
        'SyncFailureTargetTest',
        '冻结交易账本归属校验失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  });

  for (final invalidTimestamp in [
    '2026-10-12T06:17:00.947',
    '2026-02-30T06:17:00.947Z',
    '0000-10-12T06:17:00Z',
  ]) {
    test('冻结时间 $invalidTimestamp 不猜设备时区或归一化日期，零HTTP并保留原字节', () async {
      try {
        final before = await frozenChange({'updated_at': invalidTimestamp});
        await expectLater(
          service.push(),
          throwsA(
            isA<SyncOperationFailure>()
                .having(
                  (error) => error.code,
                  '原因',
                  'SYNC_FROZEN_REQUEST_INVALID',
                )
                .having(
                  (error) => error.message,
                  '安全处理入口',
                  isNot(contains('编辑')),
                ),
          ),
        );
        expect(adapter.calls, 0);
        expect(await db.select(db.syncChanges).getSingle(), before);
      } catch (error, stack) {
        logger.error(
          'SyncFailureTargetTest',
          '冻结请求无效时间校验失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });
  }

  for (final blockedScope in ['local', 'other_account', 'stale']) {
    test('账本根请求以自身定位检查 $blockedScope，空父列也不能绕过账号或本机保护', () async {
      try {
        final timestamp = DateTime.utc(2026, 10, 12);
        final payload = {
          'name': '原账本',
          'currency': 'CNY',
          'month_start_day': 1,
          'aa_enabled': false,
        };
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: _category,
                name: '原账本',
                updatedAt: timestamp,
                storageMode: d.Value(
                  blockedScope == 'local' ? 'local' : 'cloud',
                ),
                scopeAccountId: d.Value(
                  blockedScope == 'other_account' ? 'other' : _account,
                ),
                ownerAccountId: const d.Value(_account),
                bindingStatus: d.Value(
                  blockedScope == 'stale' ? 'stale' : null,
                ),
              ),
            );
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'ledger',
                entityId: _category,
                accountId: const d.Value(_account),
                action: 'upsert',
                payload: jsonEncode(payload),
                updatedAt: timestamp,
                mutationId: _mutation,
                frozenRequest: d.Value(
                  jsonEncode({
                    'mutation_id': _mutation,
                    'entity_type': 'ledger',
                    'entity_id': _category,
                    'ledger_id': _category,
                    'action': 'upsert',
                    'updated_at': timestamp.toIso8601String(),
                    'payload': payload,
                  }),
                ),
              ),
            );
        final before = await db.select(db.syncChanges).getSingle();
        await service.push();
        expect(adapter.calls, 0);
        expect(await db.select(db.syncChanges).getSingle(), before);
        expect((await db.select(db.ledgers).getSingle()).name, '原账本');
      } catch (error, stack) {
        logger.error(
          'SyncFailureTargetTest',
          '账本根账号与保护范围验证失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });
  }

  for (final frozen in [false, true]) {
    test('${frozen ? '未知冻结请求时间' : '待同步编辑时间'}无效时保留实体定位和全部原队列，零HTTP', () async {
      final payload = jsonEncode({
        'name': '餐饮',
        'kind': 'expense',
        'level': '1',
        'sort_order': 0,
        'parent_id': null,
        'icon': null,
      });
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: _category,
              action: 'upsert',
              payload: payload,
              updatedAt: frozen ? DateTime.utc(2026) : DateTime.utc(10000),
              mutationId: _mutation,
              accountId: const d.Value(_account),
              frozenRequest: d.Value(
                frozen
                    ? jsonEncode({
                        'mutation_id': _mutation,
                        'entity_type': 'category',
                        'entity_id': _category,
                        'action': 'upsert',
                        'updated_at': 'PRIVATE_INVALID_TIMESTAMP',
                        'payload': jsonDecode(payload),
                      })
                    : null,
              ),
            ),
          );
      final before = await db.select(db.syncChanges).getSingle();
      await expectLater(
        service.push(),
        throwsA(
          isA<SyncOperationFailure>()
              .having(
                (error) => error.code,
                '原因',
                frozen
                    ? 'SYNC_FROZEN_REQUEST_INVALID'
                    : 'SYNC_EDIT_TIME_INVALID',
              )
              .having(
                (error) => error.target,
                '原实体',
                const SyncTarget('category', _category),
              )
              .having(
                (error) => error.message,
                '安全提示',
                isNot(contains('PRIVATE_INVALID_TIMESTAMP')),
              ),
        ),
      );
      expect(adapter.calls, 0);
      expect(await db.select(db.syncChanges).getSingle(), before);
      expect(before.entityId, _category);
      expect(before.mutationId, _mutation);
      expect(before.rejectionReason, isNull);
    });
  }
}
