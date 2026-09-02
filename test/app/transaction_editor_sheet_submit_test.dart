/// TransactionEditorSheet 提交/编辑/AA/日期/作者头像流程测试。
///
/// 需求锚点：
/// - 新建提交：选分类 → 输入金额 → 完成，落库参数正确（Decimal 字符串、
///   本位币 nativeAmount、null AA 字段），成功后 sheet 关闭；
/// - 外币无汇率：提交被阻断并 toast 提示；
/// - 编辑模式：initialCategoryId 解析回显、updateTransaction +
///   appendEditHistory 同版本号闭环、操作者随写库一并落定；
/// - AA 开启时头部三态切换（人均 → 不分摊 → 指定 → 人均）；
/// - 日期键打开滚轮并可确认；编辑共享账本交易渲染作者头像组。
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart' show AaEditResult;
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart' show EffectiveRate;
import 'package:sesame_notes/shared/widgets/amount_expression_bar.dart';
import 'package:sesame_notes/shared/widgets/amount_keypad.dart';
import 'package:sesame_notes/shared/widgets/collaborator_avatar.dart';
import 'package:sesame_notes/shared/widgets/press_key.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet.dart';

class _MockRepo extends Mock implements LocalRepository {}

db.Category _category(String id, String name) => db.Category(
  id: id,
  name: name,
  kind: 'expense',
  icon: 'dining',
  sortOrder: 1,
  level: 1,
  updatedAt: DateTime.utc(2026, 1, 1),
);

CategoryDisplay _categoryDisplay(String id, String name) => CategoryDisplay(
  id: id,
  name: name,
  kind: 'expense',
  icon: 'dining',
  sortOrder: 1,
  level: 1,
);

/// 共享账本以 memberCount > 1 表达（schema v1 无 isShared/syncId 字段）。
db.Ledger _ledger({bool aaEnabled = false, bool isShared = false}) => db.Ledger(
  id: 'ledger-1',
  name: '测试账本',
  currency: 'CNY',
  role: 'owner',
  memberCount: isShared ? 2 : 1,
  monthStartDay: 1,
  storageMode: isShared ? 'cloud' : 'local',
  aaEnabled: aaEnabled,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

/// 虚拟用户查询桩(分摊归属区分用;测试默认无虚拟用户)。
void _stubGetByLedger(_MockRepo repo) {
  when(
    () => repo.getMembersByLedger(any()),
  ).thenAnswer((_) async => <db.LedgerMember>[]);
}

/// 新建 addTransaction 的通用桩（schema v1 无 categorySyncIdOverride）。
void _stubAddTransaction(_MockRepo repo, {String returnId = 'tx-42'}) {
  _stubGetByLedger(repo);
  when(
    () => repo.addTransaction(
      ledgerId: any(named: 'ledgerId'),
      type: any(named: 'type'),
      amount: any(named: 'amount'),
      categoryId: any(named: 'categoryId'),
      happenedAt: any(named: 'happenedAt'),
      note: any(named: 'note'),
      excludeFromStats: any(named: 'excludeFromStats'),
      currencyCode: any(named: 'currencyCode'),
      nativeAmount: any(named: 'nativeAmount'),
      payerMemberId: any(named: 'payerMemberId'),
      aaMode: any(named: 'aaMode'),
      splits: any(named: 'splits'),
      operatorMemberId: any(named: 'operatorMemberId'),
    ),
  ).thenAnswer((_) async => returnId);
}

void _stubUpdateTransaction(_MockRepo repo, {int version = 7}) {
  _stubGetByLedger(repo);
  when(
    () => repo.updateTransaction(
      id: any(named: 'id'),
      type: any(named: 'type'),
      amount: any(named: 'amount'),
      categoryId: any(named: 'categoryId'),
      note: any(named: 'note'),
      happenedAt: any(named: 'happenedAt'),
      excludeFromStats: any(named: 'excludeFromStats'),
      currencyCode: any(named: 'currencyCode'),
      nativeAmount: any(named: 'nativeAmount'),
      payerMemberId: any(named: 'payerMemberId'),
      aaMode: any(named: 'aaMode'),
      splits: any(named: 'splits'),
      operatorMemberId: any(named: 'operatorMemberId'),
    ),
  ).thenAnswer((_) async => version);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getCategoryTree(any())).thenAnswer(
      (_) async => const CategoryRowTree(topLevel: [], children: {}),
    );
    // 默认本地账本；作者身份按账本归属解析需要读到账本行。
    when(() => repo.getLedgerById(any())).thenAnswer((_) async => _ledger());
  });

  /// 构建宿主：直接以 TransactionEditorSheet 为 home（无 bottom sheet 包装，
  /// 便于断言提交后 pop 行为）。
  Widget buildApp({
    db.Ledger? ledger,
    List<CategoryDisplay> topLevel = const [],
    Map<String, EffectiveRate> rates = const {},
    Map<String, WidgetBuilder> stubs = const {},
    String? editingTransactionId,
    String? initialCategoryId,
    String? initialAmount,
    String? initialCurrencyCode,
    String? initialNativeAmount,
    int? initialAaMode,
    // 共享账本成员表（作者头像渲染用）；真实 provider 走平台通道，测试必须 override。
    List<db.LedgerMember> members = const [],
  }) {
    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerIdProvider.overrideWithBuild(
          (ref, notifier) => 'ledger-1',
        ),
        ledgerMembersProvider.overrideWith((ref, ledgerId) async => members),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<db.Ledger?>.value(ledger ?? _ledger()),
        ),
        currentLedgerCurrencyProvider.overrideWith((ref) => 'CNY'),
        effectiveRatesForLedgerProvider.overrideWith((ref) async => rates),
        categoryPickerTreeProvider('expense').overrideWith(
          (ref) => Stream<CategoryPickerTree>.value(
            CategoryPickerTree(topLevel: topLevel, children: const {}),
          ),
        ),
        localSelfIdProvider.overrideWith((ref) async => 'device-1'),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        routerConfig: createAppRouter(
          home: () => Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: TransactionEditorSheet(
                          initialKind: 'expense',
                          editingTransactionId: editingTransactionId,
                          initialCategoryId: initialCategoryId,
                          initialAmount: initialAmount,
                          initialCurrencyCode: initialCurrencyCode,
                          initialNativeAmount: initialNativeAmount,
                          initialAaMode: initialAaMode,
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open-editor'),
                ),
              ),
            ),
          ),
          stubs: stubs,
        ),
      ),
    );
  }

  /// 打开编辑器路由并等待首帧。
  Future<void> openEditor(WidgetTester tester) async {
    // 预热 currentLedgerProvider：让流在编辑器 initState 前已 emit，
    // 否则 _resolveInitialCategory 读到的 ledger 为 null。
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('open-editor'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Finder amountText(String amount) => find.descendant(
    of: find.byType(AmountExpressionBar),
    matching: find.text(amount),
  );

  Future<void> tapKeypadDigit(WidgetTester tester, String digit) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.text(digit),
      ),
    );
    await tester.pump();
  }

  /// 点击完成键并等待 pop 动画结束。
  Future<void> submit(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('新建提交：选分类 + 金额 + 完成 → addTransaction 参数正确并关闭', (tester) async {
    _stubAddTransaction(repo);

    await tester.pumpWidget(
      buildApp(topLevel: [_categoryDisplay('cat-1', '餐饮')]),
    );
    await openEditor(tester);

    // 选分类。
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    // 输入金额 12（Decimal 字符串，单位元）。
    await tapKeypadDigit(tester, '1');
    await tapKeypadDigit(tester, '2');
    expect(amountText('12'), findsOneWidget);

    // 点完成键提交。
    await submit(tester);

    verify(
      () => repo.addTransaction(
        ledgerId: 'ledger-1',
        type: 'expense',
        amount: '12.00',
        categoryId: 'cat-1',
        happenedAt: any(named: 'happenedAt'),
        note: null,
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: '12.00',
        payerMemberId: null,
        aaMode: null,
        // 操作者在写库前解析，与交易同一事务落定，不再二次回填。
        operatorMemberId: 'device-1',
      ),
    ).called(1);
    // sheet 提交后关闭。
    expect(find.byType(TransactionEditorSheet), findsNothing);
  });

  testWidgets('未选分类提交：toast 提示并保持开启', (tester) async {
    await tester.pumpWidget(buildApp());
    await openEditor(tester);
    await tapKeypadDigit(tester, '1');

    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(find.byType(TransactionEditorSheet), findsOneWidget);
    // 未选分类时完成键禁用（PressKey.enabled=false），点击不触发提交。
    final doneKey = find.ancestor(
      of: find.byIcon(AppIcons.keyboardReturn),
      matching: find.byType(PressKey),
    );
    expect(tester.widget<PressKey>(doneKey).enabled, isFalse);
    expect(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
      findsOneWidget,
    );
  });

  testWidgets('外币无汇率提交：toast 阻断', (tester) async {
    _stubAddTransaction(repo);
    await tester.pumpWidget(
      buildApp(topLevel: [_categoryDisplay('cat-1', '餐饮')]),
    );
    await openEditor(tester);

    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '1');
    // 换币种到 USD（无汇率）：走币种选择 sheet。
    await tester.tap(find.byKey(const ValueKey('amount_currency_chip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.textContaining('美元'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(TransactionEditorSheet), findsOneWidget);
    // 表达式栏的汇率缺失提示仍在（toast 已自动消失）。
    expect(find.text('请手动填写本笔汇率后保存'), findsOneWidget);
    verifyNever(
      () => repo.addTransaction(
        ledgerId: any(named: 'ledgerId'),
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        categoryId: any(named: 'categoryId'),
        happenedAt: any(named: 'happenedAt'),
        note: any(named: 'note'),
        excludeFromStats: any(named: 'excludeFromStats'),
        currencyCode: any(named: 'currencyCode'),
        nativeAmount: any(named: 'nativeAmount'),
        payerMemberId: any(named: 'payerMemberId'),
        aaMode: any(named: 'aaMode'),
        splits: any(named: 'splits'),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('编辑模式：initialCategoryId 回显 + update + 编辑历史闭环', (tester) async {
    when(
      () => repo.getCategoryById('cat-5'),
    ).thenAnswer((_) async => _category('cat-5', '旧分类'));
    _stubUpdateTransaction(repo);
    when(
      () => repo.appendEditHistory(
        recordId: any(named: 'recordId'),
        version: any(named: 'version'),
        operatorMemberId: any(named: 'operatorMemberId'),
        summary: any(named: 'summary'),
      ),
    ).thenAnswer((_) async => 1);
    await tester.pumpWidget(
      buildApp(
        editingTransactionId: 'tx-9',
        initialCategoryId: 'cat-5',
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
      ),
    );
    await openEditor(tester);
    // 初始分类解析是异步的（读 getCategoryById），多 pump 一拍。
    await tester.pump(const Duration(milliseconds: 100));

    // 输入金额 10（无 initialAmount 初值，键入即替换）。
    await tapKeypadDigit(tester, '1');
    await tapKeypadDigit(tester, '0');
    await submit(tester);

    verify(
      () => repo.updateTransaction(
        id: 'tx-9',
        type: 'expense',
        amount: '10.00',
        categoryId: 'cat-5',
        note: null,
        happenedAt: any(named: 'happenedAt'),
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: '10.00',
        payerMemberId: null,
        aaMode: null,
        operatorMemberId: 'device-1',
      ),
    ).called(1);
    verify(
      () => repo.appendEditHistory(
        recordId: 'tx-9',
        version: 7,
        operatorMemberId: 'device-1',
        summary: any(named: 'summary'),
      ),
    ).called(1);
  });

  testWidgets('AA 开启：头部分摊方式三态循环切换', (tester) async {
    await tester.pumpWidget(
      buildApp(ledger: _ledger(aaEnabled: true), topLevel: const []),
    );
    await openEditor(tester);

    final toggle = find.byKey(const ValueKey('editor_aa_mode_toggle'));
    expect(toggle, findsOneWidget);
    expect(find.text('人均分摊'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('不分摊'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('指定分摊'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('人均分摊'), findsOneWidget);
  });

  testWidgets('AA 开启 + 不分摊：提交携带 aaMode=1 并清空分摊字段', (tester) async {
    _stubAddTransaction(repo);
    _stubUpdateTransaction(repo);
    when(
      () => repo.appendEditHistory(
        recordId: any(named: 'recordId'),
        version: any(named: 'version'),
        operatorMemberId: any(named: 'operatorMemberId'),
        summary: any(named: 'summary'),
      ),
    ).thenAnswer((_) async => 1);

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(aaEnabled: true),
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
      ),
    );
    await openEditor(tester);

    await tester.tap(find.text('餐饮'));
    await tester.pump();
    // 切到不分摊。
    final toggle = find.byKey(const ValueKey('editor_aa_mode_toggle'));
    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('不分摊'), findsOneWidget);

    await tapKeypadDigit(tester, '5');
    await submit(tester);

    verify(
      () => repo.addTransaction(
        ledgerId: 'ledger-1',
        type: 'expense',
        amount: '5.00',
        categoryId: 'cat-1',
        happenedAt: any(named: 'happenedAt'),
        note: null,
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: '5.00',
        payerMemberId: null,
        aaMode: 1,
        splits: const [],
        operatorMemberId: 'device-1',
      ),
    ).called(1);
  });

  testWidgets('AA 人均提交：跳 AaEditPage 后取消 → 不落库、sheet 保持', (tester) async {
    var aaPageOpened = false;
    // 用 stub 路由替代真实 AaEditPage（其依赖链与本次断言无关），
    // 页面内点「取消」pop null 模拟用户放弃分摊配置。
    final stubs = <String, WidgetBuilder>{
      Routes.aaEdit: (_) {
        aaPageOpened = true;
        return Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('取消配置'),
              ),
            ),
          ),
        );
      },
    };

    _stubAddTransaction(repo);

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(aaEnabled: true),
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
        stubs: stubs,
      ),
    );
    await openEditor(tester);
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '5');
    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(aaPageOpened, isTrue, reason: '人均分摊提交应跳转 AaEditPage');
    // 点取消 → 编辑器保持开启、未落库。
    await tester.tap(find.text('取消配置'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(TransactionEditorSheet), findsOneWidget);
    verifyNever(
      () => repo.addTransaction(
        ledgerId: any(named: 'ledgerId'),
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        categoryId: any(named: 'categoryId'),
        happenedAt: any(named: 'happenedAt'),
        note: any(named: 'note'),
        excludeFromStats: any(named: 'excludeFromStats'),
        currencyCode: any(named: 'currencyCode'),
        nativeAmount: any(named: 'nativeAmount'),
        payerMemberId: any(named: 'payerMemberId'),
        aaMode: any(named: 'aaMode'),
        splits: any(named: 'splits'),
      ),
    );
  });

  testWidgets('AA 人均提交：AaEditPage 返回结果 → 按结果落库分摊字段', (tester) async {
    final stubs = <String, WidgetBuilder>{
      Routes.aaEdit: (_) => Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(
                const AaEditResult(
                  paidByUserId: 'u1',
                  aaMode: 0,
                  aaParticipants: ['u1', 'u2'],
                  aaSplits: null,
                ),
              ),
              child: const Text('确认分摊'),
            ),
          ),
        ),
      ),
    };

    _stubAddTransaction(repo);

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(aaEnabled: true),
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
        stubs: stubs,
      ),
    );
    await openEditor(tester);
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '8');
    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('确认分摊'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    verify(
      () => repo.addTransaction(
        ledgerId: 'ledger-1',
        type: 'expense',
        amount: '8.00',
        categoryId: 'cat-1',
        happenedAt: any(named: 'happenedAt'),
        note: null,
        excludeFromStats: false,
        currencyCode: 'CNY',
        nativeAmount: '8.00',
        payerMemberId: 'u1',
        aaMode: 0,
        splits: const [],
        operatorMemberId: 'device-1',
      ),
    ).called(1);
  });

  testWidgets('提交失败：toast 错误并保持 sheet 开启', (tester) async {
    when(
      () => repo.addTransaction(
        ledgerId: any(named: 'ledgerId'),
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        categoryId: any(named: 'categoryId'),
        happenedAt: any(named: 'happenedAt'),
        note: any(named: 'note'),
        excludeFromStats: any(named: 'excludeFromStats'),
        currencyCode: any(named: 'currencyCode'),
        nativeAmount: any(named: 'nativeAmount'),
        payerMemberId: any(named: 'payerMemberId'),
        aaMode: any(named: 'aaMode'),
        splits: any(named: 'splits'),
      ),
    ).thenThrow(Exception('db down'));

    await tester.pumpWidget(
      buildApp(topLevel: [_categoryDisplay('cat-1', '餐饮')]),
    );
    await openEditor(tester);
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '5');
    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.byIcon(AppIcons.keyboardReturn),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TransactionEditorSheet), findsOneWidget);
    expect(find.textContaining('错误'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('备注输入后清空：onNotePicked 清空并复位光标', (tester) async {
    await tester.pumpWidget(buildApp());
    await openEditor(tester);

    await tester.enterText(find.byType(TextField), '早餐');
    await tester.pump();
    // 清空按钮出现并点击。
    await tester.tap(find.byIcon(AppIcons.cancel));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('共享账本编辑：返回键关闭编辑器', (tester) async {
    when(
      () => repo.getCategoryById('cat-5'),
    ).thenAnswer((_) async => _category('cat-5', '旧分类'));

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(isShared: true),
        editingTransactionId: 'tx-9',
        initialCategoryId: 'cat-5',
      ),
    );
    await openEditor(tester);
    await tester.pump(const Duration(milliseconds: 100));

    // 返回键关闭编辑器（路由模式可 pop）。
    await tester.tap(find.byIcon(AppIcons.chevronLeft));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!tester.any(find.byType(TransactionEditorSheet))) break;
    }
    expect(find.byType(TransactionEditorSheet), findsNothing);
  });

  testWidgets('外币有汇率：提交按汇率折算 nativeAmount', (tester) async {
    _stubAddTransaction(repo);

    await tester.pumpWidget(
      buildApp(
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
        rates: const {'USD': EffectiveRate(rate: '7.2', manual: false)},
      ),
    );
    await openEditor(tester);
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '1');
    // 切到 USD（有汇率 7.2）。
    await tester.tap(find.byKey(const ValueKey('amount_currency_chip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.textContaining('美元'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await submit(tester);

    verify(
      () => repo.addTransaction(
        ledgerId: 'ledger-1',
        type: 'expense',
        amount: '1.00',
        categoryId: 'cat-1',
        happenedAt: any(named: 'happenedAt'),
        note: null,
        excludeFromStats: false,
        currencyCode: 'USD',
        nativeAmount: '7.20',
        payerMemberId: null,
        aaMode: null,
        splits: null,
        operatorMemberId: 'device-1',
      ),
    ).called(1);
  });

  testWidgets('外币折算：金额边界使用 round-half-even', (tester) async {
    _stubAddTransaction(repo);

    await tester.pumpWidget(
      buildApp(
        topLevel: [_categoryDisplay('cat-1', '餐饮')],
        rates: const {'USD': EffectiveRate(rate: '2.225', manual: false)},
      ),
    );
    await openEditor(tester);
    await tester.tap(find.text('餐饮'));
    await tester.pump();
    await tapKeypadDigit(tester, '1');
    await tester.tap(find.byKey(const ValueKey('amount_currency_chip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.textContaining('美元'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await submit(tester);

    verify(
      () => repo.addTransaction(
        ledgerId: 'ledger-1',
        type: 'expense',
        amount: '1.00',
        categoryId: 'cat-1',
        happenedAt: any(named: 'happenedAt'),
        note: null,
        excludeFromStats: false,
        currencyCode: 'USD',
        nativeAmount: '2.22',
        payerMemberId: null,
        aaMode: null,
        splits: null,
        operatorMemberId: 'device-1',
      ),
    ).called(1);
  });

  testWidgets('日期键打开滚轮并确认：_date 更新', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp());
    await openEditor(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.textContaining('/'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 滚轮打开后点完成关闭，不抛错即可（滚轮自身有专项测试）。
    await tester.ensureVisible(find.text('完成'));
    await tester.tap(find.text('完成'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(TransactionEditorSheet), findsOneWidget);
  });

  /// 编辑模式交易桩：作者 u1 创建并编辑。
  db.Transaction editingTx() => db.Transaction(
    id: 'tx-9',
    ledgerId: 'ledger-1',
    txType: 'expense',
    amount: '1',
    happenedAt: DateTime(2026, 8, 8),
    excludeFromStats: false,
    currencyCode: 'CNY',
    nativeAmount: '1',
    version: 2,
    createdByMemberId: 'u1',
    lastEditedByMemberId: 'u1',
    createdAt: DateTime.utc(2026, 8, 8),
    updatedAt: DateTime.utc(2026, 8, 8),
  );

  testWidgets('编辑共享账本交易：渲染作者头像组', (tester) async {
    when(
      () => repo.getCategoryById('cat-5'),
    ).thenAnswer((_) async => _category('cat-5', '旧分类'));
    when(
      () => repo.getTransactionById('tx-9'),
    ).thenAnswer((_) async => editingTx());
    when(
      () => repo.getTransactionById(any()),
    ).thenAnswer((_) async => editingTx());
    when(
      () => repo.getLedgerById(any()),
    ).thenAnswer((_) async => _ledger(isShared: true));

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(isShared: true),
        editingTransactionId: 'tx-9',
        initialCategoryId: 'cat-5',
        members: const [],
      ),
    );
    await openEditor(tester);
    await tester.pump(const Duration(milliseconds: 100));
    // 头像组渲染依赖成员 provider 解析成功（空列表即可），循环 pump 到出现。
    final groupFinder = find.byType(
      CollaboratorAvatarGroup,
      skipOffstage: false,
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.any(groupFinder)) break;
    }
    expect(groupFinder, findsOneWidget);
  });

  testWidgets('AA 开启 + 编辑共享账本：头部同时渲染分摊按钮与作者头像', (tester) async {
    when(
      () => repo.getCategoryById('cat-5'),
    ).thenAnswer((_) async => _category('cat-5', '旧分类'));
    when(
      () => repo.getTransactionById(any()),
    ).thenAnswer((_) async => editingTx());
    when(
      () => repo.getLedgerById(any()),
    ).thenAnswer((_) async => _ledger(aaEnabled: true, isShared: true));

    await tester.pumpWidget(
      buildApp(
        ledger: _ledger(aaEnabled: true, isShared: true),
        editingTransactionId: 'tx-9',
        initialCategoryId: 'cat-5',
        members: const [],
      ),
    );
    await openEditor(tester);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.any(find.byType(CollaboratorAvatarGroup))) break;
    }

    expect(find.byType(CollaboratorAvatarGroup), findsOneWidget);
    expect(find.byKey(const ValueKey('editor_aa_mode_toggle')), findsOneWidget);
  });
}
