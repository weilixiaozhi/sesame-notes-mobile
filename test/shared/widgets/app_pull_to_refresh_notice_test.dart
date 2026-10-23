import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_pull_to_refresh.dart';

/// 未解决的同步提示在不足刷新阈值的手势后仍须保持可见。
void main() {
  testWidgets('短距离下拉不能收起常驻同步提示', (tester) async {
    var refreshes = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppPullToRefresh(
            notice: '仍有同步问题',
            onRefresh: () async {
              refreshes++;
              return null;
            },
            child: ListView(
              physics: AppPullToRefresh.physics,
              children: const [SizedBox(height: 1000, child: Text('内容'))],
            ),
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(refreshes, 0);
    final indicator = tester.widget<SizeTransition>(
      find.byType(SizeTransition),
    );
    expect(indicator.sizeFactor.value, 1, reason: '提示依然存在，未触发刷新的下拉手势不能隐藏处理入口');
  });
}
