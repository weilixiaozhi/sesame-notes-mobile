/// MemberManagementSection 成员管理模块 widget 测试。
///
/// 云协作邀请模块已随同步层下线,本文件保留仍有效的成员管理行为:
/// - 虚拟用户行编辑输入在父级重建后保留(State 持有 controller);
/// - AA 分摊开关位于成员管理标题行(文字+开关)。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/sharing_service.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/member_management_section.dart';
import 'package:sesame_notes/shared/widgets/text_state_switch.dart';

/// 已登录账号状态:云昵称「云昵称」绑定 user-1。
class _CloudAccountNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(userId: 'user-1', displayName: '云昵称'),
  );
}

/// 构造成员桩数据 — 只填测试关心的字段,其余给固定值。
db.LedgerMember _member({
  required String userId,
  required String role,
  required bool isSelf,
}) => db.LedgerMember(
  id: 'member-$userId',
  ledgerId: 'ledger-1',
  displayName: '成员-$userId',
  memberType: 'REGISTERED',
  linkedAccountId: userId,
  role: role,
  avatarVersion: 0,
  status: 'ACTIVE',
  joinedAt: DateTime.utc(2026, 1, 1),
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  testWidgets('虚拟用户行编辑输入在父级重建后保留', (tester) async {
    final vu = db.LedgerMember(
      id: 'vu-1',
      ledgerId: 'ledger-1',
      displayName: '虚拟用户1',
      memberType: 'PLACEHOLDER',
      role: 'editor',
      avatarVersion: 0,
      status: 'ACTIVE',
      joinedAt: DateTime.utc(2026, 1, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    // 用 StatefulBuilder 包裹:由测试主动触发父级重建,
    // 验证 _VirtualUserTileState 持有的 controller 在重建后保留输入。
    late StateSetter rebuild;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ledgerVirtualUsersProvider.overrideWith(
            (ref, ledgerId) => Stream<List<db.LedgerMember>>.value([vu]),
          ),
          ledgerMembersProvider.overrideWith(
            (ref, ledgerId) async => [
              _member(userId: 'u1', role: 'owner', isSelf: true),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setter) {
                  rebuild = setter;
                  return MemberManagementSection(
                    ledgerExternalId: 'ledger-1',
                    ledgerName: '测试账本',
                    ledgerId: 'ledger-1',
                    aaEnabled: true,
                    onAaChanged: (_) {},
                    isReadOnly: false,
                    pendingVirtualUsers: const [],
                    onPendingVirtualUsersChanged: (_) {},
                    showInviteEntry: true,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('虚拟用户1'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '新名字');
    await tester.pump();

    // 触发父级重建:State 持有的 controller 必须保留正在编辑但未失焦的内容。
    rebuild(() {});
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '新名字', reason: '父级重建后行内编辑输入不应丢失');
  });

  testWidgets('AA 分摊开关位于成员管理标题行(文字+开关)', (tester) async {
    // AA 开关并入标题行(文字+紧凑 Switch),不在卡片内单独成行。
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: null,
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: false,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // AA 分摊开关与「成员管理」标题同处一行:开关内嵌状态文案
    // (aaEnabled=false 显示「关闭AA分摊」),无独立的"AA 分摊"标题文本。
    expect(find.text('成员管理'), findsOneWidget);
    expect(find.text('关闭AA分摊'), findsOneWidget);
    // 开关是轨道内带状态文案的 TextStateSwitch,非系统 Switch
    expect(find.byType(TextStateSwitch), findsOneWidget);
    // 不使用 SwitchListTile(卡片内独立一行)
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('Owner 可移除协作者：确认弹窗 → 服务端移除 → 本地标 REMOVED', (tester) async {
    final mockRepo = _MockRepo();
    when(
      () => mockRepo.updateMemberStatus(
        ledgerId: any(named: 'ledgerId'),
        accountId: any(named: 'accountId'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});
    final removed = <String>[];
    final service = _FakeSharingService(onRemove: removed.add);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ledgerMembersProvider.overrideWith(
            (ref, ledgerId) async => [
              _member(userId: 'me', role: 'owner', isSelf: true),
              _member(userId: 'u2', role: 'editor', isSelf: false),
            ],
          ),
          authSessionProvider.overrideWith(
            () => _AuthSessionNotifier(
              AuthSession(accessToken: 'x', userId: 'me', deviceId: 'd'),
            ),
          ),
          sharingServiceProvider.overrideWith((ref) => service),
          repositoryProvider.overrideWith((ref) => mockRepo),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: 'ledger-1',
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: false,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 协作者行显示移除按钮；owner 行不显示
    final removeButtons = find.byIcon(AppIcons.personRemove);
    expect(removeButtons, findsOneWidget);

    await tester.tap(removeButtons);
    await tester.pumpAndSettle();
    // 确认弹窗
    expect(find.text('移除成员'), findsOneWidget);
    await tester.tap(find.text('移除该成员'));
    await tester.pumpAndSettle();

    expect(removed, ['member-u2'], reason: '确认后必须调用服务端移除');
    verify(
      () => mockRepo.updateMemberStatus(
        ledgerId: 'ledger-1',
        accountId: 'u2',
        status: 'REMOVED',
      ),
    ).called(1);
    // 等 toast 自动消失计时器结算，避免 pending timer 断言。
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('非 Owner（协作者视角）成员行不显示移除按钮', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ledgerMembersProvider.overrideWith(
            (ref, ledgerId) async => [
              _member(userId: 'u1', role: 'owner', isSelf: false),
              _member(userId: 'me', role: 'editor', isSelf: true),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: 'ledger-1',
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: true,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(AppIcons.personRemove), findsNothing);
  });

  testWidgets('云账本本人行快照昵称为空:显示云昵称（我）而非「未知」', (tester) async {
    // 成员行快照昵称为空(历史/迁移数据):本人行必须兜底当前云 Profile 昵称。
    final selfRow = db.LedgerMember(
      id: 'member-user-1',
      ledgerId: 'ledger-1',
      displayName: '',
      memberType: 'REGISTERED',
      linkedAccountId: 'user-1',
      role: 'owner',
      avatarVersion: 0,
      status: 'ACTIVE',
      joinedAt: DateTime.utc(2026, 1, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    // 账本身份上下文经 repository 读取账本与成员行,此处提供同源桩。
    final mockRepo = _MockRepo();
    when(() => mockRepo.getLedgerById('ledger-1')).thenAnswer(
      (_) async => db.Ledger(
        id: 'ledger-1',
        name: '云账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 2,
        monthStartDay: 1,
        storageMode: 'cloud',
        aaEnabled: false,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    when(
      () => mockRepo.getMembersByLedger('ledger-1'),
    ).thenAnswer((_) async => [selfRow]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWith((ref) => mockRepo),
          ledgerMembersProvider.overrideWith(
            (ref, ledgerId) async => [selfRow],
          ),
          authSessionProvider.overrideWith(
            () => _AuthSessionNotifier(
              AuthSession(accessToken: 'x', userId: 'user-1', deviceId: 'd'),
            ),
          ),
          accountStateProvider.overrideWith(_CloudAccountNotifier.new),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: 'ledger-1',
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: true,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 本人行显示当前云 Profile 昵称并带「(我)」后缀,不得显示「未知」。
    expect(find.textContaining('云昵称', findRichText: true), findsOneWidget);
    expect(find.text('未知'), findsNothing);
    // 收尾:等目录刷新降级日志与 toast 计时器结算。
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('本地账本(无成员镜像):所有者行显示固定本地身份「单机芝麻仔（我）」', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: null,
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: false,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('单机芝麻仔', findRichText: true),
      findsOneWidget,
      reason: '本地账本本人恒显固定本地身份,不得显示「未知」',
    );
    expect(find.text('未知'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('云账本镜像模式:只渲染 REGISTERED 成员,遗留 LOCAL/占位行不出现', (tester) async {
    // 云账本成员镜像若混入 LOCAL 行或 PLACEHOLDER 行,
    // 真实成员区只渲染 REGISTERED,虚拟用户由专用区块渲染,本人不会
    // 同时出现「单机芝麻仔」与云昵称两行。
    final legacyLocal = db.LedgerMember(
      id: 'member-local',
      ledgerId: 'ledger-1',
      displayName: '',
      memberType: 'LOCAL',
      linkedAccountId: 'user-1',
      role: 'editor',
      avatarVersion: 0,
      status: 'ACTIVE',
      joinedAt: DateTime.utc(2026, 1, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    final selfRow = _member(userId: 'user-1', role: 'owner', isSelf: true);
    // 账本身份上下文经 repository 读取账本与成员行,此处提供同源桩。
    final mockRepo = _MockRepo();
    when(() => mockRepo.getLedgerById('ledger-1')).thenAnswer(
      (_) async => db.Ledger(
        id: 'ledger-1',
        name: '云账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 2,
        monthStartDay: 1,
        storageMode: 'cloud',
        aaEnabled: false,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    when(
      () => mockRepo.getMembersByLedger('ledger-1'),
    ).thenAnswer((_) async => [selfRow, legacyLocal]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWith((ref) => mockRepo),
          ledgerMembersProvider.overrideWith(
            (ref, ledgerId) async => [selfRow, legacyLocal],
          ),
          authSessionProvider.overrideWith(
            () => _AuthSessionNotifier(
              AuthSession(accessToken: 'x', userId: 'user-1', deviceId: 'd'),
            ),
          ),
          accountStateProvider.overrideWith(_CloudAccountNotifier.new),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemberManagementSection(
                ledgerExternalId: 'ledger-1',
                ledgerName: '测试账本',
                ledgerId: 'ledger-1',
                aaEnabled: false,
                onAaChanged: (_) {},
                isReadOnly: true,
                pendingVirtualUsers: const [],
                onPendingVirtualUsersChanged: (_) {},
                showInviteEntry: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // REGISTERED 本人行显示云昵称;遗留 LOCAL 行被过滤,不出现「单机芝麻仔」。
    expect(find.textContaining('云昵称', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('单机芝麻仔', findRichText: true),
      findsNothing,
      reason: '云账本成员镜像不得渲染遗留 LOCAL 行',
    );
    await tester.pump(const Duration(seconds: 3));
  });
}

/// LocalRepository 测试替身：仅记录成员状态更新调用。
class _MockRepo extends Mock implements LocalRepository {}

/// 读写双通道的 SharingService 测试替身：记录移除调用，不触真实网络。
class _FakeSharingService extends SharingService {
  _FakeSharingService({required this.onRemove}) : super(_FakeClient());

  final void Function(String memberId) onRemove;

  @override
  Future<void> removeLedgerMember({
    required String ledgerId,
    required String memberId,
  }) async {
    onRemove(memberId);
  }
}

/// 最小客户端替身：SharingService 仅构造期持有，测试路径不会访问网络。
class _FakeClient extends SesameApiClient {
  _FakeClient() : super(basePathOverride: 'http://unused.invalid');
}

/// 固定会话的 AuthSessionNotifier 测试替身。
class _AuthSessionNotifier extends AuthSessionNotifier {
  _AuthSessionNotifier(this._session);

  final AuthSession? _session;

  @override
  AuthSession? build() => _session;
}
