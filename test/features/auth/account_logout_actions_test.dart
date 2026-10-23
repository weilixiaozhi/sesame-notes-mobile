import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/features/auth/application/account_logout_actions.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/sync_issues_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 只替换账号与网络边界，验证真实退出决策的业务结果。
class _AccountCoordinator extends Mock implements AccountSwitchCoordinator {}

/// 同步动作必须复用现有协调器，不得另发请求。
class _SyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  late _AccountCoordinator account;
  late _SyncCoordinator sync;
  late ProviderContainer container;
  var identityGeneration = 0;

  setUp(() {
    account = _AccountCoordinator();
    sync = _SyncCoordinator();
    identityGeneration = 0;
    when(() => account.logout()).thenThrow(
      const PendingChangesBlockedException(
        ledgerChangeCount: 3,
        userGlobalChangeCount: 0,
        openConflictCount: 0,
      ),
    );
    when(
      () => account.logout(policy: AccountSwitchPolicy.safetyFork),
    ).thenAnswer((_) async {});
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult());
    container = ProviderContainer(
      overrides: [
        authIdentityGenerationProvider.overrideWith((_) => identityGeneration),
        accountSwitchCoordinatorProvider.overrideWithValue(account),
        syncCoordinatorProvider.overrideWithValue(sync),
        syncIssuesProvider.overrideWith(
          (_) async => [
            for (final (name, count) in [('家庭日子', 1), ('工作日子', 2)])
              SyncIssue(
                id: name,
                kind: SyncIssueKind.pendingUpload,
                target: SyncTarget('day_book', name),
                title: name,
                count: count,
              ),
          ],
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  AccountLogoutSession start() =>
      container.read(accountLogoutActionsProvider).start();

  test('待处理修改阻断默认退出时绝不改用保护副本退出', () async {
    final session = start();

    await expectLater(
      session.logout(),
      throwsA(isA<PendingChangesBlockedException>()),
    );

    verifyNever(() => account.logout(policy: AccountSwitchPolicy.safetyFork));
    verifyNever(() => sync.refreshData());
  });

  test('待处理来源统一展示：数量与名称原样返回', () async {
    final issues = await start().loadPendingIssues();

    expect(issues.map((issue) => issue.title), ['家庭日子', '工作日子']);
    expect(issues.fold(0, (total, issue) => total + issue.count), 3);
  });

  test('先同步只调用统一同步协调器，保留当前登录不退出', () async {
    final session = start();

    expect(await session.synchronizeFirst(), isFalse);

    verify(() => sync.refreshData()).called(1);
    verifyNever(() => account.logout(policy: AccountSwitchPolicy.safetyFork));
  });

  test('同步未完成不得继续退出', () async {
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult(error: 'network down'));
    final session = start();

    await expectLater(session.synchronizeFirst(), throwsA(isA<StateError>()));

    verifyNever(() => account.logout(policy: AccountSwitchPolicy.safetyFork));
  });

  test('保护副本失败不得报告退出成功', () async {
    when(
      () => account.logout(policy: AccountSwitchPolicy.safetyFork),
    ).thenThrow(StateError('保护写入失败'));
    final session = start();

    await expectLater(
      session.keepLocalCopyAndLogout(),
      throwsA(isA<StateError>()),
    );
  });

  test('确认期间身份变化：先同步不得对新账号执行', () async {
    final session = start();
    identityGeneration++;
    container.invalidate(authIdentityGenerationProvider);

    await expectLater(session.synchronizeFirst(), throwsA(isA<StateError>()));

    verifyNever(() => sync.refreshData());
    verifyNever(() => account.logout(policy: AccountSwitchPolicy.safetyFork));
  });

  test('确认期间身份变化：默认退出与保护副本退出都不得执行', () async {
    final session = start();
    identityGeneration++;
    container.invalidate(authIdentityGenerationProvider);

    await expectLater(session.logout(), throwsA(isA<StateError>()));
    await expectLater(
      session.keepLocalCopyAndLogout(),
      throwsA(isA<StateError>()),
    );

    verifyNever(() => account.logout());
    verifyNever(() => account.logout(policy: AccountSwitchPolicy.safetyFork));
  });
}
