/// LedgerEditPage 本地账本迁云入口（编辑页存储操作区）组件测试。
///
/// 需求锚点（归属在创建时选择，但已存在的本地账本必须有迁云通道）：
/// - 编辑「本地个人账本」时展示「移动到 Sesame Notes Cloud」入口；
/// - 登录门禁：未登录时入口禁用并给出登录引导，点击不触发任何迁云动作；
/// - 二次确认：确认弹窗必须带清账本名，取消则不执行；
/// - 成功：账本翻 storage_mode='cloud' + 登记 backfill 变更 + 返回列表；
/// - 失败回滚：backfill 失败时账本整体保持本地态（底层单事务原子性），
///   页面保留并弹出失败提示。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../../helpers/test_isolation.dart';

class _MockSyncService extends Mock implements SyncService {}

/// 让 backfill 登记失败的变更登记器：事务中途抛错，用于验证整体回滚。
class _FailingChangeRecorder implements ChangeRecorder {
  _FailingChangeRecorder(this._inner);

  final ChangeRecorder _inner;

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => _inner.recordUserGlobalChange(
    entityType: entityType,
    entityId: entityId,
    action: action,
    payload: payload,
    updatedAt: updatedAt,
  );

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    throw StateError('变更登记失败（测试注入）');
  }

  @override
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes}) =>
      _inner.recordLedgerChanges(changes: changes);

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) => _inner.recordUserGlobalChanges(changes: changes);
}

const testUserId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSyncService sync;
  late ProviderContainer container;

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    sync = _MockSyncService();
    // 迁云尾部会后台推一次同步，桩掉避免 mock 抛错噪声。
    when(() => sync.push()).thenAnswer((_) async {});
    when(() => sync.pull()).thenAnswer((_) async => 0);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 装配容器：[failBackfill] 时注入会抛错的变更登记器。
  Future<void> buildContainer({
    bool loggedIn = true,
    bool failBackfill = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final recorder = ChangeRecorderImpl(db, accountIdGetter: () => testUserId);
    repo = LocalRepository(
      db,
      changeTracker: failBackfill ? _FailingChangeRecorder(recorder) : recorder,
    );
    container = ProviderContainer(
      overrides: [
        // 成员统计等子模块会经 databaseProvider 取库，注入同一内存库。
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(null),
        ),
      ],
    );
    if (loggedIn) {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 't',
              userId: testUserId,
              deviceId: 'd',
            ),
          );
    }
  }

  /// 建一本带一条交易的本地账本（含 LOCAL 本人成员，迁云的前置身份）。
  Future<LedgerDisplayItem> seedLocalLedger(String name) async {
    final id = await repo.createLedger(
      name: name,
      storageMode: 'local',
      localSelfId: 'device-self',
    );
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    return LedgerDisplayItem.fromLocal(
      id: id,
      name: name,
      currency: 'CNY',
      createdAt: DateTime(2026, 1, 1),
      transactionCount: 1,
      expenseTotal: 10,
    );
  }

  Future<AppLocalizations> pump(
    WidgetTester tester,
    LedgerDisplayItem ledger,
  ) async {
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
          home: LedgerEditPage(ledger: ledger),
        ),
      ),
    );
    await tester.runAsync(() => tester.pumpAndSettle());
    return l10n;
  }

  testWidgets('未登录：入口可见但禁用 + 登录引导，点击不触发迁云', (tester) async {
    await buildContainer(loggedIn: false);
    final ledger = await seedLocalLedger('本地账本');
    final l10n = await pump(tester, ledger);

    expect(find.text(l10n.ledgersActionMoveToCloud), findsOneWidget);
    expect(find.text(l10n.ledgersSectionCloudSignInHint), findsOneWidget);
    final tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(l10n.ledgersActionMoveToCloud),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.enabled, isFalse, reason: '未登录必须禁用迁云入口，不留误点机会');

    await tester.tap(find.text(l10n.ledgersActionMoveToCloud));
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.ledgersMoveToCloudMessage('本地账本')),
      findsNothing,
      reason: '禁用态点击不得进入确认流程',
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('已登录：确认后账本翻云 + 登记 backfill 变更 + 返回列表', (tester) async {
    await buildContainer();
    final ledger = await seedLocalLedger('本地账本');
    final l10n = await pump(tester, ledger);

    await tester.ensureVisible(find.text(l10n.ledgersActionMoveToCloud));
    await tester.tap(find.text(l10n.ledgersActionMoveToCloud));
    await tester.pumpAndSettle();

    // 二次确认：文案必须点明是哪本账本上云
    expect(find.text(l10n.ledgersMoveToCloudMessage('本地账本')), findsOneWidget);
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.runAsync(() => tester.pumpAndSettle());

    final row = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledger.id))).getSingle();
    expect(row.storageMode, 'cloud', reason: '迁云后归属必须翻为云端');
    expect(row.scopeAccountId, testUserId, reason: 'backfill 归属当前账号');
    final changes = await db.select(db.syncChanges).get();
    expect(changes, isNotEmpty, reason: '本地历史数据必须补登记 backfill 变更');
    expect(changes.every((c) => c.accountId == testUserId), isTrue);
    expect(find.text(l10n.ledgersMoveToCloudSuccess), findsOneWidget);
    expect(find.byType(LedgerEditPage), findsNothing, reason: '归属已变，必须返回列表');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('取消确认：不执行迁云，账本保持本地且无变更', (tester) async {
    await buildContainer();
    final ledger = await seedLocalLedger('本地账本');
    final l10n = await pump(tester, ledger);

    await tester.ensureVisible(find.text(l10n.ledgersActionMoveToCloud));
    await tester.tap(find.text(l10n.ledgersActionMoveToCloud));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonCancel));
    await tester.runAsync(() => tester.pumpAndSettle());

    final row = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledger.id))).getSingle();
    expect(row.storageMode, 'local', reason: '取消后账本属性不得变动');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(find.byType(LedgerEditPage), findsOneWidget, reason: '取消后留在编辑页');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('失败回滚：backfill 抛错 → 账本保持本地态 + 失败弹窗 + 页面保留', (tester) async {
    await buildContainer(failBackfill: true);
    final ledger = await seedLocalLedger('本地账本');
    final l10n = await pump(tester, ledger);

    await tester.ensureVisible(find.text(l10n.ledgersActionMoveToCloud));
    await tester.tap(find.text(l10n.ledgersActionMoveToCloud));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonConfirm));
    await tester.runAsync(() => tester.pumpAndSettle());

    // 事务整体回滚：归属、本人成员、变更队列都不留半成品
    final row = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledger.id))).getSingle();
    expect(row.storageMode, 'local', reason: '失败必须整体回滚，不得停在半上云态');
    expect(row.selfMemberId, isNotNull, reason: '本人成员引用保持原值');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(find.text(l10n.commonOperationFailed), findsOneWidget);
    expect(find.byType(LedgerEditPage), findsOneWidget, reason: '失败保留现场');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('云端账本：不展示迁云入口', (tester) async {
    await buildContainer();
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await repo.createBoundLedger(id: 'cloud-1', name: '云端账本', syncId: 's');
    final ledger = LedgerDisplayItem.fromLocal(
      id: 'cloud-1',
      name: '云端账本',
      currency: 'CNY',
      createdAt: DateTime(2026, 1, 1),
      transactionCount: 0,
      expenseTotal: 0,
      storageMode: 'cloud',
    );
    await pump(tester, ledger);

    expect(
      find.text(l10n.ledgersActionMoveToCloud),
      findsNothing,
      reason: '账本已在云端，迁云入口无意义',
    );
    await tester.pump(const Duration(seconds: 3));
  });

  group('存储操作项(移动到本地/复制到本地)', () {
    /// 云端非共享账本展示项（scope 归测试账号，移动到本地的账号域校验前提）。
    Future<LedgerDisplayItem> seedCloudLedger(String id, String name) async {
      await repo.createBoundLedger(id: id, name: name, syncId: 's');
      await (db.update(db.ledgers)..where((l) => l.id.equals(id))).write(
        LedgersCompanion(scopeAccountId: d.Value(testUserId)),
      );
      return LedgerDisplayItem.fromLocal(
        id: id,
        name: name,
        currency: 'CNY',
        createdAt: DateTime(2026, 1, 1),
        transactionCount: 0,
        expenseTotal: 0,
        storageMode: 'cloud',
      );
    }

    testWidgets('云端非共享账本：显示「移动到本地」+「复制到本地」，无迁云项', (tester) async {
      await buildContainer();
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final ledger = await seedCloudLedger('cloud-2', '云端账本');
      await pump(tester, ledger);

      await tester.ensureVisible(find.text(l10n.ledgersActionMoveToLocal));
      expect(find.text(l10n.ledgersActionMoveToLocal), findsOneWidget);
      expect(find.text(l10n.ledgersActionCopyToLocal), findsOneWidget);
      expect(find.text(l10n.ledgersActionMoveToCloud), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('共享账本(协作者只读)：仅显示「复制到本地」', (tester) async {
      await buildContainer();
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final ledger = await seedCloudLedger('cloud-3', '共享账本');
      final shared = LedgerDisplayItem.fromLocal(
        id: ledger.id,
        name: ledger.name,
        currency: ledger.currency,
        createdAt: DateTime(2026, 1, 1),
        transactionCount: 0,
        expenseTotal: 0,
        storageMode: 'cloud',
        isShared: true,
        memberCount: 2,
        myRole: 'editor',
      );
      await pump(tester, shared);

      await tester.ensureVisible(find.text(l10n.ledgersActionCopyToLocal));
      expect(find.text(l10n.ledgersActionCopyToLocal), findsOneWidget);
      expect(find.text(l10n.ledgersActionMoveToLocal), findsNothing);
      expect(find.text(l10n.ledgersActionMoveToCloud), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('未登录：移动到本地/复制到本地禁用 + 登录引导', (tester) async {
      await buildContainer(loggedIn: false);
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final ledger = await seedCloudLedger('cloud-4', '云端账本');
      await pump(tester, ledger);

      await tester.ensureVisible(find.text(l10n.ledgersActionMoveToLocal));
      expect(find.text(l10n.ledgersSectionCloudSignInHint), findsOneWidget);
      for (final label in [
        l10n.ledgersActionMoveToLocal,
        l10n.ledgersActionCopyToLocal,
      ]) {
        final tile = tester.widget<ListTile>(
          find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
        );
        expect(tile.enabled, isFalse, reason: '未登录必须禁用归属操作');
      }
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('移动到本地：确认后云端账本删除并发布本地副本，返回列表', (tester) async {
      await buildContainer();
      when(
        () => sync.pushLedgerDelete(ledgerId: any(named: 'ledgerId')),
      ).thenAnswer((_) async => 'accepted');
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final ledger = await seedCloudLedger('cloud-5', '云端账本');
      await pump(tester, ledger);

      await tester.ensureVisible(find.text(l10n.ledgersActionMoveToLocal));
      await tester.tap(find.text(l10n.ledgersActionMoveToLocal));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.runAsync(() => tester.pumpAndSettle());

      // 源云端账本删除，隐藏 Fork 发布为新的本地账本。
      final rows = await db.select(db.ledgers).get();
      expect(
        rows.where((r) => r.id == ledger.id),
        isEmpty,
        reason: '源云端账本必须删除',
      );
      expect(rows, hasLength(1), reason: '隐藏 Fork 发布为唯一本地账本');
      expect(rows.single.storageMode, 'local');
      expect(find.text(l10n.ledgersMoveToLocalSuccess), findsOneWidget);
      expect(find.byType(LedgerEditPage), findsNothing, reason: '归属已变，必须返回列表');
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('复制到本地：确认后云端原件保留 + 新本地副本落库 + 页面保留', (tester) async {
      await buildContainer();
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final ledger = await seedCloudLedger('cloud-6', '云端账本');
      await pump(tester, ledger);

      await tester.ensureVisible(find.text(l10n.ledgersActionCopyToLocal));
      await tester.tap(find.text(l10n.ledgersActionCopyToLocal));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.runAsync(() => tester.pumpAndSettle());

      final rows = await db.select(db.ledgers).get();
      expect(rows, hasLength(2), reason: '云端原件 + 本地副本');
      expect(
        rows.singleWhere((r) => r.id == ledger.id).storageMode,
        'cloud',
        reason: '云端原件归属不变',
      );
      final copy = rows.singleWhere((r) => r.id != ledger.id);
      expect(copy.storageMode, 'local', reason: '副本为纯本地归属');
      expect(copy.name, '云端账本');
      expect(find.text(l10n.ledgersCopyToLocalSuccess), findsOneWidget);
      expect(
        find.byType(LedgerEditPage),
        findsOneWidget,
        reason: '云端原件未变，编辑页快照仍有效，不 pop',
      );
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
