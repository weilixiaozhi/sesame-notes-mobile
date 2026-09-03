/// 账本卡片同步状态 provider 测试。
///
/// 需求锚点：
/// - 状态由持久字段 + 会话 + 待推/冲突计数投影（纯函数已单测），provider 只负责取数；
/// - 同步轮结束（tick）后必须重算：push 标记 pushedAt 不发射业务数据信号，
///   没有 tick 卡片会停留在「待推送」；
/// - busy 信号在整轮同步（push→pull，含尾随补跑）期间保持 true，结束后复位。
library;

import 'dart:async';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/ledger_sync_status.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSyncService sync;
  late ProviderContainer container;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      // 测试登录用户为 'u'：待推 mutation 的账号域过滤依赖它。
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'u'),
    );
    sync = _MockSyncService();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  void signIn() {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
  }

  Future<void> seedPendingChange(String ledgerId) async {
    final tracker = repo.changeTracker!;
    await tracker.recordLedgerChange(
      entityType: 'transaction',
      entityId: 'tx-1',
      ledgerId: ledgerId,
      action: 'upsert',
      payload: '{}',
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> seedOpenConflict(String ledgerId) async {
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'c-1',
            ledgerId: ledgerId,
            entityType: 'transaction',
            entityId: 'tx-1',
            localPayload: '{}',
            remotePayload: '{}',
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'm-1',
          ),
        );
  }

  test('本地账本 → local（不画云）', () async {
    final id = await repo.createLedger(name: '本地账本', storageMode: 'local');

    final status = await container.read(ledgerSyncStatusProvider(id).future);

    expect(status, LedgerSyncStatus.local);
  });

  test('云账本无待推无冲突 → inSync', () async {
    await repo.createBoundLedger(id: 'cloud-1', name: '云账本');
    signIn();

    final status = await container.read(
      ledgerSyncStatusProvider('cloud-1').future,
    );

    expect(status, LedgerSyncStatus.inSync);
  });

  test('云账本有待推变更 → pendingPush（绿云）', () async {
    await repo.createBoundLedger(id: 'cloud-2', name: '云账本');
    signIn();
    await seedPendingChange('cloud-2');

    final status = await container.read(
      ledgerSyncStatusProvider('cloud-2').future,
    );

    expect(status, LedgerSyncStatus.pendingPush);
  });

  test('云账本存在 OPEN 冲突 → conflict（灰云）', () async {
    await repo.createBoundLedger(id: 'cloud-3', name: '云账本');
    signIn();
    await seedOpenConflict('cloud-3');

    final status = await container.read(
      ledgerSyncStatusProvider('cloud-3').future,
    );

    expect(status, LedgerSyncStatus.conflict);
  });

  test('云账本绑定失效 → staleBinding（灰云）', () async {
    await repo.createBoundLedger(id: 'cloud-4', name: '云账本');
    signIn();
    await (db.update(db.ledgers)..where((l) => l.id.equals('cloud-4'))).write(
      const LedgersCompanion(bindingStatus: d.Value('stale')),
    );

    final status = await container.read(
      ledgerSyncStatusProvider('cloud-4').future,
    );

    expect(status, LedgerSyncStatus.staleBinding);
  });

  test('云账本未登录 → notLoggedIn（灰云）', () async {
    await repo.createBoundLedger(id: 'cloud-5', name: '云账本');

    final status = await container.read(
      ledgerSyncStatusProvider('cloud-5').future,
    );

    expect(status, LedgerSyncStatus.notLoggedIn);
  });

  test('同步轮结束 tick 后重算：待推被标记已推送 → inSync', () async {
    await repo.createBoundLedger(id: 'cloud-6', name: '云账本');
    signIn();
    await seedPendingChange('cloud-6');
    expect(
      await container.read(ledgerSyncStatusProvider('cloud-6').future),
      LedgerSyncStatus.pendingPush,
    );

    // 模拟 push 成功：同步服务直接标记 pushedAt（不发射业务数据信号）。
    await (db.update(db.syncChanges)
          ..where((c) => c.ledgerId.equals('cloud-6')))
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())));

    expect(
      await container.read(ledgerSyncStatusProvider('cloud-6').future),
      LedgerSyncStatus.pendingPush,
      reason: 'pushedAt 标记不触发业务信号，tick 前不应重算',
    );

    container.read(syncRunTickProvider.notifier).tick();

    expect(
      await container.read(ledgerSyncStatusProvider('cloud-6').future),
      LedgerSyncStatus.inSync,
      reason: 'tick 后必须重算为已同步',
    );
  });

  test('busy 信号：整轮同步期间为 true，结束（含失败）后复位', () async {
    final gate = Completer<void>();
    when(() => sync.push()).thenAnswer((_) => gate.future);
    when(() => sync.pull()).thenAnswer((_) async => 0);
    expect(container.read(syncBusyProvider), isFalse);

    final run = container.read(syncCoordinatorProvider).run();
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(syncBusyProvider),
      isTrue,
      reason: '同步执行中 busy 必须为 true',
    );

    gate.complete();
    await run;
    expect(
      container.read(syncBusyProvider),
      isFalse,
      reason: '同步结束后 busy 必须复位',
    );
  });
}
