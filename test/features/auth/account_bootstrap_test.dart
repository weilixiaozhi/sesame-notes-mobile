import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart'
    show AccountStatus, currentAccountIdProvider;
import 'package:sesame_notes/shared/providers/account_reminder_invalidation_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

import '../../helpers/realtime_test_stub.dart';
import '../../helpers/bound_ledger_seed.dart';

/// 会话响应样例（注册/登录/刷新共用形状）。
Map<String, Object> _sessionBody({String token = 'new-access'}) => {
  'access_token': token,
  'refresh_token': 'new-refresh',
  'token_type': 'Bearer',
  'expires_in': 900,
  'device_id': 'device-1',
  'scopes': ['sync:read'],
  'user': {
    'user_id': 'user-1',
    'sesame_number': '123456789',
    'display_name': '芝麻仔000001',
    'avatar_url': null,
    'avatar_version': 0,
    'phone': '+8613800138000',
    'gender': 'UNSPECIFIED',
    'is_admin': false,
  },
};

class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

/// 可编程响应队列的 Dio 适配器：按请求顺序返回预设响应。
class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this.responses);

  final List<({int status, Map<String, Object> body, Object? error})> responses;
  int _index = 0;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    final next =
        responses[(_index < responses.length ? _index : responses.length - 1)];
    _index++;
    if (next.error != null) throw next.error!;
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

DioException _networkError() => DioException(
  requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
  type: DioExceptionType.connectionTimeout,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemorySecureStore rawStore;
  late ProviderContainer container;
  late _QueuedAdapter adapter;
  late SesameDatabase db;
  late LocalRepository repo;

  ProviderContainer buildContainer({bool useProductionRepository = false}) {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    client.dio.httpClientAdapter = adapter;
    return ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'http://test.local'),
        ),
        apiClientProvider.overrideWithValue(client),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(rawStore),
        ),
        databaseProvider.overrideWithValue(db),
        if (!useProductionRepository)
          repositoryProvider.overrideWithValue(repo),
        realtimeNoopOverride,
      ],
    );
  }

  Future<void> flushUntil(bool Function() condition) async {
    for (var i = 0; i < 40 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rawStore = _MemorySecureStore();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 从真实安全凭证与资料缓存恢复身份，网络刷新始终失败。
  Future<LocalRepository> bootstrapOfflineAccount({
    bool cachedProfile = true,
  }) async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    final prefs = await SharedPreferences.getInstance();
    if (cachedProfile) {
      await CloudProfileCache(
        prefs,
      ).write(const CloudProfile(userId: 'user-1', displayName: '缓存昵称'));
    }
    adapter = _QueuedAdapter([
      (status: 0, body: const {}, error: _networkError()),
    ]);
    container = buildContainer(useProductionRepository: true);
    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    expect(container.read(authSessionProvider), isNull);
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    return container.read(repositoryProvider);
  }

  test('离线冷启动仅有凭证也恢复账号归属，资料缓存缺失不变成本机模式', () async {
    final live = await bootstrapOfflineAccount(cachedProfile: false);
    expect(container.read(currentAccountIdProvider), 'user-1');
    expect(container.read(accountReminderInvalidationProvider).generation, 0);
    expect(container.read(accountStateProvider).profile, isNull);
    final id = await container.read(ledgerActionsProvider).create(name: '离线新本');
    expect((await live.getLedgerById(id))!.scopeAccountId, 'user-1');
    expect((await live.getLedgerById(id))!.storageMode, 'cloud');
    expect((await db.select(db.syncChanges).get()).single.accountId, 'user-1');
    await flushUntil(() => adapter.paths.isNotEmpty);
    expect(container.read(currentAccountIdProvider), 'user-1');
  });

  test('账号恢复不自动迁移本机内容或创建云同步队列', () async {
    const id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: id,
            name: '尚未确认',
            type: 'normal',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await bootstrapOfflineAccount(cachedProfile: false);
    expect((await db.select(db.memoBooks).getSingle()).storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    await flushUntil(() => adapter.paths.isNotEmpty);
  });

  test('离线冷启动记账与虚拟成员变更归属缓存账号，分类也保留账号域', () async {
    await seedBoundLedger(
      db,
      accountId: 'user-1',
      id: 'cached-ledger',
      name: '已下载账本',
      ownerAccountId: 'user-1',
    );
    final liveRepository = await bootstrapOfflineAccount();

    final memberId = await liveRepository.createPlaceholderMember(
      ledgerId: 'cached-ledger',
      name: '家人',
    );
    final transactionId = await liveRepository.addTransaction(
      ledgerId: 'cached-ledger',
      type: 'expense',
      amount: '12.50',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    final categoryId = await liveRepository.createCategory(
      name: '餐饮',
      kind: 'expense',
    );

    final changes = await db.select(db.syncChanges).get();
    for (final entityId in [memberId, transactionId, categoryId]) {
      expect(
        changes.singleWhere((change) => change.entityId == entityId).accountId,
        'user-1',
        reason: '离线保存的每条变更必须能在恢复登录会话后进入本账号push队列',
      );
    }
    expect(
      (await liveRepository.categoryStore.getCategoryById(
        categoryId,
      ))?.scopeAccountId,
      'user-1',
    );
  });

  test('离线冷启动下载标记按缓存身份隔离，新会话优先且退出后不泄露旧标记', () async {
    await bootstrapOfflineAccount();
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending('user-1', 'ledger-a');
    await downloads.markPending('user-2', 'ledger-b');

    expect(await container.read(pendingCloudLedgerDownloadsProvider.future), {
      'ledger-a',
    });

    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token-b',
            userId: 'user-2',
            deviceId: 'device-b',
          ),
        );
    expect(await container.read(pendingCloudLedgerDownloadsProvider.future), {
      'ledger-b',
    });
    final purged = Completer<void>();
    final subscription = container.listen(syncGateProvider, (_, held) {
      if (!held && !purged.isCompleted) purged.complete();
    });
    addTearDown(subscription.close);
    container.read(accountStateProvider.notifier).signOut();
    expect(
      await container.read(pendingCloudLedgerDownloadsProvider.future),
      isEmpty,
    );
    await purged.future;
  });

  test('离线冷启动删除本机账本后清除本账号下载标记，保留其他账号同名标记', () async {
    final localId = await repo.createLedger(name: '本机账本', storageMode: 'local');
    await bootstrapOfflineAccount();
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending('user-1', localId);
    await downloads.markPending('user-2', localId);

    await container.read(ledgerActionsProvider).delete(localId);

    expect(await repo.getLedgerById(localId), isNull);
    expect(await downloads.pending('user-1'), isEmpty);
    expect(await downloads.pending('user-2'), {localId});
  });

  test('无凭证：保持未登录，不发起任何刷新请求', () async {
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(), error: null),
    ]);
    container = buildContainer();
    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    expect(container.read(accountStateProvider).status, AccountStatus.local);
    expect(adapter.paths, isEmpty);
  });

  test('无凭证启动：隔离残留云端待办并清除记账初始化水位，本地账本保留', () async {
    // 播种上次会话认证失效后留下的残留：云端账本 + 待推送变更 + 设备游标。
    // 未登录启动只隔离不删行——云端账本按账号域不可访问，同账号重登后
    // 待推送变更继续补推；删除只留给用户显式退出/换账号。
    const cloudId = 'cloud-leftover';
    await seedBoundLedger(db, accountId: null, id: cloudId, name: '残留云端账本');
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    final now = DateTime.now().toUtc();
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: cloudId,
            ledgerId: d.Value(cloudId),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: const Uuid().v4(),
          ),
        );
    await db
        .into(db.syncState)
        .insert(SyncStateCompanion.insert(deviceId: 'device-1'));
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(), error: null),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));

    expect(container.read(accountStateProvider).status, AccountStatus.local);
    expect(adapter.paths, isEmpty, reason: '无凭证不发起网络请求，隔离仅操作本地库');
    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '未登录启动只隔离：本机行保留，重登后立即可用',
    );
    expect(await repo.getLedgerById(localId), isNotNull, reason: '本地账本一行不动');
    expect(
      await db.select(db.syncChanges).get(),
      hasLength(1),
      reason: '待推送变更按账号域保留，同账号重登后补推',
    );
    expect(
      (await db.select(db.syncState).getSingle()).serverCursor,
      isNull,
      reason: '清除已失效的初始化状态，重新认证后先恢复记账完整快照',
    );
  });

  test('有凭证 + 缓存资料 + 刷新 200：缓存先渲染，随后凭证束轮换并更新会话与资料', () async {
    SharedPreferences.setMockInitialValues({});
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'sesame_notes_cloud_profile_user-1',
      jsonEncode(
        const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
          displayName: '缓存昵称',
          avatarVersion: 3,
        ).toJson(),
      ),
    );
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(token: 'rotated'), error: null),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    // 缓存渲染阶段：authenticated，会话仍为空（断网启动形态）
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile?.displayName, '缓存昵称');
    expect(container.read(authSessionProvider), isNull);

    // 后台刷新完成后：凭证束轮换、会话注入、资料更新
    await flushUntil(
      () => container.read(authSessionProvider)?.accessToken == 'rotated',
    );
    expect(container.read(authSessionProvider)?.userId, 'user-1');
    expect(container.read(authSessionProvider)?.deviceId, 'device-1');
    final stored = await rawStore.read();
    expect(stored, contains('new-refresh'));
    expect(
      container.read(accountStateProvider).profile?.displayName,
      '芝麻仔000001',
    );
    // 刷新成功后会话建立并启动实时通知：ws/ticket 请求紧随 refresh 之后属
    // 设计行为（WS 只在会话存在期运行），此处只断言轮换请求必须最先且仅一次。
    expect(adapter.paths.first, '/api/v1/auth/refresh');
    expect(adapter.paths.where((p) => p == '/api/v1/auth/refresh').length, 1);
    expect(container.read(accountReminderInvalidationProvider).generation, 0);
  });

  test('刷新认证类 401：清除凭证回到未登录（资料缓存保留）', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (
        status: 401,
        body: {
          'code': 'INVALID_REFRESH_TOKEN',
          'message': '登录状态已失效，请重新登录',
          'request_id': 'r1',
        },
        error: null,
      ),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    await flushUntil(
      () => container.read(accountStateProvider).status == AccountStatus.local,
    );
    expect(container.read(accountStateProvider).status, AccountStatus.local);
    expect(await rawStore.read(), isNull);
    expect(container.read(accountReminderInvalidationProvider).generation, 1);
    // 本地账本等业务数据不在本次范围；资料缓存按账号键控保留
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sesame_notes_cloud_profile_user-1'), isNull);
  });

  test('刷新认证类401保留云端待办和本地账本，清除记账初始化水位', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    const cloudId = 'cloud-1';
    await seedBoundLedger(db, accountId: null, id: cloudId, name: '云端账本');
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    final now = DateTime.now().toUtc();
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: cloudId,
            ledgerId: d.Value(cloudId),
            action: 'upsert',
            payload: '{}',
            updatedAt: now,
            mutationId: const Uuid().v4(),
          ),
        );
    await db
        .into(db.syncState)
        .insert(SyncStateCompanion.insert(deviceId: 'device-1'));
    adapter = _QueuedAdapter([
      (
        status: 401,
        body: {
          'code': 'INVALID_REFRESH_TOKEN',
          'message': '登录状态已失效，请重新登录',
          'request_id': 'r1',
        },
        error: null,
      ),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    await flushUntil(
      () => container.read(accountStateProvider).status == AccountStatus.local,
    );

    expect(await rawStore.read(), isNull, reason: '认证类 401 必须清除凭证');
    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '认证类 401 只隔离不清库：内容删除只留给用户显式退出/换账号',
    );
    expect(await repo.getLedgerById(localId), isNotNull, reason: '本地账本一行不动');
    expect(
      await db.select(db.syncChanges).get(),
      hasLength(1),
      reason: '待推送变更按账号域保留，同账号重登后补推',
    );
    expect(
      (await db.select(db.syncState).getSingle()).serverCursor,
      isNull,
      reason: '清除已失效的初始化状态，重新认证后先恢复记账完整快照',
    );
  });

  test('刷新网络错误：凭证与缓存身份保留，账号保持 authenticated', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'sesame_notes_cloud_profile_user-1',
      jsonEncode(
        const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
          displayName: '缓存昵称',
        ).toJson(),
      ),
    );
    adapter = _QueuedAdapter([
      (status: 0, body: const {}, error: _networkError()),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    // 网络恢复前：authenticated（缓存资料），凭证未动
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile?.displayName, '缓存昵称');
    expect(await rawStore.read(), contains('old-refresh'));
    expect(container.read(authSessionProvider), isNull);
  });

  test('刷新 5xx：与网络错误同语义，凭证保留', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (
        status: 500,
        body: {
          'code': 'INTERNAL_ERROR',
          'message': '服务暂时不可用',
          'request_id': 'r2',
        },
        error: null,
      ),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    await flushUntil(() => adapter.paths.isNotEmpty);
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(await rawStore.read(), contains('old-refresh'));
  });

  test('有凭证但无缓存资料：先进入 authenticated 空资料态，刷新后补全', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(), error: null),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 模拟应用确认必需初始化完成后的首次后台会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile, isNull);
    await flushUntil(
      () => container.read(accountStateProvider).profile != null,
    );
    expect(
      container.read(accountStateProvider).profile?.displayName,
      '芝麻仔000001',
    );
  });
}
