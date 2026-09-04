/// 同步状态闸门（P1）测试。
///
/// 需求锚点：
/// - 退出登录 purge 云端账本期间必须暂停同步引擎（防 GC/WS 并发把刚清掉的
///   云端账本重新拉回），purge 完成后开闸；
/// - 闸门置起时 run/bootstrap 不得发起任何网络同步（LocalOnly 降级语义）；
/// - 无论 purge 成功或失败，闸门都必须恢复（finally 语义），否则同步永久停摆；
/// - 自动同步、实时通知和手动刷新并发触发时必须串行，且执行期的新触发
///   需要在当前轮结束后补跑，不能吞掉新写入；
/// - 统一刷新入口按账本存储模式决策：本地账本只重查，云账本才同步。
library;

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';

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
    repo = LocalRepository(db);
    sync = _MockSyncService();
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('闸门默认开启（false），hold/release 可切换', () {
    expect(container.read(syncGateProvider), isFalse, reason: '默认不暂停同步');
    container.read(syncGateProvider.notifier).hold();
    expect(container.read(syncGateProvider), isTrue);
    container.read(syncGateProvider.notifier).release();
    expect(container.read(syncGateProvider), isFalse);
  });

  test('闸门置起时 run 不发起任何同步（LocalOnly 降级）', () async {
    when(() => sync.push()).thenAnswer((_) async {});
    container.read(syncGateProvider.notifier).hold();

    final result = await container.read(syncCoordinatorProvider).run();

    verifyNever(() => sync.push());
    verifyNever(() => sync.pull());
    expect(result.error, isNotNull, reason: '暂停期间的同步必须返回错误说明');
  });

  test('闸门释放后 run 正常执行', () async {
    when(() => sync.push()).thenAnswer((_) async {});
    when(() => sync.pull()).thenAnswer((_) async => 0);

    container.read(syncGateProvider.notifier).hold();
    container.read(syncGateProvider.notifier).release();
    final result = await container.read(syncCoordinatorProvider).run();

    verify(() => sync.push()).called(1);
    verify(() => sync.pull()).called(1);
    expect(result.ok, isTrue);
  });

  test('并发 run 不重叠，并在首轮结束后合并补跑一次', () async {
    final firstPushGate = Completer<void>();
    var pushCalls = 0;
    var activeCalls = 0;
    var maxActiveCalls = 0;
    when(() => sync.push()).thenAnswer((_) async {
      pushCalls++;
      activeCalls++;
      if (activeCalls > maxActiveCalls) maxActiveCalls = activeCalls;
      if (pushCalls == 1) await firstPushGate.future;
      activeCalls--;
    });
    when(() => sync.pull()).thenAnswer((_) async => 0);

    final coordinator = container.read(syncCoordinatorProvider);
    final first = coordinator.run();
    await Future<void>.delayed(Duration.zero);
    final second = coordinator.run();
    final third = coordinator.run();

    expect(pushCalls, 1, reason: '首轮未完成时不得启动重叠 push');
    firstPushGate.complete();
    await Future.wait([first, second, third]);

    expect(maxActiveCalls, 1, reason: '所有同步入口必须由同一编排器串行执行');
    expect(pushCalls, 2, reason: '执行期的多个新触发应合并为一次尾随补跑');
    verify(() => sync.pull()).called(2);
  });

  test('统一刷新：本地账本不触网，但始终触发一次本地重查', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
    );
    final before = container.read(manualDataRefreshProvider);

    final result = await container
        .read(syncCoordinatorProvider)
        .refreshData(ledgerId: ledgerId);

    expect(result.ok, isTrue);
    verifyNever(() => sync.push());
    verifyNever(() => sync.pull());
    expect(container.read(manualDataRefreshProvider), before + 1);
  });

  test('统一刷新：账本列表在已登录且本地无云账本时仍执行账号级同步', () async {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
    when(() => sync.push()).thenAnswer((_) async {});
    when(() => sync.pull()).thenAnswer((_) async => 2);

    final result = await container.read(syncCoordinatorProvider).refreshData();

    expect(result.pulled, 2);
    verifyInOrder([() => sync.push(), () => sync.pull()]);
  });

  test('统一刷新：空账本标识与 null 一样执行已登录账号级同步', () async {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
    when(() => sync.push()).thenAnswer((_) async {});
    when(() => sync.pull()).thenAnswer((_) async => 1);

    final result = await container
        .read(syncCoordinatorProvider)
        .refreshData(ledgerId: '');

    expect(result.pulled, 1);
    verifyInOrder([() => sync.push(), () => sync.pull()]);
  });

  test('统一刷新：已登录云账本执行 push→pull，再触发本地重查', () async {
    const ledgerId = 'cloud-refresh';
    await repo.createBoundLedger(id: ledgerId, name: '云账本');
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
    when(() => sync.push()).thenAnswer((_) async {});
    when(() => sync.pull()).thenAnswer((_) async => 3);
    final before = container.read(manualDataRefreshProvider);

    final result = await container
        .read(syncCoordinatorProvider)
        .refreshData(ledgerId: ledgerId);

    expect(result.ok, isTrue);
    expect(result.pulled, 3);
    verifyInOrder([() => sync.push(), () => sync.pull()]);
    expect(container.read(manualDataRefreshProvider), before + 1);
  });

  test('统一刷新：云同步失败仍触发本地重查并返回失败结果', () async {
    const ledgerId = 'cloud-refresh-failed';
    await repo.createBoundLedger(id: ledgerId, name: '云账本');
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
    when(() => sync.push()).thenThrow(StateError('offline'));
    final before = container.read(manualDataRefreshProvider);

    final result = await container
        .read(syncCoordinatorProvider)
        .refreshData(ledgerId: ledgerId);

    expect(result.ok, isFalse, reason: '页面必须能区分同步失败，不能误报成功');
    expect(container.read(manualDataRefreshProvider), before + 1);
  });
}
