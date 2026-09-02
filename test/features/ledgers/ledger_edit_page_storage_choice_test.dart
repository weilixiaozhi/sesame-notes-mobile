/// LedgerEditPage 新建账本归属选择（P0-4）行为测试。
///
/// 需求锚点：
/// - 新建账本必须让用户明确选择「本地账本 / 云端账本」（SegmentedButton），
///   而不是靠登录态隐式决定——避免私密账本不知情上云；
/// - 已登录 Sesame Notes Cloud 时默认「云端账本」，未登录时云端选项禁用并
///   给出登录引导，未登录无论 UI 状态如何都只能建本地账本（二次夹紧）；
/// - 云端账本 = createLedger(storage_mode='cloud') 并登记 ledger upsert 变更
///   （新 schema：push 即建立服务端记录）；本地账本不登记变更。
library;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late ProviderContainer container;

  void buildContainer({bool loggedIn = false}) {
    container = ProviderContainer(
      overrides: [
        // 带变更登记的真实仓储：云端建本必须登记 ledger upsert（push 由同步层消费）。
        repositoryProvider.overrideWithValue(
          LocalRepository(db, changeTracker: ChangeRecorderImpl(db)),
        ),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    if (loggedIn) {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(accessToken: 't', userId: 'u', deviceId: 'd'),
          );
    }
  }

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    buildContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<AppLocalizations> pump(WidgetTester tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.binding.setSurfaceSize(const Size(800, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LedgerEditPage(),
        ),
      ),
    );
    await tester.runAsync(() => tester.pumpAndSettle());
    return l10n;
  }

  /// 输入账本名并保存（新建模式的保存按钮文案为 ledgersCreate）。
  /// 保存后消化 toast 的 1 秒自动关闭 timer，避免 !timersPending 断言。
  Future<void> saveLedger(
    WidgetTester tester,
    AppLocalizations l10n,
    String name,
  ) async {
    await tester.enterText(find.byType(TextFormField).first, name);
    await tester.tap(find.text(l10n.ledgersCreate));
    await tester.runAsync(() => tester.pumpAndSettle());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('未登录新建：选择器可见、云端禁用、默认本地、保存落库 local 且不登记变更', (tester) async {
    final l10n = await pump(tester);

    // 存储位置选择器出现，两段都在。
    expect(find.text(l10n.ledgersStorageLocation), findsOneWidget);
    expect(find.text(l10n.ledgersSectionLocal), findsWidgets);
    expect(find.text(l10n.ledgersSectionCloud), findsOneWidget);
    // 云端段禁用 + 登录引导提示。
    final cloudSegment = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    final cloudBtn = cloudSegment.segments.firstWhere(
      (s) => s.value == 'cloud',
    );
    expect(cloudBtn.enabled, isFalse, reason: '未登录时云端选项必须禁用，不留误点机会');
    expect(find.text(l10n.ledgersSectionCloudSignInHint), findsOneWidget);

    await saveLedger(tester, l10n, '本地本');

    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.single.storageMode, 'local', reason: '未登录只能建本地账本');
    expect(
      await db.select(db.syncChanges).get(),
      isEmpty,
      reason: '本地账本不进同步通道',
    );
  });

  testWidgets('已登录新建：默认云端、保存落库 cloud 且登记 ledger upsert 变更', (tester) async {
    buildContainer(loggedIn: true);
    final l10n = await pump(tester);

    final segment = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    expect(segment.selected, {'cloud'}, reason: '已登录时新账本默认归属云端');
    expect(find.text(l10n.ledgersStorageCloudHint), findsOneWidget);

    await saveLedger(tester, l10n, '云端本');

    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.single.storageMode, 'cloud', reason: '已登录时按默认云端归属落库');
    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(1), reason: '云端建本必须登记变更供 push 建立服务端记录');
    expect(changes.single.entityType, 'ledger');
    expect(changes.single.action, 'upsert');
    expect(changes.single.ledgerId, ledgers.single.id);
  });

  testWidgets('已登录新建：显式切到本地后保存落库 local 且不登记变更', (tester) async {
    buildContainer(loggedIn: true);
    final l10n = await pump(tester);

    await tester.tap(find.text(l10n.ledgersSectionLocal).last);
    await tester.pump();
    await saveLedger(tester, l10n, '本地本');

    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers.single.storageMode, 'local', reason: '用户显式选择本地必须尊重');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  testWidgets('编辑模式不显示存储位置选择器（归属只在创建时决定）', (tester) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-1',
            name: '已有账本',
            currency: const Value('CNY'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LedgerEditPage(
            ledger: LedgerDisplayItem.fromLocal(
              id: 'ledger-1',
              name: '已有账本',
              currency: 'CNY',
              createdAt: DateTime(2026, 1, 1),
              transactionCount: 0,
              expenseTotal: 0,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() => tester.pumpAndSettle());

    expect(
      find.byType(SegmentedButton<String>),
      findsNothing,
      reason: '编辑已有账本时归属不由选择器决定，只保留迁云操作模块',
    );
  });
}
