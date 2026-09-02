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
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/avatar_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';

/// 插库交易 id 自增序列（主键为 UUID 字符串，需保证同文件内唯一）。
var _txSeq = 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late ProviderContainer container;

  ProviderContainer buildContainer({String displayName = ''}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        avatarPathProvider.overrideWith((ref) async => null),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
        displayNameProvider.overrideWithBuild((ref, notifier) => displayName),
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

    final stats = await container.read(
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

    final stats = await container.read(
      memberExpenseStatsProvider(ledgerId).future,
    );

    final u1 = stats.firstWhere((s) => s.participantId == 'u1');
    expect(u1.expenseTotal, 80.0, reason: '跨币种必须按折本位币求和，不得把美元原币当人民币直接累加');
    expect(u1.txCount, 2);
  });

  test('本地账本：self member 解析为本人昵称，不再裸 id', () async {
    final c = buildContainer(displayName: '我的昵称');
    // 本地账本「我」= self member id（uuidV5 派生，稳定不随登录变化）。
    final selfMemberId = localSelfMemberId(ledgerId, 'local-self');
    await seedExpense(amount: '10', payerMemberId: selfMemberId);

    final stats = await c.read(memberExpenseStatsProvider(ledgerId).future);
    final row = stats.single;
    expect(
      row.displayName,
      '我的昵称',
      reason: 'self member id 必须解析为本地昵称，不得出现裸 id',
    );
    expect(row.isSelf, isTrue, reason: 'self member 必须标记为本人');
  });

  test('本地账本：未知 id 不再套本地昵称，兜底原始 id', () async {
    final c = buildContainer(displayName: '我的昵称');
    await seedExpense(amount: '10', payerMemberId: 'foreign-id');

    final stats = await c.read(memberExpenseStatsProvider(ledgerId).future);
    final row = stats.single;
    expect(row.participantId, 'foreign-id');
    expect(row.displayName, 'foreign-id', reason: '未知 id 不得张冠李戴成我的昵称');
    expect(row.isSelf, isFalse);
  });
}
