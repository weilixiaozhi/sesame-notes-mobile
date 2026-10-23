import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../../helpers/test_isolation.dart';

/// 邀请服务只返回受邀身份，首次快照由独立后台任务负责。
class _Sharing extends Mock implements SharingService {}

/// 验证前台接受邀请不调用同步协调器。
class _Coordinator extends Mock implements SyncCoordinator {}

/// 固定的邀请回执，不包含本地可展示内容。
PostInvitesByCodeAccept200Response _accepted() =>
    PostInvitesByCodeAccept200Response(
      (builder) => builder
        ..ledgerId = 'ledger-x'
        ..ledgerName = '旅行账本'
        ..role = PostInvitesByCodeAccept200ResponseRoleEnum.editor,
    );

/// 验证接受邀请只登记后台首次任务，并在异步边界保留原会话。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late _Sharing sharing;
  late _Coordinator coordinator;
  late ProviderContainer container;

  /// 可注入延迟持久化入口，测试账号或代次在写任务期间变化。
  ProviderContainer makeContainer({CloudLedgerDownloadStore? store}) =>
      ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          repositoryProvider.overrideWithValue(repo),
          sharingServiceProvider.overrideWithValue(sharing),
          syncCoordinatorProvider.overrideWithValue(coordinator),
          cloudNetworkEventsProvider.overrideWithValue(
            const Stream<bool>.empty(),
          ),
          if (store != null)
            cloudLedgerDownloadStoreProvider.overrideWithValue(store),
        ],
      );

  /// 每次登录均建立新的身份代次，同账号重新登录也会使旧意图失效。
  void signIn({String account = 'account-a', String token = 'token'}) {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          AuthSession(accessToken: token, userId: account, deviceId: 'device'),
        );
  }

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
    sharing = _Sharing();
    coordinator = _Coordinator();
    when(
      () => sharing.acceptInvite('ABC123'),
    ).thenAnswer((_) async => _accepted());
    container = makeContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await logger.clear();
  });

  test('未登录不接受邀请、不写任务、不提前发布账本', () async {
    await expectLater(
      container.read(ledgerActionsProvider).acceptInvite('ABC123'),
      throwsStateError,
    );
    verifyNever(() => sharing.acceptInvite('ABC123'));
    verifyZeroInteractions(coordinator);
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(
      await container
          .read(cloudLedgerDownloadStoreProvider)
          .pending('account-a'),
      isEmpty,
    );
  });

  test('接受成功只登记initial任务，不bootstrap也不发布空占位', () async {
    signIn();
    final actions = container.read(ledgerActionsProvider);
    await actions.acceptInvite('ABC123');
    final store = container.read(cloudLedgerDownloadStoreProvider);
    expect(await store.pending('account-a'), {'ledger-x'});
    expect(await store.unpublished('account-a'), {'ledger-x'});
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await actions.getById('ledger-x'), isNull);
    expect(await actions.getAll(), isEmpty);
    expect(await actions.getAllWithStats(), isEmpty);
    verify(() => sharing.acceptInvite('ABC123')).called(1);
    verifyZeroInteractions(coordinator);
  });

  test('API回执返回前同账号重新登录，旧意图不登记任务', () async {
    signIn();
    final started = Completer<void>();
    final response = Completer<PostInvitesByCodeAccept200Response>();
    when(() => sharing.acceptInvite('ABC123')).thenAnswer((_) {
      started.complete();
      return response.future;
    });
    final accepting = container
        .read(ledgerActionsProvider)
        .acceptInvite('ABC123');
    await started.future;
    final originalGeneration = container.read(authIdentityGenerationProvider);
    signIn(token: 'replacement-token');
    expect(
      container.read(authIdentityGenerationProvider),
      greaterThan(originalGeneration),
    );
    final rejected = expectLater(accepting, throwsStateError);
    response.complete(_accepted());
    await rejected;
    expect(
      await container
          .read(cloudLedgerDownloadStoreProvider)
          .pending('account-a'),
      isEmpty,
    );
    expect(await db.select(db.ledgers).get(), isEmpty);
    verifyZeroInteractions(coordinator);
  });

  for (final nextAccount in ['account-a', 'account-b']) {
    test('持久化任务期间登录$nextAccount，失效意图清理自身任务而保留其它任务', () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'cloud_pending_full:account-a:other-ledger',
        'initial',
      );
      final started = Completer<void>();
      final release = Completer<void>();
      final store = CloudLedgerDownloadStore(() async {
        if (!started.isCompleted) started.complete();
        await release.future;
        return preferences;
      });
      container.dispose();
      container = makeContainer(store: store);
      signIn();
      final originalGeneration = container.read(authIdentityGenerationProvider);
      final accepting = container
          .read(ledgerActionsProvider)
          .acceptInvite('ABC123');
      await started.future;
      signIn(account: nextAccount, token: 'replacement-token');
      expect(
        container.read(authIdentityGenerationProvider),
        greaterThan(originalGeneration),
      );
      final rejected = expectLater(accepting, throwsStateError);
      release.complete();
      await rejected;
      expect(await store.pending('account-a'), {'other-ledger'});
      expect(await store.unpublished('account-a'), {'other-ledger'});
      expect(await store.pending('account-b'), isEmpty);
      expect(await db.select(db.ledgers).get(), isEmpty);
      verifyZeroInteractions(coordinator);
    });
  }
}
