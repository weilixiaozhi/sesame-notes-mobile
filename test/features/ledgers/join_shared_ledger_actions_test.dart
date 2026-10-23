import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
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
import '../../helpers/bound_ledger_seed.dart';

/// API失败与重试由测试控制，成功只获得远端账本标识。
class _Sharing extends Mock implements SharingService {}

/// 前台接受邀请不得串行等待bootstrap或其它同步请求。
class _Coordinator extends Mock implements SyncCoordinator {}

/// 固定重复接受时返回相同账本身份。
PostInvitesByCodeAccept200Response _accepted() =>
    PostInvitesByCodeAccept200Response(
      (builder) => builder
        ..ledgerId = 'ledger-x'
        ..ledgerName = '旅行账本'
        ..role = PostInvitesByCodeAccept200ResponseRoleEnum.editor,
    );

/// 接受邀请前台只发布成功结果，数据展示由后台完整快照独立决定。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _Sharing sharing;
  late _Coordinator coordinator;
  late ProviderContainer container;
  late LedgerActions actions;

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(db, accountIdGetter: () => 'account');
    sharing = _Sharing();
    coordinator = _Coordinator();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
        syncCoordinatorProvider.overrideWithValue(coordinator),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    actions = container.read(ledgerActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await logger.clear();
  });

  test('重复接受成功保持同一initial任务，不生成提前展示的绑定行', () async {
    when(
      () => sharing.acceptInvite('ABC123'),
    ).thenAnswer((_) async => _accepted());
    await actions.acceptInvite('ABC123');
    await actions.acceptInvite('ABC123');
    final store = container.read(cloudLedgerDownloadStoreProvider);
    expect(await store.pending('account'), {'ledger-x'});
    expect(await store.unpublished('account'), {'ledger-x'});
    expect(await db.select(db.ledgers).get(), isEmpty);
    verify(() => sharing.acceptInvite('ABC123')).called(2);
    verifyZeroInteractions(coordinator);
  });

  test('已发布空云本再次接受邀请仅登记refresh，完整内容继续可见', () async {
    await seedBoundLedger(
      db,
      accountId: 'account',
      id: 'ledger-x',
      name: '已有完整空本',
    );
    when(
      () => sharing.acceptInvite('ABC123'),
    ).thenAnswer((_) async => _accepted());
    expect((await actions.getById('ledger-x'))!.name, '已有完整空本');
    expect(await db.select(db.transactions).get(), isEmpty);

    await actions.acceptInvite('ABC123');
    await actions.acceptInvite('ABC123');
    final store = container.read(cloudLedgerDownloadStoreProvider);
    expect(await store.pending('account'), {'ledger-x'});
    expect(await store.unpublished('account'), isEmpty);
    expect((await actions.getById('ledger-x'))!.name, '已有完整空本');
    expect((await actions.getAll()).single.id, 'ledger-x');
    expect((await actions.getAllWithStats()).single.transactionCount, 0);
    expect(await db.select(db.ledgers).get(), hasLength(1));
    verify(() => sharing.acceptInvite('ABC123')).called(2);
    verifyZeroInteractions(coordinator);
  });

  for (final networkFailure in [false, true]) {
    test('API${networkFailure ? '网络' : '业务'}失败不登记任务，重试成功后只保留一个后台任务', () async {
      var attempts = 0;
      final failure = networkFailure
          ? DioException(
              requestOptions: RequestOptions(path: '/invites/ABC123/accept'),
              type: DioExceptionType.receiveTimeout,
            )
          : StateError('INVITE_UNAVAILABLE');
      when(() => sharing.acceptInvite('ABC123')).thenAnswer((_) async {
        if (attempts++ == 0) throw failure;
        return _accepted();
      });
      await expectLater(actions.acceptInvite('ABC123'), throwsA(same(failure)));
      final store = container.read(cloudLedgerDownloadStoreProvider);
      expect(await store.pending('account'), isEmpty);
      expect(await store.unpublished('account'), isEmpty);
      expect(await db.select(db.ledgers).get(), isEmpty);
      await actions.acceptInvite('ABC123');
      expect(attempts, 2);
      expect(await store.pending('account'), {'ledger-x'});
      expect(await store.unpublished('account'), {'ledger-x'});
      expect(await db.select(db.ledgers).get(), isEmpty);
      verifyZeroInteractions(coordinator);
    });
  }
}
