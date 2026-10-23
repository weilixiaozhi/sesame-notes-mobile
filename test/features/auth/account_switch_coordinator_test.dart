import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/features/auth/application/local_book_migration.dart';
import 'package:sesame_notes/shared/providers/memo_editor_session_provider.dart';
import '../../helpers/fitness_space_fixture.dart';
import '../../helpers/fitness_running_fixture.dart';
import 'dart:async';
import 'dart:convert';
import 'package:sesame_notes/data/models/fitness.dart' as fitness;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/auth_service.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart'
    show AccountStatus, currentAccountIdProvider;
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/data/models/memo.dart' as memos;
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';
import 'package:sesame_notes/sync/realtime_client.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import '../../helpers/bound_ledger_seed.dart';

class _MemorySecureStore implements SecureStore {
  String? value;
  bool failWrite = false;
  @override
  Future<String?> read() async => value;

  /// 模拟原子安全写入及平台存储不可用。
  @override
  Future<void> write(String v) async {
    if (failWrite) throw StateError('安全存储不可用');
    value = v;
  }

  @override
  Future<void> delete() async => value = null;
}

class _MockAuthService extends Mock implements AuthService {}

/// 内存通知通道用于验证真实协调器的启停，不发起网络请求。
class _AccountRealtimeSocket implements RealtimeSocket {
  final controller = StreamController<dynamic>();

  @override
  Stream<dynamic> get messages => controller.stream;

  /// 关闭当前账号的通知通道。
  @override
  Future<void> close() async => controller.close();
}

const userA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const userB = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

ActiveCredential credentialA() => ActiveCredential(
  userId: userA,
  deviceId: 'device-a',
  refreshToken: 'refresh-a',
);

CandidateSession candidateB() => CandidateSession(
  session: const AuthSession(
    accessToken: 'token-b',
    userId: userB,
    deviceId: 'device-b',
  ),
  refreshToken: 'refresh-b',
  profile: const CloudProfile(
    userId: userB,
    sesameNumber: '222222222',
    displayName: 'B',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(credentialA());
  });

  late SesameDatabase db;
  late LocalRepository repo;
  late _MemorySecureStore rawStore;
  late _MemorySecureStore rawPending;
  late _MemorySecureStore rawMarker;
  late _MockAuthService auth;
  late SyncService service;
  late ProviderContainer container;
  late List<String?> realtimeAccounts;
  late List<_AccountRealtimeSocket> realtimeSockets;
  late Future<String> Function()? pendingRealtimeTicket;
  late bool verifyRealtimeWriteBarrier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(currentAccountIdProvider),
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(currentAccountIdProvider),
      ),
    );
    rawStore = _MemorySecureStore();
    rawPending = _MemorySecureStore();
    rawMarker = _MemorySecureStore();
    auth = _MockAuthService();
    service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'device-a',
      currentAccountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
    final prefs = await SharedPreferences.getInstance();
    realtimeAccounts = [];
    realtimeSockets = [];
    pendingRealtimeTicket = null;
    verifyRealtimeWriteBarrier = false;
    container = ProviderContainer(
      overrides: [
        realtimeClientProvider.overrideWith((ref) {
          final client = RealtimeClient(
            ticketProvider: () async {
              expect(ref.read(syncGateProvider), isFalse);
              if (verifyRealtimeWriteBarrier) {
                // 生命周期用例通过本机动作确认账号写屏障已释放。
                await ref
                    .read(syncCoordinatorProvider)
                    .runDataMutation(() async {});
              }
              realtimeAccounts.add(ref.read(authSessionProvider)?.userId);
              if (pendingRealtimeTicket != null) {
                return pendingRealtimeTicket!();
              }
              return 'ticket-${realtimeAccounts.length}';
            },
            connect: (_) {
              final socket = _AccountRealtimeSocket();
              realtimeSockets.add(socket);
              return socket;
            },
          );
          ref.onDispose(client.dispose);
          return client;
        }),
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        authServiceProvider.overrideWithValue(auth),
        syncServiceProvider.overrideWith((ref) => service),
        databaseProvider.overrideWithValue(db),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
        repositoryProvider.overrideWithValue(repo),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            rawStore,
            pendingStore: rawPending,
            logoutMarkerStore: rawMarker,
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
      ],
    );
    container.read(accountAuthFailureCleanupProvider);
  });

  tearDown(() async {
    await container.read(realtimeCoordinatorProvider).stop();
    await pumpEventQueue();
    container.dispose();
    await db.close();
  });

  test('登录提交保留本机本，显式确认后才迁移', () async {
    final memosRepo = container.read(memoRepositoryProvider);
    final before = const Uuid().v4();
    await memosRepo.createBook(id: before, name: '注册之前', type: 'normal');
    final coordinator = container.read(accountSwitchCoordinatorProvider);
    expect(
      await coordinator.commitLogin(candidate: candidateB(), onReconnect: null),
      isTrue,
    );
    expect(
      (await memosRepo.getBook(before, accountId: userB))!.isCloud,
      isFalse,
    );
    final migration = container.read(localBookMigrationProvider);
    await migration.migrate(await migration.preview());
    expect(
      (await memosRepo.getBook(before, accountId: userB))!.isCloud,
      isTrue,
    );
    final after = const Uuid().v4();
    await memosRepo.createBook(id: after, name: '明确本机', type: 'normal');
    expect(
      await coordinator.commitLogin(candidate: candidateB(), onReconnect: null),
      isTrue,
    );
    expect(
      (await memosRepo.getBook(after, accountId: userB))!.isCloud,
      isFalse,
    );
  });

  test('拒绝迁移后退出仍保留全部业务域的本机本', () async {
    final ledger = await repo.createLedger(name: '本机账本', storageMode: 'local');
    final dayId = const Uuid().v4(), memoId = const Uuid().v4();
    await container
        .read(dayRepositoryProvider)
        .createBook(id: dayId, name: '本机纪念日');
    await container
        .read(memoRepositoryProvider)
        .createBook(id: memoId, name: '本机备忘录', type: 'normal');
    final fitnessRepo = await createFitnessTestRepository(db);
    final coordinator = container.read(accountSwitchCoordinatorProvider);
    expect(
      await coordinator.commitLogin(candidate: candidateB(), onReconnect: null),
      isTrue,
    );
    final plan = await container
        .read(localBookMigrationProvider)
        .previewForPrompt();
    expect(plan!.count, 4);
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    await coordinator.logout();
    expect((await repo.getLedgerById(ledger))!.storageMode, 'local');
    expect(
      (await container.read(dayRepositoryProvider).getBook(dayId))!.isCloud,
      isFalse,
    );
    expect(
      (await container.read(memoRepositoryProvider).getBook(memoId))!.isCloud,
      isFalse,
    );
    expect(
      (await (db.select(
            db.fitnessSpaces,
          )..where((s) => s.id.equals(fitnessRepo.spaceId))).getSingle())
          .storageMode,
      'local',
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  /// 保存明确账号归属的云账本，验证切换账号时不会越过数据边界。
  Future<String> seedAccountCloudLedger(String name, String accountId) async {
    final id = const Uuid().v4();
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountId),
            ownerAccountId: d.Value(accountId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  /// A 已登录 + 云端账本（scope A）+ 一条未推送变更。
  Future<void> seedAccountA({bool withPending = true}) async {
    await rawStore.write(credentialA().encode());
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token-a',
            userId: userA,
            deviceId: 'device-a',
          ),
        );
    container
        .read(accountStateProvider.notifier)
        .signIn(
          session: const AuthSession(
            accessToken: 'token-a',
            userId: userA,
            deviceId: 'device-a',
          ),
          profile: const CloudProfile(
            userId: userA,
            sesameNumber: '111111111',
            displayName: 'A',
          ),
        );
    const ledgerId = 'ledger-a';
    await seedBoundLedger(
      db,
      accountId: userA,
      id: ledgerId,
      name: 'A 云账本',
      syncId: 'sync-a',
      ownerAccountId: userA,
    );
    if (withPending) {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'ledger',
              entityId: ledgerId,
              ledgerId: d.Value(ledgerId),
              action: 'upsert',
              payload: '{}',
              updatedAt: DateTime.now().toUtc(),
              mutationId: const Uuid().v4(),
              accountId: d.Value(userA),
            ),
          );
    }
  }

  for (final switchAccount in [false, true]) {
    test('${switchAccount ? '换号' : '退出'}被未同步修改阻断后恢复原账号唯一连接', () async {
      verifyRealtimeWriteBarrier = true;
      await seedAccountA();
      await container.read(realtimeCoordinatorProvider).start();
      final coordinator = container.read(accountSwitchCoordinatorProvider);
      if (switchAccount) {
        expect(
          await coordinator.commitLogin(
            candidate: candidateB(),
            onReconnect: null,
          ),
          isFalse,
        );
      } else {
        await expectLater(
          coordinator.logout(),
          throwsA(isA<PendingChangesBlockedException>()),
        );
      }
      await pumpEventQueue();
      expect(realtimeAccounts, [userA, userA]);
      expect(
        realtimeSockets.where((socket) => !socket.controller.isClosed),
        hasLength(1),
      );
      expect(container.read(authSessionProvider)?.userId, userA);
      await container.read(realtimeCoordinatorProvider).start();
      expect(realtimeAccounts, [userA, userA], reason: '恢复后再次启动保持幂等');
    });
  }

  test('退出持久化失败后恢复原账号连接', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA(withPending: false);
    await container.read(realtimeCoordinatorProvider).start();
    rawMarker.failWrite = true;
    await expectLater(
      container.read(accountSwitchCoordinatorProvider).logout(),
      throwsStateError,
    );
    await pumpEventQueue();
    expect(realtimeAccounts, [userA, userA]);
    expect(
      realtimeSockets.where((socket) => !socket.controller.isClosed),
      hasLength(1),
    );
  });

  test('当前凭证原子提交失败后恢复原账号连接', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA(withPending: false);
    await container.read(realtimeCoordinatorProvider).start();
    rawStore.failWrite = true;
    expect(
      await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidateB(), onReconnect: null),
      isFalse,
    );
    await pumpEventQueue();
    expect(realtimeAccounts, [userA, userA]);
    expect(
      realtimeSockets.where((socket) => !socket.controller.isClosed),
      hasLength(1),
    );
  });

  test('退出阻断开闸时的令牌轮换也等待写屏障释放后恢复连接', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA();
    await container.read(realtimeCoordinatorProvider).start();
    container.read(appSessionLifecycleProvider);
    final subscription = container.listen(syncGateProvider, (previous, next) {
      if (previous == true && !next) {
        container.read(authSessionProvider.notifier).updateToken('rotated-a');
      }
    });
    addTearDown(subscription.close);
    await expectLater(
      container.read(accountSwitchCoordinatorProvider).logout(),
      throwsA(isA<PendingChangesBlockedException>()),
    );
    await pumpEventQueue();
    expect(realtimeAccounts, [userA, userA]);
    expect(container.read(authSessionProvider)?.accessToken, 'rotated-a');
    expect(
      realtimeSockets.where((socket) => !socket.controller.isClosed),
      hasLength(1),
    );
  });

  test('恢复取票挂起时退出阻断仍立即反馈，迟到票据只恢复原账号一个连接', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA();
    await container.read(realtimeCoordinatorProvider).start();
    final ticket = Completer<String>();
    final fetching = Completer<void>();
    pendingRealtimeTicket = () {
      fetching.complete();
      return ticket.future;
    };
    try {
      await expectLater(
        container.read(accountSwitchCoordinatorProvider).logout(),
        throwsA(isA<PendingChangesBlockedException>()),
      ).timeout(const Duration(seconds: 1));
      await fetching.future;
      expect(ticket.isCompleted, isFalse);
      expect(realtimeSockets, hasLength(1));
      expect(realtimeSockets.single.controller.isClosed, isTrue);
      ticket.complete('restored-ticket');
      await pumpEventQueue();
      expect(realtimeAccounts, [userA, userA]);
      expect(
        realtimeSockets.where((socket) => !socket.controller.isClosed),
        hasLength(1),
      );
    } finally {
      if (!ticket.isCompleted) ticket.complete('cleanup-ticket');
    }
  });

  for (final switchAccount in [false, true]) {
    test('成功${switchAccount ? '换号只建立新账号连接' : '退出保持连接关闭'}', () async {
      verifyRealtimeWriteBarrier = true;
      await seedAccountA(withPending: false);
      await container.read(realtimeCoordinatorProvider).start();
      container.read(appSessionLifecycleProvider);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      final coordinator = container.read(accountSwitchCoordinatorProvider);
      if (switchAccount) {
        expect(
          await coordinator.commitLogin(
            candidate: candidateB(),
            onReconnect: null,
          ),
          isTrue,
        );
      } else {
        await coordinator.logout();
      }
      await pumpEventQueue();
      expect(realtimeAccounts, switchAccount ? [userA, userB] : [userA]);
      expect(
        realtimeSockets.where((socket) => !socket.controller.isClosed),
        hasLength(switchAccount ? 1 : 0),
      );
    });
  }

  for (final target in ['other-account', 'local', 'missing', 'unowned']) {
    for (final risk in ['pending', 'conflict']) {
      test('safetyFork 拒绝 $target 的 $risk，原凭证与请求完整保留', () async {
        await seedAccountA(withPending: false);
        String ledgerId;
        if (target == 'other-account') {
          ledgerId = await seedAccountCloudLedger('B 云账本', userB);
        } else if (target == 'local') {
          ledgerId = await repo.createLedger(
            name: '本机账本',
            storageMode: 'local',
            localSelfId: 'local-self',
          );
        } else {
          ledgerId = const Uuid().v4();
          if (target == 'unowned') {
            await db
                .into(db.ledgers)
                .insert(
                  LedgersCompanion.insert(
                    id: ledgerId,
                    name: '归属未确定的账本',
                    storageMode: const d.Value('cloud'),
                    updatedAt: DateTime.utc(2026, 7, 5),
                  ),
                );
          }
        }
        final mutationId = const Uuid().v4();
        final entityId = const Uuid().v4();
        final original = jsonEncode({
          'mutation_id': mutationId,
          'entity_type': 'transaction',
          'entity_id': entityId,
          'ledger_id': ledgerId,
          'action': 'upsert',
          'updated_at': '2026-07-05T00:00:00.123Z',
          'payload': {'note': '原始待保护内容'},
        });
        if (risk == 'pending') {
          await db
              .into(db.syncChanges)
              .insert(
                SyncChangesCompanion.insert(
                  entityType: 'transaction',
                  entityId: entityId,
                  ledgerId: d.Value(ledgerId),
                  accountId: const d.Value(userA),
                  action: 'upsert',
                  payload: original,
                  frozenRequest: d.Value(original),
                  updatedAt: DateTime.utc(2026, 7, 5),
                  mutationId: mutationId,
                ),
              );
        } else {
          await db
              .into(db.syncConflicts)
              .insert(
                SyncConflictsCompanion.insert(
                  id: entityId,
                  accountId: const d.Value(userA),
                  ledgerId: d.Value(ledgerId),
                  entityType: 'transaction',
                  entityId: entityId,
                  localPayload: original,
                  remotePayload: '{"note":"云端内容"}',
                  baseRevision: 1,
                  remoteRevision: 2,
                  localMutationId: mutationId,
                ),
              );
        }
        final ledgersBefore = await db.select(db.ledgers).get();
        final credentialBefore = await rawStore.read();

        await expectLater(
          container
              .read(accountSwitchCoordinatorProvider)
              .logout(policy: AccountSwitchPolicy.safetyFork),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              '错误说明',
              contains('账号归属不完整'),
            ),
          ),
        );

        expect(await rawStore.read(), credentialBefore);
        expect(await rawMarker.read(), isNull);
        expect(container.read(authSessionProvider)?.userId, userA);
        expect(await db.select(db.ledgers).get(), ledgersBefore);
        if (risk == 'pending') {
          final change = await (db.select(
            db.syncChanges,
          )..where((row) => row.mutationId.equals(mutationId))).getSingle();
          expect(change.payload, original);
          expect(change.frozenRequest, original);
          expect(change.pushedAt, isNull);
        } else {
          final conflict = await (db.select(
            db.syncConflicts,
          )..where((row) => row.id.equals(entityId))).getSingle();
          expect(conflict.localPayload, original);
          expect(conflict.remotePayload, '{"note":"云端内容"}');
          expect(conflict.status, 'OPEN');
        }
      });
    }
  }

  for (final loggedIn in [false, true]) {
    test('${loggedIn ? 'B退出' : '无凭证退出'}保留失效A的账本与未上传修改', () async {
      await seedAccountA();
      await rawStore.delete();
      container.read(accountStateProvider.notifier).signOut();
      if (loggedIn) {
        expect(
          await container
              .read(accountSwitchCoordinatorProvider)
              .commitLogin(candidate: candidateB(), onReconnect: null),
          isTrue,
        );
      }
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await container.read(accountSwitchCoordinatorProvider).logout();
      expect(await repo.getLedgerById('ledger-a'), isNotNull);
      expect(
        await (db.select(db.syncChanges)..where(
              (c) => c.ledgerId.equals('ledger-a') & c.pushedAt.isNull(),
            ))
            .get(),
        hasLength(1),
      );
    });
  }

  test('仅健身未同步也阻断退出，保护失败不清除源，重试保留本机和其他账号', () async {
    await seedAccountA(withPending: false);
    final fitnessRepo = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => userA,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => userA),
    ));
    final workout = await runningWorkoutFixture(fitnessRepo, name: '尚未确认的训练');
    await fitnessRepo.savePreferences(
      const fitness.FitnessPreferences(defaultRestSeconds: 75),
    );
    final other = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => userB,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => userB),
    ));
    final otherTemplate = await other.saveTemplate(
      fitness.FitnessTemplate(
        exercises: const [
          fitness.FitnessExercise(
            id: '66666666-6666-4666-8666-666666666666',
            exerciseId: '0025',
          ),
        ],
        name: '隔离模板',
      ),
    );
    final coordinator = container.read(accountSwitchCoordinatorProvider);
    await expectLater(
      coordinator.logout(),
      throwsA(isA<PendingChangesBlockedException>()),
    );
    expect(await rawStore.read(), contains('refresh-a'));
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    await db.customStatement(
      "CREATE TRIGGER fail_fitness_fork BEFORE INSERT ON fitness_entities WHEN NEW.storage_mode = 'local' BEGIN SELECT RAISE(ABORT, 'fail'); END",
    );
    await expectLater(
      coordinator.logout(policy: AccountSwitchPolicy.safetyFork),
      throwsA(anything),
    );
    expect(await rawStore.read(), contains('refresh-a'));
    expect(
      (await db.select(db.fitnessEntities).get()).where(
        (e) => e.scopeAccountId == null,
      ),
      isEmpty,
    );
    expect(
      (await db.select(db.syncChanges).get()).where(
        (c) => c.entityId == workout.id,
      ),
      isNotEmpty,
    );
    await db.customStatement('DROP TRIGGER fail_fitness_fork');
    await coordinator.logout(policy: AccountSwitchPolicy.safetyFork);
    final rows = await db.select(db.fitnessEntities).get();
    expect(rows.where((e) => e.scopeAccountId == userA), isEmpty);
    expect(
      rows.singleWhere((e) => e.id == otherTemplate.id).scopeAccountId,
      userB,
    );
    final restored = rows.singleWhere((e) => e.entityType == 'fitness_workout');
    expect(restored.scopeAccountId, isNull);
    expect(jsonDecode(restored.payload)['status'], 'in_progress');
    expect(jsonDecode(restored.payload)['name'], '尚未确认的训练');
    expect(
      jsonDecode(
        rows.singleWhere((e) => e.entityType == 'fitness_preferences').payload,
      )['default_rest_seconds'],
      75,
    );
    expect(
      (await db.select(db.syncChanges).get()).where(
        (c) => c.accountId == userA,
      ),
      isEmpty,
    );
  });

  test('没有outbox但尚未选择的健身恢复分支也阻断退出', () async {
    await seedAccountA(withPending: false);
    final fitnessRepo = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => userA,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => userA),
    ));
    final workout = await runningWorkoutFixture(fitnessRepo, name: '当前版本');
    await db.delete(db.syncChanges).go();
    final row = await db.select(db.fitnessEntities).getSingle();
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: const Uuid().v4(),
            accountId: d.Value(userA),
            entityType: row.entityType,
            entityId: workout.id,
            localPayload: row.payload,
            remotePayload: jsonEncode({
              'fitness_recovery': true,
              'id': workout.id,
              'payload': jsonDecode(row.payload),
              'deleted_at': null,
              'source': {'kind': 'pending', 'operation_id': 'test'},
            }),
            baseRevision: 0,
            remoteRevision: 0,
            localMutationId: 'fitness-recovery:test',
            status: const d.Value('RESOLVED_REMOTE'),
          ),
        );
    await expectLater(
      container.read(accountSwitchCoordinatorProvider).logout(),
      throwsA(isA<PendingChangesBlockedException>()),
    );
    expect(await rawStore.read(), contains('refresh-a'));
    expect((await db.select(db.syncConflicts).getSingle()).resolvedAt, isNull);
  });

  for (final switchAccount in [false, true]) {
    test('${switchAccount ? '换号' : '退出'}完成账号清库后仅移除旧账号下载标记', () async {
      await seedAccountA(withPending: false);
      final downloads = container.read(cloudLedgerDownloadStoreProvider);
      await downloads.markPending(userA, 'ledger-a');
      await downloads.markPending(userB, 'ledger-b');
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);

      if (switchAccount) {
        expect(
          await container
              .read(accountSwitchCoordinatorProvider)
              .commitLogin(candidate: candidateB(), onReconnect: null),
          isTrue,
        );
      } else {
        await container.read(accountSwitchCoordinatorProvider).logout();
      }

      expect(await repo.getLedgerById('ledger-a'), isNull);
      expect(await downloads.pending(userA), isEmpty);
      expect(await downloads.pending(userB), {'ledger-b'});
    });
  }

  test('账号数据库清理失败时保留下载标记，不能把未清账本误认为已下载', () async {
    await seedAccountA(withPending: false);
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending(userA, 'ledger-a');
    await db.customStatement(
      "CREATE TRIGGER fail_purge BEFORE DELETE ON ledgers BEGIN SELECT RAISE(ABORT, 'purge failed'); END",
    );

    await expectLater(
      container.read(accountSwitchCoordinatorProvider).logout(),
      throwsA(anything),
    );

    expect(await repo.getLedgerById('ledger-a'), isNotNull);
    expect(await downloads.pending(userA), {'ledger-a'});
  });

  test('无凭证退出只清理内存会话，各账号下载标记与其他偏好保留', () async {
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending(userA, '尚未建库的账本');
    await downloads.markPending(userB, '已清库的账本');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local-test-preference', '保留');

    await container.read(accountSwitchCoordinatorProvider).logout();

    expect(await downloads.pending(userA), {'尚未建库的账本'});
    expect(await downloads.pending(userB), {'已清库的账本'});
    expect(prefs.getString('local-test-preference'), '保留');
  });

  test('无凭证启动只隔离身份，保留缓存、下载任务、未发布事实及其他偏好', () async {
    const cachedId = 'cached-cloud-ledger-a';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: cachedId,
            name: 'A 的未完整缓存账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(userA),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending(userA, cachedId);
    await downloads.markPending(userA, '尚未建库的账本');
    await downloads.markPending(userB, 'ledger-b');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local-test-preference', '保留');

    await container.read(accountBootstrapProvider.future);

    // 必需本地初始化完成后，由就绪生命周期触发会话恢复。

    unawaited(container.read(accountStartupRefreshProvider.future));

    expect(await repo.getLedgerById(cachedId), isNotNull);
    expect(await downloads.pending(userA), {cachedId, '尚未建库的账本'});
    expect(await downloads.unpublished(userA), {cachedId, '尚未建库的账本'});
    expect(await downloads.pending(userB), {'ledger-b'});
    expect(await downloads.unpublished(userB), {'ledger-b'});
    expect(prefs.getString('local-test-preference'), '保留');
    expect(container.read(syncGateProvider), isFalse);
  });

  test('运行期401只隔离身份，保留缓存、各账号下载任务、未发布事实及其他偏好', () async {
    await seedAccountA(withPending: false);
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending(userA, 'ledger-a');
    await downloads.markPending(userB, 'ledger-b');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local-test-preference', '保留');
    final isolated = Completer<void>();
    final subscription = container.listen(syncGateProvider, (_, held) {
      if (!held && !isolated.isCompleted) {
        isolated.complete();
      }
    });
    addTearDown(subscription.close);

    container.read(authSessionProvider.notifier).signOut();
    await isolated.future;

    expect(await repo.getLedgerById('ledger-a'), isNotNull);
    expect(await downloads.pending(userA), {'ledger-a'});
    expect(await downloads.unpublished(userA), {'ledger-a'});
    expect(await downloads.pending(userB), {'ledger-b'});
    expect(await downloads.unpublished(userB), {'ledger-b'});
    expect(prefs.getString('local-test-preference'), '保留');
    expect(container.read(syncGateProvider), isFalse);
  });

  test('A 的重新下载在途时换号排队，迟到快照先落 A 域再清理，旧点击不得写 B 域', () async {
    await seedAccountA(withPending: false);
    await (db.update(db.ledgers)..where((row) => row.id.equals('ledger-a')))
        .write(const LedgersCompanion(bindingStatus: d.Value('stale')));
    final requested = Completer<void>();
    final response = Completer<void>();
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          requested.complete();
          await response.future;
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'ledger': {
                  'id': 'ledger-a',
                  'owner_id': userA,
                  'sync_id': 'timeline-new',
                  'name': 'A 迟到快照',
                  'currency': 'CNY',
                  'month_start_day': 1,
                  'aa_enabled': false,
                  'updated_at': '2026-09-06T00:00:00.000Z',
                },
                'members': <Object>[],
                'transactions': <Object>[],
                'categories': <Object>[],
                'recurring_transactions': <Object>[],
                'exchange_rate_overrides': <Object>[],
                'server_cursor': '42',
              },
            ),
          );
        },
      ),
    );
    // 使用真实同步服务和数据库，网络响应在换号请求发出后才返回。
    service = SyncService(
      client: SesameApiClient(dio: dio),
      db: db,
      deviceId: 'device-a',
      repo: LocalLedgerRepository(db),
      localSelfIdLoader: () async => 'local-self',
      currentAccountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
    container.invalidate(syncServiceProvider);
    final actions = container.read(ledgerActionsProvider);
    final abandon = actions.abandonLocalChanges(ledgerId: 'ledger-a');
    await requested.future;
    final switching = container
        .read(accountSwitchCoordinatorProvider)
        .commitLogin(candidate: candidateB(), onReconnect: null);
    final oldClick = actions.resolveConflictAdoptRemote('old-conflict');
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authSessionProvider)?.userId, userA);
    expect(
      container.read(syncGateProvider),
      isFalse,
      reason: '等待在途 HTTP 时不得暂停刷新造成互相等待',
    );
    response.complete();
    expect((await abandon).ok, isTrue);
    expect(await switching, isTrue);
    expect((await oldClick).error, contains('账号'));
    expect(container.read(authSessionProvider)?.userId, userB);
    expect(
      await db.select(db.ledgers).get(),
      isEmpty,
      reason: 'A 的迟到快照必须被换号清理，不能留在 B 域',
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(await db.select(db.syncState).get(), isEmpty);
  });

  test('旧账号排队的退出请求不得清理或撤销后来提交的新账号', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA(withPending: false);
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    final release = Completer<void>();
    final waiting = container
        .read(syncCoordinatorProvider)
        .runAccountTransition(() => release.future);
    final accountSwitch = container.read(accountSwitchCoordinatorProvider);
    final switching = accountSwitch.commitLogin(
      candidate: candidateB(),
      onReconnect: null,
    );
    final oldLogout = accountSwitch.logout();
    final rejection = expectLater(oldLogout, throwsA(isA<StateError>()));
    release.complete();
    await waiting;
    expect(await switching, isTrue);
    await rejection;
    await pumpEventQueue();
    expect(container.read(authSessionProvider)?.userId, userB);
    expect(realtimeAccounts, [userB], reason: '过期退出只收尾最终有效身份');
    verifyNever(
      () => auth.revokeServerSession(
        any(
          that: isA<ActiveCredential>().having(
            (value) => value.userId,
            'userId',
            userB,
          ),
        ),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    );
  });

  test('连续提交 B 和 C 后，C 的首次恢复不能被 B 的过期恢复吞掉', () async {
    verifyRealtimeWriteBarrier = true;
    await seedAccountA(withPending: false);
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    final restoredAccounts = <String?>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/sync/accounting/full')) {
            restoredAccounts.add(container.read(authSessionProvider)?.userId);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'ledger_snapshots': [],
                  'categories': [],
                  'exchange_rate_overrides': [],
                  'deleted_exchange_rate_override_ids': [],
                  'server_cursor': '0',
                },
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'changes': <Object>[],
                  'server_cursor': '0',
                  'has_more': false,
                },
              ),
            );
          }
        },
      ),
    );
    service = SyncService(
      client: SesameApiClient(dio: dio),
      db: db,
      deviceId: 'device-c',
      currentAccountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
    container.invalidate(syncServiceProvider);
    final coordinator = container.read(syncCoordinatorProvider);
    final release = Completer<void>();
    final waiting = coordinator.runAccountTransition(() => release.future);
    final accountSwitch = container.read(accountSwitchCoordinatorProvider);
    final committingB = accountSwitch.commitLogin(
      candidate: candidateB(),
      onReconnect: coordinator.reconnect,
    );
    final committingC = accountSwitch.commitLogin(
      candidate: CandidateSession(
        session: const AuthSession(
          accessToken: 'token-c',
          userId: 'user-c',
          deviceId: 'device-c',
        ),
        refreshToken: 'refresh-c',
        profile: const CloudProfile(
          userId: 'user-c',
          sesameNumber: '333333333',
          displayName: 'C',
        ),
      ),
      onReconnect: coordinator.reconnect,
    );
    release.complete();
    await waiting;
    expect(await committingB, isTrue);
    expect(await committingC, isTrue);
    await coordinator.run();
    expect(container.read(authSessionProvider)?.userId, 'user-c');
    expect(restoredAccounts, contains('user-c'));
    expect(restoredAccounts, isNot(contains(userB)));
    await pumpEventQueue();
    expect(realtimeAccounts, ['user-c'], reason: '连续账号过渡只恢复最后生效的身份');
  });

  test('零财务云本时日子 OPEN 冲突仍阻止账号切换', () async {
    await seedAccountA(withPending: false);
    await (db.delete(
      db.ledgers,
    )..where((l) => l.storageMode.equals('cloud'))).go();
    const dayId = '11111111-1111-4111-8111-111111111111';
    await container
        .read(dayRepositoryProvider)
        .createBook(
          id: dayId,
          name: '日子',
          storageMode: 'cloud',
          accountId: userA,
        );
    await db.delete(db.syncChanges).go();
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'day-conflict',
            accountId: d.Value(userA),
            dayBookId: const d.Value(dayId),
            entityType: 'day_book',
            entityId: dayId,
            localPayload: '{}',
            remotePayload: '{}',
            baseRevision: 0,
            remoteRevision: 1,
            localMutationId: 'day-mutation',
          ),
        );
    final accepted = await container
        .read(accountSwitchCoordinatorProvider)
        .commitLogin(candidate: candidateB(), onReconnect: null);
    expect(accepted, isFalse);
    expect(
      (await container.read(secureAccountStoreProvider).load())!.userId,
      userA,
    );
  });

  test('备忘录退出保护原始卡片与时间，本机本不变，旧账号队列清理', () async {
    await seedAccountA(withPending: false);
    final memoRepo = container.read(memoRepositoryProvider);
    const cloud = '11111111-1111-4111-8111-111111111111';
    const local = '22222222-2222-4222-8222-222222222222';
    final time = DateTime.utc(2026, 9, 8, 12, 34, 56, 789);
    await memoRepo.createBook(
      id: cloud,
      name: '待保护',
      type: 'credentials',
      storageMode: 'cloud',
    );
    await memoRepo.createBook(id: local, name: '本机', type: 'normal');
    await memoRepo.saveEntry(
      memos.MemoEntry(
        id: '33333333-3333-4333-8333-333333333333',
        memoBookId: cloud,
        bookType: 'credentials',
        title: '账户',
        bodyJson: encodeMemoFields(const [
          MemoField(label: '账号', value: '  a\u0000 '),
          MemoField(label: '密码', value: ' \u0000😀\n '),
        ]),
        createdAt: time,
        updatedAt: time,
      ),
      await memoRepo.target(cloud),
      preserveTimes: true,
    );
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    await container
        .read(accountSwitchCoordinatorProvider)
        .logout(policy: AccountSwitchPolicy.safetyFork);
    final books = await db.select(db.memoBooks).get();
    expect(books, hasLength(2));
    expect(books.any((b) => b.id == local), isTrue);
    final copy = books.singleWhere((b) => b.sourceMemoBookId == cloud);
    expect(copy.id, isNot(cloud));
    expect(copy.storageMode, 'local');
    expect(copy.scopeAccountId, isNull);
    final card = await db.select(db.memoEntries).getSingle();
    expect(card.memoBookId, copy.id);
    expect(card.orderKey, 0);
    final fields = memoFieldsOf(jsonDecode(card.body!));
    expect(fields.map((field) => field.label).toList(), ['账号', '密码']);
    expect(fields[0].value, '  a\u0000 ');
    expect(fields[1].value, ' \u0000😀\n ');
    expect(card.createdAt, time);
    expect(card.updatedAt, time);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('备忘录离开守卫未完成时不切账号，拒绝后保留凭证', () async {
    await seedAccountA(withPending: false);
    final decision = Completer<bool>();
    container.read(memoEditorLeaveGuardsProvider).add(() => decision.future);
    final switching = container
        .read(accountSwitchCoordinatorProvider)
        .commitLogin(candidate: candidateB(), onReconnect: null);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authSessionProvider)?.userId, userA);
    decision.complete(false);
    expect(await switching, isFalse);
    expect(
      (await container.read(secureAccountStoreProvider).load())!.userId,
      userA,
    );
  });

  test('日子未确认内容先整本保护再清旧账号，原本机本保留', () async {
    await seedAccountA(withPending: false);
    await (db.delete(
      db.ledgers,
    )..where((l) => l.storageMode.equals('cloud'))).go();
    final dayRepo = container.read(dayRepositoryProvider);
    const cloud = '11111111-1111-4111-8111-111111111111';
    const local = '22222222-2222-4222-8222-222222222222';
    await dayRepo.createBook(
      id: cloud,
      name: '待保护',
      storageMode: 'cloud',
      accountId: userA,
    );
    await dayRepo.createBook(id: local, name: '本机');
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) async => SessionRevocationResult.revoked);
    await container
        .read(accountSwitchCoordinatorProvider)
        .logout(policy: AccountSwitchPolicy.safetyFork);
    final books = await db.select(db.dayBooks).get();
    expect(books, hasLength(2));
    expect(
      books.every((b) => b.storageMode == 'local' && b.scopeAccountId == null),
      isTrue,
    );
    expect(books.any((b) => b.id == local), isTrue);
    expect(
      books.singleWhere((b) => b.sourceDayBookId == cloud).id,
      isNot(cloud),
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  group('A→B 两阶段提交', () {
    test('A 有 pending 时默认阻断：B 不提交、A 凭证与数据域不变', () async {
      await seedAccountA();
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidateB(), onReconnect: null);
      expect(ok, isFalse, reason: '预检阻断 → 登录不成立');
      expect(await rawStore.read(), contains('refresh-a'), reason: 'A 凭证保持不变');
      expect(await rawPending.read(), isNull, reason: 'B 候选凭证已撤销清除');
      expect(
        container.read(accountStateProvider).status,
        AccountStatus.authenticated,
      );
      expect(container.read(accountStateProvider).profile?.userId, userA);
      expect(
        await repo.getLedgerById('ledger-a'),
        isNotNull,
        reason: 'A 云数据域保留',
      );
    });

    test('A 无 pending 时直接切换：purge A 域 → 原子提交 B', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidateB(), onReconnect: null);
      expect(ok, isTrue);
      // B 凭证提交、会话生效
      expect(await rawStore.read(), contains('refresh-b'));
      expect(container.read(authSessionProvider)?.userId, userB);
      expect(container.read(accountStateProvider).profile?.userId, userB);
      // A 数据域已清（重登 A 从云端恢复）
      expect(await repo.getLedgerById('ledger-a'), isNull);
      // A 会话撤销调用
      verify(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(1);
    });

    test('A 有 pending 时 safetyFork：批量保护 A 云账本后再切换', () async {
      await seedAccountA();
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(
            candidate: candidateB(),
            onReconnect: null,
            policy: AccountSwitchPolicy.safetyFork,
          );
      expect(ok, isTrue);
      expect(await rawStore.read(), contains('refresh-b'));
      // Safety Fork：A 的云端账本已有本地保护副本（LOCAL、origin 溯源）
      final localLedgers =
          await (db.select(db.ledgers)..where(
                (l) =>
                    l.storageMode.equals('local') &
                    l.originLedgerId.isNotNull(),
              ))
              .get();
      expect(localLedgers, hasLength(1), reason: 'A 的 pending 账本必须生成保护副本');
      expect(localLedgers.single.originType, 'DR_PROTECT');
    });

    test('A→B 切换只清理 A 的云账本，B 的缓存保留', () async {
      await seedAccountA(withPending: false);
      final otherId = await seedAccountCloudLedger('B 云账本', userB);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidateB(), onReconnect: null);
      expect(ok, isTrue);
      expect(await repo.getLedgerById('ledger-a'), isNull, reason: 'A 域云账本已清');
      expect(
        await repo.getLedgerById(otherId),
        isNotNull,
        reason: '其他账号的云账本缓存保持隔离',
      );
    });

    test('同账号重新登录：不 purge 数据域，只原子轮换凭证束', () async {
      await seedAccountA(withPending: false);
      final candidate = CandidateSession(
        session: const AuthSession(
          accessToken: 'token-a2',
          userId: userA,
          deviceId: 'device-a',
        ),
        refreshToken: 'refresh-a2',
        profile: const CloudProfile(
          userId: userA,
          sesameNumber: '111111111',
          displayName: 'A2',
        ),
      );
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidate, onReconnect: null);
      expect(ok, isTrue);
      expect(
        await rawStore.read(),
        contains('refresh-a2'),
        reason: '同账号只轮换凭证束',
      );
      expect(
        await repo.getLedgerById('ledger-a'),
        isNotNull,
        reason: '同账号不 purge 数据域',
      );
      verifyNever(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      );
    });
  });

  group('登出顺序', () {
    for (final switchAccount in [false, true]) {
      test('${switchAccount ? '切号' : '退出'}已提交时远端撤销挂起不阻塞本机写入', () async {
        await seedAccountA(withPending: false);
        final entered = Completer<void>();
        final response = Completer<SessionRevocationResult>();
        when(
          () => auth.revokeServerSession(
            any(),
            persistRotatedCredential: any(named: 'persistRotatedCredential'),
          ),
        ).thenAnswer((_) {
          expect(container.read(syncGateProvider), isFalse);
          entered.complete();
          return response.future;
        });
        final coordinator = container.read(accountSwitchCoordinatorProvider);
        final transition = switchAccount
            ? coordinator.commitLogin(
                candidate: candidateB(),
                onReconnect: null,
              )
            : coordinator.logout();
        try {
          await entered.future;
          // 服务端回执仍挂起，本地账号提交必须已经返回且写入屏障已经释放。
          await expectLater(
            transition.timeout(const Duration(seconds: 1)),
            completes,
          );
          expect(response.isCompleted, isFalse);
          expect(
            container.read(currentAccountIdProvider),
            switchAccount ? userB : null,
          );
          expect(await rawMarker.read(), isNotNull);
          final localId = await container
              .read(syncCoordinatorProvider)
              .runDataMutation(
                () =>
                    repo.createLedger(name: '撤销期间的本机账本', storageMode: 'local'),
              );
          expect((await repo.getLedgerById(localId))!.storageMode, 'local');
        } finally {
          response.complete(SessionRevocationResult.revoked);
          await transition;
          await pumpEventQueue();
        }
        expect(await rawMarker.read(), isNull);
      });
    }

    test('候选撤销待办写失败时保留候选槽，启动后仍能撤销且不影响当前账号', () async {
      await seedAccountA();
      rawMarker.failWrite = true;
      expect(
        await container
            .read(accountSwitchCoordinatorProvider)
            .commitLogin(candidate: candidateB(), onReconnect: null),
        isFalse,
      );
      expect(
        await rawPending.read(),
        contains('refresh-b'),
        reason: '尚无持久撤销待办时，候选槽是唯一安全重试材料',
      );
      rawMarker.failWrite = false;
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await container.read(accountRecoveryProvider.future);
      expect(await rawPending.read(), isNull);
      expect(await rawMarker.read(), isNull);
      expect(await rawStore.read(), contains('refresh-a'));
      expect(container.read(authSessionProvider)?.userId, userA);
      verify(
        () => auth.revokeServerSession(
          any(
            that: isA<ActiveCredential>().having(
              (value) => value.userId,
              'userId',
              userB,
            ),
          ),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(1);
    });

    test('撤销材料落盘失败时保留当前凭证和账号数据，允许用户重试', () async {
      await seedAccountA(withPending: false);
      rawMarker.failWrite = true;
      await expectLater(
        container.read(accountSwitchCoordinatorProvider).logout(),
        throwsA(isA<StateError>()),
      );
      expect(await rawStore.read(), contains('refresh-a'));
      expect(await repo.getLedgerById('ledger-a'), isNotNull);
      expect(container.read(authSessionProvider)?.userId, userA);
    });

    test('本地清理未完成时启动恢复不能撤销仍在使用的账号', () async {
      await seedAccountA(withPending: false);
      await container
          .read(secureAccountStoreProvider)
          .saveLogoutMarker(LogoutMarker(credential: credentialA()));
      await container.read(accountRecoveryProvider.future);
      expect(await rawStore.read(), contains('refresh-a'));
      expect(await rawMarker.read(), contains('refresh-a'));
      verifyNever(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      );
    });

    test('撤销暂时失败时安全槽保留轮换凭证，当前账号凭证仍为空', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((invocation) async {
        final persist =
            invocation.namedArguments[#persistRotatedCredential]
                as Future<void> Function(ActiveCredential);
        await persist(
          const ActiveCredential(
            userId: userA,
            deviceId: 'device-a',
            refreshToken: 'rotated-a',
          ),
        );
        throw StateError('网络不可用');
      });
      await container.read(accountSwitchCoordinatorProvider).logout();
      await pumpEventQueue();
      expect(await rawStore.read(), isNull);
      expect(await rawMarker.read(), contains('rotated-a'));
      expect(await rawMarker.read(), isNot(contains('refresh-a')));
      expect(container.read(authSessionProvider), isNull);
    });

    test('离线退出后跨启动保留撤销材料，服务端确认后才删除', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
          type: DioExceptionType.connectionError,
        ),
      );
      await container.read(accountSwitchCoordinatorProvider).logout();
      await pumpEventQueue();
      expect(await rawStore.read(), isNull);
      expect(await repo.getLedgerById('ledger-a'), isNull);
      expect(container.read(authSessionProvider), isNull);

      /// 重新装配启动恢复，仅复用落盘数据，不复用内存状态。
      Future<void> restartRecovery() async {
        final restarted = ProviderContainer(
          overrides: [
            apiConfigProvider.overrideWithValue(
              const ApiConfig(baseUrl: 'https://example.test'),
            ),
            authServiceProvider.overrideWithValue(auth),
            repositoryProvider.overrideWithValue(repo),
            secureAccountStoreProvider.overrideWithValue(
              SecureAccountStore(
                rawStore,
                pendingStore: rawPending,
                logoutMarkerStore: rawMarker,
              ),
            ),
          ],
        );
        try {
          await restarted.read(accountRecoveryProvider.future);
          expect(restarted.read(authSessionProvider), isNull);
        } finally {
          restarted.dispose();
        }
      }

      await restartRecovery();
      expect(
        await rawMarker.read(),
        contains('refresh-a'),
        reason: '重启仍离线时不能丢掉唯一的安全撤销材料',
      );
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await restartRecovery();
      expect(await rawMarker.read(), isNull);
      expect(await rawStore.read(), isNull);
      verify(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(3);
    });

    test('离线切换后退出另一个账号，两个待撤销会话都可恢复', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenThrow(StateError('网络不可用'));
      expect(
        await container
            .read(accountSwitchCoordinatorProvider)
            .commitLogin(candidate: candidateB(), onReconnect: null),
        isTrue,
      );
      expect(await rawMarker.read(), contains('refresh-a'));
      await container.read(accountSwitchCoordinatorProvider).logout();
      await pumpEventQueue();
      expect(await rawMarker.read(), contains('refresh-a'));
      expect(await rawMarker.read(), contains('refresh-b'));
      expect(await rawStore.read(), isNull);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await container.read(accountRecoveryProvider.future);
      expect(await rawMarker.read(), isNull);
      verify(
        () => auth.revokeServerSession(
          any(
            that: isA<ActiveCredential>().having(
              (value) => value.userId,
              'userId',
              userA,
            ),
          ),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(2);
      verify(
        () => auth.revokeServerSession(
          any(
            that: isA<ActiveCredential>().having(
              (value) => value.userId,
              'userId',
              userB,
            ),
          ),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(2);
    });

    test('正常登出：本机清理完成后后台撤销并清除 marker', () async {
      await seedAccountA(withPending: false);
      final localId = await repo.createLedger(
        name: '本机账本',
        storageMode: 'local',
        localSelfId: 'local-self',
      );
      final membersBefore = await (db.select(
        db.ledgerMembers,
      )..where((member) => member.ledgerId.equals(localId))).get();
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await container.read(accountSwitchCoordinatorProvider).logout();
      expect(await rawStore.read(), isNull, reason: 'ActiveCredential 已删除');
      await pumpEventQueue();
      expect(await rawMarker.read(), isNull, reason: '撤销成功后 marker 清除');
      expect(container.read(accountStateProvider).status, AccountStatus.local);
      expect(
        await (db.select(
          db.ledgerMembers,
        )..where((member) => member.ledgerId.equals(localId))).get(),
        membersBefore,
        reason: '退出不重写本机成员身份、绑定或修改时间',
      );
      expect(
        await repo.getLedgerById('ledger-a'),
        isNull,
        reason: 'A 云数据域已 purge',
      );
      verify(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).called(1);
    });

    test('正常登出：云账本删除后同步冲突与拉取错误也必须清理', () async {
      await seedAccountA(withPending: false);
      final now = DateTime.now().toUtc();
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: 'resolved-conflict-a',
              accountId: d.Value(userA),
              ledgerId: d.Value('ledger-a'),
              entityType: 'transaction',
              entityId: 'tx-a',
              localPayload: '{}',
              remotePayload: '{}',
              baseRevision: 1,
              remoteRevision: 2,
              localMutationId: 'mutation-a',
              status: const d.Value('RESOLVED_REMOTE'),
              resolvedAt: d.Value(now),
            ),
          );
      await db
          .into(db.syncPullErrors)
          .insert(
            SyncPullErrorsCompanion.insert(
              changeId: 'change-a',
              accountId: d.Value(userA),
              ledgerId: const d.Value('ledger-a'),
              entityType: 'transaction',
              entityId: 'tx-a',
              action: 'upsert',
              rawChangeJson: '{}',
              firstSeenAt: now,
              lastAttemptAt: now,
            ),
          );
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);

      await container.read(accountSwitchCoordinatorProvider).logout();

      expect(await db.select(db.syncConflicts).get(), isEmpty);
      expect(await db.select(db.syncPullErrors).get(), isEmpty);
    });

    test('服务端撤销失败：本地登出完成，marker 保留为 pending revocation', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenThrow(StateError('网络不可用'));
      await container.read(accountSwitchCoordinatorProvider).logout();
      expect(await rawStore.read(), isNull, reason: '本地登出完成');
      expect(container.read(accountStateProvider).status, AccountStatus.local);
      final marker = await rawMarker.read();
      expect(marker, isNotNull, reason: '撤销失败保留 marker（pending revocation）');
      expect(marker, contains('refresh-a'));
    });

    test('pending 预检阻断登出：A 凭证与数据域保留', () async {
      await seedAccountA();
      await expectLater(
        container.read(accountSwitchCoordinatorProvider).logout(),
        throwsA(isA<PendingChangesBlockedException>()),
      );
      expect(await rawStore.read(), contains('refresh-a'));
      expect(await repo.getLedgerById('ledger-a'), isNotNull);
      expect(
        container.read(accountStateProvider).status,
        AccountStatus.authenticated,
      );
    });

    test('safetyFork 登出：本地副本保护后账号域清理完成', () async {
      await seedAccountA();
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      await container
          .read(accountSwitchCoordinatorProvider)
          .logout(policy: AccountSwitchPolicy.safetyFork);
      expect(await rawStore.read(), isNull);
      final localLedgers =
          await (db.select(db.ledgers)..where(
                (l) =>
                    l.storageMode.equals('local') &
                    l.originLedgerId.isNotNull(),
              ))
              .get();
      expect(localLedgers, hasLength(1));
      expect(
        await repo.getLedgerById('ledger-a'),
        isNull,
        reason: '云端副本已清理，保护副本保留',
      );
    });

    test('登出只清理 A 的云账本，B 的账本及交易保留', () async {
      await seedAccountA(withPending: false);
      final otherId = await seedAccountCloudLedger('B 云账本', userB);
      // 直接落库交易（不登记同步变更）：保持无 pending 状态以便登出直达 purge。
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: const Uuid().v4(),
              ledgerId: otherId,
              txType: 'expense',
              amount: '5.00',
              currencyCode: 'CNY',
              nativeAmount: '5.00',
              happenedAt: DateTime(2026, 7, 5),
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);

      await container.read(accountSwitchCoordinatorProvider).logout();

      expect(await repo.getLedgerById('ledger-a'), isNull, reason: 'A 域云账本已清');
      expect(
        await repo.getLedgerById(otherId),
        isNotNull,
        reason: '其他账号的云账本缓存保持隔离',
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((t) => t.ledgerId.equals(otherId))).get(),
        hasLength(1),
        reason: '其他账号的交易不会随当前账号退出而删除',
      );
    });

    test('LOCAL 本地账本与 null scope 数据在任何清理中不动', () async {
      final localId = await repo.createLedger(
        name: '本地账本',
        storageMode: 'local',
        localSelfId: 'self-x',
      );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'local-cat',
              name: '本地分类',
              kind: 'expense',
              level: 1,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      // 无 A 凭证：直接清内存状态
      await container.read(accountSwitchCoordinatorProvider).logout();
      expect(
        await repo.getLedgerById(localId),
        isNotNull,
        reason: 'LOCAL 账本绝不触碰',
      );
      expect(
        await repo.categoryStore.getCategoryById('local-cat'),
        isNotNull,
        reason: 'null scope 分类保留',
      );
    });

    test('登出：已确认A来源的历史本地引用复制分类原ID，无引用账号分类清除', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      // 本地账本 + 交易引用账号域子分类（父链同属账号域）
      final localId = await repo.createLedger(
        name: '本地账本',
        storageMode: 'local',
        localSelfId: 'self-x',
      );
      await (db.update(db.ledgers)..where((l) => l.id.equals(localId))).write(
        const LedgersCompanion(originAccountId: d.Value(userA)),
      );
      final now = DateTime.now().toUtc();
      await db.batch((b) {
        b.insertAll(db.categories, [
          CategoriesCompanion.insert(
            id: 'acct-parent',
            name: '购物',
            kind: 'expense',
            level: 1,
            scopeAccountId: d.Value(userA),
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'acct-child',
            name: '服装',
            kind: 'expense',
            level: 2,
            parentId: d.Value('acct-parent'),
            scopeAccountId: d.Value(userA),
            updatedAt: now,
          ),
          CategoriesCompanion.insert(
            id: 'acct-unused',
            name: '无引用',
            kind: 'expense',
            level: 1,
            scopeAccountId: d.Value(userA),
            updatedAt: now,
          ),
        ]);
      });
      // 直接构造已有明确来源的历史弱引用，现代记账入口只接受该账本本地目录。
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'legacy-local-reference',
              ledgerId: localId,
              txType: 'expense',
              amount: '1.00',
              happenedAt: DateTime(2026, 7, 5),
              categoryId: const d.Value('acct-child'),
              currencyCode: 'CNY',
              nativeAmount: '1.00',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await container.read(accountSwitchCoordinatorProvider).logout();

      // 本地副本连同父链保留原 UUID，账号原目录按退出清理规则独立处理。
      final child = await (db.select(
        db.categories,
      )..where((c) => c.id.equals('acct-child'))).getSingle();
      expect(
        child.scopeAccountId,
        isNull,
        reason: '本地账本引用的账号域分类登出后迁回本地域，交易引用不悬空',
      );
      final parent = await (db.select(
        db.categories,
      )..where((c) => c.id.equals('acct-parent'))).getSingle();
      expect(parent.scopeAccountId, isNull, reason: '父链随子分类一并保留，避免父级悬空');
      // 无引用的账号域分类照旧删除（账号隔离）
      expect(
        await (db.select(
          db.categories,
        )..where((c) => c.id.equals('acct-unused'))).getSingleOrNull(),
        isNull,
        reason: '无本地引用的账号域分类随登出清除',
      );
      // 本地账本交易引用完好
      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(localId))).getSingle();
      expect(tx.categoryId, 'acct-child', reason: '交易分类引用在登出后仍有效');
    });
  });
  for (final phase in ['unsubmitted', 'frozen', 'unknown-resolution']) {
    test('默认分类 A→B→A 保留 $phase 原意图且B不见A候选', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(
          any(),
          persistRotatedCredential: any(named: 'persistRotatedCredential'),
        ),
      ).thenAnswer((_) async => SessionRevocationResult.revoked);
      const category = '10000000-0000-4000-8000-000000000001';
      final token = 'a' * 64;
      final original = jsonEncode({
        'name': 'A未确认饮食',
        'kind': 'expense',
        'level': '1',
        'sort_order': 9,
        'icon': null,
        'parent_id': null,
        'updated_at': '2026-01-01T00:00:00.123Z',
        'base_token': token,
      });
      final frozen = phase == 'unsubmitted'
          ? null
          : jsonEncode({
              'payload': jsonDecode(original),
              'mutation_id': 'A-intent',
            });
      final resolution = phase == 'unknown-resolution'
          ? jsonEncode({
              'mutation_id': 'A-resolve',
              'expected_cloud_token': token,
              'choice': 'cloud',
            })
          : null;
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: category,
              name: 'A未确认饮食',
              kind: 'expense',
              level: 1,
              updatedAt: DateTime.utc(2026),
              scopeAccountId: const d.Value(userA),
              serverVersionToken: d.Value(token),
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: category,
              action: 'upsert',
              payload: original,
              updatedAt: DateTime.utc(2026),
              mutationId: 'A-intent',
              accountId: const d.Value(userA),
              frozenRequest: d.Value(frozen),
            ),
          );
      if (phase == 'unknown-resolution') {
        await db
            .into(db.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                id: 'A-candidate',
                entityType: 'category',
                entityId: category,
                localPayload: original,
                remotePayload: '{}',
                baseRevision: 0,
                remoteRevision: 1,
                localMutationId: 'A-intent',
                accountId: const d.Value(userA),
                resolutionRequest: d.Value(resolution),
              ),
            );
      }
      final coordinator = container.read(accountSwitchCoordinatorProvider);
      expect(
        await coordinator.commitLogin(
          candidate: candidateB(),
          onReconnect: null,
          policy: AccountSwitchPolicy.safetyFork,
        ),
        isTrue,
      );
      expect(
        await repo.categoryStore.getAllCategories(),
        isEmpty,
        reason: 'B管理目录不能读取A待确认分类',
      );
      expect(
        (await (db.select(
          db.categories,
        )..where((c) => c.scopeAccountId.equals(userA))).getSingle()).name,
        'A未确认饮食',
        reason: 'A原分类身份保留在A目录，不能为了换号丢弃待确认内容',
      );
      expect(
        (await readSyncIssues(
          db,
          account: userB,
        )).where((i) => i.target.type == 'category'),
        isEmpty,
      );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: category,
              name: 'B的饮食',
              kind: 'expense',
              level: 1,
              updatedAt: DateTime.utc(2026),
              scopeAccountId: const d.Value(userB),
              serverVersionToken: d.Value('b' * 64),
            ),
          );
      final candidateA = CandidateSession(
        session: const AuthSession(
          accessToken: 'new-a',
          userId: userA,
          deviceId: 'device-a',
        ),
        refreshToken: 'new-a',
        profile: const CloudProfile(
          userId: userA,
          sesameNumber: '111111111',
          displayName: 'A',
        ),
      );
      expect(
        await coordinator.commitLogin(
          candidate: candidateA,
          onReconnect: null,
          policy: AccountSwitchPolicy.safetyFork,
        ),
        isTrue,
      );
      final row = await (db.select(
        db.syncChanges,
      )..where((c) => c.mutationId.equals('A-intent'))).getSingle();
      expect(row.payload, original);
      expect(row.frozenRequest, frozen);
      expect(row.accountId, userA);
      expect(
        (await repo.categoryStore.getAllCategories()).single.name,
        'A未确认饮食',
      );
      expect(
        await (db.select(
          db.categories,
        )..where((c) => c.scopeAccountId.equals(userB))).get(),
        isEmpty,
        reason: '重新登录A只提供A自己的原分类，B已确认缓存独立清理',
      );
      if (resolution != null) {
        final candidate = await db.select(db.syncConflicts).getSingle();
        expect(candidate.resolutionRequest, resolution);
        expect(candidate.localPayload, original);
        expect(
          (await readSyncIssues(
            db,
            account: userA,
          )).where((i) => i.id == 'A-candidate'),
          hasLength(1),
        );
      }
    });
  }
}
