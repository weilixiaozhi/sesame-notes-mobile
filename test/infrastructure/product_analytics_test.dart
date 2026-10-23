import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/infrastructure/analytics/product_analytics_service.dart';

int _sequence = 0;

/// 只验证队列持久化、确认重试和账号隔离；事件身份由调用端先固定。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    _sequence = 0;
    SharedPreferences.setMockInitialValues({});
  });

  test('失败补报沿用 UUID，确认后移除，原账号事件不能被新账号发送', () async {
    final preferences = await SharedPreferences.getInstance();
    var account = 'a';
    var now = DateTime.utc(2026, 10, 10);
    var fail = true;
    final batches = <List<dynamic>>[];
    final tokens = <Object?>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _Adapter((request) {
        final batch = (request.data as Map)['events'] as List;
        batches.add(jsonDecode(jsonEncode(batch)) as List);
        tokens.add(request.headers['Authorization']);
        if (fail) return ResponseBody.fromString('{}', 503);
        return _json({'accepted': batch.length, 'duplicates': 0});
      });
    final service = ProductAnalyticsService(
      dio: dio,
      preferences: preferences,
      accountId: () => account,
      accessToken: () => 'token-$account',
      identityGeneration: () => account == 'a' ? 1 : 2,
      clock: () => now,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'fitness',
    );
    await service.flush();
    expect(batches.single.single.keys, isNot(contains('user_id')));
    expect(batches.single.single['event_name'], 'fitness_view');
    account = 'b';
    service.identityChanged();
    fail = false;
    await _record(
      service,
      sessionId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
      account: 'b',
      kind: 'page_view',
      pageId: 'memos',
    );
    await service.flush();
    expect(tokens.last, 'Bearer token-b');
    expect(batches.last.single['page_id'], 'memos');
    expect(batches.last.single['event_name'], 'memos_view');
    account = 'a';
    service.identityChanged();
    now = now.add(const Duration(minutes: 1));
    await service.flush();
    expect(batches.last.single['event_id'], batches.first.single['event_id']);
    expect(
      preferences.getKeys().where((key) => key.startsWith('product_analytics')),
      isEmpty,
    );
  });

  for (final negativeField in ['accepted', 'duplicates']) {
    test('负数确认$negativeField即使总数正确也保留队列，合法重复确认才清理', () async {
      final preferences = await SharedPreferences.getInstance();
      var now = DateTime.utc(2026, 10, 13);
      final batches = <List<dynamic>>[];
      var valid = false;
      final service = ProductAnalyticsService(
        dio: Dio()
          ..httpClientAdapter = _Adapter((request) {
            final batch = (request.data as Map)['events'] as List;
            batches.add(jsonDecode(jsonEncode(batch)) as List);
            if (valid) {
              return _json({'accepted': 0, 'duplicates': batch.length});
            }
            return _json({
              'accepted': negativeField == 'accepted' ? -1 : batch.length + 1,
              'duplicates': negativeField == 'duplicates'
                  ? -1
                  : batch.length + 1,
            });
          }),
        preferences: preferences,
        accountId: () => 'a',
        accessToken: () => 'token',
        identityGeneration: () => 1,
        clock: () => now,
      );
      addTearDown(service.dispose);
      await _record(
        service,
        account: 'a',
        kind: 'page_view',
        pageId: 'fitness',
        sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      final key = preferences.getKeys().single;
      final queued = preferences.getString(key);
      await service.flush();
      expect(preferences.getString(key), queued, reason: '错误确认不能删除任何已持久化事件');
      valid = true;
      await service.flush();
      expect(batches, hasLength(1), reason: '错误确认沿用重试间隔');
      now = now.add(const Duration(seconds: 31));
      await service.flush();
      expect(batches, hasLength(2));
      expect(batches.last, batches.first, reason: '重传保留UUID、会话、顺序和发生时间');
      expect(preferences.getKeys(), isEmpty);
    });
  }

  test('永久无效批次丢弃，不阻塞后续采集', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = ProductAnalyticsService(
      dio: Dio()
        ..httpClientAdapter = _Adapter(
          (_) => ResponseBody.fromString('{}', 400),
        ),
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'active',
      pageId: 'fitness',
    );
    final queued =
        jsonDecode(preferences.getString(preferences.getKeys().single)!)
            as List;
    expect((queued.single as Map).containsKey('event_name'), isFalse);
    await service.flush();
    expect(
      preferences.getKeys().where((key) => key.startsWith('product_analytics')),
      isEmpty,
    );
  });

  test('慢网络期间新事件立即落盘，旧批确认不覆盖新事件', () async {
    final preferences = await SharedPreferences.getInstance();
    final started = Completer<void>();
    final response = Completer<ResponseBody>();
    final dio = Dio()
      ..httpClientAdapter = _Adapter((_) {
        started.complete();
        return response.future;
      });
    final service = ProductAnalyticsService(
      dio: dio,
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'fitness',
    );
    final sending = service.flush();
    await started.future;
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'memos',
    );
    final key = preferences.getKeys().singleWhere(
      (key) => key.startsWith('product_analytics'),
    );
    expect(jsonDecode(preferences.getString(key)!) as List, hasLength(2));
    response.complete(_json({'accepted': 1, 'duplicates': 0}));
    await sending;
    final remaining = jsonDecode(preferences.getString(key)!) as List;
    expect(remaining, hasLength(1));
    expect(remaining.single['page_id'], 'memos');
  });

  test('操作离线重试保留名称和UUID，正文只包含受控统计字段', () async {
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime.utc(2026, 10, 12);
    var fail = true;
    final batches = <List<dynamic>>[];
    final service = ProductAnalyticsService(
      dio: Dio()
        ..httpClientAdapter = _Adapter((request) {
          final batch = (request.data as Map)['events'] as List;
          batches.add(jsonDecode(jsonEncode(batch)) as List);
          return fail
              ? ResponseBody.fromString('{}', 503)
              : _json({'accepted': batch.length, 'duplicates': 0});
        }),
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
      clock: () => now,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'action',
      pageId: 'accounting.transaction.editor',
      eventName: ProductAction.accountingTransactionCreated.eventName,
    );
    await service.flush();
    expect(batches.single.single.keys.toSet(), {
      'event_id',
      'occurred_at',
      'kind',
      'page_id',
      'platform',
      'event_name',
      'session_id',
      'event_sequence',
    });
    fail = false;
    now = now.add(const Duration(seconds: 31));
    await service.flush();
    expect(batches.last.single, batches.first.single);
    expect(batches.last.single['event_name'], 'accounting_transaction_created');
    expect(preferences.getKeys(), isEmpty);
  });

  test('无效操作和已失效身份不进入离线队列', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = ProductAnalyticsService(
      dio: Dio(),
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 2,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'action',
      pageId: 'memos.editor',
    );
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'action',
      pageId: 'memos.editor',
      eventName: 'private_note_title',
    );
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'memos.editor',
      eventName: 'memos_note_saved',
    );
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'action',
      pageId: 'memos.editor',
      eventName: 'memos_note_saved',
      generation: 1,
    );
    expect(preferences.getKeys(), isEmpty);
  });

  test('损坏操作、缺失或错配访问标识单独过滤，未知正文不污染合法离线批次', () async {
    final preferences = await SharedPreferences.getInstance();
    final batches = <List<dynamic>>[];
    final service = ProductAnalyticsService(
      dio: Dio()
        ..httpClientAdapter = _Adapter((request) {
          final batch = (request.data as Map)['events'] as List;
          batches.add(batch);
          return _json({'accepted': batch.length, 'duplicates': 0});
        }),
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
    );
    addTearDown(service.dispose);
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'accounting.transaction.editor',
    );
    final key = preferences.getKeys().single;
    final good =
        (jsonDecode(preferences.getString(key)!) as List).single as Map;
    await preferences.setString(
      key,
      jsonEncode([
        {...good, 'body': '不应上报的业务正文'},
        {
          ...good,
          'event_id': const Uuid().v4(),
          'kind': 'action',
          'event_name': 'unknown_operation',
        },
        {
          ...good,
          'event_id': const Uuid().v4(),
          'page_id': '/path-with-private-params',
        },
        {
          for (final entry in good.entries)
            if (entry.key != 'event_name') entry.key: entry.value,
          'event_id': const Uuid().v4(),
        },
        {
          ...good,
          'event_id': const Uuid().v4(),
          'event_name': 'accounting_view',
        },
        {
          ...good,
          'event_id': const Uuid().v4(),
          'event_name': 'accounting.transaction.editor',
        },
        {...good, 'event_id': const Uuid().v4(), 'kind': 'active'},
      ]),
    );
    await service.flush();
    expect(batches.single, hasLength(1));
    expect((batches.single.single as Map).keys, isNot(contains('body')));
    expect(
      (batches.single.single as Map)['page_id'],
      'accounting.transaction.editor',
    );
    expect(
      (batches.single.single as Map)['event_name'],
      'accounting_transaction_editor_view',
    );
    expect(preferences.getKeys(), isEmpty);
  });

  test('同毫秒事件保留采集端顺序，重传与账号切换不改写原会话和序号', () async {
    final preferences = await SharedPreferences.getInstance();
    final batches = <List<dynamic>>[];
    var account = 'a';
    var generation = 1;
    var fail = true;
    var now = DateTime.utc(2026, 10, 13);
    final service = ProductAnalyticsService(
      dio: Dio()
        ..httpClientAdapter = _Adapter((request) {
          final batch = (request.data as Map)['events'] as List;
          batches.add(jsonDecode(jsonEncode(batch)) as List);
          return fail
              ? ResponseBody.fromString('{}', 503)
              : _json({'accepted': batch.length, 'duplicates': 0});
        }),
      preferences: preferences,
      accountId: () => account,
      accessToken: () => 'token',
      identityGeneration: () => generation,
      clock: () => now,
    );
    addTearDown(service.dispose);
    const sessionA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    const sessionB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
    await Future.wait([
      _record(
        service,
        account: 'a',
        kind: 'action',
        pageId: 'accounting',
        eventName: 'accounting_transaction_create_click',
        sessionId: sessionA,
        generation: 1,
      ),
      _record(
        service,
        account: 'a',
        kind: 'page_view',
        pageId: 'accounting.transaction.editor',
        sessionId: sessionA,
        generation: 1,
      ),
    ]);
    await service.flush();
    expect(batches.single.map((event) => event['event_sequence']), [1, 2]);
    expect(
      batches.single.map((event) => event['occurred_at']).toSet(),
      hasLength(1),
    );
    account = 'b';
    generation = 2;
    fail = false;
    service.identityChanged();
    await _record(
      service,
      account: 'a',
      kind: 'page_view',
      pageId: 'memos',
      sessionId: sessionA,
      generation: 1,
    );
    await _record(
      service,
      account: 'b',
      kind: 'page_view',
      pageId: 'fitness',
      sessionId: sessionB,
      generation: 2,
    );
    await service.flush();
    expect(batches.last, hasLength(1));
    expect(batches.last.single['session_id'], sessionB);
    expect(batches.last.single['event_sequence'], 4);
    account = 'a';
    generation = 3;
    now = now.add(const Duration(seconds: 31));
    service.identityChanged();
    await service.flush();
    expect(batches.last, batches.first);
    expect(preferences.getKeys(), isEmpty);
  });

  test('离线恢复保留会话与顺序，未建立操作流保持空值，损坏关联只过滤自身', () async {
    final preferences = await SharedPreferences.getInstance();
    final session = const Uuid().v4();
    final flow = const Uuid().v4();
    final batches = <List<dynamic>>[];
    var fail = true;
    var now = DateTime.utc(2026, 10, 12);
    final dio = Dio()
      ..httpClientAdapter = _Adapter((request) {
        final batch = (request.data as Map)['events'] as List;
        batches.add(jsonDecode(jsonEncode(batch)) as List);
        return fail
            ? ResponseBody.fromString('{}', 503)
            : _json({'accepted': batch.length, 'duplicates': 0});
      });

    /// 模拟进程重建，队列与会话关联必须保持原值。
    ProductAnalyticsService create() => ProductAnalyticsService(
      dio: dio,
      preferences: preferences,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
      clock: () => now,
    );
    var service = create();
    await _record(
      service,
      account: 'a',
      kind: 'action',
      pageId: 'fitness.workout',
      eventName: 'fitness_workout_started',
      sessionId: session,
      flowId: flow,
    );
    await _record(
      service,
      sessionId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      account: 'a',
      kind: 'page_view',
      pageId: 'fitness',
    );
    await service.flush();
    final key = preferences.getKeys().single;
    final queued = jsonDecode(preferences.getString(key)!) as List;
    await preferences.setString(
      key,
      jsonEncode([
        ...queued,
        {
          ...queued.first as Map,
          'event_id': const Uuid().v4(),
          'flow_id': 'business-record-id',
        },
      ]),
    );
    service.dispose();
    service = create();
    addTearDown(service.dispose);
    now = now.add(const Duration(seconds: 31));
    fail = false;
    await service.flush();
    expect(batches.last, batches.first);
    expect((batches.last.first as Map)['flow_id'], flow);
    expect((batches.last.first as Map)['session_id'], session);
    expect(
      (batches.last.last as Map)['session_id'],
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    );
    expect((batches.last.last as Map).containsKey('flow_id'), isFalse);
  });
}

/// 测试响应为协议 JSON，不请求真实网络。
ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
  jsonEncode(body),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

/// 可编排 HTTP 返回值的测试传输。
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

/// 在测试生产者边界固定事件元信息，底层队列不得重新生成时间、顺序或编号。
Future<void> _record(
  ProductAnalyticsService service, {
  required String account,
  required String kind,
  required String pageId,
  required String sessionId,
  String? eventName,
  int? generation,
  String? flowId,
}) => service.record(
  ProductAnalyticsEvent(
    eventId: const Uuid().v4(),
    occurredAt: service.clock(),
    sequence: ++_sequence,
    identity: ProductAnalyticsIdentity(
      account,
      generation ?? service.identityGeneration(),
    ),
    kind: kind,
    pageId: pageId,
    sessionId: sessionId,
    action: ProductAction.values
        .where((value) => value.eventName == eventName)
        .firstOrNull,
    flowId: flowId,
  ),
);
