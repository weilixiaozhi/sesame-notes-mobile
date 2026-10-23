import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_exchange_rate_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/utils/exchange_rate_id.dart';

import '../helpers/ledger_sync_fixture.dart';
import '../helpers/test_isolation.dart';

const _account = 'd2471ee2-767a-49a7-ab02-639201999140';
const _ledgerId = 'ff7ac6a2-2d7b-4a81-abd8-11878205dd84';
const _ruleId = '6e5b77c7-76d7-407b-aae5-abfa3b304bce';
const _binding = 'b98bbd02-de41-43b5-b73e-bdc86c743107';
const _entities = ['ledger', 'exchange_rate_override', 'recurring_transaction'];

/// 先生成成功响应再模拟丢回执，验证客户端只能重发已冻结的原始命令。
class _ReplyLossFixture extends LedgerSyncFixture {
  _ReplyLossFixture(super.db, super.account) : super(localSelfId: _localSelfId);

  bool loseNextReply = false;

  /// 完整快照中的权威时间独立于本机数据库，覆盖先下载再编辑的版本链。
  DateTime? observedRemoteTime;

  /// 测试安装身份与账号无关，避免靠换设备解决同一设备的 LWW 碰撞。
  static Future<String> _localSelfId() async => 'lww-test-self';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = await super.fetch(options, requestStream, cancelFuture);
    if (options.path.endsWith('/sync/full') && observedRemoteTime != null) {
      try {
        final body =
            jsonDecode(await utf8.decodeStream(response.stream)) as Map;
        final timestamp = observedRemoteTime!.toIso8601String();
        (body['ledger'] as Map)['updated_at'] = timestamp;
        for (final recurring in body['recurring_transactions'] as List) {
          (recurring as Map)['updated_at'] = timestamp;
        }
        body['exchange_rate_overrides'] = [
          {
            'id': exchangeRateOverrideId(_account, 'USD', 'CNY'),
            'base_currency': 'USD',
            'quote_currency': 'CNY',
            'rate': '7.123456789123456789',
            'updated_at': timestamp,
          },
        ];
        return ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: response.headers,
        );
      } catch (error, stackTrace) {
        logger.error('LwwPrecisionTest', '构造权威时间快照失败', error, stackTrace);
        rethrow;
      }
    }
    if (options.path.endsWith('/sync/push') && loseNextReply) {
      loseNextReply = false;
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return response;
  }
}

/// 记录真实 SQLite、outbox 冻结和生成 SDK 之间的版本时间，不使用手写 HTTP DTO。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _ReplyLossFixture fixture;
  late ChangeRecorderImpl tracker;
  late LocalRepository repo;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    tracker = ChangeRecorderImpl(db, accountIdGetter: () => _account);
    repo = LocalRepository(
      db,
      accountIdGetter: () => _account,
      changeTracker: tracker,
    );
    fixture = _ReplyLossFixture(db, _account);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledgerId,
            name: '已有云账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            ownerAccountId: const d.Value(_account),
            syncId: const d.Value(_binding),
            updatedAt: DateTime.utc(2024),
          ),
        );
  });
  tearDown(() async {
    fixture.client.dio.close(force: true);
    await db.close();
  });

  /// 三类实体使用稳定业务身份，汇率沿用正式账号与币对派生规则。
  String entityId(String entity) => switch (entity) {
    'ledger' => _ledgerId,
    'exchange_rate_override' => exchangeRateOverrideId(_account, 'USD', 'CNY'),
    'recurring_transaction' => _ruleId,
    _ => throw StateError('未知测试实体'),
  };

  /// 构造本地持久 payload；最终 wire 只能由真实 SyncService 与生成 SDK 产生。
  String localPayload(String entity, DateTime time) {
    if (entity == 'ledger') {
      return ledgerPayload(_ledgerId, '原始账本快照', 'CNY', 1, false, time);
    }
    if (entity == 'exchange_rate_override') {
      return jsonEncode({
        'id': entityId(entity),
        'base_currency': 'USD',
        'quote_currency': 'CNY',
        'rate': '7.123456789123456789',
        'updated_at': time.toIso8601String(),
      });
    }
    return recurringTransactionPayload(
      RecurringTransaction(
        id: _ruleId,
        ledgerId: _ledgerId,
        txType: 'expense',
        amount: '12.1234567891',
        currencyCode: 'CNY',
        frequency: 'monthly',
        protocolVersion: 1,
        timeZone: 'Asia/Shanghai',
        interval: 1,
        dayOfMonth: 1,
        startDate: DateTime.utc(2024),
        enabled: false,
        createdAt: DateTime.utc(2024),
        updatedAt: time,
      ),
    );
  }

  /// 通过正式登记器落队列，确保断言包含 SQLite UTC 毫秒列的真实往返。
  Future<void> enqueue(
    String entity,
    DateTime time, {
    String action = 'upsert',
    String? payload,
  }) async {
    if (entity == 'exchange_rate_override') {
      await tracker.recordUserGlobalChange(
        entityType: entity,
        entityId: entityId(entity),
        action: action,
        payload: payload ?? localPayload(entity, time),
        updatedAt: time,
      );
    } else {
      await tracker.recordLedgerChange(
        entityType: entity,
        entityId: entityId(entity),
        ledgerId: _ledgerId,
        action: action,
        payload: payload ?? localPayload(entity, time),
        updatedAt: time,
      );
    }
  }

  /// 验证真实发送时间严格前进且以毫秒计，不通过累加整秒越过服务端容差。
  void expectIncreasingTimes(
    List<Map<String, dynamic>> changes,
    DateTime started,
  ) {
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
        reason: '同设备同实体后继修改必须严格晚于前一条版本',
      );
    }
    expect(
      times.last,
      lessThan(started.add(const Duration(seconds: 5)).millisecondsSinceEpoch),
      reason: '毫秒推进不能退化为每次增加整秒',
    );
  }

  for (final entity in _entities) {
    for (final action in ['upsert', 'delete']) {
      test('$entity $action 首次冻结保留队列毫秒并规范化微秒', () async {
        final precise = DateTime.utc(2026, 9, 1, 2, 3, 4, 789, 654);
        await enqueue(entity, precise, action: action);
        final stored = await db.select(db.syncChanges).getSingle();
        expect(stored.updatedAt.isUtc, isTrue);
        expect(stored.updatedAt.millisecond, 789);
        expect(stored.updatedAt.microsecond, 0);
        expect(
          stored.updatedAt.millisecondsSinceEpoch,
          precise.millisecondsSinceEpoch,
        );
        await fixture.service.push();
        final request = fixture.requests.single;
        expect(request['entity_id'], entityId(entity));
        expect(request['mutation_id'], stored.mutationId);
        expect(request['action'], action);
        expect(request['updated_at'], '2026-09-01T02:03:04.789Z');
      });
    }

    test('$entity 历史快照的 epoch 原样发送，不在发送或登记时换成当前时间', () async {
      final historical = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      await enqueue(entity, historical);
      await fixture.service.push();
      expect(fixture.requests.single['updated_at'], '1970-01-01T00:00:00.000Z');
    });

    test('$entity 正文缺少冗余时间仍按历史队列时刻上传，身份与业务内容不变', () async {
      try {
        final historical = DateTime.utc(2024, 2, 3, 4, 5, 6, 947, 654);
        final payload =
            jsonDecode(localPayload(entity, historical))
                as Map<String, dynamic>;
        payload.remove('updated_at');
        final originalPayload = jsonEncode(payload);
        await enqueue(entity, historical, payload: originalPayload);
        final before = await db.select(db.syncChanges).getSingle();
        expect(before.payload, originalPayload);
        await fixture.service.push();
        final request = fixture.requests.single;
        expect(request['entity_type'], entity);
        expect(request['entity_id'], before.entityId);
        expect(request['mutation_id'], before.mutationId);
        expect(request['updated_at'], '2024-02-03T04:05:06.947Z');
        final businessPayload = Map<String, dynamic>.from(payload)
          ..remove('id')
          ..remove('role')
          ..remove('member_count');
        final sentPayload = request['payload'] as Map;
        for (final entry in businessPayload.entries) {
          expect(
            sentPayload[entry.key],
            entry.value,
            reason: '业务字段 ${entry.key} 保留',
          );
        }
        final after = await db.select(db.syncChanges).getSingle();
        expect(after.entityId, before.entityId);
        expect(after.mutationId, before.mutationId);
        expect(after.updatedAt, before.updatedAt);
        expect(after.pushedAt, isNotNull);
        expect(after.rejectionReason, isNull);
      } catch (error, stack) {
        logger.error(
          'LwwPrecisionTest',
          '队列权威时间上传回归失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });

    test('$entity 提交后丢回执重试保持同一 mutation、版本及完整 payload', () async {
      final precise = DateTime.utc(2026, 9, 1, 2, 3, 4, 321, 987);
      await enqueue(entity, precise);
      fixture.loseNextReply = true;
      await expectLater(fixture.service.push(), throwsA(isA<DioException>()));
      final frozen = await db.select(db.syncChanges).getSingle();
      expect(frozen.pushedAt, isNull);
      expect(frozen.frozenRequest, isNotNull);
      final first = jsonEncode(fixture.requests.single);
      // 即使未冻结的本地说明字段后来被修正，未知回执仍只能重放完整 wire。
      final changed = jsonDecode(frozen.payload) as Map<String, dynamic>;
      changed['updated_at'] = precise
          .add(const Duration(days: 1))
          .toIso8601String();
      await (db.update(db.syncChanges)
            ..where((row) => row.id.equals(frozen.id)))
          .write(SyncChangesCompanion(payload: d.Value(jsonEncode(changed))));
      await fixture.service.push();
      expect(fixture.requests, hasLength(2));
      expect(jsonEncode(fixture.requests.last), first);
      expect(fixture.requests.last['updated_at'], '2026-09-01T02:03:04.321Z');
      expect(fixture.requests.last['mutation_id'], frozen.mutationId);
    });
  }

  test('账本100次真实人工编辑在生成请求中保持严格毫秒顺序', () async {
    final started = DateTime.now().toUtc();
    for (var index = 0; index < 100; index++) {
      await repo.updateLedger(id: _ledgerId, name: '账本改名$index');
    }
    await fixture.service.push();
    final changes = fixture.requests
        .where((row) => row['entity_type'] == 'ledger')
        .toList();
    expect(changes, hasLength(100));
    expectIncreasingTimes(changes, started);
    expect((changes.last['payload'] as Map)['name'], '账本改名99');
  });

  for (final entity in _entities) {
    test('$entity 完整快照及回执后编辑始终晚于已观察的毫秒版本', () async {
      try {
        final observed = DateTime.now().toUtc().add(const Duration(seconds: 2));
        fixture.observedRemoteTime = observed;
        await db
            .into(db.recurringTransactions)
            .insert(
              RecurringTransactionsCompanion.insert(
                id: _ruleId,
                ledgerId: _ledgerId,
                txType: 'expense',
                amount: '12.1234567891',
                currencyCode: 'USD',
                frequency: 'monthly',
                timeZone: const d.Value('Asia/Shanghai'),
                startDate: DateTime.utc(2024),
                enabled: const d.Value(false),
                updatedAt: DateTime.utc(2024),
              ),
            );
        await fixture.service.full(ledgerId: _ledgerId);
        expect(await db.select(db.syncChanges).get(), isEmpty);

        /// 读取真实投影列，不从请求或测试缓存代替数据库版本。
        Future<DateTime> storedVersion() async => switch (entity) {
          'ledger' => (await db.select(db.ledgers).getSingle()).updatedAt,
          'recurring_transaction' =>
            (await db.select(db.recurringTransactions).getSingle()).updatedAt,
          'exchange_rate_override' =>
            (await db.select(db.exchangeRateOverrides).getSingle()).updatedAt,
          _ => throw StateError('未知测试实体'),
        };

        /// 每轮执行正式仓储更新，让冻结请求与下一轮实体基线经历完整往返。
        Future<void> edit(int index) async {
          if (entity == 'ledger') {
            await repo.updateLedger(id: _ledgerId, name: '快照后编辑$index');
          } else if (entity == 'recurring_transaction') {
            await repo.toggleRecurringTransaction(_ruleId, index.isOdd);
          } else {
            await repo.setOverride(
              base: 'USD',
              quote: 'CNY',
              rate: '7.123456789123456789',
            );
          }
        }

        expect(
          (await storedVersion()).millisecondsSinceEpoch,
          observed.millisecondsSinceEpoch,
          reason: '已观察的云端版本必须在SQLite往返后保留毫秒',
        );
        var previous = observed;
        for (var index = 0; index < 3; index++) {
          if (index == 2) {
            // 已确认诊断历史可被压缩；后继时间必须仍由实体列保证。
            await db.delete(db.syncChanges).go();
          }
          await edit(index);
          final pending =
              await (db.select(db.syncChanges)..where(
                    (row) =>
                        row.entityType.equals(entity) & row.pushedAt.isNull(),
                  ))
                  .getSingle();
          expect(
            pending.updatedAt.isAfter(previous),
            isTrue,
            reason: '后继编辑必须晚于远端或上一条已确认版本',
          );
          expect(
            (await storedVersion()).millisecondsSinceEpoch,
            pending.updatedAt.millisecondsSinceEpoch,
          );
          await fixture.service.push();
          final sent = fixture.requests.lastWhere(
            (row) => row['entity_type'] == entity,
          );
          expect(
            DateTime.parse(sent['updated_at'] as String).millisecondsSinceEpoch,
            pending.updatedAt.millisecondsSinceEpoch,
          );
          previous = pending.updatedAt;
          expect(
            await (db.select(
              db.syncChanges,
            )..where((row) => row.pushedAt.isNull())).get(),
            isEmpty,
          );
        }
      } catch (error, stackTrace) {
        logger.error('LwwPrecisionTest', '快照与回执后的编辑版本回归失败', error, stackTrace);
        rethrow;
      }
    });
  }

  test('汇率100次真实修改及删除不丢毫秒，金额精度不受版本修复影响', () async {
    final rates = LocalExchangeRateRepository(
      db,
      trackerGetter: () => tracker,
      accountIdGetter: () => _account,
    );
    final started = DateTime.now().toUtc();
    for (var index = 0; index < 100; index++) {
      await rates.setOverride(
        base: 'USD',
        quote: 'CNY',
        rate: '7.${100000000000000001 + index * 10}',
      );
    }
    await rates.removeOverride(base: 'USD', quote: 'CNY');
    await fixture.service.push();
    final changes = fixture.requests
        .where((row) => row['entity_type'] == 'exchange_rate_override')
        .toList();
    expect(changes, hasLength(101));
    expectIncreasingTimes(changes, started);
    expect((changes[99]['payload'] as Map)['rate'], '7.100000000000000991');
    expect(changes.last['action'], 'delete');
  });

  test('周期创建、100次修改、暂停及删除沿用真实编辑时钟并保持排期', () async {
    final started = DateTime.now().toUtc();
    final id = await repo.addRecurringTransaction(
      ledgerId: _ledgerId,
      type: 'expense',
      amount: '12.1234567891',
      currencyCode: 'USD',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 1,
      timeZone: 'Asia/Shanghai',
      startDate: DateTime.utc(2024),
    );
    for (var index = 0; index < 100; index++) {
      await repo.updateRecurringTransaction(
        id: id,
        ledgerId: _ledgerId,
        type: 'expense',
        amount: '12.1234567891',
        note: '排期备注$index',
        frequency: 'monthly',
        interval: 1,
        dayOfMonth: 1,
        timeZone: 'Asia/Shanghai',
        startDate: DateTime.utc(2024),
      );
    }
    await repo.toggleRecurringTransaction(id, false);
    await repo.deleteRecurringTransaction(id);
    await fixture.service.push();
    final changes = fixture.requests
        .where((row) => row['entity_id'] == id)
        .toList();
    expect(changes, hasLength(103));
    expectIncreasingTimes(changes, started);
    final paused = changes[101]['payload'] as Map;
    expect(paused['enabled'], false);
    expect(paused['amount'], '12.1234567891');
    expect(paused['currency_code'], 'USD');
    expect(paused['time_zone'], 'Asia/Shanghai');
    expect(paused['start_date'], '2024-01-01T00:00:00.000Z');
    expect(paused['last_generated_date'], isNull);
    expect(changes.last['action'], 'delete');
  });
}
