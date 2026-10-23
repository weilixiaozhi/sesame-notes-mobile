import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'dart:ui' show Locale;

/// 固定中文语言环境。
class _ZhLanguageNotifier extends LanguageNotifier {
  @override
  Locale? build() => const Locale('zh');
}

/// 已登录云账号状态:昵称「云昵称」。
class _CloudAccountNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(
      userId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      displayName: '云昵称',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  ProviderContainer buildContainer({bool cloudAccount = false}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
        languageProvider.overrideWith(_ZhLanguageNotifier.new),
        if (cloudAccount)
          accountStateProvider.overrideWith(_CloudAccountNotifier.new),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 插入一个共享账本行(memberCount>1,storageMode 可自定义)。
  Future<String> seedLedger({required String storageMode}) async {
    const ledgerId = '11111111-1111-4111-8111-111111111111';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '共享账本',
            memberCount: d.Value(2),
            role: d.Value('owner'),
            aaEnabled: d.Value(true),
            storageMode: d.Value(storageMode),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    return ledgerId;
  }

  /// 插入绑定当前云账号的 REGISTERED 本人成员行(displayName 可空)。
  Future<void> seedBoundSelf(
    String ledgerId, {
    String displayName = 'Owner',
  }) async {
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-owner',
            ledgerId: ledgerId,
            displayName: displayName,
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value(
              'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
            ),
            role: const d.Value('editor'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
  }

  test('本地账本：self 恒显固定本地身份，云昵称不注入（I-04）', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
      aaEnabled: true,
    );
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    final selfMemberId = localSelfMemberId(ledgerId, 'local-self');
    expect(
      identity.selfMemberId,
      selfMemberId,
      reason: '本地账本 self = 确定性派生的 LOCAL 成员',
    );
    expect(
      identity.displayNameOf(selfMemberId),
      '单机芝麻仔',
      reason: '本地身份与云身份独立,已登录也不得显示云昵称',
    );
    expect(identity.isSelfOf(selfMemberId), isTrue);
  });

  test('云账本无成员行：交易三个身份字段引用云成员且统计均显云昵称', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    final c = buildContainer(cloudAccount: true);
    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    final author = identity.selfMemberId;
    // 固定值与服务端 UUIDv5 契约一致，不通过被测派生函数生成期望。
    const cloudMemberId = '056cf10d-2d59-599c-9d97-6749e866aa52';
    expect(author, cloudMemberId);
    expect(
      identity.selfMemberId,
      cloudMemberId,
      reason: '交易必须引用当前账号在云账本中的成员，设备身份不是云成员',
    );
    expect(identity.displayNameOf(cloudMemberId), '云昵称');
    expect(identity.isSelfOf(cloudMemberId), isTrue);
    expect(identity.isSelfOf('local-self'), isFalse);
    expect(
      await repo.getMembersByLedger(ledgerId),
      isEmpty,
      reason: '展示身份兜底不得伪造本地成员或云端成员记录',
    );

    final transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '12',
      happenedAt: DateTime(2026, 8, 8),
      aaMode: 0,
      operatorMemberId: author,
    );
    final transaction = (await repo.getTransactionById(transactionId))!;
    expect(transaction.payerMemberId, cloudMemberId);
    expect(transaction.createdByMemberId, cloudMemberId);
    expect(transaction.lastEditedByMemberId, cloudMemberId);
    final aa = await readProviderFutureFromContainer(
      c,
      aaStatisticsProvider(ledgerId).future,
    );
    final expenses = await readProviderFutureFromContainer(
      c,
      memberExpenseStatsProvider(ledgerId).future,
    );
    expect(aa.participants.single.displayName, '云昵称');
    expect(expenses.single.displayName, '云昵称');
    expect(expenses.single.expenseTotal, 12);
  });

  test('云账本无成员和账号资料：不得将设备身份或本地派生成员作为作者', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    final c = buildContainer();

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.selfMemberId, isEmpty);
    expect(identity.isSelfOf('local-self'), isFalse);
    expect(identity.displayNameOf('local-self'), '未知');
  });

  test('共享账本 storageMode 未回填 cloud：本人仍显云昵称并标记「我」', () async {
    final ledgerId = await seedLedger(storageMode: 'local');
    await seedBoundSelf(ledgerId);
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(
      identity.displayNameOf('u-owner'),
      '云昵称',
      reason: '共享账本(memberCount>1)必须按云账本口径解析,不得退回本地身份口径',
    );
    expect(identity.isSelfOf('u-owner'), isTrue);
  });

  test('self_member_id 缺失：按绑定当前账号的 REGISTERED 成员解析本人', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    await seedBoundSelf(ledgerId);
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(
      identity.selfMemberId,
      'u-owner',
      reason: '绑定成员存在时 self 必须是该成员,不能裸回退设备 id',
    );
  });

  test('资料缓存未就绪：本人回退成员行昵称,再回退「未知」', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    // 不登录:云昵称不可用,回退成员行昵称。
    await seedBoundSelf(ledgerId, displayName: 'Owner');
    final c = buildContainer();

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.displayNameOf('u-owner'), 'Owner');

    // 成员行昵称为空:防御性兜底「未知」,绝不裸显 id。
    await (db.update(db.ledgerMembers)..where((m) => m.id.equals('u-owner')))
        .write(const LedgerMembersCompanion(displayName: d.Value('')));
    c.invalidate(ledgerIdentityProvider(ledgerId));
    final refreshed = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(refreshed.displayNameOf('u-owner'), '未知');
  });

  test('未知参与人统一「未知」,虚拟用户解析自身名称', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    await seedBoundSelf(ledgerId);
    await repo.createPlaceholderMember(
      ledgerId: ledgerId,
      name: '室友A',
      id: 'vu-1',
    );
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.displayNameOf('vu-1'), '室友A');
    expect(identity.isSelfOf('vu-1'), isFalse);
    expect(identity.displayNameOf('foreign-id'), '未知');
    expect(identity.displayNameOf(null), '未知');
  });
}
