import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

/// 按队列顺序返回预设响应的 Dio 适配器，并记录每个请求的完整 URI。
class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this.responses);

  final List<({int status, Object body})> responses;
  int _index = 0;
  final List<String> uris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    uris.add(options.uri.toString());
    if (responses.isEmpty) {
      throw StateError('测试未预设响应，却有请求发出: ${options.uri}');
    }
    final next =
        responses[_index < responses.length ? _index : responses.length - 1];
    _index++;
    return ResponseBody.fromString(
      jsonEncode(next.body),
      next.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// GET /ledgers 的账本条目（契约 required：role/member_count 一并携带）。
Map<String, Object> _ledgerJson(String id) => {
  'id': id,
  'owner_id': 'user-1',
  'sync_id': const Uuid().v4(),
  'name': '云端账本',
  'currency': 'CNY',
  'month_start_day': 1,
  'aa_enabled': false,
  'role': 'owner',
  'member_count': 1,
  'updated_at': '2026-09-05T10:00:00.000Z',
};

/// GET /sync/full 的账本对象（契约 required：无 role/member_count）。
Map<String, Object> _fullLedgerJson(String id) => _ledgerJson(id)
  ..remove('role')
  ..remove('member_count');

/// 验证有效云会话下恢复闸门、快照落库和尾随同步的顺序。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late _QueuedAdapter adapter;
  late ProviderContainer container;
  late String ledgerId;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    adapter = _QueuedAdapter([]);
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    final client = SesameApiClient(dio: dio);
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'http://test.local'),
        ),
        apiClientProvider.overrideWithValue(client),
        databaseProvider.overrideWithValue(db),
        // 同步闸门用例建立已恢复的账号身份，避免进入未登录的本机模式。
        accountStateProvider.overrideWithBuild(
          (_, _) => const AccountState(
            status: AccountStatus.authenticated,
            credentialUserId: 'user-1',
          ),
        ),
        syncServiceProvider.overrideWithValue(
          SyncService(
            client: client,
            db: db,
            deviceId: 'dev-1',
            repo: LocalLedgerRepository(db),
            localSelfIdLoader: () async => 'local-self',
            currentAccountIdGetter: () => 'user-1',
          ),
        ),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'test-token',
            userId: 'user-1',
            deviceId: 'dev-1',
          ),
        );
    ledgerId = const Uuid().v4();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('恢复闸门置起时 run() 降级返回，不发起任何同步请求', () async {
    container.read(restoreGateProvider.notifier).hold();

    final result = await container.read(syncCoordinatorProvider).run();

    expect(result.ok, isFalse, reason: '全量收敛进行中，增量同步必须降级等待而不是照常执行');
    expect(
      adapter.uris,
      isEmpty,
      reason: '闸门期间不得发起任何 push/pull 网络请求，避免与 full 并发交错写库',
    );
    container.read(restoreGateProvider.notifier).release();
  });

  test('显式单本恢复不请求目录、账号full或尾随全局同步', () async {
    adapter.responses.add((
      status: 200,
      body: {
        'ledger': _fullLedgerJson(ledgerId),
        'members': [],
        'transactions': [],
        'categories': [],
        'recurring_transactions': [],
        'exchange_rate_overrides': [],
        'server_cursor': '42',
      },
    ));
    final report = await container
        .read(syncCoordinatorProvider)
        .reconnect(ledgerIds: {ledgerId}, dayBookIds: {});
    expect(report.refreshed, [ledgerId]);
    await Future<void>.delayed(Duration.zero);
    expect(adapter.uris, hasLength(1));
    expect(adapter.uris.single, contains('/sync/full?'));
    expect(await db.select(db.syncState).get(), isEmpty);
    expect(container.read(restoreGateProvider), isFalse);
  });

  test('reconnect 先收敛：完成后开闸，尾随 pull 从 full 落库后的游标开始', () async {
    // 账号完整快照提供所有账本及统一游标，随后增量从此游标继续。
    adapter.responses.addAll([
      (
        status: 200,
        body: {
          'ledger_snapshots': [
            {
              'ledger': _fullLedgerJson(ledgerId),
              'members': <Object>[],
              'transactions': <Object>[],
              'categories': <Object>[],
              'recurring_transactions': <Object>[],
              'exchange_rate_overrides': <Object>[],
            },
          ],
          'categories': <Object>[],
          'exchange_rate_overrides': <Object>[],
          'deleted_exchange_rate_override_ids': <Object>[],
          'server_cursor': '42',
        },
      ),
      (
        status: 200,
        body: {'changes': <Object>[], 'server_cursor': '42', 'has_more': false},
      ),
    ]);

    final report = await container.read(syncCoordinatorProvider).reconnect();

    expect(report.refreshed, [ledgerId]);
    expect(
      container.read(restoreGateProvider),
      isFalse,
      reason: 'reconnect 完成后必须开闸，否则后续增量同步永久降级',
    );
    final row = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
    expect(row, isNotNull, reason: 'full 快照必须已落库账本行');
    expect(row!.storageMode, 'cloud');

    // 等待尾随同步的 pull 发出。
    for (
      var i = 0;
      i < 50 && !adapter.uris.any((u) => u.contains('/sync/pull'));
      i++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    final pullUri = adapter.uris.firstWhere(
      (u) => u.contains('/sync/pull'),
      orElse: () => '',
    );
    expect(pullUri, isNotEmpty, reason: 'reconnect 完成后必须补一轮尾随同步，避免恢复期间的新事件被吞掉');
    expect(
      pullUri,
      contains('since=42'),
      reason: '尾随 pull 必须从 full 落库后的服务端游标开始，绝不回放旧时间线',
    );
    // 让尾随同步的响应处理（落库 / busy 收尾）在容器 dispose 前完成，
    // 避免 ref 在容器销毁后继续读写导致异步异常。
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
}
