// 明细 CSV 导入确认页测试。
//
// 覆盖：解析 loading → 字段映射（自动识别表头/无表头/空数据）→ 分类映射 →
// 导入全流程（无账本阻断 / 账本不存在 / 成功 / 坏行与跳过类型 / 导入异常）。
// 测试按页面需求断言 UI 文案与仓库调用，不复制实现细节。

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/presentation/import_confirm_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';

class _MockRepo extends Mock implements LocalRepository {}

/// 标准三行 CSV：表头 + 两笔支出，表头可被 GenericBillParser 全字段识别。
const _csv =
    '日期,类型,金额,币种,分类,备注\n'
    '2026-01-01,支出,12.50,CNY,餐饮,午饭\n'
    '2026-01-02,支出,20.00,CNY,交通,地铁\n';

/// 表头缺少「分类」列，用于验证下一步被阻断。
const _csvNoCategory = '日期,类型,金额\n2026-01-01,支出,12.50\n';

/// 包含坏行（日期/金额非法）与跳过类型（收入）的 CSV。
const _csvBadRows =
    '日期,类型,金额,币种,分类\n'
    '2026-01-01,支出,12.50,CNY,餐饮\n'
    '2026-01-02,收入,20.00,CNY,红包\n'
    'bad-date,支出,5.00,CNY,餐饮\n'
    '2026-01-04,支出,abc,CNY,交通\n';

/// 带完整二级分类路径的 CSV，用于锁定父分类不会在 DTO 转换时丢失。
const _csvWithSubCategory =
    '日期,类型,金额,币种,分类,二级分类\n'
    '2026-01-01,支出,18.00,CNY,餐饮,早餐\n';

/// 共享账本中无法自动匹配 Owner 分类的来源分类。
const _csvWithUnknownCategory =
    '日期,类型,金额,分类\n'
    '2026-01-01,支出,18.00,陌生分类\n';

/// 金额列用 CSV 引号保留逗号，用于区分合法千分位与非法分组。
String _csvWithAmount(String amount) =>
    '日期,类型,金额,币种,分类\n2026-01-01,支出,"$amount",CNY,餐饮\n';

/// 币种原样传入 CSV，用于验证非法值不会静默回退为账本默认币种。
String _csvWithCurrency(String currency) =>
    '日期,类型,金额,币种,分类\n2026-01-01,支出,12.50,$currency,餐饮\n';

/// 带分类图标列的 CSV，用于验证图标列映射后透传到分类创建。
const _csvWithCategoryIcon =
    '日期,类型,金额,币种,分类,分类图标\n'
    '2026-01-01,支出,18.00,CNY,餐饮,🍜\n';

/// companion → 实体行：供幂等去重测试模拟「存量交易」。
Transaction txFromCompanion(TransactionsCompanion c) => Transaction(
  id: c.id.value,
  ledgerId: c.ledgerId.value,
  txType: c.txType.value,
  amount: c.amount.value,
  categoryId: c.categoryId.value,
  happenedAt: c.happenedAt.value,
  note: c.note.value,
  recurringId: c.recurringId.present ? c.recurringId.value : null,
  createdByMemberId: c.createdByMemberId.present
      ? c.createdByMemberId.value
      : null,
  lastEditedByMemberId: c.lastEditedByMemberId.present
      ? c.lastEditedByMemberId.value
      : null,
  excludeFromStats: c.excludeFromStats.value,
  currencyCode: c.currencyCode.value,
  nativeAmount: c.nativeAmount.value,
  version: c.version.present ? c.version.value : 1,
  lastEditedAt: c.lastEditedAt.present ? c.lastEditedAt.value : null,
  payerMemberId: c.payerMemberId.present ? c.payerMemberId.value : null,
  aaMode: c.aaMode.value,
  createdAt: c.createdAt.value,
  updatedAt: c.updatedAt.value,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  Ledger ledgerFixture({
    String id = 'ledger-1',
    String name = '默认账本',
    String role = 'owner',
    String storageMode = 'local',
    String? selfMemberId = 'self-member-1',
    int memberCount = 1,
  }) => Ledger(
    id: id,
    name: name,
    currency: 'CNY',
    role: role,
    memberCount: memberCount,
    monthStartDay: 1,
    storageMode: storageMode,
    aaEnabled: false,
    selfMemberId: selfMemberId,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    resetGlobalTestState();
    repo = _MockRepo();
    when(
      () => repo.getLedgerById('ledger-1'),
    ).thenAnswer((_) async => ledgerFixture());
    when(() => repo.getAllCategories()).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.filterCategoriesForLedgerPicker(
        any(),
        ledgerId: any(named: 'ledgerId'),
        kind: any(named: 'kind'),
        topLevelOnly: any(named: 'topLevelOnly'),
      ),
    ).thenAnswer(
      (invocation) async =>
          invocation.positionalArguments.first as List<Category>,
    );
    when(
      () => repo.getTopLevelCategories('expense'),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.createCategory(
        name: any(named: 'name'),
        kind: any(named: 'kind'),
        icon: any(named: 'icon'),
        sortOrder: any(named: 'sortOrder'),
      ),
    ).thenAnswer((_) async => 'cat-1');
    // 导入服务去重与汇率预取所需数据：无存量交易、无有效汇率。
    when(
      () => repo.getTransactionsByLedger(any()),
    ).thenAnswer((_) async => <Transaction>[]);
    when(
      () => repo.getLatestAutoRates(any()),
    ).thenAnswer((_) async => <ExchangeRate>[]);
    when(
      () => repo.getOverrides(any()),
    ).thenAnswer((_) async => <ExchangeRateOverride>[]);
    when(
      () => repo.getMembersByLedger(any()),
    ).thenAnswer((_) async => <LedgerMember>[]);
    when(
      () => repo.insertTransactionsBatchWithRelations(
        transactions: any(named: 'transactions'),
        recordChanges: any(named: 'recordChanges'),
      ),
    ).thenAnswer((invocation) async {
      final txs =
          invocation.namedArguments[#transactions]
              as List<TransactionsCompanion>;
      return [for (final t in txs) t.id.value];
    });
    // 默认无待同步变更（本地账本语义），云端账本用例单独覆盖。
    when(() => repo.countPendingSyncChanges(any())).thenAnswer((_) async => 0);
  });

  /// 宿主：先渲染一个入口页，把 ImportConfirmPage 以 push 方式打开，
  /// 这样导入成功后的 pop 语义与真实导航一致，也可断言页面已关闭。
  Widget buildApp({
    required String csv,
    required bool hasHeader,
    String ledgerId = 'ledger-1',
    String? targetLedgerId,
    String? localSelfId,
  }) {
    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        if (localSelfId != null)
          localSelfIdProvider.overrideWith((ref) async => localSelfId),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => ledgerId),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImportConfirmPage(
                      csvText: csv,
                      hasHeader: hasHeader,
                      targetLedgerId: targetLedgerId ?? ledgerId,
                    ),
                  ),
                ),
                child: const Text('open-import'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 打开页面并等待后台 isolate 解析完成。
  Future<void> openAndParse(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.tap(find.text('open-import'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // compute 在真实 isolate 中解析，必须走 runAsync 让事件循环推进。
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// 点击「下一步」进入分类映射步骤。
  Future<void> goToCategoryStep(WidgetTester tester) async {
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
  }

  group('解析与字段映射', () {
    testWidgets('解析中显示 loading，解析完成进入字段映射步骤', (tester) async {
      await tester.pumpWidget(buildApp(csv: _csv, hasHeader: true));
      await tester.tap(find.text('open-import'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 后台 isolate 尚未返回时展示「准备中…」+ 转圈
      expect(find.text('准备中…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 字段映射步骤：标题、九个字段下拉、预览表、下一步
      expect(find.text('确认映射'), findsOneWidget);
      for (final label in [
        '日期',
        '类型',
        '金额',
        '币种',
        '分类',
        '二级分类',
        '分类图标',
        '二级分类图标',
        '备注',
      ]) {
        expect(find.text(label), findsWidgets, reason: '应展示字段 $label');
      }
      expect(find.text('预览：'), findsOneWidget);
      expect(find.text('下一步'), findsOneWidget);
      // 预览表头行与两行数据
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('12.50'), findsOneWidget);
    });

    testWidgets('表头自动识别：日期/类型/金额/分类被自动映射', (tester) async {
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);
      expect(find.text('分类映射'), findsOneWidget);
      expect(find.text('开始导入'), findsOneWidget);
      // 源分类列表包含表内去重后的分类名
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
    });

    testWidgets('无表头时全部字段未映射，点击下一步被阻断并提示', (tester) async {
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: false));

      expect(find.text('自动'), findsWidgets, reason: '未映射字段显示「自动」提示');
      await tester.tap(find.text('下一步'));
      await tester.pump();
      expect(find.text('请先选择"分类"列再继续'), findsOneWidget);
      // 仍停留在映射步骤
      expect(find.text('确认映射'), findsOneWidget);
      // 清掉 toast 自动消失定时器
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('表头缺分类列时下一步被阻断', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csvNoCategory, hasHeader: true),
      );

      await tester.tap(find.text('下一步'));
      await tester.pump();
      expect(find.text('请先选择"分类"列再继续'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('空 CSV 提示无数据且不得进入导入', (tester) async {
      await openAndParse(tester, buildApp(csv: '', hasHeader: true));

      expect(find.text('未解析到任何数据，请返回上一页检查 CSV 内容或分隔符。'), findsOneWidget);
      expect(find.text('开始导入'), findsNothing);
      expect(tester.takeException(), isNull);
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
    });

    testWidgets('仅表头 CSV 提示无数据且不得进入导入', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: '日期,类型,金额,币种,分类,备注\n', hasHeader: true),
      );

      expect(find.text('未解析到任何数据，请返回上一页检查 CSV 内容或分隔符。'), findsOneWidget);
      expect(find.text('开始导入'), findsNothing);
      expect(tester.takeException(), isNull);
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
    });

    testWidgets('超过 10 行时预览展示截断提示', (tester) async {
      final buf = StringBuffer('日期,类型,金额\n');
      for (var i = 1; i <= 15; i++) {
        buf.writeln('2026-01-${i.toString().padLeft(2, '0')},支出,$i.00');
      }
      await openAndParse(
        tester,
        buildApp(csv: buf.toString(), hasHeader: true),
      );

      // 1 行表头 + 15 行数据 = 16 行，仅预览前 10 行
      expect(find.text('仅预览前 10 行，共 16 行'), findsOneWidget);
    });
  });

  group('分类映射', () {
    testWidgets('共享 editor 只展示 Owner 分类镜像', (tester) async {
      final privateCategory = Category(
        id: 'private-category',
        name: '我的私有分类',
        kind: 'expense',
        sortOrder: 0,
        level: 1,
        updatedAt: DateTime(2026, 1, 1),
      );
      final ownerCategory = Category(
        id: 'owner-category',
        name: '餐饮',
        kind: 'expense',
        sortOrder: 0,
        level: 1,
        updatedAt: DateTime(2026, 1, 1),
      );
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async =>
            ledgerFixture(role: 'editor', storageMode: 'cloud', memberCount: 2),
      );
      when(
        () => repo.getAllCategories(),
      ).thenAnswer((_) async => [privateCategory]);
      when(
        () => repo.filterCategoriesForLedgerPicker(
          any(),
          ledgerId: 'ledger-1',
          kind: 'expense',
          topLevelOnly: false,
        ),
      ).thenAnswer((_) async => [ownerCategory]);

      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));
      await goToCategoryStep(tester);

      expect(find.text('餐饮（一级分类）'), findsWidgets);
      expect(find.text('我的私有分类（一级分类）'), findsNothing);
      verify(
        () => repo.filterCategoriesForLedgerPicker(
          any(),
          ledgerId: 'ledger-1',
          kind: 'expense',
          topLevelOnly: false,
        ),
      ).called(1);
    });

    testWidgets('共享 editor 分类未匹配时禁止自动创建并阻断导入', (tester) async {
      final ownerCategory = Category(
        id: 'owner-category',
        name: '所有者分类',
        kind: 'expense',
        sortOrder: 0,
        level: 1,
        updatedAt: DateTime(2026, 1, 1),
      );
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async =>
            ledgerFixture(role: 'editor', storageMode: 'cloud', memberCount: 2),
      );
      when(
        () => repo.filterCategoriesForLedgerPicker(
          any(),
          ledgerId: 'ledger-1',
          kind: 'expense',
          topLevelOnly: false,
        ),
      ).thenAnswer((_) async => [ownerCategory]);

      await openAndParse(
        tester,
        buildApp(csv: _csvWithUnknownCategory, hasHeader: true),
      );
      await goToCategoryStep(tester);

      expect(find.text('保持原名（自动创建/合并）'), findsNothing);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      expect(find.text('共享账本分类必须映射到所有者分类'), findsOneWidget);
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      verifyNever(
        () => repo.createCategory(
          name: any(named: 'name'),
          kind: any(named: 'kind'),
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      );
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('共享 editor 映射二级 Owner 分类后直接写 UUID 且不创建分类', (tester) async {
      final parent = Category(
        id: 'owner-food',
        name: '餐饮',
        kind: 'expense',
        sortOrder: 0,
        level: 1,
        updatedAt: DateTime(2026, 1, 1),
      );
      final child = Category(
        id: 'owner-breakfast',
        name: '早餐',
        kind: 'expense',
        sortOrder: 0,
        parentId: parent.id,
        level: 2,
        updatedAt: DateTime(2026, 1, 1),
      );
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async =>
            ledgerFixture(role: 'editor', storageMode: 'cloud', memberCount: 2),
      );
      when(
        () => repo.filterCategoriesForLedgerPicker(
          any(),
          ledgerId: 'ledger-1',
          kind: 'expense',
          topLevelOnly: false,
        ),
      ).thenAnswer((_) async => [parent, child]);

      await openAndParse(
        tester,
        buildApp(csv: _csvWithSubCategory, hasHeader: true),
      );
      await goToCategoryStep(tester);
      expect(find.text('餐饮 > 早餐（二级分类）'), findsWidgets);

      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();
      final captured =
          verify(
                () => repo.insertTransactionsBatchWithRelations(
                  transactions: captureAny(named: 'transactions'),
                  recordChanges: any(named: 'recordChanges'),
                ),
              ).captured.single
              as List<TransactionsCompanion>;
      expect(captured.single.categoryId.value, child.id);
      verifyNever(
        () => repo.createCategory(
          name: any(named: 'name'),
          kind: any(named: 'kind'),
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      );
      verifyNever(
        () => repo.createSubCategory(
          parentId: any(named: 'parentId'),
          name: any(named: 'name'),
          kind: any(named: 'kind'),
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      );
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('映射下拉可选择系统分类并自动按名称匹配', (tester) async {
      when(() => repo.getAllCategories()).thenAnswer(
        (_) async => [
          Category(
            id: '1',
            name: '餐饮',
            kind: 'expense',
            sortOrder: 0,
            level: 1,
            updatedAt: DateTime(2026, 1, 1),
          ),
          Category(
            id: '2',
            name: '交通',
            kind: 'expense',
            sortOrder: 1,
            level: 1,
            updatedAt: DateTime(2026, 1, 1),
          ),
          Category(
            id: '3',
            name: '早餐',
            kind: 'expense',
            sortOrder: 0,
            level: 2,
            parentId: '1',
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);

      // 自动匹配：餐饮命中 id=1（下拉应展示「餐饮（一级分类）」）
      expect(find.text('餐饮（一级分类）'), findsWidgets);
      // 交通未命中（初始为「保持原名」），手工改为系统分类 id=2
      final row = find.ancestor(
        of: find.text('交通').first,
        matching: find.byType(Row),
      );
      await tester.tap(
        find.descendant(
          of: row.first,
          matching: find.byType(DropdownButton<String?>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('交通（一级分类）').last);
      await tester.pumpAndSettle();

      // 选中后分类映射下拉应展示系统分类名
      expect(find.text('交通（一级分类）'), findsWidgets);
    });

    testWidgets('分类映射步展示预检查摘要（坏行/跳过/缺分类统计）', (tester) async {
      await openAndParse(tester, buildApp(csv: _csvBadRows, hasHeader: true));

      await goToCategoryStep(tester);

      // 4 行数据：1 行正常、1 行收入跳过、1 行日期无效、1 行金额无效
      expect(find.text('导入预检查'), findsOneWidget);
      expect(find.text('共 4 行数据'), findsOneWidget);
      expect(find.text('金额无效：1'), findsOneWidget);
      expect(find.text('日期无效：1'), findsOneWidget);
      expect(find.text('非支出类型跳过：1'), findsOneWidget);
    });

    testWidgets('预检查摘要统计币种异常与无分类行', (tester) async {
      const csv =
          '日期,类型,金额,币种,分类\n'
          '2026-01-01,支出,12.50,US\$,餐饮\n'
          '2026-01-02,支出,20.00,CNY,\n';
      await openAndParse(tester, buildApp(csv: csv, hasHeader: true));

      await goToCategoryStep(tester);

      expect(find.text('共 2 行数据'), findsOneWidget);
      expect(find.text('币种异常：1'), findsOneWidget);
      expect(find.text('无分类：1'), findsOneWidget);
    });

    testWidgets('上一步返回字段映射，再下一步回到分类映射', (tester) async {
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);
      expect(find.text('分类映射'), findsOneWidget);

      await tester.tap(find.text('上一步'));
      await tester.pumpAndSettle();
      expect(find.text('确认映射'), findsOneWidget);

      await goToCategoryStep(tester);
      expect(find.text('分类映射'), findsOneWidget);
    });
  });

  group('开始导入', () {
    testWidgets('非法逗号分组金额不得调用批量写入', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csvWithAmount('12,34'), hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      verifyNever(
        () => repo.createCategory(
          name: any(named: 'name'),
          kind: any(named: 'kind'),
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      );
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('非法币种不得静默回退默认币种并落库', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csvWithCurrency(r'US$'), hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('欧元/英镑符号前缀金额正常导入', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csvWithAmount('€100'), hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => repo.insertTransactionsBatchWithRelations(
                  transactions: captureAny(named: 'transactions'),
                  recordChanges: any(named: 'recordChanges'),
                ),
              ).captured.single
              as List<TransactionsCompanion>;
      expect(captured.single.amount.value, '100');
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('合法千分位金额以精确 Decimal 值导入', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csvWithAmount('1,234.50'), hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => repo.insertTransactionsBatchWithRelations(
                  transactions: captureAny(named: 'transactions'),
                  recordChanges: any(named: 'recordChanges'),
                ),
              ).captured.single
              as List<TransactionsCompanion>;
      expect(captured.single.amount.value, '1234.5');
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('确认页使用入口显式选择的目标账本，不读取当前账本', (tester) async {
      when(() => repo.getLedgerById('ledger-2')).thenAnswer(
        (_) async => ledgerFixture(
          id: 'ledger-2',
          name: '后来切换的账本',
          selfMemberId: 'self-member-2',
        ),
      );
      await openAndParse(
        tester,
        buildApp(
          csv: _csv,
          hasHeader: true,
          ledgerId: 'ledger-2',
          targetLedgerId: 'ledger-1',
        ),
      );

      expect(find.text('导入账本：默认账本'), findsOneWidget);
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));

      final captured =
          verify(
                () => repo.insertTransactionsBatchWithRelations(
                  transactions: captureAny(named: 'transactions'),
                  recordChanges: any(named: 'recordChanges'),
                ),
              ).captured.single
              as List<TransactionsCompanion>;
      expect(captured, isNotEmpty);
      expect(captured.every((tx) => tx.ledgerId.value == 'ledger-1'), isTrue);
    });

    testWidgets('云端账本缺少 self member 时拒绝导入且不使用设备身份', (tester) async {
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async => ledgerFixture(
          role: 'editor',
          storageMode: 'cloud',
          selfMemberId: null,
        ),
      );
      await openAndParse(
        tester,
        buildApp(csv: _csv, hasHeader: true, localSelfId: 'device-1'),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();

      expect(find.text('云端账本尚未就绪，正在同步…'), findsOneWidget);
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('无当前账本时阻断并提示先创建账本', (tester) async {
      await openAndParse(
        tester,
        buildApp(csv: _csv, hasHeader: true, ledgerId: ''),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();

      expect(find.text('请先创建账本再导入'), findsOneWidget);
      expect(find.text('分类映射'), findsOneWidget, reason: '页面不跳转');
      // 未发起导入：仓库不应收到批量写入
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('账本不存在时阻断并提示', (tester) async {
      var ledgerCalls = 0;
      when(() => repo.getLedgerById('ledger-1')).thenAnswer((_) async {
        ledgerCalls++;
        return ledgerCalls == 1 ? ledgerFixture() : null;
      });
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('请先创建账本再导入'), findsOneWidget);
      verifyNever(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('导入成功：进度弹窗 → 完成 toast → 关闭页面', (tester) async {
      // 让批量写入耗时 100ms，确保进度弹窗可被观察到。
      when(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      ).thenAnswer((invocation) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final txs =
            invocation.namedArguments[#transactions]
                as List<TransactionsCompanion>;
        return [for (final t in txs) t.id.value];
      });
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // 进度弹窗出现（导入仍在等待写入完成）
      expect(find.text('正在导入…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('正在导入…'), findsNothing);
      expect(find.text('导入完成：成功 2 条，失败 0 条'), findsOneWidget);
      // 页面已 pop 回宿主
      expect(find.text('open-import'), findsOneWidget);
      expect(find.text('开始导入'), findsNothing);

      // 仓库收到一次批量写入（两笔交易一个批次）
      verify(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      ).called(1);

      // 冲刷 5 秒延迟清空进度与 toast 定时器
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });
    testWidgets('同一 CSV 再次导入：幂等键跳过并提示已存在', (tester) async {
      // 首次导入落库后的交易；第二次导入按确定性幂等键去重。
      final importedTxs = <Transaction>[];
      when(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      ).thenAnswer((invocation) async {
        final txs =
            invocation.namedArguments[#transactions]
                as List<TransactionsCompanion>;
        importedTxs.addAll(txs.map(txFromCompanion));
        return [for (final t in txs) t.id.value];
      });
      when(
        () => repo.getTransactionsByLedger(any()),
      ).thenAnswer((_) async => List.of(importedTxs));

      // 第一次导入：两行全部成功并关闭页面。
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();
      expect(find.text('导入完成：成功 2 条，失败 0 条'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));

      // 重新打开同一文件再次导入：全部按幂等键跳过，不再次插入。
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('导入完成'), findsOneWidget);
      expect(find.textContaining('已存在，跳过 2 条'), findsOneWidget);
      verify(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: any(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      ).called(1);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('云端 editor 导入：三个人员字段使用账本 self member', (tester) async {
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async => ledgerFixture(role: 'editor', storageMode: 'cloud'),
      );
      await openAndParse(
        tester,
        buildApp(csv: _csv, hasHeader: true, localSelfId: 'device-1'),
      );
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));

      final captured = verify(
        () => repo.insertTransactionsBatchWithRelations(
          transactions: captureAny(named: 'transactions'),
          recordChanges: any(named: 'recordChanges'),
        ),
      ).captured;
      final txs = captured.single as List<TransactionsCompanion>;
      expect(txs, hasLength(2));
      for (final t in txs) {
        expect(t.payerMemberId.value, 'self-member-1');
        expect(t.createdByMemberId.value, 'self-member-1');
        expect(t.lastEditedByMemberId.value, 'self-member-1');
      }
    });

    testWidgets('二级分类 CSV 导入后交易指向子分类', (tester) async {
      when(
        () => repo.createCategory(
          name: '餐饮',
          kind: 'expense',
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => 'parent-food');
      when(
        () => repo.createSubCategory(
          parentId: 'parent-food',
          name: '早餐',
          kind: 'expense',
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => 'child-breakfast');
      await openAndParse(
        tester,
        buildApp(csv: _csvWithSubCategory, hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => repo.insertTransactionsBatchWithRelations(
                  transactions: captureAny(named: 'transactions'),
                  recordChanges: any(named: 'recordChanges'),
                ),
              ).captured.single
              as List<TransactionsCompanion>;
      expect(captured.single.categoryId.value, 'child-breakfast');
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('分类图标列映射后图标透传到分类创建', (tester) async {
      // 显式覆盖账本查询：避免同文件其他用例对 getLedgerById 的 when 残留
      // （mocktail 的 stub 注册在同一 mock 实例上，跨用例不清除）。
      when(
        () => repo.getLedgerById('ledger-1'),
      ).thenAnswer((_) async => ledgerFixture());
      when(
        () => repo.createCategory(
          name: '餐饮',
          kind: 'expense',
          icon: any(named: 'icon'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async => 'cat-food');
      await openAndParse(
        tester,
        buildApp(csv: _csvWithCategoryIcon, hasHeader: true),
      );

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      verify(
        () => repo.createCategory(
          name: '餐饮',
          kind: 'expense',
          icon: '🍜',
          sortOrder: any(named: 'sortOrder'),
        ),
      ).called(1);
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('云端账本导入完成后提示待同步条数', (tester) async {
      when(() => repo.getLedgerById('ledger-1')).thenAnswer(
        (_) async => ledgerFixture(role: 'editor', storageMode: 'cloud'),
      );
      when(
        () => repo.countPendingSyncChanges('ledger-1'),
      ).thenAnswer((_) async => 2);

      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 条记录待同步'), findsOneWidget);
      verify(() => repo.countPendingSyncChanges('ledger-1')).called(1);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('本地账本导入完成后不提示待同步', (tester) async {
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));
      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pumpAndSettle();

      expect(find.textContaining('待同步'), findsNothing);
      // 本地账本不进入同步队列：不应查询待同步计数。
      verifyNever(() => repo.countPendingSyncChanges(any()));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('坏行与跳过类型：完成弹窗展示明细，确认后关闭页面', (tester) async {
      await openAndParse(tester, buildApp(csv: _csvBadRows, hasHeader: true));

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // 有失败/跳过 → 弹「导入完成」对话框
      expect(find.text('导入完成'), findsOneWidget);
      expect(find.textContaining('无法解析的 2 行已跳过'), findsOneWidget);
      expect(find.textContaining('跳过 1 条非支出记录'), findsOneWidget);
      expect(find.textContaining('收入(1)'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.text('open-import'), findsOneWidget, reason: '确认后关闭确认页');

      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('导入服务异常：提示操作失败并进入失败统计弹窗', (tester) async {
      // 页面展示目标、_startImport 预检各查一次账本；导入服务内部再查一次，
      // 第三次查询抛错，模拟通过预检后在导入中途失败。
      var ledgerCalls = 0;
      when(() => repo.getLedgerById('ledger-1')).thenAnswer((_) async {
        ledgerCalls++;
        if (ledgerCalls > 2) throw Exception('boom');
        return ledgerFixture();
      });
      await openAndParse(tester, buildApp(csv: _csv, hasHeader: true));

      await goToCategoryStep(tester);
      await tester.tap(find.text('开始导入'));
      await tester.pump();

      // 异常发生在同一帧微任务内:toast 已弹出(1 秒后自动消失)
      expect(find.text('操作失败，请稍后重试'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('导入完成'), findsOneWidget);
      expect(find.textContaining('成功 0 条，失败 2 条'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
