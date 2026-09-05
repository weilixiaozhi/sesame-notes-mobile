/// memberExpenseStatsProvider 金额单位单测。
///
/// 锁定行为：数据库金额为规范化 Decimal 字符串（单位：元），provider 直接
/// 解析输出，与 AaStatisticsService / 账本卡片口径一致。
library;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'dart:ui' show Locale;

/// 插库交易 id 自增序列（主键为 UUID 字符串，需保证同文件内唯一）。
var _txSeq = 0;

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
    profile: CloudProfile(userId: 'cloud-user-1', displayName: '云昵称'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late ProviderContainer container;

  ProviderContainer buildContainer({bool cloudAccount = false}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
        // 固定中文环境,展示名断言不随系统语言漂移。
        languageProvider.overrideWith(_ZhLanguageNotifier.new),
        if (cloudAccount)
          accountStateProvider.overrideWith(_CloudAccountNotifier.new),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    // createLedger 返回 UUID，捕获后作为 family 参数。
    ledgerId = await repo.createLedger(
      name: '测试账本',
      storageMode: 'local',
      aaEnabled: true,
    );
    container = buildContainer();
  });

  tearDown(() async => db.close());

  /// 直接插库一笔支出交易（金额为 Decimal 字符串「元」）。
  Future<void> seedExpense({
    required String amount,
    required String payerMemberId,
  }) {
    final at = DateTime(2026, 8, 3, 12, 0);
    return db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-${_txSeq++}',
            ledgerId: ledgerId,
            txType: 'expense',
            amount: amount,
            happenedAt: at,
            currencyCode: 'CNY',
            nativeAmount: amount,
            payerMemberId: Value(payerMemberId),
            createdAt: at,
            updatedAt: at,
          ),
        );
  }

  test('成员支出金额按「元」输出（Decimal 字符串直接解析）', () async {
    // u1: 10 元 + 25 元 = 35 元；u2: 5 元。
    await seedExpense(amount: '10', payerMemberId: 'u1');
    await seedExpense(amount: '25', payerMemberId: 'u1');
    await seedExpense(amount: '5', payerMemberId: 'u2');

    final stats = await readProviderFutureFromContainer(
      container,
      memberExpenseStatsProvider(ledgerId).future,
    );

    final u1 = stats.firstWhere((s) => s.participantId == 'u1');
    expect(u1.expenseTotal, 35.0, reason: '金额按「元」字符串入库，provider 直接解析输出');
    expect(u1.txCount, 2);

    final u2 = stats.firstWhere((s) => s.participantId == 'u2');
    expect(u2.expenseTotal, 5.0);
    expect(u2.txCount, 1);
  });

  test('多币种成员支出按折本位币 nativeAmount 汇总，不再累加原币金额', () async {
    // u1: 美元原币 50 元（nativeAmount=70 元）+ 人民币 10 元
    // 期望按本位币合计 80 元，而不是原币 60 元。
    final at = DateTime(2026, 8, 3, 12, 0);
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-multi-1',
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '50',
            currencyCode: 'USD',
            nativeAmount: '70',
            happenedAt: at,
            payerMemberId: Value('u1'),
            createdAt: at,
            updatedAt: at,
          ),
        );
    await seedExpense(amount: '10', payerMemberId: 'u1');

    final stats = await readProviderFutureFromContainer(
      container,
      memberExpenseStatsProvider(ledgerId).future,
    );

    final u1 = stats.firstWhere((s) => s.participantId == 'u1');
    expect(u1.expenseTotal, 80.0, reason: '跨币种必须按折本位币求和，不得把美元原币当人民币直接累加');
    expect(u1.txCount, 2);
  });

  test('本地账本：self member 恒显固定本地身份「单机芝麻仔」，不再裸 id', () async {
    final c = buildContainer();
    // 本地账本「我」= self member id（uuidV5 派生，稳定不随登录变化）。
    final selfMemberId = localSelfMemberId(ledgerId, 'local-self');
    await seedExpense(amount: '10', payerMemberId: selfMemberId);

    final stats = await readProviderFutureFromContainer(
      c,
      memberExpenseStatsProvider(ledgerId).future,
    );
    final row = stats.single;
    expect(row.displayName, '单机芝麻仔', reason: '本地账本本人必须显示固定本地身份，不得出现裸 id');
    expect(row.isSelf, isTrue, reason: 'self member 必须标记为本人');
  });

  test('本地账本：未知 id 不套本地身份，兜底「未知」', () async {
    final c = buildContainer();
    await seedExpense(amount: '10', payerMemberId: 'foreign-id');

    final stats = await readProviderFutureFromContainer(
      c,
      memberExpenseStatsProvider(ledgerId).future,
    );
    final row = stats.single;
    expect(row.participantId, 'foreign-id');
    expect(row.displayName, '未知', reason: '未知 id 不得张冠李戴成固定本地身份，也不得裸显 id');
    expect(row.isSelf, isFalse);
  });

  test('云账本：本人显当前云 Profile 昵称', () async {
    final cloudLedgerId = await repo.createLedger(
      name: '共享账本',
      storageMode: 'cloud',
      aaEnabled: true,
    );
    final c = buildContainer(cloudAccount: true);
    await seedExpense(amount: '10', payerMemberId: 'local-self');
    // 将交易迁到云账本（云账本无成员行时本人回退 localSelfId 判定）。
    await (db.update(db.transactions)..where((t) => t.id.isNotNull())).write(
      TransactionsCompanion(ledgerId: Value(cloudLedgerId)),
    );

    final stats = await readProviderFutureFromContainer(
      c,
      memberExpenseStatsProvider(cloudLedgerId).future,
    );
    final row = stats.single;
    expect(row.displayName, '云昵称', reason: '云账本本人必须显示当前云 Profile 昵称');
    expect(row.isSelf, isTrue);
  });
}
