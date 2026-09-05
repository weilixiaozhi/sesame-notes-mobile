// 账号切换协调器：两阶段提交 / pending 预检 / 登出顺序测试。
//
// 锚点（14.1-14.3）：
//   - A→B 切换先预检 A 的 pending/conflict：block 阻断、safetyFork 批量保护；
//   - 登出顺序：marker → purge → 清凭证 → 内存失效 → 服务端撤销；
//   - purge 失败保留 A 可重试；
//   - LOCAL 账本与 null scope 数据在任何清理中一行不动。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

class _MemorySecureStore implements SecureStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
  @override
  Future<void> delete() async => value = null;
}

class _MockAuthService extends Mock implements AuthService {}

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

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
  late _MockSyncCoordinator sync;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => userA),
    );
    rawStore = _MemorySecureStore();
    rawPending = _MemorySecureStore();
    rawMarker = _MemorySecureStore();
    auth = _MockAuthService();
    sync = _MockSyncCoordinator();
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        syncCoordinatorProvider.overrideWithValue(sync),
        databaseProvider.overrideWithValue(db),
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
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 直接经 db 层插入 scope_account_id 为 NULL 的存量云端账本：
  /// 模拟账号域架构上线前落库、从未回填 scope 的历史数据。
  Future<String> seedLegacyNullScopeCloudLedger(String name) async {
    final id = const Uuid().v4();
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            storageMode: const d.Value('cloud'),
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
          credential: credentialA(),
          profile: const CloudProfile(
            userId: userA,
            sesameNumber: '111111111',
            displayName: 'A',
          ),
        );
    const ledgerId = 'ledger-a';
    await repo.createBoundLedger(id: ledgerId, name: 'A 云账本', syncId: 'sync-a');
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
      LedgersCompanion(scopeAccountId: d.Value(userA)),
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
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});
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
      verify(() => auth.revokeServerSession(any())).called(1);
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

    test('A→B 切换 purge 按 storage_mode 选区：NULL scope 存量云账本同样清除', () async {
      await seedAccountA(withPending: false);
      final legacyId = await seedLegacyNullScopeCloudLedger('存量云账本');
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});
      final ok = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(candidate: candidateB(), onReconnect: null);
      expect(ok, isTrue);
      expect(await repo.getLedgerById('ledger-a'), isNull, reason: 'A 域云账本已清');
      expect(
        await repo.getLedgerById(legacyId),
        isNull,
        reason: 'scope 为 NULL 的云端账本同样按 storage_mode 清除',
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
      verifyNever(() => auth.revokeServerSession(any()));
    });
  });

  group('登出顺序', () {
    test('正常登出：marker → purge → 清凭证 → 撤销 → 清 marker', () async {
      await seedAccountA(withPending: false);
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});
      await container.read(accountSwitchCoordinatorProvider).logout();
      expect(await rawStore.read(), isNull, reason: 'ActiveCredential 已删除');
      expect(await rawMarker.read(), isNull, reason: '撤销成功后 marker 清除');
      expect(container.read(accountStateProvider).status, AccountStatus.local);
      expect(
        await repo.getLedgerById('ledger-a'),
        isNull,
        reason: 'A 云数据域已 purge',
      );
      verify(() => auth.revokeServerSession(any())).called(1);
    });

    test('正常登出：云账本删除后同步冲突与拉取错误也必须清理', () async {
      await seedAccountA(withPending: false);
      final now = DateTime.now().toUtc();
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: 'resolved-conflict-a',
              ledgerId: 'ledger-a',
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
              ledgerId: const d.Value('ledger-a'),
              entityType: 'transaction',
              entityId: 'tx-a',
              action: 'upsert',
              rawChangeJson: '{}',
              firstSeenAt: now,
              lastAttemptAt: now,
            ),
          );
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});

      await container.read(accountSwitchCoordinatorProvider).logout();

      expect(await db.select(db.syncConflicts).get(), isEmpty);
      expect(await db.select(db.syncPullErrors).get(), isEmpty);
    });

    test('服务端撤销失败：本地登出完成，marker 保留为 pending revocation', () async {
      await seedAccountA(withPending: false);
      when(
        () => auth.revokeServerSession(any()),
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
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});
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

    test('登出 purge 按 storage_mode 选区：NULL scope 存量云账本必须整本清除', () async {
      await seedAccountA(withPending: false);
      final legacyId = await seedLegacyNullScopeCloudLedger('存量云账本');
      // 直接落库交易（不登记同步变更）：保持无 pending 状态以便登出直达 purge。
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: const Uuid().v4(),
              ledgerId: legacyId,
              txType: 'expense',
              amount: '5.00',
              currencyCode: 'CNY',
              nativeAmount: '5.00',
              happenedAt: DateTime(2026, 7, 5),
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});

      await container.read(accountSwitchCoordinatorProvider).logout();

      expect(await repo.getLedgerById('ledger-a'), isNull, reason: 'A 域云账本已清');
      expect(
        await repo.getLedgerById(legacyId),
        isNull,
        reason: 'scope 为 NULL 的云端账本同样按 storage_mode 清除',
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((t) => t.ledgerId.equals(legacyId))).get(),
        isEmpty,
        reason: '存量云账本交易随账本级联清除',
      );
    });

    test('无凭证登出：存量云端账本仍整本清除，本地账本不动', () async {
      final legacyId = await seedLegacyNullScopeCloudLedger('存量云账本');
      final localId = await repo.createLedger(
        name: '本地账本',
        storageMode: 'local',
        localSelfId: 'self-x',
      );

      await container.read(accountSwitchCoordinatorProvider).logout();

      expect(
        await repo.getLedgerById(legacyId),
        isNull,
        reason: '无凭证退出登录同样整本清除云端账本（P0-1）',
      );
      expect(await repo.getLedgerById(localId), isNotNull, reason: '本地账本一行不动');
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
        await repo.getCategoryById('local-cat'),
        isNotNull,
        reason: 'null scope 分类保留',
      );
    });

    test('登出：被本地账本引用的账号域分类迁移回本地域，无引用分类照旧删除', () async {
      await seedAccountA(withPending: false);
      when(() => auth.revokeServerSession(any())).thenAnswer((_) async {});
      // 本地账本 + 交易引用账号域子分类（父链同属账号域）
      final localId = await repo.createLedger(
        name: '本地账本',
        storageMode: 'local',
        localSelfId: 'self-x',
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
      await repo.addTransaction(
        ledgerId: localId,
        type: 'expense',
        amount: '1.00',
        happenedAt: DateTime(2026, 7, 5),
        categoryId: 'acct-child',
      );

      await container.read(accountSwitchCoordinatorProvider).logout();

      // 被本地账本引用的分类连同父链保留，scope 迁回本地域（同一行不克隆）
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
}
