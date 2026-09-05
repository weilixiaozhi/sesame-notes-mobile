// aa_statistics_providers 其余 provider 测试（本地/单人账本分支）。
//
// 需求锚点：
//   1. aaEnabledProvider 反映 ledger.aaEnabled 流；
//   2. setAaEnabled / 虚拟用户 CRUD 走 repository 并失效率刷新；失败向上抛；
//   3. currentOperatorIdForLedger：返回账本 self member id（本地账本按
//      uuidV5(ledgerId, localSelfId) 派生，身份不随登录变化）；
//   4. aaParticipantOptionsProvider：单人账本把 owner（id 即 localSelfId）纳入参与人，并追加虚拟用户；
//   5. aaStatisticsProvider：AA 关闭返回空汇总；开启后含参与人/虚拟用户；
//   6. aaParticipantAvatarContextProvider：本地账本返回空上下文；
//   7. aaMemberDetailProvider：非 AA 或成员缺失返回 null。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/utils/member_id.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late ProviderContainer container;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    // createLedger 返回 UUID，捕获后作为后续所有 family 参数。
    ledgerId = await repo.createLedger(
      name: 'AA账本',
      storageMode: 'local',
      aaEnabled: true,
      localSelfId: 'u-owner',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        // 单人账本 owner 即本人：localSelfId 置为 'u-owner'，保持参与人断言成立。
        localSelfIdProvider.overrideWith((ref) async => 'u-owner'),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => ledgerId),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  /// 通过 Consumer 捕获与容器绑定的 WidgetRef（动作函数参数）。
  Future<WidgetRef> captureRef(WidgetTester tester, ProviderContainer c) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
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

  test('aaEnabledProvider 反映账本开关', () async {
    final enabled = await readProviderFutureFromContainer(
      container,
      aaEnabledProvider.future,
    );
    expect(enabled, isTrue);
    // 开关联动由 repo.watchLedger 流语义保证，此处锁定首帧即可。
  });

  testWidgets('虚拟用户 CRUD 走 repository', (tester) async {
    final ref = await captureRef(tester, container);
    final id = await createVirtualUser(ref, ledgerId: ledgerId, name: '小明');
    expect(id, isNotEmpty);

    await renameVirtualUser(ref, id: id, name: '小红');
    final users = await repo.getMembersByLedger(ledgerId);
    expect(
      users.singleWhere((m) => m.memberType == 'PLACEHOLDER').displayName,
      '小红',
    );

    await deleteVirtualUser(ref, id);
    final after = await repo.getMembersByLedger(ledgerId);
    expect(
      after.where((m) => m.memberType == 'PLACEHOLDER'),
      isEmpty,
      reason: '删除占位成员后账本仅剩 LOCAL self 成员',
    );
  });

  testWidgets('currentOperatorIdForLedger：返回账本 self member id（派生，稳定）', (
    tester,
  ) async {
    final ref = await captureRef(tester, container);
    final expected = localSelfMemberId(ledgerId, 'u-owner');
    expect(await currentOperatorIdForLedger(ref, ledgerId), expected);
  });

  test('aaParticipantOptionsProvider：单人账本含 owner 与虚拟用户', () async {
    await repo.createPlaceholderMember(ledgerId: ledgerId, name: '虚拟A');
    final options = await container.read(
      aaParticipantOptionsProvider(ledgerId).future,
    );

    // 单人账本无成员表：owner 即本人，参与人 id = self member id（派生）。
    expect(
      options.any(
        (o) => o.id == localSelfMemberId(ledgerId, 'u-owner') && !o.isVirtual,
      ),
      isTrue,
      reason: '单人账本 self member 自动纳入参与人',
    );
    expect(options.any((o) => o.name == '虚拟A' && o.isVirtual), isTrue);
  });

  test('aaStatisticsProvider：AA 关闭返回空汇总，开启后含参与人', () async {
    final empty = await container.read(aaStatisticsProvider(ledgerId).future);
    expect(empty.participants, isNotEmpty, reason: '开启 AA 且含 owner');

    await repo.updateLedger(id: ledgerId, aaEnabled: false);
    container.invalidate(aaStatisticsProvider(ledgerId));
    final closed = await container.read(aaStatisticsProvider(ledgerId).future);
    expect(closed.participants, isEmpty);
  });

  test('aaParticipantAvatarContextProvider：本地账本空上下文', () async {
    final ctx = await container.read(
      aaParticipantAvatarContextProvider(ledgerId).future,
    );
    expect(ctx.members, isEmpty);
  });

  test('aaMemberDetailProvider：非 AA 账本返回 null', () async {
    await repo.updateLedger(id: ledgerId, aaEnabled: false);
    final detail = await container.read(
      aaMemberDetailProvider((
        ledgerId: ledgerId,
        participantId: 'u-owner',
      )).future,
    );
    expect(detail, isNull);
  });

  testWidgets('setAaEnabled 失败向上抛', (tester) async {
    final mock = _MockRepo();
    when(
      () => mock.updateLedger(
        id: any(named: 'id'),
        aaEnabled: any(named: 'aaEnabled'),
      ),
    ).thenThrow(Exception('db down'));
    final c2 = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(mock),
        // setAaEnabled 会 invalidate currentLedgerProvider；给确定流避免失效重建炸掉。
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(c2.dispose);
    final ref2 = await captureRef(tester, c2);

    expect(setAaEnabled(ref2, 'led-x', true), throwsException);
    // logger.error 触发落盘定时器，清空取消避免残留 pending timer。
    await logger.clear();
  });

  testWidgets('authorMemberIdForLedger:成员行创建失败仍返回派生成员 id,不裸写设备 id', (
    tester,
  ) async {
    final mock = _MockRepo();
    when(() => mock.getLedgerById('ledger-1')).thenAnswer(
      (_) async => Ledger(
        id: 'ledger-1',
        name: '账本',
        currency: 'CNY',
        monthStartDay: 1,
        aaEnabled: false,
        role: 'owner',
        memberCount: 1,
        storageMode: 'local',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    when(
      () => mock.ensureLocalSelfMember(
        ledgerId: any(named: 'ledgerId'),
        localSelfId: any(named: 'localSelfId'),
        displayName: any(named: 'displayName'),
      ),
    ).thenThrow(StateError('boom'));
    final c2 = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(mock),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
      ],
    );
    addTearDown(c2.dispose);
    final ref2 = await captureRef(tester, c2);

    final result = await authorMemberIdForLedger(ref2, 'ledger-1');

    expect(
      result,
      localSelfMemberId('ledger-1', 'local-self'),
      reason: '成员行创建失败降级时也必须返回确定性派生成员 id,不得裸写设备 id',
    );
    // logger.warning 触发落盘定时器，清空取消避免残留 pending timer。
    await logger.clear();
  });
}
