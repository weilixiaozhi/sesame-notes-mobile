import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' show SesameApiClient;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';
import '../helpers/realtime_test_stub.dart';
import '../helpers/bound_ledger_seed.dart';

/// 仅挂起真实隔离水位写入，确认新账号提交必须等待旧闸门释放。
class _PausedIsolationWrites extends d.QueryInterceptor {
  Completer<void>? release;
  final entered = Completer<void>();
  final finished = Completer<void>();

  /// SQLite 更新尚未执行时设置屏障，释放后完整执行生产隔离语句。
  @override
  Future<int> runUpdate(
    d.QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final gate = release;
    if (gate == null ||
        entered.isCompleted ||
        !statement.contains('sync_state')) {
      return executor.runUpdate(statement, args);
    }
    entered.complete();
    try {
      await gate.future;
      return await executor.runUpdate(statement, args);
    } finally {
      finished.complete();
    }
  }
}

/// 用内存替代平台安全存储，凭证提交和清理仍走真实门面。
class _MemorySecureStore implements SecureStore {
  String? value;

  /// 读取当前凭证束。
  @override
  Future<String?> read() async => value;

  /// 保存完整凭证束。
  @override
  Future<void> write(String value) async => this.value = value;

  /// 清空已失效凭证。
  @override
  Future<void> delete() async => value = null;
}

/// 延迟同步响应，同时让独立刷新请求返回真实 HTTP 401。
class _DelayedSyncAdapter implements HttpClientAdapter {
  final requested = Completer<RequestOptions>();
  final response = Completer<Map<String, Object?>>();

  /// 同步请求由测试释放，认证失效由 Dio 的状态码校验交给会话层处理。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/refresh')) {
      return ResponseBody.fromString(
        jsonEncode({
          'code': 'INVALID_REFRESH_TOKEN',
          'message': '登录状态已失效，请重新登录',
          'request_id': 'expired-session',
        }),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (!options.path.endsWith('/sync/push') &&
        !options.path.endsWith('/sync/pull')) {
      throw StateError('测试未预期的请求: ${options.path}');
    }
    requested.complete(options);
    return ResponseBody.fromString(
      jsonEncode(await response.future),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  /// 测试适配器没有真实网络连接。
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const credential = ActiveCredential(
    userId: 'account-a',
    deviceId: 'device-a',
    refreshToken: 'refresh-a',
  );
  const cloudId = '11111111-1111-4111-8111-111111111111';

  late SesameDatabase db;
  late LocalRepository repo;
  late _PausedIsolationWrites isolation;
  late ProviderContainer container;
  late SecureAccountStore store;
  late _DelayedSyncAdapter adapter;
  late SyncService service;
  late String localId;
  late SyncChange mutation;

  setUp(() async {
    resetGlobalTestState();
    isolation = _PausedIsolationWrites();
    db = SesameDatabase.withExecutor(
      d.ApplyInterceptor(NativeDatabase.memory()).interceptWith(isolation),
    );
    adapter = _DelayedSyncAdapter();
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    client.dio.httpClientAdapter = adapter;
    store = SecureAccountStore(
      _MemorySecureStore(),
      pendingStore: _MemorySecureStore(),
      logoutMarkerStore: _MemorySecureStore(),
    );
    await store.save(credential);
    repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(authSessionProvider)?.userId,
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(authSessionProvider)?.userId,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        apiClientProvider.overrideWithValue(client),
        secureAccountStoreProvider.overrideWithValue(store),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
        realtimeNoopOverride,
      ],
    );
    container.read(accountAuthFailureCleanupProvider);
    container
        .read(accountStateProvider.notifier)
        .signIn(
          session: const AuthSession(
            accessToken: 'access-a',
            userId: 'account-a',
            deviceId: 'device-a',
          ),
          profile: const CloudProfile(userId: 'account-a'),
        );
    await seedBoundLedger(
      db,
      accountId: credential.userId,
      id: cloudId,
      name: '云端账本',
      syncId: 'sync-a',
      ownerAccountId: credential.userId,
    );
    localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await db.delete(db.syncChanges).go();
    await repo.addTransaction(
      ledgerId: cloudId,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    mutation = (await db.select(db.syncChanges).get()).single;
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: credential.deviceId,
            accountId: d.Value(credential.userId),
            serverCursor: const d.Value('4'),
          ),
        );
    service = SyncService(
      client: client,
      db: db,
      deviceId: credential.deviceId,
      currentAccountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
  });

  tearDown(() async {
    final release = isolation.release;
    if (release != null && !release.isCompleted) release.complete();
    if (isolation.entered.isCompleted) {
      await isolation.finished.future;
      await pumpEventQueue();
    }
    container.dispose();
    await db.close();
  });

  test('认证401隔离尚未完成：B登录等待旧闸门释放后才提交', () async {
    isolation.release = Completer<void>();
    final gateStates = <bool>[];
    final subscription = container.listen(syncGateProvider, (_, next) {
      gateStates.add(next);
    });
    await expectLater(
      container.read(authSessionProvider.notifier).refresh(),
      throwsA(isA<DioException>()),
    );
    await isolation.entered.future;
    expect(await store.load(), isNull);
    expect(container.read(syncGateProvider), isTrue);

    var committed = false;
    final login = container
        .read(accountSwitchCoordinatorProvider)
        .commitLogin(
          candidate: const CandidateSession(
            session: AuthSession(
              accessToken: 'access-b',
              userId: 'account-b',
              deviceId: 'device-b',
            ),
            refreshToken: 'refresh-b',
            profile: CloudProfile(userId: 'account-b'),
          ),
          onReconnect: null,
        )
        .then((result) {
          committed = result;
          return result;
        });
    await Future<void>.delayed(Duration.zero);
    final credentialWhilePurging = await store.load();
    final sessionWhilePurging = container.read(authSessionProvider);
    final gateWhilePurging = container.read(syncGateProvider);
    final committedWhilePurging = committed;
    final cursorWhilePurging =
        (await db.select(db.syncState).getSingle()).serverCursor;

    // 先释放隔离并收尾再断言，红测也不会遗留被阻塞的异步任务。
    isolation.release!.complete();
    final result = await login;
    await isolation.finished.future;
    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '认证失效只隔离不清库：A 的本机行保留',
    );
    expect(
      (await db.select(db.syncState).getSingle()).serverCursor,
      isNull,
      reason: '隔离已清除记账初始化状态，重新认证后必须先建立完整快照',
    );
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    expect(await db.select(db.syncPullErrors).get(), isEmpty);
    subscription.close();

    expect(credentialWhilePurging, isNull);
    expect(sessionWhilePurging, isNull);
    expect(gateWhilePurging, isTrue);
    expect(committedWhilePurging, isFalse);
    expect(cursorWhilePurging, '4', reason: 'B 等待时隔离的真实水位写入尚未完成');
    expect(result, isTrue);
    expect((await store.load())?.userId, 'account-b');
    expect(container.read(authSessionProvider)?.userId, 'account-b');
    expect(gateStates, [true, false, true, false]);
    expect(container.read(syncGateProvider), isFalse);
    expect(await repo.getLedgerById(localId), isNotNull);
  });

  for (final push in [true, false]) {
    for (final authFails in [true, false]) {
      test(
        '${push ? 'push冲突' : 'pull空页'}响应${authFails ? '晚于认证401隔离：迟到的旧账号响应不得落库' : '属于有效账号：正常持久化结果'}',
        () async {
          // 先挂接错误处理，避免账号变化后的异步拒绝成为未处理异常。
          final settled = (push ? service.push() : service.pull())
              .then<Object?>((_) => null, onError: (Object error) => error);
          final request = await adapter.requested.future.timeout(
            const Duration(seconds: 5),
          );
          expect(request.path, endsWith(push ? '/sync/push' : '/sync/pull'));

          if (authFails) {
            final purged = Completer<void>();
            var held = false;
            final subscription = container.listen(syncGateProvider, (_, next) {
              if (next) held = true;
              if (held && !next && !purged.isCompleted) purged.complete();
            });
            // 真实刷新401 -> AuthSession清空 -> AccountState监听 -> 自动隔离。
            await expectLater(
              container.read(authSessionProvider.notifier).refresh(),
              throwsA(isA<DioException>()),
            );
            await purged.future.timeout(const Duration(seconds: 5));
            subscription.close();
            expect(container.read(authSessionProvider), isNull);
            expect(
              container.read(accountStateProvider).isAuthenticated,
              isFalse,
            );
            expect(await store.load(), isNull);
            expect(
              await repo.getLedgerById(cloudId),
              isNotNull,
              reason: '认证失效只隔离：旧账号已落库的本机行保留',
            );
            expect(
              await db.select(db.syncConflicts).get(),
              isEmpty,
              reason: '迟到响应不得为旧账号新建冲突',
            );
            expect(
              (await db.select(db.syncState).getSingle()).serverCursor,
              isNull,
              reason: '隔离后的记账域仍待完整初始化，迟到响应不得把它标为已消费',
            );
          }

          adapter.response.complete(
            push
                ? {
                    'outcomes': [
                      {
                        'mutation_id': mutation.mutationId,
                        'entity_id': mutation.entityId,
                        'status': 'conflict',
                        'current_revision': 9,
                        'current_deleted': false,
                        'current_entity': {'note': '远端备注'},
                      },
                    ],
                    'server_cursor': '777',
                  }
                : {'changes': [], 'server_cursor': '777', 'has_more': false},
          );
          final error = await settled;

          if (authFails) {
            expect(
              await repo.getLedgerById(cloudId),
              isNotNull,
              reason: '认证失效只隔离：旧账号已落库的本机行保留',
            );
            expect(
              await db.select(db.transactions).get(),
              hasLength(1),
              reason: '已落库的交易保留，迟到响应不得新增',
            );
            expect(
              await db.select(db.syncConflicts).get(),
              isEmpty,
              reason: '迟到响应不得为旧账号新建冲突',
            );
            expect(
              (await db.select(db.syncState).getSingle()).serverCursor,
              isNull,
              reason: '隔离后的记账域仍待完整初始化，迟到响应不得把它标为已消费',
            );
            expect(await db.select(db.syncPullErrors).get(), isEmpty);
            expect(container.read(syncGateProvider), isFalse);
            expect(error, anyOf(isNull, isA<StateError>()));
          } else {
            // 有效账号对照验证响应确实进入真实落库路径，避免无效样例造成假通过。
            expect(error, isNull);
            expect(await repo.getLedgerById(cloudId), isNotNull);
            if (push) {
              final conflicts = await db.select(db.syncConflicts).get();
              expect(conflicts, hasLength(1));
              expect(conflicts.single.remoteRevision, 9);
            } else {
              final states = await db.select(db.syncState).get();
              expect(states.single.serverCursor, '777');
            }
          }
          expect(await repo.getLedgerById(localId), isNotNull);
        },
      );
    }
  }
}
