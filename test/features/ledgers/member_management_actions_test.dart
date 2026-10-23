import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

/// 邀请与成员移除的服务端替身：记录调用并按用例指定结果。
class _MockSharingService extends Mock implements SharingService {}

/// 首次改名失败、其后委托真实仓储的替身：验证失败后可原样重试并成功落库。
class _FlakyRenameRepo extends LocalRepository {
  _FlakyRenameRepo(super.db);

  int renameCalls = 0;

  @override
  Future<void> renameMember({required String id, required String name}) async {
    renameCalls++;
    if (renameCalls == 1) throw Exception('SQLite 不能写入');
    await super.renameMember(id: id, name: name);
  }
}

/// 构造传输失败，避免把服务端业务拒绝误认为网络错误。
DioException _networkError() => DioException(
  requestOptions: RequestOptions(path: '/members'),
  type: DioExceptionType.connectionError,
);

PostLedgersByLedgerIdInvites201Response _invite(String code) =>
    PostLedgersByLedgerIdInvites201Response(
      (b) => b
        ..id = 'invite-$code'
        ..role = PostLedgersByLedgerIdInvites201ResponseRoleEnum.editor
        ..expiresAt = DateTime.utc(2027)
        ..code = code,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSharingService sharing;
  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState();
    // logger 是进程级单例：失败路径会写日志，每个用例从空日志起步并冲刷定时器。
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    sharing = _MockSharingService();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
        // 网络事件通道在测试环境不可用，等价替换为空流。
        cloudNetworkEventsProvider.overrideWithValue(const Stream.empty()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await logger.clear();
  });

  /// 建账本（外键约束：成员与交易都必须先有账本行）。
  Future<void> seedLedger({String id = 'ledger-1'}) => db
      .into(db.ledgers)
      .insert(
        LedgersCompanion.insert(
          id: id,
          name: '共享账本',
          updatedAt: DateTime.utc(2026),
        ),
      );

  /// 建协作者成员镜像行（绑定云账号，供移除后本地标 REMOVED 定位）。
  Future<void> seedRegisteredMember({
    required String id,
    required String accountId,
  }) => db
      .into(db.ledgerMembers)
      .insert(
        LedgerMembersCompanion.insert(
          id: id,
          ledgerId: 'ledger-1',
          displayName: '协作者',
          memberType: 'REGISTERED',
          linkedAccountId: Value(accountId),
          role: const Value('editor'),
          updatedAt: DateTime.utc(2026),
        ),
      );

  /// 通过 Consumer 捕获与容器绑定的 WidgetRef（动作函数参数）。
  Future<WidgetRef> captureRef(WidgetTester tester) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return const Placeholder();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return captured;
  }

  test('生成邀请码：一次生成只请求服务端一次，账本与有效期原样透传', () async {
    await seedLedger();
    when(
      () => sharing.createInvite(ledgerId: 'ledger-1', expiresInHours: 72),
    ).thenAnswer((_) async => _invite('CODE1'));

    final invite = await container
        .read(ledgerActionsProvider)
        .createInvite(ledgerId: 'ledger-1', expiresInHours: 72);

    expect(invite.code, 'CODE1');
    expect(invite.expiresAt, DateTime.utc(2027));
    verify(
      () => sharing.createInvite(ledgerId: 'ledger-1', expiresInHours: 72),
    ).called(1);
  });

  test('生成邀请码失败：向上抛出供重试，重试沿用同一有效期并拿到新码', () async {
    await seedLedger();
    var calls = 0;
    when(
      () => sharing.createInvite(ledgerId: 'ledger-1', expiresInHours: 72),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw _networkError();
      return _invite('CODE2');
    });
    final actions = container.read(ledgerActionsProvider);

    await expectLater(
      actions.createInvite(ledgerId: 'ledger-1', expiresInHours: 72),
      throwsA(isA<DioException>()),
      reason: '生成失败必须让调用方感知，才能提示并允许重试',
    );
    final retry = await actions.createInvite(
      ledgerId: 'ledger-1',
      expiresInHours: 72,
    );

    expect(retry.code, 'CODE2', reason: '重试必须重新请求服务端，不复用旧码');
    verify(
      () => sharing.createInvite(ledgerId: 'ledger-1', expiresInHours: 72),
    ).called(2);
  });

  test('Owner 移除协作者：服务端移除成功后本地成员镜像标 REMOVED', () async {
    await seedLedger();
    await seedRegisteredMember(id: 'member-u2', accountId: 'u2');
    when(
      () => sharing.removeLedgerMember(
        ledgerId: 'ledger-1',
        memberId: 'member-u2',
      ),
    ).thenAnswer((_) async {});

    await container
        .read(ledgerActionsProvider)
        .removeMember(
          ledgerId: 'ledger-1',
          memberId: 'member-u2',
          accountId: 'u2',
        );

    verify(
      () => sharing.removeLedgerMember(
        ledgerId: 'ledger-1',
        memberId: 'member-u2',
      ),
    ).called(1);
    expect(
      (await repo.getMemberById('member-u2'))!.status,
      'REMOVED',
      reason: '服务端移除成功后本地镜像必须同步为 REMOVED',
    );
  });

  test('Owner 移除协作者：服务端失败向上抛出且本地镜像保持 ACTIVE', () async {
    await seedLedger();
    await seedRegisteredMember(id: 'member-u2', accountId: 'u2');
    when(
      () => sharing.removeLedgerMember(
        ledgerId: 'ledger-1',
        memberId: 'member-u2',
      ),
    ).thenThrow(_networkError());

    await expectLater(
      container
          .read(ledgerActionsProvider)
          .removeMember(
            ledgerId: 'ledger-1',
            memberId: 'member-u2',
            accountId: 'u2',
          ),
      throwsA(isA<DioException>()),
    );

    expect(
      (await repo.getMemberById('member-u2'))!.status,
      'ACTIVE',
      reason: '服务端未移除成功时不得先改本地状态',
    );
  });

  testWidgets('虚拟成员改名：失败保留已保存名称，重试成功后写入新名称', (tester) async {
    final flaky = _FlakyRenameRepo(db);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(flaky),
      ],
    );
    final ref = await captureRef(tester);
    await seedLedger();
    final id = await flaky.createPlaceholderMember(
      ledgerId: 'ledger-1',
      name: '原昵称',
    );

    await expectLater(
      renameVirtualUser(ref.read, id: id, name: '旅行同伴'),
      throwsA(isA<Exception>()),
    );
    expect(
      (await flaky.getMemberById(id))!.displayName,
      '原昵称',
      reason: '写入失败不得改动已保存名称，成员仍可重试',
    );

    await renameVirtualUser(ref.read, id: id, name: '旅行同伴');

    expect((await flaky.getMemberById(id))!.displayName, '旅行同伴');
    expect(flaky.renameCalls, 2);
    // 失败路径写了日志，清空以结算落盘定时器，避免测试结束时残留 pending timer。
    await logger.clear();
  });

  testWidgets('虚拟成员删除：名下有账拒绝删除且保留成员，无引用可删除', (tester) async {
    await seedLedger();
    final ref = await captureRef(tester);
    final inUse = await repo.createPlaceholderMember(
      ledgerId: 'ledger-1',
      name: '同伴',
    );
    // 该成员垫付了一笔人均分摊支出：名下有账，删除必须被拒绝。
    await repo.addTransaction(
      ledgerId: 'ledger-1',
      type: 'expense',
      amount: '10',
      happenedAt: DateTime(2026, 8, 1, 8),
      payerMemberId: inUse,
      aaMode: 0,
    );

    await expectLater(
      deleteVirtualUser(ref.read, inUse),
      throwsA(isA<StateError>()),
    );
    expect(
      await repo.getMemberById(inUse),
      isNotNull,
      reason: '删除被拒绝时必须保留成员行，用户可先处理账务',
    );

    final free = await repo.createPlaceholderMember(
      ledgerId: 'ledger-1',
      name: '无引用同伴',
    );
    await deleteVirtualUser(ref.read, free);

    expect(await repo.getMemberById(free), isNull);
    // 失败路径写了日志，清空以结算落盘定时器，避免测试结束时残留 pending timer。
    await logger.clear();
  });

  test('名称 trim 后为空绝不落库：创建与改名都被拒绝', () async {
    await seedLedger();
    final id = await repo.createPlaceholderMember(
      ledgerId: 'ledger-1',
      name: '原昵称',
    );

    await expectLater(
      repo.renameMember(id: id, name: '   '),
      throwsA(isA<FormatException>()),
    );
    expect(
      (await repo.getMemberById(id))!.displayName,
      '原昵称',
      reason: '空白名称不得覆盖已保存名称',
    );

    final before = (await repo.getMembersByLedger('ledger-1')).length;
    await expectLater(
      repo.createPlaceholderMember(ledgerId: 'ledger-1', name: '   '),
      throwsA(isA<FormatException>()),
    );
    expect(
      (await repo.getMembersByLedger('ledger-1')).length,
      before,
      reason: '空白名称不得创建成员行',
    );
  });
}
