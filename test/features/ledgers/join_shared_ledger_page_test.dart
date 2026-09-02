/// 加入共享账本页（P1）行为测试。
///
/// 需求锚点：
/// - 未登录不能加入（提示先登录）；
/// - 输入邀请码 → 查询预览（账本名/角色/过期时间），失败给友好错误；
/// - 接受邀请 → 服务端接受 + 本地落云端绑定行（storage_mode='cloud'，
///   供后续 full 同步拉取账本数据）+ 成功提示。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/api/sharing_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/ledgers/presentation/join_shared_ledger_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../../helpers/test_isolation.dart';

class _MockSharingService extends Mock implements SharingService {}

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSharingService sharing;
  late _MockSyncCoordinator coordinator;
  late ProviderContainer container;

  void buildContainer({bool loggedIn = true}) {
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
        // 接受后触发的全量同步在测试中 mock 掉，避免真实 HTTP 请求。
        syncCoordinatorProvider.overrideWithValue(coordinator),
      ],
    );
    if (loggedIn) {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
          );
    }
  }

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    sharing = _MockSharingService();
    coordinator = _MockSyncCoordinator();
    when(
      () => coordinator.bootstrap(),
    ).thenAnswer((_) async => const SyncRunResult());
    buildContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<AppLocalizations> pump(WidgetTester tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const JoinSharedLedgerPage(),
        ),
      ),
    );
    await tester.pump();
    return l10n;
  }

  testWidgets('未登录：提示需先登录，不渲染邀请码输入', (tester) async {
    buildContainer(loggedIn: false);
    final l10n = await pump(tester);

    expect(find.text(l10n.joinSharedNeedLogin), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('查询邀请码成功：展示账本预览（名称/角色/过期时间）', (tester) async {
    final l10n = await pump(tester);

    when(() => sharing.queryInviteByCode('ABC123')).thenAnswer(
      (_) async => GetInvitesByCode200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = GetInvitesByCode200ResponseRoleEnum.editor
          ..expiresAt = DateTime.utc(2026, 9, 1),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abc123'); // 输入小写
    await tester.tap(find.text(l10n.joinSharedQuery));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('旅行账本'), findsOneWidget, reason: '预览必须展示账本名');
    expect(
      find.text(l10n.joinSharedAccept),
      findsOneWidget,
      reason: '查询成功后出现接受按钮',
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('查询失败：友好错误提示且不出现接受按钮', (tester) async {
    final l10n = await pump(tester);

    when(
      () => sharing.queryInviteByCode(any()),
    ).thenThrow(const FormatException('邀请码不存在'));

    await tester.enterText(find.byType(TextField), 'BAD000');
    await tester.tap(find.text(l10n.joinSharedQuery));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.joinSharedQueryFailed), findsOneWidget);
    expect(find.text(l10n.joinSharedAccept), findsNothing);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('接受邀请成功：服务端接受 + 本地落云端绑定行 + 成功提示', (tester) async {
    final l10n = await pump(tester);

    when(() => sharing.queryInviteByCode('ABC123')).thenAnswer(
      (_) async => GetInvitesByCode200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = GetInvitesByCode200ResponseRoleEnum.editor
          ..expiresAt = DateTime.utc(2026, 9, 1),
      ),
    );
    when(() => sharing.acceptInvite('ABC123')).thenAnswer(
      (_) async => PostInvitesByCodeAccept200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = PostInvitesByCodeAccept200ResponseRoleEnum.editor,
      ),
    );

    await tester.enterText(find.byType(TextField), 'ABC123');
    await tester.tap(find.text(l10n.joinSharedQuery));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.joinSharedAccept));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    verify(() => sharing.acceptInvite('ABC123')).called(1);
    final bound = await db.select(db.ledgers).get();
    expect(bound, hasLength(1), reason: '接受成功后本地必须落绑定行');
    expect(bound.single.id, 'ledger-x');
    expect(bound.single.storageMode, 'cloud', reason: '共享账本属于云端归属');
    expect(find.text(l10n.joinSharedSuccess), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('接受成功但首批历史数据同步失败：提示待同步且账本已加入', (tester) async {
    final l10n = await pump(tester);

    when(() => sharing.queryInviteByCode('ABC123')).thenAnswer(
      (_) async => GetInvitesByCode200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = GetInvitesByCode200ResponseRoleEnum.editor
          ..expiresAt = DateTime.utc(2026, 9, 1),
      ),
    );
    when(() => sharing.acceptInvite('ABC123')).thenAnswer(
      (_) async => PostInvitesByCodeAccept200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = PostInvitesByCodeAccept200ResponseRoleEnum.editor,
      ),
    );
    // bootstrap 把首批历史数据同步失败收敛为 error 结果返回（非抛出）。
    when(() => coordinator.bootstrap()).thenAnswer(
      (_) async => const SyncRunResult(error: 'bootstrap-error-marker'),
    );

    await tester.enterText(find.byType(TextField), 'ABC123');
    await tester.tap(find.text(l10n.joinSharedQuery));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.joinSharedAccept));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(l10n.joinSharedSyncDeferred),
      findsOneWidget,
      reason: '首批历史数据同步失败时必须提示「已加入，历史数据将在联网后同步」',
    );
    expect(
      find.text(l10n.joinSharedSuccess),
      findsNothing,
      reason: '待同步提示与完全成功提示互斥，不能让用户误以为数据已拉取',
    );
    final bound = await db.select(db.ledgers).get();
    expect(bound, hasLength(1), reason: '同步失败不得回滚已加入的账本绑定');
    await tester.pump(const Duration(seconds: 2));
  });
}
