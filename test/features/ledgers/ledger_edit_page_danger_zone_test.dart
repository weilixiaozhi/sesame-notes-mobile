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

/// [LedgerEditPage] 右上角「更多」菜单的角色门控组件测试。
///
/// 新 schema 下账本编辑页右上角 [_buildMoreMenu]（AppPopupMenu）只承载两类
/// 敏感操作，菜单项按「是否所有者」与「是否共享」动态生成：
///   - 所有者共享账本 → 仅「清空」；
///   - 协作者共享账本 → 无任何危险项（只读，不给操作入口）；
///   - 本地（非共享）账本 → 「清空」+「删除账本」。
///
/// 共享性由 memberCount>1 表达、角色由 role 列表达（owner/editor），
/// LedgersCompanion 必填 id/updatedAt。
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

  /// 创建菜单角色测试所需的账本。
  Future<LedgerDisplayItem> seed(
    String id,
    bool isShared,
    String myRole,
  ) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: 'L-$id',
            currency: const Value('CNY'),
            role: Value(myRole),
            memberCount: Value(isShared ? 2 : 1),
            // 共享账本归属云端、本地账本归属本地，与列表分区语义一致。
            storageMode: Value(isShared ? 'cloud' : 'local'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    return LedgerDisplayItem.fromLocal(
      id: id,
      name: 'L-$id',
      currency: 'CNY',
      createdAt: DateTime.now(),
      transactionCount: 0,
      expenseTotal: 0,
      isShared: isShared,
      memberCount: isShared ? 2 : 1,
      myRole: myRole,
    );
  }

  /// 挂载指定账本的编辑页并返回中文本地化资源。
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
    // 编辑页读取 localSelfIdProvider 时会写日志并调度 2 秒节流保存；
    // 测试结束前推进虚拟时钟让定时器到期，避免 !timersPending 报错。
    await tester.pump(const Duration(seconds: 3));
    return l10n;
  }

  /// 展开右上角「更多」菜单，让菜单项文本进入组件树供断言使用。
  Future<void> openMoreMenu(WidgetTester tester) async {
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
  }

  testWidgets('所有者共享账本 → 菜单仅含「清空」,不含「删除账本」/共享按钮', (tester) async {
    final ledger = await seed('ext-owner', true, 'owner');
    final l10n = await pump(tester, ledger);
    await openMoreMenu(tester);
    // 所有者共享账本：保留可逆的清空入口，不给本地删除入口，
    // 也不再提供「删除共享账本/退出并删除」等云端协作动作。
    expect(find.text(l10n.ledgersClear), findsOneWidget);
    expect(find.text(l10n.ledgersDelete), findsNothing);
    expect(find.text(l10n.ledgersDeleteShared), findsNothing);
    expect(find.text(l10n.ledgersLeaveAndDelete), findsNothing);
  });

  testWidgets('协作者共享账本 → 菜单无任何危险项', (tester) async {
    final ledger = await seed('ext-editor', true, 'editor');
    final l10n = await pump(tester, ledger);
    await openMoreMenu(tester);
    // 协作者只读：清空（仅所有者）与删除（仅非共享）的门控条件均不满足，
    // 菜单为空，杜绝越权操作入口。
    expect(find.text(l10n.ledgersClear), findsNothing);
    expect(find.text(l10n.ledgersDelete), findsNothing);
    expect(find.text(l10n.ledgersDeleteShared), findsNothing);
    expect(find.text(l10n.ledgersLeaveAndDelete), findsNothing);
  });

  testWidgets('本地（非共享）账本 → 菜单含「清空」+「删除账本」,不含共享按钮', (tester) async {
    // myRole 用 'owner':个人账本删除按钮的门控条件为 !isShared,
    // 这里保持模型默认角色语义（非共享账本恒为 owner）。
    final ledger = await seed('local-1', false, 'owner');
    final l10n = await pump(tester, ledger);
    await openMoreMenu(tester);
    // 本地账本既是所有者（可清空）又非共享（可删除），两项危险入口都在。
    expect(find.text(l10n.ledgersClear), findsOneWidget);
    expect(find.text(l10n.ledgersDelete), findsOneWidget);
    expect(find.text(l10n.ledgersDeleteShared), findsNothing);
    expect(find.text(l10n.ledgersLeaveAndDelete), findsNothing);
  });
}
