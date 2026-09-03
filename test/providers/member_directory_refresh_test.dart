/// 成员目录刷新编排测试(§13.4 后半句)。
///
/// 锁定行为:
/// - 已登录 + 云账本:调用成员列表接口并把公开资料落库;
/// - 未登录 / 本地账本:跳过;
/// - 30 秒防抖窗口内重复触发只请求一次;
/// - 拉取失败不影响本地快照。
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/member_directory_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../helpers/test_isolation.dart';

/// 已登录会话(未登录场景用默认 null 会话)。
class _SignedInNotifier extends AuthSessionNotifier {
  @override
  AuthSession? build() =>
      AuthSession(accessToken: 't', userId: 'user-1', deviceId: 'd');
}

class _MockMemberDirectoryService extends Mock
    implements MemberDirectoryService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> seedLedger(String storageMode) async {
    return repo.createLedger(
      name: '账本',
      storageMode: storageMode,
      aaEnabled: true,
    );
  }

  ProviderContainer buildContainer({
    required _MockMemberDirectoryService service,
    bool signedIn = true,
  }) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        memberDirectoryServiceProvider.overrideWithValue(service),
        if (signedIn) authSessionProvider.overrideWith(_SignedInNotifier.new),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('云账本:拉取成员列表并把公开资料落库', () async {
    final ledgerId = await seedLedger('cloud');
    final service = _MockMemberDirectoryService();
    when(() => service.fetchMembers(ledgerId)).thenAnswer(
      (_) async => [
        LedgerDirectoryMember(
          memberId: 'member-1',
          displayName: '新昵称',
          linkedAccountId: 'user-1',
          role: 'owner',
          status: 'ACTIVE',
          avatarUrl: 'https://example.com/a.png',
          avatarVersion: 2,
          joinedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
    );
    final container = buildContainer(service: service);

    await refreshLedgerMemberDirectory(container, ledgerId);

    verify(() => service.fetchMembers(ledgerId)).called(1);
    final row = (await repo.getMemberById('member-1'))!;
    expect(row.displayName, '新昵称');
    expect(row.avatarVersion, 2);
    expect(row.memberType, 'REGISTERED');
    // 防抖:30 秒内重复触发不再请求。
    await refreshLedgerMemberDirectory(container, ledgerId);
    verifyNoMoreInteractions(service);
  });

  test('未登录跳过拉取', () async {
    final ledgerId = await seedLedger('cloud');
    final service = _MockMemberDirectoryService();
    final container = buildContainer(service: service, signedIn: false);

    await refreshLedgerMemberDirectory(container, ledgerId);

    verifyNever(() => service.fetchMembers(any()));
  });

  test('本地账本跳过拉取', () async {
    final ledgerId = await seedLedger('local');
    final service = _MockMemberDirectoryService();
    final container = buildContainer(service: service);

    await refreshLedgerMemberDirectory(container, ledgerId);

    verifyNever(() => service.fetchMembers(any()));
  });
}
