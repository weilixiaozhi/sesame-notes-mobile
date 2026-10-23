import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/infrastructure/api/api_interceptors.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

const _account = 'd2471ee2-767a-49a7-ab02-639201999140';
const _ledger = 'ff7ac6a2-2d7b-4a81-abd8-11878205dd84';
const _rule = '6e5b77c7-76d7-407b-aae5-abfa3b304bce';
const _mutation = '69a028c4-d3cb-4523-80ba-ed575312f053';
const _binding = 'b98bbd02-de41-43b5-b73e-bdc86c743107';
const _updated = '2024-01-02T03:04:05.321Z';

/// 通过真实 Dio 请求字节验证新规则元数据和旧冻结请求使用各自正确的发送边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncService service;
  late _FrozenWireAdapter adapter;
  late Map<String, dynamic> payload;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient(basePathOverride: 'https://recurring.test');
    adapter = _FrozenWireAdapter();
    adapter.loadPending = () => db.select(db.syncChanges).get();
    client.dio.httpClientAdapter = adapter;
    client.setBearerAuth('bearerAuth', 'first-access');
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'device-1',
      currentAccountIdGetter: () => _account,
    );
    try {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: _ledger,
              name: '周期账本',
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value(_account),
              ownerAccountId: const d.Value(_account),
              syncId: const d.Value(_binding),
              updatedAt: DateTime.parse(_updated),
            ),
          );
      await db
          .into(db.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              id: _rule,
              ledgerId: _ledger,
              txType: 'expense',
              amount: '12.00',
              currencyCode: 'CNY',
              frequency: 'daily',
              timeZone: const d.Value('Asia/Shanghai'),
              startDate: DateTime.utc(2024, 1, 1),
              lastGeneratedDate: d.Value(DateTime.utc(2024, 1, 2)),
              updatedAt: DateTime.parse(_updated),
            ),
          );
      final rule = await db.select(db.recurringTransactions).getSingle();
      payload =
          jsonDecode(recurringTransactionPayload(rule)) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      logger.error('FrozenWireTest', '周期同步测试初始化失败', error, stackTrace);
      rethrow;
    }
  });

  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 保存真实 outbox 行，冻结请求可选；不会用 API 测试替身绕过生产网络路径。
  Future<void> enqueue({
    Map<String, dynamic>? localPayload,
    String? frozen,
    String ruleId = _rule,
    String mutationId = _mutation,
  }) async {
    try {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'recurring_transaction',
              entityId: ruleId,
              accountId: const d.Value(_account),
              ledgerId: const d.Value(_ledger),
              action: 'upsert',
              payload: jsonEncode(localPayload ?? payload),
              updatedAt: DateTime.parse(_updated),
              mutationId: mutationId,
              frozenRequest: d.Value(frozen),
            ),
          );
    } catch (error, stackTrace) {
      logger.error('FrozenWireTest', '周期待同步夹具保存失败', error, stackTrace);
      rethrow;
    }
  }

  test('新规则请求没有顶层生成日期，数据库进度保留', () async {
    expect(payload.containsKey('last_generated_date'), isFalse);
    await enqueue();
    await service.push();
    final change = adapter.changes.single;
    expect(
      (change['payload'] as Map).containsKey('last_generated_date'),
      isFalse,
    );
    final stored = adapter.pendingBeforeReply.single;
    expect(
      (jsonDecode(stored.frozenRequest!)['payload'] as Map).containsKey(
        'last_generated_date',
      ),
      isFalse,
    );
    final rule = await db.select(db.recurringTransactions).getSingle();
    expect(rule.lastGeneratedDate?.toUtc(), DateTime.utc(2024, 1, 2));
    expect(adapter.authorizations.single, 'Bearer first-access');
    expect(adapter.contentTypes.single, Headers.jsonContentType);
  });

  test('初始历史日期保留，未冻结旧载荷的顶层日期只在发送副本移除', () async {
    const initial = {
      'last_generated_date': null,
      'deleted_at': null,
      'occurrences': [],
    };
    final original = {
      ...payload,
      'last_generated_date': '2024-01-02T00:00:00.000Z',
      'initial_state': initial,
    };
    await enqueue(localPayload: original);
    await service.push();
    final sent = adapter.changes.single['payload'] as Map;
    expect(sent.containsKey('last_generated_date'), isFalse);
    expect(sent['initial_state'], initial);
    final stored = adapter.pendingBeforeReply.single;
    expect(jsonDecode(stored.payload), original);
  });

  for (final oldDate in [null, '2024-01-02T00:00:00.000Z']) {
    test('旧冻结日期为 $oldDate 时丢回执和限流重试保持完整正文与指纹', () async {
      final original = _frozenChange({
        ...payload,
        'last_generated_date': oldDate,
        'retired_metadata': {'value': null},
      });
      final rawOriginal = const JsonEncoder.withIndent('  ').convert(original);
      final expectedBody = '{"device_id":"device-1","changes":[$rawOriginal]}';
      final fingerprint = _fingerprint(original);
      adapter.statuses.addAll([null, 429, 200]);
      await enqueue(frozen: rawOriginal);

      await expectLater(service.push(), throwsA(isA<DioException>()));
      var stored = await db.select(db.syncChanges).getSingle();
      expect(stored.frozenRequest, rawOriginal);
      expect(stored.mutationId, _mutation);
      expect(stored.pushedAt, isNull);
      await expectLater(
        service.push(),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            '限流状态',
            429,
          ),
        ),
      );
      await service.push();

      expect(adapter.bodies, [expectedBody, expectedBody, expectedBody]);
      expect(
        adapter.changes.every((change) => _fingerprint(change) == fingerprint),
        isTrue,
      );
      stored = await db.select(db.syncChanges).getSingle();
      // 成功确认之前必须保留原冻结材料；确认后的既有队列收尾允许清理正文。
      expect(adapter.pendingBeforeReply.last.frozenRequest, rawOriginal);
      expect(stored.mutationId, _mutation);
      expect(stored.pushedAt, isNotNull);
    });
  }

  test('冻结 payload 缺少私有编辑时间时按外层时间原字节重试', () async {
    try {
      final frozenPayload = {...payload}..remove('updated_at');
      final original = _frozenChange(frozenPayload);
      final rawOriginal = const JsonEncoder.withIndent('  ').convert(original);
      final expectedBody = '{"device_id":"device-1","changes":[$rawOriginal]}';
      final fingerprint = _fingerprint(original);
      adapter.statuses.addAll([null, 200]);
      await enqueue(localPayload: frozenPayload, frozen: rawOriginal);
      await expectLater(service.push(), throwsA(isA<DioException>()));
      final before = await db.select(db.syncChanges).getSingle();
      expect(before.frozenRequest, rawOriginal);
      expect(before.payload, jsonEncode(frozenPayload));
      expect(before.pushedAt, isNull);
      await service.push();
      expect(adapter.bodies, [expectedBody, expectedBody]);
      expect(
        adapter.changes.every((change) => change['updated_at'] == _updated),
        isTrue,
      );
      expect(
        adapter.changes.every((change) => _fingerprint(change) == fingerprint),
        isTrue,
      );
      expect(adapter.pendingBeforeReply.last.frozenRequest, rawOriginal);
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
    } catch (error, stackTrace) {
      logger.error('FrozenWireTest', '冻结外层时间与原字节重试验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('认证刷新使用现有拦截器重放旧冻结正文', () async {
    final rawOriginal = const JsonEncoder.withIndent(
      '  ',
    ).convert(_frozenChange({...payload, 'last_generated_date': null}));
    var refreshes = 0;
    client.dio.interceptors.add(
      AuthRefreshInterceptor(
        dio: client.dio,
        refresh: () async {
          refreshes++;
          client.setBearerAuth('bearerAuth', 'refreshed-access');
          return 'refreshed-access';
        },
      ),
    );
    adapter.statuses.addAll([401, 200]);
    await enqueue(frozen: rawOriginal);
    await service.push();
    expect(refreshes, 1);
    expect(adapter.bodies, hasLength(2));
    expect(adapter.bodies.first, adapter.bodies.last);
    expect(adapter.bodies.first, contains(rawOriginal));
    expect(adapter.authorizations, [
      'Bearer first-access',
      'Bearer refreshed-access',
    ]);
  });

  test('损坏确认响应沿生成API包装异常，冻结队列不被确认', () async {
    adapter.responseOverride = const {'outcomes': []};
    await enqueue();
    await expectLater(
      service.push(),
      throwsA(
        isA<DioException>().having(
          (error) => error.error,
          '响应解码错误',
          isA<DeserializationError>(),
        ),
      ),
    );
    final stored = await db.select(db.syncChanges).getSingle();
    expect(stored.pushedAt, isNull);
    expect(
      stored.frozenRequest,
      adapter.pendingBeforeReply.single.frozenRequest,
    );
    expect(stored.mutationId, _mutation);
  });

  test('确认身份不匹配时拒绝回执并保留冻结队列', () async {
    adapter.responseOverride = const {
      'server_cursor': '1',
      'outcomes': [
        {
          'mutation_id': _mutation,
          'entity_id': '69b85d17-a424-4a3e-b77b-6f76f6c733ab',
          'status': 'accepted',
          'change_id': '1',
        },
      ],
    };
    await enqueue();
    await expectLater(service.push(), throwsA(isA<FormatException>()));
    final stored = await db.select(db.syncChanges).getSingle();
    expect(stored.pushedAt, isNull);
    expect(
      stored.frozenRequest,
      adapter.pendingBeforeReply.single.frozenRequest,
    );
    expect(stored.mutationId, _mutation);
  });

  test('多条旧冻结大字段按实际UTF8字节拆批，未知字段原文保留', () async {
    const secondRule = '9a904156-47e9-4fca-a562-b03903207148';
    const secondMutation = '145f803c-73c1-4ad9-bd72-ec4526596a59';
    final rule = await db.select(db.recurringTransactions).getSingle();
    await db
        .into(db.recurringTransactions)
        .insert(
          rule.toCompanion(false).copyWith(id: const d.Value(secondRule)),
        );
    // 中文一个字符占三个 UTF-8 字节，两条旧正文合计超过单次请求预算。
    final large = '旧' * 180000;
    final first = _frozenChange({...payload, 'retired_metadata': large});
    final second = {
      ...first,
      'entity_id': secondRule,
      'mutation_id': secondMutation,
    };
    final firstRaw = jsonEncode(first);
    final secondRaw = jsonEncode(second);
    expect(utf8.encode(firstRaw + secondRaw).length, greaterThan(1024 * 1024));
    await enqueue(frozen: firstRaw);
    await enqueue(
      frozen: secondRaw,
      ruleId: secondRule,
      mutationId: secondMutation,
    );
    await service.push();
    expect(adapter.changeCounts, [1, 1]);
    expect(adapter.bodies.first, contains(firstRaw));
    expect(adapter.bodies.last, contains(secondRaw));
    for (final body in adapter.bodies) {
      expect(utf8.encode(body).length, lessThanOrEqualTo(1024 * 1024));
    }
    expect(adapter.changes.map((change) => change['payload']), [
      first['payload'],
      second['payload'],
    ]);
    expect(
      (await db.select(db.syncChanges).get()).every(
        (row) => row.pushedAt != null,
      ),
      isTrue,
    );
  });
}

/// 以完整 envelope 保存旧 mutation，日期与额外字段位于原始冻结载荷中。
Map<String, dynamic> _frozenChange(Map<String, dynamic> payload) => {
  'mutation_id': _mutation,
  'entity_type': 'recurring_transaction',
  'entity_id': _rule,
  'ledger_id': _ledger,
  'sync_id': _binding,
  'action': 'upsert',
  'updated_at': _updated,
  'payload': payload,
};

/// 对账号与变更递归排序计算请求指纹，字段缺失和显式 null 必须保持不同语义。
String _fingerprint(Map<String, dynamic> change) => sha256
    .convert(
      utf8.encode(jsonEncode(_canonical({...change, 'user_id': _account}))),
    )
    .toString();

/// 对象键稳定排序，数组保留原次序，防止只比较少数字段掩盖载荷损失。
Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) return value.map(_canonical).toList();
  return value;
}

/// 读取实际 HTTP 字节并模拟提交后丢回执、限流或认证失效，全部网络仍走生产 Dio。
class _FrozenWireAdapter implements HttpClientAdapter {
  late final Future<List<SyncChange>> Function() loadPending;
  final pendingBeforeReply = <SyncChange>[];
  Map<String, Object?>? responseOverride;
  final changeCounts = <int>[];
  final statuses = <int?>[];
  final bodies = <String>[];
  final changes = <Map<String, dynamic>>[];
  final authorizations = <String?>[];
  final contentTypes = <String?>[];

  /// 用请求流记录实际发送内容，成功回执使用对应冻结 mutation 身份。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      if (options.path != '/api/v1/sync/push' || requestStream == null) {
        throw StateError('周期测试出现未预期的请求');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in requestStream) {
        bytes.add(chunk);
      }
      final body = utf8.decode(bytes.takeBytes());
      bodies.add(body);
      authorizations.add(options.headers['Authorization'] as String?);
      contentTypes.add(options.contentType);
      final decoded = jsonDecode(body) as Map;
      final batch = [
        for (final change in decoded['changes'] as List)
          Map<String, dynamic>.from(change as Map),
      ];
      changes.addAll(batch);
      changeCounts.add(batch.length);
      // 在发送字节已确定、确认尚未返回时读取队列，避免把确认后的正文清理误判为改写。
      final mutations = batch.map((change) => change['mutation_id']).toSet();
      pendingBeforeReply.addAll(
        (await loadPending()).where(
          (change) => mutations.contains(change.mutationId),
        ),
      );
      expect(options.extra['secure'], [
        {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
      ]);
      final status = statuses.isEmpty ? 200 : statuses.removeAt(0);
      if (status == null) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return ResponseBody.fromString(
        jsonEncode(
          status == 200
              ? responseOverride ??
                    {
                      'server_cursor': '1',
                      'outcomes': [
                        for (final change in batch)
                          {
                            'mutation_id': change['mutation_id'],
                            'entity_id': change['entity_id'],
                            'status': 'accepted',
                            'change_id': '1',
                            'revision': 1,
                          },
                      ],
                    }
              : {
                  'code': 'TEST_STATUS',
                  'message': '请稍后重试',
                  'request_id': 'test',
                },
        ),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    } catch (error, stackTrace) {
      logger.error(
        'FrozenWireTest',
        '周期同步网络夹具失败',
        error.runtimeType,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 测试适配器不创建真实连接，无需释放外部网络资源。
  @override
  void close({bool force = false}) {}
}
