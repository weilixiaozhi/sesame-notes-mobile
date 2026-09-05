// aa_statistics_providers 共享账本分支测试。
//
// 与 aa_statistics_providers_test（本地/单人账本分支）互补，锁定：
//   - aaParticipantOptionsProvider：共享账本从 ledgerMembersProvider 取
//     真实成员 + 虚拟用户，昵称恒非空(注册即分配),空昵称防御性回退「未知」；
//   - aaStatisticsProvider：共享账本按成员表 + 虚拟用户组装参与人名册；
//   - aaMemberExpenseStatsProvider：共享账本成员头像/显示名映射；
//   - ledgerIdentityProvider：共享账本返回全量成员上下文。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

import '../../helpers/test_isolation.dart';
import 'dart:ui' show Locale;

/// 固定中文语言环境,展示名断言不随系统语言漂移。
class _ZhLanguageNotifier extends LanguageNotifier {
  @override
  Locale? build() => const Locale('zh');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    // 共享账本：memberCount>1 + role=editor + AA 开启
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-shared-aa',
            name: '共享AA账本',
            memberCount: d.Value(2),
            role: d.Value('editor'),
            aaEnabled: d.Value(true),
            storageMode: d.Value('cloud'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    // 成员：一个 displayName 完整、一个缺失回落 account。
    // 契约：成员镜像表 role 只允许 editor（owner 由 ledgers.role 表达）。
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-owner',
            ledgerId: 'led-shared-aa',
            displayName: 'Owner',
            memberType: 'REGISTERED',
            linkedAccountId: d.Value('u-owner'),
            role: d.Value('editor'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-editor',
            ledgerId: 'led-shared-aa',
            displayName: '',
            memberType: 'REGISTERED',
            linkedAccountId: d.Value('u-editor'),
            role: d.Value('editor'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    // 虚拟用户
    await repo.createPlaceholderMember(
      ledgerId: 'led-shared-aa',
      name: '室友A',
      id: 'vu-1',
    );
    // AA 交易：支出人 u-owner（12000 分 = 120.00 元）
    await repo.addTransaction(
      ledgerId: 'led-shared-aa',
      type: 'expense',
      amount: '120.00',
      happenedAt: DateTime(2026, 8, 8),
      payerMemberId: 'u-owner',
      aaMode: 0,
    );

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        // 成员数据源：ledgerMembersProvider 直查 db.ledgerMembers，无需 override。
        // localSelfId 置 'u-owner'，使成员 isSelf 断言成立。
        localSelfIdProvider.overrideWith((ref) async => 'u-owner'),
        languageProvider.overrideWith(_ZhLanguageNotifier.new),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  /// 等待 Riverpod 消费 Drift 异步变更并完成派生 provider 重算。
  Future<void> waitUntil(
    bool Function() predicate, {
    required String reason,
  }) async {
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (!predicate()) {
      if (DateTime.now().isAfter(deadline)) fail(reason);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  test('aaParticipantOptionsProvider：共享账本成员 + 虚拟用户', () async {
    final options = await readProviderFutureFromContainer(
      container,
      aaParticipantOptionsProvider('led-shared-aa').future,
    );
    final byId = {for (final o in options) o.id: o};

    expect(byId['u-owner']?.name, 'Owner');
    expect(
      byId['u-editor']?.name,
      '未知',
      reason: '昵称恒非空(注册即分配),空昵称的防御性兜底为「未知」而非空串',
    );
    expect(byId['vu-1']?.name, '室友A');
    expect(byId['u-owner']?.isVirtual, isFalse);
    expect(byId['vu-1']?.isVirtual, isTrue);
    expect(byId['u-owner']?.isSelf, isTrue);
  });

  test('aaStatisticsProvider：共享账本统计包含成员与虚拟用户', () async {
    final stats = await readProviderFutureFromContainer(
      container,
      aaStatisticsProvider('led-shared-aa').future,
    );
    final ids = stats.participants.map((p) => p.participantId).toSet();
    expect(ids, containsAll(['u-owner', 'u-editor', 'vu-1']));
    final owner = stats.participants.firstWhere(
      (p) => p.participantId == 'u-owner',
    );
    expect(owner.totalPaid, 120.0);
    expect(owner.displayName, 'Owner');
  });

  test('aaMemberExpenseStatsProvider：成员头像/显示名映射', () async {
    final items = await readProviderFutureFromContainer(
      container,
      memberExpenseStatsProvider('led-shared-aa').future,
    );
    expect(items.single.participantId, 'u-owner');
    expect(items.single.displayName, 'Owner');
    expect(items.single.isSelf, isTrue);
  });

  test('ledgerIdentityProvider：共享账本返回全量成员上下文', () async {
    final identity = await readProviderFutureFromContainer(
      container,
      ledgerIdentityProvider('led-shared-aa').future,
    );
    expect(identity.memberMap, contains('u-owner'));
    expect(identity.memberMap, contains('u-editor'));
  });

  test('ledgerMembersProvider：成员表写入后自动返回新名册', () async {
    final provider = ledgerMembersProvider('led-shared-aa');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    expect(await container.read(provider.future), hasLength(3));

    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-new',
            ledgerId: 'led-shared-aa',
            displayName: '新成员',
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value('u-new'),
            role: const d.Value('editor'),
            updatedAt: DateTime(2026, 8, 9),
          ),
        );

    await waitUntil(
      () => container.read(provider).value?.length == 4,
      reason: '成员 Future 必须依赖统一数据变更信号，不能永久返回旧缓存',
    );
  });

  test('aaParticipantOptionsProvider：成员表写入后自动重建参与人选项', () async {
    final provider = aaParticipantOptionsProvider('led-shared-aa');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    expect(
      (await container.read(provider.future)).map((item) => item.id),
      isNot(contains('u-new-option')),
    );

    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-new-option',
            ledgerId: 'led-shared-aa',
            displayName: '自动刷新成员',
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value('u-new-option'),
            role: const d.Value('editor'),
            updatedAt: DateTime(2026, 8, 9),
          ),
        );

    await waitUntil(
      () =>
          container
              .read(provider)
              .value
              ?.any((item) => item.id == 'u-new-option') ??
          false,
      reason: '共享资源不得依赖无生产者的手动 tick',
    );
    final refreshed = container.read(provider).requireValue;
    expect(refreshed.map((item) => item.id), contains('u-new-option'));
  });

  test('成员状态分层：仅 ACTIVE 可选，退出成员仍解释历史汇总，tombstone 全部隐藏', () async {
    await (db.update(
      db.ledgerMembers,
    )..where((member) => member.id.equals('u-editor'))).write(
      const LedgerMembersCompanion(
        displayName: d.Value('已退出成员'),
        status: d.Value('REMOVED'),
      ),
    );
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'vu-deleted',
            ledgerId: 'led-shared-aa',
            displayName: '已删占位成员',
            memberType: 'PLACEHOLDER',
            status: const d.Value('ACTIVE'),
            updatedAt: DateTime(2026, 8, 9),
            deletedAt: d.Value(DateTime(2026, 8, 9)),
          ),
        );
    await repo.addTransaction(
      ledgerId: 'led-shared-aa',
      type: 'expense',
      amount: '30.00',
      happenedAt: DateTime(2026, 8, 9),
      payerMemberId: 'u-editor',
      aaMode: 2,
      splits: const [
        TransactionSplitInput(memberId: 'u-editor', amount: '30.00'),
      ],
    );

    final managedMembers = await container.read(
      ledgerMembersProvider('led-shared-aa').future,
    );
    expect(managedMembers.map((member) => member.id), {'u-owner', 'vu-1'});

    final virtualUsers = await readProviderFutureFromContainer(
      container,
      ledgerVirtualUsersProvider('led-shared-aa').future,
    );
    expect(virtualUsers.map((member) => member.id), ['vu-1']);

    final options = await readProviderFutureFromContainer(
      container,
      aaParticipantOptionsProvider('led-shared-aa').future,
    );
    expect(
      options.map((option) => option.id),
      containsAll(['u-owner', 'vu-1']),
    );
    expect(options.where((option) => option.id == 'vu-1'), hasLength(1));
    expect(options.map((option) => option.id), isNot(contains('u-editor')));
    expect(options.map((option) => option.id), isNot(contains('vu-deleted')));

    final aaStats = await readProviderFutureFromContainer(
      container,
      aaStatisticsProvider('led-shared-aa').future,
    );
    final removedSummary = aaStats.participants.singleWhere(
      (participant) => participant.participantId == 'u-editor',
    );
    expect(removedSummary.displayName, '已退出成员');
    expect(removedSummary.totalPaid, 30.0);
    expect(
      aaStats.participants.map((participant) => participant.participantId),
      isNot(contains('vu-deleted')),
    );

    final expenseStats = await readProviderFutureFromContainer(
      container,
      memberExpenseStatsProvider('led-shared-aa').future,
    );
    final removedExpense = expenseStats.singleWhere(
      (item) => item.participantId == 'u-editor',
    );
    expect(removedExpense.displayName, '已退出成员');
    expect(removedExpense.expenseTotal, 30.0);

    final identity = await readProviderFutureFromContainer(
      container,
      ledgerIdentityProvider('led-shared-aa').future,
    );
    expect(identity.memberMap, contains('u-editor'));
    expect(identity.memberMap, isNot(contains('vu-deleted')));
  });
}
