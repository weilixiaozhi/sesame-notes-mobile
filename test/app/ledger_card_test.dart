/// LedgerCard 共享账本角标图标测试。
///
/// 锁定:共享账本角标使用 AppIcons.people(与成员管理入口一致),
/// 使用 people 图标 + 成员数文本;状态图标按 storageMode 区分
/// (cloud → 云形,local → 灰色硬盘)。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/ledger_card.dart';

/// 构造账本展示项 — storageMode 'local' 时卡片状态图标走本地硬盘分支。
LedgerDisplayItem _ledger({required bool isShared, int memberCount = 1}) =>
    LedgerDisplayItem(
      id: 'ledger-1',
      name: '测试账本',
      currency: 'CNY',
      transactionCount: 3,
      expenseTotal: 12.5,
      lastUpdated: DateTime(2026, 1, 1),
      isShared: isShared,
      memberCount: memberCount,
      storageMode: 'local',
    );

/// 构造指定 storageMode 的账本展示项(供状态图标测试使用)。
LedgerDisplayItem _display({required String storageMode}) => LedgerDisplayItem(
  id: 'ledger-99',
  name: '图标测试账本',
  currency: 'CNY',
  transactionCount: 0,
  expenseTotal: 0,
  lastUpdated: DateTime(2026, 1, 1),
  storageMode: storageMode,
);

Future<void> _pump(
  WidgetTester tester,
  LedgerDisplayItem ledger, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LedgerCard(ledger: ledger)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('共享账本角标使用 people 图标 + 成员数,不再用握手图标', (tester) async {
    await _pump(tester, _ledger(isShared: true, memberCount: 2));

    expect(find.byIcon(AppIcons.people), findsOneWidget);
    expect(find.byIcon(LucideIcons.heartHandshake), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('非共享账本不渲染成员角标', (tester) async {
    await _pump(tester, _ledger(isShared: false));

    expect(find.byIcon(AppIcons.people), findsNothing);
    expect(find.byIcon(LucideIcons.heartHandshake), findsNothing);
  });

  testWidgets('不向用户展示本地自增 ID', (tester) async {
    await _pump(tester, _ledger(isShared: false));

    expect(
      find.textContaining('ID:'),
      findsNothing,
      reason: '内部自增 ID 对用户无意义且跨设备不一致，不应展示',
    );
  });

  group('状态图标(按 storageMode)', () {
    testWidgets('云端账本恒为云形图标', (tester) async {
      final ledger = _display(storageMode: 'cloud');
      await _pump(tester, ledger);

      // 云形图标必然存在(头部头像 + 状态图标各一个)
      expect(find.byIcon(AppIcons.cloudQueue), findsWidgets);
      expect(find.byIcon(AppIcons.localStorage), findsNothing);
    });

    testWidgets('本地账本显示灰色硬盘图标', (tester) async {
      final ledger = _display(storageMode: 'local');
      await _pump(tester, ledger);

      expect(find.byIcon(AppIcons.localStorage), findsOneWidget);
      expect(find.byIcon(AppIcons.cloudQueue), findsNothing);
    });
  });
}
