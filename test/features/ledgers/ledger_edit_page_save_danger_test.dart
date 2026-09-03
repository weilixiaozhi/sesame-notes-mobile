/// LedgerEditPage 保存流与危险区操作测试。

/// 需求锚点：
/// - 新建保存：名称必填校验、AA 开关随 createLedger 落库、虚拟用户批量落库、
///   成功后 toast + pop；编辑保存：改名/AA 变更走 updateLedger，无变更直接关闭；
/// - 加载失败：账本行缺失 → 错误态 + 重试恢复；
/// - 危险区（右上角「更多」菜单，本地账本可见「清空」+「删除账本」）：
///   - 清空账本：确认 → clearLedgerTransactions → toast；
///   - 删除个人账本：确认 → repo.deleteLedger 本地删行 → 清 prefs → 成功 pop；
///   - 删除失败：错误弹窗且页面保留。
///
/// 新 schema 说明：账本 id 为 UUID 字符串，LedgersCompanion 必填 id/updatedAt；
/// 个人账本删除走本地 repo.deleteLedger；共享账本 Owner 删除走
/// LedgerActions.deleteSharedAsOwner（云端 REST 删除 + purge），协作者退出走
/// LedgerActions.leaveSharedLedger（云端 /leave + purge）；本地账本迁云入口见
/// ledger_edit_page_move_to_cloud_test.dart。
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/services/exchange_rate_service.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/shared/widgets/text_state_switch.dart';

import '../../helpers/test_isolation.dart';

/// 可注入「deleteLedger 抛错」的仓库，用于覆盖删除失败弹窗分支。
class _FailDeleteRepo extends LocalRepository {
  _FailDeleteRepo(super.db);

  @override
  Future<void> deleteLedger(String id) async {
    throw Exception('delete boom');
  }
}

/// 账本编排 mock：危险区流程只验证编排调用与导航，REST 细节由仓储/服务层测试覆盖。
class _MockLedgerActions extends Mock implements LedgerActions {}

/// 假汇率服务：立即失败且不留 pending timer，避免切币种/拉汇率路径触网。
class _FailingRateService implements ExchangeRateService {
  @override
  Future<RateFetchResult> fetch(String base) async {
    throw RateFetchException('fake fail');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() => db.close());

  /// 播种账本，返回展示项。
  Future<LedgerDisplayItem> seed({
    String id = 'ledger-1',
    String name = '测试账本',
    bool isShared = false,
    String myRole = 'owner',
    String storageMode = 'local',
    bool aaEnabled = false,
    int monthStartDay = 1,
  }) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            currency: const Value('CNY'),
            role: Value(myRole),
            memberCount: Value(isShared ? 2 : 1),
            storageMode: Value(storageMode),
            aaEnabled: Value(aaEnabled),
            monthStartDay: Value(monthStartDay),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    return LedgerDisplayItem.fromLocal(
      id: id,
      name: name,
      currency: 'CNY',
      createdAt: DateTime.now(),
      transactionCount: 0,
      expenseTotal: 0,
      isShared: isShared,
      memberCount: isShared ? 2 : 1,
      myRole: myRole,
      storageMode: storageMode,
    );
  }

  /// 挂载编辑页。
  ///
  /// [useRepo] 可替换仓库（如删除失败注入抛错仓库）；
  /// [ledger] 为 null 表示新建模式；[currentLedgerId] 覆盖当前账本 id。
  Future<AppLocalizations> pump(
    WidgetTester tester, {
    LedgerDisplayItem? ledger,
    LocalRepository? useRepo,
    // 当前账本 id：新 schema 下为 UUID 字符串。
    String? currentLedgerId,
    LedgerActions? actions,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProviderScope(
          overrides: [
            // 注入同一内存库：页面列表/成员统计等 provider 均查 databaseProvider，
            // 避免测试环境触发真实文件库打开而挂起。
            databaseProvider.overrideWithValue(db),
            repositoryProvider.overrideWith((ref) => useRepo ?? repo),
            if (actions != null)
              ledgerActionsProvider.overrideWith((ref) => actions),
            currentLedgerProvider.overrideWith(
              (ref) => Stream<Ledger?>.value(null),
            ),
            if (currentLedgerId != null)
              currentLedgerIdProvider.overrideWithBuild(
                (ref, notifier) => currentLedgerId,
              ),
            exchangeRateServiceProvider.overrideWithValue(
              _FailingRateService(),
            ),
            localSelfIdProvider.overrideWith((ref) async => 'device-1'),
          ],
          child: LedgerEditPage(ledger: ledger),
        ),
      ),
    );
    await tester.runAsync(() async {
      await tester.pumpAndSettle();
    });
    // localSelfId 等异步链的收尾 timer 消化。
    await tester.pump(const Duration(seconds: 3));
    return l10n;
  }

  /// 展开右上角「更多」菜单并点击指定项。
  Future<void> tapMoreAction(WidgetTester tester, String label) async {
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// 在确认对话框点「确定」。
  Future<void> confirmDialog(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, '确定'));
    await tester.pumpAndSettle();
  }

  group('保存流', () {
    testWidgets('新建：名称必填校验，不填不落库', (tester) async {
      final l10n = await pump(tester);
      await tester.tap(find.text(l10n.ledgersCreate));
      await tester.pumpAndSettle();

      // 校验失败提示 = 名称标签文本，且页面仍在。
      expect(find.text(l10n.ledgerNameLabel), findsWidgets);
      final ledgers = await db.select(db.ledgers).get();
      expect(ledgers, isEmpty);
    });

    testWidgets('新建：填写名称保存成功，AA 开关与虚拟用户随账本落库', (tester) async {
      final l10n = await pump(tester);

      // 开启 AA 开关（TextStateSwitch 轨道点击切换）。
      await tester.tap(find.byType(TextStateSwitch));
      await tester.pumpAndSettle();
      // 添加一个虚拟用户（自动命名）。
      await tester.tap(find.text('添加虚拟用户'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '新账本');
      await tester.tap(find.text(l10n.ledgersCreate));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      final ledgers = await db.select(db.ledgers).get();
      expect(ledgers, hasLength(1));
      expect(ledgers.single.name, '新账本');
      expect(ledgers.single.aaEnabled, isTrue);
      final vus = await (db.select(
        db.ledgerMembers,
      )..where((m) => m.memberType.equals('PLACEHOLDER'))).get();
      expect(vus, hasLength(1));
      // 新建成功 toast。
      expect(find.text(l10n.ledgersCreateSuccess), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('编辑：改名并开启 AA 保存，updateLedger 落库', (tester) async {
      final ledger = await seed(aaEnabled: false);
      final l10n = await pump(tester, ledger: ledger);

      await tester.enterText(find.byType(TextFormField).first, '改名后');
      await tester.tap(find.byType(TextStateSwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonSave));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      final row = await repo.getLedgerById(ledger.id);
      expect(row!.name, '改名后');
      expect(row.aaEnabled, isTrue);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('编辑：无任何变更直接保存关闭', (tester) async {
      final ledger = await seed();
      final l10n = await pump(tester, ledger: ledger);

      await tester.tap(find.text(l10n.commonSave));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });
      final row = await repo.getLedgerById(ledger.id);
      expect(row!.name, '测试账本');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('编辑：切换币种保存，applyLedgerCurrencyChange 落库', (tester) async {
      final ledger = await seed();
      final l10n = await pump(tester, ledger: ledger);

      // 点击币种行打开选择器。
      await tester.tap(find.text('CNY (¥)'));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });
      // 选 USD。
      await tester.tap(find.textContaining('美元'));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      await tester.tap(find.text(l10n.commonSave));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });
      final row = await repo.getLedgerById(ledger.id);
      expect(row!.currency, 'USD');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('编辑：月起始日选择器更新并保存', (tester) async {
      final ledger = await seed();
      final l10n = await pump(tester, ledger: ledger);

      // 点击月起始日行打开 28 宫格选择器。
      await tester.tap(find.text(l10n.ledgersMonthStartDayNatural));
      await tester.pumpAndSettle();
      expect(
        find.byType(SheetGrabHandle),
        findsOneWidget,
        reason: '底部弹层应有统一拖拽条',
      );
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });
      final row = await repo.getLedgerById(ledger.id);
      expect(row!.monthStartDay, 15);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('加载失败与重试', () {
    testWidgets('账本行缺失：错误态 + 重试恢复', (tester) async {
      final ledger = await seed();
      // 先删掉账本行模拟加载失败。
      await (db.delete(db.ledgers)..where((l) => l.id.equals(ledger.id))).go();
      final l10n = await pump(tester, ledger: ledger);

      expect(find.text(l10n.categoryDetailLoadFailed), findsOneWidget);
      expect(find.text(l10n.analyticsRetry), findsOneWidget);
      expect(find.text(l10n.commonSave), findsNothing);

      // 恢复账本行后重试 → 正常加载。
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledger.id,
              name: ledger.name,
              currency: const Value('CNY'),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          );
      await tester.tap(find.text(l10n.analyticsRetry));
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });
      expect(find.text(l10n.commonSave), findsOneWidget);
      expect(find.text(l10n.categoryDetailLoadFailed), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('危险区操作', () {
    testWidgets('清空账本：确认后清空交易并 toast', (tester) async {
      final ledger = await seed();
      // 预置一笔交易。
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'tx-1',
              ledgerId: ledger.id,
              txType: 'expense',
              amount: '100',
              happenedAt: DateTime.now(),
              currencyCode: 'CNY',
              nativeAmount: '100',
              createdAt: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          );
      final l10n = await pump(tester, ledger: ledger);

      await tapMoreAction(tester, l10n.ledgersClear);
      await confirmDialog(tester);

      final txs = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(ledger.id))).get();
      expect(txs, isEmpty);
      expect(find.text(l10n.ledgersClearSuccess), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('删除个人账本：确认后本地删行 + 成功', (tester) async {
      final ledger = await seed(name: '待删账本');
      final l10n = await pump(tester, ledger: ledger);

      await tapMoreAction(tester, l10n.ledgersDelete);
      await confirmDialog(tester);
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      final rows = await db.select(db.ledgers).get();
      expect(rows, isEmpty, reason: '删除走 repo.deleteLedger 本地删行');
      expect(find.text(l10n.ledgersDeleted), findsOneWidget);
      expect(find.byType(LedgerEditPage), findsNothing, reason: '删除成功应返回上一页');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('删除个人账本：用户取消确认不删除', (tester) async {
      final ledger = await seed(name: '保留账本');
      final l10n = await pump(tester, ledger: ledger);

      await tapMoreAction(tester, l10n.ledgersDelete);
      await tester.tap(find.widgetWithText(OutlinedButton, '取消'));
      await tester.pumpAndSettle();

      final rows = await db.select(db.ledgers).get();
      expect(rows, hasLength(1), reason: '取消确认不得删行');
    });

    testWidgets('删除当前账本：切换到剩余账本', (tester) async {
      final l1 = await seed(id: 'ledger-a', name: '账本A');
      await seed(id: 'ledger-b', name: '账本B');
      final l10n = await pump(tester, ledger: l1, currentLedgerId: 'ledger-a');

      await tapMoreAction(tester, l10n.ledgersDelete);
      await confirmDialog(tester);
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      // 当前账本被删后列表只留 B，且页面已 pop。
      final rows = await db.select(db.ledgers).get();
      expect(rows.map((r) => r.id), ['ledger-b']);
      expect(
        find.byType(LedgerEditPage),
        findsNothing,
        reason: '删除当前账本成功后应返回上一页',
      );
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('删除个人账本失败：错误弹窗', (tester) async {
      final ledger = await seed(name: '删不掉');
      // 注入删除必失败的仓库。
      final failRepo = _FailDeleteRepo(db);
      final l10n = await pump(tester, ledger: ledger, useRepo: failRepo);

      await tapMoreAction(tester, l10n.ledgersDelete);
      await confirmDialog(tester);
      await tester.runAsync(() async {
        await tester.pumpAndSettle();
      });

      expect(find.text(l10n.commonOperationFailed), findsWidgets);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('共享账本危险区(删除共享账本/退出并删除)', () {
    /// 构造共享账本展示项 + 编排 mock 的公共桩。
    Future<_MockLedgerActions> stubActions(
      LedgerDisplayItem ledger,
      LedgerDisplayItem other,
    ) async {
      final actions = _MockLedgerActions();
      // 编辑页加载走 getById；危险区切换账本走 getAll。
      when(() => actions.getById(any())).thenAnswer((_) async => ledger);
      when(() => actions.getAll()).thenAnswer((_) async => [ledger, other]);
      return actions;
    }

    testWidgets('Owner：确认「删除共享账本」→ 编排执行 + toast + 返回列表', (tester) async {
      final ledger = await seed(
        id: 'shared-owner-flow',
        name: '共享账本A',
        isShared: true,
        myRole: 'owner',
        storageMode: 'cloud',
      );
      final other = await seed(id: 'other-1', name: '账本B');
      final actions = await stubActions(ledger, other);
      when(
        () => actions.deleteSharedAsOwner('shared-owner-flow'),
      ).thenAnswer((_) async {});
      final l10n = await pump(tester, ledger: ledger, actions: actions);

      await tapMoreAction(tester, l10n.ledgersDeleteShared);
      await confirmDialog(tester);
      await tester.runAsync(() => tester.pumpAndSettle());

      verify(() => actions.deleteSharedAsOwner('shared-owner-flow')).called(1);
      expect(find.text(l10n.ledgersDeleteSharedSuccess), findsOneWidget);
      expect(find.byType(LedgerEditPage), findsNothing, reason: '删除成功应返回上一页');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('协作者：确认「退出并删除」→ 编排执行 + toast + 返回列表', (tester) async {
      final ledger = await seed(
        id: 'shared-editor-flow',
        name: '共享账本A',
        isShared: true,
        myRole: 'editor',
        storageMode: 'cloud',
      );
      final other = await seed(id: 'other-2', name: '账本B');
      final actions = await stubActions(ledger, other);
      when(
        () => actions.leaveSharedLedger('shared-editor-flow'),
      ).thenAnswer((_) async {});
      final l10n = await pump(tester, ledger: ledger, actions: actions);

      await tapMoreAction(tester, l10n.ledgersLeaveAndDelete);
      await confirmDialog(tester);
      await tester.runAsync(() => tester.pumpAndSettle());

      verify(() => actions.leaveSharedLedger('shared-editor-flow')).called(1);
      expect(find.text(l10n.ledgersLeaveAndDeleteSuccess), findsOneWidget);
      expect(find.byType(LedgerEditPage), findsNothing, reason: '退出成功应返回上一页');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('取消确认：不触发任何编排调用，账本保留', (tester) async {
      final ledger = await seed(
        id: 'shared-owner-cancel',
        name: '共享账本A',
        isShared: true,
        myRole: 'owner',
        storageMode: 'cloud',
      );
      final other = await seed(id: 'other-3', name: '账本B');
      final actions = await stubActions(ledger, other);
      final l10n = await pump(tester, ledger: ledger, actions: actions);

      await tapMoreAction(tester, l10n.ledgersDeleteShared);
      await tester.tap(find.widgetWithText(OutlinedButton, '取消'));
      await tester.pumpAndSettle();

      verifyNever(() => actions.deleteSharedAsOwner(any()));
      expect(find.byType(LedgerEditPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('编排失败：错误弹窗且页面保留', (tester) async {
      final ledger = await seed(
        id: 'shared-owner-fail',
        name: '共享账本A',
        isShared: true,
        myRole: 'owner',
        storageMode: 'cloud',
      );
      final other = await seed(id: 'other-4', name: '账本B');
      final actions = await stubActions(ledger, other);
      when(
        () => actions.deleteSharedAsOwner('shared-owner-fail'),
      ).thenThrow(StateError('cloud boom'));
      final l10n = await pump(tester, ledger: ledger, actions: actions);

      await tapMoreAction(tester, l10n.ledgersDeleteShared);
      await confirmDialog(tester);
      await tester.runAsync(() => tester.pumpAndSettle());

      expect(find.text(l10n.commonOperationFailed), findsWidgets);
      expect(find.byType(LedgerEditPage), findsOneWidget, reason: '失败保留现场');
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
