import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/features/settings/application/import_target.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

/// 两笔支出的标准账单：确认页的映射与预览都对它成立。
const _csv =
    '日期,类型,金额,币种,分类,备注\n'
    '2026-01-01,支出,12.50,CNY,餐饮,午饭\n'
    '2026-01-02,支出,20.00,CNY,交通,地铁\n';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late ProviderContainer container;
  late WidgetRef widgetRef;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue('account'),
        // 当前账本刻意指向另一个账本：导入必须只认入口显式选择的目标。
        currentLedgerIdProvider.overrideWithBuild(
          (ref, notifier) => 'ledger-2',
        ),
        pendingCloudLedgerDownloadsProvider.overrideWithValue(
          const AsyncValue.data(<String>{}),
        ),
        // 设备身份随时可用，用来证明云账本缺成员时不会拿它兜底。
        localSelfIdProvider.overrideWithValue(
          const AsyncValue.data('device-1'),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpHarness(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            widgetRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
  }

  /// 建账本行：self member 与存储归属决定导入守卫的分支。
  Future<void> seedLedger(
    String id, {
    String storageMode = 'local',
    String? scopeAccountId,
    String? ownerAccountId,
    String? selfMemberId,
    String role = 'owner',
  }) => db
      .into(db.ledgers)
      .insert(
        LedgersCompanion.insert(
          id: id,
          name: '$id 账本',
          updatedAt: now,
          storageMode: d.Value(storageMode),
          scopeAccountId: d.Value(scopeAccountId),
          ownerAccountId: d.Value(ownerAccountId),
          selfMemberId: d.Value(selfMemberId),
          role: d.Value(role),
        ),
      );

  /// 复刻确认页的准备流程：固定目标 → 自动映射 → 逐条预览。
  Future<TransferActions> openSession(
    String text,
    String targetLedgerId, {
    String? recordPath,
  }) async {
    final table = TransferTable.parse(
      text,
      TransferKind.ledger,
      recordPath: recordPath,
    );
    final session = TransferActions(
      widgetRef.read,
      DataImportTarget(
        ledgerTarget: (
          bookId: targetLedgerId,
          accountId: widgetRef.read(currentAccountIdProvider),
          generation: widgetRef.read(authIdentityGenerationProvider),
          syncId: null,
        ),
      ),
      table,
      TransferKind.ledger,
    );
    await session.prepare();
    session.map(table.detect(TransferKind.ledger));
    await session.buildPreview();
    return session;
  }

  testWidgets('JSON同路径分组明细完整导入，重复内容保留且重开文件身份稳定', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await pumpHarness(tester);
    const text = '''
      {"groups":[
        {"entries":[{"date":"2026-01-01","amount":"10","category":"餐饮"}]},
        {"entries":[]},
        {"entries":[
          {"date":"2026-01-01","amount":"10","category":"餐饮"},
          {"date":"2026-01-02","amount":"20","category":"交通"}
        ]}
      ]}
    ''';

    await tester.runAsync(() async {
      final first = await openSession(
        text,
        'ledger-1',
        recordPath: 'groups.entries',
      );
      expect(first.preview, hasLength(3));
      expect(first.preview.every((row) => row.error == null), isTrue);
      expect(first.preview.map((row) => row.lines), [
        [1],
        [2],
        [3],
      ]);
      final ids = first.preview
          .map((row) => (row.value as ImportData).transactions.single.syncId)
          .toList();
      expect(ids.toSet(), hasLength(3), reason: '相同内容的两个真实记录拥有不同的行身份');
      final result = await first.import((_, _) {}, (_) {});
      expect(result.imported, 3);
      expect(result.failed, 0);

      final repeated = await openSession(
        text,
        'ledger-1',
        recordPath: 'groups.entries',
      );
      expect(repeated.exportId, first.exportId);
      expect(
        repeated.preview.map(
          (row) => (row.value as ImportData).transactions.single.syncId,
        ),
        ids,
      );
      expect(
        repeated.preview.every((row) => row.duplicate && !row.selected),
        isTrue,
      );
    });

    final rows = await db.select(db.transactions).get();
    expect(rows, hasLength(3));
    expect(rows.where((row) => row.amount == '10'), hasLength(2));
  });

  for (final iconHeader in [
    '二级分类图标',
    '子分类图标',
    'Subcategory Icon',
    'Sub Category Icon',
  ]) {
    testWidgets('只有$iconHeader时不把图标值导入为子分类', (tester) async {
      await seedLedger('ledger-1', selfMemberId: 'self-member-1');
      await pumpHarness(tester);

      await tester.runAsync(() async {
        final session = await openSession(
          '日期,类型,金额,币种,分类,$iconHeader\n'
              '2026-01-01,支出,10,CNY,餐饮,🍚\n',
          'ledger-1',
        );
        final mapping = session.table.detect(TransferKind.ledger);
        expect(mapping['sub_category_icon'], iconHeader);
        expect(mapping.containsKey('sub_category'), isFalse);
        final result = await session.import((_, _) {}, (_) {});
        expect(result.imported, 1);
        expect(result.failed, 0);
      });

      final categories = await db.select(db.categories).get();
      expect(categories, hasLength(1));
      expect(categories.single.name, '餐饮');
      expect(categories.single.parentId, isNull);
      final transaction = await db.select(db.transactions).getSingle();
      expect(transaction.categoryId, categories.single.id);
    });
  }

  testWidgets('确认页使用入口显式选择的目标账本，不写入当前账本', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await seedLedger('ledger-2', selfMemberId: 'self-member-2');
    await pumpHarness(tester);

    final imported = await tester.runAsync(() async {
      final session = await openSession(_csv, 'ledger-1');
      expect(session.preview.where((row) => row.error == null), hasLength(2));
      return (await session.import((_, _) {}, (_) {})).imported;
    });

    expect(imported, 2);
    final rows = await db.select(db.transactions).get();
    expect(rows, hasLength(2));
    expect(rows.map((tx) => tx.ledgerId).toSet(), {
      'ledger-1',
    }, reason: '落库账本来自入口选择的目标，与当前账本无关');
  });

  testWidgets('云端账本缺少 self member 时按账号身份派生，不使用设备身份兜底', (tester) async {
    await seedLedger(
      'ledger-1',
      storageMode: 'cloud',
      scopeAccountId: 'account',
      ownerAccountId: 'owner-account',
      selfMemberId: null,
      role: 'editor',
    );
    // 协作者只能使用账本所有者已发布的目录，导入身份测试提供完整权威镜像。
    for (final category in [
      (id: 'owner-food', name: '餐饮'),
      (id: 'owner-travel', name: '交通'),
    ]) {
      await db
          .into(db.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: 'ledger-1',
              categoryId: category.id,
              name: category.name,
              kind: 'expense',
              updatedAt: now,
            ),
          );
    }
    await pumpHarness(tester);

    final imported = await tester.runAsync(() async {
      final session = await openSession(_csv, 'ledger-1');
      expect(
        session.preview.where((row) => row.error == null),
        hasLength(2),
        reason: '缺 self 指针不影响预览本身的有效性',
      );
      return (await session.import((_, _) {}, (_) {})).imported;
    });

    expect(imported, 2, reason: '缺少 self 指针不应让整批导入失败');
    final rows = await db.select(db.transactions).get();
    expect(rows, hasLength(2));
    final accountMember = registeredMemberId('ledger-1', 'account');
    expect(
      rows.every((tx) => tx.payerMemberId == accountMember),
      isTrue,
      reason: '支出人取账号在账本内的派生成员',
    );
    expect(
      rows.any(
        (tx) => tx.payerMemberId == localSelfMemberId('ledger-1', 'device-1'),
      ),
      isFalse,
      reason: '设备身份 device-1 不得写入云端账本',
    );
  });

  testWidgets('非法千分位金额的行不可导入，不写入任何记录', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await pumpHarness(tester);

    await tester.runAsync(() async {
      final session = await openSession(
        '日期,类型,金额,币种,分类\n2026-01-01,支出,"12,34",CNY,餐饮\n',
        'ledger-1',
      );
      expect(session.preview.single.error, isNotNull);
      expect(session.preview.single.selected, isFalse);
      await expectLater(
        session.import((_, _) {}, (_) {}),
        throwsA(isA<StateError>()),
      );
    });

    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.categories).get(), isEmpty, reason: '坏行不得创建孤儿分类');
  });

  testWidgets('千分位与货币符号金额按精确 Decimal 落库', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await pumpHarness(tester);

    final imported = await tester.runAsync(() async {
      final session = await openSession(
        '日期,类型,金额,币种,分类\n2026-01-01,支出,"€1,234.50",CNY,餐饮\n',
        'ledger-1',
      );
      return (await session.import((_, _) {}, (_) {})).imported;
    });

    expect(imported, 1);
    final tx = (await db.select(db.transactions).get()).single;
    expect(tx.amount, '1234.5');
    expect(tx.nativeAmount, '1234.5');
    expect(tx.currencyCode, 'CNY');
  });

  testWidgets('坏行与跳过类型不计入导入，只写入有效记录', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await pumpHarness(tester);

    final imported = await tester.runAsync(() async {
      final session = await openSession(
        '日期,类型,金额,币种,分类\n'
            '2026-01-01,支出,12.50,CNY,餐饮\n'
            '2026-01-02,收入,20.00,CNY,红包\n'
            'bad-date,支出,5.00,CNY,餐饮\n'
            '2026-01-04,支出,abc,CNY,交通\n',
        'ledger-1',
      );
      expect(
        session.preview.where((row) => row.error == null),
        hasLength(1),
        reason: '坏日期、坏金额与收入行都不可选',
      );
      return (await session.import((_, _) {}, (_) {})).imported;
    });

    expect(imported, 1);
    final rows = await db.select(db.transactions).get();
    expect(rows, hasLength(1));
    expect(rows.single.amount, '12.5');
  });

  testWidgets('分类图标列随导入创建的分类落库', (tester) async {
    await seedLedger('ledger-1', selfMemberId: 'self-member-1');
    await pumpHarness(tester);

    final imported = await tester.runAsync(() async {
      final session = await openSession(
        '日期,类型,金额,币种,分类,分类图标\n2026-01-01,支出,18.00,CNY,餐饮,🍜\n',
        'ledger-1',
      );
      return (await session.import((_, _) {}, (_) {})).imported;
    });

    expect(imported, 1);
    final category = (await db.select(db.categories).get()).single;
    expect(category.name, '餐饮');
    expect(category.icon, '🍜');
  });
}
