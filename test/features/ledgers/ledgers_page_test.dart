/// LedgersPage 双分区列表 + 下拉刷新测试。
///
/// 覆盖场景：
///   1. 两个分区标题常驻，账本按 storage_mode 落到对应分区；
///   2. 某一侧为空时标题仍在，只显示分区内的空提示；
///   3. 下拉刷新（RefreshIndicator 的 onRefresh）会自增 `ledgerListRefreshProvider`；
///   4. 全空时也包在可滚动容器里，下拉刷新仍可触发；
///   5. 「添加账本」入口的图标/位置/跳转一致性（与分类管理页对齐）。
///
/// 测试栈：flutter_test + flutter_riverpod。新 schema 下页面列表由私有
/// _ledgersProvider 经 repositoryProvider 查询内存库，测试注入真实内存库
/// （databaseProvider → SesameDatabase.forTesting）并预先 seed 账本，既保证
/// 数据确定，又让 dataChangeSignalProvider 监听同一实例；已删除的
/// localLedgersProvider / activeCloudConfigProvider 不 override。
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledgers_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

/// 向内存库写入一本账本（新 schema：UUID 字符串 id + updatedAt 必填）。
///
/// [storageMode] 决定它落在哪个分区：'local' → 本地账本，'cloud' → 云端账本。
Future<void> _seedLedger(
  SesameDatabase db, {
  required String id,
  required String name,
  String storageMode = 'local',
}) async {
  await db
      .into(db.ledgers)
      .insert(
        LedgersCompanion.insert(
          id: id,
          name: name,
          currency: const Value('CNY'),
          storageMode: Value(storageMode),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
}

/// 构造带 override 的 ProviderContainer。
///
/// 页面列表 provider 经 repositoryProvider → databaseProvider 查询，
/// 注入真实内存库即获得确定数据（各用例预先 seed），同时避免
/// dataChangeSignalProvider 走默认 databaseProvider 创建真实文件库。
ProviderContainer _makeContainer(
  SesameDatabase db, {
  List<Override> extraOverrides = const [],
}) {
  return ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db), ...extraOverrides],
  );
}

/// 挂载 LedgersPage。
///
/// 使用 [UncontrolledProviderScope] 以便测试在 pump 后读取容器内的 provider 状态
/// （用于断言下拉刷新是否自增了刷新信号）。builder 不依赖 pumpAndSettle：页面内
/// 存在依赖异步 provider 的渲染，使用有界 pump 即可，断言不依赖 spinner 是否消失。
///
/// [platform] 默认 iOS：使 ListView 使用弹性滚动（BouncingScrollPhysics），
/// 从而顶部下拉能产生 overscroll 以触发 RefreshIndicator（Android 的夹紧滚动不会）。
Future<void> _pumpLedgersPage(
  WidgetTester tester,
  ProviderContainer container, {
  TargetPlatform platform = TargetPlatform.iOS,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        // 测试环境默认 locale 为 en，强制 zh 以渲染中文文案。
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // 通过 ThemeData.platform 设定滚动物理，避免触碰全局 debug 变量。
        theme: ThemeData(platform: platform),
        routerConfig: createAppRouter(home: () => const LedgersPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('下拉刷新调用统一的全局账本刷新入口', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-local-refresh', name: '家庭账本');
    final sync = _MockSyncCoordinator();
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult());
    final container = _makeContainer(
      db,
      extraOverrides: [syncCoordinatorProvider.overrideWithValue(sync)],
    );
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await indicator.onRefresh();

    verify(() => sync.refreshData()).called(1);
  });

  testWidgets('双分区：两个标题常驻，账本按 storage_mode 落到对应分区', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-local', name: '旅行账本');
    await _seedLedger(
      db,
      id: 'ledger-cloud',
      name: '工资卡',
      storageMode: 'cloud',
    );
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 两个分区标题常驻。
    expect(find.text('本地账本'), findsOneWidget);
    expect(find.text('云端账本'), findsOneWidget);

    // 两本账本都渲染出来。
    // 注：账本名经 RichText/TextSpan 渲染，且可能与其它 span 拼接，
    // 用 textContaining + findRichText 做子串匹配更稳健。
    expect(find.textContaining('旅行账本', findRichText: true), findsWidgets);
    expect(find.textContaining('工资卡', findRichText: true), findsWidgets);

    // 归属正确性：本地账本在「本地账本」标题之下、
    // 「云端账本」标题之上；云端账本则在云端标题之下。
    final localTitleY = tester.getCenter(find.text('本地账本')).dy;
    final cloudTitleY = tester.getCenter(find.text('云端账本')).dy;
    final localCardY = tester
        .getCenter(find.textContaining('旅行账本', findRichText: true).first)
        .dy;
    final cloudCardY = tester
        .getCenter(find.textContaining('工资卡', findRichText: true).first)
        .dy;

    expect(localCardY, greaterThan(localTitleY));
    expect(localCardY, lessThan(cloudTitleY), reason: '本地账本必须排在云端分区标题之前');
    expect(cloudCardY, greaterThan(cloudTitleY), reason: '云端账本必须排在云端分区标题之后');
  });

  testWidgets('一侧为空时分区标题仍在，只显示分区内空提示', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-local', name: '旅行账本');
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    expect(find.text('本地账本'), findsOneWidget);
    expect(find.text('云端账本'), findsOneWidget);
    // 未登录时云端分区空提示给「去登录」引导，而非「暂无」。
    expect(find.text('登录云端后即可使用云端账本'), findsOneWidget);
    expect(find.text('暂无云端账本，云端账本会在各设备间同步'), findsNothing);
  });

  testWidgets('下拉刷新触发 ledgerListRefreshProvider 自增', (tester) async {
    // 给一条本地账本，使列表可滚动（RefreshIndicator 需要可滚动子组件才能触发下拉）。
    // 平台已在 _pumpLedgersPage 中设为 iOS（弹性滚动），保证顶部下拉能触发刷新。
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-2', name: '家庭账本');
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 刷新前记录信号初值。
    final before = container.read(ledgerListRefreshProvider);

    // 在列表顶部向下 fling，触发 RefreshIndicator 的下拉刷新。
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    // 给 onRefresh（及 _handleRefresh 内的 await）留出执行时间。
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    // 刷新信号应自增 1，证明下拉刷新确实触发了账本列表的刷新逻辑。
    final after = container.read(ledgerListRefreshProvider);
    expect(after, before + 1);
  });

  testWidgets('全空时仍可下拉刷新（分区列表本身就是可滚动容器）', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 一本账都没有时，本地分区给出空提示 + 新建引导。
    expect(find.text('暂无本地账本，本地账本只保存在这台设备上'), findsOneWidget);

    final before = container.read(ledgerListRefreshProvider);

    // 空态本身是 ListView，可直接在其上 fling 触发下拉刷新。
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    // 刷新信号自增，证明空态下拉同样可以触发刷新重试。
    expect(container.read(ledgerListRefreshProvider), before + 1);
  });

  // ==================== 「添加账本」入口：图标/位置一致性（与分类管理页对齐） ====================

  /// 断言「添加账本」头部按钮：图标为圆圈加号 [AppIcons.addCircle]（与分类页
  /// 「添加分类」同源），且 tooltip 为「创建」，整站"新增"心智模型一致；
  /// 同时确认旧的普通加号 [AppIcons.add] 已被替换（头部不应再残留该 IconButton）。
  testWidgets('头部「添加账本」使用圆圈加号图标(AppIcons.addCircle)且 tooltip 为「创建」', (
    tester,
  ) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 头部应存在唯一的 addCircle 图标按钮（对应「添加账本」）。
    final addBtn = find.widgetWithIcon(IconButton, AppIcons.addCircle);
    expect(addBtn, findsOneWidget, reason: '头部「添加账本」应为圆圈加号图标按钮');
    expect(
      (tester.widget<IconButton>(addBtn)).tooltip,
      '创建',
      reason: '「添加账本」按钮 tooltip 应为「创建」',
    );

    // 普通加号(AppIcons.add)不应出现在头部——已统一为 addCircle。
    expect(
      find.widgetWithIcon(IconButton, AppIcons.add),
      findsNothing,
      reason: '头部不应残留普通加号(AppIcons.add)',
    );
  });

  // ==================== 「加入共享账本」入口：位置/门控 ====================

  /// 登录测试账号，模拟云端会话存在。
  void signIn(ProviderContainer container) {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
        );
  }

  testWidgets('已登录：云端分区标题下显示全宽「加入共享账本」按钮，头部无 link 图标', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-local', name: '旅行账本');
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    signIn(container);
    await _pumpLedgersPage(tester, container);

    // 全宽按钮：personAdd 图标 + 「加入共享账本」文案。
    expect(find.byIcon(AppIcons.personAdd), findsOneWidget);
    expect(find.text('加入共享账本'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('加入共享账本'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed != null, isTrue, reason: '已登录时入口必须可点');

    // 云端分区为空时给「暂无云端账本」而非登录引导。
    expect(find.text('暂无云端账本，云端账本会在各设备间同步'), findsOneWidget);

    // 头部无 link 图标入口（该入口在云端分区全宽按钮）。
    expect(find.widgetWithIcon(IconButton, AppIcons.link), findsNothing);
  });

  testWidgets('未登录：无「加入共享账本」按钮，云端分区空态给登录引导', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-local', name: '旅行账本');
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    expect(find.byIcon(AppIcons.personAdd), findsNothing);
    expect(find.text('加入共享账本'), findsNothing);
    expect(find.text('登录云端后即可使用云端账本'), findsOneWidget);
  });

  testWidgets('头部「添加账本」位于右上角 actions（标题右侧、贴近屏幕右缘）', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    final addBtn = find.widgetWithIcon(IconButton, AppIcons.addCircle);
    final title = find.text('账本管理');

    expect(addBtn, findsOneWidget);
    expect(title, findsOneWidget, reason: '应渲染头部标题「账本管理」');

    final screenW = tester.getSize(find.byType(MaterialApp)).width;
    final addDx = tester.getCenter(addBtn).dx;
    final titleDx = tester.getCenter(title).dx;

    // 入口必须在标题右侧（创建入口不抢占标题位置）。
    expect(addDx, greaterThan(titleDx), reason: '「添加账本」应位于标题右侧');
    // 关键区分：位于右上角 actions（贴近右缘），而非紧贴标题的 titleAction。
    // 用 0.6 屏宽作为分界——titleAction 会落在左侧区域，actions 则靠右。
    expect(
      addDx,
      greaterThan(screenW * 0.6),
      reason: '「添加账本」应位于右上角 actions（贴近屏幕右缘）',
    );
  });

  testWidgets('本地分区空提示「新建账本」按钮使用圆圈加号图标(AppIcons.addCircle)', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(db);
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 本地分区空提示出现。
    expect(find.text('暂无本地账本，本地账本只保存在这台设备上'), findsOneWidget);

    // 空提示里的「新建账本」OutlinedButton 图标应为 addCircle（与分类页空态一致），
    // 避免出现两种加号样式。
    final newBtn = find.ancestor(
      of: find.byIcon(AppIcons.addCircle),
      matching: find.bySubtype<OutlinedButton>(),
    );
    expect(newBtn, findsOneWidget, reason: '空态「新建账本」按钮图标应为圆圈加号');
  });

  testWidgets('点击「添加账本」跳转至 LedgerEditPage（新建账本）', (tester) async {
    // 新建账本页(LedgerEditPage)创建模式会在 initState 读 SharedPreferences，
    // 测试环境需预置 mock，否则可能抛 MissingPluginException。
    SharedPreferences.setMockInitialValues({});

    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(
      db,
      // 覆写 currentLedgerProvider：避免其底层依赖 repositoryProvider 在初始化时
      // 触发 LoggerService 的 2s 异步保存定时器，导致测试结束时仍有 pending timer
      // 而断言失败；这里直接给一个确定（空）的当前账本即可。
      extraOverrides: [
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    final addBtn = find.widgetWithIcon(IconButton, AppIcons.addCircle);
    expect(addBtn, findsOneWidget);

    // 点击触发 Navigator.push(LedgerEditPage)。
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // 跳转后树中应存在 LedgerEditPage（新建模式）。
    expect(
      find.byType(LedgerEditPage),
      findsOneWidget,
      reason: '点击「添加账本」应跳转到新建账本页',
    );

    // 新建账本页会触发 localSelfId 生成与 LoggerService 2s 节流保存
    // Timer，测试结束前推进虚拟时钟让 Timer 到期，避免 !timersPending 报错。
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('空状态进入页面不自动打开「新建账本」（autoOpenCreateDialog 已移除）', (tester) async {
    // 回归背景：空状态若自动打开「新建账本」，云端下线/换账号等瞬时空窗口
    // 会把用户误导进「新建账本」。现统一为只进管理页，由用户主动新建——
    // 挂载后不得出现新建账本页面。
    SharedPreferences.setMockInitialValues({});
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final container = _makeContainer(
      db,
      extraOverrides: [
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);
    // 等 postFrame 回调（若残留自动弹出逻辑会在首帧后触发）。
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byType(LedgerEditPage),
      findsNothing,
      reason: '空状态进入管理页不得自动打开新建账本流程',
    );
    expect(find.byType(Dialog), findsNothing, reason: '空状态进入管理页不得自动弹出任何对话框');
    // 空态引导仍在，用户可自行主动新建。
    expect(find.text('暂无本地账本，本地账本只保存在这台设备上'), findsOneWidget);
  });

  testWidgets('点击账本卡片编辑入口直接打开 LedgerEditPage（归属移动不再弹底部菜单）', (tester) async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();

    // 用真实的内存库 + repository,并把要编辑的账本写进库,
    // 这样编辑页 initState 的 _loadLedgerData 能立即完成,不会一直转圈。
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    await _seedLedger(db, id: 'ledger-1', name: '旅行账本');

    final container = _makeContainer(
      db,
      extraOverrides: [
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _pumpLedgersPage(tester, container);

    // 卡片编辑按钮使用 AppIcons.edit（tooltip 为「编辑」）。
    final editBtn = find.widgetWithIcon(IconButton, AppIcons.edit);
    expect(editBtn, findsOneWidget, reason: '每张账本卡片应有一个编辑入口');

    // 点击应直接进入编辑页，而非弹出归属移动底部菜单。
    await tester.tap(editBtn);
    // 编辑页为编辑模式,initState 会异步加载账本;多 pump 一次确保加载完成再 settle。
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.byType(LedgerEditPage),
      findsOneWidget,
      reason: '点击编辑入口应直接打开账本编辑页',
    );

    // 编辑页读取 localSelfIdProvider 时首次生成会写日志并调度 2s 节流保存
    // Timer，测试结束前推进虚拟时钟让 Timer 到期，避免 !timersPending 报错。
    await tester.pump(const Duration(seconds: 3));
  });
}
