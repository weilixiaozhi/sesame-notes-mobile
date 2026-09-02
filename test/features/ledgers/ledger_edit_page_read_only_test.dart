import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

/// [LedgerEditPage] 协作者只读的 widget 测试。
///
/// 设计意图：「共享账本 + 非拥有者」进入只读模式——
///   ① 名称标题显示为「账本名称」并保持高亮加粗，下方仅展示账本名称文本（不渲染输入框）；
///   ② 币种 / 月起始日两个 ListTile 置灰且不可点击（enabled=false 灰化文字与图标），且不显示右箭头；
///   ③ 底部保存按钮不渲染，从源头杜绝推送账本元信息变更。
/// 本测试同时验证 Owner 与本地账本不受该只读逻辑影响（仍可编辑、显示保存按钮）。
///
/// 新 schema 说明：账本 id 为 UUID 字符串；共享性由 memberCount>1 表达，
/// 角色由 role 列表达（owner/editor），LedgersCompanion 必填 id/updatedAt。
void main() {
  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
    TestWidgetsFlutterBinding.ensureInitialized();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() => db.close());

  Future<LedgerDisplayItem> seed(bool isShared, String myRole) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: 'L',
            currency: const Value('CNY'),
            role: Value(myRole),
            memberCount: Value(isShared ? 2 : 1),
            // 共享账本归属云端、本地账本归属本地，与列表分区语义一致。
            storageMode: Value(isShared ? 'cloud' : 'local'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    return LedgerDisplayItem.fromLocal(
      id: 'ledger-1',
      name: 'L',
      currency: 'CNY',
      createdAt: DateTime.now(),
      transactionCount: 0,
      expenseTotal: 0,
      isShared: isShared,
      memberCount: isShared ? 2 : 1,
      myRole: myRole,
    );
  }

  Future<AppLocalizations> pump(
    WidgetTester tester,
    LedgerDisplayItem ledger,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProviderScope(
          overrides: [
            // 共享账本成员统计会经 ledgerMembersProvider 查 databaseProvider，
            // 注入同一内存库避免测试环境触发真实文件库打开而挂起。
            databaseProvider.overrideWithValue(db),
            repositoryProvider.overrideWith((ref) => repo),
            currentLedgerProvider.overrideWith(
              (ref) => Stream<Ledger?>.value(null),
            ),
          ],
          child: LedgerEditPage(ledger: ledger),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // 编辑页读取 localSelfIdProvider 时首次生成会写日志并调度 2s 节流保存
    // Timer，测试结束前推进虚拟时钟让 Timer 到期，避免 !timersPending 报错。
    await tester.pump(const Duration(seconds: 3));
    return l10n;
  }

  testWidgets('协作者只读:名称仅展示文本 + 币种/起始日置灰无箭头 + 隐藏保存按钮', (tester) async {
    final ledger = await seed(true, 'editor');
    final l10n = await pump(tester, ledger);

    // ① 名称标题为「账本名称」并高亮（titleMedium 默认高亮加粗）
    expect(find.text(l10n.ledgerNameLabel), findsOneWidget);
    // ① 协作者只读：不渲染输入框，仅以纯文本展示账本名称
    // 注意：AppBar 标题同样展示账本名，故限定在 Card 内的 Text 来断言正文文本
    expect(
      find.ancestor(of: find.text('L'), matching: find.byType(Card)),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    // ③ 保存按钮不渲染
    expect(find.text(l10n.commonSave), findsNothing);
    // ② 币种 ListTile 置灰且不可点击、无右箭头
    // 注意:「主币种」标签(l10n.ledgerBaseCurrencyLabel)已上移为区块标题(在 Card 外),
    // 不位于 ListTile 内部;ListTile 内实际渲染的是币种值(由 currencyFlagLabel 输出
    // 形如「CNY (¥)」),故用包含币种代码的文本定位 ListTile。
    final currencyTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.textContaining('CNY'),
        matching: find.byType(ListTile),
      ),
    );
    expect(currencyTile.enabled, isFalse);
    expect(currencyTile.trailing, equals(null));
    // ② 月起始日 ListTile 置灰、无右箭头
    // 注意:「每月起始日」标签已上移为区块标题,ListTile 内实际渲染的是具体值
    // (种子账本默认起始日=1 → 自然月)。用该值文本定位 ListTile。
    final startDayTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(l10n.ledgersMonthStartDayNatural),
        matching: find.byType(ListTile),
      ),
    );
    expect(startDayTile.enabled, isFalse);
    expect(startDayTile.trailing, equals(null));
  });

  testWidgets('Owner 共享账本:字段可编辑 + 显示保存按钮', (tester) async {
    final ledger = await seed(true, 'owner');
    final l10n = await pump(tester, ledger);

    expect(find.text(l10n.commonSave), findsOneWidget);

    // 名称标题为「账本名称」，且渲染可编辑输入框
    expect(find.text(l10n.ledgerNameLabel), findsOneWidget);
    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    expect(nameField.enabled, isTrue);

    // 主币种标签已上移为区块标题,币种值文本(形如「人民币（CNY）」)位于 ListTile 内,据此定位。
    final currencyTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.textContaining('CNY'),
        matching: find.byType(ListTile),
      ),
    );
    expect(currencyTile.enabled, isTrue);
    // 可编辑时显示右箭头
    expect(currencyTile.trailing != null, isTrue);
  });

  testWidgets('本地账本:显示保存按钮 + 可编辑名称', (tester) async {
    final ledger = await seed(false, '');
    final l10n = await pump(tester, ledger);
    expect(find.text(l10n.commonSave), findsOneWidget);
    expect(find.text(l10n.ledgerNameLabel), findsOneWidget);
    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    expect(nameField.enabled, isTrue);
  });
}
